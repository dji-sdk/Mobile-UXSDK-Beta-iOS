//
//  DUXBetaMaxFlightDistanceListItemWidgetViewController.m
//  UXSDKCore
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

#import "DUXBetaMaxFlightDistanceListItemWidget.h"
#import "DUXBetaMaxFlightDistanceListItemWidgetModel.h"
#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaMaxFlightDistanceListItemWidget ()

@property (nonatomic, strong) DUXBetaMaxFlightDistanceListItemWidgetModel *widgetModel;

@end

@implementation DUXBetaMaxFlightDistanceListItemWidget

- (instancetype)init {
    if (self = [super init:DUXBetaListItemEditAndButton]) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init:DUXBetaListItemEditAndButton]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    // Test for existance because it is possible these were actually set before the view was loaded.
    // (For instance, duing the customizeWidgetSetup in a SmartListModel.)
    if (self.disableButtonTitle == nil) {
        self.disableButtonTitle = NSLocalizedString(@"Disable", @"Max Flight Distance Enable/Disable button");
    }
    if (self.enableButtonTitle == nil) {
        self.enableButtonTitle = NSLocalizedString(@"Enable", @"Max Flight Distance Enable/Disable button");
    }


    self.widgetModel = [[DUXBetaMaxFlightDistanceListItemWidgetModel alloc] init];
    [self.widgetModel setup];

    [self setTitle:NSLocalizedString(@"Max Flight Distance", @"System Status Checklist Item Title") andIconName:@"SystemStatusMaxFlightDistance"];
    __weak DUXBetaMaxFlightDistanceListItemWidget *weakSelf = self;
    [self setButtonAction:^(id senderWidget) {
        __strong DUXBetaMaxFlightDistanceListItemWidget *strongSelf = weakSelf;
        if (strongSelf) {
            BOOL newEnableState = !strongSelf.widgetModel.isFlightRadiusEnabled;
            [strongSelf.widgetModel flightRadiusEnable:newEnableState onCompletion:^(DUXBetaMaxFlightDistanceChange result) {
            }];
        }
    }];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(metaDataChanged), isNoviceMode, rangeValue, isFlightRadiusEnabled);
    BindRKVOModel(self.widgetModel, @selector(maxDistanceChanged), maxFlightDistance);
    BindRKVOModel(self.widgetModel, @selector(productConnectedChanged), isProductConnected);
    BindRKVOModel(self, @selector(updateButtonTitle), disableButtonTitle, enableButtonTitle);
    BindRKVOModel(self.widgetModel, @selector(unitsChanged), unitModule.unitType);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)productConnectedChanged {
    if (self.widgetModel.isProductConnected == NO) {
        [self setEditText:NSLocalizedString(@"N/A", @"N/A")];
    } else {
        // If product was just connected, the max distance doesn't change on update, so we need to manually set this.
        [self maxDistanceChanged];
    }

    [self updateUI];

}

- (void)metaDataChanged {
    if (self.widgetModel.rangeValue) {
        DJIParamCapabilityMinMax* range = (DJIParamCapabilityMinMax*)self.widgetModel.rangeValue;

        NSInteger min = [self.widgetModel.unitModule metersToMeasurementSystem:[range.min doubleValue]];
        NSInteger max = [self.widgetModel.unitModule metersToMeasurementSystem:[range.max doubleValue]];
        NSString *hintRange = [NSString stringWithFormat:@"%@(%ld-%ld%@)", (self.widgetModel.unitModule.unitType == DUXBetaMeasureUnitTypeImperial) ? @"≈" : @"", min, max, self.widgetModel.unitModule.unitSuffix];

        [self setHintText:hintRange];
        [self setEditFieldValuesMin:min maxValue:max];
    }

    [self updateUI];
}

- (void)unitsChanged {
    [self metaDataChanged];
    [self maxDistanceChanged];
}


