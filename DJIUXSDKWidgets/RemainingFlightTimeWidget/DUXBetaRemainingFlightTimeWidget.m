//
//  DUXBetaRemainingFlightTimeWidget.m
//  DJIUXSDK
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

#import "DUXBetaRemainingFlightTimeWidget.h"
#import "DUXBetaRemainingFlightTimeWidgetModel.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
#import "DUXBetaRemainingFlightTimeData.h"
@import DJIUXSDKCore;

static const CGSize kDesignSize = {612.0, 20.0};
static const CGSize kHomeImageDesignSize = {13.0, 13.0};
static const CGSize kWhiteDotDesignSize = {13.0, 13.0};
static const CGFloat kBarHeight = 3.0;
static const CGFloat kFontSize = 10.0;
static NSString * const kUninitializedFlightTime = @"--:--";

@interface DUXBetaRemainingFlightTimeWidget ()

@property (nonatomic) UIView *redView;
@property (nonatomic) UIView *yellowView;
@property (nonatomic) UIView *greenView;
@property (nonatomic) UIView *blackView;
@property (nonatomic) UIImageView *whiteDot1ImageView;
@property (nonatomic) UIImageView *whiteDot2ImageView;
@property (nonatomic) UIImageView *homeImageView;
@property (nonatomic) UILabel *remainingTimeLabel;
@property (nonatomic) UIView *timeLabelBackgroundView;

@property NSLayoutConstraint *redViewWidthConstraint;
@property NSLayoutConstraint *yellowViewWidthConstraint;
@property NSLayoutConstraint *greenViewWidthConstraint;
@property NSLayoutConstraint *whiteDot1PositionConstraint;
@property NSLayoutConstraint *whiteDot2PositionConstraint;
@property UILayoutGuide *whiteDot1Guide;
@property UILayoutGuide *whiteDot2Guide;

@end

/**
 * DUXRemainingFlightTimeWidgetModelState contains the model hooks for the DUXRemainingFlightTimeWidget.
 * It implements the hooks:
 *
 * Key: productConnected        Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft is connected.
 *
 * Key: flightTimeDataUpdate    Type: id - Sends a DUXRemainingFlightTimeData object whenever the remaining flight time updates.
 *                                          This will send approximately once a second when the aircraft is active.
 *
 * Key: isAircraftFlyingUpdate  Type: NSNumber - Sends a boolean value as an NSNumber indicating if the aircraft is currrently
 *                                               flying. YES indicates in flight, no indicates landed.
*/
@interface DUXRemainingFlightTimeWidgetModelState : DUXStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)flightTimeDataUpdate:(DUXBetaRemainingFlightTimeData *)flightTimeData;
+ (instancetype)isAircraftFlyingUpdate:(BOOL)isAircraftFlying;

@end

@implementation DUXBetaRemainingFlightTimeWidget

/*********************************************************************************/
#pragma mark - Initializer
/*********************************************************************************/

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInstanceVariables];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupInstanceVariables];
    }
    return self;
}

- (void)setupInstanceVariables {
    _remainingTimeFont = [UIFont boldSystemFontOfSize: kFontSize];
    _remainingTimeLabelBackgroundColor = [UIColor duxbeta_whiteColor];
    _remainingTimeLabelTextColor = [UIColor duxbeta_blackColor];
    
    _remainingBatteryBarColor = [UIColor duxbeta_remainingFlightTimeWidgetRemainingBatteryColor];
    _lowBatteryWarningBarColor = [UIColor duxbeta_remainingFlightTimeWidgetLowBatteryColor];
    _seriouslyLowBatteryWarningBarColor = [UIColor duxbeta_remainingFlightTimeWidgetSeriouslyLowBatteryColor];
    _seriouslyLowBatteryIndicatorColor = [UIColor duxbeta_whiteColor];
    _lowBatteryIndicatorColor = [UIColor duxbeta_whiteColor];
    _homeIndicatorColor = nil;
    
    _lowBatteryIndicatorImage = [UIImage duxbeta_imageWithAssetNamed:@"WhiteDot"];
    _seriouslyLowBatteryIndicatorImage = [UIImage duxbeta_imageWithAssetNamed:@"WhiteDot"];
    _homeIndicatorImage = [UIImage duxbeta_imageWithAssetNamed:@"HomeIcon"];
}

