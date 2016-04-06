//
//  HomePicModel.m
//  XiaoMa
//
//  Created by jt on 16/1/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HomePicModel.h"

@implementation HomeItem

- (instancetype)initWithTitlt:(NSString *)title picUrl:(NSString *)picurl andUrl:(NSString *)url imageName:(NSString *)imageName
{
    self = [super init];
    if (self) {
        self.homeItemTitle = title;
        self.homeItemPicUrl = picurl;
        self.homeItemRedirect = url;
        self.defaultImageName = imageName;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.homeItemTitle forKey:@"title"];
    [coder encodeObject:self.homeItemPicUrl forKey:@"pic"];
    [coder encodeObject:self.homeItemRedirect forKey:@"url"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.homeItemTitle = [coder decodeObjectForKey:@"title"];
        self.homeItemPicUrl = [coder decodeObjectForKey:@"pic"];
        self.homeItemRedirect = [coder decodeObjectForKey:@"url"];
    }
    return self;
}

@end

@implementation HomePicModel

+ (instancetype)homeWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HomePicModel * homePicModel = [[HomePicModel alloc] init];
    NSArray * tArray = [rsp objectForKey:@"toppics"];
    NSMutableArray * mutableArray = [NSMutableArray array];
    for (NSDictionary * dict in tArray)
    {
        HomeItem * item = [[HomeItem alloc] init];
        item.homeItemTitle = [dict stringParamForName:@"title"];
        item.homeItemPicUrl = [dict stringParamForName:@"pic"];
        item.homeItemRedirect = [dict stringParamForName:@"url"];
        [mutableArray safetyAddObject:item];
    }
    homePicModel.homeItemArray = [NSArray arrayWithArray:mutableArray];
    
    NSDictionary * bottomDict = [rsp objectForKey:@"bottomItem"];
    HomeItem * item = [[HomeItem alloc] init];
    item.homeItemTitle = [bottomDict stringParamForName:@"title"];
    item.homeItemPicUrl = [bottomDict stringParamForName:@"pic"];
    item.homeItemRedirect = [bottomDict stringParamForName:@"url"];
    homePicModel.bottomItem = item;
    
    return homePicModel;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.homeItemArray forKey:@"toppics"];
    [coder encodeObject:self.bottomItem forKey:@"bottomItem"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.homeItemArray = [coder decodeObjectForKey:@"toppics"];
        self.bottomItem = [coder decodeObjectForKey:@"bottomItem"];
    }
    return self;
}



@end
