//
//  SJLightweightTopControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJLightweightTopControlView.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry/Masonry.h>
#import "UIView+SJVideoPlayerSetting.h"
#import <SJAttributesFactory/SJAttributeWorker.h>

@interface SJLightweightTopControlView () {
    SJLightweightTopControlModel *_model;
}

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIView *itemsContainerView;

@end

@implementation SJLightweightTopControlView
@synthesize itemsContainerView = _itemsContainerView;
@synthesize backBtn = _backBtn;
@synthesize titleLabel = _titleLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _topSetupViews];
    [self _topSettingHelper];
    return self;
}

- (CGSize)intrinsicContentSize {
    if ( _isFullscreen ) {
        return CGSizeMake(SJScreen_Max(), 72);
    }
    else {
        return CGSizeMake(SJScreen_Min(), 55);
    }
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    if ( isFullscreen == _isFullscreen ) return;
    _isFullscreen = isFullscreen;
    [self invalidateIntrinsicContentSize];
}

- (void)needUpdateTitle {
    if ( self.isFullscreen ) {
        self.titleLabel.hidden = NO;
    }
    else {
        self.titleLabel.hidden = !self.model.alwaysShowTitle;
    }
    
    if ( !self.titleLabel.hidden ) {
        NSAttributedString *attrStr = nil;
        if ( 0 != self.model.title.length ) {
            attrStr = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
                make.font(self.titleLabel.font).textColor(self.titleLabel.textColor);
                make.insert(self.model.title, 0);
                make.shadow(CGSizeMake(0.5, 0.5), 1, [UIColor blackColor]);
            });
        }
        _titleLabel.attributedText = attrStr;
    }
    
    if ( _isFullscreen || !self.model.isPlayOnScrollView ) {
        _backBtn.hidden = NO;
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_backBtn.mas_trailing);
            make.centerY.equalTo(_backBtn);
            make.trailing.equalTo(_itemsContainerView.mas_leading);
        }];
    }
    else {
        _backBtn.hidden = YES;
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(16);
            make.centerY.equalTo(_backBtn);
            make.trailing.offset(-16);
        }];
    }
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(clickedBackBtnOnTopControlView:)] ) return;
    [_delegate clickedBackBtnOnTopControlView:self];
}

- (void)_topSetupViews {
    
    [self addSubview:self.backBtn];
    [self addSubview:self.titleLabel];
    [self addSubview:self.itemsContainerView];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.offset(49);
        make.leading.bottom.offset(0);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_backBtn.mas_trailing);
        make.centerY.equalTo(_backBtn);
        make.trailing.equalTo(_itemsContainerView.mas_leading);
    }];
    
    [_itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.offset(0);
        make.width.mas_greaterThanOrEqualTo(8);
    }];
    
    [SJUIFactory boundaryProtectedWithView:_backBtn];
}

- (UIButton *)backBtn {
    if ( _backBtn ) return _backBtn;
    _backBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:0];
    return _backBtn;
}

- (UILabel *)titleLabel {
    if ( _titleLabel ) return _titleLabel;
    _titleLabel = [UILabel new];
    return _titleLabel;
}

#pragma mark -
- (void)_topSettingHelper {
    __weak typeof(self) _self = self;
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.backBtn setImage:setting.backBtnImage forState:UIControlStateNormal];
        self.titleLabel.font = setting.titleFont;
        self.titleLabel.textColor = setting.titleColor;
        if ( 0 != self.model.title.length ) self.titleLabel.text = self.model.title;
    }];
}
- (SJLightweightTopControlModel *)model {
    if ( _model ) return _model;
    _model = [SJLightweightTopControlModel new];
    return _model;
}
- (UIView *)itemsContainerView {
    if ( _itemsContainerView ) return _itemsContainerView;
    _itemsContainerView = [UIView new];
    return _itemsContainerView;
}
@end


@implementation SJLightweightTopControlModel
@end
