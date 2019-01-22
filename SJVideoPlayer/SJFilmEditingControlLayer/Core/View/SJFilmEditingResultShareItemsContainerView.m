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

#if __has_include(<SJAttributesFactory/SJAttributeWorker.h>)
#import <SJAttributesFactory/SJAttributeWorker.h>
#else
#import "SJAttributeWorker.h"
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
        [btn setAttributedTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            make.insertImage(obj.image, 0, CGPointZero, CGSizeMake(40, 40));
            make.insertText(@"\n", -1);
            make.insertText(obj.title, -1);
            make.lineSpacing(8);
            make.alignment(NSTextAlignmentCenter);
            make.font([UIFont systemFontOfSize:10]).textColor([UIColor whiteColor]);
        }) forState:UIControlStateNormal];
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
