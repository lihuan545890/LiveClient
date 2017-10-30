//
//  StreamTestViewController.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "StreamTestViewController.h"

#import "LiveStreamSession.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

#import "LSRequestManager.h"

@interface StreamTestViewController ()

@property (strong) LiveStreamPlayer *palyer;
@property (strong) LiveStreamPublisher *publisher;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation StreamTestViewController
#pragma mark - 界面初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.previewView.fillMode = kGPUImageFillModePreserveAspectRatio;

    self.publisher = [LiveStreamPublisher instance];
    self.publisher.publishView = self.previewPublishView;

    self.palyer = [LiveStreamPlayer instance];
    self.palyer.playView = self.previewView;

    self.url = @"rtmp://172.25.32.17:8899/live/max";

//    self.textFieldAddress.text = [NSString stringWithFormat:@"%@_mv", self.url, nil];
    self.textFieldAddress.text = @"rtmp://172.25.32.133:8899/play/anchor_fly11_111111112?token=aaa";
    self.textFieldPublishAddress.text = [NSString stringWithFormat:@"%@_i", self.url, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.alpha = 0.7;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 添加手势
    [self addSingleTap];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 去除手势
    [self removeSingleTap];

    // 停止流
    [self stop:nil];
}

- (void)initCustomParam {
    [super initCustomParam];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    //    self.title = @"Self";
    self.tabBarItem.image = [UIImage imageNamed:@"TabBarSelf"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publish:(id)sender {
    //    [self stop:self];

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/%@", recordDir, @"publish.h264"];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/%@", recordDir, @"publish.aac"];

    BOOL bFlag = NO;

    bFlag = [[LiveStreamSession session] canCapture];
    if (bFlag) {

    } else {
        // 无权限
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"请开启摄像头和录音权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action){

                                                         }];
        [alertVC addAction:actionOK];
        [self presentViewController:alertVC animated:NO completion:nil];
    }

    if (bFlag) {
        bFlag = [self.publisher pushlishUrl:self.textFieldPublishAddress.text recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    }

    if (bFlag) {
        // 发布成功

    } else {
        // 发布失败
    }
}

- (IBAction)play:(id)sender {
    //    [self stop:self];

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *recordFilePath = @"";     //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.flv"];
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.h264"];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.aac"];

    // 开始转菊花
    BOOL bFlag = [self.palyer playUrl:self.textFieldAddress.text recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    if (bFlag) {
        // 播放成功

    } else {
        // 播放失败
    }
}

- (IBAction)stop:(id)sender {
    [self.palyer stop];
    [self.publisher stop];
}

- (IBAction)beauty:(id)sender {
    self.publisher.beauty = !self.publisher.beauty;
}

- (IBAction)mute:(id)sender {
    self.publisher.mute = !self.publisher.mute;
}

#pragma mark - 单击屏幕
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
        self.singleTap.delegate = nil;
    }
}

- (void)singleTapAction {
    [self.textFieldAddress resignFirstResponder];
    [self.textFieldPublishAddress resignFirstResponder];

    self.navigationController.navigationBar.alpha = 0.7;
    self.navigationController.navigationBar.hidden = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1
            animations:^{
                self.navigationController.navigationBar.alpha = 0;
            }
            completion:^(BOOL finished) {
                self.navigationController.navigationBar.hidden = YES;
            }];
    });
}

@end