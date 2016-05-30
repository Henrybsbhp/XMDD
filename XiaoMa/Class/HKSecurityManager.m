//
//  HKSecurityManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKSecurityManager.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>

@interface HKSecurityManager () {
    SecKeyRef _rsa_public_key;
}
@end
@implementation HKSecurityManager

+ (instancetype)sharedManager
{
    static HKSecurityManager *g_securityManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_securityManager = [[self alloc] init];
        [g_securityManager loadDefaultPublicKey];
    });
    return g_securityManager;
}

- (void)loadDefaultPublicKey
{
    [self loadPublicKeyWithFile:CKPathForMainBundle(@"xmddrct_public_key.der")];
}

- (void)loadPublicKeyWithFile:(NSString *)filePath
{
    return [self loadPublicKeyWithData:[NSData dataWithContentsOfFile:filePath]];
}

- (void)loadPublicKeyWithData:(NSData *)data
{
    SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(cert, myPolicy, &myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    _rsa_public_key = SecTrustCopyPublicKey(myTrust);
    CFRelease(cert);
    CFRelease(myPolicy);
    CFRelease(myTrust);
}


- (BOOL)verifyWithRSASignature:(NSString *)sign forMessage:(NSString *)message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], (unsigned int)[data length], digest);

    NSData *signdata = [NSData dataWithBase64String:sign];
    OSStatus status = SecKeyRawVerify(_rsa_public_key,
                                      kSecPaddingPKCS1SHA1,
                                      digest,
                                      CC_SHA1_DIGEST_LENGTH,
                                      [signdata bytes],
                                      [signdata length]);
    return status == noErr;
}

@end
