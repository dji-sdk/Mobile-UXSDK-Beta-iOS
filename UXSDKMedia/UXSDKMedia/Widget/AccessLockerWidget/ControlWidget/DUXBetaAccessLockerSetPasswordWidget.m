//
//  DUXBetaAccessLockerSetPasswordWidget.m
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

#import "DUXBetaAccessLockerSetPasswordWidget.h"
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static CGSize const kDesignSize = {400.0, 380.0};

@interface DUXBetaAccessLockerSetPasswordWidget ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UITextField *enterPasswordField;
@property (nonatomic, strong) UITextField *confirmPasswordField;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation DUXBetaAccessLockerSetPasswordWidget

- (instancetype)initWithWidgetModel:(DUXBetaAccessLockerControlWidgetModel *)widgetModel {
    self = [super init];
    if (self) {
        _widgetModel = widgetModel;
        [self createUI];
        
        _titleLabelTextColor = _titleLabel.textColor;
        _titleLabelFont = _titleLabel.font;
        
        _descriptionLabelColor = _descriptionLabel.textColor;
        _descriptionLabelFont = _descriptionLabel.font;
        
        _enterPasswordFieldTextColor = _enterPasswordField.textColor;
        _enterPasswordFieldBackgroundColor = _enterPasswordField.backgroundColor;
        _enterPasswordFieldBackgroundImage = _enterPasswordField.background;
        
        _confirmPasswordFieldTextColor = _confirmPasswordField.textColor;
        _confirmPasswordFieldBackgroundColor = _confirmPasswordField.backgroundColor;
        _confirmPasswordFieldBackgroundImage = _confirmPasswordField.background;
        
        _cancelButtonTextColor = _cancelButton.titleLabel.textColor;
        _cancelButtonFont = _cancelButton.titleLabel.font;
        
        _saveButtonTextColor = _saveButton.titleLabel.textColor;
        _saveButtonFont = _saveButton.titleLabel.font;
        
    }
    return self;
}

