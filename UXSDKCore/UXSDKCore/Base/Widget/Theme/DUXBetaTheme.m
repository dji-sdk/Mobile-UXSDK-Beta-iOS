//
//  DUXBetaTheme.m
//  UXSDKCore
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

#import "DUXBetaTheme.h"
#import "UIColor+DUXBetaColors.h"

/*
 The container classes here are near duplicates of the containers in the header
 file. The difference is to unmask the properties for modification by the owner.
 This involves changing of readonly to readwrite. The property is the same memory,
 but the DUXBetaTheme class now has modification access to the properties, while
 clients don't have modification access.
 
 This allows us to hand back these container classes but they can't be directly
 modifed by the client code.
 */
#pragma mark - Container Classes Unmasks
@interface DUXBetaThemeFonts ()
@property (nonatomic, strong, readwrite) UIFont  *standardFont;
@property (nonatomic, strong, readwrite) UIFont  *smallFont;
@property (nonatomic, strong, readwrite) UIFont  *titleFont;
@property (nonatomic, strong, readwrite) UIColor *fontColor;
@property (nonatomic, strong, readwrite) UIColor *disabledColor;
@end

@interface DUXBetaThemeColors ()
@property (nonatomic, strong, readwrite) UIColor *normalColor;
@property (nonatomic, strong, readwrite) UIColor *disconnectedColor;
@property (nonatomic, strong, readwrite) UIColor *backgroundColor;
@property (nonatomic, strong, readwrite) UIColor *widgetBackgroundColor;
@property (nonatomic, strong, readwrite) UIColor *goodColor;
@property (nonatomic, strong, readwrite) UIColor *warningColor;
@property (nonatomic, strong, readwrite) UIColor *errorDangerColor;
@end

@interface DUXBetaThemeControls ()
@property (nonatomic, strong, readwrite) UIFont  *controlFont;
@property (nonatomic, strong, readwrite) UIColor *enabldLayerBorderColor;
@property (nonatomic, strong, readwrite) UIColor *disabledLayerBorderColor;
@property (nonatomic, strong, readwrite) UIColor *contorlBackbgroundColor;
@property (nonatomic, strong, readwrite) UIColor *controlTintColor;  // May be nil
@end

@interface DUXBetaThemePanels ()
@property (nonatomic, strong, readwrite) UIColor *panelBackgroundColor;
@property (nonatomic, strong, readwrite) UIColor *panelTitleColor;
@property (nonatomic, strong, readwrite) UIColor *toolbarSelectionColor;
@property (nonatomic, readwrite) UITableViewCellSelectionStyle   tableSelectionColorStyle;
@property (nonatomic, strong, readwrite) UIImage *closeButtonImage;
@property (nonatomic, strong, readwrite) UIImage *backButtonImage;
@property (nonatomic, strong, readwrite) UIImage *toolbarSelectionFrame;
@property (nonatomic, readwrite)         CGSize  toolItemSize;
@property (nonatomic, readwrite)         UITableViewCellSeparatorStyle listDividerStyle;
@property (nonatomic, strong, readwrite) UIColor *separatorColor;
@property (nonatomic, readwrite)         UIEdgeInsets separatorEdgeInsets;
//UITableViewCellSeparatorStyleSingleLine

@end


@interface DUXBetaTheme ()
@property (nonatomic, readwrite) BOOL internalLocked;

@property (nonatomic, strong) DUXBetaThemeFonts      *themeFont;
@property (nonatomic, strong) DUXBetaThemeColors     *themeColors;
@property (nonatomic, strong) DUXBetaThemeControls   *themeControls;
@property (nonatomic, strong) DUXBetaThemePanels     *panelSettings;
@end

@implementation DUXBetaTheme
+ (DUXBetaTheme*)sharedTheme {
    static dispatch_once_t onceToken;
    static DUXBetaTheme *baseDefaultTheme;
    
    dispatch_once(&onceToken, ^{
        baseDefaultTheme = [[DUXBetaTheme alloc] init];
    });
    return baseDefaultTheme;
}

- (instancetype)mutableCopy {    // Returns an unlocked copy of the original
    DUXBetaTheme *cleanVersion = [[DUXBetaTheme alloc] initFromTheme:self];
    return cleanVersion;
}

