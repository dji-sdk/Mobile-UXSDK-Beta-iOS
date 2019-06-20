//
//  DUXBetaMapWidget.m
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

#import "DUXBetaMapWidget.h"
#import "DUXBetaMapWidgetModel.h"
#import "DUXBetaMapView.h"
#import "DUXBetaMapWidget_Protected.h"
#import "DUXBetaFlyZoneDataProvider.h"
#import "DUXBetaOverlayProvider.h"
#import "DUXBetaAnnotationProvider.h"
#import "DUXBetaMapViewLegendViewController.h"
#import "DUXBetaMapViewRenderer.h"
@import DJIUXSDKCore;

static CGSize const kDesignSize = {200.0, 200.0};
@interface DUXBetaMapWidget () <DUXBetaFlyZoneDataProviderDelegate>

@property (nonatomic, strong) DUXBetaMapState *mapState;
@property (nonatomic, strong) DUXBetaMapView *underlyingMapView;
@property (nonatomic, strong) DJICustomUnlockZone *currentlyEnabledCustomUnlockZone;

@property (nonatomic, strong) DUXBetaMapViewLegendViewController *mapViewLegendViewController;
@property (nonatomic, strong) UIButton *loginIndicator;

@end

@implementation DUXBetaMapWidget

/*********************************************************************************/
#pragma mark - System Methods
/*********************************************************************************/

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupFlyZoneDataProvider];
        [self setupDrawableElementsProviders];
        [self setupUnderlyingMapViewMapViewWithFrame:CGRectZero];
        [self setupMapWidgetProperties];
        [self setupLoginIndicator];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupFlyZoneDataProvider];
        [self setupDrawableElementsProviders];
        [self setupUnderlyingMapViewMapViewWithFrame:CGRectZero];
        [self setupMapWidgetProperties];
        [self setupLoginIndicator];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel = [[DUXBetaMapWidgetModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.widgetModel setup];
    BindRKVOModel(self.widgetModel, @selector(updateHomeLocation), homeLocation);
    BindRKVOModel(self.widgetModel, @selector(updateAircraftLocation), aircraftLocation);
    BindRKVOModel(self.widgetModel, @selector(updateAircraftHeading), attitude);
    BindRKVOModel(self.widgetModel, @selector(updateIsHomeLocationSet), isHomeLocationSet);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.widgetModel duxbeta_removeCustomObserver:self];
    [self.widgetModel cleanup];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

/*********************************************************************************/
#pragma mark - RKVO Updates
/*********************************************************************************/

- (void)updateHomeLocation {
    self.mapState.homeLocationCoordinate = self.widgetModel.homeLocation.coordinate;
    [self.underlyingMapView updateMapWithState:self.mapState];
}

- (void)updateAircraftLocation {
    self.mapState.aircraftLocationCoordinate = self.widgetModel.aircraftLocation.coordinate;
    [self.underlyingMapView updateMapWithState:self.mapState];
}

- (void)updateAircraftHeading {
    self.mapState.aircraftHeading = self.widgetModel.attitude.yaw;
    [self.underlyingMapView updateMapWithState:self.mapState];
}

- (void)updateIsHomeLocationSet {
    self.mapState.isHomeLocationSet = self.widgetModel.isHomeLocationSet;
    [self.underlyingMapView updateMapWithState:self.mapState];
}

/*********************************************************************************/
#pragma mark - Getters
/*********************************************************************************/
- (DUXBetaMapState *)mapState {
    if (!_mapState) {
        _mapState = [[DUXBetaMapState alloc] init];
    }
    return _mapState;
}

/*********************************************************************************/
#pragma mark - Setters
/*********************************************************************************/
- (void)setIsMapCameraLockedOnAircraft:(BOOL)isMapCameraLockedOnAircraft {
    if (self.isMapCameraLockedOnHomePoint) {
        self.isMapCameraLockedOnHomePoint = NO;
    }
    
    _isMapCameraLockedOnAircraft = isMapCameraLockedOnAircraft;
    
    __weak typeof(self) target = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (target.isMapCameraLockedOnAircraft) {
            if (!target.underlyingMapView.timerToUpdateCamera) {
                [target.underlyingMapView updateMapCamera];
                target.underlyingMapView.timerToUpdateCamera = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                                                target:target.underlyingMapView
                                                                                              selector:@selector(updateMapCamera)
                                                                                              userInfo:nil
                                                                                               repeats:YES];
            }
        } else {
            [target.underlyingMapView.timerToUpdateCamera invalidate];
            target.underlyingMapView.timerToUpdateCamera = nil;
        }
    });
}

- (void)setIsMapCameraLockedOnHomePoint:(BOOL)isMapCameraLockedOnHomePoint {
    if (self.isMapCameraLockedOnAircraft) {
        self.isMapCameraLockedOnAircraft = NO;
    }
    
    _isMapCameraLockedOnHomePoint = isMapCameraLockedOnHomePoint;
    
    __weak typeof(self) target = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (target.isMapCameraLockedOnHomePoint) {
            if (!target.underlyingMapView.timerToUpdateCamera) {
                [target.underlyingMapView updateMapCamera];
                target.underlyingMapView.timerToUpdateCamera = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                                                target:target.underlyingMapView
                                                                                              selector:@selector(updateMapCamera)
                                                                                              userInfo:nil
                                                                                               repeats:YES];
            }
        } else {
            [target.underlyingMapView.timerToUpdateCamera invalidate];
            target.underlyingMapView.timerToUpdateCamera = nil;
        }
    });
}

