//
//  DUXBetaMaxAltitudeListItemWidget.m
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

#import "DUXBetaMaxAltitudeListItemWidget.h"
#import "DUXBetaMaxAltitudeListItemWidgetModel.h"

#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaMaxAltitudeListItemWidget ()

@property (nonatomic) double fieldvalue;
@property (nonatomic, strong) DUXBetaMaxAltitudeListItemWidgetModel *widgetModel;
@property (nonatomic) DUXBetaAlertView *alert;

@end

@implementation DUXBetaMaxAltitudeListItemWidget

- (instancetype)init {
    if (self = [super init:DUXBetaListItemOnlyEdit]) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init:DUXBetaListItemOnlyEdit]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.widgetModel = [[DUXBetaMaxAltitudeListItemWidgetModel alloc] init];
    [self.widgetModel setup];
    
    // Load standard appearances for the 3 alerts we may show so they can be customized before use.
    [self loadCustomAlertsAppearance];
    
    [self setTitle:NSLocalizedString(@"Max Flight Altitude", @"System Status Checklist Item Title") andIconName:@"SystemStatusMaxAltitudeLimit"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(metaDataChanged), isNoviceMode, rangeValue);
    BindRKVOModel(self.widgetModel, @selector(maxAltitudeChanged), maxAltitude);
    BindRKVOModel(self.widgetModel, @selector(productConnectedChanged), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(unitsChanged), unitModule.unitType);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)dealloc {
    [_widgetModel cleanup];
}

- (void)setupUI {
    if (self.widgetModel == nil) {
        return;
    }

    if (self.trailingTitleGuide == nil) {
        [super setupUI];
        if (self.trailingTitleGuide == nil) {
            return;
        }
    }

    [self setHintText:NSLocalizedString(@"20-500m", @"20-500m")];

    __weak DUXBetaMaxAltitudeListItemWidget *weakSelf = self;
    [self setTextChangedBlock: ^(NSString *newText) {
        NSInteger newHeight = [newText intValue];
        if ((newHeight > 0) && (newHeight != (int)self.widgetModel.maxAltitude)) {
            __strong DUXBetaMaxAltitudeListItemWidget *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf handleMaxAltitudeChangeRequest:newHeight];
            }
        }
    }];
}

- (void)updateUI {
    [super updateUI];
    
    if (self.widgetModel.isProductConnected == NO) {
        if (self.enableEditField == YES) {
            self.enableEditField = NO;
        }
        [self setEditText:NSLocalizedString(@"N/A", @"N/A")];
        [self hideHintLabel:YES];
        [self hideInputField:NO];
    } else if (self.widgetModel.isNoviceMode) {
        if (self.enableEditField == YES) {
            self.enableEditField = NO;
        }
        [self setEditText:[self.widgetModel.unitModule metersToIntegerString:30.0]];
        [self hideHintLabel:YES];
        [self hideInputField:NO];
    } else {
        if (self.enableEditField == NO) {
            self.enableEditField = YES;
        }
        [self setEditText:[NSString stringWithFormat:@"%ld", (long) [self.widgetModel.unitModule metersToMeasurementSystem:self.widgetModel.maxAltitude]]];
        [self hideInputAndHint:NO];
        [self setButtonHidden:NO];
    }

}

- (void)loadCustomAlertsAppearance {
    self.aboveReturnToHomeAlertAppearance = [DUXBetaAlertView systemAlertAppearanceWarning];
    self.aboveLocalMaxAltitudeAlertAppearance = [DUXBetaAlertView systemAlertAppearanceWarning];
    self.maxAltitudeChangeFailedAlertAppearance = [DUXBetaAlertView systemAlertAppearanceError];
    self.maxAltitudeFlysafeLimitedAlertAppearance = [DUXBetaAlertView systemAlertAppearanceError];
}

