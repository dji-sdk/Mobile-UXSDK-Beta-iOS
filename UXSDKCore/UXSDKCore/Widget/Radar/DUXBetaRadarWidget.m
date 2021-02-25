//
//  DUXBetaRadarWidget.m
//  UXSDKCore
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

#import "DUXBetaRadarWidget.h"
#import "DUXBetaRadarSectionView.h"
#import "DUXBetaMultiAngleRadarSectionView.h"
#import "DUXBetaSingleAngleRadarSectionView.h"
#import "UIImage+DUXBetaAssets.h"
@import AVKit;

NSString* const DUXRadarWidgetForward_0_0 = @"RadarCustomForward_0_0";
NSString* const DUXRadarWidgetForward_0_disabled = @"RadarCustomForwardDisabled_0";

NSString* const DUXRadarWidgetForward_0_1 = @"RadarCustomForward_0_1";
NSString* const DUXRadarWidgetForward_0_2 = @"RadarCustomForward_0_2";
NSString* const DUXRadarWidgetForward_0_3 = @"RadarCustomForward_0_3";
NSString* const DUXRadarWidgetForward_0_4 = @"RadarCustomForward_0_4";
NSString* const DUXRadarWidgetForward_0_5 = @"RadarCustomForward_0_5";
NSString* const DUXRadarWidgetForward_1_disabled = @"RadarCustomForwardDisabled_1";
NSString* const DUXRadarWidgetForward_1_0 = @"RadarCustomForward_1_0";
NSString* const DUXRadarWidgetForward_1_1 = @"RadarCustomForward_1_1";
NSString* const DUXRadarWidgetForward_1_2 = @"RadarCustomForward_1_2";
NSString* const DUXRadarWidgetForward_1_3 = @"RadarCustomForward_1_3";
NSString* const DUXRadarWidgetForward_1_4 = @"RadarCustomForward_1_4";
NSString* const DUXRadarWidgetForward_1_5 = @"RadarCustomForward_1_5";
NSString* const DUXRadarWidgetForward_2_disabled = @"RadarCustomForwardDisabled_2";
NSString* const DUXRadarWidgetForward_2_0 = @"RadarCustomForward_2_0";
NSString* const DUXRadarWidgetForward_2_1 = @"RadarCustomForward_2_1";
NSString* const DUXRadarWidgetForward_2_2 = @"RadarCustomForward_2_2";
NSString* const DUXRadarWidgetForward_2_3 = @"RadarCustomForward_2_3";
NSString* const DUXRadarWidgetForward_2_4 = @"RadarCustomForward_2_4";
NSString* const DUXRadarWidgetForward_2_5 = @"RadarCustomForward_2_5";
NSString* const DUXRadarWidgetForward_3_disabled = @"RadarCustomForwardDisabled_3";
NSString* const DUXRadarWidgetForward_3_0 = @"RadarCustomForward_3_0";
NSString* const DUXRadarWidgetForward_3_1 = @"RadarCustomForward_3_1";
NSString* const DUXRadarWidgetForward_3_2 = @"RadarCustomForward_3_2";
NSString* const DUXRadarWidgetForward_3_3 = @"RadarCustomForward_3_3";
NSString* const DUXRadarWidgetForward_3_4 = @"RadarCustomForward_3_4";
NSString* const DUXRadarWidgetForward_3_5 = @"RadarCustomForward_3_5";

