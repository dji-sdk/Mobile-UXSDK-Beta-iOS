//
//  DUXBetaGPSSignalWidget.m
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

#import "DUXBetaGPSSignalWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
@import DJIUXSDKCore;
#import "DUXBetaStateChangeBroadcaster.h"

// image names used for various strength levels of the signal indicator
static NSString * const kGPSLevel0ImageName = @"SignalLevel0";
static NSString * const kGPSLevel1ImageName = @"SignalLevel1";
static NSString * const kGPSLevel2ImageName = @"SignalLevel2";
static NSString * const kGPSLevel3ImageName = @"SignalLevel3";
static NSString * const kGPSLevel4ImageName = @"SignalLevel4";
static NSString * const kGPSLevel5ImageName = @"SignalLevel5";

// Image name for the icon used to indicate use of internal GPS
static NSString * const kGPSIconImageName = @"GPSSignalIcon";

static CGFloat const kRTKIndicatorFontSize = 30.0;
static CGFloat const kCountFontSize = 30.0;
static CGFloat const kCountLeadingGuideProportionOfIcon = 1.1;
static CGFloat const kRTKIndicatorProportionOfIcon = 0.45;
static CGFloat const kSatelliteCountProportionOfHeight = 0.4;
static CGFloat const kInterItemGapToIconRatio = 0.05;

@interface DUXBetaGPSSignalWidget ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *signalImageView;
@property (nonatomic, strong) UILabel *satelliteCountLabel;
@property (nonatomic, strong) UILabel *rtkIndicatorLabel;
@property (nonatomic) CGSize minWidgetSize;

@property (strong, nonatomic) NSLayoutConstraint *rtkViewWidthConstraint;

@property (strong, nonatomic) NSLayoutConstraint *widgetAspectRatioConstraint;


@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *signalImageMapping;

@end

/**
 * GPSSignalWidgetUIState contains the hooks for UI changes in the widget class DUXBetaGPSSignalWidget.
 * It implements the hook:
 *
 * Key: widgetTap    Type: NSNumber - Sends a boolean YES value as an NSNumber indicating the widget was tapped.
*/
@interface GPSSignalWidgetUIState : DUXBetaStateChangeBaseData

+ (instancetype)widgetTap;

@end

/**
 * GPSSignalWidgetModelState contains the model hooks for the DUXBetaGPSSignalWidget.
 * It implements the hook:
 *
 * Key: productConnected        Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft is connected.
 *
 * Key: gpsSignalQualityUpdate  Type: NSNumber - Sends the new signal quality for GPS connectivity when it changes.
 *
 * Key: satelliteCountUpdate    Type: NSNumber - Sends the count of GPS satellites seen by the aircraft whenever the count changes.
 *
 * Key: isRTKEnabledUpdate      Type: NSNumber - Sends a boolean as an NSNumber indicating if RTK is currently enabled whenever the
 *                                               RTK state changes.
 *
 * Key: isRTKAccurateUpdate     Type: NSNumber - Sends a boolean as an NSNumber indicating that RTK mode is accurate whenever the
 *                                               status changes.
*/
@interface GPSSignalWidgetModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)gpsSignalQualityUpdate:(NSInteger)signalQuality;
+ (instancetype)satelliteCountUpdate:(NSInteger)satelliteCount;
+ (instancetype)isRTKEnabledUpdate:(BOOL)isRTKEnabled;
+ (instancetype)isRTKAccurateUpdate:(BOOL)isRTKAccurate;

@end

