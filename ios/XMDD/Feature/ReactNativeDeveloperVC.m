//
//  ReactNativeDeveloperVC.m
//  XMDD
//
//  Created by jiangjunchen on 16/11/2.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactNativeDeveloperVC.h"
#import "CKDatasource.h"
#import "ReactNativeManager.h"

@interface ReactNativeDeveloperVC ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ReactNativeDeveloperVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"React Native设置";
    [self setupTableView];
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = kBackgroundColor;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)reloadDatasource {
    self.datasource = $($(@{@"title": @"打开React Native", kCKItemKey: kReactNativeSwitchForceOpen},
                          @{@"title": @"关闭React Native", kCKItemKey: kReactNativeSwitchForceClose},
                          @{@"title": @"自动开关React Native", kCKItemKey: kReactNativeSwitchAuto}));
    [self.tableView reloadData];
}

- (CKDict *)currentSelectItem {
    NSString *switchType = [[NSUserDefaults standardUserDefaults] objectForKey:kReactNativeSwitchType];
    CKDict *item = self.datasource[0][switchType];
    if (!item) {
        item = self.datasource[0][kReactNativeSwitchAuto];
    }
    return item;
}

- (void)selectItem:(CKDict *)item {
    CKDict *oldItem = [self currentSelectItem];
    if (![item isEqual:oldItem]) {
        [[NSUserDefaults standardUserDefaults] setObject:item[kCKItemKey] forKey:kReactNativeSwitchType];
        oldItem.forceReload = !oldItem.forceReload;
        item.forceReload = !item.forceReload;
    }
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"开关设置";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    cell.textLabel.text = item[@"title"];
    
    @weakify(self);
    [[RACObserve(item, forceReload) takeUntilForCell:cell] subscribeNext:^(id x) {
        @strongify(self);
        CKDict *selectItem = [self currentSelectItem];
        cell.accessoryType = [item isEqual:selectItem] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    [self selectItem:item];
}

@end
