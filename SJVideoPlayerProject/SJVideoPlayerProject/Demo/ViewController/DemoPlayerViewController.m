//
//  DemoPlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "DemoPlayerViewController.h"
#import "SJVideoPlayerHelper.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry.h>
#import "SJVideoModel.h"
#import <AVFoundation/AVFoundation.h>
#import <SJVideoPlayerAssetCarrier.h>

@interface DemoPlayerViewController ()<SJVideoPlayerHelperUseProtocol>

@property (nonatomic, strong, readonly) UIView *playerSuperView;

@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;
@property (nonatomic, strong) SJVideoModel *video;
@property (nonatomic, strong) SJVideoPlayerURLAsset *asset;

@end

@implementation DemoPlayerViewController

@synthesize playerSuperView = _playerSuperView;

- (instancetype)initWithVideo:(SJVideoModel *)video asset:(SJVideoPlayerURLAsset *__nullable)asset {
    self = [super init];
    if ( !self ) return nil;
    _video = video;
    _asset = asset;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _demoVCSetupViews];
    
    if ( !self.asset ) {
        // create new asset
        SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/usertrend/166162-1513873330.mp4"]];
        asset.title = self.video.title;
        asset.alwaysShowTitle = YES;
        self.asset = asset;
    }
    else {
        [self.asset convertToUIView];   // 将资源转化为在UIView上播放.
    }
    
    
    NSLog(@"%@", NSHomeDirectory());
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%zd - %s", __LINE__, __func__);
        [self export];
    });
    
    // Do any additional setup after loading the view.
}

- (void)export {
    AVAsset *asset = [(SJVideoPlayerAssetCarrier *)[self.asset valueForKey:kSJVideoPlayerAssetKey] asset];
    AVMutableComposition *compositionM = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *audioTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //    if ( 1 >= direction ) videoTrackM.preferredTransform = CGAffineTransformMakeRotation(M_PI_2);
    
    CMTimeRange cutRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    AVAssetTrack *assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVAssetTrack *assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;

    NSError *error;
    [audioTrackM insertTimeRange:cutRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    if ( error ) {
        NSLog(@"裁剪出错 error = %@", error);
        return;
    }
    [videoTrackM insertTimeRange:cutRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
    if ( error ) {
        NSLog(@"裁剪出错 error = %@", error);
        return;
    }
    [self exportAssets:compositionM presetName:AVAssetExportPresetHighestQuality completionHandle:nil];
}

- (void)exportAssets:(AVAsset *)asset presetName:(NSString *)presetName completionHandle:(void(^)(AVAsset *sandBoxAsset, UIImage *previewImage))block {
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"_re_.mp4"];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[exportURL.absoluteString substringFromIndex:7]] ) {
        [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    }
    AVAssetExportSession *stoppedExportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:presetName];
    stoppedExportSession.outputURL = exportURL;
    stoppedExportSession.shouldOptimizeForNetworkUse = YES;
    stoppedExportSession.outputFileType = AVFileTypeMPEG4;
    [stoppedExportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%zd - %s - %zd - %@", __LINE__, __func__, stoppedExportSession.status, stoppedExportSession.error);
    }];
}

#pragma mark -
// please lazy load
@synthesize videoPlayerHelper = _videoPlayerHelper;
- (SJVideoPlayerHelper *)videoPlayerHelper {
    if ( _videoPlayerHelper ) return _videoPlayerHelper;
    _videoPlayerHelper = [[SJVideoPlayerHelper alloc] initWithViewController:self];
    return _videoPlayerHelper;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.videoPlayerHelper.vc_viewWillAppearExeBlock();
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.videoPlayerHelper playWithAsset:self.asset playerParentView:self.playerSuperView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.videoPlayerHelper.vc_viewWillDisappearExeBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.videoPlayerHelper.vc_viewDidDisappearExeBlock();
}

- (BOOL)prefersStatusBarHidden {
    return self.videoPlayerHelper.vc_prefersStatusBarHiddenExeBlock();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark -
- (void)_demoVCSetupViews {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerSuperView];
    [_playerSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(9 / 16.0f);
    }];
}

- (UIView *)playerSuperView {
    if ( _playerSuperView ) return _playerSuperView;
    _playerSuperView = [SJUIViewFactory viewWithBackgroundColor:[UIColor blackColor]];
    return _playerSuperView;
}

@end
