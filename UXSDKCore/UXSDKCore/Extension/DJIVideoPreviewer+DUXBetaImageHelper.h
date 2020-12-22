//
//  DJIVideoPreviewer+ImageHelper.h
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

#import <DJIWidget/DJIWidget.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^snapshotReceiverBlock)(UIImage* snapshot);

/**
 * The methods in the DJIVideoPreviewer ImageHelper category are designed to facilitate easy snapshot access from the previewer
 * by supporting multiple snapshot invocations instead of a single invocation. It also will remove callbacks which contain
 * no image data.
 */
// This helper extension only supports snapshots, not thumbnails currently.
@interface  DJIVideoPreviewer (ImageHelper)
@property (nonatomic, strong) NSMutableDictionary *DUXBetaSnapshottersDict;

/**
 * Call addPersistentSnapshotPreview to add a callback block for snapshots which will be called for each decoded frame. This block
 * will be persisted internally and used multiple times.
 */
- (void)addPersistentSnapshotPreview:(snapshotReceiverBlock)persisentBlock;

/**
 * Call removePersistentSnapshotPreview to remove the persistent block added with addPersistentSnapshotPreview, which will prevent it
 * from being called again.
 */
- (void)removePersistentSnapshotPreview:(snapshotReceiverBlock)persisentBlock;

/**
 * Call addOneshotSnapshotPreview to receive a one time image callback when the next previewer frame is ready and has an image.
 * The block will be called once and removed from the callback list.
 */
- (void)addOneshotSnapshotPreview:(snapshotReceiverBlock)persisentBlock;
@end

NS_ASSUME_NONNULL_END
