//
//  DUXBetaHistogramWidget.h
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
#import "DUXBetaHistogramWidgetModel.h"
#import <UXSDKCore/DUXBetaWidgetCloseButtonProtocol.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  Display:
 *  The histogram widget displays a graphical representation of the tonal values currently visible by the camera.  It also
 *  includes a close button to exit out of the widget.
 *
 *  Usage:
 *  Preferred Aspect Ratio: 18:13
 */

@interface DUXBetaHistogramWidget : DUXBetaBaseWidget

/**
 *  The widget model that the histogram widget receives its information from.
 */
@property (nonatomic, strong) DUXBetaHistogramWidgetModel *widgetModel;

/**
 *  The delegate for responding to the close button action.
 */
@property (nonatomic, weak) id <DUXBetaWidgetCloseButtonProtocol> delegate;

/**
 *  The color of the line on the histogram graph.
 */
@property (nonatomic, strong) UIColor *histogramLineColor;

/**
 *  The color of the area below the line in the histogram graph.
 */
@property (nonatomic, strong) UIColor *histogramFillColor;

/**
 *  The color of the grid behind the histogram graph.
 */
@property (nonatomic, strong) UIColor *histogramGridColor;

/**
 *  The background color of the histogram view.
 */
@property (nonatomic, strong) UIColor *histogramBackgroundColor;

/**
 *  Determines if the the grid should be drawn.
 */
@property (assign, nonatomic) BOOL shouldDrawGrid;

/**
 *  Determines if the graph should draw a cubic function vs a linear function.
 */
@property (assign, nonatomic) BOOL shouldDrawCubic;

/**
 *  Determines if the widget should show the close button.
 */
@property (assign, nonatomic) BOOL shouldShowCloseButton;

@end

NS_ASSUME_NONNULL_END
