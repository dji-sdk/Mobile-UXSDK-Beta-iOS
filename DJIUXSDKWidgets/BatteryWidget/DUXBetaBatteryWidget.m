//
//  DUXBetaBatteryWidget.m
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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
@import DJIUXSDKCore;

static CGSize const kDesignSizeOneBattery = {44.0, 18.0};
static CGSize const kDesignSizeTwoBatteries = {88.0, 30.0};

@interface DUXBetaBatteryWidget ()

@property (nonatomic, readwrite) DUXBetaBatteryWidgetDisplayState widgetDisplayState;

//single battery
@property (nonatomic) UIView *singleBatteryView;
@property (nonatomic) UIImageView *singleBatteryImageView;
@property (nonatomic) UILabel *singleBatteryPercentageLabel;

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
@property (nonatomic) NSMutableDictionary <NSNumber *, UIColor *> *statusToColorMapping;

@end

@implementation DUXBetaBatteryWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _singleBatteryImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                           @(DUXBetaBatteryStatusNormal) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryNormal"],
                                                                                           @(DUXBetaBatteryStatusError) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryError"],
                                                                                           @(DUXBetaBatteryStatusWarningLevel1) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryDangerous"],
                                                                                           @(DUXBetaBatteryStatusWarningLevel2) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryThunder"],
                                                                                           @(DUXBetaBatteryStatusOverheating) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryOverheating"],
                                                                                           @(DUXBetaBatteryStatusUnknown) : [UIImage duxbeta_imageWithAssetNamed:@"BatteryNormal"]
                                                                                           }];
        _dualBatteryImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                         @(DUXBetaBatteryStatusNormal) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryNormal"],
                                                                                         @(DUXBetaBatteryStatusError) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryNormal"],
                                                                                         @(DUXBetaBatteryStatusWarningLevel1) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryDangerous"],
                                                                                         @(DUXBetaBatteryStatusWarningLevel2) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryDangerous"],
                                                                                         @(DUXBetaBatteryStatusOverheating) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryOverheating"],
                                                                                         @(DUXBetaBatteryStatusUnknown) : [UIImage duxbeta_imageWithAssetNamed:@"DoubleBatteryNormal"]
                                                                                         }];
        _statusToColorMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                      @(DUXBetaBatteryStatusNormal) : [UIColor whiteColor],
                                                                                      @(DUXBetaBatteryStatusError) : [UIColor duxbeta_dangerColor],
                                                                                      @(DUXBetaBatteryStatusWarningLevel1) : [UIColor duxbeta_dangerColor],
                                                                                      @(DUXBetaBatteryStatusWarningLevel2) : [UIColor duxbeta_dangerColor],
                                                                                      @(DUXBetaBatteryStatusUnknown) : [UIColor duxbeta_dangerColor]
                                                                                      }];
        _voltageFont = [UIFont boldSystemFontOfSize:20.0];
        _percentageFont = [UIFont boldSystemFontOfSize:20.0];
        _widgetDisplayState = DUXBetaBatteryWidgetDisplayStateSingleBattery;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel = [[DUXBetaBatteryWidgetModel alloc] init];
    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)setupUI {
    [self drawSingleBatteryView];
}

