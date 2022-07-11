//
//  SJDanmakuPopupController.m
//  Pods
//
//  Created by 畅三江 on 2019/11/12.
//

#import "SJDanmakuPopupController.h"
#import "CALayer+SJBaseVideoPlayerExtended.h"
#import "NSTimer+SJAssetAdd.h"

#if __has_include(<SJUIKit/SJRunLoopTaskQueue.h>)
#import <SJUIKit/SJQueue.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#else
#import "SJQueue.h"
#import "NSAttributedString+SJMake.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif


NS_ASSUME_NONNULL_BEGIN

#define POINT_SPEED_FAST (0.01)

static NSNotificationName const SJDanmakuPopupControllerOnDisabledChangedNotification = @"SJDanmakuPopupControllerOnDisabledChangedNotification";
static NSNotificationName const SJDanmakuPopupControllerOnPausedChangedNotification = @"SJDanmakuPopupControllerOnPausedChangedNotification";
static NSNotificationName const SJDanmakuPopupControllerWillDisplayItemNotification = @"SJDanmakuPopupControllerWillDisplayItemNotification";
static NSNotificationName const SJDanmakuPopupControllerDidEndDisplayingItemNotification = @"SJDanmakuPopupControllerDidEndDisplayingItemNotification";
static NSString *const SJDanmakuItemUserInfoKey = @"danmakuItem";

#pragma mark -

@protocol SJDanmakuViewDataSource <NSObject>
@property (nonatomic, copy, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) __kindof UIView *customView;
@property (nonatomic, readonly) CGSize contentSize;
@end

@interface SJDanmakuView : UILabel
@property (nonatomic, strong, nullable) id<SJDanmakuViewDataSource> dataSource;
@end

@interface SJDanmakuView ()
@property (nonatomic, strong, nullable) UIView *customView;
@end

@implementation SJDanmakuView
- (CGSize)intrinsicContentSize {
    return _dataSource.contentSize;
}

- (void)setDataSource:(nullable id<SJDanmakuViewDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        
        if ( _customView != nil ) {
            [_customView removeFromSuperview];
            _customView = nil;
        }
        
        if ( dataSource.content.length != 0 ) {
            self.attributedText = dataSource.content;
        }
        else {
            self.attributedText = nil;
            _customView = dataSource.customView;
            _customView.frame = CGRectMake(0, 0, dataSource.contentSize.width, dataSource.contentSize.height);
            [self addSubview:dataSource.customView];
        }
    }
}
@end

#pragma mark -

@interface SJDanmakuViewModel : NSObject<SJDanmakuViewDataSource>
- (instancetype)initWithItem:(id<SJDanmakuItem>)item;

@property (nonatomic, copy, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) __kindof UIView *customView;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval nextItemStartTime;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) CGFloat points;
@end

@implementation SJDanmakuViewModel
- (instancetype)initWithItem:(id<SJDanmakuItem>)item {
    self = [super init];
    if ( self ) {
        if ( item.content.length != 0 ) {
            _content = item.content.copy;
            _contentSize = [_content sj_textSize];
        }
        else {
            _customView = item.customView;
            if ( CGSizeEqualToSize(CGSizeZero, _contentSize) )
                _contentSize = [item.customView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            else
                _contentSize = item.customView.bounds.size;
        }
    }
    return self;
}
@end

#pragma mark -

@interface SJDanmakuViewReusablePool : NSObject
+ (instancetype)pool;
@property (nonatomic) NSInteger size;
- (SJDanmakuView *)dequeueReusableView;
- (void)addView:(SJDanmakuView *)view;
@end

@implementation SJDanmakuViewReusablePool {
    NSMutableArray<SJDanmakuView *> *_m;
}
+ (instancetype)pool {
    return SJDanmakuViewReusablePool.alloc.init;
}
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _size = 5;
        _m = [NSMutableArray.alloc initWithCapacity:_size];
    }
    return self;
}
- (SJDanmakuView *)dequeueReusableView {
    if ( _m.count == 0 ) {
        [_m addObject:[SJDanmakuView.alloc initWithFrame:CGRectZero]];
    }
    
    SJDanmakuView *last = _m.lastObject;
    [_m removeLastObject];
    return last;
}
- (void)addView:(SJDanmakuView *)view {
    if ( view != nil && _m.count < _size ) {
        [_m addObject:view];
    }
}
@end


#pragma mark -

@protocol SJDanmakuClockDelegate;

