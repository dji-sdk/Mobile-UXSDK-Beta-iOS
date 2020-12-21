
//
//  DUXBetaEMMCStatusListItemWidget.m
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

#import "DUXBetaEMMCStatusListItemWidget.h"
#import "DUXBetaEMMCStatusListItemWidgetModel.h"

#import <UXSDKCore/UXSDKCore-Swift.h>


/**
 * DUXBetaInternalEMMCFormattingStage is internal to DUXBetaEMMCStatusListItemWidget.
 * It is used to track the current state of formatting an EMMC to allow notification when
 * an error occurs or successful completion is accomplished.
 */
NS_ENUM(NSInteger, DUXBetaInternalEMMCFormattingStage) {
    DUXBetaInternalEMMCFormattingNO = 0,
    DUXBetaInternalEMMCFormattingYES,
    DUXBetaInternalEMMCFormattingERROR
};

@interface DUXBetaEMMCStatusListItemWidget ()
@property (nonatomic, strong) DUXBetaEMMCStatusListItemWidgetModel *widgetModel;
@property (nonatomic, assign) enum DUXBetaInternalEMMCFormattingStage         isFormatting;
@property (nonatomic, assign) enum DUXBetaInternalEMMCFormattingStage         stillFormatting;
@end

@implementation DUXBetaEMMCStatusListItemWidget

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
    
    _widgetModel = [DUXBetaEMMCStatusListItemWidgetModel new];
    [_widgetModel setup];
    
    // Load standard appearances for the 3 alerts we may show so they can be customized before use.
    [self loadCustomAlertsAppearance];
    
    // Do any additional setup after loading the view.
    [super setButtonTitle:NSLocalizedString(@"Format", @"Format")];
    [super setTitle:NSLocalizedString(@"eMMC Remaining Capacity", @"DUXBetaEMMCStatusListItemWidget title") andIconName:@"eMMCSystemStatus"];
    
    __weak DUXBetaEMMCStatusListItemWidget *weakSelf = self;
    [self setButtonAction:^(DUXBetaEMMCStatusListItemWidget* senderWidget) {
        __strong DUXBetaEMMCStatusListItemWidget *strongSelf = weakSelf;
        [strongSelf displayFormatEMMCDialog];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(productConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(storageUpdated), freeStorageInMB);
    BindRKVOModel(self.widgetModel, @selector(internalStorageOperationStateUpdated), internalStorageOperationState, isInternalStorageSupported);
    BindRKVOModel(self.widgetModel, @selector(eMMCFormatErrorUpdated), sdCardFormatError);
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
    self.emmcConfirmFormatAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.emmcConfirmFormatAlertAppearance.imageTintColor = [UIColor uxsdk_warningColor];
    
    self.emmcFormattingSuccessAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.emmcFormattingSuccessAlertAppearance.imageTintColor = [UIColor uxsdk_successColor];
    
    self.emmcFormattingErrorAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.emmcFormattingErrorAlertAppearance.imageTintColor = [UIColor uxsdk_errorDangerColor];
}

- (void)productConnected {
    [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemModelState productConnected:self.widgetModel.isProductConnected]];
    [self updatePresentationDisplay];
}

- (void)storageUpdated {
    [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemModelState emmcStatusCapacityChanged:self.widgetModel.freeStorageInMB]];
    [self updatePresentationDisplay];
}

- (void)internalStorageOperationStateUpdated {
    [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemModelState emmcStateUpdated:@(self.widgetModel.internalStorageOperationState)]];
    [self updatePresentationDisplay];
}

- (void)eMMCFormatErrorUpdated {
    if (self.widgetModel.sdCardFormatError) {
        _isFormatting = DUXBetaInternalEMMCFormattingERROR;
    }
    [self updatePresentationDisplay];
    
    if (self.widgetModel.sdCardFormatError && self.widgetModel.internalStorageOperationState == DJICameraSDCardOperationStateInvalidFileSystem) {
        [self displayFormatCompletedDialog:NO];
    }
}

