//
//  SJUIFactory.h
//  LanWuZheiOS
//
//  Created by BlueDancer on 2017/11/4.
//  Copyright © 2017年 lanwuzhe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern CGSize SJScreen_Size(void);
extern float SJScreen_W(void);
extern float SJScreen_H(void);
extern float SJScreen_Min(void);
extern float SJScreen_Max(void);
extern BOOL SJ_is_iPhone5(void);
extern BOOL SJ_is_iPhone6(void);
extern BOOL SJ_is_iPhone6_P(void);
extern BOOL SJ_is_iPhoneX(void);

#pragma mark -

@interface SJUIFactory : NSObject

+ (void)commonShadowWithView:(UIView *)view;

+ (void)commonShadowWithLayer:(CALayer *)layer;

+ (void)commonShadowWithView:(UIView *)view size:(CGSize)size;

+ (void)commonShadowWithView:(UIView *)view size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

+ (void)regulate:(UIView *)view cornerRadius:(CGFloat)cornerRadius;

+ (void)boundaryProtectedWithView:(UIView *)view;

+ (CAShapeLayer *)roundShapeLayerWithSize:(CGSize)size;

+ (CAShapeLayer *)shapeLayerWithSize:(CGSize)size cornerRadius:(float)cornerRadius;

+ (CAShapeLayer *)commonShadowShapeLayerWithSize:(CGSize)size cornerRadius:(float)radius;

+ (UIFont *_Nullable)getFontWithViewHeight:(CGFloat)height;

+ (UIFont *_Nullable)getBoldFontWithViewHeight:(CGFloat)height;

@end


#pragma mark -
/*!
 *  backgroundColor if nil, it will be set clear.
 **/
@interface SJUIViewFactory : NSObject

+ (UIView *)viewWithBackgroundColor:(UIColor * __nullable )backgroundColor;

+ (UIView *)viewWithBackgroundColor:(UIColor * __nullable )backgroundColor
                              frame:(CGRect)frame;

+ (__kindof UIView *)viewWithSubClass:(Class)subClass
                      backgroundColor:(UIColor * __nullable )backgroundColor;

+ (__kindof UIView *)viewWithSubClass:(Class)subClass
                      backgroundColor:(UIColor * __nullable )backgroundColor
                                frame:(CGRect)frame;

+ (UIView *)roundViewWithBackgroundColor:(UIColor * __nullable )color;

+ (UIView *)lineViewWithHeight:(CGFloat)height
                     lineColor:(UIColor * __nullable )color;

+ (UIView *)shadowViewWithCornerRadius:(CGFloat)cornerRadius;

@end

#pragma mark -

@interface SJShapeViewFactory : NSObject

+ (UIView *)viewWithCornerRadius:(float)cornerRadius
                 backgroundColor:(UIColor * __nullable )backgroundColor;

+ (UIView *)shadowViewWithCornerRadius:(CGFloat)cornerRadius
                       backgroundColor:(UIColor * __nullable )backgroundColor;
@end


#pragma mark -
@interface SJScrollViewFactory : NSObject

+ (UIScrollView *)scrollViewWithContentSize:(CGSize)contentSize
                              pagingEnabled:(BOOL)pagingEnabled;

+ (__kindof UIScrollView *)scrollViewWithSubClass:(Class)subClass
                                      contentSize:(CGSize)contentSize
                                    pagingEnabled:(BOOL)pagingEnabled;

@end


#pragma mark -
/// backgroundColor if nil, it will be set clear.
@interface SJUITableViewFactory : NSObject

+ (UITableView *)tableViewWithStyle:(UITableViewStyle)style
                    backgroundColor:(UIColor * __nullable )backgroundColor
                     separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
       showsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
                           delegate:(id<UITableViewDelegate>)delegate
                         dataSource:(id<UITableViewDataSource>)dataSource;



+ (__kindof UITableView *_Nullable)tableViewWithSubClass:(Class)subClass
                                          style:(UITableViewStyle)style
                                backgroundColor:(UIColor * __nullable )backgroundColor
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

+ (UILabel *)labelWithFont:(UIFont * __nullable )font;

+ (UILabel *)labelWithFont:(UIFont * __nullable )font
                 textColor:(UIColor * __nullable )textColor;

+ (UILabel *)labelWithFont:(UIFont * __nullable )font
                 textColor:(UIColor * __nullable )textColor
                 alignment:(NSTextAlignment)alignment;

+ (UILabel *)labelWithText:(NSString * __nullable )text;

+ (UILabel *)labelWithText:(NSString * __nullable )text
                 textColor:(UIColor * __nullable )textColor;

