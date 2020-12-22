//
//  DUXBetaListItemEditTextButtonWidget.m
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

#import "DUXBetaListItemEditTextButtonWidget.h"
#import "UIColor+DUXBetaColors.h"

static const CGFloat kDesignHeightEditHeightMinimum = 28.0;
static const CGFloat kDesignHeightActionButtonMinimum = 28.0;
static CGFloat listItemAtionButtonSideMargin = 8.0;

@interface DUXBetaListItemEditTextButtonWidget () <UITextFieldDelegate>

@property (nonatomic, assign) BOOL      isReturnPress;
@property (nonatomic, assign) NSInteger minLimit;
@property (nonatomic, assign) NSInteger maxLimit;
@property (nonatomic, assign) CGFloat   editFieldWidthHint;

@property (nonatomic, strong) DUXBetaTextInputChangeBlock   changeBlock;
@property (nonatomic, strong) GenericButtonActionBlock  buttonActionBlock;
@property (nonatomic, strong) DUXBetaTextInputChangeBlock   internalTextChangeBlockWrapper;

@property (nonatomic, strong) NSString  *editTextString;
@property (nonatomic, strong) NSString  *originalFieldString;
@property (nonatomic, strong) NSString  *buttonTitle;
@property (nonatomic, readwrite) BOOL   hasButton;

@property (nonatomic, retain) UILabel   *hintTextLabel;
@property (nonatomic, strong) UIButton  *actionButton;

@property (nonatomic, strong) NSLayoutConstraint        *buttonWidthConstraint;

// This may be eiter centerXAnchor or rightAnchor depending on what else is currently visible
@property (nonatomic, strong) NSLayoutConstraint        *buttonPositionConstraint;

@property (nonatomic, assign) DUXBetaListItemEditTextButtonWidgetType widgetStyle;

@property (nonatomic, readwrite) BOOL   editTextIsValid;

@end

@implementation DUXBetaListItemEditTextButtonWidget

// If somebody doesn't call the specialized setter version, just give the edit without button version
- (instancetype)init {
    if (self = [super init]) {
        _widgetStyle = DUXBetaListItemOnlyEdit;
        _hasButton = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _widgetStyle = DUXBetaListItemOnlyEdit;
        _hasButton = NO;
    }
    return self;
}

- (instancetype)init:(DUXBetaListItemEditTextButtonWidgetType)widgetStyle {
    if (self = [super init]) {
        _widgetStyle = widgetStyle;
        _hasButton = (widgetStyle == DUXBetaListItemEditAndButton);
    }
    return self;
}

