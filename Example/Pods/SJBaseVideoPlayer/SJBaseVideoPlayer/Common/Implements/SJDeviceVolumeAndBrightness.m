//
//  SJDeviceVolumeAndBrightness.m
//  SJBaseVideoPlayer
//
//  Created by 蓝舞者 on 2022/10/14.
//

#import "SJDeviceVolumeAndBrightness.h"
#import <MediaPlayer/MPVolumeView.h>
#import <AVFoundation/AVFoundation.h>

static void*kBrightnessContext = &kBrightnessContext;
static void*kVolumeContext = &kVolumeContext;

@interface SJDeviceVolumeAndBrightness() {
    NSHashTable<id<SJDeviceVolumeAndBrightnessObserver>> *mObservers;
    UISlider *mSysVolumeSlider;
    
    UIScreen *mScreen;
    AVAudioSession *mSession;
    
    BOOL mBrightnessSetterLocked;
    BOOL mVolumeSetterLocked;
}
@end

@implementation SJDeviceVolumeAndBrightness

+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        mObservers = NSHashTable.weakObjectsHashTable;
        
        mScreen = UIScreen.mainScreen;
        [mScreen addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:kBrightnessContext];
        
        mSession = AVAudioSession.sharedInstance;
        [mSession addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:kVolumeContext];
        
        CGFloat maxOffset = MAX(CGRectGetWidth(mScreen.bounds),
                                CGRectGetHeight(mScreen.bounds)) + 100;
        _sysVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-maxOffset, -maxOffset, 0, 0)];
        
        for ( __kindof UIView *subview in self.sysVolumeView.subviews ) {
            if ( [subview.class.description isEqualToString:@"MPVolumeSlider"] ) {
                mSysVolumeSlider = subview;
                break;
            }
        }
    }
    return self;
}

- (void)dealloc {
    [mScreen removeObserver:self forKeyPath:@"brightness" context:kBrightnessContext];
    [mSession removeObserver:self forKeyPath:@"outputVolume" context:kVolumeContext];
}

- (void)addObserver:(id<SJDeviceVolumeAndBrightnessObserver>)observer {
    [mObservers addObject:observer];
}

- (void)removeObserver:(id<SJDeviceVolumeAndBrightnessObserver>)observer {
    [mObservers removeObject:observer];
}

- (void)setVolume:(float)volume {
    if ( isnan(volume) || isinf(volume) ) {
        return;
    }
    
    if      ( volume < 0.0f ) volume = 0.0f;
    else if ( volume > 1.0f ) volume = 1.0f;
    
    if ( volume != _volume ) {
        mVolumeSetterLocked = YES;
        _volume = volume;
        [mSysVolumeSlider setValue:volume animated:NO];
        [self _onVolumeChanged];
    }
}

- (void)setBrightness:(float)brightness {
#ifdef SJDEBUG
    NSLog(@"brightness.onSet: %f", brightness);
#endif

    
    if ( isnan(brightness) || isinf(brightness) ) {
        return;
    }
    
    if      ( brightness < 0.0f ) brightness = 0.0f;
    else if ( brightness > 1.0f ) brightness = 1.0f;
    
    if ( brightness != _brightness ) {
        mBrightnessSetterLocked = YES;
        _brightness = brightness;
        UIScreen.mainScreen.brightness = brightness;
        [self _onBrightnessChanged];
    }
}

#pragma mark - mark

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( NSThread.currentThread.isMainThread ) {
        [self _onValueChangeForKeyPath:keyPath object:object change:change context:context];
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _onValueChangeForKeyPath:keyPath object:object change:change context:context];
        });
    }
}

- (void)_onValueChangeForKeyPath:(NSString *)keyPath object:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
#ifdef SJDEBUG
    NSLog(@"onChange: %@: %@", keyPath, change);
#endif

    if      ( context == kVolumeContext ) {
        if ( !mVolumeSetterLocked ) {
            _volume = [change[NSKeyValueChangeNewKey] floatValue];
            [self _onVolumeChanged];
        }
        mVolumeSetterLocked = NO;
    }
    else if ( context == kBrightnessContext ) {
        if ( !mBrightnessSetterLocked ) {
            _brightness = [change[NSKeyValueChangeNewKey] floatValue];
            [self _onBrightnessChanged];
        }
        mBrightnessSetterLocked = NO;
    }
}

#pragma mark - mark

- (void)_onVolumeChanged {
    if ( mObservers.count > 0 ) {
        for ( id<SJDeviceVolumeAndBrightnessObserver>observer in mObservers ) {
            if ( [observer respondsToSelector:@selector(device:onVolumeChanged:)] ) [observer device:self onVolumeChanged:_volume];
        }
    }
}

- (void)_onBrightnessChanged {
    if ( mObservers.count > 0 ) {
        for ( id<SJDeviceVolumeAndBrightnessObserver>observer in mObservers ) {
            if ( [observer respondsToSelector:@selector(device:onBrightnessChanged:)] ) [observer device:self onBrightnessChanged:_brightness];
        }
    }
}

@end
