//
//  DUXBetaSDCardStatusListItemWidget.m
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

#import "DUXBetaSDCardStatusListItemWidget.h"
#import "DUXBetaSDCardStatusListItemWidgetModel.h"

#import <UXSDKCore/UXSDKCore-Swift.h>

/**
 * DUXBetaInternalSDCardFormattingStage is internal to DUXBetaSDCardRemainingCapacityListItemWidget.
 * It is used to track the current state of formatting an SD card to allow notification when
 * an error occurs or successful completion is accomplished.
 */
NS_ENUM(NSInteger, DUXBetaInternalSDCardFormattingStage) {
    DUXBetaInternalSDCardFormattingNO = 0,
    DUXBetaInternalSDCardFormattingYES,
    DUXBetaInternalSDCardFormattingERROR
};

@interface DUXBetaSDCardStatusListItemWidget ()
@property (nonatomic, strong) DUXBetaSDCardStatusListItemWidgetModel *widgetModel;
@property (nonatomic, assign) enum DUXBetaInternalSDCardFormattingStage         isFormatting;
@property (nonatomic, assign) enum DUXBetaInternalSDCardFormattingStage         stillFormatting;
@end

@implementation DUXBetaSDCardStatusListItemWidget

- (instancetype)init {
    if (self = [super init:DUXBetaListItemLabelAndButton]) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init:DUXBetaListItemLabelAndButton]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.minWidgetSize = CGSizeMake(820.0, 64.0);

    _widgetModel = [DUXBetaSDCardStatusListItemWidgetModel new];
    [_widgetModel setup];

    // Load standard appearances for the 3 alerts we may show so they can be customized before use.
    [self loadCustomAlertsAppearance];

    // Do any additional setup after loading the view.
    [super setButtonTitle:NSLocalizedString(@"Format", @"Format")];
    [super setTitle:NSLocalizedString(@"SD Card Storage", @"DUXBetaSDCardStatusListItemWidget title") andIconName:@"SystemStatusStorageSDCard"];
    
    __weak DUXBetaSDCardStatusListItemWidget *weakSelf = self;
    [self setButtonAction:^(DUXBetaSDCardStatusListItemWidget* senderWidget) {
        __strong DUXBetaSDCardStatusListItemWidget *strongSelf = weakSelf;
        [strongSelf displayFormatSDCardDialog];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(productConnected), isProductConnected);
    
    BindRKVOModel(self.widgetModel, @selector(storageUpdated), freeStorageInMB);
    BindRKVOModel(self.widgetModel, @selector(sdOperationStateUpdated), sdOperationState);
    BindRKVOModel(self.widgetModel, @selector(sdCardFormatErrorUpdated), sdCardFormatError);
    BindRKVOModel(self, @selector(formattingStatusChanged), isFormatting);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [_widgetModel cleanup];
}

- (void)loadCustomAlertsAppearance {
    self.sdCardConfirmFormatAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.sdCardConfirmFormatAlertAppearance.imageTintColor = [UIColor uxsdk_warningColor];
    
    self.sdCardFormattingSuccessAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.sdCardFormattingSuccessAlertAppearance.imageTintColor = [UIColor uxsdk_successColor];
    
    self.sdCardFormattingErrorAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.sdCardFormattingErrorAlertAppearance.imageTintColor = [UIColor uxsdk_errorDangerColor];
}

- (void)productConnected {
    [SDCardStatusItemModelState productConnected:self.widgetModel.isProductConnected];
    [self updatePresentationDisplay];
}

- (void)storageUpdated {
    [SDCardStatusItemModelState sdCardStatusCapacityChanged:self.widgetModel.freeStorageInMB];
    [self updatePresentationDisplay];
}

- (void)sdOperationStateUpdated {
    [SDCardStatusItemModelState sdCardStateUpdated:@(self.widgetModel.sdOperationState)];
    [self updatePresentationDisplay];
}

- (void)sdCardFormatErrorUpdated {
    if (self.widgetModel.sdCardFormatError) {
        _isFormatting = DUXBetaInternalSDCardFormattingERROR;
    }
    [self updatePresentationDisplay];
    
    if (self.widgetModel.sdCardFormatError &&
        (self.widgetModel.sdOperationState == DJICameraSDCardOperationStateInvalidFileSystem || self.widgetModel.sdOperationState == DJICameraSDCardOperationStateNormal)) {
        [self displayFormatCompletedDialog:NO];
    }
}

- (NSString*)displayStringForSDCardFreeSpace {
    if (_widgetModel.freeStorageInMB > 1024) {
        return [NSString stringWithFormat:@"%.02f GB", (_widgetModel.freeStorageInMB / 1024.0f)];
    } else {
        return [NSString stringWithFormat:@"%ld MB", (long) _widgetModel.freeStorageInMB];
    }
}

