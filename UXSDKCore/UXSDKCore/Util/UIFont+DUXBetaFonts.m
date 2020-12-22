//
//  UIFont+DUXBetaFonts.m
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

#import "UIFont+DUXBetaFonts.h"
#import <CoreText/CoreText.h>
#import "NSBundle+DUXBetaAssets.h"
#import "DUXBetaBaseWidget.h"

@implementation UIFont (DUXBetaFonts)

+ (UIFont *)duxbeta_dinMediumFontWithSize:(CGFloat)fontSize {
    return [self duxbeta_customFontNamed:@"DIN-Medium"
                                ofType:@"otf"
                                ofSize:fontSize];
}

+ (UIFont *)duxbeta_customFontNamed:(NSString *)customFontName ofType:(NSString *)type ofSize:(CGFloat)fontSize {
    UIFont *font = [UIFont fontWithName:customFontName size:fontSize];
    if (!font) {
        BOOL loadFontSuccess = [self duxbeta_loadFontWithName:customFontName ofType:type];
        font = [UIFont fontWithName:customFontName size:fontSize];
        if (!(font && loadFontSuccess)) {
            return [UIFont systemFontOfSize:fontSize];
        }
    }
    return font;
}

+ (UIFont *)duxbeta_customFontNamed:(NSString *)customFontName ofType:(NSString *)type ofSize:(CGFloat)fontSize forClass:(Class)classType {
    UIFont *font = [UIFont fontWithName:customFontName size:fontSize];
    if (!font) {
        BOOL loadFontSuccess = [self duxbeta_loadFontWithName:customFontName ofType:type forClass:classType];
        font = [UIFont fontWithName:customFontName size:fontSize];
        if (!(font && loadFontSuccess)) {
            return [UIFont systemFontOfSize:fontSize];
        }
    }
    return font;
}

#pragma mark - Private Method

+ (BOOL)duxbeta_loadFontWithName:(NSString *)fontName ofType:(NSString *)type {
    return [UIFont duxbeta_loadFontWithName:fontName ofType:type forClass:[DUXBetaBaseWidget class]];
}

+ (BOOL)duxbeta_loadFontWithName:(NSString *)fontName ofType:(NSString *)type forClass:(Class)classType {
    NSString *fontPath = [[NSBundle duxbeta_currentBundleFor:classType] pathForResource:fontName ofType:type];
    NSData *fontData = [NSData dataWithContentsOfFile:fontPath];

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);

    if (provider) {
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (font) {
            CFErrorRef error = NULL;
            if (CTFontManagerRegisterGraphicsFont(font, &error) == NO) {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                NSLog(@"Failed to load font: %@", errorDescription);
                CFRelease(errorDescription);
                CFRelease(font);
                return NO;
            } else {
                CFRelease(font);
                CFRelease(provider);
                return YES;
            }
        } else {
            CFRelease(provider);
            return NO;
        }
    } else {
        return NO;
    }
}

@end
