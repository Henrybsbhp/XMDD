//
//  PickerAutomobileBrandVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PickAutomobileBrandVC.h"
#import "PickerAutoSeriesVC.h"
#import "AutoInfoModel.h"

@interface PickAutomobileBrandVC ()<UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AutoInfoModel *autoModel;
@property (nonatomic, strong) NSFetchedResultsController *fetchCtrl;
@end

@implementation PickAutomobileBrandVC
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.autoModel = [AutoInfoModel new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //数据迁移
    [self dataMigration];
    self.fetchCtrl = [self.autoModel createAutoBrandFetchCtrl];
    self.fetchCtrl.delegate = self;
    [self.tableView.refreshView addTarget:self action:@selector(reloadDatasource) forControlEvents:UIControlEventValueChanged];
    [self reloadDatasource];
}

- (void)dealloc
{
    self.fetchCtrl = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"PickAutomobileBrandVC dealloc");
}

//数据迁移
- (void)dataMigration
{
    //清除2.5版本之前的数据
    if ([gAppMgr.deviceInfo firstAppearAfterVersion:@"2.5" forKey:@"AutoBrand"]) {
        NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"AutoBrand"];
        [gAppMgr.defDataMgr deleteAllObjectsWithFetchRequest:req];
        [self.autoModel cleanAutoBrandTimetag];
    }
    //3.3版本替换了CoreData的数据库，需要重置时间戳
    else if ([gAppMgr.deviceInfo firstAppearAfterVersion:@"3.3" forKey:@"xmdd2"]) {
        [self.autoModel cleanAutoBrandTimetag];
    }
}

#pragma mark - Datasource
- (void)reloadDatasource
{
    [self.fetchCtrl performFetch:nil];
    if (!self.tableView.dataSource) {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    @weakify(self);
    [[[self.autoModel rac_updateAutoBrand] initially:^{
        @strongify(self);
        [self.tableView.refreshView beginRefreshing];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [gToast showError:error.domain];
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

#pragma mark - UITableViewDelegate And Dataousrce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchCtrl.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchCtrl sections] safetyObjectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchCtrl sections] safetyObjectAtIndex:section];
    return [sectionInfo indexTitle];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchCtrl sectionIndexTitles];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    AutoBrand *brand = [self.fetchCtrl objectAtIndexPath:indexPath];
    
    titleL.text = brand.name;
    [logoV setImageByUrl:brand.logo withType:ImageURLTypeThumbnail defImage:@"cm_logo_def" errorImage:@"cm_logo_def"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AutoBrand *brand = [self.fetchCtrl objectAtIndexPath:indexPath];
    PickerAutoSeriesVC *vc = [UIStoryboard vcWithId:@"PickerAutoSeriesVC" inStoryboard:@"Car"];
    AutoBrandModel * brandModel = [[AutoBrandModel alloc] init];
    brandModel.brandid = brand.brandid;
    brandModel.brandname = brand.name;
    brandModel.brandLogo = brand.logo;
    vc.brand = brandModel;
    vc.originVC = self.originVC;
    vc.completed = self.completed;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
