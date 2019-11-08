//
//  SJFilmEditingResultShareItemsContainerView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJFilmEditingResultShareItemsContainerView.h"
#import "SJFilmEditingResultShareItem.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@implementation SJFilmEditingResultShareItemsContainerView

- (void)clickedBtn:(UIButton *)btn {
    if ( _clickedShareItemExeBlock ) _clickedShareItemExeBlock(self, _shareItems[btn.tag]);
}

- (void)setShareItems:(nullable NSArray<SJFilmEditingResultShareItem *> *)shareItems {
    if ( shareItems == _shareItems )
        return;
    _shareItems = shareItems;
    [shareItems enumerateObjectsUsingBlock:^(SJFilmEditingResultShareItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.numberOfLines = 0;
        [btn setAttributedTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.lineSpacing(8)
            .alignment(NSTextAlignmentCenter)
            .font([UIFont systemFontOfSize:10])
            .textColor([UIColor whiteColor]);
            
            make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                make.image = obj.image;
                make.bounds = CGRectMake(0, 0, 40, 40);
            });
            
            make.append(@"\n");
            make.append(obj.title);
        }] forState:UIControlStateNormal];
        btn.tag = idx;
        [btn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
        if ( idx == 0 ) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.top.bottom.offset(0);
            }];
        }
        else if ( idx != (int)shareItems.count - 1 ) {
            UIButton *beforeBtn = self.subviews[(int)idx - 1];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(beforeBtn.mas_right).offset(20);
                make.top.bottom.equalTo(beforeBtn);
            }];
        }
        else {
            UIButton *beforeBtn = self.subviews[(int)idx - 1];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(beforeBtn.mas_right).offset(20);
                make.top.bottom.equalTo(beforeBtn);
                make.right.offset(0);
            }];
        }
    }];
}
@end
NS_ASSUME_NONNULL_END
