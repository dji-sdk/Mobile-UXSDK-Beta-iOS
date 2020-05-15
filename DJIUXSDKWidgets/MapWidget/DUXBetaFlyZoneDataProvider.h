//
//  DUXBetaFlyZoneDataSource.h
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

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>
#import <DJIUXSDKWidgets/DUXBetaMapWidget.h>

@class DUXBetaFlyZoneDataProvider;
@class DUXBetaFlyZoneDataProviderModel;

@protocol DUXBetaFlyZoneDataProviderDelegate <NSObject>

- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider didUpdateFlyZones:(nonnull NSDictionary <NSString *, DJIFlyZoneInformation *> *)flyZones;
- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider didUpdateUnlockedFlyZones:(nonnull NSDictionary <NSString *, DJIFlyZoneInformation *> *)flyZones;
- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider requestsPresentationOfAlertWithTitle:(nonnull NSString *)alertTitle alertMessage:(nonnull NSString *)alertMessage loginAccountStateCompletion:(DJIAccountStateCompletionBlock)completion;
- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider successfullyUnlockedFlyZonesWithIDs:(nonnull NSArray <NSNumber *> *)flyZoneIDs;
- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider unsuccessfullyUnlockedFlyZonesWithIDs:(nonnull NSArray <NSNumber *> *)flyZoneIDs withError:(nonnull NSError *)error;
- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider abortedUnlockingProcessWithCurrentUserAccountState:(DJIUserAccountState)userAccountState;
- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider didUpdateCustomUnlockZones:(nonnull NSDictionary <NSString *, DJICustomUnlockZone *> *)customUnlockZones;
- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider didUpdateEnabledCustomUnlockZone:(nullable DJICustomUnlockZone *)customUnlockZone;

@end

@interface DUXBetaFlyZoneDataProvider : NSObject <DJIFlyZoneDelegate>

@property (nonatomic, strong, nonnull) DJIFlyZoneManager *flyZoneManager;

@property (nonatomic, strong, nonnull) DJIUserAccountManager *userAccountManager;

@property BOOL needsCustomUnlockZones;

@property (nonatomic, strong, nonnull) NSDictionary <NSNumber *, DJIFlyZoneInformation *> *flyZones;
@property (nonatomic, strong, nonnull) NSDictionary <NSNumber *, DJIFlyZoneInformation *> *unlockedFlyZones;

@property (nonatomic, strong, nonnull) DUXBetaFlyZoneDataProviderModel *model;
@property (nonatomic, weak, nullable) id<DUXBetaFlyZoneDataProviderDelegate> delegate;

- (nonnull instancetype)initWithFlyZoneManager:(nonnull DJIFlyZoneManager *)flyZoneManager NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)initWithFlyZoneManager:(nonnull DJIFlyZoneManager *)flyZoneManager UserAccountManager:(nonnull DJIUserAccountManager *)userAccountManager NS_DESIGNATED_INITIALIZER; 

- (void)refreshNearbyVisibleFlyZonesOfCategory:(DUXBetaMapVisibleFlyZones)visibleFlyZones;
- (void)getCustomUnlockedZones;
- (void)unlockFlyZonesWithFlyZoneIDs:(nullable NSArray <NSNumber *> *)flyZoneIDs;
- (void)getEnabledCustomUnlockFlyZone;

@end
