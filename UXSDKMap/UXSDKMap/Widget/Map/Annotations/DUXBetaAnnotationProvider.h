//
//  DUXBetaAnnotationProvider.h
//  UXSDKMap
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
#import <DJISDK/DJISDK.h>

@class DUXBetaMapWidget;
@class DUXBetaMapSubFlyZoneAnnotation;
@class DUXBetaMapNoFlyZoneAnnotation;

@interface DUXBetaAnnotationProvider : NSObject

@property (nonatomic, strong, readonly) NSArray <id <MKAnnotation>> *addedAnnotations;
@property (nonatomic, strong, readonly) NSArray <id <MKAnnotation>> *removedAnnotations;

@property (nonatomic, strong, readonly) NSArray <id <MKAnnotation>> *allAnnotations;

@property (nonatomic, weak) DUXBetaMapWidget *mapWidget;

- (void)beginLockedFlyZoneUpdates;
- (void)endLockedFlyZoneUpdates;

- (void)beginUnlockedFlyZoneUpdates;
- (void)endUnlockedFlyZoneUpdates;

- (void)beginCustomUnlockedFlyZoneUpdates;
- (void)endCustomUnlockedFlyZoneUpdates;

- (void)addAnnotationForLockedFlyZone:(DJIFlyZoneInformation *)flyZone;
- (void)addAnnotationForUnlockedFlyZone:(DJIFlyZoneInformation *)flyZone;

- (void)addAnnotationForSubFlyZone:(DJISubFlyZoneInformation *)subFlyZone
                     withinFlyZone:(DJIFlyZoneInformation *)flyZone;

- (void)addAnnotationForCustomUnlockZone:(DJICustomUnlockZone *)flyZone
                          sentToAircraft:(BOOL)sentToAircraft
                       enabledOnAircraft:(BOOL)enabledOnAircraft;

- (DUXBetaMapNoFlyZoneAnnotation *)flyZoneAnnotationForFlyZone:(DJIFlyZoneInformation *)flyZone;
- (DUXBetaMapSubFlyZoneAnnotation *)subFlyZoneAnnotationForSubFlyZone:(DJISubFlyZoneInformation *)subFlyZone;

@end
