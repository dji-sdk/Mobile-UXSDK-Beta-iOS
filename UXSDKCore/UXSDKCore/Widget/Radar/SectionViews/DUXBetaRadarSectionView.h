//
//  DUXBetaRadarSectionView.h
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

#import <DJISDK/DJISDK.h>

@interface DUXBetaRadarSectionView : UIView

- (instancetype)initWithSensorPosition:(DJIVisionSensorPosition)position;

- (UIImage *)sectorImageForLevel:(DJIObstacleDetectionSectorWarning)level andSectorIndex:(int)index;

@property (nonatomic, strong) NSArray<DJIObstacleDetectionSector *> *sectors;
@property (nonatomic, assign) float obstacleDistanceInMeters;
@property (nonatomic, readonly) DJIVisionSensorPosition position;
// The distance from the inner edge of the radar wedge to positon the obstacle distance from
@property (nonatomic) CGFloat distanceOffset;
@property (nonatomic, strong) UIFont *distanceFont;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UIImageView *arrow;

@property (weak, nonatomic) NSDictionary<NSString *, UIImage *>  *customizedRadarSections;
@property (nonatomic, retain) UIColor   *distanceTextColor;
@property (nonatomic, retain) UIColor   *distanceTextBackgroundColor;
@property (nonatomic, retain) UIFont    *distanceTextFont;
@property (nonatomic, retain) UIColor   *distanceArrowImageBackground;

@property (nonatomic, readonly) CGSize contentSize;

- (void)updateCustomImages;
@end
