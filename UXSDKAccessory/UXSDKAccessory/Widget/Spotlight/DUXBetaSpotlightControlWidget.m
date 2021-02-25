//
//  DUXBetaSpotlightControlWidget.m
//  UXSDKAccessory
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

#import "DUXBetaSpotlightControlWidget.h"

@import UXSDKCore;

static CGSize const kDesignSize = {375.0, 467.0};

@interface DUXBetaSpotlightControlWidget () <DUXBetaToolbarPanelSupportProtocol>

@property (strong, nonatomic) UILabel *spotlightControlWidgetHeaderLabel;

@property (strong, nonatomic) UILabel *spotlightSwitchLabel;
@property (strong, nonatomic) UISwitch *spotlightSwitch;

@property (strong, nonatomic) UISlider *brightnessSlider;
@property (strong, nonatomic) UILabel *brightnessPercentLabel;
@property (strong, nonatomic) UILabel *brightnessSliderLabel;
@property (strong, nonatomic) UILabel *brightnessDescriptionLabel;

@property (strong, nonatomic) UILabel *temperatureLabel;
@property (strong, nonatomic) UILabel *temperatureValueLabel;

@end

@implementation DUXBetaSpotlightControlWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _widgetHeaderText = @"Spotlight Settings";
        _spotlightSwitchLabelText = @"Spotlight";
        _brightnessLabelText = @"Brightness";
        _brightnessDescriptionText = @"To ease eye strain, max brightness is reduced to 50% when aircraft is not flying.";
        _temperatureLabelText = @"Temperature";
        
        _widgetHeaderLabelTextColor = [UIColor uxsdk_whiteColor];
        _spotlightSwitchLabelTextColor = [UIColor uxsdk_whiteColor];
        _brightnessLabelTextColor = [UIColor uxsdk_whiteColor];
        _brightnessDescriptionTextColor = [UIColor uxsdk_whiteColor];
        _temperatureLabelTextColor = [UIColor uxsdk_whiteColor];
        _brightnessPercentageTextColor = [UIColor uxsdk_whiteColor];
        _temperatureValueLabelTextColor = [UIColor uxsdk_whiteColor];
        
        _widgetHeaderLabelFont = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        _spotlightSwitchLabelFont = [UIFont systemFontOfSize:17];
        _brightnessLabelFont = [UIFont systemFontOfSize:17];
        _brightnessPercentageFont = [UIFont systemFontOfSize:17];
        _brightnessDescriptionFont = [UIFont systemFontOfSize:13];
        _temperatureLabelFont = [UIFont systemFontOfSize:17];
        _temperatureValueLabelFont = [UIFont systemFontOfSize:17];
        
        _spotlightSwitch = [[UISwitch alloc] init];
        _brightnessSlider = [[UISlider alloc] init];
        
        _spotlightSwitchOnTintColor = _spotlightSwitch.onTintColor;
        _spotlightSwitchTintColor = _spotlightSwitch.tintColor;
        _spotlightSwitchThumbTintColor = _spotlightSwitch.thumbTintColor;
        _spotlightSwitchOnImage = _spotlightSwitch.onImage;
        _spotlightSwitchOffImage = _spotlightSwitch.offImage;
        
        _brightnessSliderMinimumTrackTintColor = _brightnessSlider.minimumTrackTintColor;
        _brightnessSliderMaximumTrackTintColor = _brightnessSlider.maximumTrackTintColor;
        _brightnessSliderThumbTintColor = _brightnessSlider.thumbTintColor;
        _brightnessSliderMinimumValueImage = _brightnessSlider.minimumValueImage;
        _brightnessSliderMaximumValueImage = _brightnessSlider.maximumValueImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaSpotlightControlWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateEnabled), isEnabled);
    BindRKVOModel(self.widgetModel, @selector(updateBrightnessRange),maxBrightness, minBrightness);
    BindRKVOModel(self.widgetModel, @selector(updateBrightnessValue),brightness);
    BindRKVOModel(self.widgetModel, @selector(updateTemperatureLabel), temperature);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor uxsdk_blackColor];
    
    self.spotlightControlWidgetHeaderLabel = [[UILabel alloc] init];
    self.spotlightControlWidgetHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.spotlightControlWidgetHeaderLabel.adjustsFontSizeToFitWidth = YES;
    self.spotlightControlWidgetHeaderLabel.textColor = self.widgetHeaderLabelTextColor;
    self.spotlightControlWidgetHeaderLabel.font = self.widgetHeaderLabelFont;
    [self.view addSubview:self.spotlightControlWidgetHeaderLabel];
    
    self.spotlightSwitchLabel = [[UILabel alloc] init];
    self.spotlightSwitchLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.spotlightSwitchLabel.adjustsFontSizeToFitWidth = YES;
    self.spotlightSwitchLabel.textColor = self.spotlightSwitchLabelTextColor;
    self.spotlightSwitchLabel.font = self.spotlightSwitchLabelFont;
    [self.view addSubview:self.spotlightSwitchLabel];
    
    self.spotlightSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.spotlightSwitch addTarget:self action:@selector(spotlightSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.spotlightSwitch];
    
    self.brightnessSliderLabel = [[UILabel alloc] init];
    self.brightnessSliderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.brightnessSliderLabel.adjustsFontSizeToFitWidth = YES;
    self.brightnessSliderLabel.textColor = self.brightnessLabelTextColor;
    self.brightnessSliderLabel.font = self.brightnessLabelFont;
    [self.view addSubview:self.brightnessSliderLabel];
    
    self.brightnessSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.brightnessSlider.continuous = YES;
    [self.brightnessSlider addTarget:self action:@selector(brightnessSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.brightnessSlider];
    
    self.brightnessPercentLabel = [[UILabel alloc] init];
    self.brightnessPercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.brightnessPercentLabel.adjustsFontSizeToFitWidth = YES;
    self.brightnessPercentLabel.textColor = self.brightnessPercentageTextColor;
    self.brightnessPercentLabel.font = self.brightnessPercentageFont;
    [self.view addSubview:self.brightnessPercentLabel];
    
    self.brightnessDescriptionLabel = [[UILabel alloc] init];
    self.brightnessDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.brightnessDescriptionLabel.numberOfLines = 0;
    self.brightnessDescriptionLabel.textColor = self.brightnessDescriptionTextColor;
    self.brightnessDescriptionLabel.font = self.brightnessDescriptionFont;
    [self.view addSubview:self.brightnessDescriptionLabel];
    
    self.temperatureLabel = [[UILabel alloc] init];
    self.temperatureLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.temperatureLabel.adjustsFontSizeToFitWidth = YES;
    self.temperatureLabel.textColor = self.temperatureLabelTextColor;
    self.temperatureLabel.font = self.temperatureLabelFont;
    [self.view addSubview:self.temperatureLabel];
    
    self.temperatureValueLabel = [[UILabel alloc] init];
    self.temperatureValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.temperatureValueLabel.adjustsFontSizeToFitWidth = YES;
    self.temperatureValueLabel.textColor = self.temperatureValueLabelTextColor;
    self.temperatureValueLabel.font = self.temperatureValueLabelFont;
    [self.view addSubview:self.temperatureValueLabel];
    
    self.spotlightControlWidgetHeaderLabel.text = self.widgetHeaderText;
    self.spotlightSwitchLabel.text = self.spotlightSwitchLabelText;
    self.brightnessSliderLabel.text = self.brightnessLabelText;
    self.brightnessDescriptionLabel.text = self.brightnessDescriptionText;
    self.temperatureLabel.text = self.temperatureLabelText;
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.spotlightControlWidgetHeaderLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.spotlightControlWidgetHeaderLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10].active = YES;
    [self.spotlightSwitchLabel.topAnchor constraintEqualToAnchor: self.spotlightControlWidgetHeaderLabel.bottomAnchor constant:25].active = YES;
    [self.spotlightSwitchLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:28].active = YES;
    [self.spotlightSwitchLabel.centerYAnchor constraintEqualToAnchor:self.spotlightSwitch.centerYAnchor].active = YES;
    [self.spotlightSwitch.topAnchor constraintEqualToAnchor:self.spotlightControlWidgetHeaderLabel.bottomAnchor constant:25].active = YES;
    [self.spotlightSwitch.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant: -40].active = YES;
    [self.spotlightSwitch.widthAnchor constraintEqualToConstant:55].active = YES;
    [self.spotlightSwitch.heightAnchor constraintEqualToConstant:31].active = YES;
    [self.brightnessSliderLabel.topAnchor constraintEqualToAnchor:self.spotlightSwitchLabel.bottomAnchor constant:31].active = YES;
    [self.brightnessSliderLabel.leadingAnchor constraintEqualToAnchor:self.spotlightSwitchLabel.leadingAnchor].active = YES;
    [self.brightnessSlider.centerYAnchor constraintEqualToAnchor:self.brightnessSliderLabel.centerYAnchor].active = YES;
    [self.brightnessSlider.leadingAnchor constraintEqualToAnchor:self.brightnessSliderLabel.trailingAnchor constant:8.0].active = YES;
    [self.brightnessPercentLabel.leadingAnchor constraintEqualToAnchor:self.brightnessSlider.trailingAnchor constant:8.0].active = YES;
    [self.brightnessPercentLabel.centerYAnchor constraintEqualToAnchor:self.brightnessSliderLabel.centerYAnchor].active = YES;
    [self.brightnessPercentLabel.trailingAnchor constraintEqualToAnchor:self.spotlightSwitch.trailingAnchor].active = YES;
    [self.brightnessDescriptionLabel.leadingAnchor constraintEqualToAnchor:self.brightnessSliderLabel.leadingAnchor].active = YES;
    [self.brightnessDescriptionLabel.trailingAnchor constraintEqualToAnchor:self.brightnessPercentLabel.trailingAnchor].active = YES;
    [self.brightnessDescriptionLabel.topAnchor constraintEqualToAnchor:self.brightnessSliderLabel.bottomAnchor constant:30].active = YES;
    [self.temperatureLabel.topAnchor constraintEqualToAnchor:self.brightnessDescriptionLabel.bottomAnchor constant:22].active = YES;
    [self.temperatureLabel.leadingAnchor constraintEqualToAnchor:self.brightnessDescriptionLabel.leadingAnchor].active = YES;
    [self.temperatureLabel.centerYAnchor constraintEqualToAnchor:self.temperatureValueLabel.centerYAnchor].active = YES;
    [self.temperatureValueLabel.trailingAnchor constraintEqualToAnchor:self.brightnessDescriptionLabel.trailingAnchor].active = YES;
}

