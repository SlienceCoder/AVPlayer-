//
//  AudioDownloader.m
//  播放器
//
//  Created by xpchina2003 on 2017/5/10.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "AudioDownloader.h"
#import "RemoteAudioFile.h"

// 下载某一个区域的数据

@interface AudioDownloader () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) NSURL *url;
@end

@implementation AudioDownloader

- (NSURLSession *)session
{
    if (!_session) {
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
    }
    return _session;
}

- (void)downloadWithURL:(NSURL *)url offset:(long long)offset
{
    self.url = url;
    self.offset = offset;
    [self cancelAndClean];
    
    // 请求某以区间的数据
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    
    [task resume];
    
}
- (void)cancelAndClean{
    // 取消
    [self.session invalidateAndCancel];
    self.session = nil;
    
    // 清除本地缓存
    [RemoteAudioFile clearTempFile:self.url];
    // 重置
    self.loadingSize = 0;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{

    NSHTTPURLResponse *httpResponse =  (NSHTTPURLResponse *)response;
    
    self.totalSize = [[[httpResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"] lastObject] longLongValue];
    
    
    self.mineType = response.MIMEType;
    
    
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[RemoteAudioFile tempFilePath:self.url] append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.loadingSize += data.length;
    [self.outputStream write:data.bytes maxLength:data.length];
    
    // 通知外界
    if ([self.delegate respondsToSelector:@selector(downLoading)]) {
        [self.delegate downLoading];
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        // 临时大小等于文件总大小
        NSURL *url = task.response.URL;
        if ([RemoteAudioFile tempFileSize:url] == self.totalSize) {
            // 移动文件到cache
            [RemoteAudioFile moveTemPathToCachePath:url];
        }
        
    } else {
        NSLog(@"youcuowu");
    }
}
@end