- (BOOL)locked {
    return self.internalLocked;
}

- (void)lock {
    self.internalLocked = YES;
}

- (void)unlock {
    self.internalLocked = NO;
}

- (instancetype) init {
    if (self = [super init]) {
        _themeFont      = [[DUXBetaThemeFonts alloc] init];
        _themeColors    = [[DUXBetaThemeColors alloc] init];
        _themeControls  = [[DUXBetaThemeControls alloc] init];
        _panelSettings  = [[DUXBetaThemePanels alloc] init];
        [self buildDefaultTheme];
    }
    return self;
}

- (instancetype)initFromTheme:(DUXBetaTheme*)original {
    self = [super init];
    _themeFont      = [[DUXBetaThemeFonts alloc] init];
    _themeColors    = [[DUXBetaThemeColors alloc] init];
    _themeControls  = [[DUXBetaThemeControls alloc] init];
    _panelSettings  = [[DUXBetaThemePanels alloc] init];

    [self setFonts:original.themeFont.standardFont
         smallFont:original.themeFont.smallFont
         titleFont:original.themeFont.titleFont
             color:original.themeFont.fontColor
     disabledColor:original.themeFont.disabledColor];
    
    [self setThemeControls:original.themeControls.controlFont
             enabledBorder:original.themeControls.enabldLayerBorderColor disabledBorder:original.themeControls.disabledLayerBorderColor
                background:original.themeControls.contorlBackbgroundColor
                 tintColor:original.themeControls.controlTintColor];
    
    [self setThemeColors:original.themeColors.normalColor
       disconnectedColor:original.themeColors.disconnectedColor
         backgroundColor:original.themeColors.backgroundColor
   widgetBackgroundColor:original.themeColors.widgetBackgroundColor
               goodColor:original.themeColors.goodColor
            warningColor:original.themeColors.warningColor
              errorDangerColor:original.themeColors.errorDangerColor];
    
    [self setThemePanels:original.panelSettings.panelBackgroundColor
         panelTitleColor:original.panelSettings.panelTitleColor
   toolbarSelectionColor:original.panelSettings.toolbarSelectionColor
      listSelectionColor:original.panelSettings.tableSelectionColorStyle
        closeButtonImage:original.panelSettings.closeButtonImage
         backButtonImage:original.panelSettings.backButtonImage
   toolbarSelectionFrame:original.panelSettings.toolbarSelectionFrame
            toolItemSize:original.panelSettings.toolItemSize
        listDividerStyle:original.panelSettings.listDividerStyle
      listSeparatorColor:original.panelSettings.separatorColor
     separatorEdgeInsets:original.panelSettings.separatorEdgeInsets];

    return self;
}


#pragma mark - Builders

- (void) buildDefaultTheme {
    [self setFonts:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
         smallFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
         titleFont:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2] color:[UIColor whiteColor]
     disabledColor:[UIColor uxsdk_lightGrayWhite66]];
    
    [self setThemeControls:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
             enabledBorder:[UIColor whiteColor]
            disabledBorder:[UIColor uxsdk_lightGrayWhite66]
                background:[UIColor clearColor]
                 tintColor:[UIColor clearColor]];
    
    [self setThemeColors:[UIColor whiteColor]
       disconnectedColor:[UIColor uxsdk_lightGrayWhite66]
         backgroundColor:[UIColor uxsdk_blackColor]
   widgetBackgroundColor:[UIColor clearColor]
               goodColor:[UIColor uxsdk_successColor]
            warningColor:[UIColor uxsdk_warningColor]
              errorDangerColor:[UIColor uxsdk_errorDangerColor]];
    
    [self setThemePanels:self.themeColors.backgroundColor
         panelTitleColor:[UIColor uxsdk_whiteColor]
   toolbarSelectionColor:[UIColor whiteColor]
      listSelectionColor:UITableViewCellSelectionStyleBlue
        closeButtonImage:nil    
         backButtonImage:nil
   toolbarSelectionFrame:nil
            toolItemSize:CGSizeMake(64, 64) listDividerStyle:UITableViewCellSeparatorStyleSingleLine listSeparatorColor:[UIColor uxsdk_whiteColor] separatorEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    
}

