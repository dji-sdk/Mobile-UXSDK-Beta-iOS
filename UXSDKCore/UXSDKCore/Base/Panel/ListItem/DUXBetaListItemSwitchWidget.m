//
//  DUXBetaListItemSwitchWidget.m
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

#import "DUXBetaListItemSwitchWidget.h"
#import <UXSDKCore/UISwitch+DUXBetaBackgroundHelper.h>

@interface DUXBetaListItemSwitchWidget()

@property (nonatomic, strong) SwitchChangedActionBlock    actionBlock;
@property (nonatomic, assign) BOOL uiAlreadySetup;
@property (nonatomic, strong) UIView *switchBackingView;    // Only used in iOS 13+
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
    
    _switchTrackColor = [UIColor colorWithWhite:1.0 alpha:0.3];  // Using system whiteColor instead of uxsdk_whiteColor to make sure we match iOS color.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BindRKVOModel(self, @selector(switchEnabledStateChanged), onOffSwitch.enabled);
    BindRKVOModel(self, @selector(updateSwitchColors), switchTintColor, switchTrackColor, switchOffTintColor);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

- (void)setSwitchAction:(SwitchChangedActionBlock)newBlock {
    self.actionBlock = newBlock;
}

- (void)switchEnabledStateChanged {
    [self updateUI];
}

// This setupUI does not set a hard width. That should probably be imposed externally.
- (void)setupUI {
    if (_uiAlreadySetup) { return; }
    _uiAlreadySetup = YES;
    [super setupUI];
    
    self.onOffSwitch = [[UISwitch alloc] init];
    self.onOffSwitch.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *switchConstraintsView = [_onOffSwitch setupOutlineViewForUISwitch];
    [self.view addSubview:switchConstraintsView];
   
    // These are indeed magic number for Apple switches. They aren't actually documented, but are the internal sizes always used
    // for a switch. Using different numbers is non-optimal.
    [switchConstraintsView.widthAnchor constraintEqualToConstant:51.0].active = YES;
    [switchConstraintsView.heightAnchor constraintEqualToConstant:31.0].active = YES;

    [switchConstraintsView.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.leadingAnchor].active = YES;
    [switchConstraintsView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    [self.onOffSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateUI];
}

- (void)updateSwitchColors {
    [_onOffSwitch setupCustomSwitchColorsOnTint:self.switchTintColor offTint:_switchOffTintColor trackColor:_switchTrackColor];
}

- (IBAction)switchChanged:(id)sender {
    [DUXBetaStateChangeBroadcaster send:[ListItemSwitchUIState switchChanged:self.onOffSwitch.on]];
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

+ (instancetype)switchChanged:(BOOL)isOn {
    return [[self alloc] initWithKey:@"switchChanged" number:@(isOn)];
}

@end
