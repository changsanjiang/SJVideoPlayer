//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"

#import <UIKit/UIView.h>

#import <AVFoundation/AVAsset.h>

#import <AVFoundation/AVPlayerItem.h>

#import <AVFoundation/AVPlayer.h>

#import "SJVideoPlayerPresentView.h"

#import "SJVideoPlayerControl.h"

#import <Masonry/Masonry.h>

#import <AVFoundation/AVMetadataItem.h>

#import "SJVideoPlayerStringConstant.h"

#import "SJVideoPlayerPrompt.h"

#import <objc/message.h>

#import <UIKit/UIColor.h>

// MARK: 通知处理

@interface SJVideoPlayer (DBNotifications)

- (void)_SJVideoPlayerInstallNotifications;

- (void)_SJVideoPlayerRemoveNotifications;

@end



@interface SJVideoPlayer ()

@property (nonatomic, strong, readwrite) AVAsset *asset;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) AVPlayer *player;


@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) SJVideoPlayerControl *control;
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) SJVideoPlayerPrompt *prompt;

@property (nonatomic, strong, readonly) SJVideoPlayerSettings *settings;
@property (nonatomic, strong, readonly) NSMutableArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, weak, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) NSInteger onViewTag;

@end


@implementation SJVideoPlayer

@synthesize containerView = _containerView;
@synthesize control = _control;
@synthesize presentView = _presentView;
@synthesize prompt = _prompt;
@synthesize settings = _settings;
@synthesize moreSettings = _moreSettings;


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
    [self setupView];
    [self _SJVideoPlayerInstallNotifications];
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerRemoveNotifications];
}

- (void)setupView {
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

- (void)setClickedBackEvent:(void (^)())clickedBackEvent {
    _presentView.back = clickedBackEvent;
}

- (void)setAssetURL:(NSURL *)assetURL {
    _assetURL = assetURL;
    [self _sjVideoPlayerPrepareToPlay];
}

- (void)setPlaceholder:(UIImage *)placeholder {
    _placeholder = placeholder;
    _presentView.placeholderImage = placeholder;
}

- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath onViewTag:(NSInteger)tag {
    self.scrollView = scrollView;
    self.indexPath = indexPath;
    self.onViewTag = tag;
    [_control setScrollView:scrollView indexPath:indexPath onViewTag:tag];
}

// MARK: Public

- (UIView *)view {
    return self.containerView;
}

- (void)playerSettings:(void (^)(SJVideoPlayerSettings * _Nonnull))block {
    if ( block ) block(self.settings);
    [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification object:self.settings];
}

- (void)moreSettings:(void (^)(NSMutableArray<SJVideoPlayerMoreSetting *> * _Nonnull))block {
    [self resetMoreSettings];
    if ( block ) block(self.moreSettings);
    [[NSNotificationCenter defaultCenter] postNotificationName:SJMoreSettingsNotification object:self.moreSettings];
}

- (void)resetMoreSettings {
    [self.moreSettings removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:SJResetMoreSettingsNotification object:self.moreSettings];
}

// MARK: Private

- (void)_sjVideoPlayerPrepareToPlay {
    
    [UIView animateWithDuration:0.25 animations:^{
        _containerView.alpha = 1.0;
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerPrepareToPlayNotification object:nil];
    
    _error = nil;
    
    // initialize
    _asset = [AVAsset assetWithURL:_assetURL];
    
    // loaded keys
    NSArray <NSString *> *keys =
    @[@"tracks",
      @"duration",];
    _playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    // control
    [_control setAsset:_asset playerItem:_playerItem player:_player];
    
    // present
    [_presentView setPlayer:_player asset:_asset superv:_containerView];
    
    _control.delegate = _presentView;
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

- (SJVideoPlayerPrompt *)prompt {
    if ( _prompt ) return _prompt;
    _prompt = [SJVideoPlayerPrompt promptWithPresentView:self.presentView];
    return _prompt;
}

- (SJVideoPlayerSettings *)settings {
    if ( _settings ) return _settings;
    _settings = [SJVideoPlayerSettings new];
    return _settings;
}

- (NSMutableArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    if ( _moreSettings ) return _moreSettings;
    _moreSettings = [NSMutableArray new];
    return _moreSettings;
}

@end




// MARK: 通知处理

@implementation SJVideoPlayer (DBNotifications)

// MARK: 通知安装

- (void)_SJVideoPlayerInstallNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayFailedErrorNotification:) name:SJPlayerPlayFailedErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerScrollInNotification) name:SJPlayerScrollInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerScrollOutNotification) name:SJPlayerScrollOutNotification object:nil];
}

- (void)_SJVideoPlayerRemoveNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerPlayFailedErrorNotification:(NSNotification *)notifi {
    _error = notifi.object;
}

- (void)playerScrollInNotification {
    self.containerView.alpha = 1;
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.indexPath];
        UIView *onView = [cell.contentView viewWithTag:self.onViewTag];
        [self.containerView removeFromSuperview];
        [onView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
        UIView *onView = [cell.contentView viewWithTag:self.onViewTag];
        [self.containerView removeFromSuperview];
        [onView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
}

- (void)playerScrollOutNotification {
    self.containerView.alpha = 0.001;
}

@end






@implementation SJVideoPlayer (Operation)

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(_playerItem.currentTime);
}

- (void)play {
    [_control play];
}

- (void)pause {
    [_control pause];
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler {
    [_control jumpedToTime:time completionHandler:completionHandler];
}

- (void)stop {
    [_presentView sjReset];
    [_control sjReset];
}

- (void)setRate:(float)rate {
    _control.rate = rate;
}

- (float)rate {
    return _control.rate;
}

- (UIImage *)screenShot {
    return [_presentView screenShot];
}

@end






@implementation SJVideoPlayer (Prompt)

- (void)showTitle:(NSString *)title {
    [self.prompt showTitle:title duration:1];
}

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration {
    [self.prompt showTitle:title duration:duration];
}

@end


@implementation SJVideoPlayerSettings@end


@implementation SJVideoPlayerMoreSetting

+ (UIColor *)titleColor {
    UIColor *color = objc_getAssociatedObject(self, _cmd);
    if ( color ) return color;
    color = [UIColor whiteColor];
    [self setTitleColor:color];
    return color;
}

+ (void)setTitleColor:(UIColor *)titleColor {
    objc_setAssociatedObject(self, @selector(titleColor), titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (float)titleFontSize {
    float fontSize = [objc_getAssociatedObject(self, _cmd) floatValue];
    if ( 0 != fontSize ) return fontSize;
    fontSize = 12;
    [self setTitleFontSize:fontSize];
    return fontSize;
}

+ (void)setTitleFontSize:(float)titleFontSize {
    objc_setAssociatedObject(self, @selector(titleFontSize), @(titleFontSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)setTwoTitleFontSize:(float)twoTitleFontSize {
    objc_setAssociatedObject(self, @selector(twoTitleFontSize), @(twoTitleFontSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (float)twoTitleFontSize {
    float fontSize = [objc_getAssociatedObject(self, _cmd) floatValue];
    if ( 0 != fontSize ) return fontSize;
    fontSize = 14;
    [self setTwoTitleFontSize:fontSize];
    return fontSize;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block {
    return [self initWithTitle:title image:image showTowSetting:NO twoSettingTitle:@"" twoSettingItems:@[] clickedExeBlock:block];
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image showTowSetting:(BOOL)showTowSetting twoSettingTitle:(NSString *)twoSettingTitle twoSettingItems:(NSArray<SJVideoPlayerMoreSettingTwoSetting *> *)items clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block {
    self = [super init];
    if ( !self ) return self;
    self.title = title;
    self.image = image;
    self.twoSettingTitle = twoSettingTitle;
    self.showTowSetting = showTowSetting;
    self.twoSettingItems = items;
    self.clickedExeBlock = block;
    return self;
}

@end


@implementation SJVideoPlayerMoreSettingTwoSetting @end
