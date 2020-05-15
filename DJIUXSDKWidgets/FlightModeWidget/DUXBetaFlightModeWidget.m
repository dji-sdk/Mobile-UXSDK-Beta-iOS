//
//  DUXBetaFlightModeWidget.m
//  DJIUXSDK
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

#import "DUXBetaFlightModeWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
#import "UIColor+DUXBetaColors.h"
#import "DUXStateChangeBroadcaster.h"
@import DJIUXSDKCore;

static const CGFloat kDesignFontSize = 70.0;
static const CGFloat kInterItemGap = 5.0;
static const CGFloat kMissingLabelWidth = 50.0;

static const CGFloat kGapToWidgetWidthRatio = 0.04;

static NSString const *kLongestPossibleFlightMode = @"TerrainFollowing";

@interface DUXBetaFlightModeWidget ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *labelString;
@property (nonatomic, strong) UILabel *flightModeLabel;

@property (nonatomic) CGSize minWidgetSize;
@property (nonatomic, strong) NSLayoutConstraint *labelWidthConstraint;

@end

/**
 * FlightModeWidgetModelState contains the model hooks for the DUXFlightModeWidget.
 * It implements the hooks:
 *
 * Key: productConnected        Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft is connected.
 *
 * Key: flightModeTextUpdate:   Type: NSString - Sends the flight mode string whenever is is updated.
*/
@interface FlightModeWidgetModelState : DUXStateChangeBaseData
+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)flightModeTextUpdate:(NSString *)flightModeText;
@end

@implementation DUXBetaFlightModeWidget

/*********************************************************************************/
#pragma mark - Initializer
/*********************************************************************************/

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInstanceVariables];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupInstanceVariables];
    }
    return self;
}

- (void)setupInstanceVariables {
    UIImage *initialImage = [UIImage duxbeta_imageWithAssetNamed:@"FlyingMode"];
    _iconImage = [initialImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _labelTextColorConnected = [UIColor duxbeta_whiteColor];
    _labelTextColorDisconnected = [UIColor duxbeta_disabledGrayColor];
    _overallBackgroundColor = [UIColor clearColor];
    _labelBackgroundColor = [UIColor clearColor];
    _iconBackgroundColor = [UIColor clearColor];
    _iconTintColorConnected = [UIColor duxbeta_whiteColor];
    _iconTintColorDisconnected = [UIColor duxbeta_disabledGrayColor];
    _labelFont = [UIFont systemFontOfSize:kDesignFontSize];
    _hasFixedWidth = NO;
    
    [self updateMinWidgetSize];
}

/*********************************************************************************/
#pragma mark - View Lifecycle Methods
/*********************************************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaFlightModeWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(sendFlightModeString), flightModeString);
    BindRKVOModel(self.widgetModel, @selector(sendIsProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(updateUI), flightModeString, isProductConnected);
    BindRKVOModel(self, @selector(updateUI),
                  overallBackgroundColor,
                  labelTextColorConnected,
                  labelTextColorDisconnected,
                  labelBackgroundColor,
                  iconTintColorConnected,
                  iconTintColorDisconnected,
                  iconBackgroundColor,
                  iconImage,
                  labelFont);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

/*********************************************************************************/
#pragma mark - Widget UI Setup And Update Methods
/*********************************************************************************/

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)setupUI {
    self.imageView = [[UIImageView alloc] initWithImage:self.iconImage];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.imageView];
    CGFloat imageAspectRatio = self.iconImage.size.width / self.iconImage.size.height;

    [self.imageView.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageAspectRatio].active = YES;
    [self.imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    
    self.flightModeLabel = [UILabel new];
    self.flightModeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.flightModeLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.flightModeLabel];
    
    UILayoutGuide *iconLabelGap = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:iconLabelGap];
    [iconLabelGap.leadingAnchor constraintEqualToAnchor:self.imageView.trailingAnchor].active = YES;
    [iconLabelGap.widthAnchor constraintEqualToAnchor:self.imageView.widthAnchor multiplier:kGapToWidgetWidthRatio].active = YES;
    
    [self.flightModeLabel.leadingAnchor constraintEqualToAnchor:iconLabelGap.trailingAnchor].active = YES;
    [self.flightModeLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.flightModeLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    
    UILayoutGuide *labelTrailingGap = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:labelTrailingGap];
    [labelTrailingGap.leadingAnchor constraintEqualToAnchor:self.flightModeLabel.trailingAnchor].active = YES;
    [labelTrailingGap.widthAnchor constraintEqualToAnchor:self.imageView.widthAnchor multiplier:kGapToWidgetWidthRatio].active = YES;
    [labelTrailingGap.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

    [self.view layoutIfNeeded];
    [self updateMinWidgetSize];
    [self updateUI];
}

