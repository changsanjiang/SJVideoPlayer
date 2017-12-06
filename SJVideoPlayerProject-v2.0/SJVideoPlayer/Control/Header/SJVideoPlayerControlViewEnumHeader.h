//
//  SJVideoPlayerControlViewEnumHeader.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#ifndef SJVideoPlayerControlViewEnumHeader_h
#define SJVideoPlayerControlViewEnumHeader_h

typedef NS_ENUM(NSUInteger, SJVideoPlayControlViewTag) {
    SJVideoPlayControlViewTag_Back,
    SJVideoPlayControlViewTag_Full,
    SJVideoPlayControlViewTag_Play,
    SJVideoPlayControlViewTag_Pause,
    SJVideoPlayControlViewTag_Replay,
    SJVideoPlayControlViewTag_Preview,
    SJVideoPlayControlViewTag_Lock,
    SJVideoPlayControlViewTag_Unlock,
    SJVideoPlayControlViewTag_LoadFailed,
    SJVideoPlayControlViewTag_More,
};




typedef NS_ENUM(NSUInteger, SJVideoPlaySliderTag) {
    SJVideoPlaySliderTag_Volume,
    SJVideoPlaySliderTag_Brightness,
    SJVideoPlaySliderTag_Rate,
    SJVideoPlaySliderTag_Progress,
    SJVideoPlaySliderTag_Dragging,
};


//#define SJ_S_W ([UIScreen mainScreen].bounds.size.width)
//#define SJ_S_H ([UIScreen mainScreen].bounds.size.height)
//#define SJ_is_iPhone_X (MIN(SJ_S_W, SJ_S_H) / MAX(SJ_S_W, SJ_S_H) == 1125.0 / 2436)

#endif /* SJVideoPlayerControlViewEnumHeader_h */
