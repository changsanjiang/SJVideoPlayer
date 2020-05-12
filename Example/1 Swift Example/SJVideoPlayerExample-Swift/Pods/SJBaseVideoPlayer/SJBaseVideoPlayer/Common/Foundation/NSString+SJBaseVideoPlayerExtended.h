//
//  NSString+SJBaseVideoPlayerExtended.h
//  Pods
//
//  Created by 畅三江 on 2019/12/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSString (SJBaseVideoPlayerExtended)

+ (instancetype)stringWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;

@end
NS_ASSUME_NONNULL_END
