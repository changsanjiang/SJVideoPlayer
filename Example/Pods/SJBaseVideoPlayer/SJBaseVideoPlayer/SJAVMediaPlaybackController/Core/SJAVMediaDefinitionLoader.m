//
//  SJAVMediaDefinitionLoader.m
//  Pods
//
//  Created by BlueDancer on 2019/4/10.
//

#import "SJAVMediaDefinitionLoader.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaDefinitionLoader ()
@property (nonatomic, strong) id<SJMediaModelProtocol> media;
@property (nonatomic, strong, nullable) id<SJAVMediaPlayerProtocol> player;
@property (nonatomic, copy, nullable) void(^handler)(SJAVMediaDefinitionLoader *loader, AVPlayerItemStatus status);
@end

@implementation SJAVMediaDefinitionLoader
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}
- (instancetype)initWithMedia:(id<SJMediaModelProtocol>)media handler:(void (^)(SJAVMediaDefinitionLoader * _Nonnull, AVPlayerItemStatus))handler {
    self = [super init];
    if ( !self ) return nil;
    _media = media;
    _handler = handler;
    [self sj_observeWithNotification:SJAVMediaItemStatusDidChangeNotification target:nil usingBlock:^(SJAVMediaDefinitionLoader *self, NSNotification * _Nonnull note) {
        id<SJAVMediaPlayerProtocol> player = note.object;
        if ( player == self.player ) {
            [self _playerItemStatusDidChange];
        }
    }];
    
    __weak typeof(self) _self = self;
    [SJAVMediaPlayerLoader loadPlayerForMedia:media completionHandler:^(id<SJMediaModelProtocol>  _Nonnull media, id<SJAVMediaPlayerProtocol>  _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.player = player;
        [self _playerItemStatusDidChange];
    }];
    return self;
}

- (void)_playerItemStatusDidChange {
    AVPlayerItemStatus status = [_player sj_getAVPlayerItemStatus];
    if ( _handler ) _handler(self, status);
}
@end
NS_ASSUME_NONNULL_END
