//
//  InsuranceVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceVC.h"
#import "XiaoMa.h"
#import "ADViewController.h"
#import "HKCellData.h"
#import "NSString+RectSize.h"
#import <MZFormSheetController.h>
#import "InsuranceStore.h"
#import "HKLoadingModel.h"
#import "NSString+Split.h"
#import "CKLimitTextField.h"
#import "MyCarStore.h"
#import "UIView+Shake.h"
#import "InsuranceVM.h"

#import "InsInputNameVC.h"
#import "InsInputInfoVC.h"
#import "InsCheckResultsVC.h"
#import "InsuranceOrderVC.h"
#import "PickerVC.h"

@interface InsuranceVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) InsuranceStore *insStore;
@end

@implementation InsuranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupADView];
    [self setupInsStore];
    [[self.insStore getInsSimpleCars] send];
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp114"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp114"];
}

- (void)setupADView
{
    CKAsyncMainQueue(^{
        self.advc = [ADViewController vcWithADType:AdvertisementInsurance boundsWidth:self.view.frame.size.width
                                          targetVC:self mobBaseEvent:@"rp114-3"];
        [self.advc reloadDataForTableView:self.tableView];
    });
}

- (void)setupInsStore
{
    self.insStore = [InsuranceStore fetchOrCreateStore];
    //监听保险车辆信息和保险支持的省市更新
    @weakify(self);
    [self.insStore subscribeWithTarget:self domain:@"simpleCars" receiver:^(CKStore *store, CKEvent *evt) {
        @strongify(self);
        CKAsyncMainQueue(^{
            [self reloadWithEvent:evt];
        });
    }];
}

- (void)setupRefreshView
{
    if (![self.tableView isRefreshViewExists]) {
        [self.tableView.refreshView addTarget:self action:@selector(actionRefresh:)
                             forControlEvents:UIControlEventValueChanged];
    }
}
#pragma mark - Datasource
- (void)reloadWithEvent:(CKEvent *)event
{
    @weakify(self);
    [[[[[event signal] deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        @strongify(self);
        [self.view hideDefaultEmptyView];
        //如果没有省份信息，需要强制更新
        if (!self.insStore.insProvinces) {
            self.tableView.hidden = YES;
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }
        else {
            [self setupRefreshView];
            [self.tableView.refreshView beginRefreshing];
        }
    }] finally:^{
        
        @strongify(self);
        //结束动画
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        [self.view stopActivityAnimation];
    }] subscribeError:^(NSError *error) {
        
        @strongify(self);
        [self.view showDefaultEmptyViewWithText:@"获取信息失败，点击重试" tapBlock:^{
            //重新发送事件
            [event send];
        }];
    } completed:^{
       
        @strongify(self);
        self.tableView.hidden = NO;
        [self setupRefreshView];
        //刷新页面
        [self reloadData];
    }];
}

- (void)reloadData
{
    NSMutableArray *datasource = [NSMutableArray array];
    //标题
    HKCellData *promptCell = [HKCellData dataWithCellID:@"Prompt" tag:nil];
    NSString *title = @"请选择或添加一辆爱车，保险到期日前60天内，可进行核保。";
    promptCell.object = title;
    @weakify(self);
    [promptCell setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(self);
        CGSize fz = [title labelSizeWithWidth:self.tableView.frame.size.width - 28 font:[UIFont systemFontOfSize:13]];
        return ceil(fz.height) + 10;
    }];
    [datasource addObject:promptCell];
    
    //车牌
    NSArray *carCells = [self.insStore.simpleCars.allObjects arrayByMappingOperator:^id(id obj) {

        @strongify(self);
        HKCellData *cell = [HKCellData dataWithCellID:@"Car" tag:nil];
        cell.object = obj;
        [cell setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {

            @strongify(self);
            InsSimpleCar *car = obj;
            if (car.status == 0 || !car.refid) {
                [self actionInputOwnerNameWithLicenseNumber:car.licenseno];
            }
            else {
                InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
                infoVC.insModel.licenseNumber = car.licenseno;
                infoVC.insModel.premiumId = car.refid;
                infoVC.insModel.originVC = self;
                [self.navigationController pushViewController:infoVC animated:YES];
            }
        }];
        return cell;
    }];
    [datasource safetyAddObjectsFromArray:carCells];
    
    //添加车辆
    HKCellData *addCell = [HKCellData dataWithCellID:@"Add" tag:nil];
    addCell.customInfo[@"province"] = [self.insStore.insProvinces objectAtIndex:0];
    [addCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 61;
    }];
    [datasource addObject:addCell];
    
    self.datasource = datasource;
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)actionRefresh:(id)sender
{
    [[self.insStore getInsSimpleCars] send];
}

