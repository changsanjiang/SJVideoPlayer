//
//  SJLoadFailedControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJLoadFailedControlLayer.h"
#import "UIView+SJVideoPlayerSetting.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJLoadFailedControlLayer ()
@end

@implementation SJLoadFailedControlLayer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    self.promptLabel.text = SJEdgeControlLayerSettings.commonSettings.playFailedText;
    [self.reloadView.button setTitle:SJEdgeControlLayerSettings.commonSettings.playFailedButtonText forState:UIControlStateNormal];
    self.reloadView.backgroundColor = SJEdgeControlLayerSettings.commonSettings.playFailedButtonBackgroundColor;
    return self;
}
@end
NS_ASSUME_NONNULL_END