- (void)setShowFlightPath:(BOOL)showFlightPath {
    _showFlightPath = showFlightPath;
    self.mapState.showFlightPath = showFlightPath;
    if (showFlightPath) {
        [self.underlyingMapView addOverlays:self.underlyingMapView.flightPathOverlays];
    } else {
        [self.underlyingMapView removeOverlays:self.underlyingMapView.flightPathOverlays];
    }
}

- (void)setShowFlyZoneLegend:(BOOL)showFlyZoneLegend {
    if (_showFlyZoneLegend != showFlyZoneLegend) {
        _showFlyZoneLegend = showFlyZoneLegend;
        if (showFlyZoneLegend) {
            self.mapViewLegendViewController = [[DUXBetaMapViewLegendViewController alloc] init];
            self.mapViewLegendViewController.renderer = self.renderer;
            [self addChildViewController:self.mapViewLegendViewController];
            [self.view addSubview:self.mapViewLegendViewController.view];
            [self didMoveToParentViewController:self.mapViewLegendViewController];
            self.mapViewLegendViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view.bottomAnchor constraintEqualToAnchor:self.mapViewLegendViewController.view.bottomAnchor constant:10.0f].active = YES;
            [self.view.trailingAnchor constraintEqualToAnchor:self.mapViewLegendViewController.view.trailingAnchor constant:10.0f].active = YES;
            [self.view setNeedsLayout];
            
//            [self.mapViewLegendViewController.view.heightAnchor constraintEqualToConstant:260.0f].active = YES;
//            [self.mapViewLegendViewController.view.widthAnchor constraintEqualToConstant:280.0f].active = YES;
            [self.mapViewLegendViewController.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.5].active = YES;
            [self.mapViewLegendViewController.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.5].active = YES;
            [self.mapViewLegendViewController.view setNeedsLayout];
        } else {
            [self.mapViewLegendViewController willMoveToParentViewController:nil];
            [self.mapViewLegendViewController.view removeFromSuperview];
            [self.mapViewLegendViewController removeFromParentViewController];
            self.mapViewLegendViewController = nil;
        }
    }
}

- (void)setShowDirectionToHome:(BOOL)showDirectionToHome {
    _showDirectionToHome = showDirectionToHome;
    self.mapState.showDirectionToHome = showDirectionToHome;
    
    if (showDirectionToHome && self.underlyingMapView.directionToHomePolyline != nil) {
        [self.underlyingMapView addOverlay:self.underlyingMapView.directionToHomePolyline];
    } else {
        [self.underlyingMapView removeOverlay:self.underlyingMapView.directionToHomePolyline];
    }
}

- (void)setShowHomeAnnotation:(BOOL)showHomeAnnotation {
    _showHomeAnnotation = showHomeAnnotation;
    
    if (showHomeAnnotation) {
        [self.underlyingMapView addAnnotation:self.underlyingMapView.homeAnnotation];
    } else {
        [self.underlyingMapView removeAnnotation:self.underlyingMapView.homeAnnotation];
    }
}

- (void)setShowCustomUnlockZones:(BOOL)showCustomUnlockZones {
    _showCustomUnlockZones = showCustomUnlockZones;
    self.flyZoneDataProvider.needsCustomUnlockZones = showCustomUnlockZones;
    [self.flyZoneDataProvider getCustomUnlockedZones];
    [self.flyZoneDataProvider getEnabledCustomUnlockFlyZone];
}

- (void)setVisibleFlyZones:(DUXBetaMapVisibleFlyZones)visibleFlyZones {
    _visibleFlyZones = visibleFlyZones;
    
    if (_visibleFlyZones != DUXBetaMapVisibleFlyZonesNone) {
        // Add the fly zones on the map
        [self.flyZoneDataProvider refreshNearbyVisibleFlyZonesOfCategory:self.visibleFlyZones];
        [self.flyZoneDataProvider getCustomUnlockedZones];
        [self.flyZoneDataProvider getEnabledCustomUnlockFlyZone];
    } else {
        // Remove the fly zones on the map
        [self.annotationProvider beginLockedFlyZoneUpdates];
        [self.annotationProvider beginUnlockedFlyZoneUpdates];
        [self.overlayProvider beginLockedFlyZoneUpdates];
        [self.overlayProvider beginUnlockedFlyZoneUpdates];
        [self.annotationProvider endLockedFlyZoneUpdates];
        [self.annotationProvider endUnlockedFlyZoneUpdates];
        [self.overlayProvider endLockedFlyZoneUpdates];
        [self.overlayProvider endUnlockedFlyZoneUpdates];
        self.flyZones = [NSMutableDictionary dictionary];
        self.unlockedFlyZones = [NSMutableDictionary dictionary];
        self.subFlyZonesParentFlyZones = [NSMutableDictionary dictionary];
        [self updateMapView];
    }
}

- (void)setTapToUnlockEnabled:(BOOL)tapToUnlockEnabled {
    _tapToUnlockEnabled = tapToUnlockEnabled;
    [self.flyZoneDataProvider refreshNearbyVisibleFlyZonesOfCategory:self.visibleFlyZones];
    [self.flyZoneDataProvider getCustomUnlockedZones];
}

