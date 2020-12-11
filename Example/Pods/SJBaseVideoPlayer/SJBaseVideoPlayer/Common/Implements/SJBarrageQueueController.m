//
//  SJBarrageQueueController.m
//  Pods
//
//  Created by 畅三江 on 2019/11/12.
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
static NSNotificationName const SJBarrageQueueControllerWillDisplayBarrageNotification = @"SJBarrageQueueControllerWillDisplayBarrageNotification";
static NSNotificationName const SJBarrageQueueControllerDidEndDisplayBarrageNotification = @"SJBarrageQueueControllerDidEndDisplayBarrageNotification";
static NSString *const SJBarrageQueueControllerBarrageItemKey = @"barrageItem";


@interface SJBarrageViewModel : NSObject
- (instancetype)initWithBarrageItem:(id<SJBarrageItem>)item;

@property (nonatomic, copy, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) __kindof UIView *customView;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval nextBarrageStartTime;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) CGFloat points;
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
+ (instancetype)clockWithDelegate:(id<SJBarrageClockDelegate>)delegate;
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
+ (instancetype)clockWithDelegate:(id<SJBarrageClockDelegate>)delegate {
    SJBarrageClock *clock = SJBarrageClock.alloc.init;
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
    [self.delegate clock:self timeDidChange:time];
}

- (void)setPaused:(BOOL)paused {
    _paused = paused;
    [self.delegate clock:self pausedDidChange:paused];
}
@end

#pragma mark -

@interface SJBarrageLineView : UIView
@end

@implementation SJBarrageLineView
@end

#pragma mark -

@interface SJBarrageLineConfiguration ()
- (CGFloat)rateForLineAtIndex:(NSInteger)index;
- (CGFloat)topMarginForLineAtIndex:(NSInteger)index;
- (CGFloat)itemSpacingForLineAtIndex:(NSInteger)index;
- (CGFloat)heightForLineAtIndex:(NSInteger)index;
@end

#pragma mark -

@interface SJBarrageLine : NSObject
- (instancetype)initWithPool:(SJBarrageViewReusablePool *)pool;
@property (nonatomic, strong, readonly) SJBarrageViewReusablePool *pool;
@property (nonatomic, strong, readonly) SJBarrageLineView *view;

@property (nonatomic, strong, readonly, nullable) SJBarrageViewModel *last;
- (void)pause;
- (void)resume;
- (void)clear;
- (void)fire:(SJBarrageViewModel *)viewModel stoppedCallback:(void(^)(void))completion;
@end

@implementation SJBarrageLine
- (instancetype)initWithPool:(SJBarrageViewReusablePool *)pool {
    self = [super init];
    if ( self ) {
        _pool = pool;
        _view = [SJBarrageLineView.alloc initWithFrame:CGRectZero];
    }
    return self;
}

- (nullable SJBarrageViewModel *)last {
    __auto_type view = (SJBarrageView *)_view.subviews.lastObject;
    return view.viewModel;
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

- (void)fire:(SJBarrageViewModel *)viewModel stoppedCallback:(void(^)(void))completion {
    SJBarrageView *barrageView = [_pool dequeueReusableBarrageView];
    barrageView.viewModel = viewModel;
    [_view addSubview:barrageView];
    
    CGRect frame = CGRectZero;
    CGRect bounds = _view.bounds;
    frame.origin.x = bounds.size.width;
    frame.origin.y = (CGRectGetHeight(bounds) - barrageView.viewModel.contentSize.height) * 0.5;
    frame.size = barrageView.viewModel.contentSize;
    barrageView.frame = frame;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-barrageView.viewModel.points, 0, 0)];
    animation.duration = barrageView.viewModel.duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [barrageView.layer addAnimation:animation forKey:@"anim"];
    __weak typeof(self) _self = self;
    __weak typeof(barrageView) _barrageView = barrageView;
    [barrageView.layer addAnimation:animation stopHandler:^(CAAnimation * _Nonnull anim, BOOL isFinished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [_barrageView removeFromSuperview];
        [self.pool addBarrageView:_barrageView];
        if ( completion ) completion();
    }];
}
@end

#pragma mark -

@protocol SJBarrageQueueControllerViewDelegate;

@interface SJBarrageQueueControllerView : UIView
- (instancetype)initWithDelegate:(id<SJBarrageQueueControllerViewDelegate>)delegate;
@property (nonatomic, weak, nullable) id<SJBarrageQueueControllerViewDelegate> delegate;
@end

@protocol SJBarrageQueueControllerViewDelegate <NSObject>
- (void)barrageQueueControllerView:(SJBarrageQueueControllerView *)view boundsDidChange:(CGRect)bounds previousBounds:(CGRect)previousBounds;
@end

@implementation SJBarrageQueueControllerView {
    CGRect _previousBounds;
}

- (instancetype)initWithDelegate:(id<SJBarrageQueueControllerViewDelegate>)delegate {
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
        if ( [self.delegate respondsToSelector:@selector(barrageQueueControllerView:boundsDidChange:previousBounds:)] ) {
            [self.delegate barrageQueueControllerView:self boundsDidChange:bounds previousBounds:_previousBounds];
        }
    }
    _previousBounds = bounds;
}
@end

