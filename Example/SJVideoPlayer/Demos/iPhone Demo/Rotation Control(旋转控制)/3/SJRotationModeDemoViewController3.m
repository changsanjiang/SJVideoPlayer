//
//  SJRotationModeDemoViewController3.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/14.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJRotationModeDemoViewController3.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJSourceURLs.h"

@interface SJRotationModeDemoViewController3 ()

@property (nonatomic, strong) SJVideoPlayer *player;

@end

@implementation SJRotationModeDemoViewController3

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (void)_setupViews {
    _player = [SJVideoPlayer player];
    _player.rotationManager.disabledAutorotation = YES;
    _player.rotationManager.autorotationSupportedOrientations = SJOrientationMaskLandscapeLeft;
    
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Full];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Separator];
    [_player.defaultEdgeControlLayer.bottomAdapter exchangeItemForTag:SJEdgeControlLayerBottomItem_DurationTime withItemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJEdgeControlButtonItem *durationItem = [_player.defaultEdgeControlLayer.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    durationItem.insets = SJEdgeInsetsMake(8, 16);
    _player.defaultEdgeControlLayer.bottomContainerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
    _player.defaultEdgeControlLayer.topContainerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end

#pragma mark -
#import <SJRouter/SJRouter.h>
@interface SJRotationModeDemoViewController3 (RouteHandler)<SJRouteHandler>

@end

@implementation SJRotationModeDemoViewController3 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/rotationMode/vc3";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController presentViewController:[[SJRotationModeDemoViewController3 alloc] initWithNibName:@"SJRotationModeDemoViewController3" bundle:nil] animated:YES completion:nil];
}

@end
