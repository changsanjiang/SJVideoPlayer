//
//  SJResidentThread.h
//  Pods
//
//  Created by 畅三江 on 2019/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJResidentThread : NSObject
- (void)performBlock:(void(^)(void))block;
@end
NS_ASSUME_NONNULL_END
