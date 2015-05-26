//
//  JTLogModel.m
//  XiaoNiuShared
//
//  Created by jt on 14-8-21.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "JTLogModel.h"
#import "UploadLogOp.h"

@interface JTLogModel()

@property (nonatomic,strong)LogAlertView * logAlertView;
@property (nonatomic,strong)NSArray * logArray;
@property (nonatomic)NSInteger prepareUploadLogIndex;

@end

@implementation JTLogModel

- (void)addToScreen
{
    self.prepareUploadLogIndex = -1;
    UIImage * screen = [JTCaptureScreen captureScreen];
    NSData * data = UIImageJPEGRepresentation(screen, 0.1f);
    [JTCaptureScreen saveScreenshotToPhotosAlbum:screen];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths safetyObjectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/Logs",cachesDir];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    self.logArray = [[array reverseObjectEnumerator] allObjects];
    self.logAlertView = [[LogAlertView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    self.logAlertView.backgroundColor = [UIColor clearColor];
    self.logAlertView.logArray = self.logArray;

    
    [[self.logAlertView.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.logAlertView removeFromSuperview];
        self.islogViewAppear = NO;
    }];
    
    [[self.logAlertView.okBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (self.prepareUploadLogIndex < 0)
        {
            [SVProgressHUD showErrorWithStatus:@"请选择需要上传的日志"];
            return;
        }
        [self submitLog:data];
    }];
    
    __weak JTLogModel * modelSelf = self;
    [self.logAlertView setSelectBlock:^(NSInteger index) {
        modelSelf.prepareUploadLogIndex = index;
    }];
    
    self.islogViewAppear = YES;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.logAlertView];
}

- (void)submitLog:(NSData *)imageData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths safetyObjectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/Logs",cachesDir];
    
    NSString * filename = [self.logArray safetyObjectAtIndex:self.prepareUploadLogIndex];
    NSString * filepath = [NSString stringWithFormat:@"%@/%@",path,filename];
    NSData * data = [NSData dataWithContentsOfFile:filepath];
    if (!data)
    {
        return;
    }

    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSArray * array = @[data];
    UploadLogOp *op = [UploadLogOp new];
    op.req_fileType = @"txt";
    op.req_fileName = [NSString stringWithFormat:@"xmdd.%@-%@-%@.txt",@"iOS",version, self.userid];
    [op setFileArray:array withGetDataBlock:^NSData *(NSData * d) {
        return d;
    }];
    
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在上传..."];
    }] subscribeNext:^(id x) {
        [gToast showSuccess:@"上传成功"];
        
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];

    
//    UploadLogOp * op = [[UploadLogOp alloc] init];
//    op.appname = self.appname;
//    op.version = [[[NSBundle mainBundle] infoDictionary]
//                  objectForKey:(NSString *)kCFBundleVersionKey];
//    op.phone = self.userid;
//    op.filename = filename;
//    op.fileData = data;
//    
//    UploadLogOp * op2 = [[UploadLogOp alloc] init];
//    op2.appname = self.appname;
//    op2.version = [[[NSBundle mainBundle] infoDictionary]
//                   objectForKey:(NSString *)kCFBundleVersionKey];
//    op2.phone = self.userid;
//    op2.filename = [NSString stringWithFormat:@"%@.png",filename];
//    op2.fileData = imageData;
//    
//    RACSignal * uploadLogSignal = [op postRequest];
//    
//    [[uploadLogSignal initially:^{
//        [SVProgressHUD showWithStatus:@"上传log..."];
//    }] subscribeNext:^(id x) {
//        
//        [SVProgressHUD showWithStatus:@"上传img..."];
//        [[[op2 postRequest] initially:^{
//            
//        }] subscribeNext:^(id x) {
//            
//            [SVProgressHUD showSuccessWithStatus:@"成功"];
//            self.prepareUploadLogIndex = -1;
//            self.islogViewAppear = NO;
//            [self.logAlertView removeFromSuperview];
//        } error:^(NSError *error) {
//            
//            [SVProgressHUD showErrorWithStatus:@"失败，请重试"];
//            self.prepareUploadLogIndex = -1;
//            self.islogViewAppear = NO;
//            [self.logAlertView removeFromSuperview];
//        }] ;
//    } error:^(NSError *error) {
//        
//        [SVProgressHUD showErrorWithStatus:@"失败，请重试"];
//        self.prepareUploadLogIndex = -1;
//        self.islogViewAppear = NO;
//        [self.logAlertView removeFromSuperview];
//    }];
}

@end
