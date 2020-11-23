//
//  SJAsyncLoader.h
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/21.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJAsyncLoader : NSObject
+ (void)asyncLoadWithBlock:(id _Nullable(^)(void))loadBlock completionHandler:(void(^)(id _Nullable result))completionHandler;
@end
NS_ASSUME_NONNULL_END
