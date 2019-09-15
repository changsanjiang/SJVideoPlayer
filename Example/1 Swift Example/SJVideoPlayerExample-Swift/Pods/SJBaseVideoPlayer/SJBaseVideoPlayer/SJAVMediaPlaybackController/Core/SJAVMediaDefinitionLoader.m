//
//  SJAVMediaDefinitionLoader.m
//  Pods
//
//  Created by BlueDancer on 2019/4/10.
//

#import "SJAVMediaDefinitionLoader.h"
#import "SJAVMediaPlayer.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaDefinitionLoader ()
@property (nonatomic, strong, nullable) SJAVMediaPlayer *player;
@property (nonatomic, strong) id<SJMediaModelProtocol> media;
@end

@implementation SJAVMediaDefinitionLoader
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}
- (instancetype)initWithMedia:(id<SJMediaModelProtocol>)media assetStatudDidChangeHandler:(void(^)(SJAVMediaDefinitionLoader *loader))handler {
    self = [super init];
    if ( !self ) return nil;
    _media = media;
    
    self.player = [SJAVMediaPlayerLoader loadPlayerForMedia:media];
    __weak typeof(self) _self = self;
    sjkvo_observe(self.player, @"sj_assetStatus", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( handler ) handler(self);
    });
    return self;
}
@end
NS_ASSUME_NONNULL_END
