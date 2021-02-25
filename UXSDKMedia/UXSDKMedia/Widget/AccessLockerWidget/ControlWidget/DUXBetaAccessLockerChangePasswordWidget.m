//
//  DUXBetaAccessLockerChangePasswordWidget.m
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

#import "DUXBetaAccessLockerChangePasswordWidget.h"
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static CGSize const kDesignSize = {400.0, 380.0};
@interface DUXBetaAccessLockerChangePasswordWidget ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UITextField *enterCurrentPasswordField;
@property (nonatomic, strong) UITextField *enterNewPasswordField;
@property (nonatomic, strong) UITextField *confirmNewPasswordField;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation DUXBetaAccessLockerChangePasswordWidget

- (instancetype)initWithWidgetModel:(DUXBetaAccessLockerControlWidgetModel *)widgetModel {
    self = [super init];
    if (self) {
        _widgetModel = widgetModel;
        [self createUI];
        
        _titleLabelTextColor = _titleLabel.textColor;
        _titleLabelFont = _titleLabel.font;
        
        _descriptionLabelColor = _descriptionLabel.textColor;
        _descriptionLabelFont = _descriptionLabel.font;
        
        _enterCurrentPasswordFieldTextColor = _enterCurrentPasswordField.textColor;
        _enterCurrentPasswordFieldBackgroundColor = _enterCurrentPasswordField.backgroundColor;
        _enterCurrentPasswordFieldBackgroundImage = _enterCurrentPasswordField.background;
        
        _enterNewPasswordFieldTextColor = _enterNewPasswordField.textColor;
        _enterNewPasswordFieldBackgroundColor = _enterNewPasswordField.backgroundColor;
        _enterNewPasswordFieldBackgroundImage = _enterNewPasswordField.background;
        
        _confirmNewPasswordFieldTextColor = _confirmNewPasswordField.textColor;
        _confirmNewPasswordFieldBackgroundColor = _confirmNewPasswordField.backgroundColor;
        _confirmNewPasswordFieldBackgroundImage = _confirmNewPasswordField.background;
        
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
    self.titleLabel.text = @"Change Password";
    [self.titleLabel sizeToFit];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.numberOfLines = 2;
    self.descriptionLabel.text = @"Passwords can contain uppercase and lowercase letters and numbers.";
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.textColor = UIColor.whiteColor;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    self.enterCurrentPasswordField = [[UITextField alloc] init];
    self.enterCurrentPasswordField.translatesAutoresizingMaskIntoConstraints = NO;
    self.enterCurrentPasswordField.backgroundColor = UIColor.whiteColor;
    self.enterCurrentPasswordField.placeholder = @"Enter Current Password";
    self.enterCurrentPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.enterNewPasswordField = [[UITextField alloc] init];
    self.enterNewPasswordField.translatesAutoresizingMaskIntoConstraints = NO;
    self.enterNewPasswordField.backgroundColor = UIColor.whiteColor;
    self.enterNewPasswordField.placeholder = @"Enter New Password";
    self.enterNewPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.confirmNewPasswordField = [[UITextField alloc] init];
    self.confirmNewPasswordField.translatesAutoresizingMaskIntoConstraints = NO;
    self.confirmNewPasswordField.backgroundColor = UIColor.whiteColor;
    self.confirmNewPasswordField.placeholder = @"Confirm New Password";
    self.confirmNewPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    
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
    [self.view addSubview:self.enterCurrentPasswordField];
    [self.view addSubview:self.enterNewPasswordField];
    [self.view addSubview:self.confirmNewPasswordField];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.saveButton];
    
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.08].active = YES;
    
    [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor].active = YES;
    [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.descriptionLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
    
    [self.enterCurrentPasswordField.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor].active = YES;
    [self.enterCurrentPasswordField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15.0].active = YES;
    [self.enterCurrentPasswordField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15.0].active = YES;
    
    [self.enterNewPasswordField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15.0].active = YES;
    [self.enterNewPasswordField.topAnchor constraintEqualToAnchor:self.enterCurrentPasswordField.bottomAnchor constant:15.0].active = YES;
    [self.enterNewPasswordField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15.0].active = YES;
    
    [self.confirmNewPasswordField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15.0].active = YES;
    [self.confirmNewPasswordField.topAnchor constraintEqualToAnchor:self.enterNewPasswordField.bottomAnchor constant:15.0].active = YES;
    [self.confirmNewPasswordField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15.0].active = YES;

    [self.enterCurrentPasswordField.heightAnchor constraintEqualToAnchor:self.enterNewPasswordField.heightAnchor].active = YES;
    [self.confirmNewPasswordField.heightAnchor constraintEqualToAnchor:self.enterNewPasswordField.heightAnchor].active = YES;
    
    [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.confirmNewPasswordField.bottomAnchor].active = YES;
    [self.cancelButton.trailingAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
    
    [self.saveButton.leadingAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.saveButton.topAnchor constraintEqualToAnchor:self.confirmNewPasswordField.bottomAnchor].active = YES;
    [self.saveButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.saveButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.saveButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)savePasswordPressed {
    if ([self.enterNewPasswordField.text isEqualToString:self.confirmNewPasswordField.text]) {
        weakSelf(target);
        [self.widgetModel changeAccessLockerPassword:self.enterNewPasswordField.text fromCurrentPassword:self.enterCurrentPasswordField.text withCompletion:^(NSError * _Nullable error) {
            if ([target.delegate respondsToSelector:@selector(changePasswordButtonPressedWithError:)]) {
                [target.delegate changePasswordButtonPressedWithError:error];
            }
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(changePasswordButtonPressedWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"com.dji.UXSDKMedia" code:1000 userInfo:@{
                                                                                               NSLocalizedDescriptionKey:@"New passwords must match."
                                                                                               }];
            [self.delegate changePasswordButtonPressedWithError:error];
        }
    }
}

- (void)cancelPressed {
    if ([self.delegate respondsToSelector:@selector(changePasswordCancelButtonPressed)]) {
        [self.delegate changePasswordCancelButtonPressed];
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

- (void)setEnterCurrentPasswordFieldTextColor:(UIColor *)enterCurrentPasswordFieldTextColor {
    _enterCurrentPasswordFieldTextColor = enterCurrentPasswordFieldTextColor;
    _enterCurrentPasswordField.backgroundColor = enterCurrentPasswordFieldTextColor;
}

- (void)setEnterCurrentPasswordFieldBackgroundColor:(UIColor *)enterCurrentPasswordFieldBackgroundColor {
    _enterCurrentPasswordFieldBackgroundColor = enterCurrentPasswordFieldBackgroundColor;
    _enterCurrentPasswordField.backgroundColor = enterCurrentPasswordFieldBackgroundColor;
}

- (void)setEnterCurrentPasswordFieldBackgroundImage:(UIImage *)enterCurrentPasswordFieldBackgroundImage {
    _enterCurrentPasswordFieldBackgroundImage = enterCurrentPasswordFieldBackgroundImage;
    _enterCurrentPasswordField.background = enterCurrentPasswordFieldBackgroundImage;
}

- (void)setEnterNewPasswordFieldTextColor:(UIColor *)enterNewPasswordFieldTextColor {
    _enterNewPasswordFieldTextColor = enterNewPasswordFieldTextColor;
    _enterNewPasswordField.backgroundColor = enterNewPasswordFieldTextColor;
}

- (void)setEnterNewPasswordFieldBackgroundColor:(UIColor *)enterNewPasswordFieldBackgroundColor {
    _enterNewPasswordFieldBackgroundColor = enterNewPasswordFieldBackgroundColor;
    _enterNewPasswordField.backgroundColor = enterNewPasswordFieldBackgroundColor;
}

- (void)setEnterNewPasswordFieldBackgroundImage:(UIImage *)enterNewPasswordFieldBackgroundImage {
    _enterNewPasswordFieldBackgroundImage = enterNewPasswordFieldBackgroundImage;
    _enterNewPasswordField.background = enterNewPasswordFieldBackgroundImage;
}

- (void)setConfirmNewPasswordFieldTextColor:(UIColor *)confirmNewPasswordFieldTextColor {
    _confirmNewPasswordFieldTextColor = confirmNewPasswordFieldTextColor;
    _confirmNewPasswordField.backgroundColor = confirmNewPasswordFieldTextColor;
}

- (void)setConfirmNewPasswordFieldBackgroundColor:(UIColor *)confirmNewPasswordFieldBackgroundColor {
    _confirmNewPasswordFieldBackgroundColor = confirmNewPasswordFieldBackgroundColor;
    _confirmNewPasswordField.backgroundColor = confirmNewPasswordFieldBackgroundColor;
}

- (void)setConfirmNewPasswordFieldBackgroundImage:(UIImage *)confirmNewPasswordFieldBackgroundImage {
    _confirmNewPasswordFieldBackgroundImage = confirmNewPasswordFieldBackgroundImage;
    _confirmNewPasswordField.background = confirmNewPasswordFieldBackgroundImage;
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
