//
//  SJFilmEditingStatus.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJFilmEditingStatus_h
#define SJFilmEditingStatus_h

typedef NS_ENUM(NSUInteger, SJFilmEditingStatus) {
    SJFilmEditingStatus_Unknown,
    SJFilmEditingStatus_Recording,
    SJFilmEditingStatus_Cancelled,
    SJFilmEditingStatus_Paused,
    SJFilmEditingStatus_Finished,
};

#endif /* SJFilmEditingStatus_h */
