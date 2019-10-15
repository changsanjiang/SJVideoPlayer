//
//  UILabel+AsyncLoad.h
//  SJUIKit_Example
//
//  Created by BlueDancer on 2018/12/22.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UILabel (AsyncLoad)

- (void)asyncLoadAttributedString:(NSAttributedString *_Nullable(^)(void))attributedStringBlock;

@end
NS_ASSUME_NONNULL_END
