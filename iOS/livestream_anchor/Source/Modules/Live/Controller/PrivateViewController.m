//
//  PrivateViewController.m
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PrivateViewController.h"
#import "LiveWebViewController.h"
#import "AnchorPersonalViewController.h"

#import "LSImageViewLoader.h"

#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LSConfigManager.h"
#import "LSImManager.h"

#import "DialogTip.h"
#import "DialogOK.h"
#import "DialogChoose.h"

#import "SetFavoriteRequest.h"

#import "RandomGiftModel.h"
#import "UserInfoManager.h"


@interface PrivateViewController () <LiveViewControllerDelegate, IMLiveRoomManagerDelegate, PlayViewControllerDelegate,IMManagerDelegate>
// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
// 资费提示小时计时器
@property (nonatomic, strong) NSTimer *hidenTimer;
// 是否显示资费提示
@property (nonatomic, assign) BOOL isTipShow;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;

#pragma mark - 头像逻辑
@property (atomic, strong) LSImageViewLoader *ladyImageViewLoader;
@property (atomic, strong) LSImageViewLoader *intimacyLadyImageViewLoader;
@property (atomic, strong) LSImageViewLoader *intimacyManImageViewLoader;
@property (atomic, strong) LSImageViewLoader *manPreviewImageViewLoader;

#pragma mark - 随机礼物控制
@property (strong) LSTimer *randomGiftTimer;
@property (atomic, strong) NSArray *giftArray;
@property (atomic, assign) NSInteger randomGiftIndex;
// 是否第一次随机礼物
@property (nonatomic, assign) BOOL firstRandom;

// 对话框控件
@property (strong) DialogTip *dialogTipView;
// 是否能推流
@property (assign) BOOL canPublish;

@property (strong) DialogChoose *dialogChoose;
@property (nonatomic, strong) DialogChoose *closeDialogTipView;

#pragma mark - 直播间管理器
// 是否第一次进类型直播间管理器
@property (nonatomic, strong) RoomTypeIsFirstManager *firstManager;
// 买点
@property (strong) DialogOK *dialogAddCredit;

@end

@implementation PrivateViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    NSLog(@"PrivateViewController::initCustomParam( self : %p )", self);

    srand((unsigned)time(0));

    self.isTipShow = NO;
    self.randomGiftIndex = -1;

    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    self.sessionManager = [LSSessionRequestManager manager];
    self.firstManager = [RoomTypeIsFirstManager manager];
    self.loginManager = [LSLoginManager manager];

    self.ladyImageViewLoader = [LSImageViewLoader loader];
    self.intimacyManImageViewLoader = [LSImageViewLoader loader];
    self.intimacyLadyImageViewLoader = [LSImageViewLoader loader];
    self.manPreviewImageViewLoader = [LSImageViewLoader loader];

    self.dialogTipView = [DialogTip dialogTip];

    self.firstRandom = YES;
    self.canPublish = NO;

    // 初始化计时器
    self.randomGiftTimer = [[LSTimer alloc] init];
}

- (void)dealloc {
    NSLog(@"PrivateViewController::dealloc( self : %p )", self);

    if (self.dialogAddCredit) {
        [self.dialogAddCredit removeFromSuperview];
    }

    if (self.dialogChoose) {
        [self.dialogChoose removeFromSuperview];
    }
    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
    }
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;

    // 初始化播放界面
    [self setupPlayController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 刷新头像控件
    [self reloadHeadImageView];
    
    // 设置状态栏隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // 开启随机礼物定时器
    [self startRandomGiftTimer];

    // 第一次进入才发送
    if (!self.viewDidAppearEver) {
        // 刷新双向视频状态
        [self reloadVideoStatus];
    }
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 停止随机礼物计时
    [self stopRandomGiftTimer];
    
    // 设置状态栏为默认字体
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化头部界面
    [self setupHeaderImageView];

    // 通知外部处理
    if ([self.delegate respondsToSelector:@selector(onSetupViewController:)]) {
        [self.delegate onSetupViewController:self];
    }
}