+ (UILabel *)labelWithText:(NSString * __nullable )text
                 textColor:(UIColor * __nullable )textColor
                      font:(UIFont * __nullable )font;

+ (UILabel *)labelWithText:(NSString * __nullable )text
                 textColor:(UIColor * __nullable )textColor
                 alignment:(NSTextAlignment)alignment;

+ (UILabel *)labelWithText:(NSString * __nullable )text
                 textColor:(UIColor * __nullable )textColor
                 alignment:(NSTextAlignment)alignment
                      font:(UIFont * __nullable )font;

+ (UILabel *)attributeLabel;

+ (UILabel *)labelWithAttrStr:(NSAttributedString *)attrStr;

+ (void)settingLabelWithLabel:(UILabel *)label
                         text:(NSString * __nullable )text
                    textColor:(UIColor * __nullable )textColor
                    alignment:(NSTextAlignment)alignment
                         font:(UIFont * __nullable )font
                      attrStr:(NSAttributedString * __nullable )attrStr;

@end




#pragma mark -
/*!
 *  titleColor if nil, it will be set white.
 *  backgroundColor if nil, it will be set clear.
 **/
@interface SJUIButtonFactory : NSObject

+ (UIButton *)buttonWithTarget:(id __nullable )target
                           sel:(SEL __nullable )sel;

+ (UIButton *)buttonWithTarget:(id __nullable )target
                           sel:(SEL __nullable )sel
                           tag:(NSInteger)tag;

+ (UIButton *)buttonWithBackgroundColor:(UIColor * __nullable )color
                                 target:(id __nullable )target
                                    sel:(SEL __nullable )sel;

+ (UIButton *)buttonWithBackgroundColor:(UIColor * __nullable )color
                                 target:(id __nullable )target
                                    sel:(SEL __nullable )sel
                                    tag:(NSInteger)tag;

+ (UIButton *)buttonWithImageName:(NSString * __nullable )imageName;

+ (UIButton *)buttonWithTitle:(NSString * __nullable )title
                   titleColor:(UIColor * __nullable )titleColor;

+ (UIButton *)buttonWithTitle:(NSString * __nullable )title
                   titleColor:(UIColor * __nullable )titleColor
                         font:(UIFont * __nullable )font
                       target:(id __nullable )target
                          sel:(SEL __nullable )sel;

+ (UIButton *)buttonWithTitle:(NSString * __nullable )title
                   titleColor:(UIColor * __nullable )titleColor
                    imageName:(NSString * __nullable )imageName;

+ (UIButton *)buttonWithTitle:(NSString * __nullable )title
                   titleColor:(UIColor * __nullable )titleColor
                         font:(UIFont * __nullable )font
              backgroundColor:(UIColor * __nullable )backgroundColor
                       target:(id __nullable )target
                          sel:(SEL __nullable )sel
                          tag:(NSInteger)tag;

+ (UIButton *)buttonWithTitle:(NSString * __nullable )title
                   titleColor:(UIColor * __nullable )titleColor
              backgroundColor:(UIColor * __nullable )backgroundColor
                    imageName:(NSString * __nullable )imageName
                       target:(id __nullable )target
                          sel:(SEL __nullable )sel
                          tag:(NSInteger)tag;

+ (UIButton *)buttonWithTitle:(NSString * __nullable )title
                   titleColor:(UIColor * __nullable )titleColor
                         font:(UIFont * __nullable )font
              backgroundColor:(UIColor * __nullable )backgroundColor
                    imageName:(NSString * __nullable )imageName
                       target:(id __nullable )target
                          sel:(SEL __nullable )sel
                          tag:(NSInteger)tag;


+ (void)settingButtonWithBtn:(UIButton * __nullable )btn
                        font:(UIFont * __nullable )font
                       title:(NSString * __nullable )title
                  titleColor:(UIColor * __nullable )titleColor
             attributedTitle:(NSAttributedString * __nullable )attributedTitle
                   imageName:(NSString * __nullable )imageName
             backgroundColor:(UIColor * __nullable )backgroundColor
                      target:(id __nullable )target
                         sel:(SEL __nullable )sel
                         tag:(NSInteger)tag;

+ (UIButton *)buttonWithSubClass:(Class)subClass
                           title:(NSString * __nullable )title
                      titleColor:(UIColor * __nullable )titleColor
                            font:(UIFont * __nullable )font
                 backgroundColor:(UIColor * __nullable )backgroundColor
                          target:(id __nullable )target
                             sel:(SEL __nullable )sel
                             tag:(NSInteger)tag;



