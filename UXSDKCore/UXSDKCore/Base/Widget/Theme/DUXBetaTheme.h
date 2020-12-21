//
//  DUXBetaTheme.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface DUXBetaThemeFonts : NSObject
@property (nonatomic, strong, readonly) UIFont  *standardFont;
@property (nonatomic, strong, readonly) UIFont  *smallFont;
@property (nonatomic, strong, readonly) UIFont  *titleFont;
@property (nonatomic, strong, readonly) UIColor *fontColor;
@property (nonatomic, strong, readonly) UIColor *disabledColor;
@end

@interface DUXBetaThemeColors : NSObject
@property (nonatomic, strong, readonly) UIColor *normalColor;
@property (nonatomic, strong, readonly) UIColor *disconnectedColor;
@property (nonatomic, strong, readonly) UIColor *backgroundColor;
@property (nonatomic, strong, readonly) UIColor *widgetBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *goodColor;
@property (nonatomic, strong, readonly) UIColor *warningColor;
@property (nonatomic, strong, readonly) UIColor *errorDangerColor;
@end

@interface DUXBetaThemeControls : NSObject
@property (nonatomic, strong, readonly) UIFont  *controlFont;
@property (nonatomic, strong, readonly) UIColor *enabldLayerBorderColor;
@property (nonatomic, strong, readonly) UIColor *disabledLayerBorderColor;
@property (nonatomic, strong, readonly) UIColor *contorlBackbgroundColor;
@property (nonatomic, strong, readonly) UIColor *controlTintColor;  // May be nil
@end

@interface DUXBetaThemePanels : NSObject
@property (nonatomic, strong, readonly) UIColor *panelBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *panelTitleColor;
@property (nonatomic, strong, readonly) UIColor *toolbarSelectionColor;
@property (nonatomic, readonly) UITableViewCellSelectionStyle   tableSelectionColorStyle;
@property (nonatomic, strong, readonly) UIImage *closeButtonImage;
@property (nonatomic, strong, readonly) UIImage *backButtonImage;
@property (nonatomic, strong, readonly) UIImage *toolbarSelectionFrame;
@property (nonatomic, readonly)         CGSize  toolItemSize;
@property (nonatomic, readonly)         UITableViewCellSeparatorStyle listDividerStyle;
@property (nonatomic, strong, readonly) UIColor *separatorColor;
@property (nonatomic, readonly)         UIEdgeInsets separatorEdgeInsets;
//UITableViewCellSeparatorStyleSingleLine

@end

@interface DUXBetaTheme : NSObject
@property (nonatomic, readonly) BOOL isLocked;
+ (DUXBetaTheme*)sharedTheme;

// Returns an shallow unlocked copy of the original. Internals a copied and modifying
// the settings won't affect the original as all internal objects are non-mutable.
- (instancetype)mutableCopy;

- (void)lock;
- (void)unlock;

- (instancetype)setFonts:(UIFont*)standardFont
               smallFont:(UIFont*)smallFont
               titleFont:(UIFont*)titleFont
                   color:(UIColor*)color
           disabledColor:(UIColor*)disabledColor;

- (instancetype)setControlTheme:(UIFont*)controlTitleFont
                  enabledBorder:(UIColor*)enabledBorderColor
                 disabledBorder:(UIColor*)disabledBorderColor
                     background:(UIColor*)backgroundColor
                      tintColor:(UIColor*)tintColor;

- (instancetype)setThemeColors:(UIColor*)normalColor
    disconnectedColor:(UIColor*)disconnectedColor
      backgroundColor:(UIColor*)backgroundColor
widgetBackgroundColor:(UIColor*)widgetBackgroundColor
            goodColor:(UIColor*)goodColor
         warningColor:(UIColor*)warningColor
           errorDangerColor:(UIColor*)errorDangerColor;

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
           separatorEdgeInsets:(UIEdgeInsets)separatorEdgeInsets;


- (DUXBetaThemeFonts*)getStandardFont;
- (DUXBetaThemeColors*)getThemeColors;
- (DUXBetaThemeControls*)getThemeControls;
- (DUXBetaThemePanels*)getThemePanels;

@end

NS_ASSUME_NONNULL_END
