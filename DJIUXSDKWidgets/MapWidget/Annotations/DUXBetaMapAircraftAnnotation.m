//
//  DUXBetaMapAircraftAnnotation.m
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

#import "DUXBetaMapAircraftAnnotation.h"

@interface DUXBetaMapAircraftAnnotation()

@property (nonatomic, strong) NSString *prevCoordKey;
@property (nonatomic, strong) NSString *currCordKey;

@end

@implementation DUXBetaMapAircraftAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _prevCoordKey = @"Prev";
        _currCordKey = @"Curr";
        _recentCoordinates = [[NSMutableDictionary alloc] init];
        [self setCoordinate:coordinate];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _recentCoordinates = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    // Set the coordinate, and keep track of previous coordinate as well
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    // If this is our first coordinate, just initalize the current key value
    if ([self.recentCoordinates valueForKey:self.prevCoordKey] == nil && [self.recentCoordinates valueForKey:self.currCordKey] == nil) {
        [self.recentCoordinates setValue:newLocation forKey:self.currCordKey];
    }
    // Get the current coordinate stored in the dict
    CLLocation *currCoord = [self.recentCoordinates valueForKey:self.currCordKey];
    
    // Make the new coordinate the current coordinate, and current coordinate the prev coordinate
    [self.recentCoordinates setValue:currCoord forKey:self.prevCoordKey];
    [self.recentCoordinates setValue:newLocation forKey:self.currCordKey];
    
    _coordinate = newCoordinate;
}

- (CLLocationCoordinate2D)previousCoordinate {
    CLLocation *prevLocation = [self.recentCoordinates valueForKey:self.prevCoordKey];
    return prevLocation.coordinate;
}

- (CLLocationCoordinate2D)currentCoordinate {
    CLLocation *currLocation = [self.recentCoordinates valueForKey:self.currCordKey];
    return currLocation.coordinate;
}

@end
