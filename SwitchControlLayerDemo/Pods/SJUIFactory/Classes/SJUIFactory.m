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

BOOL SJ_is_iPhone5(void) {
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO;
}

BOOL SJ_is_iPhone6(void) {
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO;
}

BOOL SJ_is_iPhone6_P(void) {
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) : NO;
}

BOOL SJ_is_iPhoneX(void) {
    CGFloat s1 = ((float)((int)(SJScreen_Min() / SJScreen_Max() * 100))) / 100;
    CGFloat s2 = ((float)((int)(1125.0 / 2436 * 100))) / 100;;
    return s1 == s2;
}

static void _SJ_Round(UIView *view, float cornerRadius) {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if ( 0 != cornerRadius ) {
        view.layer.mask = [SJUIFactory shapeLayerWithSize:view.bounds.size cornerRadius:cornerRadius];
    }
    else {
        view.layer.mask = [SJUIFactory roundShapeLayerWithSize:view.bounds.size];
    }
    [CATransaction commit];
}

#pragma mark - Round View

@interface SJRoundView : UIView
@property (nonatomic, assign, readwrite) CGFloat cornerRadius;
@end
@implementation SJRoundView
- (void)layoutSubviews {
    [super layoutSubviews];
    _SJ_Round(self, _cornerRadius);
}
@end

@interface SJRoundButton : UIButton
@property (nonatomic, assign, readwrite) CGFloat cornerRadius;
@property (nonatomic, assign) BOOL haveShadow;

@end
@implementation SJRoundButton
- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _haveShadow  ) {
        [SJUIFactory commonShadowWithView:self size:self.bounds.size cornerRadius:self.cornerRadius];
    }
    else {
        _SJ_Round(self, _cornerRadius);
    }
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



@implementation SJUIFactory

+ (UIFont *)getFontWithViewHeight:(CGFloat)height {
    if ( 0 == height ) return nil;
    return [UIFont systemFontOfSize:height / 1.193359];
}

+ (UIFont *)getBoldFontWithViewHeight:(CGFloat)height {
    if ( 0 == height ) return nil;
    return [UIFont boldSystemFontOfSize:height / 1.193359];
}

+ (void)commonShadowWithView:(UIView *)view {
    [self commonShadowWithLayer:view.layer];
}

+ (void)commonShadowWithLayer:(CALayer *)layer {
    layer.shadowColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    layer.shadowOpacity = 1;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1;
    layer.masksToBounds = NO;
}

+ (void)commonShadowWithView:(UIView *)view size:(CGSize)size {
    [self commonShadowWithView:view size:size cornerRadius:0];
}

+ (void)commonShadowWithView:(UIView *)view size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
    [self commonShadowWithView:view];
    view.layer.cornerRadius = cornerRadius;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, size} cornerRadius:cornerRadius].CGPath;
}

+ (CAShapeLayer *)commonShadowShapeLayerWithSize:(CGSize)size cornerRadius:(float)cornerRadius {
    CAShapeLayer *layer = [self shapeLayerWithSize:size cornerRadius:cornerRadius];
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self commonShadowWithLayer:layer];
    return layer;
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

+ (CAShapeLayer *)roundShapeLayerWithSize:(CGSize)size {
    CGRect bounds = (CGRect){CGPointZero, size};
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:size];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = bounds;
    shapeLayer.path = maskPath.CGPath;
    return shapeLayer;
}

+ (CAShapeLayer *)shapeLayerWithSize:(CGSize)size cornerRadius:(float)cornerRadius {
    CGRect bounds = (CGRect){CGPointZero, size};
    CAShapeLayer *shapelayer = [CAShapeLayer layer];
    shapelayer.bounds = bounds;
    shapelayer.position = CGPointMake(size.width * 0.5, size.height * 0.5);
    shapelayer.path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:cornerRadius].CGPath;
    shapelayer.fillColor = [UIColor blackColor].CGColor;
    return shapelayer;
}

@end


#pragma mark - UIView

@interface SJShadowView : UIView
@property (nonatomic, assign) CGFloat cornerRadius;
@end

@implementation SJShadowView

- (void)layoutSubviews {
    [super layoutSubviews];
    [SJUIFactory commonShadowWithView:self size:self.bounds.size cornerRadius:_cornerRadius];
}
@end

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

+ (UIView *)shadowViewWithCornerRadius:(CGFloat)cornerRadius {
    SJShadowView *view = [SJShadowView new];
    view.cornerRadius = cornerRadius;
    return view;
}

@end


@implementation SJShapeViewFactory

