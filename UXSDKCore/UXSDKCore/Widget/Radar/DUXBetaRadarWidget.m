//
//  DUXBetaRadarWidget.m
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

#import "DUXBetaRadarWidget.h"
#import "DUXBetaRadarSectionView.h"
#import "DUXBetaMultiAngleRadarSectionView.h"
#import "DUXBetaSingleAngleRadarSectionView.h"
#import "UIImage+DUXBetaAssets.h"

static CGSize const kDesignSize = {100.0, 100.0};

@interface DUXBetaRadarWidget ()

@property (strong, nonatomic) NSMutableArray <DUXBetaRadarSectionView *> *radarSections;
@property (strong, nonatomic) UIImageView *avoidUpImageView;

@end

@implementation DUXBetaRadarWidget

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaRadarWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), noseState, tailState, rightState, leftState, controlState);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.radarSections = [[NSMutableArray alloc] init];
    
    //Setup constraints for the 4 main views of the radar widget.
    DUXBetaSingleAngleRadarSectionView *leftSection =  [[DUXBetaSingleAngleRadarSectionView alloc] initWithSensorPosition:DJIVisionSensorPositionLeft];
    leftSection.radarImageView.image = [leftSection sectorImageForLevel:DJIObstacleDetectionSectorWarningLevel1 andSectorIndex:0];
    leftSection.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:leftSection];
    
    [leftSection.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [leftSection.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [leftSection.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [leftSection.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [leftSection.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.2].active = YES;
    
    leftSection.hidden = YES;
    
    
    DUXBetaSingleAngleRadarSectionView *rightSection = [[DUXBetaSingleAngleRadarSectionView alloc] initWithSensorPosition:DJIVisionSensorPositionRight];
    rightSection.radarImageView.image = [rightSection sectorImageForLevel:DJIObstacleDetectionSectorWarningLevel1 andSectorIndex:1];
    rightSection.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:rightSection];
    
    [rightSection.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [rightSection.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [rightSection.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [rightSection.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [rightSection.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.2].active = YES;
    
    rightSection.hidden = YES;
    
    DUXBetaMultiAngleRadarSectionView *noseSection = [[DUXBetaMultiAngleRadarSectionView alloc] initWithSensorPosition:DJIVisionSensorPositionNose];
    noseSection.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:noseSection];
    
    [noseSection.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [noseSection.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [noseSection.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.5].active = YES;
    [noseSection.heightAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.2].active = YES;
    
    noseSection.hidden = YES;
    
    DUXBetaMultiAngleRadarSectionView *tailSection = [[DUXBetaMultiAngleRadarSectionView alloc] initWithSensorPosition:DJIVisionSensorPositionTail];
    tailSection.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tailSection];
    
    [tailSection.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [tailSection.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [tailSection.topAnchor constraintGreaterThanOrEqualToAnchor:noseSection.bottomAnchor constant:219].active = YES;
    [tailSection.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.6].active = YES;
    [tailSection.heightAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.1].active = YES;
    
    tailSection.hidden = YES;
    
    self.avoidUpImageView = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"AvoidUp"]];
    self.avoidUpImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.avoidUpImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.avoidUpImageView];
    [self.avoidUpImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.avoidUpImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    self.avoidUpImageView.hidden = YES;
    
    self.radarSections[DJIVisionSensorPositionNose] = noseSection;
    self.radarSections[DJIVisionSensorPositionTail] = tailSection;
    self.radarSections[DJIVisionSensorPositionRight] = rightSection;
    self.radarSections[DJIVisionSensorPositionLeft] = leftSection;
}

- (void)updateUI {
    //Update nose radar view.  Doesn't use obstacle distance since each sector has that property.
    DUXBetaMultiAngleRadarSectionView *noseSectionView = (DUXBetaMultiAngleRadarSectionView *)self.radarSections[self.widgetModel.noseState.position];
    noseSectionView.sectors = self.widgetModel.noseState.detectionSectors;

    //Update tail radar view.  Doesn't use obstacle distance since each sector has that property.
    DUXBetaMultiAngleRadarSectionView *tailSectionView = (DUXBetaMultiAngleRadarSectionView *)self.radarSections[self.widgetModel.tailState.position];
    //We have to reverse the data here because the sectors come in from right->left but we want left->right for displaying the data
    tailSectionView.sectors = [[self.widgetModel.tailState.detectionSectors reverseObjectEnumerator] allObjects];

    //Update right radar view.  Doesn't use sectors array.
    DUXBetaSingleAngleRadarSectionView *rightSectionView = (DUXBetaSingleAngleRadarSectionView *)self.radarSections[self.widgetModel.rightState.position];
    rightSectionView.obstacleDistanceInMeters = self.widgetModel.rightState.obstacleDistanceInMeters;

    //Update left radar view.  Doesn't use sectors array.
    DUXBetaSingleAngleRadarSectionView *leftSectionView = (DUXBetaSingleAngleRadarSectionView *)self.radarSections[self.widgetModel.leftState.position];
    leftSectionView.obstacleDistanceInMeters = self.widgetModel.leftState.obstacleDistanceInMeters;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
