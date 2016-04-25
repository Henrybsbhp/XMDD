//
//  HistoryCollectionVC.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/17.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "HistoryCollectionVC.h"
#import "HistoryCollectionOp.h"
#import "HistoryDeleteOp.h"
#import "NSDate+DateForText.h"
#import "UIImageView+WebImage.h"
#import "NSString+Price.h"

@interface HistoryCollectionVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *selectedAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *deleteArr;

@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,assign) BOOL isExist;
@property (nonatomic,assign) BOOL isLoading;

@end

@implementation HistoryCollectionVC


-(void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"HistoryCollectionVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  初始化是否存在，是否正在加载，是否在编辑
     */
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.estimatedRowHeight = 44;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    self.isExist = YES;
    self.isLoading = NO;
    self.isEditing = NO;
    
    [self.deleteBtn makeCornerRadius:5];
    [self refreshBottomView];
    [self setupNavi];
    [self requestValuationHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark TableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.isEditing)
    {
        cell = [self tableView:tableView editValuationCellForRowAtIndexPath:indexPath];
    }
    else
    {
        cell = [self tableView:tableView valuationCellForRowAtIndexPath:indexPath];
    }
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView valuationCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"valuationCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *model = [self.dataArr safetyObjectAtIndex:indexPath.section];
    UILabel *licenseNo = (UILabel *)[cell searchViewWithTag:1000];
    UIImageView *imgView = (UIImageView *)[cell searchViewWithTag:1001];
    UILabel *modelName = (UILabel *)[cell viewWithTag:1002];
    UILabel *mile = (UILabel *)[cell searchViewWithTag:1003];
    UILabel *price = (UILabel *)[cell searchViewWithTag:1004];
    UILabel *evaluateTime = (UILabel *)[cell searchViewWithTag:1005];
    UILabel *evaluateZone = (UILabel *)[cell searchViewWithTag:1006];
    licenseNo.text = model[@"licenseNo"];
    modelName.text = model[@"modelname"];
    modelName.preferredMaxLayoutWidth = self.view.bounds.size.width - 100;
    mile.text = [NSString stringWithFormat:@"%@万公里",[NSString formatForPrice:[model floatParamForName:@"mile"]]];
    price.text=[NSString stringWithFormat:@"%@万元",[NSString formatForPrice:[model floatParamForName:@"price"]]];
    evaluateTime.text = [NSString stringWithFormat:@"%@",[[NSDate dateWithUTS:model[@"evaluatetime"]]dateFormatForYYYYMMddHHmm2]];
    evaluateZone.text = model[@"evaluatezone"];
    [imgView setImageByUrl:model[@"logo"] withType:ImageURLTypeThumbnail defImage:@"avatar_default" errorImage:@"avatar_default"];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView editValuationCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editValuationCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *model = [self.dataArr safetyObjectAtIndex:indexPath.section];
    UILabel *licenseNo = (UILabel *)[cell searchViewWithTag:1000];
    UIImageView *imgView = (UIImageView *)[cell searchViewWithTag:1001];
    UILabel *modelName = (UILabel *)[cell searchViewWithTag:1002];
    UILabel *mile = (UILabel *)[cell searchViewWithTag:1003];
    UILabel *price = (UILabel *)[cell searchViewWithTag:1004];
    UILabel *evaluateTime = (UILabel *)[cell searchViewWithTag:1005];
    UILabel *evaluateZone = (UILabel *)[cell searchViewWithTag:1006];
    UIButton *checkBtn = (UIButton *)[cell searchViewWithTag:1007];
    
    licenseNo.text = model[@"licenseNo"];
    modelName.text = model[@"modelname"];
    modelName.preferredMaxLayoutWidth = self.view.bounds.size.width - 100;
    mile.text = [NSString stringWithFormat:@"%@万公里",[NSString formatForPrice:[model floatParamForName:@"mile"]]];
    price.text=[NSString stringWithFormat:@"%@万元",[NSString formatForPrice:[model floatParamForName:@"price"]]];
    evaluateTime.text = [NSString stringWithFormat:@"%@",[[NSDate dateWithUTS:model[@"evaluatetime"]]dateFormatForYYYYMMddHHmm2]];
    evaluateZone.text = model[@"evaluatezone"];
    
    
    @weakify(checkBtn)
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(checkBtn)
        BOOL isExsit = [self.deleteArr containsObject:model];
        if (isExsit)
        {
            [self.deleteArr safetyRemoveObject:model];
            [checkBtn setSelected:NO];
        }
        else
        {
            [self.deleteArr safetyAddObject:model];
            [checkBtn setSelected:YES];
        }
    }];
    
    
    checkBtn.selected = [self.deleteArr containsObject:model];
    
    [imgView setImageByUrl:model[@"logo"] withType:ImageURLTypeThumbnail defImage:@"avatar_default" errorImage:@"avatar_default"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        return UITableViewAutomaticDimension;
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return ceil(size.height+1);
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArr.count -1 > indexPath.section)
    {
        return;
    }
    else if(self.isExist && !self.isLoading)
    {
        [self loadMoreData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    UIButton *checkBtn=(UIButton *)[cell searchViewWithTag:1007];
    checkBtn.selected=!checkBtn.isSelected;
    if (checkBtn.isSelected)
    {
        [self.deleteArr safetyAddObject:self.dataArr[indexPath.section]];
        
    }
    else
    {
        [self.deleteArr safetyRemoveObject:self.dataArr[indexPath.section]];
    }
    self.selectedAllBtn.selected = (self.dataArr.count == self.deleteArr.count);
}

#pragma  mark setupUI


-(void)edit:(UIBarButtonItem *)sender
{
    /**
     *  编辑事件
     */
    [MobClick event:@"rp603_1"];
    self.isEditing = !self.isEditing;
    
    if (self.dataArr.count == 0)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:(self.isEditing ? @"完成":@"编辑")];
        [self refreshBottomView];
    }
    
    [self.deleteArr removeAllObjects];
    [self reloadData];
}

