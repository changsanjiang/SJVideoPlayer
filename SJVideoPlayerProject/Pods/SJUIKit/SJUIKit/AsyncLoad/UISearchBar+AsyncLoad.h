//
//  UISearchBar+AsyncLoad.h
//  Pods
//
//  Created by BlueDancer on 2019/1/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UISearchBar (AsyncLoad)
- (void)asyncLoadIconImage:(UIImage *_Nullable(^)(void))imageBlock forSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state;

- (void)asyncLoadSearchFieldBackgroundImage:(UIImage *_Nullable(^)(void))imageBlock forState:(UIControlState)state;
@end
NS_ASSUME_NONNULL_END
