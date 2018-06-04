//
//  SJFilmEditingResultShareItem.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJFilmEditingResultShareItem : NSObject
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
/**
 Whether can clicked When Uploading.
 上传时, 是否可以点击
 
 default is NO.
 */
@property (nonatomic) BOOL canAlsoClickedWhenUploading;
@end
