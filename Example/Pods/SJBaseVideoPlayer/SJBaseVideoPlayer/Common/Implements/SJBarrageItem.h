//
//  SJBarrageItem.h
//  Pods
//
//  Created by BlueDancer on 2019/11/12.
//

#import <Foundation/Foundation.h>
#import "SJBarrageQueueControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBarrageItem : NSObject<SJBarrageItem>
- (instancetype)initWithContent:(NSAttributedString *)content;
- (instancetype)initWithCustomView:(__kindof UIView *)customView;

@property (nonatomic, copy, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) __kindof UIView *customView;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
