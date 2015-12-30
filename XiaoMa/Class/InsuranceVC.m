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
#import "UIView+Shake.h"
#import "InsuranceVM.h"
#import "MyCarStore.h"

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
@property (nonatomic, strong) InsuranceVM *insModel;
@end

@implementation InsuranceVC

- (void)awakeFromNib
{
    self.insModel = [[InsuranceVM alloc] init];
}

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
    [MobClick beginLogPageView:@"rp1000"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp1000"];
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
    NSArray *domains = @[@"simpleCars"];
    //监听保险车辆信息和保险支持的省市更新
    @weakify(self);
    [self.insStore subscribeWithTarget:self domainList:domains receiver:^(CKStore *store, CKEvent *evt) {
        @strongify(self);
        CKAsyncMainQueue(^{
            [self reloadWithEvent:evt];
        });
    }];
}

- (void)setupRefreshView
{
    [self.tableView.refreshView addTarget:self action:@selector(actionRefresh:)
                         forControlEvents:UIControlEventValueChanged];
}
#pragma mark - Datasource
- (void)reloadWithEvent:(CKEvent *)event
{
    @weakify(self);
    [[[[event signal] deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        @strongify(self);
        [self.view hideDefaultEmptyView];
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView beginRefreshing];
        }
        else {
            self.tableView.hidden = YES;
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }
    }] subscribeError:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        else {
            [self.view stopActivityAnimation];
            [self.view showDefaultEmptyViewWithText:@"获取信息失败，点击重试" tapBlock:^{
                @strongify(self);
                //重新发送事件
                [[self.insStore getInsSimpleCars] send];
            }];
        }
    } completed:^{
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        else {
            [self.view stopActivityAnimation];
            [self setupRefreshView];
        }
        self.tableView.hidden = NO;
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
            [MobClick event:@"rp1002-2"];
            InsSimpleCar *car = obj;
            if (car.status == 0 || !car.carpremiumid) {
                [self actionInputOwnerNameForSimpleCar:car];
            }
            //核保记录
            else if (car.status == 2) {
                InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
                vc.insModel = [self.insModel copy];
                vc.insModel.simpleCar = car;
                vc.insModel.originVC = self;
                [self.navigationController pushViewController:vc animated:YES];
            }
            //有保单
            else if (car.status == 1 || car.status == 4 || car.status == 5) {
                InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
                vc.orderID = car.refid;
                [self.navigationController pushViewController:vc animated:YES];
            }
            //填写信息
            else {
                InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
                infoVC.insModel.simpleCar = car;
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
        return 50;
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

- (void)actionInputOwnerNameForSimpleCar:(InsSimpleCar *)car
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
        infoVC.insModel.simpleCar = car;
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
    return 65;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Prompt" tag:nil]) {
        [self resetPromptCell:cell withData:data];
    }
    else if ([data equalByCellID:@"Car" tag:nil]) {
        [self resetCarCell:cell withData:data atIndexPath:indexPath];
    }
    else if ([data equalByCellID:@"Add" tag:nil]) {
        [self resetAddCarCell:cell withData:data];
    }
    
    return cell;
}

#pragma mark - Cell
- (void)resetPromptCell:(UITableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *label = [cell.contentView viewWithTag:1001];
    label.text = data.object;
    
}

- (void)resetCarCell:(UITableViewCell *)cell withData:(HKCellData *)data atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *numberL = [cell viewWithTag:1001];
    UIButton *rightB = [cell viewWithTag:1002];
    
    InsSimpleCar *car = data.object;
    
    NSString *licenseno = [car.licenseno splitByStep:2 replacement:@" " count:1];
    NSString *statusdesc = [self.insModel simpleCarStatusDesc:car.status];
    licenseno = statusdesc ? [licenseno append:@"\n"] : licenseno;
    
    NSMutableAttributedString *attstr = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSForegroundColorAttributeName: HEXCOLOR(@"#454545"),
                            NSFontAttributeName: [UIFont systemFontOfSize:17]};
    [attstr appendAttributedString:[[NSAttributedString alloc] initWithString:licenseno attributes:attr1]];
    if (statusdesc) {
        NSDictionary *attr2 = @{NSForegroundColorAttributeName: HEXCOLOR(@"#888888"),
                                NSFontAttributeName: [UIFont systemFontOfSize:12]};
        [attstr appendAttributedString:[[NSAttributedString alloc] initWithString:statusdesc attributes:attr2]];
    }
    numberL.attributedText = attstr;
#if DEBUG
    rightB.hidden = car.status == 0 || car.status == 3;
#else
    rightB.hidden = car.status != 1 && car.status != 2;
#endif
    [rightB setTitle:car.status == 1 ? @"核保结果" : @"重新核保" forState:UIControlStateNormal];
    @weakify(self);
    [[[rightB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {

         @strongify(self);
         [MobClick event:@"rp1001-1"];
         //到核保结果页
         if (car.status == 1) {
             InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
             vc.insModel = [self.insModel copy];
             vc.insModel.simpleCar = car;
             vc.insModel.originVC = self;
             [self.navigationController pushViewController:vc animated:YES];
         }
         //到重新核保页
         else {
             InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
             infoVC.insModel.simpleCar = car;
             infoVC.insModel.originVC = self;
             [self.navigationController pushViewController:infoVC animated:YES];
         }
    }];
}

- (void)resetAddCarCell:(UITableViewCell *)cell withData:(HKCellData *)data
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
         [MobClick event:@"rp1000-3"];
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
            InsSimpleCar *car = [[InsSimpleCar alloc] init];
            car.licenseno = licenseno;
            [self actionInputOwnerNameForSimpleCar:car];
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
                          curRows:@[@([provinces indexOfObject:curProvince])]] map:^id(NSArray *result) {
        return [result safetyObjectAtIndex:0];
    }];
}

@end