- (void)setupCustomizableSettings {
    [super setupCustomizableSettings];
    _editTextColor = [UIColor uxsdk_linkBlueColor];

    _editTextValidColor = [UIColor uxsdk_linkBlueColor];
    _editTextInvalidColor = [UIColor uxsdk_errorDangerColor];
    _editTextBorderColor = [UIColor uxsdk_whiteColor];
    _editTextDisabledColor = [UIColor uxsdk_lightGrayWhite66];
    _editTextFont = [UIFont systemFontOfSize:14.0];
    _editTextCornerRadius = 5.0f;
    _editTextBorderWidth = 1.0f;
    
    _hintTextColor = [UIColor uxsdk_lightGrayWhite66];
    _hintTextFont = [UIFont systemFontOfSize:14.0];
    _hintBackgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _minLimit = 0;
    _maxLimit = 5000;
    _editFieldWidthHint = 0;
    
    self.enableEditField = YES;
    self.editTextIsValid = YES;
    self.dynamicButtonAdjustment = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
    
    BindRKVOModel(self, @selector(updateButtonUI), buttonColors, buttonFont,
                                                   buttonCornerRadius, buttonBorderWidth, buttonBorderColors, buttonBackgroundColors);
    BindRKVOModel(self, @selector(updateHintUI), hintBackgroundColor, hintTextColor, hintTextFont);
    BindRKVOModel(self, @selector(updateEditTextUI), editTextBorderColor, editTextDisabledColor,
                                                     editTextFont, editTextCornerRadius, editTextBorderWidth);
    BindRKVOModel(self, @selector(editTextColorUpdated), editTextColor);
    // Due to KVO calls happening as soon as the model is is bound, the base editTextColor must be set/bound before
    // Any of the optional valid/invali colors are bound, or even the validity check is bound.
    BindRKVOModel(self, @selector(updateEditTextConditionalColorsUI), editTextValidColor, editTextInvalidColor);
    BindRKVOModel(self, @selector(textValidityChanged), editTextIsValid);
    BindRKVOModel(self, @selector(editEnabledChanged), enableEditField);


    if (_widgetStyle == DUXBetaListItemEditAndButton) {
        BindRKVOModel(self, @selector(updateButtonPositioning), inputField.isHidden);

    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

- (void)editEnabledChanged {
    [self updateEditTextUI];
}

- (void)textValidityChanged {
    self.editTextColor = _editTextIsValid ? self.editTextValidColor : self.editTextInvalidColor;
}

- (instancetype)setButtonAction:(GenericButtonActionBlock)actionBlock {
    self.buttonActionBlock = actionBlock;
    return self;
}

- (GenericButtonActionBlock)getButtonAction {
    return self.buttonActionBlock;
}

- (IBAction)buttonPush {
    [DUXBetaStateChangeBroadcaster send:[ListItemEditTextButtonUIState buttonTapped]];

    if (self.buttonActionBlock) {
        self.buttonActionBlock(self);
    }
}

- (void)hideInputAndHint:(BOOL)doHide {
    self.inputField.hidden = doHide;
    self.hintTextLabel.hidden = doHide;
    [self updateButtonPositioning];
}

- (void)hideInputField:(BOOL)doHide {
    self.inputField.hidden = doHide;
    [self updateButtonPositioning];
}

- (void)hideHintLabel:(BOOL)doHide {
    self.hintTextLabel.hidden = doHide;
}

- (void)setTextChangedBlock:(DUXBetaTextInputChangeBlock)newBlock {
    _changeBlock = newBlock;
}

- (void)setKey:(DJIKey*)key isNumeric:(BOOL)isNumeric additionalInfo:(NSString*)hintString {
   
}

- (void)setupUI {
    if (self.inputField != nil) {
        return;
    }

    [super setupUI];

    self.inputField = [[UITextField alloc] init];
    self.inputField.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputField.keyboardType = UIKeyboardTypeNumberPad;
    self.inputField.returnKeyType = UIReturnKeyDone;
    self.inputField.textAlignment = NSTextAlignmentCenter;
    self.inputField.textColor = self.editTextColor;
     
    self.inputField.layer.cornerRadius = self.editTextCornerRadius;
    self.inputField.layer.borderWidth = self.editTextBorderWidth;
    self.inputField.layer.borderColor = [self.editTextBorderColor CGColor];
    [self.inputField reloadInputViews];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
        [keyboardDoneButtonView sizeToFit];
        UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                          target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStylePlain target:self
                                                                      action:@selector(doneClicked:)];
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexBarButton, doneButton, nil]];
        self.inputField.inputAccessoryView = keyboardDoneButtonView;
    }

    self.hintTextLabel = [[UILabel alloc] init];
    self.hintTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.hintTextLabel.textAlignment = NSTextAlignmentCenter;
    self.hintTextLabel.numberOfLines = 0;
    self.hintTextLabel.adjustsFontSizeToFitWidth = TRUE;
    self.hintTextLabel.textColor = _hintTextColor;
    self.hintTextLabel.font = _hintTextFont;
    self.hintTextLabel.textAlignment = NSTextAlignmentRight;

    if (_hasButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_actionButton addTarget:self action:@selector(buttonPush) forControlEvents:UIControlEventTouchUpInside];

        _actionButton.titleLabel.font = self.buttonFont;
        [_actionButton setTitleColor:[self.buttonColors objectForKey:@(UIControlStateNormal)] forState:UIControlStateNormal];
        _actionButton.layer.borderColor = [self.buttonBorderColors[@(UIControlStateNormal)] CGColor];
        _actionButton.layer.backgroundColor = [self.buttonBackgroundColors[@(UIControlStateNormal)] CGColor];
        _actionButton.layer.cornerRadius = self.buttonCornerRadius;
        _actionButton.layer.borderWidth = self.buttonBorderWidth;
        _actionButton.enabled = YES;
        _actionButton.showsTouchWhenHighlighted = YES;
        _actionButton.userInteractionEnabled = YES;
        if (_buttonTitle) {
            [_actionButton setTitle:_buttonTitle forState:UIControlStateNormal];
        }
        [_actionButton sizeToFit];
    }

    [self.view addSubview:self.inputField];
    [self.view addSubview:self.hintTextLabel];
    [self.view addSubview:self.actionButton];

    [self.inputField.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.trailingAnchor constant:0.0].active = YES;
    [self.inputField.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    if (self.editFieldWidth == 0.0) {
        if (self.editFieldWidthHint == 0.0) {
            self.inputField.text = @"88888.8";
            [self.inputField sizeToFit];
            self.editFieldWidth = self.inputField.bounds.size.width;
        } else {
            self.editFieldWidth = self.editFieldWidthHint;
        }
    }
    self.inputField.text = @"N/A";

    [self.inputField.widthAnchor constraintEqualToConstant:self.editFieldWidth].active = YES;
    [self.inputField.heightAnchor constraintEqualToConstant:kDesignHeightEditHeightMinimum].active = YES;
    self.inputField.delegate = self;

    if (_hasButton) {
        if (_buttonPositionConstraint) {
            _buttonPositionConstraint.active = NO;
        }
        if (_widgetStyle == DUXBetaListItemEditAndButton) {
            _buttonPositionConstraint = [_actionButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor];
        } else {
            _buttonPositionConstraint = [_actionButton.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.trailingAnchor constant:0.0];
        }
        _buttonPositionConstraint.active = YES;
        [_actionButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
        [_actionButton.heightAnchor constraintEqualToConstant:kDesignHeightActionButtonMinimum].active = YES;
        _buttonWidthConstraint = [_actionButton.widthAnchor constraintEqualToConstant:[self.actionButton intrinsicContentSize].width + listItemAtionButtonSideMargin * 2];
        _buttonWidthConstraint.active = YES;
    }

    [self.hintTextLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.hintTextLabel.trailingAnchor constraintEqualToAnchor:self.inputField.leadingAnchor constant:-8.0].active = YES;
    [self.hintTextLabel.heightAnchor constraintEqualToAnchor:self.inputField.heightAnchor].active = YES;

    if (_hasButton) {
        [self.hintTextLabel.leadingAnchor constraintEqualToAnchor:self.actionButton.trailingAnchor constant:8.0].active = YES;
    } else {
        [self.hintTextLabel.leadingAnchor constraintEqualToAnchor:self.trailingTitleGuide.trailingAnchor].active = YES;
    }

    
    if (self.hintText != nil) {
        self.hintTextLabel.text = self.hintText;
    }
    
    if (self.editTextString != nil) {
        self.inputField.text = self.editTextString;
    }

    __weak DUXBetaListItemEditTextButtonWidget *weakSelf = self;
    self.internalTextChangeBlockWrapper = ^(NSString *newText) {
        NSInteger newHeight = [newText intValue];
        if (newHeight > 0) {
            __strong DUXBetaListItemEditTextButtonWidget *strongSelf = weakSelf;
            if (strongSelf) {
                if (strongSelf.changeBlock) {
                    strongSelf.changeBlock(newText);
                }
            }
        }
    };
}

- (void)updateButtonPositioning {
    if ((_widgetStyle == DUXBetaListItemEditAndButton) && _dynamicButtonAdjustment) {
        _buttonPositionConstraint.active = NO;
        if (self.inputField.isHidden) {
            // Button needs to move to the right edge
            _buttonPositionConstraint = [_actionButton.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.trailingAnchor constant:0.0];
        } else {
            // Button needs to be centered
            _buttonPositionConstraint = [_actionButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor];
        }
        _buttonPositionConstraint.active = YES;
    }
}

- (void)updateEditTextConditionalColorsUI {
    // One of the contitional colors changed and those are used for the edit text color.
    [self textValidityChanged];
    [self updateEditTextUI];
}

- (void)editTextColorUpdated {
    // The standard edit text color was changed but may be overwritten by validation code
    // when validating/invalidating the edit field.
    [self updateEditTextUI];
}

- (void)updateEditTextUI {
    [super updateUI];

    self.inputField.font = self.editTextFont;
    self.inputField.layer.cornerRadius = self.editTextCornerRadius;

    if (self.inputField.enabled != self.enableEditField) {
        self.inputField.enabled = self.enableEditField;
    }
    if (self.enableEditField) {
        self.inputField.layer.borderColor = [self.editTextBorderColor CGColor];
        self.inputField.layer.borderWidth = self.editTextBorderWidth;
        self.inputField.textColor = self.editTextColor;
        [self.inputField reloadInputViews];

    } else {
        self.inputField.layer.borderColor = [self.editTextDisabledColor CGColor];
        self.inputField.textColor = self.editTextDisabledColor;
        [self.inputField reloadInputViews];
    }
}

- (void)updateHintUI {
    self.hintTextLabel.layer.borderColor = [self.hintTextColor CGColor];
    self.hintTextLabel.textColor = self.hintTextColor;
    self.hintTextLabel.font = self.hintTextFont;
    self.hintTextLabel.backgroundColor = self.hintBackgroundColor;
}

- (void)updateButtonUI {
    if (self.hasButton) {
        self.actionButton.layer.cornerRadius = self.buttonCornerRadius;
        if (self.actionButton.enabled) {
            self.actionButton.layer.borderColor = [self.buttonBorderColors[@(UIControlStateNormal)] CGColor];
        } else {
            self.actionButton.layer.borderColor = [self.buttonBorderColors[@(UIControlStateDisabled)] CGColor];
        }
        [_actionButton setTitleColor:[self.buttonColors objectForKey:@(UIControlStateNormal)] forState:UIControlStateNormal];
        [_actionButton setTitleColor:[self.buttonColors objectForKey:@(UIControlStateDisabled)] forState:UIControlStateDisabled];
        self.actionButton.layer.borderWidth = self.buttonBorderWidth;
        
        if (_actionButton.state & UIControlStateDisabled) {
            _actionButton.backgroundColor = self.buttonBackgroundColors[@(UIControlStateDisabled)];
        } else if (_actionButton.state & UIControlStateHighlighted) {
            _actionButton.layer.backgroundColor = [self.buttonBackgroundColors[@(UIControlStateHighlighted)] CGColor];
        } else if (_actionButton.state & UIControlStateSelected) {
            _actionButton.layer.backgroundColor = [self.buttonBackgroundColors[@(UIControlStateSelected)] CGColor];
        } else {
            _actionButton.backgroundColor = self.buttonBackgroundColors[@(UIControlStateNormal)];
        }

    }
}

- (void)setButtonEnabled:(BOOL)makeEnabled {
    _buttonEnabled = makeEnabled;
    _actionButton.enabled = makeEnabled;
    [self updateButtonUI];
}

- (void)setButtonHidden:(BOOL)isHidden {
    _actionButton.hidden = isHidden;
    [self updateButtonUI];
}

- (void)setButtonTitle:(NSString*)newButtonTitle {
    _buttonTitle = newButtonTitle;
    if (self.actionButton) {
        [self.actionButton setTitle:newButtonTitle forState:UIControlStateNormal];
        
        if (_buttonWidthConstraint) {
            _buttonWidthConstraint.active = NO;
        }
        _buttonWidthConstraint = [_actionButton.widthAnchor constraintEqualToConstant:[self.actionButton intrinsicContentSize].width + listItemAtionButtonSideMargin * 2];
        _buttonWidthConstraint.active = YES;
    }
}

- (void)setEditText:(NSString*)editFieldText {
    _editTextString = editFieldText;
    if (self.inputField) {
        self.inputField.text = _editTextString;
        self.editTextIsValid = [self validateInputString:_editTextString];
    }
}

- (void)setHintText:(NSString*)hintText {
    _hintText = hintText;
    if (self.hintTextLabel) {
        self.hintTextLabel.text = _hintText;
    }
}

- (void)setEditFieldWidthHint:(CGFloat)editWidthHint {
    _editFieldWidthHint = editWidthHint;
}

- (void)setEditFieldWidth:(CGFloat)editWidth {
    _editFieldWidth = editWidth;
}

- (void)setEditFieldValuesMin:(NSInteger)minValue maxValue:(NSInteger)maxValue {
    _minLimit = minValue;
    _maxLimit = maxValue;

    if ((self.enableEditField) && (self.inputField.text.length > 0)) {
        [self validateInputString:self.inputField.text];
    }
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint sizeHint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return sizeHint;
}
                   
// MARK: Support for text field.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [DUXBetaStateChangeBroadcaster send:[ListItemEditTextButtonUIState editStarted]];
    self.isReturnPress = NO;
    self.originalFieldString = [textField.text copy];  // Keep this in case they end editing with an invalid value.

    if (self.keyboardChangedStatusBlock) {
        self.keyboardChangedStatusBlock(YES);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    textField.layer.borderWidth = self.editTextBorderWidth; // This is to fix the borderWidth getting reset on a double tap
    [DUXBetaStateChangeBroadcaster send:[ListItemEditTextButtonUIState editFinished]];

    if ([self validateString:textField.text]) {
        textField.text = [NSString stringWithFormat:@"%d",textField.text.intValue];
        self.internalTextChangeBlockWrapper(textField.text);
    } else {
        textField.text = _originalFieldString;
    }

    self.editTextIsValid = YES; // The edit field guarantees to have put a valid value back in the edit field
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.keyboardChangedStatusBlock) {
        self.keyboardChangedStatusBlock(NO);
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *inputString = [NSMutableString stringWithString:textField.text];
    [inputString replaceCharactersInRange:range withString:string];
    if (inputString.length > 0) {
        self.editTextIsValid = [self validateInputString:inputString];
    }
    return YES;
}

- (BOOL)validateInputString:(NSString *)string{
    if ([self isTextFieldUnsignedIntValue:string]) {
        // A min limit of 0 is a valid min limit unless explicitly changed, so don't check to see if it has a non-zero value
        if ((self.maxLimit && (string.intValue > self.maxLimit)) || (string.intValue < self.minLimit)) {
            return NO;
        }
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)validateString:(NSString *)string {
    if ([self validateInputString:string]) {
            if (self.minLimit && (string.intValue < self.minLimit)) {
                return NO;
            }
            return YES;
    }
    return NO;
}

- (BOOL)isTextFieldUnsignedIntValue:(NSString *)text{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[0-9]+"];
    return [predicate evaluateWithObject:text];}

- (void)doneClicked:(UIButton *) button {
    [self.inputField endEditing:YES];
    [self.inputField resignFirstResponder];
}

// This is a sample version of the action block which changes the status to Ready and disables
// the flag for the action button. Override this in the custom model class for a specific
// widget.
- (GenericButtonActionBlock)sampleActionBlock {
    __weak DUXBetaListItemEditTextButtonWidget *weakSelf = self;
    return ^(DUXBetaListItemEditTextButtonWidget* classInstance) {
        __strong DUXBetaListItemEditTextButtonWidget *strongSelf = weakSelf;
        if (strongSelf) {
            
            strongSelf.buttonEnabled = NO;
        }
    };
}

@end

@implementation ListItemEditTextButtonUIState
+ (instancetype)editStarted {
    return [[self alloc] initWithKey:@"textEditingBegins"];
}

+ (instancetype)editFinished {
    return [[self alloc] initWithKey:@"textEditingEnds"];
}

+ (instancetype)buttonTapped {
    return [[self alloc] initWithKey:@"buttonTapped"];
}
@end

@implementation ListItemEditTextButtonModelState

@end
