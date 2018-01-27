//
//  SJVideoListTableViewCell.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoListTableViewCell.h"
#import "SJVideoModel.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import <SJLabel/SJLabel.h>

@interface SJVideoListTableViewCell()

@property (nonatomic, strong, readonly) UIImageView *avatarImageView;
@property (nonatomic, strong, readonly) SJLabel *nameLabel;
@property (nonatomic, strong, readonly) UIButton *attentionBtn;
@property (nonatomic, strong, readonly) SJLabel *contentLabel;
@property (nonatomic, strong, readonly) UIImageView *coverImageView;
@property (nonatomic, strong, readonly) UIImageView *playImageView;
@property (nonatomic, strong, readonly) SJLabel *createTimeLabel;
@property (nonatomic, strong, readonly) UIView *separatorLine;

@property (nonatomic, strong, readonly) UIColor *commonColor;
@end

@implementation SJVideoListTableViewCell
@synthesize avatarImageView = _avatarImageView;
@synthesize nameLabel = _nameLabel;
@synthesize attentionBtn = _attentionBtn;
@synthesize contentLabel = _contentLabel;
@synthesize coverImageView = _coverImageView;
@synthesize playImageView = _playImageView;
@synthesize createTimeLabel = _createTimeLabel;
@synthesize separatorLine = _separatorLine;

+ (CGFloat)nicknameMaxWidth {
    return SJScreen_W() - 12 - 44 - 8 * 2 - 60 - 12;
}

+ (CGFloat)contentMaxWidth {
    return SJScreen_W() - 12 * 2;
}

+ (NSString *)sj_processTimeWithCreateDate:(NSTimeInterval)createDate nowDate:(NSTimeInterval)nowDate {
    
    double value = nowDate - createDate;
    
    if ( value < 0 ) {
        return @"火星时间";
    }
    
    NSInteger year  = value / 31104000;
    NSInteger month = value / 2592000;
    NSInteger week  = value / 604800;
    NSInteger day   = value / 86400;
    NSInteger hour  = value / 3600;
    NSInteger min   = value / 60;
    
    if ( year > 0 ) {
        return [NSString stringWithFormat:@"%zd年前", year];
    }
    else if ( month > 0 ) {
        return [NSString stringWithFormat:@"%zd月前", month];
    }
    else if ( week > 0 ) {
        return [NSString stringWithFormat:@"%zd周前", week];
    }
    else if ( day > 0 ) {
        return [NSString stringWithFormat:@"%zd天前", day];
    }
    else if ( hour > 0 ) {
        return [NSString stringWithFormat:@"%zd小时前", hour];
    }
    else if ( min > 0 ) {
        return [NSString stringWithFormat:@"%zd分钟前", min];
    }
    else {
        return @"刚刚";
    }
    return @"";
}

+ (SJVideoHelper *)helperWithCreateTime:(NSTimeInterval)createTime {
    SJVideoHelper *helper = [[SJVideoHelper alloc] initWithContent:[self sj_processTimeWithCreateDate:createTime nowDate:[NSDate date].timeIntervalSince1970] font:[UIFont systemFontOfSize:12] textColor:[UIColor lightGrayColor] numberOfLines:1 maxWidth:[self nicknameMaxWidth]];
    return helper;
}

+ (SJVideoHelper *)helperWithNickname:(NSString *)nickname; {
    SJVideoHelper *helper = [[SJVideoHelper alloc] initWithContent:nickname font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor blackColor] numberOfLines:1 maxWidth:[self nicknameMaxWidth]];
    return helper;
}

+ (SJVideoHelper *)helperWithContent:(NSString *)content {
    SJVideoHelper *helper = [[SJVideoHelper alloc] initWithContent:content font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] numberOfLines:0 maxWidth:[self contentMaxWidth]];
    return helper;
}

+ (CGFloat)heightWithContentHeight:(CGFloat)contentHeight {
    return 14 + 44 + 8 + contentHeight + 8 + ([self contentMaxWidth] * 9 / 16.0f) + 8;
}



#pragma mark -


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    [self _setupViews];
    [self _addTapGesture];
    return self;
}

