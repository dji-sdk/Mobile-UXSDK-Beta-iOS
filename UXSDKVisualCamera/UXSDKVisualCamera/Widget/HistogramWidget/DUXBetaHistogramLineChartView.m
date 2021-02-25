//
//  DUXBetaHistogramLineChartView.m
//  UXSDKVisualCamera
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

#import "DUXBetaHistogramLineChartView.h"
#import <UXSDKCore/UIColor+DUXBetaColors.h>

#define GRID_WIDTH 2
#define MAX_VALUE 256
#define NUM_DATA_POINTS 64

@interface CPoint: NSObject

- (id)initWithX:(float)x andY:(float)y;
@property float x;
@property float y;
@property float dx;
@property float dy;

@end

@implementation CPoint

- (id)init {
    self = [super init];
    if (self) {
        self.x = 0;
        self.y = 0;
        self.dx = 0;
        self.dy = 0;
    }
    return self;
}

- (id)initWithX:(float)x andY:(float)y {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.dx = 0;
        self.dy = 0;
    }
    return self;
}

@end

@interface DUXBetaHistogramLineChartView ()

@property (strong, nonatomic) NSMutableArray <CPoint *> *points;
@property float xInterval;
@property float yInterval;
@property float yOffset;
@property int columnCount;
@property UIBezierPath *graph;

@end

@implementation DUXBetaHistogramLineChartView

- (id)init {
    self = [super init];
    if (self) {
        _data = [NSArray new];
        _enableCubic = YES;
        _cubicIntensity = 0.2;
        _drawGrid = YES;
        _points = [NSMutableArray new];
        _xInterval = 0;
        _yInterval = 0;
        _yOffset = 0;
        _columnCount = 5;
        _bgColor = [UIColor uxsdk_blackAlpha50];
        _fillColor = [UIColor uxsdk_whiteAlpha70];
        _lineColor = [UIColor uxsdk_whiteAlpha20];
        _gridColor = [UIColor uxsdk_whiteAlpha20];
        _graph = [UIBezierPath new];
        
        self.opaque = NO;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)setData:(NSArray<NSNumber *> *)data {
    _data = data;
    if (self.xInterval != 0) {
        [self transformDataToPoints];
        [self resetPath];
        [self setNeedsDisplay];
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)setGridColor:(UIColor *)gridColor {
    _gridColor = gridColor;
    [self setNeedsDisplay];
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    [self setNeedsDisplay];
}

- (void)setDrawGrid:(BOOL)drawGrid {
    _drawGrid = drawGrid;
    [self setNeedsDisplay];
}

- (void)setEnableCubic:(BOOL)enableCubic {
    _enableCubic = enableCubic;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self calculateInterval];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGRect background = rect;
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillRect(context, background);
    
    CGContextSetAllowsAntialiasing(context, NO);
    if (self.drawGrid) {
        [self drawGridLinesWithContext:context];
    }
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    [self.graph fill];
    [self.graph stroke];
}

- (void)drawGridLinesWithContext:(CGContextRef)context {
    
    CGContextSetLineWidth(context, GRID_WIDTH);
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextStrokeRect(context ,CGRectInset(self.bounds, 1 , 1));
    
    CGFloat columnWidth = self.bounds.size.width / self.columnCount;
    for (int i = 1; i < self.columnCount; i++) {
        CGContextMoveToPoint(context, columnWidth * i, 0.0);
        CGContextAddLineToPoint(context, columnWidth * i, self.bounds.size.height);
        CGContextSetFillColorWithColor(context, self.gridColor.CGColor);
        CGContextStrokePath(context);
    }
}

- (void)calculateInterval {
    self.yOffset = 20;
    self.xInterval = self.bounds.size.width / (NUM_DATA_POINTS - 1);
    self.yInterval = (self.bounds.size.height - self.yOffset) / MAX_VALUE;
}

- (void)transformDataToPoints {
    [self.points removeAllObjects];
    if (self.data != nil && self.data.count > 1) {
        [self.points addObject:[[CPoint alloc] initWithX:0 andY:self.bounds.size.height - [self.data objectAtIndex:0].floatValue * self.yInterval]];
        NSUInteger length = self.data.count;
        for (int j = 1; j < length - 1; j++) {
            [self.points addObject:[[CPoint alloc] initWithX:j * self.xInterval andY:self.bounds.size.height - [self.data objectAtIndex:j].floatValue * self.yInterval]];
        }
        [self.points addObject:[[CPoint alloc] initWithX:self.bounds.size.width andY:self.bounds.size.height - [self.data objectAtIndex:length - 1].floatValue * self.yInterval]];
    }
}

- (void)resetPath {
    if (self.enableCubic) {
        [self resetCubicPath];
    } else {
        [self resetLinearPath];
    }
}

- (void)resetCubicPath {
    [self.graph removeAllPoints];
    if (self.points.count != 0) {
        for (int i = 0; i < self.points.count; i++) {
            CPoint *point = self.points[i];
            if (i == 0) {
                CPoint *nextPoint = self.points[i+1];
                nextPoint.dx = (nextPoint.x - point.x) * self.cubicIntensity;
                nextPoint.dy = (nextPoint.y - point.y) * self.cubicIntensity;
                [self.graph moveToPoint:CGPointMake(point.x, point.y)];
            } else if (i == self.points.count - 1) {
                CPoint *previousPoint = self.points[i-1];
                point.dx = (point.x - previousPoint.x) * self.cubicIntensity;
                point.dy = (point.y - previousPoint.y) * self.cubicIntensity;
                [self.graph addCurveToPoint:CGPointMake(point.x, point.y) controlPoint1:CGPointMake(previousPoint.x + previousPoint.dx, previousPoint.y + previousPoint.dy) controlPoint2:CGPointMake(point.x - point.dx, point.y - point.dy)];
            } else {
                CPoint *nextPoint = self.points[i+1];
                CPoint *previousPoint = self.points[i-1];
                point.dx = (nextPoint.x - previousPoint.x) * self.cubicIntensity;
                point.dy = (nextPoint.y - previousPoint.y) * self.cubicIntensity;
                [self.graph addCurveToPoint:CGPointMake(point.x, point.y) controlPoint1:CGPointMake(previousPoint.x + previousPoint.dx, previousPoint.y + previousPoint.dy) controlPoint2:CGPointMake(point.x - point.dx, point.y - point.dy)];
            }
        }
        [self.graph addLineToPoint:CGPointMake(self.points[self.points.count - 1].x, self.bounds.size.height)];
        [self.graph addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    }
    [self.graph closePath];
}

- (void)resetLinearPath {
    [self.graph removeAllPoints];
    if (self.points.count != 0) {
        [self.graph moveToPoint:CGPointMake(self.points[0].x, self.points[0].y)];
        for (int i = 1; i < self.points.count; i++) {
            CPoint *p = self.points[i];
            [self.graph addLineToPoint:CGPointMake(p.x, p.y)];
        }
        [self.graph addLineToPoint:CGPointMake(self.points[self.points.count - 1].x, self.frame.size.height)];
        [self.graph addLineToPoint:CGPointMake(0, self.frame.size.height)];
    }
    [self.graph closePath];
}

@end
