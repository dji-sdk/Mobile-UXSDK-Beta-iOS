//
//  DUXBetaFlyZoneDataSource.m
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

#import "DUXBetaFlyZoneDataProvider.h"
#import "DUXBetaFlyZoneDataProviderModel.h"
@import DJIUXSDKCore;

@interface DUXBetaFlyZoneDataProvider ()

@end

@implementation DUXBetaFlyZoneDataProvider

- (instancetype)init {
    return [self initWithFlyZoneManager:[DJISDKManager flyZoneManager]];
}

- (nonnull instancetype)initWithFlyZoneManager:(nonnull DJIFlyZoneManager *)flyZoneManager {
    self = [super init];
    if (self) {
        _flyZoneManager = flyZoneManager;
        _needsCustomUnlockZones = NO;
        _model = [[DUXBetaFlyZoneDataProviderModel alloc] init];
        [_model setup];
    }    
    BindRKVOModel(self.model, @selector(productSerialNumberChanged), productSerialNumber);
    return self;
}

- (nonnull instancetype)initWithFlyZoneManager:(nonnull DJIFlyZoneManager *)flyZoneManager UserAccountManager:(nonnull DJIUserAccountManager *)userAccountManager {
    self = [super init];
    if (self) {
        _flyZoneManager = flyZoneManager;
        _userAccountManager = userAccountManager;
        _needsCustomUnlockZones = NO;
        _model = [[DUXBetaFlyZoneDataProviderModel alloc] init];
        [_model setup];
    }
    BindRKVOModel(self.model, @selector(productSerialNumberChanged), productSerialNumber);
    return self;
}

- (void)dealloc {
    [self.model duxbeta_removeCustomObserver:self];
    [self.model cleanup];
}

- (void)refreshNearbyVisibleFlyZonesOfCategory:(DUXBetaMapVisibleFlyZones)visibleFlyZones {
    __weak typeof(self) target = self;
    [self.flyZoneManager reloadUnlockedZoneGroupsFromServerWithCompletion:^(NSError * _Nullable error) {
        [self.flyZoneManager getUnlockedFlyZonesForAircraftWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
        
            if (error) {
                NSLog(@"Error Getting Unlocked Fly Zones: %@", error);
            } else {
                NSMutableArray *filteredInfos = [NSMutableArray array];
                for (DJIFlyZoneInformation *info in infos) {
                    if ((info.category == DJIFlyZoneCategoryRestricted && ((visibleFlyZones & DUXBetaMapVisibleFlyZonesRestricted) == NO)) ||
                        (info.category == DJIFlyZoneCategoryAuthorization && ((visibleFlyZones & DUXBetaMapVisibleFlyZonesAuthorization) == NO)) ||
                        (info.category == DJIFlyZoneCategoryWarning && ((visibleFlyZones & DUXBetaMapVisibleFlyZonesWarning) == NO)) ||
                        (info.category == DJIFlyZoneCategoryEnhancedWarning && ((visibleFlyZones & DUXBetaMapVisibleFlyZonesEnhancedWarning) == NO))) {
                            [filteredInfos addObject:info];
                    }
                }
            
                NSMutableArray *relevantFlyZones = [infos mutableCopy];
                [relevantFlyZones removeObjectsInArray:filteredInfos];
                
                NSMutableDictionary *flyZoneDictionary = [NSMutableDictionary dictionary];
                for (DJIFlyZoneInformation *info in relevantFlyZones) {
                    flyZoneDictionary[[NSString duxbeta_flyZoneProviderAccessKeyWithFlyZone:info]] = info;
                }
            
                if (target.delegate && [target.delegate respondsToSelector:@selector(flyZoneDataProvider:didUpdateUnlockedFlyZones:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [target.delegate flyZoneDataProvider:target
                                   didUpdateUnlockedFlyZones:flyZoneDictionary];
                    });
                }
            }
            
            [self.flyZoneManager getFlyZonesInSurroundingAreaWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
                if (error != nil || infos == nil) {
                    return;
                }
                
                if ([target.delegate respondsToSelector:@selector(flyZoneDataProvider:didUpdateFlyZones:)]) {
                    NSMutableDictionary *flyZoneDict = [NSMutableDictionary new];
                    for (DJIFlyZoneInformation *info in infos) {
                        [flyZoneDict setObject:info
                                        forKey:[NSString duxbeta_flyZoneProviderAccessKeyWithFlyZone:info]];
                    }
                    
                    NSMutableArray *removedKeys = [NSMutableArray array];
                    for (NSString *key in [flyZoneDict allKeys]) {
                        DJIFlyZoneInformation *info = flyZoneDict[key];
                        if ((info.category == DJIFlyZoneCategoryRestricted && ((visibleFlyZones & DUXBetaMapVisibleFlyZonesRestricted) == NO)) ||
                            (info.category == DJIFlyZoneCategoryAuthorization && ((visibleFlyZones & DUXBetaMapVisibleFlyZonesAuthorization) == NO)) ||
                            (info.category == DJIFlyZoneCategoryWarning && ((visibleFlyZones & DUXBetaMapVisibleFlyZonesWarning) == NO)) ||
                            (info.category == DJIFlyZoneCategoryEnhancedWarning && ((visibleFlyZones & DUXBetaMapVisibleFlyZonesEnhancedWarning) == NO))) {
                            [removedKeys addObject:key];
                        }
                    }
                    
                    for (NSNumber *key in removedKeys) {
                        [flyZoneDict removeObjectForKey:key];
                    }
            
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [target.delegate flyZoneDataProvider:target
                                           didUpdateFlyZones:flyZoneDict];
                    });
                }
            }];
        }];
    }];
}

