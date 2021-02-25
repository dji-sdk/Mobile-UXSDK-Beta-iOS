//
//  UXSDKAccessory.h
//  UXSDKAccessory
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

//! Project version number for UXSDKAccessory.
FOUNDATION_EXPORT double UXSDKAccessoryVersionNumber;

//! Project version string for UXSDKAccessory.
FOUNDATION_EXPORT const unsigned char UXSDKAccessoryVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UXSDKAccessory/PublicHeader.h>


/*********************************************************************************/
// Beacon Widget
/*********************************************************************************/
#import <UXSDKAccessory/DUXBetaBeaconWidget.h>
#import <UXSDKAccessory/DUXBetaBeaconWidgetModel.h>

/*********************************************************************************/
// RTK Enabled Widget
/*********************************************************************************/
#import <UXSDKAccessory/DUXBetaRTKEnabledWidget.h>
#import <UXSDKAccessory/DUXBetaRTKEnabledWidgetModel.h>

/*********************************************************************************/
// RTK Satellite Status Widget
/*********************************************************************************/
#import <UXSDKAccessory/DUXBetaRTKSatelliteStatusWidget.h>
#import <UXSDKAccessory/DUXBetaRTKSatelliteStatusWidgetModel.h>

/*********************************************************************************/
// RTK Widget
/*********************************************************************************/
#import <UXSDKAccessory/DUXBetaRTKWidget.h>

/*********************************************************************************/
// Spotlight Widget
/*********************************************************************************/
#import <UXSDKAccessory/DUXBetaSpotlightIndicatorWidget.h>
#import <UXSDKAccessory/DUXBetaSpotlightIndicatorWidgetModel.h>
#import <UXSDKAccessory/DUXBetaSpotlightControlWidget.h>
#import <UXSDKAccessory/DUXBetaSpotlightControlWidgetModel.h>

/*********************************************************************************/
// Speaker Widget
/*********************************************************************************/
#import <UXSDKAccessory/DUXBetaSpeakerControlWidget.h>
#import <UXSDKAccessory/DUXBetaSpeakerIndicatorWidget.h>
#import <UXSDKAccessory/DUXBetaSpeakerIndicatorWidgetModel.h>