/*********************************************************************************/
#pragma mark - View Lifecycle Methods
/*********************************************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaRemainingFlightTimeWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(animateWidgetVisibility), isProductConnected);

    BindRKVOModel(self, @selector(customizeUI),
                  remainingTimeFont,
                  remainingTimeLabelBackgroundColor,
                  remainingTimeLabelTextColor,
                  remainingBatteryBarColor,
                  lowBatteryWarningBarColor,
                  seriouslyLowBatteryWarningBarColor,
                  lowBatteryIndicatorImage,
                  seriouslyLowBatteryIndicatorImage,
                  homeIndicatorImage,
                  seriouslyLowBatteryIndicatorColor,
                  lowBatteryIndicatorColor,
                  homeIndicatorColor);
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), flightTimeData);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}
/*********************************************************************************/
#pragma mark - Widget UI Setup And Update Methods
/*********************************************************************************/

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)setupUI {
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.redView = [[UIView alloc] init];
    [self.view addSubview: self.redView];
    
    self.yellowView = [[UIView alloc] init];
    [self.view addSubview: self.yellowView];
    
    self.greenView = [[UIView alloc] init];
    [self.view addSubview: self.greenView];
    
    self.blackView = [[UIView alloc] init];
    self.blackView.backgroundColor = [UIColor clearColor];
    [self.view addSubview: self.blackView];
    
    self.whiteDot1ImageView = [[UIImageView alloc] init];
    self.whiteDot1ImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview: self.whiteDot1ImageView];
    
    self.whiteDot2ImageView = [[UIImageView alloc] init];
    self.whiteDot2ImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview: self.whiteDot2ImageView];
    
    self.homeImageView = [[UIImageView alloc] init];
    self.homeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview: self.homeImageView];
    
    self.remainingTimeLabel = [[UILabel alloc] init];
    self.remainingTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.remainingTimeLabel.clipsToBounds = YES;
    self.remainingTimeLabel.text = kUninitializedFlightTime;
    [self.remainingTimeLabel sizeToFit];

    self.timeLabelBackgroundView = [[UIView alloc] init];
    self.timeLabelBackgroundView.layer.cornerRadius = self.remainingTimeLabel.bounds.size.height / 2;
    self.timeLabelBackgroundView.clipsToBounds = YES;
    
    [self.view addSubview: self.timeLabelBackgroundView];
    [self.view addSubview: self.remainingTimeLabel];
    
    self.view.hidden = YES;
    [self setupConstraints];
    [self customizeUI];
}

- (void)setupConstraints {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.redView.translatesAutoresizingMaskIntoConstraints = NO;
    self.yellowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.greenView.translatesAutoresizingMaskIntoConstraints = NO;
    self.blackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.whiteDot1ImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.whiteDot2ImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.homeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabelBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Minimum height constraint
    [self.view.heightAnchor constraintGreaterThanOrEqualToConstant:kDesignSize.height].active = YES;
    
    // Vertical centering
    [self.redView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.yellowView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.greenView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.blackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.whiteDot1ImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.whiteDot2ImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.homeImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.remainingTimeLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.timeLabelBackgroundView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    // Bar heights
    [self.redView.heightAnchor constraintEqualToConstant:kBarHeight].active = YES;
    [self.yellowView.heightAnchor constraintEqualToConstant:kBarHeight].active = YES;
    [self.greenView.heightAnchor constraintEqualToConstant:kBarHeight].active = YES;
    [self.blackView.heightAnchor constraintEqualToConstant:kBarHeight].active = YES;
    
    // Image and label ratios and heights
    [self.homeImageView.heightAnchor constraintEqualToAnchor:self.homeImageView.widthAnchor].active = YES;
    [self.homeImageView.heightAnchor constraintEqualToConstant:kHomeImageDesignSize.height].active = YES;
    [self.whiteDot1ImageView.heightAnchor constraintEqualToAnchor:self.whiteDot1ImageView.widthAnchor].active = YES;
    [self.whiteDot1ImageView.heightAnchor constraintEqualToConstant:kWhiteDotDesignSize.height].active = YES;
    [self.whiteDot2ImageView.heightAnchor constraintEqualToAnchor:self.whiteDot2ImageView.widthAnchor].active = YES;
    [self.whiteDot2ImageView.heightAnchor constraintEqualToConstant:kWhiteDotDesignSize.height].active = YES;
    [self.timeLabelBackgroundView.heightAnchor constraintEqualToAnchor:self.remainingTimeLabel.heightAnchor].active = YES;
    
    // Leading/Trailing constraints
    [self.redView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.redView.trailingAnchor constraintEqualToAnchor:self.yellowView.leadingAnchor].active = YES;
    [self.yellowView.trailingAnchor constraintEqualToAnchor:self.greenView.leadingAnchor].active = YES;
    [self.greenView.trailingAnchor constraintEqualToAnchor:self.blackView.leadingAnchor].active = YES;
    [self.blackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
    CGFloat textMargin = self.remainingTimeLabel.bounds.size.height / 3;
    
    if (@available(iOS 11, *)) {
        [self.remainingTimeLabel.trailingAnchor constraintEqualToAnchor:self.greenView.trailingAnchor constant:(self.view.safeAreaInsets.left - textMargin)].active = YES;
    } else {
        [self.remainingTimeLabel.trailingAnchor constraintEqualToAnchor:self.greenView.trailingAnchor constant:(-1 * textMargin)].active = YES;
    }
    [self.homeImageView.centerXAnchor constraintEqualToAnchor:self.yellowView.trailingAnchor].active = YES;
    
    [self.timeLabelBackgroundView.centerXAnchor constraintEqualToAnchor:self.remainingTimeLabel.centerXAnchor].active = YES;
    
    [self.timeLabelBackgroundView.leadingAnchor constraintEqualToAnchor:self.remainingTimeLabel.leadingAnchor constant:(-1 * textMargin)].active = YES;
    [self.timeLabelBackgroundView.trailingAnchor constraintEqualToAnchor:self.remainingTimeLabel.trailingAnchor constant:textMargin].active = YES;
    
    // White dots (land immediately battery threshold and go home battery threshold)
    self.whiteDot1Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide: self.whiteDot1Guide];
    [self.whiteDot1Guide.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.whiteDot1ImageView.centerXAnchor constraintEqualToAnchor: self.whiteDot1Guide.trailingAnchor].active = YES;
    
    self.whiteDot2Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide: self.whiteDot2Guide];
    [self.whiteDot2Guide.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.whiteDot2ImageView.centerXAnchor constraintEqualToAnchor: self.whiteDot2Guide.trailingAnchor].active = YES;
}

