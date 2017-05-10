//
//  ViewController.m
//  播放器
//
//  Created by xpchina2003 on 2017/5/9.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "ViewController.h"
#import "RemotePlayer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *playtime;
@property (weak, nonatomic) IBOutlet UILabel *totaltime;

@property (weak, nonatomic) IBOutlet UIProgressView *loadpv;
@property (weak, nonatomic) IBOutlet UISlider *playSilder;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation ViewController

- (NSTimer *)timer
{
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self timer];
}

- (IBAction)play:(id)sender {
    
    [[RemotePlayer shareInstance] playWithURL:[NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"] isCache:YES];
}
- (IBAction)pause:(id)sender {
    [[RemotePlayer shareInstance] pause];
}
- (IBAction)resume:(id)sender {
    [[RemotePlayer shareInstance] resume];
}
- (IBAction)kuaijin:(id)sender {
    [[RemotePlayer shareInstance] seekWithTimeDiffer:15];
}
- (IBAction)progress:(UISlider *)sender {
    [[RemotePlayer shareInstance] seekWithTimeprogress:sender.value];
}
- (IBAction)rate:(id)sender {
    [[RemotePlayer shareInstance] setRate:2];
}
- (IBAction)mute:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[RemotePlayer shareInstance] setMute:sender.selected];
}
- (IBAction)volume:(UISlider *)sender {
    [[RemotePlayer shareInstance] setVolume:sender.value];
}

- (void)update
{
    NSLog(@"-------------------||%ld",(long)[RemotePlayer shareInstance].state);
  
    self.playtime.text = [[RemotePlayer shareInstance] currentTimeFormat];;
    self.totaltime.text = [[RemotePlayer shareInstance] totalTimeFormat];;
    
    self.playSilder.value = [RemotePlayer shareInstance].progress;
    self.volumeSlider.value = [RemotePlayer shareInstance].volume;
    
    self.loadpv.progress = [RemotePlayer shareInstance].loadDataProgress;
    self.muteBtn.selected = [RemotePlayer shareInstance].muted;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