- (void)setShowDJIAccountLoginIndicator:(BOOL)showDJIAccountLoginIndicator {
    _showDJIAccountLoginIndicator = showDJIAccountLoginIndicator;
    if (showDJIAccountLoginIndicator) {
        [self showLoginIndicator];
    } else {
        [self hideLoginIndicator];
    }
}

/*********************************************************************************/
#pragma mark - Setup Methods
/*********************************************************************************/

- (void)setupUnderlyingMapViewMapViewWithFrame:(CGRect)frame {
    if (self.underlyingMapView) {
        return;
    }
    
    // Create Map
    self.underlyingMapView = [[DUXBetaMapView alloc] initWithFrame:frame];
    self.underlyingMapView.mapWidget = self;
    // Add Map to self
    [self.view addSubview:self.underlyingMapView];
    
    // Layout Map
    self.underlyingMapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.underlyingMapView.topAnchor constraintEqualToAnchor : self.view.topAnchor].active = YES;
    [self.underlyingMapView.bottomAnchor constraintEqualToAnchor : self.view.bottomAnchor].active = YES;
    [self.underlyingMapView.trailingAnchor constraintEqualToAnchor : self.view.trailingAnchor].active = YES;
    [self.underlyingMapView.leadingAnchor constraintEqualToAnchor : self.view.leadingAnchor].active = YES;
    [self.underlyingMapView setNeedsDisplay];
}

- (void)setupMapWidgetProperties {
    self.isMapCameraLockedOnAircraft = NO;
    self.visibleFlyZones = DUXBetaMapVisibleFlyZonesRestricted | DUXBetaMapVisibleFlyZonesAuthorization | DUXBetaMapVisibleFlyZonesWarning | DUXBetaMapVisibleFlyZonesEnhancedWarning;
    self.showDirectionToHome = YES;
    self.showFlightPath = YES;
    self.showHomeAnnotation = YES;
    self.tapToUnlockEnabled = NO;
    self.showCustomUnlockZones = NO;
    self.showDJIAccountLoginIndicator = NO;
    self.showFlyZoneLegend = YES;
}

- (void)setupFlyZoneDataProvider {
    self.flyZoneDataProvider = [[DUXBetaFlyZoneDataProvider alloc] init];
    self.flyZoneDataProvider.flyZoneManager = [DJISDKManager flyZoneManager];
    self.flyZoneDataProvider.delegate = self;
}

- (void)setupDrawableElementsProviders {
    self.overlayProvider = [[DUXBetaOverlayProvider alloc] init];
    self.overlayProvider.mapWidget = self;
    self.annotationProvider = [[DUXBetaAnnotationProvider alloc] init];
    self.annotationProvider.mapWidget = self;
}

/*********************************************************************************/
#pragma mark - Public API Methods
/*********************************************************************************/

- (void)changeAnnotation:(DUXBetaMapAnnotationType)annotationType withImage:(UIImage *)image {
    [self changeAnnotationOfType:annotationType toCustomImage:image withCenterOffset:CGPointZero];
}

- (void)changeAnnotationOfType:(DUXBetaMapAnnotationType)annotationType toCustomImage:(UIImage *)image withCenterOffset:(CGPoint)centerOffset {
    switch (annotationType) {
        case DUXBetaMapAnnotationTypeAircraft:
            self.underlyingMapView.renderer.aircraftAnnotationImage = image;
            self.underlyingMapView.renderer.aircraftAnnotationImageCenterOffset = centerOffset;
            break;
        case DUXBetaMapAnnotationTypeHome:
            self.underlyingMapView.renderer.homeAnnotationImage = image;
            self.underlyingMapView.renderer.homeAnnotationImageCenterOffset = centerOffset;
            break;
        case DUXBetaMapAnnotationTypeEligibleFlyZones:
            self.underlyingMapView.renderer.eligibleFlyZoneImage = image;
            self.underlyingMapView.renderer.eligibleFlyZoneImageCenterOffset = centerOffset;
            break;
        case DUXBetaMapAnnotationTypeUnlockedFlyZones:
            self.underlyingMapView.renderer.unlockedFlyZoneImage = image;
            self.underlyingMapView.renderer.unlockedFlyZoneImageCenterOffset = centerOffset;
            break;
        case DUXBetaMapAnnotationTypeCustomUnlockedFlyZones:
            self.underlyingMapView.renderer.customUnlockedFlyZoneImage = image;
            self.underlyingMapView.renderer.customUnlockedFlyZoneImageCenterOffset = centerOffset;
            break;
        default:
            break;
    }
}

- (void)clearCurrentFlightPath {
    [self.underlyingMapView removeOverlays:self.underlyingMapView.flightPathOverlays];
    [self.underlyingMapView.flightPathOverlays removeAllObjects];
    [self.underlyingMapView.flightPathCoordinates removeAllObjects];
}

- (void)syncCustomUnlockZones {
    [self presentConfirmationAlertForSendingCustomUnlockZoneToAircraft];
}

/*********************************************************************************/
#pragma mark - MapView
/*********************************************************************************/

- (MKMapView *)mapView {
    // This uses polymorphism to strip down my custom map
    // And give the developer the standard MKMapView
    return self.underlyingMapView;
}

