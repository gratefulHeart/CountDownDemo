//
//  ViewController.m
//  CountDownDemo
//
//  Created by gfy on 2020/3/1.
//  Copyright © 2020 gfy. All rights reserved.
//

#import "ViewController.h"
#import "NSProcessInfo+Add.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *countButton;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;

/// 定时器
@property (nonatomic, weak) NSTimer *timer;
///// 倒计时剩余时长
@property (nonatomic, assign) NSInteger timerSeconds;

//退到后台记录时间 此时间是 优化后即包含锁屏时间的 systemuptime
@property (nonatomic, assign) NSTimeInterval currentUptime;

@end

@implementation ViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    尽量取 服务器时间  计算时间差
    self.timerSeconds = 1800;
    
    [self setupNotifications];
    
}
#pragma mark - Timer
- (void)startTimer {
    
    NSTimer *timer0 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(countDownTimerSeconds) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer0 forMode:NSRunLoopCommonModes];
    self.timer = timer0;
    
}
- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)countDownTimerSeconds {
    self.timerSeconds -= 1;
    
    if (self.timerSeconds <= 0) {
        //        倒计时结束
        [self stopTimer];
        self.timerSeconds = 0;
        self.countButton.enabled = YES;

        //        处理跳转下场直播逻辑
    }
    self.countDownLabel.text = [self formatCountDownTime:self.timerSeconds];

}
#pragma mark - Notifications
- (void)setupNotifications {
    
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name: UIApplicationDidEnterBackgroundNotification object:nil];
    //    通知外部音频暂停
}

- (void)applicationBecomeActive:(NSNotification *)noti {
    
    NSTimeInterval duration = [[NSProcessInfo processInfo] correctSystemUptime] - self.currentUptime;
    NSLog(@"duration === %f",duration);
    if (duration < 0) {
        duration = 0;
    }
    NSTimeInterval total =  self.timerSeconds - duration;
    if(total < 0) {
        total = 0;
    }
    
    self.timerSeconds = total;
    [self.timer setFireDate:[NSDate date]];
    
    
}
- (void)applicationEnterBackground:(NSNotification *)noti {
    self.currentUptime = [[NSProcessInfo processInfo] correctSystemUptime];
    
    [self.timer setFireDate:[NSDate distantFuture]];
    
}

#pragma  mark -Actions
- (IBAction)countButtonClick:(id)sender {
    self.countButton.enabled = NO;
    [self startTimer];
}

#pragma mark - Tool
- (NSString *)formatCountDownTime:(NSTimeInterval)timeInterval  {
    
    if (timeInterval < 60 * 60 ){
        int minus = (int)timeInterval / 60;
        int seconds = (long)timeInterval % 60;
        NSString *formatMinus = (minus >= 10)?[NSString stringWithFormat:@"%d",minus]:[NSString stringWithFormat:@"0%d",minus];
        NSString *formatSeconds = (seconds >= 10)?[NSString stringWithFormat:@"%d",seconds]:[NSString stringWithFormat:@"0%d",seconds];
        return  [NSString stringWithFormat:@"%@:%@",formatMinus,formatSeconds];
    }else{
        int hours = (int)timeInterval / (60 * 60);
        int minus = ((long)timeInterval %(60 * 60)) / 60;
        int seconds = (long)timeInterval % 60;
        NSString *formatHours = (hours >= 10)?[NSString stringWithFormat:@"%d",hours]:[NSString stringWithFormat:@"0%d",hours];
        NSString *formatMinus = (minus >= 10)?[NSString stringWithFormat:@"%d",minus]:[NSString stringWithFormat:@"0%d",minus];
        NSString *formatSeconds = (seconds >= 10)?[NSString stringWithFormat:@"%d",seconds]:[NSString stringWithFormat:@"0%d",seconds];
        return  [NSString stringWithFormat:@"%@:%@:%@",formatHours,formatMinus,formatSeconds];
    }
    return @"00:00";
}
@end