- (void)spotlightSwitchChanged {
    weakSelf(target);
    [self.widgetModel updateSpotlightEnabled:self.spotlightSwitch.isOn withCompletionBlock:^(NSError * _Nullable error) {
        if (error) {
            target.spotlightSwitch.on = !target.spotlightSwitch.isOn;
        }
    }];
}

- (void)brightnessSliderValueChanged:(UISlider *)sender {
    weakSelf(target);
    [self.widgetModel updateBrightness:sender.value withCompletionBlock:^(NSError * _Nullable error) {
        target.brightnessSlider.value = target.widgetModel.brightness;
    }];
}

- (void)updateEnabled {
    self.spotlightSwitch.on = self.widgetModel.isEnabled;
}

- (void)updateBrightnessRange {
    self.brightnessSlider.minimumValue = self.widgetModel.minBrightness;
    self.brightnessSlider.maximumValue = self.widgetModel.maxBrightness;
    self.brightnessSlider.value = self.widgetModel.brightness;
}

- (void)updateBrightnessValue {
    self.brightnessPercentLabel.text = [NSString stringWithFormat:@"%lu%%",(unsigned long)self.widgetModel.brightness];
    self.brightnessSlider.value = self.widgetModel.brightness;
}

- (void)updateTemperatureLabel {
    NSString *valueString= [NSString stringWithFormat:@"%.0f",self.widgetModel.temperature.doubleValue];
    NSString *kPostfix = self.widgetModel.temperatureUnits.symbol;
    self.temperatureValueLabel.text = [NSString stringWithFormat:@"%@%@", valueString, kPostfix];
}

