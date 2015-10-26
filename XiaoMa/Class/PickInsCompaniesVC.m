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
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        [self.collectionView.refreshView beginRefreshing];
    }] subscribeNext:^(GetInsCompanyListOp *op) {

        @strongify(self);
        [self.collectionView.refreshView endRefreshing];
        [[NSUserDefaults standardUserDefaults] setObject:op.rsp_names forKey:kInsCompanyListKey];
        self.datasource = op.rsp_names;
        [self.collectionView reloadData];
    } error:^(NSError *error) {

        @strongify(self);
        [self.collectionView.refreshView endRefreshing];
        [gToast showError:error.domain];
    }];
}

- (void)loadDefData
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.datasource = [def arrayForKey:kInsCompanyListKey];
    
    CKAsyncMainQueue(^{
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        layout.itemSize = CGSizeMake(self.view.frame.size.width - 12*3, 44);

        if (!self.collectionView.dataSource) {
            self.collectionView.dataSource = self;
            self.collectionView.delegate = self;
        }
        [self.collectionView reloadData];
        
    });
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
