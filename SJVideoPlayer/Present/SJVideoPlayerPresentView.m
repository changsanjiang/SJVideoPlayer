//
//  SJVideoPlayerPresentView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPresentView.h"
#import <AVFoundation/AVPlayerLayer.h>
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>

@interface SJVideoPlayerPresentView ()

@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;

@end

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
    [self _addObserver];
    return self;
}

#pragma mark -

- (void)_addObserver {
    [self.avLayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.avLayer removeObserver:self forKeyPath:@"readyForDisplay"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"readyForDisplay"] ) {
        if ( self.readyForDisplay ) self.readyForDisplay(self, self.avLayer.videoRect);
    }
}

#pragma mark -

- (void)setAsset:(SJVideoPlayerAssetCarrier *)asset {
    if ( asset == _asset ) return;
    _asset = asset;
    self.avLayer.player = asset.player;
}

- (void)setPlaceholder:(UIImage *)placeholder {
    if ( placeholder == _placeholder ) return;
    _placeholder = placeholder;
    _placeholderImageView.image = placeholder;
}

- (void)setState:(SJVideoPlayerPlayState)state {
    _state = state;
    [UIView animateWithDuration:0.25 animations:^{
        switch ( state ) {
            case SJVideoPlayerPlayState_Unknown:
            case SJVideoPlayerPlayState_Prepare: {
                _placeholderImageView.alpha = 1;
            }
                break;
            case SJVideoPlayerPlayState_Playing: {
                _placeholderImageView.alpha = 0.001;
            }
                break;
            case SJVideoPlayerPlayState_Buffing:
            case SJVideoPlayerPlayState_Pause:
            case SJVideoPlayerPlayState_PlayEnd:
            case SJVideoPlayerPlayState_PlayFailed: break;
        }
    }];
}

#pragma mark -

- (void)_presentSetupView {
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.placeholderImageView];
    _placeholderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_placeholderImageView]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(_placeholderImageView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_placeholderImageView]|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(_placeholderImageView)]];
}

- (UIImageView *)placeholderImageView {
    if ( _placeholderImageView ) return _placeholderImageView;
    _placeholderImageView = [UIImageView new];
    _placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    _placeholderImageView.clipsToBounds = YES;
    return _placeholderImageView;
}

@end
