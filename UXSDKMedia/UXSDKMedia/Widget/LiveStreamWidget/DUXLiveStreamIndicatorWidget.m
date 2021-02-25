//
//  DUXLiveStreamIndicatorWidget.m
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

#import "DUXLiveStreamIndicatorWidget.h"
#import "DUXLiveStreamControlWidget.h"
#import "DUXLiveStreamFacebookStartViewController.h"
#import <UXSDKCore/UIImage+DUXAssets.h>
#import <UXSDKCore/UIFont+DUXFonts.h>


static CGSize const kDesignSize = {36.0, 36.0};

@interface DUXLiveStreamIndicatorWidget ()

@property (nonatomic, strong, nonnull) UIImageView *facebookLiveImageView;
@property (nonatomic, strong, readwrite) DUXLiveStreamControlWidget *controlWidget;

@end


@implementation DUXLiveStreamIndicatorWidget

@synthesize facebookLiveImage = _facebookLiveImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel = [[DUXLiveStreamControlWidgetModel alloc] init];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.widgetModel setup];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.widgetModel dux_removeCustomObserver:self];
    [self.widgetModel cleanup];
}

- (void)setupUI {
    __weak typeof(self) weakSelf = self;
    self.controlWidget = [[DUXLiveStreamControlWidget alloc] init];
    self.controlWidget.widgetModel = weakSelf.widgetModel;
    self.facebookLiveImageView = [[UIImageView alloc] initWithImage:[UIImage dux_imageWithAssetNamed:@"FacebookLive" forClass:[self class]]];
    self.facebookLiveImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.facebookLiveImageView];
    self.facebookLiveImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.facebookLiveImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.facebookLiveImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.facebookLiveImageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.facebookLiveImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
}

- (void)updateUI {
    self.facebookLiveImageView.image = self.facebookLiveImage;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.controlWidget.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlWidget willMoveToParentViewController:self.parentViewController];
    [self.parentViewController addChildViewController:self.controlWidget];
    [self.parentViewController.view addSubview:self.controlWidget.view];
    [self.controlWidget didMoveToParentViewController:self.parentViewController];
    [self.controlWidget.view.heightAnchor constraintEqualToAnchor:self.parentViewController.view.heightAnchor multiplier:0.5].active = YES;
    [self.controlWidget.view.widthAnchor constraintEqualToAnchor:self.parentViewController.view.widthAnchor multiplier:0.5].active = YES;
    [self.controlWidget.view.centerXAnchor constraintEqualToAnchor:self.parentViewController.view.centerXAnchor].active = YES;
    [self.controlWidget.view.centerYAnchor constraintEqualToAnchor:self.parentViewController.view.centerYAnchor].active = YES;
}

- (DUXWidgetSizeHint)widgetSizeHint {
    DUXWidgetSizeHint hint = {
        kDesignSize.width/kDesignSize.height,
        kDesignSize.width,
        kDesignSize.height,
    };
    return hint;
}

- (UIImage *)facebookLiveImage {
    if (_facebookLiveImage) {
        return _facebookLiveImage;
    }
    return [UIImage dux_imageWithAssetNamed:@"FacebookLive" forClass:[self class]];
}

- (void)setfacebookLiveImage:(UIImage *)facebookLiveImage {
    _facebookLiveImage = facebookLiveImage;
    [self updateUI];
}

@end
