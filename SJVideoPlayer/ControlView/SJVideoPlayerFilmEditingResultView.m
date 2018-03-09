//
//  SJVideoPlayerFilmEditingResultView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerFilmEditingResultView.h"
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import <SJUIFactory/UIView+SJUIFactory.h>
#import "UIView+SJVideoPlayerSetting.h"
#import "UIView+SJControlAdd.h"
#import <SJAttributesFactory/SJAttributeWorker.h>
#import "SJFilmEditingResultShareItem.h"

@interface SJVideoPlayerFilmEditingResultView ()

@property (nonatomic, strong, readonly) UIButton *cancelBtn;
@property (nonatomic, strong, readonly) UIView *fullMaskView;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIView *itemsContainerView;

@end

@implementation SJVideoPlayerFilmEditingResultView

@synthesize cancelBtn = _cancelBtn;
@synthesize imageView = _imageView;
@synthesize fullMaskView = _fullMaskView;
@synthesize itemsContainerView = _itemsContainerView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    self.contentMode = UIViewContentModeScaleAspectFit;
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.layer.contents = (id)image.CGImage;
    self.imageView.image = image;
}

- (void)setCancelBtnTitle:(NSString *)cancelBtnTitle {
    _cancelBtnTitle = cancelBtnTitle;
    [_cancelBtn setTitle:cancelBtnTitle forState:UIControlStateNormal];
}

- (void)startAnimation {
    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.equalTo(self.mas_centerY).multipliedBy(0.82);
        make.width.equalTo(self).multipliedBy(0.4);
        make.height.equalTo(_imageView.mas_width).multipliedBy(9 / 16.0);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
        self.itemsContainerView.alpha = 1;
    }];
}

- (void)setFilmEditingResultShareItems:(NSArray<SJFilmEditingResultShareItem *> *)items {
    _filmEditingResultShareItems = items;
    [_filmEditingResultShareItems enumerateObjectsUsingBlock:^(SJFilmEditingResultShareItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [SJUIButtonFactory buttonWithAttributeTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            make.insertImage(obj.image, 0, CGPointZero, CGSizeMake(40, 40));
            make.insertText(@"\n", -1);
            make.insertText(obj.title, -1);
            make.lineSpacing(8);
            make.alignment(NSTextAlignmentCenter);
            make.font([UIFont systemFontOfSize:10]).textColor([UIColor whiteColor]);
        }) backgroundColor:[UIColor clearColor] target:self sel:@selector(clickedItemBtn:) tag:idx];
        [self.itemsContainerView addSubview:btn];
        if ( idx == 0 ) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_itemsContainerView);
                make.top.bottom.offset(0);
            }];
        }
        else if ( idx != (int)items.count - 1 ) {
            UIButton *beforeBtn = self.itemsContainerView.subviews[(int)idx - 1];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(beforeBtn.mas_trailing).offset(20);
                make.top.bottom.equalTo(beforeBtn);
            }];
        }
        else {
            UIButton *beforeBtn = self.itemsContainerView.subviews[(int)idx - 1];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(beforeBtn.mas_trailing).offset(20);
                make.top.bottom.equalTo(beforeBtn);
                make.trailing.offset(0);
            }];
        }
    }];
}

- (void)clickedBtn:(UIButton *)btn {
    if ( btn == self.cancelBtn ) {
        if ( _clickedCancleBtn ) _clickedCancleBtn(self);
    }
}

- (void)clickedItemBtn:(UIButton *)btn {
    SJFilmEditingResultShareItem *item = self.filmEditingResultShareItems[btn.tag];
    if ( item.clickedExeBlock ) {
        item.clickedExeBlock(item, self.image, nil);
    }
    
    if ( item.clickToDisappear ) {
        if ( self.clickedCancleBtn ) self.clickedCancleBtn(self);
    }
}

#pragma mark -

- (void)_setupViews {
    [self addSubview:self.fullMaskView];
    [self addSubview:self.cancelBtn];
    [self addSubview:self.imageView];
    [self addSubview:self.itemsContainerView];
    
    [_fullMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(12);
        make.top.offset(12);
        make.height.offset(26);
        make.width.equalTo(_cancelBtn.mas_height).multipliedBy(2.8);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(_imageView.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    self.itemsContainerView.alpha = 0.001;
}

- (UIView *)fullMaskView {
    if  ( _fullMaskView ) return _fullMaskView;
    _fullMaskView = [SJUIViewFactory viewWithBackgroundColor:[UIColor colorWithWhite:0 alpha:0.618]];
    return _fullMaskView;
}

- (UIView *)itemsContainerView {
    if ( _itemsContainerView ) return _itemsContainerView;
    _itemsContainerView = [SJUIViewFactory viewWithBackgroundColor:[UIColor clearColor]];
    return _itemsContainerView;
}

- (UIButton *)cancelBtn {
    if ( _cancelBtn ) return _cancelBtn;
    _cancelBtn = [SJShapeButtonFactory buttonWithCornerRadius:15 title:nil titleColor:[UIColor whiteColor] target:self sel:@selector(clickedBtn:)];
    _cancelBtn.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    return _cancelBtn;
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [SJUIImageViewFactory imageViewWithViewMode:UIViewContentModeScaleAspectFit];
    return _imageView;
}
@end