@interface SJDanmakuClock : NSObject
+ (instancetype)clockWithDelegate:(id<SJDanmakuClockDelegate>)delegate;
@property (nonatomic, weak, nullable) id<SJDanmakuClockDelegate> delegate;
@property (nonatomic, readonly) NSTimeInterval time;

@property (nonatomic, readonly, getter=isPaused) BOOL paused;
- (void)pause;
- (void)resume;
@end

@protocol SJDanmakuClockDelegate <NSObject>
- (void)clock:(SJDanmakuClock *)clock onTimeUpdated:(NSTimeInterval)time;
- (void)clock:(SJDanmakuClock *)clock onPausedChanged:(BOOL)isPaused;
@end

@interface SJDanmakuClock ()
@property (nonatomic) NSTimeInterval time;
@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic, getter=isPaused) BOOL paused;
@end
@implementation SJDanmakuClock
+ (instancetype)clockWithDelegate:(id<SJDanmakuClockDelegate>)delegate {
    SJDanmakuClock *clock = SJDanmakuClock.alloc.init;
    clock.delegate = delegate;
    return clock;
}
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _paused = YES;
    }
    return self;
}
- (void)pause {
    if ( _paused == NO ) {
        [_timer invalidate];
        _timer = nil;
        self.paused = YES;
    }
}
- (void)resume {
    if ( _paused == YES ) {
        __weak typeof(self) _self = self;
        _timer = [NSTimer assetAdd_timerWithTimeInterval:0.1 block:^(NSTimer *timer) {
            __strong typeof(_self) self = _self;
            if ( !self ) {
                [timer invalidate];
                return;
            }
            self.time += timer.timeInterval;
        } repeats:YES];
        [_timer assetAdd_fire];
        [NSRunLoop.mainRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
        self.paused = NO;
    }
}
- (void)setTime:(NSTimeInterval)time {
    _time = time;
    [self.delegate clock:self onTimeUpdated:time];
}

- (void)setPaused:(BOOL)paused {
    _paused = paused;
    [self.delegate clock:self onPausedChanged:paused];
}
@end

#pragma mark -

@interface SJDanmakuTrackView : UIView
@end

@implementation SJDanmakuTrackView
@end

#pragma mark -

@interface SJDanmakuTrackConfiguration ()
- (CGFloat)rateForTrackAtIndex:(NSInteger)index;
- (CGFloat)topMarginForTrackAtIndex:(NSInteger)index;
- (CGFloat)itemSpacingForTrackAtIndex:(NSInteger)index;
- (CGFloat)heightForTrackAtIndex:(NSInteger)index;
@end

#pragma mark -

@interface SJDanmakuTrack : NSObject
- (instancetype)initWithPool:(SJDanmakuViewReusablePool *)pool;
@property (nonatomic, strong, readonly) SJDanmakuViewReusablePool *pool;
@property (nonatomic, strong, readonly) SJDanmakuTrackView *view;

@property (nonatomic, strong, readonly, nullable) SJDanmakuViewModel *last;
- (void)pause;
- (void)resume;
- (void)clear;
- (void)fire:(SJDanmakuViewModel *)viewModel stoppedCallback:(void(^)(void))completion;
@end

@implementation SJDanmakuTrack
- (instancetype)initWithPool:(SJDanmakuViewReusablePool *)pool {
    self = [super init];
    if ( self ) {
        _pool = pool;
        _view = [SJDanmakuTrackView.alloc initWithFrame:CGRectZero];
    }
    return self;
}

- (nullable SJDanmakuViewModel *)last {
    __auto_type view = (SJDanmakuView *)_view.subviews.lastObject;
    return view.dataSource;
}

- (void)pause {
    for ( UIView *subview in _view.subviews ) {
        [subview.layer pauseAnimation];
    }
}

- (void)resume {
    for ( UIView *subview in _view.subviews ) {
        [subview.layer resumeAnimation];
    }
}

- (void)clear {
    [_view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        [view.layer removeAllAnimations];
        [view removeFromSuperview];
    }];
}

- (void)fire:(SJDanmakuViewModel *)viewModel stoppedCallback:(void(^)(void))completion {
    SJDanmakuView *danmakuView = [_pool dequeueReusableView];
    danmakuView.dataSource = viewModel;
    [danmakuView.layer removeAllAnimations];
    [_view addSubview:danmakuView];
    
    CGRect frame = CGRectZero;
    CGRect bounds = _view.bounds;
    frame.origin.x = bounds.size.width;
    frame.origin.y = (CGRectGetHeight(bounds) - viewModel.contentSize.height) * 0.5;
    frame.size = viewModel.contentSize;
    danmakuView.frame = frame;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-viewModel.points, 0, 0)];
    animation.duration = viewModel.duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [danmakuView.layer addAnimation:animation forKey:@"anim"];
    __weak typeof(self) _self = self;
    __weak typeof(danmakuView) _danmakuView = danmakuView;
    [danmakuView.layer addAnimation:animation stopHandler:^(CAAnimation * _Nonnull anim, BOOL isFinished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [_danmakuView removeFromSuperview];
        [self.pool addView:_danmakuView];
        if ( completion ) completion();
    }];
}
@end

