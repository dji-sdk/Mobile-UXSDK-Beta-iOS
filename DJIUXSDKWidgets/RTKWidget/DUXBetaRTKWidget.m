//
//  DUXBetaRTKSatelliteStatusWidget.h
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

#import "DUXBetaRTKWidget.h"
@import DJIUXSDKCore;

static const float kOKButtonLineWidth = 1.0;
static const float kOKButtonDefaultFontSize = 16.0;
static const float kOKButtonHeight = 35.0;
static const float kDisabledLabelHeight = 160.0;
static const float kDisabledLabelWidth = 420.0;
static const float kMaxHeightProportion = 0.75;
static const float kDisabledLabelDefaultFontSize = 11.0;
static const float kOkButtonTopSpace = 15.0;

static NSString *const kDisabledRTKMessage = @"Real-Time Kinematic positioning is based on the phase of the signal's carrier phase and outputs centimeter-level 3D positioning on particular coordinates. Heading is determined by the two antennas of the rover";


@interface DUXBetaRTKWidget ()

@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UILabel *rtkDisabledLabel;
@property (strong, nonatomic) UIView *rtkDisabledView;
@property (strong, nonatomic) UIView *buttonDividerView;
@property (strong, nonatomic) NSLayoutConstraint *scrollViewHeightConstraintLarge;
@property (strong, nonatomic) NSLayoutConstraint *scrollViewHeightConstraintSmall;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIStackView *stackView;

@end

/**
 * RTKWidgetUIState contains the hooks for UI changes in the widget class DUXBetaRTKWidget.
 * It implements the hook:
 *
 * Key: okTap    Type: NSNumber - Sends an NSNumber(0) when ok is tapped by the user.
*/
@interface RTKWidgetUIState : DUXBetaStateChangeBaseData

+ (instancetype)okTap;

@end

/**
 * RTKWidgetModelState contains the model hooks for the DUXBetaRTKWidget.
 * It implements the hooks:
 *
 * Key: productConnected         Type: NSNumber - Sends a boolean value as an NSNumber indicating the connected state of
 *                                               the device when it changes.
 *
 * Key: rtkEnabledUpdate         Type: NSNumber - Sends a boolean value as an NSNumber indicating if RTK is Enabled.
 * Key: visibilityUpdate         Type: NSNumber - Sends a boolean value as an NSNumber indicating if the widget is visible.
*/
@interface RTKWidgetModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;

+ (instancetype)rtkEnabledUpdate:(BOOL)isEnabled;

+ (instancetype)visibilityUpdate:(BOOL)isVisible;

@end


@implementation DUXBetaRTKWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _rtkEnabledWidget = [[DUXBetaRTKEnabledWidget alloc] init];
        _rtkSatelliteStatusWidget = [[DUXBetaRTKSatelliteStatusWidget alloc] init];
        _rtkDisabledLabel = [[UILabel alloc] init];
        
        _rtkDescriptionFont = [UIFont systemFontOfSize:kDisabledLabelDefaultFontSize];
        _rtkDescriptionTextColor = [UIColor duxbeta_whiteColor];
        _rtkDescriptionBackgroundColor = [UIColor duxbeta_clearColor];
        
        _okFont = [UIFont systemFontOfSize:kOKButtonDefaultFontSize];
        _okTextColor = [UIColor duxbeta_whiteColor];

        _okBackgroundColor = [UIColor duxbeta_clearColor];
        
        _separatorColor = [UIColor duxbeta_rtkTableBorderColor];
        _backgroundColor = [UIColor duxbeta_blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat widgetHeights = self.stackView.bounds.size.height;
    if ([self.view superview].bounds.size.height * kMaxHeightProportion > widgetHeights) {
        self.scrollViewHeightConstraintLarge = [self.scrollView.heightAnchor constraintEqualToAnchor:self.stackView.heightAnchor];
    } else {
        self.scrollViewHeightConstraintLarge = [self.scrollView.heightAnchor constraintEqualToConstant:[self.view superview].bounds.size.height * kMaxHeightProportion];
    }
    
    BindRKVOModel(self.rtkSatelliteStatusWidget.widgetModel, @selector(updateSatelliteStatusVisibility), rtkEnabled, isProductConnected);
    [[DUXBetaStateChangeBroadcaster instance] registerListener:self analyticsClassName:@"GPSSignalWidgetUIState" handler:^(DUXBetaStateChangeBaseData * _Nonnull analyticsData) {
        [self showWidgetIfSupported];
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKWidgetModelState visibilityUpdate:YES]];
    }];
    
    // Customizations
    BindRKVOModel(self, @selector(customizeDisabledLabel), rtkDescriptionTextColor, rtkDescriptionFont, rtkDescriptionBackgroundColor);
    BindRKVOModel(self, @selector(customizeOkButton), okTextColor, okFont, okBackgroundColor);
    BindRKVOModel(self, @selector(customizeBackground), backgroundColor, separatorColor);
}