- (void)setupPlayController {
    // 输入栏
    self.playVC = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    self.playVC.playDelegate = self;
    [self addChildViewController:self.playVC];
    self.playVC.liveRoom = self.liveRoom;
    // 直播间风格
    self.playVC.liveVC.roomStyleItem = [[RoomStyleItem alloc] init];
    // 连击礼物
    self.playVC.liveVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Private_Bg_Combo"];
    // 座驾背景
    self.playVC.liveVC.roomStyleItem.riderBgColor = Color(255, 109, 0, 0.7);
    self.playVC.liveVC.roomStyleItem.driverStrColor = Color(255, 255, 255, 1);
    // 弹幕
    self.playVC.liveVC.roomStyleItem.barrageBgColor = Color(37, 37, 37, 0.9); //Color(83, 13, 120, 0.9);
    // 消息列表界面
    self.playVC.liveVC.roomStyleItem.myNameColor = Color(255, 109, 0, 1);
    self.playVC.liveVC.roomStyleItem.liverNameColor = Color(92, 222, 126, 1);
    self.playVC.liveVC.roomStyleItem.liverTypeImage = [UIImage imageNamed:@"Live_Private_Vip_Broadcaster"];
    self.playVC.liveVC.roomStyleItem.followStrColor = Color(249, 231, 132, 1);
    self.playVC.liveVC.roomStyleItem.sendStrColor = Color(255, 210, 5, 1);
    self.playVC.liveVC.roomStyleItem.chatStrColor = Color(255, 255, 255, 1);
    self.playVC.liveVC.roomStyleItem.announceStrColor = Color(255, 109, 0, 1);
    self.playVC.liveVC.roomStyleItem.riderStrColor = Color(255, 109, 0, 1);
    self.playVC.liveVC.roomStyleItem.warningStrColor = Color(255, 77, 77, 1);
    self.playVC.liveVC.roomStyleItem.textBackgroundViewColor = Color(191, 191, 191, 0.17);
    
    // 修改高级私密直播间样式
    if ([self.delegate respondsToSelector:@selector(setUpLiveRoomType:)]) {
        [self.delegate setUpLiveRoomType:self];
    }

    [self.view addSubview:self.playVC.view];
    [self.playVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [self.playVC.liveVC bringSubviewToFrontFromView:self.view];
    [self.view bringSubviewToFront:self.playVC.chooseGiftListView];
    CGRect frame = self.playVC.chooseGiftListView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    self.playVC.chooseGiftListView.frame = frame;

    // 隐藏立即私密邀请控件
    self.playVC.liveVC.startOneView.backgroundColor = [UIColor clearColor];
    
    // 视频播放界面
    //    self.playVC.liveVC.videoBgImageView.backgroundColor = self.view.backgroundColor;
    // 视频互动界面
    [self.playVC.liveVC showPreview];

    // 输入栏目
    self.playVC.chatAudienceViewWidth.constant = 0;
    self.playVC.chatAudienceViewLeading.constant = 0;
    
    // 发送栏目
    self.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0xc39eff);
    self.playVC.liveSendBarView.inputTextField.textColor = [UIColor whiteColor];
    // 显示表情按钮
    self.playVC.liveSendBarView.emotionBtnWidth.constant = 30;
    
    // 初始化推流
    [self.playVC.liveVC initPublish];
}

- (void)setupHeaderImageView {
    // 计算StatusBar高度
    if ([LSDevice iPhoneXStyle]) {
        self.titleBgImageTop.constant = 44;
    } else {
        self.titleBgImageTop.constant = 20;
    }
    
    // 女士背景
    self.ladyHeadView.layer.cornerRadius = self.ladyImageView.frame.size.height / 2;
    // 女士头像
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.frame.size.width / 2;
    // 亲密度背景
    self.intimacyHeadView.layer.cornerRadius = self.intimacyHeadView.frame.size.height / 2;
    // 亲密度男士头像
    self.intimacyManImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.intimacyManImageView.layer.borderWidth = 1;
    self.intimacyManImageView.layer.cornerRadius = self.intimacyManImageView.frame.size.width / 2;
    // 亲密度女士头像
    self.intimacyLadyImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.intimacyLadyImageView.layer.borderWidth = 1;
    self.intimacyLadyImageView.layer.cornerRadius = self.intimacyManImageView.frame.size.width / 2;
    // 关注
    self.followBtnWidth.constant = 0;
    
    
    // 直播间类型资费提示(暂时不用)
//    [self setupRoomTypeImageView];
    
    // 亲密度点击事件
    WeakObject(self, weakSelf);
    [self.intimacyImageView addTapBlock:^(id obj) {
        [weakSelf clickIntimacyImage];
    }];
    [self.intimacyLadyImageView addTapBlock:^(id obj) {
        [weakSelf clickIntimacyImage];
    }];
    
    // 女士头像点击
    [self.ladyImageView addTapBlock:^(id obj) {
        [weakSelf pushToAnchorPersonal:nil];
    }];

    // 关注
    self.followBtn.hidden = YES;
    
}

