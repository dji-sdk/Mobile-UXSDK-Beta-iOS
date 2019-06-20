//
//  DUXBetaTriangleView.m
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

#import "DUXBetaMapTriangleView.h"

@implementation DUXBetaMapTriangleView

- (instancetype)initWithFrame:(CGRect)frame withCurve:(BOOL)withCurve {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTriangle:frame addCurve:withCurve];
    }
    return self;
}

- (void)setupTriangle:(CGRect)frame addCurve:(BOOL)addCurve {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGPoint leftEndPoint = CGPointMake(0.0, frame.size.height);
    CGPoint topPoint = CGPointMake(frame.size.width / 2, 0.0);
    CGPoint rightEndPoint = CGPointMake(frame.size.width, frame.size.height);
    CGPoint middlePoint = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
    
    [path moveToPoint:leftEndPoint];
    [path addLineToPoint:topPoint];
    [path addLineToPoint:rightEndPoint];
    addCurve ?
    [path addQuadCurveToPoint:leftEndPoint controlPoint:middlePoint] :
    [path addLineToPoint:leftEndPoint];

    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = path.CGPath;
    
    // Masks the view to the layer / path created
    self.layer.mask = shapeLayer;
}

@end
