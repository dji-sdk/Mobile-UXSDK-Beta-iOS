//
//  DUXBetaAccessLockerControlWidget.h
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
@class DUXBetaAccessLockerControlWidgetModel;
@class DUXBetaAccessLockerSetPasswordWidget;
@class DUXBetaAccessLockerChangeRemovePasswordWidget;
@class DUXBetaAccessLockerChangePasswordWidget;
@class DUXBetaAccessLockerRemovePasswordWidget;
@class DUXBetaAccessLockerFormatAircraftWidget;
@class DUXBetaAccessLockerEnterPasswordWidget;

NS_ASSUME_NONNULL_BEGIN

@protocol DUXBetaAccessLockerControlWidgetDelegate <NSObject>

- (void)currentScreenChangedTo:(DUXBetaBaseWidget *)newScreen;

@optional

- (void)setPasswordFailedWithError:(NSError *)error;

- (void)changePasswordFailedWithError:(NSError *)error;

- (void)removePasswordFailedWithError:(NSError *)error;

- (void)formatAircraftFailedWithError:(NSError *)error;

- (void)unlockAccessLockerFailedWithError:(NSError *)error;

@end

@interface DUXBetaAccessLockerControlWidget : DUXBetaBaseWidget

@property (nonatomic, strong) DUXBetaAccessLockerControlWidgetModel *widgetModel;

@property (nonatomic, weak) id<DUXBetaAccessLockerControlWidgetDelegate> delegate;

@property (nonatomic, strong) DUXBetaAccessLockerSetPasswordWidget *setPasswordWidget;
@property (nonatomic, strong) DUXBetaAccessLockerChangeRemovePasswordWidget *changeRemovePasswordWidget;
@property (nonatomic, strong) DUXBetaAccessLockerChangePasswordWidget *changePasswordWidget;
@property (nonatomic, strong) DUXBetaAccessLockerRemovePasswordWidget *removePasswordWidget;
@property (nonatomic, strong) DUXBetaAccessLockerFormatAircraftWidget *formatAircraftWidget;
@property (nonatomic, strong) DUXBetaAccessLockerEnterPasswordWidget *enterPasswordWidget;

@end

NS_ASSUME_NONNULL_END
