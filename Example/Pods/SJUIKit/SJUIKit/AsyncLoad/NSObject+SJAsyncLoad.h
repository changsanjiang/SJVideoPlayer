//
//  NSObject+SJAsyncLoad.h
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/24.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (SJAsyncLoad)
- (void)sj_asyncLoad:(id _Nullable(^)(void))loadBlock forKey:(NSString *)key;

- (void)sj_asyncLoad:(id  _Nullable (^)(void))loadBlock
              forKey:(NSString *)key
   completionHandler:(nullable void(^)(void))completionHandler;
@end
NS_ASSUME_NONNULL_END
