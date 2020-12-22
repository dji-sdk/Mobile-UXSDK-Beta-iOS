//
//  DUXBetaRTKEnabledWidget.m
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

#import "DUXBetaRTKEnabledWidget.h"
#import "DUXBetaRTKEnabledWidgetModel.h"
#import <UXSDKCore/DUXBetaWarningMessage.h>
#import <UXSDKCore/DUXBetaStateChangeBaseData.h>
#import <UXSDKCore/DUXBetaStateChangeBroadcaster.h>
#import <UXSDKCore/UIColor+DUXBetaColors.h>
#import <UXSDKCore/UISwitch+DUXBetaBackgroundHelper.h>
#import <UXSDKCore/DUXBetaSingleton.h>
#import <UXSDKCore/UXSDKCore-Swift.h>

static NSString *kRTKEnabledDescription = @"When RTK module malfunctions, manually disable RTK and switch back to GPS mode.\n(If you enable RTK after takeoff, the GPS will continually be used.)";

static NSString *kWarningMessageReason = @"Failed to enable RTK";
static NSString *kWarningMessageSolution = @"Motors are running. Stop them and try again.";

static CGSize const kDesignSize = {500.0, 100.0};
static const CGFloat kMarginWidth = 15.0;
static const CGFloat kTitleInitialSize = 16.0;
static const CGFloat kDescriptionInitialSize = 11.0;

@interface DUXBetaRadiotButtonAdaptorView : UIView
@end

@implementation DUXBetaRadiotButtonAdaptorView
@end

@interface DUXBetaRTKEnabledWidget()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UISwitch *enableSwitch;

@end

/**
 * RTKEnabledUIState contains the hooks for UI changes in the widget class DUXBetaRTKEnabledWidget.
 * It implements the hook:
 *
 * Key: switchChanged    Type: NSNumber - Sends a boolean value as an NSNumber indicating the state of the switch
 *                                       when it changes.
*/
@interface RTKEnabledUIState : DUXBetaStateChangeBaseData

+ (instancetype)switchChanged:(BOOL)isEnabled;

@end

/**
 * RTKEnabledWidgetModelState contains the model hooks for the DUXBetaRTKEnabledWidget.
 * It implements the hooks:
 *
 * Key: productConnected  Type: NSNumber - Sends a boolean value as an NSNumber indicating the connected state of
 *                                        the device when it changes.
 *
 * Key: rtkEnabledUpdated Type: NSNumber - Sends a boolean value as an NSNumber indicating the rtk enabled status
 *                                        when it changes.
*/
@interface RTKEnabledModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;

+ (instancetype)rtkEnabledUpdated:(BOOL)isRTKEnabled;

@end

@implementation DUXBetaRTKEnabledWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInstanceVariables];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [self setupInstanceVariables];
    }
    return self;
}

- (void)setupInstanceVariables {
    _titleFont = [UIFont systemFontOfSize:kTitleInitialSize];
    _descriptionFont = [UIFont systemFontOfSize:kDescriptionInitialSize];
    _titleTextColor = [UIColor uxsdk_whiteColor];
    _descriptionTextColor = [UIColor lightGrayColor];
    _widgetBackgroundColor = [UIColor uxsdk_clearColor];
    _titleBackgroundColor = [UIColor clearColor];
    _descriptionBackgroundColor = [UIColor clearColor];
    _enableSwitchOnTintColor = [UIColor systemGreenColor];
    _enableSwitchOffTintColor = nil;
    _enableSwitchTrackColor = [UIColor colorWithWhite:1.0 alpha:0.3];  // Using system whiteColor instead of uxsdk_whiteColor to make sure we match iOS color.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    self.widgetModel = [[DUXBetaRTKEnabledWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), rtkEnabled, isProductConnected);
    BindRKVOModel(self, @selector(updateCustomizations), titleFont, titleTextColor, descriptionFont, descriptionTextColor, widgetBackgroundColor, titleBackgroundColor, descriptionBackgroundColor);
    BindRKVOModel(self, @selector(updateSwitchCustomizations), enableSwitchOnTintColor, enableSwitchOffTintColor, enableSwitchTrackColor);

    BindRKVOModel(self.widgetModel, @selector(sendIsProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(sendRTKEnabledUpdate), rtkEnabled);
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
    UIStackView *topRowStackView = [[UIStackView alloc] init];
    topRowStackView.translatesAutoresizingMaskIntoConstraints = NO;
    topRowStackView.axis = UILayoutConstraintAxisHorizontal;
    topRowStackView.distribution = UIStackViewDistributionEqualSpacing;
    topRowStackView.alignment = UIStackViewAlignmentCenter;
    topRowStackView.spacing = 30;
    
    [self.view addSubview:topRowStackView];
    [topRowStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kMarginWidth].active = YES;
    [topRowStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:(-1 * kMarginWidth)].active = YES;
    [topRowStackView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:kMarginWidth].active = YES;
    [topRowStackView.bottomAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:(-1 * kMarginWidth)].active = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = self.titleFont;
    self.titleLabel.textColor = self.titleTextColor;
    self.titleLabel.text = NSLocalizedString(@"RTK Positioning", @"Title Label");
    
    self.enableSwitch = [[UISwitch alloc] init];
    [self.enableSwitch setOn:self.widgetModel.rtkEnabled];
    self.enableSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.enableSwitch addTarget:self
                          action:@selector(onSwitchTapped)
                forControlEvents:UIControlEventTouchUpInside];

    UIView *theSwitchView = [self.enableSwitch setupOutlineViewForUISwitch];
    [topRowStackView addArrangedSubview:self.titleLabel];
    [topRowStackView addArrangedSubview:theSwitchView];
    
    [self.enableSwitch setupCustomSwitchColorsOnTint:_enableSwitchOnTintColor offTint:_enableSwitchOffTintColor trackColor:_enableSwitchTrackColor];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.numberOfLines = 2;
    self.descriptionLabel.font = self.descriptionFont;
    self.descriptionLabel.textColor = self.descriptionTextColor;
    self.descriptionLabel.text = NSLocalizedString(kRTKEnabledDescription, @"Title Label");
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.view addSubview:self.descriptionLabel];
    
    [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kMarginWidth].active = YES;
    [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:(-1 * kMarginWidth)].active = YES;
    [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:kMarginWidth].active = YES;
    [self.descriptionLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
     
    self.view.backgroundColor = self.widgetBackgroundColor;
}