-(void)reloadData
{
    if (self.dataArr.count == 0)
    {
        self.isEditing = NO;
        self.tableView.showBottomLoadingView = NO;
        self.navigationItem.rightBarButtonItem = nil;
        [self refreshBottomView];
        self.tableView.hidden = YES;
        [self.view showImageEmptyViewWithImageName:@"def_withoutValuationHistory" text:@"暂无估值记录"];
    }
    else
    {
        self.tableView.hidden = NO;
        [self.view hideDefaultEmptyView];
    }
    /**
     *  保证在清空历史的时候也能进行一次reloadData操作
     */
    [self.tableView reloadData];
    
}

- (void)setupNavi
{
    if (self.dataArr.count == 0)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
        
        //        [rightBtn setTitleTextAttributes:@{
        //                                           NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0]
        //                                           } forState:UIControlStateNormal];
        [self.navigationItem setRightBarButtonItem:rightBtn animated:YES]; //防抖动
    }
}

-(void)refreshBottomView
{
    CGFloat offsetY = 0;
    if (self.isEditing)
    {
        offsetY = -60;
        
    }
    else
    {
        offsetY = 0;
    }
    [UIView animateWithDuration:0.5f animations:^{
        
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.view.mas_bottom).offset(offsetY);
            make.height.mas_equalTo(60);
        }];
    }];
    /**
     *  更新界面约束。避免出现卡顿一下的情况
     */
    [self.view layoutIfNeeded];
}



#pragma mark Network

