//
//  RescureHomeViewController.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/9.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescureHomeViewController.h"
#import "LoginVC.h"
#import "RescureHistoryViewController.h"
#import "GetRescueOp.h"
#import "RescureDetailsVC.h"
#import "HKRescue.h"
#import "GetRescueNoLoginOp.h"
#import "HKRescueNoLogin.h"
#import "RescueApplyOp.h"
#import "ADViewController.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "NSDate+DateForText.h"
#import "NSString+RectSize.m"
#define kWidth [UIScreen mainScreen].bounds.size.width
@interface RescureHomeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *addressLb;
@property (nonatomic, strong) UIView        * headerView;
@property (nonatomic, strong) UIImageView   * backgroundImage;
@property (nonatomic, strong) UIButton      * phoneHelperBtn;
@property (nonatomic ,strong) UIButton      * historyBtn;
@property (nonatomic, strong) ADViewController *adctrl;

@property (nonatomic, strong) NSMutableArray *datasourceArray;
@property (nonatomic, strong) NSMutableArray *desArray;
@end

@implementation RescureHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self actionFirstEnterNetwork];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.historyBtn];
    
    if (gMapHelper.addrComponent != nil) {
        [self actionAddress];
    }else{
        self.addressLb.text = @"获取位置失败, 请尝试\"刷新\"";
    }
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 28)];
    [self.headerView addSubview:self.backgroundImage];
    [self.headerView addSubview:self.phoneHelperBtn];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescureHomeViewController dealloc");
}


