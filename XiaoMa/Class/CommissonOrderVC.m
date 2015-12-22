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
#import "MyCarStore.h"
#import "CKStore.h"
#import "EditCarVC.h"
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface CommissonOrderVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MyCarStore    * carStore;
@property (nonatomic, strong) HKMyCar       * defaultCar;
@property (nonatomic, strong) NSArray       * carNumberArray;
@property (nonatomic, strong) UIImageView   * advertisingImg;
@property (nonatomic, strong) UIView        * footerView;
@property (nonatomic, strong) UIButton      * helperBtn;
@property (nonatomic, strong) UIButton      * historyBtn;
@property (nonatomic, copy)   NSString      * testStr;
@property (nonatomic, strong) NSMutableArray * dataSourceArray;
@end

@implementation CommissonOrderVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissonOrderVC dealloc!");
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.advertisingImg;
    self.tableView.tableFooterView = self.footerView;
    [self.view addSubview:self.helperBtn];
    
    [self actionNetwork];
    [self setupCarStore];
  
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.historyBtn];
}

#pragma mark - Action
- (void)actionCommissionClick {
    if (gAppMgr.myUser != nil) {
        if (self.carStore.allCars.count != 0) {
            [self actionCommissionNetwork];
        }else {
            EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }else{
        [MobClick event:@"rp101-2"];
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"协办电话: 4007-111-111"];
    }
}

- (void)actionCommissionNetwork{
    GetStartHostCarOp *op = [GetStartHostCarOp operation];
    [[[[op rac_postRequest] initially:^{
        
    }]finally:^{
        
    }]subscribeNext:^(GetStartHostCarOp *op) {
        if (op.rsp_code == 0) {
            CommissonConfirmVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissonConfirmVC"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    } error:^(NSError *error) {        
        if (error.code == 611139001) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有救援券哦!\n点击省钱攻略,此等优惠岂能错过" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"省钱攻略", nil];
            [alert show];
        }
    }];
}
- (void) actionNetwork{
    GetRescureDetailOp *op = [GetRescureDetailOp operation];
    op.rescueid = 4;
    op.type = [NSNumber numberWithInteger:1];
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
        
    }] finally:^{
        
        
    }] subscribeNext:^(GetRescureDetailOp *op) {
        @strongify(self)
        [gToast dismiss];
        
        NSString *lastStr;
        for (NSString *testStr in op.rescueDetailArray) {
            lastStr = [testStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
            [self.dataSourceArray safetyAddObject:lastStr];
        }
        
        NSString *string = [NSString stringWithFormat:@"● %@", [self.dataSourceArray safetyObjectAtIndex:0]];
        [self.dataSourceArray safetyReplaceObjectAtIndex:0 withObject:string];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [gToast showError:kDefErrorPormpt];
    }] ;
    
}

- (void)commissionHistory {
    RescureHistoryViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescureHistoryViewController"];
    vc.type = 2;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupCarStore
{
    self.carStore = [MyCarStore fetchExistsStore];
    @weakify(self);
    [self.carStore subscribeEventsWithTarget:self receiver:^(HKStore *store, HKStoreEvent *evt) {
        @strongify(self);
        [[evt signal] subscribeNext:^(id x) {
            @strongify(self);
            self.carNumberArray = [self.carStore allCars];
            if (!self.defaultCar)
            {
                self.defaultCar = [self.carStore defalutInfoCompletelyCar];
            }
        }];
    }];
    [self.carStore sendEvent:[self.carStore getAllCarsIfNeeded]];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescureDetailsVC" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLb = (UILabel *)[cell searchViewWithTag:1000];
    UILabel *detailLb = (UILabel *)[cell searchViewWithTag:1001];
    NSString * string = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    detailLb.text = string;
    //行间距
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:4];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
    [detailLb setAttributedText:attributedString1];
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
    if (size.height > 40) {
        height = size.height + 80;
    }
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
        self.dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}


- (UIButton *)helperBtn {
    if (!_helperBtn) {
        
        self.helperBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _helperBtn.frame = CGRectMake(10, self.view.bounds.size.height - (kWidth- 20) * 0.13 - 7 - 64 , kWidth  - 20, (kWidth- 20) * 0.13);
        [_helperBtn setTitle:@"我要协办" forState:UIControlStateNormal];
        [_helperBtn addTarget:self action:@selector(actionCommissionClick) forControlEvents:UIControlEventTouchUpInside];
        [_helperBtn setTintColor:[UIColor whiteColor]];
        _helperBtn.backgroundColor = [UIColor colorWithHex:@"#35cb68" alpha:1];
        _helperBtn.cornerRadius = 4;
        _helperBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    }
    return _helperBtn;
}
- (UIButton *)historyBtn {
    if (!_historyBtn) {
        self.historyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _historyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _historyBtn.frame = CGRectMake(0, 0, 60, 44);
        [_historyBtn setTitle:@"协办记录" forState:UIControlStateNormal];
        [_historyBtn addTarget:self action:@selector(commissionHistory) forControlEvents:UIControlEventTouchUpInside];
    }
    return _historyBtn;
}

@end
