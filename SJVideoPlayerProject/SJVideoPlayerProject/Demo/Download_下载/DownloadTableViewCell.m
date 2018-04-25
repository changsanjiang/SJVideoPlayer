//
//  DownloadTableViewCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "DownloadTableViewCell.h"
#import <SJUIFactory.h>
#import <Masonry.h>
#import "SJVideo+DownloadAdd.h"
#import "SJMediaDownloader.h"

@interface DownloadTableViewCell ()

@property (nonatomic, strong, readonly) UIImageView *coverImageView;
@property (nonatomic, strong, readonly) UIButton *playBtn;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) UILabel *statusLabel;
@property (nonatomic, strong, readonly) UILabel *speedLabel;
@property (nonatomic, strong, readonly) UIView *line;

@property (nonatomic, strong, readonly) UIButton *downloadBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@property (nonatomic, strong, readonly) UIButton *cancelBtn;

@end

@implementation DownloadTableViewCell
@synthesize downloadBtn = _downloadBtn;
@synthesize playBtn = _playBtn;
@synthesize pauseBtn = _pauseBtn;
@synthesize cancelBtn = _cancelBtn;
@synthesize coverImageView = _coverImageView;
@synthesize titleLabel = _titleLabel;
@synthesize progressLabel = _progressLabel;
@synthesize statusLabel = _statusLabel;
@synthesize speedLabel = _speedLabel;
@synthesize line = _line;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( btn == self.downloadBtn ) {
        if ( [self.delegate respondsToSelector:@selector(clickedDownloadBtnOnTabCell:)] ) {
            [self.delegate clickedDownloadBtnOnTabCell:self];
        }
    }
    else if ( btn == self.pauseBtn ) {
        if ( [self.delegate respondsToSelector:@selector(clickedPauseBtnOnTabCell:)] ) {
            [self.delegate clickedPauseBtnOnTabCell:self];
        }
    }
    else if ( btn == self.cancelBtn ) {
        if ( [self.delegate respondsToSelector:@selector(clickedCancelBtnOnTabCell:)] ) {
            [self.delegate clickedCancelBtnOnTabCell:self];
        }
    }
    else if ( btn == self.playBtn ) {
        if ( [self.delegate respondsToSelector:@selector(tabCell:clickedPlayBtnAtCoverImageView:)] ) {
            [self.delegate tabCell:self clickedPlayBtnAtCoverImageView:_coverImageView];
        }
    }
}
- (void)setModel:(SJVideo *)model {
    _model = model;
    _coverImageView.image = [UIImage imageNamed:model.testCoverImage];
    _titleLabel.text = model.title;
    [self update];
}
#pragma mark -
- (void)_setupViews {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.contentView addSubview:self.coverImageView];
    [self.coverImageView addSubview:self.playBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.progressLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.speedLabel];
    [self.contentView addSubview:self.line];
    [self.contentView addSubview:self.downloadBtn];
    [self.contentView addSubview:self.pauseBtn];
    [self.contentView addSubview:self.cancelBtn];
    
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.offset(8);
        make.width.offset(150 * 375 / SJScreen_Min());
        make.height.equalTo(self->_coverImageView.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_coverImageView);
        make.leading.equalTo(self->_coverImageView.mas_trailing).offset(8);
        make.trailing.offset(-8);
    }];
    
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self->_coverImageView);
        make.top.equalTo(self->_coverImageView.mas_bottom).offset(8);
    }];
    
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_progressLabel.mas_bottom).offset(8);
        make.leading.equalTo(self->_progressLabel);
    }];
    
    [_speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel.mas_bottom).offset(8);
        make.leading.equalTo(self.statusLabel);
        make.bottom.offset(-8);
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(8);
        make.bottom.offset(0);
        make.trailing.offset(-8);
        make.height.offset(0.6);
    }];
    
    [_downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self->_pauseBtn.mas_leading).offset(-8);
        make.bottom.equalTo(self->_pauseBtn);
    }];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self->_cancelBtn.mas_leading).offset(-8);
        make.bottom.equalTo(self->_cancelBtn);
    }];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-8);
        make.bottom.offset(-8);
    }];
}

