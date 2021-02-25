//
//  DUXBetaSpeakerMemoryListView.m
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

#import "DUXBetaSpeakerMemoryListView.h"

@interface DUXBetaSpeakerMemoryListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DUXBetaSpeakerMediaListSyncer *syncer;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UISwitch *loopAudioSwitch;

@end

@implementation DUXBetaSpeakerMemoryListView

- (instancetype)initWithFrame:(CGRect)frame andMediaSyncer:(DUXBetaSpeakerMediaListSyncer *)syncer {
    self = [super initWithFrame:frame];
    if (self) {
        self.syncer = syncer;
        BindRKVOModel(self.syncer, @selector(syncState), state);
        [self.syncer setPlayMode:DJISpeakerPlayModeSingleOnce completion:^(NSError * error) {}];
        [self setupUI];
        _contentLabelTextColor = self.contentLabel.textColor;
        _contentLabelFont = self.contentLabel.font;
        _indicatorViewColor = self.indicatorView.color;
        _loopAudioSwitchOnTintColor = self.loopAudioSwitch.onTintColor;
        _loopAudioSwitchTintColor = self.loopAudioSwitch.tintColor;
        _loopAudioSwitchThumbTintColor = self.loopAudioSwitch.thumbTintColor;
        _loopAudioSwitchOnImage = self.loopAudioSwitch.onImage;
        _loopAudioSwitchOffImage = self.loopAudioSwitch.offImage;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [[DUXBetaSpeakerMemoryListView alloc] initWithFrame:frame andMediaSyncer:[[DUXBetaSpeakerMediaListSyncer alloc]init]];
    return self;
}

- (void)dealloc {
    UnBindRKVOModel(self);
}

- (void)setupUI {    
    UILabel *loopAudioLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    loopAudioLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    loopAudioLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    loopAudioLabel.text = NSLocalizedString(@"Loop audio playback", @"Speaker Panel Loop audio Text");
    [self addSubview:loopAudioLabel];
    
    self.loopAudioSwitch = [[UISwitch alloc] init];
    self.loopAudioSwitch.tintColor = [UIColor whiteColor];
    self.loopAudioSwitch.on = NO;
    [self.loopAudioSwitch addTarget:self action:@selector(loopAudioSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.loopAudioSwitch];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.textColor = [UIColor lightGrayColor];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.contentLabel];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:self.indicatorView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self addSubview: self.tableView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    loopAudioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.loopAudioSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.loopAudioSwitch.topAnchor constraintEqualToAnchor:self.topAnchor constant:10].active = YES;
    [self.loopAudioSwitch.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10].active = YES;
    
    [loopAudioLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
    [loopAudioLabel.trailingAnchor constraintEqualToAnchor:self.loopAudioSwitch.leadingAnchor constant:-5].active = YES;
    [loopAudioLabel.centerYAnchor constraintEqualToAnchor:self.loopAudioSwitch.centerYAnchor].active = YES;
    
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:self.loopAudioSwitch.bottomAnchor constant:10].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
    [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10].active = YES;
    [self.contentLabel.centerYAnchor constraintEqualToAnchor:self.tableView.centerYAnchor].active = YES;
    
    [self.indicatorView.widthAnchor constraintEqualToConstant:60].active = YES;
    [self.indicatorView.heightAnchor constraintEqualToConstant:60].active = YES;
    [self.indicatorView.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor].active = YES;
    [self.indicatorView.centerYAnchor constraintEqualToAnchor:self.tableView.centerYAnchor].active = YES;
    
    [self syncState];
}

- (void)syncState {
    DUXBetaSpeakerMediaListSyncerState state = self.syncer.state;
    switch (state) {
        case DUXBetaSpeakerMediaListSyncerStateIdle: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicatorView stopAnimating];
                self.contentLabel.hidden = NO;
                self.contentLabel.text = NSLocalizedString(@"Speaker not available.", @"Speaker Panel Speaker not available Text");
                self.tableView.hidden = YES;
                [self.tableView reloadData];
            });
        }
            break;
        case DUXBetaSpeakerMediaListSyncerStateUpToDate: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicatorView stopAnimating];
                self.contentLabel.hidden = YES;
                self.contentLabel.text = @"";
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            });
        }
            break;
        case DUXBetaSpeakerMediaListSyncerStateLoading: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicatorView startAnimating];
                self.contentLabel.hidden = YES;
                self.contentLabel.text = @"";
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            });
        }
            break;
        case DUXBetaSpeakerMediaListSyncerStateError: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicatorView stopAnimating];
                self.contentLabel.hidden = NO;
                self.contentLabel.text = NSLocalizedString(@"Speaker not available.", @"Speaker Panel Speaker not available Text");
                self.tableView.hidden = YES;
                [self.tableView reloadData];
            });
        }
            break;
    }
}

