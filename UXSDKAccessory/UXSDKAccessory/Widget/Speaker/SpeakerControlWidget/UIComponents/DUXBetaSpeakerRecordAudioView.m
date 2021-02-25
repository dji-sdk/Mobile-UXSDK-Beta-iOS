//
//  DUXBetaSpeakerRecordAudioView.m
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

#import "DUXBetaSpeakerRecordAudioView.h"
#import "DUXBetaSpeakerUploadSessionManager.h"


@interface DUXBetaSpeakerRecordAudioView ()

@property (nonatomic, strong) UISwitch *playImmediatelySwitch;
@property (nonatomic, strong) UISwitch *persistSwitch;
@property (nonatomic, strong) UILabel *persistMessageLabel;
@property (nonatomic, strong) UILabel *playImmediatelyLabel;
@property (nonatomic, strong) UILabel *persistLabel;

@property (nonatomic, assign) DUXBetaSpeakerRecordButtonRecordingType startedRecordingOfType;

@property (nonatomic, strong) DUXBetaSpeakerMediaListSyncer* syncer;

@end

@implementation DUXBetaSpeakerRecordAudioView

- (instancetype)initWithFrame:(CGRect)frame andMediaSyncer:(DUXBetaSpeakerMediaListSyncer *)syncer {
    self = [super initWithFrame:frame];
    if (self) {
        _syncer = syncer;
        DUXBetaSpeakerUploadSessionManager *manager = [DUXBetaSpeakerUploadSessionManager sharedInstance];
        BindRKVOModel(manager, @selector(updateState:),currentSession);
        BindRKVOModel(_syncer, @selector(syncSpeakerEnabled), isConnected);
        [self setupUI];
        
        _playImmediatelySwitchOnTintColor = self.playImmediatelySwitch.onTintColor;
        _playImmediatelySwitchTintColor = self.playImmediatelySwitch.tintColor;
        _playImmediatelySwitchThumbTintColor = self.playImmediatelySwitch.thumbTintColor;
        _playImmediatelySwitchOnImage = self.playImmediatelySwitch.onImage;
        _playImmediatelySwitchOffImage = self.playImmediatelySwitch.offImage;
        
        _persistSwitchOnTintColor = self.persistSwitch.onTintColor;
        _persistSwitchTintColor = self.persistSwitch.tintColor;
        _persistSwitchThumbTintColor = self.persistSwitch.thumbTintColor;
        _persistSwitchOnImage = self.persistSwitch.onImage;
        _persistSwitchOffImage = self.persistSwitch.offImage;
        
        _playImmediatelyLabelText = self.playImmediatelyLabel.text;
        _playImmediatelyLabelTextColor = self.playImmediatelyLabel.textColor;
        _playImmediatelyLabelFont = self.playImmediatelyLabel.font;
        
        _persistLabelText = self.persistLabel.text;
        _persistLabelTextColor = self.persistLabel.textColor;
        _persistLabelFont = self.persistLabel.font;
        
        _persistMessageLabelText = self.persistMessageLabel.text;
        _persistMessageLabelTextColor = self.persistMessageLabel.textColor;
        _persistMessageLabelFont = self.persistMessageLabel.font;
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [[DUXBetaSpeakerRecordAudioView alloc] initWithFrame:frame andMediaSyncer:[[DUXBetaSpeakerMediaListSyncer alloc] init]];
    return self;
}

- (void)dealloc {
    UnBindRKVOModel(self);
}

- (void)updateState:(DUXBetaRKVOTransform *)transform {
    if (transform.updatedValue == nil) {
        self.recordButton.state = DUXBetaSpeakerRecordButtonStateNormal;
    }
}

- (void)setupUI {
    self.recordButton = [[DUXBetaSpeakerRecordButton alloc] initWithFrame:CGRectZero];
    self.recordButton.recordingType = DUXBetaSpeakerRecordButtonRecordingPermanent;
    [self addSubview:self.recordButton];
    
    self.playImmediatelySwitch = [[UISwitch alloc] init];
    self.playImmediatelySwitch.tintColor = [UIColor whiteColor];
    [self addSubview:self.playImmediatelySwitch];
    
    self.playImmediatelyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.playImmediatelyLabel.numberOfLines = 0;
    self.playImmediatelyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.playImmediatelyLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    self.playImmediatelyLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.playImmediatelyLabel.text = NSLocalizedString(@"Play audio immediately after recording", @"Speaker Panel Play audio immediately after recording Text");
    [self addSubview:self.playImmediatelyLabel];
    
    self.persistSwitch = [[UISwitch alloc] init];
    self.persistSwitch.tintColor = [UIColor whiteColor];
    self.persistSwitch.on = YES;
    [self.persistSwitch addTarget:self action:@selector(persistSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.persistSwitch];
    
    self.persistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.persistLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    self.persistLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.persistLabel.text = NSLocalizedString(@"Persist file?", @"Speaker Panel Persist file Text");
    [self addSubview:self.persistLabel];
    
    self.persistMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.persistMessageLabel.numberOfLines = 0;
    self.persistMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.persistMessageLabel.font = [UIFont systemFontOfSize:10.0f];
    self.persistMessageLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.persistMessageLabel.text = NSLocalizedString(@"Recorded audio file will be saved on the drone until manually deleted.", @"Speaker Panel Persist message permanent Text");
    [self addSubview:self.persistMessageLabel];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.playImmediatelyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.persistLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.playImmediatelySwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.persistSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.persistMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.persistLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10].active = YES;
    [self.persistLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
    [self.persistLabel.trailingAnchor constraintEqualToAnchor:self.persistSwitch.leadingAnchor constant:-5].active = YES;
    
    [self.persistSwitch.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10].active = YES;
    [self.persistSwitch.centerYAnchor constraintEqualToAnchor:self.persistLabel.centerYAnchor constant:7].active = YES;
    
    [self.playImmediatelySwitch.topAnchor constraintEqualToAnchor:self.persistSwitch.bottomAnchor constant:20].active = YES;
    [self.playImmediatelySwitch.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10].active = YES;
    [self.playImmediatelySwitch.centerYAnchor constraintEqualToAnchor:self.playImmediatelyLabel.centerYAnchor].active = YES;
    
    [self.playImmediatelyLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.playImmediatelyLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
    [self.playImmediatelyLabel.trailingAnchor constraintEqualToAnchor:self.playImmediatelySwitch.leadingAnchor constant:-5].active = YES;
    
    [self.persistMessageLabel.topAnchor constraintEqualToAnchor:self.persistLabel.bottomAnchor constant:2].active = YES;
    [self.persistMessageLabel.leadingAnchor constraintEqualToAnchor:self.persistLabel.leadingAnchor].active = YES;
    [self.persistMessageLabel.trailingAnchor constraintEqualToAnchor:self.persistLabel.trailingAnchor].active = YES;
    
    [self.recordButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.recordButton.topAnchor constraintEqualToAnchor:self.playImmediatelyLabel.bottomAnchor constant:10].active = YES;
    [self.recordButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.recordButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    __weak typeof(self) target = self;
    self.recordButton.startInstantRecordingAction = ^{ [target startInstantRecordingActionHandle]; };
    self.recordButton.stopInstantRecordingAction = ^{ [target stopRecordingActionHandle]; };
    self.recordButton.startListRecordingAction = ^{ [target startListRecordingActionHandle]; };
    self.recordButton.stopListRecordingAction = ^{ [target stopRecordingActionHandle]; };
    self.recordButton.recordingDurationFullCallback = ^{ [target recordingDurationFullCallbackHandle]; };
}

#pragma mark - Actions

- (void)startInstantRecordingActionHandle {
    __weak typeof(self) target = self;
    [DUXBetaSpeakerUploadSession requestMicrophoneAuthorizationWithResults:^(BOOL isSuccess) {
        if (isSuccess) {
            if (target.startNewInstantSessionCallback) {
                target.startNewInstantSessionCallback();
            }
            [[DUXBetaSpeakerUploadSessionManager sharedInstance] startInstantUploadSession];
            [target internalStartRecordingForSession: [DUXBetaSpeakerUploadSessionManager sharedInstance].currentSession];
            target.startedRecordingOfType = DUXBetaSpeakerRecordButtonRecordingTemporary;
        }
    }];
}

- (void)startListRecordingActionHandle {
    __weak typeof(self) target = self;
    [DUXBetaSpeakerUploadSession requestMicrophoneAuthorizationWithResults:^(BOOL isSuccess) {
        if (isSuccess) {
            if (target.startNewListSessionCallback) {
                target.startNewListSessionCallback();
            }
            [[DUXBetaSpeakerUploadSessionManager sharedInstance] startSaveToListUploadSession];
            [target internalStartRecordingForSession: [DUXBetaSpeakerUploadSessionManager sharedInstance].currentSession];
            target.startedRecordingOfType = DUXBetaSpeakerRecordButtonRecordingPermanent;
        }
    }];
}

- (void)internalStartRecordingForSession:(DUXBetaSpeakerUploadSession *) session {
    self.recordButton.state = DUXBetaSpeakerRecordButtonStateRecording;
    __weak typeof(self) target = self;
    [session startRecordingAndUploadingWithBlock:^(NSUInteger sendSize, NSUInteger totalSize) {
        [target.recordButton setSentSize:sendSize totalSize:totalSize];
    } completion:^(NSError *error) {
        if (error) {
            target.recordButton.state = DUXBetaSpeakerRecordButtonStateFailed;
        } else {
            target.recordButton.state = DUXBetaSpeakerRecordButtonStateSuccess;
            if (target.playImmediatelySwitch.isOn) {
                [target.syncer refreshFileListAndPlayLatestFileOnce];
            }
        }
    }];
}

- (void)recordingDurationFullCallbackHandle {
    [self stopRecordingActionHandle];
}

- (void)stopRecordingActionHandle {
    self.recordButton.state = DUXBetaSpeakerRecordButtonStateUploading;
    [[[DUXBetaSpeakerUploadSessionManager sharedInstance] currentSession] stopRecording];
}

- (void)reset {
    [self syncSpeakerEnabled];
    [[[DUXBetaSpeakerUploadSessionManager sharedInstance] currentSession] cancelUpdating];
}

- (void)syncSpeakerEnabled {
    BOOL isConnected = [[DJISDKManager keyManager] getValueForKey:[DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpeakerSubComponent subComponentIndex:0 andParam:DJIAccessoryParamIsConnected]];
    if (!isConnected) {
        self.recordButton.state = DUXBetaSpeakerRecordButtonStateIdle;
    } else {
        self.recordButton.state = DUXBetaSpeakerRecordButtonStateNormal;
        [[DUXBetaSpeakerUploadSessionManager sharedInstance] forceCancelCurrentSession];
    }
}

- (void)persistSwitchChanged:(id)sender {
    if (self.persistSwitch.isOn) {
        self.recordButton.recordingType = DUXBetaSpeakerRecordButtonRecordingPermanent;
        self.persistMessageLabel.text = NSLocalizedString(@"Recorded audio file will be saved on the drone until manually deleted.", @"Speaker Panel Persist message permanent Text");
    } else {
        self.recordButton.recordingType = DUXBetaSpeakerRecordButtonRecordingTemporary;
        self.persistMessageLabel.text = NSLocalizedString(@"Recorded audio file will be temporarily saved on the drone until it restarts.", @"Speaker Panel Persist message temporary Text");
    }
}

- (void)setPlayImmediatelySwitchOnTintColor:(UIColor *)playImmediatelySwitchOnTintColor {
    _playImmediatelySwitchOnTintColor = playImmediatelySwitchOnTintColor;
    self.playImmediatelySwitch.onTintColor = playImmediatelySwitchOnTintColor;
}

- (void)setPlayImmediatelySwitchTintColor:(UIColor *)playImmediatelySwitchTintColor {
    _playImmediatelySwitchTintColor = playImmediatelySwitchTintColor;
    self.playImmediatelySwitch.tintColor = playImmediatelySwitchTintColor;
}

- (void)setPlayImmediatelySwitchThumbTintColor:(UIColor *)playImmediatelySwitchThumbTintColor {
    _playImmediatelySwitchThumbTintColor = playImmediatelySwitchThumbTintColor;
    self.playImmediatelySwitch.thumbTintColor = playImmediatelySwitchThumbTintColor;
}

- (void)setPlayImmediatelySwitchOnImage:(UIImage *)playImmediatelySwitchOnImage {
    _playImmediatelySwitchOnImage = playImmediatelySwitchOnImage;
    self.playImmediatelySwitch.onImage = playImmediatelySwitchOnImage;
}

- (void)setPlayImmediatelySwitchOffImage:(UIImage *)playImmediatelySwitchOffImage {
    _playImmediatelySwitchOffImage = playImmediatelySwitchOffImage;
    self.playImmediatelySwitch.offImage = playImmediatelySwitchOffImage;
}

- (void)setPersistSwitchOnTintColor:(UIColor *)persistSwitchOnTintColor {
    _persistSwitchOnTintColor = persistSwitchOnTintColor;
    self.persistSwitch.onTintColor = persistSwitchOnTintColor;
}

- (void)setPersistSwitchTintColor:(UIColor *)persistSwitchTintColor {
    _persistSwitchTintColor = persistSwitchTintColor;
    self.persistSwitch.tintColor = persistSwitchTintColor;
}

- (void)setPersistSwitchThumbTintColor:(UIColor *)persistSwitchThumbTintColor {
    _persistSwitchThumbTintColor = persistSwitchThumbTintColor;
    self.persistSwitch.thumbTintColor = persistSwitchThumbTintColor;
}

- (void)setPersistSwitchOnImage:(UIImage *)persistSwitchOnImage {
    _persistSwitchOnImage = persistSwitchOnImage;
    self.persistSwitch.onImage = persistSwitchOnImage;
}

- (void)setPersistSwitchOffImage:(UIImage *)persistSwitchOffImage {
    _persistSwitchOffImage = persistSwitchOffImage;
    self.persistSwitch.offImage = persistSwitchOffImage;
}

- (void)setPlayImmediatelyLabelText:(NSString *)playImmediatelyLabelText {
    _playImmediatelyLabelText = playImmediatelyLabelText;
    self.playImmediatelyLabel.text = playImmediatelyLabelText;
}

- (void)setPlayImmediatelyLabelTextColor:(UIColor *)playImmediatelyLabelTextColor {
    _playImmediatelyLabelTextColor = playImmediatelyLabelTextColor;
    self.playImmediatelyLabel.textColor = playImmediatelyLabelTextColor;
}

- (void)setPlayImmediatelyLabelFont:(UIFont *)playImmediatelyLabelFont {
    _playImmediatelyLabelFont = playImmediatelyLabelFont;
    self.playImmediatelyLabel.font = playImmediatelyLabelFont;
}

- (void)setPersistLabelText:(NSString *)persistLabelText {
    _persistLabelText = persistLabelText;
    self.persistLabel.text = persistLabelText;
}

- (void)setPersistLabelTextColor:(UIColor *)persistLabelTextColor {
    _persistLabelTextColor = persistLabelTextColor;
    self.persistLabel.textColor = persistLabelTextColor;
}

- (void)setPersistLabelFont:(UIFont *)persistLabelFont {
    _persistLabelFont = persistLabelFont;
    self.persistLabel.font = persistLabelFont;
}

- (void)setPersistMessageLabelText:(NSString *)persistMessageLabelText {
    _persistMessageLabelText = persistMessageLabelText;
    self.persistLabel.text = persistMessageLabelText;
}

- (void)setPersistMessageLabelTextColor:(UIColor *)persistMessageLabelTextColor {
    _persistMessageLabelTextColor = persistMessageLabelTextColor;
    self.persistLabel.textColor = persistMessageLabelTextColor;
}

- (void)setPersistMessageLabelFont:(UIFont *)persistMessageLabelFont {
    _persistMessageLabelFont = persistMessageLabelFont;
    self.persistLabel.font = persistMessageLabelFont;
}

@end
