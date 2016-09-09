//
//  ViewController.m
//  testDemo
//
//  Created by qiyun on 16/9/2.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVPlayerViewController.h>
#import "IDYDownloadManager.h"

@interface ViewController ()
@property (nonatomic, strong) IDYButton  *completeButton;               /* 完成 */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.completeButton];
    
    [[IDYDownloadManager shareInstanceManager] requestWithUrl:[NSURL URLWithString:@"http://baobab.wdjcdn.com/1455968234865481297704.mp4"] fileName:@"1008.mp4"];
    [[IDYDownloadManager shareInstanceManager] requestWithUrl:[NSURL URLWithString:@"http://baobab.wdjcdn.com/1458625865688ONE.mp4"] fileName:@"1009.mp4"];
    [[IDYDownloadManager shareInstanceManager] requestWithUrl:[NSURL URLWithString:@"http://baobab.wdjcdn.com/1458625865688ONE.mp4"] fileName:@"1010.mp4"];
    
}


- (void)videoFinished:(NSNotification *)not{
    
    NSLog(@"finished...");
}

- (IDYButton *)completeButton{
    
    if (!_completeButton) {
        
        _completeButton = [IDYButton buttonWithType:UIButtonTypeCustom];
        _completeButton.normalImageNamed = dy_video_record_confirm;
        _completeButton.titleString = dy_camera_record_comp;
        _completeButton.frame = CGRectMake(100, 100, 50, 50);
        
        
    }
    return _completeButton;
}

- (void)player{
    
    NSString *urlString = @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
    
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:urlString]];
    // 初始化playerItem
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    // create an AVPlayer
    //AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:urlString]];
    
    // create a player view controller
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    controller.player = player;
    [player play];
    
    // show the view controller
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    controller.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 300);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
