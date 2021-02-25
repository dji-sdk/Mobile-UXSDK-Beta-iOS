//
//  DUXBetaLocationUtil.m
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

#import "DUXBetaLocationUtil.h"

@implementation DUXBetaLocationUtil

+ (double)distanceInMeters:(CLLocation *)location1 andLocation:(CLLocation *)location2 {
    if (location1 == nil) { return 0; }
    if (location2 == nil) { return 0; }
    
    if (!IsGPSValid(location1.coordinate)) { return 0; }
    if (!IsGPSValid(location2.coordinate)) { return 0; }
            
    return [location1 distanceFromLocation:location2];
}

+ (CLLocationDirection)angleBetween:(CLLocation *)location1 andLocation:(CLLocation *)location2 {
    double distance1 = [self distanceInMeters:location1 andLocation:location2];
    if (distance1 == 0) { return 0; }
    
    CLLocation *location3 = [[CLLocation alloc] initWithLatitude:location2.coordinate.latitude longitude:location1.coordinate.longitude];
    double distance2 = [location1 distanceFromLocation:location3];
    
    double ans = acos(distance2/distance1);
    if (location1.coordinate.latitude <= location2.coordinate.latitude) {
        if (location1.coordinate.longitude > location2.coordinate.longitude)  {
            ans = 2 * M_PI - ans;
        }
    } else {
        ans = location1.coordinate.longitude >= location2.coordinate.longitude ? M_PI + ans: M_PI - ans;
    }
    
    return ans * 180.0 / M_PI;
}


@end
