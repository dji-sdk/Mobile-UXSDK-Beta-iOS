//
//  DUXBetaGimbalPitchWidget.m
//  UXSDKCameraCore
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

#import "DUXBetaGimbalPitchWidget.h"
#import "DUXBetaGimbalPitchView.h"
#import <UXSDKCore/UIFont+DUXBetaFonts.h>
#import <UXSDKCore/UIColor+DUXBetaColors.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define DEVICE_SIZE_RATE(x)         (IS_IPAD?(1.5*(x)):(x))
#define INDICATOR_THICK             DEVICE_SIZE_RATE(1.5)
#define INDICATOR_INTERVAL          ((int)DEVICE_SIZE_RATE(10.0))
#define INDICATOR_MIN_Y             INDICATOR_INTERVAL
#define LINE_LENGTH_RATE            (0.48)
#define weakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define strongSelf(__TARGET__, __WEAK__) typeof(self) __TARGET__=__WEAK__
#ifdef weakReturn
#undef weakReturn
#endif
#define weakReturn(__TARGET__) __strong typeof(__TARGET__) __strong##__TARGET__ = __TARGET__; \
if(__strong##__TARGET__==nil)return;

static CGSize const kDesignSize = {30, 100};

@interface DUXBetaGimbalPitchWidget ()

@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic, strong) UIView *gimbalPitchIndicatorsView;
@property (assign, nonatomic) NSInteger numberOfGimbalLines;
@property (nonatomic, strong) NSLayoutConstraint *gimbalPitchLabelLocationConstraint;
@property (nonatomic, strong) NSLayoutConstraint *gimbalCircleIndicatorLocationConstraint;
@property (nonatomic, strong) DUXBetaGimbalPitchView *gimbalPitchLabel;

@end

@implementation DUXBetaGimbalPitchWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _stableBoundIndicatorColor = [UIColor uxsdk_selectedBlueColor];
        _upperBoundWarningIndicatorColor = [UIColor uxsdk_errorDangerColor];
        _lowerWarningBoundIndicatorColor = [UIColor uxsdk_errorDangerColor];
        _generalPitchCircleIndicatorColor = [UIColor uxsdk_whiteColor];
        
        _positivePitchBackgroundColor = [UIColor uxsdk_blackColor];
        _linesColor = [UIColor uxsdk_whiteColor];
        _horizontalLineColor = [UIColor uxsdk_errorDangerColor];
        
        _gimbalPitchLabel = [[DUXBetaGimbalPitchView alloc] init];
        _gimbalPitchLabelFont = _gimbalPitchLabel.pitchLabel.font;
        _gimbalPitchLabelBackgroundColor = _gimbalPitchLabel.pitchLabel.backgroundColor;
        _gimbalPitchLabelTextColor = _gimbalPitchLabel.pitchLabel.textColor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaGimbalPitchWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(performFadeAnimation), widgetShouldFadeOut);
    BindRKVOModel(self.widgetModel, @selector(updateUI),state);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor clearColor];
    [self drawGimbalLines];
    [self setupGimbalPitchLabel];
    [self.view layoutIfNeeded];
}

