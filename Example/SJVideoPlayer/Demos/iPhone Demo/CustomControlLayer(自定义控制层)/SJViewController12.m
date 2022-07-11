//
//  SJViewController12.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/10/11.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController12.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJSourceURLs.h"
#import "SJCustomControlLayerViewController.h"


static SJEdgeControlButtonItemTag SJTestEdgeControlButtonItemTag = 101;
static SJControlLayerIdentifier SJTestControlLayerIdentifier = 101;


@interface SJViewController12 ()<SJCustomControlLayerViewControllerDelegate>

@property (nonatomic, strong) SJVideoPlayer *player;

@end

@implementation SJViewController12

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
    
    // Do any additional setup after loading the view from its nib.
}

///
/// 添加控制层到切换器中
///     只需添加一次, 之后直接切换即可.
///
- (void)_addCustomControlLayerToSwitcher {
    __weak typeof(self) _self = self;
    [_player.switcher addControlLayerForIdentifier:SJTestControlLayerIdentifier lazyLoading:^id<SJControlLayer> _Nonnull(SJControlLayerIdentifier identifier) {
        __strong typeof(_self) self = _self;
        if ( !self ) return nil;
        SJCustomControlLayerViewController *vc = SJCustomControlLayerViewController.new;
        vc.delegate = self;
        return vc;
    }];
}

///
/// 切换控制层
///
- (void)switchControlLayer {
    if ( _player.isFullscreen == NO ) {
        [_player rotate:SJOrientation_LandscapeLeft animated:YES completion:^(SJVideoPlayer * _Nonnull player) {
           [player.switcher switchControlLayerForIdentifier:SJTestControlLayerIdentifier];
        }];
    }
    else {
        [self.player.switcher switchControlLayerForIdentifier:SJTestControlLayerIdentifier];
    }
}

///
/// 点击空白区域, 切换回旧控制层
///
- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer {
    [self.player.switcher switchControlLayerForIdentifier:SJControlLayer_Edge];
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
 
- (void)_setupViews {
    _player = [SJVideoPlayer player];
    [self _removeExtraItems];
    [self _addSwitchItem];
    [self _addCustomControlLayerToSwitcher];
    
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

///
/// 删除当前demo不需要的item
///
- (void)_removeExtraItems {
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Full];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Separator];
    [_player.defaultEdgeControlLayer.bottomAdapter exchangeItemForTag:SJEdgeControlLayerBottomItem_DurationTime withItemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJEdgeControlButtonItem *durationItem = [_player.defaultEdgeControlLayer.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    durationItem.insets = SJEdgeInsetsMake(8, 16);
    _player.defaultEdgeControlLayer.bottomContainerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
    _player.defaultEdgeControlLayer.topContainerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
}

///
/// 添加一个切换控制层的item(在右侧)
///
- (void)_addSwitchItem {
    _player.defaultEdgeControlLayer.rightMargin = 12; // 距离右边屏幕的间隔
    
    SJEdgeControlButtonItem *switchItem = [SJEdgeControlButtonItem.alloc initWithImage:[UIImage imageNamed:@"2"] target:self action:@selector(switchControlLayer) tag:SJTestEdgeControlButtonItemTag];
    [_player.defaultEdgeControlLayer.rightAdapter addItem:switchItem];
    [_player.defaultEdgeControlLayer.rightAdapter reload];

}
@end

#pragma mark -
#import <SJRouter/SJRouter.h>
@interface SJViewController12 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController12 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/CustomControlLayer/vc12";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:SJViewController12.new animated:YES];
}

@end