@implementation DUXBetaGPSSignalWidget

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
    _signalImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaGPSSatelliteStrengthLevel0)    : [UIImage duxbeta_imageWithAssetNamed:kGPSLevel0ImageName],
        @(DUXBetaGPSSatelliteStrengthLevel1)    : [UIImage duxbeta_imageWithAssetNamed:kGPSLevel1ImageName],
        @(DUXBetaGPSSatelliteStrengthLevel2)    : [UIImage duxbeta_imageWithAssetNamed:kGPSLevel2ImageName],
        @(DUXBetaGPSSatelliteStrengthLevel3)    : [UIImage duxbeta_imageWithAssetNamed:kGPSLevel3ImageName],
        @(DUXBetaGPSSatelliteStrengthLevel4)    : [UIImage duxbeta_imageWithAssetNamed:kGPSLevel4ImageName],
        @(DUXBetaGPSSatelliteStrengthLevel5)    : [UIImage duxbeta_imageWithAssetNamed:kGPSLevel5ImageName],
        @(DUXBetaGPSSatelliteStrengthLevelNone) : [UIImage duxbeta_imageWithAssetNamed:kGPSLevel0ImageName]
    }];
    _widgetIcon = [UIImage duxbeta_imageWithAssetNamed:kGPSIconImageName];
    _satelliteCountNumberFont = [UIFont systemFontOfSize:kCountFontSize];
    _rtkIndicatorFont = [UIFont systemFontOfSize:kRTKIndicatorFontSize];
    _rtkIndicatorTextColorAccurate = [UIColor whiteColor];
    _rtkIndicatorTextColorInaccurate = [UIColor redColor];
    _iconTintColorConnected = [UIColor whiteColor];
    _iconTintColorDisconnected = [UIColor duxbeta_disabledGrayColor];
    _iconBackgroundColor = [UIColor clearColor];
    _signalBackgroundColor = [UIColor clearColor];
    _satelliteCountNumberColor = [UIColor whiteColor];
    _satelliteCountBackgroundColor = [UIColor clearColor];
    _rtkIndicatorBackgroundColor = [UIColor clearColor];
    _widgetBackgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaGPSSignalWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Register for updates from model
    BindRKVOModel(self.widgetModel, @selector(updateRTKUI), isRTKEnabled, isRTKAccurate, isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(updateSignalUI), isRTKEnabled, satelliteSignal, isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(updateCountUI), isRTKEnabled, satelliteCount, isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(updateIconUI), isProductConnected);
    // Send hook updates
    BindRKVOModel(self.widgetModel, @selector(sendIsProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(sendGPSSignalQualityUpdate), satelliteSignal);
    
    // Register for updates from customizations
    BindRKVOModel(self, @selector(updateRTKUI), rtkIndicatorFont, rtkIndicatorTextColorAccurate,
                  rtkIndicatorTextColorInaccurate, rtkIndicatorBackgroundColor);
    BindRKVOModel(self, @selector(updateSignalUI), signalBackgroundColor);
    BindRKVOModel(self, @selector(updateCountUI), satelliteCountBackgroundColor, satelliteCountNumberFont, satelliteCountNumberColor);
    BindRKVOModel(self, @selector(updateIconUI), iconBackgroundColor, iconTintColorConnected,
                  iconTintColorDisconnected, widgetIcon);
    BindRKVOModel(self, @selector(updateWidgetBackground), widgetBackgroundColor);
    
    BindRKVOModel(self.widgetModel, @selector(sendIsProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(sendGPSSignalQualityUpdate), satelliteSignal);
    BindRKVOModel(self.widgetModel, @selector(sendSatelliteCountUpdate), satelliteCount);
    BindRKVOModel(self.widgetModel, @selector(sendRTKEnabledUpdate), isRTKEnabled);
    BindRKVOModel(self.widgetModel, @selector(sendRTKAccurateUpdate), isRTKAccurate);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    // setup GPS image view
    self.iconImageView = [[UIImageView alloc] initWithImage:self.widgetIcon];
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.iconImageView];

    // setup signal indicator image view using appropriate image
    self.signalImageView = [[UIImageView alloc] initWithImage:[self currentSignalIndicatorImage]];
    self.signalImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.signalImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.signalImageView];

    // setup satellite count label
    self.satelliteCountLabel = [[UILabel alloc] init];
    self.satelliteCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.satelliteCountLabel.textColor = [UIColor whiteColor];
    self.satelliteCountLabel.textAlignment = NSTextAlignmentCenter;
    self.satelliteCountLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.satelliteCountLabel];
    
    // Setup RTK Indicator Label
    self.rtkIndicatorLabel = [UILabel new];
    self.rtkIndicatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rtkIndicatorLabel.text = @"R";
    self.rtkIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.rtkIndicatorLabel];
    
    [self.view sendSubviewToBack:self.signalImageView];
    [self.view bringSubviewToFront:self.satelliteCountLabel];
    [self.view bringSubviewToFront:self.rtkIndicatorLabel];

    [self setupConstraints];
    [self updateSignalUI];
    [self updateCountUI];
    [self updateRTKUI];
    [self updateIconUI];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(widgetTapped)];
    [self.view addGestureRecognizer:singleTap];
    
    //Set aspect ratio constraint after widget size has been determined in setup
    self.widgetAspectRatioConstraint = [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:[self widgetSizeHint].preferredAspectRatio];
    self.widgetAspectRatioConstraint.active = YES;
}

- (void)widgetTapped {
    [[DUXBetaStateChangeBroadcaster instance] send:[GPSSignalWidgetUIState widgetTap]];
}

