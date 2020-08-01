//
//  DUXBetaListItemTrivialSwitchWidget.m
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

#import "DUXBetaListItemTrivialSwitchWidget.h"
#import "DUXBetaListItemSwitchWidgetModel.h"

@import DJIUXSDKCore;

@interface DUXBetaListItemTrivialSwitchWidget ()
@property (nonatomic, strong) DUXBetaListItemSwitchWidgetModel *widgetModel;
@property (nonatomic, strong) DJIKey *widgetModelKey;

@end

@implementation DUXBetaListItemTrivialSwitchWidget

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_widgetModelKey) {
        self.widgetModel = [[DUXBetaListItemSwitchWidgetModel alloc] initWithKey:self.widgetModelKey];
        [self.widgetModel setup];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BindRKVOModel(self, @selector(valueForSwitchChanged), self.widgetModel.genericBool);
    BindRKVOModel(self, @selector(updateEnabledStates), self.widgetModel.isProductConnected);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

- (void)dealloc {
     [self.widgetModel cleanup];
}

// return instancetype to allow chaining on instantiation
- (instancetype)setTitle:(NSString*)titleString andKey:(DJIKey*)theKey {
    // This tears down the old model if it exists and builds a fresh one
    _widgetModelKey = theKey;
    self.widgetModel = [[DUXBetaListItemSwitchWidgetModel alloc] initWithKey:self.widgetModelKey];
    
    __weak DUXBetaListItemTrivialSwitchWidget *weakSelf = self;
    [self setSwitchAction:^(BOOL newSwitchValue) {
        __strong DUXBetaListItemTrivialSwitchWidget *strongSelf = weakSelf;
        [strongSelf.widgetModel toggleSettingWithCompletionBlock:^(NSError *error) {
            
        }];
    }];
    [self setTitle:titleString andIconName:nil];
    return self;
}

- (void)valueForSwitchChanged {
    [DUXBetaStateChangeBroadcaster send:[ListItemTrivalModelUIState switchModelValueChanged:self.widgetModel.genericBool]];
    [self.onOffSwitch setOn:self.widgetModel.genericBool];
}

- (void)updateEnabledStates {
    self.onOffSwitch.enabled = self.widgetModel.isProductConnected;
}


@end

@implementation ListItemTrivalModelUIState

+ (instancetype)switchModelValueChanged:(BOOL)isOn {
    return [[self alloc] initWithKey:@"switchModelValueChanged" number:@(isOn)];
}

@end