- (void)drawGimbalLines {
    self.gimbalPitchIndicatorsView = [[UIView alloc] init];
    self.gimbalPitchIndicatorsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.gimbalPitchIndicatorsView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.gimbalPitchIndicatorsView];
    [self.gimbalPitchIndicatorsView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.gimbalPitchIndicatorsView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.gimbalPitchIndicatorsView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.gimbalPitchIndicatorsView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.25].active = YES;
    [self.view layoutIfNeeded];
    
    self.numberOfGimbalLines = 10;
    
    //Top Circle
    CAShapeLayer *topCircleLayer = [CAShapeLayer layer];
    [topCircleLayer setBounds:CGRectMake(0.0f, 0.0f, self.gimbalPitchIndicatorsView.frame.size.width - INDICATOR_THICK,self.gimbalPitchIndicatorsView.frame.size.width - INDICATOR_THICK)];
    [topCircleLayer setPosition:CGPointMake(self.gimbalPitchIndicatorsView.frame.size.width/2,self.gimbalPitchIndicatorsView.frame.size.width/2)];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:
                          CGRectMake(0.0f, 0.0f, self.gimbalPitchIndicatorsView.frame.size.width - INDICATOR_THICK, self.gimbalPitchIndicatorsView.frame.size.width - INDICATOR_THICK)];
    [topCircleLayer setPath:[path CGPath]];
    [topCircleLayer setStrokeColor:self.linesColor.CGColor];
    [topCircleLayer setLineWidth:INDICATOR_THICK];
    [topCircleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [[self.gimbalPitchIndicatorsView layer] addSublayer:topCircleLayer];
    
    //Bottom Circle
    CAShapeLayer *bottomCircleLayer = [CAShapeLayer layer];
    [bottomCircleLayer setBounds:CGRectMake(0.0f, 0.0f, self.gimbalPitchIndicatorsView.frame.size.width - INDICATOR_THICK,self.gimbalPitchIndicatorsView.frame.size.width - INDICATOR_THICK)];
    [bottomCircleLayer setPosition:CGPointMake(self.gimbalPitchIndicatorsView.frame.size.width/2,self.gimbalPitchIndicatorsView.frame.size.height - self.gimbalPitchIndicatorsView.frame.size.width/2)];
    path = [UIBezierPath bezierPathWithOvalInRect:
            CGRectMake(0.0f, 0.0f, self.gimbalPitchIndicatorsView.frame.size.width - INDICATOR_THICK, self.gimbalPitchIndicatorsView.frame.size.width - INDICATOR_THICK)];
    [bottomCircleLayer setPath:[path CGPath]];
    [bottomCircleLayer setStrokeColor:self.linesColor.CGColor];
    [bottomCircleLayer setLineWidth:INDICATOR_THICK];
    [bottomCircleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [[self.gimbalPitchIndicatorsView layer] addSublayer:bottomCircleLayer];
    
    //Start at the bottom of the top circle
    float startDrawingPosition = self.gimbalPitchIndicatorsView.frame.size.width * 2;
    
    //Total remaining space between the top and bottom circles to draw lines
    float avaliableDrawingHeight = self.gimbalPitchIndicatorsView.frame.size.height - self.gimbalPitchIndicatorsView.frame.size.width * 2;
    
    float spaceBetweenLines = avaliableDrawingHeight / (self.numberOfGimbalLines + 1);
    
    for (int i = 0; i < self.numberOfGimbalLines; i++) {
        CAShapeLayer *gimbalLine = [CAShapeLayer layer];
        [gimbalLine setBounds:CGRectMake(0.0f, 0.0f, self.gimbalPitchIndicatorsView.frame.size.width,self.gimbalPitchIndicatorsView.frame.size.width)];
        [gimbalLine setPosition:CGPointMake(self.gimbalPitchIndicatorsView.frame.size.width/2,startDrawingPosition + spaceBetweenLines/2)];
        
        path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.gimbalPitchIndicatorsView.frame.size.width, INDICATOR_THICK/2)];
        [gimbalLine setPath:[path CGPath]];
        //3rd line needs to be red, also draw black background
        if (i == 2) {
            [gimbalLine setStrokeColor:self.horizontalLineColor.CGColor];
            [gimbalLine setFillColor:self.horizontalLineColor.CGColor];
            
            CAShapeLayer *blackBackground = [CAShapeLayer layer];
            blackBackground.backgroundColor = self.positivePitchBackgroundColor.CGColor;
            blackBackground.cornerRadius = self.gimbalPitchIndicatorsView.frame.size.width/2;
            blackBackground.opacity = 0.2;
            [blackBackground setBounds:CGRectMake(0.0f, 0.0f, self.gimbalPitchIndicatorsView.frame.size.width,self.gimbalPitchIndicatorsView.frame.size.width)];
            [blackBackground setPosition:CGPointMake(self.gimbalPitchIndicatorsView.frame.size.width/2,self.gimbalPitchIndicatorsView.frame.size.width/2)];
            
            UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.gimbalPitchIndicatorsView.frame.size.width, startDrawingPosition + INDICATOR_THICK)];
            [blackBackground setPath:[backgroundPath CGPath]];
            [[self.gimbalPitchIndicatorsView layer] insertSublayer:blackBackground below:topCircleLayer];
        } else {
            [gimbalLine setStrokeColor:self.linesColor.CGColor];
            [gimbalLine setFillColor:self.linesColor.CGColor];
        }
        gimbalLine.cornerRadius = INDICATOR_THICK/2;
        [[self.gimbalPitchIndicatorsView layer] addSublayer:gimbalLine];
        startDrawingPosition = startDrawingPosition + spaceBetweenLines;
    }
    self.gimbalPitchIndicatorsView.layer.cornerRadius = self.gimbalPitchIndicatorsView.frame.size.width/2;
    self.gimbalPitchIndicatorsView.clipsToBounds = YES;
}

