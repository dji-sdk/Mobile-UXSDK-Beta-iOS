//
//  DUXBetaSpeakerControlWidget.m
//  UXSDKAccessory
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

#import "DUXBetaSpeakerControlWidget.h"
#import "DUXBetaSpeakerVolumeView.h"
#import "DUXBetaSpeakerBroadcastTypeView.h"
#import "DUXBetaSpeakerRecordAudioView.h"
#import "DUXBetaSpeakerMemoryListView.h"
#import "DUXBetaSpeakerBottomBar.h"

@import UXSDKCore;

static CGSize const kDesignSize = {375.0, 667.0};

@interface DUXBetaSpeakerControlWidget ()  <DUXBetaToolbarPanelSupportProtocol>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation DUXBetaSpeakerControlWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel = [UILabel new];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        _titleLabelText = NSLocalizedString(@"Speaker Settings", @"Speaker Panel Title Text");
        _titleLabelTextColor = [UIColor whiteColor];
        _titleLabelFont = [UIFont boldSystemFontOfSize:18];
        
        _closeButtonNormalImage = [UIImage duxbeta_imageWithAssetNamed:@"CancelButton" forClass:[self class]];
        _closeButtonPressedImage = [UIImage duxbeta_imageWithAssetNamed:@"CancelButtonPressed" forClass:[self class]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [[UIColor uxsdk_blackColor] colorWithAlphaComponent:0.9];
    [self.view addSubview:self.titleLabel];
    
    self.closeButton = [UIButton new];
    UIImage *normalImage = self.closeButtonNormalImage;
    UIImage *pressedImage = self.closeButtonPressedImage;
    [self.closeButton setImage:normalImage forState:UIControlStateNormal];
    [self.closeButton setImage:pressedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    DUXBetaSpeakerMediaListSyncer *syncer = [[DUXBetaSpeakerMediaListSyncer alloc] init];
    [syncer setup];
    
    self.volumeContainer = [[DUXBetaSpeakerVolumeView alloc] initWithFrame:CGRectZero andMediaSyncer:syncer];
    [self.view addSubview:self.volumeContainer];
    
    self.broadcastTypeView = [[DUXBetaSpeakerBroadcastTypeView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.broadcastTypeView];
    
    self.instantRecordView = [[DUXBetaSpeakerRecordAudioView alloc] initWithFrame:CGRectZero andMediaSyncer:syncer];
    self.instantRecordView.hidden = NO;
    [self.view addSubview:self.instantRecordView];
    
    self.memoryListView = [[DUXBetaSpeakerMemoryListView alloc] initWithFrame:CGRectZero andMediaSyncer:syncer];
    self.memoryListView.hidden = YES;
    [self.view addSubview:self.memoryListView];
    
    self.bottomBar = [[DUXBetaSpeakerBottomBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.bottomBar];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.volumeContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.broadcastTypeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.memoryListView.translatesAutoresizingMaskIntoConstraints = NO;
    self.instantRecordView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.closeButton.leadingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToConstant:44].active = YES;
    
    [self.closeButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-5].active = YES;
    [self.closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.closeButton.heightAnchor constraintEqualToConstant:44].active = YES;
    [self.closeButton.widthAnchor constraintEqualToConstant:44].active = YES;
    
    [self.volumeContainer.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor].active = YES;
    [self.volumeContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.volumeContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.volumeContainer.heightAnchor constraintEqualToConstant:40].active = YES;
    
    [self.broadcastTypeView.topAnchor constraintEqualToAnchor:self.volumeContainer.bottomAnchor].active = YES;
    [self.broadcastTypeView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.broadcastTypeView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.broadcastTypeView.heightAnchor constraintEqualToConstant:50].active = YES;
    
    [self.memoryListView.topAnchor constraintEqualToAnchor:self.broadcastTypeView.bottomAnchor].active = YES;
    [self.memoryListView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.memoryListView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.memoryListView.bottomAnchor constraintEqualToAnchor:self.bottomBar.topAnchor].active = YES;
    
    [self.instantRecordView.topAnchor constraintEqualToAnchor:self.broadcastTypeView.bottomAnchor].active = YES;
    [self.instantRecordView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.instantRecordView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.instantRecordView.bottomAnchor constraintEqualToAnchor:self.bottomBar.topAnchor].active = YES;
    
    [self.bottomBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.bottomBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.bottomBar.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    
    [self setupActions];
}

- (void)setupActions {
    __weak typeof(self) target = self;
    self.broadcastTypeView.didSelectTypeCallback = ^(NSUInteger index) {
        if (index == 0) {
            target.instantRecordView.hidden = NO;
            target.memoryListView.hidden = YES;
        } else {
            target.instantRecordView.hidden = YES;
            target.memoryListView.hidden = NO;
        }
    };
}

- (void)close {
    if ([self.delegate respondsToSelector:@selector(closeButtonPressedForWidget:)]) {
        [self.delegate closeButtonPressedForWidget:self];
    }
}

- (void)setTitleLabelText:(NSString *)titleLabelText {
    _titleLabelText = titleLabelText;
    self.titleLabel.text = titleLabelText;
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    self.titleLabel.font = titleLabelFont;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor {
    _titleLabelTextColor = titleLabelTextColor;
    self.titleLabel.textColor = titleLabelTextColor;
}

- (void)setCloseButtonNormalImage:(UIImage *)closeButtonNormalImage {
    _closeButtonNormalImage = closeButtonNormalImage;
    [self.closeButton setImage:closeButtonNormalImage forState:UIControlStateNormal];
}

- (void)setCloseButtonPressedImage:(UIImage *)closeButtonPressedImage {
    _closeButtonPressedImage = closeButtonPressedImage;
    [self.closeButton setImage:closeButtonPressedImage forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

#pragma mark - Panel Support Methods

- (NSString * _Nullable) toolbarItemTitle {
    return @"Speaker";
}

- (UIImage * _Nullable) toolbarItemIcon {
    return [UIImage duxbeta_imageWithAssetNamed:@"SpeakerActive" forClass:[self class]];
}

@end
