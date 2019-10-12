//
//  SJVideoPlayerURLAsset+SJControlAdd.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import <objc/message.h>

@implementation SJVideoPlayerURLAsset (SJControlAdd)

- (nullable instancetype)initWithTitle:(NSString *)title URL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithTitle:title URL:URL specifyStartTime:0 playModel:playModel];
}

- (nullable instancetype)initWithTitle:(NSString *)title URL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime playModel:(__kindof SJPlayModel *)playModel {
    if ( URL == nil ) return nil;
    self = [self initWithURL:URL specifyStartTime:specifyStartTime playModel:playModel];
    if ( !self ) return nil;
    self.title = title; 
    return self;
}

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)title {
    return objc_getAssociatedObject(self, _cmd);
}

- (nullable instancetype)initWithAttributedTitle:(NSAttributedString *)title
                                             URL:(NSURL *)URL
                                       playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithAttributedTitle:title URL:URL specifyStartTime:0 playModel:playModel];
}

- (nullable instancetype)initWithAttributedTitle:(NSAttributedString *)title
                                             URL:(NSURL *)URL
                                specifyStartTime:(NSTimeInterval)specifyStartTime
                                       playModel:(__kindof SJPlayModel *)playModel {
    if ( URL == nil ) return nil;
    self = [self initWithURL:URL specifyStartTime:specifyStartTime playModel:playModel];
    if ( self ) {
        self.attributedTitle = title;
    }
    return self;
}

- (void)setAttributedTitle:(nullable NSAttributedString *)attributedTitle {
    objc_setAssociatedObject(self, @selector(attributedTitle), attributedTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSAttributedString *)attributedTitle {
    return objc_getAssociatedObject(self, _cmd);
}
@end
