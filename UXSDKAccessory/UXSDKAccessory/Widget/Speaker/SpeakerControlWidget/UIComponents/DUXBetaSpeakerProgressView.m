//
//  DUXBetaSpeakerProgressView.m
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

#import "DUXBetaSpeakerProgressView.h"

@interface DUXBetaSpeakerProgressView ()

@property (nonatomic, strong) CAShapeLayer* shapeLayer;

@end

@implementation DUXBetaSpeakerProgressView

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
        self.shapeLayer.strokeColor = [UIColor colorWithRed:16.0/255.0 green:136.0/255.0 blue:242.0/255.0 alpha:1.0].CGColor;
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        self.shapeLayer.strokeStart = 0.0f;
        self.shapeLayer.strokeEnd = 0.0f;
        self.shapeLayer.lineWidth = 4.0f;
        self.shapeLayer.lineJoin = kCALineCapRound;
        [self.layer addSublayer:self.shapeLayer];
        _progressStrokeColor = [UIColor colorWithRed:16.0/255.0 green:136.0/255.0 blue:242.0/255.0 alpha:1.0];
        _progressFillColor = [UIColor clearColor];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    self.shapeLayer.strokeEnd = progress;
}

- (void)setProgressFillColor:(UIColor *)progressFillColor {
    _progressFillColor = progressFillColor;
    self.shapeLayer.fillColor = progressFillColor.CGColor;
}

- (void)setProgressStrokeColor:(UIColor *)progressStrokeColor {
    _progressStrokeColor = progressStrokeColor;
    self.shapeLayer.strokeColor = progressStrokeColor.CGColor;
}

@end
