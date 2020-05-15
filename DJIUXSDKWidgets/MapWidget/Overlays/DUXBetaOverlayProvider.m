//
//  DUXBetaOverlayProvider.m
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

#import "DUXBetaOverlayProvider.h"
#import "DUXBetaMapWidget_Protected.h"
#import "DUXBetaMapFlyZoneCircleOverlay.h"
#import "DUXBetaMapSubFlyZonePolygonOverlay.h"
#import "DUXBetaMapWidget.h"
@import DJIUXSDKCore;

@interface DUXBetaOverlayProvider ()

@property (nonatomic, strong) NSMutableDictionary *mutableAddedLockedOverlays;
@property (nonatomic, strong) NSMutableDictionary *mutableRemovedLockedOverlays;

@property (nonatomic, strong) NSMutableDictionary *mutableAllLockedOverlays;

@property (nonatomic, strong) NSMutableDictionary *mutableAddedUnlockedOverlays;
@property (nonatomic, strong) NSMutableDictionary *mutableRemovedUnlockedOverlays;

@property (nonatomic, strong) NSMutableDictionary *mutableAllUnlockedOverlays;

@property (nonatomic, strong) NSMutableDictionary *mutableAddedCustomUnlockedOverlays;
@property (nonatomic, strong) NSMutableDictionary *mutableRemovedCustomUnlockedOverlays;
@property (nonatomic, strong) NSMutableDictionary *mutableAllCustomUnlockedOverlays;

@end

@implementation DUXBetaOverlayProvider

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableAddedLockedOverlays = [NSMutableDictionary dictionary];
        _mutableRemovedLockedOverlays = [NSMutableDictionary dictionary];
        _mutableAllLockedOverlays = [NSMutableDictionary dictionary];
        
        _mutableAddedUnlockedOverlays = [NSMutableDictionary dictionary];
        _mutableRemovedUnlockedOverlays = [NSMutableDictionary dictionary];
        _mutableAllUnlockedOverlays = [NSMutableDictionary dictionary];
        
        _mutableAddedCustomUnlockedOverlays = [NSMutableDictionary dictionary];
        _mutableRemovedCustomUnlockedOverlays = [NSMutableDictionary dictionary];
        _mutableAllCustomUnlockedOverlays = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Update Methods

- (void)beginLockedFlyZoneUpdates {
    self.mutableAddedLockedOverlays = [NSMutableDictionary dictionary];
}

- (void)endLockedFlyZoneUpdates {
    NSArray *allAddedLockedOverlaysKeys = self.mutableAddedLockedOverlays.allKeys;
    for (NSString *flyZoneIdentifier in allAddedLockedOverlaysKeys) {
        if (self.mutableAddedUnlockedOverlays[flyZoneIdentifier] != nil) {
            [self.mutableAddedLockedOverlays removeObjectForKey:flyZoneIdentifier];
        }
    }

    for (NSString *flyZoneIdentifier in self.mutableAllLockedOverlays.allKeys) {
        if (self.mutableAddedLockedOverlays[flyZoneIdentifier] == nil) {
            self.mutableRemovedLockedOverlays[flyZoneIdentifier] = self.mutableAllLockedOverlays[flyZoneIdentifier];
        }
    }
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedLockedOverlays.allKeys) {
        [self.mutableAllLockedOverlays removeObjectForKey:flyZoneIdentifier];
    }
    
    [self recomputeAllLockedFlyZones];
}

- (void)beginUnlockedFlyZoneUpdates {
    self.mutableAddedUnlockedOverlays = [NSMutableDictionary dictionary];
}

- (void)endUnlockedFlyZoneUpdates {
    for (NSString *flyZoneIdentifier in self.mutableAllUnlockedOverlays.allKeys) {
        if (self.mutableAddedUnlockedOverlays[flyZoneIdentifier] == nil) {
            self.mutableRemovedUnlockedOverlays[flyZoneIdentifier] = self.mutableAllUnlockedOverlays[flyZoneIdentifier];
        } else {
            if (self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier]) {
                DJIFlyZoneInformation *flyZone = self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier];
                if ([self filterWithCategory:flyZone.category]) {
                    self.mutableRemovedUnlockedOverlays[flyZoneIdentifier] = self.mutableAllUnlockedOverlays[flyZoneIdentifier];
                }
            } else if (self.mapWidget.unlockedFlyZones[flyZoneIdentifier]) {
                DJIFlyZoneInformation *flyZone = self.mapWidget.unlockedFlyZones[flyZoneIdentifier];
                if ([self filterWithCategory:flyZone.category]) {
                    self.mutableRemovedUnlockedOverlays[flyZoneIdentifier] = self.mutableAllUnlockedOverlays[flyZoneIdentifier];
                }
            }
        }
    }
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedUnlockedOverlays) {
        [self.mutableAllUnlockedOverlays removeObjectForKey:flyZoneIdentifier];
    }
    
    [self recomputeAllUnlockedFlyZones];
}

