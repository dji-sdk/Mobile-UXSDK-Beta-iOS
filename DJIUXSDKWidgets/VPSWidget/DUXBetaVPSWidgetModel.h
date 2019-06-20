//
//  DUXBetaVPSWidgetModel.h
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Enum listing all the different states of the VPS status
 */
typedef NS_ENUM(NSUInteger, DUXBetaVPSStatus) {
    //VPS is currently being used
    DUXBetaVPSStatusBeingUsed,
    //VPS is enabled
    DUXBetaVPSStatusEnabled,
    //VPS status is unknown
    DUXBetaVPSStatusUnknown
};

@interface DUXBetaVPSWidgetModel : DUXBetaBaseWidgetModel

/**
 *  Get VPS status
 */
@property (assign, nonatomic, readonly) DUXBetaVPSStatus vpsStatus;

/**
 *  Get VPS height
 */
@property (nonatomic, readonly) NSMeasurement *vpsHeight;

/**
 *  Get VPS danger height, which is fixed to 1.2 meters
 */
@property (nonatomic, readonly) NSMeasurement *vpsDangerHeight;

/**
 *  Set units for VPS
 */
@property (nonatomic, strong) NSUnitLength *vpsUnits;

@end

NS_ASSUME_NONNULL_END
