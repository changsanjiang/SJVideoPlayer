//
//  NSDate+SJAdded.h
//  SJUIKit
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSDate (SJAdded)
@property (nonatomic, strong, readonly) NSString *sj_yyyy_MM_dd_HH_mm_ss;
@property (nonatomic, strong, readonly) NSString *sj_yyyy_MM_dd_HH_mm;
@property (nonatomic, strong, readonly) NSString *sj_yyyy_MM_dd;
@property (nonatomic, strong, readonly) NSString *sj_HH_mm_ss;
@property (nonatomic, strong, readonly) NSString *sj_yyyy;
@property (nonatomic, strong, readonly) NSString *sj_MM;
@property (nonatomic, strong, readonly) NSString *sj_dd;
@property (nonatomic, strong, readonly) NSString *sj_HH;
@property (nonatomic, strong, readonly) NSString *sj_mm;
@property (nonatomic, strong, readonly) NSString *sj_ss;
@end
NS_ASSUME_NONNULL_END