- (void)setSpotlightSwitchOnTintColor:(UIColor *)spotlightSwitchOnTintColor {
    _spotlightSwitchOnTintColor = spotlightSwitchOnTintColor;
    _spotlightSwitch.onTintColor = spotlightSwitchOnTintColor;
}

- (void)setSpotlightSwitchTintColor:(UIColor *)spotlightSwitchTintColor {
    _spotlightSwitchTintColor = spotlightSwitchTintColor;
    _spotlightSwitch.tintColor = spotlightSwitchTintColor;
}

- (void)setSpotlightSwitchThumbTintColor:(UIColor *)spotlightSwitchThumbTintColor {
    _spotlightSwitchThumbTintColor = spotlightSwitchThumbTintColor;
    _spotlightSwitch.thumbTintColor = spotlightSwitchThumbTintColor;
}

- (void)setSpotlightSwitchOnImage:(UIImage *)spotlightSwitchOnImage {
    _spotlightSwitchOnImage = spotlightSwitchOnImage;
    _spotlightSwitch.onImage = spotlightSwitchOnImage;
}

- (void)setSpotlightSwitchOffImage:(UIImage *)spotlightSwitchOffImage {
    _spotlightSwitchOffImage = spotlightSwitchOffImage;
    _spotlightSwitch.offImage = spotlightSwitchOffImage;
}

