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

- (SJFilmEditingResultUploader *)successfulScreenshot:(UIImage *)screenshot;

- (SJFilmEditingResultUploader *)successfulExportedVideo:(NSURL *)fileURL;

- (void)clickedItem:(SJFilmEditingResultShareItem *)item
         screenshot:(nullable UIImage *)screenshot
recordedVideoFileURL:(nullable NSURL *)recordedVideoFileURL;

@end

@interface SJFilmEditingResultUploader : NSObject

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
