//
//  LWZTableSectionShrinker.h
//  LWZAudioModule_Example
//
//  Created by BlueDancer on 2018/9/3.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface LWZTableSectionShrinker<ObjectType> : NSObject
- (instancetype)initWithTitle:(nullable id)title
              titleWhenShrank:(nullable id)titleWhenShrank
                      dataArr:(nullable NSArray<ObjectType> *)dataArr;

@property (nonatomic, readonly, getter=isShrink) BOOL shrink;
- (void)switchingStatus;
- (nullable NSArray<ObjectType> *)dataArrByShrinkStatus;
- (nullable id)titleForShrinkStatus;

- (void)resetDataArr:(nullable NSArray<ObjectType> *)dataArr;
@end
NS_ASSUME_NONNULL_END
