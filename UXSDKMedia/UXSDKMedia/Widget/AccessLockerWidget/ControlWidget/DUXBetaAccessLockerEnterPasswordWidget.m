//
//  DUXBetaAccessLockerEnterPasswordWidget.m
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

#import "DUXBetaAccessLockerEnterPasswordWidget.h"
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static CGSize const kDesignSize = {400, 300};
@interface DUXBetaAccessLockerEnterPasswordWidget ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UITextField *enterPasswordField;

@property (nonatomic, strong) UIButton *formatAircraftButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *unlockButton;

@end

@implementation DUXBetaAccessLockerEnterPasswordWidget

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
        
        _formatAircraftButtonTextColor = _formatAircraftButton.titleLabel.textColor;
        _formatAircraftButtonFont = _formatAircraftButton.titleLabel.font;
        
        _cancelButtonTextColor = _cancelButton.titleLabel.textColor;
        _cancelButtonFont = _cancelButton.titleLabel.font;
        
        _unlockButtonTextColor = _unlockButton.titleLabel.textColor;
        _unlockButtonFont = _unlockButton.titleLabel.font;
    }
    return self;
}

- (void)createUI {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.text = @"Enter Password";
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.descriptionLabel];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.text = @"The password is stored locally on the aircraft.  Password retrieval is not available for this reason.  DJI is not able to reset your password.  If you forget your password you will need to format the aircraft to remove the password.  Formatting the aircraft will delete all data in its storage.";
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.textColor = UIColor.whiteColor;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    self.enterPasswordField = [[UITextField alloc] init];
    self.enterPasswordField.translatesAutoresizingMaskIntoConstraints = NO;
    self.enterPasswordField.backgroundColor = UIColor.whiteColor;
    self.enterPasswordField.placeholder = @"Enter Password";
    self.enterPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.formatAircraftButton = [[UIButton alloc] init];
    self.formatAircraftButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.formatAircraftButton setTitle:@"Format" forState:UIControlStateNormal];
    [self.formatAircraftButton addTarget:self action:@selector(formatButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.formatAircraftButton setTitleColor:[UIColor uxsdk_errorDangerColor] forState:UIControlStateNormal];
    self.formatAircraftButton.backgroundColor = UIColor.clearColor;
    self.formatAircraftButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitleColor:[UIColor uxsdk_selectedBlueColor] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = UIColor.clearColor;
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] weight:UIFontWeightLight];
    
    self.unlockButton = [[UIButton alloc] init];
    self.unlockButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.unlockButton setTitle:@"Unlock" forState:UIControlStateNormal];
    [self.unlockButton addTarget:self action:@selector(unlockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.unlockButton setTitleColor:[UIColor uxsdk_selectedBlueColor] forState:UIControlStateNormal];
    self.unlockButton.backgroundColor = UIColor.clearColor;
    self.unlockButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    self.view.layer.cornerRadius = 8.0;
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.enterPasswordField];
    [self.view addSubview:self.formatAircraftButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.unlockButton];

    [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.08].active = YES;
    
    [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor].active = YES;
    [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.descriptionLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.45].active = YES;
    
    [self.enterPasswordField.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor].active = YES;
    [self.enterPasswordField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15.0].active = YES;
    [self.enterPasswordField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15.0].active = YES;
    [self.enterPasswordField.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
    
    [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.cancelButton.topAnchor constraintGreaterThanOrEqualToAnchor:self.enterPasswordField.bottomAnchor].active = YES;
    [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
    [self.cancelButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.33].active = YES;
    
    [self.unlockButton.leadingAnchor constraintEqualToAnchor:self.cancelButton.trailingAnchor].active = YES;
    [self.unlockButton.topAnchor constraintGreaterThanOrEqualToAnchor:self.enterPasswordField.bottomAnchor].active = YES;
    [self.unlockButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.unlockButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
    
    [self.formatAircraftButton.topAnchor constraintGreaterThanOrEqualToAnchor:self.enterPasswordField.bottomAnchor].active = YES;
    [self.formatAircraftButton.leadingAnchor constraintEqualToAnchor:self.unlockButton.trailingAnchor].active = YES;
    [self.formatAircraftButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.formatAircraftButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.formatAircraftButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
    [self.formatAircraftButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.33].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)unlockButtonPressed {
    weakSelf(target);
    [self.widgetModel loginToAccessLockerWithPassword:self.enterPasswordField.text andCompletion:^(NSError * _Nullable error) {
        if ([target.delegate respondsToSelector:@selector(unlockButtonPressedWithError:)]) {
            [target.delegate unlockButtonPressedWithError:error];
        }
    }];
}

- (void)cancelPressed {
    if ([self.delegate respondsToSelector:@selector(enterPasswordCancelButtonPressed)]) {
        [self.delegate enterPasswordCancelButtonPressed];
    }
}

- (void)formatButtonPressed {
    if ([self.delegate respondsToSelector:@selector(enterPasswordFormatButtonPressed)]) {
        [self.delegate enterPasswordFormatButtonPressed];
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

- (void)setFormatAircraftButtonTextColor:(UIColor *)formatAircraftButtonTextColor {
    _formatAircraftButtonTextColor = formatAircraftButtonTextColor;
    [_formatAircraftButton setTitleColor:formatAircraftButtonTextColor forState:UIControlStateNormal];
}

- (void)setFormatAircraftButtonFont:(UIFont *)formatAircraftButtonFont {
    _formatAircraftButtonFont = formatAircraftButtonFont;
    _formatAircraftButton.titleLabel.font = formatAircraftButtonFont;
}

- (void)setCancelButtonTextColor:(UIColor *)cancelButtonTextColor {
    _cancelButtonTextColor = cancelButtonTextColor;
    [_cancelButton setTitleColor:cancelButtonTextColor forState:UIControlStateNormal];
}

- (void)setCancelButtonFont:(UIFont *)cancelButtonFont {
    _cancelButtonFont = cancelButtonFont;
    _cancelButton.titleLabel.font = cancelButtonFont;
}

- (void)setUnlockButtonTextColor:(UIColor *)unlockButtonTextColor {
    _unlockButtonTextColor = unlockButtonTextColor;
    [_unlockButton setTitleColor:unlockButtonTextColor forState:UIControlStateNormal];
}

- (void)setUnlockButtonFont:(UIFont *)unlockButtonFont {
    _unlockButtonFont = unlockButtonFont;
    _unlockButton.titleLabel.font = unlockButtonFont;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