- (void)setupUI {
    [super setupUI];
    
    __weak DUXBetaMaxFlightDistanceListItemWidget *weakSelf = self;
    [self setTextChangedBlock: ^(NSString *newText) {
        NSInteger newMaxDistance = [newText intValue];
        if (newMaxDistance > 0) {
            __strong DUXBetaMaxFlightDistanceListItemWidget *strongSelf = weakSelf;
            if (strongSelf) {
                // Convert max distance from current units to metric if needed
                newMaxDistance = [self.widgetModel.unitModule measurementRoundeUpToMeters:newMaxDistance];
                [strongSelf.widgetModel updateMaxDistance:newMaxDistance onCompletion:^(DUXBetaMaxFlightDistanceChange resultInfo) {
                    
                }];
            }
        }
    }];
}

- (void)updateUI {
    [super updateUI];
    
    BOOL isConnected = self.widgetModel.isProductConnected;
    BOOL isFlightRadiusEnabled = self.widgetModel.isFlightRadiusEnabled;
    BOOL isNoviceMode = self.widgetModel.isNoviceMode;

    if (isConnected == NO) {
        if (self.enableEditField == YES) {
            self.enableEditField = NO;
        }
        [self setEditText:NSLocalizedString(@"N/A", @"N/A")];
        [self hideHintLabel:YES];
        [self hideInputField:NO];
        [self setButtonHidden:YES];
    } else if (isNoviceMode) {
        if (self.enableEditField == YES) {
            self.enableEditField = NO;
        }
        [self setEditText:[self.widgetModel.unitModule metersToIntegerString:30.0]];
        [self hideHintLabel:YES];
        [self hideInputField:NO];
        [self setButtonHidden:YES];
    } else if (isFlightRadiusEnabled) {
        if (self.enableEditField == NO) {
            self.enableEditField = YES;
        }
        [self setEditText:[NSString stringWithFormat:@"%ld", (long) [self.widgetModel.unitModule metersToMeasurementSystem:self.widgetModel.maxFlightDistance]]];
        self.inputField.layer.borderWidth = self.editTextBorderWidth;
        [self hideInputAndHint:NO];
        [self updateButtonTitle];
        [self setButtonHidden:NO];
    } else {
        if (self.enableEditField == YES) {
            self.enableEditField = NO;
        }
        [self setEditText:[NSString stringWithFormat:@"%ld", (long) [self.widgetModel.unitModule metersToMeasurementSystem:self.widgetModel.maxFlightDistance]]];
        [self hideInputAndHint:YES];
        [self updateButtonTitle];
        [self setButtonHidden:NO];
    }
}

- (void)maxDistanceChanged {
    if (!self.widgetModel.isNoviceMode) {
        NSString *distanceString = [NSString stringWithFormat:@"%ld", (long)self.widgetModel.maxFlightDistance];
        [self setEditText:distanceString];
        [self updateUI];
    }
}

- (void)updateButtonTitle {
    if (self.widgetModel.isFlightRadiusEnabled) {
        [self setButtonTitle:self.disableButtonTitle];
    } else {
        [self setButtonTitle:self.enableButtonTitle];
    }
}

@end

#pragma mark - Hooks

@implementation MaxFlightDistanceItemModelState
+ (instancetype)setMaxFlightDistanceSucceeded {
    return [[self alloc] initWithKey:@"setMaxFlightDistanceSucceeded" number:@(YES)];
}

+ (instancetype)setMaxFlightDistanceFailed:(NSError*)error {
    return [[self alloc] initWithKey:@"setMaxFlightDistanceFailed" object:error];
}

+ (instancetype)maxFlightDistanceEnabled:(BOOL)isEnabled {
    return [[self alloc] initWithKey:@"maxFlightDistanceEnabled" number:@(isEnabled)];
}

+ (instancetype)maxFlightDistanceUpdated:(NSInteger)maxFlightDistance {
    return [[self alloc] initWithKey:@"maxFlightDistanceUpdated" number:@(maxFlightDistance)];
}
 
@end
