//
//  DUXBetaRemoteControllerSignalWidget.h
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidget.h>
#import "DUXBetaRemoteControllerSignalWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Display:
 *  This widget displays the drone's connection strength with the remote controller.  It consists of a static icon
 *  representing the remote controller and another icon which updates to display the signal strength.
 *
 *  Usage:
 *  Preferred Aspect Ratio 38:18
 */

@interface DUXBetaRemoteControllerSignalWidget : DUXBetaBaseWidget

/**
 *  The widget model that the remote controller signal widget receives its information from.
 */
@property (nonatomic, strong) DUXBetaRemoteControllerSignalWidgetModel *widgetModel;

/**
 *  Set the image for the signal strength level.
 *
 *  @param image The desired image.
 *  @param level The signal strength level to change the image for.
 */
- (void)setImage:(UIImage *)image forRemoteControllerBarLevel:(DUXBetaRemoteSignalBarsLevel)level;

/**
 *  Get the image for the signal strength level.
 *
 *  @param level The signal strength level to get the image for.
 */
- (UIImage *)imageForBarLevel:(DUXBetaRemoteSignalBarsLevel)level;

/**
 *  The icon that represents the remote controller.
 */
@property (nonatomic, strong) UIImage *remoteControllerWidgetIcon;

/**
 *  The color of the icon when disconnected from product.
*/
@property (nonatomic, strong) UIColor *disconnectedTintColor;

/**
 *  The color of the icon when connected from product.
*/
@property (nonatomic, strong) UIColor *connectedTintColor;

@end

NS_ASSUME_NONNULL_END
