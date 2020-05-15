//
//  DUXRCStickModeListItemWidget.m
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

#import "DUXRCStickModeListItemWidget.h"
#import "DUXRCStickModeListItemWidgetModel.h"
#import "NSObject+DUXBetaRKVOExtension.h"
@import DJIUXSDKCore;

/**
 * Enumerated values used for mapping radio contol UI indexes into human readable versions for mapping to RC stick mode versions
 */
typedef NS_ENUM(NSInteger, DUXBetaSupportedRCStickControlModes) {
    DUXBetaRCStickMode1 = 0,
    DUXBetaRCStickMode2 = 1,
    DUXBetaRCStickMode3 = 2
};

@interface DUXRCStickModeListItemWidget ()
@property (nonatomic, strong) DUXRCStickModeListItemWidgetModel  *widgetModel;

@end

@implementation DUXRCStickModeListItemWidget

- (void)viewDidLoad {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setOptionTitles:@[NSLocalizedString(@"Mode 1", @" RC Stick Mode 1"),
                            NSLocalizedString(@"Mode 2", @" RC Stick Mode 2"),
                            NSLocalizedString(@"Mode 3", @" RC Stick Mode 3")]];
    [super setTitle:@"Control Stick Mode" andIconName: @"SystemStatusRC"];
    
    self.widgetModel = [DUXRCStickModeListItemWidgetModel new];
    [_widgetModel setup];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(productConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(rcStickModeChanged), remoteControllerMappingStyle);
    
    __weak DUXRCStickModeListItemWidget *weakSelf = self;
    [self setOptionSelectedAction:^(NSInteger oldSelectedIndex, NSInteger newSelectedIndex) {
        __strong DUXRCStickModeListItemWidget *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        DJIRCAircraftMappingStyle   newMode = DJIRCAircraftMappingStyle2;
        switch (newSelectedIndex) {
            case DUXBetaRCStickMode1:
                newMode = DJIRCAircraftMappingStyle1;
                break;
                
            case DUXBetaRCStickMode2:
                newMode = DJIRCAircraftMappingStyle2;
                break;
            
            case DUXBetaRCStickMode3:
                newMode = DJIRCAircraftMappingStyle3;
                break;
                
            default:
                // No other mode supported, shouldn't be allowd. Bail out
                return;
        }
        [DUXStateChangeBroadcaster send:[RCModeListItemUIState rcModeControlChange:newSelectedIndex]];
        [strongSelf.widgetModel setStickMode:newMode onCompletion:^(NSError *error) {
            
        }];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)dealloc {
    [_widgetModel cleanup];
}

- (void)productConnected {
    [self setEnabled:self.widgetModel.isProductConnected];
    [RCModeListItemModelState productConnected:self.widgetModel.isProductConnected];
}

- (void)rcStickModeChanged {
    NSInteger possibleNewStyle = DUXBetaRCStickMode2;
    
    switch (self.widgetModel.remoteControllerMappingStyle) {
        case DJIRCAircraftMappingStyle1:
            possibleNewStyle = DUXBetaRCStickMode1;
            break;
            
        case DJIRCAircraftMappingStyle2:
            possibleNewStyle = DUXBetaRCStickMode2;
            break;
            
        case DJIRCAircraftMappingStyle3:
            possibleNewStyle = DUXBetaRCStickMode3;
            break;
            
        case DJIRCAircraftMappingStyleCustom:
        case DJIRCAircraftMappingStyleUnknown:
        default:
            //  One of the cases we can't handle. Set the selection to none
            possibleNewStyle = DUXBetaRCStickMode2;
            break;
            
    }
    if (self.selection != possibleNewStyle) {
        self.selection = possibleNewStyle;
    }
}

@end

@implementation RCModeListItemUIState

+ (instancetype)rcModeControlChange:(NSInteger)newValue {
    return [[self alloc] initWithKey:@"rcModeControlChange" number:@(newValue)];
}

@end