- (void)handleMaxAltitudeChangeRequest:(NSInteger)newHeight {
    if (!self.widgetModel.isNoviceMode) {
        
        // Quick sanity check
        // Convert newHeight height from current units to metric if needed
        newHeight = [self.widgetModel.unitModule measurementRoundeUpToMeters:newHeight];
        DUXBetaMaxAltitudeChange heightValidity = [self.widgetModel validateNewHeight:newHeight];
        if (_widgetModel.needsFlightHeightLimit && (heightValidity ==  DUXBetaMaxAltitudeChangeAboveWarningHeightLimit || heightValidity == DUXBetaMaxAltitudeChangeAboveWarningHeightLimitAndBelowReturnHomeAltitude)) {
            [self presentLimitedHeightDeniedDialog: newHeight];
        } else  if ((heightValidity == DUXBetaMaxAltitudeChangeMaxAltitudeValid) ||
                    (heightValidity == DUXBetaMaxAltitudeChangeAboveReturnHomeMaxAltitude) ||
                    (heightValidity == DUXBetaMaxAltitudeChangeBelowReturnHomeAltitude)) {

            __weak DUXBetaMaxAltitudeListItemWidget *weakSelf = self;
            [self.widgetModel updateMaxHeight:newHeight onCompletion:^(DUXBetaMaxAltitudeChange result) {
                __strong DUXBetaMaxAltitudeListItemWidget *strongSelf = weakSelf;
                if ((result == DUXBetaMaxAltitudeChangeUnableToChangeMaxAltitudeInBeginnerMode) ||
                    (result == DUXBetaMaxAltitudeChangeUnknownError) ||
                    (result == DUXBetaMaxAltitudeChangeUnableToChangeReturnHomeAltitude)) {
                    [strongSelf presentError];
                    [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemModelState setMaxAltitudeFailed:result]];
                } else if (heightValidity == DUXBetaMaxAltitudeChangeBelowReturnHomeAltitude) {
                    [strongSelf presentResetReturnHomeConfirmation:newHeight];
                 }
            }];
        } else if ((heightValidity == DUXBetaMaxAltitudeChangeAboveWarningHeightLimit) ||
                   (heightValidity == DUXBetaMaxAltitudeChangeAboveWarningHeightLimitAndBelowReturnHomeAltitude)) {
            [self presentWarning:heightValidity newHeight:newHeight];
        }
    }
}

- (void)presentResetReturnHomeConfirmation:(NSInteger)newHeight {
    __weak DUXBetaMaxAltitudeListItemWidget *weakSelf = self;

    self.alert = [DUXBetaAlertView warningAlertWithTitle:NSLocalizedString(@"Max Flight Altitude", @"Max Flight Altitude")
                                             message:[NSString stringWithFormat:NSLocalizedString(@"Failsafe RTH altitude cannot exceed maximum flight altitude. Failsafe RTH altitude will be set to %@.", @"Warning when setting max height above RTH limit"), [self.widgetModel.unitModule metersToUnitString:newHeight]]];
    
    DUXBetaAlertAction *defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                    style:UIAlertActionStyleDefault
                                                               actionType:DUXBetaAlertActionTypeClosure
                                                                   target:nil
                                                                 selector:nil
                                                         completionAction:^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogActionConfirmed:@"MaxAltitudeReturnHomeAltitudeUpdate"]];
        
        __strong DUXBetaMaxAltitudeListItemWidget *strongSelf = weakSelf;
        [strongSelf.widgetModel updateMaxHeight:newHeight onCompletion:^(DUXBetaMaxAltitudeChange result) {
            if ((result == DUXBetaMaxAltitudeChangeUnableToChangeMaxAltitudeInBeginnerMode) ||
                (result == DUXBetaMaxAltitudeChangeUnknownError) ||
                (result == DUXBetaMaxAltitudeChangeUnableToChangeReturnHomeAltitude)) {
                [strongSelf presentError];
                [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemModelState setMaxAltitudeFailed:result]];
            } else {
                [strongSelf.alert closeWithCompletion:nil];
                [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemModelState setMaxAltitudeSucceeded]];

            }
        }];
    }];
    
    void (^dismissCallback)(void) = ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogDismissed:@"MaxAltitudeReturnHomeAltitudeUpdate"]];
    };
    void (^cancelCallback)(void) = ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogActionCanceled:@"MaxAltitudeReturnHomeAltitudeUpdate"]];
    };
    DUXBetaAlertAction *cancelAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                   style:UIAlertActionStyleCancel
                                                              actionType:DUXBetaAlertActionTypeClosure
                                                                  target:nil
                                                                selector:nil
                                                        completionAction:cancelCallback];
    self.alert.dissmissCompletion = dismissCallback;
    [self.alert add:cancelAction];
    [self.alert add:defaultAction];
    self.alert.appearance = self.aboveReturnToHomeAlertAppearance;
    
    [self.alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogDisplayed:@"MaxAltitudeReturnHomeAltitudeUpdate"]];
    }];
}
    