- (void)updateMapView {
    if ([NSThread isMainThread]) {
        @synchronized (self) {
            [self.underlyingMapView removeOverlays:self.underlyingMapView.overlays];
            // TODO: Figure out why flyzones are being duplicated
            //[self.underlyingMapView removeOverlays:self.overlayProvider.removedOverlays];
            [self.underlyingMapView addOverlays:self.overlayProvider.addedOverlays
                                          level:MKOverlayLevelAboveRoads];
            [self.underlyingMapView removeAnnotations:self.annotationProvider.removedAnnotations];
            [self.underlyingMapView addAnnotations:self.annotationProvider.addedAnnotations];
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            @synchronized (self) {
                [self.underlyingMapView removeOverlays:self.underlyingMapView.overlays];
                // TODO: Figure out why flyzones are being duplicated
                //[self.underlyingMapView removeOverlays:self.overlayProvider.removedOverlays];
                [self.underlyingMapView addOverlays:self.overlayProvider.addedOverlays
                                              level:MKOverlayLevelAboveRoads];
                [self.underlyingMapView removeAnnotations:self.annotationProvider.removedAnnotations];
                [self.underlyingMapView addAnnotations:self.annotationProvider.addedAnnotations];
            }
        });
    }
}

- (DUXBetaMapViewRenderer *)renderer {
    return self.underlyingMapView.renderer;
}

- (void)setupLoginIndicator {
    self.loginIndicator = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loginIndicator.hidden = !self.showDJIAccountLoginIndicator;
    [self.loginIndicator setTitle:[self loginIndicatorTitle]
                         forState:UIControlStateNormal];
    [self.loginIndicator addTarget:self
                            action:@selector(performAccountAction:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.loginIndicator];
    self.loginIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginIndicator.heightAnchor constraintEqualToConstant:30.0f].active = YES;
    [self.loginIndicator.widthAnchor constraintEqualToConstant:120.0f].active = YES;
    [self.loginIndicator.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                       constant:8.0f].active = YES;
    [self.loginIndicator.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                  constant:20.0f].active = YES;
    [self.loginIndicator setNeedsLayout];
    [self.loginIndicator layoutIfNeeded];
    
    self.loginIndicator.layer.borderColor = self.loginIndicator.currentTitleColor.CGColor;
    self.loginIndicator.layer.borderWidth = 0.5f;
    self.loginIndicator.layer.cornerRadius = 14.0f;
}

- (void)updateLoginIndicator {
    [self.loginIndicator setTitle:[self loginIndicatorTitle]
                         forState:UIControlStateNormal];
}

- (void)showLoginIndicator {
    self.loginIndicator.hidden = NO;
    [self.view bringSubviewToFront:self.loginIndicator];
}

- (nonnull NSString *)loginIndicatorTitle {
    if ([self isUserLoggedIn]) {
        return NSLocalizedString(@"Log Out", "Login Indicator Title");
    } else {
        return NSLocalizedString(@"Log In", "Login Indicator Title");
    }
}

- (void)performAccountAction:(id)sender {
    __weak typeof(self)target = self;
    if ([self isUserLoggedIn]) {
        [[DJISDKManager userAccountManager] logOutOfDJIUserAccountWithCompletion:^(NSError * _Nullable error) {
            [target updateLoginIndicator];
        }];
    } else {
        [self loginWithCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
            [target updateLoginIndicator];
        }];
    }
}

- (BOOL)isUserLoggedIn {
    if ([DJISDKManager userAccountManager].userAccountState == DJIUserAccountStateNotAuthorized ||
        [DJISDKManager userAccountManager].userAccountState == DJIUserAccountStateAuthorized) {
        return YES;
    } else if ([DJISDKManager userAccountManager].userAccountState == DJIUserAccountStateNotLoggedIn ||
               [DJISDKManager userAccountManager].userAccountState == DJIUserAccountStateTokenOutOfDate ||
               [DJISDKManager userAccountManager].userAccountState == DJIUserAccountStateUnknown) {
        return NO;
    } else {
        return NO;
    }
}

- (void)hideLoginIndicator {
    self.loginIndicator.hidden = YES;
}

/*********************************************************************************/
#pragma mark - Private API Methods
/*********************************************************************************/

- (void)presentAlertController:(UIAlertController *)alertController {
    [self presentViewController:alertController
                                                animated:YES
                                              completion:nil];
}

- (void)presentLoginFailedAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unlock Failed", "Map widget fly zone unlocking alert")
                                                                             message:NSLocalizedString(@"Unable to unlock fly zone because the login failed.", "Map widget fly zone unlocking alert")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "Map widget fly zone unlocking alert")
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:action];
    [self presentAlertController:alertController];
}

- (void)presentConfirmationAlertForSelfUnlockingWithFlyZoneIDs:(NSArray <NSNumber *> *)flyZoneIDs {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Fly Zone Unlock", "Map widget fly zone unlocking alert")
                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"By tapping Unlock, you agree that you have the authorization to operate in this fly zone. A record of this request will be linked to your DJI account. Tap Cancel to abort the operation.", "Map widget fly zone unlocking alert"), flyZoneIDs.firstObject.unsignedIntegerValue]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    __weak typeof(self)target = self;
    UIAlertAction *unlockAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Unlock", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [target.flyZoneDataProvider unlockFlyZonesWithFlyZoneIDs:flyZoneIDs];
                                                         }];
    [alertController addAction:unlockAction];
    [self presentAlertController:alertController];
}

