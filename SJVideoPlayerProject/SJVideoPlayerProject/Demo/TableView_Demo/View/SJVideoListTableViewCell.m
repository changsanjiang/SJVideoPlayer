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
#import <SJAttributeWorker.h>
#import "YYTapActionLabel.h"

@interface SJVideoListTableViewCell()

@property (nonatomic, strong, readonly) UIImageView *avatarImageView;
@property (nonatomic, strong, readonly) YYLabel *nameLabel;
@property (nonatomic, strong, readonly) UIButton *attentionBtn;
@property (nonatomic, strong, readonly) YYTapActionLabel *contentLabel;
@property (nonatomic, strong, readonly) UIImageView *coverImageView;
@property (nonatomic, strong, readonly) UIImageView *playImageView;
@property (nonatomic, strong, readonly) YYLabel *createTimeLabel;
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

+ (void)sync_makeVideoContent:(void(^)(CGFloat contentMaxWidth, UIFont *font, UIColor *textColor))block {
    if ( block ) block([self contentMaxWidth], [UIFont boldSystemFontOfSize:14], [UIColor blackColor]);
}

+ (void)sync_makeNickName:(void (^)(CGFloat contentMaxWidth, UIFont *font, UIColor *textColor))block {
    if ( block ) block([self nicknameMaxWidth], [UIFont boldSystemFontOfSize:14], [UIColor blackColor]);
}

+ (void)sync_makeCreateTime:(void (^)(CGFloat contentMaxWidth, UIFont *font, UIColor *textColor))block {
    if ( block ) block([self nicknameMaxWidth], [UIFont boldSystemFontOfSize:12], [UIColor blackColor]);
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
#warning should be set it tag. 应该设置它的`tag`. 请不要设置为0.
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
    _nameLabel.textLayout = model.nicknameLayout;
    _createTimeLabel.textLayout = model.createTimeLayout;
    _contentLabel.textLayout = model.videoContentLayout;
}

- (void)_setupViews {
    self.clipsToBounds = NO;
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
        make.trailing.equalTo(_attentionBtn.mas_leading).offset(-8);
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
- (UIButton *)attentionBtn {
    if ( _attentionBtn ) return _attentionBtn;
    _attentionBtn = [SJUIButtonFactory roundButtonWithTitle:@"关注" titleColor:[UIColor blueColor] font:[UIFont systemFontOfSize:14] backgroundColor:[UIColor whiteColor] target:nil sel:NULL tag:0];
    _attentionBtn.layer.borderColor = [UIColor blueColor].CGColor;
    _attentionBtn.layer.borderWidth = 0.6;
    _attentionBtn.layer.cornerRadius = 15;
    return _attentionBtn;
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
- (YYTapActionLabel *)contentLabel {
    if ( _contentLabel ) return _contentLabel;
    _contentLabel = [YYTapActionLabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.userInteractionEnabled = YES;
    _contentLabel.preferredMaxLayoutWidth = [[self class] contentMaxWidth];
    _contentLabel.displaysAsynchronously = YES;
    _contentLabel.ignoreCommonProperties = YES;
    return _contentLabel;
}
- (YYLabel *)nameLabel {
    if ( _nameLabel ) return _nameLabel;
    _nameLabel = [YYLabel new];
    _nameLabel.preferredMaxLayoutWidth = [[self class] nicknameMaxWidth];
    _nameLabel.displaysAsynchronously = YES;
    _nameLabel.ignoreCommonProperties = YES;
    return _nameLabel;
}
- (YYLabel *)createTimeLabel {
    if ( _createTimeLabel ) return _createTimeLabel;
    _createTimeLabel = [YYLabel new];
    _createTimeLabel.displaysAsynchronously = YES;
    _createTimeLabel.ignoreCommonProperties = YES;
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
