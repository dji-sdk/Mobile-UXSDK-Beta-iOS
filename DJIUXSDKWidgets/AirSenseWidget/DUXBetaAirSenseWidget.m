//
//  DUXBetaAirSenseWidget.m
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

#import "DUXBetaAirSenseWidget.h"
#import "DUXBetaAirSenseWidgetModel.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
#import "DUXBetaAirSenseHtmlViewController.h"
#import "DUXBetaAirSenseDialogViewController.h"
#import "DUXBetaStateChangeBroadcaster.h"
#import "NSLayoutConstraint+DUXBetaMultiplier.h"

@import DJIUXSDKCore;

static NSString * const DUXBetaAirSenseWidgetDialogTitle = @"Another aircraft is nearby. Fly with caution.";
static NSString * const DUXBetaAirSenseWidgetDialogMessage = @"Please make sure you have read and understood the DJI AirSense Warnings.";

@interface DUXBetaAirSenseWidget ()

@property (nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *airSenseColorMapping;
@property (nonatomic) BOOL hasViewAppeared;
@property (nonatomic, strong) UIImageView *airSenseImageView;
@property (nonatomic, strong) DUXBetaAirSenseDialogViewController *dialogViewController;
@property (nonatomic, strong) NSLayoutConstraint *widgetAspectRatioConstraint;
@property (nonatomic) CGSize minWidgetSize;

@end

/**
 * AirSenseWidgetModelState contains the hooks for model changes in the AirSenseWidgetModel.
 * It implements the hooks:
 *
 * Key: productConnected    Type: NSNumber - Sends a boolean value as an NSNumber indicating the connected state of
 *                                           the device when it changes
 *
 * Key: airSenseConnected   Type: NSNumber - Sends a boolean value as an NSNumber indication if AirSense is connected and active
 *
 * Key: airSenseWarningLevelUpdate  Type: NSNumber - Sends an NSNumber containing the updated warning level when AirSense updates
 *
 * Key: airSnseWarningStateUpdate   Type: NSNumber - Sends an NSNumber containing the AirSense warning state as an integer
*/
@interface AirSenseWidgetModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)airSenseConnected:(BOOL)isAirSenseConnected;
+ (instancetype)airSenseWarningLevelUpdate:(NSNumber *)warningLevel;
+ (instancetype)airSenseWarningStateUpdate:(NSNumber *)warningState;

@end

