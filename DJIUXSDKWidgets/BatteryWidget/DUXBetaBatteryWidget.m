//
//  DUXBetaBatteryWidget.m
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

#import "DUXBetaBatteryWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
#import "DUXBetaBatteryWidgetModel.h"
#import "DUXStateChangeBroadcaster.h"
@import DJIUXSDKCore;

static CGFloat const kVoltageAndPercentFontSize = 110.0;
static CGFloat const kSingleBatteryPercentFontSize = 70.0;
static CGFloat const kWidgetIconDualToWidgetWidthRatio = (1.0 / 3);
static CGFloat const kSingleIconWidthToWidgetWidthRatio = 0.4;
static CGFloat const kDualAspectRatio = 0.7;
static CGFloat const kBoxWidthToWidgetHeightRatio = 0.02;
static CGFloat const kVoltageLabelToBoxWidthRatio = 0.9;

@interface DUXBetaBatteryWidget ()

@property (nonatomic, readwrite) DUXBetaBatteryWidgetDisplayState widgetDisplayState;

//single battery
@property (nonatomic) UIView *singleBatteryView;
@property (nonatomic) UIImageView *singleBatteryImageView;
@property (nonatomic) UILabel *singleBatteryPercentageLabel;

@property (nonatomic) CGSize minWidgetSizeSingleBattery;

//dual battery
@property (nonatomic) UIView *dualBatteryView;
@property (nonatomic) UIImageView *dualBatteryImageView;

@property (nonatomic) UILabel *dualBatteryBatteryOnePercentageLabel;
@property (nonatomic) UILabel *dualBatteryBatteryTwoPercentageLabel;

@property (nonatomic) UILabel *dualBatteryBatteryOneVoltageLabel;
@property (nonatomic) UILabel *dualBatteryBatteryTwoVoltageLabel;

@property (nonatomic) UIView *dualBatteryBatteryOneBorderRectangle;
@property (nonatomic) UIView *dualBatteryBatteryTwoBorderRectangle;

@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *singleBatteryImageMapping;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *dualBatteryImageMapping;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIColor *> *imageTintMapping;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIColor *> *statusToVoltageColorMapping;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIColor *> *statusToPercentageColorMapping;

@property (nonatomic) CGSize minWidgetSizeDualBattery;

@property (strong, nonatomic) NSLayoutConstraint *singleBatteryViewAspectRatioConstraint;

@end

/**
 * DUXBatteryWidgetUIState contains the hooks for UI changes in the widget class DUXBatteryWidget.
 * It implements the hook:
 *
 * Key: widgetTapped    Type: NSNumber - Sends a boolean YES value as an NSNumber indicating the widget was tapped.
*/
@interface DUXBatteryWidgetUIState : DUXStateChangeBaseData

+ (instancetype)widgetTap;

@end

/**
 * DUXBatteryWidgetModelState contains the hooks for model changes for the DUXBatteryWidget.
 * It implements the hooks:
 *
 * Key: productConnected    Type: NSNumber - Sends a boolean value as an NSNumber when the product connects or disconnects.
 *                                            YES means connected, NO means disconnected.
 *
 * Key: batteryStateUpdate   Type: id  - Sends a DUXBateryState object when the battery state changes.
*/
@interface DUXBatteryWidgetModelState : DUXStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)batteryStateUpdate:(DUXBetaBatteryState *)batteryState;

@end

