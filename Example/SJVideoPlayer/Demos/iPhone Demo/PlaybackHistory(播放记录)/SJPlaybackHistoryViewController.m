//
//  SJPlaybackHistoryViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/2/20.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJPlaybackHistoryViewController.h"
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <objc/message.h>
#import <SJBaseVideoPlayer/SJPlaybackRecordSaveHandler.h>
#import "SJPopPromptCustomView.h"
#import "SJVideoModel.h"
#import "SJSourceURLs.h"

///
/// 这里对 record 类扩展了一个属性, 在保存记录时会自动保存到数据库中
/// 你可以按照这种方式, 扩展一些自己的业务属性
///
@interface SJPlaybackRecord (SJTestExtended)
@property (nonatomic, copy, nullable) NSString *title;
@end

@implementation SJPlaybackRecord (SJTestExtended)
- (void)setTitle:(nullable NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable NSString *)title {
    return objc_getAssociatedObject(self, _cmd);
}
@end

#pragma mark -

@interface SJPlaybackHistoryViewController ()
@property (nonatomic, strong, nullable) SJVideoModel *media;
@property (nonatomic, strong, readonly) SJVideoPlayer *player;
@end

@implementation SJPlaybackHistoryViewController
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];

    // 请根据自己的业务模型来操作, 此处为模拟服务器返回的数据模型
    _media = SJVideoModel.alloc.init;
    _media.id = 50;
    _media.URL = SourceURL2;
    _media.mediaTitle = @"Hello world!";
    
    // 请根据自己的业务模型来操作, 此处为模拟当前登录的用户
    NSInteger userId = 50;

    {
        // 步骤1: 查询播放记录(如不存在, 将返回nil)
        SJPlaybackRecord *record = [SJPlaybackHistoryController.shared recordForMedia:_media.id user:userId mediaType:SJMediaTypeVideo];
        // - 不存在则创建
        if ( record == nil ) {
            record = SJPlaybackRecord.alloc.init;
            record.mediaId = _media.id;
            record.userId = userId;
            record.mediaType = SJMediaTypeVideo;
            // - 添加一些扩展属性, 便于开发者的业务逻辑开发
            record.title = _media.mediaTitle;
        }
        
        // 步骤2: 播放
        SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:_media.URL startPosition:record.position];
        // - 为将要播放的 asset 关联一个 record
        asset.record = record;
        // - 进行播放
        self.player.URLAsset = asset;
        // - 如果之前播放过, 这里提示一下用户从上次的位置进行播放
        if ( record.position != 0 ) {
            [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append([NSString stringWithFormat:@"从上次的位置 %@ 处开始播放", [self.player stringForSeconds:record.position]]);
                make.textColor(UIColor.whiteColor);
            }] duration:5];
        }
    }
    
    // 步骤3: 初始化保存管理类
    SJPlaybackRecordSaveHandler *handler = SJPlaybackRecordSaveHandler.shared;
    // 指定保存的时机, handler 将自动进行保存
    handler.events = SJPlayerEventMaskAll;
}

- (void)_setupViews {
    self.view.backgroundColor = UIColor.whiteColor;
    
    _player = SJVideoPlayer.player;
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(20);
        }
        make.left.right.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9/16.0);
    }];
}
@end


#pragma mark -


#import <SJRouter.h>

@interface SJPlaybackHistoryViewController (RouteHandler)<SJRouteHandler>

@end

@implementation SJPlaybackHistoryViewController (RouteHandler)
+ (NSString *)routePath {
    return @"playbackHistory";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:self.new animated:YES];
}
@end