NSString* const DUXRadarWidgetRear_0_disabled = @"RadarCustomBackwardDisabled_0";
NSString* const DUXRadarWidgetRear_0_0 = @"RadarCustomBackward_0_0";
NSString* const DUXRadarWidgetRear_0_1 = @"RadarCustomBackward_0_1";
NSString* const DUXRadarWidgetRear_0_2 = @"RadarCustomBackward_0_2";
NSString* const DUXRadarWidgetRear_0_3 = @"RadarCustomBackward_0_3";
NSString* const DUXRadarWidgetRear_0_4 = @"RadarCustomBackward_0_4";
NSString* const DUXRadarWidgetRear_0_5 = @"RadarCustomBackward_0_5";
NSString* const DUXRadarWidgetRear_1_disabled = @"RadarCustomBackwardDisabled_1";
NSString* const DUXRadarWidgetRear_1_0 = @"RadarCustomBackward_1_0";
NSString* const DUXRadarWidgetRear_1_1 = @"RadarCustomBackward_1_1";
NSString* const DUXRadarWidgetRear_1_2 = @"RadarCustomBackward_1_2";
NSString* const DUXRadarWidgetRear_1_3 = @"RadarCustomBackward_1_3";
NSString* const DUXRadarWidgetRear_1_4 = @"RadarCustomBackward_1_4";
NSString* const DUXRadarWidgetRear_1_5 = @"RadarCustomBackward_1_5";
NSString* const DUXRadarWidgetRear_2_disabled = @"RadarCustomBackwardDisabled_2";
NSString* const DUXRadarWidgetRear_2_0 = @"RadarCustomBackward_2_0";
NSString* const DUXRadarWidgetRear_2_1 = @"RadarCustomBackward_2_1";
NSString* const DUXRadarWidgetRear_2_2 = @"RadarCustomBackward_2_2";
NSString* const DUXRadarWidgetRear_2_3 = @"RadarCustomBackward_2_3";
NSString* const DUXRadarWidgetRear_2_4 = @"RadarCustomBackward_2_4";
NSString* const DUXRadarWidgetRear_2_5 = @"RadarCustomBackward_2_5";
NSString* const DUXRadarWidgetRear_3_disabled = @"RadarCustomBackwardDisabled_3";
NSString* const DUXRadarWidgetRear_3_0 = @"RadarCustomBackward_3_0";
NSString* const DUXRadarWidgetRear_3_1 = @"RadarCustomBackward_3_1";
NSString* const DUXRadarWidgetRear_3_2 = @"RadarCustomBackward_3_2";
NSString* const DUXRadarWidgetRear_3_3 = @"RadarCustomBackward_3_3";
NSString* const DUXRadarWidgetRear_3_4 = @"RadarCustomBackward_3_4";
NSString* const DUXRadarWidgetRear_3_5 = @"RadarCustomBackward_3_5";

NSString* const DUXRadarWidgetLeft_0_0 = @"RadarCustomLeft_0_0";
NSString* const DUXRadarWidgetLeft_0_1 = @"RadarCustomLeft_0_1";
NSString* const DUXRadarWidgetRight_1_0 = @"RadarCustomLeft_1_0";
NSString* const DUXRadarWidgetRight_1_1 = @"RadarCustomLeft_1_1";

NSString* const DUXRadarWidgetOverheadObstruction = @"RadarCustomOverheadObstruction";
NSString* const DUXRadarWidgetArrow = @"RadarCustomArrow";

static CGSize const kDesignSize = {220.0, 352.0};

@interface DUXBetaRadarWidget ()

@property (strong, nonatomic) NSMutableArray <DUXBetaRadarSectionView *> *radarSections;
@property (strong, nonatomic) UIImageView *avoidUpImageView;
@property (strong, nonatomic) AVAudioPlayer *level1AudioPlayer; // Convert to array during customizations
@property (strong, nonatomic) AVAudioPlayer *level2AudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *level3AudioPlayer;
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *>  *customizedRadarSections;
@end

