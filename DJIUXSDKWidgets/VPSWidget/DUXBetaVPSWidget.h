//
//  DUXBetaVPSWidget.h
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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
#import "DUXBetaVPSWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Shows the status of the vision positioning system
 * as well as the height of the aircraft as received from the
 * vision positioning system if available. Defaults to meters if nothing is set.
 */
@interface DUXBetaVPSWidget : DUXBetaBaseWidget

@property (nonatomic, strong) DUXBetaVPSWidgetModel *widgetModel;

- (void)setImage:(UIImage *)image forVPSStatus:(DUXBetaVPSStatus)status;
- (UIImage *)imageForVPSStatus:(DUXBetaVPSStatus)status;

@property (nonatomic, strong) UIColor *disabledFontColor;
@property (nonatomic, strong) UIColor *dangerFontColor;
@property (nonatomic, strong) UIColor *normalFontColor;

@end

NS_ASSUME_NONNULL_END
