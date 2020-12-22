//
//  DUXBetaListItemTitleWidget.m
//  UXSDKCore
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

#import "DUXBetaListItemTitleWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIColor+DUXBetaColors.h"

/// Default list item minimum width
static const CGFloat listWidgetDefaultMinSizeWidth = 320.0;
/// Default list item minimum height
static const CGFloat listWidgetDefaultMinSizeHeight = 54.0;

/**
 * Internal properties used by DUXBetaListItemTitleWidget
 */
@interface DUXBetaListItemTitleWidget ()

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation DUXBetaListItemTitleWidget

- (instancetype)init {
    self = [super init];
    self.minWidgetSize = CGSizeMake(listWidgetDefaultMinSizeWidth, listWidgetDefaultMinSizeHeight);
    [self setupCustomizableSettings];
    return self;
}

- (instancetype)initWithTitle:(NSString*)title andIconName:(NSString* _Nullable)iconName {
    if (self = [super init]) {
        _titleString = title;
        _iconName = iconName;
        [self setupCustomizableSettings];
        
        self.minWidgetSize = CGSizeMake(listWidgetDefaultMinSizeWidth, listWidgetDefaultMinSizeHeight);
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.minWidgetSize = CGSizeMake(listWidgetDefaultMinSizeWidth, listWidgetDefaultMinSizeHeight);
        [self setupCustomizableSettings];
    }
    return self;
}

