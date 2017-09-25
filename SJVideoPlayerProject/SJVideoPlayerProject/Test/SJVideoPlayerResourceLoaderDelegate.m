//
//  SJVideoPlayerResourceLoaderDelegate.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/17.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerResourceLoaderDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation SJVideoPlayerResourceLoaderDelegate

// 当外界需要播放一段资源时, 会抛一个请求到这里 , 到时候, 只需要根据请求信息, 抛数据给外界。
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"resourceLoader: \n%@\n", resourceLoader);
    NSLog(@"loadingRequest: \n%@\n", loadingRequest);

    
    // 1. 如何根据请求信息, 返回给外界
    loadingRequest.contentInformationRequest.contentLength = 3840883;
    
    NSString *mimeType = @"video/mp4";
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2. 响应数据给外界
    NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil] options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestedLength = loadingRequest.dataRequest.requestedLength;
    
    data = [data subdataWithRange:NSMakeRange(requestOffset, requestedLength)];
    
    [loadingRequest.dataRequest respondWithData:data];
    
    // 3. 完成请求方法
    [loadingRequest finishLoading];
    
    
    /*!
<AVAssetResourceLoadingRequest: 0x17400e870, URL request = <NSMutableURLRequest: 0x17400eaa0> { URL: streaming://vod.lanwuzhe.com/9da7002189d34b60bbf82ac743241a61/d0539e7be21a4f8faa9fef69a67bc1fb-5287d2089db37e62345123a1be272f8b.mp4?video= }, request ID = 2, content information request = <AVAssetResourceLoadingContentInformationRequest: 0x17400e9d0, content type = "(null)", content length = 0, byte range access supported = NO, disk caching permitted = NO, renewal date = (null)>, data request = <AVAssetResourceLoadingDataRequest: 0x17400e8f0, requested offset = 0, requested length = 2, requests all data to end of resource = NO, current offset = 0>>
     */
    return YES;
}

//- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest {
//    return YES;
//}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest  {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

//- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForResponseToAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge {
//    return YES;
//}
//
//- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge {
//    
//}

- (void)dealloc {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

@end
