//
//  DUXBetaFPVDecodeModel.h
//  DJIUXSDKWidgets
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>
#import <DJISDK/DJISDK.h>
#import <DJIWidget/DJIWidget.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Data model for the decoding adapter used to define
 *  the underlying logic and communication.
*/
@interface DUXBetaFPVDecodeModel : DUXBetaBaseWidgetModel

/**
*   The frame needed by the videopreviewer to display the video feed.
*/
@property (nonatomic, assign, readonly) CGRect contentClipRect;

/**
*   The encoding type needed by the videopreviewer to display the video feed.
*/
@property (nonatomic, assign, readonly) H264EncoderType encodeType;

/**
*   Initialization method that takes a DJIVideoFeed as a parameter
*/
- (instancetype)initWithVideoFeed:(DJIVideoFeed *)videoFeed;

- (void)updateContentRect;
- (void)updateEncodeType;

@end

NS_ASSUME_NONNULL_END
