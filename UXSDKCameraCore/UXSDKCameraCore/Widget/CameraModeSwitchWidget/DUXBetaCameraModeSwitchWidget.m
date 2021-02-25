//
//  DUXBetaCameraModeSwitchWidget.m
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

#import "DUXBetaCameraModeSwitchWidget.h"
#import "DUXBetaCameraModeSwitchWidgetModel.h"

#import <UXSDKCore/UIImage+DUXBetaAssets.h>

@interface DUXBetaCameraModeSwitchWidget ()

@property (nonatomic, strong) NSMutableDictionary *customSwitchPositionImages;

@end

@implementation DUXBetaCameraModeSwitchWidget

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaCameraModeSwitchWidgetModel alloc] initWithPreferredCameraIndex:self.preferredCameraIndex];
    [self.widgetModel setup];
    
    self.customSwitchPositionImages = [NSMutableDictionary dictionary];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self, @selector(update), self.widgetModel.switchPosition);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.switchPositionImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.switchPositionImageView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:self.switchPositionImageView];
    [self.switchPositionImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.switchPositionImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.switchPositionImageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.switchPositionImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
}

/*********************************************************************************/
#pragma mark - Widget Size Hint
/*********************************************************************************/

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {.preferredAspectRatio = 1.2, .minimumWidth = 58, .minimumHeight = 48};
    return hint;
}

/*********************************************************************************/
#pragma mark - Update
/*********************************************************************************/
- (void)update {
    if (self.widgetModel.switchPosition == DUXBetaCameraModeSwitchPositionShootPhoto) {
        self.switchPositionImageView.image = self.customSwitchPositionImages[@(DUXBetaCameraModeSwitchPositionShootPhoto)] ?: [UIImage duxbeta_imageWithAssetNamed:@"CameraModeSwitchShootPhoto" forClass:[self class]];
    } else if (self.widgetModel.switchPosition == DUXBetaCameraModeSwitchPositionRecordVideo) {
        self.switchPositionImageView.image = self.customSwitchPositionImages[@(DUXBetaCameraModeSwitchPositionRecordVideo)] ?: [UIImage duxbeta_imageWithAssetNamed:@"CameraModeSwitchRecordVideo" forClass:[self class]];
    } else if (self.widgetModel.switchPosition == DUXBetaCameraModeSwitchPositionUnknown) {
        self.switchPositionImageView.image = self.customSwitchPositionImages[@(DUXBetaCameraModeSwitchPositionUnknown)] ?: [UIImage duxbeta_imageWithAssetNamed:@"CameraModeSwitchShootPhoto" forClass:[self class]];
    }
}

/*********************************************************************************/
#pragma mark - Customization
/*********************************************************************************/
- (void)setImage:(UIImage *)image forSwitchPosition:(DUXBetaCameraModeSwitchPosition)position {
    self.customSwitchPositionImages[@(position)] = image;
}

@end
