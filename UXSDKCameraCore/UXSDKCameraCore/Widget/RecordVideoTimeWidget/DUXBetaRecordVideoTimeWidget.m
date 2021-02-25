//
//  DUXBetaRecordVideoTimeWidget.m
//  UXSDKCameraCore
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

#import "DUXBetaRecordVideoTimeWidget.h"
#import "DUXBetaRecordVideoTimeWidgetModel.h"
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static CGSize const kDesignSize = {100.0, 20.0};

@interface DUXBetaRecordVideoTimeWidget ()

@property (nonatomic, strong) UILabel *recordingTimeLabel;
@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, strong) NSTimer *dotTimer;
@property (nonatomic, strong) NSLayoutConstraint *timeLabelWithDotConstraint;
@property (nonatomic, strong) NSLayoutConstraint *timeLabelWithoutDotConstraint;

@end

@implementation DUXBetaRecordVideoTimeWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _recordingDotColor = [UIColor uxsdk_errorDangerColor];
        _recordingTimeTextColor = [UIColor uxsdk_whiteColor];
        _recordingTimeFont = [UIFont systemFontOfSize:18];
        _showRecordingIndicator = YES;
        [self setupDefaultTimeFormatter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaRecordVideoTimeWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), recordingTimeInSeconds);
    BindRKVOModel(self.widgetModel, @selector(toggleAnimation),isRecording);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.recordingTimeLabel = [[UILabel alloc] init];
    self.recordingTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.dotView = [[UIView alloc] init];
    self.dotView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.recordingTimeLabel];
    [self.view addSubview:self.dotView];
    
    [self.dotView.widthAnchor constraintEqualToAnchor:self.dotView.heightAnchor multiplier:1.0].active = YES;
    [self.dotView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    
    self.dotView.backgroundColor = self.recordingDotColor;
    self.dotView.layer.masksToBounds = true;
    
    [self.dotView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.dotView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.dotView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    self.timeLabelWithDotConstraint = [self.recordingTimeLabel.leadingAnchor constraintEqualToAnchor:self.dotView.trailingAnchor];
    self.timeLabelWithoutDotConstraint = [self.recordingTimeLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor];
    
    self.timeLabelWithoutDotConstraint.active = NO;
    self.timeLabelWithDotConstraint.active = YES;
    
    [self.recordingTimeLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.recordingTimeLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.recordingTimeLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;

    self.recordingTimeLabel.textColor = self.recordingTimeTextColor;
    self.recordingTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.recordingTimeLabel.adjustsFontSizeToFitWidth = YES;
    self.recordingTimeLabel.font = self.recordingTimeFont;
}

- (void)updateUI {
    self.dotView.layer.cornerRadius = self.dotView.frame.size.width/2;
    self.recordingTimeLabel.text = [self formattingSeconds:self.widgetModel.recordingTimeInSeconds];
    self.recordingTimeLabel.font = [self.recordingTimeFont fontWithSize:self.recordingTimeLabel.frame.size.height * self.recordingTimeFont.pointSize/self.widgetSizeHint.minimumHeight];
}

- (void)setupDefaultTimeFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    self.timeFormatter = formatter;
}

- (void)toggleAnimation {
    if (self.showRecordingIndicator) {
        if (self.widgetModel.isRecording) {
            self.dotTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(toggleDotHidden)
                                                           userInfo:nil
                                                            repeats:YES];
        } else {
            [self.dotTimer invalidate];
            self.dotTimer = nil;
            self.dotView.hidden = NO;
        }
    }
}

- (void)setShowRecordingIndicator:(BOOL)showRecordingIndicator {
    _showRecordingIndicator = showRecordingIndicator;
    if (showRecordingIndicator) {
        self.dotView.hidden = NO;
        self.timeLabelWithoutDotConstraint.active = NO;
        self.timeLabelWithDotConstraint.active = YES;
        [self toggleAnimation];
    } else {
        self.dotView.hidden = YES;
        self.timeLabelWithDotConstraint.active = NO;
        self.timeLabelWithoutDotConstraint.active = YES;
    }
}

- (void)toggleDotHidden {
    self.dotView.hidden = !self.dotView.hidden;
}

- (NSString *)formattingSeconds:(NSInteger)seconds {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSString *formattedTimeString = [self.timeFormatter stringFromDate:date];
    return formattedTimeString;
}

- (void)setRecordingDotColor:(UIColor *)recordingDotColor {
    _recordingDotColor = recordingDotColor;
    self.dotView.backgroundColor = recordingDotColor;
}

- (void)setRecordingTimeTextColor:(UIColor *)recordingTimeTextColor {
    _recordingTimeTextColor = recordingTimeTextColor;
    self.recordingTimeLabel.textColor = recordingTimeTextColor;
}

- (void)setRecordingTimeFont:(UIFont *)recordingTimeFont {
    _recordingTimeFont = recordingTimeFont;
    self.recordingTimeLabel.font = recordingTimeFont;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

- (void)setTimeFormatter:(NSDateFormatter *)timeFormatter {
    _timeFormatter = timeFormatter;
    [self updateUI];
}

@end
