//
//  DUXBetaRecordVideoWidget.m
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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

#import "DUXBetaRecordVideoWidget.h"
#import "DUXBetaCameraStorageState.h"
#import "DUXBetaRecordVideoWidgetModel.h"
#import "DUXBetaRecordVideoTimeWidget.h"
#import "DUXBetaRecordVideoTimeWidgetModel.h"
#import <AVFoundation/AVFoundation.h>

@import UXSDKCore;

@interface DUXBetaRecordVideoWidget ()

@property (strong, nonatomic) AVAudioPlayer *startRecordingPlayer;
@property (strong, nonatomic) AVAudioPlayer *stopRecordingPlayer;

@property (nonatomic, strong) DUXBetaRecordVideoWidgetModel *widgetModel;

@end


@implementation DUXBetaRecordVideoWidget

@dynamic widgetModel;
@synthesize cameraIndex = _cameraIndex;

- (instancetype)init {
    self = [super init];
    if (self) {
        _showRecordVideoTimeWidget = YES;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [self setupRecordImages];
    
    self.widgetModel = [[DUXBetaRecordVideoWidgetModel alloc] initWithPreferredCameraIndex:self.cameraIndex];
    [self.widgetModel setup];
    
    [super viewDidLoad];
    
    [self setupAudio];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self, @selector(updateIsRecording:), self.widgetModel.isRecording);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

#pragma mark - Helper Methods

- (void)setupUI {
    [super setupUI];
    
    self.recordVideoTimeWidget = [[DUXBetaRecordVideoTimeWidget alloc] init];
    self.recordVideoTimeWidget.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordVideoTimeWidget.view.hidden = YES;
    self.recordVideoTimeWidget.showRecordingIndicator = NO;
    
    [self.recordVideoTimeWidget installInViewController:self];
    [self.view bringSubviewToFront:self.centerImageView];
    
    [self.recordVideoTimeWidget.view.topAnchor constraintEqualToAnchor:self.borderImageView.bottomAnchor constant:5.0].active = YES;
    [self.recordVideoTimeWidget.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.recordVideoTimeWidget.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.recordVideoTimeWidget.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:.20].active = YES;
    
    __weak typeof(self) weakSelf = self;
    
    self.action = ^{
        if (weakSelf.widgetModel.canStartRecording == YES) {
            [weakSelf.widgetModel startRecordVideoWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                }
            }];
        } else if (weakSelf.widgetModel.canStopRecording == YES) {
            [weakSelf.widgetModel stopRecordVideoWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                }
            }];
        }
    };
}

- (void)setupAudio {
    NSString *startRecordingAudioFileName = @"RecordVideoStartSound";
    NSString *startRecordingFileType = AVFileTypeWAVE;
    NSData *startRecordingAssetData = [NSData duxbeta_dataWithAssetNamed:startRecordingAudioFileName];
    self.startRecordingPlayer = [[AVAudioPlayer alloc] initWithData:startRecordingAssetData
                                                       fileTypeHint:startRecordingFileType
                                                              error:nil];
    self.startRecordingPlayer.volume = 1.0;
    self.startRecordingPlayer.numberOfLoops = 0;
    
    NSString *stopRecordingAudioFileName = @"RecordVideoStopSound";
    NSString *stopRecordingFileType = AVFileTypeWAVE;
    NSData *stopRecordingAssetData = [NSData duxbeta_dataWithAssetNamed:stopRecordingAudioFileName];
    self.stopRecordingPlayer = [[AVAudioPlayer alloc] initWithData:stopRecordingAssetData
                                                      fileTypeHint:stopRecordingFileType
                                                             error:nil];
    self.stopRecordingPlayer.volume = 1.0;
    self.stopRecordingPlayer.numberOfLoops = 0;
}

- (void)setupRecordImages {
    self.borderEnabledImage = [UIImage duxbeta_imageWithAssetNamed:@"RecordBorderEnabled" forClass:[self class]];
    self.borderDisabledImage = [UIImage duxbeta_imageWithAssetNamed:@"RecordBorderDisabled" forClass:[self class]];
    self.borderPressedImage = [UIImage duxbeta_imageWithAssetNamed:@"RecordBorderPressed" forClass:[self class]];
    self.centerEnabledImage = [UIImage duxbeta_imageWithAssetNamed:@"RecordCenterEnabled" forClass:[self class]];
    self.centerDisabledImage = [UIImage duxbeta_imageWithAssetNamed:@"RecordCenterDisabled" forClass:[self class]];
    self.centerPressedImage = [UIImage duxbeta_imageWithAssetNamed:@"RecordCenterPressed" forClass:[self class]];
    
    self.stopRecordEnabledImage = [UIImage duxbeta_imageWithAssetNamed:@"StopRecordingEnabled" forClass:[self class]];
    self.stopRecordPressedImage = [UIImage duxbeta_imageWithAssetNamed:@"StopRecordingPressed" forClass:[self class]];
    self.stopRecordDisabledImage = [UIImage duxbeta_imageWithAssetNamed:@"StopRecordingDisabled" forClass:[self class]];
}

- (UIImage *)centerImageForState:(DUXBetaCaptureActionState)state {
    switch (state) {
        case DUXBetaCaptureActionStateEnabled:
            return self.widgetModel.canStopRecording ? self.stopRecordEnabledImage : self.centerEnabledImage;;
        case DUXBetaCaptureActionStatePressed:
            return self.widgetModel.canStopRecording ? self.stopRecordPressedImage : self.centerPressedImage;
        default:
            return self.widgetModel.canStopRecording ? self.stopRecordDisabledImage : self.centerDisabledImage;
    }
}

#pragma mark - Widget Model Update Methods

- (void)updateIsRecording:(DUXBetaRKVOTransform *)transform {
    BOOL oldValue = [[transform oldValue] boolValue];
    BOOL newValue = [[transform updatedValue] boolValue];
    
    if (oldValue ^ newValue) {
        [self updateUI];
    }
    self.recordVideoTimeWidget.view.hidden = !(self.widgetModel.isRecording && self.showRecordVideoTimeWidget);
}

#pragma mark - Setters

- (void)setShowRecordVideoTimeWidget:(BOOL)showRecordVideoTimeWidget {
    _showRecordVideoTimeWidget = showRecordVideoTimeWidget;
    if (self.widgetModel.isRecording) {
        self.recordVideoTimeWidget.view.hidden = NO;
    }
}

@end
