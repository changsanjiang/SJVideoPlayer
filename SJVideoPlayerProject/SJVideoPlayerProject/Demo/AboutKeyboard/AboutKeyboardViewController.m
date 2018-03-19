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
@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation AboutKeyboardViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( !self ) return nil;
    _orientation = UIInterfaceOrientationPortrait;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _videoPlayer = [SJVideoPlayer player];
    [self.view addSubview:_videoPlayer.view];
    _textView = [SJUITextViewFactory textViewWithTextColor:[UIColor blackColor] backgroundColor:[UIColor greenColor] font:[UIFont boldSystemFontOfSize:14]];
    _textView.text = @"Please Enter...";
    [_textView becomeFirstResponder];
    [_videoPlayer.controlLayerDataSource.controlView addSubview:_textView];
    
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo(_videoPlayer.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.offset(200);
        make.height.offset(30);
    }];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _videoPlayer.assetURL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
    });

    
    __weak typeof(self) _self = self;
    _videoPlayer.willRotateScreen = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.textView resignFirstResponder];       // text view resignFirstResponder.
    };
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - about keyboard orientation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return _videoPlayer.currentOrientation;
}

@end