@implementation DUXBetaAirSenseWidget

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
    _airSenseImage =  [UIImage duxbeta_imageWithAssetNamed:@"AirSenseIcon"];
    _disconnectedImage = [UIImage duxbeta_imageWithAssetNamed:@"AirSenseDisconnected"];
    _iconBackgroundColor = [UIColor clearColor];
    _checkedCheckboxImage = [UIImage duxbeta_imageWithAssetNamed:@"CheckedCheckbox"];
    _uncheckedCheckboxImage = [UIImage duxbeta_imageWithAssetNamed:@"EmptyCheckbox"];
    _checkboxLabelTextColor = [UIColor duxbeta_blackColor];
    _checkboxLabelTextFont = [UIFont systemFontOfSize:18];
    _dialogMessageTextColor = [UIColor duxbeta_linkBlueColor];
    _dialogMessageTextFont = [UIFont systemFontOfSize:18];
    _dialogTitle = DUXBetaAirSenseWidgetDialogTitle;
    _dialogMessage = DUXBetaAirSenseWidgetDialogMessage;
    _dialogBackgroundColor = [UIColor duxbeta_whiteColor];
    _dialogTitleTextColor = [UIColor duxbeta_blackColor];
    _hasViewAppeared = NO;
    
    _airSenseColorMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaAirSenseState_Disconnected) : [UIColor duxbeta_disabledGrayColor],
        @(DUXBetaAirSenseState_NoAirplanesNearby) : [UIColor duxbeta_disabledGrayColor],
        @(DUXBetaAirSenseState_Level0) : [UIColor duxbeta_whiteColor],
        @(DUXBetaAirSenseState_Level1) : [UIColor duxbeta_selectedColor],
        @(DUXBetaAirSenseState_Level2) : [UIColor duxbeta_airSenseYellowColor],
        @(DUXBetaAirSenseState_Level3) : [UIColor duxbeta_dangerColor],
        @(DUXBetaAirSenseState_Level4) : [UIColor duxbeta_dangerColor],
        @(DUXBetaAirSenseState_Unknown) : [UIColor duxbeta_disabledGrayColor]
    }];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"optOutAirSense"] != nil) {
        _hasOptedOutDialog = [[defaults objectForKey:@"optOutAirSense"] boolValue];
    } else {
        _hasOptedOutDialog = NO;
    }
    
    [self updateMinImageDimensions];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaAirSenseWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(sendIsProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(sendIsAirSenseConnected), isAirSenseConnected);
    BindRKVOModel(self.widgetModel, @selector(sendAirSenseWarningLevelUpdate), airSenseWarningLevel);
    BindRKVOModel(self.widgetModel, @selector(sendAirSenseWarningStateUpdate), airSenseWarningState);

    BindRKVOModel(self.widgetModel, @selector(updateUI), airSenseWarningState, airSenseWarningLevel, isAirSenseConnected, isProductConnected);
    BindRKVOModel(self, @selector(updateUI),
        iconBackgroundColor,
        checkedCheckboxImage,
        uncheckedCheckboxImage,
        checkboxLabelTextColor,
        checkboxLabelTextFont,
        dialogMessageTextColor,
        dialogMessageTextFont,
        dialogMessage,
        dialogTitle
    );
    BindRKVOModel(self, @selector(updateMinImageDimensions), airSenseImage, disconnectedImage);
    BindRKVOModel(self.widgetModel, @selector(presentDialogIfAppropriate), airSenseWarningState);
    
    self.hasViewAppeared = YES;
    [self updateUI]; 
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
    UIImage *image = self.airSenseImage;
    self.airSenseImageView = [[UIImageView alloc] initWithImage:image];
    self.airSenseImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.airSenseImageView];
    
    CGFloat imageAspectRatio = image.size.width / image.size.height;
    
    self.widgetAspectRatioConstraint = [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageAspectRatio];
    self.widgetAspectRatioConstraint.active = YES;

    [self.airSenseImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.airSenseImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.airSenseImageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.airSenseImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    self.airSenseImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self updateUI];
}

