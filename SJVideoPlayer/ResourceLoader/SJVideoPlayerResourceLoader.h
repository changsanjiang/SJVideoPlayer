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

@property (class, nonatomic, readonly) NSBundle *preferredLanguageBundle;
@property (class, nonatomic, readonly) NSBundle *enBundle;
@property (class, nonatomic, readonly) NSBundle *zhHansBundle; // 简体中文
@property (class, nonatomic, readonly) NSBundle *zhHantBundle; // 繁體中文
@end
NS_ASSUME_NONNULL_END