#pragma mark - Setters
- (instancetype)setFonts:(UIFont*)standardFont
               smallFont:(UIFont*)smallFont
               titleFont:(UIFont*)titleFont
                   color:(UIColor*)color
           disabledColor:(UIColor*)disabledColor {
    if (self.internalLocked) {
        return self;
    }

    _themeFont.standardFont = standardFont;
    _themeFont.smallFont = smallFont;
    _themeFont.titleFont = titleFont;
    _themeFont.fontColor = color;
    _themeFont.disabledColor = disabledColor;
    return self;
}

- (instancetype)setThemeControls:(UIFont*)controlTitleFont
                  enabledBorder:(UIColor*)enabledBorderColor
                 disabledBorder:(UIColor*)disabledBorderColor
                     background:(UIColor*)backgroundColor
                      tintColor:(UIColor*)tintColor {
    if (self.internalLocked) {
        return self;
    }

    _themeControls.controlFont = controlTitleFont;
    _themeControls.enabldLayerBorderColor = enabledBorderColor;
    _themeControls.disabledLayerBorderColor = disabledBorderColor;
    _themeControls.contorlBackbgroundColor = backgroundColor;
    _themeControls.controlTintColor = tintColor;
    return self;
}


- (instancetype)setThemeColors:(UIColor*)normalColor
             disconnectedColor:(UIColor*)disconnectedColor
               backgroundColor:(UIColor*)backgroundColor
         widgetBackgroundColor:(UIColor*)widgetBackgroundColor
                     goodColor:(UIColor*)goodColor
                  warningColor:(UIColor*)warningColor
                    errorDangerColor:(UIColor*)errorDangerColor {
    if (self.internalLocked) {
        return self;
    }

    _themeColors.normalColor = normalColor;
    _themeColors.disconnectedColor = disconnectedColor;
    _themeColors.backgroundColor = backgroundColor;
    _themeColors.widgetBackgroundColor = widgetBackgroundColor;
    _themeColors.goodColor = goodColor;
    _themeColors.warningColor = warningColor;
    _themeColors.errorDangerColor = errorDangerColor;
    return self;
}

- (instancetype)setThemePanels:(UIColor*)panelBackgroundColor
               panelTitleColor:(UIColor*)panelTitleColor
         toolbarSelectionColor:(UIColor*)toolbarSelectionColor
            listSelectionColor:(UITableViewCellSelectionStyle)tableSelectionColorStyle
              closeButtonImage:(UIImage*)closeButtonImage
               backButtonImage:(UIImage*)backButtonImage
         toolbarSelectionFrame:(UIImage*)toolbarSelectionFrame
               toolItemSize:(CGSize)toolItemSize
              listDividerStyle:(UITableViewCellSeparatorStyle)listDividerStyle
            listSeparatorColor:(UIColor*)listDividerColor
           separatorEdgeInsets:(UIEdgeInsets)separatorEdgeInsets {
    if (self.internalLocked) {
        return self;
    }
    
    _panelSettings.panelBackgroundColor = panelBackgroundColor;
    _panelSettings.panelTitleColor = panelTitleColor;
    _panelSettings.toolbarSelectionColor = toolbarSelectionColor;
    _panelSettings.tableSelectionColorStyle = tableSelectionColorStyle;
    _panelSettings.closeButtonImage = closeButtonImage;
    _panelSettings.backButtonImage = backButtonImage;
    _panelSettings.toolbarSelectionFrame = toolbarSelectionFrame;
    _panelSettings.toolItemSize = toolItemSize;
    _panelSettings.listDividerStyle = listDividerStyle;
    _panelSettings.separatorColor = listDividerColor;
    _panelSettings.separatorEdgeInsets = separatorEdgeInsets;

    return self;
}

#pragma mark - Getters
- (DUXBetaThemeFonts*)getStandardFont {
    return self.themeFont;
}

- (DUXBetaThemeColors *)getThemeColors {
    return self.themeColors;
}

- (DUXBetaThemeControls *)getThemeControls {
    return self.themeControls;
}

- (DUXBetaThemePanels *)getThemePanels {
    return self.panelSettings;
}

@end


#pragma mark - Container Classes
@implementation DUXBetaThemeFonts
@end

@implementation DUXBetaThemeColors
@end

@implementation DUXBetaThemeControls
@end

@implementation DUXBetaThemePanels
@end

