//
//  CKPaths.h
//  JTReader
//
//  Created by jiangjunchen on 13-12-4.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C"
{
#endif

    NSString *CKPathForBundle(NSString *bundleName, NSString *fileName);
    NSString *CKPathForMainBundle(NSString *fileName);
    NSString *CKPathForDocument(NSString *fileName);
    NSString *CKPathForCache(NSString *fileName);
    
    NSURL *CKURLForMainBundle(NSString *fileName);
    NSURL *CKURLForDocument(NSString *fileName);
    NSURL *CKURLForCache(NSString *fileName);

#if defined __cplusplus
};
#endif
