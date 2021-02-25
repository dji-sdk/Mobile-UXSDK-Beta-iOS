//
//  DUXBetaSpeakerRecordButton.m
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

#import "DUXBetaSpeakerRecordButton.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>


#define SPEAKER_BUTTON_SIZE (80.0f)
#define SPEAKER_RECORDING_TIME_LIMIT (60)

@interface DUXBetaSpeakerRecordButton ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, assign) NSTimeInterval audioDuration;
@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *imageMapping;

@end

@implementation DUXBetaSpeakerRecordButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                       @(DUXBetaSpeakerRecordButtonStateIdle) : [UIImage duxbeta_imageWithAssetNamed:@"SpeakerRecordInactive" forClass:[self class]],
                                                                                       @(DUXBetaSpeakerRecordButtonStateNormal) : [UIImage duxbeta_imageWithAssetNamed:@"SpeakerRecord" forClass:[self class]],
                                                                                       @(DUXBetaSpeakerRecordButtonStateRecording) : [UIImage duxbeta_imageWithAssetNamed:@"SpeakerStop" forClass:[self class]],
                                                                                       @(DUXBetaSpeakerRecordButtonStateUploading) : [NSNull null],
                                                                                       @(DUXBetaSpeakerRecordButtonStateSuccess) : [UIImage duxbeta_imageWithAssetNamed:@"SpeakerUploaded" forClass:[self class]],
                                                                                       @(DUXBetaSpeakerRecordButtonStateFailed) : [UIImage duxbeta_imageWithAssetNamed:@"SpeakerUploadFailed" forClass:[self class]]
                                                                                       }];
        self.state = DUXBetaSpeakerRecordButtonStateNormal;
        self.recordingType = DUXBetaSpeakerRecordButtonRecordingTemporary;
        
        UIImage* image = [UIImage duxbeta_imageWithAssetNamed:@"SpeakerRecord" forClass:[self class]];//TODO: consider if _imageMapping can be used
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button addTarget:self action:@selector(didClickedButton) forControlEvents:UIControlEventTouchUpInside];
        [self.button setImage:image forState:UIControlStateNormal];
        [self addSubview:self.button];
        
        self.progressView = [[DUXBetaSpeakerProgressView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        self.progressView.hidden = YES;
        [self addSubview:self.progressView];
        
        self.uploadingView = [[DUXBetaSpeakerUploadingView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        self.uploadingView.hidden = YES;
        [self addSubview:self.uploadingView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:14.0f];
        self.label.text = NSLocalizedString(@"Tap to start recording.", @"Speaker Panel Record Button Text");
        self.label.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        [self addSubview:self.label];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.countLabel.textColor = [UIColor whiteColor];
        self.countLabel.hidden = YES;
        [self addSubview:self.countLabel];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.button.translatesAutoresizingMaskIntoConstraints = NO;
        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
        self.uploadingView.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.countLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.button.heightAnchor constraintEqualToConstant:SPEAKER_BUTTON_SIZE].active = YES;
        [self.button.widthAnchor constraintEqualToConstant:SPEAKER_BUTTON_SIZE].active = YES;
        [self.button.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [self.button.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-30].active = YES;
        
        [self.label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [self.label.heightAnchor constraintEqualToConstant:20].active = YES;
        [self.label.topAnchor constraintEqualToAnchor:self.button.bottomAnchor constant:10].active = YES;
        
        [self.countLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.countLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [self.countLabel.heightAnchor constraintEqualToConstant:20].active = YES;
        [self.countLabel.topAnchor constraintEqualToAnchor:self.button.bottomAnchor constant:10].active = YES;
        
        [self.progressView.heightAnchor constraintEqualToConstant:image.size.width].active = YES;
        [self.progressView.widthAnchor constraintEqualToConstant:image.size.height].active = YES;
        [self.progressView.centerXAnchor constraintEqualToAnchor:self.button.centerXAnchor].active = YES;
        [self.progressView.centerYAnchor constraintEqualToAnchor:self.button.centerYAnchor].active = YES;
        
        [self.uploadingView.heightAnchor constraintEqualToConstant:image.size.width].active = YES;
        [self.uploadingView.widthAnchor constraintEqualToConstant:image.size.height].active = YES;
        [self.uploadingView.centerXAnchor constraintEqualToAnchor:self.button.centerXAnchor].active = YES;
        [self.uploadingView.centerYAnchor constraintEqualToAnchor:self.button.centerYAnchor].active = YES;
        
        _recordButtonLabelTextColor = self.label.textColor;
        _recordButtonLabelFont = self.label.font;
        
        _recordingTimeLabelTextColor = self.countLabel.textColor;
        _recordingTimeLabelFont = self.countLabel.font;
    }
    return self;
}

#pragma mark - Interface

- (void)setSentSize:(NSUInteger)send totalSize:(NSUInteger)totalSize {
    if (self.state != DUXBetaSpeakerRecordButtonStateUploading) { return; }
    if (totalSize == 0) { return; }
    float percent = (float)send / totalSize * 100;
    NSString *uploadingString = NSLocalizedString(@"Uploading", @"Speaker Panel Uploading Text");
    self.label.text = [NSString stringWithFormat:@"%@: %.0f%%",uploadingString, percent];
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)startRecordingCounter {
    self.state = DUXBetaSpeakerRecordButtonStateRecording;
}

- (void)setCurrentTimestamp:(NSTimeInterval)time {
    _currentTimestamp = time;
    self.countLabel.text = [NSString stringWithFormat:@"%d s",(int)_currentTimestamp];
    CGFloat progress =  _currentTimestamp / SPEAKER_RECORDING_TIME_LIMIT;
    
    [self.progressView setProgress:progress];
    
    if (_currentTimestamp >= 60) {
        if (self.recordingDurationFullCallback) {
            self.recordingDurationFullCallback();
        }
    }
}

- (void)setState:(DUXBetaSpeakerRecordButtonState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    [self updateUI];
}

- (void)updateUI {
    switch (_state) {
        case DUXBetaSpeakerRecordButtonStateIdle: {
            [self.button setImage:[UIImage duxbeta_imageWithAssetNamed:@"SpeakerRecordInactive" forClass:[self class]] forState:UIControlStateNormal];//TODO: consider if _imageMapping can be used
            self.label.text = NSLocalizedString(@"Accessory unavailable.", @"Speaker Panel Accessory Unavailable Text");
            self.progressView.hidden = YES;
            self.countLabel.hidden = YES;
            self.uploadingView.hidden = YES;
            self.button.hidden = NO;
            self.label.hidden = NO;
            self.button.enabled = NO;
        }
            break;
        case DUXBetaSpeakerRecordButtonStateNormal: {
            [self.button setImage:[UIImage duxbeta_imageWithAssetNamed:@"SpeakerRecord" forClass:[self class]] forState:UIControlStateNormal];//TODO: consider if _imageMapping can be used
            self.label.text = NSLocalizedString(@"Tap to start recording.", @"Speaker Panel Tap to start recording Text");
            self.progressView.hidden = YES;
            self.countLabel.hidden = YES;
            self.uploadingView.hidden = YES;
            self.button.hidden = NO;
            self.label.hidden = NO;
            self.button.enabled = YES;
        }
            break;
        case DUXBetaSpeakerRecordButtonStateRecording: {
            [self.button setImage:[UIImage duxbeta_imageWithAssetNamed:@"SpeakerStop" forClass:[self class]] forState:UIControlStateNormal];//TODO: consider if _imageMapping can be used
            self.progressView.hidden = NO;
            self.countLabel.hidden = NO;
            self.uploadingView.hidden = YES;
            self.button.hidden = NO;
            self.label.hidden = YES;
            self.button.enabled = YES;
        }
            break;
        case DUXBetaSpeakerRecordButtonStateUploading: {
            self.label.text = NSLocalizedString(@"Uploading...", @"Speaker Panel Uploading Text");
            self.progressView.hidden = YES;
            self.countLabel.hidden = YES;
            self.uploadingView.hidden = NO;
            self.button.hidden = YES;
            self.label.hidden = NO;
            self.button.enabled = NO;
        }
            break;
        case DUXBetaSpeakerRecordButtonStateSuccess: {
            [self.button setImage:[UIImage duxbeta_imageWithAssetNamed:@"SpeakerUploaded" forClass:[self class]] forState:UIControlStateNormal];//TODO: consider if _imageMapping can be used
            self.label.text = NSLocalizedString(@"Uploaded successfully", @"Speaker Panel Uploaded successfully Text");
            self.progressView.hidden = YES;
            self.countLabel.hidden = YES;
            self.uploadingView.hidden = YES;
            self.button.hidden = NO;
            self.label.hidden = NO;
            self.button.enabled = NO;
        }
            break;
        case DUXBetaSpeakerRecordButtonStateFailed: {
            [self.button setImage:[UIImage duxbeta_imageWithAssetNamed:@"SpeakerUploadFailed" forClass:[self class]] forState:UIControlStateNormal];//TODO: consider if _imageMapping can be used
            self.label.text = NSLocalizedString(@"Failed to upload", @"Speaker Panel Failed to upload Text");
            self.progressView.hidden = YES;
            self.countLabel.hidden = YES;
            self.uploadingView.hidden = YES;
            self.button.hidden = NO;
            self.label.hidden = NO;
            self.button.enabled = NO;
        }
            break;
    }
}

- (void)didClickedButton {
    switch (_state) {
        case DUXBetaSpeakerRecordButtonStateNormal: {
            if (self.recordingType == DUXBetaSpeakerRecordButtonRecordingTemporary) {
                if (self.startInstantRecordingAction) { self.startInstantRecordingAction(); }
            } else {
                if (self.startListRecordingAction) { self.startListRecordingAction(); }
            }
            self.currentDuration = 0;
            [self setCurrentTimestamp: self.currentDuration];
            self.timer = [NSTimer timerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(handleSpeakerRecordButtonDurationTimer)
                                               userInfo:nil
                                                repeats:YES];
            
            [self setNeedsDisplay];
            break;
        }
        case DUXBetaSpeakerRecordButtonStateRecording: {
            if (self.recordingType == DUXBetaSpeakerRecordButtonRecordingTemporary) {
                if (self.stopInstantRecordingAction) { self.stopInstantRecordingAction(); }
            } else {
                if (self.stopListRecordingAction) { self.stopListRecordingAction(); }
            }
            [self.timer invalidate];
            self.timer = nil;
            self.currentDuration = 0;
            [self setCurrentTimestamp: self.currentDuration];
            break;
        }
        case DUXBetaSpeakerRecordButtonStateIdle:
        case DUXBetaSpeakerRecordButtonStateUploading:
        case DUXBetaSpeakerRecordButtonStateSuccess:
        case DUXBetaSpeakerRecordButtonStateFailed:
            break;
    }
}

- (void)handleSpeakerRecordButtonDurationTimer {
    self.currentDuration += 1;
    [self setCurrentTimestamp: self.currentDuration];
}

- (void)setSpeakerImage:(UIImage *)speakerImage forRecordingState:(DUXBetaSpeakerRecordButtonState)recordingState {
    [self.imageMapping setObject:speakerImage forKey:@(recordingState)];
    [self updateUI];
}

- (UIImage *)getSpeakerImageForRecordingState:(DUXBetaSpeakerRecordButtonState)recordingState {
    return [self.imageMapping objectForKey:@(recordingState)];
}

- (void)setRecordButtonLabelTextColor:(UIColor *)recordButtonLabelTextColor {
    _recordButtonLabelTextColor = recordButtonLabelTextColor;
    self.label.textColor = recordButtonLabelTextColor;
}

- (void)setRecordButtonLabelFont:(UIFont *)recordButtonLabelFont {
    _recordButtonLabelFont = recordButtonLabelFont;
    self.label.font = recordButtonLabelFont;
}

- (void)setRecordingTimeLabelTextColor:(UIColor *)recordingTimeLabelTextColor {
    _recordingTimeLabelTextColor = recordingTimeLabelTextColor;
    self.countLabel.textColor = recordingTimeLabelTextColor;
}

- (void)setRecordingTimeLabelFont:(UIFont *)recordingTimeLabelFont {
    _recordingTimeLabelFont = recordingTimeLabelFont;
    self.countLabel.font = recordingTimeLabelFont;
}

@end
