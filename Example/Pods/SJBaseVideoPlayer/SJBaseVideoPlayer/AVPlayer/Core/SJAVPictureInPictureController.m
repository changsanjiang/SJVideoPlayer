//
//  SJAVPictureInPictureController.m
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2020/9/26.
//

#import "SJAVPictureInPictureController.h"
#import <AVKit/AVPictureInPictureController.h>

@interface SJAVPictureInPictureController ()<AVPictureInPictureControllerDelegate>
@property (nonatomic, strong) AVPictureInPictureController *pictureInPictureController;
@property (nonatomic) SJPictureInPictureStatus status;
@end

@implementation SJAVPictureInPictureController
@synthesize delegate = _delegate;
static NSString *kPictureInPicturePossible = @"pictureInPicturePossible";

- (nullable instancetype)initWithLayer:(AVPlayerLayer *)layer delegate:(id<SJPictureInPictureControllerDelegate>)delegate {
    if ( !SJAVPictureInPictureController.isPictureInPictureSupported ) return nil;
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _pictureInPictureController = [AVPictureInPictureController.alloc initWithPlayerLayer:layer];
        _pictureInPictureController.delegate = self;
        [_pictureInPictureController addObserver:self forKeyPath:kPictureInPicturePossible options:NSKeyValueObservingOptionNew context:&kPictureInPicturePossible];
    }
    return self;
}

- (void)dealloc {
#ifdef SJDEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    
    [_pictureInPictureController removeObserver:self forKeyPath:kPictureInPicturePossible context:&kPictureInPicturePossible];
    if ( _status != SJPictureInPictureStatusStopping ||
         _status != SJPictureInPictureStatusStopped ) {
        [self _stopPictureInPicture];
    }
}

- (void)setRequiresLinearPlayback:(BOOL)requiresLinearPlayback {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
    _pictureInPictureController.requiresLinearPlayback = requiresLinearPlayback;
#endif
}

- (BOOL)requiresLinearPlayback {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
    return _pictureInPictureController.requiresLinearPlayback;
#else
    return NO;
#endif
}

- (BOOL)isAvailable {
    return _status != SJPictureInPictureStatusStopping && _status != SJPictureInPictureStatusStopped;
}

- (BOOL)isEnabled {
    return _status == SJPictureInPictureStatusStarting || _status == SJPictureInPictureStatusRunning;
}

+ (BOOL)isPictureInPictureSupported {
    return AVPictureInPictureController.isPictureInPictureSupported;
}

- (void)startPictureInPicture {
#ifdef SJDEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif

    _wantsPictureInPictureStart = YES;

    switch ( self.status ) {
        case SJPictureInPictureStatusStarting:
        case SJPictureInPictureStatusRunning:
            /* return */
            return;
        case SJPictureInPictureStatusUnknown:
        case SJPictureInPictureStatusStopping:
        case SJPictureInPictureStatusStopped: {
            self.status = SJPictureInPictureStatusStarting;
            [self _startPictureInPictureIfReady];
        }
            break;
    }
}

- (void)stopPictureInPicture {
#ifdef SJDEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    
    _wantsPictureInPictureStart = NO;
    
    switch ( self.status ) {
        case SJPictureInPictureStatusStopping:
        case SJPictureInPictureStatusStopped:
            /* return */
            return;
        case SJPictureInPictureStatusUnknown:
        case SJPictureInPictureStatusStarting:
        case SJPictureInPictureStatusRunning: {
            self.status = SJPictureInPictureStatusStopping;
            [self _stopPictureInPicture];
        }
            break;
    }
}

#pragma mark -

- (void)_startPictureInPictureIfReady {
    BOOL isReady = (_status == SJPictureInPictureStatusStarting) && _pictureInPictureController.isPictureInPicturePossible;
    
    if ( isReady ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_pictureInPictureController startPictureInPicture];
        });
    }
}

- (void)_stopPictureInPicture {
    [self->_pictureInPictureController stopPictureInPicture];
}

- (void)setStatus:(SJPictureInPictureStatus)status {
    _status = status;
    if ( [self.delegate respondsToSelector:@selector(pictureInPictureController:statusDidChange:)] ) {
        [self.delegate pictureInPictureController:self statusDidChange:status];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( context == &kPictureInPicturePossible ) {
            [self _startPictureInPictureIfReady];
        }
    });
}

#pragma mark - AVPictureInPictureControllerDelegate

#pragma mark start

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    self.status = SJPictureInPictureStatusRunning;
#ifdef SJDEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    [self _stopPictureInPicture];
#ifdef SJDEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

#pragma mark stop

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    self.status = SJPictureInPictureStatusStopped;
}
 
// 恢复界面(看后续是否需要)
//- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
//
//}
@end
