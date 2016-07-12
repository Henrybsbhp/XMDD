//
//  ScanQRCodeVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/4/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "ScanQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanQRCodeVC () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) UIView *scanRectView;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@end

@implementation ScanQRCodeVC

- (void)dealloc
{
    DebugLog(@"ScanQRCodeVC deallocated!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self firstSetup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_session) {
        [self.session startRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)firstSetup
{
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    
    CGSize scanSize = CGSizeMake(windowSize.width * 3 / 4, windowSize.width * 3 / 4);
    CGRect scanRect = CGRectMake((windowSize.width - scanSize.width) / 2, (windowSize.height - scanSize.height) / 2, scanSize.width, scanSize.height);
    
    scanRect = CGRectMake(scanRect.origin.y / windowSize.height, scanRect.origin.x / windowSize.width, scanRect.size.height / windowSize.height, scanRect.size.width / windowSize.width);
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            
            if (IOSVersionGreaterThanOrEqualTo(@"8.0")){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"您没有开启摄像头权限,请前往设置打开" ActionItems:@[cancel]];
        [alert show];
        
        return;
        
    } else {
        self.output = [[AVCaptureMetadataOutput alloc] init];
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        self.session = [[AVCaptureSession alloc] init];
        [self.session setSessionPreset:([UIScreen mainScreen].bounds.size.height < 500) ? AVCaptureSessionPreset640x480 : AVCaptureSessionPresetHigh];
        [self.session addInput:self.input];
        [self.session addOutput:self.output];
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        self.output.rectOfInterest = scanRect;
        
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.preview.frame = [UIScreen mainScreen].bounds;
        [self.view.layer insertSublayer:self.preview atIndex:0];
        
        self.scanRectView = [UIView new];
        [self.view addSubview:self.scanRectView];
        self.scanRectView.frame = CGRectMake(0, 0, scanSize.width, scanSize.height);
        self.scanRectView.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
        self.scanRectView.layer.borderColor = [UIColor redColor].CGColor;
        self.scanRectView.layer.borderWidth = 1;
        
        // 开始捕获
        [self.session startRunning];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count == 0) {
        return;
    }
    
    if (metadataObjects.count > 0) {
        [self.session stopRunning];
        
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        // 输出扫描字符串
        
        [gAppMgr.navModel pushToViewControllerByUrl:metadataObject.stringValue];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
