//
//  RemoteAudioFile.m
//  播放器
//
//  Created by xpchina2003 on 2017/5/10.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "RemoteAudioFile.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

#define kTempPath NSTemporaryDirectory()

@implementation RemoteAudioFile


+ (NSString *)tempFilePath:(NSURL *)url
{
     return [kTempPath stringByAppendingString:url.lastPathComponent];
}

// 下载完成 -》 cache+文件名称
+ (NSString *)cacheFilePath:(NSURL *)url
{
    
    return [kCachePath stringByAppendingString:url.lastPathComponent];
    
}
// 下载中 -> tem +文件名称
+ (BOOL)cacheFileExist:(NSURL *)url
{
    NSString *path = [self cacheFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];

}
+ (BOOL)tempFileExist:(NSURL *)url
{
    NSString *path = [self tempFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
+ (long long)cacheFileSize:(NSURL *)url
{
   
    // 1.2计算文件路径对应的文件大小
    if (![self cacheFileExist:url]) {
        return 0;
    }
    // 1.1获取文件路径
    NSString *path = [self cacheFilePath:url];
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [fileInfoDic[NSFileSize] longLongValue];
    
}
+ (long long)tempFileSize:(NSURL *)url
{
    // 1.2计算文件路径对应的文件大小
    if (![self tempFileExist:url]) {
        return 0;
    }
    // 1.1获取文件路径
    NSString *path = [self tempFilePath:url];
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [fileInfoDic[NSFileSize] longLongValue];
}

+ (NSString *)contentType:(NSURL *)url
{
    NSString *path = [self cacheFilePath:url];
    NSString *fileExtension = path.pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    return contentType;
}

+ (void)moveTemPathToCachePath:(NSURL *)url
{
    NSString *temPath = [self tempFilePath:url];
    NSString *cachePath = [self cacheFilePath:url];
    [[NSFileManager defaultManager] moveItemAtPath:temPath toPath:cachePath error:nil];
}

+ (void)clearTempFile:(NSURL *)url
{
    NSString *tempPath = [self tempFilePath:url];
    
    BOOL isDirectory = YES;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&isDirectory];
   
    if (isExist && !isDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    }
    
    
}
@end
