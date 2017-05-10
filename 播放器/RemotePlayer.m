//
//  RemotePlayer.m
//  播放器
//
//  Created by xpchina2003 on 2017/5/9.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "RemotePlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface RemotePlayer ()
@property (nonatomic, strong) AVPlayer *play;

@end

@implementation RemotePlayer
static RemotePlayer *_player;
+ (instancetype)shareInstance
{
    if (!_player) {
        _player = [[RemotePlayer alloc] init];
    }
    return _player;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_player) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _player = [super allocWithZone:zone];
        });
    }
    return _player;
}
- (void)playWithURL:(NSURL *)url
{
    _url = url;
    // 资源的请求
    AVURLAsset *ass = [AVURLAsset assetWithURL:url];
    
    // 资源的组织
    AVPlayerItem *Item = [AVPlayerItem playerItemWithAsset:ass];
    
    // 当资源的组织者告诉我们资源准备完毕播放
    // AVPlayerItemStatus status
    [Item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 创建一个播放器
    self.play = [AVPlayer playerWithPlayerItem:Item];
    
    [self.play play];
    
    
}

- (void)pause
{
    [self.play pause];
}
- (void)resume
{
    [self.play play];
}
- (void)stop
{
    [self.play pause];
    self.play = nil;
}


- (void)seekWithTimeDiffer:(NSTimeInterval)timerdiffer
{
    // 总时长
    
    NSTimeInterval total =  [self totalTime];
    // 已经播放的时长
   
    
   NSTimeInterval playTimeSec =  [self currentTime];
    playTimeSec += timerdiffer;
    
    [self seekWithTimeprogress:playTimeSec / total];

}
- (void)seekWithTimeprogress:(float)progress
{
    if (progress<0 || progress>1) {
        return;
    }
    // 可以指定时间节点去播放
    // 时间CMTime : 影片时间
    // 影片时间转成秒
    // 秒-》饮片时间
    
    
    // 总时长
    
    // 已经播放的时长
//    self.play.currentItem.currentTime
    
    
    
    NSTimeInterval playTimeSec = self.totalTime * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    
    
    [self.play seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间点的音频资源");
        } else {
            NSLog(@"取消加载这个时间点的音频资源");
        }
        
    }];
    
}

- (void)setRate:(float)rate
{
    [self.play setRate:rate];
}
- (float)rate
{
    return self.play.rate;
}

- (void)setMute:(BOOL)muted
{
    [self.play setMuted:muted];
}
- (BOOL)muted
{
    return self.play.muted;
}
- (void)setVolume:(float)volume
{
    
    if (volume < 0|| volume>1) {
        return;
    }
    if (volume>0) {
        [self setMute:NO];
    }
    
    [self.play setVolume:volume];
}
- (float)volume
{
    return self.play.volume;
}

- (NSString *)currentTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.currentTime/60,(int)self.currentTime%60];
}
- (NSString *)totalTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.totalTime/60,(int)self.totalTime%60];
}
#pragma mark --数据事件
- (NSTimeInterval)totalTime
{
    CMTime totalTime = self.play.currentItem.duration;
    NSTimeInterval total =  CMTimeGetSeconds(totalTime);
    if (isnan(total)) {
        return 0;
    }
    return total;
}

- (NSTimeInterval)currentTime
{
    CMTime currentTime = self.play.currentItem.currentTime;
    
    NSTimeInterval playTimeSec = CMTimeGetSeconds(currentTime);
    
    if (isnan(playTimeSec)) {
        return 0;
    }
    return playTimeSec;
}
- (float)progress
{
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime/self.totalTime;
}
- (float)loadDataProgress
{
    if (self.totalTime == 0) {
        return 0;
    }
    
   CMTimeRange timeRange = [[[self.play.currentItem loadedTimeRanges] lastObject] CMTimeRangeValue];
    
  CMTime loadtime =  CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadtime);
    
    return loadTimeSec/self.totalTime;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"statue"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备完毕");
            [self.play play];
        } else {
            NSLog(@"状态未知");
        }
        
    }
}

@end