- (UIImageView *)coverImageView {
    if ( _coverImageView ) return _coverImageView;
    _coverImageView = [SJUIImageViewFactory imageViewWithBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1] viewMode:UIViewContentModeScaleAspectFill];
    _coverImageView.userInteractionEnabled = YES;
    _coverImageView.tag = 101;
    return _coverImageView;
}
- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [SJUIButtonFactory buttonWithImageName:@"play" target:self sel:@selector(clickedBtn:) tag:0];
    return _playBtn;
}
- (UILabel *)titleLabel {
    if ( _titleLabel ) return _titleLabel;
    _titleLabel = [SJUILabelFactory labelWithFont:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor]];
    _titleLabel.numberOfLines = 0;
    return _titleLabel;
}
- (UILabel *)progressLabel {
    if ( _progressLabel ) return _progressLabel;
    _progressLabel = [SJUILabelFactory labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor]];
    return _progressLabel;
}
- (UILabel *)statusLabel {
    if ( _statusLabel ) return _statusLabel;
    _statusLabel = [SJUILabelFactory labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor]];
    return _statusLabel;
}
- (UILabel *)speedLabel {
    if ( _speedLabel ) return _speedLabel;
    _speedLabel = [SJUILabelFactory labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor]];
    return _speedLabel;
}
- (UIView *)line {
    if ( _line ) return _line;
    _line = [SJUIViewFactory viewWithBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    return _line;
}
- (UIButton *)downloadBtn {
    if ( _downloadBtn ) return _downloadBtn;
    _downloadBtn = [SJShapeButtonFactory buttonWithCornerRadius:6 title:@"Download" titleColor:[UIColor whiteColor] target:self sel:@selector(clickedBtn:)];
    _downloadBtn.backgroundColor = [UIColor blueColor];
    return _downloadBtn;
}
- (UIButton *)pauseBtn {
    if ( _pauseBtn ) return _pauseBtn;
    _pauseBtn = [SJShapeButtonFactory buttonWithCornerRadius:6 title:@"Pause" titleColor:[UIColor whiteColor] target:self sel:@selector(clickedBtn:)];
    _pauseBtn.backgroundColor = [UIColor blueColor];
    return _pauseBtn;
}
- (UIButton *)cancelBtn {
    if ( _cancelBtn ) return _cancelBtn;
    _cancelBtn = [SJShapeButtonFactory buttonWithCornerRadius:6 title:@"Cancel" titleColor:[UIColor whiteColor] target:self sel:@selector(clickedBtn:)];
    _cancelBtn.backgroundColor = [UIColor blueColor];
    return _cancelBtn;
}

#pragma mark -
- (void)update {
    [self updateProgress];
    [self updateStatus];
}
- (void)updateProgress {
    float downloadProgress = _model.entity.downloadProgress;
    _progressLabel.text = [NSString stringWithFormat:@"Progress: %.0f%%", downloadProgress * 100];
    
    if ( 1 != downloadProgress )
         _speedLabel.text = [NSString stringWithFormat:@"Speed: %.02fM/s", (1.0 * _model.entity.speed) / 1024 / 1024];
    else _speedLabel.text = @"Speed: 0M/s";
}
- (void)updateStatus {
    NSString *prompt = nil;
    switch ( _model.entity.downloadStatus ) {
        case SJMediaDownloadStatus_Unknown: {
            prompt = @"Unknown";
        }
            break;
        case SJMediaDownloadStatus_Waiting: {
            prompt = @"Waiting";
        }
            break;
        case SJMediaDownloadStatus_Downloading: {
            prompt = @"Downloading";
        }
            break;
        case SJMediaDownloadStatus_Finished: {
            prompt = @"Finished";
        }
            break;
        case SJMediaDownloadStatus_Paused: {
            prompt = @"Paused";
        }
            break;
        case SJMediaDownloadStatus_Failed: {
            prompt = @"Failed";
        }
            break;
        case SJMediaDownloadStatus_Deleted: {
            prompt = @"Deleted";
        }
            break;
        case SJMediaDownloadStatus_TimeOut: {
            prompt = @"TimeOut";
        }
            break;
        case SJMediaDownloadStatus_UnsupportedURL: {
            prompt = @"UnsupportedURL";
        }
            break;
        case SJMediaDownloadStatus_ConnectionWasLost: {
            prompt = @"ConnectionWasLost";
        }
            break;
        case SJMediaDownloadStatus_BadURL: {
            prompt = @"BadURL";
        }
            break;
        case SJMediaDownloadStatus_NotConnectedToInternet: {
            prompt = @"NotConnectedToInternet";
        }
            break;
    }
    
    _statusLabel.text = [NSString stringWithFormat:@"Status: %@", prompt];
}
@end
