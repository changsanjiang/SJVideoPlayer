//
//  TestAVCompositionViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/8/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TestAVCompositionViewController.h"
#import "SJVideoPlayer.h"
#import <UIView+SJUIFactory.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN
@interface TestAVCompositionViewController ()
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation TestAVCompositionViewController
@synthesize indicator = _indicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    // Do any additional setup after loading the view.
}

- (IBAction)play:(id)sender {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    
    [self.indicator startAnimating];
    __weak typeof(self) _self = self;
    [asset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
        });
        
        NSError *error;
        CMTimeRange cutRange = CMTimeRangeMake(CMTimeMakeWithSeconds(0, NSEC_PER_SEC), asset.duration);
        AVMutableComposition *compositionM = [AVMutableComposition composition];
        AVAssetTrack *assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        AVAssetTrack *assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;

        AVMutableCompositionTrack *audioTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrackM insertTimeRange:cutRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
        if ( error ) NSLog(@"Export Failed: error = %@", error);
        
        AVMutableCompositionTrack *videoTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrackM insertTimeRange:cutRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
        if ( error ) NSLog(@"Export Failed: error = %@", error);
        
        
        // play
        self.player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAVAsset:compositionM];
    }];
}

- (void)_setupViews {
    _player = [SJVideoPlayer player];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            make.top.offset(20);
        }
        make.leading.trailing.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9/16.0);
    }];
    
    _player.autoPlay = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (UIActivityIndicatorView *)indicator {
    if ( _indicator ) return _indicator;
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicator.csj_size = CGSizeMake(80, 80);
    _indicator.center = self.view.center;
    _indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
    _indicator.clipsToBounds = YES;
    _indicator.layer.cornerRadius = 6;
    [self.view addSubview:_indicator];
    return _indicator;
}

@end
NS_ASSUME_NONNULL_END
