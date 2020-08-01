//
//  DUXBetaReturnToHomeAltitudeListItemWidget.m
//  DJIUXSDKWidgets
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

#import "DUXBetaReturnToHomeAltitudeListItemWidget.h"
#import "DUXBetaReturnToHomeAltitudeListItemWidgetModel.h"
#import "NSObject+DUXBetaRKVOExtension.h"
#import <DJIUXSDKWidgets/DJIUXSDKWidgets-Swift.h>

@import DJIUXSDKCore;

@interface DUXBetaReturnToHomeAltitudeListItemWidget ()
@property (nonatomic, strong) DUXBetaReturnToHomeAltitudeListItemWidgetModel *widgetModel;
@end

@implementation DUXBetaReturnToHomeAltitudeListItemWidget

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
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    _widgetModel = [DUXBetaReturnToHomeAltitudeListItemWidgetModel new];
    [self.widgetModel setup];

    // Load standard appearances for the 2 alerts we may show so they can be customized before use.
    [self loadCustomAlertsAppearance];
    
    [self setTitle:NSLocalizedString(@"Return-To-Home Altitude", @"System Status Checklist Item Title") andIconName:@"SystemStatusRTHAltitude"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(metaDataChanged), isNoviceMode, rangeValue);
    BindRKVOModel(self.widgetModel, @selector(maxAltitudeChanged), maxAltitude);
    BindRKVOModel(self.widgetModel, @selector(rthAltitudeChanged), returnToHomeAltitude);
    BindRKVOModel(self.widgetModel, @selector(productConnectedChanged), isProductConnected);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)productConnectedChanged {
    if (self.widgetModel.isProductConnected == NO) {
        [self setEditText:NSLocalizedString(@"N/A", @"N/A")];
    } else {
        // If product was just connected, the RTH height doesn't always change on update, so we need to manually set this.
        [self maxAltitudeChanged];
    }

    [self updateUI];
}

- (void)metaDataChanged {
    if (self.widgetModel.rangeValue) {
        NSInteger min = [self.widgetModel.rangeValue.min intValue];
        NSInteger max = [self.widgetModel.rangeValue.max intValue];

        NSString *rangeString = [NSString stringWithFormat:@"(%ld-%ld%@)", min, max, self.widgetModel.measurementUnitString];
        [self setHintText:rangeString];
        [self setEditFieldValuesMin:min maxValue:max];
    }

    [self updateUI];
}

- (void)maxAltitudeChanged {
    [self metaDataChanged];
    // If we want to auto-update the RTH, do so here, but MaxAltitudeListItemWidget will adjust down as required.
    [self updateUI];
}

- (void)rthAltitudeChanged {
    if (!self.widgetModel.isNoviceMode) {
        NSString *heightString = [NSString stringWithFormat:@"%ld", (long)self.widgetModel.returnToHomeAltitude];
        [self setEditText:heightString];
    }
}

- (void)setupUI {
    [super setupUI];
    
    __weak DUXBetaReturnToHomeAltitudeListItemWidget *weakSelf = self;
    [self setTextChangedBlock: ^(NSString *newText) {
        NSInteger newHeight = [newText intValue];
        // TODO: Once we handle imperial units here, there needs to be some slop added to the altitude change comparison
        if ((newHeight > 0) && (newHeight != (int)self.widgetModel.returnToHomeAltitude))  {
            __strong DUXBetaReturnToHomeAltitudeListItemWidget *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf handleRTHAltitudeChangeRequest:newHeight];
            }
        }
    }];
}

- (void)loadCustomAlertsAppearance {
    self.rthAltitudeChangeAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.rthAltitudeChangeAlertAppearance.heightScale = DUXBetaAlertViewHeightScaleSmall;
    self.rthAltitudeChangeAlertAppearance.imageTintColor = [UIColor duxbeta_warningColor];
    
    self.rthAltitudeExceedsMaxAltitudeAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.rthAltitudeExceedsMaxAltitudeAlertAppearance.heightScale = DUXBetaAlertViewHeightScaleSmall;
    self.rthAltitudeExceedsMaxAltitudeAlertAppearance.imageTintColor = [UIColor duxbeta_dangerColor];
}

- (void)updateUI {
    [super updateUI];
    
    BOOL isConnected = self.widgetModel.isProductConnected;
    BOOL isNoviceMode = self.widgetModel.isNoviceMode;

    if (isConnected == NO) {
        if (self.enableEditField == YES) {
            self.enableEditField = NO;
        }
        [self setEditText:NSLocalizedString(@"N/A", @"N/A")];
        [self hideHintLabel:YES];
        [self hideInputField:NO];
    } else if (isNoviceMode) {
        if (self.enableEditField == YES) {
            self.enableEditField = NO;
        }
        [self setEditText:[self.widgetModel metersToUnitString:30.0]];
        [self hideHintLabel:YES];
        [self hideInputField:NO];
    } else {
        if (self.enableEditField == NO) {
            self.enableEditField = YES;
        }
        [self setEditText:[NSString stringWithFormat:@"%ld", (long) [self.widgetModel metersToMeasurementSystem:self.widgetModel.returnToHomeAltitude]]];
        [self hideInputAndHint:NO];
    }
}