- (void)drawSingleBatteryView {
    self.singleBatteryView = [[UIView alloc] init];
    self.singleBatteryView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.singleBatteryView];
    [self.singleBatteryView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.singleBatteryView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.singleBatteryView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.singleBatteryView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    self.singleBatteryImageView = [[UIImageView alloc] initWithImage:[self currentIndicatorImageForSingleBattery:[self.widgetModel.batteryInformation objectForKey:kDUXBetaBattery1Key]]];
    
    [self.singleBatteryView addSubview:self.singleBatteryImageView];
    
    self.singleBatteryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.singleBatteryImageView.leadingAnchor constraintEqualToAnchor:self.singleBatteryView.leadingAnchor].active = YES;
    [self.singleBatteryImageView.topAnchor constraintEqualToAnchor:self.singleBatteryView.topAnchor].active = YES;
    [self.singleBatteryImageView.bottomAnchor constraintEqualToAnchor:self.singleBatteryView.bottomAnchor].active = YES;
    [self.singleBatteryImageView.trailingAnchor constraintEqualToAnchor:self.singleBatteryView.centerXAnchor].active = YES;
    
    self.singleBatteryImageView.contentMode = UIViewContentModeScaleAspectFit;

    [self.singleBatteryImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.singleBatteryPercentageLabel = [[UILabel alloc] init];
    [self.singleBatteryView addSubview:self.singleBatteryPercentageLabel];
    self.singleBatteryPercentageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.singleBatteryPercentageLabel.leadingAnchor constraintEqualToAnchor:self.singleBatteryImageView.trailingAnchor].active = YES;
    [self.singleBatteryPercentageLabel.trailingAnchor constraintEqualToAnchor:self.singleBatteryView.trailingAnchor].active = YES;
    [self.singleBatteryPercentageLabel.topAnchor constraintEqualToAnchor:self.singleBatteryView.topAnchor].active = YES;
    [self.singleBatteryPercentageLabel.bottomAnchor constraintEqualToAnchor:self.singleBatteryView.bottomAnchor].active = YES;
    self.singleBatteryPercentageLabel.textColor = [UIColor whiteColor];
    self.singleBatteryPercentageLabel.font = self.percentageFont;
    self.singleBatteryPercentageLabel.textAlignment = NSTextAlignmentLeft;
    self.singleBatteryPercentageLabel.minimumScaleFactor = 0.1;
    self.singleBatteryPercentageLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)updateSingleBatteryView {
    DUXBetaBatteryState *battery1State = [self.widgetModel.batteryInformation objectForKey:kDUXBetaBattery1Key];
    if (battery1State) {
        self.singleBatteryImageView.image = [self currentIndicatorImageForSingleBattery:battery1State];
        
        if (battery1State.state == DUXBetaBatteryStatusUnknown) {
            self.singleBatteryPercentageLabel.text =  NSLocalizedString(@"N/A", @"Battery Icon Label");
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusUnknown)];
            self.singleBatteryPercentageLabel.font = [self.percentageFont fontWithSize:self.singleBatteryPercentageLabel.frame.size.height * self.percentageFont.pointSize/self.widgetSizeHint.minimumHeight];
            return;
        } else if (battery1State.state == DUXBetaBatteryStatusNormal) {
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusNormal)];
        } else if (battery1State.state == DUXBetaBatteryStatusError) {
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusError)];
        } else if (battery1State.state == DUXBetaBatteryStatusWarningLevel1) {
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusWarningLevel1)];
        } else if (battery1State.state == DUXBetaBatteryStatusWarningLevel2) {
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusWarningLevel2)];
        }
        
        self.singleBatteryPercentageLabel.text = [NSString stringWithFormat:@"%.0f%%", battery1State.batteryPercentage];
    }
    
    DUXBetaBatteryState *batteryAggregationState = [self.widgetModel.batteryInformation objectForKey:kDUXBetaBatteryAggregationKey];
    if (batteryAggregationState) {
        self.singleBatteryImageView.image = [self currentIndicatorImageForSingleBattery:batteryAggregationState];
        
        if (batteryAggregationState.state == DUXBetaBatteryStatusUnknown) {
            self.singleBatteryPercentageLabel.text =  NSLocalizedString(@"N/A", @"Battery Icon Label");
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusUnknown)];
            self.singleBatteryPercentageLabel.font = [self.percentageFont fontWithSize:self.singleBatteryPercentageLabel.frame.size.height * self.percentageFont.pointSize/self.widgetSizeHint.minimumHeight];
            return;
        } else if (batteryAggregationState.state == DUXBetaBatteryStatusNormal) {
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusNormal)];
        } else if (batteryAggregationState.state == DUXBetaBatteryStatusError) {
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusError)];
        } else if (batteryAggregationState.state == DUXBetaBatteryStatusWarningLevel1) {
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusWarningLevel1)];
        } else if (batteryAggregationState.state == DUXBetaBatteryStatusWarningLevel2) {
            self.singleBatteryPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(DUXBetaBatteryStatusWarningLevel2)];
        }
        
        self.singleBatteryPercentageLabel.text = [NSString stringWithFormat:@"%.0f%%", batteryAggregationState.batteryPercentage];
        self.singleBatteryPercentageLabel.font = [self.percentageFont fontWithSize:self.singleBatteryPercentageLabel.frame.size.height * self.percentageFont.pointSize/self.widgetSizeHint.minimumHeight];
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
    
    self.dualBatteryImageView = [[UIImageView alloc] initWithImage:[self.dualBatteryImageMapping objectForKey:@(DUXBetaBatteryStatusUnknown)]];
    
    [self.dualBatteryView addSubview:self.dualBatteryImageView];

    self.dualBatteryImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.dualBatteryImageView.leadingAnchor constraintEqualToAnchor:self.dualBatteryView.leadingAnchor].active = YES;
    [self.dualBatteryImageView.topAnchor constraintEqualToAnchor:self.dualBatteryView.topAnchor].active = YES;
    [self.dualBatteryImageView.bottomAnchor constraintEqualToAnchor:self.dualBatteryView.bottomAnchor].active = YES;
    [self.dualBatteryImageView.widthAnchor constraintEqualToAnchor:self.dualBatteryView.widthAnchor multiplier:.33].active = YES;

    self.dualBatteryImageView.contentMode = UIViewContentModeScaleAspectFit;

    self.dualBatteryBatteryOnePercentageLabel = [[UILabel alloc] init];
    [self.dualBatteryView addSubview:self.dualBatteryBatteryOnePercentageLabel];

    self.dualBatteryBatteryOnePercentageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryOnePercentageLabel.leadingAnchor constraintEqualToAnchor:self.dualBatteryImageView.trailingAnchor].active = YES;
    [self.dualBatteryBatteryOnePercentageLabel.topAnchor constraintEqualToAnchor:self.dualBatteryView.topAnchor].active = YES;
    [self.dualBatteryBatteryOnePercentageLabel.bottomAnchor constraintEqualToAnchor:self.dualBatteryView.centerYAnchor].active = YES;
    [self.dualBatteryBatteryOnePercentageLabel.widthAnchor constraintEqualToAnchor:self.dualBatteryView.widthAnchor multiplier:.33].active = YES;

    self.dualBatteryBatteryOnePercentageLabel.textColor = [UIColor whiteColor];
    self.dualBatteryBatteryOnePercentageLabel.font = self.percentageFont;
    self.dualBatteryBatteryOnePercentageLabel.textAlignment = NSTextAlignmentLeft;
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
    [self.dualBatteryBatteryTwoPercentageLabel.widthAnchor constraintEqualToAnchor:self.dualBatteryView.widthAnchor multiplier:.33].active = YES;

    self.dualBatteryBatteryTwoPercentageLabel.textColor = [UIColor whiteColor];
    self.dualBatteryBatteryTwoPercentageLabel.font = self.percentageFont;
    self.dualBatteryBatteryTwoPercentageLabel.textAlignment = NSTextAlignmentLeft;
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
    self.dualBatteryBatteryOneBorderRectangle.layer.borderColor = [UIColor whiteColor].CGColor;
    self.dualBatteryBatteryOneBorderRectangle.layer.borderWidth = 2.0f;

    self.dualBatteryBatteryTwoBorderRectangle = [[UIView alloc] init];
    [self.dualBatteryView addSubview:self.dualBatteryBatteryTwoBorderRectangle];

    self.dualBatteryBatteryTwoBorderRectangle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryTwoBorderRectangle.leadingAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoPercentageLabel.trailingAnchor].active = YES;
    [self.dualBatteryBatteryTwoBorderRectangle.topAnchor constraintEqualToAnchor:self.dualBatteryView.centerYAnchor constant:1].active = YES;
    [self.dualBatteryBatteryTwoBorderRectangle.bottomAnchor constraintEqualToAnchor:self.dualBatteryView.bottomAnchor].active = YES;
    [self.dualBatteryBatteryTwoBorderRectangle.trailingAnchor constraintEqualToAnchor:self.dualBatteryView.trailingAnchor].active = YES;

    self.dualBatteryBatteryTwoBorderRectangle.backgroundColor = [UIColor clearColor];
    self.dualBatteryBatteryTwoBorderRectangle.layer.borderColor = [UIColor whiteColor].CGColor;
    self.dualBatteryBatteryTwoBorderRectangle.layer.borderWidth = 2.0f;

    self.dualBatteryBatteryOneVoltageLabel = [[UILabel alloc] init];
    [self.dualBatteryView insertSubview:self.dualBatteryBatteryOneVoltageLabel aboveSubview:self.dualBatteryBatteryOneBorderRectangle];
    self.dualBatteryBatteryOneVoltageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryOneVoltageLabel.leadingAnchor constraintEqualToAnchor:self.dualBatteryBatteryOneBorderRectangle.leadingAnchor constant:1].active = YES;
    [self.dualBatteryBatteryOneVoltageLabel.trailingAnchor constraintEqualToAnchor:self.dualBatteryBatteryOneBorderRectangle.trailingAnchor constant:-1].active = YES;
    [self.dualBatteryBatteryOneVoltageLabel.topAnchor constraintEqualToAnchor:self.dualBatteryBatteryOneBorderRectangle.topAnchor constant:1].active = YES;
    [self.dualBatteryBatteryOneVoltageLabel.bottomAnchor constraintEqualToAnchor:self.dualBatteryBatteryOneBorderRectangle.bottomAnchor constant:-1].active = YES;

    self.dualBatteryBatteryOneVoltageLabel.textColor = [UIColor whiteColor];
    self.dualBatteryBatteryOneVoltageLabel.font = self.voltageFont;
    self.dualBatteryBatteryOneVoltageLabel.textAlignment = NSTextAlignmentCenter;
    self.dualBatteryBatteryOneVoltageLabel.minimumScaleFactor = 0.1;
    self.dualBatteryBatteryOneVoltageLabel.adjustsFontSizeToFitWidth = YES;
    self.dualBatteryBatteryOneVoltageLabel.numberOfLines = 0;
    self.dualBatteryBatteryOneVoltageLabel.lineBreakMode = NSLineBreakByClipping;

    self.dualBatteryBatteryTwoVoltageLabel = [[UILabel alloc] init];
    [self.dualBatteryView insertSubview:self.dualBatteryBatteryTwoVoltageLabel aboveSubview:self.dualBatteryBatteryTwoBorderRectangle];
    self.dualBatteryBatteryTwoVoltageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dualBatteryBatteryTwoVoltageLabel.leadingAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoBorderRectangle.leadingAnchor constant:1].active = YES;
    [self.dualBatteryBatteryTwoVoltageLabel.trailingAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoBorderRectangle.trailingAnchor constant:-1].active = YES;
    [self.dualBatteryBatteryTwoVoltageLabel.bottomAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoBorderRectangle.bottomAnchor constant:-1].active = YES;
    [self.dualBatteryBatteryTwoVoltageLabel.topAnchor constraintEqualToAnchor:self.dualBatteryBatteryTwoBorderRectangle.topAnchor constant:1].active = YES;

    self.dualBatteryBatteryTwoVoltageLabel.textColor = [UIColor whiteColor];
    self.dualBatteryBatteryTwoVoltageLabel.font = self.voltageFont;
    self.dualBatteryBatteryTwoVoltageLabel.textAlignment = NSTextAlignmentCenter;
    self.dualBatteryBatteryTwoVoltageLabel.minimumScaleFactor = 0.1;
    self.dualBatteryBatteryTwoVoltageLabel.adjustsFontSizeToFitWidth = YES;
    self.dualBatteryBatteryTwoVoltageLabel.numberOfLines = 0;
    self.dualBatteryBatteryTwoVoltageLabel.lineBreakMode = NSLineBreakByClipping;
}

