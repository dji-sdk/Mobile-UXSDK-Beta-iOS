//
//  DUXBetaManualZoomWidget.m
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

#import <QuartzCore/QuartzCore.h>
#import "DUXBetaManualZoomWidget.h"
#import "DUXBetaManualZoomWidgetModel.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIFont+DUXBetaFonts.h>
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static const CGSize kDesignSize = {20.0, 100.0};
static const CGFloat kDesignButtonHeight = 15.0;
static const CGFloat kDesignCenterBarHeight = 10.0;
static const NSInteger kNumberOfBarsVisibleInScrollView = 10;

@interface DUXBetaManualZoomWidget () <UIScrollViewDelegate>

@property (nonatomic) UIButton *topButton;
@property (nonatomic) UIButton *bottomButton;
@property (nonatomic) UIView *centerBarView;
@property (nonatomic) UILabel *centerBarLabel;

@property (nonatomic) UIView *scrollGradientContainerView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *scrollContentView;

@property BOOL needsToUpdateModel;

@property CGFloat aspectRatio;

@property (nonatomic) NSTimer *scrollTimer;
@property (nonatomic) NSTimer *focalLengthUpdateTimer;

@end

@implementation DUXBetaManualZoomWidget

/*********************************************************************************/
#pragma mark - Initializer
/*********************************************************************************/

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundColor = [UIColor uxsdk_blackAlpha60];
        _buttonBackgroundColor = [UIColor uxsdk_blackAlpha20];
        _barsColor = [UIColor uxsdk_whiteColor];
        _centerBarColor = [UIColor uxsdk_whiteColor];
        _textFontColor = [UIColor uxsdk_blackColor];
        
        _topImage = [UIImage duxbeta_imageWithAssetNamed:@"Plus" forClass:[self class]];
        _bottomImage = [UIImage duxbeta_imageWithAssetNamed:@"Minus" forClass:[self class]];
        _aspectRatio = kDesignSize.width / kDesignSize.height;
    }
    return self;
}

/*********************************************************************************/
#pragma mark - View Lifecycle Methods
/*********************************************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaManualZoomWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(animateWidgetVisibility), shouldShowWidget);
    BindRKVOModel(self.widgetModel, @selector(focalLengthRangeChanged), minFocalLength, maxFocalLength);
    BindRKVOModel(self.widgetModel, @selector(currentFocalLengthChanged), currentFocalLength);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

/*********************************************************************************/
#pragma mark - Widget UI Setup And Update Methods
/*********************************************************************************/

- (void)setupUI {
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = self.backgroundColor;
    
    self.topButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.topButton addTarget:self action:@selector(topButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.topButton setImage:self.topImage forState:UIControlStateNormal];
    [self.view addSubview:self.topButton];
    
    self.bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomButton addTarget:self action:@selector(bottomButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomButton setImage:self.bottomImage forState:UIControlStateNormal];
    [self.view addSubview:self.bottomButton];
    
    self.centerBarView = [[UIView alloc] init];
    self.centerBarView.userInteractionEnabled = NO;
    [self.view addSubview:self.centerBarView];
    
    self.centerBarLabel = [[UILabel alloc] init];
    self.centerBarLabel.adjustsFontSizeToFitWidth = YES;
    self.centerBarLabel.textAlignment = NSTextAlignmentCenter;
    self.centerBarLabel.font = [UIFont boldSystemFontOfSize:10];
    [self.centerBarView addSubview:self.centerBarLabel];
    
    self.scrollGradientContainerView = [[UIView alloc] init];
    [self.view insertSubview:self.scrollGradientContainerView belowSubview:self.centerBarView];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.pinchGestureRecognizer.enabled = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    [self.scrollGradientContainerView addSubview:self.scrollView];
    
    //configure scroll view content
    self.scrollContentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.scrollContentView];
    
    self.scrollGradientContainerView.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollContentView.backgroundColor = [UIColor clearColor];
    
    self.view.hidden = YES;
    [self setupConstraints];
    [self customizeUI];
}

