//
//  MutInsCalculateVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutInsCalculateVC.h"
#import "MutInsCalculateResultVC.h"
#import "GetCalculateBaseInfoOp.h"
#import "OutlayCalculateWithFrameNumOp.h"

#import "OETextField.h"
#import "NSString+RectSize.h"

@interface MutInsCalculateVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) CKList *dataSource;
@property (strong, nonatomic) NSArray *insuranceList;
@property (strong, nonatomic) NSArray *couponList;
@property (strong, nonatomic) NSArray *activityList;

@property (strong, nonatomic) NSString *frameNo;
@end

@implementation MutInsCalculateVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getCalculateBaseInfo];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network

-(void)getCalculateBaseInfo
{
    @weakify(self)
    GetCalculateBaseInfoOp *op = [GetCalculateBaseInfoOp operation];
    
    [[[op rac_postRequest]initially:^{
        @strongify(self)
        
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        
    }]subscribeNext:^(GetCalculateBaseInfoOp *op) {
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        
        CKList *list = [CKList list];
        [list addObjectsFromArray:@[[self textFieldCellData],[self btnCellData]]];
        NSMutableArray *tempArr = [[NSMutableArray alloc]init];
        [tempArr addObject:list];
        [self.dataSource addObjectsFromArray:tempArr];
        
        
        NSMutableArray *dataArray = [[NSMutableArray alloc]init];
        NSDictionary *dic = @{@"insurancelist":op.insuranceList,@"couponlist":op.couponList,@"activitylist":op.activityList};
        CKList *cellList = [CKList list];
        [cellList addObjectsFromArray:[self getCouponInfoWithData:dic]];
        [cellList addObjectsFromArray:@[[self setupBlankCell]]];
        [dataArray addObject:cellList];
        [self.dataSource addObjectsFromArray:dataArray];
        
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
    }];
}

-(void)calculateFrameNo
{
    @weakify(self)
    OutlayCalculateWithFrameNumOp *op = [OutlayCalculateWithFrameNumOp operation];
    
    op.frameNo = self.frameNo;
    
    [[[op rac_postRequest]initially:^{
        
        [gToast showingWithText:@"费用试算中..."];
        
    }]subscribeNext:^(OutlayCalculateWithFrameNumOp *op) {
        @strongify(self)
        
        [gToast dismiss];
        
        MutInsCalculateResultVC *vc = [UIStoryboard vcWithId:@"MutInsCalculateResultVC" inStoryboard:@"Temp"];
        vc.model = op;
        [self.navigationController pushViewController:vc animated:YES];
        
        
    } error:^(NSError *error) {
        
        NSString *errStr = error.domain;
        [gToast showMistake:errStr.length == 0 ? @"费用试算失败请重试" : errStr];
        
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CKList *cellList = self.dataSource[section];
    return cellList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID]];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block)
    {
        block(item, cell, indexPath);
    }
    
    return cell;
}

#pragma mark - CellData

-(CKDict *)textFieldCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"TextFieldCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    @weakify(self)
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self)
        
        UIButton *questionBtn = [cell viewWithTag:100];
        [[questionBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
            @strongify(self)
            
            [self showLicenseTips];
            
        }];
        
        OETextField *textField = [cell viewWithTag:101];
        [textField setNormalInputAccessoryViewWithDataArr:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];
        
        [textField setTextDidChangedBlock:^(CKLimitTextField *textField) {
            
            NSString *newtext = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            textField.text = [newtext uppercaseString];
            self.frameNo = textField.text;
            
        }];
    });
    return data;
}
-(CKDict *)btnCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"BtnCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 90;
    });
    @weakify(self)
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self)
        
        UIButton *calculateBtn = [cell viewWithTag:100];
        [[calculateBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
            @strongify(self)
            
            if ([self checkFrameNo])
            {
                [self calculateFrameNo];
            }
            
        }];
        
    });
    return data;
}

- (CKDict *)setupTipsHeaderCell
{
    CKDict *tipsHeaderCell = [CKDict dictWith:@{kCKItemKey: @"tipsHeaderCell", kCKCellID: @"TipsHeaderCell"}];
    tipsHeaderCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 35;
    });
    
    tipsHeaderCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return tipsHeaderCell;
}

- (CKDict *)setupTipsTitleCellWithText:(NSString *)title
{
    CKDict *tipsTitleCell = [CKDict dictWith:@{kCKItemKey: @"tipsTitleCell", kCKCellID: @"TipsTitleCell"}];
    tipsTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 30;
    });
    
    tipsTitleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        if ([title isEqualToString:@"保障"])
        {
            UIImage *image = [UIImage imageNamed:@"mins_ensure"];
            imageView.image = image;
        } else if ([title isEqualToString:@"福利"])
        {
            UIImage *image = [UIImage imageNamed:@"mins_benefit"];
            imageView.image = image;
        } else
        {
            UIImage *image = [UIImage imageNamed:@"mins_activity"];
            imageView.image = image;
        }
        
        titleLabel.text = title;
    });
    
    return tipsTitleCell;
}

