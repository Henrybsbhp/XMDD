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
#define kWidth [UIScreen mainScreen].bounds.size.width
@interface RescureHomeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *addressLb;
@property (nonatomic)CLLocationCoordinate2D endCoordinate;
@property (nonatomic, strong) UIView        * headerView;
@property (nonatomic, strong) UIImageView   * backgroundImage;
@property (nonatomic, strong) UIButton      * phoneHelperBtn;

@property (nonatomic, strong) ADViewController *adctrl;

@property (nonatomic, strong) NSMutableArray *datasourceArray;

@end

@implementation RescureHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loginNetwork];
    self.tableView.separatorStyle = NO;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.frame = CGRectMake(0, 0, 60, 44);
    [btn setTitle:@"救援记录" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(rescueHistory) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    
    if (gMapHelper.addrComponent.streetNumber.street != nil) {
        
         self.addressLb.text = [NSString stringWithFormat:@"%@%@%@%@", gMapHelper.addrComponent.province,gMapHelper.addrComponent.city, gMapHelper.addrComponent.district, gMapHelper.addrComponent.streetNumber.street];;
    }else{
        self.addressLb.text = @"获取位置失败, 请尝试\"刷新\"";
    }
   
    
    [self.headerView addSubview:self.backgroundImage];
    [self.headerView addSubview:self.phoneHelperBtn];
    
    self.tableView.separatorStyle = NO;
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(deallocInfo);
}

- (BOOL)loginResult {
    BOOL result = [LoginViewModel loginIfNeededForTargetViewController:nil];
    return result;
}
- (void)loginNetwork {
    NSLog(@"long ======= %lf", gMapHelper.coordinate.longitude);
    BOOL result = [LoginViewModel loginIfNeededForTargetViewController:nil];
    NSLog(@"%d", result);
    @weakify(self)
    if (result) {//已登录
        GetRescueOp *op = [GetRescueOp operation];
        
        [[[[op rac_postRequest] initially:^{
            [gToast showingWithText:@"加载中..."];
        }] finally:^{
        }] subscribeNext:^(GetRescueOp *op) {
            @strongify(self)
            self.datasourceArray = (NSMutableArray *)op.req_resceuArray;
            if (self.datasourceArray.count == 0) {
                
            }
            [gToast dismiss];
            self.tableView.tableHeaderView = self.headerView;
            [self.tableView reloadData];
        } error:^(NSError *error) {
            
        }] ;
 
    }else {//未登录
        GetRescueNoLoginOp *op = [GetRescueNoLoginOp operation];
        [[[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"加载中..."];
        }] finally:^{
            
        }] subscribeNext:^(GetRescueNoLoginOp *op) {
            @strongify(self)
            self.datasourceArray = (NSMutableArray *)op.req_resceuArray;
            [gToast dismiss];
            self.tableView.tableHeaderView = self.headerView;
            [self.tableView reloadData];
        } error:^(NSError *error) {
            
        }] ;
        
    }
}


- (void)phoneHelperClick:(UIButton *)sender {
    
    BOOL result = [LoginViewModel loginIfNeededForTargetViewController:nil];
    if (result) {
         RescueApplyOp *op = [RescueApplyOp operation];
        op.longitude = [NSString stringWithFormat:@"%lf", gMapHelper.coordinate.longitude];
        op.latitude = [NSString stringWithFormat:@"%lf", gMapHelper.coordinate.latitude];
        [[[[op rac_postRequest] initially:^{
           
        }] finally:^{
            
            
        }] subscribeNext:^(RescueApplyOp *op) {
           
        } error:^(NSError *error) {
            [gToast showError:kDefErrorPormpt];
        }] ;
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"救援电话: 4007-111-111"];
    }else{
        [MobClick event:@"rp101-2"];
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"救援电话: 4007-111-111"];
    }
}