- (void)setupUI {
    self.view.hidden = YES;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    [self.scrollView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.scrollView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    
    [self.scrollView.widthAnchor constraintEqualToConstant:self.rtkEnabledWidget.widgetSizeHint.minimumWidth].active = YES;
    
    self.stackView = [[UIStackView alloc] init];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.alignment = UIStackViewAlignmentLeading;
    [self.scrollView addSubview:self.stackView];

    [self.stackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
    [self.stackView.leftAnchor constraintEqualToAnchor:self.scrollView.leftAnchor].active = YES;
    [self.stackView.rightAnchor constraintEqualToAnchor:self.scrollView.rightAnchor].active = YES;
    [self.stackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor].active = YES;
    
    self.scrollViewHeightConstraintSmall = [self.scrollView.heightAnchor constraintEqualToAnchor:self.stackView.heightAnchor];//TODO: move to setupUI?
    
    // RTK Enabled Widget
    self.rtkEnabledWidget.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView addArrangedSubview:self.rtkEnabledWidget.view];
    
    // RTK Satellite Status Widget
    //[self.scrollView addSubview:self.rtkSatelliteStatusWidget.view];
    self.rtkSatelliteStatusWidget.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView addArrangedSubview:self.rtkSatelliteStatusWidget.view];
    
    // RTK Disabled Label View
    self.rtkDisabledView = [[UIView alloc] init];
    self.rtkDisabledView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rtkDisabledView.widthAnchor constraintEqualToConstant:500.0].active = YES;
    [self.rtkDisabledView.heightAnchor constraintEqualToConstant:kDisabledLabelHeight].active = YES;
    
    self.rtkDisabledLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rtkDisabledView addSubview:self.rtkDisabledLabel];
    [self.rtkDisabledLabel.widthAnchor constraintEqualToConstant:kDisabledLabelWidth].active = YES;
    [self.rtkDisabledLabel.heightAnchor constraintEqualToConstant:kDisabledLabelHeight].active = YES;
    [self.rtkDisabledLabel.centerYAnchor constraintEqualToAnchor:self.rtkDisabledView.centerYAnchor].active = YES;
    [self.rtkDisabledLabel.centerXAnchor constraintEqualToAnchor:self.rtkDisabledView.centerXAnchor].active = YES;
    self.rtkDisabledLabel.text = NSLocalizedString(kDisabledRTKMessage, @"RTKWidgetDisabledMessage");
    self.rtkDisabledLabel.numberOfLines = 3;
    
    [self.stackView addArrangedSubview:self.rtkDisabledView];
    
    // OK Button
    self.okButton = [[UIButton alloc] init];
    self.okButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.okButton];
    [self.okButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.okButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.okButton.topAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:kOkButtonTopSpace].active = YES;
    [self.okButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.okButton.heightAnchor constraintEqualToConstant:kOKButtonHeight].active = YES;
    self.okButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.okButton setTitle:NSLocalizedString(@"OK", @"RTKWidgetOK")  forState:UIControlStateNormal];
    self.okButton.hidden = NO;
    
    [self.okButton addTarget:self action:@selector(hideWidget) forControlEvents:UIControlEventTouchUpInside];
    
    self.buttonDividerView = [[UIView alloc] init];
    self.buttonDividerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.buttonDividerView];
    [self.buttonDividerView.heightAnchor constraintEqualToConstant:kOKButtonLineWidth].active = YES;
    [self.buttonDividerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.buttonDividerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.buttonDividerView.topAnchor constraintEqualToAnchor:self.okButton.topAnchor].active = YES;
}