- (CKDict *)setupTipsCellWithCouponList:(NSArray *)couponList
{
    CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"tipsCell", kCKCellID: @"TipsCell"}];
    tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 22;
    });
    
    tipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *firstImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UIImageView *secondImageView = (UIImageView *)[cell.contentView viewWithTag:103];
        UILabel *firstTipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *secondTipsLabel = (UILabel *)[cell.contentView viewWithTag:104];
        NSString *firstString = couponList[0];
        if (firstString.length > 0) {
            firstImageView.hidden = NO;
            firstTipsLabel.text = firstString;
        }
        
        if (couponList.count > 1) {
            NSString *secondString = couponList[1];
            secondImageView.hidden = NO;
            secondTipsLabel.text = secondString;
        } else {
            secondImageView.hidden = YES;
            secondTipsLabel.text = @"";
        }
    });
    
    return tipsCell;
}

- (CKDict *)setupSingleTipsCellWithCouponString:(NSString *)couponString
{
    CKDict *singleTipsCell = [CKDict dictWith:@{kCKItemKey: @"singleTipsCell", kCKCellID: @"SingleTipsCell"}];
    singleTipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [couponString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 93 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 22);
        
        return height;
    });
    
    singleTipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        tipsLabel.text = couponString;
    });
    
    return singleTipsCell;
}

- (CKDict *)setupBlankCell
{
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"blankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 15;
    });
    
    blankCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return blankCell;
}

#pragma mark - Utility


- (NSMutableArray *)getCouponInfoWithData:(NSDictionary *)data
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSArray *insuranceList = data[@"insurancelist"];
    if (insuranceList.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:insuranceList];
        CKDict *tipsHeaderCell = [self setupTipsHeaderCell];
        CKDict *insuranceTitleCell = [self setupTipsTitleCellWithText:@"保障"];
        [tempArray addObject:tipsHeaderCell];
        [tempArray addObject:insuranceTitleCell];
        for (NSArray *array in newArray) {
            CKDict *insuranceCell = [self setupTipsCellWithCouponList:array];
            [tempArray addObject:insuranceCell];
        }
    }
    
    NSArray *couponList = data[@"couponlist"];
    if (data.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:couponList];
        CKDict *couponTitleCell = [self setupTipsTitleCellWithText:@"福利"];
        [tempArray addObject:couponTitleCell];
        for (NSArray *array in newArray) {
            CKDict *couponCell = [self setupTipsCellWithCouponList:array];
            [tempArray addObject:couponCell];
        }
    }
    
    NSArray *activityList = data[@"activitylist"];
    if (activityList.count > 0) {
        CKDict *activityCell = [self setupTipsTitleCellWithText:@"活动"];
        [tempArray addObject:activityCell];
        for (NSString *string in activityList) {
            CKDict *activityCell = [self setupSingleTipsCellWithCouponString:string];
            [tempArray addObject:activityCell];
        }
    }
    
    return tempArray;
}

- (NSMutableArray *)splitArrayIntoDoubleNewArray:(NSArray *)array
{
    // Create our array of arrays
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    // Loop through all of the elements using a for loop
    for (int a = 0; a < array.count / 2 + 1; a++) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if (a * 2 < array.count) {
            id obj = [array objectAtIndex:a * 2];
            [tempArray addObject:obj];
        }
        
        if (a * 2 + 1 < array.count) {
            id obj2 = [array objectAtIndex:a * 2 + 1];
            [tempArray addObject:obj2];
        }
        [newArray addObject:tempArray];
    }
    return newArray;
}

-(void)showLicenseTips
{
    CGSize size = CGSizeMake(300, 200);
    UIViewController *vc = [[UIViewController alloc] init];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.cornerRadius = 0;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleFade;
    sheet.shouldDismissOnBackgroundViewTap = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    sheet.portraitTopInset = floor((self.view.frame.size.height - size.height) / 2);
    
    [sheet presentAnimated:YES completionHandler:nil];
    
    vc.view.backgroundColor = [UIColor clearColor];
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:vc.view.bounds];
    [vc.view addSubview:imgv];
    imgv.autoresizingMask = UIViewAutoresizingFlexibleAll;
    imgv.image = [UIImage imageNamed:@"common_carFrameNo_imageView"];
}

-(BOOL)checkFrameNo
{
    if ([self isHasZhhansCharacter:self.frameNo] == YES)
    {
        [gToast showMistake:@"请输入合法的车辆识别代号"];
        return NO;
    }
    
    if (self.frameNo.length == 0)
    {
        [gToast showMistake:@"请输入车辆识别代号"];
        return NO;
    }
    
    if (self.frameNo.length < 17)
    {
        [gToast showMistake:@"车辆识别代号位数不符合要求，请重新输入"];
        return NO;
    }
    return YES;
}

- (BOOL)isHasZhhansCharacter:(NSString *)aString
{
    NSInteger a;
    
    for (NSInteger i = 0; i < aString.length; i++)
    {
        a = [aString characterAtIndex:i];
        
        if (a >= 0x4e00 && a <= 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item[kCKCellGetHeight])
    {
        return ((CKCellGetHeightBlock)item[kCKCellGetHeight])(item, indexPath);
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 8;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}


#pragma mark - LazyLoad

-(CKList *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [[CKList alloc]init];
    }
    return _dataSource;
}



@end
