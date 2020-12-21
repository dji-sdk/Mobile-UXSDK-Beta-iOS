//
//  DUXBetaRadarSectionView.m
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

#import "DUXBetaRadarSectionView.h"
#import "UIImage+DUXBetaAssets.h"

@implementation DUXBetaRadarSectionView

- (instancetype)initWithSensorPosition:(DJIVisionSensorPosition)position {
    if (self = [self initWithFrame:CGRectZero]) {
        _sectors = [[NSArray alloc] init];
        _obstacleDistanceInMeters = 0;
        _position = position;
    }
    return self;
}

- (instancetype)init {
    if (self = [self initWithFrame:CGRectZero]) {
        _sectors = [[NSArray alloc] init];
        _obstacleDistanceInMeters = 0;
    }
    return self;
}

- (void)setSectors:(NSArray<DJIObstacleDetectionSector *> *)sectors {
    _sectors = sectors;
}

- (void)setObstacleDistanceInMeters:(float)obstacleDistanceInMeters {
    _obstacleDistanceInMeters = obstacleDistanceInMeters;
}

- (UIImage *)sectorImageForLevel:(DJIObstacleDetectionSectorWarning)level andSectorIndex:(int)index {
    if (self.position == DJIVisionSensorPositionNose) {
        return [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"RadarForward_%d_%ld", index, level - 1]];
    } else if (self.position == DJIVisionSensorPositionTail) {
        return [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"RadarBackward_%d_%ld", index, level - 1]];
    } else if (self.position == DJIVisionSensorPositionLeft) {
        return [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"AvoidLeft_%d_%ld", index, level - 1]];
    } else if (self.position == DJIVisionSensorPositionRight) {
        return [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"AvoidRight_%d_%ld", index, level - 1]];
    } else {
        return [UIImage duxbeta_imageWithAssetNamed:@""];
    }
}

@end