- (void)presentWarning:(DUXBetaMaxAltitudeChange)heightValidity newHeight:(NSInteger)newHeight {
    NSString *dialogIdentifier = @"MaxAltitudeOverAlarmConfirmation";
    self.alert = [DUXBetaAlertView warningAlertWithTitle:NSLocalizedString(@"Max Flight Altitude", @"Max Flight Altitude")
                                             message:NSLocalizedString(@"Altering the maximum altitude setting could violate local laws and regulations (a 400 ft / 120 m flight limit is set by the FAA).\nYou are solely responsible and liable for the operation of the aircraft after altering these settings.\nDJI and its affiliates shall not be liable for any damages, whether in contract, tort (including negligence), or any other legal or equitable theory.", @"Warning when setting max height above legal limit")];
    
    __weak DUXBetaMaxAltitudeListItemWidget *weakSelf = self;
    DUXBetaAlertAction *defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                    style:UIAlertActionStyleDefault
                                                               actionType:DUXBetaAlertActionTypeClosure
                                                                   target:nil
                                                                 selector:nil
                                                         completionAction:^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogActionConfirmed:dialogIdentifier]];
        __strong DUXBetaMaxAltitudeListItemWidget *strongSelf = weakSelf;
        if ((heightValidity == DUXBetaMaxAltitudeChangeAboveWarningHeightLimitAndBelowReturnHomeAltitude) || (heightValidity == DUXBetaMaxAltitudeChangeBelowReturnHomeAltitude)) {
            [strongSelf.alert closeWithCompletion: ^{
                [strongSelf presentResetReturnHomeConfirmation:newHeight];
            }];
        } else {
            [strongSelf.widgetModel updateMaxHeight:newHeight onCompletion:^(DUXBetaMaxAltitudeChange result) {
                if ((result == DUXBetaMaxAltitudeChangeUnableToChangeMaxAltitudeInBeginnerMode) ||
                    (result == DUXBetaMaxAltitudeChangeUnknownError) ||
                    (result == DUXBetaMaxAltitudeChangeUnableToChangeReturnHomeAltitude)) {
                    [self presentError];
                    [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemModelState setMaxAltitudeFailed:result]];
                } else {
                    [strongSelf.alert closeWithCompletion:nil];
                    [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemModelState setMaxAltitudeSucceeded]];
                }
            }];
        }
    }];
    
    void (^dismissCallback)(void) = ^{
        [weakSelf updateUI];
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogDismissed:dialogIdentifier]];
    };
    void (^cancelCallback)(void) = ^{
        [weakSelf updateUI];
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogActionCanceled:dialogIdentifier]];
    };
    DUXBetaAlertAction *cancelAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                   style:UIAlertActionStyleCancel
                                                              actionType:DUXBetaAlertActionTypeClosure
                                                                  target:nil
                                                                selector:nil
                                                        completionAction:cancelCallback];
    self.alert.dissmissCompletion = dismissCallback;
    
    [self.alert add:cancelAction];
    [self.alert add:defaultAction];
    self.alert.appearance = self.aboveLocalMaxAltitudeAlertAppearance;
    
    [self.alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogDisplayed:dialogIdentifier]];
    }];
}

