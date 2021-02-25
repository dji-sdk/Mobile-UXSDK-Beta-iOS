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
@property (nonatomic, readwrite) CGSize contentSize;
@end

@implementation DUXBetaMultiAngleRadarSectionView

- (instancetype)initWithSensorPosition:(DJIVisionSensorPosition)position {
    self = [super initWithSensorPosition:position];
    if (self) {
        self.arrow = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"ArrowImage"]];
        self.arrow.translatesAutoresizingMaskIntoConstraints = NO;
        _sectorImages = [NSMutableArray new];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.arrow = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"ArrowImage"]];
        self.arrow.translatesAutoresizingMaskIntoConstraints = NO;
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
        [super setObstacleDistanceInMeters:distance];
    }
}

- (void)setupConstraints {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    //Goes left to right for top and bottom;
    UIView *segmentsView = [UIView new];
    segmentsView.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    

    // Compute forward width
    CGFloat totalWidth = 0.0;
    CGFloat maxHeight = 0.0;
    int segmentWidths[4] = {0, 0, 0, 0};
    for (int sectorIndex = 0; sectorIndex < 4; sectorIndex++) {
        sector0ImageView.image = [self sectorImageForLevel:DJIObstacleDetectionSectorWarningLevel1 andSectorIndex:sectorIndex];
        maxHeight = MAX(maxHeight, sector0ImageView.image.size.height);
        segmentWidths[sectorIndex] = sector0ImageView.image.size.width;
        totalWidth += segmentWidths[sectorIndex];
    }
    
    [self.sectorImages addObject:sector0ImageView];
    [self.sectorImages addObject:sector1ImageView];
    [self.sectorImages addObject:sector2ImageView];
    [self.sectorImages addObject:sector3ImageView];
    
    [segmentsView addSubview:sector0ImageView];
    [segmentsView addSubview:sector1ImageView];
    [segmentsView addSubview:sector2ImageView];
    [segmentsView addSubview:sector3ImageView];

    [self addSubview:segmentsView];
    self.contentSize = CGSizeMake(totalWidth, maxHeight);

    UILayoutGuide *fixedGuide = [UILayoutGuide new];
    [segmentsView addLayoutGuide:fixedGuide];
    
    [fixedGuide.heightAnchor constraintEqualToConstant:maxHeight].active = YES;
    [fixedGuide.widthAnchor constraintEqualToConstant:1.0].active = YES;
    [fixedGuide.centerXAnchor constraintEqualToAnchor:segmentsView.centerXAnchor].active = YES;
    [fixedGuide.topAnchor constraintEqualToAnchor:segmentsView.topAnchor].active = YES;

    [segmentsView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    
    [sector0ImageView.bottomAnchor constraintEqualToAnchor:segmentsView.bottomAnchor].active = YES;
    [sector1ImageView.bottomAnchor constraintEqualToAnchor:segmentsView.bottomAnchor].active = YES;
    [sector2ImageView.bottomAnchor constraintEqualToAnchor:segmentsView.bottomAnchor].active = YES;
    [sector3ImageView.bottomAnchor constraintEqualToAnchor:segmentsView.bottomAnchor].active = YES;

    [sector0ImageView.topAnchor constraintEqualToAnchor:segmentsView.topAnchor].active = YES;
    [sector1ImageView.topAnchor constraintEqualToAnchor:segmentsView.topAnchor].active = YES;
    [sector2ImageView.topAnchor constraintEqualToAnchor:segmentsView.topAnchor].active = YES;
    [sector3ImageView.topAnchor constraintEqualToAnchor:segmentsView.topAnchor].active = YES;

    if (self.position == DJIVisionSensorPositionTail) {
        [segmentsView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
   } else {
       [segmentsView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
   }

    //Sector 0
    [sector0ImageView.widthAnchor constraintEqualToAnchor:segmentsView.widthAnchor multiplier:(segmentWidths[0] / totalWidth)].active = YES;
//    [sector0ImageView.leadingAnchor constraintEqualToAnchor:segmentsView.leadingAnchor constant:6.0].active = YES;
    
    //Sector 1
    [sector1ImageView.widthAnchor constraintEqualToAnchor:segmentsView.widthAnchor multiplier:(segmentWidths[1] / totalWidth)].active = YES;
    [sector1ImageView.leadingAnchor constraintEqualToAnchor:sector0ImageView.trailingAnchor constant:-6.0].active = YES;
    
    //Sector 2
    [sector2ImageView.widthAnchor constraintEqualToAnchor:segmentsView.widthAnchor multiplier:(segmentWidths[2] / totalWidth)].active = YES;
    [sector2ImageView.leadingAnchor constraintEqualToAnchor:sector1ImageView.trailingAnchor constant:6.0].active = YES;
    
    //Sector 3
    [sector3ImageView.widthAnchor constraintEqualToAnchor:segmentsView.widthAnchor multiplier:(segmentWidths[3] / totalWidth)].active = YES;
    [sector3ImageView.leadingAnchor constraintEqualToAnchor:sector2ImageView.trailingAnchor constant:-6.0].active = YES;
//    [sector3ImageView.trailingAnchor constraintEqualToAnchor:segmentsView.trailingAnchor constant:6.0].active = YES;

    [segmentsView.leadingAnchor constraintEqualToAnchor:sector0ImageView.leadingAnchor].active = YES;
    [segmentsView.trailingAnchor constraintEqualToAnchor:sector3ImageView.trailingAnchor].active = YES;
    [self.leadingAnchor constraintEqualToAnchor:segmentsView.leadingAnchor].active = YES;
    [self.trailingAnchor constraintEqualToAnchor:segmentsView.trailingAnchor].active = YES;

    [self addSubview:self.arrow];
    [self.arrow.heightAnchor constraintEqualToConstant:self.arrow.image.size.height].active = YES;
    [self.arrow.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    if (self.position == DJIVisionSensorPositionTail) {
        self.arrow.transform = CGAffineTransformMakeRotation(M_PI);
        [self.arrow.bottomAnchor constraintEqualToAnchor:segmentsView.topAnchor constant:0].active = YES;
    } else {
        [self.arrow.topAnchor constraintEqualToAnchor:segmentsView.bottomAnchor constant:0].active = YES;
    }

    self.distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.distanceLabel];
    [self.distanceLabel.centerXAnchor constraintEqualToAnchor:self.arrow.centerXAnchor].active = YES;
    if (self.position == DJIVisionSensorPositionTail) {
        [self.distanceLabel.bottomAnchor constraintEqualToAnchor:self.arrow.topAnchor constant:-10.0].active = YES;
    } else {
        [self.distanceLabel.topAnchor constraintEqualToAnchor:self.arrow.bottomAnchor constant:10.0].active = YES;
    }
    
    if (self.position == DJIVisionSensorPositionTail) {
        [self.topAnchor constraintEqualToAnchor:segmentsView.topAnchor].active = YES;
    } else {
        [self.bottomAnchor constraintEqualToAnchor:segmentsView.bottomAnchor].active = YES;
    }
    self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height + self.arrow.image.size.height + 10 + 20);

}

- (void)disableRadarSection:(NSArray<DJIObstacleDetectionSector *> *)sectors {
    UIImage *workImage = nil;
    
    if (self.position == DJIVisionSensorPositionNose) {
        for (int i = 0; i < sectors.count; i++) {
            if (self.customizedRadarSections) {
                workImage = self.customizedRadarSections[[NSString stringWithFormat:@"RadarCustomForwardDisabled_%d_0", i]];
            }
            if (workImage == nil) {
                workImage = [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"RadarForwardDisabled_%d_0", i]];
            }
            self.sectorImages[i].image = workImage;
            workImage = nil;
        }
    } else if (self.position == DJIVisionSensorPositionTail) {
        for (int i = 0; i < sectors.count; i++) {
            if (self.customizedRadarSections) {
                workImage = self.customizedRadarSections[[NSString stringWithFormat:@"RadarCustomBackwardDisabled_%d_0", i]];
            }
            if (workImage == nil) {
                workImage = [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"RadarBackwardDisabled_%d_0", i]];
            }
            self.sectorImages[i].image = workImage;
            workImage = nil;
        }
    }
}

@end