- (void)unlockFlyZonesWithFlyZoneIDs:(NSArray <NSNumber *> *)flyZoneIDs {
    DJIUserAccountState currentUserAccountState = self.userAccountManager.userAccountState;
    __weak typeof(self) target = self;
    if (currentUserAccountState == DJIUserAccountStateNotLoggedIn || currentUserAccountState == DJIUserAccountStateTokenOutOfDate) {
        // Present message to login
        if (self.delegate && [self.delegate respondsToSelector:@selector(flyZoneDataProvider:requestsPresentationOfAlertWithTitle:alertMessage:loginAccountStateCompletion:)]) {
            [self.delegate flyZoneDataProvider:self
          requestsPresentationOfAlertWithTitle:NSLocalizedString(@"Unlock Requires DJI Login", "Map widget fly zone unlocking alert")
                                  alertMessage:NSLocalizedString(@"In order to unlock fly zones you must login with your DJI account. Tap Login to continue logging in.", "Map widget fly zone unlocking alert")
                   loginAccountStateCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
                [target unlockFlyZonesWithFlyZoneIDs:flyZoneIDs];
            }];
        }
    } else if (currentUserAccountState == DJIUserAccountStateNotAuthorized || currentUserAccountState == DJIUserAccountStateUnknown) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(flyZoneDataProvider:abortedUnlockingProcessWithCurrentUserAccountState:)]) {
            [self.delegate flyZoneDataProvider:self abortedUnlockingProcessWithCurrentUserAccountState:currentUserAccountState];
        }
    } else if (currentUserAccountState == DJIUserAccountStateAuthorized) {
        [self.flyZoneManager unlockFlyZones:flyZoneIDs
                                        withCompletion:^(NSError * _Nullable error) {
            if (error) {
                if (target.delegate && [target.delegate respondsToSelector:@selector(flyZoneDataProvider:unsuccessfullyUnlockedFlyZonesWithIDs:withError:)]) {
                    [target.delegate flyZoneDataProvider:self unsuccessfullyUnlockedFlyZonesWithIDs:flyZoneIDs withError:error];
                }
            } else {
                [self refreshNearbyVisibleFlyZonesOfCategory:DUXBetaMapVisibleFlyZonesAuthorization];
                if (target.delegate && [target.delegate respondsToSelector:@selector(flyZoneDataProvider:successfullyUnlockedFlyZonesWithIDs:)]) {
                    [target.delegate flyZoneDataProvider:self successfullyUnlockedFlyZonesWithIDs:flyZoneIDs];
                }
            }
        }];
    }
}

- (void)productSerialNumberChanged {
    [self getCustomUnlockedZones];
    if (self.model.productSerialNumber) {
        [self getEnabledCustomUnlockFlyZone];
    }
}

