//
//  UIView+Extension.m
//  CSJQQMusic
//
//  Created by ya on 12/21/16.
//  Copyright © 2016 ya. All rights reserved.
//

#import "UIView+Extension.h"


@interface _SJRoundImageView : UIImageView
@end

@implementation _SJRoundImageView
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
    self.clipsToBounds = YES;
}
@end

@interface _SJRoundLabel : UILabel
@end

@implementation _SJRoundLabel
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
    self.clipsToBounds = YES;
}
@end

@interface _SJRoundView : UIView
@end

@implementation _SJRoundView
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
    self.clipsToBounds = YES;
}
@end


@implementation UIView (Extension)


- (UIViewController *)csj_viewController {

    if ([self isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)self;
        UIResponder *responder = view.nextResponder;
        while ( ![responder isKindOfClass:[UIViewController class]] ) {
            if ( [responder isMemberOfClass:[UIResponder class]] ) {
                return nil;
            }
            responder = responder.nextResponder;
        }
        return (UIViewController *)responder;
    }

    return nil;
}

 /// 截当前视图, 返回Image.
- (UIImage *)csj_currentSnapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

 /// 视图底部 用OC 画虚线. ⚠️ 需要把代码拷贝到 drawRect中.
- (void)csj_lyXuXian {

    CGRect  rect        = self.bounds;
    CGFloat width       = rect.size.width;
    CGFloat height      = rect.size.height;
    CGFloat gapSpace    = 4.0;
    CGFloat length      = width - gapSpace * 2;
    NSInteger count     = length * 0.5;
    CGFloat startX      = gapSpace;

    UIBezierPath *path  = [UIBezierPath bezierPath];
    for (int i = 0; i < count * 0.5; i ++) {
        [path moveToPoint:CGPointMake(startX + i * 2.0,
                                      height)];

        [path addLineToPoint:CGPointMake(startX + (i + 1) * 2.0,
                                         height)];
        startX += 2.0;
        [path setLineWidth:6.0 / [UIScreen mainScreen].scale];

        /// 颜色
        [UIColor.redColor set];

        /// 绘制
        [path stroke];
    }
}


- (void)setCsj_x:(CGFloat)csj_x {
    CGRect frame    = self.frame;
    frame.origin.x  = csj_x;
    self.frame      = frame;
}
- (CGFloat)csj_x {
    return self.frame.origin.x;
}


- (void)setCsj_y:(CGFloat)csj_y {
    CGRect frame    = self.frame;
    frame.origin.y  = csj_y;
    self.frame      = frame;
}
- (CGFloat)csj_y {
    return self.frame.origin.y;
}


- (void)setCsj_w:(CGFloat)csj_w {
    CGRect frame        = self.frame;
    frame.size.width    = csj_w;
    self.frame          = frame;
}
- (CGFloat)csj_w {
    return self.frame.size.width;
}


- (void)setCsj_h:(CGFloat)csj_h {
    CGRect frame        = self.frame;
    frame.size.height   = csj_h;
    self.frame          = frame;
}
- (CGFloat)csj_h {
    return self.frame.size.height;
}

- (void)csj_centerWithView:(UIView *)view {
    self.center = CGPointMake(view.csj_w * 0.5, view.csj_h * 0.5);
}

- (void)setCsj_size:(CGSize)csj_size {
    CGRect frame        = self.frame;
    frame.size          = csj_size;
    self.frame          = frame;

}

- (CGSize)csj_size {
    return self.frame.size;
}

- (void)setCsj_centerX:(CGFloat)csj_centerX {
    CGPoint center  = self.center;
    center.x        = csj_centerX;
    self.center     = center;
}
- (CGFloat)csj_centerX {
    
    return self.center.x;
}


- (void)setCsj_centerY:(CGFloat)csj_centerY {
    CGPoint center  = self.center;
    center.y        = csj_centerY;
    self.center     = center;
}
- (CGFloat)csj_centerY {
    return self.center.y;
}

- (void)csj_cornerRadius {
    CGFloat min = MIN(self.csj_w, self.csj_h);
    self.layer.cornerRadius  = min * 0.5;
    self.clipsToBounds       = YES;
}

#pragma mark - layer
- (void)rounded:(CGFloat)cornerRadius {
    [self rounded:cornerRadius width:0 color:nil];
}

- (void)border:(CGFloat)borderWidth color:(UIColor *)borderColor {
    [self rounded:0 width:borderWidth color:borderColor];
}

- (void)rounded:(CGFloat)cornerRadius width:(CGFloat)borderWidth color:(UIColor *)borderColor {
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = [borderColor CGColor];
    self.layer.masksToBounds = YES;
}


