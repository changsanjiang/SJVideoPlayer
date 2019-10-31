//
//  SJRotationModeDemoViewController1.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJRotationModeDemoViewController1.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import "SJSourceURLs.h"
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJViewController4.h"

@interface SJRotationModeDemoViewController1 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJBaseVideoPlayer *player;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation SJRotationModeDemoViewController1
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _player = [SJVideoPlayer player];
    
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:SourceURL4];
    asset.title = @"123456789";
    _player.URLAsset = asset;
    [_playerContainerView addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) _self = self;
    _player.rotationObserver.rotationDidStartExeBlock = ^(id<SJRotationManagerProtocol>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
#ifdef DEBUG
        NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
    };
}

- (IBAction)rotate:(id)sender {
    [_player rotate];
}

- (IBAction)rotateToTheLLO:(id)sender {
    [_player rotate:SJOrientation_LandscapeLeft animated:YES];
}

- (IBAction)rotateToTheLRO:(id)sender {
    [_player rotate:SJOrientation_LandscapeRight animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        NSLog(@"================");
    }];
}

- (IBAction)disableAction:(UISwitch *)sender {
    _player.rotationManager.disabledAutorotation = sender.isOn;
    
    if ( sender.isOn ) {
        [_player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"已禁止自动旋转. 此时旋转设备, 播放器将不会自动旋转");
            make.textColor(UIColor.whiteColor);
        }] duration:3];
    }
    else {
        [_player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"已开启自动旋转. 此时旋转设备, 播放器将自动旋转");
            make.textColor(UIColor.whiteColor);
        }] duration:3];
    }
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_player play];
#ifdef DEBUG
    NSLog(@"AA: %d - %s", (int)__LINE__, __func__);
#endif
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_player pause];
#ifdef DEBUG
        NSLog(@"AA: %d - %s", (int)__LINE__, __func__);
#endif
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

#pragma mark - Test

- (IBAction)clickedPlayButton:(id)sender {
    self.player.assetURL = [NSURL URLWithString:[_textField.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
}

- (IBAction)push:(id)sender {
    SJViewController4 *vc = [SJViewController4.alloc initWithAsset:self.player.URLAsset];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)change:(id)sender {
    self.player.assetURL = SourceURL1;
}

@end


#pragma mark -
#import <SJRouter/SJRouter.h>
@interface SJRotationModeDemoViewController1 (RouteHandler)<SJRouteHandler>

@end

@implementation SJRotationModeDemoViewController1 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/rotationMode/vc1";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJRotationModeDemoViewController1 alloc] initWithNibName:@"SJRotationModeDemoViewController1" bundle:nil] animated:YES];
}

@end