#pragma mark -

@interface SJBarrageQueueControllerObserver : NSObject<SJBarrageQueueControllerObserver>
- (instancetype)initWithController:(SJBarrageQueueController *)controller;
@end

@implementation SJBarrageQueueControllerObserver
@synthesize disabledDidChangeExeBlock = _disabledDidChangeExeBlock;
@synthesize pausedDidChangeExeBlock = _pausedDidChangeExeBlock;
@synthesize willDisplayBarrageExeBlock = _willDisplayBarrageExeBlock;
@synthesize didEndDisplayBarrageExeBlock = _didEndDisplayBarrageExeBlock;
- (instancetype)initWithController:(SJBarrageQueueController *)controller {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_pausedDidChange:) name:SJBarrageQueueControllerPausedDidChangeNotification object:controller];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_disabledDidChange:) name:SJBarrageQueueControllerDisabledDidChangeNotification object:controller];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_willDisplayBarrage:) name:SJBarrageQueueControllerWillDisplayBarrageNotification object:controller];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didEndDisplayBarrage:) name:SJBarrageQueueControllerDidEndDisplayBarrageNotification object:controller];
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
- (void)_willDisplayBarrage:(NSNotification *)note {
    if ( _willDisplayBarrageExeBlock ) _willDisplayBarrageExeBlock(note.object, note.userInfo[SJBarrageQueueControllerBarrageItemKey]);
}
- (void)_didEndDisplayBarrage:(NSNotification *)note {
    if ( _didEndDisplayBarrageExeBlock ) _didEndDisplayBarrageExeBlock(note.object, note.userInfo[SJBarrageQueueControllerBarrageItemKey]);
}
@end
 
#pragma mark -


@interface SJBarrageQueueController ()<SJBarrageQueueControllerViewDelegate, SJBarrageClockDelegate> {
    SJQueue<id<SJBarrageItem>> *_queue;
    SJBarrageClock *_clock;
}
@property (nonatomic, strong, readonly) SJBarrageViewReusablePool *reusablePool;
@property (nonatomic, strong, readonly) NSMutableArray<SJBarrageLine *> *lines;
@property (nonatomic, getter=isPaused) BOOL paused;
@end

@implementation SJBarrageQueueController
@synthesize view = _view;
static CGFloat SJScreenMaxWidth;
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SJScreenMaxWidth = MAX(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds));
    });
}

- (instancetype)initWithNumberOfLines:(NSUInteger)numberOfLines {
    self = [super init];
    if ( self ) {
        _reusablePool = SJBarrageViewReusablePool.pool;
        _queue = SJQueue.queue;
        _clock = [SJBarrageClock clockWithDelegate:self];
        _view = [SJBarrageQueueControllerView.alloc initWithDelegate:self];
        _lines = [NSMutableArray arrayWithCapacity:4];
        _configuration = SJBarrageLineConfiguration.alloc.init;
        
        self.numberOfLines = numberOfLines;
    }
    return self;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    if ( numberOfLines != _numberOfLines ) {
        _numberOfLines = numberOfLines;
         
        // 移除多余的行
        if ( numberOfLines < _lines.count ) {
            NSRange range = NSMakeRange(numberOfLines, _lines.count - numberOfLines);
            NSArray<SJBarrageLine *> *useless = [_lines subarrayWithRange:range];
            [useless enumerateObjectsUsingBlock:^(SJBarrageLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj.view removeFromSuperview];
            }];
            [_lines removeObjectsInRange:range];
        }
        // 创建新增的行
        else if ( numberOfLines > _lines.count ) {
            for ( NSInteger i = _lines.count ; i < numberOfLines ; ++ i ) {
                SJBarrageLine *line = [SJBarrageLine.alloc initWithPool:_reusablePool];
                [_view addSubview:line.view];
                [_lines addObject:line];
            }
        }
        
        [self reloadConfiguration];
    }
}

- (void)setDisabled:(BOOL)disabled {
    if ( disabled != _disabled ) {
        _disabled = disabled;
        if ( disabled ) [self removeAll];
        [self _postNotification:SJBarrageQueueControllerDisabledDidChangeNotification];
    }
}