- (void)sendIsProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKEnabledModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendRTKEnabledUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKEnabledModelState rtkEnabledUpdated:self.widgetModel.rtkEnabled]];
}

- (void)sendSwitchChanged {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKEnabledUIState switchChanged:self.enableSwitch.on]];
}

- (void)onSwitchTapped {
    if (self.enableSwitch.isOn) {
        if (self.widgetModel.canEnableRTK) {
            [self.widgetModel sendRtkEnabled:YES];
        } else {
            [self.enableSwitch setOn:NO];
            if (self.widgetModel.areMotorsOn) {
                [self sendMotorsOnWarningMessage];
            }
        }
    } else {
        [self.widgetModel sendRtkEnabled:NO];
    }
}

- (void)updateCustomizations {
    self.titleLabel.textColor = self.titleTextColor;
    self.titleLabel.backgroundColor = self.titleBackgroundColor;
    self.titleLabel.font = self.titleFont;
    self.descriptionLabel.textColor = self.descriptionTextColor;
    self.descriptionLabel.backgroundColor = self.descriptionBackgroundColor;
    self.descriptionLabel.font = self.descriptionFont;
    self.view.backgroundColor = self.widgetBackgroundColor;
}

- (void)updateSwitchCustomizations {
    [self.enableSwitch setupCustomSwitchColorsOnTint:_enableSwitchOnTintColor offTint:_enableSwitchOffTintColor trackColor:_enableSwitchTrackColor];
}

- (void)updateUI {
    [self.enableSwitch setOn:self.widgetModel.rtkEnabled && self.widgetModel.isProductConnected];
    [self sendSwitchChanged];
}

- (void)sendMotorsOnWarningMessage {
    DUXBetaWarningMessageKey *warningMessageKey = [[DUXBetaWarningMessageKey alloc] initWithIndex:0
                                                                                parameter:DUXBetaWarningMessageParameterSendWarningMessage];
    
    DUXBetaWarningMessage *warningMessage = [[DUXBetaWarningMessage alloc] init];
    warningMessage.reason = kWarningMessageReason;
    warningMessage.solution = kWarningMessageSolution;
    warningMessage.level = DUXBetaWarningMessageLevelNotify;
    warningMessage.type = DUXBetaWarningMessageTypePinned;
    
    ModelValue *modelWithWarningMessage = [[ModelValue alloc] initWithValue:[warningMessage copy]];
    
    [[DUXBetaSingleton sharedObservableInMemoryKeyedStore] setModelValue:modelWithWarningMessage
                                                              forKey:warningMessageKey];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end

@implementation RTKEnabledUIState

+ (instancetype)switchChanged:(BOOL)isEnabled {
    return [[RTKEnabledUIState alloc] initWithKey:@"switchChanged" number:[NSNumber numberWithBool:isEnabled]];
}

@end

@implementation RTKEnabledModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[RTKEnabledModelState alloc] initWithKey:@"productConnected" number:[NSNumber numberWithBool:isConnected]];
}

+ (instancetype)rtkEnabledUpdated:(BOOL)isRTKEnabled {
    return [[RTKEnabledModelState alloc] initWithKey:@"rtkEnabledUpdated" number:[NSNumber numberWithBool:isRTKEnabled]];
}

@end
