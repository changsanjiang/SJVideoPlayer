//
//  SJDanmakuItem.h
//  Pods
//
//  Created by 畅三江 on 2019/11/12.
//

#import <Foundation/Foundation.h>
#import "SJDanmakuPopupControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJDanmakuItem : NSObject<SJDanmakuItem>
- (instancetype)initWithContent:(NSAttributedString *)content;
- (instancetype)initWithCustomView:(__kindof UIView *)customView;

@property (nonatomic, copy, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) __kindof UIView *customView;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
