//
//  DUXBetaSpotlightIndicatorWidget.m
//  UXSDKAccessory
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

#import "DUXBetaSpotlightIndicatorWidget.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import "DUXBetaSpotlightControlWidget.h"


static CGSize const kDesignSize = {24.0, 24.0};

@interface DUXBetaSpotlightIndicatorWidget ()

@property (nonatomic, strong) UIButton *spotlightButton;

@end

@implementation DUXBetaSpotlightIndicatorWidget

@synthesize activeImage = _activeImage;
@synthesize inactiveImage = _inactiveImage;

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaSpotlightIndicatorWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateEnabled), isEnabled);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.spotlightButton = [[UIButton alloc] init];
    [self.view addSubview:self.spotlightButton];
    self.spotlightButton.translatesAutoresizingMaskIntoConstraints =NO;
    self.spotlightButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.spotlightButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.spotlightButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.spotlightButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.spotlightButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    self.spotlightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.spotlightButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.spotlightButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateEnabled {
    if (self.widgetModel.isEnabled) {
        [self.spotlightButton setImage:self.activeImage forState:UIControlStateNormal];
    } else {
        [self.spotlightButton setImage:self.inactiveImage forState:UIControlStateNormal];
    }
}

- (void)buttonPressed {
    if ([self.delegate respondsToSelector:@selector(spotlightIndicatorWidgetRequestingDisplayOfWidget:)]) {
        DUXBetaSpotlightControlWidget *spotlightControlWidget = [[DUXBetaSpotlightControlWidget alloc] init];
        [self.delegate spotlightIndicatorWidgetRequestingDisplayOfWidget:spotlightControlWidget];
    }
}

- (UIImage *)activeImage {
    if (_activeImage) {
        return _activeImage;
    }
    return [UIImage duxbeta_imageWithAssetNamed:@"BeaconActive" forClass:[self class]];
}

- (UIImage *)inactiveImage {
    if (_inactiveImage) {
        return _inactiveImage;
    }
    return [UIImage duxbeta_imageWithAssetNamed:@"BeaconInactive" forClass:[self class]];
}

- (void)setActiveImage:(UIImage *)activeImage {
    _activeImage = activeImage;
    [self updateEnabled];
}

- (void)setInactiveImage:(UIImage *)inactiveImage {
    _inactiveImage = inactiveImage;
    [self updateEnabled];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
