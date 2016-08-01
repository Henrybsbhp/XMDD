//
//  GetShareDetailOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/26.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetShareDetailOp : BaseOp

@property (nonatomic)ShareSceneType pagePosition;
@property (nonatomic)ShareButtonType buttonId;
@property (nonatomic)NSInteger gasCharge;
@property (nonatomic)NSInteger spareCharge;
@property (nonatomic, copy)NSString * shareCode;

@property (nonatomic, copy)NSString * rsp_title;
@property (nonatomic, copy)NSString * rsp_desc;
@property (nonatomic, copy)NSString * rsp_linkurl;
@property (nonatomic, copy)NSString * rsp_imgurl;
@end
