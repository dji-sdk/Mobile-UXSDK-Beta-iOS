//
//  DUXBetaEMMStatusListItemWidgetModel.m
//  
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

#import "DUXBetaEMMCStatusListItemWidgetModel.h"

@interface DUXBetaEMMCStatusListItemWidgetModel ()

@property (nonatomic, readwrite) BOOL       isInternalStorageSupported;
@property (nonatomic, readwrite) DJICameraSDCardOperationState internalStorageOperationState;
@property (nonatomic, readwrite) NSInteger  freeStorageInMB;
@property (nonatomic, readwrite) BOOL       isInternalStorageInserted;
@property (nonatomic, readwrite) NSError    *formatError;

/**
 * The camera index this model is currently observing. Defaults to camera 0.
 */
@property (nonatomic, readwrite) NSUInteger preferredCameraIndex;


@end

@implementation DUXBetaEMMCStatusListItemWidgetModel

- (void)inSetup {
    [self bindKeys];
}

- (void)bindKeys {
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamIsInternalStorageSupported], isInternalStorageSupported);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamInternalStorageRemainingSpaceInMB], freeStorageInMB);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamInternalStorageOperationState], internalStorageOperationState);
    
    BindRKVOModel(self, @selector(storageStateChanged), internalStorageOperationState);
}

- (void)inCleanup {
    UnBindSDK;
}

- (void)setPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    if (_preferredCameraIndex != preferredCameraIndex) {
        [self bindKeys];
    }
}

- (void)storageStateChanged {
    if (_internalStorageOperationState == DJICameraSDCardOperationStateNotInserted) {
        self.isInternalStorageInserted = NO;
    } else {
        self.isInternalStorageInserted = YES;
        
    }
}
- (NSString *)formatErrorDescription {
    if (self.formatError != nil) {
        return [NSString stringWithFormat:@"\n%@", self.formatError.localizedDescription];
    }
    
    return @"";
}


- (void)formatSDCard {
    __weak DUXBetaEMMCStatusListItemWidgetModel *weakSelf = self;
    DJICameraKey *cameraKey = [DJICameraKey keyWithIndex:_preferredCameraIndex andParam:DJICameraParamFormatStorage];
    
    [[DJISDKManager keyManager] performActionForKey:cameraKey
                                      withArguments:@[@(DJICameraStorageLocationInternalStorage)]
                                      andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
        // This completion is only for the performAction method, not for the results of the format action. It will
        // not report when formating is completed, only if there are paraeter errors with this call.
        __strong DUXBetaEMMCStatusListItemWidgetModel *strongSelf = weakSelf;
        
        strongSelf.formatError = error;
        if (error != nil) {
            strongSelf.sdCardFormatError = YES;
        } else {
            strongSelf.sdCardFormatError = NO;
        }
    }];
    
}

@end