- (void)presentLimitedHeightDeniedDialog:(NSInteger)newHeight {
    NSString *dialogIdentifier = @"FlightLimitNeededError";
    self.alert = [DUXBetaAlertView failAlertWithTitle:NSLocalizedString(@"Max Flight Altitude", @"Max Flight Altitude")
                                          message:NSLocalizedString(@"Setting failed. Flight altitude exceeds max limit (400 ft / 120m.)", @"Setting failed. Flight altitude exceeds max limit (400 ft / 120m.)")];
    
    DUXBetaAlertAction *defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                    style:UIAlertActionStyleCancel
                                                               actionType:DUXBetaAlertActionTypeClosure
                                                                   target:nil selector:nil
                                                         completionAction:^(){
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogActionConfirmed:dialogIdentifier]];
    }];
    
    void (^dismissCallback)(void) = ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogDismissed:dialogIdentifier]];
    };
    self.alert.dissmissCompletion = dismissCallback;
    [self.alert add:defaultAction];
    self.alert.appearance = self.maxAltitudeFlysafeLimitedAlertAppearance;
    [self.alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogDisplayed:dialogIdentifier]];
    }];
}

- (void)presentError {
    NSString *dialogIdentifier = @"MaxAltitudeOverAlarmConfirmation";
    self.alert = [DUXBetaAlertView failAlertWithTitle:NSLocalizedString(@"Max Flight Altitude", @"Max Flight Altitude")
                                         message:NSLocalizedString(@"Failed to set. Input number in range.", @"Failed to set. Input number in range.")];
    
    DUXBetaAlertAction *defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                    style:UIAlertActionStyleCancel
                                                               actionType:DUXBetaAlertActionTypeClosure
                                                                   target:nil selector:nil
                                                         completionAction:^(){
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogActionConfirmed:dialogIdentifier]];
    }];

    void (^dismissCallback)(void) = ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogDismissed:dialogIdentifier]];
    };
    self.alert.dissmissCompletion = dismissCallback;
    [self.alert add:defaultAction];
    self.alert.appearance = self.maxAltitudeChangeFailedAlertAppearance;
    [self.alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemUIState dialogDisplayed:dialogIdentifier]];
    }];
}

- (void)unitsChanged {
    [self metaDataChanged];
    [self maxAltitudeChanged];
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

- (void)productConnectedChanged {
    self.enableEditField = (self.widgetModel.isNoviceMode == NO) && self.widgetModel.isProductConnected;
    [MaxAltitudeItemModelState productConnected:self.widgetModel.isProductConnected];
    // If there was an existing connection, we need to reload the altitude value in case it was in the middle of being
    // changec during the disconnect.
    [self maxAltitudeChanged];
}

- (void)maxAltitudeChanged {
    NSString *heightString = [NSString stringWithFormat:@"%ld", (long)[self.widgetModel.unitModule metersToMeasurementSystem:self.widgetModel.maxAltitude]];
    [self setEditText:heightString];
    [self updateUI];
}

@end

@implementation MaxAltitudeItemUIState

@end

@implementation MaxAltitudeItemModelState

+ (instancetype)maxAltitudeChanged:(NSInteger)maxAltitude {
    return [[self alloc] initWithKey:@"maxAltitudeChanged" number:@(maxAltitude)];
}
 
+ (instancetype)setMaxAltitudeSucceeded {
    return [[self alloc] initWithKey:@"setMaxAltitudeSucceeded" number:@(YES)];
}

+ (instancetype)setMaxAltitudeFailed:(DUXBetaMaxAltitudeChange)error {
    return [[self alloc] initWithKey:@"setMaxAltitudeFailed" number:@(error)];
}

@end
