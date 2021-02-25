//
//  DUXBetaSpeakerUploadingView.m
//  UXSDKAccessory
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

#import "DUXBetaSpeakerUploadingView.h"
#import <UXSDKCore/UXSDKCore.h>

@interface DUXBetaSpeakerUploadingView ()

@property (nonatomic, strong) CAShapeLayer* shapeLayer;

@end

@implementation DUXBetaSpeakerUploadingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = self.bounds;
        CGFloat offset = 9.0f;
        CGFloat radius = self.bounds.size.width / 2 - offset;
        UIBezierPath* bezierPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:radius startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
        
        self.shapeLayer.path = bezierPath.CGPath;
        self.shapeLayer.strokeColor = [UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0].CGColor;
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        self.shapeLayer.strokeStart = 0.0f;
        self.shapeLayer.strokeEnd = 0.75f;
        self.shapeLayer.lineJoin = kCALineCapRound;
        self.shapeLayer.lineWidth = 4.0f;
        [self.layer addSublayer:self.shapeLayer];
        
        _uploadingViewStrokeColor = [UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0];
        _uploadingViewFillColor = [UIColor clearColor];
        __weak typeof(self) target = self;
        [self duxbeta_addCustomObserver:self forKeyPath:@RKVOKeypath(self.hidden) block:^(id  _Nullable oldValue, id  _Nullable newValue) {
            [target syncAnimateState];
        }];
        
        [self syncAnimateState];
    }
    return self;
}

- (void)syncAnimateState {
    if (self.isHidden) {
        [self.shapeLayer removeAllAnimations];
    } else {
        [self.shapeLayer removeAllAnimations];
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
        rotationAnimation.duration = 1.0f;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        
        [self.shapeLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

- (void)setUploadingViewFillColor:(UIColor *)uploadingViewFillColor {
    _uploadingViewFillColor = uploadingViewFillColor;
    self.shapeLayer.fillColor = uploadingViewFillColor.CGColor;
}

- (void)setUploadingViewStrokeColor:(UIColor *)uploadingViewStrokeColor {
    _uploadingViewStrokeColor = uploadingViewStrokeColor;
    self.shapeLayer.strokeColor = uploadingViewStrokeColor.CGColor;
}

@end
