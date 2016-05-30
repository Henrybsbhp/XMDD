//
//  NavigationModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigationModel : NSObject
@property (nonatomic, strong) UINavigationController *curNavCtrl;

- (BOOL)pushToViewControllerByUrl:(NSString *)url;

+ (NSString *)appendStaticParam:(NSString *)url;
+ (NSString *)appendParams:(NSDictionary *)params forUrl:(NSString *)url;
@end