// 直播间类型资费提示(暂时不用)
- (void)setupRoomTypeImageView {
    
    self.tipView = [[ChardTipView alloc] init];
    self.tipView.gotBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0X5D0E86);
//    [self.tipView setTipWithRoomPrice:self.liveRoom.imLiveRoom.roomPrice
//                              roomTip:NSLocalizedStringFromSelf(@"PUBLIV_TIP")
//                           creditText:NSLocalizedStringFromSelf(@"CREDIT_TIP")];
    self.tipView.hidden = YES;
    [self.view addSubview:self.tipView];
    [self.roomTypeImageView sizeToFit];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomTypeImageView.mas_bottom).offset(2);
        make.width.equalTo(@(self.roomTypeImageView.frame.size.width * 1.5));
        make.left.equalTo(@0);
    }];
    
    // 直播间类型点击事件
    WeakObject(self, weakSelf);
    [self.roomTypeImageView addTapBlock:^(id obj) {
        if (!weakSelf.isTipShow) {
            weakSelf.hidenTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                   target:weakSelf
                                                                 selector:@selector(hidenChardTip)
                                                                 userInfo:nil
                                                                  repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:weakSelf.hidenTimer forMode:NSRunLoopCommonModes];
            [weakSelf.view bringSubviewToFront:weakSelf.tipView];
            weakSelf.tipView.hidden = NO;
            weakSelf.isTipShow = YES;
        }
    }];
}

- (void)setupVideoPreview:(BOOL)start {
    self.playVC.liveVC.previewImageView.hidden = start;
}

#pragma mark - 点击亲密度
- (void)clickIntimacyImage {
    LiveWebViewController *webViewController = [[LiveWebViewController alloc] init];
    webViewController.isIntimacy = YES;
    webViewController.anchorId = self.liveRoom.userId;
    webViewController.title = @"Intimacy Level";
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - 按钮事件
- (void)hidenChardTip {
    // TODO:点击资费提示
    self.tipView.hidden = YES;
    if (self.hidenTimer) {
        [self.hidenTimer invalidate];
        self.hidenTimer = nil;
    }
    self.isTipShow = NO;
}

- (IBAction)pushToAnchorPersonal:(id)sender {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] init];
    listViewController.anchorId = self.liveRoom.userId;
    listViewController.enterRoom = 0;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (IBAction)followAction:(id)sender {
    // TODO:点击关注
    [self sendFollowRequest];
}

