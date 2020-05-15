//
//  DUXBetaAirSenseHtmlViewController.m
//  DJIUXSDKWidgets
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

#import "DUXBetaAirSenseDialogViewController.h"
#import "DUXBetaAirSenseHtmlViewController.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIColor+DUXBetaColors.h"
#import <CoreGraphics/CoreGraphics.h>
#import "DUXStateChangeBroadcaster.h"
#import "DUXBetaAirSenseWidgetUIState.h"

@import DJIUXSDKCommunication;
@import DJIUXSDKCore;

@interface DUXBetaAirSenseDialogViewController ()

@property (strong, nonatomic) UIButton *checkboxButton;
@property (strong, nonatomic) UIButton *termsButton;
@property (strong, nonatomic) UILabel *checkboxLabel;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation DUXBetaAirSenseDialogViewController

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message {
    self = [super init];
    if (self) {
        _dialogMessage = message;
        _dialogTitle = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(430, 315);
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self, @selector(updateUI),checkedCheckboxImage,
                                            uncheckedCheckboxImage,
                                            checkboxLabelTextColor,
                                            checkboxLabelTextFont,
                                            warningMessageTextColor,
                                            warningMessageTextFont,
                                            dialogTitle,
                                            dialogTitleTextColor,
                                            dialogMessage);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // There are 4 superviews, each masking one corner of the view.
    self.view.superview.superview.superview.superview.layer.cornerRadius = 2.0;
    self.view.superview.superview.superview.layer.cornerRadius = 2.0;
    self.view.superview.superview.layer.cornerRadius = 2.0;
    self.view.superview.layer.cornerRadius = 2.0;
    self.view.layer.cornerRadius = 2.0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[DUXStateChangeBroadcaster instance] send:[DUXBetaAirSenseWidgetUIState warningDialogDismiss]];
}

- (void)setupUI {
    //Title Label:
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightRegular];
    self.titleLabel.textColor = [UIColor duxbeta_blackColor];
    
    //Message text/button
    self.termsButton = [[UIButton alloc] init];
    self.termsButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.termsButton.titleLabel.textAlignment = NSTextAlignmentJustified;
    self.termsButton.backgroundColor = [UIColor clearColor];
    [self.termsButton addTarget:self action:@selector(presentTermsDialog) forControlEvents:UIControlEventTouchUpInside];
    self.termsButton.titleLabel.numberOfLines = 0;
    
    // Checkbox
    self.checkboxButton = [[UIButton alloc] init];
    self.checkboxButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.checkboxButton addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];

    // Checkbox Label
    self.checkboxLabel = [[UILabel alloc] init];
    self.checkboxLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.checkboxLabel.text = @"Don't show again";
    self.checkboxLabel.backgroundColor = [UIColor clearColor];
    self.checkboxLabel.textAlignment = NSTextAlignmentLeft;
    
    // Combined Checkbox + Label View
    UIView *boxAndLabelView = [[UIView alloc] init];
    boxAndLabelView.translatesAutoresizingMaskIntoConstraints = NO;
    [boxAndLabelView addSubview:self.checkboxButton];
    [boxAndLabelView addSubview:self.checkboxLabel];
    [boxAndLabelView.heightAnchor constraintEqualToConstant:28].active = YES;
    
    [self.checkboxButton.widthAnchor constraintEqualToConstant:28].active = YES;
    [self.checkboxButton.leadingAnchor constraintEqualToAnchor:boxAndLabelView.leadingAnchor constant:0.0].active = YES;
    [self.checkboxButton.heightAnchor constraintEqualToAnchor:boxAndLabelView.heightAnchor constant:0.0].active = YES;
    
    [self.checkboxLabel.leadingAnchor constraintEqualToAnchor:self.checkboxButton.trailingAnchor constant:10.0].active = YES;
    [self.checkboxLabel.centerYAnchor constraintEqualToAnchor:self.checkboxButton.centerYAnchor constant:0.0].active = YES;

    //Top level view:
    self.view.backgroundColor = [UIColor duxbeta_whiteColor];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.termsButton];
    [self.view addSubview:boxAndLabelView];
    
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:25.0].active = YES;
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20.0].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-25.0].active = YES;
    
    [self.termsButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15.0].active = YES;
    [self.termsButton.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:25.0].active = YES;
    [self.termsButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15.0].active = YES;
    
    [boxAndLabelView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:25.0].active = YES;
    [boxAndLabelView.topAnchor constraintEqualToAnchor:self.termsButton.bottomAnchor constant:40.0].active = YES;
    [boxAndLabelView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-25.0].active = YES;

    UIButton *okButton = [[UIButton alloc] init];
    okButton.translatesAutoresizingMaskIntoConstraints = false;
    
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    okButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    [okButton setTitleColor:[UIColor duxbeta_linkBlueColor] forState:UIControlStateNormal];
    UIColor *okBorderColor = [UIColor duxbeta_lightGrayTransparentColor];
    okButton.layer.borderColor = [okBorderColor CGColor];
    okButton.layer.borderWidth = 3.0;
    [self.view addSubview:okButton];
    [okButton.heightAnchor constraintEqualToConstant:75.0].active = YES;
    
    // Deliberately set outside the view so that only the top border shows
    [okButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:4.0].active = YES;
    [okButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:-4.0].active = YES;
    [okButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:4.0].active = YES;
    
    [self updateUI];
}

- (void)updateUI {
    [self.checkboxButton setBackgroundImage:self.checkedCheckboxImage forState:UIControlStateSelected];
    [self.checkboxButton setBackgroundImage:self.uncheckedCheckboxImage forState:UIControlStateNormal];
    self.checkboxLabel.textColor = self.checkboxLabelTextColor;
    self.checkboxLabel.font = self.checkboxLabelTextFont;
    [self.termsButton setTitleColor:self.warningMessageTextColor forState:UIControlStateNormal];
    [self.termsButton.titleLabel setFont:self.warningMessageTextFont];
    self.titleLabel.text = self.dialogTitle;
    self.titleLabel.textColor = self.dialogTitleTextColor;
    
    NSMutableAttributedString *messageText = [[NSMutableAttributedString alloc] initWithString:self.dialogMessage];
    
    NSMutableParagraphStyle *textSpacingStyle = [[NSMutableParagraphStyle alloc] init];
    textSpacingStyle.lineSpacing = 10;
    
    [messageText addAttribute:NSParagraphStyleAttributeName value:textSpacingStyle range:NSMakeRange(0, self.dialogMessage.length)];
    [messageText addAttribute:NSForegroundColorAttributeName value:self.warningMessageTextColor range:NSMakeRange(0, self.dialogMessage.length)];
    [messageText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, self.dialogMessage.length)];
    [self.termsButton setAttributedTitle:messageText forState:UIControlStateNormal];
}

- (void)presentTermsDialog {
    [[DUXStateChangeBroadcaster instance] send:[DUXBetaAirSenseWidgetUIState termsLinkTap]];

    UIViewController *htmlViewController = [[DUXBetaAirSenseHtmlViewController alloc] init];
    [self presentViewController:htmlViewController animated:YES completion:nil];
}

// Function to toggle "Don't show again" checkbox
- (void)toggleButton:(UIButton *)pressedButton {
    [[DUXStateChangeBroadcaster instance] send:[DUXBetaAirSenseWidgetUIState dontShowAgainCheckBoxTap:!pressedButton.selected]];
    
    pressedButton.selected = !pressedButton.selected;
}

- (void)dismissViewController {
    [[NSUserDefaults standardUserDefaults] setBool:self.checkboxButton.selected forKey:@"optOutAirSense"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
