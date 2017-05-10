//
//  RemoteResourceLoaderDelegate.m
//  播放器
//
//  Created by xpchina2003 on 2017/5/10.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "RemoteResourceLoaderDelegate.h"
#import "RemoteAudioFile.h"
#import "AudioDownloader.h"
#import "NSURL+SZ.h"

@interface RemoteResourceLoaderDelegate ()
@property (nonatomic, strong) AudioDownloader *downloader;
@end

@implementation RemoteResourceLoaderDelegate


- (AudioDownloader *)downloader
{
    if (!_downloader) {
        _downloader = [[AudioDownloader alloc] init];
    }
    return _downloader;
}
// 当外界。需要播放一段音频资源时候呢，会抛出一个请求，给这个对象
// 这个对象，到时候，只需要根据请求信息，抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"%@",loadingRequest);
    
    // 1.本地有没有该文件的缓存，如果有，直接根据本地缓存，相应外界数据（3个步骤）
    // 拿到路径
    // 判断有没
    NSURL *url = loadingRequest.request.URL;
    if ([RemoteAudioFile cacheFileExist:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    if (self.downloader.loadingSize == 0) {
        //
        NSURL *httpUrl = [url httpURL];
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        
        [self.downloader downloadWithURL:httpUrl offset:requestOffset];
        
        
        return YES;
    }
    
    // 大步骤
    // 2.判断有没有在下载，如果没有return
    
    // 3。有下载 -> 判断是否需要重新下载，如果是，直接重新下载 return
    
    // 4.处理所有请求，在下载过程中不断的处理请求
    
    
    
    // 如何根据请求信息返回给外界
    
    // 如果本地已经下载好了该文件
    
    
    
    return YES;
}
// 取消请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"取消");
}

#pragma mark --私有方法
// 处理本地已经下载好的资源
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    // 如果本地已经下载好了该文件
    
    // 1.填充相应的相应信息
    // 计算总大小
   
    NSURL *url = loadingRequest.request.URL;
    long long totalSize = [RemoteAudioFile cacheFileSize:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    
    NSString *contentType = [RemoteAudioFile contentType:url];
    loadingRequest.contentInformationRequest.contentType = contentType;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    
    // 2.相应数据给外界
    NSData *data = [NSData dataWithContentsOfFile:[RemoteAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long requestLength = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3.完成本次请求（一旦所有的数据请求完了，才能调用完成请求方法）
    [loadingRequest finishLoading];
    
    
}

@end
