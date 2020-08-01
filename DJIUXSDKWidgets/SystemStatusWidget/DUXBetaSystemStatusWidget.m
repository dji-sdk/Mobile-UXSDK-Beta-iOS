//
//  DUXBetaSystemStatusStatusWidget.m
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
#import "DUXBetaSystemStatusWidget.h"
#import "DUXMarqueeLabel.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
@import DJIUXSDKCore;
#import "DUXBetaStateChangeBroadcaster.h"

static const CGSize kDesignSize = {297.0, 32.0};
static const CGFloat kDesignFontSize = 27.0;
static NSString * const kInitialText = @"Disconnected";

/**
 * DUXBetaSystemStatusWidgetModelState contains the model hooks for the DUXBetaSystemStatusWidget.
 * It implements the hooks:
 *
 * Key: productConnected    Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft is connected.
 *
 * Key: systemStatusUpdated Type: NSString - The current system status message is sent whenever it changes.
*/
@interface DUXBetaSystemStatusWidgetModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)systemStatusUpdated:(NSString *)systemStatusMessage;

@end

/**
 * DUXBetaStatusWidgetUIState contains the hooks for UI changes in the widget class DUXBetaSystemStatusWidget.
 * It implements the hook:
 *
 * Key: onWidgetTap    Type: NSNumber - Sends a boolean YES value as an NSNumber indicating the widget was tapped.
*/
@interface DUXBetaSystemStatusWidgetUIState : DUXBetaStateChangeBaseData

+ (instancetype)onWidgetTap;

@end

@interface DUXBetaSystemStatusWidget ()

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIColor *> *backgroundColorForWarningLevel;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIColor *> *textColorForWarningLevel;
@property (nonatomic, strong) DUXMarqueeLabel *horizontalScrollingLabel;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation DUXBetaSystemStatusWidget

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
    _messageFont = [UIFont duxbeta_dinMediumFontWithSize:kDesignFontSize];
    _isGradientEnabled = NO;
    _backgroundColorForWarningLevel = [@{
        @(DJIWarningStatusLevelOffline)    : [UIColor clearColor],
        @(DJIWarningStatusLevelNone)       : [UIColor clearColor],
        @(DJIWarningStatusLevelGood)       : [UIColor clearColor],
        @(DJIWarningStatusLevelWarning)    : [UIColor clearColor],
        @(DJIWarningStatusLevelError)      : [UIColor clearColor],
    } mutableCopy];
            
    _textColorForWarningLevel = [@{
        @(DJIWarningStatusLevelOffline)    : [UIColor duxbeta_disabledGrayColor],
        @(DJIWarningStatusLevelNone)       : [UIColor duxbeta_systemStatusWidgetGreenColor],
        @(DJIWarningStatusLevelGood)       : [UIColor duxbeta_systemStatusWidgetGreenColor],
        @(DJIWarningStatusLevelWarning)    : [UIColor duxbeta_yellowColor],
        @(DJIWarningStatusLevelError)      : [UIColor duxbeta_systemStatusWidgetRedColor],
    } mutableCopy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaSystemStatusWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(handleSuggestedMessageUpdate), suggestedWarningMessage);
    BindRKVOModel(self.widgetModel, @selector(updateUI), systemStatusWarningLevel);
    BindRKVOModel(self.widgetModel, @selector(updateIsCriticalWarning), isCriticalWarning);
    BindRKVOModel(self, @selector(updateLabelFont), messageFont);
    BindRKVOModel(self, @selector(setGradientBackground), isGradientEnabled, view.bounds);
        
    // Bind hooks to model updates
    BindRKVOModel(self.widgetModel, @selector(sendProductConnected), isProductConnected);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setGradientBackground {
    if (self.isGradientEnabled) {
        // Set gradient backgrounds
        UIColor *gradientSafeColorPattern = [self gradientPatternWithBounds:self.view.bounds
                                                                     colors:@[(__bridge id)[UIColor duxbeta_systemStatusWidgetGreenColor].CGColor,
                                                                              (__bridge id)[UIColor duxbeta_clearColor].CGColor]];
        UIColor *gradientWarningColorPattern = [self gradientPatternWithBounds:self.view.bounds
                                                                        colors:@[(__bridge id)[UIColor duxbeta_yellowColor].CGColor,
                                                                                 (__bridge id)[UIColor duxbeta_clearColor].CGColor]];
        UIColor *gradientErrorColorPattern = [self gradientPatternWithBounds:self.view.bounds
                                                                      colors:@[(__bridge id)[UIColor duxbeta_systemStatusWidgetRedColor].CGColor,
                                                                               (__bridge id)[UIColor duxbeta_clearColor].CGColor]];
        UIColor *gradientDisabledColorPattern = [self gradientPatternWithBounds:self.view.bounds
                                                                         colors:@[(__bridge id)[UIColor duxbeta_disabledGrayColor].CGColor,
                                                                                  (__bridge id)[UIColor duxbeta_clearColor].CGColor]];

        [self setBackgroundColor:gradientSafeColorPattern forSystemStatusWarningLevel:DJIWarningStatusLevelGood];
        [self setBackgroundColor:gradientDisabledColorPattern forSystemStatusWarningLevel:DJIWarningStatusLevelOffline];
        [self setBackgroundColor:gradientDisabledColorPattern forSystemStatusWarningLevel:DJIWarningStatusLevelNone];
        [self setBackgroundColor:gradientWarningColorPattern forSystemStatusWarningLevel:DJIWarningStatusLevelWarning];
        [self setBackgroundColor:gradientErrorColorPattern forSystemStatusWarningLevel:DJIWarningStatusLevelError];
        
        // Set text color to white for all warning levels
        self.textColorForWarningLevel = [@{
            @(DJIWarningStatusLevelOffline)    : [UIColor duxbeta_whiteColor],
            @(DJIWarningStatusLevelNone)       : [UIColor duxbeta_whiteColor],
            @(DJIWarningStatusLevelGood)       : [UIColor duxbeta_whiteColor],
            @(DJIWarningStatusLevelWarning)    : [UIColor duxbeta_whiteColor],
            @(DJIWarningStatusLevelError)      : [UIColor duxbeta_whiteColor],
        } mutableCopy];
    }
}

