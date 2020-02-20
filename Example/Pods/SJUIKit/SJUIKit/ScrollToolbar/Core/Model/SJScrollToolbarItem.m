//
//  SJScrollToolbarItem.m
//  SJScrollToolbar
//
//  Created by 畅三江 on 2019/12/23.
//

#import "SJScrollToolbarItem.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJScrollToolbarItem
- (instancetype)initWithTitle:(nullable NSString *)title {
    return [self initWithTitle:title imageUrl:nil];
}

- (instancetype)initWithTitle:(nullable NSString *)title imageUrl:(nullable NSString *)imageUrl {
    self = [super init];
    if ( self ) {
        _title = title.copy;
        _imageUrl = imageUrl.copy;
    }
    return self;
}

- (instancetype)initWithAttributedString:(nullable NSAttributedString *)attributedString {
    self = [super init];
    if ( self ) {
        _attributedString = attributedString.copy;
    }
    return self;
}

- (instancetype)initWithImage:(nullable UIImage *)image {
    self = [super init];
    if ( self ) {
        _image = image;
    }
    return self;
}

@end
NS_ASSUME_NONNULL_END
