//
//  SupportFileManager.m
//  XiaoMa
//
//  Created by jt on 16/1/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "SupportFileManager.h"
#import "RACAFNetworking.h"

@interface SupportFileManager ()

@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *fileManager;

@end

@implementation SupportFileManager

+ (SupportFileManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static SupportFileManager *g_supportFileManager;
    dispatch_once(&onceToken, ^{
        g_supportFileManager = [[SupportFileManager alloc] init];
    });
    return g_supportFileManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _fileManager = [[AFHTTPRequestOperationManager alloc] init];
    }
    return self;
}

- (RACSignal *)rac_handleSupportFile:(NSString *)strUrl
{
    NSArray * separateArray = [strUrl componentsSeparatedByString:@"/"];
    NSString * fileName = [separateArray safetyObjectAtIndex:separateArray.count - 1];
    NSArray * separateNames = [fileName componentsSeparatedByString:@"_"];
    if (separateNames.count != 3)
    {
        return nil;
    }
    // 名字后缀
    NSString * suffix = [separateArray safetyObjectAtIndex:separateArray.count - 1];
    // 名字前缀
    NSString * prefix = [fileName stringByReplacingOccurrencesOfString:suffix withString:@""];

    RACSubject * subject = [RACSubject subject];
    [[self rac_downloadSupportFileForUrl:strUrl] subscribeNext:^(RACTuple *tuple) {
        
        if (![tuple.second isKindOfClass:[NSData class]])
        {
            return ;
        }
        NSData * data = (NSData *)tuple.second;
        CKAsyncHighQueue(^{
            
            [self deleteFileByNamePrefix:prefix];
            NSString * filePath = [self writeFileByName:fileName andData:data];
            
            if (filePath.length)
            {
                [subject sendNext:RACTuplePack(filePath)];
                [subject sendCompleted];
            }
            else
            {
                NSError * error = [NSError errorWithDomain:@"writeFileByName error" code:500 userInfo:nil];
                [subject sendError:error];
            }
        });
    } error:^(NSError *error) {
        
        [subject sendError:error];
    }];
    
    return subject;
}


- (RACSignal *)rac_downloadSupportFileForUrl:(NSString *)strUrl
{
    // 文件名称必须为jspatch_HomeViewController_201601011212.js
    // 类型_对应文件名称_时间戳.文件类型
    NSURLRequest *fileReq = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc]  initWithRequest:fileReq];
    
    RACSignal *signal = [[self.fileManager rac_enqueueHTTPRequestOperation:op]
                         deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]];
    signal = [signal catch:^RACSignal *(NSError *error) {
        
        return [RACSignal return:error];
    }];
    return signal;
}

/// 删除匹配前缀的文件
- (BOOL)deleteFileByNamePrefix:(NSString *)prefix
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docPath = [paths safetyObjectAtIndex:0];
    if (!docPath.length)
    {
        return NO;
    }
    NSArray * files = [fileManager contentsOfDirectoryAtPath:docPath error:nil];
    for (NSString * fileName in files)
    {
        if ([fileName hasPrefix:prefix])
        {
            NSString * filePath = [docPath stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
    
    return YES;
}

- (NSString *)writeFileByName:(NSString *)name andData:(NSData *)data
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docPath = [paths safetyObjectAtIndex:0];
    if (!docPath.length)
    {
        return nil;
    }
    NSString *filePath = [docPath stringByAppendingPathComponent:name];
    BOOL flag = [data writeToFile:filePath atomically:YES];
    return flag ? filePath :  nil;
}

@end