- (IBAction)closeAction:(id)sender {
    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
    }
    WeakObject(self, weakObj);
    self.closeDialogTipView = [DialogChoose dialog];
    [self.closeDialogTipView hiddenCheckView];
    self.closeDialogTipView.tipsLabel.text = NSLocalizedStringFromSelf(@"EXIT_LIVEROOM_TIP");
    [self.closeDialogTipView showDialog:self.view cancelBlock:^{
        
    } actionBlock:^{
        [weakObj.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - 数据逻辑
- (void)reloadHeadImageView {
    self.laddyNameLabel.text = self.liveRoom.userName;
    
    // TODO:刷新女士头像
    [self.ladyImageViewLoader refreshCachedImage:self.ladyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    // TODO:刷新亲密度男士头像
    WeakObject(self, weakSelf);
    [[UserInfoManager manager] getFansBaseInfo:self.loginManager.loginItem.userId finishHandler:^(AudienModel * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.intimacyManImageViewLoader refreshCachedImage:weakSelf.intimacyManImageView options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
        });
    }];
    // TODO:刷新亲密度女士头像
    [self.intimacyLadyImageViewLoader refreshCachedImage:self.intimacyLadyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    // TODO:刷新亲密度
//    NSString *imageName = [NSString stringWithFormat:@"Live_Private_Img_Intimacy_Head_%d", self.liveRoom.imLiveRoom.loveLevel];
//    UIImage *image = [UIImage imageNamed:imageName];
//    if (image) {
//        self.intimacyImageView.image = image;
//    }
    // 设置模糊
    UIImage *manBlurImage = [UIImage imageNamed:@"Two_Video_icon"];
    [self.playVC.liveVC.previewImageView setImage:manBlurImage];
}

- (void)reloadVideoStatus {
    NSLog(@"PrivateViewController::reloadVideoStatus( publishUrl : %@ )", self.liveRoom.publishUrl);

    if (self.liveRoom.publishUrl.length > 0) {
        // 已经有推流地址, 发送命令
        [self sendVideoControl:YES];

    } else {
        // 停止推流
        [self.playVC.liveVC stopPublish];

        // 刷新界面
        [self setupVideoPreview:NO];
    }
}

- (void)sendVideoControl:(BOOL)start {
    // 显示菊花
    self.playVC.liveVC.preActivityView.hidden = NO;
    [self.playVC.liveVC.preActivityView startAnimating];

    IMControlType type = start ? IMCONTROLTYPE_START : IMCONTROLTYPE_CLOSE;
    BOOL bFlag = [self.imManager controlManPush:self.liveRoom.roomId
                                        control:type
                                  finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSArray<NSString *> *_Nonnull manPushUrl) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          // 隐藏菊花
                                          self.playVC.liveVC.preActivityView.hidden = YES;

                                          if (success) {
                                              BOOL bChange = YES;
                                              BOOL bSuccess = NO;

                                              if (start) {
                                                  // 开启视频互动成功
                                                  if (manPushUrl.count > 0) {
                                                      bChange = YES;
                                                      bSuccess = YES;

                                                      // 开始推流
                                                      self.liveRoom.publishUrlArray = manPushUrl;

                                                  } else {
                                                      bChange = NO;

                                                      // 发送关闭命令
                                                      [self.imManager controlManPush:self.liveRoom.roomId control:IMCONTROLTYPE_CLOSE finishHandler:nil];

                                                      // 错误提示
                                                      NSLog(@"PrivateViewController::sendVideoControl( 发起视频互动失败(没有推流地址), errType : %d )", errType);
                                                      [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:NSLocalizedStringFromSelf(@"LOCAL_ERROR_NO_PUSH_URL")];
                                                  }
                                              } else {
                                                  // 关闭视频互动成功
//                                                  // 停止推流
//                                                  [self.playVC.liveVC stopPublish];
                                              }

                                              // 改变界面状态
                                              if (bSuccess) {
                                                  // 开始推流
                                                  [self.playVC.liveVC publish];
                                              } else {
                                                  // 停止推流
                                                  [self.playVC.liveVC stopPublish];
                                              }

                                              [self setupVideoPreview:bSuccess];
//                                              if (bChange) {
//                                                  self.playVC.liveVC.previewImageView.hidden = start;
//
//                                                  self.playVC.liveVC.startVideoImageView.hidden = start;
//                                                  self.playVC.liveVC.startVideoBtn.hidden = start;
//                                                  self.playVC.liveVC.showBtn.enabled = start;
//
//                                                  [self.playVC.liveVC.preActivityView stopAnimating];
//                                              }

                                          } else {
                                              NSString *errStr = start ? @"开启视频互动失败" : @"关闭视频互动失败";
                                              NSLog(@"PrivateViewController::sendVideoControl( %@, errType : %d )", errStr, errType);
                                              if (start) {
                                                  if (errType == LCC_ERR_NO_CREDIT) {
                                                      // 没钱, 弹出充值
                                                      if (self.dialogAddCredit) {
                                                          [self.dialogAddCredit removeFromSuperview];
                                                      }

                                                      WeakObject(self, weakSelf);
                                                      self.dialogAddCredit = [DialogOK dialog];
                                                      self.dialogAddCredit.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_ERR_ADD_CREDIT");
                                                      [self.dialogAddCredit showDialog:self.view
                                                                           actionBlock:^{
                                                                               [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                                                               [weakSelf.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
                                                                           }];

                                                  } else {
                                                      // 错误提示
                                                      [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:errMsg];
                                                  }
                                              } else {
                                                  // 错误提示
                                                  [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:errMsg];
                                              }
                                          }
                                      });
                                  }];
    if (!bFlag) {
        self.playVC.liveVC.preActivityView.hidden = YES;
        [self.playVC.liveVC.preActivityView stopAnimating];
    }
}

- (void)sendFollowRequest {
    [[LiveModule module].analyticsManager reportActionEvent:BroadcastClickFollow eventCategory:EventCategoryBroadcast];
    SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
    request.userId = self.liveRoom.userId;
    request.roomId = self.liveRoom.roomId;
    request.isFav = YES;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.followBtn.hidden = YES;
                self.followBtnWidth.constant = 0;
                //                [self.playVC.liveVC addAudienceFollowLiverMessage:self.playVC.loginManager.loginItem.nickName];
            } else {
                // 错误提示
                [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:NSLocalizedStringFromSelf(@"FOLLOW_FAIL")];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - IM回调
- (void)onRecvLoveLevelUpNotice:(int)loveLevel {
    NSLog(@"PrivateViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d )", loveLevel);
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO:刷新亲密度
        NSString *imageName = [NSString stringWithFormat:@"Live_Private_Img_Intimacy_Head_%d", loveLevel];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            self.intimacyImageView.image = image;
        }
    });
}

