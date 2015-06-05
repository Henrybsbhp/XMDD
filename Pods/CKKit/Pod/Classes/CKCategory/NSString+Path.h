//
//  NSString+Path.h
//  JTReader
//
//  Created by jiangjunchen on 13-9-26.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Path)

- (BOOL)makeSurePathExists;
- (BOOL)pathExists;
@end
