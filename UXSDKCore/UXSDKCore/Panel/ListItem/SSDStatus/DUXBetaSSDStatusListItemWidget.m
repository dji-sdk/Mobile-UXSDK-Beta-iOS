//
//  DUXBetaSSDStatusListItemWidget.m
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

#import "DUXBetaSSDStatusListItemWidget.h"
#import "DUXBetaSSDStatusListItemWidgetModel.h"

#import <UXSDKCore/UXSDKCore-Swift.h>


/**
 * DUXBetaInternalSSDFormattingStage is internal to DUXBetaSSDStatusListItemWidget.
 * It is used to track the current state of formatting an SSD to allow notification when
 * an error occurs or successful completion is accomplished.
 */
NS_ENUM(NSInteger, DUXBetaInternalSSDFormattingStage) {
    DUXBetaInternalSSDFormattingNO = 0,
    DUXBetaInternalSSDFormattingYES,
    DUXBetaInternalSSDFormattingERROR
};

@interface DUXBetaSSDStatusListItemWidget ()
@property (nonatomic, strong) DUXBetaSSDStatusListItemWidgetModel *widgetModel;
@property (nonatomic, assign) enum DUXBetaInternalSSDFormattingStage         isFormatting;
@property (nonatomic, assign) enum DUXBetaInternalSSDFormattingStage         stillFormatting;
@end

@implementation DUXBetaSSDStatusListItemWidget

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
    
    _widgetModel = [DUXBetaSSDStatusListItemWidgetModel new];
    [_widgetModel setup];
    
    // Load standard appearances for the 3 alerts we may show so they can be customized before use.
    [self loadCustomAlertsAppearance];
    
    // Do any additional setup after loading the view.
    [super setButtonTitle:NSLocalizedString(@"Format", @"Format")];
    [super setTitle:NSLocalizedString(@"SSD Remaining Capacity", @"DUXBetaSSDStatusListItemWidget title") andIconName:@"SystemStatusStorageSSD"];
    
    __weak DUXBetaSSDStatusListItemWidget *weakSelf = self;
    [self setButtonAction:^(DUXBetaSSDStatusListItemWidget* senderWidget) {
        __strong DUXBetaSSDStatusListItemWidget *strongSelf = weakSelf;
        [strongSelf displayFormatSSDDialog];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(productConnected), isProductConnected);
    
    BindRKVOModel(self.widgetModel, @selector(ssdConnectedChanged), isSSDConnected);
    BindRKVOModel(self.widgetModel, @selector(storageUpdated), freeStorageInMB);
    BindRKVOModel(self.widgetModel, @selector(ssdOperationStateUpdated), ssdOperationState);
    BindRKVOModel(self.widgetModel, @selector(ssdFormatErrorUpdated), ssdFormatError);
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
    self.ssdConfirmFormatAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.ssdConfirmFormatAlertAppearance.imageTintColor = [UIColor uxsdk_warningColor];
    
    self.ssdFormattingSuccessAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.ssdFormattingSuccessAlertAppearance.imageTintColor = [UIColor uxsdk_successColor];
    
    self.ssdFormattingErrorAlertAppearance = [DUXBetaAlertView systemAlertAppearance];
    self.ssdFormattingErrorAlertAppearance.imageTintColor = [UIColor uxsdk_errorDangerColor];
}


- (void)productConnected {
    [SSDStatusItemModelState productConnected:self.widgetModel.isProductConnected];
    [self updatePresentationDisplay];
}

- (void)ssdConnectedChanged {
    [self updatePresentationDisplay];
}

- (void)storageUpdated {
    [SSDStatusItemModelState ssdStatusCapacityChanged:self.widgetModel.freeStorageInMB];
    [self updatePresentationDisplay];
}

