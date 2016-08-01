//
//  MapBottomView.h
//  XiaoMa
//
//  Created by jt on 15-4-24.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapBottomView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *addressLb;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (weak, nonatomic) IBOutlet UIButton *collectBtn;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtm;
@property (weak, nonatomic) IBOutlet UIButton *navigationBtn;

@end