- (void)sendIsProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[GPSSignalWidgetModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendGPSSignalQualityUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[GPSSignalWidgetModelState gpsSignalQualityUpdate:self.widgetModel.satelliteSignal]];
}

- (void)sendSatelliteCountUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[GPSSignalWidgetModelState satelliteCountUpdate:self.widgetModel.satelliteCount]];
}

- (void)sendRTKEnabledUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[GPSSignalWidgetModelState isRTKEnabledUpdate:self.widgetModel.isRTKEnabled]];
}

- (void)sendRTKAccurateUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[GPSSignalWidgetModelState isRTKAccurateUpdate:self.widgetModel.isRTKAccurate]];
}

- (void)updateWidgetBackground {
    self.view.backgroundColor = self.widgetBackgroundColor;
}

- (void)updateRTKUI {
    self.rtkIndicatorLabel.backgroundColor = self.rtkIndicatorBackgroundColor;
    
    if (self.widgetModel.isRTKAccurate) {
        self.rtkIndicatorLabel.textColor = self.rtkIndicatorTextColorAccurate;
    } else {
        self.rtkIndicatorLabel.textColor = self.rtkIndicatorTextColorInaccurate;
    }
    
    CGFloat fontSize = self.rtkIndicatorFont.pointSize * (self.view.frame.size.height / self.minWidgetSize.height);
    self.rtkIndicatorLabel.font = [self.rtkIndicatorFont fontWithSize:fontSize];
    
    if (self.widgetModel.isRTKEnabled && self.widgetModel.isProductConnected) {
        self.rtkIndicatorLabel.hidden = NO;
        self.rtkViewWidthConstraint.active = YES;

    } else {
        self.rtkIndicatorLabel.hidden = YES;
        self.rtkViewWidthConstraint.active = NO;
    }
    [self updateMinImageDimensions];
    self.widgetAspectRatioConstraint = [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:self.widgetSizeHint.preferredAspectRatio];
}

- (void)updateSignalUI {
    self.signalImageView.backgroundColor = self.signalBackgroundColor;
    if (!self.widgetModel.isProductConnected) {
        self.signalImageView.image = self.signalImageMapping[@(DUXBetaGPSSatelliteStrengthLevel0)];
    } else if (self.widgetModel.isRTKEnabled && self.widgetModel.isRTKAccurate) {
        self.signalImageView.image = self.signalImageMapping[@(DUXBetaGPSSatelliteStrengthLevel5)];
    } else {
        self.signalImageView.image = [self currentSignalIndicatorImage];
    }
    [self updateMinImageDimensions];
}

- (void)updateCountUI {
    self.satelliteCountLabel.backgroundColor = self.satelliteCountBackgroundColor;
    self.satelliteCountLabel.textColor = self.satelliteCountNumberColor;
    self.satelliteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.widgetModel.satelliteCount];
    CGFloat pointSize = self.satelliteCountNumberFont.pointSize * (self.view.frame.size.height / self.minWidgetSize.height);
    self.satelliteCountLabel.font = [self.satelliteCountNumberFont fontWithSize:pointSize];
    
    if (self.widgetModel.isProductConnected) {
        [self.satelliteCountLabel setHidden:NO];
    } else {
        [self.satelliteCountLabel setHidden:YES];
    }
}

- (void)updateIconUI {
    self.iconImageView.backgroundColor = self.iconBackgroundColor;
    self.iconImageView.image = [self.widgetIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if (self.widgetModel.isProductConnected) {
        [self.iconImageView setTintColor:self.iconTintColorConnected];
    } else {
        [self.iconImageView setTintColor:self.iconTintColorDisconnected];
    }
    [self updateMinImageDimensions];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateRTKUI];
    [self updateSignalUI];
    [self updateCountUI];
    [self updateIconUI];
}

