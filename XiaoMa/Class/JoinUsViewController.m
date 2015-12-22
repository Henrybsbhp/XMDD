//
//  JoinUsViewController.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/25.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "JoinUsViewController.h"
#import "UIView+Shake.h"
#import "JoinResultViewController.h"
#import "HKLocationDataModel.h"
#import "ApplyUnionOp.h"
#import "GetAreaInfoOp.h"
#import "AreaTablePickerVC.h"

@interface JoinUsViewController ()
@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@property (nonatomic, strong) UITextField *nameField;

@property (nonatomic, strong) UITextField *phoneField;

@property (nonatomic, strong) UITextField *cityField;

@property (nonatomic, strong) HKLocationDataModel *hkLocation;

- (IBAction)applyAction:(id)sender;

@end

@implementation JoinUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"加盟请填写资料";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
    UILabel * lb = (UILabel *)[cell.contentView viewWithTag:1001];
    UITextField * tf = (UITextField *)[cell.contentView viewWithTag:1002];
    if (indexPath.row == 0) {
        lb.text = @"手机：";
        tf.placeholder = @"请输入11位手机号";
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.text = gAppMgr.myUser.phoneNumber;
        [[[tf rac_signalForControlEvents:UIControlEventEditingChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            if (tf.text.length > 11) {
                tf.text = [tf.text substringToIndex:11];
            }
        }];
        self.phoneField = tf;
    }
    else if (indexPath.row == 1){
        lb.text = @"姓名：";
        tf.placeholder = @"请填写联系人姓名";
        self.nameField = tf;
    }
    else {
        lb.text = @"城市：";
        tf.placeholder = @"请选择省市区";
        tf.enabled = NO;
        self.cityField = tf;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        [self.phoneField resignFirstResponder];
        [self.nameField resignFirstResponder];
        
        //清除所有NSUserDefaults的缓存
//        NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
//        NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
//        for(NSString* key in [dictionary allKeys]){
//            [userDefatluts removeObjectForKey:key];
//            [userDefatluts synchronize];
//        }
        
        AreaTablePickerVC * vc = [AreaTablePickerVC initPickerAreaVCWithType:PickerVCTypeProvinceAndCityAndDicstrict fromVC:self];
        
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * districtModel) {
            self.cityField.text = [NSString stringWithFormat:@"%@ %@ %@", provinceModel.infoName, cityModel.infoName, districtModel.infoName];
            self.hkLocation = [[HKLocationDataModel alloc] init];
            self.hkLocation.province = provinceModel.infoName;
            self.hkLocation.city = cityModel.infoName;
            self.hkLocation.district = districtModel.infoName;
        }];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)applyAction:(id)sender {
    if (self.phoneField.text.length != 11) {
        [self shakeCellAtIndex:0];
        return;
    }
    if (self.nameField.text.length == 0) {
        [self shakeCellAtIndex:1];
        return;
    }
    if (self.cityField.text.length == 0) {
        [self shakeCellAtIndex:2];
        return;
    }
    ApplyUnionOp *op = [ApplyUnionOp new];
    op.req_phone = self.phoneField.text;
    op.req_name = self.nameField.text;
    op.req_province = self.hkLocation.province;
    op.req_city = self.hkLocation.city;
    op.req_district = self.hkLocation.district;
    [gToast showingWithoutText];
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(ApplyUnionOp * op) {
        @strongify(self);
        [gToast dismiss];
        JoinResultViewController * vc = [UIStoryboard vcWithId:@"JoinResultViewController" inStoryboard:@"About"];
        vc.phone = self.phoneField.text;
        vc.name = self.nameField.text;
        vc.address = [NSString stringWithFormat:@"%@ %@ %@", self.hkLocation.province, self.hkLocation.city, self.hkLocation.district];
        vc.tip = op.rsp_tip;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
    
}

#pragma mark - Private
- (void)shakeCellAtIndex:(NSInteger)index
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UIView *container = [cell.contentView viewWithTag:1002];
    [container shake];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DebugLog(@"dealloc~~");
}
@end