-(void)round:(CGFloat)cornerRadius RectCorners:(UIRectCorner)rectCorner {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}


-(void)shadow:(UIColor *)shadowColor opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset {
    //给Cell设置阴影效果
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
}


#pragma mark - base

+ (CGFloat)getLabelHeightByWidth:(CGFloat)width Title:(NSString *)title font:(UIFont *)font {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

- (BOOL)sjHasSubView:(UIView *)subView {
    __block BOOL bol = NO;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj == subView ) {
            bol = YES;
            *stop = YES;
        }
    }];
    return bol;
}

// MARK: Animations

- (void)revealAnimation {
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionReveal;
    anima.subtype = kCATransitionFromRight;
    anima.duration = 0.5;
    anima.fillMode = kCAFillModeForwards;
    anima.removedOnCompletion = NO;
    [self.layer addAnimation:anima forKey:@"anima"];
}

- (void)cubeAnimation {
    [self animationWithType:@"cube" key:@"anima"];
}

- (void)rippleEffectAnimation {
    [self animationWithType:@"rippleEffect" key:@"rippleEffectAnimation"];
}

- (void)fadeAnimation {
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionFade;
    anima.subtype = kCATransitionFromRight;
    anima.duration = 1.0f;
    [self.layer addAnimation:anima forKey:@"fadeAnimation"];
}

- (void)animationWithType:(NSString *)type key:(NSString *)key {
    CATransition *anima = [CATransition animation];
    anima.type = type; 
    anima.subtype = kCATransitionFromRight;
    anima.duration = 1.0f;
    [self.layer addAnimation:anima forKey:key];
}

- (void)scaleAnimation {
    CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    NSValue *value1 = [NSNumber numberWithFloat:1.2];
    NSValue *value2 = [NSNumber numberWithFloat:1.1];
    NSValue *value3 = [NSNumber numberWithFloat:1.0];
    anima.values = @[value1, value2, value3];
    anima.repeatCount = 1;
    [self.layer addAnimation:anima forKey:@"scaleAnimation"];
}
    
- (void)praiseAnimationWithFatherView:(UIView *)fatherView complete:(void(^)())block {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    NSInteger random = arc4random() % 8;
    NSString *imageName = [NSString stringWithFormat:@"zan_%02zd", random];
    imageView.image = [UIImage imageNamed:imageName];
    [fatherView addSubview:imageView];
    
    CGPoint position = [self.superview convertPoint:self.center toView:fatherView];
    position.y -= 25;
    imageView.layer.position = position;
    
    NSTimeInterval totalAnimationDuration = 6;
    
    imageView.alpha = 0.0;
    imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    /*!
     *  弹出动画 阻尼动画
     */
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:50 options:UIViewAnimationOptionCurveEaseOut animations:^{
        imageView.alpha = 0.9;
        imageView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    /*!
     *  随机偏转角度
     */
    NSInteger i = arc4random_uniform(2);
    NSInteger rotationDirection = 1 - ( 2 * i);// -1 OR 1,随机方向
    
    /*!
     *  图片在上升过程中旋转
     */
    NSInteger rotationFraction = arc4random_uniform(10); //随机角度
    [UIView animateWithDuration:4 animations:^{
        imageView.transform = CGAffineTransformMakeRotation(rotationDirection * M_PI/(4 + rotationFraction * 0.2));
    } completion:nil];
    
    /*!
     *  动画路径
     */
    UIBezierPath *sPath = [UIBezierPath bezierPath];
    [sPath moveToPoint:position];
    
    CGFloat AnimH = 100; // 动画路径高度,
    
    // 随机终点
    CGFloat ViewX = position.x;
    CGFloat ViewY = position.y;
    CGPoint endPoint = CGPointMake(ViewX + rotationDirection* 0, ViewY - AnimH);
    
    
    /*!
     *  随机control点
     */
    CGFloat sign = arc4random()%2 == 1 ? 1 : -1;
    CGFloat controlPointValue = (arc4random()%50 + arc4random()%100) * sign;
    CGPoint controlPoint1 = CGPointMake(position.x - controlPointValue, position.y - 300);
    CGPoint controlPoint2 = CGPointMake(position.x + controlPointValue, position.y - 300);
    
    /*!
     *  根据贝塞尔曲线添加动画
     */
    [sPath addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
    CGFloat duration = totalAnimationDuration + endPoint.y / AnimH; //endPoint.y/AnimH; //arc4random()%5;
    
    CAKeyframeAnimation *positionAnimate = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimate.repeatCount = 1;
    positionAnimate.duration = duration;
    positionAnimate.fillMode = kCAFillModeForwards;
    positionAnimate.removedOnCompletion = NO;
    positionAnimate.path = sPath.CGPath;
    [imageView.layer addAnimation:positionAnimate forKey:@"heartAnimated"];
    
    /*!
     *  消失动画
     */
    [UIView animateWithDuration:totalAnimationDuration - arc4random() % 3 animations:^{
        imageView.layer.opacity = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        if ( block ) block();
    }];

}

- (void)praiseAnimationWithFatherView:(UIView *)fatherView {
    [self praiseAnimationWithFatherView:fatherView complete:nil];
}

// MARK: 创建视图

+ (UIView *)roundViewWithBackGroundColor:(UIColor *)backgroundColor {
    _SJRoundView *view = [_SJRoundView new];
    view.backgroundColor = backgroundColor;
    return view;
}

+ (UIImageView *)imageViewWithImageStr:(NSString *)imageStr {
    return [self imageViewWithImageStr:imageStr viewMode:UIViewContentModeScaleAspectFit];
}

+ (UIImageView *)imageViewWithImageStr:(NSString *)imageStr viewMode:(UIViewContentMode)viewMode {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStr]];
    imageView.contentMode = viewMode;
    imageView.clipsToBounds = YES;
    return imageView;
}

