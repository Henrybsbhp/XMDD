//
//  CommissonOrderVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CommissonOrderVC.h"
#import "NSString+RectSize.h"
#import "GetRescureDetailOp.h"
#import "CommissonConfirmVC.h"
#import "RescureHistoryViewController.h"
#import "LoginViewModel.h"
#import "GetStartHostCarOp.h"
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface CommissonOrderVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIImageView   * advertisingImg;
@property (nonatomic, strong)                                            UIView        * footerView;
@property (nonatomic, strong) UIButton      * helperBtn;
@property (nonatomic, copy)   NSString      * testStr;
@property (nonatomic, strong) NSMutableArray * dataSourceArray;
@end

@implementation CommissonOrderVC

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(deallocInfo);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL result = [LoginViewModel loginIfNeededForTargetViewController:nil];
    NSLog(@"%c", result);
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.advertisingImg;
    self.tableView.tableFooterView = self.footerView;
    [self.view addSubview:self.helperBtn];
    
    [self commissionNetwork];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.frame = CGRectMake(0, 0, 60, 44);
    [btn setTitle:@"协办记录" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(commissionHistory) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    

}
- (void)CommissionClick {
    BOOL result = [LoginViewModel loginIfNeededForTargetViewController:nil];
    if (result) {
        [self networks];
   
    }else{
        [MobClick event:@"rp101-2"];
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"协办电话: 4007-111-111"];
    }
}

- (void)networks{
    GetStartHostCarOp *op = [GetStartHostCarOp operation];
    [[[op rac_postRequest] initially:^{
        
    }]subscribeNext:^(id x) {
        CommissonConfirmVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissonConfirmVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }error:^(NSError *error) {
        
        CommissonConfirmVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissonConfirmVC"];
        [self.navigationController pushViewController:vc animated:YES];
//        if (error.code == 611139001) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有救援券哦，点击省钱攻略，此等优惠岂能错过！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"省钱攻略", nil];
//            [alert show];
//        }
    }];
}
- (void)commissionNetwork {
    GetRescureDetailOp *op = [GetRescureDetailOp operation];
    op.rescueid = 4;
    op.type = [NSNumber numberWithInteger:1];
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"加载中..."];
    }] finally:^{
        
        
    }] subscribeNext:^(GetRescureDetailOp *op) {
        @strongify(self)
        [gToast dismiss];
        
        NSString *lastStr;
        for (NSString *testStr in op.rescueDetailArray) {
            lastStr = [testStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [self.dataSourceArray addObject:lastStr];
        }
        NSString *string = [NSString stringWithFormat:@"● %@", op.rescueDetailArray[0]];
        lastStr = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n● "];
        self.dataSourceArray[0] = lastStr;
        
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [gToast showError:kDefErrorPormpt];
        NSLog(@"%@", error.description);
    }] ;

}

- (void)commissionHistory {
    RescureHistoryViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescureHistoryViewController"];
    vc.type = 2;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescureDetailsVC" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLb = [cell.contentView viewWithTag:1000];
    UILabel *detailLb = [cell.contentView viewWithTag:1001];
    NSString * string = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    detailLb.text = string;
    //行间距
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:4];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
    [detailLb setAttributedText:attributedString1];
    [detailLb sizeToFit];
    
    if (indexPath.row == 0) {
        titleLb.text = @"服务对象";
    }else if (indexPath.row == 1){
        titleLb.text = @"准备材料";
    }else if (indexPath.row == 2){
        titleLb.text = @"注意事项";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * str = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    
    CGFloat width = kWidth - 30;
    CGSize size = [str labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
    CGFloat height;
    height = size.height + 63;
    return height;
}
#pragma mark - lazyLoading
- (UIImageView *)advertisingImg {
    if (!_advertisingImg) {
        self.advertisingImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.44 * kWidth)];
        _advertisingImg.image = [UIImage imageNamed:@"commissonBanner"];
    }
    return _advertisingImg;
}
- (UIView *)footerView {
    if (!_footerView) {
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, (kWidth- 20) * 0.13 + 7)];
    }
    return _footerView;
}
- (NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        self.dataSourceArray = [@[] mutableCopy];
    }
    return _dataSourceArray;
}


- (UIButton *)helperBtn {
    if (!_helperBtn) {
        
        self.helperBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _helperBtn.frame = CGRectMake(10, self.view.bounds.size.height - (kWidth- 20) * 0.13 - 7 - 64 , kWidth  - 20, (kWidth- 20) * 0.13);
        [_helperBtn setTitle:@"我要协办" forState:UIControlStateNormal];
        [_helperBtn addTarget:self action:@selector(CommissionClick) forControlEvents:UIControlEventTouchUpInside];
        [_helperBtn setTintColor:[UIColor whiteColor]];
        _helperBtn.backgroundColor = [UIColor colorWithHex:@"#35cb68" alpha:1];
        _helperBtn.cornerRadius = 4;
        _helperBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    }
    return _helperBtn;
}
@end