- (void)beginCustomUnlockedFlyZoneUpdates {
    self.mutableAddedCustomUnlockedOverlays = [NSMutableDictionary dictionary];
}

- (void)endCustomUnlockedFlyZoneUpdates {
    NSArray *allCustomUnlockedOverlaysKeys = [self.mutableAllCustomUnlockedOverlays.allKeys copy];
    
    for (NSString *flyZoneIdentifier in allCustomUnlockedOverlaysKeys) {
        if (![self.mutableAddedCustomUnlockedOverlays.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableRemovedCustomUnlockedOverlays[flyZoneIdentifier] = self.mutableAllCustomUnlockedOverlays[flyZoneIdentifier];
        }
    }
    
    [self recomputeAllCustomUnlockedFlyZones];
}

- (void)recomputeAllLockedFlyZones {
    NSArray *allMutableAddedLockedOverlaysKeys = self.mutableAddedLockedOverlays.allKeys;
    for (NSString *flyZoneIdentifier in allMutableAddedLockedOverlaysKeys) {
        if (![self.mutableAllLockedOverlays.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableAllLockedOverlays[flyZoneIdentifier] = self.mutableAddedLockedOverlays[flyZoneIdentifier];
        }
    }
    
    NSArray *allMutableAllLockedOverlaysKeys = self.mutableAllLockedOverlays.allKeys;
    for (NSString *flyZoneIdentifier in allMutableAllLockedOverlaysKeys) {
        if (![self.mutableAddedLockedOverlays.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableRemovedLockedOverlays[flyZoneIdentifier] = self.mutableAllLockedOverlays[flyZoneIdentifier];
        }
    }
}

- (void)recomputeAllUnlockedFlyZones {
    NSArray *allMutableAddedUnlockedOverlaysKeys = self.mutableAddedUnlockedOverlays.allKeys;
    for (NSString *flyZoneIdentifier in allMutableAddedUnlockedOverlaysKeys) {
        if (![self.mutableAllUnlockedOverlays.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableAllUnlockedOverlays[flyZoneIdentifier] = self.mutableAddedUnlockedOverlays[flyZoneIdentifier];
        }
    }
    
    NSArray *allMutableAllUnlockedOverlaysKeys = self.mutableAllUnlockedOverlays.allKeys;
    for (NSString *flyZoneIdentifier in allMutableAllUnlockedOverlaysKeys) {
        if (![self.mutableAddedUnlockedOverlays.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableRemovedUnlockedOverlays[flyZoneIdentifier] = self.mutableAllUnlockedOverlays[flyZoneIdentifier];
        }
    }
}

- (void)recomputeAllCustomUnlockedFlyZones {
    self.mutableAllCustomUnlockedOverlays = [self.mutableAddedCustomUnlockedOverlays mutableCopy];
    
    if (self.mapWidget.showCustomUnlockZones) {
        for (NSString *flyZoneIdentifier in self.mutableAddedCustomUnlockedOverlays) {
            if (![self.mutableAllCustomUnlockedOverlays.allKeys containsObject:flyZoneIdentifier]) {
                self.mutableAllCustomUnlockedOverlays[flyZoneIdentifier] = self.mutableAddedCustomUnlockedOverlays[flyZoneIdentifier];
            }
        }
    } else {
        [self.mutableRemovedCustomUnlockedOverlays addEntriesFromDictionary:self.mutableAllCustomUnlockedOverlays];
    }
}

#pragma mark - Overlay Handling

- (void)addLockedOverlayForFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapFlyZoneCircleOverlay *noFlyZoneCircle = [self noFlyZoneCircleOverlayWithFlyZone:flyZone];
    self.mutableAddedLockedOverlays[[NSString duxbeta_flyZoneProviderAccessKeyWithFlyZone:flyZone]] = noFlyZoneCircle;
}

- (void)addUnlockedOverlayForFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapFlyZoneCircleOverlay *noFlyZoneCircle = [self noFlyZoneCircleOverlayWithFlyZone:flyZone];
    self.mutableAddedUnlockedOverlays[[NSString duxbeta_flyZoneProviderAccessKeyWithFlyZone:flyZone]] = noFlyZoneCircle;
}

- (void)addOverlayForCylinderSubFlyZone:(DJISubFlyZoneInformation *)subFlyZone
                          withinFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapFlyZoneCircleOverlay *subFlyZoneCircle = [self subFlyZoneCircleOverlayWithSubFlyZone:subFlyZone];
    self.mutableAddedLockedOverlays[[NSString duxbeta_subFlyZoneProviderAccessKeyWithFlyZone:flyZone subFlyZone:subFlyZone]] = subFlyZoneCircle;
}

- (void)addOverlayForPolygonSubFlyZone:(DJISubFlyZoneInformation *)subFlyZone
                         withinFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapSubFlyZonePolygonOverlay *subFlyZonePolygonOverlay = [self subFlyZonePolygonOverlayWithSubFlyZonePolygon:subFlyZone
                                                                                                     withinFlyZone:flyZone];
    self.mutableAddedLockedOverlays[[NSString duxbeta_subFlyZoneProviderAccessKeyWithFlyZone:flyZone subFlyZone:subFlyZone]] = subFlyZonePolygonOverlay;
}

- (void)addOverlayForCustomUnlockZone:(DJICustomUnlockZone *)flyZone
                       sentToAircraft:(BOOL)sentToAircraft
                    enabledOnAircraft:(BOOL)enabledOnAircraft {
    DUXBetaMapFlyZoneCircleOverlay *noFlyZoneOverlay = [self customUnlockFlyZoneCircleOverlayWithFlyZone:flyZone
                                                                                      sentToAircraft:sentToAircraft
                                                                                   enabledOnAircraft:enabledOnAircraft];
    self.mutableAddedCustomUnlockedOverlays[[NSString duxbeta_customUnlockZoneProviderAccessKeyWithFlyZone:flyZone]] = noFlyZoneOverlay;
}

#pragma mark - Generating Overlays

- (DUXBetaMapFlyZoneCircleOverlay *)noFlyZoneCircleOverlayWithFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapFlyZoneCircleOverlay *noFlyZoneCircle = [DUXBetaMapFlyZoneCircleOverlay circleWithCenterCoordinate:flyZone.center
                                                                                                      radius:flyZone.radius];
    noFlyZoneCircle.flyZoneType = DJIFlyZoneTypeCircle;
    noFlyZoneCircle.category = flyZone.category;
    noFlyZoneCircle.noFlyZoneID = @(flyZone.flyZoneID);
    noFlyZoneCircle.isUnlocked = [flyZone isUnlocked];
    return noFlyZoneCircle;
}