@implementation DUXBetaRadarWidget

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaRadarWidgetModel alloc] init];
    [self.widgetModel setup];
    
    self.enableRadarAlertSounds = YES;
    [self setupUI];
    [self loadRadarSoundPlayers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), noseState, tailState, rightState, leftState, controlState);
    BindRKVOModel(self.widgetModel, @selector(playAlertSound), radarWarningLevel);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)loadRadarSoundPlayers {
    NSString *audioPathLevel1 = [[NSBundle bundleForClass:self.class] pathForResource:@"uxsdk_radar_beep_1000" ofType:@"wav"];
    NSString *audioPathLevel2 = [[NSBundle bundleForClass:self.class] pathForResource:@"uxsdk_radar_beep_500" ofType:@"wav"];
    NSString *audioPathLevel3 = [[NSBundle bundleForClass:self.class] pathForResource:@"uxsdk_radar_beep_250" ofType:@"wav"];
    @try {
        NSError *error = nil;
        self.level1AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPathLevel1] error:&error];
        self.level2AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPathLevel2] error:&error];
        self.level3AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPathLevel3] error:&error];
    }
    @catch (NSException *exception) {
        
    }

}
- (void)setupUI {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.userInteractionEnabled = NO;
    
    self.radarSections = [[NSMutableArray alloc] init];
    
    [self.view.heightAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:self.widgetSizeHint.preferredAspectRatio].active = YES;
    
    // Setup constraints for the 4 main views of the radar widget. Do this by loading all 4 section classes then getting the
    // bounding box for the the 3 bar position. This will allow us to create a view to contain the images.
    // Fun layout trivia. The top images have a 6 point overlap between the left image and the inner image to allow them to appear as a nice arc.
    
    DUXBetaSingleAngleRadarSectionView *leftSection =  [[DUXBetaSingleAngleRadarSectionView alloc] initWithSensorPosition:DJIVisionSensorPositionLeft];
    DUXBetaSingleAngleRadarSectionView *rightSection = [[DUXBetaSingleAngleRadarSectionView alloc] initWithSensorPosition:DJIVisionSensorPositionRight];
    DUXBetaMultiAngleRadarSectionView *noseSection = [[DUXBetaMultiAngleRadarSectionView alloc] initWithSensorPosition:DJIVisionSensorPositionNose];
    DUXBetaMultiAngleRadarSectionView *tailSection = [[DUXBetaMultiAngleRadarSectionView alloc] initWithSensorPosition:DJIVisionSensorPositionTail];

    leftSection.translatesAutoresizingMaskIntoConstraints = NO;
    rightSection.translatesAutoresizingMaskIntoConstraints = NO;
    noseSection.translatesAutoresizingMaskIntoConstraints = NO;
    tailSection.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *topView = [[UIView alloc] init];
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *bottomView = [[UIView alloc] init];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *leftRightView = [[UIView alloc] init];
    leftRightView.translatesAutoresizingMaskIntoConstraints = NO;
    
    leftSection.radarImageView.image = [leftSection sectorImageForLevel:DJIObstacleDetectionSectorWarningLevel1 andSectorIndex:0];
    rightSection.radarImageView.image = [rightSection sectorImageForLevel:DJIObstacleDetectionSectorWarningLevel1 andSectorIndex:1];
    
    [leftRightView addSubview:leftSection];
    [leftRightView addSubview:rightSection];
    [topView addSubview:noseSection];
    [bottomView addSubview:tailSection];

    // Build the main radar view which is:
    // Nose row
    // Side - Up warning - Side row
    // Tail row

    [self.view addSubview:topView];
    [self.view addSubview:leftRightView];
    [self.view addSubview:bottomView];
    
    // Do the top widget only
    [noseSection.centerXAnchor constraintEqualToAnchor:topView.centerXAnchor].active = YES;
    [noseSection.topAnchor constraintEqualToAnchor:topView.topAnchor].active = YES;
    
    [topView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [topView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [topView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;

    [topView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.22].active = YES;;
    
    // Do the middle row only
    [leftRightView.topAnchor constraintEqualToAnchor:topView.bottomAnchor].active = YES;
    [leftRightView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [leftRightView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [leftRightView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.41].active = YES;;

    [leftSection.leadingAnchor constraintEqualToAnchor:leftRightView.leadingAnchor].active = YES;
    [leftSection.topAnchor constraintEqualToAnchor:leftRightView.topAnchor].active = YES;
    [leftSection.bottomAnchor constraintEqualToAnchor:leftRightView.bottomAnchor].active = YES;
    leftSection.hidden = YES;
    
    
    [rightSection.trailingAnchor constraintEqualToAnchor:leftRightView.trailingAnchor].active = YES;
    [rightSection.topAnchor constraintEqualToAnchor:leftRightView.topAnchor].active = YES;
    [rightSection.bottomAnchor constraintEqualToAnchor:leftRightView.bottomAnchor].active = YES;
    rightSection.hidden = YES;
    
    // Do the bottom view here.
    [tailSection.centerXAnchor constraintEqualToAnchor:bottomView.centerXAnchor].active = YES;
    [tailSection.bottomAnchor constraintEqualToAnchor:bottomView.bottomAnchor].active = YES;

    [bottomView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [bottomView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [bottomView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
 
    [bottomView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.37].active = YES;

    noseSection.hidden = YES;
    tailSection.hidden = YES;


    self.avoidUpImageView = [[UIImageView alloc] initWithImage:[UIImage duxbeta_imageWithAssetNamed:@"AvoidUp"]];
    self.avoidUpImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.avoidUpImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.avoidUpImageView];
    [self.avoidUpImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.avoidUpImageView.centerYAnchor constraintEqualToAnchor:leftRightView.centerYAnchor].active = YES;
    [self.avoidUpImageView.widthAnchor constraintEqualToAnchor:self.avoidUpImageView.heightAnchor].active = YES;
    [self.avoidUpImageView.heightAnchor constraintEqualToAnchor:leftRightView.heightAnchor multiplier:0.42].active = YES;
    self.avoidUpImageView.hidden = YES;

    self.radarSections[DJIVisionSensorPositionNose] = noseSection;
    self.radarSections[DJIVisionSensorPositionTail] = tailSection;
    self.radarSections[DJIVisionSensorPositionRight] = rightSection;
    self.radarSections[DJIVisionSensorPositionLeft] = leftSection;
}

- (void)updateUI {
    //Update nose radar view.  Doesn't use obstacle distance since each sector has that property.
    DUXBetaMultiAngleRadarSectionView *noseSectionView = (DUXBetaMultiAngleRadarSectionView *)self.radarSections[self.widgetModel.noseState.position];
    noseSectionView.sectors = self.widgetModel.noseState.detectionSectors;

    //Update tail radar view.  Doesn't use obstacle distance since each sector has that property.
    DUXBetaMultiAngleRadarSectionView *tailSectionView = (DUXBetaMultiAngleRadarSectionView *)self.radarSections[self.widgetModel.tailState.position];
    //We have to reverse the data here because the sectors come in from right->left but we want left->right for displaying the data
    tailSectionView.sectors = [[self.widgetModel.tailState.detectionSectors reverseObjectEnumerator] allObjects];

    //Update right radar view.  Doesn't use sectors array.
    DUXBetaSingleAngleRadarSectionView *rightSectionView = (DUXBetaSingleAngleRadarSectionView *)self.radarSections[self.widgetModel.rightState.position];
    rightSectionView.obstacleDistanceInMeters = self.widgetModel.rightState.obstacleDistanceInMeters;

    //Update left radar view.  Doesn't use sectors array.
    DUXBetaSingleAngleRadarSectionView *leftSectionView = (DUXBetaSingleAngleRadarSectionView *)self.radarSections[self.widgetModel.leftState.position];
    leftSectionView.obstacleDistanceInMeters = self.widgetModel.leftState.obstacleDistanceInMeters;
    
    // Update upper radar blocking obstacle
    self.avoidUpImageView.hidden = !self.widgetModel.controlState.isAscentLimitedByObstacle;
}

- (void)playAlertSound {
    if (!self.enableRadarAlertSounds) {
        return;
    }
    switch (self.widgetModel.radarWarningLevel) {
        case DJIObstacleDetectionSectorWarningLevel1:
            [self.level1AudioPlayer play];
            break;
        
        case DJIObstacleDetectionSectorWarningLevel2:
            [self.level2AudioPlayer play];
            break;
            
        case DJIObstacleDetectionSectorWarningLevel3:
            [self.level3AudioPlayer play];
            break;
            
        default:
            break;
    }
}

#pragma mark - Customizations
- (void)setCustomRadarImages:(NSDictionary<NSString *,UIImage *> *)radarImages {
    self.customizedRadarSections = radarImages;
    // Now update all the sub objects
    DUXBetaMultiAngleRadarSectionView *noseSectionView = (DUXBetaMultiAngleRadarSectionView *)self.radarSections[self.widgetModel.noseState.position];
    noseSectionView.customizedRadarSections = _customizedRadarSections;
    [noseSectionView updateCustomImages];
    
    DUXBetaMultiAngleRadarSectionView *tailSectionView = (DUXBetaMultiAngleRadarSectionView *)self.radarSections[self.widgetModel.tailState.position];
    tailSectionView.customizedRadarSections = _customizedRadarSections;
    [tailSectionView updateCustomImages];
    

    DUXBetaSingleAngleRadarSectionView *leftSectionView = (DUXBetaSingleAngleRadarSectionView *)self.radarSections[self.widgetModel.leftState.position];
    leftSectionView.customizedRadarSections = _customizedRadarSections;
    [leftSectionView updateCustomImages];
    
    DUXBetaSingleAngleRadarSectionView *rightSectionView = (DUXBetaSingleAngleRadarSectionView *)self.radarSections[self.widgetModel.rightState.position];
    rightSectionView.customizedRadarSections = _customizedRadarSections;
    [rightSectionView updateCustomImages];
    
    [self updateUI];
}

- (void)setDistanceArrowImageBackground:(UIColor *)arrowBackground {
    _distanceArrowImageBackground = arrowBackground;
    
    DUXBetaRadarSectionView *noseSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.noseState.position];
    [noseSectionView setDistanceArrowImageBackground:arrowBackground];
    DUXBetaRadarSectionView *tailSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.tailState.position];
    [tailSectionView setDistanceArrowImageBackground:arrowBackground];
    
    DUXBetaRadarSectionView *leftSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.leftState.position];
    [leftSectionView setDistanceArrowImageBackground:arrowBackground];
    DUXBetaRadarSectionView *rightSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.rightState.position];
    [rightSectionView setDistanceArrowImageBackground:arrowBackground];
}

- (void)setUpwardObstacleBackgroundColor:(UIColor *)upObstacleBackgroundColor {
    _upwardObstacleImageBackgroundColor = upObstacleBackgroundColor;
    self.avoidUpImageView.backgroundColor = upObstacleBackgroundColor;
}

- (void)setRadarWarningLevels:(NSArray *)warningLevels {
    // TODO: Determine how distance ranges should be passed and stored economically
}

- (void)setDistanceTextColor:(UIColor *)color {
    _distanceTextColor = color;
    // Now forward to the segments which show distance
    DUXBetaRadarSectionView *noseSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.noseState.position];
    [noseSectionView setDistanceTextColor:color];
    DUXBetaRadarSectionView *tailSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.tailState.position];
    [tailSectionView setDistanceTextColor:color];

    DUXBetaRadarSectionView *leftSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.leftState.position];
    [leftSectionView setDistanceTextColor:color];
    DUXBetaRadarSectionView *rightSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.rightState.position];
    [rightSectionView setDistanceTextColor:color];
}

