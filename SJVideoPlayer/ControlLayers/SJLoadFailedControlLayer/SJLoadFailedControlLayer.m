//
//  SJLoadFailedControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJLoadFailedControlLayer.h"
#import "SJVideoPlayerSettings.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJLoadFailedControlLayer ()
@end

@implementation SJLoadFailedControlLayer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _updateSettings];
    return self;
}

- (void)_updateSettings {
    SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
    [self.reloadView.button setTitle:sources.playFailedButtonText forState:UIControlStateNormal];
    self.reloadView.backgroundColor = sources.playFailedButtonBackgroundColor;
    self.promptLabel.text = sources.playFailedText;
}
@end
NS_ASSUME_NONNULL_END
