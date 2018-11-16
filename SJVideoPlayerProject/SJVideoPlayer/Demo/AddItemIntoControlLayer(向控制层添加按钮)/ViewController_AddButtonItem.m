//
//  ViewController_AddButtonItem.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewController_AddButtonItem.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>

/// 控制层 Item 相关操作 之 `添加按钮`

static SJEdgeControlButtonItemTag SJEdgeControlButtonItemTag_Share = 10;        // 分享

@interface ViewController_AddButtonItem ()<SJRouteHandler, SJEdgeControlButtonItemDelegate>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewController_AddButtonItem

+ (NSString *)routePath {
    return @"player/defaultPlayer/addItem";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
//    [_player showTitle:@"当前Demo为: 添加 item 到控制层" duration:-1];

    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    
    // Do any additional setup after loading the view.
}

#pragma mark - add
- (IBAction)add:(id)sender {
    // add share item into top control layer
    
    // create item
    SJEdgeControlButtonItem *shareItem = [SJEdgeControlButtonItem placeholderWithSize:58 tag:SJEdgeControlButtonItemTag_Share];
    shareItem.image = [UIImage imageNamed:@"share"];
    shareItem.delegate = self;
    [shareItem addTarget:self action:@selector(clickedShareItem)];
    
    // add
    [_player.defaultEdgeControlLayer.topAdapter addItem:shareItem];
    [_player.defaultEdgeControlLayer.topAdapter reload];
    
    
    
#ifdef SJMAC
    // 这个方法无需调用, 这里调用是为了调试
    [_player controlLayerNeedAppear];
#endif
}

#pragma mark - remove
- (IBAction)remove:(id)sender {
    [_player.defaultEdgeControlLayer.topAdapter removeItemForTag:SJEdgeControlButtonItemTag_Share];
    [_player.defaultEdgeControlLayer.topAdapter reload];
}

/// 向centerAdapter添加Item
- (IBAction)addItemIntoCenterControllayer:(id)sender {
    UISlider *v = [UISlider new];
    /// 测试, 给一个随机大小
    v.bounds = CGRectMake(0, 0, 200, 200);
    /// 测试, 随机颜色
    v.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                         green:arc4random() % 256 / 255.0
                                          blue:arc4random() % 256 / 255.0
                                         alpha:1];
    
    SJEdgeControlButtonItem *item = [SJEdgeControlButtonItem frameLayoutWithCustomView:v tag:0];
    [_player.defaultEdgeControlLayer.centerAdapter addItem:item];
    [_player.defaultEdgeControlLayer.centerAdapter reload];
}

- (void)clickedShareItem {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

#pragma mark - update
/// 每次控制层显示, 下面这个方法, 都将会调用
/// 如果需要根据播放器的状态, 更新Item的属性, 可以直接在这个方法里面修改即可
- (void)updatePropertiesIfNeeded:(SJEdgeControlButtonItem *)item videoPlayer:(__kindof SJBaseVideoPlayer *)player {
    
#ifdef DEBUG
    NSLog(@"%d - %s [控制层每次显示之前, 将会调用这个方法, 如需更新资源, 可以像如下方式操作.]", (int)__LINE__, __func__);
#endif
    
    // 直接修改即可
    //    if ( player.isFullScreen ){
    //        item.image = [UIImage imageNamed:@"..."];
    //    }
    
    /// 有些时候, 我们需要某个按钮, 在小屏时隐藏, 大屏后显示.
    /// 可以通过下面这个属性, 来控制item是否隐藏
    /// 注意: 将逻辑放到item的代理方法中`updatePropertiesIfNeeded:videoPlayer:`
    //  imageItem.hidden = !player.isFullScreen;
}





#pragma mark -
- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // create a player of the default type
    _player = [SJVideoPlayer player];
    
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