- (void)updatePresentationDisplay {
    NSString *displayString = @"";
    BOOL enableFormat = YES;
    BOOL isDisabled = NO;
    BOOL isNormal = NO;
    BOOL formattingJustEnded = NO;

    if (!_widgetModel.isProductConnected) {
        displayString = NSLocalizedString(@"N/A", @"N/A");
        enableFormat = NO;
        isDisabled = YES;
        if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
            _stillFormatting = DUXBetaInternalSDCardFormattingERROR;
        }
    } else if (_widgetModel.isSDCardInserted && (_widgetModel.sdOperationState == DJICameraSDCardOperationStateNormal)) {
        isNormal = YES;
        displayString = [self displayStringForSDCardFreeSpace];
        if (_stillFormatting && (_widgetModel.sdOperationState == DJICameraSDCardOperationStateNormal)) {
            formattingJustEnded = YES;
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
                    displayString = [self displayStringForSDCardFreeSpace];
                    break;
                case DJICameraSDCardOperationStateNotInserted:
                    // This can only be reached if isSDCardInserted is YES, but the sdOperationState is not inserted. Should not be possible
                    displayString = NSLocalizedString(@"Not Inserted", @"Not Inserted");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
                        _stillFormatting = DUXBetaInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateInvalid:
                    displayString = NSLocalizedString(@"Invalid", @"Invalid");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
                        _stillFormatting = DUXBetaInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateReadOnly:
                    displayString = NSLocalizedString(@"Write Protected", @"Write Protected");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
                        _stillFormatting = DUXBetaInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationFormatNeeded:
                    displayString = NSLocalizedString(@"Format Required", @"Format Required");
                    if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
                        _stillFormatting = DUXBetaInternalSDCardFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateFormatting:
                    displayString = NSLocalizedString(@"Formatting…", @"Formatting…");
                    enableFormat = NO;
                    _stillFormatting = YES;
                    break;
                case DJICameraSDCardOperationStateInvalidFileSystem:
                    displayString = NSLocalizedString(@"Format Required", @"Format Required");
                    if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
                        _stillFormatting = DUXBetaInternalSDCardFormattingERROR;
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
                    displayString = [NSString stringWithFormat:@"%@, (%@)", NSLocalizedString(@"Slow", @"Slow"), [self displayStringForSDCardFreeSpace]];
                    break;
                case DJICameraSDCardOperationStateUnknownError:
                    displayString = NSLocalizedString(@"Unknown Error", @"Unknown Error");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
                        _stillFormatting = DUXBetaInternalSDCardFormattingERROR;
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
                    if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
                        _stillFormatting = DUXBetaInternalSDCardFormattingERROR;
                    }
                    break;
            }
        }
    }
    
    // Final step, set display text, colors and button enable state
    self.buttonEnabled = enableFormat;
    // These need to look at the final customizaton colors
    [self.displayTextLabel setText:displayString];
    UIColor *textColor = [UIColor uxsdk_warningColor];
    if (isNormal) {
        textColor = [UIColor uxsdk_whiteColor];
    } else if (isDisabled) {
        textColor = [UIColor uxsdk_disabledGrayWhite58];
    }
    [self.displayTextLabel setTextColor:textColor];

    if ((_isFormatting == DUXBetaInternalSDCardFormattingYES) && ((_stillFormatting != DUXBetaInternalSDCardFormattingYES) || formattingJustEnded)) {
        // Set the isFormatting flag. The KVO will then decide if the error dialog needs to be shown.
        self.isFormatting = DUXBetaInternalSDCardFormattingNO;
    }
}

- (void)formattingStatusChanged {
    if (_isFormatting == DUXBetaInternalSDCardFormattingNO) {
        // Formatting has ended if _stillFormatting is not NO because we only set it to DUXBetaInternalSDCardFormattingNO in here when processing is done.
        if (_stillFormatting != DUXBetaInternalSDCardFormattingNO) {
            BOOL success = (_stillFormatting == DUXBetaInternalSDCardFormattingYES) && (self.widgetModel.sdCardFormatError == NO);
            _isFormatting = DUXBetaInternalSDCardFormattingNO;
            [self displayFormatCompletedDialog:success];
            _stillFormatting = DUXBetaInternalSDCardFormattingNO;
        }
    } else if (_isFormatting == DUXBetaInternalSDCardFormattingYES) {
        // Just started formatting, only set the flag to know if we think it is still happening.
        _stillFormatting = DUXBetaInternalSDCardFormattingYES;
    } else {
        if (self.isFormatting == DUXBetaInternalSDCardFormattingERROR) {
            // We can skip checking DUXBetaInternalSDCardFormattingERROR state, because this is catched by sdCardFormatErrorUpdated method
            return;
        }
        // Either done normally or errored
        BOOL success = !((_stillFormatting == DUXBetaInternalSDCardFormattingERROR) || (self.widgetModel.sdCardFormatError == YES));
        [self displayFormatCompletedDialog:success];
    }
}

