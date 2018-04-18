//
//  SJVideoPlayerPresentView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPresentView.h"
#import <AVFoundation/AVPlayerLayer.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerPresentView ()

@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;

@end

NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerPresentView

@synthesize placeholderImageView = _placeholderImageView;

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)avLayer {
    return (AVPlayerLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _presentSetupView];
    return self;
}

#pragma mark -

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

#pragma mark -

- (void)setPlayer:(AVPlayer *)player {
    if ( player == _player ) return;
    self.avLayer.player = player;
}

- (void)setPlaceholder:(UIImage *)placeholder {
    if ( placeholder == _placeholder ) return;
    _placeholder = placeholder;
    _placeholderImageView.image = placeholder;
}

- (void)setPlayState:(SJVideoPlayerPlayState)playState {
    _playState = playState;
    [UIView animateWithDuration:0.5 animations:^{
        switch ( playState ) {
            case SJVideoPlayerPlayState_Unknown:
            case SJVideoPlayerPlayState_Prepare: {
                self->_placeholderImageView.alpha = 1;
            }
                break;
            case SJVideoPlayerPlayState_Playing: {
                self->_placeholderImageView.alpha = 0.001;
            }
                break;
            case SJVideoPlayerPlayState_Buffing:
            case SJVideoPlayerPlayState_Paused:
            case SJVideoPlayerPlayState_PlayEnd:
            case SJVideoPlayerPlayState_PlayFailed: break;
        }
    }];
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    if ( videoGravity == self.videoGravity ) return;
    [self avLayer].videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    return [self avLayer].videoGravity;
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    _placeholderImageView.frame = self.bounds;
}

- (void)_presentSetupView {
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.placeholderImageView];
}

- (UIImageView *)placeholderImageView {
    if ( _placeholderImageView ) return _placeholderImageView;
    _placeholderImageView = [UIImageView new];
    _placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    _placeholderImageView.clipsToBounds = YES;
    return _placeholderImageView;
}

@end
