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
#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaRadarSectionView ()
@property (nonatomic, readwrite) CGSize contentSize;
@property (nonatomic, strong) DUXBetaUnitTypeModule *commonUnitFormatter;
@end


@implementation DUXBetaRadarSectionView

- (instancetype)initWithSensorPosition:(DJIVisionSensorPosition)position {
    if (self = [self initWithFrame:CGRectZero]) {
        _sectors = [[NSArray alloc] init];
        _obstacleDistanceInMeters = 0;
        _position = position;
        self.distanceLabel = [UILabel new];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _distanceLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.40];
        _distanceFont = [UIFont systemFontOfSize:18.0];
        _distanceLabel.font = _distanceFont;
        _distanceLabel.textColor = [UIColor whiteColor];
        _distanceLabel.adjustsFontSizeToFitWidth = YES;
        _distanceLabel.textAlignment = NSTextAlignmentCenter;
        
        _commonUnitFormatter = [[DUXBetaUnitTypeModule alloc] init];
        [_commonUnitFormatter setup];
        _distanceLabel.text = [self formatObstacleDistanceString];

    }
    return self;
}

- (instancetype)init {
    if (self = [self initWithFrame:CGRectZero]) {
        _sectors = [[NSArray alloc] init];
        _obstacleDistanceInMeters = 0;
        self.distanceLabel = [UILabel new];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _distanceLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.40];
        _distanceLabel.textColor = [UIColor whiteColor];
        _distanceLabel.adjustsFontSizeToFitWidth = YES;
        _distanceLabel.layer.cornerRadius = 4.5;
        _distanceLabel.layer.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.4].CGColor;
        _distanceLabel.text = [self formatObstacleDistanceString];

    }
    return self;
}

- (void)setSectors:(NSArray<DJIObstacleDetectionSector *> *)sectors {
    _sectors = sectors;
}

- (void)setObstacleDistanceInMeters:(float)obstacleDistanceInMeters {
    _obstacleDistanceInMeters = obstacleDistanceInMeters;
    _distanceLabel.text = [self formatObstacleDistanceString];

}

- (UIImage *)sectorImageForLevel:(DJIObstacleDetectionSectorWarning)level andSectorIndex:(int)index {
    UIImage *returnUIImage = nil;

    if (self.position == DJIVisionSensorPositionNose) {
        if (self.customizedRadarSections) {
            NSString *customizedImageName = [NSString stringWithFormat:@"RadarCustomForward_%d_%ld", index, level - 1];
            returnUIImage = self.customizedRadarSections[customizedImageName];
        }
        if (returnUIImage == nil) {
            returnUIImage = [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"RadarForward_%d_%ld", index, level - 1]];
        }
    } else if (self.position == DJIVisionSensorPositionTail) {
        if (self.customizedRadarSections) {
            NSString *customizedImageName = [NSString stringWithFormat:@"RadarCustomBackward_%d_%ld", index, level - 1];
            returnUIImage = self.customizedRadarSections[customizedImageName];
        }
        if (returnUIImage == nil) {
            returnUIImage = [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"RadarBackward_%d_%ld", index, level - 1]];
        }
    } else if (self.position == DJIVisionSensorPositionLeft) {
        if (self.customizedRadarSections) {
            NSString *customizedImageName = [NSString stringWithFormat:@"RadarCustomLeft_%d_%ld", index, level - 1];
            returnUIImage = self.customizedRadarSections[customizedImageName];
        }
        if (returnUIImage == nil) {
            returnUIImage = [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"AvoidLeft_%d_%ld", index, level - 1]];
        }
    } else if (self.position == DJIVisionSensorPositionRight) {
        if (self.customizedRadarSections) {
            NSString *customizedImageName = [NSString stringWithFormat:@"RadarCustomRight_%d_%ld", index, level - 1];
            returnUIImage = self.customizedRadarSections[customizedImageName];
        }
        if (returnUIImage == nil) {
            returnUIImage = [UIImage duxbeta_imageWithAssetNamed:[NSString stringWithFormat:@"AvoidRight_%d_%ld", index, level - 1]];
        }
    } else {
        returnUIImage = [UIImage duxbeta_imageWithAssetNamed:@""];
    }
    
    return returnUIImage;
}

- (NSString*)formatObstacleDistanceString {
    return [NSString stringWithFormat:@"%0.1f%@", [_commonUnitFormatter metersToMeasurementSystem:_obstacleDistanceInMeters], [_commonUnitFormatter unitSuffix]];
}

#pragma mark - Customizations

- (void)setDistanceArrowImageBackground:(UIColor *)arrowBackgroundColor {
    _distanceArrowImageBackground = arrowBackgroundColor;
    _arrow.backgroundColor = arrowBackgroundColor;
}

- (void)setDistanceTextColor:(UIColor *)color {
    _distanceTextColor = color;
    _distanceLabel.textColor = color;
}

- (void)setDistanceTextBackgroundColor:(UIColor *)textBackgroundColor {
    _distanceTextBackgroundColor = textBackgroundColor;
    _distanceLabel.backgroundColor = textBackgroundColor;
}

- (void)setDistanceTextFont:(UIFont *)font {
    _distanceTextFont = font;
    _distanceLabel.font = font;
}

/**
 * This method does nothing for the RadarSectionView but may be overridden for the subclasses and is called when graphics are
 * dynmaically customized.
 */
- (void)updateCustomImages {
    
}
@end