- (void)presentConfirmationAlertForSelfUnlockRequestOnUnlockedFlyZone:(NSString *)flyZoneSubtitle {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Fly Zone Unlocked", "Map widget fly zone unlocked alert")
                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"%@","Map widget fly zone unlocked alert"),flyZoneSubtitle]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "Map widget fly zone unlocked alert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    [self presentAlertController:alertController];
}

- (void)presentConfirmationAlertForSendingCustomUnlockZoneToAircraft {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Fly Zone Custom Unlock Sync", "Map widget fly zone unlocking alert")
                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"Tap Sync to begin synchronizing custom unlock zone with aircraft.", "Map widget fly zone unlocking alert")]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    __weak typeof(self)target = self;
    UIAlertAction *unlockAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sync", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [target.flyZoneDataProvider.flyZoneManager syncUnlockedZoneGroupToAircraftWithCompletion:^(NSError * _Nullable error) {
                                                                 if (error) {
                                                                     [target presentError:error];
                                                                 }
                                                             }];
                                                         }];
    [alertController addAction:unlockAction];
    [self presentAlertController:alertController];
}

- (void)presentConfirmationAlertForEnablingCustomUnlockZone:(DJICustomUnlockZone *)customUnlockZone {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm to Enable Fly Zone Custom Unlock", "Map widget fly zone unlocking alert")
                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"Tap Enable to enable custom unlock zone with aircraft. If you have another custom unlock zone currently enable on the aircraft, it will be disabled.", "Map widget fly zone unlocking alert")]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    __weak typeof(self)target = self;
    UIAlertAction *unlockAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Enable", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if (self.currentlyEnabledCustomUnlockZone) {
                                                                 [target.flyZoneDataProvider.flyZoneManager enableCustomUnlockZone:nil
                                                                                                                    withCompletion:^(NSError * _Nullable error) {
                                                                                                                        if (error) {
                                                                                                                            [target presentError:error];
                                                                                                                        } else {
                                                                                                                            [target.flyZoneDataProvider.flyZoneManager enableCustomUnlockZone:customUnlockZone
                                                                                                                                                                               withCompletion:^(NSError * _Nullable error) {
                                                                                                                                                                                   [target presentError:error];
                                                                                                                                                                               }];
                                                                                                                        }
                                                                                                                    }];
                                                             } else {
                                                                 [target.flyZoneDataProvider.flyZoneManager enableCustomUnlockZone:customUnlockZone
                                                                                                                    withCompletion:^(NSError * _Nullable error) {
                                                                                                                        [target presentError:error];
                                                                                                                    }];
                                                             }
                                                         }];
    [alertController addAction:unlockAction];
    [self presentAlertController:alertController];
}

- (void)presentConfirmationAlertForDisablingCustomUnlockZone:(DJICustomUnlockZone *)customUnlockZone {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm to Disable Fly Zone Custom Unlock", "Map widget fly zone unlocking alert")
                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"Tap Disable to disable custom unlock zone with aircraft. You will no longer be able to operate in the custom unlock zone.", "Map widget fly zone unlocking alert")]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    __weak typeof(self)target = self;
    UIAlertAction *unlockAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Disable", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [target.flyZoneDataProvider.flyZoneManager enableCustomUnlockZone:customUnlockZone
                                                                                                                withCompletion:^(NSError * _Nullable error) {
                                                                                                                    if (error) {
                                                                                                                        [target presentError:error];
                                                                                                                    }
                                                                                                                }];
                                                         }];
    [alertController addAction:unlockAction];
    [self presentAlertController:alertController];
}

- (void)presentError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Fly Zone Manager Error", "Map widget fly zone unlocking alert")
                                                                             message:error.localizedDescription
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "Map widget fly zone error alert")
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:okAction];
    
    [self presentAlertController:alertController];
}

- (void)loginWithCompletion:(DJIAccountStateCompletionBlock)completion {
    __weak typeof(self) target = self;
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:YES
                                                                        withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
                                                                            [target updateLoginIndicator];
                                                                            completion(state, error);
                                                                        }];
}

- (void)presentLoginAlertControllerWithAlertTitle:(nonnull NSString *)alertTitle
                                     alertMessage:(nonnull NSString *)alertMessage
                      loginAccountStateCompletion:(DJIAccountStateCompletionBlock)completion {
    __weak typeof(self) target = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Login", "Map widget fly zone unlocking alert")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [target loginWithCompletion:completion];
                                                        }];
    [alertController addAction:loginAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "Map widget fly zone unlocking alert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    [self presentAlertController:alertController];
}

/*********************************************************************************/
#pragma mark - Customization
/*********************************************************************************/

- (void)setFlyZoneOverlayColor:(nullable UIColor *)color
            forFlyZoneCategory:(DJIFlyZoneCategory)category {
    [self.underlyingMapView.renderer setFlyZoneOverlayColor:color
                                         forFlyZoneCategory:category];
    [self flyZoneColorChanged];
}

- (nonnull UIColor *)flyZoneOverlayColorForFlyZoneCategory:(DJIFlyZoneCategory)category {
    return [self.underlyingMapView.renderer flyZoneOverlayColorForFlyZoneCategory:category];
}

- (void)setFlyZoneOverlayAlpha:(CGFloat)alpha
            forFlyZoneCategory:(DJIFlyZoneCategory)category {
    [self.underlyingMapView.renderer setFlyZoneOverlayAlpha:alpha
                                         forFlyZoneCategory:category];
}

