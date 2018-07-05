# SJVideoPlayer
[![Build Status](https://travis-ci.org/changsanjiang/SJVideoPlayer.svg?branch=master)](https://travis-ci.org/changsanjiang/SJVideoPlayer)
[![Version](https://img.shields.io/cocoapods/v/SJVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/SJVideoPlayer)
[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://github.com/changsanjiang)
[![License](https://img.shields.io/github/license/changsanjiang/SJVideoPlayer.svg)](https://github.com/changsanjiang/SJVideoPlayer/blob/master/LICENSE.md)

### Installation
```ruby
# Player with default control layer.
pod 'SJVideoPlayer'

# The base player, without the control layer, can be used if you need a custom control layer.
pod 'SJBaseVideoPlayer'
```
- [Base Video Player](https://github.com/changsanjiang/SJBaseVideoPlayer)

___

## Features
- [x] Quick initialization
- [x] [Support Fullscreen Pop Gesture](https://github.com/changsanjiang/SJFullscreenPopGesture)
- [x] [Network status change prompt](https://upload-images.jianshu.io/upload_images/2318691-819b9bd24115ae29.gif?imageMogr2/auto-orient/strip)
- [x] [Support rotation to the orientation you want](https://github.com/changsanjiang/SJBaseVideoPlayer/blob/9e018b7a919e14e2986ba3beda0e47d823768b54/SJBaseVideoPlayer/SJBaseVideoPlayer.h#L459)
- [x] [Export clips or generate GIF or Screenshot](https://github.com/changsanjiang/SJBaseVideoPlayer/blob/9e018b7a919e14e2986ba3beda0e47d823768b54/SJBaseVideoPlayer/SJBaseVideoPlayer.h#L544)
- [x] [Custom control layer](https://github.com/changsanjiang/SJBaseVideoPlayer/blob/9e018b7a919e14e2986ba3beda0e47d823768b54/SJBaseVideoPlayer/SJBaseVideoPlayer.h#L630)
- [x] [Support in TableHeaderView | TableViewCell | CollectionViewCell playing video](https://github.com/changsanjiang/SJBaseVideoPlayer/blob/9e018b7a919e14e2986ba3beda0e47d823768b54/SJBaseVideoPlayer/Model/SJVideoPlayerURLAsset.h#L14)
- [x] Adjust brightness by slide vertical at left side of screen
- [x] Adjust volume by slide vertical at right side of screen
- [x] Slide horizontal to fast forward and rewind
- [x] Full screen mode drag will display video preview
- [x] [Continue playing, Jumping into the next interface can use the resource initialization of the previous interface](https://github.com/changsanjiang/SJBaseVideoPlayer/blob/9e018b7a919e14e2986ba3beda0e47d823768b54/SJBaseVideoPlayer/Model/SJVideoPlayerURLAsset.h#L133)
___


## Example
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/play.gif" />
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/export.gif" />

___

## Contact
* Email: changsanjiang@gmail.com
* QQGroup: 719616775 
___

## License
SJVideoPlayer is available under the MIT license. See the LICENSE file for more info.

___

## 使用图解
- 播放器在普通视图上播放:

![在UIView上播放.png](http://upload-images.jianshu.io/upload_images/2318691-09585f373eff7211?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```Objective-C

/// 以下为示例:
    _videoPlayer = [SJVideoPlayer player];
    _videoPlayer.view.frame = CGRectMake(0, 20, 375, 375 * 9/16.0); // 可以使用AutoLayout, 这里为了简便设置的Frame.
    [self.view addSubview:_videoPlayer.view];
    // 初始化资源
    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"http://..."]];
    // 当然也可以指定开始时间. 如下, 从第20秒开始播放
    // _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"http://..."] specifyStartTime:20.0];

```

___


* 播放器在UITableViewCell或UICollectionViewCell中播放:

![播放器在UITableViewCell或UICollectionViewCell中播放.png](http://upload-images.jianshu.io/upload_images/2318691-18c33f4e5fcbb0f6?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```Objective-C

/// 以下为示例:
/// UICollectionView同UITableView初始化一致, 所以此处仅展示UITableView的示例.
- (void)clickedPlayBtnOnTabCell:(SJVideoListTableViewCell *)cell playerSuperview:(UIView *)playerSuperview {
    //  1. 创建一个播放资源
    SJPlayModel *playModel =
    [SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:playerParentView.tag  // 请务必设置tag, 且不能等于0. 由于重用机制, 当视图滚动时, 播放器需要通过此tag寻找其父视图
                                                    atIndexPath:[self.tableView indexPathForCell:cell]
                                                      tableView:self.tableView];
    SJVideoPlayerURLAsset *asset =
    [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"http://..."]
                                     playModel:playModel];

    // 2. 设置资源标题
    asset.title = @"DIY心情转盘 #手工##手工制作##卖包子喽##1块1个##卖完就撤#";
    // 3. 默认情况下, 小屏时不显示标题, 全屏后才会显示, 这里设置一直显示标题
    asset.alwaysShowTitle = YES;
  
    _videoPlayer = [SJVideoPlayer player];
    [playerSuperview addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    // 设置资源
    _videoPlayer.URLAsset = asset;
}

```
___

* 播放器在tableHeaderView上播放:
![播放器在tableHeaderView上播放.png](http://upload-images.jianshu.io/upload_images/2318691-d1894aeb69b2db58?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```Objective-C

/// 以下为示例:    
    __weak typeof(self) _self = self;
    // table header btn clicked event.
    self.tableHeaderView.clickedPlayBtnExeBlock = ^(TableHeaderView * _Nonnull playerSuperview) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        //  1. 创建一个播放资源
        SJVideoPlayerURLAsset *asset =
        [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"https://..."]
                                         playModel:[SJPlayModel UITableViewHeaderViewPlayModelWithPlayerSuperview:playerSuperview tableView:self.tableView]];

        // 2. 设置资源标题
        asset.title = @"DIY心情转盘 #手工##手工制作#";
        // 3. 默认情况下, 小屏时不显示标题, 全屏后才会显示, 这里设置一直显示标题
        asset.alwaysShowTitle = YES;

        self.videoPlayer = [SJVideoPlayer player];
        [playerSuperview addSubview:self.videoPlayer.view];
        [self.videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        // 设置资源
        self.videoPlayer.URLAsset = asset;
    };

```

___


* 播放器在UICollectionViewCell中播放, 同时UICollectionView在tableHeaderView中:
![播放器在UICollectionViewCell中播放, 同时UICollectionView在tableHeaderView中.png](http://upload-images.jianshu.io/upload_images/2318691-70b8ddc7ba50d42f?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```Objective-C

/// 以下为示例:
    __weak typeof(self) _self = self;
    _tableHeaderView.clickedPlayBtnExeBlock = ^(TableHeaderView *view, UICollectionView *collectionView, NSIndexPath *indexPath, UIView *playerSuperview) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;        

        //  1. 创建一个播放资源
        SJPlayModel *playModel = [SJPlayModel UICollectionViewNestedInUITableViewHeaderViewPlayModelWithPlayerSuperviewTag:playerSuperview.tag atIndexPath:indexPath collectionView:collectionView tableView:self.tableView];

        SJVideoPlayerURLAsset *asset =
        [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"https://..."]
                                         playModel:playModel];
        
        // 2. 设置资源标题
        asset.title = @"DIY心情转盘 #手工##手工制作#";
        // 3. 默认情况下, 小屏时不显示标题, 全屏后才会显示, 这里设置一直显示标题
        asset.alwaysShowTitle = YES;

        self.videoPlayer = [SJVideoPlayer player];
        [playerSuperview addSubview:self.videoPlayer.view];
        [self.videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        // 设置资源
        self.videoPlayer.URLAsset = asset;
    };

```

___

* 播放器在UICollectionCell中播放, 同时UICollectionView在UITableViewCell中:
![播放器在UICollectionCell中播放, 同时UICollectionView在UITableViewCell中.png](http://upload-images.jianshu.io/upload_images/2318691-2f82f8729c95b56c?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```Objective-C

/// 以下为示例:
- (void)clickedPlayWithTableViewCell:(NestedTableViewCell *)tabCell
                     playerSuperview:(UIView *)playerSuperview
         collectionViewCellIndexPath:(NSIndexPath *)collectionViewCellIndexPath
                      collectionView:(UICollectionView *)collectionView {
    //  1. 创建一个播放资源
    NSIndexPath *tabCellIndexPath = [self.tableView indexPathForCell:tabCell];

    SJPlayModel *playModel = [SJPlayModel UICollectionViewNestedInUITableViewCellPlayModelWithPlayerSuperviewTag:playerSuperview.tag atIndexPath:collectionViewCellIndexPath collectionViewTag:collectionView.tag collectionViewAtIndexPath:tabCellIndexPath tableView:self.tableView];

    SJVideoPlayerURLAsset *asset =
    [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"https://..."]
                                     playModel:playModel];

    // 2. 设置资源标题
    asset.title = @"DIY心情转盘 #手工##手工制作#";
    // 3. 默认情况下, 小屏时不显示标题, 全屏后才会显示, 这里设置一直显示标题
    asset.alwaysShowTitle = YES;

    self.videoPlayer = [SJVideoPlayer player];
    [playerSuperview addSubview:self.videoPlayer.view];
    [self.videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
    }];
    // 设置资源
    self.videoPlayer.URLAsset = asset;
}

```

___

## 资源三板斧
* 资源刷新. 在播放一个资源时, 可能有一些意外情况导致播放失败(如网络环境差). 此时当用户点击刷新按钮, 我们需要对当前的资源(Asset)进行刷新. SJVideoPlayer提供了直接的方法去刷新, 不需要开发者再重复的去创建新的Asset.

```Objective-C

/// 以下为示例:
    // 对当前资源进行刷新, 尝试重新播放视频
    [_videoPlayer refresh];

```

* 记录某个播放位置. 我们有时候想存储某个视频的播放记录, 以便下次, 能够从指定的位置进行播放. 那什么时候存储合适呢? 最好的时机就是资源被释放时. SJVideoPlayer提供了每个资源在Dealloc中, 都进行的回调, 如下:

```Objective-C

/// 以下为示例:
     // 每个资源dealloc时的回调
    _videoPlayer.assetDeallocExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer) {
      // .....
    };

```

* **续播**. 在播放时, 我们可能需要切换界面, 而希望视频能够在下一个界面无缝的进行播放. 针对此种情况 SJVideoPlayerURLAsset 提供了便利的初始化方法. 请看片段:

```Objective-C

- (instancetype)initWithOtherAsset:(SJVideoPlayerURLAsset *)otherAsset 
                         playModel:(__kindof SJPlayModel *)playModel;

/// 以下为示例:
  // 新界面的播放器, 资源初始化:
    _videoPlayer = [SJVideoPlayer player];
    _videoPlayer.view.frame = CGRectMake(0, 20, 375, 375 * 9/16.0); // 可以使用AutoLayout, 这里为了简便设置的Frame.
    [self.view addSubview:_videoPlayer.view];
    // 初始化资源
    _videoPlayer.URLAsset = [SJVideoPlayerURLAsset initWithOtherAsset:otherAsset playModel:[SJPlayModel playModel....]; 

```
是的, otherAsset即为上一个页面播放的Asset, 只要用它进行初始化即可实现续播功能. 同时可以发现, 初始化时, 除了需要一个otherAsset, 其他方面同开始的示例一模一样.

请看下图:
![image](http://upload-images.jianshu.io/upload_images/2318691-fa54404017304342?imageMogr2/auto-orient/strip)

___

## 优雅自如的旋转

对于旋转, 我们开发者肯定需要绝对的控制, 例如: 设置自动旋转所支持方向. 能够主动+自动旋转, 而且还需要能在适当的时候禁止自动旋转. 旋转前后的回调等等... 放心这些功能都有, 我挨个给大家介绍一下:

先说说何为自动旋转. 其实就是播放器根据当前设备的方向, 进行自动旋转.

* 设置自动旋转所支持方向, SJVideoPlayer自动旋转支持的方向如下:

```Objective-C

/// 自动旋转所支持的方向
typedef NS_ENUM(NSUInteger, SJAutoRotateSupportedOrientation) {
    SJAutoRotateSupportedOrientation_All,
    SJAutoRotateSupportedOrientation_Portrait = 1 << 0,
    SJAutoRotateSupportedOrientation_LandscapeLeft = 1 << 1,  // UIDeviceOrientationLandscapeLeft
    SJAutoRotateSupportedOrientation_LandscapeRight = 1 << 2, // UIDeviceOrientationLandscapeRight
};

```

以上为自动旋转时, 所支持的方向, 播放器默认为`SJAutoRotateSupportedOrientation_All`. 当我们不想让播放器旋转到某个方向时, 可以如下设置:

```Objective-C

/// 以下为示例:
    // 例如设置播放器只能在全屏方向上旋转
    _videoPlayer.supportedOrientation = SJAutoRotateSupportedOrientation_LandscapeLeft | SJAutoRotateSupportedOrientation_LandscapeRight;

```
___

* 主动旋转. 当我们想主动旋转时, 大概分为以下三点:
  - 主动旋转. 播放器旋转到用户当前的设备方向或小屏.
  - 主动旋转到指定方向. 
  - 主动旋转完成后的回调.

请看以下方法, 分别对应以上三点:

```Objective-C

- (void)rotate;
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated;
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof SJBaseVideoPlayer *player))block;

// 调用示例:
[_videoPlayer rotate]; // 主动旋转, 让播放器旋转到用户当前的设备方向或小屏.

``` 

___


* 旋转前后的回调. 我们在播放一个视频时, 小屏播的时候, 状态栏的style一般为UIStatusBarStyleDefault. 但是全屏播放视频时, 状态栏就得变成UIStatusBarStyleLightContent, 看下图对比:
  - ![白条.png](http://upload-images.jianshu.io/upload_images/2318691-03d63335eb415dde?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) 
  - ![黑条.png](http://upload-images.jianshu.io/upload_images/2318691-dcf80f12db11eb38?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
额, 我们赶紧说回调吧, 状态栏还是变成白的好一点. 旋转前的回调以及旋转后的回调如下:

```Objective-C

/// 旋转前的回调
@property (nonatomic, copy, nullable) void(^viewWillRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);
/// 旋转后的回调
@property (nonatomic, copy, nullable) void(^viewDidRotateExeBlock)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);

/// 以下为示例:

// 旋转前的示例(我常用旋转前的block, 旋转后的block基本没用过😝):
// 1. 设置播放器旋转前的回调. 
    _videoPlayer.viewWillRotateExeBlock = ^(SJVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [UIView animateWithDuration:0.25 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    };
// 2. 根据控制层的显示状态 去控制状态栏的显示和隐藏
- (BOOL)prefersStatusBarHidden {
  // 全屏播放时, 使状态栏根据控制层显示或隐藏
  if ( self.videoPlayer.isFullScreen ) return !self.videoPlayer.controlLayerAppeared;
  return NO;
}
// 3. 如果播放器为全屏显示时, 返回状态栏的style为UIStatusBarStyleLightContent, 小屏返回 UIStatusBarStyleDefault
- (UIStatusBarStyle)preferredStatusBarStyle {
  // 全屏播放时, 使状态栏变成白色
  if ( self.videoPlayer.isFullScreen ) return UIStatusBarStyleLightContent;
  return UIStatusBarStyleDefault;
}

```

___

* 禁止自动旋转. 这个功能是必须有的, 如果不禁止旋转, 请看图:

![需要禁止旋转.gif](http://upload-images.jianshu.io/upload_images/2318691-41cea0eeeaaf4d8b?imageMogr2/auto-orient/strip)
SJVideoPlayer可以通过如下方式禁止自动旋转:

```Objective-C

// 禁止自动旋转. 
_videoPlayer.disableAutoRotation = YES;

```

这里有两点需要注意: 1. 返回时要记得恢复自动旋转. 2. 禁止自动旋转后, 手动点击全屏按钮, 还是可以旋转的.

___

* 禁止任何旋转. 也就是锁屏. 请看图:

![锁屏.gif](http://upload-images.jianshu.io/upload_images/2318691-0e98cdcbae21d4ce?imageMogr2/auto-orient/strip)

请注意: 在锁屏状态下, 此时不管是主动旋转, 还是自动旋转, 都将不触发. 代码如下:

```Objective-C

/// 锁屏
_videoPlayer.lockedScreen = YES;

```

___


* 还有一些其他便利的属性, 如下:

```Objective-C

/// 是否是全屏
@property (nonatomic, readonly) BOOL isFullScreen;
/// 当前播放器的方向
@property (nonatomic) SJOrientation orientation;
/// 当前播放器旋转到的设备方向
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;

```
___

## 播放的控制

SJVideoPlayer的常规播放控制大概有:  静音, 自动播放, 使播放, 使暂停, 使停止, 使重播. 
哦, 对了还有亮度, 声音, 速率(rate)这些的设置. 并且都有相应的回调. 代码我就不贴了, 一看就明白了.

我再介绍一下其他的控制功能:
- 后台播放视频, 这个功能我引用自: https://juejin.im/post/5a38e1a0f265da4327185a26, 大家可以给点个❤️鼓励一下作者. 我将这个功能集成到了SJVideoPlayer播放器中, 如下:

```Objective-C

/**
 关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
 
 当您想在后台播放视频时:
 1. 需要设置 videoPlayer.pauseWhenAppDidEnterBackground = NO; (该值默认为YES, 即App进入后台默认暂停).
 2. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
 */
@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;

// 示例:
_videoPlayer.pauseWhenAppDidEnterBackground = YES; // 请记得按上述注释的步骤配置

```

___

* 播放完毕的回调. 我们有时候希望能够重复的播放一个视频. 这时可能需要监听当前的视频有没有播放结束. SJVideoPlayer 提供了播放视频完毕后的回调, 代码如下:

```Objective-C

    __weak typeof(self) _self = self;
    _videoPlayer.playDidToEndExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [player replay];
    }

```

如上, 当播放完毕时, 播放器调用 replay 方法, 让其从头重新开始播放.

___

## 网络状态变更时的提示
有时候我们需要能够友好的告诉客户当前的网络状态发生了改变, 毕竟流量是要钱的. 我们继续看图:
![网络状态变更提示.png](http://upload-images.jianshu.io/upload_images/2318691-c8dd1fb181ec14c2?imageMogr2/auto-orient/strip)
这些提示, 我都做了本地化处理, 支持的语言有: 中文/繁体/英文. 开发者也可以自己定义想要的提示. 后面我会介绍SJVideoPlayer全局的配置类, 它可以配置各个控件的图片, slider, 本地化的一些提示等等.

___

## 待续...


### 文章汇总
介绍: 
* https://www.jianshu.com/p/4c2a493fb4bf

使用: 
* https://www.jianshu.com/p/a60389f9acaf
* https://www.jianshu.com/p/6a968ec24d3f
