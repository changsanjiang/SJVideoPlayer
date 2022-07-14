//
//  NSObject+SJ.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/7/14.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SJ)
@property (nonatomic, strong, class, readonly) NSArray<NSString *> *csj_invarList;
@property (nonatomic, strong, class, readonly) NSArray<NSString *> *csj_methodList;
@property (nonatomic, strong, class, readonly) NSArray<NSString *> *csj_propertyList;
@property (nonatomic, strong, class, readonly) NSArray<NSString *> *csj_protocolList;
@property (nonatomic, strong, class, readonly) NSArray<NSString *> *csj_invarTypeList;
@end

NS_ASSUME_NONNULL_END