- (CGFloat)flyZoneOverlayAlphaForFlyZoneCategory:(DJIFlyZoneCategory)category {
    return [self.underlyingMapView.renderer flyZoneOverlayAlphaForFlyZoneCategory:category];
}

- (void)setUnlockedFlyZoneOverlayColor:(UIColor *)unlockedFlyZoneOverlayColor {
    [self.underlyingMapView.renderer setUnlockedFlyZoneOverlayColor:unlockedFlyZoneOverlayColor];
    [self flyZoneColorChanged];
}

- (UIColor *)unlockedFlyZoneOverlayColor {
    return [self.underlyingMapView.renderer unlockedFlyZoneOverlayColor];
}

- (void)setUnlockedFlyZoneOverlayAlpha:(CGFloat)unlockedFlyZoneOverlayAlpha {
    [self.underlyingMapView.renderer setUnlockedFlyZoneOverlayAlpha:unlockedFlyZoneOverlayAlpha];
}

- (CGFloat)unlockedFlyZoneOverlayAlpha {
    return self.underlyingMapView.renderer.unlockedFlyZoneOverlayAlpha;
}

- (void)setMaximumHeightFlyZoneOverlayColor:(UIColor *)maximumHeightZoneOverlayColor {
    [self.underlyingMapView.renderer setMaximumHeightFlyZoneOverlayColor:maximumHeightZoneOverlayColor];
    [self flyZoneColorChanged];
}

- (UIColor *)maximumHeightFlyZoneOverlayColor {
    return [self.underlyingMapView.renderer maximumHeightFlyZoneOverlayColor];
}

- (void)setMaximumHeightFlyZoneOverlayAlpha:(CGFloat)maximumHeightFlyZoneOverlayAlpha {
    [self.underlyingMapView.renderer setMaximumHeightFlyZoneOverlayAlpha:maximumHeightFlyZoneOverlayAlpha];
}

- (CGFloat)maximumHeightFlyZoneOverlayAlpha {
    return self.underlyingMapView.renderer.maximumHeightFlyZoneOverlayAlpha;
}

- (void)setFlyZoneOverlayBorderWidth:(CGFloat)flyZoneOverlayBorderWidth {
    [self.underlyingMapView.renderer setFlyZoneOverlayBorderWidth:flyZoneOverlayBorderWidth];
}

- (CGFloat)flyZoneOverlayBorderWidth {
    return [self.underlyingMapView.renderer flyZoneOverlayBorderWidth];
}

- (void)setFlightPathStrokeColor:(UIColor *)flightPathStrokeColor {
    [self.underlyingMapView.renderer setFlightPathStrokeColor:flightPathStrokeColor];
}

- (UIColor *)flightPathStrokeColor {
    return [self.underlyingMapView.renderer flightPathStrokeColor];
}

- (void)setFlightPathStrokeWidth:(CGFloat)flightPathStrokeWidth {
    [self.underlyingMapView.renderer setFlightPathStrokeWidth:flightPathStrokeWidth];
}

- (CGFloat)flightPathStrokeWidth {
    return [self.underlyingMapView.renderer flightPathStrokeWidth];
}

- (void)setDirectionToHomeStrokeColor:(UIColor *)directionToHomeStrokeColor {
    [self.underlyingMapView.renderer setDirectionToHomeStrokeColor:directionToHomeStrokeColor];
}

- (UIColor *)directionToHomeStrokeColor {
    return [self.underlyingMapView.renderer directionToHomeStrokeColor];
}

- (void)setDirectionToHomeStrokeWidth:(CGFloat)directionToHomeStrokeWidth {
    [self.underlyingMapView.renderer setDirectionToHomeStrokeWidth:directionToHomeStrokeWidth];
}

- (CGFloat)directionToHomeStrokeWidth {
    return [self.underlyingMapView.renderer directionToHomeStrokeWidth];
}

- (UIColor *)customUnlockFlyZoneOverlayColor {
    return [self.underlyingMapView.renderer customUnlockFlyZoneOverlayColor];
}

- (void)setCustomUnlockFlyZoneOverlayColor:(UIColor *)customUnlockFlyZoneOverlayColor {
    self.underlyingMapView.renderer.customUnlockFlyZoneOverlayColor = customUnlockFlyZoneOverlayColor;
    [self flyZoneColorChanged];
}

- (CGFloat)customUnlockFlyZoneOverlayAlpha {
    return [self.underlyingMapView.renderer customUnlockFlyZoneOverlayAlpha];
}

- (void)setCustomUnlockFlyZoneOverlayAlpha:(CGFloat)customUnlockFlyZoneOverlayAlpha {
    self.underlyingMapView.renderer.customUnlockFlyZoneOverlayAlpha = customUnlockFlyZoneOverlayAlpha;
}

- (UIColor *)customUnlockFlyZoneSentToAircraftOverlayColor {
    return [self.underlyingMapView.renderer customUnlockFlyZoneSentToAircraftOverlayColor];
}

- (void)setCustomUnlockFlyZoneSentToAircraftOverlayColor:(UIColor *)customUnlockFlyZoneSentToAircraftOverlayColor {
    [self.underlyingMapView.renderer setCustomUnlockFlyZoneSentToAircraftOverlayColor:customUnlockFlyZoneSentToAircraftOverlayColor];
    [self flyZoneColorChanged];
}

