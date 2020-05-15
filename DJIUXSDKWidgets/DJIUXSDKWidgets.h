//
//  DJIUXSDKWidgets.h
//  DJIUXSDKWidgets
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

#import <UIKit/UIKit.h>

//! Project version number for DJIUXSDKWidgets.
FOUNDATION_EXPORT double DJIUXSDKWidgetsVersionNumber;

//! Project version string for DJIUXSDKWidgets.
FOUNDATION_EXPORT const unsigned char DJIUXSDKWidgetsVersionString[];

/*********************************************************************************/
// Helpers
/*********************************************************************************/
#import <DJIUXSDKWidgets/UIImage+DUXBetaAssets.h>
#import <DJIUXSDKWidgets/NSData+DUXBetaAssets.h>
#import <DJIUXSDKWidgets/UIFont+DUXBetaFonts.h>
#import <DJIUXSDKWidgets/NSBundle+DUXBetaAssets.h>
#import <DJIUXSDKWidgets/NSLayoutConstraint+DUXBetaMultiplier.h>
#import <DJIUXSDKCore/DUXBetaKeyManager.h>

/*********************************************************************************/
// Base Class
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaBaseWidget.h>
#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>

/*********************************************************************************/
// Panel Widgets
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXPanelWidgetSupport.h>

#import <DJIUXSDKWidgets/DUXListItemTitleWidget.h>
#import <DJIUXSDKWidgets/DUXListItemLabelButtonWidget.h>
#import <DJIUXSDKWidgets/DUXListItemEditTextButtonWidget.h>
#import <DJIUXSDKWidgets/DUXListItemRadioButtonWidget.h>
#import <DJIUXSDKWidgets/DUXListItemSwitchWidget.h>


/*********************************************************************************/
// AirSense Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaAirSenseWidget.h>
#import <DJIUXSDKWidgets/DUXBetaAirSenseWidgetModel.h>

/*********************************************************************************/
// Altitude Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaAltitudeWidget.h>
#import <DJIUXSDKWidgets/DUXBetaAltitudeWidgetModel.h>

/*********************************************************************************/
// Battery Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaBatteryWidget.h>
#import <DJIUXSDKWidgets/DUXBetaBatteryWidgetModel.h>
#import <DJIUXSDKWidgets/DUXBetaBatteryState.h>

/*********************************************************************************/
// Compass Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaCompassWidget.h>
#import <DJIUXSDKWidgets/DUXBetaCompassWidgetModel.h>

/*********************************************************************************/
// Connection Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaConnectionWidget.h>
#import <DJIUXSDKWidgets/DUXBetaConnectionWidgetModel.h>

/*********************************************************************************/
// Dashboard Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaDashboardWidget.h>

/*********************************************************************************/
// FlightMode Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaFlightModeWidget.h>
#import <DJIUXSDKWidgets/DUXBetaFlightModeWidgetModel.h>

/*********************************************************************************/
// FPV Widget
/*****************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaFPVDecodeAdapter.h>
#import <DJIUXSDKWidgets/DUXBetaFPVDecodeModel.h>

/*********************************************************************************/
// GPS Signal Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaGPSSignalWidget.h>
#import <DJIUXSDKWidgets/DUXBetaGPSSignalWidgetModel.h>

/*********************************************************************************/
// Home Distance Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaHomeDistanceWidget.h>
#import <DJIUXSDKWidgets/DUXBetaHomeDistanceWidgetModel.h>

/*********************************************************************************/
// Horizontal Velocity Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaHorizontalVelocityWidget.h>
#import <DJIUXSDKWidgets/DUXBetaHorizontalVelocityWidgetModel.h>

/*********************************************************************************/
// Map Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaMapWidget.h>
#import <DJIUXSDKWidgets/DUXBetaMapWidgetModel.h>
#import <DJIUXSDKWidgets/DUXBetaFlyZoneDataProvider.h>
#import <DJIUXSDKWidgets/DUXBetaOverlayProvider.h>
#import <DJIUXSDKWidgets/DUXBetaAnnotationProvider.h>
#import <DJIUXSDKWidgets/DUXBetaFlyZoneDataProviderModel.h>
#import <DJIUXSDKWidgets/DUXBetaMapFlyZoneCircleOverlay.h>
#import <DJIUXSDKWidgets/DUXBetaMapPolylineOverlay.h>
#import <DJIUXSDKWidgets/DUXBetaMapSubFlyZonePolygonOverlay.h>
#import <DJIUXSDKWidgets/DUXBetaMapView.h>

/*********************************************************************************/
// RC Distance Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaRCDistanceWidget.h>
#import <DJIUXSDKWidgets/DUXBetaRCDistanceWidgetModel.h>

/*********************************************************************************/
// Remaining Flight Time Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaRemainingFlightTimeWidget.h>
#import <DJIUXSDKWidgets/DUXBetaRemainingFlightTimeWidgetModel.h>

/*********************************************************************************/
// Remote Controller Signal Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaRemoteControllerSignalWidget.h>
#import <DJIUXSDKWidgets/DUXBetaRemoteControllerSignalWidgetModel.h>

/*********************************************************************************/
// Simulator Indicator Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaSimulatorIndicatorWidget.h>
#import <DJIUXSDKWidgets/DUXBetaSimulatorIndicatorWidgetModel.h>

/*********************************************************************************/
// System Status Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaSystemStatusWidget.h>
#import <DJIUXSDKWidgets/DUXBetaSystemStatusWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - MaxAltitudeListItem Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXMaxAltitudeListItemWidget.h>
#import <DJIUXSDKWidgets/DUXMaxAltitudeListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - SDCardRemainingCapacityListItem Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXSDCardRemainingCapacityListItemWidget.h>
#import <DJIUXSDKWidgets/DUXSDCardRemainingCapacityListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - RCStickModeListItem Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXRCStickModeListItemWidget.h>
#import <DJIUXSDKWidgets/DUXRCStickModeListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - FlightModeListItem Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXFlightModeListItemWidget.h>
#import <DJIUXSDKWidgets/DUXFlightModeListItemWidgetModel.h>

/*********************************************************************************/
// Vertical Velocity Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaVerticalVelocityWidget.h>
#import <DJIUXSDKWidgets/DUXBetaVerticalVelocityWidgetModel.h>

/*********************************************************************************/
// Video Signal Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaVideoSignalWidget.h>
#import <DJIUXSDKWidgets/DUXBetaVideoSignalWidgetModel.h>

/*********************************************************************************/
// Vision Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaVisionWidget.h>
#import <DJIUXSDKWidgets/DUXBetaVisionWidgetModel.h>

/*********************************************************************************/
// VPS Widget
/*********************************************************************************/
#import <DJIUXSDKWidgets/DUXBetaVPSWidget.h>
#import <DJIUXSDKWidgets/DUXBetaVPSWidgetModel.h>
