//
//  DUXListItemLabelButtonWidget.m
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

#import "DUXListItemLabelButtonWidget.h"
@import DJIUXSDKCore;

static CGFloat listItemAtionButtonSideMargin = 8.0;
static const CGFloat kDesignHeightActionButtonMinimum = 28.0;

@interface DUXListItemLabelButtonWidget ()

@property (nonatomic, strong) UIButton  *actionButton;
@property (nonatomic, strong) UILabel   *displayTextLabel;
@property (nonatomic, strong) NSString  *labelText;
@property (nonatomic, strong) NSString  *buttonTitle;

@property (nonatomic, strong) GenericButtonActionBlock  buttonActionBlock;

@property (nonatomic, readwrite) BOOL   hasButton;
@property (nonatomic, readwrite) BOOL   hasLabel;

@property (nonatomic, strong) NSLayoutConstraint        *buttonWidthConstraint;
@end

@implementation DUXListItemLabelButtonWidget

- (instancetype)init:(DUXListItemLabelWidgetType)widgetStyle {
    if (self = [super init]) {
        [self setupWidgetStyle: widgetStyle];
    }
    return self;
}

// If instantiating this from a storyboard or xib file,
// the default widget style is with a label and button
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupWidgetStyle: DUXListItemLabelAndButton];
    }
    return self;
}

- (void)setupWidgetStyle:(DUXListItemLabelWidgetType)widgetStyle {
    _hasButton = (widgetStyle == DUXListItemButtonOnly) || (widgetStyle == DUXListItemLabelAndButton);
    _hasLabel =  (widgetStyle == DUXListItemLabelOnly) || (widgetStyle == DUXListItemLabelAndButton);
    if (_hasButton) {
        self.buttonEnabled = YES;
    }
}

- (void)setupCustomizableSettings {
    [super setupCustomizableSettings];
    _labelFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    _labelTextColorNormal = [self normalColor];
    _labelTextColorDisconnected = [self disabledColor];
}

