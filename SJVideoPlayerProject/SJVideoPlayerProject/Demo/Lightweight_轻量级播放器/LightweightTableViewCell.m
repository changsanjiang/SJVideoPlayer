//
//  LightweightTableViewCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "LightweightTableViewCell.h"
#import "SJVideoModel.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import <SJAttributeWorker.h>
#import "YYTapActionLabel.h"

@interface LightweightTableViewCell()

@property (nonatomic, strong, readonly) UIColor *commonColor;
@property (nonatomic, strong, readonly) UIImageView *avatarImageView;
@property (nonatomic, strong, readonly) YYLabel *nameLabel;
@property (nonatomic, strong, readonly) UIButton *attentionBtn;
@property (nonatomic, strong, readonly) UIImageView *coverImageView;
@property (nonatomic, strong, readonly) UIImageView *playImageView;
@property (nonatomic, strong, readonly) YYLabel *createTimeLabel;
@property (nonatomic, strong, readonly) UIView *separatorLine;

@property (nonatomic, strong, readonly) UIView *contentContainerView;
@property (nonatomic, strong, readonly) YYTapActionLabel *contentLabel;

@end

@implementation LightweightTableViewCell
@synthesize avatarImageView = _avatarImageView;
@synthesize nameLabel = _nameLabel;
@synthesize attentionBtn = _attentionBtn;
@synthesize contentLabel = _contentLabel;
@synthesize coverImageView = _coverImageView;
@synthesize playImageView = _playImageView;
@synthesize createTimeLabel = _createTimeLabel;
@synthesize contentContainerView = _contentContainerView;
@synthesize separatorLine = _separatorLine;

+ (CGFloat)nicknameMaxWidth {
    return SJScreen_W() - 12 - 44 - 8 * 2 - 60 - 12;
}

+ (CGFloat)contentMaxWidth {
    return SJScreen_W() - 12 * 2;
}

+ (void)sync_makeVideoContent:(SJTextAppearance)block {
    if ( block ) block([self contentMaxWidth], [UIFont boldSystemFontOfSize:14], [UIColor blackColor]);
}

+ (void)sync_makeNickname:(SJTextAppearance)block {
    if ( block ) block([self nicknameMaxWidth], [UIFont boldSystemFontOfSize:14], [UIColor whiteColor]);
}

+ (void)sync_makeCreateTime:(SJTextAppearance)block {
    if ( block ) block([self nicknameMaxWidth], [UIFont boldSystemFontOfSize:12], [UIColor whiteColor]);
}

+ (CGFloat)heightWithContentHeight:(CGFloat)contentHeight {
    return SJScreen_W() * 9 / 16 + contentHeight + 16;
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
    [self.contentView addSubview:self.coverImageView];
    [_coverImageView addSubview:self.avatarImageView];
    [_coverImageView addSubview:self.nameLabel];
    [_coverImageView addSubview:self.attentionBtn];
    [_coverImageView  addSubview:self.playImageView];
    [_coverImageView addSubview:self.createTimeLabel];
    [self.contentView addSubview:self.contentContainerView];
    [_contentContainerView addSubview:self.contentLabel];
    [_contentContainerView addSubview:self.separatorLine];

    
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.equalTo(_coverImageView.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.offset(8);
        make.size.offset(36);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_avatarImageView.mas_trailing).offset(6);
        make.centerY.equalTo(_avatarImageView);
    }];
    
    [_attentionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_avatarImageView);
        make.trailing.offset(-8);
        make.width.offset(50);
    }];
    
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_avatarImageView);
        make.bottom.equalTo(_coverImageView).offset(-8);
    }];
    
    [_contentContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverImageView.mas_bottom);
        make.leading.bottom.trailing.offset(0);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.bottom.equalTo(_separatorLine.mas_top);
        make.leading.offset(12);
        make.trailing.offset(-12);
    }];
    
    [_separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(8);
    }];
}

- (UIImageView *)avatarImageView {
    if ( _avatarImageView ) return _avatarImageView;
    _avatarImageView = [SJShapeImageViewFactory roundImageViewWithBackgroundColor:self.commonColor];
    return _avatarImageView;
}
- (UIButton *)attentionBtn {
    if ( _attentionBtn ) return _attentionBtn;
    _attentionBtn = [SJUIButtonFactory roundButtonWithTitle:@"关注" titleColor:[UIColor blueColor] font:[UIFont systemFontOfSize:12] backgroundColor:[UIColor whiteColor] target:nil sel:NULL tag:0];
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
- (UIView *)contentContainerView {
    if ( _contentContainerView ) return _contentContainerView;
    _contentContainerView = [SJUIViewFactory viewWithBackgroundColor:[UIColor whiteColor]];
    return _contentContainerView;
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