@implementation DUXBetaBatteryWidget

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
    _singleBatteryImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaBatteryStatusNormal) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryNormal"],
        @(DUXBetaBatteryStatusError) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryError"],
        @(DUXBetaBatteryStatusWarningLevel1) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryNormal"],
        @(DUXBetaBatteryStatusWarningLevel2) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryThunder"],
        @(DUXBetaBatteryStatusOverheating) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryOverheating"],
        @(DUXBetaBatteryStatusUnknown) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryNormal"]
    }];
    _dualBatteryImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaBatteryStatusNormal) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryNormal"],
        @(DUXBetaBatteryStatusError) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryNormal"],//Never used, error state only phantom3
        @(DUXBetaBatteryStatusWarningLevel1) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryNormal"],
        @(DUXBetaBatteryStatusWarningLevel2) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryThunder"],
        @(DUXBetaBatteryStatusOverheating) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryOverheating"],
        @(DUXBetaBatteryStatusUnknown) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryNormal"]
    }];
    _imageTintMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaBatteryStatusNormal) : [UIColor duxbeta_whiteColor],
        @(DUXBetaBatteryStatusError) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusWarningLevel1) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusWarningLevel2) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusOverheating) : [UIColor duxbeta_batteryOverheatingYellowColor],
        @(DUXBetaBatteryStatusUnknown) : [UIColor duxbeta_disabledGrayColor]
    }];
    _statusToVoltageColorMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaBatteryStatusNormal) : [UIColor duxbeta_batteryNormalGreen],
        @(DUXBetaBatteryStatusError) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusWarningLevel1) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusWarningLevel2) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusOverheating) : [UIColor duxbeta_batteryOverheatingYellowColor],
        @(DUXBetaBatteryStatusUnknown) : [UIColor duxbeta_disabledGrayColor]
    }];
    _statusToPercentageColorMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaBatteryStatusNormal) : [UIColor duxbeta_batteryNormalGreen],
        @(DUXBetaBatteryStatusError) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusWarningLevel1) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusWarningLevel2) : [UIColor duxbeta_redColor],
        @(DUXBetaBatteryStatusOverheating) : [UIColor duxbeta_batteryOverheatingYellowColor],
        @(DUXBetaBatteryStatusUnknown) : [UIColor duxbeta_disabledGrayColor]
    }];
    _voltageFontDual = [UIFont boldSystemFontOfSize:kVoltageAndPercentFontSize];
    _percentageFontDual = [UIFont boldSystemFontOfSize:kVoltageAndPercentFontSize];
    _percentageFontSingle = [UIFont systemFontOfSize:kSingleBatteryPercentFontSize];
    _widgetDisplayState = DUXBetaBatteryWidgetDisplayStateSingleBattery;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaBatteryWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.widgetModel.batteryState isMemberOfClass:[DUXDualBatteryState class]]) {
        [self updateUI];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), batteryState);
    BindRKVOModel(self, @selector(updateMinImageDimensions), singleBatteryImageMapping, dualBatteryImageMapping);
    
    BindRKVOModel(self.widgetModel, @selector(sendIsProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(sendBatteryStateUpdate), batteryState);
    BindRKVOModel(self, @selector(updateCurrentBatteryView), view.bounds);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    [self updateMinImageDimensions];
    [self drawSingleBatteryView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(widgetTapped)];
    [self.view addGestureRecognizer:singleTap];
}

