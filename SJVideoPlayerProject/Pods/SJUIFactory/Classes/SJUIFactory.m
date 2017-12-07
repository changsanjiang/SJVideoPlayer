//
//  SJUIFactory.m
//  LanWuZheiOS
//
//  Created by BlueDancer on 2017/11/4.
//  Copyright © 2017年 lanwuzhe. All rights reserved.
//

#import "SJUIFactory.h"
#import "UIImagePickerController+Extension.h"
#import "UIView+SJUIFactory.h"

CGSize SJScreen_Size(void) {
    return [UIScreen mainScreen].bounds.size;
}

float SJScreen_W(void) {
    return SJScreen_Size().width;
}

float SJScreen_H(void) {
    return SJScreen_Size().height;
}

float SJScreen_Min(void) {
    return MIN(SJScreen_W(), SJScreen_H());
}

float SJScreen_Max(void) {
    return MAX(SJScreen_W(), SJScreen_H());
}

BOOL SJ_is_iPhoneX(void) {
    return SJScreen_Min() / SJScreen_Max() == 1125.0 / 2436;
}

/*!
 *  通过高度 get 到字体大小
 *
 *  不管粗体还是普通, 高度相同, 粗细不同.
 *
 *  Height  Font    scale
 *  12      10      1.2
 *  18      15      1.2
 *  24      20      1.2
 *  36      30      1.2
 *  48      40      1.2
 */

#pragma mark - Round View

@interface SJRoundView : UIView
@property (nonatomic, strong, readonly) CAShapeLayer *shapeLayer;
@end
@implementation SJRoundView
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
    
    //    CAShapeLayer *layer = [CAShapeLayer layer];
    //    layer.frame = self.bounds;
    //    layer.path = [UIBezierPath bezierPathWithArcCenter:_sjCenter(self.frame) radius:CGRectGetWidth(self.frame) * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
    //    self.layer.mask = layer;
    
}

@synthesize shapeLayer = _shapeLayer;
- (CAShapeLayer *)shapeLayer {
    if ( _shapeLayer ) return _shapeLayer;
    _shapeLayer = [CAShapeLayer layer];
    return _shapeLayer;
}
@end

#pragma mark - Line View

@interface SJLineView : UIView
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, strong, readonly) UIColor *lineColor;
- (instancetype)initWithHeight:(CGFloat)height lineColor:(UIColor *)lineColor;
@end

@implementation SJLineView

- (instancetype)initWithHeight:(CGFloat)height lineColor:(UIColor *)lineColor {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    self.backgroundColor = [UIColor clearColor];
    _height = height;
    _lineColor = lineColor;
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, rect.size.height * 0.5)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height * 0.5)];
    bezierPath.lineWidth = _height;
    [_lineColor set];
    [bezierPath stroke];
}

@end


#pragma mark - Round

@interface SJRoundImageView : UIImageView @end
@implementation SJRoundImageView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    self.clipsToBounds = YES;
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
}
@end

@interface SJRoundButton : UIButton @end
@implementation SJRoundButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    self.clipsToBounds = YES;
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
}
@end



@implementation SJUIFactory

+ (instancetype)sharedManager {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

+ (UIFont *)getFontWithViewHeight:(CGFloat)height {
    if ( 0 == height ) return nil;
    return [UIFont systemFontOfSize:height / 1.2];
}

+ (UIFont *)getBoldFontWithViewHeight:(CGFloat)height {
    if ( 0 == height ) return nil;
    return [UIFont boldSystemFontOfSize:height / 1.2];
}

+ (void)commonShadowWithView:(UIView *)view {
    view.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    view.layer.shadowOpacity = 1;
    view.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    view.layer.masksToBounds = NO;
}

+ (void)regulate:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}

