//
//  NSData+JSON.m
//  JTReader
//
//  Created by jiangjunchen on 14-1-13.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

@implementation NSData (JSON)

- (id)jsonObject
{
    return [self jsonObjectWithError:nil];
}

- (id)jsonObjectWithError:(NSError **)error
{
    id jsonObj = [NSJSONSerialization JSONObjectWithData:self options:0 error:error];
    if (error)
    {
        NSLog(@"JSON Parsing Error: %@", *error);
    }
    return jsonObj;
}
@end
