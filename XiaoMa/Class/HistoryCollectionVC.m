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

@property (nonatomic,assign) BOOL isEditing;

@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *deleteArr;

@property (nonatomic,strong) NSMutableIndexSet *selectSet;

@property (nonatomic,assign) BOOL isExist;
@property (nonatomic,assign) BOOL isLoading;

@end

@implementation HistoryCollectionVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isExist=YES;
    self.isLoading=NO;
    [self getDataArr];
    [self setupUI];
    [self refreshBottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark tableViewDelegate

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
    DebugLog(@"%@",model);
    UILabel *licenseNo = (UILabel *)[cell searchViewWithTag:1000];
    UIImageView *imgView = (UIImageView *)[cell searchViewWithTag:1001];
    UILabel *modelName = (UILabel *)[cell viewWithTag:1002];
    UILabel *mile = (UILabel *)[cell searchViewWithTag:1003];
    UILabel *price = (UILabel *)[cell searchViewWithTag:1004];
    UILabel *evaluateTime = (UILabel *)[cell searchViewWithTag:1005];
    UILabel *evaluateZone = (UILabel *)[cell searchViewWithTag:1006];
    licenseNo.text = model[@"licenseNo"];
    modelName.text = model[@"modelname"];
    DebugLog(@"%@,%@",modelName.text,model[@"modelname"]);
    mile.text = [NSString stringWithFormat:@"%@万公里",model[@"mile"]];
//    price.text=model[@"price"];
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
//        price.text=model[@"price"];
    evaluateTime.text=[NSString stringWithFormat:@"%@",[[NSDate dateWithUTS:model[@"evaluatetime"]]dateFormatForYYYYMMddHHmm]];
    evaluateZone.text=model[@"evaluatezone"];
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

#pragma  mark UI

- (void)setupUI
{        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0]
                                                                     } forState:UIControlStateNormal];
    
    self.isEditing = NO;
    
    [self.deleteBtn makeCornerRadius:5];
}

-(void)edit:(UIBarButtonItem *)sender
{
    self.isEditing = !self.isEditing;
    
    [self refreshBottomView];
    
    [self.navigationItem.rightBarButtonItem setTitle:(self.isEditing ? @"完成":@"编辑")];
    if (self.dataArr.count == 0)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self reloadData];
}

-(void)reloadData
{
    [self.tableView reloadData];
    if (self.dataArr.count == 0) {
        [self.tableView showDefaultEmptyViewWithText:@"暂无估值记录"];
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



#pragma mark network

-(void)loadMoreData
{
    HistoryCollectionOp *op = [HistoryCollectionOp new];
    NSDictionary *model = self.dataArr.lastObject;
    op.req_evaluateTime =model[@"evaluatetime"];
    [[[op rac_postRequest]initially:^{
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
        self.isLoading = YES;
    }]subscribeNext:^(HistoryCollectionOp *op) {
        [self.dataArr addObjectsFromArray:op.rsp_dataArr];
        [self.tableView.bottomLoadingView stopActivityAnimation];
        self.isLoading = NO;
        self.isExist = (op.rsp_dataArr.count == 10)?YES:NO;
        if (!self.isExist)
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
    [[[[op rac_postRequest] initially:^{
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(HistoryCollectionOp *op) {
        [self.dataArr addObjectsFromArray:op.rsp_dataArr];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [self.tableView showDefaultEmptyViewWithText:@"网络请求失败。点击屏幕重新请求" tapBlock:^{
            [self getDataArr];
        }];
    }];
}





-(void)uploadDeletaArr
{
    HistoryDeleteOp *deleteOp=[HistoryDeleteOp new];
    NSString *deleteStr=[self.deleteArr componentsJoinedByString:@","];
    deleteOp.req_evaluateIds=deleteStr;
    [[deleteOp rac_postRequest]subscribeNext:^(id x) {
        //仅触发信号
    }error:^(NSError *error) {
        [gToast showError:@"error.domain"];
    }completed:^{
        [self.tableView showDefaultEmptyViewWithText:@"暂无估值记录"];
    }];
}

#pragma mark LazyLoad

-(NSMutableIndexSet *)selectSet
{
    if (!_selectSet)
    {
        _selectSet = [[NSMutableIndexSet alloc]init];
    }
    return _selectSet;
}

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

#pragma markBottomButtonAction

- (IBAction)delete:(id)sender {
    if (self.selectSet.count)
    {
        [self uploadDeletaArr];
    }
    else
    {
        [gToast showError:@"请选择一家商户进行删除"];
    }
}


- (IBAction)selectAll:(id)sender {
    
    if (self.selectSet.count == gAppMgr.myUser.favorites.favoritesArray.count)
    {
        [self.selectSet removeAllIndexes];
        [self.tableView reloadData];
        [self.selectedAllBtn setSelected:!self.selectedAllBtn.isSelected];
        return;
    }
    [self.selectSet removeAllIndexes];
    for (NSInteger i = 0 ; i < gAppMgr.myUser.favorites.favoritesArray.count ; i++)
    {
        [self.selectSet addIndex:i];
    }
    [self reloadData];
    [self.selectedAllBtn setSelected:!self.selectedAllBtn.isSelected];
}

@end