+ (void)boundaryProtectedWithView:(UIView *)view {
    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

@end


#pragma mark - UIView
@implementation SJUIViewFactory

+ (UIView *)viewWithBackgroundColor:(UIColor *)backgroundColor {
    return [self viewWithBackgroundColor:backgroundColor frame:CGRectZero];
}

+ (UIView *)viewWithBackgroundColor:(UIColor *)backgroundColor frame:(CGRect)frame {
    UIView *view = [UIView new];
    [self _settingView:view backgroundColor:backgroundColor frame:frame];
    return view;
}

+ (__kindof UIView *)viewWithSubClass:(Class)subClass
                      backgroundColor:(UIColor *)backgroundColor {
    return [self viewWithSubClass:subClass backgroundColor:backgroundColor frame:CGRectZero];
}

+ (__kindof UIView *)viewWithSubClass:(Class)subClass
                      backgroundColor:(UIColor *)backgroundColor
                                frame:(CGRect)frame {
    UIView *view = [subClass new];
    [self _settingView:view backgroundColor:backgroundColor frame:frame];
    return view;
}

+ (void)_settingView:(UIView *)view
    backgroundColor:(UIColor *)backgroundColor
              frame:(CGRect)frame {
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    view.backgroundColor = backgroundColor;
    view.frame = frame;
}

+ (UIView *)roundViewWithBackgroundColor:(UIColor *)color {
    SJRoundView *view = [SJRoundView new];
    view.backgroundColor = color;
    return view;
}

+ (UIView *)lineViewWithHeight:(CGFloat)height lineColor:(UIColor *)color {
    UIView *view = [[SJLineView alloc] initWithHeight:height lineColor:color];
    return view;
}
@end



#pragma mark - UIScrollView

@implementation SJScrollViewFactory

+ (UIScrollView *)scrollViewWithContentSize:(CGSize)contentSize pagingEnabled:(BOOL)pagingEnabled {
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.contentSize = contentSize;
    scrollView.pagingEnabled = pagingEnabled;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    return scrollView;
}

@end


#pragma mark - UITableView

@implementation SJUITableViewFactory

+ (UITableView *)tableViewWithStyle:(UITableViewStyle)style backgroundColor:(UIColor *)backgroundColor separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle showsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator delegate:(id<UITableViewDelegate>)delegate dataSource:(id<UITableViewDataSource>)dataSource {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    tableView.backgroundColor = backgroundColor;
    tableView.separatorStyle = separatorStyle;
    tableView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.delegate = delegate;
    tableView.dataSource = dataSource;
    return tableView;
}

+ (UITableView *)tableViewWithSubClass:(Class)subClass
                                 style:(UITableViewStyle)style
                       backgroundColor:(UIColor *)backgroundColor
                        separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
          showsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
                              delegate:(id<UITableViewDelegate>)delegate
                            dataSource:(id<UITableViewDataSource>)dataSource {
    if ( [subClass isKindOfClass:[UITableView class]] ) return nil;
    UITableView *tableView = [[subClass alloc] initWithFrame:CGRectZero style:style];
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    tableView.backgroundColor = backgroundColor;
    tableView.separatorStyle = separatorStyle;
    tableView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.delegate = delegate;
    tableView.dataSource = dataSource;
    return tableView;
}

+ (void)settingTableView:(UITableView *)tableView rowHeight:(CGFloat)rowHeight sectionHeaderHeight:(CGFloat)sectionHeaderHeight sectionFooterHeight:(CGFloat)sectionFooterHeight {
    tableView.rowHeight = rowHeight;
    tableView.sectionHeaderHeight = sectionHeaderHeight;
    tableView.sectionFooterHeight = sectionFooterHeight;
}

+ (void)settingTableView:(UITableView *)tableView
      estimatedRowHeight:(CGFloat)estimatedRowHeight
estimatedSectionHeaderHeight:(CGFloat)estimatedSectionHeaderHeight
estimatedSectionFooterHeight:(CGFloat)estimatedSectionFooterHeight {
    tableView.estimatedRowHeight = estimatedRowHeight;
    tableView.estimatedSectionHeaderHeight = estimatedSectionHeaderHeight;
    tableView.estimatedSectionFooterHeight = estimatedSectionFooterHeight;
}

@end



#pragma mark - UICollectionView

@implementation SJUICollectionViewFactory

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor {
    UICollectionView *collectionView = [self collectionViewWithItemSize:itemSize backgroundColor:backgroundColor scrollDirection:UICollectionViewScrollDirectionVertical];
    return collectionView;
}


+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)direction {
    
    CGFloat itemW = itemSize.width;
    CGFloat itemH = itemSize.height;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(itemW, itemH);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.scrollDirection = direction;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = backgroundColor;
    collectionView.showsHorizontalScrollIndicator = YES;
    collectionView.showsVerticalScrollIndicator = YES;
    
    return collectionView;
}

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)direction headerSize:(CGSize)headerSize footerSize:(CGSize)footerSize {
    CGFloat itemW = itemSize.width;
    CGFloat itemH = itemSize.height;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(itemW, itemH);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.scrollDirection = direction;
    flowLayout.headerReferenceSize = headerSize;
    flowLayout.footerReferenceSize = footerSize;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = backgroundColor;
    collectionView.showsHorizontalScrollIndicator = YES;
    collectionView.showsVerticalScrollIndicator = YES;
    
    return collectionView;
}

