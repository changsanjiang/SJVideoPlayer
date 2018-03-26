//
//  SJVideoPlayerRightControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerRightControlView.h"
#import "UIView+SJVideoPlayerSetting.h"
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-retain-self"
@interface SJVideoPlayerRightControlView ()

@property (nonatomic, strong, readonly) UIButton *editingBtn;

@end

@implementation SJVideoPlayerRightControlView

@synthesize editingBtn = _editingBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _rightSetupView];
    [self _rightSettingHelper];
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(49, 49);
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(rightControlView:clickedBtnTag:)] ) return;
    [_delegate rightControlView:self clickedBtnTag:btn.tag];
}

- (void)_rightSetupView {
    [self addSubview:self.editingBtn];
    
    [_editingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_editingBtn.superview);
    }];
}

- (UIButton *)editingBtn {
    if ( _editingBtn ) return _editingBtn;
    _editingBtn = [SJUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayerRightViewTag_FilmEditing];
    return _editingBtn;
}
 
#pragma mark -
- (void)_rightSettingHelper {
    __weak typeof(self) _self = self;
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.editingBtn setImage:setting.filmEditingBtnImage forState:UIControlStateNormal];
    }];
}
@end

#pragma clang diagnostic pop
