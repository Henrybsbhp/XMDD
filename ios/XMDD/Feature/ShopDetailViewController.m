//
//  ShopDetailViewController.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailViewController.h"
#import "ShopDetailCollectionLayout.h"
#import "ShopDetailHeaderView.h"
#import "NSString+RectSize.h"

const NSString *kCommentSection = @"CommentSection";
const NSString *kServiceSection = @"ServiceSection";
typedef void (^PrepareCollectionCellBlock)(CKDict *item, UICollectionView *collectionView,
                                           NSIndexPath *indexPath, __kindof UICollectionViewCell *cell);
typedef void (^CollectionCellSelectedBlock)(CKDict *item, UICollectionView *collectionView, NSIndexPath *indexPath);

@interface ShopDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ShopDetailCollectionLayout *collectionLayout;
@property (nonatomic, strong) CKList *datasource;
@end

@implementation ShopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCollectionView {
    self.collectionLayout = [[ShopDetailCollectionLayout alloc] init];
    self.collectionLayout.minimumLineSpacing = 0;
    
    self.collectionView.backgroundColor = kBackgroundColor;
    self.collectionView.collectionViewLayout = self.collectionLayout;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[ShopDetailHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
}

#pragma mark - Datasource
- (void)reloadDatasource {
    self.datasource = $($(@1), [self createServiceSectionItems], [self createCommentSectionItems]);
    [self.collectionView reloadData];
}

- (id)createServiceSectionItems {
    return CKNULL;
}

- (id)createCommentSectionItems {
    return CKNULL;
}

#pragma mark -
#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(ScreenWidth, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(ScreenWidth, 165);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //评论的section
    if ([kCommentSection isEqualToString:[self.datasource[section] key]]) {
        return UIEdgeInsetsMake(10, 0, 0, 0);
    }
    return UIEdgeInsetsZero;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.datasource count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.datasource[section] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ShopDetailHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                    withReuseIdentifier:@"Header" forIndexPath:indexPath];
    view.trottingView.text = [self appendSpace:_shop.announcement andWidth:self.view.frame.size.width - 60];
    view.trottingContainerView.hidden = _shop.announcement.length == 0;
    view.picURLArray = _shop.picArray;
    [[[view.tapGesture rac_gestureSignal] takeUntil:[view rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [MobClick event:@"rp105_2"];
    }];
    return view;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:item[kCKCellID] forIndexPath:indexPath];
    PrepareCollectionCellBlock block = item[kCKCellPrepare];
    if (block) {
        block(item, collectionView, indexPath, cell);
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    CollectionCellSelectedBlock block = item[kCKCellSelected];
    if (block) {
        block(item, collectionView, indexPath);
    }
}

#pragma mark - Util
- (NSString *)appendSpace:(NSString *)note andWidth:(CGFloat)w
{
    NSString * spaceNote = note;
    for (NSInteger i = 0;i< 1000;i++)
    {
        CGSize size = [spaceNote labelSizeWithWidth:9999 font:[UIFont systemFontOfSize:13]];
        if (size.width > w)
            return spaceNote;
        spaceNote = [spaceNote append:@" "];
    }
    return spaceNote;
}
@end
