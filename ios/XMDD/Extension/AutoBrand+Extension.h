//
//  AutoBrand+Extension.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AutoBrand.h"

@interface AutoBrand (Extension)

- (void)resetWithJSONResponse:(NSDictionary *)rsp;
+ (AutoBrand *)fetchAutoBrandByID:(NSNumber *)bid;

@end
