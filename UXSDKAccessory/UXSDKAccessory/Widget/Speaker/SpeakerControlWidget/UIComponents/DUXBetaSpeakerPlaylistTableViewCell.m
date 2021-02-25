//
//  DUXBetaSpeakerPlaylistTableViewCell.m
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

#import "DUXBetaSpeakerPlaylistTableViewCell.h"
@import UXSDKCore;

#define duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET (10.0f)
@interface DUXBetaSpeakerPlaylistTableViewCell ()

@property (nonatomic, strong) UIImageView* playingImageView;
@property (nonatomic, strong) UILabel* indexLabel;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* durationLabel;
@property (nonatomic, strong) UIButton* deleteButton;
@property (nonatomic, strong) UIButton* playButton;

@end

@implementation DUXBetaSpeakerPlaylistTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _playingImage = [UIImage duxbeta_imageWithAssetNamed:@"SpeakerSettingsPlaying" forClass:[self class]];
        _deleteButtonImage = [UIImage duxbeta_imageWithAssetNamed:@"SpeakerSettingsDelete" forClass:[self class]];
        _playImage = [UIImage duxbeta_imageWithAssetNamed:@"SpeakerSettingsPlay" forClass:[self class]];
        _pauseImage = [UIImage duxbeta_imageWithAssetNamed:@"SpeakerSettingsPause" forClass:[self class]];
        
        _indexLabelTextColor = [UIColor lightGrayColor];
        _indexLabelFont = [UIFont systemFontOfSize:12];
        
        _titleLabelTextColor = [UIColor whiteColor];
        _titleLabelFont = [UIFont boldSystemFontOfSize:12];
        
        _durationLabelTextColor = [UIColor lightGrayColor];
        _durationLabelFont = [UIFont systemFontOfSize:10];
        
        self.playingImageView = [[UIImageView alloc] initWithImage:self.playingImage];
        self.playingImageView.hidden = YES;
        [self.contentView addSubview:self.playingImageView];
        
        self.indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.indexLabel.font = self.indexLabelFont;
        self.indexLabel.textColor = self.indexLabelTextColor;
        self.indexLabel.text = @"1";
        self.indexLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.indexLabel];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = self.titleLabelFont;
        self.titleLabel.textColor = self.titleLabelTextColor;
        self.titleLabel.text = NSLocalizedString(@"Voice Memo Name", @"Speaker Panel Voice memo name Text");
        [self.contentView addSubview:self.titleLabel];
        
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.durationLabel.font = self.durationLabelFont;
        self.durationLabel.textColor = self.durationLabelTextColor;
        self.durationLabel.text = @"00:24";
        [self.contentView addSubview:self.durationLabel];
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteButton setImage:self.deleteButtonImage forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(didClickedDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.deleteButton];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setImage:self.playImage forState:UIControlStateNormal];
        [self.playButton setImage:self.pauseImage forState:UIControlStateSelected];
        [self.playButton addTarget:self action:@selector(didClickedPlayButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.playButton];
        
        [self makeConstraints];
    }
    return self;
}

- (void)dealloc {
    UnBindRKVOModel(self);
}

- (void)didClickedDeleteButton {
    if (self.deleteAction) {
        self.deleteAction(self.model);
    }
}

- (void)didClickedPlayButton {
    if (self.model.isPlaying) {
        if (self.stopAction) {
            self.stopAction(self.model);
        }
    } else {
        if (self.playAction) {
            self.playAction(self.model);
        }
    }
}

- (void)setModel:(DUXBetaSpeakerMediaModel *) model {
    if (_model == model) {
        return;
    }
    [_model duxbeta_removeCustomObserver:self];
    _model = model;
    BindRKVOModel(model,@selector(syncData),fileName, isPlaying, playMode, durationInSeconds, displayIndex);
    [self syncData];
}