- (void)handleRTHAltitudeChangeRequest:(NSInteger) newHeight {
    if (self.widgetModel.isNoviceMode) { return; }
    
    // Quick sanity check
    DUXBetaReturnToHomeAltitudeChange heightValidity = [self.widgetModel validateNewHeight:newHeight];
    switch (heightValidity) {
        case DUXBetaReturnToHomeAltitudeChangeValid:
        case DUXBetaReturnToHomeAltitudeChangeAboveWarningHeightLimit:
            [DUXBetaStateChangeBroadcaster send:[ReturnToHomeAltitudeListItemUIState validHeightEntered:newHeight]];
            break;

        case DUXBetaReturnToHomeAltitudeChangeAboveMaximumAltitude:
            break;

        default:
            [DUXBetaStateChangeBroadcaster send:[ReturnToHomeAltitudeListItemUIState invalidHeightRejected:newHeight]];
            break;
    }

    if ((heightValidity == DUXBetaReturnToHomeAltitudeChangeValid) || (heightValidity == DUXBetaReturnToHomeAltitudeChangeAboveWarningHeightLimit)) {
        [self.widgetModel updateReturnHomeHeight:newHeight onCompletion:^(DUXBetaReturnToHomeAltitudeChange result) {
            if (result == DUXBetaReturnToHomeAltitudeChangeValid) {
                [self presentWarning];
            }
        }];
    } else if (heightValidity == DUXBetaReturnToHomeAltitudeChangeAboveMaximumAltitude) {
        [self presentError];
    }
}

- (void)presentWarning {
    DUXBetaAlertView *alert = [DUXBetaAlertView warningAlertWithTitle:NSLocalizedString(@"Return to Home Altitude", @"Return to Home Altitude")
                                                      message:NSLocalizedString(@"The return altitude has been changed, please pay attention to flight safety.", @"The return altitude has been changed, please pay attention to flight safety.")
                                                  heightScale:DUXBetaAlertViewHeightScaleSmall];
    void (^dismissCallback)(void) = ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogActionDismiss:@"Return To Home Altitude change acknowledged."]];
    };
    DUXBetaAlertAction *cancelAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                   style:UIAlertActionStyleCancel
                                                              actionType:DUXBetaAlertActionTypeClosure
                                                                  target:nil
                                                                selector:nil
                                                        completionAction:dismissCallback];
    alert.dissmissCompletion = dismissCallback;
    [alert add:cancelAction];
    alert.appearance = self.rthAltitudeChangeAlertAppearance;
    [alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogDisplayed:@"Return To Home Altitude change acknowledged."]];
    }];
}

- (void)presentError {
    DUXBetaAlertView *alert = [DUXBetaAlertView failAlertWithTitle:NSLocalizedString(@"Return to Home Altitude", @"Return to Home Altitude")
                                                  message:NSLocalizedString(@"Return to home altitude cannot exceed maximum flight altitude.", @"Return to home altitude cannot exceed maximum flight altitude.")
                                              heightScale:DUXBetaAlertViewHeightScaleSmall];
    
    void (^dismissCallback)(void) = ^{
        [DUXBetaStateChangeBroadcaster send:[ReturnToHomeAltitudeListItemUIState dialogDisplayed:@"Return To Home Altitude change failed acknowledged."]];
    };
    DUXBetaAlertAction *defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                    style:UIAlertActionStyleDefault
                                                               actionType:DUXBetaAlertActionTypeClosure
                                                                   target:nil
                                                                 selector:nil
                                                         completionAction:dismissCallback];
    alert.dissmissCompletion = dismissCallback;
    [alert add:defaultAction];
    alert.appearance = self.rthAltitudeExceedsMaxAltitudeAlertAppearance;
    [alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[ReturnToHomeAltitudeListItemUIState dialogDisplayed:@"Return To Home Altitude change failed."]];
    }];
    [self rthAltitudeChanged]; // Revert display text to current RTH altitude value.
}

@end

@implementation ReturnToHomeAltitudeListItemUIState
+ (instancetype)invalidHeightRejected:(NSInteger)invalidHeightInMeters {
    return [[self alloc] initWithKey:@"invalidHeightRejected" number:@(invalidHeightInMeters)];
}

+ (instancetype)validHeightEntered:(NSInteger)validHeightInMeters {
    return [[self alloc] initWithKey:@"validHeightEntered" number:@(validHeightInMeters)];
}
@end
