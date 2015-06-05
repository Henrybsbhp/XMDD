//
//  NSData+JSON.h
//  JTReader
//
//  Created by jiangjunchen on 14-1-13.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JSON)

- (id)jsonObject;
- (id)jsonObjectWithError:(NSError **)error;

@end
