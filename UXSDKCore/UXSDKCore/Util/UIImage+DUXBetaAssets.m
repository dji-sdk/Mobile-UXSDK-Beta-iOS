//
//  UIImage+Assets.m
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

#import "UIImage+DUXBetaAssets.h"
#import "NSBundle+DUXBetaAssets.h"
#import "DUXBetaBaseWidget.h"

@implementation UIImage (DUXBetaAssets)

+ (UIImage *)duxbeta_imageWithAssetNamed:(NSString *)assetName {
    return [UIImage duxbeta_imageWithAssetNamed:assetName forClass:[DUXBetaBaseWidget class]];
}

+ (UIImage *)duxbeta_imageWithAssetNamed:(NSString *)assetName forClass:(Class)classType {
    NSBundle *currentBundle = [NSBundle duxbeta_currentBundleFor:classType];
    UIImage *assetImage = [UIImage imageNamed:assetName inBundle:currentBundle compatibleWithTraitCollection:nil];
    
    if (assetImage == nil)  {
        NSLog(@"*** Invalid Asset: %@ ***", assetName);
        NSLog(@"Please make sure that the asset you are referring to is available with the same file name in DJIUXSDK.frameworks/Assets");
        NSLog(@"A placeholder image (orange square) will be returned in the meantime.");
        
        CGSize size = CGSizeMake(20.0, 20.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [[UIColor orangeColor] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        assetImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return assetImage;
}

+ (UIImage *)duxbeta_colorizeImage:(UIImage*)image withColor:(UIColor*)tintColor {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [tintColor setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}
@end
