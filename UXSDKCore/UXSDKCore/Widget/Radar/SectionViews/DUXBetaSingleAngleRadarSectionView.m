//
//  DUXBetaSingleAngleRadarSectionView.m
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

#import "DUXBetaSingleAngleRadarSectionView.h"
#import "DUXBetaRadarWidget.h"
#import "UIImage+DUXBetaAssets.h"

@interface DUXBetaSingleAngleRadarSectionView ()

@end

@implementation DUXBetaSingleAngleRadarSectionView

- (instancetype)initWithSensorPosition:(DJIVisionSensorPosition)position {
    self = [super initWithSensorPosition:position];
    if (self) {
        self.arrow = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"ArrowImage"]];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.arrow = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"ArrowImage"]];
        [self setupConstraints];
    }
    return self;
}

- (void)setObstacleDistanceInMeters:(float)obstacleDistanceInMeters {
    [super setObstacleDistanceInMeters:obstacleDistanceInMeters];
    if (obstacleDistanceInMeters <= 0 || obstacleDistanceInMeters >= 6) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
        if (obstacleDistanceInMeters < 3) {
            self.radarImageView.image = [self sectorImageForLevel:DJIObstacleDetectionSectorWarningLevel2 andSectorIndex:(self.position == DJIVisionSensorPositionLeft ? 0 : 1)];
        } else {
            self.radarImageView.image = [self sectorImageForLevel:DJIObstacleDetectionSectorWarningLevel1 andSectorIndex:(self.position == DJIVisionSensorPositionLeft ? 0 : 1)];
        }
        if (obstacleDistanceInMeters < 0.0) {
            obstacleDistanceInMeters = 0.0;
            self.hidden = YES;
        }
        [super setObstacleDistanceInMeters:obstacleDistanceInMeters];
    }
}

- (void)setSectors:(NSArray<DJIObstacleDetectionSector *> *)sectors {
    //Doesn't do anything for SingleAngleRadar
    [super setSectors:sectors];
}

- (void)setupConstraints {
    self.radarImageView = [UIImageView new];
    [self addSubview:self.radarImageView];
    self.radarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.radarImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.radarImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.radarImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.radarImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.radarImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.radarImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    self.radarImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.arrow.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.arrow];
    [self.arrow.centerYAnchor constraintEqualToAnchor:self.radarImageView.centerYAnchor].active = YES;
    
    if (self.position == DJIVisionSensorPositionLeft) {
        self.arrow.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [self.arrow.leadingAnchor constraintEqualToAnchor:self.radarImageView.trailingAnchor constant:5].active = YES;
    } else {
        self.arrow.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self.arrow.trailingAnchor constraintEqualToAnchor:self.radarImageView.leadingAnchor constant:-5].active = YES;
    }
    
    self.distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.distanceLabel];
    [self.distanceLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    // Use the intrinsic size since we only need the edge.
 //   [self.distanceLabel.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.distanceLabel.heightAnchor constraintEqualToConstant:16].active = YES;
    if (self.position == DJIVisionSensorPositionLeft) {
        [self.distanceLabel.leadingAnchor constraintEqualToAnchor:self.arrow.trailingAnchor constant:10].active = YES;
    } else {
        [self.distanceLabel.trailingAnchor constraintEqualToAnchor:self.arrow.leadingAnchor constant:-10].active = YES;
    }
}

#pragma mark - Customizations

- (void)setDistanceArrowImageBackground:(UIColor*)arrowBackgroundColor {
    self.distanceArrowImageBackground = arrowBackgroundColor;
    self.arrow.backgroundColor = arrowBackgroundColor;
}


- (void)updateCustomImages {
    UIImage *workImage = nil;
    
    [super updateCustomImages];

    if (self.customizedRadarSections) {
        workImage = self.customizedRadarSections[DUXRadarWidgetArrow];
    }
    
    if (workImage == nil) {
        workImage = [UIImage duxbeta_imageWithAssetNamed:@"ArrowImage"];
    }
    self.arrow.image = workImage;
}

@end