- (void)setupGimbalPitchLabel {
    self.gimbalPitchLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.gimbalPitchLabel];
    [self.gimbalPitchLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.gimbalPitchLabel.heightAnchor constraintEqualToConstant:25].active = YES;
    self.gimbalPitchLabelLocationConstraint = [self.gimbalPitchLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.gimbalPitchIndicatorsView.frame.size.height/2];
    self.gimbalPitchLabelLocationConstraint.active = YES;
    [self.gimbalPitchLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    self.useGimbalPitchLabel = YES;
    
    self.indicatorView = [[UIView alloc] init];
    self.indicatorView.backgroundColor = [UIColor whiteColor];
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.indicatorView belowSubview:self.gimbalPitchLabel];
    
    [self.indicatorView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.indicatorView.widthAnchor constraintEqualToConstant:self.gimbalPitchIndicatorsView.frame.size.width + 5].active = YES;
    [self.indicatorView.heightAnchor constraintEqualToConstant:self.gimbalPitchIndicatorsView.frame.size.width + 5].active = YES;
    self.gimbalCircleIndicatorLocationConstraint = [self.indicatorView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.gimbalPitchIndicatorsView.frame.size.height/2];
    self.gimbalCircleIndicatorLocationConstraint.active = YES;
    self.indicatorView.layer.cornerRadius = (self.gimbalPitchIndicatorsView.frame.size.width + 5)/2;
    
    if (self.useGimbalPitchLabel) {
        self.indicatorView.alpha = 0.0;
    }
}

- (void)updateUI {
    if (self.view.frame.size.height > 0) {
        self.indicatorView.backgroundColor = [self indicatorColorForPitchLocation:self.widgetModel.state.currentPitchValue];
        self.gimbalCircleIndicatorLocationConstraint.constant = [self gimbalCircleIndicatorLocationForPitch:self.widgetModel.state.currentPitchValue];
        if (self.useGimbalPitchLabel && self.widgetModel.state.currentPitchValue >= self.widgetModel.upperWarningBound) {
            self.indicatorView.alpha = 1 - (float)(self.widgetModel.state.maxPitch - self.widgetModel.state.currentPitchValue)/(self.widgetModel.state.maxPitch - self.widgetModel.upperWarningBound);
            self.gimbalCircleIndicatorLocationConstraint.constant = [self gimbalLocationForPitch:self.widgetModel.upperWarningBound];
        } else if (self.useGimbalPitchLabel && self.widgetModel.state.currentPitchValue <= self.widgetModel.lowerWarningBound) {
            self.indicatorView.alpha = 1 - (float)(self.widgetModel.state.minPitch - self.widgetModel.state.currentPitchValue)/(self.widgetModel.state.minPitch - self.widgetModel.lowerWarningBound);
            self.gimbalPitchLabelLocationConstraint.constant = [self gimbalLocationForPitch:self.widgetModel.lowerWarningBound];
        } else if (self.useGimbalPitchLabel) {
            self.gimbalPitchLabelLocationConstraint.constant = [self gimbalLocationForPitch:self.widgetModel.state.currentPitchValue];
            self.indicatorView.alpha = 0.0;
        }
    }
}

- (float)gimbalCircleIndicatorLocationForPitch:(NSInteger)pitch {
    NSInteger totalRangeOfValues = labs(self.widgetModel.state.maxPitch) + labs(self.widgetModel.state.minPitch);
    float heightForOnePitchDegree = (self.view.frame.size.height - self.indicatorView.frame.size.height)/(float)totalRangeOfValues;
    if (pitch >= 0) {
        return heightForOnePitchDegree * (self.widgetModel.state.maxPitch - pitch);
    } else {
        return heightForOnePitchDegree * (self.widgetModel.state.maxPitch + labs(pitch));
    }
}