+ (UIImageView *)roundImageViewWithImageStr:(NSString *)imageStr viewMode:(UIViewContentMode)viewMode {
    _SJRoundImageView *imageView = [[_SJRoundImageView alloc] initWithImage:[UIImage imageNamed:imageStr]];
    imageView.contentMode = viewMode;
    imageView.clipsToBounds = YES;
    return imageView;
}

+ (UILabel *)labelWithFontSize:(CGFloat)size textColor:(UIColor *)textColor {
    return [self labelWithFontSize:size textColor:textColor alignment:NSTextAlignmentLeft];
}

+ (UILabel *)labelWithFontSize:(CGFloat)size textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment {
    return [self labelWithFontSize:size textColor:textColor alignment:alignment backgroundColor:[UIColor clearColor]];
}

+ (UILabel *)labelWithFontSize:(CGFloat)size textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment backgroundColor:(UIColor *)backgroundColor {
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:size];
    label.textAlignment = alignment;
    label.textColor = textColor;
    label.backgroundColor = backgroundColor;
    return label;
}

+ (UILabel *)roundLabelWithFontSize:(CGFloat)size textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment backgroundColor:(UIColor *)backgroundColor {
    _SJRoundLabel *label = [[_SJRoundLabel alloc] init];
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = textColor;
    label.textAlignment = alignment;
    label.backgroundColor = backgroundColor;
    return label;
}

+ (UILabel *)roundLabelWithFontSize:(CGFloat)size textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment {
    return [self roundLabelWithFontSize:size textColor:textColor alignment:alignment backgroundColor:[UIColor clearColor]];
}

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

+ (UIButton *)buttonWithImageName:(NSString *)imageName tag:(NSUInteger)tag target:(id)target sel:(SEL)sel {
    return [self buttonWithImageName:imageName title:nil tag:tag target:target sel:sel];
}

+ (UIButton *)buttonWithImageName:(NSString *)imageName title:(NSString *)title tag:(NSUInteger)tag target:(id)target sel:(SEL)sel {
    return [self buttonWithImageName:imageName title:title backgroundColor:nil tag:tag target:target sel:sel];
}

+ (UIButton *)buttonWithImageName:(NSString *)imageName title:(NSString *)title backgroundColor:(UIColor *)backgroundColor tag:(NSUInteger)tag target:(id)target sel:(SEL)sel {
    return [self buttonWithImageName:imageName title:title titleColor:[UIColor whiteColor] backgroundColor:nil tag:tag target:target sel:sel];
}

+ (UIButton *)buttonWithImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor tag:(NSUInteger)tag target:(id)target sel:(SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    btn.backgroundColor = backgroundColor;
    btn.tag = tag;
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    return btn;

}

+ (UIButton *)buttonWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor tag:(NSUInteger)tag  target:(id)target sel:(SEL)sel fontSize:(CGFloat)fontSize {
    return [self buttonWithTitle:title titleColor:nil backgroundColor:backgroundColor tag:tag target:target sel:sel fontSize:fontSize];
}

+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor tag:(NSUInteger)tag target:(id)target sel:(SEL)sel fontSize:(CGFloat)fontSize {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn setBackgroundColor:backgroundColor];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    return btn;
}
@end