- (void)reloadConfiguration {
    SJBarrageLine *last = _lines.lastObject;
    __block SJBarrageLine *prel = nil;
    [_lines enumerateObjectsUsingBlock:^(SJBarrageLine * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat topMargin = [self.configuration topMarginForLineAtIndex:idx];
        CGFloat height = [self.configuration heightForLineAtIndex:idx];
        [line.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            prel == nil ? make.top.offset(topMargin) : make.top.equalTo(prel.view.mas_bottom).offset(topMargin);
            make.left.right.offset(0);
            make.height.offset(height);
            if ( line == last ) make.bottom.offset(0);
        }];
    
        prel = line;
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
    [_lines makeObjectsPerformSelector:@selector(clear)];
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

- (NSInteger)queueSize {
    return _queue.size;
}

#pragma mark -

- (void)clock:(SJBarrageClock *)clock timeDidChange:(NSTimeInterval)time {
    if ( CGRectIsEmpty(self.view.bounds) )
        return;
    
    for ( NSInteger index = 0 ; index < _numberOfLines ; ++ index ) {
        SJBarrageLine *line = _lines[index];
        SJBarrageViewModel *_Nullable last = line.last;
        if ( time >= last.nextBarrageStartTime + last.delay ) {
            id<SJBarrageItem> _Nullable item = _queue.dequeue;
            if ( item != nil ) {
                [self _postNotification:SJBarrageQueueControllerWillDisplayBarrageNotification userInfo:@{SJBarrageQueueControllerBarrageItemKey:item}];
                SJBarrageViewModel *viewModel = [SJBarrageViewModel.alloc initWithBarrageItem:item];
                CGFloat itemSpacing = [_configuration itemSpacingForLineAtIndex:index];
                CGFloat barragePoints = viewModel.contentSize.width;
                NSTimeInterval pointDuration = [self _pointDurationForLineAtIndex:index];
                CGFloat allPoints = [self _allPointsWithBarragePoints:barragePoints];
                
                viewModel.duration = allPoints * pointDuration;
                viewModel.nextBarrageStartTime = time + (barragePoints + itemSpacing) * pointDuration;
                viewModel.points = allPoints;
                
                __weak typeof(self) _self = self;
                [line fire:viewModel stoppedCallback:^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    [self _postNotification:SJBarrageQueueControllerDidEndDisplayBarrageNotification userInfo:@{SJBarrageQueueControllerBarrageItemKey:item}];
                    [self _pauseClockIfNeeded];
                }];
            }
        }
    }
}

- (void)clock:(SJBarrageClock *)clock pausedDidChange:(BOOL)isPaused {
    [_lines makeObjectsPerformSelector:isPaused ? @selector(pause) : @selector(resume)];
}

- (void)barrageQueueControllerView:(SJBarrageQueueControllerView *)view boundsDidChange:(CGRect)bounds previousBounds:(CGRect)previousBounds {
    if ( previousBounds.size.width > bounds.size.width ) {
        CGFloat points = previousBounds.size.width - bounds.size.width;
        for ( NSInteger i = 0 ; i < _numberOfLines ; ++ i ) {
            _lines[i].last.delay += points * [self _pointDurationForLineAtIndex:i];
        }
    }
    previousBounds = bounds;
}

#pragma mark -

- (void)setPaused:(BOOL)paused {
    if ( paused != _paused ) {
        _paused = paused;
        [self _postNotification:SJBarrageQueueControllerPausedDidChangeNotification];
    }
}

- (NSTimeInterval)_pointDurationForLineAtIndex:(NSInteger)index {
    return POINT_SPEED_FAST / [_configuration rateForLineAtIndex:index];
}

- (CGFloat)_allPointsWithBarragePoints:(CGFloat)barragePoints {
    return barragePoints + SJScreenMaxWidth;
}
 
- (void)_pauseClockIfNeeded {
    if ( _queue.size == 0 ) {
        for ( SJBarrageLine *line in _lines ) {
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

@implementation SJBarrageLineConfiguration {
    BOOL _isResponse_rateForLineAtIndex;
    BOOL _isResponse_topMarginForLineAtIndex;
    BOOL _isResponse_itemSpacingForLineAtIndex;
    BOOL _isResponse_heightForLineAtIndex;
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

- (void)setDelegate:(nullable id<SJBarrageLineConfigurationDelegate>)delegate {
    _delegate = delegate;
    _isResponse_rateForLineAtIndex = [delegate respondsToSelector:@selector(barrageLineConfiguration:rateForLineAtIndex:)];
    _isResponse_topMarginForLineAtIndex = [delegate respondsToSelector:@selector(barrageLineConfiguration:topMarginForLineAtIndex:)];
    _isResponse_itemSpacingForLineAtIndex = [delegate respondsToSelector:@selector(barrageLineConfiguration:itemSpacingForLineAtIndex:)];
    _isResponse_heightForLineAtIndex = [delegate respondsToSelector:@selector(barrageLineConfiguration:heightForLineAtIndex:)];
}

- (CGFloat)rateForLineAtIndex:(NSInteger)index {
    CGFloat rate = _isResponse_rateForLineAtIndex ? [_delegate barrageLineConfiguration:self rateForLineAtIndex:index] : _rate;
    return rate ?: CGFLOAT_MIN;
}
- (CGFloat)topMarginForLineAtIndex:(NSInteger)index {
    return _isResponse_topMarginForLineAtIndex ? [_delegate barrageLineConfiguration:self topMarginForLineAtIndex:index] : _topMargin;
}
- (CGFloat)itemSpacingForLineAtIndex:(NSInteger)index {
    return _isResponse_itemSpacingForLineAtIndex ? [_delegate barrageLineConfiguration:self itemSpacingForLineAtIndex:index] : _itemSpacing;
}
- (CGFloat)heightForLineAtIndex:(NSInteger)index {
    return _isResponse_heightForLineAtIndex ? [_delegate barrageLineConfiguration:self heightForLineAtIndex:index] : _height;
}
@end
NS_ASSUME_NONNULL_END
