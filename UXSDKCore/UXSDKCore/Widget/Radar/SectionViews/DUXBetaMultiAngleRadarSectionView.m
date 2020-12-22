//
//  DUXBetaMultiAngleRadarSectionView.m
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

#import "DUXBetaMultiAngleRadarSectionView.h"
#import "UIImage+DUXBetaAssets.h"
#import "DUXBetaUIImageView.h"

@interface DUXBetaMultiAngleRadarSectionView ()

@property (strong, nonatomic) UIImageView *arrow;
@property (strong, nonatomic) UILabel *distanceLabel;

@end

@implementation DUXBetaMultiAngleRadarSectionView

- (instancetype)initWithSensorPosition:(DJIVisionSensorPosition)position {
    self = [super initWithSensorPosition:position];
    if (self) {
        _arrow = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"ArrowImage"]];
        _distanceLabel = [UILabel new];
        _distanceLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.40];
        _distanceLabel.textColor = [UIColor whiteColor];
        _distanceLabel.adjustsFontSizeToFitWidth = YES;
        _distanceLabel.text = @"0.0M";
        _sectorImages = [NSMutableArray new];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _arrow = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"ArrowImage"]];
        _distanceLabel = [UILabel new];
        _distanceLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.40];
        _distanceLabel.textColor = [UIColor whiteColor];
        _distanceLabel.adjustsFontSizeToFitWidth = YES;
        _distanceLabel.text = @"0.0M";
        [self setupConstraints];
    }
    return self;
}

- (void)setSectors:(NSArray<DJIObstacleDetectionSector *> *)sectors {
    [super setSectors:sectors];
    if (sectors != nil && sectors.count > 0) {
        float distance = NSIntegerMax;
        for (int i = 0; i < sectors.count; i++) {
            if (sectors[i].obstacleDistanceInMeters < distance) {
                distance = sectors[i].obstacleDistanceInMeters;
            }
            DJIObstacleDetectionSectorWarning level = sectors[i].warningLevel;
            if (level > 0 && level <= 6) {
                self.sectorImages[i].image = [self sectorImageForLevel:level andSectorIndex:i];
                self.hidden = NO;
            }
            if (level == DJIObstacleDetectionSectorWarningInvalid || level == DJIObstacleDetectionSectorWarningUnknown) {
                [self disableRadarSection:sectors];
            }
        }
        if (distance < 0.0) {
            distance = 0.0;
            [self disableRadarSection:sectors];
        }
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1fM",distance];
        [super setObstacleDistanceInMeters:distance];
    }
}

- (void)setupConstraints {
    //Goes left to right for top and bottom;
    DUXBetaUIImageView *sector0ImageView = [DUXBetaUIImageView new];
    sector0ImageView.scale = 1.0;
    DUXBetaUIImageView *sector1ImageView = [DUXBetaUIImageView new];
    sector1ImageView.scale = 1.0;
    DUXBetaUIImageView *sector2ImageView = [DUXBetaUIImageView new];
    sector2ImageView.scale = 1.0;
    DUXBetaUIImageView *sector3ImageView = [DUXBetaUIImageView new];
    sector3ImageView.scale = 1.0;
    
    sector0ImageView.contentMode = UIViewContentModeScaleAspectFit;
    sector1ImageView.contentMode = UIViewContentModeScaleAspectFit;
    sector2ImageView.contentMode = UIViewContentModeScaleAspectFit;
    sector3ImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    sector0ImageView.translatesAutoresizingMaskIntoConstraints = NO;
    sector1ImageView.translatesAutoresizingMaskIntoConstraints = NO;
    sector2ImageView.translatesAutoresizingMaskIntoConstraints = NO;
    sector3ImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:sector0ImageView];
    [self addSubview:sector1ImageView];
    [self addSubview:sector2ImageView];
    [self addSubview:sector3ImageView];
    
    //Sector 0
    [sector0ImageView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.25].active = YES;
    [sector0ImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [sector0ImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [sector0ImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    //Sector 1
    [sector1ImageView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.25].active = YES;
    [sector1ImageView.leadingAnchor constraintEqualToAnchor:sector0ImageView.trailingAnchor].active = YES;
    [sector1ImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [sector1ImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    //Sector 2
    [sector2ImageView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.25].active = YES;
    [sector2ImageView.leadingAnchor constraintEqualToAnchor:sector1ImageView.trailingAnchor].active = YES;
    [sector2ImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [sector2ImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    //Sector 3
    [sector3ImageView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.25].active = YES;
    [sector3ImageView.leadingAnchor constraintEqualToAnchor:sector2ImageView.trailingAnchor].active = YES;
    [sector3ImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [sector3ImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [sector3ImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

    
    [self.sectorImages addObject:sector0ImageView];
    [self.sectorImages addObject:sector1ImageView];
    [self.sectorImages addObject:sector2ImageView];
    [self.sectorImages addObject:sector3ImageView];
    
    self.arrow.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.arrow];
    [self.arrow.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    if (self.position == DJIVisionSensorPositionTail) {
        self.arrow.transform = CGAffineTransformMakeRotation(M_PI);
        [self.arrow.topAnchor constraintEqualToAnchor:self.topAnchor constant:-5].active = YES;
    } else {
        [self.arrow.topAnchor constraintEqualToAnchor:self.bottomAnchor constant:5].active = YES;
    }
    
    self.distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.distanceLabel];
    [self.distanceLabel.centerXAnchor constraintEqualToAnchor:self.arrow.centerXAnchor].active = YES;
    [self.distanceLabel.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.distanceLabel.heightAnchor constraintEqualToConstant:16].active = YES;
    if (self.position == DJIVisionSensorPositionTail) {
        [self.distanceLabel.bottomAnchor constraintEqualToAnchor:self.arrow.topAnchor constant:-10].active = YES;
    } else {
        [self.distanceLabel.topAnchor constraintEqualToAnchor:self.arrow.bottomAnchor constant:10].active = YES;
    }
}

- (void)disableRadarSection:(NSArray<DJIObstacleDetectionSector *> *)sectors {
    if (self.position == DJIVisionSensorPositionNose) {
        for (int i = 0; i < sectors.count; i++) {
            self.sectorImages[i].image = [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"RadarForwardDisabled_%d_0", i]];
        }
    } else if (self.position == DJIVisionSensorPositionTail) {
        for (int i = 0; i < sectors.count; i++) {
            self.sectorImages[i].image = [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"RadarBackwardDisabled_%d_0", i]];
        }
    }
}

@end
