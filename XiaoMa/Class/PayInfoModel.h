//
//  PayInfoModel.h
//  XiaoMa
//
//  Created by fuqi on 16/6/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WechatPayInfo : NSObject

@property (nonatomic,strong)NSDictionary * payInfo;

//@property (nonatomic,copy)NSString * appid;
//@property (nonatomic,copy)NSString * partnerId;
//@property (nonatomic,copy)NSString * prepayId;
//@property (nonatomic,copy)NSString * noncestr;
//@property (nonatomic,copy)NSString * timestamp;
//@property (nonatomic,copy)NSString * package;
//@property (nonatomic,copy)NSString * sign;


@end

@interface PayInfoModel : NSObject

@property (nonatomic,copy)NSString * alipayInfo;
@property (nonatomic,strong)WechatPayInfo * wechatInfo;

+ (instancetype)payInfoWithJSONResponse:(NSDictionary *)rsp;

@end
