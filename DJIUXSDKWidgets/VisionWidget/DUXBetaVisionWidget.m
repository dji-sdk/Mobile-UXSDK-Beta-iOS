//
//  DUXBetaVisionWidget.m
//  DJIUXSDK
//  
//  Copyright © 2018-2019 DJI. All rights reserved.
//

#import "DUXBetaVisionWidget.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
@import DJIUXSDKCore;

static const CGSize kDesignSize = {18.0, 18.0};

@interface DUXBetaVisionWidget ()

@property (nonatomic) UIImageView *visionImageView;
@property (nonatomic) NSMutableDictionary <NSNumber *, UIImage *> *visionImageMapping;

@end

@implementation DUXBetaVisionWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _visionImageMapping = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                @(DUXBetaVisionStatusEnabled) : [UIImage duxbeta_imageWithAssetNamed:@"visionEnabled"],
                                                                                @(DUXBetaVisionStatusDisabled) : [UIImage duxbeta_imageWithAssetNamed:@"visionDisabled"],
                                                                                @(DUXBetaVisionStatusObstacleAvoidanceAllSensorsEnabled) : [UIImage duxbeta_imageWithAssetNamed:@"visionAllSensorsEnabled"],
                                                                                @(DUXBetaVisionStatusObstacleAvoidanceLeftRightSensorsDisabled) : [UIImage duxbeta_imageWithAssetNamed:@"visionLeftRightSensorsDisabled"],
                                                                                @(DUXBetaVisionStatusObstacleAvoidanceAllSensorsDisabled) : [UIImage duxbeta_imageWithAssetNamed:@"visionAllSensorsDisabled"],
                                                                                @(DUXBetaVisionStatusClosed) : [UIImage duxbeta_imageWithAssetNamed:@"visionClosed"],
                                                                                @(DUXBetaVisionStatusUnknown) : [UIImage duxbeta_imageWithAssetNamed:@"visionDisabled"]
                                                                                }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel = [[DUXBetaVisionWidgetModel alloc] init];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.widgetModel setup];
    BindRKVOModel(self.widgetModel, @selector(updateUI), visionStatus);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.widgetModel duxbeta_removeCustomObserver:self];
    [self.widgetModel cleanup];
}

- (void)setupUI {
    UIImage *image = [self.visionImageMapping objectForKey:@(self.widgetModel.visionStatus)];
    CGFloat imageAspectRatio = image.size.width / image.size.height;
    self.visionImageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:self.visionImageView];
    self.visionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.visionImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.visionImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.visionImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.visionImageView.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageAspectRatio].active = YES;
    self.visionImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)updateUI {
    self.visionImageView.image = [self.visionImageMapping objectForKey:@(self.widgetModel.visionStatus)];
}

- (void)setImage:(UIImage *)image forVisionStatus:(DUXBetaVisionStatus)status {
    [self.visionImageMapping setObject:image forKey:@(status)];
    [self updateUI];
}

- (UIImage *)imageForVisionStatus:(DUXBetaVisionStatus)status {
    return [self.visionImageMapping objectForKey:@(status)];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
