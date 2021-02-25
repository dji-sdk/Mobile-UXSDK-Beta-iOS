//
//  DUXBetaSpotlightControlWidgetModel.m
//  UXSDKAccessory
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

#import "DUXBetaSpotlightControlWidgetModel.h"
#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaSpotlightControlWidgetModel ()

@property (nonatomic, assign, readwrite) BOOL isEnabled;

@property (nonatomic, strong, readwrite) DJIParamCapabilityMinMax *brightnessRange;
@property (nonatomic, assign, readwrite) CGFloat celsiusTemperature;

@property (nonatomic, strong, readwrite) NSMeasurement *temperature;
@property (nonatomic, assign, readwrite) NSUInteger brightness;
@property (nonatomic, assign, readwrite) NSUInteger minBrightness;
@property (nonatomic, assign, readwrite) NSUInteger maxBrightness;
/**
* The module handling the unit type related logic
*/
@property (nonatomic, strong) DUXBetaUnitTypeModule *unitModule;

@end

@implementation DUXBetaSpotlightControlWidgetModel

@synthesize temperatureUnits = _temperatureUnits;

- (instancetype)init {
    self = [super init];
    if (self) {
        _isEnabled = NO;
        if (self.unitModule.unitType == DUXBetaMeasureUnitTypeMetric) {
            _temperature = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitTemperature.celsius];
        } else {
            _temperature = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitTemperature.fahrenheit];
        }
        _temperature = 0;
        _brightness = 0;
        _minBrightness = 0;
        _maxBrightness = 0;
        self.unitModule = [DUXBetaUnitTypeModule new];
        [self addModule:self.unitModule];
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpotlightSubComponent subComponentIndex:0 andParam:DJIAccessoryParamEnabled], isEnabled);
    BindSDKKey([DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpotlightSubComponent subComponentIndex:0 andParam:DJIAccessoryParamBrightness], brightness);
    BindSDKKey([DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpotlightSubComponent subComponentIndex:0 andParam:DJIAccessoryParamBrightnessRange], brightnessRange);
    BindSDKKey([DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpotlightSubComponent subComponentIndex:0 andParam:DJIAccessoryParamTemperature], celsiusTemperature);
    BindRKVOModel(self, @selector(unwrapBrightnessRange), brightnessRange);
    BindRKVOModel(self, @selector(convertTemperature), temperature);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateSpotlightEnabled:(BOOL)enabled withCompletionBlock:(DUXBetaWidgetModelActionCompletionBlock)completionBlock {
    [[DJISDKManager keyManager] setValue:@(enabled) forKey:[DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpotlightSubComponent subComponentIndex:0 andParam:DJIAccessoryParamEnabled] withCompletion:^(NSError * _Nullable error) {
        completionBlock(error);
    }];
}

- (void)updateBrightness:(float)brightness withCompletionBlock:(DUXBetaWidgetModelActionCompletionBlock)completionBlock {
    [[DJISDKManager keyManager] setValue:@(brightness) forKey:[DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpotlightSubComponent subComponentIndex:0 andParam:DJIAccessoryParamBrightness] withCompletion:^(NSError * _Nullable error) {
        completionBlock(error);
    }];
}

- (void)unwrapBrightnessRange {
    self.minBrightness = [self.brightnessRange.min intValue];
    self.maxBrightness = [self.brightnessRange.max intValue];
}

- (void)convertTemperature {
    NSMeasurement *temp = [[NSMeasurement alloc] initWithDoubleValue:self.celsiusTemperature unit: NSUnitTemperature.celsius];
    self.temperature = [temp measurementByConvertingToUnit: self.temperatureUnits];
}

- (NSUnitTemperature *)temperatureUnits {
    if (_temperatureUnits) {
        return _temperatureUnits;
    } else if (self.unitModule.unitType == DUXBetaMeasureUnitTypeMetric) {
        return NSUnitTemperature.celsius;
    } else {
        return NSUnitTemperature.fahrenheit;
    }
}

- (void)setTemperatureUnits:(NSUnitTemperature *)temperatureUnits {
    _temperatureUnits = temperatureUnits;
    [self convertTemperature];
}

@end
