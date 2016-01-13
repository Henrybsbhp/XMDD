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
    homePicModel.yjxcPic = [rsp stringParamForName:@"yjxcpic"];
    homePicModel.mzlqpic = [rsp stringParamForName:@"mzlqpic"];
    homePicModel.bxfwpic = [rsp stringParamForName:@"bxfwpic"];
    homePicModel.zyjypic = [rsp stringParamForName:@"zyjypic"];
    homePicModel.njxbpic = [rsp stringParamForName:@"njxbpic"];
    
    return homePicModel;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.homeItemArray forKey:@"toppics"];
    [coder encodeObject:self.yjxcPic forKey:@"yjxcpic"];
    [coder encodeObject:self.mzlqpic forKey:@"mzlqpic"];
    [coder encodeObject:self.bxfwpic forKey:@"bxfwpic"];
    [coder encodeObject:self.zyjypic forKey:@"zyjypic"];
    [coder encodeObject:self.njxbpic forKey:@"njxbpic"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.homeItemArray = [coder decodeObjectForKey:@"toppics"];
        self.yjxcPic = [coder decodeObjectForKey:@"yjxcpic"];
        self.mzlqpic = [coder decodeObjectForKey:@"mzlqpic"];
        self.bxfwpic = [coder decodeObjectForKey:@"bxfwpic"];
        self.zyjypic = [coder decodeObjectForKey:@"zyjypic"];
        self.njxbpic = [coder decodeObjectForKey:@"njxbpic"];
    }
    return self;
}



@end
