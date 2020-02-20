//
//  SJFullscreenCustomStatusBar.m
//  Pods
//
//  Created by 畅三江 on 2019/12/11.
//

#import "SJFullscreenCustomStatusBar.h"
#import "SJVideoPlayerSettings.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
#define _SJBatteryChargingColor  [UIColor colorWithRed:67/255.0 green:205/255.0 blue:90/255.0 alpha:1]
#define _SJBatteryUnpluggedColor [UIColor whiteColor]

@interface _SJBatteryView : UIImageView
@property (nonatomic) UIDeviceBatteryState batteryState;
@property (nonatomic) float batteryLevel;
@property (nonatomic, strong, readonly) UIView *chargeView;
@property (nonatomic, strong, readonly) UIImageView *lightningImageView;
@end

@implementation _SJBatteryView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _chargeView = [UIView.alloc initWithFrame:CGRectZero];
        _chargeView.layer.cornerRadius = 1;
        [self addSubview:_chargeView];
        
        _lightningImageView = [UIImageView.alloc initWithFrame:CGRectZero];
        _lightningImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_lightningImageView];
        [_lightningImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
        }];
    }
    return self;
}

- (void)setBatteryState:(UIDeviceBatteryState)batteryState {
    if ( batteryState != _batteryState ) {
        _batteryState = batteryState;
        [self _reload];
    }
}

- (void)setBatteryLevel:(float)batteryLevel {
    if ( batteryLevel != _batteryLevel ) {
        _batteryLevel = batteryLevel;
        [self _reload];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _reload];
}

- (void)_reload {
    CGRect bounds = self.bounds;
    CGFloat padding = 2;
    
    CGFloat charge = (bounds.size.width - padding * 2) * _batteryLevel;
    if ( charge < 1 ) charge = 1;
    _chargeView.frame = CGRectMake(padding, padding, charge, bounds.size.height - padding * 2);
    
    switch ( _batteryState ) {
        case UIDeviceBatteryStateUnknown:
        case UIDeviceBatteryStateUnplugged: {
            _chargeView.backgroundColor = _SJBatteryUnpluggedColor;
            _lightningImageView.hidden = YES;
        }
            break;
        case UIDeviceBatteryStateCharging:
        case UIDeviceBatteryStateFull: {
            _chargeView.backgroundColor = _SJBatteryChargingColor;
            _lightningImageView.hidden = NO;
        }
            break;
    }
}
@end

@interface SJFullscreenCustomStatusBar ()
@property (nonatomic, strong, readonly) UILabel *networkStatusLabel;
@property (nonatomic, strong, readonly) UILabel *timeLabel;

@property (nonatomic, strong, readonly) UIImageView *batteryNubImageView;
@property (nonatomic, strong, readonly) _SJBatteryView *batteryView;
@property (nonatomic, strong, readonly) UILabel *chargeLabel;

@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;
@end

@implementation SJFullscreenCustomStatusBar
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _dateFormatter = NSDateFormatter.alloc.init;
        _dateFormatter.dateFormat = @"HH:mm";
        
        [self _setupViews];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_updateSettings) name:SJVideoPlayerSettingsUpdatedNotification object:nil];
        [self _updateSettings];
        [self _reload];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setNetworkStatus:(SJNetworkStatus)networkStatus {
    if ( networkStatus != _networkStatus ) {
        _networkStatus = networkStatus;
        [self _reload];
    }
}

- (void)setDate:(nullable NSDate *)date {
    _date = date;
    [self _reload];
}

- (void)setBatteryState:(UIDeviceBatteryState)batteryState {
    if ( batteryState != _batteryState ) {
        _batteryState = batteryState;
        [self _reload];
    }
}

- (void)setBatteryLevel:(float)batteryLevel {
    if ( batteryLevel != _batteryLevel ) {
        _batteryLevel = batteryLevel;
        [self _reload];
    }
}

- (void)_reload {
    SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
    switch ( _networkStatus ) {
        case SJNetworkStatus_NotReachable:
            _networkStatusLabel.text = sources.statusBarNoNetworkText;
            break;
        case SJNetworkStatus_ReachableViaWWAN:
            _networkStatusLabel.text = sources.statusBarCellularNetworkText;
            break;
        case SJNetworkStatus_ReachableViaWiFi:
            _networkStatusLabel.text = sources.statusBarWiFiText;
            break;
    }
    
    _timeLabel.text = [_dateFormatter stringFromDate:_date];
    _chargeLabel.text = [NSString stringWithFormat:@"%d%%", (int)(_batteryLevel * 100)];
    _batteryView.batteryLevel = _batteryLevel;
    _batteryView.batteryState = _batteryState;
}

#pragma mark -

- (void)_setupViews {
    UIColor *textColor = [UIColor whiteColor];
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    
    _networkStatusLabel = [UILabel.alloc initWithFrame:CGRectZero];
    _networkStatusLabel.textColor = textColor;
    _networkStatusLabel.font = font;
    [self addSubview:_networkStatusLabel];
    
    _timeLabel = [UILabel.alloc initWithFrame:CGRectZero];
    _timeLabel.textColor = textColor;
    _timeLabel.font = font;
    [self addSubview:_timeLabel];
    
    _chargeLabel = [UILabel.alloc initWithFrame:CGRectZero];
    _chargeLabel.textColor = textColor;
    _chargeLabel.font = font;
    [self addSubview:_chargeLabel];
    
    _batteryView = [_SJBatteryView.alloc initWithFrame:CGRectZero];
    _batteryView.contentMode = UIViewContentModeCenter;
    [self addSubview:_batteryView];
    
    _batteryNubImageView = [UIImageView.alloc initWithFrame:CGRectZero];
    _batteryNubImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_batteryNubImageView];
    
    [_networkStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(8);
        make.centerY.offset(0);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_chargeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.batteryView.mas_left).offset(-5);
        make.centerY.offset(0);
    }];
    
    [_batteryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.batteryNubImageView.mas_left).offset(-1);
        make.centerY.offset(0);
    }];
    
    [_batteryNubImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-8);
        make.centerY.offset(0);
    }];
}

- (void)_updateSettings {
    SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
    _batteryNubImageView.image = sources.batteryNubImage;
    _batteryView.image = sources.batteryBorderImage;
    _batteryView.lightningImageView.image = sources.batteryLightningImage;
}
@end
NS_ASSUME_NONNULL_END