- (void)updateDualBatteryView {
    DUXBetaBatteryState *battery1State = [self.widgetModel.batteryInformation objectForKey:kDUXBetaBattery1Key];
    DUXBetaBatteryState *battery2State = [self.widgetModel.batteryInformation objectForKey:kDUXBetaBattery2Key];
    
    DUXBetaBatteryStatus worstStatus = [self worstBatteryStatusForBatteryStates:@[battery1State, battery2State]];
    self.dualBatteryImageView.image = [self currentIndicatorImageForBatteryStates:@[battery1State,battery2State]];
    
    self.dualBatteryBatteryOnePercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(worstStatus)];
    self.dualBatteryBatteryTwoPercentageLabel.textColor = [self.statusToColorMapping objectForKey:@(worstStatus)];
    self.dualBatteryBatteryOneVoltageLabel.textColor = [self.statusToColorMapping objectForKey:@(worstStatus)];
    self.dualBatteryBatteryTwoVoltageLabel.textColor = [self.statusToColorMapping objectForKey:@(worstStatus)];
    self.dualBatteryBatteryOneBorderRectangle.layer.borderColor = [self.statusToColorMapping objectForKey:@(worstStatus)].CGColor;
    self.dualBatteryBatteryTwoBorderRectangle.layer.borderColor = [self.statusToColorMapping objectForKey:@(worstStatus)].CGColor;
    
    if (worstStatus == DUXBetaBatteryStatusUnknown) {
        self.dualBatteryBatteryOnePercentageLabel.text = NSLocalizedString(@"N/A", @"Battery Icon Label");
        self.dualBatteryBatteryTwoPercentageLabel.text = NSLocalizedString(@"N/A", @"Battery Icon Label");
        self.dualBatteryBatteryOneVoltageLabel.text = NSLocalizedString(@"N/A", @"Battery Icon Label");
        self.dualBatteryBatteryTwoVoltageLabel.text = NSLocalizedString(@"N/A", @"Battery Icon Label");
    } else {
        self.dualBatteryBatteryOnePercentageLabel.text = [NSString stringWithFormat:@"%.0f%%", battery1State.batteryPercentage];
        self.dualBatteryBatteryTwoPercentageLabel.text = [NSString stringWithFormat:@"%.0f%%",battery2State.batteryPercentage];
        self.dualBatteryBatteryOneVoltageLabel.text = [NSString stringWithFormat:@"%.2fV",battery1State.voltage.doubleValue];
        self.dualBatteryBatteryTwoVoltageLabel.text = [NSString stringWithFormat:@"%.2fV",battery2State.voltage.doubleValue];
    }
    
    self.dualBatteryBatteryOnePercentageLabel.font = [self.percentageFont fontWithSize:self.dualBatteryBatteryOnePercentageLabel.frame.size.height * self.percentageFont.pointSize/self.widgetSizeHint.minimumHeight];
    self.dualBatteryBatteryTwoPercentageLabel.font = [self.percentageFont fontWithSize:self.dualBatteryBatteryTwoPercentageLabel.frame.size.height * self.percentageFont.pointSize/self.widgetSizeHint.minimumHeight];
    
    self.dualBatteryBatteryOneVoltageLabel.font = [self.voltageFont fontWithSize:self.dualBatteryBatteryOneVoltageLabel.frame.size.height * self.voltageFont.pointSize/self.widgetSizeHint.minimumHeight];
    self.dualBatteryBatteryTwoVoltageLabel.font = [self.voltageFont fontWithSize:self.dualBatteryBatteryTwoVoltageLabel.frame.size.height * self.voltageFont.pointSize/self.widgetSizeHint.minimumHeight];
    
    self.dualBatteryBatteryOneBorderRectangle.layer.borderWidth = self.dualBatteryBatteryOneBorderRectangle.frame.size.height * 2.0f / self.widgetSizeHint.minimumHeight;
    self.dualBatteryBatteryTwoBorderRectangle.layer.borderWidth = self.dualBatteryBatteryTwoBorderRectangle.frame.size.height * 2.0f / self.widgetSizeHint.minimumHeight;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.widgetModel setup];    
    BindRKVOModel(self.widgetModel, @selector(updateUI), batteryInformation);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.widgetModel duxbeta_removeCustomObserver:self];
    [self.widgetModel cleanup];
}

