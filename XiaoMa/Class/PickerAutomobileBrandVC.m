//
//  PickerAutomobileBrandVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PickerAutomobileBrandVC.h"
#import "PickerAutoSeriesVC.h"
#import "AutoInfoModel.h"

@interface PickerAutomobileBrandVC ()<UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AutoInfoModel *autoModel;
@property (nonatomic, strong) NSFetchedResultsController *fetchCtrl;
@end

@implementation PickerAutomobileBrandVC
- (void)awakeFromNib
{
    self.autoModel = [AutoInfoModel new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fetchCtrl = [self.autoModel createAutoBrandFetchCtrl];
    self.fetchCtrl.delegate = self;
    [self.tableView.refreshView addTarget:self action:@selector(reloadDatasource) forControlEvents:UIControlEventValueChanged];
    [self reloadDatasource];
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

- (void)reloadDatasource
{
    [self.fetchCtrl performFetch:nil];
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
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchCtrl sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchCtrl sections] objectAtIndex:section];
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
    [[[gAppMgr.mediaMgr rac_getPictureForUrl:brand.logo withType:ImageURLTypeOrigin defaultPic:@"cm_logo_def" errorPic:@"cm_logo_def"]
      takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        logoV.image = x;
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AutoBrand *brand = [self.fetchCtrl objectAtIndexPath:indexPath];
    PickerAutoSeriesVC *vc = [UIStoryboard vcWithId:@"PickerAutoSeriesVC" inStoryboard:@"Mine"];
    vc.brandid = brand.brandid;
    vc.brandName = brand.name;
    vc.originVC = self.originVC;
    vc.completed = self.completed;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
