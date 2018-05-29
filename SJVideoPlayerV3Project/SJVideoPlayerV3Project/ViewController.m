//
//  ViewController.m
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "ViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>

@interface ViewController ()

@property (nonatomic, strong, readonly) SJVideoPlayer *videoPlayer;

@end

@implementation ViewController
@synthesize videoPlayer = _videoPlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(8);
        make.leading.trailing.offset(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(9/16.0f);
    }];
    
    _videoPlayer.assetURL = [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/usertrend/166162-1513873330.mp4"];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (SJVideoPlayer *)videoPlayer {
    if ( _videoPlayer ) return _videoPlayer;
    _videoPlayer = [SJVideoPlayer player];
    return _videoPlayer;
}

@end
