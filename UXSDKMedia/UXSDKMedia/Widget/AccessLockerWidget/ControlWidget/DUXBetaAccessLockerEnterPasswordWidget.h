//
//  DUXBetaAccessLockerEnterPasswordWidget.h
//  UXSDKMedia
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

#import <UXSDKCore/DUXBetaBaseWidget.h>
#import "DUXBetaAccessLockerControlWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DUXBetaAccessLockerEnterPasswordWidgetDelegate <NSObject>

- (void)unlockButtonPressedWithError:(NSError * _Nullable)error;
- (void)enterPasswordFormatButtonPressed;
- (void)enterPasswordCancelButtonPressed;

@end

@interface DUXBetaAccessLockerEnterPasswordWidget : DUXBetaBaseWidget

- (instancetype)initWithWidgetModel:(DUXBetaAccessLockerControlWidgetModel *)widgetModel;

@property (nonatomic, strong) DUXBetaAccessLockerControlWidgetModel *widgetModel;

@property (nonatomic, weak) id<DUXBetaAccessLockerEnterPasswordWidgetDelegate> delegate;

@property (nonatomic, strong) UIColor *titleLabelTextColor;
@property (nonatomic, strong) UIFont *titleLabelFont;

@property (nonatomic, strong) UIColor *descriptionLabelColor;
@property (nonatomic, strong) UIFont *descriptionLabelFont;

@property (nonatomic, strong) UIColor * _Nullable enterPasswordFieldTextColor;
@property (nonatomic, strong) UIColor * _Nullable enterPasswordFieldBackgroundColor;
@property (nonatomic, strong) UIImage * _Nullable enterPasswordFieldBackgroundImage;

@property (nonatomic, strong) UIColor *formatAircraftButtonTextColor;
@property (nonatomic, strong) UIFont *formatAircraftButtonFont;

@property (nonatomic, strong) UIColor *cancelButtonTextColor;
@property (nonatomic, strong) UIFont *cancelButtonFont;

@property (nonatomic, strong) UIColor *unlockButtonTextColor;
@property (nonatomic, strong) UIFont *unlockButtonFont;

@end

NS_ASSUME_NONNULL_END