- (void)setupConstraints {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.topButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.centerBarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.centerBarLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollGradientContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:self.aspectRatio].active = YES;
    
    CGFloat imageToSelfRatio = kDesignButtonHeight / kDesignSize.height;
    
    [self.topButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageToSelfRatio].active = YES;
    [self.topButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.topButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.topButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
    [self.bottomButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageToSelfRatio].active = YES;
    [self.bottomButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.bottomButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.bottomButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
    CGFloat centerBarToSelfRatio = kDesignCenterBarHeight / kDesignSize.height;
    
    [self.centerBarView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.centerBarView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.centerBarView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.centerBarView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:centerBarToSelfRatio].active = YES;
    
    [self.centerBarLabel.topAnchor constraintEqualToAnchor:self.centerBarView.topAnchor].active = YES;
    [self.centerBarLabel.bottomAnchor constraintEqualToAnchor:self.centerBarView.bottomAnchor].active = YES;
    [self.centerBarLabel.leadingAnchor constraintEqualToAnchor:self.centerBarView.leadingAnchor].active = YES;
    [self.centerBarLabel.trailingAnchor constraintEqualToAnchor:self.centerBarView.trailingAnchor].active = YES;
    
    [self.scrollGradientContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.scrollGradientContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.scrollGradientContainerView.topAnchor constraintEqualToAnchor:self.topButton.bottomAnchor].active = YES;
    [self.scrollGradientContainerView.bottomAnchor constraintEqualToAnchor:self.bottomButton.topAnchor].active = YES;
    
    [self addFocusMarksWithNumberOfBars: (self.widgetModel.maxFocalLength - self.widgetModel.minFocalLength)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutScrollContentView];
}

- (void)layoutScrollContentView {
    if (self.scrollGradientContainerView.bounds.size.height == 0 ||
        self.scrollGradientContainerView.bounds.size.width == 0) {
        return;
    }
    
    self.scrollView.frame = self.scrollGradientContainerView.bounds;
    
    //math for calculating height of the content view.
    // this will give us the relative height of each "section" we then will place the bars inside of these sections later on.
    CGFloat relativeHeightOfSection = self.scrollGradientContainerView.frame.size.height/kNumberOfBarsVisibleInScrollView;
    //now that we know how many sections that are needed we multiply this by the total number of bars + the scrollview height.  We use the scrollview height because the top and bottom have half the height of the scrollview in padding.
    CGFloat heightOfContentView = relativeHeightOfSection * (self.widgetModel.maxFocalLength - self.widgetModel.minFocalLength) + self.scrollView.frame.size.height;

    self.scrollContentView.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, heightOfContentView);
    [self.scrollView setContentSize:(CGSizeMake(self.scrollContentView.frame.size.width, heightOfContentView))];
    
    //Gradient setup code
    NSObject *transparent = (NSObject *) [[UIColor colorWithWhite:0 alpha:0] CGColor];
    NSObject *opaque = (NSObject *) [[UIColor colorWithWhite:0 alpha:1] CGColor];
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.scrollGradientContainerView.bounds;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.scrollGradientContainerView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects: transparent, opaque, opaque, transparent, nil];
    
    // Set percentage of scrollview that fades at top & bottom
    gradientLayer.locations = [NSArray arrayWithObjects: @(0.0), @(0.4), @(1.0 - 0.4), @(1.0), nil];
    [maskLayer addSublayer:gradientLayer];
    self.scrollGradientContainerView.layer.mask = maskLayer;
    
    for (int i=0; i<self.scrollContentView.subviews.count; i++) {
        UIView *barView = self.scrollContentView.subviews[i];
        barView.frame = CGRectMake(0, 0, self.scrollContentView.bounds.size.width * 0.8, self.scrollView.bounds.size.height * 0.015);
        barView.center = self.scrollContentView.center;
        CGFloat y = i * relativeHeightOfSection + (self.scrollView.frame.size.height/2);
        barView.frame = CGRectMake(barView.frame.origin.x, y, barView.bounds.size.width, barView.bounds.size.height);
    }
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = self.view.bounds.size.width / 10;
    [self scrollToFocalLength:self.widgetModel.currentFocalLength animated:NO needsToUpdateModel:NO];
}

/*********************************************************************************/
#pragma mark - RKVO Callbacks
/*********************************************************************************/

- (void)currentFocalLengthChanged {
    if (self.focalLengthUpdateTimer) {
        [self.focalLengthUpdateTimer invalidate];
    }
    self.focalLengthUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self scrollToFocalLength:self.widgetModel.currentFocalLength animated:YES needsToUpdateModel:NO];
    }];
}

- (void)focalLengthRangeChanged {
    [self addFocusMarksWithNumberOfBars: (self.widgetModel.maxFocalLength - self.widgetModel.minFocalLength)];
    [self.view layoutSubviews];
}

- (void)animateWidgetVisibility {
    float duration = 0.15;
    if (self.view.hidden && self.widgetModel.shouldShowWidget) {
        self.view.alpha = 0;
        self.view.hidden = NO;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.alpha = 1;
        } completion:^(BOOL finished) {}];
    } else if (!self.view.hidden && !self.widgetModel.shouldShowWidget) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.hidden = YES;
        });
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {}];
    }
}

