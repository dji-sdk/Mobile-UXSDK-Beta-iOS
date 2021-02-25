//
//  DUXBetaCaptureWidget.m
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

#import "DUXBetaCaptureWidget.h"
#import "DUXBetaCaptureWidgetModel.h"
#import "DUXBetaShootPhotoWidget.h"
#import "DUXBetaRecordVideoWidget.h"


@interface DUXBetaCaptureWidget ()

@property (nonatomic, strong) DUXBetaShootPhotoWidget *shootPhotoWidget;
@property (nonatomic, strong) DUXBetaRecordVideoWidget *recordVideoWidget;
@property (nonatomic, strong) NSLayoutConstraint *widgetAspectRatioConstraint;

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, DUXBetaBaseWidget *> *customChildWidgets;

@end

@implementation DUXBetaCaptureWidget

/*********************************************************************************/
#pragma mark - View Lifecycle
/*********************************************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaCaptureWidgetModel alloc] initWithPreferredCameraIndex:self.cameraIndex];
    [self.widgetModel setup];
    
    self.customChildWidgets = [NSMutableDictionary dictionary];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self, @selector(updateCameraMode), self.widgetModel.cameraMode);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

/*********************************************************************************/
#pragma mark - Setters
/*********************************************************************************/

- (void)setCameraIndex:(NSUInteger)preferredCameraIndex {
    if (_cameraIndex != preferredCameraIndex) {
        _cameraIndex = preferredCameraIndex;
        self.widgetModel.cameraIndex = preferredCameraIndex;
        self.shootPhotoWidget.cameraIndex = preferredCameraIndex;
        self.recordVideoWidget.cameraIndex = preferredCameraIndex;
    }
}

/*********************************************************************************/
#pragma mark - Widget Size Hint
/*********************************************************************************/

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {.preferredAspectRatio = 1, .minimumWidth = 60, .minimumHeight = 60};
    return hint;
}

/*********************************************************************************/
#pragma mark - Widget Model Bindings
/*********************************************************************************/

- (void)updateCameraMode {
    switch (self.widgetModel.cameraMode) {
        case DJICameraModeShootPhoto:
            [self displayShootPhotoWidget];
            break;
        case DJICameraModeRecordVideo:
            [self displayRecordVideoWidget];
            break;
        default:
            [self displayDefaultState];
            break;
    }
}

- (void)displayShootPhotoWidget {
    DUXBetaBaseWidget *customChildWidget = self.customChildWidgets[@(self.widgetModel.cameraMode)];
    if (customChildWidget) {
        [self.recordVideoWidget installInViewController:nil];
        [self.shootPhotoWidget installInViewController:nil];
        self.recordVideoWidget = nil;
        self.shootPhotoWidget = nil;
        [customChildWidget installInViewController:customChildWidget];
        [customChildWidget layoutWidgetInView:self.view];
    } else {
        [self.recordVideoWidget installInViewController:nil];
        self.recordVideoWidget = nil;
        
        if (!self.shootPhotoWidget) {
            self.shootPhotoWidget = [[DUXBetaShootPhotoWidget alloc] init];
            self.shootPhotoWidget.cameraIndex = self.cameraIndex;
            [self.shootPhotoWidget installInViewController:self];
            [self.shootPhotoWidget.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
            [self.shootPhotoWidget.view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
            [self.shootPhotoWidget.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
            [self.shootPhotoWidget.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
            self.widgetAspectRatioConstraint.active = NO;
            self.widgetAspectRatioConstraint = [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:self.shootPhotoWidget.widgetSizeHint.preferredAspectRatio];
            self.widgetAspectRatioConstraint.active = YES;
        }
    }
}

- (void)displayRecordVideoWidget {
    DUXBetaBaseWidget *customChildWidget = self.customChildWidgets[@(self.widgetModel.cameraMode)];
    if (customChildWidget) {
        [self.recordVideoWidget installInViewController:nil];
        [self.shootPhotoWidget installInViewController:nil];
        self.recordVideoWidget = nil;
        self.shootPhotoWidget = nil;
        [customChildWidget installInViewController:customChildWidget];
        [customChildWidget layoutWidgetInView:self.view];
    } else {
        [self.shootPhotoWidget installInViewController:nil];
        self.shootPhotoWidget = nil;
        
        if (!self.recordVideoWidget) {
            self.recordVideoWidget = [[DUXBetaRecordVideoWidget alloc] init];
            self.recordVideoWidget.cameraIndex = self.cameraIndex;
            [self.recordVideoWidget installInViewController:self];
            [self.recordVideoWidget.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
            [self.recordVideoWidget.view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
            [self.recordVideoWidget.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
            [self.recordVideoWidget.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
            self.widgetAspectRatioConstraint.active = NO;
            self.widgetAspectRatioConstraint = [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:self.recordVideoWidget.widgetSizeHint.preferredAspectRatio];
            self.widgetAspectRatioConstraint.active = YES;
        }
    }
}

- (void)displayDefaultState {
    // handle default state
//    [self.shootPhotoWidget installInViewController:nil];
//    [self.recordVideoWidget installInViewController:nil];
    [self displayShootPhotoWidget];
}

/*********************************************************************************/
#pragma mark - Customization
/*********************************************************************************/

- (void)setChildWidget:(nullable DUXBetaBaseWidget *)widget
         forCameraMode:(DJICameraMode)cameraMode {
    if (widget) {
        self.customChildWidgets[@(cameraMode)] = widget;
    }
}

@end
