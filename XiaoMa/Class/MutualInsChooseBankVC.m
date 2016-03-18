//
//  ChooseBankVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsChooseBankVC.h"

@interface MutualInsChooseBankVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation MutualInsChooseBankVC

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController popViewControllerAnimated:YES];
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
