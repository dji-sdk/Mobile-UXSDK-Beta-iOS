//
//  DUXBetaAccessLockerControlWidget.m
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

#import "DUXBetaAccessLockerControlWidget.h"
#import "DUXBetaAccessLockerControlWidgetModel.h"
#import "DUXBetaAccessLockerSetPasswordWidget.h"
#import "DUXBetaAccessLockerChangeRemovePasswordWidget.h"
#import "DUXBetaAccessLockerChangePasswordWidget.h"
#import "DUXBetaAccessLockerRemovePasswordWidget.h"
#import "DUXBetaAccessLockerFormatAircraftWidget.h"
#import "DUXBetaAccessLockerEnterPasswordWidget.h"


@interface DUXBetaAccessLockerControlWidget ()<DUXBetaAccessLockerSetPasswordWidgetDelegate, DUXBetaAccessLockerChangeRemovePasswordWidgetDelegate, DUXBetaAccessLockerChangePasswordWidgetDelegate, DUXBetaAccessLockerRemovePasswordWidgetDelegate, DUXBetaAccessLockerFormatAircraftWidgetDelegate, DUXBetaAccessLockerEnterPasswordWidgetDelegate>

@property (nonatomic, strong) DUXBetaBaseWidget *displayedWidget;

@end

@implementation DUXBetaAccessLockerControlWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _widgetModel = [[DUXBetaAccessLockerControlWidgetModel alloc] init];
        
        _setPasswordWidget = [[DUXBetaAccessLockerSetPasswordWidget alloc] initWithWidgetModel:_widgetModel];
        _changeRemovePasswordWidget = [[DUXBetaAccessLockerChangeRemovePasswordWidget alloc] initWithWidgetModel:_widgetModel];
        _changePasswordWidget = [[DUXBetaAccessLockerChangePasswordWidget alloc] initWithWidgetModel:_widgetModel];
        _removePasswordWidget = [[DUXBetaAccessLockerRemovePasswordWidget alloc] initWithWidgetModel:_widgetModel];
        _formatAircraftWidget = [[DUXBetaAccessLockerFormatAircraftWidget alloc] initWithWidgetModel:_widgetModel];
        _enterPasswordWidget = [[DUXBetaAccessLockerEnterPasswordWidget alloc] initWithWidgetModel:_widgetModel];
        
        _setPasswordWidget.delegate = self;
        _changeRemovePasswordWidget.delegate = self;
        _removePasswordWidget.delegate = self;
        _formatAircraftWidget.delegate = self;
        _enterPasswordWidget.delegate = self;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.widgetModel setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateDisplayedAccessLockerPage), currentAccessLockerStateType);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)updateDisplayedAccessLockerPage {
    switch(self.widgetModel.currentAccessLockerStateType) {
        case DJIAccessLockerStateNotInitialized:
            self.displayedWidget = self.setPasswordWidget;
            break;
        case DJIAccessLockerStateLocked:
            self.displayedWidget = self.enterPasswordWidget;
            break;
        case DJIAccessLockerStateUnlocked:
            self.displayedWidget = self.changeRemovePasswordWidget;
            break;
        case DJIAccessLockerStateUnknown:
            self.displayedWidget = self.setPasswordWidget;
            break;
    }
}

#pragma mark - DUXBetaAccessLockerSetPasswordWidgetDelegate Methods

- (void)setPasswordCancelButtonPressed {
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (void)setPasswordButtonPressedWithError:(NSError * _Nullable)error {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(setPasswordFailedWithError:)]) {
            [self.delegate setPasswordFailedWithError:error];
        }
    } else {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
}

#pragma mark - DUXBetaAccessLockerChangeRemovePasswordWidgetDelegate Methods

- (void)changePasswordButtonPressed {
    self.displayedWidget = self.changePasswordWidget;
}

- (void)removePasswordButtonPressed {
    self.displayedWidget = self.removePasswordWidget;
}

#pragma mark - DUXBetaAccessLockerChangePasswordWidgetDelegate Methods

- (void)changePasswordButtonPressedWithError:(NSError * _Nullable)error {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(changePasswordFailedWithError:)]) {
            [self.delegate changePasswordFailedWithError:error];
        }
    }
}

- (void)changePasswordCancelButtonPressed {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

#pragma mark - DUXBetaAccessLockerRemovePasswordWidgetDelegate Methods

- (void)removePasswordButtonPressedWithError:(NSError * _Nullable)error {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(removePasswordFailedWithError:)]) {
            [self.delegate removePasswordFailedWithError:error];
        }
    }
}

- (void)removePasswordFormatAircraftButtonPressed {
    self.displayedWidget = self.formatAircraftWidget;
}

- (void)removePasswordCancelButtonPressed {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

#pragma mark DUXBetaAccessLockerFormatAircraftWidgetDelegate Methods

- (void)formatAircraftButtonPressedWithError:(NSError * _Nullable)error {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(formatAircraftFailedWithError:)]) {
            [self.delegate formatAircraftFailedWithError:error];
        }
    }
}

- (void)formatAircraftCancelButtonPressed {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

#pragma mark DUXBetaAccessLockerEnterPasswordWidgetDelegate Methods

- (void)unlockButtonPressedWithError:(NSError * _Nullable)error {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(unlockAccessLockerFailedWithError:)]) {
            [self.delegate unlockAccessLockerFailedWithError:error];
        }
    }
}

- (void)enterPasswordFormatButtonPressed {
    self.displayedWidget = self.formatAircraftWidget;
}

- (void)enterPasswordCancelButtonPressed {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)setDisplayedWidget:(DUXBetaBaseWidget *)displayedWidget {
    [_displayedWidget removeFromParentViewController];
    [_displayedWidget.view removeFromSuperview];
    
    _displayedWidget = displayedWidget;
    
    if ([self.delegate respondsToSelector:@selector(currentScreenChangedTo:)]) {
        [self.delegate currentScreenChangedTo:displayedWidget];
    }
    
    [displayedWidget installInViewController:self];
    
    displayedWidget.view.translatesAutoresizingMaskIntoConstraints = NO;
    [displayedWidget.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [displayedWidget.view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [displayedWidget.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [displayedWidget.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    return self.displayedWidget.widgetSizeHint;
}

@end