- (void)updateUI {
    if (self.widgetModel.batteryInformation.count == 2) {
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
        [self updateDualBatteryView];
    } else if (self.widgetModel.batteryInformation.count == 1 || self.widgetModel.batteryInformation.count == 0) {
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

- (UIImage *)currentIndicatorImageForSingleBattery:(DUXBetaBatteryState *)state {
    return [self.singleBatteryImageMapping objectForKey:@(state.state)];
}

- (UIImage *)currentIndicatorImageForBatteryStates:(NSArray <DUXBetaBatteryState *> *)states {
    return [self.dualBatteryImageMapping objectForKey:@([self worstBatteryStatusForBatteryStates:states])];
}

- (DUXBetaBatteryStatus)worstBatteryStatusForBatteryStates:(NSArray <DUXBetaBatteryState *> *)states {
    DUXBetaBatteryStatus worstStatusFound = DUXBetaBatteryStatusNormal;
    for (DUXBetaBatteryState *state in states) {
        if (state.state > worstStatusFound) {
            worstStatusFound = state.state;
        }
    }
    return worstStatusFound;
}

- (void)setImage:(UIImage *)image forSingleBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    [self.singleBatteryImageMapping setObject:image forKey:@(batteryStatus)];
    if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateDualBattery) {
        [self updateDualBatteryView];
    } else {
        [self updateSingleBatteryView];
    }
}