- (void)setBrightnessSliderMinimumTrackTintColor:(UIColor *)brightnessSliderMinimumTrackTintColor {
    _brightnessSliderMinimumTrackTintColor = brightnessSliderMinimumTrackTintColor;
    _brightnessSlider.minimumTrackTintColor = brightnessSliderMinimumTrackTintColor;
}

- (void)setBrightnessSliderMaximumTrackTintColor:(UIColor *)brightnessSliderMaximumTrackTintColor {
    _brightnessSliderMaximumTrackTintColor = brightnessSliderMaximumTrackTintColor;
    _brightnessSlider.maximumTrackTintColor = brightnessSliderMaximumTrackTintColor;
}

- (void)setBrightnessSliderThumbTintColor:(UIColor *)brightnessSliderThumbTintColor {
    _brightnessSliderThumbTintColor = brightnessSliderThumbTintColor;
    _brightnessSlider.thumbTintColor = brightnessSliderThumbTintColor;
}

- (void)setBrightnessSliderMinimumValueImage:(UIImage *)brightnessSliderMinimumValueImage {
    _brightnessSliderMinimumValueImage = brightnessSliderMinimumValueImage;
    _brightnessSlider.minimumValueImage = brightnessSliderMinimumValueImage;
}

- (void)setBrightnessSliderMaximumValueImage:(UIImage *)brightnessSliderMaximumValueImage {
    _brightnessSliderMaximumValueImage = brightnessSliderMaximumValueImage;
    _brightnessSlider.maximumValueImage = brightnessSliderMaximumValueImage;
}

- (void)setWidgetHeaderText:(NSString *)widgetHeaderText {
    _widgetHeaderText = widgetHeaderText;
    _spotlightControlWidgetHeaderLabel.text = widgetHeaderText;
}

- (void)setWidgetHeaderLabelTextColor:(UIColor *)widgetHeaderLabelTextColor {
    _widgetHeaderLabelTextColor = widgetHeaderLabelTextColor;
    _spotlightControlWidgetHeaderLabel.textColor = widgetHeaderLabelTextColor;
}

- (void)setWidgetHeaderLabelFont:(UIFont *)widgetHeaderLabelFont {
    _widgetHeaderLabelFont = widgetHeaderLabelFont;
    _spotlightControlWidgetHeaderLabel.font = widgetHeaderLabelFont;
}

- (void)setSpotlightSwitchLabelText:(NSString *)spotlightSwitchLabelText {
    _spotlightSwitchLabelText = spotlightSwitchLabelText;
    _spotlightSwitchLabel.text = spotlightSwitchLabelText;
}

