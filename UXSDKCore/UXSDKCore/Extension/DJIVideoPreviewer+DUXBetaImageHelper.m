//
//  DJIVideoPreviewer+ImageHelper.m
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DJIVideoPreviewer+DUXBetaImageHelper.h"
#import <objc/runtime.h>

// Key for the dict in the associated object.
static void *DUXBetaSnapshottersDictKey = "DUXBetaSnapshottersDictKey";
// The global queue for the snapshotter.
static dispatch_queue_t _DUXBetaSnapshotterHelperQueue;

// Macro to validated and create snapshotter dispatch queue if needed.
#define validate_processing_queue { if (_DUXBetaSnapshotterHelperQueue == nil) { _DUXBetaSnapshotterHelperQueue = dispatch_queue_create("snapshotterHelperQueue", DISPATCH_QUEUE_SERIAL); } }

@implementation  DJIVideoPreviewer (ImageHelper)

- (void)addPersistentSnapshotPreview:(snapshotReceiverBlock)persistentBlock {
    validate_processing_queue;

    NSMutableDictionary *workDict = self.DUXBetaSnapshottersDict;
    dispatch_async(_DUXBetaSnapshotterHelperQueue, ^(){
        NSMutableArray *snapshotters = workDict[@"persistent"];
        if (snapshotters == nil) {
            snapshotters = [NSMutableArray arrayWithObject:persistentBlock];
            workDict[@"persistent"] = snapshotters;
        } else {
            if ([snapshotters indexOfObject:persistentBlock] == NSNotFound) {
                [snapshotters addObject:persistentBlock];
            }
        }
        [self installMySnapshotter];

    });
}

- (void)removePersistentSnapshotPreview:(snapshotReceiverBlock)persisentBlock {
    validate_processing_queue;

    NSMutableDictionary *workDict = self.DUXBetaSnapshottersDict;
    dispatch_async(_DUXBetaSnapshotterHelperQueue, ^(){
        NSMutableArray *snapshotters = workDict[@"persistent"];
        if (snapshotters) {
            [snapshotters removeObjectsInArray:@[persisentBlock]];
        }
    });
}

- (void)addOneshotSnapshotPreview:(snapshotReceiverBlock)persistentBlock {
    validate_processing_queue;

    NSMutableDictionary *workDict = self.DUXBetaSnapshottersDict;
        dispatch_async(_DUXBetaSnapshotterHelperQueue, ^(){
        NSMutableArray *snapshotters = workDict[@"transient"];
        if (snapshotters == nil) {
            snapshotters = [NSMutableArray arrayWithObject:persistentBlock];
            workDict[@"transient"] = snapshotters;
        } else {
            [snapshotters addObject:persistentBlock];
        }
        [self installMySnapshotter];
    });
}

- (void)installMySnapshotter {
    [self snapshotPreview:^(UIImage *image) {
        // Distribute to the snapshot requests here
        // First, make a safe copy of the UIImage ourside the normal snapshot flow, then distribute. Do not thread due to
        if (image == nil) {
            // Nothing was prepped in the decoder on the install. It gave an immediate callback and didn't save the block. Try
            // again in 0.01666 seconds.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01666 * NSEC_PER_SEC)), _DUXBetaSnapshotterHelperQueue, ^{
                [self installMySnapshotter];
            });
            return;
        } else {
        }
        UIImage *safeImage = [image copy];
        NSMutableDictionary *workDict = self.DUXBetaSnapshottersDict;

        dispatch_async(_DUXBetaSnapshotterHelperQueue, ^(){
            NSMutableArray *persistent = workDict[@"persistent"];
            NSMutableArray *transient = workDict[@"transient"];
            
            NSMutableArray *nextPersistent = [NSMutableArray new];
            for (NSUInteger index = 0; index < persistent.count; index++) {
                __weak snapshotReceiverBlock callback = persistent[index];

                persistent[index] = [NSNull null];  // Allow any dangling handler to release. Now callback will also be nil
                if (callback != nil) {
                    [nextPersistent addObject:callback];    // Save the persistent callback for next time
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        callback(safeImage);
                    });
                }
            }
            workDict[@"persistent"] = nextPersistent;       // Now any surviving persistent callback can be preserved for the next snapshot
            
            if (transient) {
                // Now work through the transient list if it exists, but we don't need to save any of them off for next time.
                for (NSUInteger index = 0; index < transient.count; index++) {
                    __weak snapshotReceiverBlock callback = transient[index];
                    if (callback != nil) {
                        callback(image);
                    }
                }
                workDict[@"transient"] = nil;   // Remove all transient image callbacks
            }
        });
        // The 0.1666 seconds should support framerates up to 60fps (.0166666 seconds per frame) in case we ever have cameras that run that fast.
        // TODO: Dynamically tune the frequency better to actual decoder frequency
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01666 * NSEC_PER_SEC)), _DUXBetaSnapshotterHelperQueue, ^{
            NSMutableDictionary *workDict = self.DUXBetaSnapshottersDict;
            NSMutableArray *persistent = workDict[@"persistent"];
            NSMutableArray *transient = workDict[@"transient"];
            if ((persistent.count > 0 || (transient.count > 0))) {
                [self installMySnapshotter];
            }
        });
    }];
}

- (NSMutableDictionary*)DUXBetaSnapshottersDict {
    NSMutableDictionary *outDict = objc_getAssociatedObject(self, DUXBetaSnapshottersDictKey);
    if (outDict == nil) {
        outDict = [NSMutableDictionary new];
        self.DUXBetaSnapshottersDict = outDict;
    }
    return outDict;
}

- (void)setDUXBetaSnapshottersDict:(NSMutableDictionary*)snapshottersDict {
    objc_setAssociatedObject(self, DUXBetaSnapshottersDictKey, snapshottersDict, OBJC_ASSOCIATION_RETAIN);  // Specifically atomic access
}
@end
