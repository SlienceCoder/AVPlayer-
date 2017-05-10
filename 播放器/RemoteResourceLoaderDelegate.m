//
//  RemoteResourceLoaderDelegate.m
//  播放器
//
//  Created by xpchina2003 on 2017/5/10.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "RemoteResourceLoaderDelegate.h"

@implementation RemoteResourceLoaderDelegate

// 当外界。需要播放一段音频资源时候呢，会抛出一个请求，给这个对象
// 这个对象，到时候，只需要根据请求信息，抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"%@",loadingRequest);
    // 如何根据请求信息返回给外界
    // 1.填充相应的相应信息
    loadingRequest.contentInformationRequest.contentLength = 4093201;
    loadingRequest.contentInformationRequest.contentType = @"public.mp3";
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    
    // 2.相应数据给外界
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/xpchina/Desktop/235319.mp3" options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long requestLength = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3.完成本次请求（一旦所有的数据请求完了，才能调用完成请求方法）
    [loadingRequest finishLoading];
    
    
    return YES;
}
// 取消请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"取消");
}
@end