#pragma mark - Action
- (void)actionAddress {
    NSString *tempAdd = [NSString stringWithFormat:@"%@%@%@%@%@", gMapHelper.addrComponent.province,gMapHelper.addrComponent.city, gMapHelper.addrComponent.district, gMapHelper.addrComponent.street,gMapHelper.addrComponent.number];
    
    self.addressLb.text = [tempAdd stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
}
- (void)actionFirstEnterNetwork {
    if (gAppMgr.myUser != nil) {//已登录
        GetRescueOp *op = [GetRescueOp operation];
        
        [[[[op rac_postRequest] initially:^{
            self.bottomView.hidden = YES;
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }] finally:^{
            [self.view stopActivityAnimation];
            
        }] subscribeNext:^(GetRescueOp *op) {
            self.bottomView.hidden = NO;
            [self.view stopActivityAnimation];
            [self.datasourceArray safetyAddObjectsFromArray:op.req_resceuArray];
            NSString *tempStr;
            NSString *lastStr;
            for (HKRescue *rescue in op.req_resceuArray) {
                tempStr = [NSString stringWithFormat:@"● %@", rescue.rescueDesc];
                lastStr = [tempStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n● "];
                [self.desArray safetyAddObject:lastStr];
                
            }
            [self.tableView reloadData];
        } error:^(NSError *error) {
            self.bottomView.hidden = YES;
            if (self.datasourceArray.count == 0) {
//                [self.view showDefaultEmptyViewWithText:kDefErrorPormpt tapBlock:^{
//                    [self actionFirstEnterNetwork];
//                }];
            }
            
        }] ;
        
    }else {//未登录
        GetRescueNoLoginOp *op = [GetRescueNoLoginOp operation];
        [[[[op rac_postRequest] initially:^{
            self.bottomView.hidden = YES;
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }] finally:^{
             [self.view stopActivityAnimation];
        }] subscribeNext:^(GetRescueNoLoginOp *op) {
            self.bottomView.hidden = NO;
            [self.datasourceArray safetyAddObjectsFromArray:op.req_resceuArray];
            NSString *tempStr;
            NSString *lastStr;
            for (HKRescueNoLogin *rescue in op.req_resceuArray) {
                tempStr = [NSString stringWithFormat:@"● %@", rescue.rescueDesc];
                lastStr = [tempStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n● "];
                [self.desArray safetyAddObject:lastStr];
                
            }
            [self.tableView reloadData];
        } error:^(NSError *error) {
            self.bottomView.hidden = YES;
            if (self.datasourceArray.count == 0) {
//                [self.view showDefaultEmptyViewWithText:kDefErrorPormpt tapBlock:^{
//                    [self actionFirstEnterNetwork];
//                }];
            }
        }] ;
    }
}

- (void)actionPhoneHelper:(UIButton *)sender {
    
    if (gAppMgr.myUser != nil) {
        RescueApplyOp *op = [RescueApplyOp operation];
        op.address = self.addressLb.text;
        op.longitude = [NSString stringWithFormat:@"%lf", gMapHelper.coordinate.longitude];
        op.latitude = [NSString stringWithFormat:@"%lf", gMapHelper.coordinate.latitude];
       
        [[[[op rac_postRequest] initially:^{
            
        }] finally:^{
            
        }] subscribeNext:^(RescueApplyOp *op) {

        } error:^(NSError *error) {
            
        }] ;
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"救援电话: 4007-111-111"];
    }else{
        [MobClick event:@"rp101-2"];
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"救援电话: 4007-111-111"];
    }
}

- (void)actionRescueHistory {
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        RescureHistoryViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescureHistoryViewController"];
        vc.type = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)refreshClick:(UIButton *)sender {
    
    [[[gMapHelper rac_getInvertGeoInfo] initially:^{
         self.addressLb.hidden = YES;
    }]
     subscribeNext:^(AMapReGeocode * getInfo) {
         self.addressLb.hidden = NO;
         [self actionAddress];
         
     } error:^(NSError *error) {
         self.addressLb.hidden = NO;
         switch (error.code) {
             case kCLErrorDenied:
             {
                 if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
                 {
                     UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"请允许小马达达访问您的位置，进入系统-[设置]-[小马达达]-[位置]-使用期间" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置", nil];
                     
                     [[av rac_buttonClickedSignal] subscribeNext:^(id x) {
                         
                         if ([x integerValue] == 1)
                         {
                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                         }
                     }];
                     [av show];
                 }
                 else
                 {
                     UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"请允许小马达达访问您的位置" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                     
                     [av show];
                 }
                 break;
             }
             case LocationFail:
             {
                 UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"城市定位失败,请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                 
                 [av show];
             }
             default:
             {
                 
                self.addressLb.text = @"获取位置失败, 请尝试\"刷新\"";
                break;
             }
         }
         
     }];
}

#pragma mark - spacing
- (NSAttributedString *)attributedStringforHeight:(NSString *)str {
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:3];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [str length])];
    return attributedString1;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescureHomeViewController" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *titleImg    = (UIImageView *)[cell searchViewWithTag:1000];
    UILabel * nameLb         = (UILabel *)[cell searchViewWithTag:1001];
    UILabel * conditionsLb   = (UILabel *)[cell searchViewWithTag:1006];
    UILabel * priceLb        = (UILabel *)[cell searchViewWithTag:1003];
    UILabel * numberLb       = (UILabel *)[cell searchViewWithTag:1004];
    UIView  * view           = (UIView  *)[cell searchViewWithTag:1005];
    UILabel * remainingLb    = (UILabel *)[cell searchViewWithTag:1007];
    UILabel * tempLb         = (UILabel *)[cell searchViewWithTag:1008];
    view.layer.borderColor = [UIColor colorWithHex:@"#fe9d87" alpha:1].CGColor;
    view.layer.cornerRadius = 4;
    view.layer.masksToBounds = YES;
    if (gAppMgr.myUser != nil) {
        HKRescue *rescue = [self.datasourceArray safetyObjectAtIndex:indexPath.row];
        nameLb.text = rescue.serviceName;
        priceLb.text = [NSString stringWithFormat:@"￥%@", rescue.amount];
        numberLb.text = [NSString stringWithFormat:@"%@", rescue.serviceCount];
        
        if ([rescue.serviceCount integerValue] == 0) {
            
            numberLb.hidden = YES;
            remainingLb.hidden = YES;
            tempLb.hidden = YES;
        }else {
            numberLb.hidden = NO;
            remainingLb.hidden = NO;
            tempLb.hidden = NO;
        }
        if (self.desArray.count != 0) {
             [conditionsLb setAttributedText:[self attributedStringforHeight:[self.desArray safetyObjectAtIndex:indexPath.row]]];
        }
        
    }else {
        HKRescueNoLogin *noLogin = self.datasourceArray[indexPath.row];
        nameLb.text = noLogin.serviceName;
        priceLb.text = [NSString stringWithFormat:@"￥%@", noLogin.amount];
        if (self.desArray.count != 0) {
             [conditionsLb setAttributedText:[self attributedStringforHeight:[self.desArray safetyObjectAtIndex:indexPath.row]]];
        }
        numberLb.hidden = YES;
        remainingLb.hidden = YES;
        tempLb.hidden = YES;
    }
    
    if (indexPath.row == 0) {
        titleImg.image = [UIImage imageNamed:@"rescue_trailer"];
    }else if (indexPath.row == 1){
        titleImg.image = [UIImage imageNamed:@"pump_power"];
    }else if (indexPath.row == 2){
        titleImg.image = [UIImage imageNamed:@"rescue_tire"];
    }
    return cell;
}



