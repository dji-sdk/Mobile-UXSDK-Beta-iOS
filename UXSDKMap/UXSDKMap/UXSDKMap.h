//
//  UXSDKMap.h
//  UXSDKMap
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

//! Project version number for UXSDKMap.
FOUNDATION_EXPORT double UXSDKMapVersionNumber;

//! Project version string for UXSDKMap.
FOUNDATION_EXPORT const unsigned char UXSDKMapVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UXSDKMap/PublicHeader.h>

/*********************************************************************************/
// Util
/*********************************************************************************/
#import <UXSDKMap/NSString+DUXBetaStrings.h>

/*********************************************************************************/
// Extension
/*********************************************************************************/
#import <UXSDKMap/DJIFlyZoneInformation+DUXBetaFlyZoneInformation.h>

/*********************************************************************************/
// Map Widget
/*********************************************************************************/
#import <UXSDKMap/DUXBetaMapWidget.h>
#import <UXSDKMap/DUXBetaMapWidgetModel.h>
#import <UXSDKMap/DUXBetaFlyZoneDataProvider.h>
#import <UXSDKMap/DUXBetaOverlayProvider.h>
#import <UXSDKMap/DUXBetaAnnotationProvider.h>
#import <UXSDKMap/DUXBetaFlyZoneDataProviderModel.h>
#import <UXSDKMap/DUXBetaMapFlyZoneCircleOverlay.h>
#import <UXSDKMap/DUXBetaMapPolylineOverlay.h>
#import <UXSDKMap/DUXBetaMapSubFlyZonePolygonOverlay.h>
#import <UXSDKMap/DUXBetaMapView.h>