#pragma mark -

@protocol SJDanmakuLayoutContainerViewDelegate;

@interface SJDanmakuLayoutContainerView : UIView
- (instancetype)initWithDelegate:(id<SJDanmakuLayoutContainerViewDelegate>)delegate;
@property (nonatomic, weak, nullable) id<SJDanmakuLayoutContainerViewDelegate> delegate;
@end

@protocol SJDanmakuLayoutContainerViewDelegate <NSObject>
- (void)layoutContainerView:(SJDanmakuLayoutContainerView *)view boundsDidChange:(CGRect)bounds previousBounds:(CGRect)previousBounds;
@end

@implementation SJDanmakuLayoutContainerView {
    CGRect _previousBounds;
}

- (instancetype)initWithDelegate:(id<SJDanmakuLayoutContainerViewDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _delegate = delegate;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    if ( !CGRectEqualToRect(bounds, _previousBounds) ) {
        if ( [self.delegate respondsToSelector:@selector(layoutContainerView:boundsDidChange:previousBounds:)] ) {
            [self.delegate layoutContainerView:self boundsDidChange:bounds previousBounds:_previousBounds];
        }
    }
    _previousBounds = bounds;
}
@end

#pragma mark -

@interface SJDanmakuPopupControllerObserver : NSObject<SJDanmakuPopupControllerObserver>
- (instancetype)initWithController:(SJDanmakuPopupController *)controller;
@end

@implementation SJDanmakuPopupControllerObserver
@synthesize onDisabledChanged = _onDisabledChanged;
@synthesize onPausedChanged = _onPausedChanged;
@synthesize willDisplayItem = _willDisplayItem;
@synthesize didEndDisplayingItem = _didEndDisplayingItem;
- (instancetype)initWithController:(SJDanmakuPopupController *)controller {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_onPausedChanged:) name:SJDanmakuPopupControllerOnPausedChangedNotification object:controller];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_disabledDidChange:) name:SJDanmakuPopupControllerOnDisabledChangedNotification object:controller];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_willDisplayItem:) name:SJDanmakuPopupControllerWillDisplayItemNotification object:controller];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didEndDisplayingItem:) name:SJDanmakuPopupControllerDidEndDisplayingItemNotification object:controller];
    }
    return self;
}
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)_onPausedChanged:(NSNotification *)note {
    if ( _onPausedChanged ) _onPausedChanged(note.object);
}
- (void)_disabledDidChange:(NSNotification *)note {
    if ( _onDisabledChanged ) _onDisabledChanged(note.object);
}
- (void)_willDisplayItem:(NSNotification *)note {
    if ( _willDisplayItem ) _willDisplayItem(note.object, note.userInfo[SJDanmakuItemUserInfoKey]);
}
- (void)_didEndDisplayingItem:(NSNotification *)note {
    if ( _didEndDisplayingItem ) _didEndDisplayingItem(note.object, note.userInfo[SJDanmakuItemUserInfoKey]);
}
@end
 
#pragma mark -


@interface SJDanmakuPopupController ()<SJDanmakuLayoutContainerViewDelegate, SJDanmakuClockDelegate> {
    SJQueue<id<SJDanmakuItem>> *_queue;
    SJDanmakuClock *_clock;
}
@property (nonatomic, strong, readonly) SJDanmakuViewReusablePool *reusablePool;
@property (nonatomic, strong, readonly) NSMutableArray<SJDanmakuTrack *> *tracks;
@property (nonatomic, getter=isPaused) BOOL paused;
@end

@implementation SJDanmakuPopupController
@synthesize view = _view;
static CGFloat SJScreenMaxWidth;
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SJScreenMaxWidth = MAX(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
    });
}

- (instancetype)initWithNumberOfTracks:(NSUInteger)numberOfTracks {
    self = [super init];
    if ( self ) {
        _reusablePool = SJDanmakuViewReusablePool.pool;
        _queue = SJQueue.queue;
        _clock = [SJDanmakuClock clockWithDelegate:self];
        _view = [SJDanmakuLayoutContainerView.alloc initWithDelegate:self];
        _tracks = [NSMutableArray arrayWithCapacity:4];
        _trackConfiguration = SJDanmakuTrackConfiguration.alloc.init;
        
        self.numberOfTracks = numberOfTracks;
    }
    return self;
}

