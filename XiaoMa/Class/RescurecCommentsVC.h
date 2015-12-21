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
@property (nonatomic, assign)   NSInteger       type;//救援类型
@property (nonatomic, strong)   NSDate      *   applyTime;//救援时间
@property (nonatomic, strong)   NSNumber    *   applyId;//救援id
@property (nonatomic, copy)     NSString    *   serviceName;//服务名称
@property (nonatomic, copy)     NSString    *   licenceNumber;//车牌号
@property (nonatomic, strong)   NSNumber    *   applyType;//1.救援 2.协办
@end
