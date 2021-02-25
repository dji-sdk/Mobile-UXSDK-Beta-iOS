//
//  DUXBetaCompassWidget.m
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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

#import "DUXBetaCompassWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIColor+DUXBetaColors.h"

@interface DUXBetaCompassWidget ()

@property (nonatomic, strong) DUXBetaCompassLayer *compassLayer;

@end

@implementation DUXBetaCompassWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        self.compassLayer = [DUXBetaCompassLayer new];
        
        self.compassLayer.compassBackgroundColor = [UIColor uxsdk_white5];
        self.compassLayer.horizonColor = [UIColor uxsdk_compassWidgetHorizonColor];
        self.compassLayer.boundsColor = [UIColor uxsdk_darkGrayColor];
        self.compassLayer.lineColor = [UIColor uxsdk_whiteAlpha20];
        self.compassLayer.yawColor = [UIColor uxsdk_selectedBlueColor];
        self.compassLayer.invalidColor = [UIColor uxsdk_errorDangerColor];
        self.compassLayer.blinkColor = [UIColor uxsdk_errorDangerColorAlpha30];
        
        self.compassLayer.designSize = CGSizeMake(87, 87);
        self.compassLayer.innerMargin = 6;
        self.compassLayer.maskMargin = 15;
        self.compassLayer.notchSize = CGSizeMake(7, 7);
        self.compassLayer.aircraftSize = CGSizeMake(14, 22);
        self.compassLayer.gimbalYawSize = CGSizeMake(54, 65);
        self.compassLayer.northIconSize = CGSizeMake(10, 10);
        self.compassLayer.homeIconSize = CGSizeMake(12, 12);
        self.compassLayer.rcIconSize = CGSizeMake(10, 10);
        
        self.compassLayer.notchImage = [UIImage duxbeta_imageWithAssetNamed:@"Notch"];
        self.compassLayer.aircraftImage = [UIImage duxbeta_imageWithAssetNamed:@"AircraftSymbol"];
        self.compassLayer.gimbalYawImage = [UIImage duxbeta_imageWithAssetNamed:@"GimbalYaw"];
        self.compassLayer.northImage = [UIImage duxbeta_imageWithAssetNamed:@"North"];
        self.compassLayer.homeImage = [UIImage duxbeta_imageWithAssetNamed:@"Home"];
        self.compassLayer.rcImage = [UIImage duxbeta_imageWithAssetNamed:@"RCLocation"];
        
        [self.view.layer addSublayer: self.compassLayer];
        self.view.clipsToBounds = NO;
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaCompassWidgetModel alloc] init];
    [self.widgetModel setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    BindRKVOModel(self.widgetModel, @selector(updateIsConnected), isProductConnected);
    BindRKVOModel(self.widgetModel.compassState, @selector(updateUI),
                  aircraftState.angle,
                  aircraftState.distance,
                  rcLocationState.angle,
                  rcLocationState.distance,
                  homeLocationState.angle,
                  homeLocationState.distance,
                  aircraftAttitude.pitch,
                  aircraftAttitude.roll,
                  aircraftAttitude.yaw,
                  gimbalHeading,
                  deviceHeading,
                  centerType);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat min = MIN(self.view.frame.size.width, self.view.frame.size.height);
    if (self.view.frame.size.width < self.view.frame.size.height) {
        self.compassLayer.frame = CGRectMake(0, self.view.frame.size.height / 2 - min / 2, min, min);
    } else {
        self.compassLayer.frame = CGRectMake(self.view.frame.size.width / 2 - min / 2, 0, min, min);
    }
    [self updateUI];
}

- (void)updateIsConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[CompassModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)updateUI {
    [[DUXBetaStateChangeBroadcaster instance] send:[CompassModelState compassStateUpdated:self.widgetModel.compassState]];
    
    [self.compassLayer updateCompassState:self.widgetModel.compassState];
    
    [self.view setNeedsDisplay];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    CGSize designSize = self.compassLayer.designSize;
    DUXBetaWidgetSizeHint hint = {designSize.width / designSize.height, designSize.width, designSize.height};
    return hint;
}

@end

@implementation CompassModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[CompassModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)compassStateUpdated:(DUXBetaCompassState *)state {
    return [[CompassModelState alloc] initWithKey:@"compassStateUpdated" object:state];
}

@end
