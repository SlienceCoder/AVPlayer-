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

@interface RemoteResourceLoaderDelegate () <AudioDownloaderDelegate>

@property (nonatomic, strong) AudioDownloader *downloader;


@property (nonatomic, strong) NSMutableArray *loadingRequests;
@end

@implementation RemoteResourceLoaderDelegate

- (NSMutableArray *)loadingRequests
{
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}
- (AudioDownloader *)downloader
{
    if (!_downloader) {
        _downloader = [[AudioDownloader alloc] init];
        _downloader.delegate = self;
    }
    return _downloader;
}
// 当外界。需要播放一段音频资源时候呢，会抛出一个请求，给这个对象
// 这个对象，到时候，只需要根据请求信息，抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
//    NSLog(@"%@",loadingRequest);
    
    // 1.本地有没有该文件的缓存，如果有，直接根据本地缓存，相应外界数据（3个步骤）
    // 拿到路径
    // 判断有没
    NSURL *url = loadingRequest.request.URL;
    
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    
    
    if ([RemoteAudioFile cacheFileExist:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    // 记录所有请求
    [self.loadingRequests addObject:loadingRequest];
    
    // 2.判断没有在下载
    if (self.downloader.loadingSize == 0) {
        //
        NSURL *httpUrl = [url httpURL];
        
        
        
        [self.downloader downloadWithURL:httpUrl offset:requestOffset];
        
        
        return YES;
    }
    
    //3.当前是否需要下载
    // 3.1当前资源请求，开始点<下载的开始点
    
    // 3.2当资源的请求，开始点>开始的下载点+下载长度+666
    if (requestOffset < self.downloader.offset || requestOffset > (self.downloader.offset+self.downloader.loadingSize+666)) {
        [self.downloader downloadWithURL:url offset:requestOffset];
        
        return YES;
    }
    
    // 开始处理资源请求(在下载过程中也要不断的判断)
    [self handleAllLoadingRequest];
    
    
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
    [self.loadingRequests removeObject:loadingRequest];
}

- (void)handleAllLoadingRequest
{
    NSLog(@"不断处理请求");
    NSMutableArray *deleteRequest = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        // 1.填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.downloader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        
        NSString *contentType = self.downloader.mineType;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        // 2.填充数据
        NSData *data = [NSData dataWithContentsOfFile:[RemoteAudioFile tempFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:[RemoteAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        long long requestLength = loadingRequest.dataRequest.requestedLength;
        
        
        long long responseOffset = requestOffset - self.downloader.offset;
        long long responseLength = MIN(self.downloader.offset+self.downloader.loadingSize-requestOffset, requestLength);
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        [loadingRequest.dataRequest respondWithData:subData];
        
        // 3.完成请求(必须把关于这个请求的区间数据都返回完才完成这个请求)
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [deleteRequest addObject:loadingRequest];
        }
        [self.loadingRequests removeObjectsInArray:deleteRequest];
       
    }
    
   
    

}
- (void)downLoading
{
    [self handleAllLoadingRequest];
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