-(void)loadMoreData
{
    HistoryCollectionOp *op = [HistoryCollectionOp new];
    NSDictionary *model = self.dataArr.lastObject;
    op.req_evaluateTime =model[@"evaluatetime"];
    
    [[[op rac_postRequest]initially:^{
        
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
        self.isLoading = YES;
    }]subscribeNext:^(HistoryCollectionOp *op) {
        
        self.isLoading = NO;
        
        self.isExist = (op.rsp_dataArr.count >= 10 ? YES : NO);
        [self.dataArr safetyAddObjectsFromArray:op.rsp_dataArr];
        
        
        [self.tableView.bottomLoadingView stopActivityAnimation];
        
        if (!self.isExist && self.dataArr.count != 0)
        {
            self.tableView.showBottomLoadingView = YES;
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        self.isLoading = NO;
    }];
}


-(void)requestValuationHistory
{
    HistoryCollectionOp *op = [HistoryCollectionOp new];
    op.req_evaluateTime = @(0);
    
    [[[op rac_postRequest] initially:^{
        
        self.isLoading = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }]  subscribeNext:^(HistoryCollectionOp *op) {
        
        self.isLoading = NO;
        [self.view stopActivityAnimation];
        
        self.dataArr = [NSMutableArray arrayWithArray:op.rsp_dataArr];
        if (self.dataArr.count == 0)
        {
            self.tableView.showBottomLoadingView = YES;
            [self.tableView.bottomLoadingView hideIndicatorText];
            self.tableView.hidden = YES;
            [self.view showImageEmptyViewWithImageName:@"def_withoutValuationHistory" text:@"暂无估值记录"];
        }
        else
        {
            self.tableView.hidden = NO;
            [self.view hideDefaultEmptyView];
            if (op.rsp_dataArr.count >= 10)
            {
                self.isExist = YES;
                [self.tableView.bottomLoadingView hideIndicatorText];
            }
            else
            {
                self.isExist = NO;
            }
        }
        [self.tableView reloadData];
        [self setupNavi];
        
    } error:^(NSError *error) {
        
        self.isLoading = NO;
        [self.view stopActivityAnimation];
        
        @weakify(self)
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"估值记录获取失败，请点击屏幕重试" tapBlock:^{
            @strongify(self);
            [self requestValuationHistory];
        }];
    }];
}





-(void)uploadDeletaArr:(NSString *)deleteStr
{
    HistoryDeleteOp *deleteOp = [HistoryDeleteOp new];
    deleteOp.req_evaluateIds = deleteStr;
    [[[deleteOp rac_postRequest] initially:^{
        [gToast showingWithText:@""];
    }] subscribeNext:^(id x) {
        
        [gToast dismiss];
        
        if (![deleteStr isEqualToString:@"all"])
        {
            for (NSDictionary *dic in self.deleteArr)
            {
                [self.dataArr safetyRemoveObject:dic];
            }
        }
        else
        {
            [self.dataArr removeAllObjects];
        }
        [self.deleteArr removeAllObjects];
        [self reloadData];
    }error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
    
}

#pragma mark LazyLoad

-(NSMutableArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr = [NSMutableArray new];
    }
    return _dataArr;
}

-(NSMutableArray *)deleteArr
{
    if (!_deleteArr)
    {
        _deleteArr = [NSMutableArray new];
    }
    return _deleteArr;
}

#pragma mark BottomViewButtonAction

- (IBAction)delete:(id)sender {
    /**
     *  删除事件
     */
    [MobClick event:@"rp603_3"];
    if (self.deleteArr.count)
    {
        NSMutableArray *deleteStrArr = [NSMutableArray new];
        for (NSDictionary *dic in self.deleteArr)
        {
            [deleteStrArr safetyAddObject:dic[@"evaluateid"]];
        }
        NSString *deleteStr = [deleteStrArr componentsJoinedByString:@","];
        [self uploadDeletaArr:deleteStr];
    }
    else
    {
        [gToast showError:@"请选中要删除的估值记录"];
    }
}


- (IBAction)selectAll:(id)sender {
    /**
     *  清空事件
     */
    self.selectedAllBtn.selected = YES;
    [MobClick event:@"rp603_2"];
    
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
        self.selectedAllBtn.selected = NO;
    }];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [self uploadDeletaArr:@"all"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否清空估值记录" ActionItems:@[cancel,confirm]];
    [alert show];
}
@end