- (void)updateUI {
    if (self.widgetModel.isFlying) {
        int remainingFlightTime = self.widgetModel.flightTimeData.flightTime;
        if (remainingFlightTime / 3600 > 0) {
            int hours = remainingFlightTime / 3600;
            int minutes = ((remainingFlightTime - (hours * 3600)) / 60);
            self.remainingTimeLabel.text = [NSString stringWithFormat:@"%dh:%02dm:%02ds", hours, minutes, remainingFlightTime % 60];
        } else {
            self.remainingTimeLabel.text = [NSString stringWithFormat:@"%02dm:%02ds", remainingFlightTime / 60, remainingFlightTime % 60];
        }
    } else {
        self.remainingTimeLabel.text = kUninitializedFlightTime;
    }
    [self.remainingTimeLabel sizeToFit];
    
    self.timeLabelBackgroundView.layer.cornerRadius = self.remainingTimeLabel.bounds.size.height / 2;
    
    // Calculates the position where each bar should end
    float greenPercentage = MIN(100.0, MAX(0.0, self.widgetModel.flightTimeData.remainingCharge));
    float yellowPercentage = MIN(100.0, MAX(0.0, self.widgetModel.flightTimeData.batteryNeededToGoHome));
    float redPercentage = MIN(100.0, MAX(0.0, self.widgetModel.flightTimeData.batteryNeededToLand));
    float whiteDot1Percentage = self.widgetModel.flightTimeData.seriousLowBatteryThreshold;
    float whiteDot2Percentage = self.widgetModel.flightTimeData.lowBatteryThreshold;
    
    // Calculates the width of each bar by subtracting the widths of preceeding bars
    CGFloat redWidth, yellowWidth, greenWidth, totalWidth, fullWidth;
    
    fullWidth = self.view.bounds.size.width;    
    totalWidth = greenPercentage * fullWidth / 100.0;
    greenWidth = MAX(0.0, (greenPercentage - yellowPercentage) * fullWidth / 100.0);
    yellowWidth = MAX(0.0, (yellowPercentage - redPercentage) * fullWidth / 100.0);
    redWidth = redPercentage * fullWidth / 100.0;
    
    if (redWidth > totalWidth) {
        redWidth = totalWidth;
        greenWidth = 0.0;
    }
    
    if (!self.redViewWidthConstraint) {
        self.redViewWidthConstraint = [self.redView.widthAnchor constraintEqualToConstant: redWidth];
        self.redViewWidthConstraint.active = YES;
    } else {
        self.redViewWidthConstraint.constant = redWidth;
    }
    
    if (!self.yellowViewWidthConstraint) {
        self.yellowViewWidthConstraint = [self.yellowView.widthAnchor constraintEqualToConstant: yellowWidth];
        self.yellowViewWidthConstraint.active = YES;
    } else {
        self.yellowViewWidthConstraint.constant = yellowWidth;
    }
    
    if (!self.greenViewWidthConstraint) {
        self.greenViewWidthConstraint = [self.greenView.widthAnchor constraintEqualToConstant: greenWidth];
        self.greenViewWidthConstraint.active = YES;
    } else {
        self.greenViewWidthConstraint.constant = greenWidth;
    }
    
    float greenViewRightEdge = self.greenView.frame.origin.x + self.greenView.frame.size.width;
    float homeViewRightEdge = self.homeImageView.frame.origin.x + self.homeImageView.frame.size.width;
    
    if (yellowPercentage == 0 && redPercentage == 0) {
        self.homeImageView.hidden = YES;
    } else if (homeViewRightEdge > greenViewRightEdge) {
        self.homeImageView.hidden = YES;
    } else {
        self.homeImageView.hidden = NO;
    }
    
    CGFloat whiteDot1ConstraintConstant = self.view.frame.size.width * MAX(whiteDot1Percentage / 100.0, CGFLOAT_MIN);
    if (!self.whiteDot1PositionConstraint) {
        self.whiteDot1PositionConstraint = [self.whiteDot1Guide.widthAnchor constraintEqualToConstant: whiteDot1ConstraintConstant];
        self.whiteDot1PositionConstraint.active = YES;
    } else {
        self.whiteDot1PositionConstraint.constant = whiteDot1ConstraintConstant;
    }
    
    float whiteDot1RightEdge = self.whiteDot1ImageView.frame.origin.x + self.whiteDot1ImageView.frame.size.width;

    if (whiteDot1RightEdge > greenViewRightEdge) {
        self.whiteDot1ImageView.hidden = YES;
    } else {
        self.whiteDot1ImageView.hidden = NO;
    }
    
    CGFloat whiteDot2ConstraintConstant = self.view.frame.size.width * MAX(whiteDot2Percentage / 100.0, CGFLOAT_MIN);
    if (!self.whiteDot2PositionConstraint) {
        self.whiteDot2PositionConstraint = [self.whiteDot2Guide.widthAnchor constraintEqualToConstant: whiteDot2ConstraintConstant];
        self.whiteDot2PositionConstraint.active = YES;
    } else {
        self.whiteDot2PositionConstraint.constant = whiteDot2ConstraintConstant;
    }
    
    float whiteDot2RightEdge = self.whiteDot2ImageView.frame.origin.x + self.whiteDot2ImageView.frame.size.width;

    if (whiteDot2RightEdge > greenViewRightEdge) {
        self.whiteDot2ImageView.hidden = YES;
    } else {
        self.whiteDot2ImageView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {}];
}

