//
//  ViewController_ItemExamples.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewController_ItemExamples.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import <SJAttributesFactory/SJAttributeWorker.h>

/// 控制层 Item 相关操作 之 `添加按钮`

static SJEdgeControlButtonItemTag SJEdgeControlButtonItemTag_Share = 10;        // 分享

@interface ViewController_ItemExamples ()<SJRouteHandler, SJEdgeControlButtonItemDelegate>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewController_ItemExamples

+ (NSString *)routePath {
    return @"player/defaultPlayer/itemExamples";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    _player.pausedToKeepAppearState = YES;
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    
    
    [_player showTitle:@"当前Demo为: 更多 item 的创建示例" duration:-1];

    
    
    // 1. 49 * 49 大小的图片item
    SJEdgeControlButtonItem *imageItem = [[SJEdgeControlButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] target:self action:@selector(test:) tag:SJEdgeControlButtonItemTag_Share];
    /// 是否隐藏
    /// 有些时候, 我们需要某个按钮, 在小屏时隐藏, 大屏后显示.
    /// 可以通过下面这个属性, 来控制item是否隐藏
    /// 注意: 将逻辑放到item的代理方法中`updatePropertiesIfNeeded:videoPlayer:`
//    imageItem.delegate = self;
//    imageItem.hidden = YES;
    [_player.defaultEdgeControlLayer.topAdapter addItem:imageItem];
    
    
    // 2. 49 * title.size.width
    SJEdgeControlButtonItem *titleItem = [[SJEdgeControlButtonItem alloc] initWithTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append(@"Share").font([UIFont systemFontOfSize:14]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    }) target:self action:@selector(test:) tag:SJEdgeControlButtonItemTag_Share];
    
    // 调整 item 前后间隔
    titleItem.insets = SJEdgeInsetsMake(8, 8);
    [_player.defaultEdgeControlLayer.topAdapter addItem:titleItem];
    
    
    
    // 3. 自定义视图
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 58, 49)];
    customView.backgroundColor = [UIColor yellowColor];
    SJEdgeControlButtonItem *customItem = [[SJEdgeControlButtonItem alloc] initWithCustomView:customView tag:SJEdgeControlButtonItemTag_Share/* 这个标记一定要与其他item区分开, 我这里为了方便就使用了同一个... */];
    [_player.defaultEdgeControlLayer.bottomAdapter addItem:customItem];
    
    
    // 4.1 占位item(先占好位置, 后更新属性)
    SJEdgeControlButtonItem *placeholderItem = [SJEdgeControlButtonItem placeholderWithSize:49 tag:SJEdgeControlButtonItemTag_Share];
    [_player.defaultEdgeControlLayer.rightAdapter addItem:placeholderItem];
    
    // 用于异步加载资源
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // ... 耗时任务
        placeholderItem.image = [UIImage imageNamed:@"share"];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新
            [self.player.defaultEdgeControlLayer.rightAdapter reload];
        });
    });
    
    
    // 4.2 占位2
    // 创建一个大小为 49 * 49 的item
//    SJEdgeControlButtonItem *p2 = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlButtonItemTag_Share];
    
    
    // 4.3 占位3
    // 创建一个自适应大小的item, 不过高度必须是49
    SJEdgeControlButtonItem *p3 = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xAutoresizing tag:SJEdgeControlButtonItemTag_Share];
    // 在这里我就直接设置标题了, 也可以异步更新
    p3.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append([UIImage imageNamed:@"share"], CGPointZero, CGSizeZero).alignment(NSTextAlignmentCenter);
        make.append(@"\nshare").font([UIFont systemFontOfSize:10]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
        make.shadow(CGSizeZero, 1, [UIColor redColor]);
    });
    
    [_player.defaultEdgeControlLayer.leftAdapter addItem:p3];

    
    // 添加了item的容器 更新一下
    [_player.defaultEdgeControlLayer.topAdapter reload];
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
    [_player.defaultEdgeControlLayer.rightAdapter reload];
    [_player.defaultEdgeControlLayer.leftAdapter reload];
}


- (void)test:(SJEdgeControlButtonItem *)item {
    
}




#pragma mark - update
/// 下面这个代理方法 会在每次控制层显示的时候调用
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
