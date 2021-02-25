//
//  DUXBetaSpeakerVolumeView.m
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

#import "DUXBetaSpeakerVolumeView.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>


@interface DUXBetaSpeakerVolumeView ()

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UISlider* slider;
@property (nonatomic, strong) UILabel* detailLabel;
@property (nonatomic, strong) DUXBetaSpeakerMediaListSyncer *syncer;

@end

@implementation DUXBetaSpeakerVolumeView

- (instancetype)initWithFrame:(CGRect)frame andMediaSyncer:(DUXBetaSpeakerMediaListSyncer *)syncer {
    self = [super initWithFrame:frame];
    if (self) {
        _syncer = syncer;
        _titleLabelText = NSLocalizedString(@"Speaker Volume", @"Speaker Panel Speaker Volume Text");
        _titleLabelTextColor = [UIColor whiteColor];
        _titleLabelFont = [UIFont boldSystemFontOfSize:15.0f];
        
        _speakerVolumePercentageLabelTextColor = [UIColor whiteColor];
        _speakerVolumePercentageLabelFont = [UIFont boldSystemFontOfSize:12.0f];
        
        _slider = [[UISlider alloc] initWithFrame:CGRectZero];

        UIImage *whiteTrackImage = [UIImage duxbeta_imageWithAssetNamed:@"SliderWhiteTrack" forClass:[self class]];
        UIImage *blueTrackImage = [UIImage duxbeta_imageWithAssetNamed:@"SliderBlueTrack" forClass:[self class]];
        _minimumVolumeSliderTrackImage = [blueTrackImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        _maximumVolumeSliderTrackImage = [whiteTrackImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
        
        _volumeSliderThumbImage = [UIImage duxbeta_imageWithAssetNamed:@"SliderWhiteThumb" forClass:[self class]];
        
        _minimumVolumeSliderTintColor = _slider.minimumTrackTintColor;
        _maximumVolumeSliderTintColor = _slider.maximumTrackTintColor;
        _volumeSliderThumbTintColor = _slider.thumbTintColor;
        
        BindRKVOModel(syncer, @selector(updateSliderEndpoints),volumeRange);
        BindRKVOModel(syncer, @selector(updateSliderValue),volume);
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [[DUXBetaSpeakerVolumeView alloc] initWithFrame:frame andMediaSyncer:[[DUXBetaSpeakerMediaListSyncer alloc] init]];
    return self;
}

- (void)setupUI {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text = self.titleLabelText;
    self.titleLabel.textColor = self.titleLabelTextColor;
    self.titleLabel.font = self.titleLabelFont;
    [self addSubview:self.titleLabel];
    
    [self.slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventTouchUpOutside];
    [self.slider setThumbImage:self.volumeSliderThumbImage forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:self.minimumVolumeSliderTrackImage forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:self.maximumVolumeSliderTrackImage forState:UIControlStateNormal];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 100;
    [self addSubview:self.slider];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.textColor = self.speakerVolumePercentageLabelTextColor;
    self.detailLabel.font = self.speakerVolumePercentageLabelFont;
    self.detailLabel.text = @"0 %";
    [self addSubview:self.detailLabel];
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:0.3];
    [self addSubview:line];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    line.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [self.detailLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.detailLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.detailLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.detailLabel.widthAnchor constraintEqualToConstant:50].active = YES;
    
    [self.slider.leadingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor constant:10].active = YES;
    [self.slider.trailingAnchor constraintEqualToAnchor:self.detailLabel.leadingAnchor constant:-10].active = YES;
    [self.slider.heightAnchor constraintEqualToConstant:20].active = YES;
    [self.slider.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    [line.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [line.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [line.topAnchor constraintEqualToAnchor:self.bottomAnchor constant:-2].active = YES;
    [line.heightAnchor constraintEqualToConstant:1].active = YES;
}

- (void)updateSliderEndpoints {
    self.slider.minimumValue = self.syncer.volumeRange.min.floatValue;
    self.slider.maximumValue = self.syncer.volumeRange.max.floatValue;
}

- (void)updateSliderValue {
    self.slider.value = self.syncer.volume;
    self.detailLabel.text = [NSString stringWithFormat:@"%.f %@",self.slider.value,@"%"];
}

#pragma mark - Slider Actions

- (void)sliderChange:(UISlider *)slider {
    self.detailLabel.text = [NSString stringWithFormat:@"%.f %@",slider.value,@"%"];
    [self.syncer setSpeakerVolumePercentage:slider.value completion:^(NSError *error) {
        
    }];
}

#pragma mark - Setters

- (void)setTitleLabelText:(NSString *)titleLabelText {
    _titleLabelText = titleLabelText;
    self.titleLabel.text = titleLabelText;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor {
    _titleLabelTextColor = titleLabelTextColor;
    self.titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    self.titleLabel.font = titleLabelFont;
}

- (void)setSpeakerVolumePercentageLabelTextColor:(UIColor *)speakerVolumePercentageLabelTextColor {
    _speakerVolumePercentageLabelTextColor = speakerVolumePercentageLabelTextColor;
    self.detailLabel.textColor = speakerVolumePercentageLabelTextColor;
}

- (void)setSpeakerVolumePercentageLabelFont:(UIFont *)speakerVolumePercentageLabelFont {
    _speakerVolumePercentageLabelFont = speakerVolumePercentageLabelFont;
    self.detailLabel.font = speakerVolumePercentageLabelFont;
}

- (void)setMinimumVolumeSliderTrackImage:(UIImage *)minimumVolumeSliderTrackImage {
    _minimumVolumeSliderTrackImage = minimumVolumeSliderTrackImage;
    [self.slider setMinimumTrackImage:self.minimumVolumeSliderTrackImage forState:UIControlStateNormal];
}

- (void)setMaximumVolumeSliderImage:(UIImage *)maximumVolumeSliderTrackImage {
    _maximumVolumeSliderTrackImage = maximumVolumeSliderTrackImage;
    [self.slider setMaximumTrackImage:self.maximumVolumeSliderTrackImage forState:UIControlStateNormal];
}

- (void)setVolumeSliderThumbImage:(UIImage *)volumeSliderThumbImage {
    _volumeSliderThumbImage = volumeSliderThumbImage;
    [self.slider setThumbImage:self.volumeSliderThumbImage forState:UIControlStateNormal];
}

- (void)setMinimumVolumeSliderTintColor:(UIColor *)minimumVolumeSliderTintColor {
    _minimumVolumeSliderTintColor = minimumVolumeSliderTintColor;
    [self.slider setMinimumTrackImage:nil forState:UIControlStateNormal];
    self.slider.minimumTrackTintColor = minimumVolumeSliderTintColor;
}

- (void)setMaximumVolumeSliderTintColor:(UIColor *)maximumVolumeSliderTintColor {
    _maximumVolumeSliderTintColor = maximumVolumeSliderTintColor;
    [self.slider setMaximumTrackImage:nil forState:UIControlStateNormal];
    self.slider.maximumTrackTintColor = maximumVolumeSliderTintColor;
}

- (void)setVolumeSliderThumbTintColor:(UIColor *)volumeSliderThumbTintColor {
    _volumeSliderThumbTintColor = volumeSliderThumbTintColor;
    [self.slider setThumbImage:nil forState:UIControlStateNormal];
    self.slider.thumbTintColor = volumeSliderThumbTintColor;
}

@end
