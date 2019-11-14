//
//  SJBarrageViewModel.h
//  Pods
//
//  Created by BlueDancer on 2019/11/12.
//

#import <Foundation/Foundation.h>
#import "SJBarrageQueueControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBarrageViewModel : NSObject
- (instancetype)initWithBarrageItem:(id<SJBarrageItem>)item;

@property (nonatomic, copy, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) __kindof UIView *customView;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval nextBarrageStartTime;
@property (nonatomic) NSTimeInterval delay;
@end
NS_ASSUME_NONNULL_END