- (UIColor *)gradientPatternWithBounds:(CGRect)bounds colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = bounds;
    gradientLayer.colors = colors;
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    
    UIGraphicsBeginImageContext(gradientLayer.bounds.size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIColor alloc] initWithPatternImage:image];
}

- (void)setupUI {
    self.backgroundView = [[UIImageView alloc] init];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backgroundView];

    [self.backgroundView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.backgroundView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.backgroundView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.backgroundView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;

    self.horizontalScrollingLabel = [[DUXMarqueeLabel alloc] initWithFrame:CGRectZero duration:12 andFadeLength:5];
    self.horizontalScrollingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.horizontalScrollingLabel.marqueeType = MLContinuous;
    self.horizontalScrollingLabel.trailingBuffer = 20.0;
    self.horizontalScrollingLabel.animationDelay = 0.0;
    self.horizontalScrollingLabel.textColor = self.textColorForWarningLevel[@(DJIWarningStatusLevelOffline)];
    self.horizontalScrollingLabel.font = self.messageFont;
    self.horizontalScrollingLabel.text = kInitialText;
    self.view.backgroundColor = self.backgroundColorForWarningLevel[@(DJIWarningStatusLevelOffline)];

    [self.view addSubview:self.horizontalScrollingLabel];

    [self.view.heightAnchor constraintEqualToConstant:self.widgetSizeHint.minimumHeight].active = YES;
    [self.horizontalScrollingLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.horizontalScrollingLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.horizontalScrollingLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                             multiplier:0.975].active = YES;
    [self.horizontalScrollingLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor
                                                             multiplier:0.8].active = YES;

    [self updateUI];
    [self handleSuggestedMessageUpdate];
    [self updateIsCriticalWarning];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

/*********************************************************************************/
#pragma mark - Widget Model Callbacks
/*********************************************************************************/
- (void)handleSuggestedMessageUpdate {
    self.horizontalScrollingLabel.text = self.widgetModel.suggestedWarningMessage;
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaSystemStatusWidgetModelState systemStatusUpdated:self.widgetModel.suggestedWarningMessage]];
}

- (void)updateIsCriticalWarning {
    if (self.widgetModel.isCriticalWarning) {
        if (![self.backgroundView.layer animationForKey:@"view_blink"]) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.toValue = @(0.0f);
            animation.fromValue = @(1.0f);
            animation.duration = 0.5;
            animation.fillMode = kCAFillModeForwards;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            animation.autoreverses = YES;
            animation.repeatCount = HUGE_VAL;
            [self.backgroundView.layer addAnimation:animation forKey:@"view_blink"];
        }
    }
}

- (void)updateUI {
    self.horizontalScrollingLabel.textColor = self.textColorForWarningLevel[@(self.widgetModel.systemStatusWarningLevel)];
    self.backgroundView.backgroundColor = self.backgroundColorForWarningLevel[@(self.widgetModel.systemStatusWarningLevel)];
    CGFloat pointSize = self.messageFont.pointSize * (self.horizontalScrollingLabel.frame.size.height / self.widgetSizeHint.minimumHeight);
    self.horizontalScrollingLabel.font = [self.messageFont fontWithSize:pointSize];
}

/*********************************************************************************/
#pragma mark - UI
/*********************************************************************************/
- (void)viewDidLayoutSubviews {
    [self updateUI];
}

/*********************************************************************************/
#pragma mark - Customization
/*********************************************************************************/

- (void)setBackgroundColor:(UIColor *)color forSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel {
    self.backgroundColorForWarningLevel[@(systemStatusWarningLevel)] = color;
    [self updateUI];
}

- (UIColor *)backgroundColorForSystemStatusWarningLevel:(DJIWarningStatusLevel)SystemStatusWarningLevel {
    return self.backgroundColorForWarningLevel[@(SystemStatusWarningLevel)];
}

- (void)setTextColor:(UIColor *)color forSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel {
    self.textColorForWarningLevel[@(systemStatusWarningLevel)] = color;
    [self updateUI];
}

- (UIColor *)textColorForSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel {
    return self.textColorForWarningLevel[@(systemStatusWarningLevel)];
}

- (void)updateLabelFont {
    self.horizontalScrollingLabel.font = self.messageFont;
    [self updateUI];
}

- (void)sendProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaSystemStatusWidgetModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)handleTap {
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaSystemStatusWidgetUIState onWidgetTap]];
}

@end

@implementation DUXBetaSystemStatusWidgetModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[DUXBetaSystemStatusWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)systemStatusUpdated:(NSString *)systemStatusMessage {
    return [[DUXBetaSystemStatusWidgetModelState alloc] initWithKey:@"systemStatusMessage" string:systemStatusMessage];
}

@end

@implementation DUXBetaSystemStatusWidgetUIState

+ (instancetype)onWidgetTap {
    return [[DUXBetaSystemStatusWidgetUIState alloc] initWithKey:@"onWidgetTap" number:@(0)];
}

@end
