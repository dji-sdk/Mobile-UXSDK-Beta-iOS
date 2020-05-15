//
//  DUXBetaVerticalVelocityWidget.m
//  DJIUXSDK
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

#import "DUXBetaVerticalVelocityWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
@import DJIUXSDKCore;

static CGSize const kDesignSize = {120.0, 15.0};
static const CGFloat kLabelFontSize = 10.0;
static const CGFloat kValueFontSize = 14.0;

@interface DUXBetaVerticalVelocityWidget ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation DUXBetaVerticalVelocityWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _lightFontColor = [UIColor duxbeta_whiteColor];
        _darkFontColor = [UIColor duxbeta_grayColor];
        self.upImage = [UIImage duxbeta_imageWithAssetNamed:@"UpArrow"];
        self.downImage = [UIImage duxbeta_imageWithAssetNamed:@"DownArrow"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel = [[DUXBetaVerticalVelocityWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), verticalVelocity);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.arrowImageView = [[UIImageView alloc] init];
    self.arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.arrowImageView];
    
    self.label = [UILabel new];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.label];
    
    UILayoutGuide *space = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:space];
    
    [space.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:1].active = YES;
    [space.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.04].active = YES;
    [space.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [space.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self.arrowImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.arrowImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.arrowImageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.arrowImageView.rightAnchor constraintEqualToAnchor:space.leftAnchor].active = YES;
    [self.arrowImageView.heightAnchor constraintEqualToAnchor:self.arrowImageView.widthAnchor multiplier:1].active = YES;
    
    [self.label.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.label.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.label.leftAnchor constraintEqualToAnchor:space.rightAnchor].active = YES;
    [self.label.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
}

- (void)updateUI {
    [self.label setAttributedText: self.attributedLabelValue];
    self.arrowImageView.image = [self currentIndicator];
}

- (UIImage *)currentIndicator {
    if (self.widgetModel.verticalVelocity.doubleValue == 0) { return nil; }
    return self.widgetModel.verticalVelocity.doubleValue > 0 ? self.upImage : self.downImage;
}

- (NSMutableAttributedString *)attributedLabelValue {
    NSString *kPrefix = @"V.S";
    NSString *valueString = [NSString stringWithFormat:@"%0.1f", fabs(self.widgetModel.verticalVelocity.doubleValue)];
    NSString *kPostfix = self.widgetModel.verticalVelocityUnits.symbol;
    NSString *basicString = [NSString stringWithFormat:@"%@ %@ %@", kPrefix, valueString, kPostfix];
    NSMutableAttributedString *labelString = [[NSMutableAttributedString alloc] initWithString:basicString];
    
    NSRange prefixRange = NSMakeRange(0, kPrefix.length);
    NSRange valueRange = NSMakeRange(kPrefix.length + 1, valueString.length);
    NSRange postfixRange = NSMakeRange(kPrefix.length + valueString.length + 2, kPostfix.length);
    
    CGFloat smallFontSize = kLabelFontSize * MIN(self.view.frame.size.width / kDesignSize.width, self.view.frame.size.height / kDesignSize.height);
    CGFloat largeFontSize = smallFontSize * (kValueFontSize / kLabelFontSize);
    
    UIFont *smallFont = [UIFont boldSystemFontOfSize:smallFontSize];
    UIFont *largeFont = [UIFont boldSystemFontOfSize:largeFontSize];
    
    [labelString addAttribute:NSFontAttributeName value:smallFont range:prefixRange];
    [labelString addAttribute:NSForegroundColorAttributeName value:self.darkFontColor range:prefixRange];
    [labelString addAttribute:NSFontAttributeName value:largeFont range:valueRange];
    [labelString addAttribute:NSForegroundColorAttributeName value:self.lightFontColor range:valueRange];
    [labelString addAttribute:NSFontAttributeName value:smallFont range:postfixRange];
    [labelString addAttribute:NSForegroundColorAttributeName value:self.darkFontColor range:postfixRange];
    
    return labelString;
}

- (void)setUpImage:(UIImage *)upImage {
    _upImage = upImage;
    [self updateUI];
}

- (void)setDownImage:(UIImage *)downImage {
    _downImage = downImage;
    [self updateUI];
}

- (void)setLightFontColor:(UIColor *)lightFontColor {
    _lightFontColor = lightFontColor;
    [self updateUI];
}

- (void)setDarkFontColor:(UIColor *)darkFontColor {
    _darkFontColor = darkFontColor;
    [self updateUI];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