- (void)displayFormatSDCardDialog {
    NSString *dialogIdentifier = @"FormatConfirmation";
    __weak DUXBetaSDCardStatusListItemWidget *weakSelf = self;

    DUXBetaAlertView *alert = [DUXBetaAlertView warningAlertWithTitle:NSLocalizedString(@"SD Card Format", @"SD Card Format")
                                                      message:NSLocalizedString(@"Are you sure you want to format the SD card?", "SD Formatting Workflow Action Description")];
    DUXBetaAlertAction *defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                    style:UIAlertActionStyleDefault
                                                               actionType:DUXBetaAlertActionTypeClosure
                                                                   target:nil
                                                                 selector:nil
                                                         completionAction:^{
        __strong DUXBetaSDCardStatusListItemWidget *strongSelf = weakSelf;
    
        [DUXBetaStateChangeBroadcaster send:[SDCardStatusItemUIState dialogActionConfirmed:dialogIdentifier]];
    
        strongSelf.isFormatting = YES;
        [self.widgetModel formatSDCard];
    }];
    
    DUXBetaAlertAction *cancelAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                   style:UIAlertActionStyleCancel
                                                              actionType:DUXBetaAlertActionTypeClosure
                                                                  target:nil
                                                                selector:nil
                                                        completionAction:^{
        [DUXBetaStateChangeBroadcaster send:[SDCardStatusItemUIState dialogActionCanceled:dialogIdentifier]];
        __strong DUXBetaSDCardStatusListItemWidget *strongSelf = weakSelf;
        strongSelf.isFormatting = NO;
    }];
    [alert setDissmissCompletion:^{
        [DUXBetaStateChangeBroadcaster send:[SDCardStatusItemUIState dialogDismissed:dialogIdentifier]];
    }];
    [alert add:cancelAction];
    [alert add:defaultAction];
    alert.appearance = self.sdCardConfirmFormatAlertAppearance;
    [alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[SDCardStatusItemUIState dialogDisplayed:dialogIdentifier]];
    }];
}

- (void)displayFormatCompletedDialog:(BOOL)success {
    DUXBetaAlertView *alert;
    DUXBetaAlertAction *defaultAction;
    NSString *dialogIndentifier = success ? @"FromatSuccess": @"FormatError";
    
    if (success) {
        alert = [DUXBetaAlertView successAlertWithTitle:NSLocalizedString(@"SD Card Format", @"SD Card Format")
                                            message:NSLocalizedString(@"SD card formatting completed.", "Camera Formatting Workflow Success Description")];
        defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                        style:UIAlertActionStyleCancel
                                                   actionType:DUXBetaAlertActionTypeClosure
                                                       target:nil
                                                     selector:nil
                                             completionAction:^(){
                            [DUXBetaStateChangeBroadcaster send:[SDCardStatusItemUIState dialogActionConfirmed:dialogIndentifier]];
        }];

        alert.appearance = self.sdCardFormattingSuccessAlertAppearance;
    } else {
        alert = [DUXBetaAlertView failAlertWithTitle:NSLocalizedString(@"SD Card Format", @"SD Card Format")
                                         message:[NSString stringWithFormat:NSLocalizedString(@"Error formatting SD card. %@", "Camera Formatting Workflow Failure Description"), self.widgetModel.formatErrorDescription]];
                
        defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                        style:UIAlertActionStyleCancel
                                                   actionType:DUXBetaAlertActionTypeClosure
                                                       target:nil
                                                     selector:nil
                                             completionAction:^(){
                                                 [DUXBetaStateChangeBroadcaster send:[SDCardStatusItemUIState dialogActionConfirmed:dialogIndentifier]];
                                             }];

        alert.appearance = self.sdCardFormattingErrorAlertAppearance;
    }

    alert.dissmissCompletion = ^{
        [DUXBetaStateChangeBroadcaster send:[SDCardStatusItemUIState dialogDismissed:dialogIndentifier]];
    };
    [alert add:defaultAction];
    [alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[SDCardStatusItemUIState dialogDisplayed:dialogIndentifier]];
    }];
    
    self.widgetModel.sdCardFormatError = NO;
}

@end
    
@implementation SDCardStatusItemModelState

+ (instancetype)sdCardStatusCapacityChanged:(NSInteger)freeStorageChanged {
    return [[SDCardStatusItemModelState alloc] initWithKey:@"sdCardStatusCapacityChanged" number:@(freeStorageChanged)];
}

+ (instancetype)sdCardStateUpdated:(NSNumber *)operationState {
    return [[SDCardStatusItemModelState alloc] initWithKey:@"sdCardStateUpdated" value:operationState];
}

@end

@implementation SDCardStatusItemUIState

@end
