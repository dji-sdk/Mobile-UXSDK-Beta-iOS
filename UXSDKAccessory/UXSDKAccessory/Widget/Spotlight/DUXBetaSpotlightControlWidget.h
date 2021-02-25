//
//  DUXBetaSpotlightControlWidget.h
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

#import <UXSDKCore/DUXBetaBaseWidget.h>
#import "DUXBetaSpotlightControlWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaSpotlightControlWidget : DUXBetaBaseWidget

//Control Customization
@property (strong, nonatomic) UIColor *spotlightSwitchOnTintColor;
@property (strong, nonatomic) UIColor *spotlightSwitchTintColor;
@property (strong, nonatomic) UIColor *spotlightSwitchThumbTintColor;
@property (strong, nonatomic) UIImage *spotlightSwitchOnImage;
@property (strong, nonatomic) UIImage *spotlightSwitchOffImage;

@property (strong, nonatomic) UIColor *brightnessSliderMinimumTrackTintColor;
@property (strong, nonatomic) UIColor *brightnessSliderMaximumTrackTintColor;
@property (strong, nonatomic) UIColor *brightnessSliderThumbTintColor;
@property (strong, nonatomic) UIImage *brightnessSliderMinimumValueImage;
@property (strong, nonatomic) UIImage *brightnessSliderMaximumValueImage;

//Text Customization
@property (strong, nonatomic) NSString *widgetHeaderText;
@property (strong, nonatomic) UIColor *widgetHeaderLabelTextColor;
@property (strong, nonatomic) UIFont *widgetHeaderLabelFont;

@property (strong, nonatomic) NSString *spotlightSwitchLabelText;
@property (strong, nonatomic) UIColor *spotlightSwitchLabelTextColor;
@property (strong, nonatomic) UIFont *spotlightSwitchLabelFont;

@property (strong, nonatomic) NSString *brightnessLabelText;
@property (strong, nonatomic) UIColor *brightnessLabelTextColor;
@property (strong, nonatomic) UIFont *brightnessLabelFont;

@property (strong, nonatomic) UIColor *brightnessPercentageTextColor;
@property (strong, nonatomic) UIFont *brightnessPercentageFont;

@property (strong, nonatomic) NSString *brightnessDescriptionText;
@property (strong, nonatomic) UIColor *brightnessDescriptionTextColor;
@property (strong, nonatomic) UIFont *brightnessDescriptionFont;

@property (strong, nonatomic) NSString *temperatureLabelText;
@property (strong, nonatomic) UIColor *temperatureLabelTextColor;
@property (strong, nonatomic) UIFont *temperatureLabelFont;

@property (strong, nonatomic) UIColor *temperatureValueLabelTextColor;
@property (strong, nonatomic) UIFont *temperatureValueLabelFont;

@property (strong, nonatomic) DUXBetaSpotlightControlWidgetModel *widgetModel;

@end

NS_ASSUME_NONNULL_END