- (DUXBetaMapFlyZoneCircleOverlay *)subFlyZoneCircleOverlayWithSubFlyZone:(DJISubFlyZoneInformation *)subFlyZone {
    DUXBetaMapFlyZoneCircleOverlay *subFlyZoneCircle = [DUXBetaMapFlyZoneCircleOverlay circleWithCenterCoordinate:subFlyZone.center
                                                                                                       radius:subFlyZone.radius];
  
    return subFlyZoneCircle;
}

- (DUXBetaMapSubFlyZonePolygonOverlay *)subFlyZonePolygonOverlayWithSubFlyZonePolygon:(DJISubFlyZoneInformation *)subFlyZonePolygon
                                                                    withinFlyZone:(DJIFlyZoneInformation *)flyZone {
    // You have to populate an array of coordinates to create a polygon
    NSArray *vertices = subFlyZonePolygon.vertices;
    CLLocationCoordinate2D coordinates[vertices.count];
    for (int i = 0; i < vertices.count; i++) {
        NSValue *value = [vertices objectAtIndex:i];
        CLLocationCoordinate2D coordinate;
        [value getValue:&coordinate];
        coordinates[i] = coordinate;
    }
    
    DUXBetaMapSubFlyZonePolygonOverlay *subFlyZonePolygonOverlay = [DUXBetaMapSubFlyZonePolygonOverlay polygonWithCoordinates:coordinates
                                                                                                                count:vertices.count];
    subFlyZonePolygonOverlay.maxFlightHeight = subFlyZonePolygon.maximumFlightHeight;
    subFlyZonePolygonOverlay.category = flyZone.category;
    return subFlyZonePolygonOverlay;
}

- (DUXBetaMapFlyZoneCircleOverlay *)customUnlockFlyZoneCircleOverlayWithFlyZone:(DJICustomUnlockZone *)flyZone
                                                             sentToAircraft:(BOOL)sentToAircraft
                                                          enabledOnAircraft:(BOOL)enabledOnAircraft {
    DUXBetaMapFlyZoneCircleOverlay *noFlyZoneCircle = [DUXBetaMapFlyZoneCircleOverlay circleWithCenterCoordinate:flyZone.center
                                                                                                  radius:flyZone.radius];
    noFlyZoneCircle.flyZoneType = DJIFlyZoneTypeCircle;
    noFlyZoneCircle.noFlyZoneID = @(flyZone.ID);
    noFlyZoneCircle.isCustomUnlockZone = YES;
    noFlyZoneCircle.isCustomUnlockZoneSentToAircraft = sentToAircraft;
    noFlyZoneCircle.isCustomUnlockZoneEnabled = enabledOnAircraft;
    return noFlyZoneCircle;
}

