//
//  UXSDKCore.h
//  UXSDKCore
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

#import <Foundation/Foundation.h>

//! Project version number for UXSDKCore.
FOUNDATION_EXPORT double UXSDKCoreVersionNumber;

//! Project version string for UXSDKCore.
FOUNDATION_EXPORT const unsigned char UXSDKCoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UXSDKCore/PublicHeader.h>

/*********************************************************************************/
// Core
/*********************************************************************************/
#import <UXSDKCore/DUXBetaSingleton.h>
#import <UXSDKCore/DUXBetaKeyManager.h>
#import <UXSDKCore/DUXBetaWarningMessage.h>

/*********************************************************************************/
// Hooks
/*********************************************************************************/
#import <UXSDKCore/DUXBetaStateChangeBaseData.h>
#import <UXSDKCore/DUXBetaStateChangeBroadcaster.h>

/*********************************************************************************/
// Remote KVO
/*********************************************************************************/
#import <UXSDKCore/DUXBetaRKVOHeaders.h>

/*********************************************************************************/
// Protocols
/*********************************************************************************/
#import <UXSDKCore/DUXBetaWidgetCloseButtonProtocol.h>

/*********************************************************************************/
// Utils
/*********************************************************************************/
#import <UXSDKCore/UIColor+DUXBetaColors.h>
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIFont+DUXBetaFonts.h>
#import <UXSDKCore/NSBundle+DUXBetaAssets.h>
#import <UXSDKCore/NSData+DUXBetaAssets.h>
#import <UXSDKCore/DJIVideoPreviewer+DUXBetaImageHelper.h>
#import <UXSDKCore/DUXBetaLocationUtil.h>

/*********************************************************************************/
// Extensions
/*********************************************************************************/
#import <UXSDKCore/NSDateFormatter+DUXBetaDateFormatter.h>
#import <UXSDKCore/NSLayoutConstraint+DUXBetaMultiplier.h>
#import <UXSDKCore/NSObject+DUXBetaSwiftHelpers.h>
#import <UXSDKCore/UISwitch+DUXBetaBackgroundHelper.h>

/*********************************************************************************/
// Custom Interface Controls
/*********************************************************************************/
#import <UXSDKCore/DUXBetaUIImageView.h>

/*********************************************************************************/
// Audio Tools
/*********************************************************************************/
#import <UXSDKCore/DUXBetaAudioSource.h>
#import <UXSDKCore/DUXBetaVoiceNotification.h>
#import <UXSDKCore/DUXBetaAudioFilePCMParser.h>

/*********************************************************************************/
// Base Class
/*********************************************************************************/
#import <UXSDKCore/DUXBetaBaseWidget.h>
#import <UXSDKCore/DUXBetaBaseWidgetModel.h>
#import <UXSDKCore/DUXBetaTheme.h>

/*********************************************************************************/
// Panel Widgets
/*********************************************************************************/
#import <UXSDKCore/DUXBetaPanelWidgetSupport.h>
#import <UXSDKCore/DUXBetaListItemTitleWidget.h>
#import <UXSDKCore/DUXBetaListItemLabelButtonWidget.h>
#import <UXSDKCore/DUXBetaListItemEditTextButtonWidget.h>
#import <UXSDKCore/DUXBetaListItemRadioButtonWidget.h>
#import <UXSDKCore/DUXBetaListItemSwitchWidget.h>

/*********************************************************************************/
// AirSense Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaAirSenseWidget.h>
#import <UXSDKCore/DUXBetaAirSenseWidgetModel.h>

/*********************************************************************************/
// Battery Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaBatteryWidget.h>
#import <UXSDKCore/DUXBetaBatteryWidgetModel.h>
#import <UXSDKCore/DUXBetaBatteryState.h>

/*********************************************************************************/
// Compass Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaCompassWidget.h>
#import <UXSDKCore/DUXBetaCompassWidgetModel.h>

/*********************************************************************************/
// Connection Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaConnectionWidget.h>
#import <UXSDKCore/DUXBetaConnectionWidgetModel.h>

/*********************************************************************************/
// FlightMode Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaFlightModeWidget.h>
#import <UXSDKCore/DUXBetaFlightModeWidgetModel.h>

/*********************************************************************************/
// FPV Widget
/*****************************************************************************/
#import <UXSDKCore/DUXBetaFPVDecodeAdapter.h>
#import <UXSDKCore/DUXBetaFPVDecodeModel.h>

/*********************************************************************************/
// GPS Signal Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaGPSSignalWidget.h>
#import <UXSDKCore/DUXBetaGPSSignalWidgetModel.h>

/*********************************************************************************/
// Radar Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaRadarWidget.h>
#import <UXSDKCore/DUXBetaRadarWidgetModel.h>

/*********************************************************************************/
// Remaining Flight Time Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaRemainingFlightTimeWidget.h>
#import <UXSDKCore/DUXBetaRemainingFlightTimeWidgetModel.h>

/*********************************************************************************/
// Remote Controller Signal Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaRemoteControllerSignalWidget.h>
#import <UXSDKCore/DUXBetaRemoteControllerSignalWidgetModel.h>

/*********************************************************************************/
// Simulator Indicator Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaSimulatorIndicatorWidget.h>
#import <UXSDKCore/DUXBetaSimulatorIndicatorWidgetModel.h>

/*********************************************************************************/
// System Status Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaSystemStatusWidget.h>
#import <UXSDKCore/DUXBetaSystemStatusWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - EMMC Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaEMMCStatusListItemWidget.h>
#import <UXSDKCore/DUXBetaEMMCStatusListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - MaxAltitudeListItem Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaMaxAltitudeListItemWidget.h>
#import <UXSDKCore/DUXBetaMaxAltitudeListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - SDCardRemainingCapacityListItem Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaSDCardStatusListItemWidget.h>
#import <UXSDKCore/DUXBetaSDCardStatusListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - SSDRemainingCapacityListItem Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaSSDStatusListItemWidget.h>
#import <UXSDKCore/DUXBetaSSDStatusListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - RCStickModeListItem Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaRCStickModeListItemWidget.h>
#import <UXSDKCore/DUXBetaRCStickModeListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - FlightModeListItem Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaFlightModeListItemWidget.h>
#import <UXSDKCore/DUXBetaFlightModeListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - DUXBetaMaxFlightDistanceListItemWidget Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaMaxFlightDistanceListItemWidget.h>
#import <UXSDKCore/DUXBetaMaxFlightDistanceListItemWidgetModel.h>

/*********************************************************************************/
// SystemStatusList - DUXBetaReturnToHomeAltitudeListItemWidget Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaReturnToHomeAltitudeListItemWidget.h>
#import <UXSDKCore/DUXBetaReturnToHomeAltitudeListItemWidgetModel.h>

/*********************************************************************************/
// Video Signal Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaVideoSignalWidget.h>
#import <UXSDKCore/DUXBetaVideoSignalWidgetModel.h>

/*********************************************************************************/
// Vision Widget
/*********************************************************************************/
#import <UXSDKCore/DUXBetaVisionWidget.h>
#import <UXSDKCore/DUXBetaVisionWidgetModel.h>

// This widget is used to show how to write/use a simple options widget
#import <UXSDKCore/DUXBetaSampleListItemWidget.h>

// Thes widget is used for building single key based widgets.
#import <UXSDKCore/DUXBetaListItemTrivialSwitchWidget.h>
