//
//  DUXFlightModeListItemWidget.m
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

#import "DUXFlightModeListItemWidget.h"
#import "DUXFlightModeListItemWidgetModel.h"
#import "NSObject+DUXBetaRKVOExtension.h"
@import DJIUXSDKCore;

@interface DUXFlightModeListItemWidget ()
@property (nonatomic, strong) DUXFlightModeListItemWidgetModel *widgetModel;

@end

@implementation DUXFlightModeListItemWidget

- (instancetype)init {
    if (self = [super init:DUXListItemLabelOnly]) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)coder {
    if (self = [super init:DUXListItemLabelOnly]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    self.widgetModel = [[DUXFlightModeListItemWidgetModel alloc] init];
    [self.widgetModel setup];

    [self setTitle:NSLocalizedString(@"Flight Mode", @"System Status Checklist Item Title") andIconName:@"SystemStatusFlightMode"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(flightModeUpdate), flightModeString, isProductConnected);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)dealloc {
    [_widgetModel cleanup];
}

- (void)flightModeUpdate {
    NSString *newString = @"N/A";
    if ((self.widgetModel.isProductConnected) && (self.widgetModel.flightModeString != nil)) {
        newString = self.widgetModel.flightModeString;
    } else {
        // Get the possibly localized version instead of our default placeholder
        newString = NSLocalizedString(@"N/A", @"N/A");
    }
    [self setLabelText:newString];
    [DUXStateChangeBroadcaster send:[FlightModeListItemModelState flightModeUpdated:newString]];
}

@end

@implementation FlightModeListItemUIState

@end