- (void)animateWidgetVisibility {
    float duration = 0.3;
    if (self.view.hidden && self.widgetModel.isProductConnected) {
        self.view.alpha = 0;
        self.view.hidden = NO;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.alpha = 1;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    } else if (!self.view.hidden && !self.widgetModel.isProductConnected) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.hidden = YES;
        });
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

/*********************************************************************************/
#pragma mark - Customization Methods
/*********************************************************************************/

- (void)customizeUI {
    self.remainingTimeLabel.font = self.remainingTimeFont;
    self.remainingTimeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabelBackgroundView.backgroundColor = self.remainingTimeLabelBackgroundColor;
    self.remainingTimeLabel.textColor = self.remainingTimeLabelTextColor;
    
    self.redView.backgroundColor = self.seriouslyLowBatteryWarningBarColor;
    self.yellowView.backgroundColor = self.lowBatteryWarningBarColor;
    self.greenView.backgroundColor = self.remainingBatteryBarColor;
    
    self.whiteDot1ImageView.image = [self.seriouslyLowBatteryIndicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.whiteDot2ImageView.image = [self.lowBatteryIndicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (self.homeIndicatorColor != nil) {
        self.homeImageView.image = [self.homeIndicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.homeImageView.tintColor = self.homeIndicatorColor;
    } else {
        self.homeImageView.image = [self.homeIndicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    self.whiteDot1ImageView.tintColor = self.seriouslyLowBatteryIndicatorColor;
    self.whiteDot2ImageView.tintColor = self.lowBatteryIndicatorColor;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end

@implementation DUXRemainingFlightTimeWidgetModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[DUXRemainingFlightTimeWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)flightTimeDataUpdate:(DUXBetaRemainingFlightTimeData *)flightTimeData {
    return [[DUXRemainingFlightTimeWidgetModelState alloc] initWithKey:@"flightTimeDataUpdate" object:flightTimeData];
}

+ (instancetype)isAircraftFlyingUpdate:(BOOL)isAircraftFlying {
    return [[DUXRemainingFlightTimeWidgetModelState alloc] initWithKey:@"isAircraftFlyingUpdate" number:@(isAircraftFlying)];
}

@end