+ (UICollectionView *)collectionViewWithItemSize:(CGSize)itemSize backgroundColor:(UIColor *)backgroundColor scrollDirection:(UICollectionViewScrollDirection)scrollDirection minimumLineSpacing:(CGFloat)minimumLineSpacing minimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    CGFloat itemW = itemSize.width;
    CGFloat itemH = itemSize.height;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(itemW, itemH);
    flowLayout.minimumLineSpacing = minimumLineSpacing;
    flowLayout.minimumInteritemSpacing = minimumInteritemSpacing;
    flowLayout.scrollDirection = scrollDirection;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = backgroundColor;
    collectionView.showsHorizontalScrollIndicator = YES;
    collectionView.showsVerticalScrollIndicator = YES;
    return collectionView;
}

@end




#pragma mark - Label

@implementation SJUILabelFactory

+ (UILabel *)labelWithFont:(UIFont *)font {
    return [self labelWithFont:font textColor:nil alignment:0];
}

+ (UILabel *)labelWithFont:(UIFont *)font
                 textColor:(UIColor *)textColor {
    return [self labelWithFont:font textColor:textColor alignment:0];
}


+ (UILabel *)labelWithFont:(UIFont *)font
                 textColor:(UIColor *)textColor
                 alignment:(NSTextAlignment)alignment {
    return [self labelWithText:nil textColor:textColor alignment:alignment font:font];
}

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor {
    return [self labelWithText:text textColor:textColor alignment:0];
}

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor
                 alignment:(NSTextAlignment)alignment {
    return [self labelWithText:text textColor:textColor alignment:alignment font:nil];
}

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor
                 alignment:(NSTextAlignment)alignment
                      font:(UIFont *)font {
    UILabel *label = [UILabel new];
    [self settingLabelWithLabel:label text:text textColor:textColor alignment:alignment font:font attrStr:nil];
    return label;
}

+ (UILabel *)labelWithAttrStr:(NSAttributedString *)attrStr {
    UILabel *label = [UILabel new];
    [self settingLabelWithLabel:label text:nil textColor:nil alignment:0 font:nil attrStr:attrStr];
    return label;
}

+ (void)settingLabelWithLabel:(UILabel *)label
                         text:(NSString *)text
                    textColor:(UIColor *)textColor
                    alignment:(NSTextAlignment)alignment
                         font:(UIFont *)font
                      attrStr:(NSAttributedString *)attrStr {
    label.textAlignment = alignment;
    if ( !textColor ) textColor = [UIColor whiteColor];
    label.textColor = textColor;
    if ( text ) label.text = text;
    if ( attrStr ) label.attributedText = attrStr;
    else {
        if ( !font ) font = [UIFont systemFontOfSize:14];
        label.font = font;
    }
    [label sizeToFit];
}

@end



@implementation SJUIButtonFactory
+ (UIButton *)buttonWithTarget:(id)target sel:(SEL)sel {
    return [self buttonWithBackgroundColor:nil target:target sel:sel];
}

+ (UIButton *)buttonWithTarget:(id)target sel:(SEL)sel tag:(NSInteger)tag {
    return [self buttonWithBackgroundColor:nil target:target sel:sel tag:tag];
}

+ (UIButton *)buttonWithBackgroundColor:(UIColor *)color
                                 target:(id)target
                                    sel:(SEL)sel {
    return [self buttonWithBackgroundColor:color target:target sel:sel tag:0];
}


+ (UIButton *)buttonWithBackgroundColor:(UIColor *)color
                                 target:(id)target
                                    sel:(SEL)sel
                                    tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    if ( !color ) color = [UIColor clearColor];
    btn.backgroundColor = color;
    btn.tag = tag;
    return btn;
}

