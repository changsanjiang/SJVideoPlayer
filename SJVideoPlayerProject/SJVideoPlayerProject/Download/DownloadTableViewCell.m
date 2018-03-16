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
#import "SJVideo.h"

@interface DownloadTableViewCell ()

@property (nonatomic, strong, readonly) UIImageView *coverImageView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) UILabel *statusLabel;
@property (nonatomic, strong, readonly) UIView *line;

@end

@implementation DownloadTableViewCell
@synthesize coverImageView = _coverImageView;
@synthesize titleLabel = _titleLabel;
@synthesize progressLabel = _progressLabel;
@synthesize statusLabel = _statusLabel;
@synthesize line = _line;

+ (CGFloat)height {
    return ceil(8 + (100 * 375 / SJScreen_Min() * 9 / 16.0) + 1 + 8);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)setModel:(SJVideo *)model {
    _model = model;
    _titleLabel.text = model.title;
}

#pragma mark -
- (void)_setupViews {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.progressLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.line];
    
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
        make.leading.equalTo(_titleLabel);
        make.bottom.equalTo(_coverImageView);
    }];
    
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_titleLabel);
        make.bottom.equalTo(_progressLabel);
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverImageView.mas_bottom).offset(8);
        make.leading.equalTo(_coverImageView);
        make.trailing.offset(-8);
        make.height.offset(0.6);
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
@end
