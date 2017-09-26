//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"
#import <UIKit/UIView.h>
#import <UIKit/UIColor.h>
#import <objc/message.h>
#import <Masonry/Masonry.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVMetadataItem.h>
#import "SJVideoPlayerPresentView.h"
#import "SJVideoPlayerControl.h"
#import "SJVideoPlayerStringConstant.h"
#import <SJPrompt/SJPrompt.h>
#import "SJVideoPlayerAssetCarrier.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerMoreSettingTwoSetting.h"
#import "SJVideoPlayerSettings.h"

#pragma mark -

@interface SJVideoPlayer ()

@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) SJVideoPlayerControl *control;
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) SJPrompt *prompt;

@property (nonatomic, strong, readonly) SJVideoPlayerSettings *settings;

@property (nonatomic, weak,   readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) NSInteger onViewTag;

@property (nonatomic, strong, readwrite) SJVideoPlayerAssetCarrier *assetCarrier;

@property (nonatomic, assign, readwrite) BOOL needJump;

@property (nonatomic, assign, readwrite) NSTimeInterval jumpedToTime;

@end


#pragma mark -

@interface SJVideoPlayer (DBNotifications)

- (void)_installNotifications;

- (void)_removeNotifications;

@end


#pragma mark -

@implementation SJVideoPlayer

@synthesize containerView = _containerView;
@synthesize control = _control;
@synthesize presentView = _presentView;
@synthesize prompt = _prompt;
@synthesize settings = _settings;


+ (instancetype)sharedPlayer {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self _setupView];
    [self _installNotifications];
    return self;
}

- (void)dealloc {
    [self _removeNotifications];
}

- (void)_setupView {
    [self.containerView addSubview:self.presentView];
    [self.presentView addSubview:self.control.view];
    
    [_presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [_control.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

// MARK: Setter

- (void)setClickedBackEvent:(void (^)(void))clickedBackEvent {
    _presentView.back = clickedBackEvent;
}

- (void)setAssetURL:(NSURL *)assetURL {
    if ( !assetURL ) return;
    _assetURL = assetURL;
    [self _prepareToPlay];
}

- (void)setPlaceholder:(UIImage *)placeholder {
    _placeholder = placeholder;
    _presentView.placeholderImage = placeholder;
}

- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath onViewTag:(NSInteger)tag {
    self.scrollView = scrollView;
    self.indexPath = indexPath;
    self.onViewTag = tag;
    [_control setScrollView:scrollView indexPath:indexPath];
}

// MARK: Public

- (UIView *)view {
    return self.containerView;
}

// MARK: Private

- (void)_prepareToPlay {
    
    [self stop];

    [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerPrepareToPlayNotification object:nil];
    
    [UIView animateWithDuration:0.25 animations:^{
        _containerView.alpha = 1.0;
    }];
    
    _assetCarrier = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:_assetURL];
    
    // control
    _control.assetCarrier = _assetCarrier;
    _control.delegate = _presentView;
    _control.prompt = self.prompt;
    __weak typeof(self) _self = self;
    _control.clickedLoadFiledBtnCallBlock = ^(SJVideoPlayerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.assetURL = self.assetURL;
    };
    
    // present
    _assetCarrier.presentViewSuperView = _containerView;
    _presentView.assetCarrier = _assetCarrier;
    _presentView.enabledRotation = YES;
}

// MARK: Lazy

- (UIView *)containerView {
    if ( _containerView ) return _containerView;
    _containerView = [UIView new];
    _containerView.backgroundColor = [UIColor blackColor];
    return _containerView;
}

- (SJVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [SJVideoPlayerPresentView new];
    return _presentView;
}

- (SJVideoPlayerControl *)control {
    if ( _control ) return _control;
    _control = [SJVideoPlayerControl new];
    return _control;
}

- (SJPrompt *)prompt {
    if ( _prompt ) return _prompt;
    _prompt = [SJPrompt promptWithPresentView:self.presentView];
    return _prompt;
}

- (SJVideoPlayerSettings *)settings {
    if ( _settings ) return _settings;
    _settings = [SJVideoPlayerSettings new];
    return _settings;
}

@end



#pragma mark -

@implementation SJVideoPlayer (Setting)

- (void)playerSettings:(void (^)(SJVideoPlayerSettings * _Nonnull))block {
    if ( block ) block(self.settings);
    [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification object:self.settings];
}

- (void)moreSettings:(void (^)(NSMutableArray<SJVideoPlayerMoreSetting *> * _Nonnull))block {
    NSMutableArray<SJVideoPlayerMoreSetting *> *moreSettingsM = [NSMutableArray new];
    if ( block ) block(moreSettingsM);
    [[NSNotificationCenter defaultCenter] postNotificationName:SJMoreSettingsNotification object:moreSettingsM];
}

@end



#pragma mark -

@implementation SJVideoPlayer (DBNotifications)

- (void)_installNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayFailedErrorNotification:) name:SJPlayerPlayFailedErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerScrollInNotification) name:SJPlayerScrollInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerScrollOutNotification) name:SJPlayerScrollOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerBeginPlayingNotification) name:SJPlayerBeginPlayingNotification object:nil];
}

- (void)_removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerPlayFailedErrorNotification:(NSNotification *)notifi {
    _error = notifi.object;
}

- (void)playerScrollInNotification {
    UIView *onView = nil;
    if ( [self.scrollView isKindOfClass:[UITableView class]] ) {
        UITableView *tableView = (UITableView *)self.scrollView;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.indexPath];
        onView = [cell.contentView viewWithTag:self.onViewTag];
    } else if ( [self.scrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
        onView = [cell.contentView viewWithTag:self.onViewTag];
    }
    if ( !onView ) return;
    self.containerView.alpha = 1;
    [self.containerView removeFromSuperview];
    [onView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (void)playerScrollOutNotification {
    self.containerView.alpha = 0.001;
}

- (void)playerBeginPlayingNotification {
    if ( !self.needJump ) return;
    [self jumpedToTime:self.jumpedToTime completionHandler:nil];
    self.needJump = NO;
    self.jumpedToTime = 0;
}

@end




#pragma mark -

@implementation SJVideoPlayer (Operation)

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(self.assetCarrier.playerItem.currentTime);
}

- (void)playWithURL:(NSURL *)playURL {
    self.assetURL = playURL;
}

- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time {
    self.assetURL = playURL;
    if ( 0 == time ) return;
    self.jumpedToTime = time;
    self.needJump = YES;
}

- (void)play {
    [_control play];
}

- (void)pause {
    [_control pause];
}

- (void)stopRotation {
    _presentView.enabledRotation = NO;
}

- (void)enableRotation {
    _presentView.enabledRotation = YES;
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler {
    [_control jumpedToTime:time completionHandler:completionHandler];
}

- (void)stop {
    _error = nil;
    _assetCarrier = nil;
    _indexPath = nil;
    _containerView.alpha = 0.001;
    [_presentView sjReset];
    [_control sjReset];
}

- (void)setRate:(float)rate {
    _control.rate = rate;
}

- (float)rate {
    return _control.rate;
}

- (UIImage *)screenshot {
    return [_presentView screenshot];
}

@end




#pragma mark -

@implementation SJVideoPlayer (Prompt)

- (void)showTitle:(NSString *)title {
    [self.prompt showTitle:title duration:1];
}

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration {
    [self.prompt showTitle:title duration:duration];
}

- (void)hiddenTitle {
    [self.prompt hidden];
}

@end

