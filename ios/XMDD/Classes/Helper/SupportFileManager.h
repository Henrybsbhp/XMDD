//
//  SupportFileManager.h
//  XiaoMa
//
//  Created by jt on 16/1/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SupportFileManager : NSObject

+ (SupportFileManager *)sharedManager;

- (RACSignal *)rac_handleSupportFile:(NSString *)strUrl;


- (RACSignal *)rac_downloadSupportFileForUrl:(NSString *)strUrl;

@end
