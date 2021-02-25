//
//  DUXBetaCaptureBaseWidget.h
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2021 DJI
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
#import <UXSDKCore/DUXBetaStateChangeBaseData.h>

#import "DUXBetaCaptureBaseWidgetModel.h"

/**
 *  TODO: Add widget description
*/
@interface DUXBetaCaptureBaseWidget : DUXBetaBaseWidget

/**
 *  The widget model that contains the underlying logic and communication.
*/
@property (nonatomic, strong) DUXBetaCaptureBaseWidgetModel *widgetModel;

@end

/**
 * CaptureBaseModelState contains the hooks for model changes in the DUXBetaCaptureBaseWidget.
 * It implements the hooks:
 *
 * Key: productConnected    Type: NSNumber - Sends a boolean value as an NSNumber indicating the connected state of
 *                                           the device when it changes.
*/
@interface CaptureBaseModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;

@end

/**
 * CaptureBaseUIState contains the hooks for UI changes in the widget class DUXBetaCaptureBaseWidget.
 * It implements the hooks:
 *
 * Key: widgetTapped         Type: NSNumber - Sends a boolean YES as an NSNumber when the widget is tapped.
*/
@interface CaptureBaseUIState : DUXBetaStateChangeBaseData

+ (instancetype)widgetTapped;

@end
