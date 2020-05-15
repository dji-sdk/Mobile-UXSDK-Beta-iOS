//
//  DUXMaxAltitudeListItemWidget.m
//  DJIUXSDKWidgets
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

#import "DUXMaxAltitudeListItemWidget.h"
#import "DUXMaxAltitudeListItemWidgetModel.h"
#import "NSObject+DUXBetaRKVOExtension.h"
@import DJIUXSDKCore;

@interface DUXMaxAltitudeListItemWidget()

@property (nonatomic) double fieldvalue;
@property (nonatomic, strong) DUXMaxAltitudeListItemWidgetModel *widgetModel;

@end

@implementation DUXMaxAltitudeListItemWidget

- (instancetype)init {
    if (self = [super init:DUXListItemOnlyEdit]) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init:DUXListItemOnlyEdit]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.widgetModel = [[DUXMaxAltitudeListItemWidgetModel alloc] init];
    [self.widgetModel setup];

    [self setTitle:NSLocalizedString(@"Max Flight Altitude", @"System Status Checklist Item Title") andIconName:@"SystemStatusMaxAltitudeLimit"];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(metaDataChanged), isNoviceMode, rangeValue);
    BindRKVOModel(self.widgetModel, @selector(maxAltitudeChanged), maxAltitude);
    BindRKVOModel(self.widgetModel, @selector(productConnectedChanged), isProductConnected);
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

    __weak DUXMaxAltitudeListItemWidget *weakSelf = self;
    [self setTextChangedBlock: ^(NSString *newText) {
        NSInteger newHeight = [newText intValue];
        if (newHeight > 0) {
            __strong DUXMaxAltitudeListItemWidget *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf handleMaxAltitudeChangeRequest:newHeight];
            }
        }
    }];
}

- (void)handleMaxAltitudeChangeRequest:(NSInteger) newHeight {
    if (!self.widgetModel.isNoviceMode) {
        // Quick sanity check
        __weak DUXMaxAltitudeListItemWidget *weakSelf = self;
        DUXMaxAltitudeChange heightValidity = [self.widgetModel validateNewHeight:newHeight];
        switch (heightValidity) {
            case DUXMaxAltitudeChangeMaxAltitudeValid:
            case DUXMaxAltitudeChangeAboveReturnHomeMaxAltitude:
            case DUXMaxAltitudeChangeAboveWarningHeightLimit:
            case DUXMaxAltitudeChangeAboveWarningHeightLimitAndReturnHomeAltitude:
                [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState validHeightEntered:newHeight]];
                break;
            
            default:
                [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState invalidHeightRejected:newHeight]];
                break;
        }

        if ((heightValidity == DUXMaxAltitudeChangeMaxAltitudeValid) || (heightValidity == DUXMaxAltitudeChangeAboveReturnHomeMaxAltitude)) {
            [self.widgetModel updateMaxHeight:newHeight onCompletion:^(DUXMaxAltitudeChange result) {
                if ((result == DUXMaxAltitudeChangeUnableToChangeMaxAltitudeInBeginnerMode) ||
                    (result == DUXMaxAltitudeChangeUnknownError) ||
                    (result == DUXMaxAltitudeChangeUnableToChangeReturnHomeAltitude)) {
                        [self presentFailed];
                    }
            }];
        } else if ((heightValidity == DUXMaxAltitudeChangeAboveWarningHeightLimit) || (heightValidity == DUXMaxAltitudeChangeAboveWarningHeightLimitAndReturnHomeAltitude)) {
            NSString *msg = NSLocalizedString(@"You Are Altering The Max Altitude Setting. This may violate local laws or regulations (for instance a 400ft (122m) height limit is set by the FAA in the USA). You are solely responsible and liable for the operation of the aircraft after altering these settings. DJI and its affiliates shall not be liable for any damages, whether in contract, tort (including negligence), or any other legal or equitable theory.", @"Warning when setting max height above legal limit");

            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Flight Warning", @"Flight Warning")
                                           message:msg
                                           preferredStyle:UIAlertControllerStyleAlert];
             
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {
                    __strong DUXMaxAltitudeListItemWidget *strongSelf = weakSelf;
                    [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogActionConfirm:@"Confirmed Max Altitude over 400ft warning"]];
                    if (heightValidity == DUXMaxAltitudeChangeAboveWarningHeightLimitAndReturnHomeAltitude) {
                        [strongSelf presentResetReturnHomeConfirmation:newHeight];
                    } else {
                        [strongSelf.widgetModel updateMaxHeight:newHeight onCompletion:^(DUXMaxAltitudeChange result) {
                            if ((result == DUXMaxAltitudeChangeUnableToChangeMaxAltitudeInBeginnerMode) ||
                                (result == DUXMaxAltitudeChangeUnknownError) ||
                                (result == DUXMaxAltitudeChangeUnableToChangeReturnHomeAltitude)) {
                                    [self presentFailed];
                                }
                        }];
                    }
            }];
            
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {
                [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogActionDismiss:@"Cancelled change from Max Altitude over 400ft warning"]];
            }];

            [alert addAction:cancelAction];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogDisplayed:@"Max Altitude over 400ft warning"]];
        }
    }
}

