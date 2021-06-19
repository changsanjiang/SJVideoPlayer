//
//  SJPlaybackListControllerDefines.h
//  SJPlaybackListController
//
//  Created by 蓝舞者 on 2021/6/17.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#ifndef SJPlaybackListControllerDefines_h
#define SJPlaybackListControllerDefines_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SJPlaybackMode) {
    SJPlaybackModeInOrder,         // 顺序播放
    SJPlaybackModeRepeatOne,       // 单曲循环
    SJPlaybackModeShuffle,         // 随机
};

typedef NS_OPTIONS(NSUInteger, SJPlaybackModeMask) {
    SJPlaybackModeMaskInOrder   = 1 << SJPlaybackModeInOrder,
    SJPlaybackModeMaskRepeatOne = 1 << SJPlaybackModeRepeatOne,
    SJPlaybackModeMaskShuffle   = 1 << SJPlaybackModeShuffle,
    
    SJPlaybackModeMaskAll = SJPlaybackModeMaskInOrder |
                            SJPlaybackModeMaskRepeatOne |
                            SJPlaybackModeMaskShuffle,
};

#endif /* SJPlaybackListControllerDefines_h */