#pragma mark - PlayViewControllerDelegate
- (void)onCloseLiveRoom:(PlayViewController *)vc {
    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
    }
    WeakObject(self, weakObj);
    self.closeDialogTipView = [DialogChoose dialog];
    [self.closeDialogTipView hiddenCheckView];
    self.closeDialogTipView.tipsLabel.text = NSLocalizedStringFromSelf(@"EXIT_LIVEROOM_TIP");
    [self.closeDialogTipView showDialog:self.view cancelBlock:^{
        
    } actionBlock:^{
        if (weakObj.liveRoom.roomId.length > 0) {
            // 发送退出直播间
            NSLog(@"PublicViewController::liveHeadCloseAction [发送退出直播间:%@]",self.liveRoom.roomId);
            [weakObj.imManager leaveRoom:self.liveRoom.roomId];
            // QN判断已退出直播间
            [LiveModule module].roomID = nil;
        }
    }];
}

#pragma mark - 播放界面回调
- (void)onReEnterRoom:(PlayViewController *)vc {
    NSLog(@"PrivateViewController::onReEnterRoom()");
    // 清空旧的推流地址
    [self.liveRoom reset];

    // 刷新双向视频状态
    [self reloadVideoStatus];
}

#pragma mark - 播放界面回调
- (void)onGetLiveRoomGiftList:(NSArray<LiveRoomGiftModel *> *)array {
    NSLog(@"PrivateViewController::onGetLiveRoomGiftList( count : %lu )", (unsigned long)array.count);
    // 更新礼物数组
    self.giftArray = array;

    if (self.firstRandom) {
        int randValue = rand();
        self.randomGiftIndex = randValue % self.giftArray.count;
        RandomGiftModel *gift = [self.giftArray objectAtIndex:self.randomGiftIndex];
        LiveRoomGiftModel *giftModel = gift.giftModel;

        WeakObject(self, weakSelf);
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:giftModel.allItem.infoItem.smallImgUrl]
            options:0
            progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

            }
            completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    });
                }
            }];
        self.firstRandom = NO;
    }
}

#pragma mark - 倒数控制
- (void)randomGiftCountDown {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 修改随机礼物
        UIImage *defaultImage = [UIImage imageNamed:@"Live_Publish_Btn_Gift"];

        if (self.giftArray.count > 0) {
            int randValue = rand();
            self.randomGiftIndex = randValue % self.giftArray.count;
            self.playVC.presentRow = self.randomGiftIndex;
            RandomGiftModel *gift = [self.giftArray objectAtIndex:self.randomGiftIndex];
            LiveRoomGiftModel *giftModel = gift.giftModel;
            NSString *url = [[LiveGiftDownloadManager manager] backMiddleImgUrlWithGiftID:giftModel.giftId];

            WeakObject(self, weakSelf);
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager loadImageWithURL:[NSURL URLWithString:url]
                options:0
                progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

                }
                completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        });
                    }
                }];
        } else {
            // 没有随机礼物
            self.randomGiftIndex = -1;
        }
    });
}

- (void)startRandomGiftTimer {
    NSLog(@"PrivateViewController::startRandomGiftTimer()");
    
    WeakObject(self, weakSelf);
    [self.randomGiftTimer startTimer:nil timeInterval:300.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf randomGiftCountDown];
    }];
}

- (void)stopRandomGiftTimer {
    NSLog(@"PrivateViewController::stopRandomGiftTimer()");
    
    [self.randomGiftTimer stopTimer];
}

@end