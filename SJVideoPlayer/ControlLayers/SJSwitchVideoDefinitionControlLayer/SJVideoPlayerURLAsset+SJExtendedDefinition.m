//
//  SJVideoPlayerURLAsset+SJExtendedDefinition.m
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#import "SJVideoPlayerURLAsset+SJExtendedDefinition.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJVideoPlayerURLAsset (SJExtendedDefinition)

- (void)setDefinition_fullName:(nullable NSString *)definition_fullName {
    objc_setAssociatedObject(self, @selector(definition_fullName), definition_fullName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable NSString *)definition_fullName {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDefinition_lastName:(nullable NSString *)definition_lastName {
    objc_setAssociatedObject(self, @selector(definition_lastName), definition_lastName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable NSString *)definition_lastName {
    NSString *_Nullable name = objc_getAssociatedObject(self, _cmd);
    if ( name != nil )
        return name;
    return self.definition_fullName;
}
@end
NS_ASSUME_NONNULL_END