- (void)actionInputOwnerNameWithLicenseNumber:(NSString *)licenseno
{
    InsInputNameVC *vc = [UIStoryboard vcWithId:@"InsInputNameVC" inStoryboard:@"Insurance"];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(270, 160) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    //取消
    [[[vc.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] take:1] subscribeNext:^(id x) {
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    //确定
    @weakify(self);
    @weakify(vc);
    [[vc.ensureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        @strongify(vc);
        if (vc.nameField.text.length == 0) {
            [vc.nameField shake];
            return ;
        }
        [vc.nameField endEditing:YES];
        [sheet dismissAnimated:YES completionHandler:nil];

        InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
        infoVC.insModel.realName = vc.nameField.text;
        infoVC.insModel.licenseNumber = licenseno;
        infoVC.insModel.originVC = self;
        [self.navigationController pushViewController:infoVC animated:YES];
    }];
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.section];
    if (data.selectedBlock) {
        data.selectedBlock(tableView, indexPath);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.section];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.section];
    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Prompt" tag:nil]) {
        [self resetPromptCell:cell withData:data];
    }
    else if ([data equalByCellID:@"Car" tag:nil]) {
        [self resetCarCell:cell withData:data];
    }
    else if ([data equalByCellID:@"Add" tag:nil]) {
        [self resetAddCarCell:cell withData:data];
    }
    
    [cell prepareCellForTableView:tableView atIndexPath:indexPath];
    return cell;
}

#pragma mark - Cell
- (void)resetPromptCell:(JTTableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *label = [cell.contentView viewWithTag:1001];
    label.text = data.object;

}

- (void)resetCarCell:(JTTableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *numberL = [cell viewWithTag:1002];
    UIButton *stateB = [cell viewWithTag:1003];
    UIImageView *arrowV = [cell viewWithTag:1004];
    
    InsSimpleCar *car = data.object;
    numberL.text = [car.licenseno splitByStep:2 replacement:@" " count:1];
    
    if (car.status == 0 || car.status == 3) {
        arrowV.hidden = NO;
        stateB.hidden = YES;
    }
    else {
        stateB.hidden = NO;
        arrowV.hidden = YES;
        NSString *title = @"我的订单";
        if (car.status == 2) {
            title = @"核保记录";
        }
        [stateB setTitle:title forState:UIControlStateNormal];
        
        @weakify(self);
        [[[stateB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             
             @strongify(self);
             //核保记录
             if (car.status == 2) {
                 InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
                 vc.insModel = [[InsuranceVM alloc] init];
                 vc.insModel.licenseNumber = car.licenseno;
                 vc.insModel.premiumId = car.refid;
                 vc.insModel.originVC = self;
                 [self.navigationController pushViewController:vc animated:YES];
             }
             //有保单
             else if (car.status == 1 || car.status == 4) {
                 InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
                 vc.orderID = car.refid;
                 [self.navigationController pushViewController:vc animated:YES];
             }
        }];
    }
}

- (void)resetAddCarCell:(JTTableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *provinceL = [cell viewWithTag:10011];
    UIButton *provinceB = [cell viewWithTag:10013];
    CKLimitTextField *textF = [cell viewWithTag:1002];
    UIButton *addB = [cell viewWithTag:1003];

    Area *province = data.customInfo[@"province"];
    provinceL.text = province.abbr;
    
    @weakify(self);
    [[[provinceB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         @strongify(self);
         if (self.insStore.insProvinces.count == 1) {
             Area *province = [self.insStore.insProvinces objectAtIndex:0];
             [gToast showText:[NSString stringWithFormat:@"当前只支持%@", province.name]];
         }
         else if (self.insStore.insProvinces.count > 0) {
             [[self pickProvinceFrom:[self.insStore.insProvinces allObjects] curProvince:data.customInfo[@"province"]]
              subscribeNext:^(Area *curProvince) {
                  data.customInfo[@"province"] = curProvince;
                  provinceL.text = curProvince.abbr;
             }];
         }
    }];
    
    textF.textLimit = 6;
    textF.text = data.customInfo[@"suffix"];
    
    [textF setDidBeginEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = nil;
    }];
    
    [textF setDidEndEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = @"A12345";
    }];

    [textF setTextDidChangedBlock:^(CKLimitTextField *field) {
        field.text = [field.text uppercaseString];
        data.customInfo[@"suffix"] = field.text;
    }];
    
    [[[addB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        NSString *prefix = [(Area *)data.customInfo[@"province"] abbr];
        NSString *licenseno = [prefix append:data.customInfo[@"suffix"]];
        data.customInfo[@"licenseno"] = licenseno;
        if (![MyCarStore verifiedLicenseNumberFrom:licenseno]) {
            [gToast showText:@"请输入正确的车牌号码"];
        }
        else {
            [self actionInputOwnerNameWithLicenseNumber:licenseno];
        }
    }];
}

- (RACSignal *)pickProvinceFrom:(NSArray *)provinces curProvince:(Area *)curProvince
{
    PickerVC *vc = [PickerVC pickerVC];
    [vc setGetTitleBlock:^NSString *(NSInteger row, NSInteger component) {
        Area *province = [provinces safetyObjectAtIndex:row];
        return [NSString stringWithFormat:@"%@（%@）", province.name, province.abbr];
    }];
    return [[vc rac_presentInView:self.navigationController.view datasource:@[provinces]
                         curRows:[NSArray safetyArrayWithObject:curProvince]] map:^id(NSArray *result) {
        return [result safetyObjectAtIndex:0];
    }];
}

@end
