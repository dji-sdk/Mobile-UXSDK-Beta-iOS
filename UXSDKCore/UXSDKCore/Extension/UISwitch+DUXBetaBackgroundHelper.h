//
//  UISwitch+BackgroundHelper.h
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @category The category/extension for UISwitch to allow implementing pre-iOS 13 style track ring around switches which can be colorized and will
 * allow showing a background color when the switch in the in the OFF state.
 *
 * Each of the defined methods works for iOS 13 or pre-13 and can be used identically in either. To use these extensions,
 * first call setupOutlineViewForUISwitch after the switch has been created. The backing view if created, will be set to use with autolayout.
 * To position the switch using autolayout anchors, call viewForLayout, which will either return the backing view in iOS 13, or the
 * UISwitch for pre-iOS 13.
 *
 * Customizing the UISwitch is done by calling the method setupCustomSwitchColorsOnTint:offTint:trackColor:.
 */
@interface UISwitch (iOS13Backgrounds)
/**
 * @brief Call setupOutlineViewForUISwitch to create the switch background for iOS 13 or newer, or just return the UISwitch on
 * pre-iOS 13 devices
 * @return Returns a UIView which can be used for autolayout. Either the UISwitch on pre-iOS 13 systems, or the switch
 * background view for iOS 13
 */
- (UIView *)setupOutlineViewForUISwitch;

/**
 * @brief Call setupCustomSwitchColorsOnTint:offTint:trackColor: to set each of the 3 possible colors for a UISwitch.
 * @param onTint The color to use for the on position side, or nil to use the default color.
 * @param offTint The color to use for the off position side, or nil to use the default color.
 * @param trackColor The color to use for the visible track around the switch, or nil to use the default color. Used in iOS 13+ only
 */
- (void)setupCustomSwitchColorsOnTint:(UIColor*)onTint offTint:(UIColor*)offTint trackColor:(UIColor*)trackColor;

/**
* @brief Call viewForLayout retrieve a view for use with autolayout of the UISwitch, independent of the OS version.
* @return Returns a UIView which can be used for autolayout. Either the UISwitch on pre-iOS 13 systems, or the switch
* background view for iOS 13
*/
- (UIView *)viewForLayout;
@end

NS_ASSUME_NONNULL_END