- (void)presentResetReturnHomeConfirmation:(NSInteger) newHeight {
    __weak DUXMaxAltitudeListItemWidget *weakSelf = self;

    NSString *msg = NSLocalizedString(@"Failsafe RTH altitude cannot exceed maximum flight altitude. Failsafe RTH altitude will be set to entered maximum altitude value", @"Warning when setting max height above RTH limit");

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Flight Warning", @"Flight Warning")
                                   message:msg
                                   preferredStyle:UIAlertControllerStyleAlert];
     
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {
            __strong DUXMaxAltitudeListItemWidget *strongSelf = weakSelf;
            [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogActionConfirm:@"Confirmed must change return home altitude"]];
            [strongSelf.widgetModel updateMaxHeight:newHeight onCompletion:^(DUXMaxAltitudeChange result) {
                if ((result == DUXMaxAltitudeChangeUnableToChangeMaxAltitudeInBeginnerMode) ||
                    (result == DUXMaxAltitudeChangeUnknownError) ||
                    (result == DUXMaxAltitudeChangeUnableToChangeReturnHomeAltitude)) {
                        [self presentFailed];
                    }
            }];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
            [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogActionDismiss:@"Cancelled must change return home altitude"]];
    }];

    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogDisplayed:@"Must change return home altitude"]];
}

- (void)presentFailed {
    NSString *msg = NSLocalizedString(@"Failed to set maximum altitude", @"Failed to set maximum altitude");
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Flight Warning", @"Flight Warning")
                                   message:msg
                                   preferredStyle:UIAlertControllerStyleAlert];
     
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {
        [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogDisplayed:@"Max Altitude change failed acknowledged."]];
    }];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    [DUXStateChangeBroadcaster send:[MaxAltitudeListItemUIState dialogDisplayed:@"Max Altitude change failed."]];
}

- (void)metaDataChanged {
    if (self.widgetModel.rangeValue) {
        DJIParamCapabilityMinMax* range = (DJIParamCapabilityMinMax*)self.widgetModel.rangeValue;

        NSInteger min = [range.min intValue];
        NSInteger max = [range.max intValue];
        NSString *hintRange = [NSString stringWithFormat:@"%ld-%ldm", min, max];
        [self setHintText:hintRange];
        [self setEditFieldValuesMin:min maxValue:max];
    }
    
    self.enableEditField = (self.widgetModel.isNoviceMode == NO) && self.widgetModel.isProductConnected;
 }

- (void)productConnectedChanged {
    self.enableEditField = (self.widgetModel.isNoviceMode == NO) && self.widgetModel.isProductConnected;
    [MaxAltitudeListItemModelState productConnected:self.widgetModel.isProductConnected];
    // If there was an existing connection, we need to reload the altitude value in case it was in the middle of being
    // changec during the disconnect.
    [self maxAltitudeChanged];
}

- (void)maxAltitudeChanged {
    NSString *heightString = [NSString stringWithFormat:@"%ld", (long)self.widgetModel.maxAltitude];
    [self setEditText:heightString];
}
@end

@implementation MaxAltitudeListItemUIState

+ (instancetype)invalidHeightRejected:(NSInteger)invalidHeightInMeters {
    return [[self alloc] initWithKey:@"invalidHeightRejected" number:@(invalidHeightInMeters)];
}

+ (instancetype)validHeightEntered:(NSInteger)invalidHeightInMeters {
    return [[self alloc] initWithKey:@"validHeightEntered" number:@(invalidHeightInMeters)];
}

@end

