//
//  DUXBetaListItemRadioButtonWidget.m
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

#import "DUXBetaListItemRadioButtonWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "NSObject+DUXBetaRKVOExtension.h"
@import DJIUXSDKCore;

@interface DUXBetaListItemRadioButtonWidget ()

@property (nonatomic, strong) UISegmentedControl        *radioControl;
@property (nonatomic, strong) NSLayoutAnchor            *radioLeadingAnchor;
@property (nonatomic, strong) NSMutableArray<NSString*> *titlesArray;
@property (nonatomic, strong) RadioButtonOptionChanged  actionBlock;
@property (nonatomic, readwrite) BOOL                   isControlEnabled;

@property (nonatomic, strong) UIColor *selectionTint;
@property (nonatomic, strong) UIColor *tabsBackgroundColor;

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIColor*>  *customSelectionTints;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIColor*>  *customBackgroundColors;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIColor*>  *customDisabledColora;

@property (nonatomic, strong) UIImage   *baseDividerImage;  // This is the raw image to be colorized into colorizedDividerImage
@property (nonatomic, strong) UIImage   *colorizedDividerImage;
@property (nonatomic, strong) UIImage   *ios13BackgroundImage;
@end

@implementation DUXBetaListItemRadioButtonWidget

- (instancetype)init {
    if (self = [super init]) {
        _titlesArray = [NSMutableArray new];
        _selection = UISegmentedControlNoSegment;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _titlesArray = [NSMutableArray new];
        _selection = UISegmentedControlNoSegment;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self setupUI];
}