+ (UIButton *)buttonWithImageName:(NSString * __nullable )imageName
                           target:(id __nullable )target
                              sel:(SEL __nullable )sel
                              tag:(NSInteger)tag;



+ (UIButton *)buttonWithAttributeTitle:(NSAttributedString * __nullable )attrStr
                       backgroundColor:(UIColor * __nullable )backgroundColor
                                target:(id __nullable )target
                                   sel:(SEL __nullable )sel
                                   tag:(NSInteger)tag;


+ (UIButton *)roundButton;

+ (UIButton *)roundButtonWithTitle:(NSString * __nullable )title
                        titleColor:(UIColor * __nullable )titleColor
                              font:(UIFont * __nullable )font
                   backgroundColor:(UIColor * __nullable )backgroundColor
                            target:(id __nullable )target
                               sel:(SEL __nullable )sel
                               tag:(NSInteger)tag;



+ (UIButton *)roundButtonWithBoldTitle:(NSString * __nullable )title
                            titleColor:(UIColor * __nullable )titleColor
                                  font:(UIFont * __nullable )font
                       backgroundColor:(UIColor * __nullable )backgroundColor
                                target:(id __nullable )target
                                   sel:(SEL __nullable )sel
                                   tag:(NSInteger)tag;



+ (UIButton *)roundButtonWithImageName:(NSString * __nullable )imageName
                                target:(id __nullable )target
                                   sel:(SEL __nullable )sel
                                   tag:(NSInteger)tag;



+ (UIButton *)roundButtonWithAttributeTitle:(NSAttributedString * __nullable )attrStr
                                       font:(UIFont * __nullable )font
                            backgroundColor:(UIColor * __nullable )backgroundColor
                                     target:(id __nullable )target
                                        sel:(SEL __nullable )sel
                                        tag:(NSInteger)tag;

@end


/*!
 *  backgroundColor default is clear.
 **/
@interface SJShapeButtonFactory : NSObject

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius;

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                     backgroundColor:(UIColor * __nullable )backgroundColor;

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                     backgroundColor:(UIColor * __nullable )backgroundColor
                              target:(id __nullable )target
                                 sel:(SEL __nullable )sel;

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                     backgroundColor:(UIColor * __nullable )backgroundColor
                              target:(id __nullable )target
                                 sel:(SEL __nullable )sel
                                 tag:(NSInteger)tag;

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                               title:(NSString * __nullable )title
                          titleColor:(UIColor * __nullable )titleColor
                              target:(id __nullable )target
                                 sel:(SEL __nullable )sel;

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                               title:(NSString * __nullable )title
                          titleColor:(UIColor * __nullable )titleColor
                                font:(UIFont * __nullable )font
                              target:(id __nullable )target
                                 sel:(SEL __nullable )sel;

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                               title:(NSString * __nullable )title
                          titleColor:(UIColor * __nullable )titleColor
                                font:(UIFont * __nullable )font
                              target:(id __nullable )target
                                 sel:(SEL __nullable )sel
                                 tag:(NSInteger)tag;

+ (UIButton *)shadowButtonWithCornerRadius:(CGFloat)cornerRadius
                           backgroundColor:(UIColor *)backgroundColor
                           attributedTitle:(NSAttributedString *)attributedTitle
                                    target:(id __nullable )target
                                       sel:(SEL __nullable )sel
                                       tag:(NSInteger)tag;
@end


#pragma mark -

@interface SJUIImageViewFactory : NSObject
/*!
 *  viewMode -> UIViewContentModeScaleAspectFit
 **/
+ (UIImageView *)imageViewWithBackgroundColor:(UIColor * __nullable )color;

+ (UIImageView *)imageViewWithBackgroundColor:(UIColor * __nullable )color
                                     viewMode:(UIViewContentMode)mode;

+ (UIImageView *)imageViewWithViewMode:(UIViewContentMode)mode;

+ (UIImageView *)imageViewWithImageName:(NSString * __nullable )imageName;

+ (UIImageView *)imageViewWithImageName:(NSString * __nullable )imageName
                               viewMode:(UIViewContentMode)mode;

+ (UIImageView *)imageViewWithImageName:(NSString * __nullable )imageName
                               viewMode:(UIViewContentMode)mode
                        backgroundColor:(UIColor * __nullable )color;

@end

/*!
 *  viewMode -> UIViewContentModeScaleAspectFill
 *  不提供设置隐影, 如果要设置阴影
 */
@interface SJShapeImageViewFactory : NSObject

+ (UIImageView *)imageViewWithCornerRadius:(float)cornerRadius;

+ (UIImageView *)imageViewWithCornerRadius:(float)cornerRadius
                           backgroundColor:(UIColor * __nullable )backgroundColor;