- (void)ssdFormatErrorUpdated {
    if (self.widgetModel.ssdFormatError) {
        _isFormatting = DUXBetaInternalSSDFormattingERROR;
    }
    [self updatePresentationDisplay];
    
    if (self.widgetModel.ssdFormatError && self.widgetModel.ssdOperationState == DJICameraSSDOperationStateInvalidFileSystem) {
        [self displayFormatCompletedDialog:NO];
    }
}


- (void)ssdOperationStateUpdated {
    [SSDStatusItemModelState ssdStateUpdated:@(self.widgetModel.ssdOperationState)];
    [self updatePresentationDisplay];
}

- (NSString*)displayStringForSSDFreeSpace {
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
    BOOL isError = NO;
    BOOL formattingJustEnded = NO;

    if (!_widgetModel.isProductConnected) {
        displayString = NSLocalizedString(@"N/A", @"N/A");
        enableFormat = NO;
        isDisabled = YES;
        if (_isFormatting == DUXBetaInternalSSDFormattingYES) {
            _stillFormatting = DUXBetaInternalSSDFormattingERROR;
        }
    } else if (_widgetModel.isSSDConnected && (_widgetModel.ssdOperationState == DJICameraSSDOperationStateIdle)) {
        isNormal = YES;
        displayString = [self displayStringForSSDFreeSpace];
        if (_stillFormatting && (_widgetModel.ssdOperationState == DJICameraSSDOperationStateIdle)) {
            formattingJustEnded = YES;
        }
    } else {
        if ((_widgetModel.isSSDConnected == NO) || (_widgetModel.ssdOperationState == DJICameraSSDOperationStateNotFound)) {
            displayString = NSLocalizedString(@"Not Inserted", @"Not Inserted");
            enableFormat = NO;
        } else {
            switch (_widgetModel.ssdOperationState) {
                case DJICameraSSDOperationStateNotFound:
                    // This can only be reached if isSSDConnected is YES, but the ssdOperationState is not found. Should not be possible
                    displayString = NSLocalizedString(@"Not Inserted", @"Not Inserted");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalSSDFormattingYES) {
                        _stillFormatting = DUXBetaInternalSSDFormattingERROR;
                    }
                    break;
                case DJICameraSSDOperationStateIdle:
                    // This state can only be reached if isSSDConnected == NO, but state is normal
                    isNormal = YES;
                    displayString = [self displayStringForSSDFreeSpace];
                    _stillFormatting = DUXBetaInternalSSDFormattingNO;
                    break;
                case DJICameraSSDOperationStateSaving:
                    displayString = NSLocalizedString(@"Saving", @"Saving");
                    enableFormat = NO;
                    break;
                case DJICameraSSDOperationStateFormatting:
                    displayString = NSLocalizedString(@"Formatting…", @"Formatting…");
                    enableFormat = NO;
                    _stillFormatting = YES;
                    break;
                case DJICameraSSDOperationStateInitializing:
                    displayString = NSLocalizedString(@"Initializing", @"Initializing");
                    enableFormat = NO;
                    break;
                case DJICameraSSDOperationStateError:
                    displayString = NSLocalizedString(@"Error", @"Error");
                    enableFormat = NO;
                    isError = YES;
                    if (_isFormatting == DUXBetaInternalSSDFormattingYES) {
                        _stillFormatting = DUXBetaInternalSSDFormattingERROR;
                    }
                    break;
                case DJICameraSSDOperationStateFull:
                    displayString = NSLocalizedString(@"Full", @"Full");
                    break;
                case DJICameraSSDOperationStatePoorConnection:
                    displayString = NSLocalizedString(@"Poor Connection", @"Poor Connection");
                    enableFormat = NO;
                    break;
                case DJICameraSSDOperationStateSwitchingLicense:
                    displayString = NSLocalizedString(@"Switching License", @"Switching License");
                    enableFormat = NO;
                    break;
                case DJICameraSSDOperationStateFormattingRequired:
                    displayString = NSLocalizedString(@"Formatting Required", @"Formatting Required");
                    if (_isFormatting == DUXBetaInternalSSDFormattingYES) {
                        _stillFormatting = DUXBetaInternalSSDFormattingERROR;
                    }
                    break;
                case DJICameraSSDOperationStateNotInitialized:
                    displayString = NSLocalizedString(@"Not Initialized", @"Not Initialized");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalSSDFormattingYES) {
                        _stillFormatting = DUXBetaInternalSSDFormattingERROR;
                    }
                    break;
                case DJICameraSSDOperationStateInvalidFileSystem:
                    displayString = NSLocalizedString(@"Format Required", @"Format Required");
                    if (_isFormatting == DUXBetaInternalSSDFormattingYES) {
                        _stillFormatting = DUXBetaInternalSSDFormattingERROR;
                    }
                    break;
                case DJICameraSSDOperationStateUnknown:
                default:
                    displayString = NSLocalizedString(@"Unknown Error", @"Unknown Error");
                    enableFormat = NO;
                    if (_isFormatting == DUXBetaInternalSSDFormattingYES) {
                        _stillFormatting = DUXBetaInternalSSDFormattingERROR;
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
    if (isError) {
        textColor = [UIColor uxsdk_errorDangerColor];
    } else if (isNormal) {
        textColor = [UIColor uxsdk_whiteColor];
    } else if (isDisabled) {
        textColor = [UIColor uxsdk_disabledGrayWhite58];
    }
    [self.displayTextLabel setTextColor:textColor];
    
    if ((_isFormatting == DUXBetaInternalSSDFormattingYES) && ((_stillFormatting != DUXBetaInternalSSDFormattingYES) || formattingJustEnded)) {
        // Set the isFormatting flag. The KVO will then decide if the error dialog needs to be shown.
        self.isFormatting = DUXBetaInternalSSDFormattingNO;
    }
}


- (void)formattingStatusChanged {
    if (_isFormatting == DUXBetaInternalSSDFormattingNO) {
        // Formatting has ended if _stillFormatting is not NO because we only set it to DUXBetaInternalSSDFormattingNO in here when processing is done.
        if (_stillFormatting != DUXBetaInternalSSDFormattingNO) {
            BOOL success = (_stillFormatting == DUXBetaInternalSSDFormattingYES) && (self.widgetModel.ssdFormatError == NO);
            _isFormatting = DUXBetaInternalSSDFormattingNO;
            [self displayFormatCompletedDialog:success];
            _stillFormatting = DUXBetaInternalSSDFormattingNO;
        }
    } else if (_isFormatting == DUXBetaInternalSSDFormattingYES) {
        // Just started formatting, only set the flag to know if we think it is still happening.
        _stillFormatting = DUXBetaInternalSSDFormattingYES;
    } else {
        // Either done normally or errored
        BOOL success = !((_stillFormatting == DUXBetaInternalSSDFormattingERROR) || (self.widgetModel.ssdFormatError == YES));
        [self displayFormatCompletedDialog:success];
    }
}

- (void)displayFormatSSDDialog {
    NSString *dialogIdentifier = @"FormatConfirmation";
    __weak DUXBetaSSDStatusListItemWidget *weakSelf = self;
    
    DUXBetaAlertView *alert = [DUXBetaAlertView warningAlertWithTitle:NSLocalizedString(@"SSD Storage Format", @"SSD Storage Format")
                                                      message:NSLocalizedString(@"Are you sure you want to format the SSD storage?", "SSD Formatting Workflow Action Description")];
    DUXBetaAlertAction *defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                                    style:UIAlertActionStyleDefault
                                                               actionType:DUXBetaAlertActionTypeClosure
                                                                   target:nil
                                                                 selector:nil
                                                         completionAction:^{
        __strong DUXBetaSSDStatusListItemWidget *strongSelf = weakSelf;
        
        [DUXBetaStateChangeBroadcaster send:[SSDStatusItemUIState dialogActionConfirmed:dialogIdentifier]];
        
        strongSelf.isFormatting = YES;
        [self.widgetModel formatSSD];
    }];
    
    DUXBetaAlertAction *cancelAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                   style:UIAlertActionStyleCancel
                                                              actionType:DUXBetaAlertActionTypeClosure
                                                                  target:nil
                                                                selector:nil
                                                        completionAction:^{
        [DUXBetaStateChangeBroadcaster send:[SSDStatusItemUIState dialogActionCanceled:dialogIdentifier]];
        __strong DUXBetaSSDStatusListItemWidget *strongSelf = weakSelf;
        strongSelf.isFormatting = NO;
    }];
    [alert setDissmissCompletion:^{
        [DUXBetaStateChangeBroadcaster send:[SSDStatusItemUIState dialogDismissed:dialogIdentifier]];
    }];
    [alert add:cancelAction];
    [alert add:defaultAction];
    alert.appearance = self.ssdConfirmFormatAlertAppearance;
    [alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[SSDStatusItemUIState dialogDisplayed:dialogIdentifier]];
    }];
}

