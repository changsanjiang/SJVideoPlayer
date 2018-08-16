//
//  AboutKeyboardViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/15.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "AboutKeyboardViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>

@interface AboutKeyboardViewController ()

@property (nonatomic, strong) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation AboutKeyboardViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( !self ) return nil;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _videoPlayer = [SJVideoPlayer player];
    [self.view addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.equalTo(self->_videoPlayer.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    _videoPlayer.hideBackButtonWhenOrientationIsPortrait = YES;
    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]];
    _videoPlayer.URLAsset.title = @"Test Test";
    _videoPlayer.URLAsset.alwaysShowTitle = YES;
    
    __weak typeof(self) _self = self;
    _videoPlayer.viewWillRotateExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.textView resignFirstResponder];
    };
    
    _videoPlayer.controlLayerAppearStateChanged = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL state) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.textView.isFirstResponder ) [self.textView resignFirstResponder];
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // test test test test test test test test test test test
    // test test test test test test test test test test test
    // test test test test test test test test test test test
    // test test test test test test test test test test test
    // test test test test test test test test test test test
    _textView = [SJUITextViewFactory textViewWithTextColor:[UIColor blackColor] backgroundColor:[UIColor greenColor] font:[UIFont boldSystemFontOfSize:14]];
    _textView.text = @"Please Enter...";
    [_textView becomeFirstResponder];
    [_videoPlayer.controlLayerDataSource.controlView addSubview:_textView];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.offset(200);
        make.height.offset(30);
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
@end
