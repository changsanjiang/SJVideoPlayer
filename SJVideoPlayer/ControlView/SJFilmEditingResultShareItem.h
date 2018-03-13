//
//  SJFilmEditingResultShareItem.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJFilmEditingResultShareItem, SJFilmEditingResultUploader;

@protocol SJFilmEditingResultShareDelegate;




@interface SJFilmEditingResultShare : NSObject

- (instancetype)initWithShateItems:(NSArray<SJFilmEditingResultShareItem *> *)filmEditingResultShareItems;

@property (nonatomic, weak, readwrite, nullable) id<SJFilmEditingResultShareDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray<SJFilmEditingResultShareItem *> *filmEditingResultShareItems;

@end



#pragma mark -

@protocol SJFilmEditingResultShareDelegate <NSObject>

- (void)prepareToExport;   // 准备导出, 可以做一些准备工作.

- (SJFilmEditingResultUploader *)successfulScreenshot:(UIImage *)screenshot;

- (SJFilmEditingResultUploader *)successfulExportedVideo:(NSURL *)sandboxURL screenshot:(UIImage *)screenshot;

- (void)clickedItem:(SJFilmEditingResultShareItem *)item;

- (void)clickedCancelButton;

@end

@interface SJFilmEditingResultUploader : NSObject

@property (nonatomic, strong, nullable) UIImage *screenshot;
@property (nonatomic, strong, nullable) NSURL *exportedVideoURL;

@property (nonatomic) float progress;
@property (nonatomic) BOOL uploaded;
@property (nonatomic) BOOL failed;

@end



@interface SJFilmEditingResultShareItem : NSObject

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) UIImage *image;

@end
NS_ASSUME_NONNULL_END
