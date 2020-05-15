//
//  DUXBetaMapWidget_Protected.h
//  DJIUXSDK
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

#import <DJIUXSDKWidgets/DUXBetaMapWidget.h>

@class DUXBetaMapViewRenderer;
@class DUXBetaAnnotationProvider;
@class DUXBetaOverlayProvider;
@class DUXBetaFlyZoneDataProvider;

@interface DUXBetaMapWidget ()

@property (nonatomic, weak) UIViewController *containingViewController;
@property (nonatomic, weak) DUXBetaMapViewRenderer *renderer;

@property (nonatomic, strong) DUXBetaOverlayProvider *overlayProvider;
@property (nonatomic, strong) DUXBetaAnnotationProvider *annotationProvider;
@property (nonatomic, strong) DUXBetaFlyZoneDataProvider *flyZoneDataProvider;

@property (nonatomic, strong) NSMutableDictionary <NSString *, DJIFlyZoneInformation *> *flyZones;
@property (nonatomic, strong) NSMutableDictionary <NSString *, DJIFlyZoneInformation *> *unlockedFlyZones;
@property (nonatomic, strong) NSMutableDictionary <NSString *, DJICustomUnlockZone *> *customUnlockedFlyZones;
@property (nonatomic, strong) NSMutableDictionary <NSString *, DJICustomUnlockZone *> *customUnlockedFlyZonesOnAircraft;

// Mapping of sub fly zone ID to it's parent fly zone
@property (nonatomic, strong) NSMutableDictionary <NSString *, DJIFlyZoneInformation *> *subFlyZonesParentFlyZones;

- (void)presentAlertController:(UIAlertController *)alertController;
- (void)presentConfirmationAlertForSelfUnlockingWithFlyZoneIDs:(NSArray <NSNumber *> *)flyZoneIDs;
- (void)presentConfirmationAlertForSelfUnlockRequestOnUnlockedFlyZone:(NSString *)flyZoneSubtitle;
- (void)presentConfirmationAlertForSendingCustomUnlockZoneToAircraft;

- (void)presentConfirmationAlertForEnablingCustomUnlockZone:(DJICustomUnlockZone *)customUnlockZone;
- (void)presentConfirmationAlertForDisablingCustomUnlockZone:(DJICustomUnlockZone *)customUnlockZone;

@end
