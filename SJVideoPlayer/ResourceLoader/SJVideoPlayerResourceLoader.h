//
//  SJVideoPlayerResourceLoader.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerResourceLoader : NSObject
+ (nullable UIImage *)imageNamed:(NSString *)name;
+ (nullable NSString *)localizedStringForKey:(NSString *)key;
///
/// 多语言切换
///
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(void));
@end
NS_ASSUME_NONNULL_END