- (void)setNumberOfTracks:(NSInteger)numberOfTracks {
    if ( numberOfTracks != _numberOfTracks ) {
        _numberOfTracks = numberOfTracks;
         
        // 移除多余的行
        if ( numberOfTracks < _tracks.count ) {
            NSRange range = NSMakeRange(numberOfTracks, _tracks.count - numberOfTracks);
            NSArray<SJDanmakuTrack *> *useless = [_tracks subarrayWithRange:range];
            [useless enumerateObjectsUsingBlock:^(SJDanmakuTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj.view removeFromSuperview];
            }];
            [_tracks removeObjectsInRange:range];
        }
        // 创建新增的行
        else if ( numberOfTracks > _tracks.count ) {
            for ( NSInteger i = _tracks.count ; i < numberOfTracks ; ++ i ) {
                SJDanmakuTrack *track = [SJDanmakuTrack.alloc initWithPool:_reusablePool];
                [_view addSubview:track.view];
                [_tracks addObject:track];
            }
        }
        
        [self reloadTrackConfiguration];
    }
}

- (void)setDisabled:(BOOL)disabled {
    if ( disabled != _disabled ) {
        _disabled = disabled;
        if ( disabled ) [self removeAll];
        [self _postNotification:SJDanmakuPopupControllerOnDisabledChangedNotification];
    }
}

- (void)reloadTrackConfiguration {
    SJDanmakuTrack *last = _tracks.lastObject;
    __block SJDanmakuTrack *pret = nil;
    [_tracks enumerateObjectsUsingBlock:^(SJDanmakuTrack * _Nonnull track, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat topMargin = [self.trackConfiguration topMarginForTrackAtIndex:idx];
        CGFloat height = [self.trackConfiguration heightForTrackAtIndex:idx];
        [track.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            pret == nil ? make.top.offset(topMargin) : make.top.equalTo(pret.view.mas_bottom).offset(topMargin);
            make.left.right.offset(0);
            make.height.offset(height);
            if ( track == last ) make.bottom.offset(0);
        }];
    
        pret = track;
    }];
}

- (void)enqueue:(id<SJDanmakuItem>)item {
    if ( _disabled ) return;
    [_queue enqueue:item];
    if ( _paused == NO ) [_clock resume];
}

- (void)emptyQueue {
    [_queue empty];
}

- (void)removeDisplayedItems {
    [_tracks makeObjectsPerformSelector:@selector(clear)];
}

- (void)removeAll {
    [self emptyQueue];
    [self removeDisplayedItems];
    [self _pauseClockIfNeeded];
}

- (void)pause {
    if ( _disabled ) return;
    [_clock pause];
    self.paused = YES;
}

- (void)resume {
    if ( _disabled ) return;
    [_clock resume];
    self.paused = NO;
}

- (id<SJDanmakuPopupControllerObserver>)getObserver {
    return [SJDanmakuPopupControllerObserver.alloc initWithController:self];
}

- (NSInteger)queueSize {
    return _queue.size;
}

#pragma mark -

- (void)clock:(SJDanmakuClock *)clock onTimeUpdated:(NSTimeInterval)time {
    if ( CGRectIsEmpty(self.view.bounds) )
        return;
    
    for ( NSInteger index = 0 ; index < _numberOfTracks ; ++ index ) {
        SJDanmakuTrack *line = _tracks[index];
        SJDanmakuViewModel *_Nullable last = line.last;
        if ( time >= last.nextItemStartTime + last.delay ) {
            id<SJDanmakuItem> _Nullable item = _queue.dequeue;
            if ( item != nil ) {
                [self _postNotification:SJDanmakuPopupControllerWillDisplayItemNotification userInfo:@{SJDanmakuItemUserInfoKey:item}];
                SJDanmakuViewModel *viewModel = [SJDanmakuViewModel.alloc initWithItem:item];
                CGFloat itemSpacing = [_trackConfiguration itemSpacingForTrackAtIndex:index];
                CGFloat danmakuPoints = viewModel.contentSize.width;
                NSTimeInterval pointDuration = [self _pointDurationForLineAtIndex:index];
                CGFloat allPoints = [self _allTransitionPointsWithDanmakuPoints:danmakuPoints];
                
                viewModel.duration = allPoints * pointDuration;
                viewModel.nextItemStartTime = time + (danmakuPoints + itemSpacing) * pointDuration;
                viewModel.points = allPoints;
                
                __weak typeof(self) _self = self;
                [line fire:viewModel stoppedCallback:^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    [self _postNotification:SJDanmakuPopupControllerDidEndDisplayingItemNotification userInfo:@{SJDanmakuItemUserInfoKey:item}];
                    [self _pauseClockIfNeeded];
                }];
            }
        }
    }
}

