//
//  DUXBetaAnnotationProvider.m
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

#import "DUXBetaAnnotationProvider.h"
#import "DUXBetaMapWidget_Protected.h"
#import "DUXBetaMapSubFlyZoneAnnotation.h"
#import "DUXBetaMapNoFlyZoneAnnotation.h"
#import "DUXBetaMapWidget.h"
@import DJIUXSDKCore;

@interface DUXBetaAnnotationProvider ()

@property (nonatomic, strong) NSMutableDictionary *mutableAddedLockedAnnotations;
@property (nonatomic, strong) NSMutableDictionary *mutableRemovedLockedAnnotations;

@property (nonatomic, strong) NSMutableDictionary *mutableAllLockedAnnotations;

@property (nonatomic, strong) NSMutableDictionary *mutableAddedUnlockedAnnotations;
@property (nonatomic, strong) NSMutableDictionary *mutableRemovedUnlockedAnnotations;

@property (nonatomic, strong) NSMutableDictionary *mutableAllUnlockedAnnotations;

@property (nonatomic, strong) NSMutableDictionary *mutableAddedCustomUnlockedAnnotations;
@property (nonatomic, strong) NSMutableDictionary *mutableRemovedCustomUnlockedAnnotations;

@property (nonatomic, strong) NSMutableDictionary *mutableAllCustomUnlockedAnnotations;

@end

@implementation DUXBetaAnnotationProvider

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableAddedLockedAnnotations = [NSMutableDictionary dictionary];
        _mutableRemovedLockedAnnotations = [NSMutableDictionary dictionary];
        _mutableAllLockedAnnotations = [NSMutableDictionary dictionary];
        
        _mutableAddedUnlockedAnnotations = [NSMutableDictionary dictionary];
        _mutableRemovedUnlockedAnnotations = [NSMutableDictionary dictionary];
        _mutableAllUnlockedAnnotations = [NSMutableDictionary dictionary];
        
        _mutableAddedCustomUnlockedAnnotations = [NSMutableDictionary dictionary];
        _mutableRemovedCustomUnlockedAnnotations = [NSMutableDictionary dictionary];
        _mutableAllCustomUnlockedAnnotations = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Update Methods
- (void)beginLockedFlyZoneUpdates {
    self.mutableAddedLockedAnnotations = [NSMutableDictionary dictionary];
}

- (void)endLockedFlyZoneUpdates {
    NSArray *allAddedLockedAnnotationsKeys = self.mutableAddedLockedAnnotations.allKeys;
    for (NSString *flyZoneIdentifier in allAddedLockedAnnotationsKeys) {
        if (self.mutableAddedUnlockedAnnotations[flyZoneIdentifier] != nil) {
            [self.mutableAddedLockedAnnotations removeObjectForKey:flyZoneIdentifier];
        }
    }

    for (NSString *flyZoneIdentifier in self.mutableAllLockedAnnotations.allKeys) {
        if (self.mutableAddedLockedAnnotations[flyZoneIdentifier] == nil) {
            self.mutableRemovedLockedAnnotations[flyZoneIdentifier] = self.mutableAllLockedAnnotations[flyZoneIdentifier];
        }
    }
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedLockedAnnotations.allKeys) {
        [self.mutableAllLockedAnnotations removeObjectForKey:flyZoneIdentifier];
    }
    
    [self recomputeAllLockedFlyZones];
}

- (void)beginUnlockedFlyZoneUpdates {
    self.mutableAddedUnlockedAnnotations = [NSMutableDictionary dictionary];
}

- (void)endUnlockedFlyZoneUpdates {
    for (NSString *flyZoneIdentifier in self.mutableAllUnlockedAnnotations.allKeys) {
        if (self.mutableAddedUnlockedAnnotations[flyZoneIdentifier] == nil) {
            self.mutableRemovedUnlockedAnnotations[flyZoneIdentifier] = self.mutableAllUnlockedAnnotations[flyZoneIdentifier];
        } else {
            if (self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier]) {
                DJIFlyZoneInformation *flyZone = self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier];
                if ([self filterWithCategory:flyZone.category]) {
                    self.mutableRemovedUnlockedAnnotations[flyZoneIdentifier] = self.mutableAllUnlockedAnnotations[flyZoneIdentifier];
                }
            } else if (self.mapWidget.unlockedFlyZones[flyZoneIdentifier]) {
                DJIFlyZoneInformation *flyZone = self.mapWidget.unlockedFlyZones[flyZoneIdentifier];
                if ([self filterWithCategory:flyZone.category]) {
                    self.mutableRemovedUnlockedAnnotations[flyZoneIdentifier] = self.mutableAllUnlockedAnnotations[flyZoneIdentifier];
                }
            }
        }
    }
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedUnlockedAnnotations) {
        [self.mutableAllUnlockedAnnotations removeObjectForKey:flyZoneIdentifier];
    }
    
    [self recomputeAllUnlockedFlyZones];
}

