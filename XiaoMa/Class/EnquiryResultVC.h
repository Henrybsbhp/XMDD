//
//  EnquiryResultVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnquiryResultVC : UITableViewController
@property (nonatomic, strong, readonly) NSArray *insurances;
@property (nonatomic, strong, readonly) NSString *calculatorID;

- (void)reloadWithInsurance:(NSArray *)insurances calculatorID:(NSString *)cid;

@end
