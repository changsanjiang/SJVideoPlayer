//
//  SJAVMediaDefinitionPrepareStatusObserver.m
//  Pods
//
//  Created by 畅三江 on 2019/10/5.
//

#import "SJAVMediaDefinitionPrepareStatusObserver.h"
#import "SJAVMediaPresentView.h"
#import "SJAVMediaPlayer.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJAVMediaDefinitionPrepareStatusObserver
- (instancetype)initWithPlayer:(SJAVMediaPlayer *)player presentView:(SJAVMediaPresentView *)presentView {
    self = [super init];
    if ( self ) {
        _player = player;
        _presentView = presentView;
    
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(statusDidChange) name:SJAVMediaPlayerAssetStatusDidChangeNotification object:player];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(statusDidChange) name:SJAVMediaPresentViewReadyForDisplayDidChangeNotification object:presentView];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)statusDidChange {
    if ( _statusDidChangeExeBlock ) _statusDidChangeExeBlock(self);
}
@end
NS_ASSUME_NONNULL_END
