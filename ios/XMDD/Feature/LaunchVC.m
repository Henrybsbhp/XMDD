//
//  LaunchVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "LaunchVC.h"
#import "GradientView.h"
#import "HKTabBarVC.h"

@interface LaunchVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *skipBtn;
@property (nonatomic, strong) UIWindow *nextWindow;
@property (nonatomic, assign) BOOL isDismissing;

@property (nonatomic, strong) RACDisposable *signalDisposable;
@end
@implementation LaunchVC

- (void)dealloc
{
    DebugLog(@"LaunchVC dealloc");
}

- (void)viewDidLoad
{
    
    @weakify(self)
    
    [super viewDidLoad];
    [self setupSkipBtn];
    gAppDelegate.window.windowLevel = UIWindowLevelStatusBar;
    self.imageView.image = self.image;
    if (self.info.fullscreen) {
        self.bottomView.hidden = YES;
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            @strongify(self)
            
            make.bottom.equalTo(self.view);
        }];
    }
    
    if (self.info.url.length)
    {
        [self setupClickAction];
        ///如果是有广告，并且没有点击，时间停留多一秒
        [self countDownCircleAfterDelay:self.info.staytime > 0 ? self.info.staytime : 3];
    }
    else
    {
        [self countDownCircleAfterDelay:self.info.staytime > 0 ? self.info.staytime : 2];
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (![image isEqual:self.imageView.image]) {
        CKAsyncMainQueue(^{
            self.imageView.image = image;
        });
    }
}

- (void)setupSkipBtn
{
    self.skipBtn.layer.cornerRadius = 20;
    self.skipBtn.layer.masksToBounds = YES;
}

- (void)setupClickAction
{
    @weakify(self)
    
    UITapGestureRecognizer * gesture = self.imageView.customObject;
    if (!gesture)
    {
        UITapGestureRecognizer *ge = [[UITapGestureRecognizer alloc] init];
        [self.imageView addGestureRecognizer:ge];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.customObject = ge;
    }
    gesture = self.imageView.customObject;
    
    [[gesture rac_gestureSignal] subscribeNext:^(id x) {
        
        @strongify(self)
        [self.signalDisposable dispose];
        [self swithToRootViewAfterDelay:0.1 url:self.info.url];
    }];
}

- (void)swithToRootViewAfterDelay:(NSTimeInterval)delay url:(NSString *) url
{
    if (self.isDismissing) {
        return;
    }
    self.isDismissing = YES;
    @weakify(self)
    CKAfter(delay, ^{
        
        if (gAppMgr.navModel.curNavCtrl && url.length)
        {
            //  使用队列模式
            NSDictionary * dict = @{@"url":url};
            [gAppDelegate.openUrlQueue addObject:dict forKey:nil];
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            gAppDelegate.window.alpha = 0;
        } completion:^(BOOL finished) {
            
            @strongify(self)
            
            gAppDelegate.window = self.nextWindow;
        }];
    });
}

- (void)countDownCircleAfterDelay:(NSTimeInterval)delay
{
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(20, 20) radius:20 startAngle:M_PI_2*3 endAngle:M_PI*2 + M_PI_2*3 clockwise:YES];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc]init];
    shapeLayer.customTag = 100;
    shapeLayer.frame = self.skipBtn.bounds;
    shapeLayer.lineWidth = 3;
    shapeLayer.fillColor =  [[UIColor clearColor] CGColor];
    shapeLayer.strokeColor = [HEXCOLOR(@"#18D06A") CGColor];
    shapeLayer.path = [bezierPath CGPath];
    [self.skipBtn.layer addSublayer:shapeLayer];
    shapeLayer.strokeEnd = 1;
    
    CGFloat diffPi = (0.1/delay);
    
    self.signalDisposable = [[[RACSignal interval:0.1 onScheduler:[RACScheduler mainThreadScheduler]]take:delay*10]subscribeNext:^(id x) {
        
        shapeLayer.strokeStart += diffPi;
    }completed:^{
        [self swithToRootViewAfterDelay:0.1 url:nil];
    }];
}

- (IBAction)actionSkip:(id)sender
{
    [MobClick event:@"shouye" attributes:@{@"shouye":@"shouye_tiaoguo"}];
    [self.signalDisposable dispose];
    [self swithToRootViewAfterDelay:0.1 url:nil];
}

-(UIWindow *)nextWindow
{
    if (!_nextWindow)
    {
        _nextWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _nextWindow.backgroundColor = [UIColor whiteColor];
        HKTabBarVC *vc = [[HKTabBarVC alloc] init];
        gAppMgr.tabBarVC = vc;
        _nextWindow.rootViewController = vc;
        [_nextWindow makeKeyAndVisible];
    }
    return _nextWindow;
}

@end
