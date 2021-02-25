//
//  DUXBetaManualFocusWidget.m
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

#import <QuartzCore/QuartzCore.h>
#import "DUXBetaManualFocusWidget.h"
#import "DUXBetaManualFocusWidgetModel.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIFont+DUXBetaFonts.h>
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static const CGSize kDesignSize = {20.0, 100.0};
static const CGFloat kDesignButtonHeight = 15.0;
static const NSInteger kNumberOfBarsVisibleInScrollView = 10;

@interface DUXBetaManualFocusWidget () <UIScrollViewDelegate>

@property (nonatomic) UIButton *topButton;
@property (nonatomic) UIButton *bottomButton;
@property (nonatomic) UIView *centerBarView;
@property (nonatomic) UIView *scrollGradientContainerView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *scrollContentView;

@property NSTimeInterval timeIntervalSinceScrolling;

@property CGFloat aspectRatio;

@end

@implementation DUXBetaManualFocusWidget

/*********************************************************************************/
#pragma mark - Initializer
/*********************************************************************************/

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundColor = [UIColor uxsdk_blackAlpha60];
        _buttonBackgroundColor = [UIColor uxsdk_blackAlpha20];
        _barsColor = [UIColor uxsdk_whiteColor];
        
        _topImage = [UIImage duxbeta_imageWithAssetNamed:@"MacroFocus" forClass:[self class]];
        _bottomImage = [UIImage duxbeta_imageWithAssetNamed:@"InfinityFocus" forClass:[self class]];
        
        _timeIntervalSinceScrolling = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

/*********************************************************************************/
#pragma mark - View Lifecycle Methods
/*********************************************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaManualFocusWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(animateWidgetVisibility), shouldShowWidget);
    BindRKVOModel(self.widgetModel, @selector(focusRingUpperBoundChanged), focusRingUpperBound);
    BindRKVOModel(self.widgetModel, @selector(focusRingValueChanged), focusRingValue);
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
    
    self.aspectRatio = kDesignSize.width / kDesignSize.height;
        
    self.topButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.topButton addTarget:self action:@selector(topButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.topButton];
    
    self.bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomButton addTarget:self action:@selector(bottomButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomButton];
    
    self.centerBarView = [[UIView alloc] init];
    self.centerBarView.userInteractionEnabled = NO;
    [self.view addSubview:self.centerBarView];
    
    self.scrollGradientContainerView = [[UIView alloc] init];
    self.scrollGradientContainerView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.scrollGradientContainerView belowSubview:self.centerBarView];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.pinchGestureRecognizer.enabled = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    [self.scrollGradientContainerView addSubview:self.scrollView];
    
    self.scrollContentView = [[UIView alloc] init];
    self.scrollContentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.scrollContentView];
    
    self.view.hidden = YES;
    [self setupConstraints];
    [self customizeUI];
}

- (void)setupConstraints {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.topButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.centerBarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollGradientContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    CGFloat centerBarToSelfRatio = 5.0 / kDesignSize.height;
    [self.centerBarView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.centerBarView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.centerBarView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.centerBarView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:centerBarToSelfRatio].active = YES;
    
    [self.scrollGradientContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.scrollGradientContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.scrollGradientContainerView.topAnchor constraintEqualToAnchor:self.topButton.bottomAnchor].active = YES;
    [self.scrollGradientContainerView.bottomAnchor constraintEqualToAnchor:self.bottomButton.topAnchor].active = YES;
    
    [self addFocusMarksWithNumberOfBars: self.widgetModel.focusRingUpperBound];
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
    
    int numberOfBars = self.widgetModel.focusRingUpperBound == 0 ? 100 : self.widgetModel.focusRingUpperBound;
    
    //math for calculating height of the content view.
    // this will give us the relative height of each "section" we then will place the bars inside of these sections later on.
    CGFloat relativeHeightOfSection = self.scrollGradientContainerView.frame.size.height/kNumberOfBarsVisibleInScrollView;
    //now that we know how many sections that are needed we multiply this by the total number of bars + the scrollview height.  We use the scrollview height because the top and bottom have half the height of the scrollview in padding.
    CGFloat heightOfContentView = relativeHeightOfSection * (numberOfBars / 6) + self.scrollView.frame.size.height;
    
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
    self.view.layer.cornerRadius = self.view.bounds.size.width / 10;
}

/*********************************************************************************/
#pragma mark - RKVO Callbacks
/*********************************************************************************/

- (void)focusRingUpperBoundChanged {
    [self addFocusMarksWithNumberOfBars: self.widgetModel.focusRingUpperBound];
    [self scrollToCurrentFocalLengthAnimated:NO];
}

