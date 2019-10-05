//
//  SJListViewAutoplayMediaInfoView.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/8/16.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJListViewAutoplayMediaInfoView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <SJUIKit/SJCornerMask.h>

NS_ASSUME_NONNULL_BEGIN
@interface __SJTestButton : UIButton

@end

@implementation __SJTestButton

- (CGSize)intrinsicContentSize {
    return CGSizeMake(49, 49);
}

@end

@interface SJListViewAutoplayMediaInfoView ()
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *desLabel;
@property (nonatomic, strong, readonly) UIStackView *stackView;
@property (nonatomic, strong, readonly) UIImageView *pausedImageView;
@end

@implementation SJListViewAutoplayMediaInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)reloadData {
    _nameLabel.attributedText = _dataSource.name;
    _desLabel.attributedText = _dataSource.des;
    _pausedImageView.hidden = !_dataSource.showPausedImageView;
}

#pragma mark -

- (void)_setupView {
    [self addSubview:self.nameLabel];
    [self addSubview:self.desLabel];
    [self addSubview:self.stackView];
    [self addSubview:self.pausedImageView];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.desLabel);
        make.bottom.equalTo(self.desLabel.mas_top).offset(-12);
    }];
    
    [_desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(12);
        make.bottom.equalTo(self.stackView);
        make.right.equalTo(self.stackView.mas_left).offset(-12);
    }];
    
    [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(49);
        make.bottom.offset(-34);
        make.right.offset(-12);
    }];
    
    [_pausedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    UIButton *(^makeButton)(void) = ^UIButton *{
        UIButton *btn = [__SJTestButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = UIColor.whiteColor;
        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:@"https://xy2.res.netease.com/pc/zt/20160104090145/data/18.png"] forState:UIControlStateNormal];
        SJCornerMaskSetRound(btn, 3, UIColor.brownColor);
        return btn;
    };
    [_stackView addArrangedSubview:makeButton()];
    [_stackView addArrangedSubview:makeButton()];
    [_stackView addArrangedSubview:makeButton()];
}

@synthesize nameLabel = _nameLabel;
- (UILabel *)nameLabel {
    if ( _nameLabel == nil ) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _nameLabel;
}

@synthesize desLabel = _desLabel;
- (UILabel *)desLabel {
    if ( _desLabel == nil ) {
        _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _desLabel.numberOfLines = 0;
    }
    return _desLabel;
}

@synthesize stackView = _stackView;
- (UIStackView *)stackView {
    if ( _stackView == nil ) {
        _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.distribution = UIStackViewDistributionEqualSpacing;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.spacing = 12;
    }
    return _stackView;
}

@synthesize pausedImageView = _pausedImageView;
- (UIImageView *)pausedImageView {
    if ( _pausedImageView == nil ) {
        _pausedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"db_play_big"]];
    }
    return _pausedImageView;
}
@end
NS_ASSUME_NONNULL_END