- (void)getCustomUnlockedZones {
    //If testing we want to ignore the user account state.
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"DJIUXSDKTesting"]) {
        __weak typeof(self) target = self;
        [self.flyZoneManager getLoadedUnlockedZoneGroupsWithCompletion:^(NSArray<DJIUnlockedZoneGroup *> * _Nullable groups,
                                                                         NSError * _Nullable error) {
            if (!error) {
                for (DJIUnlockedZoneGroup *group in groups) {
                    if ([group.SN isEqualToString:self.model.productSerialNumber]) {
                        [target processUnlockedZoneGroup:group];
                    }
                }
            }
        }];
    } else {
        __weak typeof(self)target = self;
        DJIUserAccountState currentUserAccountState = self.userAccountManager.userAccountState;
        if (!self.needsCustomUnlockZones) {
            return;
        }
        if (currentUserAccountState == DJIUserAccountStateNotLoggedIn || currentUserAccountState == DJIUserAccountStateTokenOutOfDate) {
            // Present message to login
            if (self.delegate && [self.delegate respondsToSelector:@selector(flyZoneDataProvider:requestsPresentationOfAlertWithTitle:alertMessage:loginAccountStateCompletion:)]) {
                [self.delegate flyZoneDataProvider:self
              requestsPresentationOfAlertWithTitle:NSLocalizedString(@"Custom Unlock Requires DJI Login", "Map widget fly zone unlocking alert")
                                      alertMessage:NSLocalizedString(@"In order to retrieve custom unlock fly zones you must login with your DJI account, please make sure the serial number of the aircraft you are connected to matches your custom unlock records. Tap Login to continue logging in.", "Map widget fly zone unlocking alert")
                       loginAccountStateCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
                    [target getCustomUnlockedZones];
                }];
            }
        } else if (currentUserAccountState == DJIUserAccountStateNotAuthorized || currentUserAccountState == DJIUserAccountStateUnknown) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(flyZoneDataProvider:abortedUnlockingProcessWithCurrentUserAccountState:)]) {
                [self.delegate flyZoneDataProvider:self abortedUnlockingProcessWithCurrentUserAccountState:currentUserAccountState];
            }
        } else if (currentUserAccountState == DJIUserAccountStateAuthorized) {
            __weak typeof(self) target = self;
            [self.flyZoneManager getLoadedUnlockedZoneGroupsWithCompletion:^(NSArray<DJIUnlockedZoneGroup *> * _Nullable groups,
                                                                             NSError * _Nullable error) {
                if (!error) {
                    for (DJIUnlockedZoneGroup *group in groups) {
                        if ([group.SN isEqualToString:self.model.productSerialNumber]) {
                            [target processUnlockedZoneGroup:group];
                        }
                    }
                }
            }];
        }
    }
}

- (void)getEnabledCustomUnlockFlyZone {
    if (!self.needsCustomUnlockZones) {
        return;
    }
    __weak typeof(self)target = self;
    [self.flyZoneManager getEnabledCustomUnlockZoneWithCompletion:^(DJICustomUnlockZone * _Nullable zone, NSError * _Nullable error) {
        if (zone && target.delegate && [target.delegate respondsToSelector:@selector(flyZoneDataProvider:didUpdateCustomUnlockZones:)]) {
            [target.delegate flyZoneDataProvider:target
                didUpdateEnabledCustomUnlockZone:zone];
        }
    }];
}

- (void)processUnlockedZoneGroup:(DJIUnlockedZoneGroup *)unlockedZoneGroup {
    NSMutableDictionary *customUnlockedZoneMapping = [NSMutableDictionary dictionary];
    for (DJICustomUnlockZone *flyZone in unlockedZoneGroup.customUnlockZones) {
        customUnlockedZoneMapping[[NSString duxbeta_customUnlockZoneProviderAccessKeyWithFlyZone:flyZone]] = flyZone;
    }
    
    [self.delegate flyZoneDataProvider:self
            didUpdateCustomUnlockZones:customUnlockedZoneMapping];
}

#pragma mark - DJIFlyZoneDelegate

- (void)flyZoneManager:(DJIFlyZoneManager *)manager didUpdateFlyZoneState:(DJIFlyZoneState)state {
    [self refreshNearbyVisibleFlyZonesOfCategory:DUXBetaMapVisibleFlyZonesNone];
}

- (void)flyZoneManager:(DJIFlyZoneManager *)manager didUpdateBasicDatabaseUpgradeProgress:(float)progress andError:(NSError * _Nullable)error {
    
}

@end