- (void)rescueHistory {
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        [MobClick event:@"rp101-5"];
        RescureHistoryViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescureHistoryViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)refreshClick:(UIButton *)sender {
    
    [[[gMapHelper rac_getInvertGeoInfo] initially:^{
        
    }]
     subscribeNext:^(AMapReGeocode * getInfo) {
  
        self.addressLb.text = [NSString stringWithFormat:@"%@%@%@%@", gMapHelper.addrComponent.province,gMapHelper.addrComponent.city, gMapHelper.addrComponent.district, gMapHelper.addrComponent.streetNumber.street];;
        
    } error:^(NSError *error) {
        
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
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"定位失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                
                [av show];
                break;
            }
        }
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescureHomeViewController" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *titleImg = [cell.contentView viewWithTag:1000];
    UILabel *nameLb = [cell.contentView viewWithTag:1001];
    UILabel *conditionsLb = [cell.contentView viewWithTag:1006];
    UILabel *priceLb  = [cell.contentView viewWithTag:1003];
    UILabel *numberLb = [cell.contentView viewWithTag:1004];
    UIView  *view = [cell.contentView viewWithTag:1005];
    UILabel *remainingLb = [cell.contentView viewWithTag:1007];
    UILabel *tempLb = [cell.contentView viewWithTag:1008];
    UILabel *textLb = [cell.contentView viewWithTag:1111];
    textLb.hidden = YES;
    view.layer.borderColor = [UIColor colorWithHex:@"#fe9d87" alpha:1].CGColor;
    view.layer.cornerRadius = 4;
    view.layer.masksToBounds = YES;
    if ([self loginResult]) {
        HKRescue *rescue = self.datasourceArray[indexPath.row];
        nameLb.text = rescue.serviceName;
        priceLb.text = [NSString stringWithFormat:@"￥%@", rescue.amount];
        numberLb.text = [NSString stringWithFormat:@"%@", rescue.serviceCount];
        
        if ([rescue.serviceCount integerValue] == 0) {
            
            textLb.hidden = NO;
            numberLb.hidden = YES;
            remainingLb.hidden = YES;
            tempLb.hidden = YES;
        }
        
        NSString *string = [NSString stringWithFormat:@"● %@", rescue.rescueDesc];
        NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
        NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle1 setLineSpacing:3];
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
        [conditionsLb setAttributedText:attributedString1];
        [conditionsLb sizeToFit];

//        conditionsLb.text = [NSString stringWithFormat:@"● %@", rescue.rescueDesc];
    }else {
        HKRescueNoLogin *noLogin = self.datasourceArray[indexPath.row];
        nameLb.text = noLogin.serviceName;
        priceLb.text = [NSString stringWithFormat:@"%@", noLogin.amount];
        NSString *string = [NSString stringWithFormat:@"● %@", noLogin.rescueDesc];
        NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
        NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle1 setLineSpacing:3];
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
        [conditionsLb setAttributedText:attributedString1];
        [conditionsLb sizeToFit];
        numberLb.hidden = YES;
        remainingLb.hidden = YES;
        tempLb.hidden = YES;
    }
    
    if (indexPath.row == 0) {
        titleImg.image = [UIImage imageNamed:@"拖车服务"];
    }else if (indexPath.row == 1){
        titleImg.image = [UIImage imageNamed:@"泵电服务"];
    }else if (indexPath.row == 2){
        titleImg.image = [UIImage imageNamed:@"换胎服务"];
    }
    return cell;
}



#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label  = [tableView viewWithTag:1006];
    NSString *str = [label.text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n● "];
    label.text = str;
    CGSize size = CGSizeMake(label.frame.size.width, 0);
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:12.0]};
    CGRect rect = [label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    CGRect frame = label.frame;
    frame.size.height = rect.size.height;
    label.frame = frame;
    if (label.frame.size.height < 20) {
        return 89;
    }else if ( label.frame.size.height >= 20 && label.frame.size.height <= 40) {
    return 89 ;
    }else {
        return 89 + label.frame.size.height - 10;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [MobClick event:@"rp101-5"];
    if ([self loginResult]) {
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
        [_phoneHelperBtn addTarget:self action:@selector(phoneHelperClick:) forControlEvents:UIControlEventTouchUpInside];
        [_phoneHelperBtn setTitle:@"一键救援" forState:UIControlStateNormal];
        _phoneHelperBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_phoneHelperBtn setTintColor:[UIColor whiteColor]];
        _phoneHelperBtn.backgroundColor = [UIColor colorWithHex:@"#fe4a00" alpha:1];
        _phoneHelperBtn.cornerRadius = 19;
    }
    return _phoneHelperBtn;
}

- (NSMutableArray *)datasourceArray {
    if (!_datasourceArray) {
        self.datasourceArray = [@[] mutableCopy];
    }
    return _datasourceArray;
}

@end