- (void)drawSingleBatteryView {
    self.singleBatteryView = [[UIView alloc] init];
    self.singleBatteryView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.singleBatteryView];
    [self.singleBatteryView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.singleBatteryView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.singleBatteryView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.singleBatteryView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    UIImage *currentBatteryImage = [self currentIndicatorImageForSingleBattery:self.widgetModel.batteryState];
    self.singleBatteryImageView = [[UIImageView alloc] initWithImage:currentBatteryImage];
    
    [self.singleBatteryView addSubview:self.singleBatteryImageView];
    
    CGFloat iconAspectRatio = currentBatteryImage.size.width / currentBatteryImage.size.height;
    self.singleBatteryViewAspectRatioConstraint = [self.singleBatteryView.widthAnchor constraintEqualToAnchor:self.singleBatteryView.heightAnchor multiplier:iconAspectRatio * 2];
    
    self.singleBatteryViewAspectRatioConstraint.active = YES;
    
    self.singleBatteryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.singleBatteryImageView.leadingAnchor constraintEqualToAnchor:self.singleBatteryView.leadingAnchor].active = YES;
    [self.singleBatteryImageView.topAnchor constraintEqualToAnchor:self.singleBatteryView.topAnchor].active = YES;
    [self.singleBatteryImageView.bottomAnchor constraintEqualToAnchor:self.singleBatteryView.bottomAnchor].active = YES;
    [self.singleBatteryImageView.widthAnchor constraintEqualToAnchor:self.singleBatteryView.widthAnchor multiplier:kSingleIconWidthToWidgetWidthRatio].active = YES;
    
    self.singleBatteryImageView.contentMode = UIViewContentModeScaleAspectFit;

    [self.singleBatteryImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.singleBatteryPercentageLabel = [[UILabel alloc] init];
    [self.singleBatteryView addSubview:self.singleBatteryPercentageLabel];
    self.singleBatteryPercentageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    CGFloat labelWidthAsPercentOfView = 1.0 - kSingleIconWidthToWidgetWidthRatio;
    [self.singleBatteryPercentageLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:labelWidthAsPercentOfView].active = YES;
    [self.singleBatteryPercentageLabel.leadingAnchor constraintEqualToAnchor:self.singleBatteryImageView.trailingAnchor].active = YES;
    [self.singleBatteryPercentageLabel.trailingAnchor constraintEqualToAnchor:self.singleBatteryView.trailingAnchor].active = YES;
    [self.singleBatteryPercentageLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.singleBatteryPercentageLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
        
    self.singleBatteryPercentageLabel.textColor = [self.statusToPercentageColorMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)];
    self.singleBatteryPercentageLabel.font = self.percentageFontSingle;
    self.singleBatteryPercentageLabel.textAlignment = NSTextAlignmentLeft;
    self.singleBatteryPercentageLabel.minimumScaleFactor = 0.1;
    self.singleBatteryPercentageLabel.adjustsFontSizeToFitWidth = YES;
    self.singleBatteryPercentageLabel.numberOfLines = 0;
    self.singleBatteryPercentageLabel.lineBreakMode = NSLineBreakByClipping;
}

- (void)updateSingleBatteryView {
    if ([self.widgetModel.batteryState isKindOfClass:[DUXBetaBatteryState class]] || [self.widgetModel.batteryState isKindOfClass:[DUXAggregateBatteryState class]]) {
        self.singleBatteryImageView.image = [self currentIndicatorImageForSingleBattery:self.widgetModel.batteryState];
        [self.singleBatteryImageView setTintColor:[self.imageTintMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)]];
        self.singleBatteryPercentageLabel.textColor = [self.statusToPercentageColorMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)];
        
        CGFloat scaledFontSize = self.percentageFontSingle.pointSize * (self.singleBatteryPercentageLabel.frame.size.height / self.widgetSizeHint.minimumHeight);
        self.singleBatteryPercentageLabel.font = [self.percentageFontSingle fontWithSize:scaledFontSize];
        
        if (self.widgetModel.batteryState.warningStatus == DUXBetaBatteryStatusUnknown) {
            self.singleBatteryPercentageLabel.text =  NSLocalizedString(@"N/A", @"Battery Icon Label");
            return;
        }

        self.singleBatteryPercentageLabel.text = [NSString stringWithFormat:@"%.0f%%", self.widgetModel.batteryState.batteryPercentage];
    }
}

