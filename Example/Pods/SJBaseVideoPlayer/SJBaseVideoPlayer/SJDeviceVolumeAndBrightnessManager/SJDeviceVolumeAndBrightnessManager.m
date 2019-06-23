//
//  SJDeviceVolumeAndBrightnessManager.m
//  SJDeviceVolumeAndBrightnessManager
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJDeviceVolumeAndBrightnessManager.h"
#import "SJDeviceBrightnessView.h"
#import "SJDeviceVolumeAndBrightnessManagerResourceLoader.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
static NSNotificationName const SJDeviceVolumeDidChangeNotification = @"SJDeviceVolumeDidChangeNotification";
static NSNotificationName const SJDeviceBrightnessDidChangeNotification = @"SJDeviceBrightnessDidChangeNotification";

@interface SJDeviceVolumeAndBrightnessManagerObserver : NSObject<SJDeviceVolumeAndBrightnessManagerObserver>
- (instancetype)initWithMgr:(id<SJDeviceVolumeAndBrightnessManager>)mgr;
@end

@implementation SJDeviceVolumeAndBrightnessManagerObserver {
    id _volumeDidChangeToken;
    id _brightnessDidChangeToken;
}
@synthesize volumeDidChangeExeBlock = _volumeDidChangeExeBlock;
@synthesize brightnessDidChangeExeBlock = _brightnessDidChangeExeBlock;

- (instancetype)initWithMgr:(id<SJDeviceVolumeAndBrightnessManager>)mgr {
    self = [super init];
    if ( !self )
        return nil;
    __weak typeof(self) _self = self;
    _volumeDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:SJDeviceVolumeDidChangeNotification object:mgr queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        id<SJDeviceVolumeAndBrightnessManager> mgr = note.object;
        if ( self.volumeDidChangeExeBlock ) self.volumeDidChangeExeBlock(mgr, mgr.volume);
    }];
    
    _brightnessDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:SJDeviceBrightnessDidChangeNotification object:mgr queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        id<SJDeviceVolumeAndBrightnessManager> mgr = note.object;
        if ( self.brightnessDidChangeExeBlock ) self.brightnessDidChangeExeBlock(mgr, mgr.brightness);
    }];
    return self;
}

- (void)dealloc {
    if ( _volumeDidChangeToken ) [NSNotificationCenter.defaultCenter removeObserver:_volumeDidChangeToken];
    if ( _brightnessDidChangeToken ) [NSNotificationCenter.defaultCenter removeObserver:_brightnessDidChangeToken];
}
@end


@interface SJDeviceVolumeAndBrightnessManager () {
    SJDeviceBrightnessView *_brightnessView;
    UISlider *_volumeSlider;
}

@property (nonatomic, strong, readonly) UISlider *volumeSlider;
@property (nonatomic, strong, readonly) UIView *brightnessView;
@property (nonatomic, strong, nullable) id brightnessDidChangeToken;
@property (nonatomic, strong, nullable) id volumeDidChangeToken;
@end

@implementation SJDeviceVolumeAndBrightnessManager
@synthesize brightness = _brightness;
@synthesize targetView = _targetView;

+ (instancetype)shared {
    static id s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [self new];
    });
    return s;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    for ( UIView *subview in [[MPVolumeView new] subviews] ) {
        if ( [subview.class.description isEqualToString:@"MPVolumeSlider"] ) {
            _volumeSlider = (UISlider *)subview;
            break;
        }
    }
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.brightnessDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:UIScreenBrightnessDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            [self brightnessDidChange];
        }];
        
        sjkvo_observe([AVAudioSession sharedInstance], @"outputVolume", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self volumeDidChange];
        });
        
        CGFloat value = [AVAudioSession sharedInstance].outputVolume;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.volume = value;
        });
    });
    return self;
}

- (id<SJDeviceVolumeAndBrightnessManagerObserver>)getObserver {
    return [[SJDeviceVolumeAndBrightnessManagerObserver alloc] initWithMgr:self];
}

- (void)volumeDidChange {
    [NSNotificationCenter.defaultCenter postNotificationName:SJDeviceVolumeDidChangeNotification object:self];
}

- (void)brightnessDidChange {
    [NSNotificationCenter.defaultCenter postNotificationName:SJDeviceBrightnessDidChangeNotification object:self];
}

- (void)dealloc {
    if ( _brightnessDidChangeToken ) [NSNotificationCenter.defaultCenter removeObserver:_brightnessDidChangeToken];
}

- (SJDeviceBrightnessView *)brightnessView {
    if ( !_brightnessView ) {
        SJDeviceBrightnessView *brightnessView = [SJDeviceBrightnessView new];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [SJDeviceVolumeAndBrightnessManagerResourceLoader imageNamed:@"sj_video_player_brightness"];
            NSString *brightnessText = [SJDeviceVolumeAndBrightnessManagerResourceLoader localizedStringForKey:SJVolBrigControlBrightnessText];
            dispatch_async(dispatch_get_main_queue(), ^{
                brightnessView.image = image;
                brightnessView.titleLabel.text = brightnessText;
            });
        });
        _brightnessView = brightnessView;
    }
    _brightnessView.value = self.brightness;
    _brightnessView.alpha = 0.001;
    return _brightnessView;
}

@synthesize volume = _volume;
- (void)setVolume:(float)volume {
    if ( isnan(volume) )
        return;
    
    if ( volume < 0 )
        volume = 0;
    else if ( volume > 1 )
        volume = 1;
    
    _volume = volume;
    _volumeSlider.value = volume;

    [NSNotificationCenter.defaultCenter postNotificationName:SJDeviceVolumeDidChangeNotification object:self];
}

- (float)volume {
    return _volume;
}

- (void)setBrightness:(float)brightness {
    if ( isnan(brightness) )
        return;
    
    if ( brightness < 0 )
        brightness = 0;
    else if ( brightness > 1 )
        brightness = 1;
    
    [UIScreen mainScreen].brightness = brightness;
    _brightnessView.value = brightness;
    
    [self _show_brightnessView];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hidden_brightnessView) object:nil];
    [self performSelector:@selector(_hidden_brightnessView) withObject:nil afterDelay:0.5];
    
    [NSNotificationCenter.defaultCenter postNotificationName:SJDeviceBrightnessDidChangeNotification object:self];
}

- (float)brightness {
    return [UIScreen mainScreen].brightness;
}

- (void)_show_brightnessView {
    if ( !_brightnessView ) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.brightnessView];
    }
    else {
        [UIApplication.sharedApplication.keyWindow bringSubviewToFront:_brightnessView];
    }
    [_brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(155, 155));
        make.center.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    _brightnessView.transform = _targetView.transform;
    [UIView animateWithDuration:0.25 animations:^{
        self->_brightnessView.alpha = 1;
    }];
}

- (void)_hidden_brightnessView {
    [UIView animateWithDuration:0.25 animations:^{
        self->_brightnessView.alpha = 0.001;
    }];
}
@end
NS_ASSUME_NONNULL_END
