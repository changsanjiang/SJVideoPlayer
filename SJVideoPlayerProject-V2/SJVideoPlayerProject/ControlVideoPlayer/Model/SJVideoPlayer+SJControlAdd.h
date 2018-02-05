//
//  SJVideoPlayer+SJControlAdd.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"
#import "SJVideoPlayerMoreSetting.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const SJVideoPlayerSetMoreSettingsNotification;

@interface SJVideoPlayer (SJControlAdd)

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@end

NS_ASSUME_NONNULL_END