- (void)drawDualBatteryView {
    self.dualBatteryView = [[UIView alloc] init];
    self.dualBatteryView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dualBatteryView.hidden = YES;
    
    [self.view addSubview:self.dualBatteryView];
    
    [self.dualBatteryView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.dualBatteryView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.dualBatteryView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.dualBatteryView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

    UIImage *currentBatteryImage = [self currentIndicatorImageForDualBattery:self.widgetModel.batteryState];
    
    self.dualBatteryImageView = [[UIImageView alloc] initWithImage:currentBatteryImage];
    self.dualBatteryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryImageView setTintColor:[self.imageTintMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)]];
    
    CGFloat iconAspectRatio = currentBatteryImage.size.width / currentBatteryImage.size.height;
    [self.dualBatteryImageView.widthAnchor constraintLessThanOrEqualToAnchor:self.dualBatteryImageView.heightAnchor multiplier:iconAspectRatio].active = YES;
    
    [self.dualBatteryView addSubview:self.dualBatteryImageView];

    [self.dualBatteryImageView.leadingAnchor constraintEqualToAnchor:self.dualBatteryView.leadingAnchor].active = YES;
    [self.dualBatteryImageView.heightAnchor constraintLessThanOrEqualToAnchor:self.dualBatteryView.heightAnchor].active = YES;
    [self.dualBatteryImageView.centerYAnchor constraintEqualToAnchor:self.dualBatteryView.centerYAnchor].active = YES;
    [self.dualBatteryImageView.widthAnchor constraintEqualToAnchor:self.dualBatteryView.widthAnchor multiplier:kWidgetIconDualToWidgetWidthRatio].active = YES;

    self.dualBatteryImageView.contentMode = UIViewContentModeScaleAspectFit;

    self.dualBatteryBatteryOnePercentageLabel = [[UILabel alloc] init];
    [self.dualBatteryView addSubview:self.dualBatteryBatteryOnePercentageLabel];

    self.dualBatteryBatteryOnePercentageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryOnePercentageLabel.leadingAnchor constraintEqualToAnchor:self.dualBatteryImageView.trailingAnchor].active = YES;
    [self.dualBatteryBatteryOnePercentageLabel.topAnchor constraintEqualToAnchor:self.dualBatteryView.topAnchor].active = YES;
    [self.dualBatteryBatteryOnePercentageLabel.bottomAnchor constraintEqualToAnchor:self.dualBatteryView.centerYAnchor].active = YES;
    [self.dualBatteryBatteryOnePercentageLabel.widthAnchor constraintEqualToAnchor:self.dualBatteryView.widthAnchor multiplier:kWidgetIconDualToWidgetWidthRatio].active = YES;

    self.dualBatteryBatteryOnePercentageLabel.textColor = [self.statusToPercentageColorMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)];
    self.dualBatteryBatteryOnePercentageLabel.font = self.percentageFontDual;
    self.dualBatteryBatteryOnePercentageLabel.textAlignment = NSTextAlignmentCenter;
    self.dualBatteryBatteryOnePercentageLabel.minimumScaleFactor = 0.1;
    self.dualBatteryBatteryOnePercentageLabel.adjustsFontSizeToFitWidth = YES;
    self.dualBatteryBatteryOnePercentageLabel.numberOfLines = 0;
    self.dualBatteryBatteryOnePercentageLabel.lineBreakMode = NSLineBreakByClipping;

    self.dualBatteryBatteryTwoPercentageLabel = [[UILabel alloc] init];
    [self.dualBatteryView addSubview:self.dualBatteryBatteryTwoPercentageLabel];
    self.dualBatteryBatteryTwoPercentageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryTwoPercentageLabel.topAnchor constraintEqualToAnchor:self.dualBatteryView.centerYAnchor].active = YES;
    [self.dualBatteryBatteryTwoPercentageLabel.leadingAnchor constraintEqualToAnchor:self.dualBatteryImageView.trailingAnchor].active = YES;
    [self.dualBatteryBatteryTwoPercentageLabel.bottomAnchor constraintEqualToAnchor:self.dualBatteryView.bottomAnchor].active = YES;
    [self.dualBatteryBatteryTwoPercentageLabel.widthAnchor constraintEqualToAnchor:self.dualBatteryView.widthAnchor multiplier:kWidgetIconDualToWidgetWidthRatio].active = YES;

    self.dualBatteryBatteryTwoPercentageLabel.textColor = [self.statusToPercentageColorMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)];
    self.dualBatteryBatteryTwoPercentageLabel.font = self.percentageFontDual;
    self.dualBatteryBatteryTwoPercentageLabel.textAlignment = NSTextAlignmentCenter;
    self.dualBatteryBatteryTwoPercentageLabel.minimumScaleFactor = 0.1;
    self.dualBatteryBatteryTwoPercentageLabel.adjustsFontSizeToFitWidth = YES;
    self.dualBatteryBatteryTwoPercentageLabel.numberOfLines = 0;
    self.dualBatteryBatteryTwoPercentageLabel.lineBreakMode = NSLineBreakByClipping;

    self.dualBatteryBatteryOneBorderRectangle = [[UIView alloc] init];
    [self.dualBatteryView addSubview:self.dualBatteryBatteryOneBorderRectangle];

    self.dualBatteryBatteryOneBorderRectangle.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.dualBatteryBatteryOneBorderRectangle.leadingAnchor constraintEqualToAnchor:self.dualBatteryBatteryOnePercentageLabel.trailingAnchor].active = YES;
    [self.dualBatteryBatteryOneBorderRectangle.topAnchor constraintEqualToAnchor:self.dualBatteryView.topAnchor].active = YES;
    [self.dualBatteryBatteryOneBorderRectangle.bottomAnchor constraintEqualToAnchor:self.dualBatteryView.centerYAnchor constant: -1].active = YES;
    [self.dualBatteryBatteryOneBorderRectangle.trailingAnchor constraintEqualToAnchor:self.dualBatteryView.trailingAnchor].active = YES;

    self.dualBatteryBatteryOneBorderRectangle.backgroundColor = [UIColor clearColor];
    self.dualBatteryBatteryOneBorderRectangle.layer.borderColor = [self.statusToPercentageColorMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)].CGColor;
    self.dualBatteryBatteryOneBorderRectangle.layer.borderWidth = self.view.frame.size.height * kBoxWidthToWidgetHeightRatio;

    self.dualBatteryBatteryTwoBorderRectangle = [[UIView alloc] init];
    [self.dualBatteryView addSubview:self.dualBatteryBatteryTwoBorderRectangle];

    self.dualBatteryBatteryTwoBorderRectangle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryTwoBorderRectangle.leadingAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoPercentageLabel.trailingAnchor].active = YES;
    [self.dualBatteryBatteryTwoBorderRectangle.topAnchor constraintEqualToAnchor:self.dualBatteryView.centerYAnchor constant:1].active = YES;
    [self.dualBatteryBatteryTwoBorderRectangle.bottomAnchor constraintEqualToAnchor:self.dualBatteryView.bottomAnchor].active = YES;
    [self.dualBatteryBatteryTwoBorderRectangle.trailingAnchor constraintEqualToAnchor:self.dualBatteryView.trailingAnchor].active = YES;

    self.dualBatteryBatteryTwoBorderRectangle.backgroundColor = [UIColor clearColor];
    self.dualBatteryBatteryTwoBorderRectangle.layer.borderColor = [self.statusToPercentageColorMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)].CGColor;
    self.dualBatteryBatteryTwoBorderRectangle.layer.borderWidth = self.view.frame.size.height * kBoxWidthToWidgetHeightRatio;

    self.dualBatteryBatteryOneVoltageLabel = [[UILabel alloc] init];
    [self.dualBatteryView insertSubview:self.dualBatteryBatteryOneVoltageLabel aboveSubview:self.dualBatteryBatteryOneBorderRectangle];
    self.dualBatteryBatteryOneVoltageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryOneVoltageLabel.widthAnchor constraintEqualToAnchor:self.dualBatteryBatteryOneBorderRectangle.widthAnchor multiplier:kVoltageLabelToBoxWidthRatio].active = YES;
    [self.dualBatteryBatteryOneVoltageLabel.centerXAnchor constraintEqualToAnchor:self.dualBatteryBatteryOneBorderRectangle.centerXAnchor].active = YES;
    [self.dualBatteryBatteryOneVoltageLabel.topAnchor constraintEqualToAnchor:self.dualBatteryBatteryOneBorderRectangle.topAnchor constant:1].active = YES;
    [self.dualBatteryBatteryOneVoltageLabel.bottomAnchor constraintEqualToAnchor:self.dualBatteryBatteryOneBorderRectangle.bottomAnchor constant:-1].active = YES;

    self.dualBatteryBatteryOneVoltageLabel.textColor = [self.statusToVoltageColorMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)];
    self.dualBatteryBatteryOneVoltageLabel.font = self.voltageFontDual;
    self.dualBatteryBatteryOneVoltageLabel.textAlignment = NSTextAlignmentCenter;
    self.dualBatteryBatteryOneVoltageLabel.minimumScaleFactor = 0.1;
    self.dualBatteryBatteryOneVoltageLabel.adjustsFontSizeToFitWidth = YES;
    self.dualBatteryBatteryOneVoltageLabel.numberOfLines = 0;
    self.dualBatteryBatteryOneVoltageLabel.lineBreakMode = NSLineBreakByClipping;

    self.dualBatteryBatteryTwoVoltageLabel = [[UILabel alloc] init];
    [self.dualBatteryView insertSubview:self.dualBatteryBatteryTwoVoltageLabel aboveSubview:self.dualBatteryBatteryTwoBorderRectangle];
    self.dualBatteryBatteryTwoVoltageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryTwoVoltageLabel.widthAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoBorderRectangle.widthAnchor multiplier:kVoltageLabelToBoxWidthRatio].active = YES;
    [self.dualBatteryBatteryTwoVoltageLabel.centerXAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoBorderRectangle.centerXAnchor].active = YES;
    [self.dualBatteryBatteryTwoVoltageLabel.bottomAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoBorderRectangle.bottomAnchor constant:-1].active = YES;
    [self.dualBatteryBatteryTwoVoltageLabel.topAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoBorderRectangle.topAnchor constant:1].active = YES;

    self.dualBatteryBatteryTwoVoltageLabel.textColor = [self.statusToVoltageColorMapping objectForKey:@(self.widgetModel.batteryState.warningStatus)];
    self.dualBatteryBatteryTwoVoltageLabel.font = self.voltageFontDual;
    self.dualBatteryBatteryTwoVoltageLabel.textAlignment = NSTextAlignmentCenter;
    self.dualBatteryBatteryTwoVoltageLabel.minimumScaleFactor = 0.1;
    self.dualBatteryBatteryTwoVoltageLabel.adjustsFontSizeToFitWidth = YES;
    self.dualBatteryBatteryTwoVoltageLabel.numberOfLines = 0;
    self.dualBatteryBatteryTwoVoltageLabel.lineBreakMode = NSLineBreakByClipping;
}

