//
//  SJDYTableViewCell.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/12.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJDYTableViewCell.h"
#import <Masonry/Masonry.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>

@interface SJDYDemoPlayer : SJBaseVideoPlayer<SJDYDemoPlayer>

@end

#pragma mark -

@interface SJDYTableViewCell () {
    SJDYDemoPlayer *_player;
}
@property (nonatomic, strong) UIImageView *playImageView;
@end

@implementation SJDYTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self ) {
        [self _setupViews];
    }
    return self;
}
  
#pragma mark - mark

- (void)_setupViews {
    self.backgroundColor = UIColor.blackColor;
    
    _player = SJDYDemoPlayer.player;
    [self _setupPlayer];
    [self.contentView addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    if (@available(iOS 13.0, *)) {
        _playImageView = [UIImageView.alloc initWithImage:[[UIImage imageNamed:@"play"] imageWithTintColor:[UIColor colorWithRed:0.92 green:0.05 blue:0.5 alpha:1]]];
    } else {
        _playImageView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"play"]];
    }
    _playImageView.hidden = YES;
    [self.contentView addSubview:_playImageView];
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (void)_setupPlayer {
    // 播放完毕后, 重新播放. 也就是循环播放
    _player.playbackObserver.playbackDidFinishExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        [player replay];
    };
    __weak typeof(_player) _weakPlayer = _player;
    // 设置仅支持单击手势
    _player.gestureController.supportedGestureTypes = SJPlayerGestureTypeMask_SingleTap;
    // 重定义单击手势的处理
    _player.gestureController.singleTapHandler = ^(id<SJGestureController>  _Nonnull control, CGPoint location) {
        // 此处改为单击暂停或播放
        _weakPlayer.isPaused ? [_weakPlayer play] : [_weakPlayer pauseForUser];
    };
    // 播放状态改变后刷新播放按钮显示状态
    __weak typeof(self) _self = self;
    _player.playbackObserver.playbackStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // 当前资源被播放过
        if ( player.isPlayed ) {
            // 只要被播放过的并且是用户暂停时, 才显示播放按钮
            BOOL isPaused = player.isUserPaused;
            self.playImageView.hidden = !isPaused;
        }
        // 未播放过的, 不显示播放按钮
        else {
            self.playImageView.hidden = YES;
        }
    };
}
@end


@implementation SJDYDemoPlayer
@dynamic isUserPaused, isPaused;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        self.view.backgroundColor = UIColor.clearColor;
        self.presentView.backgroundColor = UIColor.clearColor;
        self.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.autoplayWhenSetNewAsset = NO;
        self.rotationManager.disabledAutorotation = YES;
        self.pausedInBackground = YES;
        self.resumePlaybackWhenScrollAppeared = NO;
        self.resumePlaybackWhenAppDidEnterForeground = NO;
    }
    return self;
}

- (void)setAllowsPlayback:(BOOL (^_Nullable)(id<SJDYDemoPlayer> _Nonnull))allowsPlayback {
    self.canPlayAnAsset = allowsPlayback;
}

- (BOOL (^_Nullable)(id<SJDYDemoPlayer> _Nonnull))allowsPlayback {
    return (id)self.canPlayAnAsset;
}

- (void)configureWithURL:(NSURL *)URL {
    [self stop];
    SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:URL];
    self.URLAsset = asset;
}

@end
