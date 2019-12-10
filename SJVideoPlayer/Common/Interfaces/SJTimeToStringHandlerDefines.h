//
//  SJTimeToStringHandlerDefines.h
//  Pods
//
//  Created by BlueDancer on 2019/11/27.
//

#ifndef SJTimeToStringHandlerDefines_h
#define SJTimeToStringHandlerDefines_h

NS_ASSUME_NONNULL_BEGIN
@protocol SJTimeToStringHandler <NSObject>
- (NSString *)stringForSeconds:(NSInteger)secs;
@end
NS_ASSUME_NONNULL_END

#endif /* SJTimeToStringHandlerDefines_h */
