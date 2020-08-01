//
//  NSData+DUXBetaAssets.m
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

#import "NSData+DUXBetaAssets.h"
#import "NSBundle+DUXBetaAssets.h"
#import "DUXBetaBaseWidget.h"

@implementation NSData (DUXBetaAssets)

+ (NSData *)duxbeta_dataWithAssetNamed:(NSString *)assetName {
    NSBundle *currentBundle = [NSBundle duxbeta_currentBundle];
    NSDataAsset *asset = [[NSDataAsset alloc] initWithName:assetName bundle:currentBundle];
    NSData *assetData = asset.data;
    
    if (assetData == nil)  {
        NSLog(@"*** Invalid Asset: %@ ***", assetName);
        NSLog(@"Please make sure that the asset you are referring to is available with the same file name in the framework");
    }
    return assetData;
}


@end