- (NSString*)displayStringForInternalStorageFreeSpace {
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
    BOOL notSupported = NO;
    
    if (!_widgetModel.isProductConnected) {
        displayString = NSLocalizedString(@"N/A", @"N/A");
        enableFormat = NO;
        isDisabled = YES;
        if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
            _stillFormatting = DUXBetaInternalEMMCFormattingERROR;
        }
    } else if (_widgetModel.isInternalStorageSupported == NO) {
        displayString = NSLocalizedString(@"Not Supported", @"Not Supported");
        isNormal = NO;
        enableFormat = NO;
        notSupported = YES;
    } else if (_widgetModel.isInternalStorageInserted && (_widgetModel.internalStorageOperationState == DJICameraSDCardOperationStateNormal)) {
        isNormal = YES;
        displayString = [self displayStringForInternalStorageFreeSpace];
        if (_stillFormatting && (_widgetModel.internalStorageOperationState == DJICameraSDCardOperationStateNormal)) {
            formattingJustEnded = YES;
        }
    } else {
        if ((_widgetModel.isInternalStorageInserted == NO) || (_widgetModel.internalStorageOperationState == DJICameraSDCardOperationStateNotInserted)) {
            displayString = NSLocalizedString(@"Not Inserted", @"Not Inserted");
            enableFormat = NO;
        } else {
            switch (_widgetModel.internalStorageOperationState) {
                case DJICameraSDCardOperationStateNormal:
                    // This state can only be reached if isSDCardInserted == NO, but state is normal
                    isNormal = YES;
                    displayString = [self displayStringForInternalStorageFreeSpace];
                    break;
                case DJICameraSDCardOperationStateNotInserted:
                    // This can only be reached if isSDCardInserted is YES, but the internalStorageOperationState is not inserted. Should not be possible
                    displayString = NSLocalizedString(@"Not Inserted", @"Not Inserted");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
                        _stillFormatting = DUXBetaInternalEMMCFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateInvalid:
                    displayString = NSLocalizedString(@"Invalid", @"Invalid");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
                        _stillFormatting = DUXBetaInternalEMMCFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateReadOnly:
                    displayString = NSLocalizedString(@"Write Protected", @"Write Protected");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
                        _stillFormatting = DUXBetaInternalEMMCFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationFormatNeeded:
                    displayString = NSLocalizedString(@"Format Required", @"Format Required");
                    if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
                        _stillFormatting = DUXBetaInternalEMMCFormattingERROR;
                    }
                    break;
                case DJICameraSDCardOperationStateFormatting:
                    displayString = NSLocalizedString(@"Formatting…", @"Formatting…");
                    enableFormat = NO;
                    _stillFormatting = YES;
                    break;
                case DJICameraSDCardOperationStateInvalidFileSystem:
                    displayString = NSLocalizedString(@"Format Required", @"Format Required");
                    if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
                        _stillFormatting = DUXBetaInternalEMMCFormattingERROR;
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
                    displayString = [NSString stringWithFormat:@"%@, (%@)", NSLocalizedString(@"Slow", @"Slow"), [self displayStringForInternalStorageFreeSpace]];
                    break;
                case DJICameraSDCardOperationStateUnknownError:
                    displayString = NSLocalizedString(@"Unknown Error", @"Unknown Error");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
                        _stillFormatting = DUXBetaInternalEMMCFormattingERROR;
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
                    if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
                        _stillFormatting = DUXBetaInternalEMMCFormattingERROR;
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
    if (notSupported) {
        textColor = [UIColor uxsdk_errorDangerColor];
    } else if (isNormal) {
        textColor = [UIColor uxsdk_whiteColor];
    } else if (isDisabled) {
        textColor = [UIColor uxsdk_disabledGrayWhite58];
    }
    [self.displayTextLabel setTextColor:textColor];
    
    if ((_isFormatting == DUXBetaInternalEMMCFormattingYES) && ((_stillFormatting != DUXBetaInternalEMMCFormattingYES) || formattingJustEnded)) {
        // Set the isFormatting flag. The KVO will then decide if the error dialog needs to be shown.
        self.isFormatting = DUXBetaInternalEMMCFormattingNO;
    }
}

- (void)formattingStatusChanged {
    if (_isFormatting == DUXBetaInternalEMMCFormattingNO) {
        // Formatting has ended if _stillFormatting is not NO because we only set it to DUXBetaInternalEMMCFormattingNO in here when processing is done.
        if (_stillFormatting != DUXBetaInternalEMMCFormattingNO) {
            BOOL success = (_stillFormatting == DUXBetaInternalEMMCFormattingYES) && (self.widgetModel.sdCardFormatError == NO);
            _isFormatting = DUXBetaInternalEMMCFormattingNO;
            [self displayFormatCompletedDialog:success];
            _stillFormatting = DUXBetaInternalEMMCFormattingNO;
        }
    } else if (_isFormatting == DUXBetaInternalEMMCFormattingYES) {
        // Just started formatting, only set the flag to know if we think it is still happening.
        _stillFormatting = DUXBetaInternalEMMCFormattingYES;
    } else {
        // Either done normally or errored
        BOOL success = !((_stillFormatting == DUXBetaInternalEMMCFormattingERROR) || (self.widgetModel.sdCardFormatError == YES));
        [self displayFormatCompletedDialog:success];
    }
}

- (void)displayFormatEMMCDialog {
    NSString *dialogIdentifier = @"FormatConfirmation";
    __weak DUXBetaEMMCStatusListItemWidget *weakSelf = self;
    
    DUXBetaAlertView *alert = [DUXBetaAlertView warningAlertWithTitle:NSLocalizedString(@"eMMC Card Format", @"eMMC Card Format")
                                                      message:NSLocalizedString(@"Are you sure you want to format the internal storage (eMMC)?", "eMMC Formatting Workflow Action Description")];
    DUXBetaAlertAction *defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                    style:UIAlertActionStyleDefault
                                                               actionType:DUXBetaAlertActionTypeClosure
                                                                   target:nil
                                                                 selector:nil
                                                         completionAction:^{
        __strong DUXBetaEMMCStatusListItemWidget *strongSelf = weakSelf;
        
        [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemUIState dialogActionConfirmed:dialogIdentifier]];
        
        strongSelf.isFormatting = YES;
        [self.widgetModel formatSDCard];
    }];
    
    DUXBetaAlertAction *cancelAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                   style:UIAlertActionStyleCancel
                                                              actionType:DUXBetaAlertActionTypeClosure
                                                                  target:nil
                                                                selector:nil
                                                        completionAction:^{
        [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemUIState dialogActionCanceled:dialogIdentifier]];
        __strong DUXBetaEMMCStatusListItemWidget *strongSelf = weakSelf;
        strongSelf.isFormatting = NO;
    }];
    [alert setDissmissCompletion:^{
        [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemUIState dialogDismissed:dialogIdentifier]];
    }];
    [alert add:cancelAction];
    [alert add:defaultAction];
    alert.appearance = self.emmcConfirmFormatAlertAppearance;
    [alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemUIState dialogDisplayed:dialogIdentifier]];
    }];
}

