//
//  DUXBetaListItemSwitchWidget.m
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

#import "DUXBetaListItemSwitchWidget.h"
@import DJIUXSDKCore;

@interface DUXBetaListItemSwitchWidget ()
@property (nonatomic, strong) SwitchChangedActionBlock    actionBlock;
@property (nonatomic, assign) BOOL uiAlreadySetup;
@end

@implementation DUXBetaListItemSwitchWidget

- (void)setupCustomizableSettings {
    [super setupCustomizableSettings];
    _switchTintColor = UIColor.systemGreenColor;
}

/*********************************************************************************/
#pragma mark - View Lifecycle Methods
/*********************************************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BindRKVOModel(self, @selector(switchEnabledStateChanged), onOffSwitch.enabled);
    BindRKVOModel(self, @selector(updateSwitchTint), switchTintColor);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

- (void)setSwitchAction:(SwitchChangedActionBlock)newBlock {
    self.actionBlock = newBlock;
}

- (void)switchEnabledStateChanged {
    [DUXBetaStateChangeBroadcaster send:[ListItemSwitchUIState switchEnabled:self.onOffSwitch.enabled]];
    [self updateUI];
}

// This setupUI does not set a hard width. That should probably be imposed externally.
- (void)setupUI {
    if (_uiAlreadySetup) { return; }
    _uiAlreadySetup = YES;
    [super setupUI];
    
    self.onOffSwitch = [[UISwitch alloc] init];
    self.onOffSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.onOffSwitch];
    
    if (@available(iOS 13, *)) {
        UIView *switchBackingView = [[UIView alloc] initWithFrame:_onOffSwitch.frame];
        [_onOffSwitch.superview insertSubview:switchBackingView belowSubview:_onOffSwitch];
        switchBackingView.userInteractionEnabled = NO;
        switchBackingView.translatesAutoresizingMaskIntoConstraints = NO;

        switchBackingView.layer.cornerRadius = switchBackingView.bounds.size.height / 2;
        switchBackingView.layer.borderColor = [[UIColor whiteColor] CGColor];
        switchBackingView.layer.borderWidth = 2.0;
        switchBackingView.backgroundColor = [UIColor clearColor];

        [switchBackingView.leadingAnchor constraintEqualToAnchor:_onOffSwitch.leadingAnchor].active = YES;;
        [switchBackingView.trailingAnchor constraintEqualToAnchor:_onOffSwitch.trailingAnchor].active = YES;;
        [switchBackingView.topAnchor constraintEqualToAnchor:_onOffSwitch.topAnchor].active = YES;;
        [switchBackingView.bottomAnchor constraintEqualToAnchor:_onOffSwitch.bottomAnchor].active = YES;;
    }
   
    // These are indded magic number for Apple switches. They aren't actually documented, but are the internal sizes always used
    // for a switch. Using different numbers is non-optimal.
    [self.onOffSwitch.widthAnchor constraintEqualToConstant:51.0].active = YES;
    [self.onOffSwitch.heightAnchor constraintEqualToConstant:31.0].active = YES;

    [self.onOffSwitch.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.leadingAnchor].active = YES;
    [self.onOffSwitch.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    [self.onOffSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateUI];
}

- (void)updateSwitchTint {
    self.onOffSwitch.onTintColor = self.switchTintColor;
}

- (IBAction)switchChanged:(id)sender {
    [DUXBetaStateChangeBroadcaster send:[ListItemSwitchUIState switchValueChanged:self.onOffSwitch.on]];
    if (self.actionBlock) {
        self.actionBlock(self.onOffSwitch.on);
    }
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    CGFloat height = 44.0;
    CGFloat width = 320.0;
    DUXBetaWidgetSizeHint hint = {width/height, width, height};
    return hint;
}

@end

@implementation ListItemSwitchUIState

+ (instancetype)switchValueChanged:(BOOL)isOn {
    return [[self alloc] initWithKey:@"switchValueChanged" number:@(isOn)];
}

+ (instancetype)switchEnabled:(BOOL)isEnabled {
    return [[self alloc] initWithKey:@"switchEnabled" number:@(isEnabled)];
}

@end