- (void)updateDualBatteryView:(DUXDualBatteryState *)dualBatteryState {
    self.dualBatteryImageView.image = [self currentIndicatorImageForDualBattery:dualBatteryState];
    [self.dualBatteryImageView setTintColor:[self.imageTintMapping objectForKey:@(dualBatteryState.warningStatus)]];

    self.dualBatteryBatteryOnePercentageLabel.textColor = [self.statusToPercentageColorMapping objectForKey:@(dualBatteryState.warningStatus)];
    self.dualBatteryBatteryTwoPercentageLabel.textColor = [self.statusToPercentageColorMapping objectForKey:@(dualBatteryState.warningStatus)];
    self.dualBatteryBatteryOneVoltageLabel.textColor = [self.statusToPercentageColorMapping objectForKey:@(dualBatteryState.warningStatus)];
    self.dualBatteryBatteryTwoVoltageLabel.textColor = [self.statusToPercentageColorMapping objectForKey:@(dualBatteryState.warningStatus)];
    self.dualBatteryBatteryOneBorderRectangle.layer.borderColor = [self.statusToVoltageColorMapping objectForKey:@(dualBatteryState.warningStatus)].CGColor;
    self.dualBatteryBatteryTwoBorderRectangle.layer.borderColor = [self.statusToVoltageColorMapping objectForKey:@(dualBatteryState.warningStatus)].CGColor;
    
    if (dualBatteryState.warningStatus == DUXBetaBatteryStatusUnknown) {
        self.dualBatteryBatteryOnePercentageLabel.text = NSLocalizedString(@"N/A", @"Battery Icon Label");
        self.dualBatteryBatteryTwoPercentageLabel.text = NSLocalizedString(@"N/A", @"Battery Icon Label");
        self.dualBatteryBatteryOneVoltageLabel.text = NSLocalizedString(@"N/A", @"Battery Icon Label");
        self.dualBatteryBatteryTwoVoltageLabel.text = NSLocalizedString(@"N/A", @"Battery Icon Label");
    } else {
        self.dualBatteryBatteryOnePercentageLabel.text = [NSString stringWithFormat:@"%.0f%%", dualBatteryState.batteryPercentage];
        self.dualBatteryBatteryTwoPercentageLabel.text = [NSString stringWithFormat:@"%.0f%%", dualBatteryState.battery2Percentage];
        self.dualBatteryBatteryOneVoltageLabel.text = [NSString stringWithFormat:@"%.2fV", dualBatteryState.voltage.doubleValue];
        self.dualBatteryBatteryTwoVoltageLabel.text = [NSString stringWithFormat:@"%.2fV", dualBatteryState.battery2Voltage.doubleValue];
    }
    
    self.dualBatteryBatteryOnePercentageLabel.font = [self.percentageFontDual fontWithSize:self.dualBatteryBatteryOnePercentageLabel.frame.size.height * self.percentageFontDual.pointSize/self.widgetSizeHint.minimumHeight];
    self.dualBatteryBatteryTwoPercentageLabel.font = [self.percentageFontDual fontWithSize:self.dualBatteryBatteryTwoPercentageLabel.frame.size.height * self.percentageFontDual.pointSize/self.widgetSizeHint.minimumHeight];
    
    self.dualBatteryBatteryOneVoltageLabel.font = [self.voltageFontDual fontWithSize:self.dualBatteryBatteryOneVoltageLabel.frame.size.height * self.voltageFontDual.pointSize/self.widgetSizeHint.minimumHeight];
    self.dualBatteryBatteryTwoVoltageLabel.font = [self.voltageFontDual fontWithSize:self.dualBatteryBatteryTwoVoltageLabel.frame.size.height * self.voltageFontDual.pointSize/self.widgetSizeHint.minimumHeight];
    
    self.dualBatteryBatteryOneBorderRectangle.layer.borderWidth = self.view.frame.size.height * kBoxWidthToWidgetHeightRatio;
    self.dualBatteryBatteryTwoBorderRectangle.layer.borderWidth = self.view.frame.size.height * kBoxWidthToWidgetHeightRatio;
}