- (void)displayFormatCompletedDialog:(BOOL)success {
    DUXBetaAlertView *alert;
    DUXBetaAlertAction *defaultAction;
    NSString *dialogIndentifier = success ? @"FromatSuccess": @"FormatError";
    
    if (success) {
        alert = [DUXBetaAlertView successAlertWithTitle:NSLocalizedString(@"eMMC Card Format", @"eMMC Card Format")
                                            message:NSLocalizedString(@"Internal storage (eMMC) formatting completed.", "eMMC Formatting Workflow Success Description")];
        defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                        style:UIAlertActionStyleCancel
                                                   actionType:DUXBetaAlertActionTypeClosure
                                                       target:nil
                                                     selector:nil
                                             completionAction:^(){
            [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemUIState dialogActionConfirmed:dialogIndentifier]];
        }];
        
        alert.appearance = self.emmcFormattingSuccessAlertAppearance;
    } else {
        alert = [DUXBetaAlertView failAlertWithTitle:NSLocalizedString(@"eMMC Card Format", @"eMMC Card Format")
                                         message:[NSString stringWithFormat:NSLocalizedString(@"Error formatting internal storage (eMMC). %@", "eMMC Formatting Workflow Failure Description"), self.widgetModel.formatErrorDescription]];
        
        defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                        style:UIAlertActionStyleCancel
                                                   actionType:DUXBetaAlertActionTypeClosure
                                                       target:nil
                                                     selector:nil
                                             completionAction:^(){
            [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemUIState dialogActionConfirmed:dialogIndentifier]];
        }];
        
        alert.appearance = self.emmcFormattingErrorAlertAppearance;
    }
    
    alert.dissmissCompletion = ^{
        [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemUIState dialogDismissed:dialogIndentifier]];
    };
    [alert add:defaultAction];
    [alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[EMMCStatusItemUIState dialogDisplayed:dialogIndentifier]];
    }];
    
    self.widgetModel.sdCardFormatError = NO;
}

@end

@implementation EMMCStatusItemModelState

+ (instancetype)emmcStatusCapacityChanged:(NSInteger)freeStorageChanged {
    return [[EMMCStatusItemModelState alloc] initWithKey:@"emmcStatusCapacityChanged" number:@(freeStorageChanged)];
}

+ (instancetype)emmcStateUpdated:(NSNumber *)operationState {
    return [[EMMCStatusItemModelState alloc] initWithKey:@"emmcStateUpdated" value:operationState];
}

@end

@implementation EMMCStatusItemUIState

@end
