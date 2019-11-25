//
//  SJBarrageQueueController.m
//  Pods
//
//  Created by BlueDancer on 2019/11/12.
//

#import "SJBarrageQueueController.h"
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

static NSNotificationName const SJBarrageQueueControllerDisabledDidChangeNotification = @"SJBarrageQueueControllerDisabledDidChangeNotification";
static NSNotificationName const SJBarrageQueueControllerPausedDidChangeNotification = @"SJBarrageQueueControllerPausedDidChangeNotification";

@interface SJBarrageViewModel : NSObject
- (instancetype)initWithBarrageItem:(id<SJBarrageItem>)item;

@property (nonatomic, copy, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) __kindof UIView *customView;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval nextBarrageStartTime;
@property (nonatomic) NSTimeInterval delay;
@end

@implementation SJBarrageViewModel
- (instancetype)initWithBarrageItem:(id<SJBarrageItem>)item {
    self = [super init];
    if ( self ) {
        if ( item.content.length != 0 ) {
            _content = item.content.copy;
            _contentSize = [_content sj_textSize];
        }
        else {
            _customView = item.customView;
            _contentSize = item.customView.bounds.size;
            if ( CGSizeEqualToSize(CGSizeZero, _contentSize) )
                _contentSize = [item.customView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        }
    }
    return self;
}
@end

#pragma mark -

@interface SJBarrageView : UILabel
@property (nonatomic, strong, nullable) SJBarrageViewModel *viewModel;
@end

@interface SJBarrageView ()
@property (nonatomic, strong, nullable) UIView *customView;
@end

@implementation SJBarrageView
- (CGSize)intrinsicContentSize {
    return _viewModel.contentSize;
}

- (void)setViewModel:(nullable SJBarrageViewModel *)viewModel {
    _viewModel = viewModel;
    if ( _customView != nil ) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    
    if ( viewModel.content.length != 0 ) {
        self.attributedText = viewModel.content;
    }
    else {
        self.attributedText = nil;
        _customView = viewModel.customView;
        _customView.frame = CGRectMake(0, 0, viewModel.contentSize.width, viewModel.contentSize.height);
        [self addSubview:viewModel.customView];
    }
}
@end


#pragma mark -

@interface SJBarrageViewReusablePool : NSObject
+ (instancetype)pool;
@property (nonatomic) NSInteger size;
- (SJBarrageView *)dequeueReusableBarrageView;
- (void)addBarrageView:(SJBarrageView *)view;
@end

@implementation SJBarrageViewReusablePool {
    NSMutableArray<SJBarrageView *> *_m;
}
+ (instancetype)pool {
    return SJBarrageViewReusablePool.alloc.init;
}
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _size = 5;
        _m = [NSMutableArray.alloc initWithCapacity:_size];
    }
    return self;
}
- (SJBarrageView *)dequeueReusableBarrageView {
    if ( _m.count == 0 ) {
        [_m addObject:[SJBarrageView.alloc initWithFrame:CGRectZero]];
    }
    
    SJBarrageView *last = _m.lastObject;
    [_m removeLastObject];
    return last;
}
- (void)addBarrageView:(SJBarrageView *)view {
    if ( view != nil && _m.count < _size ) {
        [_m addObject:view];
    }
}
@end


#pragma mark -

@protocol SJBarrageClockDelegate;

@interface SJBarrageClock : NSObject
+ (instancetype)clock;
@property (nonatomic, weak, nullable) id<SJBarrageClockDelegate> delegate;
@property (nonatomic, readonly) NSTimeInterval time;

@property (nonatomic, readonly, getter=isPaused) BOOL paused;
- (void)pause;
- (void)resume;
@end

@protocol SJBarrageClockDelegate <NSObject>
- (void)clock:(SJBarrageClock *)clock timeDidChange:(NSTimeInterval)time;
- (void)clock:(SJBarrageClock *)clock pausedDidChange:(BOOL)isPaused;
@end

@interface SJBarrageClock ()
@property (nonatomic) NSTimeInterval time;
@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic, getter=isPaused) BOOL paused;
@end
@implementation SJBarrageClock
+ (instancetype)clock {
    return SJBarrageClock.alloc.init;
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
    [self.delegate clock:self timeDidChange:time];
}

- (void)setPaused:(BOOL)paused {
    _paused = paused;
    [self.delegate clock:self pausedDidChange:paused];
}
@end

#pragma mark -

@interface SJBarrageContainerView : UIView
@property (nonatomic, strong, readonly, nullable) SJBarrageView *lastView;
- (void)pauseAnimations;
- (void)resumeAnimations;
@end

@implementation SJBarrageContainerView
- (void)pauseAnimations {
    for ( UIView *subview in self.subviews ) {
        [subview.layer pauseAnimation];
    }
}
- (void)resumeAnimations {
    for ( UIView *subview in self.subviews ) {
        [subview.layer resumeAnimation];
    }
}
- (nullable SJBarrageView *)lastView {
    return self.subviews.lastObject;
}
@end