- (CGFloat)customUnlockFlyZoneSentToAircraftOverlayAlpha {
    return [self.underlyingMapView.renderer customUnlockFlyZoneSentToAircraftOverlayAlpha];
}

- (void)setCustomUnlockFlyZoneSentToAircraftOverlayAlpha:(CGFloat)customUnlockFlyZoneSentToAircraftOverlayAlpha {
    [self.underlyingMapView.renderer setCustomUnlockFlyZoneSentToAircraftOverlayAlpha:customUnlockFlyZoneSentToAircraftOverlayAlpha];
}

- (UIColor *)customUnlockFlyZoneEnabledOverlayColor {
    return [self.underlyingMapView.renderer customUnlockFlyZoneEnabledOverlayColor];
}

- (void)setCustomUnlockFlyZoneEnabledOverlayColor:(UIColor *)customUnlockFlyZoneEnabledOverlayColor {
    [self.underlyingMapView.renderer setCustomUnlockFlyZoneEnabledOverlayColor:customUnlockFlyZoneEnabledOverlayColor];
    [self flyZoneColorChanged];
}

- (CGFloat)customUnlockFlyZoneEnabledOverlayAlpha {
    return [self.underlyingMapView.renderer customUnlockFlyZoneEnabledOverlayAlpha];
}

- (void)setCustomUnlockFlyZoneEnabledOverlayAlpha:(CGFloat)customUnlockFlyZoneEnabledOverlayAlpha {
    [self.underlyingMapView.renderer setCustomUnlockFlyZoneEnabledOverlayAlpha:customUnlockFlyZoneEnabledOverlayAlpha];
}

- (void)flyZoneColorChanged {
    [self.mapViewLegendViewController.collectionView reloadData];
}

/*********************************************************************************/
#pragma mark - DUXBetaFlyZoneDataProviderDelegate
/*********************************************************************************/

- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider didUpdateFlyZones:(nonnull NSDictionary <NSString *, DJIFlyZoneInformation *> *)flyZones {
    [self.annotationProvider beginLockedFlyZoneUpdates];
    [self.overlayProvider beginLockedFlyZoneUpdates];
    self.subFlyZonesParentFlyZones = [NSMutableDictionary dictionary];
    for (DJIFlyZoneInformation *flyZone in flyZones.allValues) {
        if (flyZone.type == DJIFlyZoneTypeCircle) {
            [self.overlayProvider addLockedOverlayForFlyZone:flyZone];
            if (self.tapToUnlockEnabled && (flyZone.category == DJIFlyZoneCategoryAuthorization || flyZone.category == DJIFlyZoneCategoryEnhancedWarning)) {
                [self.annotationProvider addAnnotationForLockedFlyZone:flyZone];
            }
        } else if (flyZone.type == DJIFlyZoneTypePoly) {
            for (DJISubFlyZoneInformation *subFlyZone in flyZone.subFlyZones) {
                if (subFlyZone.shape == DJISubFlyZoneShapeCylinder) {
                    [self.overlayProvider addOverlayForCylinderSubFlyZone:subFlyZone
                                                            withinFlyZone:flyZone];
                } else if (subFlyZone.shape == DJISubFlyZoneShapePolygon) {
                    [self.overlayProvider addOverlayForPolygonSubFlyZone:subFlyZone
                                                           withinFlyZone:flyZone];
                }
                self.subFlyZonesParentFlyZones[[NSString duxbeta_subFlyZoneProviderAccessKeyWithFlyZone:flyZone subFlyZone:subFlyZone]] = flyZone;
            }
        }
    }
    [self.annotationProvider endLockedFlyZoneUpdates];
    [self.overlayProvider endLockedFlyZoneUpdates];
    
    self.flyZones = [flyZones mutableCopy];
    
    [self updateMapView];
}

- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider didUpdateUnlockedFlyZones:(nonnull NSDictionary <NSString *, DJIFlyZoneInformation *> *)flyZones {
    [self.annotationProvider beginUnlockedFlyZoneUpdates];
    [self.overlayProvider beginUnlockedFlyZoneUpdates];
    for (DJIFlyZoneInformation *flyZone in flyZones.allValues) {
        if (flyZone.type == DJIFlyZoneTypeCircle) {
            [self.overlayProvider addUnlockedOverlayForFlyZone:flyZone];
            if (self.tapToUnlockEnabled && (flyZone.category == DJIFlyZoneCategoryAuthorization || flyZone.category == DJIFlyZoneCategoryEnhancedWarning)) {
                [self.annotationProvider addAnnotationForUnlockedFlyZone:flyZone];
            }
        } else if (flyZone.type == DJIFlyZoneTypePoly) {
            for (DJISubFlyZoneInformation *subFlyZone in flyZone.subFlyZones) {
                if (subFlyZone.shape == DJISubFlyZoneShapeCylinder) {
                    [self.overlayProvider addOverlayForCylinderSubFlyZone:subFlyZone
                                                            withinFlyZone:flyZone];
                    [self.annotationProvider addAnnotationForSubFlyZone:subFlyZone
                                                          withinFlyZone:flyZone];
                } else if (subFlyZone.shape == DJISubFlyZoneShapePolygon) {
                    [self.overlayProvider addOverlayForPolygonSubFlyZone:subFlyZone
                                                           withinFlyZone:flyZone];
                }
            }
        }
    }
    [self.annotationProvider endUnlockedFlyZoneUpdates];
    [self.overlayProvider endUnlockedFlyZoneUpdates];
    
    self.unlockedFlyZones = [flyZones mutableCopy];
    
    [self updateMapView];
}

