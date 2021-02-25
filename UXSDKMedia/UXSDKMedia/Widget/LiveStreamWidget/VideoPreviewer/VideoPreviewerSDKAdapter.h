//
//  VideoPreviewerSDKAdapter.h
//  VideoPreviewer
//
//  MIT License
//  
//  Copyright © 2018-2020 DJI
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

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>
#import <DJIWidget/DJIVideoPreviewer.h>

@class DJIVideoPreviewer;
@class VideoPreviewerSDKAdapter;

@protocol VideoPreviewerSDKAdapterDelegate <NSObject>

@optional

- (void)videoPreviewerSDKAdapter:(nonnull VideoPreviewerSDKAdapter *)adapter didChangeCurrentCameraIndexTo:(NSUInteger)currentCameraIndex;

@end

@interface VideoPreviewerSDKAdapter : NSObject <DJIVideoFeedSourceListener, DJIVideoFeedListener, DJIVideoPreviewerFrameControlDelegate>

+ (nonnull instancetype)defaultAdapterWithVideoPreviewer:(nonnull DJIVideoPreviewer *)videoPreviewer;

+ (nonnull instancetype)lightbridge2AdapterWithVideoPreviewer:(nonnull DJIVideoPreviewer *)videoPreviewer;

+ (nonnull instancetype)adapterWithVideoPreviewer:(nonnull DJIVideoPreviewer *)videoPreviewer
                                     andVideoFeed:(nonnull DJIVideoFeed *)videoFeed;

+ (nonnull instancetype)adapterWithAircraftModel:(nonnull NSString *)model
                                  videoPreviewer:(nonnull DJIVideoPreviewer *)videoPreviewer
                                       videoFeed:(nonnull DJIVideoFeed *)videoFeed;

@property (nonatomic, weak, nullable) DJIVideoPreviewer *videoPreviewer;

@property (nonatomic, weak, nullable) DJIVideoFeed *videoFeed;

@property (nonatomic, assign) NSUInteger preferredCameraIndex;

@property (nonatomic, assign, readonly) NSUInteger currentCameraIndex;

@property (nonatomic, weak, nullable) id <VideoPreviewerSDKAdapterDelegate> delegate;

- (void)start;

- (void)stop;

@end