- (void)setImage:(UIImage *)image forDualBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    [self.dualBatteryImageMapping setObject:image forKey:@(batteryStatus)];
    if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateDualBattery) {
        [self updateDualBatteryView];
    } else {
        [self updateSingleBatteryView];
    }
}

- (void)setColor:(UIColor *)color forBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    [self.statusToColorMapping setObject:color forKey:@(batteryStatus)];
    if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateDualBattery) {
        [self updateDualBatteryView];
    } else {
        [self updateSingleBatteryView];
    }
}

- (void)setPercentageFont:(UIFont *)percentageFont {
    _percentageFont = percentageFont;
    if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateDualBattery) {
        [self updateDualBatteryView];
    } else {
        [self updateSingleBatteryView];
    }
}

- (void)setVoltageFont:(UIFont *)voltageFont {
    _voltageFont = voltageFont;
    if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateDualBattery) {
        [self updateDualBatteryView];
    } else {
        [self updateSingleBatteryView];
    }
}

- (UIColor *)getColorForBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    return [self.statusToColorMapping objectForKey:@(batteryStatus)];
}

- (UIImage *)getImageForSingleBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    return [self.singleBatteryImageMapping objectForKey:@(batteryStatus)];
}

- (UIImage *)getImageForDualBatteryStatus:(DUXBetaBatteryStatus)batteryStatus {
    return [self.dualBatteryImageMapping objectForKey:@(batteryStatus)];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    if (self.widgetDisplayState == DUXBetaBatteryWidgetDisplayStateSingleBattery) {
        DUXBetaWidgetSizeHint hint = {kDesignSizeOneBattery.width / kDesignSizeOneBattery.height, kDesignSizeOneBattery.width, kDesignSizeOneBattery.height};
        return hint;
    } else {
        DUXBetaWidgetSizeHint hint = {kDesignSizeTwoBatteries.width / kDesignSizeTwoBatteries.height, kDesignSizeTwoBatteries.width, kDesignSizeTwoBatteries.height};
        return hint;
    }
}

@end
