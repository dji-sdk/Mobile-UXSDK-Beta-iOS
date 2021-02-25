//
//  DUXBetaAPASWidget.m
//  UXSDKFlight
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

#import "DUXBetaAPASWidget.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>



static CGSize const kDesignSize = {24.0, 24.0};

@interface DUXBetaAPASWidget ()

@property (strong, nonatomic) UIButton *apasButton;

@end

@implementation DUXBetaAPASWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _disabledImage = [UIImage duxbeta_imageWithAssetNamed:@"ApasNormal" forClass:[self class]];
        _inactiveImage = [UIImage duxbeta_imageWithAssetNamed:@"ApasInactive" forClass:[self class]];
        _activeImage = [UIImage duxbeta_imageWithAssetNamed:@"ApasActive" forClass:[self class]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel = [[DUXBetaAPASWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateAPASImage), apasState);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor clearColor];
    self.apasButton = [[UIButton alloc] init];
    [self.view addSubview:self.apasButton];
    self.apasButton.translatesAutoresizingMaskIntoConstraints =NO;
    self.apasButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.apasButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.apasButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.apasButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.apasButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    self.apasButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.apasButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.apasButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.apasButton setImage:self.disabledImage forState:UIControlStateNormal];
}

- (void)updateAPASImage {
    switch (self.widgetModel.apasState) {
        case DUXBetaAPASStateUnknown:
            [self.apasButton setImage:self.disabledImage forState:UIControlStateNormal];
            break;
        case DUXBetaAPASStateNotSupported:
            [self.apasButton setImage:self.disabledImage forState:UIControlStateNormal];
            break;
        case DUXBetaAPASStateDisabled:
            [self.apasButton setImage:self.disabledImage forState:UIControlStateNormal];
            break;
        case DUXBetaAPASStateInactive:
            [self.apasButton setImage:self.inactiveImage forState:UIControlStateNormal];
            break;
        case DUXBetaAPASStateActive:
            [self.apasButton setImage:self.activeImage forState:UIControlStateNormal];
            break;
    }
}

- (void)buttonPressed {
    [self.widgetModel toggleAPASWithCompletion:^(NSError * _Nullable error) {
        
    }];
}

- (void)setActiveImage:(UIImage *)activeImage {
    _activeImage = activeImage;
    [self updateAPASImage];
}

- (void)setInactiveImage:(UIImage *)inactiveImage {
    _inactiveImage = inactiveImage;
    [self updateAPASImage];
}

- (void)setDisabledImage:(UIImage *)disabledImage {
    _disabledImage = disabledImage;
    [self updateAPASImage];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
