//
//  DUXBetaMapView.h
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

#import <MapKit/MapKit.h>
@class DUXBetaMapWidget;
@class DUXBetaMapViewRenderer;
@class DUXBetaMapPolylineOverlay;
@class DUXBetaMapHomeAnnotation;
@class DUXBetaMapAircraftAnnotation;

@interface DUXBetaMapState : NSObject

// Aircraft State
@property (nonatomic, assign) CLLocationCoordinate2D homeLocationCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D aircraftLocationCoordinate;
@property (nonatomic, assign) double aircraftHeading;
// Flags
@property (nonatomic, assign) BOOL isHomeLocationSet;
@property (nonatomic, assign) BOOL showDirectionToHome;
@property (nonatomic, assign) BOOL showFlightPath;

@end

@interface DUXBetaMapView : MKMapView

// Aircraft State
- (CLLocation *)homeCoordinate;
- (CLLocation *)aircraftLocation;
// Data Retrieval
- (void)updateMapWithState:(DUXBetaMapState *)mapState;
- (void)updateMapCamera;

// Manages updating users location only
@property (nonatomic, strong) CLLocationManager *locationManager;
// Map camera properties
@property (nonatomic, strong) NSTimer *timerToUpdateCamera;
// Drone state
@property (nonatomic, assign) CGFloat yaw; // In radians

// Flight Path Data
@property NSMutableArray<DUXBetaMapPolylineOverlay *> *flightPathOverlays;
@property NSMutableArray<CLLocation *> *flightPathCoordinates;
// Polyline Overlays
@property (nonatomic, strong) DUXBetaMapPolylineOverlay *directionToHomePolyline;
// Annotations on map
@property (nonatomic, strong) DUXBetaMapAircraftAnnotation *aircraftAnnotation;
@property (nonatomic, strong) DUXBetaMapHomeAnnotation     *homeAnnotation;
// Map Renderer
@property (nonatomic, strong) DUXBetaMapViewRenderer *renderer;
//the widget this map is embedded in
@property (nonatomic, weak) DUXBetaMapWidget *mapWidget;

@end
