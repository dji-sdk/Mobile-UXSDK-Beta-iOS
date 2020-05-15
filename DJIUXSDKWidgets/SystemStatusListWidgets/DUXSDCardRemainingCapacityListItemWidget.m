//
//  DUXSDCardRemainingCapacityListItemWidget.m
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

#import "DUXSDCardRemainingCapacityListItemWidget.h"
#import "DUXSDCardRemainingCapacityListItemWidgetModel.h"
@import DJIUXSDKCore;

/**
 * DUXInternalSDCardFormattingStage is internal to SUXSDCardRemainingCapacityListItemWidget.
 * It is used to track the current state of formatting an SD card to allow notification when
 * an error occurs or successful completion is accomplished.
 */
NS_ENUM(NSInteger, DUXInternalSDCardFormattingStage) {
    DUXInternalSDCardFormattingNO = 0,
    DUXInternalSDCardFormattingYES,
    DUXInternalSDCardFormattingERROR
};

@interface DUXSDCardRemainingCapacityListItemWidget ()
@property (nonatomic, strong) DUXSDCardRemainingCapacityListItemWidgetModel *widgetModel;
@property (nonatomic, assign) enum DUXInternalSDCardFormattingStage         isFormatting;
@end

@implementation DUXSDCardRemainingCapacityListItemWidget

- (instancetype)init {
    if (self = [super init:DUXListItemLabelAndButton]) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init:DUXListItemLabelAndButton]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.minWidgetSize = CGSizeMake(820.0, 64.0);

    _widgetModel = [DUXSDCardRemainingCapacityListItemWidgetModel new];
    [_widgetModel setup];

    // Do any additional setup after loading the view.
    [super setButtonTitle:NSLocalizedString(@"Format", @"Format")];
    [super setTitle:NSLocalizedString(@"SD Card Remaining Capacity", @"DUXSDCardRemainingCapacityListItemWidget title") andIconName:@"SystemStatusStorageSDCard"];
    
    __weak DUXSDCardRemainingCapacityListItemWidget *weakSelf = self;
    [self setButtonAction:^(DUXSDCardRemainingCapacityListItemWidget* senderWidget) {
        __strong DUXSDCardRemainingCapacityListItemWidget *strongSelf = weakSelf;
        [strongSelf displayFormatSDCardDialog];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(productConnected), isProductConnected);
    
    BindRKVOModel(self.widgetModel, @selector(storageUpdated), freeStorageInMB);
    BindRKVOModel(self.widgetModel, @selector(sdCardInsertedUpdated), isSDCardInserted);
    BindRKVOModel(self.widgetModel, @selector(sdOperationStateUpdated), sdOperationState);
    BindRKVOModel(self.widgetModel, @selector(sdCardFormatErrorUpdated), sdCardFormatError);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [_widgetModel cleanup];
}

- (void)productConnected {
    [SDCardRemainingCapacityListWidgetModelState productConnected:self.widgetModel.isProductConnected];
    [self updatePresentationDisplay];
}

- (void)storageUpdated {
    [SDCardRemainingCapacityListWidgetModelState sdCardRemainingCapacityChanged:self.widgetModel.freeStorageInMB];
    [self updatePresentationDisplay];
}

- (void)sdCardInsertedUpdated {
    [SDCardRemainingCapacityListWidgetModelState sdCardRemainingCapacityCardInserted:self.widgetModel.isSDCardInserted];
    [self updatePresentationDisplay];
}

- (void)sdOperationStateUpdated {
    [SDCardRemainingCapacityListWidgetModelState sdCardRemainingCapacityOperatingStatusChanged:@(self.widgetModel.sdOperationState)];
    [self updatePresentationDisplay];
}

- (void)sdCardFormatErrorUpdated {
    _isFormatting = DUXInternalSDCardFormattingERROR;
    [self updatePresentationDisplay];
}