- (void)setSpotlightSwitchLabelTextColor:(UIColor *)spotlightSwitchLabelTextColor {
    _spotlightSwitchLabelTextColor = spotlightSwitchLabelTextColor;
    _spotlightSwitchLabel.textColor = spotlightSwitchLabelTextColor;
}

- (void)setSpotlightSwitchLabelFont:(UIFont *)spotlightSwitchLabelFont {
    _spotlightSwitchLabelFont = spotlightSwitchLabelFont;
    _spotlightSwitchLabel.font = spotlightSwitchLabelFont;
}

- (void)setBrightnessLabelText:(NSString *)brightnessLabelText {
    _brightnessLabelText = brightnessLabelText;
    _brightnessSliderLabel.text = brightnessLabelText;
}

- (void)setBrightnessLabelTextColor:(UIColor *)brightnessLabelTextColor {
    _brightnessLabelTextColor = brightnessLabelTextColor;
    _brightnessSliderLabel.textColor = brightnessLabelTextColor;
}

- (void)setBrightnessLabelFont:(UIFont *)brightnessLabelFont {
    _brightnessLabelFont = brightnessLabelFont;
    _brightnessSliderLabel.font = brightnessLabelFont;
}

- (void)setBrightnessPercentageTextColor:(UIColor *)brightnessPercentageTextColor {
    _brightnessPercentageTextColor = brightnessPercentageTextColor;
    _brightnessPercentLabel.textColor = brightnessPercentageTextColor;
}

- (void)setBrightnessPercentageFont:(UIFont *)brightnessPercentageFont {
    _brightnessPercentageFont = brightnessPercentageFont;
    _brightnessPercentLabel.font = brightnessPercentageFont;
}

- (void)setBrightnessDescriptionText:(NSString *)brightnessDescriptionText {
    _brightnessDescriptionText = brightnessDescriptionText;
    _brightnessDescriptionLabel.text = brightnessDescriptionText;
    [_brightnessDescriptionLabel sizeToFit];
}

- (void)setBrightnessDescriptionTextColor:(UIColor *)brightnessDescriptionTextColor {
    _brightnessDescriptionTextColor = brightnessDescriptionTextColor;
    _brightnessDescriptionLabel.textColor = brightnessDescriptionTextColor;
}

- (void)setBrightnessDescriptionFont:(UIFont *)brightnessDescriptionFont {
    _brightnessDescriptionFont = brightnessDescriptionFont;
    _brightnessDescriptionLabel.font = brightnessDescriptionFont;
    [_brightnessDescriptionLabel sizeToFit];
}

- (void)setTemperatureLabelText:(NSString *)temperatureLabelText {
    _temperatureLabelText = temperatureLabelText;
    _temperatureLabel.text = temperatureLabelText;
}

- (void)setTemperatureLabelTextColor:(UIColor *)temperatureLabelTextColor {
    _temperatureLabelTextColor = temperatureLabelTextColor;
    _temperatureLabel.textColor = temperatureLabelTextColor;
}

- (void)setTemperatureLabelFont:(UIFont *)temperatureLabelFont {
    _temperatureLabelFont = temperatureLabelFont;
    _temperatureLabel.font = temperatureLabelFont;
}

- (void)setTemperatureValueLabelTextColor:(UIColor *)temperatureValueLabelTextColor {
    _temperatureValueLabelTextColor = temperatureValueLabelTextColor;
    _temperatureValueLabel.textColor = temperatureValueLabelTextColor;
}

- (void)setTemperatureValueLabelFont:(UIFont *)temperatureValueLabelFont {
    _temperatureValueLabelFont = temperatureValueLabelFont;
    _temperatureValueLabel.font = temperatureValueLabelFont;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

- (NSString * _Nullable) toolbarItemTitle {
    return @"Spotlight";
}
//- (UIImage * _Nullable) toolbarItemIcon {
//    return [UIImage duxbeta_imageWithAssetNamed:@"beacon_active" forClass:[self class]];
//}

@end
