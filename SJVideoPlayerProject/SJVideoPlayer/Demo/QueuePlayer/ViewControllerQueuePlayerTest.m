//
//  ViewControllerQueuePlayerTest.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/5/31.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "ViewControllerQueuePlayerTest.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>
#import <AVFoundation/AVFoundation.h>
#import <SJBaseVideoPlayer/SJAVMediaPlayer.h>
#import <SJUIKit/NSObject+SJObserverHelper.h>

@interface ViewControllerQueuePlayerTest ()<SJRouteHandler>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) AVQueuePlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) AVPlayer *player2;
@property (nonatomic, strong) AVURLAsset *source;
@property (nonatomic, strong) AVMutableComposition *mutableAsset;
@end

@implementation ViewControllerQueuePlayerTest
+ (NSString *)routePath {
    return @"queuePlayer/test";
}

+ (void)handleRequestWithParameters:(nullable SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(nullable SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if ( self ) { }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)initPlayer:(id)sender {
    NSURL *URL = [NSURL URLWithString:@"https://xy2.v.netease.com/r/video/20190308/31cbdd25-3cc9-49d4-934c-8d29b54fc15b.mp4"];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:URL options:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
    sjkvo_observe(item, @"status", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    });
    
    _player = [[AVQueuePlayer alloc] initWithPlayerItem:item];
    [_player play];
    
    _playerLayer = [AVPlayerLayer layer];
    _playerLayer.player = _player;
    _playerLayer.frame = _containerView.layer.bounds;
    [_containerView.layer addSublayer:_playerLayer];
}

- (IBAction)insertItem:(id)sender {
    NSURL *URL = [NSURL URLWithString:@"https://xy2.v.netease.com/2018/0815/2b4c5207f8977c183897728dc6c77d58qt.mp4"];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:URL options:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];

    
    // 只有播放时, 才会去加载
    sjkvo_observe(item, @"status", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    });
    
    if ( [_player canInsertItem:item afterItem:_player.currentItem] ) {
        [_player insertItem:item afterItem:_player.currentItem];
    }
    
}
- (IBAction)advanceToNextItem:(id)sender {
    AVPlayerItem *item = _player.currentItem;
    [_player advanceToNextItem];
    [_player removeItem:item];
}


- (IBAction)f:(id)sender {
    NSURL *URL = [NSURL URLWithString:@"https://xy2.v.netease.com/r/video/20190308/31cbdd25-3cc9-49d4-934c-8d29b54fc15b.mp4"];
    self.source = [[AVURLAsset alloc] initWithURL:URL options:nil];
    NSString *k_tracks = @"tracks";
    [self.source loadValuesAsynchronouslyForKeys:@[k_tracks] completionHandler:^{
        
        AVKeyValueStatus status = [self.source statusOfValueForKey:k_tracks error:nil];
        if ( status == AVKeyValueStatusLoaded ) {
            self.mutableAsset = [AVMutableComposition composition];
            AVMutableCompositionTrack *mutableVideoTrack = [self.mutableAsset addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:1];
            AVMutableCompositionTrack *mutableAudioTrack = [self.mutableAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:2];
            CMTime start = kCMTimeZero;
            CMTime duration = CMTimeMakeWithSeconds(10, NSEC_PER_SEC);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            [mutableVideoTrack insertTimeRange:range ofTrack:[self.source tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:NULL];
            [mutableAudioTrack insertTimeRange:range ofTrack:[self.source tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:NULL];
            
            NSLog(@"1. 完成");
        }
    }];
}

- (IBAction)p:(id)sender {
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:self.mutableAsset];
    
    _player2 = [[AVPlayer alloc] initWithPlayerItem:item];
    [_player2 play];
    
    _playerLayer = [AVPlayerLayer layer];
    _playerLayer.player = _player2;
    _playerLayer.frame = _containerView.layer.bounds;
    [_containerView.layer addSublayer:_playerLayer];
}

- (IBAction)add:(id)sender {
    AVMutableCompositionTrack *mutableVideoTrack = [self.mutableAsset trackWithTrackID:1];
    AVMutableCompositionTrack *mutableAudioTrack = [self.mutableAsset trackWithTrackID:2];
    CMTime end = self.mutableAsset.duration;
    CMTime start = end;
    CMTime duration = CMTimeMakeWithSeconds(10, NSEC_PER_SEC);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    [mutableVideoTrack insertTimeRange:range ofTrack:[self.source tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:end error:NULL];
    [mutableAudioTrack insertTimeRange:range ofTrack:[self.source tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:end error:NULL];
    NSLog(@"2. end");
}
- (IBAction)p2:(id)sender {
    [_player2 playImmediatelyAtRate:1.0];
}

@end

