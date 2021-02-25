//
//  DUXBetaCompassWidget.h
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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
#import "DUXBetaStateChangeBroadcaster.h"
#import "DUXBetaCompassWidgetModel.h"
#import "DUXBetaCompassLayer.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This widget aggregates the attitude and location data of the aircraft
 * into one widget.
 *
 * This widget includes:
 *
 * - Position of the aircraft relative to the pilot
 * - Distance of the aircraft from the pilot
 * - Heading of the aircraft relative to the pilot
 * - True north relative to the pilot and the aircraft
 * - The aircraft's last recorded home location
 * - Attitude of the aircraft
 * - Yaw of the gimbal
 */
@interface DUXBetaCompassWidget : DUXBetaBaseWidget

/// The widget model used to define the underlying logic and communication.
@property (nonatomic, strong) DUXBetaCompassWidgetModel *widgetModel;

/// The custom class resposible for drawing the compass widget.
@property (nonatomic, readonly) DUXBetaCompassLayer *compassLayer;

@end

/**
 * CompassModelState contains the model hooks for the DUXBetaCompassWidget.
 * It implements the hook:
 *
 * Key: productConnected        Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft is connected.
 * Key: compassStateUpdated     Type: DUXBetaCompassState - Sends the compass state object when it gets updated.
*/
@class DUXBetaCompassState;
@interface CompassModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)compassStateUpdated:(DUXBetaCompassState *)state;

@end

NS_ASSUME_NONNULL_END