- (void)hideWidget {
    [self.view setHidden:YES];
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKWidgetUIState okTap]];
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKWidgetModelState visibilityUpdate:NO]];
}

- (void)showWidgetIfSupported {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.rtkSatelliteStatusWidget.widgetModel.modelName isEqualToString:DJIAircraftModelNamePhantom4RTK] ||
             [self.rtkSatelliteStatusWidget.widgetModel.modelName isEqualToString:DJIAircraftModelNameMatrice210RTK] ||
             [self.rtkSatelliteStatusWidget.widgetModel.modelName isEqualToString:DJIAircraftModelNameMatrice210RTKV2] ) {
            [self.view setHidden:NO];
        }
    });
}

- (void)updateSatelliteStatusVisibility {
    BOOL shouldHideSatelliteStatus = !(self.rtkEnabledWidget.widgetModel.rtkEnabled && self.rtkEnabledWidget.widgetModel.isProductConnected);
    [self.rtkSatelliteStatusWidget.view setHidden:shouldHideSatelliteStatus];
    [self.rtkDisabledView setHidden:self.rtkEnabledWidget.widgetModel.rtkEnabled];
    self.scrollViewHeightConstraintLarge.active = !shouldHideSatelliteStatus;
    self.scrollViewHeightConstraintSmall.active = shouldHideSatelliteStatus;
    
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKWidgetModelState rtkEnabledUpdate:self.rtkEnabledWidget.widgetModel.rtkEnabled]];
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKWidgetModelState productConnected:self.rtkEnabledWidget.widgetModel.isProductConnected]];
}

#pragma mark - Customizations

- (void)customizeDisabledLabel {
    self.rtkDisabledLabel.textColor = self.rtkDescriptionTextColor;
    self.rtkDisabledLabel.font = self.rtkDescriptionFont;
    self.rtkDisabledLabel.backgroundColor = self.rtkDescriptionBackgroundColor;
}
                  
- (void)customizeOkButton {
    [self.okButton setTitleColor:self.okTextColor forState:UIControlStateNormal];
    self.okButton.titleLabel.font = self.okFont;
    self.okButton.backgroundColor = self.okBackgroundColor;
    [self.okButton setNeedsDisplay];
}

- (void)customizeBackground {
    self.view.backgroundColor = self.backgroundColor;
    self.buttonDividerView.backgroundColor = self.separatorColor;
    if (self.rtkSatelliteStatusWidget != nil) {
        self.rtkSatelliteStatusWidget.tableColor = self.separatorColor;
    }
}

#pragma mark - DUXBetaBaseWidget

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.view.bounds.size.width/self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height};
    return hint;
}

@end

@implementation RTKWidgetUIState : DUXBetaStateChangeBaseData

+ (instancetype)okTap {
    return [[RTKWidgetUIState alloc] initWithKey:@"okTap" number:@0];
}

@end

@implementation RTKWidgetModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[RTKWidgetModelState alloc] initWithKey:@"productConnected" number:[NSNumber numberWithBool:isConnected]];
}

+ (instancetype)rtkEnabledUpdate:(BOOL)isEnabled {
    return [[RTKWidgetModelState alloc] initWithKey:@"rtkEnabledUpdate" number:[NSNumber numberWithBool:isEnabled]];
}

+ (instancetype)visibilityUpdate:(BOOL)isVisible {
    return [[RTKWidgetModelState alloc] initWithKey:@"visibilityUpdate" number:[NSNumber numberWithBool:isVisible]];
}

@end