- (void)_addTapGesture {
    _coverImageView.userInteractionEnabled = YES;
    _coverImageView.tag = 101;
    [_coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if ( [_delegate respondsToSelector:@selector(clickedPlayOnTabCell:playerParentView:)] ) {
        [_delegate clickedPlayOnTabCell:self playerParentView:tap.view];
    }
}

- (void)setModel:(SJVideoModel *)model {
    _model = model;
    _avatarImageView.image = [UIImage imageNamed:model.creator.avatar];
    _coverImageView.image = [UIImage imageNamed:model.coverURLStr];
    
    _nameLabel.drawData = model.nicknameHelper.contentData;
    _contentLabel.drawData = model.contentHelper.contentData;
    _createTimeLabel.drawData = model.createTimeHelper.contentData;
}

- (void)_setupViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.createTimeLabel];
    [self.contentView addSubview:self.attentionBtn];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.coverImageView];
    [_coverImageView  addSubview:self.playImageView];
    [self.contentView addSubview:self.separatorLine];
    
    [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(14);
        make.leading.offset(12);
        make.size.offset(44);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_avatarImageView.mas_trailing).offset(8);
        make.bottom.equalTo(_avatarImageView.mas_centerY);
        make.trailing.equalTo(_attentionBtn.mas_leadingMargin);
    }];
    
    [_createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_nameLabel);
        make.bottom.equalTo(_avatarImageView);
    }];
    
    [_attentionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-12);
        make.centerY.equalTo(_avatarImageView);
        make.width.offset(60);
    }];
    
    [SJUIFactory boundaryProtectedWithView:_attentionBtn];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_avatarImageView.mas_bottom).offset(8);
        make.leading.equalTo(_avatarImageView);
        make.trailing.equalTo(_attentionBtn);
    }];
    
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentLabel.mas_bottom).offset(8);
        make.leading.trailing.equalTo(_contentLabel);
        make.height.equalTo(_coverImageView.mas_width).multipliedBy(9.0f / 16);
    }];
    
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_coverImageView);
    }];
    
    [_separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(0.6);
    }];
    
}

- (UIImageView *)avatarImageView {
    if ( _avatarImageView ) return _avatarImageView;
    _avatarImageView = [SJShapeImageViewFactory roundImageViewWithBackgroundColor:self.commonColor];
    return _avatarImageView;
}
- (SJLabel *)nameLabel {
    if ( _nameLabel ) return _nameLabel;
    _nameLabel = [SJLabel new];
    _nameLabel.preferredMaxLayoutWidth = [[self class] nicknameMaxWidth];
    return _nameLabel;
}
- (UIButton *)attentionBtn {
    if ( _attentionBtn ) return _attentionBtn;
    _attentionBtn = [SJUIButtonFactory roundButtonWithTitle:@"关注" titleColor:[UIColor blueColor] font:[UIFont systemFontOfSize:14] backgroundColor:[UIColor whiteColor] target:nil sel:NULL tag:0];
    _attentionBtn.layer.borderColor = [UIColor blueColor].CGColor;
    _attentionBtn.layer.borderWidth = 0.6;
    _attentionBtn.layer.cornerRadius = 15;
    return _attentionBtn;
}
- (SJLabel *)contentLabel {
    if ( _contentLabel ) return _contentLabel;
    _contentLabel = [SJLabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.preferredMaxLayoutWidth = [[self class] contentMaxWidth];
    return _contentLabel;
}
- (UIImageView *)coverImageView {
    if ( _coverImageView ) return _coverImageView;
    _coverImageView = [SJUIImageViewFactory imageViewWithViewMode:UIViewContentModeScaleAspectFill];
    return _coverImageView;
}
- (UIImageView *)playImageView {
    if ( _playImageView ) return _playImageView;
    _playImageView = [SJUIImageViewFactory imageViewWithImageName:@"play"];
    return _playImageView;
}
- (SJLabel *)createTimeLabel {
    if ( _createTimeLabel ) return _createTimeLabel;
    _createTimeLabel = [SJLabel new];
    _nameLabel.preferredMaxLayoutWidth = [[self class] nicknameMaxWidth];
    return _createTimeLabel;
}
- (UIView *)separatorLine {
    if ( _separatorLine ) return _separatorLine;
    _separatorLine = [SJUIViewFactory viewWithBackgroundColor:self.commonColor];
    return _separatorLine;
}
- (UIColor *)commonColor {
    float value = 230.0 / 255;
    return [UIColor colorWithRed:value green:value blue:value alpha:1];
}
@end
