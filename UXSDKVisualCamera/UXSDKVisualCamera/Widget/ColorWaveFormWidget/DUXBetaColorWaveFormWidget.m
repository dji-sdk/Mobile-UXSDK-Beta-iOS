//
//  DUXBetaColorWaveFormWidget.m
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

#import "DUXBetaColorWaveFormWidget.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static const CGSize kDesignSize = {180.0, 130.0};

@interface DUXBetaColorWaveFormWidget ()

@property (weak, nonatomic) DJILiveViewColorMonitorFilter *filter;
@property (strong, nonatomic, readwrite) DJIVideoPreviewer *previewer;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *colorMonitorDisplayModeCombineBtn;
@property (strong, nonatomic) UIButton *colorMonitorDisplayModeYChannelBtn;
@property (strong, nonatomic) UIView *monitorView;
@property (strong, nonatomic) UILabel *notSupportedLabel;

@property (strong, nonatomic) UIView *notSupportedView;
@property (strong, nonatomic) UIView *colorWaveFormView;

@property (strong, nonatomic) UIImage * colorMonitorRGBOnImage;
@property (strong, nonatomic) UIImage * colorMonitorRGBOffImage;
@property (strong, nonatomic) UIImage * colorMonitorYOnImage;
@property (strong, nonatomic) UIImage * colorMonitorYOffImage;

@end

@implementation DUXBetaColorWaveFormWidget

- (instancetype)initWithVideoPreviewer:(DJIVideoPreviewer *)previewer {
    self = [super init];
    if (self) {
        _previewer = previewer;
        _colorMonitorRGBOnImage = [UIImage duxbeta_imageWithAssetNamed:@"ColorMonitorRGBOn" forClass:[self class]];
        _colorMonitorRGBOffImage = [UIImage duxbeta_imageWithAssetNamed:@"ColorMonitorRGBNor" forClass:[self class]];
        _colorMonitorYOnImage = [UIImage duxbeta_imageWithAssetNamed:@"ColorMonitorYOn" forClass:[self class]];
        _colorMonitorYOffImage = [UIImage duxbeta_imageWithAssetNamed:@"ColorMonitorYNor" forClass:[self class]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaColorWaveFormWidgetModel alloc] initWithVideoPreviewer:self.previewer];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(renderedViewUpdated),renderedColorWaveFormView);
    BindRKVOModel(self.widgetModel, @selector(updateColorWaveFormSupported),colorWaveFormSupported);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.notSupportedView = [[UIView alloc] init];
    self.notSupportedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.notSupportedView];
    [self.notSupportedView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.notSupportedView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.notSupportedView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.notSupportedView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    self.notSupportedView.backgroundColor = [UIColor uxsdk_blackColor];
    self.notSupportedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.notSupportedLabel.text = NSLocalizedString(@"This feature is not supported", @"Display message when not supported");
    self.notSupportedLabel.textColor = [UIColor whiteColor];
    self.notSupportedLabel.numberOfLines = 3;
    self.notSupportedLabel.textAlignment = NSTextAlignmentCenter;
    [self.notSupportedView addSubview:self.notSupportedLabel];
    [self.notSupportedLabel.centerYAnchor constraintEqualToAnchor:self.notSupportedView.centerYAnchor].active = YES;
    [self.notSupportedLabel.centerXAnchor constraintEqualToAnchor:self.notSupportedView.centerXAnchor].active = YES;
    [self.notSupportedLabel.widthAnchor constraintEqualToAnchor:self.notSupportedView.widthAnchor].active = YES;
    [self.notSupportedLabel.heightAnchor constraintEqualToAnchor:self.notSupportedView.heightAnchor].active = YES;
    self.notSupportedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.notSupportedLabel setNeedsDisplay];
    
    self.colorWaveFormView = [[UIView alloc] init];
    self.colorWaveFormView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.colorWaveFormView];
    [self.colorWaveFormView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.colorWaveFormView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.colorWaveFormView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.colorWaveFormView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    self.colorWaveFormView.backgroundColor = [UIColor uxsdk_blackColor];
    
    self.widgetModel.displayMode = DJILiveViewColorMonitorDisplayTypeCombine;
    self.closeButton = [[UIButton alloc] init];
    [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.hidden = NO;
    UIImage *closeButtonImage = [UIImage duxbeta_imageWithAssetNamed:@"Cancel" forClass:[self class]];
    [self.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [self.colorWaveFormView addSubview:self.closeButton];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton.leadingAnchor constraintEqualToAnchor:self.colorWaveFormView.leadingAnchor].active = YES;
    [self.closeButton.topAnchor constraintEqualToAnchor:self.colorWaveFormView.topAnchor].active = YES;
    [self.closeButton.widthAnchor constraintEqualToConstant:kDesignSize.width * .17].active = YES;
    [self.closeButton.heightAnchor constraintEqualToConstant:kDesignSize.height * .23].active = YES;
    
    self.colorMonitorDisplayModeCombineBtn = [[UIButton alloc] init];
    [self.colorMonitorDisplayModeCombineBtn addTarget:self action:@selector(combineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.colorWaveFormView addSubview:self.colorMonitorDisplayModeCombineBtn];
    [self setCommonButtonAnchors:self.colorMonitorDisplayModeCombineBtn];
    [self.colorMonitorDisplayModeCombineBtn.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    
    self.colorMonitorDisplayModeYChannelBtn = [[UIButton alloc] init];
    [self.colorMonitorDisplayModeYChannelBtn addTarget:self action:@selector(yChannelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.colorWaveFormView addSubview:self.colorMonitorDisplayModeYChannelBtn];
    [self setCommonButtonAnchors:self.colorMonitorDisplayModeYChannelBtn];
    [self.colorMonitorDisplayModeYChannelBtn.leadingAnchor constraintEqualToAnchor:self.colorMonitorDisplayModeCombineBtn.trailingAnchor constant:10].active = YES;
    
    [self combineButtonPressed:self.colorMonitorDisplayModeCombineBtn];
    
    [self updateColorWaveFormSupported];
}

- (void)updateColorWaveFormSupported {
    if (self.widgetModel.colorWaveFormSupported) {
        self.notSupportedView.hidden = YES;
        self.colorWaveFormView.hidden = NO;
    } else {
        self.notSupportedView.hidden = NO;
        self.colorWaveFormView.hidden = YES;
    }
}

- (void)renderedViewUpdated {
    if (self.widgetModel.renderedColorWaveFormView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:self.widgetModel.renderedColorWaveFormView];
            self.widgetModel.renderedColorWaveFormView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self.widgetModel.renderedColorWaveFormView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
            [self.widgetModel.renderedColorWaveFormView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
            [self.widgetModel.renderedColorWaveFormView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
            [self.widgetModel.renderedColorWaveFormView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        });
    }
}

- (void)setCommonButtonAnchors:(UIButton *)button {
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button.widthAnchor constraintEqualToConstant:20].active = YES;
    [button.heightAnchor constraintEqualToConstant:22].active = YES;
    [button.bottomAnchor constraintEqualToAnchor:self.colorWaveFormView.bottomAnchor].active = YES;
}

- (void)combineButtonPressed:(UIButton *)sender {
    self.widgetModel.displayMode = DJILiveViewColorMonitorDisplayTypeCombine;
    [self.colorMonitorDisplayModeCombineBtn setImage:self.colorMonitorRGBOnImage forState:UIControlStateNormal];
    [self.colorMonitorDisplayModeYChannelBtn setImage:self.colorMonitorYOffImage forState:UIControlStateNormal];
}

- (void)yChannelButtonPressed:(UIButton *)sender {
    self.widgetModel.displayMode = DJILiveViewColorMonitorDisplayTypeYChannel;
    [self.colorMonitorDisplayModeCombineBtn setImage:self.colorMonitorRGBOffImage forState:UIControlStateNormal];
    [self.colorMonitorDisplayModeYChannelBtn setImage:self.colorMonitorYOnImage forState:UIControlStateNormal];
}

- (void)closeButtonPressed:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(closeButtonPressedForWidget:)]) {
        [self.delegate closeButtonPressedForWidget:self];
    }
}

