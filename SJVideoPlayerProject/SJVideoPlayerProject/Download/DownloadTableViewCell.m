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
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) UILabel *statusLabel;
@property (nonatomic, strong, readonly) UIView *line;

@property (nonatomic, strong, readonly) UIButton *downloadBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@property (nonatomic, strong, readonly) UIButton *cancelBtn;

@end

@implementation DownloadTableViewCell
@synthesize downloadBtn = _downloadBtn;
@synthesize pauseBtn = _pauseBtn;
@synthesize cancelBtn = _cancelBtn;
@synthesize coverImageView = _coverImageView;
@synthesize titleLabel = _titleLabel;
@synthesize progressLabel = _progressLabel;
@synthesize statusLabel = _statusLabel;
@synthesize line = _line;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    [self _setupViews];
    [self _installNotifications];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
}

- (void)setModel:(SJVideo *)model {
    _model = model;
    _coverImageView.image = [UIImage imageNamed:model.testCoverImage];
    _titleLabel.text = model.title;
    [self setProgressStrWithProgress:model.downloadProgress];
    [self setDownloadStatusStrWithStatus:model.downloadStatus];
}

- (void)_installNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDownloadProgress:) name:SJMediaDownloadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDownloadStatusChanged:) name:SJMediaDownloadStatusChangedNotification object:nil];
}

- (void)mediaDownloadProgress:(NSNotification *)notifi {
    id<SJMediaEntity> entity = notifi.object;
    if ( entity.mediaId != _model.mediaId ) return;
    _model.downloadProgress = entity.downloadProgress;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setProgressStrWithProgress:[entity downloadProgress]];
    });
}

- (void)mediaDownloadStatusChanged:(NSNotification *)notifi {
    id<SJMediaEntity> entity = notifi.object;
    if ( entity.mediaId != _model.mediaId ) return;
    _model.downloadStatus = entity.downloadStatus;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDownloadStatusStrWithStatus:[entity downloadStatus]];
    });
}
#pragma mark -
- (void)_setupViews {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.progressLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.line];
    [self.contentView addSubview:self.downloadBtn];
    [self.contentView addSubview:self.pauseBtn];
    [self.contentView addSubview:self.cancelBtn];
    
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.offset(8);
        make.width.offset(100 * 375 / SJScreen_Min());
        make.height.equalTo(_coverImageView.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverImageView);
        make.leading.equalTo(_coverImageView.mas_trailing).offset(8);
        make.trailing.offset(-8);
    }];
    
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_coverImageView);
        make.top.equalTo(_coverImageView.mas_bottom).offset(8);
    }];
    
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_progressLabel.mas_bottom).offset(8);
        make.leading.equalTo(_progressLabel);
        make.bottom.offset(-8);
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_statusLabel.mas_bottom).offset(8);
        make.leading.equalTo(_statusLabel);
        make.trailing.offset(-8);
        make.height.offset(0.6);
    }];
    
    [_downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_pauseBtn.mas_leading).offset(-8);
        make.bottom.equalTo(_pauseBtn);
    }];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_cancelBtn.mas_leading).offset(-8);
        make.bottom.equalTo(_cancelBtn);
    }];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-8);
        make.bottom.offset(-8);
    }];
}

- (UIImageView *)coverImageView {
    if ( _coverImageView ) return _coverImageView;
    _coverImageView = [SJUIImageViewFactory imageViewWithBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1] viewMode:UIViewContentModeScaleAspectFill];
    return _coverImageView;
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
- (void)setProgressStrWithProgress:(float)progress {
    _progressLabel.text = [NSString stringWithFormat:@"Progress: %.0f%%", progress * 100];
}

- (void)setDownloadStatusStrWithStatus:(SJMediaDownloadStatus)status {
    NSString *prompt = nil;
    switch ( status ) {
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
