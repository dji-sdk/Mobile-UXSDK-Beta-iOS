//
//  DUXListItemEditTextButtonWidget.m
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

#import "DUXListItemEditTextButtonWidget.h"

@import DJIUXSDKCore;

static const CGFloat kDesignHeightEditHeightMinimum = 28.0;
static const CGFloat kDesignHeightActionButtonMinimum = 28.0;
static CGFloat listItemAtionButtonSideMargin = 8.0;

@interface DUXListItemEditTextButtonWidget () <UITextFieldDelegate>

@property (nonatomic, assign) BOOL      isReturnPress;
@property (nonatomic, assign) NSInteger minLimit;
@property (nonatomic, assign) NSInteger maxLimit;
@property (nonatomic, assign) CGFloat   editFieldWidthHint;

@property (nonatomic, strong) DUXTextInputChangeBlock   changeBlock;
@property (nonatomic, strong) GenericButtonActionBlock  buttonActionBlock;
@property (nonatomic, strong) DUXTextInputChangeBlock   internalTextChangeBlockWrapper;

@property (nonatomic, strong) NSString  *editTextString;
@property (nonatomic, strong) NSString  *originalFieldString;
@property (nonatomic, strong) NSString  *buttonTitle;
@property (nonatomic, readwrite) BOOL   hasButton;

@property (nonatomic, retain) UILabel   *hintTextLabel;
@property (nonatomic, strong) UIButton  *actionButton;

@property (nonatomic, strong) NSLayoutConstraint        *buttonWidthConstraint;

@end

@implementation DUXListItemEditTextButtonWidget

// If somebody doesn't call the specialized setter version, just give the edit without button version
- (instancetype)init {
    if (self = [super init]) {
        _hasButton = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _hasButton = NO;
    }
    return self;
}

- (instancetype)init:(DUXListItemEditTextButtonWidgetType)widgetStyle {
    if (self = [super init]) {
        _hasButton = (widgetStyle == DUXListItemEditAndButton);
    }
    return self;
}

- (void)setupCustomizableSettings {
    [super setupCustomizableSettings];
    _editTextColor = [UIColor duxbeta_linkBlueColor];
    _editTextBorderColor = [UIColor duxbeta_whiteColor];
    _editTextDisabledColor = [UIColor duxbeta_lightGrayColor];
    _editTextFont = [UIFont systemFontOfSize:14.0];
    _editTextCornerRadius = 5.0f;
    _editTextBorderWidth = 1.0f;
    
    _hintTextColor = [UIColor duxbeta_lightGrayColor];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
    
    BindRKVOModel(self, @selector(editEnabledChanged), enableEditField);
    
    BindRKVOModel(self, @selector(updateButtonUI), buttonColors, buttonFont,
                                                    buttonCornerRadius, buttonBorderWidth, buttonBorderColors);
    BindRKVOModel(self, @selector(updateHintUI), hintBackgroundColor, hintTextColor, hintTextFont);
    BindRKVOModel(self, @selector(updateEditTextUI), editTextColor, editTextBorderColor, editTextDisabledColor, editTextFont, editTextCornerRadius, editTextBorderWidth);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

- (void)editEnabledChanged {
    if (self.inputField.enabled != self.enableEditField) {
        [self updateEditTextUI];
    }
}

- (instancetype)setButtonAction:(GenericButtonActionBlock)actionBlock {
    self.buttonActionBlock = actionBlock;
    return self;
}

- (GenericButtonActionBlock)getButtonAction {
    return self.buttonActionBlock;
}

- (IBAction)buttonPush {
    [DUXStateChangeBroadcaster send:[ListItemEditTextUIState buttonTapped]];

    if (self.buttonActionBlock) {
        self.buttonActionBlock(self);
    }
}

- (void)setTextChangedBlock:(DUXTextInputChangeBlock)newBlock {
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
        [_actionButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
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

    __weak DUXListItemEditTextButtonWidget *weakSelf = self;
    self.internalTextChangeBlockWrapper = ^(NSString *newText) {
        NSInteger newHeight = [newText intValue];
        if (newHeight > 0) {
            __strong DUXListItemEditTextButtonWidget *strongSelf = weakSelf;
            if (strongSelf) {
                if (strongSelf.changeBlock) {
                    strongSelf.changeBlock(newText);
                }
            }
        }
    };
}

- (void)updateEditTextUI {
    [super updateUI];
    
    self.inputField.font = self.editTextFont;
    self.inputField.layer.cornerRadius = self.editTextCornerRadius;
    self.inputField.layer.borderWidth = self.editTextBorderWidth;

    if (self.inputField.enabled != self.enableEditField) {
        self.inputField.enabled = self.enableEditField;
        if (self.enableEditField) {
            self.inputField.layer.borderColor = [self.editTextBorderColor CGColor];
            self.inputField.textColor = self.editTextColor;
            [self.inputField reloadInputViews];
        } else {
            self.inputField.layer.borderColor = [self.editTextDisabledColor CGColor];
            self.inputField.textColor = self.editTextDisabledColor;
            [self.inputField reloadInputViews];
        }
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
    }
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
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint sizeHint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return sizeHint;
}
                   
// MARK: Support for text field.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [DUXStateChangeBroadcaster send:[ListItemEditTextUIState editBeginsUpdate]];
    self.isReturnPress = NO;
    self.originalFieldString = [textField.text copy];  // Keep this in case they end editing with an invalid value.

    if (self.keyboardChangedStatusBlock) {
        self.keyboardChangedStatusBlock(YES);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    textField.layer.borderWidth = self.editTextBorderWidth; // This is to fix the borderWidth getting reset on a double tap
    [DUXStateChangeBroadcaster send:[ListItemEditTextUIState editEndsUpdate]];
    if ([self validateString:textField.text]) {
        textField.text = [NSString stringWithFormat:@"%d",textField.text.intValue];
        self.internalTextChangeBlockWrapper(textField.text);
    } else {
        textField.text = _originalFieldString;
    }
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
        return [self validateInputString:inputString];
    }
    return YES;
}

- (BOOL)validateInputString:(NSString *)string{
    if ([self isTextFieldUnsignedIntValue:string]) {
        if (self.maxLimit && (string.intValue > self.maxLimit)) {
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
    __weak DUXListItemEditTextButtonWidget *weakSelf = self;
    return ^(DUXListItemEditTextButtonWidget* classInstance) {
        __strong DUXListItemEditTextButtonWidget *strongSelf = weakSelf;
        if (strongSelf) {
            
            strongSelf.buttonEnabled = NO;
        }
    };
}

@end

@implementation ListItemEditTextUIState
+ (instancetype)editBeginsUpdate {
    return [[self alloc] initWithKey:@"textEditingBegins"];
}

+ (instancetype)editEndsUpdate {
    return [[self alloc] initWithKey:@"textEditingEnds"];
}

+ (instancetype)buttonTapped {
    return [[self alloc] initWithKey:@"buttonTapped"];
}

+ (instancetype)buttonStateChanged:(BOOL)newState {
    return [[self alloc] initWithKey:@"buttonStateChanged" number:@(newState)];
}
@end

@implementation ListItemEditTextModelState

@end
