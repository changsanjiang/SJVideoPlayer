//
//  SJUIFactory.h
//  LanWuZheiOS
//
//  Created by BlueDancer on 2017/11/4.
//  Copyright © 2017年 lanwuzhe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SJUIFactory : NSObject

+ (instancetype)sharedManager;

@property (class, nonatomic, assign, readonly) BOOL isiPhoneX;


+ (UIFont *)getFontWithViewHeight:(CGFloat)height;


+ (UIFont *)getBoldFontWithViewHeight:(CGFloat)height;

+ (void)commonShadowWithView:(UIView *)view;

+ (void)regulate:(UIView *)view cornerRadius:(CGFloat)cornerRadius;

+ (void)boundaryProtectedWithView:(UIView *)view;


#pragma mark - View
/// backgroundColor if nil, it will be set clear.
+ (UIView *)viewWithBackgroundColor:(UIColor *)backgroundColor;



+ (UIView *)viewWithBackgroundColor:(UIColor *)backgroundColor frame:(CGRect)frame;


+ (UIView *)roundViewWithBackgroundColor:(UIColor *)color;


+ (UIView *)lineViewWithHeight:(CGFloat)height lineColor:(UIColor *)color;



#pragma mark - ScrollView
+ (UIScrollView *)scrollViewWithContentSize:(CGSize)contentSize pagingEnabled:(BOOL)pagingEnabled;




#pragma mark - TableView
/// backgroundColor if nil, it will be set clear.
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




#pragma mark - Collection View
+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor;

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)direction;

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)direction headerSize:(CGSize)headerSize footerSize:(CGSize)footerSize;

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)scrollDirection minimumLineSpacing:(CGFloat)minimumLineSpacing minimumInteritemSpacing:(CGFloat)minimumInteritemSpacing;




#pragma mark - Label
+ (UILabel *)labelWithFont:(UIFont *)font
                 textColor:(UIColor *)textColor;

+ (UILabel *)labelWithFont:(UIFont *)font
                 textColor:(UIColor *)textColor
                 alignment:(NSTextAlignment)alignment;

/// textColor if nil, it will be set white.
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



#pragma mark - UIButton
+ (UIButton *)buttonWithTarget:(id)target sel:(SEL)sel;

+ (UIButton *)buttonWithTarget:(id)target sel:(SEL)sel tag:(NSInteger)tag;

+ (UIButton *)buttonWithBackgroundColor:(UIColor *)color
                                 target:(id)target
                                    sel:(SEL)sel;
+ (UIButton *)buttonWithBackgroundColor:(UIColor *)color
                                 target:(id)target
                                    sel:(SEL)sel
                                    tag:(NSInteger)tag;

+ (UIButton *)buttonWithImageName:(NSString *)imageName;

+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor;

+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor imageName:(NSString *)imageName;

/// titleColor if nil, it will be set white.
/// backgroundColor if nil, it will be set clear.
/// height is show ( font + space ) height.
/// if the height is equal to 0, this will not set it.
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



#pragma mark - ImageView
+ (UIImageView *)imageViewWithViewMode:(UIViewContentMode)mode;

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName
                               viewMode:(UIViewContentMode)mode;


/// viewMode -> UIViewContentModeScaleAspectFit
+ (UIImageView *)imageViewWithImageName:(NSString *)imageName;



+ (UIImageView *)imageViewWithBackgroundColor:(UIColor *)color
                                     viewMode:(UIViewContentMode)mode;



/// viewMode -> UIViewContentModeScaleAspectFit
+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName;



+ (UIImageView *)roundImageViewWithBackgroundColor:(UIColor *)color
                                          viewMode:(UIViewContentMode)mode;



+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName
                                    viewMode:(UIViewContentMode)mode;




#pragma mark - TextField
/// 如果placeholderColor不为nil, 则设置为 attr. 否则设置是default
/// textColor if nil, it will be set black.
/// height is show ( font + space ) height.
/// backgroundColor if nil, it will be set clear.
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




#pragma mark - TextView
+ (UITextView *)textViewWithTextColor:(UIColor *)textColor
                      backgroundColor:(UIColor *)backgroundColor
                                 font:(UIFont *)font;



#pragma mark - ImagePickerViewController
- (void)
alterPickerViewControllerWithController:(UIViewController *)controller
                             alertTitle:(NSString *)title
                                    msg:(NSString *)msg
                           photoLibrary:(void(^)(UIImage *selectedImage))photoLibraryBlock
                                 camera:(void(^)(UIImage *selectedImage))cameraBlock;

@end

