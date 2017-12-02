//
//  SJVideoPlayerTopControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerTopControlView.h"
#import "SJVideoPlayerControlViewEnumHeader.h"
#import <SJUIFactory/SJUIFactory.h>
#import "SJVideoPlayerResources.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayerControlMaskView.h"

@interface SJVideoPlayerTopControlView ()

@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *controlMaskView;
@property (nonatomic, strong, readonly) UIButton *backBtn;
@property (nonatomic, strong, readonly) UIButton *previewBtn;
@property (nonatomic, strong, readonly) UIButton *moreBtn;

@end

@implementation SJVideoPlayerTopControlView
@synthesize controlMaskView = _controlMaskView;

@synthesize backBtn = _backBtn;
@synthesize previewBtn = _previewBtn;
@synthesize moreBtn = _moreBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _topSetupViews];
    return self;
}

- (void)clickedBtn:(UIButton *)bt {
    
}

- (void)_topSetupViews {
    [self.containerView addSubview:self.controlMaskView];
    [self.containerView addSubview:self.backBtn];
    [self.containerView addSubview:self.previewBtn];
    [self.containerView addSubview:self.moreBtn];
    
    [_controlMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.offset(0);
        make.height.equalTo(_backBtn.mas_width);
    }];
    
    [_previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.bottom.equalTo(_backBtn);
        make.trailing.equalTo(_moreBtn.mas_leading);
    }];
    
    [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.bottom.equalTo(_backBtn);
        make.trailing.offset(0);
    }];
}

- (UIButton *)backBtn {
    if ( _backBtn ) return _backBtn;
    _backBtn = [SJUIFactory buttonWithImageName:[SJVideoPlayerResources bundleComponentWithImageName:@"sj_video_player_back"] target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Back];
    return _backBtn;
}

- (UIButton *)previewBtn {
    if ( _previewBtn ) return _previewBtn;
    _previewBtn = [SJUIFactory buttonWithTitle:@"预览" titleColor:[UIColor whiteColor] height:16 backgroundColor:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Preview];
    return _previewBtn;
}

- (UIButton *)moreBtn {
    if ( _moreBtn ) return _moreBtn;
    _moreBtn = [SJUIFactory buttonWithImageName:[SJVideoPlayerResources bundleComponentWithImageName:@"sj_video_player_more"] target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_More];
    return _moreBtn;
}


- (SJVideoPlayerControlMaskView *)controlMaskView {
    if ( _controlMaskView ) return _controlMaskView;
    _controlMaskView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    return _controlMaskView;
}

@end
