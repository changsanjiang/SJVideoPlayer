//
//  SJUIFactory.h
//  LanWuZheiOS
//
//  Created by BlueDancer on 2017/11/4.
//  Copyright © 2017年 lanwuzhe. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGSize SJScreen_Size(void);
extern float SJScreen_W(void);
extern float SJScreen_H(void);
extern float SJScreen_Min(void);
extern float SJScreen_Max(void);
extern BOOL SJ_is_iPhoneX(void);

#pragma mark -

@interface SJUIFactory : NSObject

+ (instancetype)sharedManager;

+ (UIFont *)getFontWithViewHeight:(CGFloat)height;

+ (UIFont *)getBoldFontWithViewHeight:(CGFloat)height;

+ (void)commonShadowWithView:(UIView *)view;

+ (void)regulate:(UIView *)view cornerRadius:(CGFloat)cornerRadius;

+ (void)boundaryProtectedWithView:(UIView *)view;

@end


#pragma mark -
/*!
 *  backgroundColor if nil, it will be set clear.
 **/
@interface SJUIViewFactory : NSObject

+ (UIView *)viewWithBackgroundColor:(UIColor *)backgroundColor;

+ (UIView *)viewWithBackgroundColor:(UIColor *)backgroundColor
                              frame:(CGRect)frame;

+ (__kindof UIView *)viewWithSubClass:(Class)subClass
                      backgroundColor:(UIColor *)backgroundColor;

+ (__kindof UIView *)viewWithSubClass:(Class)subClass
                      backgroundColor:(UIColor *)backgroundColor
                                frame:(CGRect)frame;

+ (UIView *)roundViewWithBackgroundColor:(UIColor *)color;

+ (UIView *)lineViewWithHeight:(CGFloat)height
                     lineColor:(UIColor *)color;

@end


#pragma mark -
@interface SJScrollViewFactory : NSObject

+ (UIScrollView *)scrollViewWithContentSize:(CGSize)contentSize
                              pagingEnabled:(BOOL)pagingEnabled;

@end


#pragma mark -
/// backgroundColor if nil, it will be set clear.
@interface SJUITableViewFactory : NSObject

+ (UITableView *)tableViewWithStyle:(UITableViewStyle)style
                    backgroundColor:(UIColor *)backgroundColor
                     separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
       showsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
                           delegate:(id<UITableViewDelegate>)delegate
                         dataSource:(id<UITableViewDataSource>)dataSource;



+ (__kindof UITableView *)tableViewWithSubClass:(Class)subClass
                                          style:(UITableViewStyle)style
                                backgroundColor:(UIColor *)backgroundColor
                                 separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
                   showsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
                                       delegate:(id<UITableViewDelegate>)delegate
                                     dataSource:(id<UITableViewDataSource>)dataSource;



+ (void)settingTableView:(UITableView *)tableView
               rowHeight:(CGFloat)rowHeight
     sectionHeaderHeight:(CGFloat)sectionHeaderHeight
     sectionFooterHeight:(CGFloat)sectionFooterHeight;



+ (void)settingTableView:(UITableView *)tableView
      estimatedRowHeight:(CGFloat)estimatedRowHeight
estimatedSectionHeaderHeight:(CGFloat)estimatedSectionHeaderHeight
estimatedSectionFooterHeight:(CGFloat)estimatedSectionFooterHeight;

@end


#pragma mark -
@interface SJUICollectionViewFactory : NSObject

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor;

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)direction;

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)direction headerSize:(CGSize)headerSize footerSize:(CGSize)footerSize;

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)scrollDirection minimumLineSpacing:(CGFloat)minimumLineSpacing minimumInteritemSpacing:(CGFloat)minimumInteritemSpacing;

@end


#pragma mark -
/*!
 *  textColor if nil, it will be set white.
 *  font if nil, it will be set 14.
 **/
@interface SJUILabelFactory : NSObject

+ (UILabel *)labelWithFont:(UIFont *)font;

+ (UILabel *)labelWithFont:(UIFont *)font
                 textColor:(UIColor *)textColor;

+ (UILabel *)labelWithFont:(UIFont *)font
                 textColor:(UIColor *)textColor
                 alignment:(NSTextAlignment)alignment;

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor;

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor
                 alignment:(NSTextAlignment)alignment;

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor
                 alignment:(NSTextAlignment)alignment
                      font:(UIFont *)font;

+ (UILabel *)labelWithAttrStr:(NSAttributedString *)attrStr;


+ (void)settingLabelWithLabel:(UILabel *)label
                         text:(NSString *)text
                    textColor:(UIColor *)textColor
                    alignment:(NSTextAlignment)alignment
                         font:(UIFont *)font
                      attrStr:(NSAttributedString *)attrStr;

@end


#pragma mark -
/*!
 *  titleColor if nil, it will be set white.
 *  backgroundColor if nil, it will be set clear.
 **/
@interface SJUIButtonFactory : NSObject

+ (UIButton *)buttonWithTarget:(id)target
                           sel:(SEL)sel;

+ (UIButton *)buttonWithTarget:(id)target
                           sel:(SEL)sel
                           tag:(NSInteger)tag;

+ (UIButton *)buttonWithBackgroundColor:(UIColor *)color
                                 target:(id)target
                                    sel:(SEL)sel;

+ (UIButton *)buttonWithBackgroundColor:(UIColor *)color
                                 target:(id)target
                                    sel:(SEL)sel
                                    tag:(NSInteger)tag;

