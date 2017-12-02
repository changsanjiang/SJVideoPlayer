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
    SJVideoPlayerPlayStateUnknown = 0,
    SJVideoPlayerPlayStateCaching,
    SJVideoPlayerPlayStateError,
    SJVideoPlayerPlayStatePlaying,
    SJVideoPlayerPlayStatePausing,
    SJVideoPlayerPlayStateStopped,
};

#endif /* SJVideoPlayerState_h */
