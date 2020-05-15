//
//  DUXBetaMapView.m
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

#import "DUXBetaMapView.h"
#import "DUXBetaMapWidget.h"
#import "DUXBetaMapViewRenderer.h"
#import "DUXBetaMapPolylineOverlay.h"
#import "DUXBetaMapHomeAnnotation.h"
#import "DUXBetaMapAircraftAnnotation.h"
#import "DUXBetaMapAircraftAnnotationView.h"

@implementation DUXBetaMapState

@end

@interface DUXBetaMapView ()<UIGestureRecognizerDelegate>

@property CLLocationCoordinate2D prevCoord;

@end

@implementation DUXBetaMapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup Properties
        _flightPathOverlays = [[NSMutableArray alloc] init];
        _flightPathCoordinates = [[NSMutableArray alloc] init];
        _prevCoord = kCLLocationCoordinate2DInvalid;
        // Setup Map
        [self setupMapProperties];
    }
    return self;
}

- (void)dealloc {
    [self.timerToUpdateCamera invalidate];
}

#pragma mark - Setup Methods

- (void)setupMapProperties {
    self.renderer = [[DUXBetaMapViewRenderer alloc] initWithMapView:self];
    self.delegate = self.renderer;
    //Gesture reconizer
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchDetected:)];
    [pinch setDelegate:self];
    [pinch setDelaysTouchesBegan:YES];
    [self addGestureRecognizer:pinch];

    self.showsUserLocation = YES;
    self.showsCompass = YES;
    self.showsBuildings = YES;
    self.showsPointsOfInterest = YES;
    self.userTrackingMode = MKUserTrackingModeFollow;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return  YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return  YES;
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.timerToUpdateCamera invalidate];
            self.timerToUpdateCamera = nil;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.timerToUpdateCamera) {
                if (self.mapWidget.isMapCameraLockedOnAircraft) {
                    [self updateMapCamera];
                    self.timerToUpdateCamera = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateMapCamera) userInfo:nil repeats:YES];
                }
            }
        });
    }
}

#pragma mark - Aircraft State Methods

- (void)setHomeCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self.homeAnnotation == nil) {
        self.homeAnnotation = [[DUXBetaMapHomeAnnotation alloc] initWithCoordinate:coordinate];
        [self addAnnotation:self.homeAnnotation];
        [self zoomInOnDrone:coordinate];
    }
    [self.homeAnnotation setCoordinate:coordinate];
}

- (CLLocation *)homeCoordinate {
    CLLocationCoordinate2D homeCoordinate = self.homeAnnotation.coordinate;
    return [[CLLocation alloc] initWithLatitude:homeCoordinate.latitude longitude:homeCoordinate.longitude];
}

- (void)setAircraftCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self.aircraftAnnotation == nil) {
        
        self.aircraftAnnotation = [[DUXBetaMapAircraftAnnotation alloc] initWithCoordinate:coordinate];
        [self addAnnotation:self.aircraftAnnotation];
        return;
    }
    // Update the drone annotation
    [UIView animateWithDuration:0.15 animations:^{
        [self.aircraftAnnotation setCoordinate:coordinate];
    }];
}

- (CLLocation *)aircraftLocation {
    CLLocationCoordinate2D droneCoordinate = [self.aircraftAnnotation coordinate];
    return [[CLLocation alloc] initWithLatitude:droneCoordinate.latitude longitude:droneCoordinate.longitude];
}

- (void)setYaw:(CGFloat)yaw {
    _yaw = (yaw / 180) * M_PI;
    [self.renderer.aircraftAnnotationView setYawInRadians:_yaw];
}

#pragma mark - Update Aircraft State Methods