+ (UIButton *)buttonWithImageName:(NSString *)imageName;

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor;

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                    imageName:(NSString *)imageName;

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                         font:(UIFont *)font
              backgroundColor:(UIColor *)backgroundColor
                       target:(id)target
                          sel:(SEL)sel
                          tag:(NSInteger)tag;

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
              backgroundColor:(UIColor *)backgroundColor
                    imageName:(NSString *)imageName
                       target:(id)target
                          sel:(SEL)sel
                          tag:(NSInteger)tag;

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                         font:(UIFont *)font
              backgroundColor:(UIColor *)backgroundColor
                    imageName:(NSString *)imageName
                       target:(id)target
                          sel:(SEL)sel
                          tag:(NSInteger)tag;


+ (void)settingButtonWithBtn:(UIButton *)btn
                        font:(UIFont *)font
                       title:(NSString *)title
                  titleColor:(UIColor *)titleColor
             attributedTitle:(NSAttributedString *)attributedTitle
                   imageName:(NSString *)imageName
             backgroundColor:(UIColor *)backgroundColor
                      target:(id)target
                         sel:(SEL)sel
                         tag:(NSInteger)tag;

+ (UIButton *)buttonWithSubClass:(Class)subClass
                           title:(NSString *)title
                      titleColor:(UIColor *)titleColor
                            font:(UIFont *)font
                 backgroundColor:(UIColor *)backgroundColor
                          target:(id)target
                             sel:(SEL)sel
                             tag:(NSInteger)tag;



+ (UIButton *)buttonWithImageName:(NSString *)imageName
                           target:(id)target
                              sel:(SEL)sel
                              tag:(NSInteger)tag;



+ (UIButton *)buttonWithAttributeTitle:(NSAttributedString *)attrStr
                       backgroundColor:(UIColor *)backgroundColor
                                target:(id)target
                                   sel:(SEL)sel
                                   tag:(NSInteger)tag;



+ (UIButton *)roundButtonWithTitle:(NSString *)title
                        titleColor:(UIColor *)titleColor
                              font:(UIFont *)font
                   backgroundColor:(UIColor *)backgroundColor
                            target:(id)target
                               sel:(SEL)sel
                               tag:(NSInteger)tag;



+ (UIButton *)roundButtonWithBoldTitle:(NSString *)title
                            titleColor:(UIColor *)titleColor
                                  font:(UIFont *)font
                       backgroundColor:(UIColor *)backgroundColor
                                target:(id)target
                                   sel:(SEL)sel
                                   tag:(NSInteger)tag;



+ (UIButton *)roundButtonWithImageName:(NSString *)imageName
                                target:(id)target
                                   sel:(SEL)sel
                                   tag:(NSInteger)tag;



+ (UIButton *)roundButtonWithAttributeTitle:(NSAttributedString *)attrStr
                                       font:(UIFont *)font
                            backgroundColor:(UIColor *)backgroundColor
                                     target:(id)target
                                        sel:(SEL)sel
                                        tag:(NSInteger)tag;


@end


#pragma mark -
/*!
 *  viewMode -> UIViewContentModeScaleAspectFit
 **/
@interface SJUIImageViewFactory : NSObject

+ (UIImageView *)imageViewWithBackgroundColor:(UIColor *)color;

+ (UIImageView *)imageViewWithBackgroundColor:(UIColor *)color
                                     viewMode:(UIViewContentMode)mode;

+ (UIImageView *)imageViewWithViewMode:(UIViewContentMode)mode;

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName;

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName
                               viewMode:(UIViewContentMode)mode;


+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName;

+ (UIImageView *)roundImageViewWithBackgroundColor:(UIColor *)color
                                          viewMode:(UIViewContentMode)mode;

+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName
                                    viewMode:(UIViewContentMode)mode;

@end



#pragma mark -
/// 如果placeholderColor不为nil, 则设置为 attr. 否则设置是default
/// textColor if nil, it will be set black.
/// backgroundColor if nil, it will be set clear.
@interface SJUITextFieldFactory : NSObject
+ (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder
                         placeholderColor:(UIColor *)placeholderColor
                                     text:(NSString *)text
                                     font:(UIFont *)font
                                textColor:(UIColor *)textColor
                             keyboardType:(UIKeyboardType)keyboardType
                            returnKeyType:(UIReturnKeyType)returnKeyType
                          backgroundColor:(UIColor *)backgroundColor;



+ (UITextField *)textFieldWithAttrPlaceholder:(NSAttributedString *)placeholder
                                         text:(NSString *)text
                                         font:(UIFont *)font
                                    textColor:(UIColor *)textColor
                                 keyboardType:(UIKeyboardType)keyboardType
                                returnKeyType:(UIReturnKeyType)returnKeyType
                              backgroundColor:(UIColor *)backgroundColor;



+ (void)textField:(UITextField *)textField setPlaceholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor;



+ (void)textField:(UITextField *)textField setLeftSpace:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace;

@end


#pragma mark -
@interface SJUITextViewFactory : NSObject

+ (UITextView *)textViewWithTextColor:(UIColor *)textColor
                      backgroundColor:(UIColor *)backgroundColor
                                 font:(UIFont *)font;

@end


#pragma mark -
@interface SJUIImagePickerControllerFactory : NSObject

+ (instancetype)shared;

- (void)alterPickerViewControllerWithController:(UIViewController *)controller
                                     alertTitle:(NSString *)title
                                            msg:(NSString *)msg
                                   photoLibrary:(void(^)(UIImage *selectedImage))photoLibraryBlock
                                         camera:(void(^)(UIImage *selectedImage))cameraBlock;
@end
