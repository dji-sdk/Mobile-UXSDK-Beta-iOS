//
//  DUXBetaConnectionWidget.h
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
#import "DUXBetaConnectionWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
* Widget that reflects the connected to aircraft state
*/
@interface DUXBetaConnectionWidget : DUXBetaBaseWidget

/**
* The widget model that holds the information needed by the widget
*/
@property (nonatomic, strong) DUXBetaConnectionWidgetModel *widgetModel;

/**
* Image used to reflect the connected state
*/
@property (nonatomic, strong) UIImage *connectedImage;

/**
* Image used to reflect the disconnected state
*/
@property (nonatomic, strong) UIImage *disconnectedImage;

/**
* Color used for the image container background color
*/
@property (nonatomic, strong) UIColor *backgroundColor;

/**
* Tint color applied to image container when the aircraft is connected
*/
@property (nonatomic, strong) UIColor *connectedTintColor;

/**
* Tint color applied to image container when the aircraft is disconnected
*/
@property (nonatomic, strong) UIColor *disconnectedTintColor;

@end

NS_ASSUME_NONNULL_END
