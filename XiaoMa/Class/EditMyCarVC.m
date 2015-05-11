//
//  EditMyCarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EditMyCarVC.h"
#import "XiaoMa.h"
#import "AddCarOp.h"
#import "UpdateCarOp.h"
#import "DeleteCarOp.h"
#import "DatePickerVC.h"

@interface EditMyCarVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HKMyCar *curCar;
@property (nonatomic, assign) BOOL isEditingModel;
@end

@implementation EditMyCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadWithOriginCar:(HKMyCar *)originCar
{
    _originCar = originCar;
    if (originCar) {
        _curCar = [originCar copy];
        _isEditingModel = YES;
    }
    else {
        _curCar = [HKMyCar new];
        _isEditingModel = NO;
    }
    [self.tableView reloadData];
}


#pragma mark - Action
- (IBAction)actionSave:(id)sender
{
    @weakify(self);
    RACSignal *sig;
    if (self.isEditingModel) {
        UpdateCarOp *op = [UpdateCarOp new];
        op.req_car = self.curCar;
        sig = [op rac_postRequest];
    }
    else {
        AddCarOp *op = [AddCarOp new];
        op.req_car = self.curCar;
        sig = [op rac_postRequest];
    }
    
    [[sig initially:^{
        [gToast showingWithText:@"正在保存..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast showSuccess:@"保存成功!"];
        [self postCustomNotificationName:kNotifyRefreshMyCarList object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

- (IBAction)actionDelete:(id)sender
{
    //添加模式,点击删除直接返回上一页
    if (!self.isEditingModel) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    @weakify(self);
    DeleteCarOp *op = [DeleteCarOp new];
    op.req_carid = self.curCar.carId;
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在删除..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast showSuccess:@"删除成功!"];
        [self postCustomNotificationName:kNotifyRefreshMyCarList object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.curCar ? 9 : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell;
    if (indexPath.row == 2 || indexPath.row == 3) {
        cell = [self cellForType2AtIndexPath:indexPath];
    }
    else if (indexPath.row == 8) {
        cell = [self cellForType3AtIndexPath:indexPath];
    }
    else {
        cell = [self cellForType1AtIndexPath:indexPath];
    }
    cell.customSeparatorInset = UIEdgeInsetsZero;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //购车时间
    if (indexPath.row == 1) {
        [[DatePickerVC rac_presentPackerVCInView:self.navigationController.view withSelectedDate:self.curCar.purchasedate]
         subscribeNext:^(NSDate *date) {
             self.curCar.purchasedate = date;
        }];
    }
    //保险到期日
    else if (indexPath.row == 6) {
        [[DatePickerVC rac_presentPackerVCInView:self.navigationController.view withSelectedDate:self.curCar.insexipiredate]
         subscribeNext:^(NSDate *date) {
             self.curCar.insexipiredate = date;
         }];
    }
    //品牌车系
    else if (indexPath.row == 2) {
        
    }
    //具体车型
    else if (indexPath.row == 3) {
        
    }
    else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
        if ([field isKindOfClass:[UITextField class]] && field.userInteractionEnabled == YES) {
            [field becomeFirstResponder];
        }
    }
 }

#pragma mark - Cell
- (JTTableViewCell *)cellForType1AtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    
    field.userInteractionEnabled = YES;
    HKMyCar *car = self.curCar;
    if (indexPath.row == 0) {
        titleL.attributedText = [self attrStrWithTitle:@"车牌号码" asterisk:YES];
        field.text = car.licencenumber;
        [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            car.licencenumber = x;
        }];
    }
    else  if (indexPath.row  == 1) {
        titleL.attributedText = [self attrStrWithTitle:@"购车时间" asterisk:YES];
        [[RACObserve(car, purchasedate) takeUntilForCell:cell] subscribeNext:^(NSDate *date) {
            field.text = [date dateFormatForYYMMdd];
        }];
        field.userInteractionEnabled = NO;
    }
    else  if (indexPath.row  == 4) {
        titleL.attributedText = [self attrStrWithTitle:@"整车价格" asterisk:NO];
        field.text = [NSString stringWithFormat:@"%.2f", car.price];
        [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString *str) {
            car.price = [str floatValue];
        }];
    }
    else if (indexPath.row == 5) {
        titleL.attributedText = [self attrStrWithTitle:@"当前里程" asterisk:NO];
        field.text = [NSString stringWithFormat:@"%d公里", (int)car.odo];
        [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString *str) {
            car.odo = [str integerValue];
        }];
    }
    else if (indexPath.row == 6) {
        titleL.attributedText = [self attrStrWithTitle:@"保险到期日" asterisk:NO];
        [[RACObserve(car, insexipiredate) takeUntilForCell:cell] subscribeNext:^(NSDate *date) {
            field.text = [date dateFormatForYYMMdd];
        }];
        field.userInteractionEnabled = NO;
    }
    else if (indexPath.row == 7) {
        titleL.attributedText = [self attrStrWithTitle:@"保险公司" asterisk:NO];
        field.text = car.inscomp;
        [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString *str) {
            car.inscomp = str;
        }];
    }
    
    return cell;
}

- (JTTableViewCell *)cellForType2AtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *subTitleL = (UILabel *)[cell.contentView viewWithTag:1002];
    
    if (indexPath.row == 2) {
        titleL.attributedText = [self attrStrWithTitle:@"品牌车系" asterisk:YES];
        [[RACObserve(self.curCar, brand) takeUntilForCell:cell] subscribeNext:^(id x) {
            subTitleL.text = x;
        }];
    }
    else if (indexPath.row == 3) {
        titleL.attributedText = [self attrStrWithTitle:@"具体车型" asterisk:YES];
        [[RACObserve(self.curCar, model) takeUntilForCell:cell] subscribeNext:^(id x) {
            subTitleL.text = x;
        }];
    }
    return cell;
}

- (JTTableViewCell *)cellForType3AtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"Cell3" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UISwitch *switchV = (UISwitch *)[cell.contentView viewWithTag:1002];
    
    titleL.text = @"设为默认车辆";
    switchV.on = self.curCar.isDefault;
    @weakify(self);
    [[switchV rac_newOnChannel] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        BOOL on = [x boolValue];
        self.curCar.isDefault = on;
    }];
    return cell;
}

#pragma mark - Utility
- (NSAttributedString *)attrStrWithTitle:(NSString *)title asterisk:(BOOL)asterisk
{
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedString];
    NSAttributedString *titleStr = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor darkTextColor]}];
    [attrStr appendAttributedString:titleStr];
    if (asterisk) {
        NSAttributedString *asteriskStr = [[NSAttributedString alloc] initWithString:@"*" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor redColor]}];
        [attrStr appendAttributedString:asteriskStr];
    }
    
    return attrStr;
}
@end