+ (UIButton *)buttonWithImageName:(NSString *)imageName {
    UIButton *btn = [UIButton new];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return btn;
}

+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor {
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    return btn;
}

+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor imageName:(NSString *)imageName {
    UIButton *btn = [self buttonWithTitle:title titleColor:titleColor];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return btn;
}

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                         font:(UIFont *)font
              backgroundColor:(UIColor *)backgroundColor
                       target:(id)target
                          sel:(SEL)sel
                          tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [self settingButtonWithBtn:btn font:font title:title titleColor:titleColor attributedTitle:nil imageName:nil backgroundColor:backgroundColor target:target sel:sel tag:tag];
    return btn;
}

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
              backgroundColor:(UIColor *)backgroundColor
                    imageName:(NSString *)imageName
                       target:(id)target
                          sel:(SEL)sel
                          tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [self settingButtonWithBtn:btn font:[UIFont systemFontOfSize:14] title:nil titleColor:titleColor attributedTitle:nil imageName:nil backgroundColor:backgroundColor target:target sel:sel tag:tag];
    return btn;
}

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                         font:(UIFont *)font
              backgroundColor:(UIColor *)backgroundColor
                    imageName:(NSString *)imageName
                       target:(id)target
                          sel:(SEL)sel
                          tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [self settingButtonWithBtn:btn font:font title:title titleColor:titleColor attributedTitle:nil imageName:imageName backgroundColor:backgroundColor target:target sel:sel tag:tag];
    return btn;
}

