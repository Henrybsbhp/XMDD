//
//  PickerInsCompnaiesVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PickInsCompaniesVC.h"
#import "GetInsCompanyListOp.h"

#define kInsCompanyListKey     @"$InsCompanyList"

@interface PickInsCompaniesVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation PickInsCompaniesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    [self loadDefData];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    GetInsCompanyListOp *op = [GetInsCompanyListOp operation];
    @weakify(self);
    [[[[op rac_postRequest] initially:^{
        
        @strongify(self);
        [self.collectionView.refreshView beginRefreshing];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(GetInsCompanyListOp *op) {

        @strongify(self);
        [[NSUserDefaults standardUserDefaults] setObject:op.rsp_names forKey:kInsCompanyListKey];
        [self refreshViewWithDatasource:op.rsp_names];
    } error:^(NSError *error) {

        @strongify(self);
        [self refreshViewWithDatasource:self.datasource];
        [gToast showError:error.domain];
    }];
}

- (void)loadDefData
{
    CKAsyncMainQueue(^{
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        layout.itemSize = CGSizeMake(floor((self.view.frame.size.width - 12*3)/2.0), 44);

        if (!self.collectionView.dataSource) {
            self.collectionView.dataSource = self;
            self.collectionView.delegate = self;
        }
        self.datasource = [[NSUserDefaults standardUserDefaults] arrayForKey:kInsCompanyListKey];
        [self.collectionView reloadData];
    });
}

- (void)refreshViewWithDatasource:(NSArray *)datasource
{
    [self.collectionView.refreshView endRefreshing];
    self.datasource = datasource;
    [self.collectionView reloadData];
    if (self.datasource.count == 0) {
        CGFloat offset = self.collectionView.contentInset.top;
        @weakify(self);
        [self.collectionView showDefaultEmptyViewWithText:@"暂无保险公司信息" centerOffset:offset tapBlock:^{
            @strongify(self);
            [self reloadData];
        }];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.pickedBlock) {
        NSString *name = [self.datasource safetyObjectAtIndex:indexPath.item];
        self.pickedBlock(name);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LabelCell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    label.text = [self.datasource safetyObjectAtIndex:indexPath.row];
    return cell;
}

@end
