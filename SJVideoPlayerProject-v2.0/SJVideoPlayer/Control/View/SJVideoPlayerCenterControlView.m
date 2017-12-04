//
//  SJVideoPlayerCenterControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerCenterControlView.h"
#import <SJUIFactory/SJUIFactoryHeader.h>
#import "SJVideoPlayerResources.h"
#import <Masonry/Masonry.h>
#import <SJAttributesFactory/SJAttributesFactoryHeader.h>

@interface SJVideoPlayerCenterControlView ()

@end

@implementation SJVideoPlayerCenterControlView
@synthesize failedBtn = _failedBtn;
@synthesize replayBtn = _replayBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _centerSetupView];
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(centerControlView:clickedBtnTag:)] ) return;
    [_delegate centerControlView:self clickedBtnTag:btn.tag];
}

- (void)_centerSetupView {
    [self.containerView addSubview:self.failedBtn];
    [self.containerView addSubview:self.replayBtn];
    [_failedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (UIButton *)failedBtn {
    if ( _failedBtn ) return _failedBtn;
    _failedBtn = [SJUIFactory buttonWithTitle:@"加载失败,点击重试" titleColor:[UIColor whiteColor] height:16 backgroundColor:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_LoadFailed];
    return _failedBtn;
}
- (UIButton *)replayBtn {
    if ( _replayBtn ) return _replayBtn;
    _replayBtn = [SJUIFactory buttonWithAttributeTitle:[SJAttributesFactory producingWithTask:^(SJAttributeWorker * _Nonnull worker) {
        UIImage *image = [SJVideoPlayerResources imageNamed:@"sj_video_player_replay"];
        worker
        .insert(image, 0, CGPointZero, CGSizeMake(35, 32))
        .insert(@"\n重播", -1);;
        
        worker
        .font([UIFont systemFontOfSize:16])
        .fontColor([UIColor whiteColor])
        .alignment(NSTextAlignmentCenter)
        .lineSpacing(6);
    }] backgroundColor:nil target:self sel:@selector(clickedBtn:) tag:SJVideoPlayControlViewTag_Replay];
    _replayBtn.titleLabel.numberOfLines = 0;
    return _replayBtn;
}
@end