- (void)clock:(SJDanmakuClock *)clock onPausedChanged:(BOOL)isPaused {
    [_tracks makeObjectsPerformSelector:isPaused ? @selector(pause) : @selector(resume)];
}

- (void)layoutContainerView:(SJDanmakuLayoutContainerView *)view boundsDidChange:(CGRect)bounds previousBounds:(CGRect)previousBounds {
    if ( previousBounds.size.width > bounds.size.width ) {
        CGFloat points = previousBounds.size.width - bounds.size.width;
        for ( NSInteger i = 0 ; i < _numberOfTracks ; ++ i ) {
            _tracks[i].last.delay += points * [self _pointDurationForLineAtIndex:i];
        }
    }
    previousBounds = bounds;
}

#pragma mark -

- (void)setPaused:(BOOL)paused {
    if ( paused != _paused ) {
        _paused = paused;
        [self _postNotification:SJDanmakuPopupControllerOnPausedChangedNotification];
    }
}

- (NSTimeInterval)_pointDurationForLineAtIndex:(NSInteger)index {
    return POINT_SPEED_FAST / [_trackConfiguration rateForTrackAtIndex:index];
}

- (CGFloat)_allTransitionPointsWithDanmakuPoints:(CGFloat)danmakuPoints {
    return danmakuPoints + SJScreenMaxWidth;
}
 
- (void)_pauseClockIfNeeded {
    if ( _queue.size == 0 ) {
        for ( SJDanmakuTrack *line in _tracks ) {
            if ( line.last != nil ) return;
        }
        
        [_clock pause];
    }
}

- (void)_postNotification:(NSNotificationName)note {
    [self _postNotification:note userInfo:nil];
}

- (void)_postNotification:(NSNotificationName)note userInfo:(nullable NSDictionary *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:note object:self userInfo:userInfo];
    });
}
@end

#pragma mark -

@implementation SJDanmakuTrackConfiguration {
    BOOL _isResponse_rateForTrackAtIndex;
    BOOL _isResponse_topMarginForTrackAtIndex;
    BOOL _isResponse_itemSpacingForTrackAtIndex;
    BOOL _isResponse_heightForTrackAtIndex;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _rate = 1;
        _topMargin = 3.0;
        _itemSpacing = 38.0;
        _height = 26.0;
    }
    return self;
}

- (void)setDelegate:(nullable id<SJDanmakuTrackConfigurationDelegate>)delegate {
    _delegate = delegate;
    _isResponse_rateForTrackAtIndex = [delegate respondsToSelector:@selector(trackConfiguration:rateForTrackAtIndex:)];
    _isResponse_topMarginForTrackAtIndex = [delegate respondsToSelector:@selector(trackConfiguration:topMarginForTrackAtIndex:)];
    _isResponse_itemSpacingForTrackAtIndex = [delegate respondsToSelector:@selector(trackConfiguration:itemSpacingForTrackAtIndex:)];
    _isResponse_heightForTrackAtIndex = [delegate respondsToSelector:@selector(trackConfiguration:heightForTrackAtIndex:)];
}

- (CGFloat)rateForTrackAtIndex:(NSInteger)index {
    CGFloat rate = _isResponse_rateForTrackAtIndex ? [_delegate trackConfiguration:self rateForTrackAtIndex:index] : _rate;
    return rate ?: CGFLOAT_MIN;
}
- (CGFloat)topMarginForTrackAtIndex:(NSInteger)index {
    return _isResponse_topMarginForTrackAtIndex ? [_delegate trackConfiguration:self topMarginForTrackAtIndex:index] : _topMargin;
}
- (CGFloat)itemSpacingForTrackAtIndex:(NSInteger)index {
    return _isResponse_itemSpacingForTrackAtIndex ? [_delegate trackConfiguration:self itemSpacingForTrackAtIndex:index] : _itemSpacing;
}
- (CGFloat)heightForTrackAtIndex:(NSInteger)index {
    return _isResponse_heightForTrackAtIndex ? [_delegate trackConfiguration:self heightForTrackAtIndex:index] : _height;
}
@end
NS_ASSUME_NONNULL_END
