//
//  DUXLiveStreamFacebookMetadataViewController.m
//  DJIUXSDKLiveStreamModule
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

#import "DUXLiveStreamFacebookMetadataViewController.h"
#import "DUXLiveStreamControlWidget.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <UXSDKCore/UIImage+DUXAssets.h>

@interface DUXLiveStreamFacebookMetadataViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) FBSDKProfilePictureView *avatarView;
@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UIPickerView *privacyPickerView;
@property (strong, nonatomic) UILabel *privacyLabel;
@property (assign, nonatomic) BOOL startedLiveStreaming;
@property (strong, nonatomic) NSArray *privacyOptions;
@property (strong, nonatomic) UIButton *closeButton;

@end

@implementation DUXLiveStreamFacebookMetadataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startedLiveStreaming = NO;
    self.avatarView = [[FBSDKProfilePictureView alloc] init];
    self.descriptionTextField = [[UITextField alloc] init];
    self.privacyPickerView = [[UIPickerView alloc] init];
    self.privacyLabel = [[UILabel alloc] init];
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarView.pictureMode = FBSDKProfilePictureModeSquare;
    [self.view addSubview:self.avatarView];
    [self.avatarView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.avatarView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20.0].active = YES;
    [self.avatarView.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.avatarView.widthAnchor constraintEqualToConstant:50].active = YES;
    
    self.descriptionTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionTextField.placeholder = @"Stream description...";
    self.descriptionTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.descriptionTextField];
    self.descriptionTextField.backgroundColor = [UIColor whiteColor];
    [self.descriptionTextField.topAnchor constraintEqualToAnchor:self.avatarView.bottomAnchor constant:20.0].active = YES;
    [self.descriptionTextField.heightAnchor constraintEqualToConstant:34.0].active = YES;
    [self.descriptionTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    [self.descriptionTextField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10.0].active = YES;
    
    self.privacyOptions = @[@"EVERYONE", @"ALL_FRIENDS", @"FRIENDS_OF_FRIENDS", @"SELF"];
    self.privacyPickerView.delegate = self;
    self.privacyPickerView.dataSource = self;
    self.privacyPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.privacyPickerView.backgroundColor = [UIColor colorWithRed:66/255.0 green:103/255.0 blue:178/255.0 alpha:1.0];
    self.privacyPickerView.layer.cornerRadius = 5.0;
    [self.view addSubview:self.privacyPickerView];
    [self.privacyPickerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.privacyPickerView.topAnchor constraintEqualToAnchor:self.descriptionTextField.bottomAnchor constant:30].active = YES;
    [self.privacyPickerView.heightAnchor constraintEqualToConstant:64].active = YES;
    [self.privacyPickerView.widthAnchor constraintEqualToAnchor:self.descriptionTextField.widthAnchor multiplier:0.5].active = YES;
    
    self.privacyLabel.textColor = [UIColor whiteColor];
    self.privacyLabel.numberOfLines = 2;
    self.privacyLabel.font = [UIFont systemFontOfSize:14];
    self.privacyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.privacyLabel.textAlignment = NSTextAlignmentCenter;
    NSString *privacyLabelText = [NSString stringWithFormat:@"%@\n%@",@"Privacy",@"Setting:"];
    self.privacyLabel.text = privacyLabelText;
    [self.view addSubview:self.privacyLabel];
    [self.privacyLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:5.0].active = YES;
    [self.privacyLabel.trailingAnchor constraintEqualToAnchor:self.privacyPickerView.leadingAnchor constant:10.0].active = YES;
    [self.privacyLabel.topAnchor constraintEqualToAnchor:self.descriptionTextField.bottomAnchor constant:30].active = YES;
    [self.privacyLabel.heightAnchor constraintEqualToAnchor:self.privacyPickerView.heightAnchor].active = YES;
    
    self.startButton.backgroundColor = [UIColor colorWithRed:66/255.0 green:103/255.0 blue:178/255.0 alpha:1.0];
    [self.startButton setTitle:NSLocalizedString(@"Go Live", @"Title for button to start LiveStream") forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.startButton.layer.cornerRadius = 3.0;
    [self.view addSubview:self.startButton];
    [self.startButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.startButton.topAnchor constraintEqualToAnchor:self.privacyPickerView.bottomAnchor constant:30].active = YES;
    [self.startButton.widthAnchor constraintEqualToAnchor:self.descriptionTextField.widthAnchor multiplier:0.5].active = YES;
    
    [self.closeButton setImage:[UIImage dux_imageWithAssetNamed:@"XButton" forClass:[self class]] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeViewController) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.closeButton];
    [self.closeButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:5.0].active = YES;
    [self.closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:5.0].active = YES;
    [self.closeButton.heightAnchor constraintEqualToConstant:20.0].active = YES;
    [self.closeButton.widthAnchor constraintEqualToConstant:20.0].active = YES;
}

- (void)updateUI {
    self.privacyLabel.font = self.privacyLabelFont;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.privacyOptions[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel*) view;
    if (!label){
        label = [[UILabel alloc] init];
        label.font = [label.font fontWithSize:14];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    label.text = self.privacyOptions[row];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.privacyOptionSelected = self.privacyOptions[row];
}

- (void)startAction {
    if (self.startedLiveStreaming) {
        self.startedLiveStreaming = NO;
        [self.context stopLiveStream];
        [self.startButton setTitle:NSLocalizedString(@"Go Live", @"Title for button to start LiveStream") forState:UIControlStateNormal];
    } else {
        self.startedLiveStreaming = YES;
        [self.context startLiveStream];
        [self.startButton setTitle:NSLocalizedString(@"Stop Live", @"Title for button to stop LiveStream") forState:UIControlStateNormal];
    }
}

- (void)closeViewController {
    [self.parentViewController willMoveToParentViewController:nil];
    [self.parentViewController.view removeFromSuperview];
    [self.parentViewController removeFromParentViewController];
    [self.parentViewController didMoveToParentViewController:nil];
}

- (void)setPrivacyLabelFont:(UIFont *)privacyLabelFont {
    _privacyLabelFont = privacyLabelFont;
    [self updateUI];
}

@end
