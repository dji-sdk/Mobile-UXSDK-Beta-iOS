//
//  DUXBetaColorWaveFormWidget.h
//  UXSDKVisualCamera
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
#import "DUXBetaColorWaveFormWidgetModel.h"
#import <UXSDKCore/DUXBetaWidgetCloseButtonProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Display:
 *  Shows a graph depicting the different waveforms from the camera for the purpose of doing color correction.  These
 *  waveforms can be combined into one graph, seperated into individual graphs, or just the brightness graph.  The widget
 *  also has a close button which the delegate can handle.
 *
 *  NOTE: This widget will not function on the iOS simulator and instead will show a black view with text.
 *
 *  Usage:
 *  Preferred Aspect Ratio: 180:30
 */

@interface DUXBetaColorWaveFormWidget : DUXBetaBaseWidget

/**
 *  Use this initializer to create the widget.
 *
 *  @param previewer The video previewer instance to see the colorwaveform data from.
 */
- (instancetype)initWithVideoPreviewer:(DJIVideoPreviewer *)previewer;

/**
 *  Use this delegate method to respond to the close button action
 */
@property (weak, nonatomic) id <DUXBetaWidgetCloseButtonProtocol> delegate;

/**
 *  The video previewer that this colorwaveform is showing data for.
 */
@property (strong, nonatomic, readonly) DJIVideoPreviewer *previewer;

/**
 *  The widget model that the color wave form widget receives its information from.
 */
@property (strong, nonatomic) DUXBetaColorWaveFormWidgetModel *widgetModel;

/**
 *  The widget model that the color wave form widget receives its information from.
 *
 *  @param image The image you want to be displayed.
 *  @param displayType The display type you want the image to be shown for.
 *  @param isActive Determines what state of the button the image should be shown for.
 */
- (void)setButtonImage:(UIImage *)image forColorMonitorDisplayType:(DJILiveViewColorMonitorDisplayType)displayType andActiveState:(BOOL)isActive;

@end

NS_ASSUME_NONNULL_END