- (void)setButtonImage:(UIImage *)image forColorMonitorDisplayType:(DJILiveViewColorMonitorDisplayType)displayType andActiveState:(BOOL)isActive {
    if (displayType == DJILiveViewColorMonitorDisplayTypeCombine) {
        if (isActive) {
            self.colorMonitorRGBOnImage = image;
        } else {
            self.colorMonitorRGBOffImage = image;
            
        }
    } else if (displayType == DJILiveViewColorMonitorDisplayTypeYChannel) {
        if (isActive) {
            self.colorMonitorYOnImage = image;
        } else {
            self.colorMonitorYOffImage = image;
        }
    }
    
    if (self.widgetModel.displayMode == DJILiveViewColorMonitorDisplayTypeCombine) {
        [self.colorMonitorDisplayModeCombineBtn setImage:self.colorMonitorRGBOnImage forState:UIControlStateNormal];
        [self.colorMonitorDisplayModeYChannelBtn setImage:self.colorMonitorYOffImage forState:UIControlStateNormal];
    } else if (self.widgetModel.displayMode == DJILiveViewColorMonitorDisplayTypeYChannel) {
        [self.colorMonitorDisplayModeCombineBtn setImage:self.colorMonitorRGBOffImage forState:UIControlStateNormal];
        [self.colorMonitorDisplayModeYChannelBtn setImage:self.colorMonitorYOnImage forState:UIControlStateNormal];
    }
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