- (void)flyZoneDataProvider:(DUXBetaFlyZoneDataProvider *)flyZoneDataProvider requestsPresentationOfAlertWithTitle:(nonnull NSString *)alertTitle alertMessage:(nonnull NSString *)alertMessage loginAccountStateCompletion:(DJIAccountStateCompletionBlock)completion {
    [self presentLoginAlertControllerWithAlertTitle:alertTitle
                                       alertMessage:alertMessage
                        loginAccountStateCompletion:completion];
}

- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider successfullyUnlockedFlyZonesWithIDs:(nonnull NSArray <NSNumber *> *)flyZoneIDs {
    NSString *flyZoneKey = [NSString stringWithFormat:@"%ld", flyZoneIDs.firstObject.unsignedIntegerValue];
    NSString *flyZoneName = [self.flyZones[flyZoneKey] name];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unlock Successful", "Map widget fly zone unlocking alert")
                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"Successfully unlocked fly zone %@ with ID %zd.", "Map widget fly zone unlocking alert"),flyZoneName, flyZoneIDs.firstObject.unsignedIntegerValue]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "Map widget fly zone unlocking alert")
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:action];
    [self presentAlertController:alertController];
}

- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider unsuccessfullyUnlockedFlyZonesWithIDs:(nonnull NSArray <NSNumber *> *)flyZoneIDs withError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unlock Failed", "Map widget fly zone unlocking alert")
                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"Failed to unlock fly zone with ID %zd.", "Map widget fly zone unlocking alert"), flyZoneIDs.firstObject.unsignedIntegerValue]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "Map widget fly zone unlocking alert")
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:action];
    [self presentAlertController:alertController];
}

- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider abortedUnlockingProcessWithCurrentUserAccountState:(DJIUserAccountState)userAccountState {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unlock Failed", "Map widget fly zone unlocking alert")
                                                                             message:NSLocalizedString(@"Unable to unlock fly zone because this account is not authorized to do so.", "Map widget fly zone unlocking alert")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "Map widget fly zone unlocking alert")
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:action];
    [self presentAlertController:alertController];
}

- (void)flyZoneDataProvider:(DUXBetaFlyZoneDataProvider *)flyZoneDataProvider didUpdateCustomUnlockZones:(NSDictionary<NSString *,DJICustomUnlockZone *> *)customUnlockZones {
    if (!self.showCustomUnlockZones) {
        [self.overlayProvider beginCustomUnlockedFlyZoneUpdates];
        [self.annotationProvider beginCustomUnlockedFlyZoneUpdates];
        [self.overlayProvider endCustomUnlockedFlyZoneUpdates];
        [self.annotationProvider endCustomUnlockedFlyZoneUpdates];
        [self updateMapView];
        return;
    }
    
    NSArray *customUnlockZonesOnAircraft = [flyZoneDataProvider.flyZoneManager getCustomUnlockZonesFromAircraft];
    self.customUnlockedFlyZonesOnAircraft = [NSMutableDictionary dictionary];
    for (DJICustomUnlockZone *flyZone in customUnlockZonesOnAircraft) {
        self.customUnlockedFlyZonesOnAircraft[[NSString duxbeta_customUnlockZoneProviderAccessKeyWithFlyZone:flyZone]] = flyZone;
    }
    
    [self.overlayProvider beginCustomUnlockedFlyZoneUpdates];
    [self.annotationProvider beginCustomUnlockedFlyZoneUpdates];
    
    for (NSString *flyZoneIdentifier in customUnlockZones.allKeys) {
        [self.overlayProvider addOverlayForCustomUnlockZone:customUnlockZones[flyZoneIdentifier]
                                             sentToAircraft:[self.customUnlockedFlyZonesOnAircraft.allKeys containsObject:flyZoneIdentifier]
                                          enabledOnAircraft:[flyZoneIdentifier isEqualToString:[NSString duxbeta_customUnlockZoneProviderAccessKeyWithFlyZone:self.currentlyEnabledCustomUnlockZone]]];
        if (self.tapToUnlockEnabled) {
            [self.annotationProvider addAnnotationForCustomUnlockZone:customUnlockZones[flyZoneIdentifier]
                                                       sentToAircraft:[self.customUnlockedFlyZonesOnAircraft.allKeys containsObject:flyZoneIdentifier]
                                                    enabledOnAircraft:[flyZoneIdentifier isEqualToString:[NSString duxbeta_customUnlockZoneProviderAccessKeyWithFlyZone:self.currentlyEnabledCustomUnlockZone]]];
        }
    }
    
    [self.overlayProvider endCustomUnlockedFlyZoneUpdates];
    [self.annotationProvider endCustomUnlockedFlyZoneUpdates];
    
    self.customUnlockedFlyZones = [customUnlockZones mutableCopy];
    
    [self updateMapView];
}

- (void)flyZoneDataProvider:(nonnull DUXBetaFlyZoneDataProvider *)flyZoneDataProvider didUpdateEnabledCustomUnlockZone:(nullable DJICustomUnlockZone *)customUnlockZone {
    self.currentlyEnabledCustomUnlockZone = customUnlockZone;
    [self.flyZoneDataProvider getCustomUnlockedZones];
}

@end
