//
//  RescurecCommentsVC.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RescurecCommentsVC : UIViewController
@property (nonatomic, assign)   NSInteger       isLog;//是否已评价
@property (nonatomic, assign)   NSInteger       type;
@property (nonatomic, strong)   NSDate      *   applyTime;
@property (nonatomic, strong)   NSNumber    *   applyId;
@property (nonatomic, copy)     NSString    *   serviceName;//服务名称
@property (nonatomic, copy)     NSString    *   licenceNumber;//车牌号
@end