- (BOOL)filterWithCategory:(DJIFlyZoneCategory)category {
    if (category == DJIFlyZoneCategoryRestricted) {
        return !(self.mapWidget.visibleFlyZones & DUXBetaMapVisibleFlyZonesRestricted);
    } else if (category == DJIFlyZoneCategoryAuthorization) {
        return !(self.mapWidget.visibleFlyZones & DUXBetaMapVisibleFlyZonesAuthorization);
    } else if (category == DJIFlyZoneCategoryEnhancedWarning) {
        return !(self.mapWidget.visibleFlyZones & DUXBetaMapVisibleFlyZonesEnhancedWarning);
    } else if (category == DJIFlyZoneCategoryWarning) {
        return !(self.mapWidget.visibleFlyZones & DUXBetaMapVisibleFlyZonesWarning);
    } else /*if (category == DJIFlyZoneCategoryUnknown)*/ {
        return NO;
    }
}

#pragma mark - Public Properties

- (NSArray <id <MKOverlay>> *)allOverlays {
    // Combine locked and unlocked overlays together, unlocked overlays will replace locked ones
    NSMutableArray *allOverlays = [NSMutableArray array];
    
    for (NSString *flyZoneIdentifier in self.mutableAllLockedOverlays.allKeys) {
        if (self.mapWidget.flyZones[flyZoneIdentifier] != nil) {
            DJIFlyZoneInformation *flyZone = (DJIFlyZoneInformation *)self.mapWidget.flyZones[flyZoneIdentifier];
            if ([self filterWithCategory:flyZone.category]) {
                if (self.mutableAllUnlockedOverlays[flyZoneIdentifier] == nil) {
                    [allOverlays addObject:self.mutableAllLockedOverlays[flyZoneIdentifier]];
                } else {
                    [allOverlays addObject:self.mutableAllUnlockedOverlays[flyZoneIdentifier]];
                }
            } else {
                // Do nothing, zone's filtered out
            }
        } else {
            // Sub fly zones cannot be unlocked for now, just check for parent zone category
            DJIFlyZoneInformation *parentFlyZone = self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier];
            if ([self filterWithCategory:parentFlyZone.category]) {
                [allOverlays addObject:self.mutableAllLockedOverlays[flyZoneIdentifier]];
            }
        }
    }
    
    return [NSArray arrayWithArray:allOverlays];
}

- (NSArray<id<MKOverlay>> *)addedOverlays {
    NSMutableArray *addedOverlays = [NSMutableArray array];
    
    for (NSString *flyZoneIdentifier in self.mutableAddedLockedOverlays.allKeys) {
        //If added fly zone not already in all overlays and not filtered out, then add it to added
        if (self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier]) {
            DJIFlyZoneInformation *flyZone = self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier];
            if (![self filterWithCategory:flyZone.category]) {
                [addedOverlays addObject:self.mutableAddedLockedOverlays[flyZoneIdentifier]];
            }
        } else if (self.mapWidget.flyZones[flyZoneIdentifier]) {
            DJIFlyZoneInformation *flyZone = self.mapWidget.flyZones[flyZoneIdentifier];
            if (![self filterWithCategory:flyZone.category]) {
                [addedOverlays addObject:self.mutableAddedLockedOverlays[flyZoneIdentifier]];
            }
        }
    }
    
    for (NSString *flyZoneIdentifier in self.mutableAddedUnlockedOverlays.allKeys) {
        DJIFlyZoneInformation *flyZone = self.mapWidget.unlockedFlyZones[flyZoneIdentifier];
        if (![self filterWithCategory:flyZone.category]) {
            [addedOverlays addObject:self.mutableAddedUnlockedOverlays[flyZoneIdentifier]];
        }
    }

    if (self.mapWidget.showCustomUnlockZones) {
        for (NSString *flyZoneIdentifier in self.mutableAddedCustomUnlockedOverlays.allKeys) {
            [addedOverlays addObject:self.mutableAddedCustomUnlockedOverlays[flyZoneIdentifier]];
        }
    }

    return addedOverlays;
}

- (NSArray<id<MKOverlay>> *)removedOverlays {
    NSMutableArray *removedOverlays = [NSMutableArray array];
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedLockedOverlays.allKeys) {
        [removedOverlays addObject:self.mutableRemovedLockedOverlays[flyZoneIdentifier]];
    }
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedUnlockedOverlays.allKeys) {
        [removedOverlays addObject:self.mutableRemovedUnlockedOverlays[flyZoneIdentifier]];
    }
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedCustomUnlockedOverlays.allKeys) {
        [removedOverlays addObject:self.mutableRemovedCustomUnlockedOverlays[flyZoneIdentifier]];
    }
    
    return removedOverlays;
}

@end
