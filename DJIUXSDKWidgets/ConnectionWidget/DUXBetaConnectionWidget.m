//
//  DUXBetaConnectionWidget.m
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

#import "DUXBetaConnectionWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "DUXStateChangeBroadcaster.h"
#import "NSLayoutConstraint+DUXBetaMultiplier.h"
@import DJIUXSDKCore;

@interface DUXBetaConnectionWidget ()

/**
* Private property that holds the refrence to the icon image container
*/
@property (nonatomic, strong) UIImageView *connectionImageView;

/**
* Private property for changing the aspect ratio constraint when customized with differently sized images
*/
@property (nonatomic, strong) NSLayoutConstraint *widgetAspectRatioConstraint;

/**
* Private property backing widgetSizeHint
*/
@property (nonatomic) CGSize minWidgetSize;

@end

/**
 * DUXConnectionWidgetModelState contains the model hooks for the DUXConnectionWidget.
 * It implements the hook:
 *
 * Key: productConnected    Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft is connected.
*/
@interface DUXConnectionWidgetModelState : DUXStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;

@end

@implementation DUXBetaConnectionWidget

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
    // Set default images
    _connectedImage = [UIImage duxbeta_imageWithAssetNamed:@"Connected"];
    _disconnectedImage = [UIImage duxbeta_imageWithAssetNamed:@"Disconnected"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Bind the widget with its associated widget model
    self.widgetModel = [[DUXBetaConnectionWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), isProductConnected);
    BindRKVOModel(self, @selector(updateUI), connectedImage, disconnectedImage, backgroundColor, connectedTintColor, disconnectedTintColor);
    BindRKVOModel(self, @selector(updateMinImageDimensions), connectedImage, disconnectedImage);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop observing state updates
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    // Start the cleanup process on the widget model
    [self.widgetModel cleanup];
}

#pragma mark - Public Methods

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return hint;
}

#pragma mark - Private Methods

- (void)setupUI {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *initialImage = self.widgetModel.isProductConnected ? self.connectedImage : self.disconnectedImage;
    CGFloat imageAspectRatio = initialImage.size.width / initialImage.size.height;
    self.widgetAspectRatioConstraint = [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageAspectRatio];
    self.widgetAspectRatioConstraint.active = YES;
    
    self.connectionImageView = [[UIImageView alloc] initWithImage:initialImage];
    [self.view addSubview:self.connectionImageView];
    self.connectionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.connectionImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.connectionImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.connectionImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.connectionImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    self.connectionImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIColor *color = self.widgetModel.isProductConnected ? self.connectedTintColor : self.disconnectedTintColor;
    [self.connectionImageView setTintColor:color];
    
    [self.connectionImageView setBackgroundColor: self.backgroundColor];
}

- (void)updateUI {
    // Forward isProductConnected change detected to custom DUXConnectionWidgetState implementation
    [[DUXStateChangeBroadcaster instance] send:[DUXConnectionWidgetModelState productConnected:self.widgetModel.isProductConnected]];
    
    UIImage *image = self.widgetModel.isProductConnected ? self.connectedImage : self.disconnectedImage;
    [self.connectionImageView setImage:image];
    
    UIColor *color = self.widgetModel.isProductConnected ? self.connectedTintColor : self.disconnectedTintColor;
    [self.connectionImageView setTintColor:color];
    
    [self.connectionImageView setBackgroundColor: self.backgroundColor];
}

- (void)updateMinImageDimensions {
    NSArray *iconArray = [[NSArray alloc] initWithObjects:self.connectedImage,self.disconnectedImage, nil];
    
    _minWidgetSize = [self maxSizeInImageArray:iconArray];

    [self.widgetAspectRatioConstraint duxbeta_updateMultiplier:self.widgetSizeHint.preferredAspectRatio];
}

@end

/**
* Implementation of the custom class used by DUXStateChangeBroadcaster
*/
@implementation DUXConnectionWidgetModelState: DUXStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[DUXConnectionWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

@end
