//
//  PlayerCollectionViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "PlayerCollectionViewController.h"
#import "PlayerCollectionViewCell.h"
#import <Masonry.h>
#import "SJVideoPlayer.h"

static NSString * const PlayerCollectionViewCellID = @"PlayerCollectionViewCell";

@interface PlayerCollectionViewController ()<PlayerCollectionViewCellDelegate>

@property (nonatomic, strong, readwrite) SJVideoPlayer *videoPlayer;

@end

@implementation PlayerCollectionViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = [PlayerCollectionViewCell itemSize];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) { }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CollectionView";

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PlayerCollectionViewCell class] forCellWithReuseIdentifier:PlayerCollectionViewCellID];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _videoPlayer.disableRotation = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _videoPlayer.disableRotation = YES;
}

- (void)dealloc {
    [_videoPlayer stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:PlayerCollectionViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)clickedPlayOnColCell:(PlayerCollectionViewCell *)cell {
    [self _removeOldPlayer];

    [self _createNewPlayerWithView:cell.backgroundImageView indexPath:[self.collectionView indexPathForCell:cell] tag:cell.backgroundImageView.tag videoURLStr:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"];
}

- (void)_removeOldPlayer {
    // clear old player
    SJVideoPlayer *oldPlayer = _videoPlayer;
    if ( !oldPlayer ) return;
    [oldPlayer stopAndFadeOut];
}

- (void)_createNewPlayerWithView:(UIView *)view
                       indexPath:(NSIndexPath *)indexPath
                             tag:(NSInteger)tag
                     videoURLStr:(NSString *)videoURLStr {
    // create new player
    _videoPlayer = [SJVideoPlayer player];
    _videoPlayer.view.alpha = 0.001;
    [view addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    // fade in
    [UIView animateWithDuration:0.5 animations:^{
        self->_videoPlayer.view.alpha = 1;
    }];
    
    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:videoURLStr] scrollView:self.collectionView indexPath:indexPath superviewTag:tag];
    
    _videoPlayer.autoPlay = YES;
}

@end

#if 0
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
static UIImage *frameImage(CGSize size, CGFloat radians) {
    UIGraphicsBeginImageContextWithOptions(size, YES, 1); {
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectInfinite);
        CGContextRef gc = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(gc, size.width / 2, size.height / 2);
        CGContextRotateCTM(gc, radians);
        CGContextTranslateCTM(gc, size.width / 4, 0);
        [[UIColor redColor] setFill];
        CGFloat w = size.width / 10;
        CGContextFillEllipseInRect(gc, CGRectMake(-w / 2, -w / 2, w, w));
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
static void makeAnimatedGif(void) {
    static NSUInteger kFrameCount = 16;
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @0.02f, // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"animated.gif"];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            UIImage *image = frameImage(CGSizeMake(300, 300), M_PI * 2 * i / kFrameCount);
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    CFRelease(destination);
    
    NSLog(@"url=%@", fileURL);
}
#endif
