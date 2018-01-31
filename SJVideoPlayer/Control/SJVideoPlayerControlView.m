//
//  SJVideoPlayerControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControlView.h"
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>
#import <Masonry/Masonry.h>
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#import <SJOrentationObserver/SJOrentationObserver.h>

@interface SJVideoPlayerControlView()<SJVideoPlayerTopControlViewDelegate, SJVideoPlayerLeftControlViewDelegate, SJVideoPlayerCenterControlViewDelegate, SJVideoPlayerBottomControlViewDelegate, SJVideoPlayerPreviewViewDelegate>
@property (nonatomic, weak, readonly) SJOrentationObserver *orentationObserver;
@end

@implementation SJVideoPlayerControlView
@synthesize bottomProgressSlider = _bottomProgressSlider;
@synthesize previewView = _previewView;
@synthesize topControlView = _topControlView;
@synthesize leftControlView = _leftControlView;
@synthesize centerControlView = _centerControlView;
@synthesize bottomControlView = _bottomControlView;
@synthesize orentationObserver = _orentationObserver;

- (instancetype)initWithOrentationObserver:(__weak SJOrentationObserver *)orentationObserver {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    _orentationObserver = orentationObserver;
    [self _controlSetupView];
    _topControlView.delegate = self;
    _leftControlView.delegate = self;
    _centerControlView.delegate = self;
    _bottomControlView.delegate = self;
    _previewView.delegate = self;
    __weak typeof(self) _self = self;
    self.setting = ^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.bottomProgressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomProgressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
    };
    [self _controlAddObserve];
    return self;
}

#pragma mark

- (void)_controlAddObserve {
    [self.orentationObserver sj_addObserver:self forKeyPath:@"fullScreen"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"fullScreen"] ) {
        NSLog(@"%f", self.topViewHeight);
        [self.topControlView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(self.topViewHeight);
        }];
        [self.bottomControlView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(self.bottomViewHeight);
        }];
    }
}
#pragma mark

- (void)_controlSetupView {

    [self.containerView addSubview:self.topControlView];
    [self.containerView addSubview:self.leftControlView];
    [self.containerView addSubview:self.centerControlView];
    [self.containerView addSubview:self.bottomControlView];
    [self.containerView addSubview:self.previewView];
    [self.containerView addSubview:self.bottomProgressSlider];
    
    [_topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.offset(self.topViewHeight);
    }];
    
    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topControlView.previewBtn.mas_bottom).offset(12);
        make.leading.trailing.offset(0);
        make.height.offset([UIScreen mainScreen].bounds.size.width * 0.25);
    }];
    
    [_leftControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.offset(self.leftViewWidth);
        make.leading.offset(0);
        make.centerY.offset(0);
    }];
    
    [_centerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.equalTo(_centerControlView.superview).multipliedBy(0.382);
        make.height.equalTo(_centerControlView.mas_width);
    }];
    
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.offset(0);
        make.height.offset(self.bottomViewHeight);
    }];
    
    [_bottomProgressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(1);
    }];
    
}

- (SJVideoPlayerTopControlView *)topControlView {
    if ( _topControlView ) return _topControlView;
    _topControlView = [SJVideoPlayerTopControlView new];
    return _topControlView;
}

- (SJVideoPlayerLeftControlView *)leftControlView {
    if ( _leftControlView ) return _leftControlView;
    _leftControlView = [SJVideoPlayerLeftControlView new];
    return _leftControlView;
}

- (SJVideoPlayerCenterControlView *)centerControlView {
    if ( _centerControlView ) return _centerControlView;
    _centerControlView = [SJVideoPlayerCenterControlView new];
    return _centerControlView;
}

- (SJVideoPlayerBottomControlView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [SJVideoPlayerBottomControlView new];
    return _bottomControlView;
}

#pragma mark
- (void)topControlView:(SJVideoPlayerTopControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)leftControlView:(SJVideoPlayerLeftControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)centerControlView:(SJVideoPlayerCenterControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)bottomControlView:(SJVideoPlayerBottomControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)previewView:(SJVideoPlayerPreviewView *)view didSelectItem:(SJVideoPreviewModel *)item {
    if ( ![_delegate respondsToSelector:@selector(controlView:didSelectPreviewItem:)] ) return;
    [_delegate controlView:self didSelectPreviewItem:item];
}

- (SJVideoPlayerPreviewView *)previewView {
    if ( _previewView ) return _previewView;
    _previewView = [SJVideoPlayerPreviewView new];
    _previewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    return _previewView;
}
- (SJSlider *)bottomProgressSlider {
    if ( _bottomProgressSlider ) return _bottomProgressSlider;
    _bottomProgressSlider = [SJSlider new];
    _bottomProgressSlider.trackHeight = 1;
    _bottomProgressSlider.pan.enabled = NO;
    return _bottomProgressSlider;
}

#pragma mark -
- (CGFloat)topViewHeight {
    return !self.orentationObserver.isFullScreen ? 49 : 72;
}
- (CGFloat)leftViewWidth {
    return 49;
}
- (CGFloat)bottomViewHeight {
    return !self.orentationObserver.isFullScreen ? 49 : 60;
}
@end
