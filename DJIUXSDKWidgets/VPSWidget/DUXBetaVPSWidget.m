//
//  DUXBetaVPSWidget.m
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

#import "DUXBetaVPSWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
@import DJIUXSDKCore;

static CGSize const kDesignSize = {90.0, 15.0};
static const CGFloat kLabelFontSize = 10.0;
static const CGFloat kValueFontSize = 14.0;

@interface DUXBetaVPSWidget ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *vpsImageView;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIImage *> *vpsImageMapping;

@end

@implementation DUXBetaVPSWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _disabledFontColor = [UIColor duxbeta_grayColor];
        _dangerFontColor = [UIColor duxbeta_dangerColor];
        _normalFontColor = [UIColor duxbeta_whiteColor];
        
        _vpsImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                             @(DUXBetaVPSStatusBeingUsed) : [UIImage duxbeta_imageWithAssetNamed:@"VPSEnabled"],
                                                                             @(DUXBetaVPSStatusEnabled) : [UIImage duxbeta_imageWithAssetNamed:@"VPSDisabled"],
                                                                             @(DUXBetaVPSStatusUnknown) : [UIImage duxbeta_imageWithAssetNamed:@"VPSDisabled"],
                                                                             }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaVPSWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), vpsStatus, vpsHeight);
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
    
    self.vpsImageView = [[UIImageView alloc] init];
    self.vpsImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.vpsImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.vpsImageView];

    self.label = [UILabel new];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.label];
    
    UILayoutGuide *space = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:space];

    [space.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:1].active = YES;
    [space.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.04].active = YES;
    [space.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [space.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self.vpsImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.vpsImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.vpsImageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.vpsImageView.rightAnchor constraintEqualToAnchor:space.leftAnchor].active = YES;
    [self.vpsImageView.heightAnchor constraintEqualToAnchor:self.vpsImageView.widthAnchor multiplier:1].active = YES;

    [self.label.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.label.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.label.leftAnchor constraintEqualToAnchor:space.rightAnchor].active = YES;
    [self.label.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
}

- (void)updateUI {
    [self.label setAttributedText: self.attributedLabelValue];
    self.vpsImageView.image = [self.vpsImageMapping objectForKey: @(self.widgetModel.vpsStatus)];
}

- (NSMutableAttributedString *)attributedLabelValue {
    if (self.widgetModel.vpsStatus == DUXBetaVPSStatusBeingUsed) {
        NSString *kPrefix = @"VPS";
        NSString *valueString = [NSString stringWithFormat:@"%0.1f", self.widgetModel.vpsHeight.doubleValue];
        NSString *kPostfix = self.widgetModel.vpsUnits.symbol;

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
        [labelString addAttribute:NSForegroundColorAttributeName value:self.normalFontColor range:prefixRange];
        [labelString addAttribute:NSFontAttributeName value:largeFont range:valueRange];
        
        UIColor *textColor = (self.widgetModel.vpsHeight.doubleValue < self.widgetModel.vpsDangerHeight.doubleValue) ? self.dangerFontColor : self.normalFontColor;
        [labelString addAttribute:NSForegroundColorAttributeName value:textColor range:valueRange];
        [labelString addAttribute:NSFontAttributeName value:smallFont range:postfixRange];
        [labelString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:postfixRange];
        
        return labelString;
    } else {
        NSMutableAttributedString *labelString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"N/A", @"Label when VPS feature is not enabled")];
        CGFloat fontSize = self.view.frame.size.width * (kValueFontSize / kDesignSize.width);
        
        UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
        
        NSRange range = NSMakeRange(0, labelString.length);
        [labelString addAttribute:NSFontAttributeName value:font range:range];
        [labelString addAttribute:NSForegroundColorAttributeName value:self.dangerFontColor range:range];
        
        return labelString;
    }
}

- (void)setImage:(UIImage *)image forVPSStatus:(DUXBetaVPSStatus)status {
    [self.vpsImageMapping setObject:image forKey:@(status)];
    [self updateUI];
}

- (UIImage *)imageForVPSStatus:(DUXBetaVPSStatus)status {
    return [self.vpsImageMapping objectForKey:@(status)];
}

- (void)setDangerFontColor:(UIColor *)dangerFontColor {
    _dangerFontColor = dangerFontColor;
    [self updateUI];
}

- (void)setNormalFontColor:(UIColor *)normalFontColor {
    _normalFontColor = normalFontColor;
    [self updateUI];
}

- (void)setDisabledFontColor:(UIColor *)disabledFontColor {
    _disabledFontColor = disabledFontColor;
    [self updateUI];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
