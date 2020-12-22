//
//  DUXBetaVideoSignalWidget.m
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

#import "DUXBetaVideoSignalWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIColor+DUXBetaColors.h"
#import "DUXBetaStateChangeBroadcaster.h"

static NSString * const kVideoFeedLevel0ImageName = @"SignalLevel0";
static NSString * const kVideoFeedLevel1ImageName = @"SignalLevel1";
static NSString * const kVideoFeedLevel2ImageName = @"SignalLevel2";
static NSString * const kVideoFeedLevel3ImageName = @"SignalLevel3";
static NSString * const kVideoFeedLevel4ImageName = @"SignalLevel4";
static NSString * const kVideoFeedLevel5ImageName = @"SignalLevel5";
static NSString * const kRemoteIconImageName = @"VideoSignal";

static const CGFloat kFrequencyBandToWidgetWidthRatio = 0.41;
static const CGFloat kFrequencyBandToWidgetHeightRatio = 0.33;
static const CGFloat kFrequencyBandFontSize = 30.0;

@interface DUXBetaVideoSignalWidget ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *signalImageView;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *signalImageMapping;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *iconImageMapping;
@property (nonatomic, strong) UILabel *frequencyBandLabel;
@property (nonatomic) CGSize minWidgetSize;
@property (nonatomic) NSString *frequencyBandText;
@property (nonatomic, strong) NSDictionary *lightbridgeBandToText;
@property (nonatomic, strong) NSDictionary *ocusyncBandToText;
@property (nonatomic, strong) NSDictionary *wifiBandToText;

@property (nonatomic) DUXBetaAirLinkType currentAirLinkType;

@end

/**
 * DUXBetaVideoSignalModelState contains the model hooks for the DUXBetaVideoSignalWidget.
 * It implements the hooks:
 *
 * Key: productConnected                Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft
 *                                                       is connected.
 *
 * Key: videoSignalQualityUpdate        Type: NSNumber - Sends the DUXBetaVideoSignalStrength as an NSNumber whenever the
 *                                                       video signal quality changes.
 *
 * Key: lightbridgeFrequncyBandUpdae    Type: NSNumber - Sends the DJILightbridgeFrequencyBand enum value as an NSNumber whenever
 *                                                       the frequency band changes when using a Lightbridge connected aircraft.
 *
 * Key: wififFrequencyBandUpdate        Type: NSNumber - Sends the DJIWiFiFrequencyBand enum value as an NSNumber whenever
 *                                                       the frequency band changes when using a WiFi connected aircraft.
 *
 * Key: ocusyncFrequencyBandUpdate      Type: NSNumber - Sends the DJIOcuSyncFrequencyBand enum value as an NSNumber whenever
 *                                                       the frequency band changes when using an OcuSync connected aircraft.
*/
@interface DUXBetaVideoSignalModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)videoSignalQualityUpdate:(DUXBetaVideoSignalStrength)videoSignalQuality;
+ (instancetype)lightbridgeFrequencyBandUpdate:(DJILightbridgeFrequencyBand)frequencyBand;
+ (instancetype)wifiFrequencyBandUpdate:(DJIWiFiFrequencyBand)frequencyBand;
+ (instancetype)ocusyncFrequencyBandUpdate:(DJIOcuSyncFrequencyBand)frequencyBand;

@end

