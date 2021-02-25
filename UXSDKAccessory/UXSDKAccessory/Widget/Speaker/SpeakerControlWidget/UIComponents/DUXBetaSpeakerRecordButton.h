//
//  DUXBetaSpeakerRecordButton.h
//  UXSDKAccessory
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

#import <UIKit/UIKit.h>
#import "DUXBetaSpeakerProgressView.h"
#import "DUXBetaSpeakerUploadingView.h"

typedef NS_ENUM(NSUInteger, DUXBetaSpeakerRecordButtonState) {
    DUXBetaSpeakerRecordButtonStateIdle,
    DUXBetaSpeakerRecordButtonStateNormal,
    DUXBetaSpeakerRecordButtonStateRecording,
    DUXBetaSpeakerRecordButtonStateUploading,
    DUXBetaSpeakerRecordButtonStateSuccess,
    DUXBetaSpeakerRecordButtonStateFailed
};

typedef NS_ENUM(NSUInteger, DUXBetaSpeakerRecordButtonRecordingType) {
    DUXBetaSpeakerRecordButtonRecordingTemporary,
    DUXBetaSpeakerRecordButtonRecordingPermanent,
};

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaSpeakerRecordButton : UIView

@property (nonatomic, assign) DUXBetaSpeakerRecordButtonState state;
@property (nonatomic, assign) DUXBetaSpeakerRecordButtonRecordingType recordingType;
@property (nonatomic, strong) DUXBetaSpeakerProgressView *progressView;
@property (nonatomic, strong) DUXBetaSpeakerUploadingView *uploadingView;

@property (nonatomic, assign) NSTimeInterval currentTimestamp;

- (void)setSentSize:(NSUInteger)send totalSize:(NSUInteger)totalSize;

@property (nonatomic, copy) void (^startInstantRecordingAction)(void);
@property (nonatomic, copy) void (^stopInstantRecordingAction)(void);
@property (nonatomic, copy) void (^startListRecordingAction)(void);
@property (nonatomic, copy) void (^stopListRecordingAction)(void);
@property (nonatomic, copy) void (^recordingDurationFullCallback)(void);

- (void)setSpeakerImage:(UIImage *)speakerImage forRecordingState:(DUXBetaSpeakerRecordButtonState)recordingState;
- (UIImage *)getSpeakerImageForRecordingState:(DUXBetaSpeakerRecordButtonState)recordingState;

@property (nonatomic, strong) UIColor *recordButtonLabelTextColor;
@property (nonatomic, strong) UIFont *recordButtonLabelFont;

@property (nonatomic, strong) UIColor *recordingTimeLabelTextColor;
@property (nonatomic, strong) UIFont *recordingTimeLabelFont;

@end

NS_ASSUME_NONNULL_END
