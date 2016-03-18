//
//  MutualInsGrouponSubMsgVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "HKMutualGroup.h"

@interface MutualInsGrouponSubMsgVC : HKViewController
@property (nonatomic, strong)HKMutualGroup * group;
@property (nonatomic, strong) NSArray *groupMembers;
@property (nonatomic, copy) void(^didScrollBlock)(UIScrollView *scrollView);

- (void)reloadData;

@end