/*********************************************************************************/
#pragma mark - Scroll View Methods
/*********************************************************************************/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.needsToUpdateModel) {
        //we need to map the offest to a value from 0 to MaxValue
        CGFloat offset = self.scrollView.contentOffset.y;
        //gives us what percentage of the view we are at.  We need to subtract off the height of the scrollview because we would never be able to get the ratio to be 1 at the bottom because of padding.
        CGFloat contentViewRatio = offset/(self.scrollContentView.frame.size.height - self.scrollView.frame.size.height);
        
        NSInteger oldRingValue = self.widgetModel.currentFocalLength;
        NSInteger possibleNewValue;
        
        possibleNewValue = self.widgetModel.minFocalLength + ((self.widgetModel.maxFocalLength - self.widgetModel.minFocalLength) * contentViewRatio);
        
        //There is no point in spamming the aircraft with updates if we haven't moved at least 1 in our scrollview.  The setValue method takes an integer
        if (labs(possibleNewValue - oldRingValue) >= 1 && possibleNewValue <= self.widgetModel.maxFocalLength && possibleNewValue >= self.widgetModel.minFocalLength) {
            if (self.scrollTimer) {
                [self.scrollTimer invalidate];
            }
            self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [self.widgetModel zoomToFocalLength: possibleNewValue];
            }];
            [[NSRunLoop currentRunLoop] addTimer:self.scrollTimer forMode:NSRunLoopCommonModes];
        }
    }
    
    CGFloat relativeHeightOfSection = self.scrollView.frame.size.height / kNumberOfBarsVisibleInScrollView;
    if (self.widgetModel.shouldShowWidget && relativeHeightOfSection > 0) {
        float text = self.widgetModel.minFocalLength + self.scrollView.contentOffset.y / relativeHeightOfSection;
        self.centerBarLabel.text = [NSString stringWithFormat:@"%.1f mm",text];
    } else {
        self.centerBarLabel.text = [NSString stringWithFormat:@""];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.needsToUpdateModel = YES;
}

- (void)scrollToFocalLength:(float)focalLength animated:(BOOL)animated needsToUpdateModel:(BOOL)needsToUpdateModel {
    self.needsToUpdateModel = needsToUpdateModel;
    if (self.widgetModel.maxFocalLength <= self.widgetModel.minFocalLength ||
        focalLength < self.widgetModel.minFocalLength ||
        focalLength > self.widgetModel.maxFocalLength) {
        return;
    }
    CGFloat relativeHeightOfSection = self.scrollView.frame.size.height / kNumberOfBarsVisibleInScrollView;
    CGFloat heightOfContentView = relativeHeightOfSection * (self.widgetModel.maxFocalLength - self.widgetModel.minFocalLength) + self.scrollView.frame.size.height;
    CGFloat ratio = (CGFloat)(self.widgetModel.maxFocalLength - focalLength) / (CGFloat)(self.widgetModel.maxFocalLength - self.widgetModel.minFocalLength);
    CGFloat offset = (1.0 - ratio) * (heightOfContentView - self.scrollView.frame.size.height);
    [self.scrollView setContentOffset:CGPointMake(0, offset) animated:animated];
}

/*********************************************************************************/
#pragma mark - Button pressed methods
/*********************************************************************************/

- (void)bottomButtonPressed {
    [self scrollToFocalLength:self.widgetModel.currentFocalLength - 1 animated:YES needsToUpdateModel:YES];
}

- (void)topButtonPressed {
    [self scrollToFocalLength:self.widgetModel.currentFocalLength + 1 animated:YES needsToUpdateModel:YES];
}
/*********************************************************************************/
#pragma mark - Customization Methods
/*********************************************************************************/

- (void)addFocusMarksWithNumberOfBars:(NSUInteger) numberOfBarsInContentViewOverall {
    [self.scrollContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for(int i=0; i<numberOfBarsInContentViewOverall; i++) {
        UIView *barView = [[UIView alloc] init];
        barView.backgroundColor = self.barsColor;
        barView.translatesAutoresizingMaskIntoConstraints = NO;
        barView.layer.cornerRadius = 1;
        barView.layer.masksToBounds = true;
        [self.scrollContentView addSubview:barView];
    }
}

- (void)customizeUI {
    self.view.backgroundColor = self.backgroundColor;
    self.bottomButton.backgroundColor = self.buttonBackgroundColor;
    self.topButton.backgroundColor = self.buttonBackgroundColor;
    self.centerBarView.backgroundColor = self.barsColor;
    self.centerBarLabel.textColor = self.textFontColor;
    
    [self.topButton setImage:self.topImage forState:UIControlStateNormal];
    [self.bottomButton setImage:self.bottomImage forState:UIControlStateNormal];
    
    [self addFocusMarksWithNumberOfBars:(self.widgetModel.maxFocalLength - self.widgetModel.minFocalLength)];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self customizeUI];
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor {
    _buttonBackgroundColor = buttonBackgroundColor;
    [self customizeUI];
}

- (void)setBarsColor:(UIColor *)barsColor {
    _barsColor = barsColor;
    [self customizeUI];
}

- (void)setTopImage:(UIImage *)topImage {
    _topImage = topImage;
    [self customizeUI];
}

- (void)setBottomImage:(UIImage *)bottomImage {
    _bottomImage = bottomImage;
    [self customizeUI];
}

- (void)setTextFontColor:(UIColor *)textFontColor {
    _textFontColor = textFontColor;
    [self customizeUI];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
