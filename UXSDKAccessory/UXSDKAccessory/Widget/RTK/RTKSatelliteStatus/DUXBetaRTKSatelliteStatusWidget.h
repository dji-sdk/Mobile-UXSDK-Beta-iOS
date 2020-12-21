//
//  DUXBetaRTKSatelliteStatusWidget.h
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
#import "DUXBetaRTKSatelliteStatusWidgetModel.h"

typedef NS_ENUM(NSUInteger, DUXBetaRTKLocationState) {
    DUXBetaRTKLocationStateNone = 0,
    DUXBetaRTKLocationStateSinglePoint = 16,
    DUXBetaRTKLocationStateFloat = 32,
    DUXBetaRTKLocationStateFloatIono = 33,
    DUXBetaRTKLocationStateFloatNarrow = 34,
    DUXBetaRTKLocationStateFixedPoint = 50,
};

NS_ASSUME_NONNULL_BEGIN

/**
*  Display:
*  This widget displays the state of RTK base station state and a table of RTK positioning values.
*
*  Usage:
*  Preferred Aspect Ratio 500:500
*/
@interface DUXBetaRTKSatelliteStatusWidget : DUXBetaBaseWidget

/**
 *  The widget model that the battery widget receives its information from.
*/
@property (nonatomic, strong) DUXBetaRTKSatelliteStatusWidgetModel *widgetModel;

/**
 *  The font of the status title label (Base Station Status:). Default point size = 12.
*/
@property (nonatomic, strong) UIFont *statusTitleLabelFont;

/**
 *  The color of the status title label.
*/
@property (nonatomic, strong) UIColor *statusTitleLabelTextColor;

/**
 *  The background color of the status title label.
*/
@property (nonatomic, strong) UIColor *statusTitleLabelBackgroundColor;

/**
 *  The font of the status label (follows the status title label). Default point size = 12.
*/
@property (nonatomic, strong) UIFont *statusLabelFont;

/**
 *  The background color of the status label.
*/
@property (nonatomic, strong) UIColor *statusLabelBackgroundColor;

/**
 *  The font of the title labels (labels in the first row or column of the table). Default point size = 12.
*/
@property (nonatomic, strong) UIFont *titleLabelFont;

/**
 *  The text color of the title labels.
*/
@property (nonatomic, strong) UIColor *titleLabelTextColor;

/**
 *  The background color of the title labels.
*/
@property (nonatomic, strong) UIColor *titleLabelBackgroundColor;

/**
 *  The font of the value labels (labels in the first row or column of the table). Default point size = 12.
*/
@property (nonatomic, strong) UIFont *valueLabelFont;

/**
 *  The text color of the value labels.
*/
@property (nonatomic, strong) UIColor *valueLabelTextColor;

/**
 *  The background color of the value labels.
*/
@property (nonatomic, strong) UIColor *valueLabelBackgroundColor;

/**
 *  The table line color (default gray).
*/
@property (nonatomic, strong) UIColor *tableColor;

/**
 *  The visibility of the Beidou satellite counts row of the table.
*/
@property (nonatomic, assign) BOOL isBeidouCountVisible;

/**
 *  The visibility of the Glonass satellite counts row of the table.
*/
@property (nonatomic, assign) BOOL isGlonassCountVisible;

/**
 *  The visibility of the Galileo satellite counts row of the table.
*/
@property (nonatomic, assign) BOOL isGalileoCountVisible;

/**
 *  The image asset for the valid orientaion icon (only shown for M210RTK).
*/
@property (nonatomic, strong) UIImage *orientationValidImage;

/**
 *  The image asset for the invalid orientaion icon (only shown for M210RTK).
*/
@property (nonatomic, strong) UIImage *orientationInvalidImage;

/**
 *  The image tint for the valid orientaion icon (only shown for M210RTK).
*/
@property (nonatomic, strong) UIColor *orientationValidTint;

/**
 *  The image tint for the invalid orientaion icon (only shown for M210RTK).
*/
@property (nonatomic, strong) UIColor *orientationInvalidTint;

/**
 *  The background color of the widget.
*/
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *  Set the color of the connection status text for the specified connection status state.
*/
- (void)setStatusTextColor:(UIColor *)fontColor forConnectionStatus:(DUXBetaRTKConnectionStatus)status;

/**
 *  Get the color of the connection status text for the specified connection status state.
*/
- (UIColor *)statusTextColorForConnectionStatus:(DUXBetaRTKConnectionStatus)status;

@end

NS_ASSUME_NONNULL_END
