//
//  DUXBetaVerticalVelocityWidgetModel.m
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

#import "DUXBetaVerticalVelocityWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaVerticalVelocityWidgetModel()

@property (nonatomic) DJISDKVector3D *velocityVector;
@property (nonatomic) NSMeasurement *verticalVelocity;

@end

@implementation DUXBetaVerticalVelocityWidgetModel

@synthesize verticalVelocityUnits = _verticalVelocityUnits;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.velocityVector = nil;
        if (self.unitSystem == DUXBetaUnitSystemMetric) {
            self.verticalVelocity = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.meters];
        } else {
            self.verticalVelocity = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.feet];
        }
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamVelocity], velocityVector);

    BindRKVOModel(self, @selector(updateVelocityVector), velocityVector);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void) updateVelocityVector {
    if (self.velocityVector == nil) { return; }
    NSMeasurement *verticalVelocity = [[NSMeasurement alloc] initWithDoubleValue:self.velocityVector.z * -1 unit: NSUnitLength.meters];
    self.verticalVelocity = [verticalVelocity measurementByConvertingToUnit: self.verticalVelocityUnits];
}

- (NSUnitLength *)verticalVelocityUnits {
    if (_verticalVelocityUnits) {
        return _verticalVelocityUnits;
    } else if (self.unitSystem == DUXBetaUnitSystemMetric) {
        return NSUnitLength.meters;
    } else {
        return NSUnitLength.feet;
    }
}

- (void)setVerticalVelocityUnits:(NSUnitLength *)verticalVelocityUnits {
    _verticalVelocityUnits = verticalVelocityUnits;
    [self updateVelocityVector];
}

@end