- (void)beginCustomUnlockedFlyZoneUpdates {
    self.mutableAddedCustomUnlockedAnnotations = [NSMutableDictionary dictionary];
}

- (void)endCustomUnlockedFlyZoneUpdates {
    NSArray *allCustomUnlockedAnnotationsKeys = [self.mutableAllCustomUnlockedAnnotations.allKeys copy];
    
    for (NSString *flyZoneIdentifier in allCustomUnlockedAnnotationsKeys) {
        if (![self.mutableAddedCustomUnlockedAnnotations.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableRemovedCustomUnlockedAnnotations[flyZoneIdentifier] = self.mutableAllCustomUnlockedAnnotations[flyZoneIdentifier];
        }
    }
    
    [self recomputeAllCustomUnlockedFlyZones];
}

- (void)recomputeAllLockedFlyZones {
    NSArray *allMutableAddedLockedAnnotationsKeys = self.mutableAddedLockedAnnotations.allKeys;
    for (NSString *flyZoneIdentifier in allMutableAddedLockedAnnotationsKeys) {
        if (![self.mutableAllLockedAnnotations.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableAllLockedAnnotations[flyZoneIdentifier] = self.mutableAddedLockedAnnotations[flyZoneIdentifier];
        }
    }
    
    NSArray *allMutableAllLockedAnnotationsKeys = self.mutableAllLockedAnnotations.allKeys;
    for (NSString *flyZoneIdentifier in allMutableAllLockedAnnotationsKeys) {
        if (![self.mutableAddedLockedAnnotations.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableRemovedLockedAnnotations[flyZoneIdentifier] = self.mutableAllLockedAnnotations[flyZoneIdentifier];
        }
    }
}

- (void)recomputeAllUnlockedFlyZones {
    NSArray *allMutableAddedUnlockedAnnotationsKeys = self.mutableAddedUnlockedAnnotations.allKeys;
    for (NSString *flyZoneIdentifier in allMutableAddedUnlockedAnnotationsKeys) {
        if (![self.mutableAllUnlockedAnnotations.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableAllUnlockedAnnotations[flyZoneIdentifier] = self.mutableAddedUnlockedAnnotations[flyZoneIdentifier];
        }
    }
    
    NSArray *allMutableAllUnlockedAnnotationsKeys = self.mutableAllUnlockedAnnotations.allKeys;
    for (NSString *flyZoneIdentifier in allMutableAllUnlockedAnnotationsKeys) {
        if (![self.mutableAddedUnlockedAnnotations.allKeys containsObject:flyZoneIdentifier]) {
            self.mutableRemovedUnlockedAnnotations[flyZoneIdentifier] = self.mutableAllUnlockedAnnotations[flyZoneIdentifier];
        }
    }
}

- (void)recomputeAllCustomUnlockedFlyZones {
    self.mutableAllCustomUnlockedAnnotations = [self.mutableAddedCustomUnlockedAnnotations mutableCopy];
    
    if (self.mapWidget.showCustomUnlockZones) {
        for (NSString *flyZoneIdentifier in self.mutableAddedCustomUnlockedAnnotations) {
            if (![self.mutableAllCustomUnlockedAnnotations.allKeys containsObject:flyZoneIdentifier]) {
                self.mutableAllCustomUnlockedAnnotations[flyZoneIdentifier] = self.mutableAddedCustomUnlockedAnnotations[flyZoneIdentifier];
            }
        }
    } else {
        [self.mutableRemovedCustomUnlockedAnnotations addEntriesFromDictionary:self.mutableAllCustomUnlockedAnnotations];
    }
}

#pragma mark - Annotation Handling

- (void)addAnnotationForSubFlyZone:(DJISubFlyZoneInformation *)subFlyZone
                     withinFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapSubFlyZoneAnnotation *subFlyZoneAnnotation = [self subFlyZoneAnnotationForSubFlyZone:subFlyZone];
    self.mutableAddedLockedAnnotations[[NSString duxbeta_subFlyZoneProviderAccessKeyWithFlyZone:flyZone subFlyZone:subFlyZone]] = subFlyZoneAnnotation;
}

- (void)addAnnotationForLockedFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapNoFlyZoneAnnotation *flyZoneAnnotation = [self flyZoneAnnotationForFlyZone:flyZone];
    self.mutableAddedLockedAnnotations[[NSString duxbeta_flyZoneProviderAccessKeyWithFlyZone:flyZone]] = flyZoneAnnotation;
}

- (void)addAnnotationForUnlockedFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapNoFlyZoneAnnotation *flyZoneAnnotation = [self flyZoneAnnotationForFlyZone:flyZone];
    self.mutableAddedUnlockedAnnotations[[NSString duxbeta_flyZoneProviderAccessKeyWithFlyZone:flyZone]] = flyZoneAnnotation;
}

- (void)addAnnotationForCustomUnlockZone:(DJICustomUnlockZone *)flyZone
                          sentToAircraft:(BOOL)sentToAircraft
                       enabledOnAircraft:(BOOL)enabledOnAircraft {
    DUXBetaMapNoFlyZoneAnnotation *flyZoneAnnotation = [self flyZoneAnnotationForCustomUnlockZone:flyZone
                                                                               sentToAircraft:sentToAircraft
                                                                            enabledOnAircraft:enabledOnAircraft];
    self.mutableAddedCustomUnlockedAnnotations[[NSString duxbeta_customUnlockZoneProviderAccessKeyWithFlyZone:flyZone]] = flyZoneAnnotation;
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

- (NSArray <id <MKOverlay>> *)allAnnotations {
    // Combine locked and unlocked Annotations together, unlocked Annotations will replace locked ones
    NSMutableArray *allAnnotations = [NSMutableArray array];
    
    for (NSString *flyZoneIdentifier in self.mutableAllLockedAnnotations.allKeys) {
        if (self.mapWidget.flyZones[flyZoneIdentifier] != nil) {
            DJIFlyZoneInformation *flyZone = (DJIFlyZoneInformation *)self.mapWidget.flyZones[flyZoneIdentifier];
            if ([self filterWithCategory:flyZone.category]) {
                if (self.mutableAllUnlockedAnnotations[flyZoneIdentifier] == nil) {
                    [allAnnotations addObject:self.mutableAllLockedAnnotations[flyZoneIdentifier]];
                } else {
                    [allAnnotations addObject:self.mutableAllUnlockedAnnotations[flyZoneIdentifier]];
                }
            } else {
                // Do nothing, zone's filtered out
            }
        } else {
            // Sub fly zones cannot be unlocked for now, just check for parent zone category
            DJIFlyZoneInformation *parentFlyZone = self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier];
            if ([self filterWithCategory:parentFlyZone.category]) {
                [allAnnotations addObject:self.mutableAllLockedAnnotations[flyZoneIdentifier]];
            }
        }
    }
    
    return [NSArray arrayWithArray:allAnnotations];
}

- (NSArray<id<MKOverlay>> *)addedAnnotations {
    NSMutableArray *addedAnnotations = [NSMutableArray array];
    
    for (NSString *flyZoneIdentifier in self.mutableAddedLockedAnnotations.allKeys) {
        //If added fly zone not already in all Annotations and not filtered out, then add it to added
        if (self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier]) {
            DJIFlyZoneInformation *flyZone = self.mapWidget.subFlyZonesParentFlyZones[flyZoneIdentifier];
            if (![self filterWithCategory:flyZone.category]) {
                [addedAnnotations addObject:self.mutableAddedLockedAnnotations[flyZoneIdentifier]];
            }
        } else if (self.mapWidget.flyZones[flyZoneIdentifier]) {
            DJIFlyZoneInformation *flyZone = self.mapWidget.flyZones[flyZoneIdentifier];
            if (![self filterWithCategory:flyZone.category]) {
                [addedAnnotations addObject:self.mutableAddedLockedAnnotations[flyZoneIdentifier]];
            }
        }
    }
    
    for (NSString *flyZoneIdentifier in self.mutableAddedUnlockedAnnotations.allKeys) {
        DJIFlyZoneInformation *flyZone = self.mapWidget.unlockedFlyZones[flyZoneIdentifier];
        if (![self filterWithCategory:flyZone.category]) {
            [addedAnnotations addObject:self.mutableAddedUnlockedAnnotations[flyZoneIdentifier]];
        }
    }
    
    if (self.mapWidget.showCustomUnlockZones) {
        for (NSString *flyZoneIdentifier in self.mutableAddedCustomUnlockedAnnotations.allKeys) {
            [addedAnnotations addObject:self.mutableAddedCustomUnlockedAnnotations[flyZoneIdentifier]];
        }
    }

    return addedAnnotations;
}

