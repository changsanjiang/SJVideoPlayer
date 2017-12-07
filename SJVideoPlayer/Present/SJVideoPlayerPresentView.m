//
//  SJVideoPlayerPresentView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPresentView.h"
#import <AVFoundation/AVPlayerLayer.h>
#import "SJVideoPlayerAssetCarrier.h"

@interface SJVideoPlayerPresentView ()
@end

@implementation SJVideoPlayerPresentView

@synthesize placeholderImageView = _placeholderImageView;

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    _videoGravity = AVLayerVideoGravityResizeAspect;
    [self _presentSetupView];
    [self _addObserver];
    return self;
}

- (AVPlayerLayer *)avLayer {
    return (AVPlayerLayer *)self.layer;
}

#pragma mark - Observer

- (void)_addObserver {
    [self.avLayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.avLayer removeObserver:self forKeyPath:@"readyForDisplay"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"readyForDisplay"] ) {
        if ( self.readyForDisplay ) self.readyForDisplay(self);
    }
}

#pragma mark - Setter

- (void)setAsset:(SJVideoPlayerAssetCarrier *)asset {
    _asset = asset;
    self.avLayer.player = asset.player;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;
    self.avLayer.videoGravity = videoGravity;
}

#pragma mark - Views
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
