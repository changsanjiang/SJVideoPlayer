//
//  SJiPadDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/23.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJiPadDemoViewController1.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJSourceURLs.h"
static SJEdgeControlButtonItemTag const SJTestItemTag1 = 100;

@interface SJiPadDemoViewController1 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJiPadDemoViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self _addTestItem];
}

- (void)testAction {
    __weak typeof(self) _self = self;
    [_player setFitOnScreen:NO animated:YES completionHandler:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        UIViewController *vc = [UIViewController new];
        vc.view.backgroundColor = UIColor.blueColor;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)_setupViews {
    _player = [SJVideoPlayer player];
    [_playerContainerView addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    _player.onlyUsedFitOnScreen = YES;
    _player.assetURL = SourceURL0;
}

- (void)_addTestItem {
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"Push").textColor(UIColor.greenColor);
    }] target:self action:@selector(testAction) tag:SJTestItemTag1];
    
    [_player.defaultEdgeControlLayer.rightAdapter addItem:item];
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