@implementation DUXBetaVideoSignalWidget

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
    _widgetBackgroundColor = [UIColor clearColor];
    _barsBackgroundColor = [UIColor clearColor];
    _iconBackgroundColor = [UIColor clearColor];
    _frequencyBandBackgroundColor = [UIColor clearColor];
    _frequencyBandFont = [UIFont systemFontOfSize:kFrequencyBandFontSize];
    _frequencyBandTextColor = [UIColor whiteColor];
    _iconTintColorConnected = [UIColor uxsdk_whiteColor];
    _iconTintColorDisconnected = [UIColor uxsdk_disabledGrayWhite58];
    _currentAirLinkType = DUXBetaAirLinkTypeUnknown;
    
    UIImage *hdIcon = [UIImage duxbeta_imageWithAssetNamed:kRemoteIconImageName];
    _iconImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaAirLinkTypeLightbridge) : [hdIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
        @(DUXBetaAirLinkTypeOcuSync)     : [hdIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
        @(DUXBetaAirLinkTypeWiFi)        : [hdIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
        @(DUXBetaAirLinkTypeUnknown)     : [hdIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
    }];
                                    
    _signalImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaVideoSignalStrengthLevel0) : [UIImage duxbeta_imageWithAssetNamed:kVideoFeedLevel0ImageName],
        @(DUXBetaVideoSignalStrengthLevel1) : [UIImage duxbeta_imageWithAssetNamed:kVideoFeedLevel1ImageName],
        @(DUXBetaVideoSignalStrengthLevel2) : [UIImage duxbeta_imageWithAssetNamed:kVideoFeedLevel2ImageName],
        @(DUXBetaVideoSignalStrengthLevel3) : [UIImage duxbeta_imageWithAssetNamed:kVideoFeedLevel3ImageName],
        @(DUXBetaVideoSignalStrengthLevel4) : [UIImage duxbeta_imageWithAssetNamed:kVideoFeedLevel4ImageName],
        @(DUXBetaVideoSignalStrengthLevel5) : [UIImage duxbeta_imageWithAssetNamed:kVideoFeedLevel5ImageName]
    }];
    
    _lightbridgeBandToText = @{
        @(DJILightbridgeFrequencyBandUnknown) : @"",
        @(DJILightbridgeFrequencyBand2Dot4GHz) : @"2.4G",
        @(DJILightbridgeFrequencyBand5Dot7GHz) : @"5.7G",
        @(DJILightbridgeFrequencyBand5Dot8GHz) : @"5.8G"
    };
    
    _ocusyncBandToText = @{
        @(DJIOcuSyncFrequencyBandUnknown) : @"",
        @(DJIOcuSyncFrequencyBandDual) : @"",
        @(DJIOcuSyncFrequencyBand2Dot4GHz) : @"2.4G",
        @(DJIOcuSyncFrequencyBand5Dot8GHz) : @"5.8G"
    };
    
    _wifiBandToText = @{
        @(DJIWiFiFrequencyBandUnknown) : @"",
        @(DJIWiFiFrequencyBandDual) : @"",
        @(DJIWiFiFrequencyBand2Dot4GHz) : @"2.4G",
        @(DJIWiFiFrequencyBand5GHz) : @"5.0G"
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaVideoSignalWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), barsLevel, isProductConnected);

    BindRKVOModel(self, @selector(updateUI), frequencyBandBackgroundColor,
                                                frequencyBandFont,
                                                frequencyBandTextColor,
                                                widgetBackgroundColor,
                                                barsBackgroundColor,
                                                iconBackgroundColor,
                                                iconTintColorConnected,
                                                iconTintColorDisconnected);
    
    // Widget Model Hooks
    BindRKVOModel(self.widgetModel, @selector(sendProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(sendVideoSignalQualityUpdate), barsLevel);
    BindRKVOModel(self.widgetModel, @selector(handleFrequencyBandUpdateLightbridge), lightBridgeFrequencyBand);
    BindRKVOModel(self.widgetModel, @selector(handleFrequencyBandUpdateWiFi), wifiFrequencyBand);
    BindRKVOModel(self.widgetModel, @selector(handleFrequencyBandUpdateOcuSync), ocuSyncFrequencyBand);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    // iconImageView
    UIImage *iconImage = [self.iconImageMapping objectForKey:@(self.currentAirLinkType)];
    self.iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.iconImageView];
    
    CGFloat iconAspectRatio = self.iconImageView.image.size.width / self.iconImageView.image.size.height;
    
    [self.iconImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.iconImageView.widthAnchor constraintEqualToAnchor:self.iconImageView.heightAnchor multiplier:iconAspectRatio].active = YES;
    [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.iconImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    // signalImageView
    self.signalImageView = [[UIImageView alloc] initWithImage:[self imageForSignalStrength:self.widgetModel.barsLevel]];
    self.signalImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.signalImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.signalImageView];
    
    CGFloat signalAspectRatio = self.signalImageView.image.size.width / self.signalImageView.image.size.height;
    
    [self.signalImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.signalImageView.widthAnchor constraintEqualToAnchor:self.signalImageView.heightAnchor multiplier:signalAspectRatio].active = YES;
    [self.signalImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.signalImageView.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor].active = YES;
    [self.signalImageView.bottomAnchor constraintEqualToAnchor:self.iconImageView.bottomAnchor].active = YES;
    
    // frequencyBandLabel
    self.frequencyBandLabel = [UILabel new];
    self.frequencyBandLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.frequencyBandLabel.text = @"";
    self.frequencyBandLabel.textColor = self.frequencyBandTextColor;
    [self.view addSubview:self.frequencyBandLabel];
    
    [self.frequencyBandLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.frequencyBandLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:kFrequencyBandToWidgetHeightRatio].active = YES;
    [self.frequencyBandLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor].active = YES;
    [self.frequencyBandLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:kFrequencyBandToWidgetWidthRatio].active = YES;
    
    [self updateMinImageDimensions];
    [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:[self widgetSizeHint].preferredAspectRatio].active = YES;
    
    [self updateUI];
}

// Widget Model Hooks

- (void)sendProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaVideoSignalModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendVideoSignalQualityUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaVideoSignalModelState videoSignalQualityUpdate:self.widgetModel.barsLevel]];
}

