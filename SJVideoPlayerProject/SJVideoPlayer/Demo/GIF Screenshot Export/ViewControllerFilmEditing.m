//
//  ViewControllerFilmEditing.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/11/2.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerFilmEditing.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import <objc/message.h>
#import "SJFilmEditingSettings.h"

@interface ViewControllerFilmEditing ()<SJRouteHandler, SJVideoPlayerFilmEditingResultUpload>
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic) BOOL isLogin;

@property (nonatomic, strong) id shareInfo;
@end

@implementation ViewControllerFilmEditing

+ (NSString *)routePath {
    return @"player/filmEditing";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    SJFilmEditingSettings.update(^(SJFilmEditingSettings *settings) {
//        settings.cancelText = @"...";
//        settings.doneText = @"...";
//        .....
//        ....
//        ..
    });
    
    [_player showTitle:@"当前Demo为 剪辑操作示例.  请全屏后, 点击右侧剪辑按钮." duration:-1];
    
    // play
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    _player.URLAsset.alwaysShowTitle = YES;
    
    
    // 1. 开启剪辑层(GIF/Screenshot/Export)
    _player.enableFilmEditing = YES;
    
    // 2. config
    SJVideoPlayerFilmEditingConfig *config = [[SJVideoPlayerFilmEditingConfig alloc] init];
    config.resultNeedUpload = YES; // 剪辑结果是否需要上传, 默认为YES
    config.resultUploader = self;  // 上传者
    // 导出成功后, 是否保存到相册
//    config.saveResultToAlbumWhenExportSuccess = YES;
    
    /// 2.1 用户每次点击某个操作时, 该block都会被调用. 返回Yes, 则开始操作
    ///     - 例如, 当截屏时, 用户登录之后才能继续操作, 可以在此方法中返回NO, 让用户前往登录
    __weak typeof(self) _self = self;
    config.shouldStartWhenUserSelectedAnOperation = ^BOOL(__kindof SJBaseVideoPlayer *videoPlayer, SJVideoPlayerFilmEditingOperation selectedOperation) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;

#warning 可以在这里做一些清理工作, 每次开始某个操作时, 该block都会被调用
//        self.shareInfo = nil;
        
        // 1. 模拟 未登录
        if ( !self.isLogin ) {
            [videoPlayer showTitle:@"未登录, 正在跳转登录" duration:1 hiddenExeBlock:^(SJVideoPlayer * _Nonnull player) {
                // 切换回上一个控制层(退出剪辑控制层)
                [player.switcher switchToPreviousControlLayer];
                
                // 2. 转回竖屏
                [player rotate:SJOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    
                    // 3. 前往登录界面
                    //                UIViewController *loginVC = [UIViewController new];
                    //                loginVC.view.backgroundColor = [UIColor whiteColor];
                    //                [self.navigationController pushViewController:loginVC animated:YES];
                    
                    // 我在这里就直接设置登录态了, 开发者可以如第三步一样, 跳转自己的登录页面
                    self.isLogin = !self.isLogin;
                    [player showTitle:@"测试:  已设置为登录态, 现在可以继续操作了" duration:10];
                }];
            }];
            
            return NO;
        }
        
        return YES;
    };
    
    static NSString *const kQQ = @"QQ";
    static NSString *const kWechat = @"Wechat";
    static NSString *const kWeibo = @"Weibo";
    
    SJFilmEditingResultShareItem *qq =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kQQ image:[UIImage imageNamed:@"result_qq"]];
    qq.canAlsoClickedWhenUploading = NO; // 上传的时候, 是否可以点击, 默认为NO
    
    SJFilmEditingResultShareItem *wechat =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kWechat image:[UIImage imageNamed:@"result_wechat"]];
    
    SJFilmEditingResultShareItem *weibo =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kWeibo image:[UIImage imageNamed:@"result_weibo"]];
    
    /// 3. 分享按钮
    config.resultShareItems = @[qq, wechat, weibo];
    
    /// 3.1 点击分享按钮的回调
    config.clickedResultShareItemExeBlock = ^(__kindof SJBaseVideoPlayer *player, SJFilmEditingResultShareItem *item, id<SJVideoPlayerFilmEditingResult> result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        NSString *title = nil;
        if ( item.title == kQQ ) {
            title = @"分享到QQ";
        }
        else if ( item.title == kWechat ) {
            title = @"分享到Wechat";
        }
        else if ( item.title == kWeibo ) {
            title = @"分享到Weibo";
        }

        [player showTitle:title];
        
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    };
    
    // 4. 配置到播放器
    [_player.filmEditingConfig config:config];
}

// 上传剪辑结果
static NSString *kCancelFlag = @"cancel";
- (void)upload:(id<SJVideoPlayerFilmEditingResult>)result
      progress:(void(^ __nullable)(float progress))progressBlock
       success:(void(^ __nullable)(void))success
       failure:(void (^ __nullable)(NSError *error))failure {

    switch ( result.operation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown: break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
// GIF操作, 请上传GIF到自己的服务器
//            result.fileURL // 文件保存的路径
//            result.image   // 通过gif文件, 创建的UIImage
//            result.data    // data
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
// 截屏操作, 请上传截屏到自己的服务器
//            result.image   // 截屏创建的UIImage
//            result.data    // data
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
// 导出操作, 请上传导出的视频到自己的服务器
//            result.fileURL // 文件保存的路径
//            result.data    // data
        }
            break;
    }
    
    
//    测试: 此处为 模拟上传
//    测试: 此处为 模拟上传
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        float progress = 0;
        // 取消的标记
        BOOL flag_cancel = NO;
        
        // 模拟上传进度
        while ( progress < 1 ) {
            // 是否取消上传
            flag_cancel = [objc_getAssociatedObject(result, &kCancelFlag) boolValue];
            
            if ( flag_cancel )
                break;
            
            progress += 0.2;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( progressBlock )
                    progressBlock(progress);
            });
            sleep(1); // 模拟延时
        }
        
        // 是否取消操作
        if ( flag_cancel )
            return;
        
        // 回调上传成功的block
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( success )
                success();
        });
    });
}

// 用户点击了取消按钮, 请在这里取消上传
- (void)cancelUpload:(id<SJVideoPlayerFilmEditingResult>)result {
    objc_setAssociatedObject(result, &kCancelFlag, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




#pragma mark - setup view
- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // create a player of the default type
    _player = [SJVideoPlayer player];
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    _player.pausedToKeepAppearState = YES;
    _player.generatePreviewImages = YES;
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
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

@end
