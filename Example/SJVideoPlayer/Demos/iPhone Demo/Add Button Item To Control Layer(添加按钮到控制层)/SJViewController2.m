//
//  SJViewController2.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController2.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJSourceURLs.h"

static SJEdgeControlButtonItemTag const SJTestItemTag1 = 100;
static SJEdgeControlButtonItemTag const SJTestImageItemTag = 101;
static SJEdgeControlButtonItemTag const SJTestTextItemTag = 102;
static SJEdgeControlButtonItemTag const SJTestCustomItemTag = 103;

@interface SJViewController2 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerVIew;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJViewController2
- (BOOL)shouldAutorotate {
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)test {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
}

- (IBAction)addItem:(id)sender {
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"Added");
        make.font([UIFont boldSystemFontOfSize:14]);
        make.textColor(UIColor.greenColor);
    }] target:self action:@selector(test) tag:SJTestItemTag1];
    
    [_player.defaultEdgeControlLayer.rightAdapter addItem:item];
    [_player.defaultEdgeControlLayer.rightAdapter reload];
    
    

    
// 以下方法为显示控制层
    [_player controlLayerNeedAppear];
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已添加到右侧 `text item`");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
}
- (IBAction)exchangeItem:(id)sender {
    [_player.defaultEdgeControlLayer.bottomAdapter exchangeItemForTag:SJEdgeControlLayerBottomItem_DurationTime withItemForTag:SJEdgeControlLayerBottomItem_Progress];
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
    
    
    
// 以下方法为显示控制层
    [_player controlLayerNeedAppear];
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已交换底部 `时长item`与`进度item`的位置");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
}
- (IBAction)removeItem:(id)sender {
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Separator];
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
    
    
    // 以下方法为显示控制层
    [_player controlLayerNeedAppear];
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已删除底部 `分割线item`");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
}

- (IBAction)imageItem:(id)sender {
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithImage:[UIImage imageNamed:@"play"] target:self action:@selector(test) tag:SJTestImageItemTag];
    [_player.defaultEdgeControlLayer.topAdapter addItem:item];
    [_player.defaultEdgeControlLayer.topAdapter reload];
    
    
    // 以下方法为显示控制层
    [_player controlLayerNeedAppear];
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已添加到顶部 `image item`");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
}
- (IBAction)textItem:(id)sender {
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"textItem");
        make.font([UIFont boldSystemFontOfSize:14]);
        make.textColor(UIColor.greenColor);
    }] target:self action:@selector(test) tag:SJTestTextItemTag];
    [_player.defaultEdgeControlLayer.topAdapter addItem:item];
    [_player.defaultEdgeControlLayer.topAdapter reload];
    
    
    // 以下方法为显示控制层
    [_player controlLayerNeedAppear];
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已添加到顶部 `text item`");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
}
- (IBAction)customViewItem:(id)sender {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 49)];
    view.backgroundColor = [UIColor redColor];
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithCustomView:view tag:SJTestCustomItemTag];
    [_player.defaultEdgeControlLayer.topAdapter addItem:item];
    [_player.defaultEdgeControlLayer.topAdapter reload];
    

    // 以下方法为显示控制层
    [_player controlLayerNeedAppear];
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已添加到顶部 `custom view`");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
}

#pragma mark -
- (void)_setupViews {
    _player = [SJVideoPlayer player];
    [_playerContainerVIew addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    _player.assetURL = SourceURL1;
    _player.defaultEdgeControlLayer.enabledClips = YES;
    
}

@end



#import <SJRouter/SJRouter.h>
@interface SJViewController2 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController2 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/controlLayer/edgeButtonItem";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController2 alloc] initWithNibName:@"SJViewController2" bundle:nil] animated:YES];
}

@end
