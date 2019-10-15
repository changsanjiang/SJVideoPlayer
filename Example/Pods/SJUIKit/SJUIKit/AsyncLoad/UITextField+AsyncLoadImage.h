//
//  UITextField+AsyncLoadImage.h
//  LWZBarrageKit
//
//  Created by BlueDancer on 2019/9/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (AsyncLoadImage)

- (void)asyncLoadBackgroundImage:(UIImage *_Nullable(^)(void))imageBlock;

@end

NS_ASSUME_NONNULL_END