+ (void)settingButtonWithBtn:(UIButton *)btn
                        font:(UIFont *)font
                       title:(NSString *)title
                  titleColor:(UIColor *)titleColor
             attributedTitle:(NSAttributedString *)attributedTitle
                   imageName:(NSString *)imageName
             backgroundColor:(UIColor *)backgroundColor
                      target:(id)target
                         sel:(SEL)sel
                         tag:(NSInteger)tag {
    if ( title ) [btn setTitle:title forState:UIControlStateNormal];
    if ( !titleColor ) titleColor = [UIColor whiteColor];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    if ( attributedTitle ) [btn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    [btn setBackgroundColor:backgroundColor];
    if ( target ) [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    if ( font ) [btn.titleLabel setFont:font];
    if ( imageName ) [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    btn.titleLabel.numberOfLines = 0;
    btn.tag = tag;
}

+ (UIButton *)buttonWithSubClass:(Class)subClass
                           title:(NSString *)title
                      titleColor:(UIColor *)titleColor
                            font:(UIFont *)font
                 backgroundColor:(UIColor *)backgroundColor
                          target:(id)target
                             sel:(SEL)sel
                             tag:(NSInteger)tag {
    UIButton *btn = [subClass new];
    [self settingButtonWithBtn:btn font:font title:title titleColor:titleColor attributedTitle:nil imageName:nil backgroundColor:backgroundColor target:target sel:sel tag:tag];
    return btn;
}

+ (UIButton *)buttonWithImageName:(NSString *)imageName
                           target:(id)target
                              sel:(SEL)sel
                              tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [self settingButtonWithBtn:btn font:nil title:nil titleColor:nil attributedTitle:nil imageName:imageName backgroundColor:nil target:target sel:sel tag:tag];
    return btn;
}

+ (UIButton *)buttonWithAttributeTitle:(NSAttributedString *)attrStr
                       backgroundColor:(UIColor *)backgroundColor
                                target:(id)target
                                   sel:(SEL)sel
                                   tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [self settingButtonWithBtn:btn font:nil title:nil titleColor:nil attributedTitle:attrStr imageName:nil backgroundColor:backgroundColor target:target sel:sel tag:tag];
    return btn;
}

+ (UIButton *)roundButtonWithTitle:(NSString *)title
                        titleColor:(UIColor *)titleColor
                              font:(UIFont *)font
                   backgroundColor:(UIColor *)backgroundColor
                            target:(id)target
                               sel:(SEL)sel
                               tag:(NSInteger)tag {
    return [self buttonWithSubClass:[SJRoundButton class] title:title titleColor:titleColor font:font backgroundColor:backgroundColor target:target sel:sel tag:tag];
}



+ (UIButton *)roundButtonWithBoldTitle:(NSString *)title
                            titleColor:(UIColor *)titleColor
                                  font:(UIFont *)font
                       backgroundColor:(UIColor *)backgroundColor
                                target:(id)target
                                   sel:(SEL)sel
                                   tag:(NSInteger)tag {
    UIButton *btn = [SJRoundButton new];
    [self settingButtonWithBtn:btn font:font title:title titleColor:titleColor attributedTitle:nil imageName:nil backgroundColor:backgroundColor target:target sel:sel tag:tag];
    return btn;
}



+ (UIButton *)roundButtonWithImageName:(NSString *)imageName
                                target:(id)target
                                   sel:(SEL)sel
                                   tag:(NSInteger)tag {
    UIButton *btn = [SJRoundButton new];
    [self settingButtonWithBtn:btn font:nil title:nil titleColor:nil attributedTitle:nil imageName:imageName backgroundColor:nil target:target sel:sel tag:tag];
    return btn;
}



+ (UIButton *)roundButtonWithAttributeTitle:(NSAttributedString *)attrStr
                                       font:(UIFont *)font
                            backgroundColor:(UIColor *)backgroundColor
                                     target:(id)target
                                        sel:(SEL)sel
                                        tag:(NSInteger)tag {
    UIButton *btn = [SJRoundButton new];
    [self settingButtonWithBtn:btn font:font title:nil titleColor:nil attributedTitle:attrStr imageName:nil backgroundColor:backgroundColor target:target sel:sel tag:tag];
    return btn;
}

@end




#pragma mark - UIImageVIew

@implementation SJUIImageViewFactory

+ (UIImageView *)imageViewWithBackgroundColor:(UIColor *)color {
    return [self imageViewWithBackgroundColor:color viewMode:UIViewContentModeScaleAspectFit];
}

+ (UIImageView *)imageViewWithViewMode:(UIViewContentMode)mode {
    return [self imageViewWithImageName:nil];
}

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName
                               viewMode:(UIViewContentMode)mode {
    UIImageView *imageView = [UIImageView new];
    if ( imageName ) imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = mode;
    imageView.clipsToBounds = YES;
    return imageView;
}

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName {
    return [SJUIImageViewFactory imageViewWithImageName:imageName viewMode:UIViewContentModeScaleAspectFit];
}

+ (UIImageView *)imageViewWithBackgroundColor:(UIColor *)color
                                     viewMode:(UIViewContentMode)mode {
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = mode;
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = color;
    return imageView;
}

+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName {
    return [SJUIImageViewFactory roundImageViewWithImageName:imageName viewMode:UIViewContentModeScaleAspectFit];
}

+ (UIImageView *)roundImageViewWithBackgroundColor:(UIColor *)color
                                          viewMode:(UIViewContentMode)mode {
    UIImageView *imageView = [SJRoundImageView new];
    imageView.contentMode = mode;
    imageView.backgroundColor = color;
    return imageView;
}

+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName
                                    viewMode:(UIViewContentMode)mode {
    UIImageView *imageView = [SJRoundImageView new];
    imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = mode;
    return imageView;
}

@end


#pragma mark - Text Field

@implementation SJUITextFieldFactory

+ (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder
                         placeholderColor:(UIColor *)placeholderColor
                                     text:(NSString *)text
                                     font:(UIFont *)font
                                textColor:(UIColor *)textColor
                             keyboardType:(UIKeyboardType)keyboardType
                            returnKeyType:(UIReturnKeyType)returnKeyType
                          backgroundColor:(UIColor *)backgroundColor {
    UITextField *textField = [UITextField new];
    if ( 0 != placeholder.length && nil != placeholderColor ) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:placeholderColor}];
        textField.tintColor = placeholderColor;
    }
    else textField.placeholder = placeholder;
    textField.text = text;
    textField.font = font;
    if ( !textColor ) textColor = [UIColor blackColor];
    textField.keyboardType = keyboardType;
    textField.textColor = textColor;
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    textField.backgroundColor = backgroundColor;
    textField.returnKeyType = returnKeyType;
    return textField;
}