- (void)updatePresentationDisplay {
    NSString *displayString = @"";
    BOOL enableFormat = YES;
    BOOL isDisabled = NO;
    BOOL isNormal = NO;
    enum DUXInternalSDCardFormattingStage stillFormatting = DUXInternalSDCardFormattingNO;

    if (!_widgetModel.isProductConnected) {
        displayString = NSLocalizedString(@"N/A", @"N/A");
        enableFormat = NO;
        isDisabled = YES;
        if (_isFormatting == DUXInternalSDCardFormattingYES) {
            stillFormatting = DUXInternalSDCardFormattingERROR;
        }
    } else if (_widgetModel.isSDCardInserted && (_widgetModel.sdOperationState == DJICameraSDCardOperationStateNormal)) {
        isNormal = YES;
        if (_widgetModel.freeStorageInMB > 1024) {
            displayString = [NSString stringWithFormat:@"%.02f GB", (_widgetModel.freeStorageInMB / 1024.0f)];
        } else {
            displayString = [NSString stringWithFormat:@"%ld MB", (long) _widgetModel.freeStorageInMB];
        }
    } else {
        if ((_widgetModel.isSDCardInserted == NO) || (_widgetModel.sdOperationState == DJICameraSDCardOperationStateNotInserted)) {
            displayString = NSLocalizedString(@"Not Inserted", @"Not Inserted");
            enableFormat = NO;
        } else {
            switch (_widgetModel.sdOperationState) {
                case DJICameraSDCardOperationStateNormal:
                    // This state can only be reached if isSDCardInserted == NO, but state is normal
                    isNormal = YES;
                    if (_widgetModel.freeStorageInMB > 1024) {
                        displayString = [NSString stringWithFormat:@"%.02f GB", (_widgetModel.freeStorageInMB / 1024.0f)];
                    } else {
                        displayString = [NSString stringWithFormat:@"%ld MB", (long) _widgetModel.freeStorageInMB];
                    }
                    break;
                case DJICameraSDCardOperationStateNotInserted:
                    // This can only be reached if isSDCardInserted is YES, but the sdOperationState is not inserted. Should not be possible
                    displayString = NSLocalizedString(@"Not Inserted", @"Not Inserted");
                    enableFormat = NO;
                    if (_isFormatting == DUXInternalSDCardFormattingYES) {
                        stillFormatting = DUXInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateInvalid:
                    displayString = NSLocalizedString(@"Invalid", @"Invalid");
                    enableFormat = NO;
                    if (_isFormatting == DUXInternalSDCardFormattingYES) {
                        stillFormatting = DUXInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateReadOnly:
                    displayString = NSLocalizedString(@"Write Protected", @"Write Protected");
                    enableFormat = NO;
                    if (_isFormatting == DUXInternalSDCardFormattingYES) {
                        stillFormatting = DUXInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationFormatNeeded:
                    displayString = NSLocalizedString(@"Format Required", @"Format Required");
                    if (_isFormatting == DUXInternalSDCardFormattingYES) {
                        stillFormatting = DUXInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateFormatting:
                    displayString = NSLocalizedString(@"Formatting…", @"Formatting…");
                    enableFormat = NO;
                    stillFormatting = YES;
                    break;
                case DJICameraSDCardOperationStateInvalidFileSystem:
                    displayString = NSLocalizedString(@"Format Required", @"Format Required");
                    if (_isFormatting == DUXInternalSDCardFormattingYES) {
                        stillFormatting = DUXInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateBusy:
                    displayString = NSLocalizedString(@"Busy", @"Busy");
                    enableFormat = NO;
                    break;
                case DJICameraSDCardOperationStateFull:
                    displayString = NSLocalizedString(@"Full", @"Full");
                    break;
                case DJICameraSDCardOperationStateSlow:
                    displayString = NSLocalizedString(@"Slow", @"Slow");
                    break;
                case DJICameraSDCardOperationStateUnknownError:
                    displayString = NSLocalizedString(@"Unknown Error", @"Unknown Error");
                    enableFormat = NO;
                    if (_isFormatting == DUXInternalSDCardFormattingYES) {
                        stillFormatting = DUXInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateNoRemainFileIndices:
                    displayString = NSLocalizedString(@"No file indices", @"No file indices");
                    break;
                case DJICameraSDCardOperationStateInitializing:
                    displayString = NSLocalizedString(@"Initializing", @"Initializing");
                    enableFormat = NO;
                    break;
                case DJICameraSDCardOperationStateFormatRecommended:
                    displayString = NSLocalizedString(@"Formatting Recommended", @"Formatting Recommended");
                    break;
                case DJICameraSDCardOperationStateRecoveringFiles:
                    displayString = NSLocalizedString(@"Repairing Video Files", @"Repairing Video Files");
                    enableFormat = NO;
                    break;
                case DJICameraSDCardOperationStateWritingSlowly:
                    displayString = NSLocalizedString(@"Slow Write Speed", @"Slow Write Speed");
                    break;
                default:
                    displayString = NSLocalizedString(@"Unknown Error", @"Unknown Error");
                    enableFormat = NO;
                    if (_isFormatting == DUXInternalSDCardFormattingYES) {
                        stillFormatting = DUXInternalSDCardFormattingERROR;
                    }
                    break;
            }
        }
    }
    
    // Final step, set display text, colors and button enable state
    self.buttonEnabled = enableFormat;
    // These need to look at the final customizaton colors
    [self.displayTextLabel setText:displayString];
    UIColor *textColor = [UIColor duxbeta_warningColor];
    if (isNormal) {
        textColor = [UIColor duxbeta_whiteColor];
    } else if (isDisabled) {
        textColor = [UIColor duxbeta_disabledGrayColor];
    }
    [self.displayTextLabel setTextColor:textColor];

    if ((_isFormatting != DUXInternalSDCardFormattingNO) && (stillFormatting != DUXInternalSDCardFormattingYES)) {
        // Transitioned on the format state. Was it successful or not??
        BOOL success = (_isFormatting == DUXInternalSDCardFormattingYES)
                        && (stillFormatting != DUXInternalSDCardFormattingYES)
                        && (self.widgetModel.sdCardFormatError == NO);
        _isFormatting = DUXInternalSDCardFormattingNO;
        [self displayFormatCompletedDialog:success];
    }
}

- (void)displayFormatSDCardDialog {
    __weak DUXSDCardRemainingCapacityListItemWidget *weakSelf = self;

    NSString *msg = NSLocalizedString(@"Are you sure you want to format the SD card?", "Camera Formatting Workflow Action Description");
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"⚠️ SD Card Format", @"⚠️ SD Card Format")
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
     
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
            __strong DUXSDCardRemainingCapacityListItemWidget *strongSelf = weakSelf;
        
            [DUXStateChangeBroadcaster send:[SDCardRemainingCapacityListWidgetUIState dialogActionConfirm:@"sdCardFormatDialogConfirm"]];
        
            strongSelf.isFormatting = YES;
            [self.widgetModel formatSDCard];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        [DUXStateChangeBroadcaster send:[SDCardRemainingCapacityListWidgetUIState dialogActionDismiss:@"sdCardFormatDialogConfirmCancel"]];
        __strong DUXSDCardRemainingCapacityListItemWidget *strongSelf = weakSelf;
        strongSelf.isFormatting = NO;
    }];

    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    [DUXStateChangeBroadcaster send:[SDCardRemainingCapacityListWidgetUIState dialogDisplayed:@"sdCardFormatDialog"]];
}

- (void)displayFormatCompletedDialog:(BOOL)success {

    NSString *msg;
    NSString *title;
    if (success) {
        title = NSLocalizedString(@"✅ SD Card Format", @"✅ SD Card Format");
        msg = NSLocalizedString(@"SD card formatting completed.", "Camera Formatting Workflow Success Description");
    } else {
        title = NSLocalizedString(@"🛑 SD Card Format", @"🛑 SD Card Format");
        msg = NSLocalizedString(@"Error formatting SD card.", "Camera Formatting Workflow Failure Description");
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
     
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        
        if (success) {
            [DUXStateChangeBroadcaster send:[SDCardRemainingCapacityListWidgetUIState dialogActionDismiss:@"sdCardFormatDialogResultSuccess"]];
        } else {
            [DUXStateChangeBroadcaster send:[SDCardRemainingCapacityListWidgetUIState dialogActionDismiss:@"sdCardFormatDialogResultFailed"]];
        }
    }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    [DUXStateChangeBroadcaster send:[SDCardRemainingCapacityListWidgetUIState dialogDisplayed:@"sdCardFormatDialogResult"]];
    self.widgetModel.sdCardFormatError = NO;
}


@end
    
@implementation SDCardRemainingCapacityListWidgetModelState

+ (instancetype)sdCardRemainingCapacityChanged:(NSInteger)freeStorageChanged {
    return [[SDCardRemainingCapacityListWidgetModelState alloc] initWithKey:@"sdCardRemainingCapacityChanged" number:@(freeStorageChanged)];
}

+ (instancetype)sdCardRemainingCapacityCardInserted:(BOOL)cardInserted {
    return [[SDCardRemainingCapacityListWidgetModelState alloc] initWithKey:@"sdCardRemainingCapacityCardInserted" number:@(cardInserted)];
}

+ (instancetype)sdCardRemainingCapacityOperatingStatusChanged:(NSNumber *)operationState {
    return [[SDCardRemainingCapacityListWidgetModelState alloc] initWithKey:@"sdCardRemainingCapacityOperatingStatusChanged" value:operationState];
}

@end

@implementation SDCardRemainingCapacityListWidgetUIState

@end