- (void)displayFormatCompletedDialog:(BOOL)success {
    DUXBetaAlertView *alert;
    DUXBetaAlertAction *defaultAction;
    NSString *dialogIndentifier = success ? @"FormatSuccess": @"FormatError";
    
    if (success) {
        alert = [DUXBetaAlertView successAlertWithTitle:NSLocalizedString(@"SSD Storage Format", @"SSD Storage Format")
                                            message:NSLocalizedString(@"SSD formatting completed.", "Camera Formatting Workflow Success Description")];
        defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                        style:UIAlertActionStyleCancel
                                                   actionType:DUXBetaAlertActionTypeClosure
                                                       target:nil
                                                     selector:nil
                                             completionAction:^(){
            [DUXBetaStateChangeBroadcaster send:[SSDStatusItemUIState dialogActionConfirmed:dialogIndentifier]];
        }];
        
        alert.appearance = self.ssdFormattingSuccessAlertAppearance;
    } else {
        alert = [DUXBetaAlertView failAlertWithTitle:NSLocalizedString(@"SSD Storage Format", @"SSD Storage Format")
                                         message:[NSString stringWithFormat:NSLocalizedString(@"Error formatting SSD storage. %@", "Camera Formatting Workflow Failure Description"), self.widgetModel.formatErrorDescription]];
        
        defaultAction = [DUXBetaAlertAction actionWithActionTitle:NSLocalizedString(@"OK", @"OK")
                                                        style:UIAlertActionStyleCancel
                                                   actionType:DUXBetaAlertActionTypeClosure
                                                       target:nil
                                                     selector:nil
                                             completionAction:^(){
            [DUXBetaStateChangeBroadcaster send:[SSDStatusItemUIState dialogActionConfirmed:dialogIndentifier]];
        }];
    }
    
    alert.dissmissCompletion = ^{
        [DUXBetaStateChangeBroadcaster send:[SSDStatusItemUIState dialogDismissed:dialogIndentifier]];
    };
    [alert add:defaultAction];
    alert.appearance = success ? self.ssdFormattingSuccessAlertAppearance : self.ssdFormattingErrorAlertAppearance;;
    [alert showWithCompletion: ^{
        [DUXBetaStateChangeBroadcaster send:[SSDStatusItemUIState dialogDisplayed:dialogIndentifier]];
    }];
    
    self.widgetModel.ssdFormatError = NO;
}

@end

@implementation SSDStatusItemModelState

+ (instancetype)ssdStatusCapacityChanged:(NSInteger)freeStorageChanged {
    return [[SSDStatusItemModelState alloc] initWithKey:@"ssdStatusCapacityChanged" number:@(freeStorageChanged)];
}

+ (instancetype)ssdStateUpdated:(NSNumber *)operationState {
    return [[SSDStatusItemModelState alloc] initWithKey:@"ssdStateUpdated" value:operationState];
}

@end

@implementation SSDStatusItemUIState

@end
