//
//  VideoPlayerCollectionViewCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/28.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "VideoPlayerCollectionViewCell.h"

#import "UIView+SJExtension.h"

#import <Masonry/Masonry.h>

#import <SJBorderLineView/SJBorderlineView.h>

@interface VideoPlayerCollectionViewCell ()

@property (nonatomic, strong, readonly) SJBorderlineView *backgroundView;

@property (nonatomic, strong, readonly) UIButton *playVideoBtn;

@end

@implementation VideoPlayerCollectionViewCell

@synthesize backgroundView = _backgroundView;
@synthesize videoImageView = _videoImageView;
@synthesize playVideoBtn = _playVideoBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _VideoPlayerCollectionViewCellSetupUI];
    return self;
}

// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    if ( ![self.delegate respondsToSelector:@selector(clickedPlayBtnOnTheCell:onViewTag:)] ) return;
    [self.delegate clickedPlayBtnOnTheCell:self onViewTag:self.videoImageView.tag];
}

// MARK: UI

- (void)_VideoPlayerCollectionViewCellSetupUI {
    
    [self.contentView addSubview:self.backgroundView];
    [_backgroundView addSubview:self.videoImageView];
    [_videoImageView addSubview:self.playVideoBtn];
    
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.bottom.offset(-6);
    }];
    
    [_playVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (UIButton *)playVideoBtn {
    if ( _playVideoBtn ) return _playVideoBtn;
    _playVideoBtn = [UIButton buttonWithImageName:@"db_play_big" tag:0 target:self sel:@selector(clickedBtn:)];
    return _playVideoBtn;
}

- (UIImageView *)videoImageView {
    if ( _videoImageView ) return _videoImageView;
    _videoImageView = [UIImageView imageViewWithImageStr:[NSString stringWithFormat:@"%zd", arc4random() % 3] viewMode:UIViewContentModeScaleAspectFit];
    _videoImageView.userInteractionEnabled = YES;
    _videoImageView.tag = 101;
    return _videoImageView;
}

- (UIView *)backgroundView {
    if ( _backgroundView ) return _backgroundView;
    _backgroundView = [SJBorderlineView borderlineViewWithSide:SJBorderlineSideAll startMargin:0 endMargin:0 lineColor:[UIColor lightGrayColor] lineWidth:1 backgroundColor:[UIColor clearColor]];
    return _backgroundView;
}
@end

