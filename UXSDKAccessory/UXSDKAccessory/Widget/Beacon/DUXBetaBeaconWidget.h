//
//  DUXBetaBeaconWidget.h
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
@class DUXBetaBeaconWidgetModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Display:
 *  This widget provides a button for toggling the the Mavic 2 Enterprise's beacon attachment.
 *
 *  Usage:
 *  Preferred Aspect Ratio: 24:24
 */
@interface DUXBetaBeaconWidget : DUXBetaBaseWidget

/**
 *  The widget model that the beacon widget recieves its information from.
 */
@property (nonatomic, strong) DUXBetaBeaconWidgetModel *widgetModel;

/**
 *  The image used to show that the beacon is on.
 */
@property (nonatomic, strong) UIImage *activeImage;

/**
 *  The image used to show that the beacon is off.
 */
@property (nonatomic, strong) UIImage *inactiveImage;

@end

NS_ASSUME_NONNULL_END