- (NSArray<id<MKOverlay>> *)removedAnnotations {
    NSMutableArray *removedAnnotations = [NSMutableArray array];
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedLockedAnnotations.allKeys) {
        [removedAnnotations addObject:self.mutableRemovedLockedAnnotations[flyZoneIdentifier]];
    }
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedUnlockedAnnotations.allKeys) {
        [removedAnnotations addObject:self.mutableRemovedUnlockedAnnotations[flyZoneIdentifier]];
    }
    
    for (NSString *flyZoneIdentifier in self.mutableRemovedCustomUnlockedAnnotations.allKeys) {
        [removedAnnotations addObject:self.mutableRemovedCustomUnlockedAnnotations[flyZoneIdentifier]];
    }
    
    return removedAnnotations;
}


#pragma mark - Generating Annotations

- (DUXBetaMapSubFlyZoneAnnotation *)subFlyZoneAnnotationForSubFlyZone:(DJISubFlyZoneInformation *)subFlyZone {
    DUXBetaMapSubFlyZoneAnnotation *subFlyZoneAnnotation = [[DUXBetaMapSubFlyZoneAnnotation alloc] initWithCoordinate:subFlyZone.center];
    subFlyZoneAnnotation.height = subFlyZone.maximumFlightHeight;
    subFlyZoneAnnotation.title = [NSString stringWithFormat:@"%ld m", (long)subFlyZone.maximumFlightHeight];
    return subFlyZoneAnnotation;
}

