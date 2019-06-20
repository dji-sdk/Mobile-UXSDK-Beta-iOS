//
//  UIImage+DUXBetaAssets.m
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

#import "UIImage+DUXBetaAssets.h"
#import "DUXBetaBaseWidget.h"

@implementation UIImage (DUXBetaAssets)

+ (UIImage *)duxbeta_imageWithAssetNamed:(NSString *)assetName {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[DUXBetaBaseWidget class]];
    NSURL *assetBundleURL = [frameworkBundle.resourceURL URLByAppendingPathComponent:@"/DUXBetaAssets.bundle"];
    NSBundle *assetBundle = [NSBundle bundleWithURL:assetBundleURL];
    
    UIImage *assetImage = [UIImage imageNamed:assetName
                                     inBundle:assetBundle
                compatibleWithTraitCollection:nil];
    
    if (assetImage == nil)  {
        NSLog(@"*** Invalid Asset: %@ ***", assetName);
        NSLog(@"Please make sure that the asset your are refering is available with the same file name in DJIUXSDK.frameworks/Assets");
        NSLog(@"A placeholder image (orange square) will be return in the mean time.");
        
        CGSize size = CGSizeMake(20.0, 20.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [[UIColor orangeColor] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        assetImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return assetImage;
}
@end
