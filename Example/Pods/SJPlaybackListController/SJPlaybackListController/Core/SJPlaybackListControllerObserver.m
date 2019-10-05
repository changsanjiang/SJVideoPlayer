//
//  SJPlaybackListControllerObserver.m
//  SJPlaybackListController
//
//  Created by 畅三江 on 2019/1/23.
//

#import "SJPlaybackListControllerObserver.h"
NS_ASSUME_NONNULL_BEGIN
@implementation SJPlaybackListControllerObserver {
    id _prepareToPlayToken;
    id _playbackModeDidChangeToken;
    id _listDidChangeToken;
}

@synthesize prepareToPlayMediaExeBlock = _prepareToPlayMediaExeBlock;
@synthesize playbackModeDidChangeExdBlock = _playbackModeDidChangeExdBlock;
@synthesize listDidChangeExeBlock = _listDidChangeExeBlock;

- (instancetype)initWithListController:(id<SJPlaybackListController>)controller {
    self = [super init];
    if ( !self ) return nil;
    __weak typeof(self) _self = self;
    _prepareToPlayToken = [NSNotificationCenter.defaultCenter addObserverForName:SJPlaybackListControllerPrepareToPlayMediaNotification object:controller queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( self.prepareToPlayMediaExeBlock ) self.prepareToPlayMediaExeBlock(note.object);
        });
    }];
    _playbackModeDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:SJPlaybackListControllerPlaybackModeDidChangeNotification object:controller queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( self.playbackModeDidChangeExdBlock ) self.playbackModeDidChangeExdBlock(note.object);
        });
    }];
    _listDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:SJPlaybackListControllerListDidChangeNotification object:controller queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( self.listDidChangeExeBlock ) self.listDidChangeExeBlock(note.object);
        });
    }];
    return self;
}
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:_prepareToPlayToken];
    [NSNotificationCenter.defaultCenter removeObserver:_playbackModeDidChangeToken];
    [NSNotificationCenter.defaultCenter removeObserver:_listDidChangeToken];
}
@end
NS_ASSUME_NONNULL_END