- (void)updateUI {
    if ([self.widgetModel.batteryState isMemberOfClass:[DUXDualBatteryState class]]) {
        self.singleBatteryViewAspectRatioConstraint.active = NO;
        if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateSingleBattery) {
            self.widgetDisplayState = DUXBetaBatteryWidgetDisplayStateDualBattery;
            if ([self.delegate respondsToSelector:@selector(batteryWidgetChangedDisplayState:)]) {
                [self.delegate batteryWidgetChangedDisplayState:DUXBetaBatteryWidgetDisplayStateDualBattery];
            }
        }
        if (!self.dualBatteryView) {
            [self drawDualBatteryView];
        }
        self.singleBatteryView.hidden = YES;
        self.dualBatteryView.hidden = NO;
        [self updateDualBatteryView:(DUXDualBatteryState *)self.widgetModel.batteryState];
    } else if ([self.widgetModel.batteryState isMemberOfClass:[DUXBetaBatteryState class]] || [self.widgetModel.batteryState isMemberOfClass:[DUXAggregateBatteryState class]]) {
        self.singleBatteryViewAspectRatioConstraint.active = YES;
        if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateDualBattery) {
            self.widgetDisplayState = DUXBetaBatteryWidgetDisplayStateSingleBattery;
            if ([self.delegate respondsToSelector:@selector(batteryWidgetChangedDisplayState:)]) {
                [self.delegate batteryWidgetChangedDisplayState:DUXBetaBatteryWidgetDisplayStateSingleBattery];
            }
        }
        self.dualBatteryView.hidden = YES;
        self.singleBatteryView.hidden = NO;
        [self updateSingleBatteryView];
    }
}

