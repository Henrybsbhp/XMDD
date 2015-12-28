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
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet JTTableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *selectedAllBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic,strong) NSMutableIndexSet *deleteSet;
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
}


- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  初始化是否存在，是否正在加载，是否在编辑
     */
    self.isExist=YES;
    self.isLoading=NO;
    self.isEditing = NO;
    [self getDataArr];
    if (self.dataArr.count > 0)
    {
        [self setupNavi];
    }
    [self.deleteBtn makeCornerRadius:5];
    [self refreshBottomView];
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
    }
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
    modelName.preferredMaxLayoutWidth = self.view.bounds.size.width - 50;
    mile.text = [NSString stringWithFormat:@"%@万公里",[NSString formatForPrice:[model floatParamForName:@"mile"]]];
    price.text=[NSString stringWithFormat:@"%@万元",[NSString formatForPrice:[model floatParamForName:@"price"]]];
    evaluateTime.text = [NSString stringWithFormat:@"%@",[[NSDate dateWithUTS:model[@"evaluatetime"]]dateFormatForYYYYMMddHHmm]];
    evaluateZone.text = model[@"evaluatezone"];
    [imgView setImageByUrl:model[@"logo"] withType:ImageURLTypeThumbnail defImage:@"avatar_default" errorImage:@"avatar_default"];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView editValuationCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editValuationCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
    modelName.preferredMaxLayoutWidth = self.view.bounds.size.width - 50;
    mile.text = [NSString stringWithFormat:@"%@万公里",[NSString formatForPrice:[model floatParamForName:@"mile"]]];
    price.text=[NSString stringWithFormat:@"%@万元",[NSString formatForPrice:[model floatParamForName:@"price"]]];
    evaluateTime.text = [NSString stringWithFormat:@"%@",[[NSDate dateWithUTS:model[@"evaluatetime"]]dateFormatForYYYYMMddHHmm]];
    evaluateZone.text = model[@"evaluatezone"];
    @weakify(self);
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        checkBtn.selected=!checkBtn.isSelected;
        if (checkBtn.isSelected)
        {
            [self.deleteArr safetyAddObject:self.dataArr[indexPath.section]];
        }
        else
        {
            [self.deleteArr safetyRemoveObject:self.dataArr[indexPath.section]];
        }
    }];
    checkBtn.selected = [self.deleteArr containsObject:model]?YES:NO;
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
    if (self.dataArr.count-1 > indexPath.section)
    {
        return;
    }
    else if(self.isExist&&!self.isLoading)
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

- (void)setupNavi
{
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0]
                                                                     } forState:UIControlStateNormal];
    
}

-(void)edit:(UIBarButtonItem *)sender
{
    /**
     *  编辑事件
     */
    [MobClick event:@"rp603-1"];
    self.isEditing = !self.isEditing;
    
    [self.navigationItem.rightBarButtonItem setTitle:(self.isEditing ? @"完成":@"编辑")];
    [self refreshBottomView];
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
        [self.tableView showDefaultEmptyViewWithText:@"暂无估值记录"];
    }
    else
    {
        [self.tableView hideDefaultEmptyView];
    }
    /**
     *  保证在清空历史的时候也能进行一次reloadData操作
     */
    [self.tableView reloadData];
    
}

-(void)refreshBottomView
{
    CGFloat offsetY = 0;
    if (self.isEditing)
    {
        offsetY = -50;
        
    }
    else
    {
        offsetY = 0;
    }
    [UIView animateWithDuration:0.5f animations:^{
        
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.view.mas_bottom).offset(offsetY);
            make.height.mas_equalTo(50);
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
    @weakify(self);
    [[[op rac_postRequest]initially:^{
        @strongify(self);
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
        self.isLoading = YES;
    }]subscribeNext:^(HistoryCollectionOp *op) {
        @strongify(self);
        [self.dataArr safetyAddObjectsFromArray:op.rsp_dataArr];
        [self.tableView.bottomLoadingView stopActivityAnimation];
        self.isLoading = NO;
        self.isExist = (op.rsp_dataArr.count == 10?YES:NO);
        if (!self.isExist && self.dataArr.count != 0)
        {
            self.tableView.showBottomLoadingView = YES;
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
        }
        [self.tableView reloadData];
    }];
}


-(void)getDataArr
{
    HistoryCollectionOp *op=[HistoryCollectionOp new];
    op.req_evaluateTime=@(0);
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
        @strongify(self);
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        @strongify(self);
        [self.view stopActivityAnimation];
    }] subscribeNext:^(HistoryCollectionOp *op) {
        @strongify(self);
        [self.dataArr safetyAddObjectsFromArray:op.rsp_dataArr];
        [self reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        [self.view showDefaultEmptyViewWithText:@"估值记录获取失败，请点击屏幕重试" tapBlock:^{
            @strongify(self);
            [self getDataArr];
        }];
    }];
}





-(void)uploadDeletaArr:(NSString *)deleteStr
{
    HistoryDeleteOp *deleteOp = [HistoryDeleteOp new];
    deleteOp.req_evaluateIds = deleteStr;
    @weakify(self);
    [[deleteOp rac_postRequest]subscribeNext:^(id x) {
        //仅触发信号
    }error:^(NSError *error) {
        [gToast showError:error.domain];
    }completed:^{
        @strongify(self);
        for (NSDictionary *dic in self.deleteArr)
        {
            
            [self.dataArr safetyRemoveObject:dic];
        }
        [self reloadData];
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
    [MobClick event:@"rp603-3"];
    if (self.deleteArr.count)
    {
        NSMutableArray *deleteStrArr = [NSMutableArray new];
        for (NSDictionary *dic in self.deleteArr)
        {
            [deleteStrArr safetyAddObject:dic[@"evaluateid"]];
        }
        NSString *deleteStr = [deleteStrArr componentsJoinedByString:@","];
        [self uploadDeletaArr:deleteStr];
        [self.deleteArr removeAllObjects];
    }
    else
    {
        [gToast showError:@"请选中要删除的估值记录"];
    }
    [self reloadData];
}


- (IBAction)selectAll:(id)sender {
    /**
     *  清空事件
     */
    [MobClick event:@"rp603-2"];
    [self.deleteArr removeAllObjects];
    [self.deleteArr safetyAddObjectsFromArray:self.dataArr];
    [self.tableView reloadData];
    UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:@"请确认是否清空估值记录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alerView show];
    [[alerView rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
        if (index.integerValue == 1)
        {
            [self uploadDeletaArr:@"all"];
            [self.dataArr removeAllObjects];
        }
        [self.deleteArr removeAllObjects];
        [self reloadData];
    }];
}

#pragma mark Utility


@end
