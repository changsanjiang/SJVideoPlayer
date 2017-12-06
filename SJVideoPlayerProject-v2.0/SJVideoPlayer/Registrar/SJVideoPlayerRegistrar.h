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
    SJVideoPlayerBackstageState_Forground,  // 从后台进入前台
    SJVideoPlayerBackstageState_Background, // 从前台进入后台
};

@interface SJVideoPlayerRegistrar : NSObject

@property (nonatomic, assign) SJVideoPlayerBackstageState state;

@property (nonatomic, assign) BOOL userClickedPause;

- (void)reset;

@end