- (void)widgetTapped {
    [[DUXStateChangeBroadcaster instance] send:[DUXBatteryWidgetUIState widgetTap]];
}

- (void)sendIsProductConnected {
    [[DUXStateChangeBroadcaster instance] send:[DUXBatteryWidgetModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendBatteryStateUpdate {
    [[DUXStateChangeBroadcaster instance] send:[DUXBatteryWidgetModelState batteryStateUpdate:self.widgetModel.batteryState]];
}

- (UIImage *)currentIndicatorImageForSingleBattery:(DUXBetaBatteryState *)state {
    UIImage* indicatorImage = [self.singleBatteryImageMapping objectForKey:@(state.warningStatus)];
    return [indicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIImage *)currentIndicatorImageForDualBattery:(DUXBetaBatteryState *)state {
    UIImage* indicatorImage = [self.dualBatteryImageMapping objectForKey:@(state.warningStatus)];
    return [indicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setImage:(UIImage *)image forSingleBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    [self.singleBatteryImageMapping setObject:image forKey:@(batteryStatus)];
    [self updateCurrentBatteryView];
}

- (void)setImage:(UIImage *)image forDualBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    [self.dualBatteryImageMapping setObject:image forKey:@(batteryStatus)];
    [self updateCurrentBatteryView];
}

- (void)setVoltageColor:(UIColor *)color forBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    [self.statusToVoltageColorMapping setObject:color forKey:@(batteryStatus)];
    [self updateCurrentBatteryView];
}

- (void)setPercentageColor:(UIColor *)color forBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    [self.statusToPercentageColorMapping setObject:color forKey:@(batteryStatus)];
    [self updateCurrentBatteryView];
}

- (void)setPercentageFontSingle:(UIFont *)percentageFontSingle {
    _percentageFontSingle = percentageFontSingle;
    [self updateCurrentBatteryView];
}

- (void)setPercentageFontDual:(UIFont *)percentageFontDual {
    _percentageFontDual = percentageFontDual;
    [self updateCurrentBatteryView];
}

- (void)setVoltageFontDual:(UIFont *)voltageFontDual {
    _voltageFontDual = voltageFontDual;
    [self updateCurrentBatteryView];
}

- (void)setTintColor:(UIColor *)color forBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    [self.imageTintMapping setObject:color forKey:@(batteryStatus)];
}

- (UIColor *)getTintColorForBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    return [self.imageTintMapping objectForKey:@(batteryStatus)];
}

