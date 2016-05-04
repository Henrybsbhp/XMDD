//
//  CKPaths.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-4.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "CKPaths.h"

NSString *CKPathForMainBundle(NSString *fileName)
{
    return CKPathForBundle(nil, fileName);
}

NSString *CKPathForBundle(NSString *bundleName, NSString *fileName)
{
    NSBundle *bundle;
    if (bundleName.length == 0)
    {
        bundle = [NSBundle mainBundle];
    }
    else
    {
        bundle = [NSBundle bundleWithIdentifier:bundleName];
    }
    return [[bundle resourcePath] stringByAppendingPathComponent:fileName];
}

NSString *CKPathForDocument(NSString *fileName)
{
    static NSString *documentBasePath = nil;
    if (!documentBasePath)
    {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES);
        documentBasePath = [dirs objectAtIndex:0];
    }
    NSString *path = fileName ? [documentBasePath stringByAppendingPathComponent:fileName] : documentBasePath;
    
    return path;
}

NSString *CKPathForCache(NSString *fileName)
{
    static NSString *cacheBasePath = nil;
    if (!cacheBasePath)
    {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                            NSUserDomainMask,
                                                            YES);
        cacheBasePath = [dirs objectAtIndex:0];
    }
    return [cacheBasePath stringByAppendingPathComponent:fileName];
}

NSURL *CKURLForMainBundle(NSString *fileName)
{
    return [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:fileName];
}

NSURL *CKURLForDocument(NSString *fileName)
{
    NSString *path = CKPathForDocument(fileName);
    if (path)
    {
        return [[NSURL alloc] initFileURLWithPath:path];
    }
    return nil;
}

NSURL *CKURLForCache(NSString *fileName)
{
    NSString *path = CKPathForCache(fileName);
    if (path)
    {
        return [[NSURL alloc] initFileURLWithPath:path];
    }
    return nil;
}

