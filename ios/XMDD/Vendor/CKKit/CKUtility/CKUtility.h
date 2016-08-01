//
//  CKUtility.h
//  JTReader
//
//  Created by jiangjunchen on 13-10-21.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "CKMethods.h"
#import "CKPaths.h"
#import "CKSegmentHelper.h"
#import "UIColor+ColorWithHexString.h"
#import <Foundation/Foundation.h>

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define HEXCOLOR(strhex) [UIColor colorWithHex:(strhex) alpha:1]

#define IOSVersionGreaterThanOrEqualTo(v)  \
    ([[UIDevice currentDevice].systemVersion compare:v options:NSNumericSearch] != NSOrderedAscending)