#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * str = [self.desArray safetyObjectAtIndex:indexPath.row];
    
    CGFloat width = kWidth - 149;
    CGSize size = [str labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
    if (size.height < 20) {
        return 89;
    }else if (size.height >= 20 && size.height <= 40) {
        return 89 ;
    }else {
        return 89 + size.height - 10;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (gAppMgr.myUser != nil) {
        HKRescue *rescue = self.datasourceArray[indexPath.row];
        RescureDetailsVC *vc = [UIStoryboard vcWithId:@"RescureDetailsVC" inStoryboard:@"Rescue"];
        vc.type = indexPath.row + 1;
        vc.titleStr = rescue.serviceName;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        HKRescueNoLogin *noLogin = self.datasourceArray[indexPath.row];
        RescureDetailsVC *vc = [UIStoryboard vcWithId:@"RescureDetailsVC" inStoryboard:@"Rescue"];
        vc.type = indexPath.row + 1;
        vc.titleStr = noLogin.serviceName;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}


#pragma mark - lazyLoading

- (UIView *)headerView {
    if (!_headerView) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.44 * kWidth + 38 + 9)];
    }
    return _headerView;
}

- (UIImageView *)backgroundImage {
    if (!_backgroundImage) {
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.44 * kWidth)];
        _backgroundImage.image = [UIImage imageNamed:@"banner"];
    }
    return _backgroundImage;
}

- (UIButton *)phoneHelperBtn {
    if (!_phoneHelperBtn) {
        self.phoneHelperBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _phoneHelperBtn.frame = CGRectMake(28, CGRectGetMaxY(self.backgroundImage.frame) + 4, kWidth - 56, 38);
        [_phoneHelperBtn addTarget:self action:@selector(actionPhoneHelper:) forControlEvents:UIControlEventTouchUpInside];
        [_phoneHelperBtn setTitle:@"一键救援" forState:UIControlStateNormal];
        _phoneHelperBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_phoneHelperBtn setTintColor:[UIColor whiteColor]];
        _phoneHelperBtn.backgroundColor = [UIColor colorWithHex:@"#fe4a00" alpha:1];
        _phoneHelperBtn.cornerRadius = 19;
    }
    return _phoneHelperBtn;
}
- (UIButton *)historyBtn {
    if (!_historyBtn) {
        self.historyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _historyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _historyBtn.frame = CGRectMake(0, 0, 60, 44);
        [_historyBtn setTitle:@"救援记录" forState:UIControlStateNormal];
        [_historyBtn addTarget:self action:@selector(actionRescueHistory) forControlEvents:UIControlEventTouchUpInside];
    }
    return _historyBtn;
}

- (NSMutableArray *)datasourceArray {
    if (!_datasourceArray) {
        self.datasourceArray = [[NSMutableArray alloc] init];
    }
    return _datasourceArray;
}
- (NSMutableArray *)desArray {
    if (!_desArray) {
        self.desArray = [[NSMutableArray alloc] init];
    }
    return _desArray;
}
@end
