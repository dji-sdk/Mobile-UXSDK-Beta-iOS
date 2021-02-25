//
//  DUXBetaSimulatorIndicatorWidget.m
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

#import "DUXBetaSimulatorIndicatorWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIColor+DUXBetaColors.h"
#import "DUXBetaStateChangeBroadcaster.h"
#import "NSLayoutConstraint+DUXBetaMultiplier.h"

/**
 * DUXBetaSimulatorIndicatorWidgetModelState contains the model hooks for the DUXBetaSimulatorIndicatorWidget.
 * It implements the hooks:
 *
 * Key: productConnected        Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft is connected.
 *
 * Key: simpulatorStateUpdated  Type: NSNumber - Sends a boolean value as an NSNumber when the simulator state changes.
*/
@interface DUXBetaSimulatorIndicatorModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)simulatorStateUpdated:(BOOL)isActive;

@end

/**
 * SimulatorIndicatorUIState contains the hooks for UI changes in the widget class DUXBetaSimulatorIndicatorWidget.
 * It implements the hook:
 *
 * Key: widgetTapped    Type: NSNumber - Sends a boolean YES value as an NSNumber indicating the widget was tapped.
*/
@interface SimulatorIndicatorUIState : DUXBetaStateChangeBaseData

+ (instancetype)widgetTapped;

@end

@interface DUXBetaSimulatorIndicatorWidget()

@property (nonatomic, assign) DUXBetaSimulatorIndicatorState state;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *imageMapping;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIColor *> *tintColorMapping;
@property (nonatomic) CGSize minWidgetSize;
@property (nonatomic, strong) NSLayoutConstraint *widgetAspectRatioConstraint;

@end

@implementation DUXBetaSimulatorIndicatorWidget

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
    self.imageMapping =  [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaSimulatorIndicatorStateActive): [UIImage duxbeta_imageWithAssetNamed:@"SimulatorActiveImage"],
        @(DUXBetaSimulatorIndicatorStateInactive): [UIImage duxbeta_imageWithAssetNamed:@"SimulatorInactiveImage"],
        @(DUXBetaSimulatorIndicatorStateDisconnected): [UIImage duxbeta_imageWithAssetNamed:@"SimulatorInactiveImage"]
    }];
    
    self.tintColorMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
        @(DUXBetaSimulatorIndicatorStateActive): [UIColor uxsdk_goodColor],
        @(DUXBetaSimulatorIndicatorStateInactive): [UIColor uxsdk_whiteColor],
        @(DUXBetaSimulatorIndicatorStateDisconnected): [UIColor uxsdk_grayWhite50]
    }];
    
    [self updateMinImageDimensions];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Intialize view model
    self.widgetModel = [[DUXBetaSimulatorIndicatorWidgetModel alloc] init];
    [self.widgetModel setup];
    
    // Intiailize user interface
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Bind widget to model updates
    BindRKVOModel(self.widgetModel, @selector(modelChanged), isSimulatorActive, isProductConnected);
    
    // Bind widget to customization updates
    BindRKVOModel(self.widgetModel, @selector(sendSimulatorStatus), isSimulatorActive);
    BindRKVOModel(self.widgetModel, @selector(sendProductConnected), isProductConnected);
    BindRKVOModel(self, @selector(updateUI), backgroundColor);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

#pragma mark - Public Methods

- (void)setImage:(UIImage *)image forState:(DUXBetaSimulatorIndicatorState)state {
    self.imageMapping[@(state)] = image;
    [self updateMinImageDimensions];
    [self updateUI];
}

- (UIImage *)getImageForState:(DUXBetaSimulatorIndicatorState)state {
    return [self.imageMapping[@(state)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setTintColor:(UIColor *)color forState:(DUXBetaSimulatorIndicatorState)state {
    self.tintColorMapping[@(state)] = color;
    [self updateUI];
}

- (UIColor *)getTintColorForState:(DUXBetaSimulatorIndicatorState)state {
    return self.tintColorMapping[@(state)];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return hint;
}

#pragma mark - Private Methods

- (void)setupUI {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *initialImage = [self getImageForState:self.state];
    CGFloat imageAspectRatio = initialImage.size.width / initialImage.size.height;
    self.widgetAspectRatioConstraint = [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageAspectRatio];
    self.widgetAspectRatioConstraint.active = YES;
    
    self.imageView = [[UIImageView alloc] initWithImage:initialImage];
    [self.view addSubview:self.imageView];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)modelChanged {
    [self updateState];
    [self updateUI];
}

- (void)updateState {
    if (!self.widgetModel.isProductConnected) {
        self.state = DUXBetaSimulatorIndicatorStateDisconnected;
    } else if (!self.widgetModel.isSimulatorActive) {
        self.state = DUXBetaSimulatorIndicatorStateInactive;
    } else {
        self.state = DUXBetaSimulatorIndicatorStateActive;
    }
}

- (void)updateUI {
    self.imageView.image = [self getImageForState:self.state];
    self.imageView.tintColor = [self getTintColorForState:self.state];
    self.view.backgroundColor = self.backgroundColor;
}

- (void)sendProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaSimulatorIndicatorModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendSimulatorStatus {
    [[DUXBetaStateChangeBroadcaster instance] send:[DUXBetaSimulatorIndicatorModelState productConnected:self.widgetModel.isSimulatorActive]];
}

- (void)handleTap {
    [[DUXBetaStateChangeBroadcaster instance] send:[SimulatorIndicatorUIState widgetTapped]];
}

- (void)updateMinImageDimensions {
    _minWidgetSize = [self maxSizeInImageArray:self.imageMapping.allValues];
    [self.widgetAspectRatioConstraint duxbeta_updateMultiplier:self.widgetSizeHint.preferredAspectRatio];
}

@end

@implementation DUXBetaSimulatorIndicatorModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[DUXBetaSimulatorIndicatorModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)simulatorStateUpdated:(BOOL)isActive {
    return [[DUXBetaSimulatorIndicatorModelState alloc] initWithKey:@"simulatorStateUpdate" number:@(isActive)];
}

@end

@implementation SimulatorIndicatorUIState

+ (instancetype)widgetTapped {
    return [[SimulatorIndicatorUIState alloc] initWithKey:@"widgetTapped" value:@(0)];
}

@end