- (void)updateUI {
    self.labelString = self.widgetModel.flightModeString;
    self.imageView.image = self.iconImage;
    self.view.backgroundColor = self.overallBackgroundColor;

    CGFloat pointSize = self.labelFont.pointSize * (self.flightModeLabel.frame.size.height / self.widgetSizeHint.minimumHeight);
    self.flightModeLabel.font = [self.labelFont fontWithSize:pointSize];
    
    self.flightModeLabel.text = self.widgetModel.flightModeString;

    self.labelWidthConstraint.active = NO;
    
    if (self.hasFixedWidth) {
        CGRect sizeOfLargestFlightModeString = [kLongestPossibleFlightMode boundingRectWithSize:CGSizeMake(0,0)
                                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                                     attributes:@{NSFontAttributeName : [self.labelFont fontWithSize:pointSize]}
                                                                                        context:nil];
        
        self.labelWidthConstraint = [self.flightModeLabel.widthAnchor constraintEqualToConstant:(sizeOfLargestFlightModeString.size.width + 1)];
        self.labelWidthConstraint.active = YES;
    }
    
    self.flightModeLabel.backgroundColor = self.labelBackgroundColor;
    self.imageView.backgroundColor = self.iconBackgroundColor;
    
    if (self.widgetModel.isProductConnected) {
        self.imageView.tintColor = self.iconTintColorConnected;
        self.flightModeLabel.textColor = self.labelTextColorConnected;
    } else {
        self.imageView.tintColor = self.iconTintColorDisconnected;
        self.flightModeLabel.textColor = self.labelTextColorDisconnected;
    }
}

- (void)sendIsProductConnected {
    [[DUXStateChangeBroadcaster instance] send:[FlightModeWidgetModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendFlightModeString {
    [[DUXStateChangeBroadcaster instance] send:[FlightModeWidgetModelState flightModeTextUpdate:self.widgetModel.flightModeString]];
}

- (void)updateMinWidgetSize {
    NSAssert(self.iconImage != nil, @"Must have an icon image");
    
    CGSize tempSize = {CGFLOAT_MIN, CGFLOAT_MIN};
    if (self.iconImage) {
        if (tempSize.width < _iconImage.size.width) {
            tempSize.width = _iconImage.size.width;
        }
        if (tempSize.height < _iconImage.size.height) {
            tempSize.height = _iconImage.size.height;
        }
    }
    
    if (self.flightModeLabel) {
        tempSize.width += kInterItemGap;
        tempSize.width += self.flightModeLabel.frame.size.width;
        if (tempSize.height < self.flightModeLabel.frame.size.height) {
            tempSize.height += self.flightModeLabel.frame.size.height;
        }
    } else {
        // No label. Make a default width of 50
        tempSize.width += kMissingLabelWidth;
    }
    
    _minWidgetSize = tempSize;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {_minWidgetSize.width / _minWidgetSize.height, _minWidgetSize.width, _minWidgetSize.height};
    return hint;
}

@end

@implementation FlightModeWidgetModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[FlightModeWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)flightModeTextUpdate:(NSString *)flightModeText {
    return [[FlightModeWidgetModelState alloc] initWithKey:@"flightModeStringUpdate" string:flightModeText];
}

@end