- (void)updateUI {
    self.view.backgroundColor = self.iconBackgroundColor;

    // Check if product has an AirSense receiver
    if (self.widgetModel.isAirSenseConnected || !self.widgetModel.isProductConnected) {
        [self.view setHidden:NO];
    } else {
        [self.view setHidden:YES];
        return;
    }
    
    // Set widget icon
    if (self.widgetModel.airSenseWarningState == DUXBetaAirSenseState_Disconnected) {
        self.airSenseImageView.image = [self.disconnectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        self.airSenseImageView.image = [self.airSenseImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    // Set icon tinting
    [self.airSenseImageView setTintColor:self.airSenseColorMapping[@(self.widgetModel.airSenseWarningState)]];
    
    if (self.widgetModel.airSenseWarningState == DUXBetaAirSenseState_Level4) {
        if (![self.view.layer animationForKey:@"view_blink"]) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.toValue = @(0.4f);
            animation.fromValue = @(1.0f);
            animation.byValue = @(0.06);
            animation.duration = 0.3;
            animation.fillMode = kCAFillModeForwards;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            animation.autoreverses = YES;
            animation.repeatCount = HUGE_VAL;
            [self.view.layer addAnimation:animation forKey:@"view_blink"];
        }
    } else {
        [self.view.layer removeAnimationForKey:@"view_blink"];
    }
}

- (void)presentDialogIfAppropriate {
    BOOL isPresentingDialog = [self presentedViewController] != nil;

    if (isPresentingDialog) {
        [self setDialogCustomizations];
    } else {
        if (self.widgetModel.airSenseWarningLevel >= 1 &&
            !self.hasOptedOutDialog &&
            self.hasViewAppeared &&
            self.widgetModel.isProductConnected) {
            [self presentAlertDialog];
        }
    }
}

- (void)setDialogCustomizations {
    self.dialogViewController.checkboxLabelTextColor = self.checkboxLabelTextColor;
    self.dialogViewController.checkboxLabelTextFont = self.checkboxLabelTextFont;
    self.dialogViewController.checkedCheckboxImage = self.checkedCheckboxImage;
    self.dialogViewController.uncheckedCheckboxImage = self.uncheckedCheckboxImage;
    self.dialogViewController.warningMessageTextColor = self.dialogMessageTextColor;
    self.dialogViewController.warningMessageTextFont = self.dialogMessageTextFont;
    self.dialogViewController.dialogTitle = self.dialogTitle;
    self.dialogViewController.dialogMessage = self.dialogMessage;
    self.dialogViewController.view.backgroundColor = self.dialogBackgroundColor;
    self.dialogViewController.dialogTitleTextColor = self.dialogTitleTextColor;
}

- (void)presentAlertDialog {
    self.dialogViewController = [[DUXBetaAirSenseDialogViewController alloc] initWithTitle:self.dialogTitle
                                                                            andMessage:self.dialogMessage];
    [self setDialogCustomizations];
    self.dialogViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.dialogViewController.presentingWidget = self;
    [self presentViewController:self.dialogViewController animated:YES completion:nil];
}

- (void)setTintColor:(UIColor *)color forWarningState:(DUXBetaAirSenseState)state {
    self.airSenseColorMapping[@(state)] = color;
    [self updateUI];
}

- (UIColor *)getTintColorForWarningState:(DUXBetaAirSenseState)state {
    return self.airSenseColorMapping[@(state)];
}

- (void)sendIsProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[AirSenseWidgetModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendIsAirSenseConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[AirSenseWidgetModelState airSenseConnected:self.widgetModel.isAirSenseConnected]];
}

- (void)sendAirSenseWarningLevelUpdate {
    NSNumber *numberToSend = [[NSNumber alloc] initWithUnsignedInteger:self.widgetModel.airSenseWarningLevel];
    [[DUXBetaStateChangeBroadcaster instance] send:[AirSenseWidgetModelState airSenseWarningLevelUpdate:numberToSend]];
}

- (void)sendAirSenseWarningStateUpdate {
    NSNumber *numberToSend = [[NSNumber alloc] initWithUnsignedInteger:self.widgetModel.airSenseWarningState];
    [[DUXBetaStateChangeBroadcaster instance] send:[AirSenseWidgetModelState airSenseWarningStateUpdate:numberToSend]];
}

- (void)updateMinImageDimensions {
    NSArray *iconImages = [[NSArray alloc] initWithObjects:self.airSenseImage, self.disconnectedImage, nil];
    
    _minWidgetSize = [self maxSizeInImageArray:iconImages];
    self.widgetAspectRatioConstraint = [self.widgetAspectRatioConstraint duxbeta_updateMultiplier:self.widgetSizeHint.preferredAspectRatio];
    [self updateUI];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return hint;
}

@end

@implementation AirSenseWidgetModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[AirSenseWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)airSenseConnected:(BOOL)isAirSenseConnected {
    return [[AirSenseWidgetModelState alloc] initWithKey:@"airSenseConnected" number:@(isAirSenseConnected)];
}

+ (instancetype)airSenseWarningLevelUpdate:(NSNumber *)warningLevel {
    return [[AirSenseWidgetModelState alloc] initWithKey:@"airSenseWarningLevel" number:warningLevel];
}

+ (instancetype)airSenseWarningStateUpdate:(NSNumber *)warningState {
    return [[AirSenseWidgetModelState alloc] initWithKey:@"airSenseWarningState" value:warningState];
}

@end