- (void)setupCustomizableSettings {
    [super setupCustomizableSettings];

    _customSelectionTints = [NSMutableDictionary new];
    _customBackgroundColors = [NSMutableDictionary new];

    _selectionTint = [UIColor duxbeta_whiteColor];
    _tabsBackgroundColor = [UIColor colorWithWhite:0.0f alpha:.2f];   // Black with slight transparency
    
    // Some special color handling due to the way UISegementControl handles disabling the control. The selected color
    // needs to be set based on the highlight color. But then the selection disappears during a disable
    // so the disabled state then needs to be the normal color. And we have to adjust selected state
    // during control enable disable.
    // TL;DR version: these colors need to be set unsually due to the differing background color of the selected state.
    _selectedRadioTextColor = [UIColor duxbeta_blackColor];
    self.buttonColors[@(UIControlStateSelected)] = [self selectedRadioTextColor];
    self.buttonColors[@(UIControlStateDisabled)] = [self normalColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self, @selector(tintUpdated), selection);
    BindRKVOModel(self, @selector(selectedRadioTextColorChanged), selectedRadioTextColor);
    BindRKVOModel(self, @selector(enableStateChanged), radioControl.enabled);
    BindRKVOModel(self, @selector(backgroundTintUpdated), tabsBackgroundColor, selectionTint);
    BindRKVOModel(self, @selector(editingEnableChanged), isControlEnabled);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

#pragma mark - Options setup and support
- (void)setOptionSelectedAction:(RadioButtonOptionChanged)actionBlock {
    _actionBlock = actionBlock;
}

- (void)setSelection:(NSInteger)selectionIndex {
    if ((selectionIndex >= 0) && (selectionIndex < _radioControl.numberOfSegments)) {
        NSInteger oldValue = _selection;
        _selection = selectionIndex;
        [_radioControl setSelectedSegmentIndex:selectionIndex];
        if (_actionBlock) {
            _actionBlock(oldValue, selectionIndex);
        }
    }
}

- (NSInteger)count {
    return _radioControl.numberOfSegments;
}

- (void)setEnabled:(BOOL)isEnabled {
    _isControlEnabled = isEnabled;
    _radioControl.enabled = isEnabled;
    if (isEnabled) {
        _radioControl.layer.borderColor = [self.buttonBorderColors[@(UIControlStateNormal)] CGColor];
    } else {
        _radioControl.layer.borderColor = [self.buttonBorderColors[@(UIControlStateDisabled)] CGColor];
    }
}

- (void)setEnabled:(BOOL)isEnabled atOptionIndex:(NSInteger)optionIndex {
    [_radioControl setEnabled:isEnabled forSegmentAtIndex:optionIndex];
}

- (BOOL)isEnabledAtOptionIndex:(NSInteger)optionIndex {
    return [_radioControl isEnabledForSegmentAtIndex:optionIndex];
}

- (void)setOptionTitles:(NSArray<NSString *> *)optionsNameArray {
    if (_radioControl) {
        for (NSString *newOptionName in optionsNameArray) {
            [self addOptionToGroup:newOptionName];
        }
        [self updateUI];
    } else {
        [_titlesArray addObjectsFromArray:optionsNameArray];
    }
}

- (NSInteger)addOptionToGroup:(NSString*)optionName {
    [_titlesArray addObject:optionName];
    if (_radioControl) {
        [_radioControl insertSegmentWithTitle:optionName atIndex:_radioControl.numberOfSegments animated:YES];
    }

    return _titlesArray.count;
}

- (BOOL)setOption:(NSString*)optionName atIndex:(NSInteger)optionIndex {
    if (optionIndex >= _radioControl.numberOfSegments) {
        return NO;
    }
    [_radioControl setTitle:optionName forSegmentAtIndex:optionIndex];
    return YES;
}

- (void)removeOptionFromGroup:(NSInteger)optionIndex {
    [_radioControl removeSegmentAtIndex:optionIndex animated:NO];
}

- (void)radioControlChanged:(UISegmentedControl *)theControl {
    NSInteger oldValue = _selection;
    _selection = theControl.selectedSegmentIndex;
    if (_actionBlock) {
        _actionBlock(oldValue, _selection);
    }
}

- (void)selectedRadioTextColorChanged {
    self.buttonColors[@(UIControlStateSelected)] = [self selectedRadioTextColor];
    [self enableStateChanged];  // Juggle the selection and tint colors using the new color as needed.
}

#pragma mark - UI
- (void)setupUI {
    if (_radioControl != nil) {
        return;
    }
    
    [super setupUI];
    _radioControl = [[UISegmentedControl alloc] initWithItems:_titlesArray];
    _radioControl.translatesAutoresizingMaskIntoConstraints = NO;
    _radioControl.layer.cornerRadius = self.buttonCornerRadius;
    _radioControl.layer.borderColor = [self.buttonBorderColors[@(UIControlStateNormal)] CGColor];
    _radioControl.layer.borderWidth = self.buttonBorderWidth;

    if (@available(iOS 13.0, *)) {
        _radioControl.selectedSegmentTintColor = _selectionTint;
        [self backgroundTintUpdated];
    } else {
        _radioControl.layer.masksToBounds = YES;
        _radioControl.tintColor = _selectionTint;
    }

    [self enableStateChanged]; // The KVO won't have been installed when setupUI is first called. This also calls tintUpdated internally
    
    _radioControl.layer.borderColor = [self.buttonBorderColors[@(UIControlStateNormal)] CGColor];
    _radioControl.layer.borderWidth = self.buttonBorderWidth;
    [self updateButtonTextColors];
    
    [self.view addSubview:_radioControl];

    [_radioControl.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.trailingAnchor].active = YES;
    [_radioControl.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self updateRadioControlLeadingAnchor];
    [_radioControl.heightAnchor constraintEqualToConstant:_radioControl.intrinsicContentSize.height].active = YES;
    
    _radioControl.enabled = _isControlEnabled;
    _radioControl.apportionsSegmentWidthsByContent = YES;
    [_radioControl setSelectedSegmentIndex:_selection];
    [_radioControl addTarget:self action:@selector(radioControlChanged:) forControlEvents:UIControlEventValueChanged];

    [self updateUI];
}

- (void)updateRadioControlLeadingAnchor {
    [_radioControl sizeToFit];
    [_radioControl.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.centerXAnchor].active = YES;
}

- (void)updateUI {
    [super updateUI];
    [self updateRadioControlLeadingAnchor];
}

#pragma mark - Customizations

- (void)tintUpdated {
    if (_baseDividerImage == nil) {
        _baseDividerImage = [[UIImage duxbeta_imageWithAssetNamed:@"VerticalDivider"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    UIColor *workingTintColor = nil;
    if (_radioControl.enabled) {
        workingTintColor = self.buttonBorderColors[@(UIControlStateNormal)];
    } else {
        workingTintColor = self.buttonBorderColors[@(UIControlStateDisabled)];
    }

    _colorizedDividerImage = [UIImage duxbeta_colorizeImage:_baseDividerImage withColor:workingTintColor];
    [_radioControl setDividerImage:_colorizedDividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)enableStateChanged {
    // This routine is to force changes in color for enable/disable states. When the UISegmentControl is disabled, the highlighting goes away.
    // That means the selected text color probably doesn't match the unselected text color. So we have to juggle the selected color state depending
    // on if the control is enabled or not.
    [self tintUpdated];

    if (_radioControl.enabled) {
        [_radioControl setTitleTextAttributes:@{ NSForegroundColorAttributeName:self.buttonColors[@(UIControlStateSelected)] }
                                     forState:UIControlStateSelected];
    } else {
        [_radioControl setTitleTextAttributes:@{ NSForegroundColorAttributeName:self.buttonColors[@(UIControlStateNormal)] }
                                     forState:UIControlStateSelected];
    }
    
    if (@available(iOS 13.0, *)) {
    } else {
        // For pre-iOS 13, remove the selection highlight
        if (_radioControl.enabled) {
            _radioControl.tintColor = _selectionTint;
        } else {
            _radioControl.tintColor = [UIColor clearColor];
        }
    }
}

- (void)backgroundTintUpdated {
    if (@available(iOS 13.0, *)) {
        
        if (_ios13BackgroundImage == nil) {
            [self createBaseiOS13BackgroundImage];
        }
        
        UIImage *normalBackgroundImage = [UIImage duxbeta_colorizeImage:_ios13BackgroundImage withColor:_tabsBackgroundColor];
        UIImage *selectionImage = [UIImage duxbeta_colorizeImage:_ios13BackgroundImage withColor:_selectionTint];
 
        // Must set the background image for normal to something (even clear) or else the others won't work
        [_radioControl setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_radioControl setBackgroundImage:selectionImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    }
}

- (void)createBaseiOS13BackgroundImage {
    if (_ios13BackgroundImage == nil) {
        UIImage *image = [UIImage duxbeta_imageWithAssetNamed:@"RadioControlBackground"];
        CGSize newSize = CGSizeMake(image.size.width, _radioControl.frame.size.height - (2.0 * self.buttonBorderWidth));
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

       _ios13BackgroundImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (void)updateButtonTextColors {
    [_radioControl setTitleTextAttributes:@{ NSForegroundColorAttributeName:self.buttonColors[@(UIControlStateNormal)] }
                                forState:UIControlStateNormal];
    [_radioControl setTitleTextAttributes:@{ NSForegroundColorAttributeName:self.buttonColors[@(UIControlStateSelected)] }
                                 forState:UIControlStateSelected];
    [_radioControl setTitleTextAttributes:@{ NSForegroundColorAttributeName: self.buttonColors[@(UIControlStateDisabled)] }
                                 forState:UIControlStateDisabled];
}

- (void)editingEnableChanged {
    if (_isControlEnabled != _radioControl.enabled) {
        _radioControl.enabled = _isControlEnabled;
    }
}

- (void)setTextColor:(UIColor*)color forState:(UIControlState)state {
    self.buttonColors[@(state)] = color;
    [self updateButtonTextColors];
}


- (void)setTabsBackgroundColor:(UIColor *)color {
    _tabsBackgroundColor = color;
}

#pragma mark - Size Support

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint sizeHint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return sizeHint;
}


@end

#pragma mark - Hooks

@implementation ListItemRadioButtonModelState : ListItemTitleModelState
@end

@implementation ListItemRadioButtonUIState : ListItemTitleUIState
@end
