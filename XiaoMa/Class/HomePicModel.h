//
//  HomePicModel.h
//  XiaoMa
//
//  Created by jt on 16/1/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeItem : NSObject<NSCoding>

@property (nonatomic,copy)NSString * homeItemTitle;
@property (nonatomic,copy)NSString * homeItemPicUrl;
@property (nonatomic,copy)NSString * homeItemRedirect;

@property (nonatomic,copy)NSString * defaultImageName;

- (instancetype)initWithTitlt:(NSString *)title picUrl:(NSString *)picurl
                       andUrl:(NSString *)url imageName:(NSString *)imageName;

@end

@interface HomePicModel : NSObject<NSCoding>

///homepage上面一排按钮配置信息
@property (nonatomic,strong)NSArray * homeItemArray;

///一键洗车图片
@property (nonatomic,strong)NSString * yjxcPic;
///每周礼券图片
@property (nonatomic,strong)NSString * mzlqpic;
///保险服务图片
@property (nonatomic,strong)NSString * bxfwpic;
///专业救援图片
@property (nonatomic,strong)NSString * zyjypic;
///年检协办图片
@property (nonatomic,strong)NSString * njxbpic;

+ (instancetype)homeWithJSONResponse:(NSDictionary *)rsp;

@end
