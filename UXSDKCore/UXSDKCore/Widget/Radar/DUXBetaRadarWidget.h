//
//  DUXBetaRadarWidget.h
//  UXSDKCore
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
#import "DUXBetaRadarWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * Constants to use as keys for defining the customized radar widget images. The name format is:
 * BaseConstant_<Slice0..N>_<WarningLevel>
 * Forward radar has 4 slices, rear radar 4 slices, and left and right 2 slices each for most aircraft.
 * The lowest warnng level (0) indicates no detected obstacle. The distance is aircraft dependant.
 * Images which are not defined will use the standard RadarWidget images
 */

extern NSString* const DUXRadarWidgetForward_0_disabled;
extern NSString* const DUXRadarWidgetForward_0_0;
extern NSString* const DUXRadarWidgetForward_0_1;
extern NSString* const DUXRadarWidgetForward_0_2;
extern NSString* const DUXRadarWidgetForward_0_3;
extern NSString* const DUXRadarWidgetForward_0_4;
extern NSString* const DUXRadarWidgetForward_0_5;
extern NSString* const DUXRadarWidgetForward_1_disabled;
extern NSString* const DUXRadarWidgetForward_1_0;
extern NSString* const DUXRadarWidgetForward_1_1;
extern NSString* const DUXRadarWidgetForward_1_2;
extern NSString* const DUXRadarWidgetForward_1_3;
extern NSString* const DUXRadarWidgetForward_1_4;
extern NSString* const DUXRadarWidgetForward_1_5;
extern NSString* const DUXRadarWidgetForward_2_disabled;
extern NSString* const DUXRadarWidgetForward_2_0;
extern NSString* const DUXRadarWidgetForward_2_1;
extern NSString* const DUXRadarWidgetForward_2_2;
extern NSString* const DUXRadarWidgetForward_2_3;
extern NSString* const DUXRadarWidgetForward_2_4;
extern NSString* const DUXRadarWidgetForward_2_5;
extern NSString* const DUXRadarWidgetForward_3_disabled;
extern NSString* const DUXRadarWidgetForward_3_0;
extern NSString* const DUXRadarWidgetForward_3_1;
extern NSString* const DUXRadarWidgetForward_3_2;
extern NSString* const DUXRadarWidgetForward_3_3;
extern NSString* const DUXRadarWidgetForward_3_4;
extern NSString* const DUXRadarWidgetForward_3_5;

extern NSString* const DUXRadarWidgetRear_0_disabled;
extern NSString* const DUXRadarWidgetRear_0_0;
extern NSString* const DUXRadarWidgetRear_0_1;
extern NSString* const DUXRadarWidgetRear_0_2;
extern NSString* const DUXRadarWidgetRear_0_3;
extern NSString* const DUXRadarWidgetRear_0_4;
extern NSString* const DUXRadarWidgetRear_0_5;
extern NSString* const DUXRadarWidgetRear_1_disabled;
extern NSString* const DUXRadarWidgetRear_1_0;
extern NSString* const DUXRadarWidgetRear_1_1;
extern NSString* const DUXRadarWidgetRear_1_2;
extern NSString* const DUXRadarWidgetRear_1_3;
extern NSString* const DUXRadarWidgetRear_1_4;
extern NSString* const DUXRadarWidgetRear_1_5;
extern NSString* const DUXRadarWidgetRear_2_disabled;
extern NSString* const DUXRadarWidgetRear_2_0;
extern NSString* const DUXRadarWidgetRear_2_1;
extern NSString* const DUXRadarWidgetRear_2_2;
extern NSString* const DUXRadarWidgetRear_2_3;
extern NSString* const DUXRadarWidgetRear_2_4;
extern NSString* const DUXRadarWidgetRear_2_5;
extern NSString* const DUXRadarWidgetRear_3_disabled;
extern NSString* const DUXRadarWidgetRear_3_0;
extern NSString* const DUXRadarWidgetRear_3_1;
extern NSString* const DUXRadarWidgetRear_3_2;
extern NSString* const DUXRadarWidgetRear_3_3;
extern NSString* const DUXRadarWidgetRear_3_4;
extern NSString* const DUXRadarWidgetRear_3_5;
;
extern NSString* const DUXRadarWidgetLeft_0_0;
extern NSString* const DUXRadarWidgetLeft_0_1;
extern NSString* const DUXRadarWidgetRight_1_0;
extern NSString* const DUXRadarWidgetRight_1_1;

extern NSString* const DUXRadarWidgetOverheadObstruction;
extern NSString* _Nonnull const DUXRadarWidgetArrow;


@interface DUXBetaRadarWidget : DUXBetaBaseWidget
@property (nonatomic, strong) DUXBetaRadarWidgetModel *widgetModel;
@property (nonatomic, readwrite) BOOL   enableRadarAlertSounds;
@property (nonatomic, strong) UIColor   *distanceTextColor;
@property (nonatomic, strong) UIColor   *distanceTextBackgroundColor;
@property (nonatomic, strong) UIFont    *distanceTextFont;
@property (nonatomic, strong) UIColor   *distanceArrowImageBackground;
@property (nonatomic, strong) UIColor   *upwardObstacleImageBackgroundColor;


#pragma mark - Customizations
- (void)setCustomRadarImages:(NSDictionary<NSString *,UIImage *> *)radarImages;
- (void)setDistanceArrowImageBackground:(UIColor *)arrowBackgroundColor;
- (void)setUpwardObstaclImageBackgroundColor:(UIColor *)upObstacleBackgroundColor;

- (void)setRadarWarningLevels:(NSArray *)warningLevels;
- (void)setDistanceTextColor:(UIColor *)color;
- (void)setDistanceTextBackgroundColor:(UIColor *)textBackgroundColor;
- (void)setDistanceTextFont:(UIFont *)font;


@end

NS_ASSUME_NONNULL_END
