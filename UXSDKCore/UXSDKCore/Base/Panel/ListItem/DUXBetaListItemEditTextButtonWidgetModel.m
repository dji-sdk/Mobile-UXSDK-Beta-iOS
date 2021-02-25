//
//  DUXBetaListItemEditTextButtonWidgetModel.m
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

#import "DUXBetaListItemEditTextButtonWidgetModel.h"
#import "UIImage+DUXBetaAssets.h"

@interface DUXBetaListItemEditTextButtonWidgetModel()

@property (nonatomic, strong) DJIKey* keyForField;
@property (nonatomic, strong) DJIKey *rangeKey;
@property (nonatomic, strong) DJIKey *enabledKey;   // If nil, don't show enabled button
@property (nonatomic, strong) NSString *rangeStringFormat;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation DUXBetaListItemEditTextButtonWidgetModel

// TODO: Flesh this out to handle more than just numeric fields eventually
// Right now this code in the model is unused.
- (void)currentKey:(DJIKey*)key rangeKey:(DJIKey *)rangeKey enabledKey:(DJIKey *)enabledKey rangeStringFormat:(NSString*)rangeStringFmt iconName:(NSString*) iconName {
    self.keyForField = key;
    self.rangeKey = rangeKey;
    self.enabledKey = enabledKey;
    self.rangeStringFormat = rangeStringFmt;

    if (iconName != nil) {
        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:iconName]];
    }
}

- (void)setup {
}

- (void)cleanup {
}

- (void)dealloc {
    [self cleanup];
}

@end