- (void)setDistanceTextBackgroundColor:(UIColor *)textBackgroundColor {
    _distanceTextBackgroundColor = textBackgroundColor;
    // Now forward to the segments which show distance
    DUXBetaRadarSectionView *noseSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.noseState.position];
    [noseSectionView setDistanceTextBackgroundColor:textBackgroundColor];
    DUXBetaRadarSectionView *tailSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.tailState.position];
    [tailSectionView setDistanceTextBackgroundColor:textBackgroundColor];

    DUXBetaRadarSectionView *leftSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.leftState.position];
    [leftSectionView setDistanceTextBackgroundColor:textBackgroundColor];
    DUXBetaRadarSectionView *rightSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.rightState.position];
    [rightSectionView setDistanceTextBackgroundColor:textBackgroundColor];
}

- (void)setDistanceTextFont:(UIFont *)font {
    _distanceTextFont = font;

    DUXBetaRadarSectionView *noseSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.noseState.position];
    [noseSectionView setDistanceFont:font];
    DUXBetaRadarSectionView *tailSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.tailState.position];
    [tailSectionView setDistanceFont:font];

    DUXBetaRadarSectionView *leftSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.leftState.position];
    [leftSectionView setDistanceFont:font];
    DUXBetaRadarSectionView *rightSectionView = (DUXBetaRadarSectionView *)self.radarSections[self.widgetModel.rightState.position];
    [rightSectionView setDistanceFont:font];
}

- (void)setUpwardObstacleImageBackgroundColor:(UIColor *)backgroundColor {
    _upwardObstacleImageBackgroundColor = backgroundColor;
    self.avoidUpImageView.backgroundColor = backgroundColor;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

- (void)updateCustomImages {
    UIImage *workImage;
    
    if (self.customizedRadarSections) {
        workImage = self.customizedRadarSections[DUXRadarWidgetOverheadObstruction];
    }
    if (workImage == nil) {
        workImage = [UIImage duxbeta_imageWithAssetNamed:@"AvoidUp"];
    }
    self.avoidUpImageView.image = workImage;
}

@end
