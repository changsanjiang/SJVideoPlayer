//
//  SJVideoPlayerState.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#ifndef SJVideoPlayerState_h
#define SJVideoPlayerState_h

typedef NS_ENUM(NSUInteger, SJVideoPlayerPlayState) {
    SJVideoPlayerPlayState_Unknown = 0,
    SJVideoPlayerPlayState_Prepare,
    SJVideoPlayerPlayState_Playing,
    SJVideoPlayerPlayState_Buffing,
    SJVideoPlayerPlayState_Paused,
    SJVideoPlayerPlayState_PlayEnd,
    SJVideoPlayerPlayState_PlayFailed,
};

#endif /* SJVideoPlayerState_h */
