//
//  SJAVMediaPlayAssetSwitcher.m
//  Pods
//
//  Created by 畅三江 on 2019/1/13.
//

#import "SJAVMediaPlayAssetSwitcher.h"
#import "NSTimer+SJAssetAdd.h"
#import "SJAVMediaPlayAsset.h"
#import "SJAVMediaPresentView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayAssetSwitcher ()<SJAVMediaPlayAssetPropertiesObserverDelegate>
@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic, strong, nullable) id<SJAVPlayerLayerPresenterObserver> presenterObserver;

@property (nonatomic, strong, readonly) SJAVMediaPlayAsset *asset;
@property (nonatomic, strong, readonly) SJAVMediaPlayAssetPropertiesObserver *assetObserver;

@property (nonatomic, copy, readonly) CMTime(^currentTime)(void);
@property (nonatomic, copy, readonly) SJSwitchVideoDefinitionCompletionHandler completionHandler;
@end

@implementation SJAVMediaPlayAssetSwitcher

- (instancetype)initWithURL:(NSURL *)URL
                  presenter:(id<SJAVPlayerLayerPresenter>)presenter
                currentTime:(CMTime(^)(void))currentTime
          completionHandler:(SJSwitchVideoDefinitionCompletionHandler)completionHandler {
    self = [super init];
    if ( self ) {
        _URL = URL;
        _presenter = presenter;
        _currentTime = currentTime;
        _completionHandler = completionHandler;
        
        // create asset
        _asset = [[SJAVMediaPlayAsset alloc] initWithURL:URL];
        _assetObserver = [[SJAVMediaPlayAssetPropertiesObserver alloc] initWithPlayerAsset:_asset];
        _assetObserver.delegate = self;
    }
    return self;
}

- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus {
    switch ( playerItemStatus ) {
        case AVPlayerItemStatusUnknown: break;
        case AVPlayerItemStatusReadyToPlay: {
            [self _seekToCurrentTime];
        }
            break;
        case AVPlayerItemStatusFailed: {
            if ( _completionHandler ) _completionHandler(self, NO, nil);
        }
            break;
    }
}

- (void)_seekToCurrentTime {
    SJAVMediaPlayAsset *newAsset = _asset;
    AVPlayerItem *newPlayerItem = newAsset.playerItem;
    __weak typeof(self) _self = self;
    [newPlayerItem seekToTime:self.currentTime() toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !finished ) {
            [self _switchFailed];
        }
        else {
            switch ( UIApplication.sharedApplication.applicationState ) {
                case UIApplicationStateActive:
                case UIApplicationStateInactive: {
                    self.presenter.player = newAsset.player;
                    self.presenterObserver = [self.presenter getObserver];
                    self.presenterObserver.isReadyForDisplayExeBlock = ^(id<SJAVPlayerLayerPresenter>  _Nonnull presenter) {
                        __strong typeof(_self) self = _self;
                        if ( !self ) return ;
                        [self _switchFinished];
                    };
                }
                    break;
                case UIApplicationStateBackground: {
                    [self _switchFinished];
                }
                    break;
            }
        }
    }];
}

- (void)_switchFailed {
    if ( _completionHandler ) _completionHandler(self, NO, nil);
}

- (void)_switchFinished {
    if ( _completionHandler ) _completionHandler(self, YES, _asset);
}
@end
NS_ASSUME_NONNULL_END