- (void)syncData {
    NSString *fileTitleText = self.model.fileName;
    if (!fileTitleText || [fileTitleText isEqualToString:@""]) {
        fileTitleText = [NSString stringWithFormat:@"Audio_(%@)",self.model.mediaFile.timeCreated];
    }
    
    self.titleLabel.text = fileTitleText;
    self.playingImageView.hidden = !self.model.isPlaying;
    self.indexLabel.hidden = self.model.isPlaying;
    self.durationLabel.text = [self timeFormatted:(int)self.model.durationInSeconds];
    self.indexLabel.text = [NSString stringWithFormat:@"%lu",self.model.displayIndex];
    self.playButton.selected = self.model.isPlaying;
    
    if (self.model.mediaFile.audioStorageLocation == DJIAudioStorageLocationTemporary) {
        self.durationLabel.text = @"Temporary file";
    }
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void)makeConstraints {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.playingImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.playingImageView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET * 2].active = YES;
    [self.playingImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.playingImageView.widthAnchor constraintEqualToConstant:15].active = YES;
    [self.playingImageView.heightAnchor constraintEqualToConstant:15].active = YES;
    
    [self.indexLabel.leftAnchor constraintEqualToAnchor:self.playingImageView.leftAnchor].active = YES;
    [self.indexLabel.rightAnchor constraintEqualToAnchor:self.playingImageView.rightAnchor].active = YES;
    [self.indexLabel.topAnchor constraintEqualToAnchor:self.playingImageView.topAnchor].active = YES;
    [self.indexLabel.bottomAnchor constraintEqualToAnchor:self.playingImageView.bottomAnchor].active = YES;
    
    [self.deleteButton.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET].active = YES;
    [self.deleteButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.deleteButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.deleteButton.widthAnchor constraintEqualToConstant:40].active = YES;
    
    [self.playButton.rightAnchor constraintEqualToAnchor:self.deleteButton.leftAnchor constant:-duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET].active = YES;
    [self.playButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.playButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.playButton.widthAnchor constraintEqualToConstant:40].active = YES;
    
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.playingImageView.trailingAnchor constant:duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.playButton.leadingAnchor constant:-duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET].active = YES;
    [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:-duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET/2].active = YES;
    
    [self.durationLabel.leadingAnchor constraintEqualToAnchor:self.playingImageView.trailingAnchor constant:duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET].active = YES;
    [self.durationLabel.trailingAnchor constraintEqualToAnchor:self.playButton.leadingAnchor constant:-duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET].active = YES;
    [self.durationLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:duxbeta_SPEAKER_PLAY_LIST_CELL_OFFSET/4].active = YES;
}

- (void)setPlayingImage:(UIImage *)playingImage {
    _playingImage = playingImage;
    self.playingImageView.image = playingImage;
}

- (void)setDeleteButtonImage:(UIImage *)deleteButtonImage {
    _deleteButtonImage = deleteButtonImage;
    [self.deleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
}

- (void)setPlayImage:(UIImage *)playImage {
    _playImage = playImage;
    [self.playButton setImage:playImage forState:UIControlStateNormal];
}

- (void)setPauseImage:(UIImage *)pauseImage {
    _pauseImage = pauseImage;
    [self.playButton setImage:pauseImage forState:UIControlStateSelected];
}

- (void)setIndexLabelTextColor:(UIColor *)indexLabelTextColor {
    _indexLabelTextColor = indexLabelTextColor;
    self.indexLabel.textColor = indexLabelTextColor;
}

- (void)setIndexLabelFont:(UIFont *)indexLabelFont {
    _indexLabelFont = indexLabelFont;
    self.indexLabel.font = indexLabelFont;
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    self.titleLabel.font = titleLabelFont;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor {
    _titleLabelTextColor = titleLabelTextColor;
    self.titleLabel.textColor = titleLabelTextColor;
}

- (void)setDurationLabelTextColor:(UIColor *)durationLabelTextColor {
    _durationLabelTextColor = durationLabelTextColor;
    self.durationLabel.textColor = durationLabelTextColor;
}

- (void)setDurationLabelFont:(UIFont *)durationLabelFont {
    _durationLabelFont = durationLabelFont;
    self.durationLabel.font = durationLabelFont;
}

@end
