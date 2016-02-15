//
//  InsCheckFailVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/21.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsCheckFailVC.h"
#import "HKCellData.h"
#import "NSString+RectSize.h"

#import "InsInputInfoVC.h"

@interface InsCheckFailVC ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation InsCheckFailVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"InsCheckFailVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Action
- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1004-1"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionMakeCall:(id)sender
{
    [MobClick event:@"rp1004-7"];
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"客服电话: 4007-111-111"];
}

///重新核保
- (IBAction)actionReUnderwrite:(id)sender
{
    InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
    infoVC.insModel = self.insModel;
    [self.navigationController pushViewController:infoVC animated:YES];
}
#pragma mark - Datasource
- (void)reloadData
{
    HKCellData *baseCell = [HKCellData dataWithCellID:@"Base" tag:nil];
    HKCellData *reasonCell = [HKCellData dataWithCellID:@"Reason" tag:nil];
    @weakify(self);
    [reasonCell setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(self);
        CGSize lbsize = [self.errmsg labelSizeWithWidth:tableView.frame.size.width - 44 font:[UIFont systemFontOfSize:14]];
        return MAX(44, ceil(lbsize.height) + 70);
    }];
    self.datasource = @[baseCell, reasonCell];
}

#pragma mark - UITableViewDelegate and datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 310;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Reason" tag:nil]) {
        [self resetReasonCell:cell forData:data];
    }
    
    return cell;
}

#pragma mark - Cell
- (void)resetReasonCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *label = [cell viewWithTag:1002];
    label.text = self.errmsg;
}

@end