- (float)gimbalLocationForPitch:(NSInteger)pitch {
    NSInteger totalRangeOfValues = labs(self.widgetModel.state.maxPitch) + labs(self.widgetModel.state.minPitch);
    float heightForOnePitchDegree = (self.view.frame.size.height - self.gimbalPitchLabel.frame.size.height)/(float)totalRangeOfValues;
    if (pitch >= 0) {
        return heightForOnePitchDegree * (self.widgetModel.state.maxPitch - pitch);
    } else {
        return heightForOnePitchDegree * (self.widgetModel.state.maxPitch + labs(pitch));
    }
}

- (UIColor *)indicatorColorForPitchLocation:(NSInteger)pitch {
    if (pitch <= self.widgetModel.stableRangeUpperBound && pitch >= self.widgetModel.stableRangeLowerBound) {
        return self.stableBoundIndicatorColor;
    } else if (pitch >= self.widgetModel.upperWarningBound) {
        return self.upperBoundWarningIndicatorColor;
    } else if (pitch <= self.widgetModel.lowerWarningBound) {
        return self.lowerWarningBoundIndicatorColor;
    } else {
        return self.generalPitchCircleIndicatorColor;
    }
}

- (void)performFadeAnimation {
    if (self.widgetModel.widgetShouldFadeOut) {
        [self fadeWidgetOut];
    } else {
        [self fadeWidgetIn];
    }
}

- (void)fadeWidgetIn {
    [UIView animateWithDuration:0.5f animations:^{
        [self.view setAlpha:1.0];
    } completion:nil];
}

- (void)fadeWidgetOut {
    [UIView animateWithDuration:0.5f animations:^{
        [self.view setAlpha:0.2];
    } completion:nil];
}

- (void)setUseGimbalPitchLabel:(BOOL)useGimbalPitchLabel {
    _useGimbalPitchLabel = useGimbalPitchLabel;
    self.gimbalPitchLabel.hidden = !useGimbalPitchLabel;
}

- (void)setGimbalPitchLabelFont:(UIFont *)gimbalPitchLabelFont {
    _gimbalPitchLabelFont = gimbalPitchLabelFont;
    self.gimbalPitchLabel.pitchLabel.font = gimbalPitchLabelFont;
}

- (void)setGimbalPitchLabelTextColor:(UIColor *)gimbalPitchLabelTextColor {
    _gimbalPitchLabelTextColor = gimbalPitchLabelTextColor;
    self.gimbalPitchLabel.pitchLabel.textColor = gimbalPitchLabelTextColor;
}

- (void)setGimbalPitchLabelBackgroundColor:(UIColor *)gimbalPitchLabelBackgroundColor {
    _gimbalPitchLabelBackgroundColor = gimbalPitchLabelBackgroundColor;
    self.gimbalPitchLabel.pitchLabel.backgroundColor = gimbalPitchLabelBackgroundColor;
}

- (void)setLinesColor:(UIColor *)linesColor {
    _linesColor = linesColor;
    for (CALayer *layer in self.gimbalPitchIndicatorsView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    [self drawGimbalLines];
}

- (void)setHorizontalLineColor:(UIColor *)horizontalLineColor {
    _horizontalLineColor = horizontalLineColor;
    for (CALayer *layer in self.gimbalPitchIndicatorsView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    [self drawGimbalLines];
}

- (void)setStableBoundIndicatorColor:(UIColor *)stableBoundIndicatorColor {
    _stableBoundIndicatorColor = stableBoundIndicatorColor;
    [self updateUI];
}

- (void)setLowerWarningBoundIndicatorColor:(UIColor *)lowerWarningBoundIndicatorColor {
    _lowerWarningBoundIndicatorColor = lowerWarningBoundIndicatorColor;
    [self updateUI];
}

- (void)setUpperBoundWarningIndicatorColor:(UIColor *)upperBoundWarningIndicatorColor {
    _upperBoundWarningIndicatorColor = upperBoundWarningIndicatorColor;
    [self updateUI];
}

- (void)setGeneralPitchCircleIndicatorColor:(UIColor *)generalPitchCircleIndicatorColor {
    _generalPitchCircleIndicatorColor = generalPitchCircleIndicatorColor;
    [self updateUI];
}

- (void)setPositivePitchBackgroundColor:(UIColor *)positivePitchBackgroundColor {
    _positivePitchBackgroundColor = positivePitchBackgroundColor;
    for (CALayer *layer in self.gimbalPitchIndicatorsView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    [self drawGimbalLines];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
