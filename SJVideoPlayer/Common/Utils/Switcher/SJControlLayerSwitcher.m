//
//  SJControlLayerSwitcher.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJControlLayerSwitcher.h"

NS_ASSUME_NONNULL_BEGIN
SJControlLayerIdentifier SJControlLayer_Uninitialized = LONG_MAX;
static NSString *const SJPlayerSwitchControlLayerUserInfoKey = @"SJPlayerSwitchControlLayerUserInfoKey";
static NSNotificationName const SJPlayerWillBeginSwitchControlLayerNotification = @"SJPlayerWillBeginSwitchControlLayerNotification";
static NSNotificationName const SJPlayerDidEndSwitchControlLayerNotification = @"SJPlayerDidEndSwitchControlLayerNotification";

@interface SJControlLayerSwitcherObsrever : NSObject<SJControlLayerSwitcherObsrever>
- (instancetype)initWithSwitcher:(id<SJControlLayerSwitcher>)switcher;
@end

@implementation SJControlLayerSwitcherObsrever
@synthesize playerWillBeginSwitchControlLayer = _playerWillBeginSwitchControlLayer;
@synthesize playerDidEndSwitchControlLayer = _playerDidEndSwitchControlLayer;
- (instancetype)initWithSwitcher:(id<SJControlLayerSwitcher>)switcher {
    self = [super init];
    if ( !self ) return nil; 
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willBeginSwitchControlLayer:) name:SJPlayerWillBeginSwitchControlLayerNotification object:switcher];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didEndSwitchControlLayer:) name:SJPlayerDidEndSwitchControlLayerNotification object:switcher];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)willBeginSwitchControlLayer:(NSNotification *)note {
    if ( self.playerWillBeginSwitchControlLayer ) self.playerWillBeginSwitchControlLayer(note.object, note.userInfo[SJPlayerSwitchControlLayerUserInfoKey]);
}

- (void)didEndSwitchControlLayer:(NSNotification *)note {
    if ( self.playerDidEndSwitchControlLayer ) self.playerDidEndSwitchControlLayer(note.object, note.userInfo[SJPlayerSwitchControlLayerUserInfoKey]);
}
@end

@interface SJControlLayerSwitcher ()
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) NSMutableDictionary *map;
@end

@implementation SJControlLayerSwitcher
@synthesize currentIdentifier = _currentIdentifier;
@synthesize previousIdentifier = _previousIdentifier;
@synthesize delegate = _delegate;
@synthesize resolveControlLayer = _resolveControlLayer;

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
}
#endif

- (instancetype)initWithPlayer:(__weak SJBaseVideoPlayer *)videoPlayer {
    self = [super init];
    if ( !self ) return nil;
    _videoPlayer = videoPlayer;
    _map = [NSMutableDictionary dictionary];
    _previousIdentifier = SJControlLayer_Uninitialized;
    _currentIdentifier = SJControlLayer_Uninitialized;
    return self;
}

- (id<SJControlLayerSwitcherObsrever>)getObserver {
    return [[SJControlLayerSwitcherObsrever alloc] initWithSwitcher:self];
}

- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier {
    id<SJControlLayer> _Nullable oldValue = (id)self.videoPlayer.controlLayerDataSource;
    id<SJControlLayer> _Nullable newValue = [self controlLayerForIdentifier:identifier];
    if ( !newValue && _resolveControlLayer ) {
        newValue = _resolveControlLayer(identifier);
        [self addControlLayerForIdentifier:identifier lazyLoading:^id<SJControlLayer> _Nonnull(SJControlLayerIdentifier identifier) {
            return newValue;
        }];
    }
    NSParameterAssert(newValue); if ( !newValue ) return;
    if ( oldValue == newValue )
        return;
    
    if ( [self.delegate respondsToSelector:@selector(switcher:shouldSwitchToControlLayer:)] ) {
        if ( ![self.delegate switcher:self shouldSwitchToControlLayer:identifier] )
            return;
    }
    
    // - begin -
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlayerWillBeginSwitchControlLayerNotification object:self userInfo:newValue?@{SJPlayerSwitchControlLayerUserInfoKey:newValue}:nil];

    [oldValue exitControlLayer];
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;

    // update identifiers
    _previousIdentifier = _currentIdentifier;
    _currentIdentifier = identifier;

    _videoPlayer.controlLayerDataSource = newValue;
    _videoPlayer.controlLayerDelegate = newValue;
    [newValue restartControlLayer];
    
    // - end -
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlayerDidEndSwitchControlLayerNotification object:self userInfo:@{SJPlayerSwitchControlLayerUserInfoKey:newValue}];
}

- (BOOL)switchToPreviousControlLayer {
    if ( self.previousIdentifier == SJControlLayer_Uninitialized ) return NO;
    if ( !self.videoPlayer ) return NO;
    [self switchControlLayerForIdentitfier:self.previousIdentifier];
    return YES;
}

- (void)addControlLayerForIdentifier:(SJControlLayerIdentifier)identifier
                         lazyLoading:(nullable id<SJControlLayer>(^)(SJControlLayerIdentifier identifier))loading {
#ifdef DEBUG
    NSParameterAssert(loading);
#endif
    
    [self.map setObject:loading forKey:@(identifier)];
    if ( self.currentIdentifier == identifier ) {
        [self switchControlLayerForIdentitfier:identifier];
    }
}

- (void)deleteControlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    [self.map removeObjectForKey:@(identifier)];
}

- (nullable id<SJControlLayer>)controlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    id _Nullable result = self.map[@(identifier)];
    if ( !result )
        return nil;
    
    // loaded
    if ( [result conformsToProtocol:@protocol(SJControlLayer)] ) {
        return result;
    }
    
    // lazy loading
    id<SJControlLayer> controlLayer = ((id<SJControlLayer>(^)(SJControlLayerIdentifier))result)(identifier);
    [self.map setObject:controlLayer forKey:@(identifier)];
    return controlLayer;
}

- (BOOL)containsControlLayer:(SJControlLayerIdentifier)identifier {
    return self.map[@(identifier)] != nil;
}
@end
NS_ASSUME_NONNULL_END
