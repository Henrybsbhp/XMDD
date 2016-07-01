//
//  HomePicModel.m
//  XiaoMa
//
//  Created by jt on 16/1/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HomePicModel.h"

@implementation HomeItem

- (instancetype)initWithId:(NSString *)itemId titlt:(NSString *)title picUrl:(NSString *)picurl andUrl:(NSString *)url imageName:(NSString *)imageName isnew:(BOOL)flag
{
    self = [super init];
    if (self) {
        self.homeItemId = itemId;
        self.homeItemTitle = title;
        self.homeItemPicUrl = picurl;
        self.homeItemRedirect = url;
        self.defaultImageName = imageName;
        self.isNewFlag = flag;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.homeItemTitle forKey:@"title"];
    [coder encodeObject:self.homeItemPicUrl forKey:@"pic"];
    [coder encodeObject:self.homeItemRedirect forKey:@"url"];
    [coder encodeObject:self.homeItemId forKey:@"itemid"];
    [coder encodeBool:self.isNewFlag forKey:@"newflag"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.homeItemTitle = [coder decodeObjectForKey:@"title"];
        self.homeItemPicUrl = [coder decodeObjectForKey:@"pic"];
        self.homeItemRedirect = [coder decodeObjectForKey:@"url"];
        self.homeItemId = [coder decodeObjectForKey:@"itemid"];
        self.isNewFlag = [coder decodeBoolForKey:@"newflag"];
        
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
    NSArray * tArray = [rsp objectForKey:@"modules"];
    NSMutableArray * mutableArray = [NSMutableArray array];
    for (NSDictionary * dict in tArray)
    {
        HomeItem * item = [[HomeItem alloc] init];
        item.homeItemTitle = [dict stringParamForName:@"title"];
        item.homeItemPicUrl = [dict stringParamForName:@"pic"];
        item.homeItemRedirect = [dict stringParamForName:@"url"];
        item.homeItemId = [dict stringParamForName:@"moduleid"];
        item.isNewFlag = [dict boolParamForName:@"isnewflag"];
        [mutableArray safetyAddObject:item];
    }
    homePicModel.homeItemArray = [NSArray arrayWithArray:mutableArray];
    
    NSArray * tArray2 = [rsp objectForKey:@"moremodules"];
    NSMutableArray * mutableArray2 = [NSMutableArray array];
    for (NSDictionary * dict in tArray2)
    {
        HomeItem * item = [[HomeItem alloc] init];
        item.homeItemTitle = [dict stringParamForName:@"title"];
        item.homeItemPicUrl = [dict stringParamForName:@"pic"];
        item.homeItemRedirect = [dict stringParamForName:@"url"];
        item.homeItemId = [dict stringParamForName:@"moduleid"];
        item.isNewFlag = [dict boolParamForName:@"isnewflag"];
        [mutableArray2 safetyAddObject:item];
    }
    homePicModel.moreItemArray = [NSArray arrayWithArray:mutableArray2];
    
    return homePicModel;
}

- (HomePicModel *)analyzeHomePicModel:(HomePicModel *)model
{
    for (HomeItem * item in model.homeItemArray)
    {
        [self handleHomeItem:item];
    }
    for (HomeItem * item in model.moreItemArray)
    {
        [self handleHomeItem:item];
    }
    
    return model;
}

- (void)handleHomeItem:(HomeItem *)item
{
    //设置默认图片
    if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=g"])
        item.defaultImageName = @"hp_refuel_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=sl"])
        item.defaultImageName = @"hp_carwash_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=coins"])
        item.defaultImageName = @"hp_mutualIns_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=ins"])
        item.defaultImageName = @"hp_insurance_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=a"])
        item.defaultImageName = @"hp_weekcoupon_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=vio"])
        item.defaultImageName = @"peccancy_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=val"])
        item.defaultImageName = @"hp_valuation_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=rescue"])
        item.defaultImageName = @"hp_rescue_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=ast"])
        item.defaultImageName = @"hp_assist_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=nearbyservice&type=1"])
        item.defaultImageName = @"hp_parking_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=nearbyservice&type=2"])
            item.defaultImageName = @"hp_4sshop_300";
    else if ([item.homeItemRedirect hasPrefix:@"xmdd://j?t=nearbyservice&type=3"])
        item.defaultImageName = @"hp_gasshop_300";
    else
        item.defaultImageName = @"hp_default_300";
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.homeItemArray forKey:@"toppics"];
    [coder encodeObject:self.moreItemArray forKey:@"moretoppics"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.homeItemArray = [coder decodeObjectForKey:@"toppics"];
        self.moreItemArray = [coder decodeObjectForKey:@"moretoppics"];
    }
    return self;
}



@end