- (void)handleFrequencyBandUpdateLightbridge {
    self.frequencyBandLabel.text = self.lightbridgeBandToText[@(self.widgetModel.lightBridgeFrequencyBand)];
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaVideoSignalModelState lightbridgeFrequencyBandUpdate:self.widgetModel.lightBridgeFrequencyBand]];
    self.currentAirLinkType = DUXBetaAirLinkTypeLightbridge;
}

- (void)handleFrequencyBandUpdateOcuSync {
    self.frequencyBandLabel.text = self.ocusyncBandToText[@(self.widgetModel.ocuSyncFrequencyBand)];
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaVideoSignalModelState ocusyncFrequencyBandUpdate:self.widgetModel.ocuSyncFrequencyBand]];
    self.currentAirLinkType = DUXBetaAirLinkTypeOcuSync;
}

- (void)handleFrequencyBandUpdateWiFi {
    self.frequencyBandLabel.text = self.wifiBandToText[@(self.widgetModel.wifiFrequencyBand)];
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaVideoSignalModelState wifiFrequencyBandUpdate:self.widgetModel.wifiFrequencyBand]];
    self.currentAirLinkType = DUXBetaAirLinkTypeWiFi;
}

- (void)updateUI {
    CGFloat fontSize = self.frequencyBandFont.pointSize * (self.view.frame.size.height / self.minWidgetSize.height);
    self.frequencyBandLabel.font = [self.frequencyBandFont fontWithSize:fontSize];
    self.frequencyBandLabel.textColor = self.frequencyBandTextColor;
    self.view.backgroundColor = self.widgetBackgroundColor;
    self.frequencyBandLabel.backgroundColor = self.frequencyBandBackgroundColor;
    self.iconImageView.backgroundColor = self.iconBackgroundColor;
    self.signalImageView.backgroundColor = self.barsBackgroundColor;
    self.iconImageView.image = [self.iconImageMapping objectForKey:@(self.currentAirLinkType)];
    
    if (self.widgetModel.isProductConnected) {
        self.frequencyBandLabel.hidden = NO;
        self.signalImageView.image = self.signalImageMapping[@(self.widgetModel.barsLevel)];
        self.iconImageView.tintColor = self.iconTintColorConnected;
    } else {
        self.frequencyBandLabel.hidden = YES;
        self.signalImageView.image = self.signalImageMapping[@(DUXBetaVideoSignalStrengthLevel0)];
        self.iconImageView.tintColor = self.iconTintColorDisconnected;
    }
}

- (void)setBarsImage:(UIImage *)image forVideoSignalStrength:(DUXBetaVideoSignalStrength)level {
    [self.signalImageMapping setObject:image forKey:@(level)];
    [self updateUI];
}

- (UIImage *)imageForSignalStrength:(DUXBetaVideoSignalStrength)level {
    return self.signalImageMapping[@(level)];
}

- (void)setIconImage:(UIImage *)image forAirLinkType:(DUXBetaAirLinkType)airLinkType {
    [self.iconImageMapping setObject:image forKey:@(airLinkType)];
    [self updateUI];
}

- (UIImage *)imageForAirLinkType:(DUXBetaAirLinkType)airLinkType {
    return [self.iconImageMapping objectForKey:@(airLinkType)];
}

- (void)updateMinImageDimensions {
    CGSize iconContainingSize = [self maxSizeInImageArray:[self.iconImageMapping allValues]];
    CGSize signalContainingSize = [self maxSizeInImageArray:[self.signalImageMapping allValues]];

    CGFloat widgetWidth = iconContainingSize.width + signalContainingSize.width;

    _minWidgetSize = CGSizeMake(widgetWidth, MAX(iconContainingSize.height, signalContainingSize.height));
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return hint;
}

@end

@implementation DUXBetaVideoSignalModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[DUXBetaVideoSignalModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)videoSignalQualityUpdate:(DUXBetaVideoSignalStrength)videoSignalQuality {
    return [[DUXBetaVideoSignalModelState alloc] initWithKey:@"videoSignalQualityUpdate" number:@(videoSignalQuality)];
}

+ (instancetype)lightbridgeFrequencyBandUpdate:(DJILightbridgeFrequencyBand)frequencyBand {
    return [[DUXBetaVideoSignalModelState alloc] initWithKey:@"lightbridgeFrequencyBandUpdate" number:@(frequencyBand)];
}

+ (instancetype)wifiFrequencyBandUpdate:(DJIWiFiFrequencyBand)frequencyBand {
    return [[DUXBetaVideoSignalModelState alloc] initWithKey:@"wifiFrequencyBandUpdate" number:@(frequencyBand)];
}

+ (instancetype)ocusyncFrequencyBandUpdate:(DJIOcuSyncFrequencyBand)frequencyBand {
    return [[DUXBetaVideoSignalModelState alloc] initWithKey:@"ocusyncFrequencyBandUpdate" number:@(frequencyBand)];
}

@end
