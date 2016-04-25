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
#import "CKDatasource.h"
#import "NSString+RectSize.h"
#import <MZFormSheetController.h>
#import "InsuranceStore.h"
#import "HKLoadingModel.h"
#import "NSString+Split.h"
#import "CKLimitTextField.h"
#import "UIView+Shake.h"
#import "InsuranceVM.h"
#import "MyCarStore.h"
#import "IQKeyboardManager.h"
#import "OETextField.h"
#import "DeleteInsCarOp.h"

#import "InsInputNameVC.h"
#import "InsInputInfoVC.h"
#import "InsCheckResultsVC.h"
#import "InsuranceOrderVC.h"
#import "PickerVC.h"

@interface InsuranceVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) InsuranceStore *insStore;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) InsuranceVM *insModel;
@property (nonatomic, strong) CKDict *addCarItem;

@end

@implementation InsuranceVC

- (void)awakeFromNib
{
    self.insModel = [[InsuranceVM alloc] init];
    self.insModel.originVC = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupADView];
    [self setupInsStore];
    [[self.insStore getInsSimpleCars] send];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"InsuranceVC dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].disableSpecialCaseForScrollView = YES;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 50;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].disableSpecialCaseForScrollView = NO;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 10;
}

- (void)setupADView
{
    CKAsyncMainQueue(^{
        self.advc = [ADViewController vcWithADType:AdvertisementInsurance boundsWidth:self.view.frame.size.width
                                          targetVC:self mobBaseEvent:@"rp114_3" mobBaseEventDict:nil];
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
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
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
    self.datasource = $([self promptItem], CKJoin([self carItemList]), self.isEditing ? CKNULL : [self addCarItem]);
    [self.tableView reloadData];
    [self resetRightNavigationItemWithHidden:![self checkInsCarsEditable]];
    [self.view endEditing:YES];
}

#pragma mark - Request
- (void)requestDeleteInsCarWithData:(CKDict *)data
{
    InsSimpleCar *car = data[@"car"];
    DeleteInsCarOp *op = [DeleteInsCarOp operation];
    op.req_carpremiumid = car.carpremiumid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在删除..."];
    }] subscribeNext:^(id x) {
    
        @strongify(self);
        [gToast showSuccess:@"删除成功"];
        [self deleteItem:data];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - Cell Items
- (CKDict *)promptItem
{
    CKDict *item = [CKDict dictWith:@{kCKCellID:@"Prompt", kCKItemKey:@"Prompt",
                                      @"title":@"请选择或添加一辆爱车，保险到期日前60天内，可进行核保。"}];
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        NSString *title = item[@"title"];
        CGSize fz = [title labelSizeWithWidth:self.tableView.frame.size.width - 28 font:[UIFont systemFontOfSize:13]];
        return ceil(fz.height) + 10;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath){
        UILabel *label = [cell.contentView viewWithTag:1001];
        label.text = data[@"title"];
        
    });
    return item;
}

- (NSArray *)carItemList
{
    NSMutableArray *cars = [NSMutableArray array];
    for (InsSimpleCar *car in self.insStore.simpleCars.allObjects) {
        [cars addObject:[self carItemWithInsCar:car]];
    }
    return cars;
}

- (CKDict *)carItemWithInsCar:(InsSimpleCar *)car
{
    CKDict *item = [CKDict dictWith:@{kCKCellID:@"Car", kCKItemKey:car.licenseno, @"car":car}];
    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        if (self.isEditing) {
            return ;
        }
        [self.view endEditing:YES];
        [MobClick event:@"rp1002_2"];
        InsSimpleCar *car = data[@"car"];
        if (car.status == 0 || [car.carpremiumid integerValue] == 0) {
            [self actionInputOwnerNameForSimpleCar:car];
        }
        //核保记录
        else if (car.status == 2) {
            InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
            vc.insModel = [self.insModel copy];
            vc.insModel.simpleCar = car;
            [self.navigationController pushViewController:vc animated:YES];
        }
        //有保单
        else if (car.status == 1 || car.status == 4 || car.status == 5) {
            InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
            vc.insModel = [self.insModel copy];
            vc.orderID = car.refid;
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        //填写信息
        else {
            InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
            infoVC.insModel = [self.insModel copy];
            infoVC.insModel.simpleCar = car;
            [self.navigationController pushViewController:infoVC animated:YES];
        }
    });
    return item;
}

- (CKDict *)addCarItem
{
    if (!_addCarItem) {
        CKDict *item = [CKDict dictWith:@{kCKCellID:@"Add", kCKItemKey:@"Add"}];
        item[@"province"] = [self.insStore.insProvinces objectAtIndex:0];
        _addCarItem = item;
    }
    return _addCarItem;
}

