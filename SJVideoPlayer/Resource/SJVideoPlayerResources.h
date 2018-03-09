//
//  SJVideoPlayerResources.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const SJVideoPlayer_ReplayText;
UIKIT_EXTERN NSString *const SJVideoPlayer_PreviewText;
UIKIT_EXTERN NSString *const SJVideoPlayer_PlayFailedText;
UIKIT_EXTERN NSString *const SJVideoPlayer_NotReachablePrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_ReachableViaWWANPrompt;
UIKIT_EXTERN NSString *const SJVideoPlayer_CancelBtnTitle;
UIKIT_EXTERN NSString *const SJVideoPlayer_RecordTipsText;


@interface SJVideoPlayerResources : NSObject

+ (UIImage *)imageNamed:(NSString *)name;

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName;

+ (NSString *)localizedStringForKey:(NSString *)key;

@end