- (DUXBetaBaseWidgetModel *)widgetModel {
    [[[NSException alloc] initWithName:NSGenericException reason:@"Derived classes must have a widget model" userInfo:nil] raise];
    return [[DUXBetaBaseWidgetModel alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BindRKVOModel(self, @selector(buttonEnabledChanged), buttonEnabled);
    BindRKVOModel(self, @selector(updateButton), buttonFont, buttonBorderWidth, buttonCornerRadius, buttonEnabled, buttonColors);
    BindRKVOModel(self, @selector(updateLabel), labelFont, labelTextColorNormal, labelTextColorDisconnected);
    BindRKVOModel(self.widgetModel, @selector(updateLabel), isProductConnected);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

- (void)setButtonTitle:(NSString *)newButtonTitle {
    if (_hasButton) {
        _buttonTitle = newButtonTitle;
        if (_actionButton) {
            [_actionButton setTitle:newButtonTitle forState:UIControlStateNormal];
            [_actionButton sizeToFit];
            
            if (_buttonWidthConstraint) {
                _buttonWidthConstraint.active = NO;
            }
            _buttonWidthConstraint = [_actionButton.widthAnchor constraintEqualToConstant:[self.actionButton intrinsicContentSize].width + listItemAtionButtonSideMargin * 2];
            _buttonWidthConstraint.active = YES;
        }
    }
}

- (void)setLabelText:(NSString *)labelText {
    if (_hasLabel) {
        _labelText = labelText;
        if (self.displayTextLabel) {
            self.displayTextLabel.text = labelText;
            [DUXStateChangeBroadcaster send:[ListItemLabelButtonUIState displayStringUpdated:self.displayString]];
        }
    }
}

#pragma mark - Action Button Support

- (void)buttonEnabledChanged {
    [DUXStateChangeBroadcaster send:[ListItemLabelButtonUIState enabledButtonStateChanged:self.buttonEnabled]];
    [self updateUI];
}

- (instancetype)setButtonAction:(GenericButtonActionBlock)actionBlock {
    self.buttonActionBlock = actionBlock;
    return self;
}

- (GenericButtonActionBlock)getButtonAction {
    return self.buttonActionBlock;
}

- (IBAction)buttonPush {
    [DUXStateChangeBroadcaster send:[ListItemLabelButtonUIState buttonTapped]];

    if (self.buttonActionBlock) {
        self.buttonActionBlock(self);
    }
}

#pragma mark - Standard Widget UI

- (void)setupUI {
    [super setupUI];

    if (_hasButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_actionButton addTarget:self action:@selector(buttonPush) forControlEvents:UIControlEventTouchUpInside];

        _actionButton.titleLabel.font = self.buttonFont;
        [_actionButton setTitle:_buttonTitle forState:UIControlStateNormal];

        _actionButton.layer.borderColor = [self.buttonBorderColors[@(UIControlStateNormal)] CGColor];
        _actionButton.layer.cornerRadius = self.buttonCornerRadius;
        _actionButton.layer.borderWidth = self.buttonBorderWidth;
        _actionButton.enabled = YES;
        _actionButton.showsTouchWhenHighlighted = YES;
        _actionButton.userInteractionEnabled = YES;
        [_actionButton sizeToFit];

        [self.view addSubview:self.actionButton];
        
        self.trailingMarginConstraint.active = NO;
        // Since we have a button, we now need to adjust the trailingTitleGuide to be the front of our button.
        self.trailingMarginConstraint = [self.trailingTitleGuide.trailingAnchor constraintEqualToAnchor:_actionButton.leadingAnchor];
        self.trailingMarginConstraint.active = YES;
    }

    if (_hasLabel) {
        _displayTextLabel = [[UILabel alloc] init];
        _displayTextLabel.translatesAutoresizingMaskIntoConstraints = NO;

        self.displayTextLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.displayTextLabel.textAlignment = NSTextAlignmentRight;
        self.displayTextLabel.textColor = self.labelTextColorDisconnected;
        self.displayTextLabel.font = self.labelFont;
        if (_labelText) {
            self.displayTextLabel.text = _labelText;
        }
        [self.view addSubview:self.displayTextLabel];

        [self.displayTextLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
        [self.displayTextLabel.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.leadingAnchor].active = YES;
    }

    if (_hasLabel && _hasButton) {
        [_actionButton.leftAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [_actionButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
        [self.displayTextLabel.leadingAnchor constraintEqualToAnchor:_actionButton.trailingAnchor constant:10].active = YES;
    } else if (_hasButton) {
        [_actionButton.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.leadingAnchor].active = YES;
        [_actionButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    }
    
    if (_hasButton) {
        [_actionButton.heightAnchor constraintEqualToConstant:kDesignHeightActionButtonMinimum].active = YES;
        _buttonWidthConstraint = [_actionButton.widthAnchor constraintEqualToConstant:[self.actionButton intrinsicContentSize].width + listItemAtionButtonSideMargin * 2];
        _buttonWidthConstraint.active = YES;
    }
    
    [self updateButton];
    [self updateLabel];
}

- (void)updateButton {
    if (!self.hasButton) {
        return;
    }
    [_actionButton setTitleColor:[self.buttonColors objectForKey:@(UIControlStateDisabled)] forState:UIControlStateDisabled];
    [_actionButton setTitleColor:[self.buttonColors objectForKey:@(UIControlStateNormal)] forState:UIControlStateNormal];

    _actionButton.titleLabel.font = self.buttonFont;
    _actionButton.layer.borderWidth = self.buttonBorderWidth;
    _actionButton.layer.cornerRadius = self.buttonCornerRadius;
    
    if (self.buttonEnabled != _actionButton.enabled) {
        if (self.buttonEnabled) {
            _actionButton.enabled = self.buttonEnabled;
            _actionButton.layer.borderColor = [self.buttonBorderColors[@(UIControlStateNormal)] CGColor];
            _actionButton.titleLabel.textColor = self.buttonColors[@(UIControlStateNormal)];
        } else {
            _actionButton.enabled = self.buttonEnabled;
            _actionButton.layer.borderColor = [self.buttonBorderColors[@(UIControlStateDisabled)] CGColor];
            _actionButton.titleLabel.textColor = self.buttonColors[@(UIControlStateDisabled)];
        }
    }
}

- (void)updateLabel {
    if (!self.hasLabel) {
        return;
    }
    _displayTextLabel.font = self.labelFont;
    if (self.widgetModel.isProductConnected) {
        _displayTextLabel.textColor = self.labelTextColorNormal;
    } else {
        _displayTextLabel.textColor = self.labelTextColorDisconnected;
    }
}

// This is a sample version of the action block which changes the status to Ready and disables
// the flag for the action button. Override this in the custom model class for a specific
// widget.
- (GenericButtonActionBlock)sampleActionBlock {
    __weak DUXListItemLabelButtonWidget *weakSelf = self;
    return ^(DUXListItemLabelButtonWidget* classInstance) {
        __strong DUXListItemLabelButtonWidget *strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.displayTextLabel.text = NSLocalizedString(@"Ready", @"Ready");
            
            strongSelf.buttonEnabled = NO;
        }
    };
}

#pragma mark - To Override
/*
 This method must be overridden by the actual concrete class
 */
- (NSString *)displayString {
    return @"Needs Override";
}

#pragma mark - Update Helpers

- (void)displayTextUpdated {
    [DUXStateChangeBroadcaster send:[ListItemLabelButtonUIState displayStringUpdated:self.displayString]];
    [self updateUI];
}

@end

#pragma mark - Hooks 

@implementation ListItemLabelButtonUIState

+ (instancetype)buttonTapped {
    return [[self alloc] initWithKey:@"buttonTapped" number:@(YES)];
}

+ (instancetype)enabledButtonStateChanged:(BOOL)newState {
    return [[self alloc] initWithKey:@"enabledButtonStateChanged" number:@(newState)];
}

+ (instancetype)displayStringUpdated:(NSString *)newValue {
    return [[self alloc] initWithKey:@"displayStringUpdated" string:newValue];
}

@end

@implementation ListItemLabelButtonModelState

@end

