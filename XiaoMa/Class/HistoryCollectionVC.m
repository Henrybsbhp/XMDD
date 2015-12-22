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
    self.isExist=YES;
    self.isLoading=NO;
    [self getDataArr];
    if (self.dataArr.count > 0)
    {
        [self setupUI];
    }
    
    [self refreshBottomView];
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
    mile.text = [NSString stringWithFormat:@"%@万公里",model[@"mile"]];
    price.text=[NSString stringWithFormat:@"%@万元",model[@"price"]];
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
    mile.text=[NSString stringWithFormat:@"%@万公里",model[@"mile"]];
    price.text=[NSString stringWithFormat:@"%@万元",model[@"price"]];
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
        self.selectedAllBtn.selected = (self.dataArr.count == self.deleteArr.count);
    }];
    if ([self.deleteArr containsObject:model] || self.selectedAllBtn.selected)
    {
        checkBtn.selected = YES;
    }
    else
    {
        checkBtn.selected = NO;
    }
    [imgView setImageByUrl:model[@"logo"] withType:ImageURLTypeThumbnail defImage:@"avatar_default" errorImage:@"avatar_default"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
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



-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
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

- (void)setupUI
{
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0]
                                                                     } forState:UIControlStateNormal];
    self.isEditing = NO;
    [self.deleteBtn makeCornerRadius:5];
    
}

-(void)edit:(UIBarButtonItem *)sender
{
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
    self.selectedAllBtn.selected = NO;
    [self.deleteArr removeAllObjects];
    [self reloadData];
}

-(void)reloadData
{
    [self.tableView reloadData];
    if (self.dataArr.count == 0) {
        [self.tableView showDefaultEmptyViewWithText:@"暂无估值纪录"];
    }
    else {
        [self.tableView hideDefaultEmptyView];
    }
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
        self.isExist = (op.rsp_dataArr.count == 10)?YES:NO;
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
        if (self.dataArr.count == 0)
        {
            [self reloadData];
            self.navigationItem.rightBarButtonItem = nil;
        }
        else
        {
            [self.tableView reloadData];
        }
    } error:^(NSError *error) {
        @strongify(self);
        [self.view showDefaultEmptyViewWithText:@"网络请求失败，请点击屏幕重试" tapBlock:^{
            @strongify(self);
            [self getDataArr];
        }];
    }];
}





-(void)uploadDeletaArr
{
    HistoryDeleteOp *deleteOp = [HistoryDeleteOp new];
    NSMutableArray *deleteStrArr = [NSMutableArray new];
    for (NSDictionary *dic in self.deleteArr)
    {
        [deleteStrArr safetyAddObject:dic[@"evaluateid"]];
    }
    NSString *deleteStr = [deleteStrArr componentsJoinedByString:@","];
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
        if (self.dataArr.count == 0)
        {
            [self.tableView showDefaultEmptyViewWithText:@"暂无估值纪录"];
        }
        [self.tableView reloadData];
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
    if (self.deleteArr.count)
    {
        [self uploadDeletaArr];
        self.isEditing = NO;
        [self refreshBottomView];
        if (self.deleteArr.count == self.dataArr.count)
        {
            self.navigationItem.rightBarButtonItem = nil;
            [self.dataArr removeAllObjects];
            [self.deleteArr removeAllObjects];
            self.tableView.showBottomLoadingView=NO;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.title = @"编辑";
        }
        
    }
    else
    {
        [gToast showError:@"请选中要删除的估值记录"];
    }
    [self reloadData];
}


- (IBAction)selectAll:(id)sender {
    [self.deleteArr removeAllObjects];
    self.selectedAllBtn.selected =! self.selectedAllBtn.isSelected;
    [self.deleteArr safetyAddObjectsFromArray:self.dataArr];
    if (!self.selectedAllBtn.isSelected) {
        [self.deleteArr removeAllObjects];
    }
    [self.tableView reloadData];
}

#pragma mark Utility


@end
