//
//  RescueViewController.m
//  XiaoMa
//
//  Created by jt on 15-4-28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "RescueViewController.h"
#import "NSString+RectSize.h"

#define Title @"会员（免费）：\n\
拖车服务	\n免费一年三次24小时拖车服务，拖车免费里程范围单程20公里，超出部分按照当地市场价格问客户现场收取。\n\
泵电服务	\n免费一年各限3次，泵电（一天限一次）、换胎（有完好的自备胎情况下一天限一次）换胎服务\n\
\
非会员收费：以当地实际结算价格为准。"


#define SubTitle @"备注：\n\
（1）此类服务只限故障车，事故类、困境类、交通管制类不在免费服务范围内；\n\
（2）正常情况下接到电话1小时之内到达服务地点。如遇法定节假日、恶劣的天气情况或地区偏远，所到达的救援时间需等待。"

@interface RescueViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *rescurBtn;

@end

@implementation RescueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.row == 0)
    {
        height = 200.0f;
    }
    else if (indexPath.row == 1)
    {
        height = [Title labelSizeWithWidth:self.tableView.frame.size.width font:[UIFont systemFontOfSize:15]].height ;
        
        height = height + 8;
    }
    else
    {
        height = [SubTitle labelSizeWithWidth:self.tableView.frame.size.width font:[UIFont systemFontOfSize:15]].height ;
        
        height = height + 8;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"RescueCellA"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel * lb = (UILabel *)[cell searchViewWithTag:30101];
        lb.text = [NSString stringWithFormat:@"%@%@%@",gMapHelper.province,gMapHelper.city,gMapHelper.district];
    }
    else if (indexPath.row == 1)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"RescueCellB"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel * lb = (UILabel *)[cell searchViewWithTag:30201];
        lb.text = Title;
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"RescueCellC"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel * lb = (UILabel *)[cell searchViewWithTag:30301];
        lb.text = SubTitle;
    }
    return cell;
}


@end
