//
//  DUXBetaAccessLockerFormatAircraftWidget.m
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

#import "DUXBetaAccessLockerFormatAircraftWidget.h"
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static CGSize const kDesignSize = {400.0, 120.0};
@interface DUXBetaAccessLockerFormatAircraftWidget ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *formatButton;

@end

@implementation DUXBetaAccessLockerFormatAircraftWidget

- (instancetype)initWithWidgetModel:(DUXBetaAccessLockerControlWidgetModel *)widgetModel {
    self = [super init];
    if (self) {
        _widgetModel = widgetModel;
        [self createUI];
        _titleLabelTextColor = _titleLabel.textColor;
        _titleLabelFont = _titleLabel.font;
        
        _descriptionLabelColor = _descriptionLabel.textColor;
        _descriptionLabelFont = _descriptionLabel.font;
        
        _cancelButtonTextColor = _cancelButton.titleLabel.textColor;
        _cancelButtonFont = _cancelButton.titleLabel.font;
        
        _formatButtonTextColor = _formatButton.titleLabel.textColor;
        _formatButtonFont = _formatButton.titleLabel.font;
    }
    return self;
}

- (void)createUI {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.text = @"Format Aircraft";
    [self.titleLabel sizeToFit];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.text = @"Formatting the aircraft will delete all data in its storage.  Are you sure you want to format the aircraft?";
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.textColor = UIColor.whiteColor;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitleColor:[UIColor uxsdk_selectedBlueColor] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = UIColor.clearColor;
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] weight:UIFontWeightLight];
    
    self.formatButton = [[UIButton alloc] init];
    self.formatButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.formatButton setTitle:@"Format" forState:UIControlStateNormal];
    [self.formatButton addTarget:self action:@selector(formatAircraftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.formatButton setTitleColor:[UIColor uxsdk_errorDangerColor] forState:UIControlStateNormal];
    self.formatButton.backgroundColor = UIColor.clearColor;
    self.formatButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    self.view.layer.cornerRadius = 8.0;
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.descriptionLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.formatButton];

    [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.20].active = YES;
    
    [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor].active = YES;
    [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.descriptionLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.60].active = YES;
    
    [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor].active = YES;
    [self.cancelButton.trailingAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.20].active = YES;
    
    [self.formatButton.leadingAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.formatButton.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor].active = YES;
    [self.formatButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.formatButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.formatButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.20].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)cancelButtonPressed {
    if ([self.delegate respondsToSelector:@selector(formatAircraftCancelButtonPressed)]) {
        [self.delegate formatAircraftCancelButtonPressed];
    }
}

- (void)formatAircraftButtonPressed {
    weakSelf(target);
    [self.widgetModel formatAircraftWithCompletion:^(NSError * _Nullable error) {
        if ([target.delegate respondsToSelector:@selector(formatAircraftButtonPressedWithError:)]) {
            [target.delegate formatAircraftButtonPressedWithError:error];
        }
    }];
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

- (void)setCancelButtonTextColor:(UIColor *)cancelButtonTextColor {
    _cancelButtonTextColor = cancelButtonTextColor;
    [_cancelButton setTitleColor:cancelButtonTextColor forState:UIControlStateNormal];
}

- (void)setCancelButtonFont:(UIFont *)cancelButtonFont {
    _cancelButtonFont = cancelButtonFont;
    _cancelButton.titleLabel.font = cancelButtonFont;
}

- (void)setFormatButtonTextColor:(UIColor *)formatButtonTextColor {
    _formatButtonTextColor = formatButtonTextColor;
    [_formatButton setTitleColor:formatButtonTextColor forState:UIControlStateNormal];
}

- (void)setFormatButtonFont:(UIFont *)formatButtonFont {
    _formatButtonFont = formatButtonFont;
    _formatButton.titleLabel.font = formatButtonFont;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