#pragma mark - Actions

- (void)playActionHandle:(DUXBetaSpeakerMediaModel *)model {
    [self.syncer playFileWithIndex:model.fileIndex completion:^(NSError * error) {
        //NSLog(@"Play error %@", error);
    }];
}

- (void)stopActionHandle:(DUXBetaSpeakerMediaModel *)model {
    [self.syncer stopPlayFileWithIndex:model.fileIndex completion:^(NSError * error) {
        //NSLog(@"Stop play error %@", error);
    }];
}

- (void)deleteActionHandle:(DUXBetaSpeakerMediaModel *)model {
    [self.syncer deleteFileWithIndex:model.fileIndex completion:^(NSError * error) {
        //NSLog(@"Delete error %@", error);
    }];
}

#pragma mark - TableView Delegate and Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* modelList = self.syncer.modelList;
    if (!modelList) {
        return 0;
    }
    return modelList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"com.dji.accessory.speaker.settingscell";
    
    DUXBetaSpeakerPlaylistTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[DUXBetaSpeakerPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.model = self.syncer.modelList[indexPath.row];
    
    __weak typeof (self) target = self;
    cell.playAction = ^(DUXBetaSpeakerMediaModel *model) {
        [target playActionHandle:model];
    };
    
    cell.stopAction = ^(DUXBetaSpeakerMediaModel *model) {
        [target stopActionHandle:model];
    };
    
    cell.deleteAction = ^(DUXBetaSpeakerMediaModel *model) {
        [target deleteActionHandle:model];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.willDisplaySpeakerPlaylistCell) {
        self.willDisplaySpeakerPlaylistCell((DUXBetaSpeakerPlaylistTableViewCell *)cell, indexPath);
    }
}

- (void)loopAudioSwitchChanged:(id)sender {
    [self.syncer setPlayMode:self.loopAudioSwitch.isOn ? DJISpeakerPlayModeRepeatSingle: DJISpeakerPlayModeSingleOnce completion:^(NSError * error) {}];
}

- (void)setContentLabelTextColor:(UIColor *)contentLabelTextColor {
    _contentLabelTextColor = contentLabelTextColor;
    self.contentLabel.textColor = contentLabelTextColor;
}

- (void)setContentLabelFont:(UIFont *)contentLabelFont {
    _contentLabelFont = contentLabelFont;
    self.contentLabel.font = contentLabelFont;
}

- (void)setIndicatorViewColor:(UIColor *)indicatorViewColor {
    _indicatorViewColor = indicatorViewColor;
    self.indicatorView.color = indicatorViewColor;
}

- (void)setLoopAudioSwitchOnTintColor:(UIColor *)loopAudioSwitchOnTintColor {
    _loopAudioSwitchOnTintColor = loopAudioSwitchOnTintColor;
    self.loopAudioSwitch.onTintColor = loopAudioSwitchOnTintColor;
}

- (void)setLoopAudioSwitchTintColor:(UIColor *)loopAudioSwitchTintColor {
    _loopAudioSwitchTintColor = loopAudioSwitchTintColor;
    self.loopAudioSwitch.tintColor = loopAudioSwitchTintColor;
}

- (void)setLoopAudioSwitchThumbTintColor:(UIColor *)loopAudioSwitchThumbTintColor {
    _loopAudioSwitchThumbTintColor = loopAudioSwitchThumbTintColor;
    self.loopAudioSwitch.thumbTintColor = loopAudioSwitchThumbTintColor;
}

- (void)setLoopAudioSwitchOnImage:(UIImage *)loopAudioSwitchOnImage {
    _loopAudioSwitchOnImage = loopAudioSwitchOnImage;
    self.loopAudioSwitch.onImage = loopAudioSwitchOnImage;
}

- (void)setLoopAudioSwitchOffImage:(UIImage *)loopAudioSwitchOffImage {
    _loopAudioSwitchOffImage = loopAudioSwitchOffImage;
    self.loopAudioSwitch.offImage = loopAudioSwitchOffImage;
}

@end