- (void)updateCurrentBatteryView {
    if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateDualBattery) {
        [self updateDualBatteryView:(DUXDualBatteryState *)self.widgetModel.batteryState];
    } else {
        [self updateSingleBatteryView];
    }
}

- (UIColor *)getVoltageColorForBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    return [self.statusToVoltageColorMapping objectForKey:@(batteryStatus)];
}

- (UIColor *)getPercentageColorForBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    return [self.statusToPercentageColorMapping objectForKey:@(batteryStatus)];
}

- (UIImage *)getImageForSingleBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    return [self.singleBatteryImageMapping objectForKey:@(batteryStatus)];
}

- (UIImage *)getImageForDualBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    return [self.dualBatteryImageMapping objectForKey:@(batteryStatus)];
}

- (void)updateMinImageDimensions {
    CGSize iconMaxSizeSingle = [self maxSizeInImageArray:[self.singleBatteryImageMapping allValues]];
    CGFloat widgetWidthSingle = iconMaxSizeSingle.width / kSingleIconWidthToWidgetWidthRatio;
    _minWidgetSizeSingleBattery = CGSizeMake(widgetWidthSingle, iconMaxSizeSingle.height);
    
    CGSize iconMaxSizeDual = [self maxSizeInImageArray:[self.dualBatteryImageMapping allValues]];
    CGFloat widgetWidthDual = iconMaxSizeDual.width / kWidgetIconDualToWidgetWidthRatio;
    _minWidgetSizeDualBattery = CGSizeMake(widgetWidthDual, iconMaxSizeDual.height / kDualAspectRatio);
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateSingleBattery) {
        DUXBetaWidgetSizeHint hint = {self.minWidgetSizeSingleBattery.width / self.minWidgetSizeSingleBattery.height, self.minWidgetSizeSingleBattery.width, self.minWidgetSizeSingleBattery.height};
        return hint;
    } else {
        DUXBetaWidgetSizeHint hint = {self.minWidgetSizeDualBattery.width / self.minWidgetSizeDualBattery.height, self.minWidgetSizeDualBattery.width, self.minWidgetSizeDualBattery.height};
        return hint;
    }
}

@end

@implementation DUXBatteryWidgetUIState

+ (instancetype)widgetTap {
    return [[DUXBatteryWidgetUIState alloc] initWithKey:@"widgetTap" number:@(0)];
}

@end

@implementation DUXBatteryWidgetModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[DUXBatteryWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)batteryStateUpdate:(DUXBetaBatteryState *)batteryState {
    return [[DUXBatteryWidgetModelState alloc] initWithKey:@"batteryStateUpdate" object:batteryState];
}

@end
