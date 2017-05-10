//
//  RemotePlayer.h
//  播放器
//
//  Created by xpchina2003 on 2017/5/9.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

// 播放器的状态
typedef NS_ENUM(NSInteger, RemoteAudioPalyerState) {

    RemoteAudioPlayerStateUnkonwn = 0, // 未知
    RemoteAudioPlayerStateLoading = 1, // 正在加载
    RemoteAudioPlayerStatePlaying = 2, // 正在播放
    RemoteAudioPlayerStateStopped = 3, // 停止
    RemoteAudioPlayerStatePause = 4, // 暂停
    RemoteAudioPlayerStateFaild = 5 // 失败
    
};

@interface RemotePlayer : NSObject
+ (instancetype)shareInstance;
- (void)playWithURL:(NSURL *)url isCache:(BOOL)cache;
- (void)pause;
- (void)resume;
- (void)stop;


- (void)seekWithTimeDiffer:(NSTimeInterval)timerdiffer;
- (void)seekWithTimeprogress:(float)progress;

//- (void)setRate:(float)rate;
- (void)setMute:(BOOL)muted;
//- (void)setVolume:(float)volume;

#pragma mark --数据提供
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
@property (nonatomic, copy, readonly) NSString *totalTimeFormat;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, copy, readonly) NSString *currentTimeFormat;
@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign, readonly) float loadDataProgress;

@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float rate;

@property (nonatomic, assign, readonly) RemoteAudioPalyerState state; // 更改状态



@end
