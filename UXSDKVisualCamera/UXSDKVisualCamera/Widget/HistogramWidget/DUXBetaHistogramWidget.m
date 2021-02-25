//
//  DUXBetaHistogramWidget.m
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

#import "DUXBetaHistogramWidget.h"
#import "DUXBetaHistogramLineChartView.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIFont+DUXBetaFonts.h>


@interface DUXBetaHistogramWidget ()

@property (nonatomic, strong) DUXBetaHistogramLineChartView *lineChart;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation DUXBetaHistogramWidget

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel = [[DUXBetaHistogramWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self.widgetModel enableHistogramWithCompletionBlock:^(NSError * _Nullable error) {
        
    }];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateLineChart), histogramData);
    BindRKVOModel(self.widgetModel, @selector(updateVisibility), isHistogramEnabled);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.lineChart = [[DUXBetaHistogramLineChartView alloc] init];
    _histogramLineColor = self.lineChart.lineColor;
    _histogramFillColor = self.lineChart.fillColor;
    _histogramGridColor = self.lineChart.gridColor;
    _histogramBackgroundColor = self.lineChart.bgColor;
    _shouldDrawGrid = self.lineChart.drawGrid;
    _shouldDrawCubic = self.lineChart.enableCubic;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lineChart];
    self.lineChart.translatesAutoresizingMaskIntoConstraints = NO;

    [self.lineChart.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.lineChart.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.lineChart.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.lineChart.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;

    _shouldShowCloseButton = YES;
    self.closeButton = [[UIButton alloc] init];
    [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.hidden = NO;
    UIImage *closeButtonImage = [UIImage duxbeta_imageWithAssetNamed:@"Cancel" forClass:[self class]];
    [self.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [self.view addSubview:self.closeButton];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.closeButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.closeButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier: 0.17].active = YES;
    [self.closeButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.23].active = YES;
}

- (void)updateLineChart {
    self.lineChart.data = self.widgetModel.histogramData;
}

- (void)updateVisibility {
    self.lineChart.hidden = !self.widgetModel.isHistogramEnabled;
}

- (void)closeButtonPressed:(UIButton *)sender {
    [self.widgetModel disableHistogramWithCompletionBlock:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"There was an error disabling the histogram");
        }
        if ([self.delegate respondsToSelector:@selector(closeButtonPressedForWidget:)]) {
            [self.delegate closeButtonPressedForWidget:self];
        }
    }];
}

- (void)setShouldDrawGrid:(BOOL)shouldDrawGrid {
    _shouldDrawGrid = shouldDrawGrid;
    self.lineChart.drawGrid = shouldDrawGrid;
}

- (void)setShouldDrawCubic:(BOOL)shouldDrawCubic {
    _shouldDrawCubic = shouldDrawCubic;
    self.lineChart.enableCubic = shouldDrawCubic;
}

- (void)setHistogramFillColor:(UIColor *)histogramFillColor {
    _histogramFillColor = histogramFillColor;
    self.lineChart.fillColor = histogramFillColor;
}

- (void)setHistogramGridColor:(UIColor *)histogramGridColor {
    _histogramGridColor = histogramGridColor;
    self.lineChart.gridColor = histogramGridColor;
}

- (void)setHistogramLineColor:(UIColor *)histogramLineColor {
    _histogramLineColor = histogramLineColor;
    self.lineChart.lineColor = histogramLineColor;
}

- (void)setHistogramBackgroundColor:(UIColor *)histogramBackgroundColor {
    _histogramBackgroundColor = histogramBackgroundColor;
    self.lineChart.bgColor = histogramBackgroundColor;
}

- (void)setShouldShowCloseButton:(BOOL)shouldShowCloseButton {
    _shouldShowCloseButton = shouldShowCloseButton;
    self.closeButton.hidden = !shouldShowCloseButton;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {1.38, 18, 13};
    return hint;
}

@end
