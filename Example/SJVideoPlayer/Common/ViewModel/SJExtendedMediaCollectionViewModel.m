//
//  SJExtendedMediaCollectionViewModel.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJExtendedMediaCollectionViewModel.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJExtendedMediaCollectionViewModel
- (instancetype)initWithItem:(SJVideoModel *)item mediaTitleFont:(nonnull UIFont *)font {
    self = [super init];
    if ( self ) {
        _url = item.URL;
        _cover = item.cover;
        _avatar = item.avatar;
        
        _mediaTitle = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.textColor([UIColor blackColor]);
            make.font(font);
            make.append(item.mediaTitle);
        }];
        
        _username = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.textColor([UIColor blackColor]);
            make.font([UIFont systemFontOfSize:14]);
            make.append(item.username);
        }];
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