+ (UITextField *)textFieldWithAttrPlaceholder:(NSAttributedString *)placeholder
                                         text:(NSString *)text
                                         font:(UIFont *)font
                                    textColor:(UIColor *)textColor
                                 keyboardType:(UIKeyboardType)keyboardType
                                returnKeyType:(UIReturnKeyType)returnKeyType
                              backgroundColor:(UIColor *)backgroundColor {
    UITextField *textField = [UITextField new];
    textField.attributedPlaceholder = placeholder;
    textField.text = text;
    textField.font = font;
    if ( !textColor ) textColor = [UIColor blackColor];
    textField.keyboardType = keyboardType;
    textField.textColor = textColor;
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    textField.backgroundColor = backgroundColor;
    textField.returnKeyType = returnKeyType;
    return textField;
}


+ (void)textField:(UITextField *)textField setPlaceholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor {
    if ( 0 != placeholder.length && nil != placeholderColor ) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:placeholderColor}];
    }
    textField.tintColor = placeholderColor;
}

+ (void)textField:(UITextField *)textField setLeftSpace:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace {
    if ( 0 != leftSpace ) {
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.leftView = [SJUIViewFactory viewWithBackgroundColor:nil frame:CGRectMake(0, 0, leftSpace, 0)];
    }
    
    if ( 0 != rightSpace ) {
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.rightView = [SJUIViewFactory viewWithBackgroundColor:nil frame:CGRectMake(0, 0, rightSpace, 0)];
    }
}

@end



#pragma mark - Text View

@implementation SJUITextViewFactory

+ (UITextView *)textViewWithTextColor:(UIColor *)textColor
                      backgroundColor:(UIColor *)backgroundColor
                                 font:(UIFont *)font {
    UITextView *textView = [UITextView new];
    textView.textColor = textColor;
    textView.backgroundColor = backgroundColor;
    textView.font = font;
    return textView;
}

@end



#pragma mark - UIImagePickerController

@interface SJUIImagePickerControllerFactory ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation SJUIImagePickerControllerFactory

+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (void)alterPickerViewControllerWithController:(UIViewController *)controller
                                     alertTitle:(NSString *)title
                                            msg:(NSString *)msg
                                   photoLibrary:(void(^)(UIImage *selectedImage))photoLibraryBlock
                                         camera:(void(^)(UIImage *selectedImage))cameraBlock {
    NSMutableArray<NSString *> *titlesM = [NSMutableArray new];
    NSMutableArray<void(^)(void)> *actionsM = [NSMutableArray new];
    
    // 拍照
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        [titlesM addObject:@"拍照"];
        [actionsM addObject:^{
            UIImagePickerController *pickerController = [UIImagePickerController new];
            pickerController.delegate = self;
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.didFinishPickingImageCallBlock = ^(UIImage *selectedImage) {
                if ( cameraBlock ) cameraBlock(selectedImage);
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                [controller presentViewController:pickerController animated:YES completion:nil];
            });
        }];
    }
    
    // 相册
    [titlesM addObject:@"相册"];
    [actionsM addObject:^ {
        UIImagePickerController *pickerController = [UIImagePickerController new];
        pickerController.delegate = self;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.didFinishPickingImageCallBlock = ^(UIImage *selectedImage) {
            if ( photoLibraryBlock ) photoLibraryBlock(selectedImage);
        };
        dispatch_async(dispatch_get_main_queue(), ^{
            [controller presentViewController:pickerController animated:YES completion:nil];
        });
    }];
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleActionSheet];
    
    // actions
    [titlesM enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            actionsM[idx]();
        }];
        [alertController addAction:action];
    }];
    
    // cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //if iPhone
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            [controller presentViewController:alertController animated:YES completion:nil];
        }
        //if iPad
        else {
            // Change Rect to position Popover
            UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
            popPresenter.sourceView = [UIApplication sharedApplication].keyWindow;
            popPresenter.sourceRect = CGRectMake(0, [UIApplication sharedApplication].keyWindow.csj_h, [UIApplication sharedApplication].keyWindow.csj_w, 0);
            popPresenter.permittedArrowDirections = UIPopoverArrowDirectionDown;
            [controller presentViewController:alertController animated:YES completion:nil];
        }
    });
}

#pragma mark Image Picker Controller Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *imageOriginal = [info objectForKey:UIImagePickerControllerOriginalImage];
        if ( picker.didFinishPickingImageCallBlock ) picker.didFinishPickingImageCallBlock(imageOriginal);
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