#pragma mark -

@protocol SJBarrageQueueControllerViewDelegate;

@interface SJBarrageQueueControllerView : UIView
@property (nonatomic, weak, nullable) id<SJBarrageQueueControllerViewDelegate> delegate;
@end

@protocol SJBarrageQueueControllerViewDelegate <NSObject>
- (void)barrageQueueControllerView:(SJBarrageQueueControllerView *)view boundsDidChange:(CGRect)bounds;
@end

@implementation SJBarrageQueueControllerView {
    CGRect _bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    if ( !CGRectEqualToRect(bounds, _bounds) ) {
        if ( [self.delegate respondsToSelector:@selector(barrageQueueControllerView:boundsDidChange:)] ) {
            [self.delegate barrageQueueControllerView:self boundsDidChange:bounds];
        }
    }
    _bounds = bounds;
}
@end

#pragma mark -

@interface SJBarrageQueueControllerObserver : NSObject<SJBarrageQueueControllerObserver>
- (instancetype)initWithController:(SJBarrageQueueController *)controller;
@end

@implementation SJBarrageQueueControllerObserver
@synthesize disabledDidChangeExeBlock = _disabledDidChangeExeBlock;
@synthesize pausedDidChangeExeBlock = _pausedDidChangeExeBlock;
- (instancetype)initWithController:(SJBarrageQueueController *)controller {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_pausedDidChange:) name:SJBarrageQueueControllerPausedDidChangeNotification object:controller];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_disabledDidChange:) name:SJBarrageQueueControllerDisabledDidChangeNotification object:controller];
    }
    return self;
}
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)_pausedDidChange:(NSNotification *)note {
    if ( _pausedDidChangeExeBlock ) _pausedDidChangeExeBlock(note.object);
}
- (void)_disabledDidChange:(NSNotification *)note {
    if ( _disabledDidChangeExeBlock ) _disabledDidChangeExeBlock(note.object);
}
@end

#pragma mark -

static CGFloat SJScreenMaxWidth;

@interface SJBarrageQueueController ()<SJBarrageQueueControllerViewDelegate, SJBarrageClockDelegate>
@property (nonatomic, strong, readonly) SJQueue<id<SJBarrageItem>> *queue;
@property (nonatomic, strong, readonly) SJBarrageViewReusablePool *reusablePool;
@property (nonatomic, strong, readonly) SJBarrageClock *clock;
@property (nonatomic, strong, readonly) NSArray<SJBarrageLineConfiguration *> *configurations;
@property (nonatomic, strong, readonly) NSArray<SJBarrageContainerView *> *containerViews;
@property (nonatomic, strong, readonly) SJBarrageQueueControllerView *view;
@property (nonatomic, getter=isPaused) BOOL paused;
@end

@implementation SJBarrageQueueController
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SJScreenMaxWidth = MAX(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
    });
}

- (instancetype)initWithLines:(NSUInteger)lines {
    self = [super init];
    if ( self ) {
        _queue = SJQueue.queue;
        _reusablePool = SJBarrageViewReusablePool.pool;
        _clock = SJBarrageClock.clock;
        _clock.delegate = self;
        _view = [SJBarrageQueueControllerView.alloc initWithFrame:CGRectZero];
        _view.delegate = self;

        NSMutableArray<SJBarrageLineConfiguration *> *configurations = [NSMutableArray arrayWithCapacity:lines];
        NSMutableArray<SJBarrageContainerView *> *containerViews = [NSMutableArray arrayWithCapacity:lines];
        for ( NSUInteger i = 0; i < lines; ++ i ) {
            SJBarrageLineConfiguration *config = SJBarrageLineConfiguration.alloc.init;
            config.rate = (i % 2 == 0) ? 1 : 0.9;
            [configurations addObject:config];
            
            SJBarrageContainerView *containerView = [SJBarrageContainerView.alloc initWithFrame:CGRectZero];
            [containerViews addObject:containerView];
            [_view addSubview:containerView];
        }
        _configurations = configurations.copy;
        _containerViews = containerViews.copy;
        [self updateForConfigurations];
    }
    return self;
}

- (void)setDisabled:(BOOL)disabled {
    if ( disabled != _disabled ) {
        _disabled = disabled;
        if ( disabled ) [self removeAll];
        [self _postNotification:SJBarrageQueueControllerDisabledDidChangeNotification];
    }
}

- (nullable SJBarrageLineConfiguration *)configurationAtIndex:(NSInteger)idx {
    if ( idx < 0 || idx >= _configurations.count )
        return nil;
    return _configurations[idx];
}

