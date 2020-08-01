//
//  DUXBetaRemoteControllerSignalWidget.m
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

#import "DUXBetaRemoteControllerSignalWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
#import "UIColor+DUXBetaColors.h"
#import "DUXBetaStateChangeBroadcaster.h"

@import DJIUXSDKCore;

// image names used for various strength levels of the signal indicator
static NSString * const kRemoteLevel0ImageName = @"SignalLevel0";
static NSString * const kRemoteLevel1ImageName = @"SignalLevel1";
static NSString * const kRemoteLevel2ImageName = @"SignalLevel2";
static NSString * const kRemoteLevel3ImageName = @"SignalLevel3";
static NSString * const kRemoteLevel4ImageName = @"SignalLevel4";
static NSString * const kRemoteLevel5ImageName = @"SignalLevel5";

static NSString * const kRemoteIconImageName = @"RemoteControllerIcon";

@interface DUXBetaRemoteControllerSignalWidget ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *signalImageView;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *signalImageMapping;
@property (nonatomic) CGSize minWidgetSize;

@end

/**
 * RemoteControllerSignalWidgetModelState contains the model hooks for the DUXBetaRemoteControllerSignalWidget.
 * It implements the hooks:
 *
 * Key: productConnected                    Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft
 *                                                           is connected.
 *
 * Key: remoteControlSignalQualityUpdate    Type: NSNumber - Sends changes in the remote controller signal controller as an NSNumber
*/
@interface RemoteControllerSignalWidgetModelState : DUXBetaStateChangeBaseData
+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)remoteControllerSignalQualityUpdate:(NSInteger)signalQuality;
@end

@implementation DUXBetaRemoteControllerSignalWidget

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
        @(DUXBetaRemoteSignalBarsLevel0) : [UIImage duxbeta_imageWithAssetNamed:kRemoteLevel0ImageName],
        @(DUXBetaRemoteSignalBarsLevel1) : [UIImage duxbeta_imageWithAssetNamed:kRemoteLevel1ImageName],
        @(DUXBetaRemoteSignalBarsLevel2) : [UIImage duxbeta_imageWithAssetNamed:kRemoteLevel2ImageName],
        @(DUXBetaRemoteSignalBarsLevel3) : [UIImage duxbeta_imageWithAssetNamed:kRemoteLevel3ImageName],
        @(DUXBetaRemoteSignalBarsLevel4) : [UIImage duxbeta_imageWithAssetNamed:kRemoteLevel4ImageName],
        @(DUXBetaRemoteSignalBarsLevel5) : [UIImage duxbeta_imageWithAssetNamed:kRemoteLevel5ImageName]
    }];
    _remoteControllerWidgetIcon = [[UIImage duxbeta_imageWithAssetNamed:kRemoteIconImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _connectedTintColor = [UIColor duxbeta_whiteColor];
    _disconnectedTintColor = [UIColor duxbeta_disabledGrayColor];
    [self updateMinImageDimensions];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaRemoteControllerSignalWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), barsLevel, isProductConnected);
    BindRKVOModel(self, @selector(updateUI), connectedTintColor, disconnectedTintColor, remoteControllerWidgetIcon);
    
    // Send hook updates
    BindRKVOModel(self.widgetModel, @selector(sendIsProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(sendRCSignalQualityUpdate), barsLevel);
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
    // Setup RC image view
    self.iconImageView = [[UIImageView alloc] initWithImage:self.remoteControllerWidgetIcon];
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.iconImageView];
    
    CGFloat iconAspectRatio = self.iconImageView.image.size.width / self.iconImageView.image.size.height;
    
    [self.iconImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.iconImageView.widthAnchor constraintEqualToAnchor:self.iconImageView.heightAnchor multiplier:iconAspectRatio].active = YES;
    [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.iconImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    // Setup signal indicator image view using current signal image
    self.signalImageView = [[UIImageView alloc] initWithImage:[self currentSignalIndicatorImage]];
    self.signalImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.signalImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.signalImageView];
    
    CGFloat signalAspectRatio = self.signalImageView.image.size.width / self.signalImageView.image.size.height;

    [self.signalImageView.widthAnchor constraintEqualToAnchor:self.signalImageView.heightAnchor multiplier:signalAspectRatio].active = YES;
    [self.signalImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.signalImageView.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor].active = YES;
    [self.signalImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.signalImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self.view layoutIfNeeded];
    [self updateMinImageDimensions];
    [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:[self widgetSizeHint].preferredAspectRatio].active = YES;
}

// Model Hooks 
- (void)sendIsProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[RemoteControllerSignalWidgetModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendRCSignalQualityUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[RemoteControllerSignalWidgetModelState remoteControllerSignalQualityUpdate:self.widgetModel.barsLevel]];
}

- (UIImage *)currentSignalIndicatorImage {
    return [self.signalImageMapping objectForKey:@(self.widgetModel.barsLevel)];
}

- (void)updateUI {
    self.iconImageView.image = self.remoteControllerWidgetIcon;
    if (self.widgetModel.isProductConnected) {
        self.signalImageView.image = [self currentSignalIndicatorImage];
        self.iconImageView.tintColor = self.connectedTintColor;
    } else {
        self.signalImageView.image = self.signalImageMapping[@(DUXBetaRemoteSignalBarsLevel0)];
        self.iconImageView.tintColor = self.disconnectedTintColor;
    }
    [self updateMinImageDimensions];
}

- (void)setImage:(UIImage *)image forRemoteControllerBarLevel:(DUXBetaRemoteSignalBarsLevel)level {
    [self.signalImageMapping setObject:image forKey:@(level)];
    [self updateUI];
}

- (UIImage *)imageForBarLevel:(DUXBetaRemoteSignalBarsLevel)level {
    return [self.signalImageMapping objectForKey:@(level)];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return hint;
}

- (void)updateMinImageDimensions {
    CGSize signalContainerSize = [self maxSizeInImageArray:[self.signalImageMapping allValues]];
    CGFloat widgetWidth = signalContainerSize.width + self.remoteControllerWidgetIcon.size.width;
    
    _minWidgetSize = CGSizeMake(widgetWidth, MAX(signalContainerSize.height, self.iconImageView.frame.size.height));
}

@end

@implementation RemoteControllerSignalWidgetModelState
+ (instancetype)productConnected:(BOOL)isConnected {
    return [[RemoteControllerSignalWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)remoteControllerSignalQualityUpdate:(NSInteger)signalQuality {
    return [[RemoteControllerSignalWidgetModelState alloc] initWithKey:@"remoteControllerSignalQualityUpdate" number:@(signalQuality)];
}

@end