- (instancetype)setTitle:(NSString*)titleString andIconName:(NSString* _Nullable)iconName {
    // This tears down the old model if it exists and builds a fresh one
    _titleString = titleString;
    if (iconName) {
        _iconImage = [[UIImage duxbeta_imageWithAssetNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    // Subclasses will need to implement this. This widget doesn't need a model, it is just the label
//    self.widgetModel = [[DUXBetaGenericOptionSwitchWidgetModel alloc] initWithKey:self.widgetModelKey];
    [self setupUI];
    return self;
}

- (void)setupCustomizableSettings {
    _titleColor = [UIColor uxsdk_whiteColor];
    _backgroundColor = [UIColor uxsdk_clearColor];
    _titleFont = [UIFont systemFontOfSize:17.0];
    _iconTintColor = [UIColor uxsdk_whiteColor];
    if (_iconName) {
        _iconImage = [[UIImage duxbeta_imageWithAssetNamed:_iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    _disconnectedValueColor = UIColor.uxsdk_disabledGrayWhite58;
    _normalValueColor = UIColor.uxsdk_whiteColor;
    _warningValueColor = UIColor.uxsdk_warningColor;
    _errorValueColor = UIColor.uxsdk_errorDangerColor;
    
    _buttonFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    _buttonBorderWidth = 1.0f;
    _buttonCornerRadius = 3.0f;
    _buttonColors = [@{
        @(UIControlStateNormal) : [self normalColor],
        @(UIControlStateDisabled) : [self disabledColor],
        @(UIControlStateSelected) : [self normalColor],
        @(UIControlStateHighlighted) : [self normalColor]
    } mutableCopy];
    
    _buttonBackgroundColors = [NSMutableDictionary new];

    _buttonBorderColors = [@{
        @(UIControlStateNormal) : [self buttonBorderNormalColor],
        @(UIControlStateDisabled) : [self buttonBorderDisabledColor],
        @(UIControlStateSelected) : [self buttonBorderNormalColor],
        @(UIControlStateHighlighted) : [self buttonBorderNormalColor]
    } mutableCopy];

}

// Generally override this method and add your model creation.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.minWidgetSize = self.view.bounds.size;
    BindRKVOModel(self, @selector(updateUI), titleColor, iconTintColor, backgroundColor, iconImage, titleFont,
                                            disconnectedValueColor, normalValueColor, warningValueColor, errorValueColor);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

// This setupUI does not set a hard width. That should probably be imposed externally.
- (void)setupUI {
    if (self.titleLabel != nil) {
        return;
    }
    
    _trailingMarginGuide = [UILayoutGuide new];
    [self.view addLayoutGuide:_trailingMarginGuide];
    [_trailingMarginGuide.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10.0].active = YES;
    [_trailingMarginGuide.widthAnchor constraintEqualToConstant:0.0].active = YES;
    [_trailingMarginGuide.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [_trailingMarginGuide.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    self.iconView = nil;
    if (self.iconImage) {
        self.iconView = [[UIImageView alloc] initWithImage:self.iconImage];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.tintColor = self.iconTintColor;
        [self.view addSubview:self.iconView];
        [self.iconView.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor multiplier:0.95].active = YES;
        [self.iconView.heightAnchor constraintLessThanOrEqualToConstant:30.0].active = YES;
        [self.iconView.widthAnchor constraintEqualToAnchor:self.iconView.heightAnchor].active = YES;
        [self.iconView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0].active = YES;
    } else {
        self.iconView = [[UIImageView alloc] init];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.iconView];
        [self.iconView.widthAnchor constraintEqualToConstant:0.0].active = YES;
        [self.iconView.heightAnchor constraintEqualToConstant:2.0].active = YES;
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [self.iconView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    }

    self.view.backgroundColor = [self backgroundColor];   // Put whatever we need behind this widget for a background.
    
    self.trailingTitleGuide = [UILayoutGuide new];
    [self.view addLayoutGuide:self.trailingTitleGuide];
    self.trailingMarginConstraint = [self.trailingTitleGuide.trailingAnchor constraintEqualToAnchor:self.view.centerXAnchor];
    self.trailingMarginConstraint.active = YES;
    [self.trailingTitleGuide.widthAnchor constraintEqualToConstant:0.0].active = YES;
    [self.trailingTitleGuide.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.trailingTitleGuide.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = self.titleString;
    self.titleLabel.font = self.titleFont;
    self.titleLabel.allowsDefaultTighteningForTruncation = YES;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.75;
    [self.titleLabel sizeToFit];
    
    // Customize colors here
    self.titleLabel.textColor = [self normalColor];
    [self.view addSubview:self.titleLabel];
    
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconView.trailingAnchor constant:8.0].active = YES;
    [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor constant:-12.0].active = YES;
    [self.titleLabel.widthAnchor constraintEqualToConstant:self.titleLabel.frame.size.width].active = YES;
}

- (void)updateUI {
    self.titleLabel.textColor = self.titleColor;
    self.view.backgroundColor = self.backgroundColor;
    self.titleLabel.font = self.titleFont;
    self.iconView.tintColor = self.iconTintColor;
    self.iconView.image = self.iconImage;
}

- (void)setButtonColor:(UIColor *)buttonColor forUIControlState:(UIControlState)controlState {
    [self.buttonColors setObject:buttonColor forKey:@(controlState)];
}

- (UIColor*)getButtonColorForUIControlState:(UIControlState)controlState {
    return [self.buttonColors objectForKey:@(controlState)];
}

- (void)setButtonBorderColor:(UIColor *)buttonColor forUIControlState:(UIControlState)controlState {
    [self.buttonBorderColors setObject:buttonColor forKey:@(controlState)];
}

- (UIColor *)getButtonBorderColorForUIControlState:(UIControlState)controlState {
    return [self.buttonBorderColors objectForKey:@(controlState)];
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor forUIControlState:(UIControlState)controlState {
    [self.buttonBackgroundColors setObject:buttonBackgroundColor forKey:@(controlState)];
}

- (UIColor *)getButtonBackgroundColorForUIControlState:(UIControlState)controlState {
    return [self.buttonBackgroundColors objectForKey:@(controlState)];
}

- (UIColor*)normalColor {
    return _normalValueColor;
}

- (UIColor*)disabledColor {
    return _disconnectedValueColor;
}

- (UIColor*)warningColor {
    return _warningValueColor;
}

- (UIColor*)errorColor {
    return _errorValueColor;
}

- (UIColor*)buttonBorderNormalColor {
    return [UIColor uxsdk_whiteColor];
}

- (UIColor*)buttonBorderDisabledColor {
    return [UIColor uxsdk_disabledGrayWhite58];
}

- (UIColor*)buttonBorderSelectedColor {
    return [UIColor uxsdk_whiteColor];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {listWidgetDefaultMinSizeWidth/listWidgetDefaultMinSizeHeight, listWidgetDefaultMinSizeWidth, listWidgetDefaultMinSizeHeight};
    return hint;
}

- (BOOL)forceAspectRatio {
    return NO;
}

@end

@implementation ListItemTitleUIState

+ (instancetype)dialogDisplayed:(id)dialogIdentifier  {
    return [[self alloc] initWithKey:@"dialogDisplayed" object:dialogIdentifier];
}

+ (instancetype)dialogActionConfirmed:(id)dialogIdentifier  {
    return [[self alloc] initWithKey:@"dialogActionConfirmed" object:dialogIdentifier];
}

+ (instancetype)dialogActionCanceled:(id)dialogIdentifier  {
    return [[self alloc] initWithKey:@"dialogActionCanceled" object:dialogIdentifier];
}

+ (instancetype)dialogDismissed:(id)dialogIdentifier  {
    return [[self alloc] initWithKey:@"dialogDismissed" object:dialogIdentifier];
} 
@end

@implementation ListItemTitleModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[self alloc] initWithKey:@"productConnectedUpdate" number:@(isConnected)];
}

@end
