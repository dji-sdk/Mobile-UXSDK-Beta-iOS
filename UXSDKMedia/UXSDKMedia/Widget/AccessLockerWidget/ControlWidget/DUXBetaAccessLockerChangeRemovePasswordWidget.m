//
//  DUXBetaAccessLockerChangeRemovePasswordWidget.m
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

#import "DUXBetaAccessLockerChangeRemovePasswordWidget.h"
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static CGSize const kDesignSize = {400.0, 170.0};

@interface DUXBetaAccessLockerChangeRemovePasswordWidget ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UIButton *changePasswordButton;
@property (nonatomic, strong) UIButton *removePasswordButton;

@end

@implementation DUXBetaAccessLockerChangeRemovePasswordWidget

- (instancetype)initWithWidgetModel:(DUXBetaAccessLockerControlWidgetModel *)widgetModel {
    self = [super init];
    if (self) {
        _widgetModel = widgetModel;
        [self createUI];
        _titleLabelTextColor = _titleLabel.textColor;
        _titleLabelFont = _titleLabel.font;
        
        _descriptionLabelColor = _descriptionLabel.textColor;
        _descriptionLabelFont = _descriptionLabel.font;
        
        _changePasswordButtonTextColor = _changePasswordButton.titleLabel.textColor;
        _changePasswordButtonFont = _changePasswordButton.titleLabel.font;
        
        _changePasswordButtonTextColor = _removePasswordButton.titleLabel.textColor;
        _changePasswordButtonFont = _removePasswordButton.titleLabel.font;
    }
    return self;
}

- (void)createUI {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.text = @"Change or Remove Password";
    [self.titleLabel sizeToFit];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.text = @"The current password is required in order to change or remove the password.";
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.textColor = UIColor.whiteColor;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    self.changePasswordButton = [[UIButton alloc] init];
    self.changePasswordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.changePasswordButton setTitle:@"Change Password" forState:UIControlStateNormal];
    [self.changePasswordButton addTarget:self action:@selector(changePasswordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.changePasswordButton setTitleColor:[UIColor uxsdk_selectedBlueColor] forState:UIControlStateNormal];
    self.changePasswordButton.backgroundColor = UIColor.clearColor;
    self.changePasswordButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    self.removePasswordButton = [[UIButton alloc] init];
    self.removePasswordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.removePasswordButton setTitle:@"Remove Password" forState:UIControlStateNormal];
    [self.removePasswordButton addTarget:self action:@selector(removePasswordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.removePasswordButton setTitleColor:[UIColor uxsdk_selectedBlueColor] forState:UIControlStateNormal];
    self.removePasswordButton.backgroundColor = UIColor.clearColor;
    self.removePasswordButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    self.view.layer.cornerRadius = 8.0;
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.descriptionLabel];
    [self.view addSubview:self.changePasswordButton];
    [self.view addSubview:self.removePasswordButton];
    
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.16].active = YES;
    
    [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor].active = YES;
    [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.descriptionLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.3].active = YES;
    
    [self.changePasswordButton.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor].active = YES;
    [self.changePasswordButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.changePasswordButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.changePasswordButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.3].active = YES;
    
    [self.removePasswordButton.topAnchor constraintEqualToAnchor:self.changePasswordButton.bottomAnchor].active = YES;
    [self.removePasswordButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.removePasswordButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.removePasswordButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.3].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)changePasswordButtonPressed {
    if ([self.delegate respondsToSelector:@selector(changePasswordButtonPressed)]) {
        [self.delegate changePasswordButtonPressed];
    }
}

- (void)removePasswordButtonPressed {
    if ([self.delegate respondsToSelector:@selector(removePasswordButtonPressed)]) {
        [self.delegate removePasswordButtonPressed];
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

- (void)setChangePasswordButtonTextColor:(UIColor *)changePasswordButtonTextColor {
    _changePasswordButtonTextColor = changePasswordButtonTextColor;
    [_changePasswordButton setTitleColor:changePasswordButtonTextColor forState:UIControlStateNormal];
}

- (void)setChangePasswordButtonFont:(UIFont *)changePasswordButtonFont {
    _changePasswordButtonFont = changePasswordButtonFont;
    _changePasswordButton.titleLabel.font = changePasswordButtonFont;
}

- (void)setRemovePasswordButtonTextColor:(UIColor *)removePasswordButtonTextColor {
    _removePasswordButtonTextColor = removePasswordButtonTextColor;
    [_removePasswordButton setTitleColor:removePasswordButtonTextColor forState:UIControlStateNormal];
}

- (void)setRemovePasswordButtonFont:(UIFont *)removePasswordButtonFont {
    _removePasswordButtonFont = removePasswordButtonFont;
    _removePasswordButton.titleLabel.font = removePasswordButtonFont;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
