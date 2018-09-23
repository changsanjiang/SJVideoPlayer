//
//  SJLightweightRightControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJLightweightRightControlView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJUIFactory/SJUIFactory.h>)
#import <SJUIFactory/SJUIFactory.h>
#else
#import "SJUIFactory.h"
#endif


@interface SJLightweightRightControlView ()

@property (nonatomic, strong, readonly) UIButton *editingBtn;

@end

@implementation SJLightweightRightControlView

@synthesize editingBtn = _editingBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _rightSetupView];
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(49, 49);
}

- (void)setFilmEditingBtnImage:(UIImage *)filmEditingBtnImage {
    _filmEditingBtnImage = filmEditingBtnImage;
    [self.editingBtn setImage:filmEditingBtnImage forState:UIControlStateNormal];
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(rightControlView:clickedBtnTag:)] ) return;
    [_delegate rightControlView:self clickedBtnTag:btn.tag];
}

- (void)_rightSetupView {
    [self addSubview:self.editingBtn];
    
    [_editingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_editingBtn.superview);
    }];
}

- (UIButton *)editingBtn {
    if ( _editingBtn ) return _editingBtn;
    _editingBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJLightweightRightControlViewTag_FilmEditing];
    return _editingBtn;
}
@end
