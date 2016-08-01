//
//  HKSecurityManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKSecurityManager : NSObject

+ (instancetype)sharedManager;

//load public key
- (void)loadPublicKeyWithFile:(NSString *)filePath;
- (void)loadPublicKeyWithData:(NSData *)data;

- (BOOL)verifyWithRSASignature:(NSString *)sign forMessage:(NSString *)message;

@end
