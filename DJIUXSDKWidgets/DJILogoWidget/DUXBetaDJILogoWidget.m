//
//  DUXBetaDJILogoWidget.m
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

#import "DUXBetaDJILogoWidget.h"
@import UXSDKCore;

/**
 * DUXBetaDJILogoUIState contains the model hooks for the DUXBetaDJILogoWidget.
 * It implements the hook:
 *
 * Key: widgetTapped    Type: NSNumber - Sends a boolean YES as an NSNumber when the widget was tapped.
*/
@interface DUXBetaDJILogoUIState : DUXBetaStateChangeBaseData

+ (instancetype)widgetTapped;

@end

@interface DUXBetaDJILogoWidget ()

@property (nonatomic, retain) UIImageView *logoImageView;
@property (nonatomic, assign) CGSize minWidgetSize;

@end

@implementation DUXBetaDJILogoWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        self.logoImage = [UIImage duxbeta_imageWithAssetNamed:@"DJILogo" forClass:[self class]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupUI];
}

- (void)setupUI {
    self.logoImageView = [[UIImageView alloc] initWithImage:self.logoImage];
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:self.logoImageView];
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.logoImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.logoImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.logoImageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.logoImageView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {_minWidgetSize.width / _minWidgetSize.height, _minWidgetSize.width, _minWidgetSize.height};
    return hint;
}

- (void)setLogoImage:(UIImage *)logoImage {
    if (logoImage == nil) {
        _logoImage = [UIImage duxbeta_imageWithAssetNamed:@"DJILogo" forClass:[self class]];
    }
    _logoImage = logoImage;
    _minWidgetSize = _logoImage.size;
    
    [self updateUI];
}

- (void)updateUI {
    self.logoImageView.image = self.logoImage;
}

- (void)handleTap {
    [DUXBetaStateChangeBroadcaster send:[DUXBetaDJILogoUIState widgetTapped]];
}

@end

@implementation DUXBetaDJILogoUIState

+ (instancetype)widgetTapped {
    return [[DUXBetaDJILogoUIState alloc] initWithKey:@"widgetTapped" number:@(0)];
}

@end
