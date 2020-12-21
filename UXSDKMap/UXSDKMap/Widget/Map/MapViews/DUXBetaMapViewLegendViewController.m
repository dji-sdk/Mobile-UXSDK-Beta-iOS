//
//  DUXBetaMapViewLegendViewController.m
//  UXSDKMap
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

#import "DUXBetaMapViewLegendViewController.h"
#import "DUXBetaMapViewRenderer.h"

typedef NS_ENUM (NSUInteger, DUXBetaMapViewLegendCellType) {
    DUXBetaMapViewLegendCellTypeRestricted = 0,
    DUXBetaMapViewLegendCellTypeAuthorization = 1,
    DUXBetaMapViewLegendCellTypeEnhancedWarning = 2,
    DUXBetaMapViewLegendCellTypeWarning = 3,
    DUXBetaMapViewLegendCellTypeSelfUnlocked = 4,
    DUXBetaMapViewLegendCellTypeCustomUnlockNotSent = 5,
    DUXBetaMapViewLegendCellTypeCustomUnlockSentToAircraft = 6,
    DUXBetaMapViewLegendCellTypeCustomUnlockEnabled = 7,
};

@interface DUXBetaMapViewLegendCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat alpha;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation DUXBetaMapViewLegendCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.1;
        _titleLabel.numberOfLines = 4;
        _titleLabel.baselineAdjustment = UIBaselineAdjustmentNone;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0].active = YES;
        [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [_titleLabel.heightAnchor constraintEqualToConstant:70.0f].active = YES;
        [_titleLabel setNeedsLayout];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.titleLabel setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, rect.size.width-2, rect.size.width-2)] CGPath];
    self.shapeLayer.fillColor = [[self.color colorWithAlphaComponent:self.alpha] CGColor];
    self.shapeLayer.strokeColor = [self.color CGColor];
    [self.layer addSublayer:self.shapeLayer];
}

@end

static NSString *const DUXBetaMapViewLegendCollectionViewCellReuseIdentifier = @"DUXBetaMapViewLegendCollectionViewCellReuseIdentifier";

@interface DUXBetaMapViewLegendViewController ()

@end

@implementation DUXBetaMapViewLegendViewController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10.0f;
    layout.minimumInteritemSpacing = 5.0f;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    layout.itemSize = CGSizeMake(75.0, 145.0);
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[DUXBetaMapViewLegendCollectionViewCell class]
            forCellWithReuseIdentifier:DUXBetaMapViewLegendCollectionViewCellReuseIdentifier];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    visualEffectView.layer.cornerRadius = 7.0f;
    visualEffectView.layer.masksToBounds = YES;
    [self.view addSubview:visualEffectView];
    [self.view sendSubviewToBack:visualEffectView];
    [visualEffectView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [visualEffectView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [visualEffectView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [visualEffectView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [visualEffectView setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak typeof(self)target = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [target.collectionView flashScrollIndicators];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (UIColor *)colorForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [self.renderer flyZoneOverlayColorForFlyZoneCategory:DJIFlyZoneCategoryRestricted];
    } else if (indexPath.row == 1) {
        return [self.renderer flyZoneOverlayColorForFlyZoneCategory:DJIFlyZoneCategoryAuthorization];
    } else if (indexPath.row == 2) {
        return [self.renderer flyZoneOverlayColorForFlyZoneCategory:DJIFlyZoneCategoryEnhancedWarning];
    } else if (indexPath.row == 3) {
        return [self.renderer flyZoneOverlayColorForFlyZoneCategory:DJIFlyZoneCategoryWarning];
    } else if (indexPath.row == 4) {
        return [self.renderer unlockedFlyZoneOverlayColor];
    } else if (indexPath.row == 5) {
        return [self.renderer customUnlockFlyZoneOverlayColor];
    } else if (indexPath.row == 6) {
        return [self.renderer customUnlockFlyZoneSentToAircraftOverlayColor];
    } else if (indexPath.row == 7) {  
        return [self.renderer customUnlockFlyZoneEnabledOverlayColor];
    } else {
        return [UIColor clearColor];
    }
}

- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NSLocalizedString(@"Restricted", "Map Widget Legend Title");
    } else if (indexPath.row == 1) {
        return NSLocalizedString(@"Authorization", "Map Widget Legend Title");
    } else if (indexPath.row == 2) {
        return NSLocalizedString(@"Enhanced Warning", "Map Widget Legend Title");
    } else if (indexPath.row == 3) {
        return NSLocalizedString(@"Warning", "Map Widget Legend Title");
    } else if (indexPath.row == 4) {
        return NSLocalizedString(@"Unlocked", "Map Widget Legend Title");
    } else if (indexPath.row == 5) {
        return NSLocalizedString(@"Custom Unlock Not Sent", "Map Widget Legend Title");
    } else if (indexPath.row == 6) {
        return NSLocalizedString(@"Custom Unlock Sent", "Map Widget Legend Title");
    } else if (indexPath.row == 7) {
        return NSLocalizedString(@"Custom Unlock Sent and Enabled", "Map Widget Legend Title");
    } else {
        return NSLocalizedString(@"None", "Map Widget Legend Title");
    }
}

- (CGFloat)alphaForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [self.renderer flyZoneOverlayAlphaForFlyZoneCategory:DJIFlyZoneCategoryRestricted];
    } else if (indexPath.row == 1) {
        return [self.renderer flyZoneOverlayAlphaForFlyZoneCategory:DJIFlyZoneCategoryAuthorization];
    } else if (indexPath.row == 2) {
        return [self.renderer flyZoneOverlayAlphaForFlyZoneCategory:DJIFlyZoneCategoryEnhancedWarning];
    } else if (indexPath.row == 3) {
        return [self.renderer flyZoneOverlayAlphaForFlyZoneCategory:DJIFlyZoneCategoryWarning];
    } else if (indexPath.row == 4) {
        return [self.renderer unlockedFlyZoneOverlayAlpha];
    } else if (indexPath.row == 5) {
        return [self.renderer customUnlockFlyZoneOverlayAlpha];
    } else if (indexPath.row == 6) {
        return [self.renderer customUnlockFlyZoneSentToAircraftOverlayAlpha];
    } else if (indexPath.row == 7) {
        return [self.renderer customUnlockFlyZoneEnabledOverlayAlpha];
    } else {
        return 0.0f;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DUXBetaMapViewLegendCollectionViewCell *cell = (DUXBetaMapViewLegendCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:DUXBetaMapViewLegendCollectionViewCellReuseIdentifier
                                                                                                                               forIndexPath:indexPath];
    cell.titleLabel.text = [self titleForIndexPath:indexPath];
    cell.color = [self colorForIndexPath:indexPath];
    cell.alpha = [self alphaForIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    [cell setNeedsDisplay];
    return cell;
}

@end
