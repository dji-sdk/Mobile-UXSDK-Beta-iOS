//
//  DUXBetaVideoSignalWidget.h
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
#import "DUXBetaVideoSignalWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Display:
 *  This widget displays the incoming video strength from the drone.  It consists of a static icon
 *  representing the video and another icon which updates to display the signal strength.
 *
 *  Usage:
 *  Preferred Aspect Ratio 43:18
 */

@interface DUXBetaVideoSignalWidget : DUXBetaBaseWidget

/**
 *  The widget model that the video signal widget receives its information from.
 */
@property (nonatomic, strong) DUXBetaVideoSignalWidgetModel *widgetModel;

/**
 * The color of the text indicating which band the connection is using (2.4GHz, 5.8GHz etc.).
*/
@property (nonatomic, strong) UIColor *frequencyBandTextColor;

/**
 *  The font of the text indicating which band the connection is using (2.4GHz, 5.8GHz etc.) Default point size = 30.
*/
@property (nonatomic, strong) UIFont *frequencyBandFont;

/**
 *  The background color of the label indicating which band the connection is using (2.4GHz, 5.8GHz etc.).
*/
@property (nonatomic, strong) UIColor *frequencyBandBackgroundColor;

/**
 *  The background color of the signal indicator image view.
*/
@property (nonatomic, strong) UIColor *barsBackgroundColor;

/**
 *  The background color of the icon image view.
*/
@property (nonatomic, strong) UIColor *iconBackgroundColor;

/**
 *  The background color of the entire widget.
*/
@property (nonatomic, strong) UIColor *widgetBackgroundColor;

/**
 *  The color of the icon when product is connected.
*/
@property (nonatomic, strong) UIColor *iconTintColorConnected;

/**
 *  The color of the icon when product is disconnected.
*/
@property (nonatomic, strong) UIColor *iconTintColorDisconnected;

/**
 *  Set the signal image(bars) to be displayed for the video signal strength level.
 *
 *  @param image The desired image.
 *  @param level The video signal strength level to change the image for.
 */
- (void)setBarsImage:(UIImage *)image forVideoSignalStrength:(DUXBetaVideoSignalStrength)level;

/**
 *  Get the signal image for the video signal strength level.
 *
 *  @param level The video signal strength level to get the image for.
 */
- (UIImage *)imageForSignalStrength:(DUXBetaVideoSignalStrength)level;

/**
 *  Update the icon image to be displayed for the air link transmission type.
 *  By default, the all icons are the same (HD).
 *
 * @param image The desired image.
 * @param airLinkType The type of air link transmission to change the icon for.
 */
- (void)setIconImage:(UIImage *)image forAirLinkType:(DUXBetaAirLinkType)airLinkType;

/**
*  Get the icon image for corresponding air link transmission type.
*
*  @param airLinkType The air link transmission type to get the icon image for.
*/
- (UIImage *)imageForAirLinkType:(DUXBetaAirLinkType)airLinkType;

@end

NS_ASSUME_NONNULL_END
