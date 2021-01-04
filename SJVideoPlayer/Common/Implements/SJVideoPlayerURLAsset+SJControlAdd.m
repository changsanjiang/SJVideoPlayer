//
//  SJVideoPlayerURLAsset+SJControlAdd.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import <objc/message.h>
#import "SJVideoPlayerConfigurations.h"
#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@implementation SJVideoPlayerURLAsset (SJControlAdd)

- (nullable instancetype)initWithTitle:(NSString *)title URL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithTitle:title URL:URL startPosition:0 playModel:playModel];
}

- (nullable instancetype)initWithTitle:(NSString *)title URL:(NSURL *)URL startPosition:(NSTimeInterval)startPosition playModel:(__kindof SJPlayModel *)playModel {
    if ( URL == nil ) return nil;
    self = [self initWithURL:URL startPosition:startPosition playModel:playModel];
    if ( !self ) return nil;
    self.title = title; 
    return self;
}

- (void)setTitle:(nullable NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable NSString *)title {
    return objc_getAssociatedObject(self, _cmd);
}

- (nullable instancetype)initWithAttributedTitle:(NSAttributedString *)title
                                             URL:(NSURL *)URL
                                       playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithAttributedTitle:title URL:URL startPosition:0 playModel:playModel];
}

- (nullable instancetype)initWithAttributedTitle:(NSAttributedString *)title
                                             URL:(NSURL *)URL
                                startPosition:(NSTimeInterval)startPosition
                                       playModel:(__kindof SJPlayModel *)playModel {
    if ( URL == nil ) return nil;
    self = [self initWithURL:URL startPosition:startPosition playModel:playModel];
    if ( self ) {
        self.attributedTitle = title;
    }
    return self;
}

- (void)setAttributedTitle:(nullable NSAttributedString *)attributedTitle {
    objc_setAssociatedObject(self, @selector(attributedTitle), attributedTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable NSAttributedString *)attributedTitle {
    NSAttributedString *_Nullable astr = objc_getAssociatedObject(self, _cmd);
    if ( astr == nil && self.title != nil ) {
        id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
        astr = [[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(self.title);
            make.font(sources.titleLabelFont);
            make.textColor(sources.titleLabelColor);
            make.lineBreakMode(NSLineBreakByTruncatingTail);
            make.shadow(^(NSShadow * _Nonnull make) {
                make.shadowOffset = CGSizeMake(0, 0.5);
                make.shadowColor = UIColor.blackColor;
            });
        }] copy];
        [self setAttributedTitle:astr];
    }
    return astr;
}
@end
NS_ASSUME_NONNULL_END
