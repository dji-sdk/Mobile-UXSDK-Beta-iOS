//
//  DUXBetaAccessLockerIndicatorWidget.m
//  UXSDKMedia
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

#import "DUXBetaAccessLockerIndicatorWidget.h"
#import "DUXBetaAccessLockerControlWidget.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>


static CGSize const kDesignSize = {24.0, 24.0};

@interface DUXBetaAccessLockerIndicatorWidget ()

@property (nonatomic, strong) UIButton *accessLockerButton;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *imageMapping;

@end

@implementation DUXBetaAccessLockerIndicatorWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                       @(DJIAccessLockerStateUnknown) : [UIImage duxbeta_imageWithAssetNamed:@"NotInitialized" forClass:[self class]],
                                                                                       @(DJIAccessLockerStateLocked) : [UIImage duxbeta_imageWithAssetNamed:@"Locked" forClass:[self class]],
                                                                                       @(DJIAccessLockerStateUnlocked) : [UIImage duxbeta_imageWithAssetNamed:@"Unlocked" forClass:[self class]],
                                                                                       @(DJIAccessLockerStateNotInitialized) : [UIImage duxbeta_imageWithAssetNamed:@"NotInitialized" forClass:[self class]]
                                                                                    }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaAccessLockerIndicatorWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateAccessLockerState), currentAccessLockerStateType);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.accessLockerButton = [[UIButton alloc] init];
    [self.view addSubview:self.accessLockerButton];
    self.accessLockerButton.translatesAutoresizingMaskIntoConstraints =NO;
    self.accessLockerButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.accessLockerButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.accessLockerButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.accessLockerButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.accessLockerButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    self.accessLockerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.accessLockerButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.accessLockerButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.accessLockerButton.backgroundColor = UIColor.clearColor;
}

- (void)updateAccessLockerState {
    switch (self.widgetModel.currentAccessLockerStateType) {
        case DJIAccessLockerStateNotInitialized:
            [self.accessLockerButton setImage:[self getImageForAccessLockerState:DJIAccessLockerStateNotInitialized] forState:UIControlStateNormal];
            break;
        case DJIAccessLockerStateLocked:
            [self.accessLockerButton setImage:[self getImageForAccessLockerState:DJIAccessLockerStateLocked] forState:UIControlStateNormal];
            break;
        case DJIAccessLockerStateUnlocked:
            [self.accessLockerButton setImage:[self getImageForAccessLockerState:DJIAccessLockerStateUnlocked] forState:UIControlStateNormal];
            break;
        case DJIAccessLockerStateUnknown:
            [self.accessLockerButton setImage:[self getImageForAccessLockerState:DJIAccessLockerStateUnknown] forState:UIControlStateNormal];
            break;
    }
}

- (void)buttonPressed {
    if ([self.delegate respondsToSelector:@selector(accessLockerIndicatorWidgetRequestingDisplayOfWidget:)]) {
        DUXBetaAccessLockerControlWidget *accessLockerControlWidget = [[DUXBetaAccessLockerControlWidget alloc] init];
        [self.delegate accessLockerIndicatorWidgetRequestingDisplayOfWidget:accessLockerControlWidget];
    }
}

- (void)setAccessLockerImage:(UIImage *)image forAccessLockerState:(DJIAccessLockerState)accessLockerState {
    [self.imageMapping setObject:image forKey:@(accessLockerState)];
}

- (UIImage *)getImageForAccessLockerState:(DJIAccessLockerState)accessLockerState {
    return [self.imageMapping objectForKey:@(accessLockerState)];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}
@end