+ (UIView *)viewWithCornerRadius:(float)cornerRadius
                 backgroundColor:(UIColor *)backgroundColor {
    SJRoundView *view = [SJRoundView new];
    view.cornerRadius = cornerRadius;
    view.backgroundColor = backgroundColor;
    return view;
}

+ (UIView *)shadowViewWithCornerRadius:(CGFloat)cornerRadius
                       backgroundColor:(UIColor * __nullable )backgroundColor {
    SJShadowView *view = [SJShadowView new];
    view.cornerRadius = cornerRadius;
    view.backgroundColor = backgroundColor;
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

+ (UIScrollView *)scrollViewWithSubClass:(Class)subClass
                             contentSize:(CGSize)contentSize
                           pagingEnabled:(BOOL)pagingEnabled {
    UIScrollView *scrollView = [subClass new];
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
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    return tableView;
}

+ (UITableView *)tableViewWithSubClass:(Class)subClass
                                 style:(UITableViewStyle)style
                       backgroundColor:(UIColor *)backgroundColor
                        separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
          showsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
                              delegate:(id<UITableViewDelegate>)delegate
                            dataSource:(id<UITableViewDataSource>)dataSource {
    if ( ![subClass isSubclassOfClass:[UITableView class]] ) return nil;
    UITableView *tableView = [[subClass alloc] initWithFrame:CGRectZero style:style];
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    tableView.backgroundColor = backgroundColor;
    tableView.separatorStyle = separatorStyle;
    tableView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.delegate = delegate;
    tableView.dataSource = dataSource;
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    if ( style == UITableViewStyleGrouped ) tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
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

+ (UILabel *)labelWithText:(NSString *)text {
    return [self labelWithText:text textColor:nil];
}

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor {
    return [self labelWithText:text textColor:textColor alignment:0];
}

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor
                      font:(UIFont *)font {
    return [self labelWithText:text textColor:textColor alignment:NSTextAlignmentLeft font:font];
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

+ (UILabel *)attributeLabel {
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
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

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                         font:(UIFont *)font
                       target:(id)target
                          sel:(SEL)sel {
    return [self buttonWithTitle:title titleColor:titleColor font:font backgroundColor:nil target:target sel:sel tag:0];
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
    [self settingButtonWithBtn:btn font:[UIFont systemFontOfSize:14] title:title titleColor:titleColor attributedTitle:nil imageName:imageName backgroundColor:backgroundColor target:target sel:sel tag:tag];
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
    if ( attributedTitle ) {
        [btn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        btn.titleLabel.numberOfLines = 0;
    }
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    [btn setBackgroundColor:backgroundColor];
    if ( target ) [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    if ( !font ) font = [UIFont systemFontOfSize:14];
    [btn.titleLabel setFont:font];
    if ( imageName ) [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
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

+ (UIButton *)roundButton {
    return [SJRoundButton new];
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


#pragma mark - Button CornerRadius

@implementation SJShapeButtonFactory

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius {
    return [self buttonWithCornerRadius:cornerRadius backgroundColor:nil];
}

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                     backgroundColor:(UIColor *)backgroundColor {
    return [self buttonWithCornerRadius:cornerRadius backgroundColor:backgroundColor target:NULL sel:NULL tag:0];
}

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                     backgroundColor:(UIColor *)backgroundColor
                              target:(id)target
                                 sel:(SEL)sel {
    return [self buttonWithCornerRadius:cornerRadius backgroundColor:backgroundColor target:target sel:sel tag:0];
}

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                     backgroundColor:(UIColor *)backgroundColor
                              target:(id)target
                                 sel:(SEL)sel
                                 tag:(NSInteger)tag {
    SJRoundButton *btn = [SJRoundButton new];
    btn.cornerRadius = cornerRadius;
    btn.backgroundColor = backgroundColor;
    if ( target ) [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    return btn;
}

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                               title:(NSString *)title
                          titleColor:(UIColor *)titleColor
                              target:(id)target
                                 sel:(SEL)sel {
    return [self buttonWithCornerRadius:cornerRadius title:title titleColor:titleColor font:[UIFont systemFontOfSize:14] target:target sel:sel];
}

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                               title:(NSString *)title
                          titleColor:(UIColor *)titleColor
                                font:(UIFont *)font
                              target:(id)target
                                 sel:(SEL)sel {
    return [self buttonWithCornerRadius:cornerRadius title:title titleColor:titleColor font:font target:target sel:sel tag:0];
}

+ (UIButton *)buttonWithCornerRadius:(CGFloat)cornerRadius
                               title:(NSString *)title
                          titleColor:(UIColor *)titleColor
                                font:(UIFont *)font
                              target:(id)target
                                 sel:(SEL)sel
                                 tag:(NSInteger)tag {
    SJRoundButton *btn = (SJRoundButton *)[self buttonWithCornerRadius:cornerRadius backgroundColor:nil target:target sel:sel tag:tag];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    return btn;
}

+ (UIButton *)shadowButtonWithCornerRadius:(CGFloat)cornerRadius
                           backgroundColor:(UIColor *)backgroundColor
                           attributedTitle:(NSAttributedString *)attributedTitle
                                    target:(id __nullable )target
                                       sel:(SEL __nullable )sel
                                       tag:(NSInteger)tag {
    SJRoundButton *btn = (SJRoundButton *)[self buttonWithCornerRadius:cornerRadius backgroundColor:backgroundColor target:target sel:sel tag:tag];
    btn.haveShadow = YES;
    [btn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    return btn;
}
@end


#pragma mark - UIImageVIew

@implementation SJUIImageViewFactory

+ (UIImageView *)imageViewWithBackgroundColor:(UIColor *)color {
    return [self imageViewWithBackgroundColor:color viewMode:UIViewContentModeScaleAspectFit];
}

+ (UIImageView *)imageViewWithViewMode:(UIViewContentMode)mode {
    return [self imageViewWithImageName:nil viewMode:mode];
}

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName
                               viewMode:(UIViewContentMode)mode {
    return [self imageViewWithImageName:imageName viewMode:mode backgroundColor:nil];
}

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName {
    return [SJUIImageViewFactory imageViewWithImageName:imageName viewMode:UIViewContentModeScaleAspectFit];
}

+ (UIImageView *)imageViewWithBackgroundColor:(UIColor *)color
                                     viewMode:(UIViewContentMode)mode {
    return [self imageViewWithImageName:nil viewMode:mode backgroundColor:color];
}

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName
                               viewMode:(UIViewContentMode)mode
                        backgroundColor:(UIColor *)color {
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = mode;
    if ( color ) imageView.backgroundColor = color;
    if ( imageName ) imageView.image = [UIImage imageNamed:imageName];
    imageView.clipsToBounds = YES;
    return imageView;
}

@end



#pragma mark - Shape Image View

@interface SJShapeImageView : UIImageView
@property (nonatomic, assign, readwrite) CGFloat cornerRadius;
@end
@implementation SJShapeImageView
- (void)layoutSubviews {
    [super layoutSubviews];
    _SJ_Round(self, _cornerRadius);
}
@end

@implementation SJShapeImageViewFactory

+ (UIImageView *)imageViewWithCornerRadius:(float)cornerRadius {
    return [self imageViewWithCornerRadius:cornerRadius imageName:nil];
}

+ (UIImageView *)imageViewWithCornerRadius:(float)cornerRadius
                           backgroundColor:(UIColor *)backgroundColor {
    UIImageView *imageView = [self imageViewWithCornerRadius:cornerRadius];
    imageView.backgroundColor = backgroundColor;
    return imageView;
}

+ (UIImageView *)imageViewWithCornerRadius:(float)cornerRadius
                                 imageName:(NSString *)imageName {
    return [self imageViewWithCornerRadius:cornerRadius imageName:imageName viewMode:UIViewContentModeScaleAspectFill];
}

+ (UIImageView *)imageViewWithCornerRadius:(float)cornerRadius
                                 imageName:(NSString *)imageName
                                  viewMode:(UIViewContentMode)mode {
    SJShapeImageView *imageView = [[SJShapeImageView alloc] init];
    imageView.cornerRadius = cornerRadius;
    if ( imageView ) imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = mode;
    return imageView;
}

+ (UIImageView *)roundImageView {
    return [self roundImageViewWithViewMode:UIViewContentModeScaleAspectFill];
}

+ (UIImageView *)roundImageViewWithViewMode:(UIViewContentMode)mode {
    return [self roundImageViewWithImageName:nil viewMode:mode];
}

+ (UIImageView *)roundImageViewWithBackgroundColor:(UIColor *)color {
    return [self roundImageViewWithBackgroundColor:color viewMode:UIViewContentModeScaleAspectFill];
}

+ (UIImageView *)roundImageViewWithBackgroundColor:(UIColor *)color
                                          viewMode:(UIViewContentMode)mode {
    return [self roundImageViewWithImageName:nil viewMode:mode backgroundColor:color];
}

+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName {
    return [self roundImageViewWithImageName:imageName viewMode:UIViewContentModeScaleAspectFill];
}

+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName
                                    viewMode:(UIViewContentMode)mode {
    return [self roundImageViewWithImageName:imageName viewMode:mode backgroundColor:nil];
}

+ (UIImageView *)roundImageViewWithImageName:(NSString *)imageName
                                    viewMode:(UIViewContentMode)mode
                             backgroundColor:(UIColor *)color {
    SJShapeImageView *imageView = [SJShapeImageView new];
    if ( imageName ) imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = mode;
    if ( color ) imageView.backgroundColor = color;
    return imageView;
}
@end


#pragma mark - Text Field

@interface SJTextField : UITextField<UITextFieldDelegate>
@property (nonatomic, copy) void(^textChangeExeBlock)(UITextField *textField);
@property (nonatomic, copy) void(^returnExeBlock)(UITextField *textField);
@end

@implementation SJTextField
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged) name:UITextFieldTextDidChangeNotification object:self];
    self.delegate = self;
    return self;
}
- (void)textChanged {
    if ( _textChangeExeBlock ) _textChangeExeBlock(self);
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( self.returnExeBlock ) self.returnExeBlock(self);
    return YES;
}
@end

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

+ (__kindof UITextField *)textFieldWithAttrPlaceholder:(NSAttributedString *)placeholder
                                         text:(NSString *)text
                                         font:(UIFont *)font
                                    textColor:(UIColor *)textColor
                                 keyboardType:(UIKeyboardType)keyboardType
                                returnKeyType:(UIReturnKeyType)returnKeyType
                              backgroundColor:(UIColor *)backgroundColor {
    return [self textFieldWithAttrPlaceholder:placeholder text:text font:font textColor:textColor keyboardType:keyboardType returnKeyType:returnKeyType backgroundColor:backgroundColor textChangedExeBlock:nil returnExeBlock:nil];
}

+ (__kindof UITextField *)textFieldWithAttrPlaceholder:(NSAttributedString * __nullable )placeholder
                                                  text:(NSString * __nullable )text
                                                  font:(UIFont * __nullable )font
                                             textColor:(UIColor * __nullable )textColor
                                          keyboardType:(UIKeyboardType)keyboardType
                                         returnKeyType:(UIReturnKeyType)returnKeyType
                                       backgroundColor:(UIColor * __nullable )backgroundColor
                                   textChangedExeBlock:(void(^__nullable)(UITextField *textField))textChangeExeBlock
                                        returnExeBlock:(void (^ _Nullable)(UITextField * _Nonnull))returnExeBlock {
    SJTextField *textField = [SJTextField new];
    textField.attributedPlaceholder = placeholder;
    textField.text = text;
    textField.font = font;
    if ( !textColor ) textColor = [UIColor blackColor];
    textField.keyboardType = keyboardType;
    textField.textColor = textColor;
    if ( !backgroundColor ) backgroundColor = [UIColor clearColor];
    textField.backgroundColor = backgroundColor;
    textField.returnKeyType = returnKeyType;
    textField.textChangeExeBlock = textChangeExeBlock;
    textField.returnExeBlock = returnExeBlock;
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
    return [self textViewWithSubClass:[UITextView class] textColor:textColor backgroundColor:backgroundColor font:font];
}

+ (__kindof UITextView *)textViewWithSubClass:(Class)cls
                           textColor:(UIColor * __nullable )textColor
                     backgroundColor:(UIColor * __nullable )backgroundColor
                                font:(UIFont * __nullable )font {
    UITextView *textView = [cls new];
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
    [self alterPickerViewControllerWithController:controller alertTitle:title msg:msg actions:nil photoLibrary:photoLibraryBlock camera:cameraBlock];
}

- (void)alterPickerViewControllerWithController:(UIViewController *)controller
                                     alertTitle:(NSString *)title
                                            msg:(NSString *)msg
                                        actions:(NSArray<UIAlertAction *> *)otherActions
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
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        // 相册
        [titlesM addObject:@"相册"];
        [actionsM addObject:^ {
            UIImagePickerController *pickerController = [UIImagePickerController new];
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerController.delegate = self;
            pickerController.didFinishPickingImageCallBlock = ^(UIImage *selectedImage) {
                if ( photoLibraryBlock ) photoLibraryBlock(selectedImage);
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                [controller presentViewController:pickerController animated:YES completion:nil];
            });
        }];
    }
    
    
    if ( 0 == titlesM.count ) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"无法访问相册, 请确认是否授权!" preferredStyle:UIAlertControllerStyleAlert];
        [controller presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: 0 == title.length ? nil : title message:0 == msg.length ? nil : msg preferredStyle:UIAlertControllerStyleActionSheet];
    
    [otherActions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull action, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertController addAction:action];
    }];
    
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


#pragma mark - SJDrawView

@implementation SJDrawUIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if ( _drawBlock ) _drawBlock(self);
}

@end

