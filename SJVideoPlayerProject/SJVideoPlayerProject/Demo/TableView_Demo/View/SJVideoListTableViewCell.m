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
#import <objc/message.h>

@interface SJVideoListTableViewCell()

@property (nonatomic, strong, readonly) UIImageView *avatarImageView;
@property (nonatomic, strong, readonly) YYLabel *nameLabel;
@property (nonatomic, strong, readonly) UIButton *attentionBtn;
@property (nonatomic, strong, readonly) YYTapActionLabel *contentLabel;
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

static const char *kNickName = "kNickName";
static const char *kCreateTime = "kCreateTime";
static const char *kVideoTitle = "kVideoTitle";

+ (void)sync_makeContentWithVideo:(SJVideoModel *)video tappedDelegate:(id<NSAttributedStringTappedDelegate>)tappedDelegate {
    YYTextContainer *container;
    YYTextLayout *textLayout;

    // nickname
    container = [YYTextContainer containerWithSize:CGSizeMake(SJScreen_W() - 12 - 44 - 8 * 2 - 60 - 12, CGFLOAT_MAX)];
    container.maximumNumberOfRows = 1;
    textLayout = [YYTextLayout layoutWithContainer:container text:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.insert(video.creator.nickname, 0).font([UIFont boldSystemFontOfSize:14]).textColor([UIColor blackColor]);
    })];
    objc_setAssociatedObject(video, kNickName, textLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // create time
    textLayout = [YYTextLayout layoutWithContainer:container text:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.insert(sj_processTime(video.createTime, video.serverTime), 0).font([UIFont boldSystemFontOfSize:12]).textColor([UIColor blackColor]);
    })];
    objc_setAssociatedObject(video, kCreateTime, textLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // title
    container = [YYTextContainer containerWithSize:CGSizeMake(SJScreen_W() - 12 * 2, CGFLOAT_MAX)];
    textLayout = [YYTextLayout sj_layoutWithContainer:container text:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        NSString *regxp = @"(?:#[^#]+#)|(?:@[^\\s]+\\s)|(?:http[^\\s]+\\s)";
        
        make.insert(video.title, 0).font([UIFont boldSystemFontOfSize:14]).textColor([UIColor blackColor]);
        make.regexp(regxp, ^(SJAttributesRangeOperator * _Nonnull matched) {
            matched.textColor([UIColor purpleColor]);
        });

        // last set tapped delegate
        make.workInProcess.tappedDelegate = tappedDelegate;
        make.workInProcess.addTapAction(regxp);
        make.workInProcess.object = video;
    })];
    objc_setAssociatedObject(video, kVideoTitle, textLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (CGFloat)heightWithVideo:(SJVideoModel *)video {
    YYTextLayout *titleLayout = objc_getAssociatedObject(video, kVideoTitle);
    return 14 + 44 + 8 + titleLayout.textBoundingSize.height + 8 + (SJScreen_W() * 9 / 16.0f) + 8;
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
    _nameLabel.textLayout = objc_getAssociatedObject(model, kNickName);
    _createTimeLabel.textLayout = objc_getAssociatedObject(model, kCreateTime);
    _contentLabel.textLayout = objc_getAssociatedObject(model, kVideoTitle);
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
        make.leading.equalTo(self->_avatarImageView.mas_trailing).offset(8);
        make.bottom.equalTo(self->_avatarImageView.mas_centerY);
    }];
    
    [_createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self->_nameLabel);
        make.bottom.equalTo(self->_avatarImageView);
    }];
    
    [_attentionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-12);
        make.centerY.equalTo(self->_avatarImageView);
        make.width.offset(60);
    }];
    
    [SJUIFactory boundaryProtectedWithView:_attentionBtn];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_avatarImageView.mas_bottom).offset(8);
        make.leading.equalTo(self->_avatarImageView);
        make.trailing.equalTo(self->_attentionBtn);
        make.bottom.equalTo(self->_coverImageView.mas_top).offset(-8);
    }];
    
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_coverImageView.mas_width).multipliedBy(9.0f / 16);
        make.bottom.offset(-8);
    }];
    
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self->_coverImageView);
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
    _contentLabel.userInteractionEnabled = YES;
    _contentLabel.displaysAsynchronously = YES;
    _contentLabel.ignoreCommonProperties = YES;
    return _contentLabel;
}
- (YYLabel *)nameLabel {
    if ( _nameLabel ) return _nameLabel;
    _nameLabel = [YYLabel new];
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

#pragma mark -
static NSString *sj_processTime(NSTimeInterval createDate, NSTimeInterval nowDate) {
    
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
@end
