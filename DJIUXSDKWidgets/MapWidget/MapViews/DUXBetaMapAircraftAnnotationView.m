//
//  DUXBetaMapDroneAnnotationView.m
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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

#import "DUXBetaMapAircraftAnnotationView.h"
#import "UIImage+DUXBetaAssets.h"

@implementation DUXBetaMapAircraftAnnotationView

- (nonnull instancetype)initWithAnnotation:(nullable id <MKAnnotation>)annotation reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupAnnotationViews];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder  {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupAnnotationViews];
    }
    return self;
}

- (void)setupAnnotationViews {
    UIImageView *aircraftImageView = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"MapAircraftSymbol"]];
    UIImageView *visionConeImageView = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"MapVisionCone"]];
    aircraftImageView.translatesAutoresizingMaskIntoConstraints = NO;
    visionConeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:aircraftImageView];
    [self addSubview:visionConeImageView];
    [self sendSubviewToBack:visionConeImageView];
    
    [aircraftImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [aircraftImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    [visionConeImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [visionConeImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-visionConeImageView.frame.size.height/2].active = YES;
}

- (void)setImage:(UIImage *)image {
    [self removeAllSubviews];
    super.image = image;
}

- (void)removeAllSubviews {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
}

- (void)setYawInRadians:(double)yaw {
    [UIView animateWithDuration:0.15 animations:^{
        self.transform = CGAffineTransformMakeRotation(yaw);
    }];
}

@end