// This method is where all the data is imported
- (void)updateMapWithState:(DUXBetaMapState *)mapState {
    // Update Home Location
    if (mapState.isHomeLocationSet) {
        [self setHomeCoordinate:mapState.homeLocationCoordinate];
    }
    
    if (!CLLocationCoordinate2DIsValid(self.prevCoord)) {
        self.prevCoord = mapState.aircraftLocationCoordinate;
    }
    
    // Update Aircraft Coordinate
    [self setAircraftCoordinate:mapState.aircraftLocationCoordinate];
    
    // Update flight path / draw line based on total given coordinates, and remove previous line
    // Only update flight path if it's a valid coordinate, and if it is 1.5 meters away from the previous coordinate
    double distanceBetweenCurrentAndPrevAircraftCoord = [self distanceBetweenCoordinates:self.prevCoord coordTwo:mapState.aircraftLocationCoordinate];
    BOOL isCurrentAircraftCoordValid = (mapState.aircraftLocationCoordinate.latitude != 0.0 || mapState.aircraftLocationCoordinate.longitude != 0.0);
    if (isCurrentAircraftCoordValid && distanceBetweenCurrentAndPrevAircraftCoord > 1.5) {
        // Remove Line
        [self removeOverlays:self.flightPathOverlays];
        [self.flightPathOverlays removeAllObjects];
        self.prevCoord = mapState.aircraftLocationCoordinate;
        // Add new coordinate to list of coordinates used to create new line
        CLLocation *currentAircraftLocation = [[CLLocation alloc] initWithLatitude:mapState.aircraftLocationCoordinate.latitude longitude:mapState.aircraftLocationCoordinate.longitude];
        [self.flightPathCoordinates addObject: currentAircraftLocation];
        // Extract locations from flightPathCoordinates
        CLLocationCoordinate2D flightPathCoords[self.flightPathCoordinates.count];
        [self extractCoordinates:self.flightPathCoordinates to:flightPathCoords];
        // Update flight path
        [self updateFlightPath:flightPathCoords showOnMap:mapState.showFlightPath];
    }
    
    // Update Aircraft Yaw
    self.yaw = mapState.aircraftHeading;
    
    // Update direction to home
    if (isCurrentAircraftCoordValid) {
        [self updateDirectionToHomePathWithHomeCoordinate:self.homeAnnotation.coordinate
                               aircraftLocationCoordinate:mapState.aircraftLocationCoordinate
                                          shouldShowOnMap:mapState.showDirectionToHome];
    }
}

- (void)updateFlightPath:(CLLocationCoordinate2D[])coordinates showOnMap:(BOOL)show {
    DUXBetaMapPolylineOverlay *flightPathPolyline = [DUXBetaMapPolylineOverlay polylineWithCoordinates:coordinates count:self.flightPathCoordinates.count];
    flightPathPolyline.polylineType = DUXBetaMapPolylineFlightPath;
    [self.flightPathOverlays addObject:flightPathPolyline];
    if (show) {
        [self addOverlay:flightPathPolyline];
    }
}

- (void)updateDirectionToHomePathWithHomeCoordinate:(CLLocationCoordinate2D)homeCoordinate
                         aircraftLocationCoordinate:(CLLocationCoordinate2D)aircraftCoordinate
                                    shouldShowOnMap:(BOOL)show {
    if (show) {
        CLLocationCoordinate2D coordinates[2] = {homeCoordinate, aircraftCoordinate};
        DUXBetaMapPolylineOverlay *directionToHomePolyline = [DUXBetaMapPolylineOverlay polylineWithCoordinates:coordinates count:2];
        directionToHomePolyline.polylineType = DUXBetaMapPolylineDirectionToHome;
        if(self.directionToHomePolyline == nil) {
            self.directionToHomePolyline = directionToHomePolyline;
            [self addOverlay:self.directionToHomePolyline];
        } else {
            [self removeOverlay:self.directionToHomePolyline];
            self.directionToHomePolyline = directionToHomePolyline;
            [UIView animateWithDuration:1.0 animations:^{
                [self addOverlay:self.directionToHomePolyline];
            }];
        }
    }
}

- (void)updateMapCamera {
    // Centers the map on the drone
    if (self.mapWidget.isMapCameraLockedOnAircraft &&
        CLLocationCoordinate2DIsValid([self aircraftLocation].coordinate) &&
        ([self aircraftLocation].coordinate.latitude != 0 ||
        [self aircraftLocation].coordinate.longitude != 0)) {
        [self setCenterCoordinate:[self aircraftLocation].coordinate
                         animated:YES];
    } else if (self.mapWidget.isMapCameraLockedOnHomePoint) {
        [self setCenterCoordinate:self.homeCoordinate.coordinate
                         animated:YES];
    }
}

#pragma mark - Helper Methods

- (void)extractCoordinates:(NSMutableArray<CLLocation *> *)locations to:(CLLocationCoordinate2D *)coordinate {
    for (int i = 0; i < locations.count; i++) {
        CLLocation *location = [locations objectAtIndex:i];
        if (location.coordinate.latitude != 0.0 || location.coordinate.longitude != 0.0) {
            coordinate[i] = location.coordinate;
        }
    }
}

- (double)distanceBetweenCoordinates:(CLLocationCoordinate2D)coordOne coordTwo:(CLLocationCoordinate2D)coordTwo {
    CLLocation *locationOne = [[CLLocation alloc] initWithLatitude:coordOne.latitude longitude:coordOne.longitude];
    CLLocation *locationTwo = [[CLLocation alloc] initWithLatitude:coordTwo.latitude longitude:coordTwo.longitude];
    return [locationOne distanceFromLocation:locationTwo];
}

- (void)zoomInOnDrone:(CLLocationCoordinate2D)coordinate {
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        // Set Camera
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.001, 0.001));
        [self setRegion:region animated:YES];
    }
}

@end