- (void)focusRingValueChanged {
    if ([[NSDate date] timeIntervalSince1970] - self.timeIntervalSinceScrolling > 1.0) {
        if (self.widgetModel.focusRingUpperBound != 0) {
            //update the view now that it is setup;
            CGFloat ratio = (CGFloat)self.widgetModel.focusRingValue/self.widgetModel.focusRingUpperBound;
            CGFloat offset = ratio * (self.scrollContentView.frame.size.height - self.scrollView.frame.size.height);
            [self.scrollView setContentOffset:CGPointMake(0, offset)];
        }
    }
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
    self.timeIntervalSinceScrolling = [[NSDate date] timeIntervalSince1970];
    
    //we need to map the offest to a value from 0 to MaxValue
    CGFloat offset = self.scrollView.contentOffset.y;
    //gives us what percentage of the view we are at.  We need to subtract off the height of the scrollview because we would never be able to get the ratio to be 1 at the bottom because of padding.
    CGFloat contentViewRatio = offset/(self.scrollContentView.frame.size.height - self.scrollView.frame.size.height);
    
    NSInteger oldFocusRingValue = self.widgetModel.focusRingValue;
    NSInteger possibleNewValue = self.widgetModel.focusRingUpperBound * contentViewRatio;
    
    //There is no point in spamming the aircraft with updates if we haven't moved at least 1 in our scrollview.  The setValue method takes an integer
    if (labs(possibleNewValue - oldFocusRingValue) >= 1 && possibleNewValue <= self.widgetModel.focusRingUpperBound) {
        [[DJISDKManager keyManager] setValue:@(possibleNewValue) forKey:[DJICameraKey keyWithIndex:self.widgetModel.preferredCameraIndex andParam:DJICameraParamFocusRingValue] withCompletion:^(NSError * _Nullable error) {}];
    }
}

- (void)scrollToCurrentFocalLengthAnimated:(BOOL)animated {
    if (self.widgetModel.focusRingUpperBound <= 0) {
        return;
    }
    CGFloat relativeHeightOfSection = self.scrollView.frame.size.height / kNumberOfBarsVisibleInScrollView;
    CGFloat heightOfContentView = relativeHeightOfSection * self.widgetModel.focusRingUpperBound / 6 + self.scrollView.frame.size.height;
    CGFloat ratio = (CGFloat)(self.widgetModel.focusRingUpperBound - self.widgetModel.focusRingValue) / (CGFloat)(self.widgetModel.focusRingUpperBound);
    CGFloat offset = (1.0 - ratio) * (heightOfContentView - self.scrollView.frame.size.height);
    [self.scrollView setContentOffset:CGPointMake(0, offset) animated:animated];
}

/*********************************************************************************/
#pragma mark - Button pressed methods
/*********************************************************************************/

- (void)topButtonPressed {
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollContentView.frame.size.height - self.scrollView.frame.size.height) animated:YES];
}

- (void)bottomButtonPressed {
    __weak typeof(self) weakSelf = self;
    [[DJISDKManager keyManager] setValue:@(self.widgetModel.infinityFocusValue)
                                  forKey:[DJICameraKey keyWithIndex:self.widgetModel.preferredCameraIndex andParam:DJICameraParamFocusRingValue]
                          withCompletion:^(NSError * _Nullable error) {
                              [weakSelf scrollToCurrentFocalLengthAnimated:YES];
                          }];
}

/*********************************************************************************/
#pragma mark - Customization Methods
/*********************************************************************************/

- (void)addFocusMarksWithNumberOfBars:(NSUInteger) numberOfBarsInContentViewOverall {
    if (numberOfBarsInContentViewOverall == 0) { numberOfBarsInContentViewOverall = 100; }
    [self.scrollContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for(int i=0; i<numberOfBarsInContentViewOverall / 6; i++) {
        UIView *barView = [[UIView alloc] init];
        barView.backgroundColor = self.barsColor;
        barView.translatesAutoresizingMaskIntoConstraints = NO;
        barView.layer.cornerRadius = 1;
        barView.layer.masksToBounds = true;
        [self.scrollContentView addSubview:barView];
    }
    [self.view setNeedsLayout];
}

- (void)customizeUI {
    self.view.backgroundColor = self.backgroundColor;
    self.centerBarView.backgroundColor = [UIColor whiteColor];
    self.topButton.backgroundColor = self.buttonBackgroundColor;
    self.bottomButton.backgroundColor = self.buttonBackgroundColor;
    
    [self.topButton setImage:self.topImage forState:UIControlStateNormal];
    [self.bottomButton setImage:self.bottomImage forState:UIControlStateNormal];
    
    [self addFocusMarksWithNumberOfBars:self.widgetModel.focusRingUpperBound];
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

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
