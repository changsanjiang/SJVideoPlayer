//
//  SJScrollToolbarItem.h
//  SJScrollToolbar
//
//  Created by 畅三江 on 2019/12/23.
//

#import <Foundation/Foundation.h>
#import "SJScrollToolbarDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollToolbarItem : NSObject<SJScrollToolbarItem>
- (instancetype)initWithTitle:(nullable NSString *)title;
- (instancetype)initWithTitle:(nullable NSString *)title imageUrl:(nullable NSString *)imageUrl;
- (instancetype)initWithAttributedString:(nullable NSAttributedString *)attributedString;
- (instancetype)initWithImage:(nullable UIImage *)image;

@property (nonatomic, copy, nullable) NSAttributedString *attributedString;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *imageUrl;
@property (nonatomic, strong, nullable) UIImage *image;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