- (DUXBetaMapNoFlyZoneAnnotation *)flyZoneAnnotationForFlyZone:(DJIFlyZoneInformation *)flyZone {
    DUXBetaMapNoFlyZoneAnnotation *flyZoneAnnotation = [[DUXBetaMapNoFlyZoneAnnotation alloc] initWithCoordinate:flyZone.center];
    flyZoneAnnotation.title = flyZone.name;
    flyZoneAnnotation.noFlyZoneID = @(flyZone.flyZoneID);
    flyZoneAnnotation.isUnlocked = [flyZone isUnlocked];
    flyZoneAnnotation.isUnlockable = YES;

    if ([flyZone isUnlocked]) {
        flyZoneAnnotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"Currently unlocked and expires at %@", "Map widget fly zone callout text"),flyZone.unlockEndTime];
    }
    
    return flyZoneAnnotation;
}

- (DUXBetaMapNoFlyZoneAnnotation *)flyZoneAnnotationForCustomUnlockZone:(DJICustomUnlockZone *)flyZone
                                                     sentToAircraft:(BOOL)sentToAircraft
                                                  enabledOnAircraft:(BOOL)enabledOnAircraft {
    DUXBetaMapNoFlyZoneAnnotation *flyZoneAnnotation = [[DUXBetaMapNoFlyZoneAnnotation alloc] initWithCoordinate:flyZone.center];
    flyZoneAnnotation.title = flyZone.name;
    flyZoneAnnotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"Currently unlocked and expires at %@", "Map widget fly zone callout text"),flyZone.endTime];
    flyZoneAnnotation.noFlyZoneID = @(flyZone.ID);
    flyZoneAnnotation.isCustomUnlockZone = YES;
    flyZoneAnnotation.isCustomUnlockZoneSentToAircraft = sentToAircraft;
    flyZoneAnnotation.isCustomUnlockZoneEnabled = enabledOnAircraft;

    return flyZoneAnnotation;
}

@end