#pragma mark - Action
- (void)actionRefresh:(id)sender
{
    [[self.insStore getInsSimpleCars] send];
}

- (void)actionInputOwnerNameForSimpleCar:(InsSimpleCar *)car
{
    [self.view endEditing:YES];
    InsInputNameVC *vc = [UIStoryboard vcWithId:@"InsInputNameVC" inStoryboard:@"Insurance"];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(270, 160) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    //取消
    [[[vc.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] take:1] subscribeNext:^(id x) {
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    //确定
    @weakify(vc, self);
    [[vc.ensureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(vc, self);
        if (vc.nameField.text.length != 0 )
        {
            [vc.nameField endEditing:YES];
            [sheet dismissAnimated:YES completionHandler:nil];
            
            InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
            infoVC.insModel = [self.insModel copy];
            infoVC.insModel.realName = vc.nameField.text;
            infoVC.insModel.simpleCar = car;
            [self.navigationController pushViewController:infoVC animated:YES];
        }
        else
        {
            [vc.nameField shake];
        }
        
    }];
}

#pragma mark - Edit
- (BOOL)checkInsCarsEditable
{
    for (CKDict *data in self.datasource.allObjects) {
        InsSimpleCar *car = data[@"car"];
        if ([self isInsCarEditable:car]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isInsCarEditable:(InsSimpleCar *)car
{
    int status = car.status;
    return [car.carpremiumid integerValue] > 0 && (status == 0 || status == 2 || status == 3);
}

- (void)deleteItem:(CKDict *)item
{
    NSInteger index = [self.datasource indexOfObjectForKey:item.key];
    [self.datasource removeObjectAtIndex:index];
    NSIndexSet *indexSet1 = [NSIndexSet indexSetWithIndex:index];
    NSIndexSet *indexSet2;

    if (![self checkInsCarsEditable]) {
        [self.datasource addObject:[self addCarItem] forKey:nil];
        indexSet2 = [NSIndexSet indexSetWithIndex:self.datasource.count-1];
        [self endEditing];
    }
    
    [self.tableView beginUpdates];
    [self.tableView deleteSections:indexSet1 withRowAnimation:UITableViewRowAnimationAutomatic];
    if (indexSet2) {
        [self.tableView insertSections:indexSet2 withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}

- (void)endEditing
{
    self.isEditing = NO;
    if (![self.datasource objectForKey:@"Add"]) {
        [self.datasource addObject:self.addCarItem forKey:@"Add"];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:self.datasource.count-1];
        [self.tableView beginUpdates];
        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    [self resetRightNavigationItemWithHidden:![self checkInsCarsEditable]];
}

- (void)beginEditing
{
    self.isEditing = YES;
    NSInteger index = [self.datasource indexOfObjectForKey:@"Add"];
    if (index != NSNotFound) {
        [self.datasource removeObjectAtIndex:index];
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    [self resetRightNavigationItemWithHidden:NO];
}

- (void)resetRightNavigationItemWithHidden:(BOOL)hidden
{
    if (!hidden) {
        if (self.isEditing) {
            self.navigationItem.rightBarButtonItem = [self barButtonItemWithTitle:@"取消" selector:@selector(endEditing)];
        }
        else {
            self.navigationItem.rightBarButtonItem = [self barButtonItemWithTitle:@"编辑" selector:@selector(beginEditing)];
        }
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title selector:(SEL)selector
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setTitleColor:kDefTintColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *item = self.datasource[indexPath.section];
    if (item[kCKCellSelected]) {
        CKCellSelectedBlock block = item[kCKCellSelected];
        block(item, indexPath);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.datasource[indexPath.section];
    if (item[kCKCellGetHeight]) {
        CKCellGetHeightBlock block = item[kCKCellGetHeight];
        return block(item, indexPath);
    }
    return 73;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
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
    CKDict *item = self.datasource[indexPath.section];
    NSString *cellid = item[kCKCellID];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    if (item[kCKCellPrepare]) {
        CKCellPrepareBlock block = item[kCKCellPrepare];
        block(item, cell, indexPath);
    }
    if ([@"Add" isEqualToString:cellid]) {
        [self resetAddCarCell:cell withData:item];
    }
    else if ([@"Car" isEqualToString:cellid]) {
        [self resetCarCell:cell withData:item];
    }
    return cell;
}

#pragma mark - Cell
- (void)resetCarCell:(UITableViewCell *)cell withData:(CKDict *)data
{
    UILabel *numberL = [cell viewWithTag:1001];
    UIButton *rightB = [cell viewWithTag:1002];
    UIImageView *arrowV = [cell viewWithTag:1003];
    UIButton *trashB = [cell viewWithTag:1004];
    
    InsSimpleCar *car = data[@"car"];
    
    @weakify(self);
    [[[RACObserve(self, isEditing) distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        arrowV.hidden = self.isEditing;
        trashB.hidden = !(self.isEditing && [self isInsCarEditable:car]);
        rightB.hidden = self.isEditing || (car.status != 1 && car.status != 2);
    }];

    [[[trashB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
        @strongify(self);
        [self requestDeleteInsCarWithData:data];
    }];
    
    NSString *licenseno = [car.licenseno splitByStep:2 replacement:@" " count:1];
    NSString *statusdesc = [self.insModel simpleCarStatusDesc:car.status];
    licenseno = statusdesc ? [licenseno append:@"\n"] : licenseno;
    
    NSMutableAttributedString *attstr = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSForegroundColorAttributeName: kDarkTextColor,
                            NSFontAttributeName: [UIFont systemFontOfSize:17]};
    [attstr appendAttributedString:[[NSAttributedString alloc] initWithString:licenseno attributes:attr1]];
    if (statusdesc) {
        NSDictionary *attr2 = @{NSForegroundColorAttributeName: kGrayTextColor,
                                NSFontAttributeName: [UIFont systemFontOfSize:12]};
        [attstr appendAttributedString:[[NSAttributedString alloc] initWithString:statusdesc attributes:attr2]];
    }
    numberL.attributedText = attstr;

//#if DEBUG
//    rightB.hidden = car.status == 0 || car.status == 3;
//#endif
    [rightB setTitle:car.status == 1 ? @"核保结果" : @"重新核保" forState:UIControlStateNormal];

    [[[rightB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {

         @strongify(self);
         [MobClick event:@"rp1001_1"];
         //到核保结果页
         if (car.status == 1) {
             InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
             vc.insModel = [self.insModel copy];
             vc.insModel.simpleCar = car;
             [self.navigationController pushViewController:vc animated:YES];
         }
         //到重新核保页
         else {
             InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
             infoVC.insModel = [self.insModel copy];
             infoVC.insModel.simpleCar = car;
             [self.navigationController pushViewController:infoVC animated:YES];
         }
    }];
}

- (void)resetAddCarCell:(UITableViewCell *)cell withData:(CKDict *)data
{
    UILabel *provinceL = [cell viewWithTag:10011];
    UIButton *provinceB = [cell viewWithTag:10013];
    OETextField *textF = [cell viewWithTag:1002];
    UIButton *addB = [cell viewWithTag:1003];
    
    [textF setNormalInputAccessoryViewWithDataArr:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];
    
    Area *province = data[@"province"];
    provinceL.text = province.abbr;
    
    @weakify(self);
    [[[provinceB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         @strongify(self);
         [MobClick event:@"rp1000_3"];
         [self.view endEditing:YES];
         if (self.insStore.insProvinces.count == 1) {
             Area *province = [self.insStore.insProvinces objectAtIndex:0];
             [gToast showText:[NSString stringWithFormat:@"当前只支持%@", province.name]];
         }
         else if (self.insStore.insProvinces.count > 0) {
             [[self pickProvinceFrom:[self.insStore.insProvinces allObjects] curProvince:data[@"province"]]
              subscribeNext:^(Area *curProvince) {
                  data[@"province"] = curProvince;
                  provinceL.text = curProvince.abbr;
              }];
         }
     }];
    
    textF.textLimit = 6;
    textF.text = data[@"suffix"];
    
    [textF setDidBeginEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = nil;
    }];
    
    [textF setDidEndEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = @"A12345";
    }];
    
    [textF setTextDidChangedBlock:^(CKLimitTextField *field) {
        field.text = [field.text uppercaseString];
        data[@"suffix"] = field.text;
    }];
    
    [[[addB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.view endEditing:YES];
        NSString *prefix = [(Area *)data[@"province"] abbr];
        NSString *licenseno = [prefix append:data[@"suffix"]];
        data[@"licenseno"] = licenseno;
        if (![MyCarStore verifiedLicenseNumberFrom:licenseno]) {
            [gToast showText:@"请输入正确的车牌号码"];
            return ;
        }
        
        InsSimpleCar *car = [[self.insStore.simpleCars allObjects] firstObjectByFilteringOperator:^BOOL(InsSimpleCar *acar) {
            return [acar.licenseno isEqualToString:licenseno];
        }];
        if (car) {
            [gToast showText:@"该车牌已经存在，不能重复输入"];
            return;
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