- (void)updateForConfigurations {
    [self.containerViews enumerateObjectsUsingBlock:^(SJBarrageContainerView * _Nonnull container, NSUInteger idx, BOOL * _Nonnull stop) {
        SJBarrageLineConfiguration *config = self.configurations[idx];
        [container mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat topMargin = config.topMargin;
            CGFloat height = config.height;
            idx == 0 ? make.top.offset(0) : make.top.equalTo(self.containerViews[idx - 1].mas_bottom).offset(topMargin);
            make.left.right.offset(0);
            make.height.offset(height);
            if ( idx == self.containerViews.count - 1 ) { make.bottom.offset(0); }
        }];
    }];
}

- (void)enqueue:(id<SJBarrageItem>)barrage {
    if ( _disabled ) return;
    [_queue enqueue:barrage];
    if ( _paused == NO ) [_clock resume];
}

- (void)emptyQueue {
    [_queue empty];
}

- (void)removeDisplayedBarrages {
    for ( SJBarrageContainerView *container in _containerViews ) {
        [container.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            [view.layer removeAllAnimations];
            [view removeFromSuperview];
        }];
    }
}

- (void)removeAll {
    [self emptyQueue];
    [self removeDisplayedBarrages];
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

- (id<SJBarrageQueueControllerObserver>)getObserver {
    return [SJBarrageQueueControllerObserver.alloc initWithController:self];
}

- (void)clock:(SJBarrageClock *)clock timeDidChange:(NSTimeInterval)time {
    if ( CGRectIsEmpty(self.view.bounds) )
        return;
    
    for ( NSInteger i = 0 ; i < _containerViews.count ; ++ i ) {
        SJBarrageContainerView *container = _containerViews[i];
        SJBarrageViewModel *_Nullable last = container.lastView.viewModel;
        if ( time >= last.nextBarrageStartTime + last.delay ) {
            id<SJBarrageItem> _Nullable item = self.queue.dequeue;
            if ( item != nil ) {
                SJBarrageLineConfiguration *config = self.configurations[i];
                SJBarrageViewModel *viewModel = [SJBarrageViewModel.alloc initWithBarrageItem:item];
                NSTimeInterval pointDuration = [self _pointDuration] / config.rate;
                CGFloat barragePoints = viewModel.contentSize.width;
                CGFloat itemMargin = config.itemMargin;
                CGFloat allPoints = [self _allPoints:barragePoints];
                
                viewModel.startTime = time;
                viewModel.duration = allPoints * pointDuration;
                viewModel.nextBarrageStartTime = time + (barragePoints + itemMargin) * pointDuration;
                
                SJBarrageView *barrageView = [self.reusablePool dequeueReusableBarrageView];
                barrageView.viewModel = viewModel;
                [container addSubview:barrageView];
                
                CGRect frame = CGRectZero;
                CGRect bounds = container.bounds;
                frame.origin.x = bounds.size.width;
                frame.origin.y = CGRectGetHeight(bounds) * 0.5 - viewModel.contentSize.height * 0.5;
                frame.size = viewModel.contentSize;
                barrageView.frame = frame;
                
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
                animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
                animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-allPoints, 0, 0)];
                animation.duration = viewModel.duration;
                animation.fillMode = kCAFillModeForwards;
                animation.removedOnCompletion = NO;
                [barrageView.layer addAnimation:animation forKey:@"anim"];
                __weak typeof(self) _self = self;
                __weak typeof(barrageView) _barrageView = barrageView;
                [barrageView.layer addAnimation:animation stopHandler:^(CAAnimation * _Nonnull anim, BOOL isFinished) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    [_barrageView removeFromSuperview];
                    [self.reusablePool addBarrageView:_barrageView];
                    [self _pauseClockIfNeeded];
                }];
            }
        }
    }
}

- (void)clock:(SJBarrageClock *)clock pausedDidChange:(BOOL)isPaused {
    [self.containerViews makeObjectsPerformSelector:isPaused ? @selector(pauseAnimations) : @selector(resumeAnimations)];
}

- (void)barrageQueueControllerView:(SJBarrageQueueControllerView *)view boundsDidChange:(CGRect)bounds {
    [self removeDisplayedBarrages];
}

#pragma mark -

- (void)setPaused:(BOOL)paused {
    if ( paused != _paused ) {
        _paused = paused;
        [self _postNotification:SJBarrageQueueControllerPausedDidChangeNotification];
    }
}

- (NSTimeInterval)_pointDuration {
    return POINT_SPEED_FAST;
}

- (CGFloat)_allPoints:(CGFloat)barragePoints {
    return barragePoints + SJScreenMaxWidth;
}

- (void)_pauseClockIfNeeded {
    if ( self.queue.size == 0 ) {
        for ( SJBarrageContainerView *container in _containerViews ) {
            if ( container.lastView != nil ) return;
        }
        
        [_clock pause];
    }
}

- (void)_postNotification:(NSNotificationName)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:note object:self];
    });
}
@end

@implementation SJBarrageLineConfiguration
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _rate = 1;
        _topMargin = 3.0;
        _itemMargin = 38.0;
        _height = 26.0;
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
