//
//  UnbundlingVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UnbundlingVC.h"
#import "ResultVC.h"
#import "DrawingBoardView.h"

@interface UnbundlingVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *unbundlingBtn;

@end

@implementation UnbundlingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.unbundlingBtn setCornerRadius:5.0f];
    
    [self btnClick];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void) btnClick
{
    [[self.unbundlingBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        ResultVC *vc = [UIStoryboard vcWithId:@"ResultVC" inStoryboard:@"Bank"];
        
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        formSheet.presentedFormSheetSize = CGSizeMake(self.view.frame.size.width - 60, 238);
        formSheet.cornerRadius = 2.0;
        formSheet.shadowOpacity = 0.01;
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.shouldCenterVertically = YES;
        
        [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            [vc.drawView drawSuccess];
            [[vc.confirmBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                [formSheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }];
    }];
}

#pragma mark - TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
//{
//    return @"已发送验证码至13999999999，请输入验证码解绑~";
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    UILabel * lb = [[UILabel alloc] init];
    lb.font = [UIFont systemFontOfSize:14];
    lb.textColor = [UIColor darkGrayColor];
    
    NSMutableAttributedString *attriObtained = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已发送验证码至139****1111，请输入验证码解绑~"]];
    [attriObtained addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(@"#23ac2d") range:NSMakeRange(7, 11)];
    lb.attributedText = attriObtained;
    
    [headerView addSubview:lb];
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(headerView.mas_left).offset(16);
        make.centerY.equalTo(headerView.mas_centerY).offset(6);
    }];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell" forIndexPath:indexPath];
    
    UIView *backView = (UIView *)[cell.contentView viewWithTag:1001];
    UITextField *textfield = (UITextField *)[cell.contentView viewWithTag:1002];
    [backView setBorderWidth:1.0];
    [backView setBorderColor:HEXCOLOR(@"#dfdfdf")];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
