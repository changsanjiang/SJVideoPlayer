//
//  ViewController.m
//  Demo
//
//  Created by BlueDancer on 2018/5/18.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#pragma mark - 该project是一个 关于如何自定义控制层的实例, 关于更详细的示例, 请前往主项目查看.

/// SJBaseVideoPlayer 与 SJVideoPlayer 的区别
/// SJBaseVideoPlayer
/// 主要功能
/// 1. 控制一个资源的播放/导出/截屏
/// 2. 视频的旋转控制
/// 3. 网络状态监听
/// 4. 显示提示
/// 还有一个其他方法, 可以前往头文件查看

/// SJVideoPlayer
/// 继承于 SJBaseVideoPlayer
/// 主要是UI交互功能的实现, 其中包括BaseVideoPlayer中关于控制层的代理协议
/// 可以参照该实现自定义一个控制层

/// 播放器的delegate 和 dataSource 可以来回的切换
/// 比如: 播放控制层 / 导出视频层, 这些控制层可以通过替换播放器的delegate和dataSource来实现

#import "ViewController.h"
#import <Masonry.h>
#import "SJDemoVideoPlayer.h"


@interface ViewController ()
@property (nonatomic, strong) SJDemoVideoPlayer *videoPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// 初始化一个播放器
    _videoPlayer = [SJDemoVideoPlayer player];
    /// 将播放器的视图添加到父视图上
    [self.view addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.leading.trailing.offset(0);
        make.height.equalTo(self.videoPlayer.view.mas_width).multipliedBy(9/16.0);
    }];
    
    /// 播放一个资源
    /// 调用initWith...初始化即可
    /// 可以从指定的进度继续播放
    /// 如下, 从第10秒开始播放
    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"] specifyStartTime:10]; // 关于如何记录播放时间, 请看下面的 资源部分的注释

    [self 一些注释];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)一些注释 {
    
    #pragma mark -控制层
    /// 控制层默认会在3秒后, 自动隐藏
    /// 如果想在某个时刻, 立即显示控制层, 可以像下面这样做
    /// 手动调用 显示控制层
    
    /// 隐藏控制层
    /// 播放器会回调代理方法  - (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer;
    /// 代理方法的实现参照: SJDemoVideoPlayerControlLayer 中
    [_videoPlayer controlLayerNeedDisappear];
    
    /// 显示
    /// 播放器回调如上隐藏, 参照见 SJDemoVideoPlayerControlLayer 中
    [_videoPlayer controlLayerNeedAppear];
    
    
    
    /// 查看控制层是否显示
    if ( _videoPlayer.controlLayerAppeared ) NSLog(@"控制层显示中");
    else NSLog(@"控制层已隐藏");
    
    
    /// 控制层显示状态改变时调用
    _videoPlayer.controlLayerAppearStateChanged = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL state) {
        if ( state ) NSLog(@"控制层显示中");
        else NSLog(@"控制层已隐藏");
    };
    
    /// 播放暂停时, 保持控制层的显示状态
    _videoPlayer.pausedToKeepAppearState = YES;
    /// 播放失败时, 保持控制层的显示状态
    _videoPlayer.playFailedToKeepAppearState = YES;
    
    
    #pragma mark -播放控制
#if 0
    /// 是否自动播放, 默认是yes
    _videoPlayer.autoPlay = YES;
    /// 播放
    [_videoPlayer play];
    /// 使暂停
    [_videoPlayer pause];
    /// 停止播放
    [_videoPlayer stop];
    /// 是否静音
    _videoPlayer.mute = YES;
    /// 修改声音
    /// 当 _videoPlayer.mute = YES; 设置无效
    _videoPlayer.volume = 0.6;
    /// 修改亮度
    _videoPlayer.brightness = 0.6;
    /// 修改速率
    _videoPlayer.rate = 1.5;
    /// 速率改变的回调
    _videoPlayer.rateChanged = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
    };
    
    // 速率/声音/亮度变更 会调用代理方法
    - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer muteChanged:(BOOL)mute;
    
    - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer volumeChanged:(float)volume;
    
    - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;
    
    - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer rateChanged:(float)rate;
#endif
    
    #pragma mark -资源
#if 0
    // 播放一个资源, 可以是本地, 也可是网络资源
    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/sample.mp4"] beginTime:10];
    // 刷新当前的资源
    [_videoPlayer refresh];
    // 每个资源 dealloc的时候, 会调用这个方法
    // 可以本地记录一下这个资源的播放进度
    // 下次播放, 初始化资源时从指定的时间
    _videoPlayer.assetDeallocExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer) {
        
    };
    
    // 播放一个新的资源时, 播放器会 调用代理方法, 如下
    - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset;
    
    // 播放状态改变时, 会调用
    - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state;
#endif
    
    #pragma mark -网络状态
#if 0
    /// 当前的网络状态
    _videoPlayer.networkStatus;
    
    /// 网路状态变更会 回调代理方法
    - (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status;
#endif
    
    
    #pragma mark -scrollview
#if 0
    /// 当在 scrollView 上播放的时候
    /// 滚动出现时, 会调用代理方法
    /// 实现可以参照 DemoLayer 里面的
    - (void)videoPlayerWillAppearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer;

    /// 隐藏时, 回调的代理方法
    /// 实现可以参照 DemoLayer 里面的
    - (void)videoPlayerWillDisappearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer;
#endif
    
    
    #pragma mark -手动控制旋转, 详见 basePlayer 中的方法介绍
    
    #pragma mark -全屏手势的一些设置, 详见 UINavigationController+SJVideoPlayerAdd 和 UIViewController+SJVideoPlayerAdd 这两个头文件
    
    #pragma mark -loadingView, 详见 demoLayer 中的使用
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
