//
//  SJAsyncLoader.h
//  SJUIKit_Example
//
//  Created by BlueDancer on 2018/12/21.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJAsyncLoader : NSObject
- (instancetype)initWithBlock:(id _Nullable(^)(void))loadBlock completionHandler:(void(^)(id _Nullable result))completionHandler;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
