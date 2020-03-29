//
//  SJPageMenuItemView.h
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/11.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPageMenuItemViewDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPageMenuItemView : UIView<SJPageMenuItemView>
@property (nonatomic, strong, null_resettable) UIFont *font;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
@end
NS_ASSUME_NONNULL_END