- (void)setupConstraints {
    CGFloat iconAspectRatio = self.iconImageView.image.size.width / self.iconImageView.image.size.height;
    
    [self.iconImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.iconImageView.widthAnchor constraintEqualToAnchor:self.iconImageView.heightAnchor multiplier:iconAspectRatio].active = YES;
    [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.iconImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    UILayoutGuide *iconSignalGap = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:iconSignalGap];
    [iconSignalGap.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor].active = YES;
    [iconSignalGap.widthAnchor constraintEqualToAnchor:self.iconImageView.widthAnchor multiplier:kInterItemGapToIconRatio].active = YES;
    
    CGFloat signalAspectRatio = self.signalImageView.image.size.width / self.signalImageView.image.size.height;
    
    [self.signalImageView.widthAnchor constraintEqualToAnchor:self.signalImageView.heightAnchor multiplier:signalAspectRatio].active = YES;
    [self.signalImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.signalImageView.leadingAnchor constraintEqualToAnchor:iconSignalGap.trailingAnchor].active = YES;
    [self.signalImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    UILayoutGuide *signalRTKGap = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:signalRTKGap];
    [signalRTKGap.leadingAnchor constraintEqualToAnchor:self.signalImageView.trailingAnchor].active = YES;
    [signalRTKGap.widthAnchor constraintEqualToAnchor:self.iconImageView.widthAnchor multiplier:kInterItemGapToIconRatio].active = YES;

    [self.rtkIndicatorLabel.leadingAnchor constraintEqualToAnchor:signalRTKGap.trailingAnchor].active = YES;
    self.rtkViewWidthConstraint = [self.rtkIndicatorLabel.widthAnchor constraintEqualToAnchor:self.iconImageView.widthAnchor multiplier:kRTKIndicatorProportionOfIcon];
    self.rtkViewWidthConstraint.active = YES;
    
    [self.rtkIndicatorLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.rtkIndicatorLabel.topAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    UILayoutGuide *satelliteCountHorizontalOffset = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:satelliteCountHorizontalOffset];
    [satelliteCountHorizontalOffset.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [satelliteCountHorizontalOffset.widthAnchor constraintEqualToAnchor:self.iconImageView.widthAnchor multiplier:kCountLeadingGuideProportionOfIcon].active = YES;

    [self.satelliteCountLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.satelliteCountLabel.centerXAnchor constraintEqualToAnchor:satelliteCountHorizontalOffset.trailingAnchor].active = YES;
    [self.satelliteCountLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:kSatelliteCountProportionOfHeight].active = YES;
}

- (UIImage *)currentSignalIndicatorImage {
    return [self.signalImageMapping objectForKey:@(self.widgetModel.satelliteSignal)];
}

- (UIImage *)imageForSatelliteStrength:(DUXBetaGPSSatelliteStrength)satelliteStrength {
    return [self.signalImageMapping objectForKey:@(satelliteStrength)];
}

- (void)setImage:(UIImage *)image forSatelliteStrength:(DUXBetaGPSSatelliteStrength)satelliteStrength {
    [self.signalImageMapping setObject:image forKey:@(satelliteStrength)];
    [self updateSignalUI];
}

- (void)updateMinImageDimensions {
    CGSize signalContainerSize = [self maxSizeInImageArray:[self.signalImageMapping allValues]];
    
    // Widget shrinks when RTK enabled indicator is hidden.
    float rtkWidthProportionOfIcon = self.widgetModel.isRTKEnabled ? kRTKIndicatorProportionOfIcon : 0;
    
    // width = iconWidth + interItemWidth + signalWidth + interItemWidth + rtkWidth
    CGFloat widgetWidth = (self.widgetIcon.size.width * (1 + rtkWidthProportionOfIcon + (2 * kInterItemGapToIconRatio))) + signalContainerSize.width;
    
    _minWidgetSize = CGSizeMake(widgetWidth, MAX(self.widgetIcon.size.height, signalContainerSize.height));
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return hint;
}

@end

@implementation GPSSignalWidgetUIState

+ (instancetype)widgetTap {
    return [[GPSSignalWidgetUIState alloc] initWithKey:@"widgetTap" number:@(0)];
}

@end

@implementation GPSSignalWidgetModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[GPSSignalWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)gpsSignalQualityUpdate:(NSInteger)signalQuality {
    return [[GPSSignalWidgetModelState alloc] initWithKey:@"gpsSignalQualityUpdate" number:@(signalQuality)];
}

+ (instancetype)satelliteCountUpdate:(NSInteger)satelliteCount {
    return [[GPSSignalWidgetModelState alloc] initWithKey:@"satelliteCountUpdate" number:@(satelliteCount)];
}

+ (instancetype)isRTKEnabledUpdate:(BOOL)isRTKEnabled {
    return [[GPSSignalWidgetModelState alloc] initWithKey:@"isRTKEnabledUpdate" number:@(isRTKEnabled)];
}

+ (instancetype)isRTKAccurateUpdate:(BOOL)isRTKAccurate {
    return [[GPSSignalWidgetModelState alloc] initWithKey:@"isRTKAccurateUpdate" number:@(isRTKAccurate)];
}

@end