+ (UIImageView *)imageViewWithCornerRadius:(float)cornerRadius
                                 imageName:(NSString * __nullable )imageName;

+ (UIImageView *)imageViewWithCornerRadius:(float)cornerRadius
                                 imageName:(NSString * __nullable )imageName
                                  viewMode:(UIViewContentMode)mode;


+ (UIImageView *)roundImageView;

+ (UIImageView *)roundImageViewWithViewMode:(UIViewContentMode)mode;

+ (UIImageView *)roundImageViewWithBackgroundColor:(UIColor * __nullable )color;

+ (UIImageView *)roundImageViewWithBackgroundColor:(UIColor * __nullable )color
                                          viewMode:(UIViewContentMode)mode;

+ (UIImageView *)roundImageViewWithImageName:(NSString * __nullable )imageName;

+ (UIImageView *)roundImageViewWithImageName:(NSString * __nullable )imageName
                                    viewMode:(UIViewContentMode)mode;
@end



#pragma mark -
/// 如果placeholderColor不为nil, 则设置为 attr. 否则设置是default
/// textColor if nil, it will be set black.
/// backgroundColor if nil, it will be set clear.
@interface SJUITextFieldFactory : NSObject
+ (UITextField *)textFieldWithPlaceholder:(NSString * __nullable )placeholder
                         placeholderColor:(UIColor * __nullable )placeholderColor
                                     text:(NSString * __nullable )text
                                     font:(UIFont * __nullable )font
                                textColor:(UIColor * __nullable )textColor
                             keyboardType:(UIKeyboardType)keyboardType
                            returnKeyType:(UIReturnKeyType)returnKeyType
                          backgroundColor:(UIColor * __nullable )backgroundColor;



+ (__kindof UITextField *)textFieldWithAttrPlaceholder:(NSAttributedString * __nullable )placeholder
                                                  text:(NSString * __nullable )text
                                                  font:(UIFont * __nullable )font
                                             textColor:(UIColor * __nullable )textColor
                                          keyboardType:(UIKeyboardType)keyboardType
                                         returnKeyType:(UIReturnKeyType)returnKeyType
                                       backgroundColor:(UIColor * __nullable )backgroundColor;

+ (__kindof UITextField *)textFieldWithAttrPlaceholder:(NSAttributedString * __nullable )placeholder
                                                  text:(NSString * __nullable )text
                                                  font:(UIFont * __nullable )font
                                             textColor:(UIColor * __nullable )textColor
                                          keyboardType:(UIKeyboardType)keyboardType
                                         returnKeyType:(UIReturnKeyType)returnKeyType
                                       backgroundColor:(UIColor * __nullable )backgroundColor
                                   textChangedExeBlock:(void(^__nullable)(UITextField *textField))textChangeExeBlock
                                        returnExeBlock:(void(^__nullable)(UITextField *textField))returnExeBlock;


+ (void)textField:(UITextField *)textField setPlaceholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor;



+ (void)textField:(UITextField *)textField setLeftSpace:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace;

@end


#pragma mark -
@interface SJUITextViewFactory : NSObject

+ (UITextView *)textViewWithTextColor:(UIColor * __nullable )textColor
                      backgroundColor:(UIColor * __nullable )backgroundColor
                                 font:(UIFont * __nullable )font;

+ (__kindof UITextView *)textViewWithSubClass:(Class)cls
                           textColor:(UIColor * __nullable )textColor
                      backgroundColor:(UIColor * __nullable )backgroundColor
                                 font:(UIFont * __nullable )font;

@end


#pragma mark -

@interface SJUIImagePickerControllerFactory : NSObject

+ (instancetype)shared;

- (void)alterPickerViewControllerWithController:(UIViewController *)controller
                                     alertTitle:(NSString * __nullable )title
                                            msg:(NSString * __nullable )msg
                                   photoLibrary:(void(^)(UIImage *selectedImage))photoLibraryBlock
                                         camera:(void(^)(UIImage *selectedImage))cameraBlock;

- (void)alterPickerViewControllerWithController:(UIViewController *)controller
                                     alertTitle:(NSString * __nullable )title
                                            msg:(NSString * __nullable )msg
                                        actions:(NSArray<UIAlertAction *> * __nullable )otherActions
                                   photoLibrary:(void(^)(UIImage *selectedImage))photoLibraryBlock
                                         camera:(void(^)(UIImage *selectedImage))cameraBlock;

@end



#pragma mark -

@interface SJDrawUIView : UIView

@property (nonatomic, copy, readwrite) void(^drawBlock)(SJDrawUIView *view);

@end

NS_ASSUME_NONNULL_END
