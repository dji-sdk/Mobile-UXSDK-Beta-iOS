//
//  DUXBetaFocusModeWidget.m
//  UXSDKCameraCore
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

#import "DUXBetaFocusModeWidget.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIFont+DUXBetaFonts.h>


static const CGSize kDesignSize = {35.0, 35.0};
static const CGFloat kDesignBorderThickness = 0.5;
static const CGFloat kDesignLabelFontSize = 10.0;

@interface DUXBetaFocusModeWidget ()

@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UILabel *label;

@end

@implementation DUXBetaFocusModeWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _normalFontColor = [UIColor whiteColor];
        _activeFontColor = [UIColor colorWithRed:10.0/255.0 green:238.0/255.0 blue:139.0/255.0 alpha:1.0];
        _labelFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaFocusModeWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), isSupported, focusMode);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    
    self.view.layer.borderColor = self.borderColor.CGColor;
    self.view.layer.borderWidth = kDesignBorderThickness * self.view.frame.size.height / kDesignSize.height;
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.1;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label = label;
    [self.view addSubview:label];
    
    [label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:2].active = YES;
    [label.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-2].active = YES;
    [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.layer.borderWidth = kDesignBorderThickness * self.view.frame.size.height / kDesignSize.height;
    self.label.attributedText = [self attributedLabel];
    [self setupFonts];
}

- (NSString *)rightHandLabelText {
    return NSLocalizedString(@"MF", "Focus widget option value");
}

// TODO: Add check for isAFCEnabled through camera settings panel when implemented
- (NSString *)leftHandLabelText {
    if (self.widgetModel.isAFCSupportedOnAircraft) {
        return NSLocalizedString(@"AFC", "Focus widget option value");
    } else {
        return NSLocalizedString(@"AF", "Focus widget option value");
    }
}

- (NSAttributedString *)attributedLabel {
    NSString *fullString = [NSString stringWithFormat:@"%@/%@", [self leftHandLabelText], [self rightHandLabelText]];
    NSRange fullRange = NSMakeRange(0, fullString.length);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullString];
    
    NSUInteger leftHandLabelTextLength = [self leftHandLabelText].length;
    NSUInteger rightHandLabelTextLength = [self rightHandLabelText].length;
    NSRange afRange = NSMakeRange(0, leftHandLabelTextLength);
    NSRange mfRange = NSMakeRange(leftHandLabelTextLength+1, rightHandLabelTextLength);
    NSRange slashRange = NSMakeRange(leftHandLabelTextLength, 1);
    
    [attributedString addAttribute:NSFontAttributeName value:self.labelFont range:fullRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.normalFontColor range:slashRange];
    
    if (self.widgetModel.focusMode == DJICameraFocusModeManual) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.normalFontColor range:afRange];
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.activeFontColor range:mfRange];
    } else if (self.widgetModel.focusMode == DJICameraFocusModeAuto || self.widgetModel.focusMode == DJICameraFocusModeAFC) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.normalFontColor range:mfRange];
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.activeFontColor range:afRange];
    } else {
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.normalFontColor range:fullRange];
    }

    return attributedString;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    __weak typeof(self) weakSelf = self;
    [weakSelf.widgetModel switchFocusMode:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)updateUI {
    [self.label setAttributedText: self.attributedLabel];
}

- (void)setupFonts {
    CGFloat adjustedSize =  kDesignLabelFontSize / kDesignSize.width * self.view.frame.size.width;
    self.labelFont = [UIFont systemFontOfSize:adjustedSize];
}

- (void)setNormalFontColor:(UIColor *)normalFontColor {
    _normalFontColor = normalFontColor;
    [self updateUI];
}

- (void)setActiveFontColor:(UIColor *)activeFontColor {
    _activeFontColor = activeFontColor;
    [self updateUI];
}

- (void)setLabelFont:(UIFont *)labelFont {
    _labelFont = labelFont;
    [self updateUI];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
