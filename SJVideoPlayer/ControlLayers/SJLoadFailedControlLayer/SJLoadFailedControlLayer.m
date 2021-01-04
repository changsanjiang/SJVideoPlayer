//
//  SJLoadFailedControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJLoadFailedControlLayer.h"
#import "SJVideoPlayerConfigurations.h"

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
    id<SJVideoPlayerControlLayerResources> resources = SJVideoPlayerConfigurations.shared.resources;
    id<SJVideoPlayerLocalizedStrings> strings = SJVideoPlayerConfigurations.shared.localizedStrings;
    [self.reloadView.button setTitle:strings.reload forState:UIControlStateNormal];
    self.reloadView.backgroundColor = resources.playFailedButtonBackgroundColor;
    self.promptLabel.text = strings.playbackFailedPrompt;
}
@end
NS_ASSUME_NONNULL_END
