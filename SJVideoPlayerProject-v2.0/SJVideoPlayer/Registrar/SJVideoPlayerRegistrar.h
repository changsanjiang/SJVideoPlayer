//
//  SJVideoPlayerRegistrar.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SJVideoPlayerBackstageState) {
    SJVideoPlayerBackstageState_Normal,
    SJVideoPlayerBackstageState_Forground,
    SJVideoPlayerBackstageState_Background,
    SJVideoPlayerBackstageState_UserClickedPause,
};

@interface SJVideoPlayerRegistrar : NSObject

@property (nonatomic, assign) SJVideoPlayerBackstageState state;

@end