- (void)createUI {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.text = @"Set Password";
    [self.titleLabel sizeToFit];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.text = @"Your password is used to ensure the secure use of your aircraft. After setting a password, it will be required to control the aircraft and for reading aircraft memory when the aircraft is connected to a computer as an external device.  Passwords can contain uppercase and lowercase letters and numbers.";
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.textColor = UIColor.whiteColor;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    self.enterPasswordField = [[UITextField alloc] init];
    self.enterPasswordField.translatesAutoresizingMaskIntoConstraints = NO;
    self.enterPasswordField.backgroundColor = UIColor.whiteColor;
    self.enterPasswordField.placeholder = @"Enter Password";
    self.enterPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.confirmPasswordField = [[UITextField alloc] init];
    self.confirmPasswordField.translatesAutoresizingMaskIntoConstraints = NO;
    self.confirmPasswordField.backgroundColor = UIColor.whiteColor;
    self.confirmPasswordField.placeholder = @"Confirm Password";
    self.confirmPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitleColor:[UIColor uxsdk_selectedBlueColor] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = UIColor.clearColor;
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] weight:UIFontWeightLight];
    
    self.saveButton = [[UIButton alloc] init];
    self.saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(savePasswordPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton setTitleColor:[UIColor uxsdk_selectedBlueColor] forState:UIControlStateNormal];
    self.saveButton.backgroundColor = UIColor.clearColor;
    self.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    self.view.layer.cornerRadius = 8.0;
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.descriptionLabel];
    [self.view addSubview:self.enterPasswordField];
    [self.view addSubview:self.confirmPasswordField];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.saveButton];

    [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.08].active = YES;
    
    [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor].active = YES;
    [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.descriptionLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.40].active = YES;
    
    [self.enterPasswordField.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor].active = YES;
    [self.enterPasswordField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15.0].active = YES;
    [self.enterPasswordField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15.0].active = YES;
    [self.enterPasswordField.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
    
    [self.confirmPasswordField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15.0].active = YES;
    [self.confirmPasswordField.topAnchor constraintEqualToAnchor:self.enterPasswordField.bottomAnchor constant:15.0].active = YES;
    [self.confirmPasswordField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15.0].active = YES;
    [self.confirmPasswordField.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;

    [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.confirmPasswordField.bottomAnchor].active = YES;
    [self.cancelButton.trailingAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self.saveButton.leadingAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.saveButton.topAnchor constraintEqualToAnchor:self.confirmPasswordField.bottomAnchor].active = YES;
    [self.saveButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.saveButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)savePasswordPressed {
    weakSelf(target);
    [self.widgetModel initalizeAccessLockerWithPassword:self.enterPasswordField.text andCompletion:^(NSError * _Nullable error) {
        if ([target.delegate respondsToSelector:@selector(setPasswordButtonPressedWithError:)]) {
            [target.delegate setPasswordButtonPressedWithError:error];
        }
    }];
}

- (void)cancelPressed {
    if ([self.delegate respondsToSelector:@selector(setPasswordCancelButtonPressed)]) {
        [self.delegate setPasswordCancelButtonPressed];
    }
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor {
    _titleLabelTextColor = titleLabelTextColor;
    _titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    _titleLabel.font = titleLabelFont;
}

- (void)setDescriptionLabelColor:(UIColor *)descriptionLabelColor {
    _descriptionLabelColor = descriptionLabelColor;
    _descriptionLabel.textColor = descriptionLabelColor;
}

- (void)setDescriptionLabelFont:(UIFont *)descriptionLabelFont {
    _descriptionLabelFont = descriptionLabelFont;
    _descriptionLabel.font = descriptionLabelFont;
}

- (void)setEnterPasswordFieldTextColor:(UIColor *)enterPasswordFieldTextColor {
    _enterPasswordFieldTextColor = enterPasswordFieldTextColor;
    _enterPasswordField.textColor = enterPasswordFieldTextColor;
}

- (void)setEnterPasswordFieldBackgroundColor:(UIColor *)enterPasswordFieldBackgroundColor {
    _enterPasswordFieldBackgroundColor = enterPasswordFieldBackgroundColor;
    _enterPasswordField.backgroundColor = enterPasswordFieldBackgroundColor;
}

- (void)setEnterPasswordFieldBackgroundImage:(UIImage *)enterPasswordFieldBackgroundImage {
    _enterPasswordFieldBackgroundImage = enterPasswordFieldBackgroundImage;
    _enterPasswordField.background = enterPasswordFieldBackgroundImage;
}

- (void)setConfirmPasswordFieldTextColor:(UIColor *)confirmPasswordFieldTextColor {
    _confirmPasswordFieldTextColor = confirmPasswordFieldTextColor;
    _confirmPasswordField.textColor = confirmPasswordFieldTextColor;
}

- (void)setConfirmPasswordFieldBackgroundColor:(UIColor *)confirmPasswordFieldBackgroundColor {
    _confirmPasswordFieldBackgroundColor = confirmPasswordFieldBackgroundColor;
    _confirmPasswordField.backgroundColor = confirmPasswordFieldBackgroundColor;
}

- (void)setConfirmPasswordFieldBackgroundImage:(UIImage *)confirmPasswordFieldBackgroundImage {
    _confirmPasswordFieldBackgroundImage = confirmPasswordFieldBackgroundImage;
    _confirmPasswordField.background = confirmPasswordFieldBackgroundImage;
}

- (void)setCancelButtonTextColor:(UIColor *)cancelButtonTextColor {
    _cancelButtonTextColor = cancelButtonTextColor;
    [_cancelButton setTitleColor:cancelButtonTextColor forState:UIControlStateNormal];
}

- (void)setCancelButtonFont:(UIFont *)cancelButtonFont {
    _cancelButtonFont = cancelButtonFont;
    _cancelButton.titleLabel.font = cancelButtonFont;
}

- (void)setSaveButtonTextColor:(UIColor *)saveButtonTextColor {
    _saveButtonTextColor = saveButtonTextColor;
    [_saveButton setTitleColor:saveButtonTextColor forState:UIControlStateNormal];
}

- (void)setSaveButtonFont:(UIFont *)saveButtonFont {
    _saveButtonFont = saveButtonFont;
    _saveButton.titleLabel.font = saveButtonFont;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
