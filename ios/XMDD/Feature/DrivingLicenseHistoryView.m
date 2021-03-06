//
//  DrivingLicenseHistoryView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DrivingLicenseHistoryView.h"
#import <Masonry.h>
#import "DrivingLicenseThumbCell.h"
#import "DrivingLicenseViewLayout.h"
#import "GetPicHistoryOp.h"
#import "DeletePicHistoryOp.h"

@interface DrivingLicenseHistoryView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation DrivingLicenseHistoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitWithFrame:self.frame];
    }
    return self;
}

- (void)commonInitWithFrame:(CGRect)frame
{
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:[[DrivingLicenseViewLayout alloc] init]];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    [self.collectionView registerClass:[DrivingLicenseThumbCell class] forCellWithReuseIdentifier:@"ThumbCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
}


- (RACSignal *)rac_reloadDataWithSelectedRecord:(PictureRecord *)selectedRecord
{
    @weakify(self);
    return [[self rac_fetchDrivingLicenseRecords] doNext:^(NSArray *records) {
        
        @strongify(self);
        self.recordList = records;
        if (selectedRecord) {
            self.selectedRecordIndex = [records indexOfObject:selectedRecord];
        }
        else {
            self.selectedRecordIndex = NSNotFound;
        }
        if (self.selectedRecordIndex != NSNotFound) {
            PictureRecord *record = [records objectAtIndex:self.selectedRecordIndex];
            record.image = selectedRecord.image;
            [self.collectionView reloadData];
            CKAsyncMainQueue(^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedRecordIndex inSection:0];
                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            });
        }
        else {
            [self.collectionView reloadData];
        }
    }];
}

- (PictureRecord *)currentSelectedRecord
{
    return [self.recordList safetyObjectAtIndex:self.selectedRecordIndex];
}

#pragma mark - Action
- (void)actionDeleteRecord:(PictureRecord *)record
{
    
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        NSInteger item = [self.recordList indexOfObject:record];
        if (item == NSNotFound) {
            return ;
        }
        
        @weakify(self);
        [[[self rac_deleteDrivingLicenseRecord:record] initially:^{
            
            [gToast showingWithText:@"正在删除..."];
        }] subscribeNext:^(id x) {
            
            @strongify(self);
            [gToast dismiss];
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.recordList];
            [array safetyRemoveObjectAtIndex:item];
            self.recordList = array;
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:0]]];
            if (self.selectedRecordIndex == item) {
                self.selectedRecordIndex = NSNotFound;
            }
        } error:^(NSError *error) {
            
            [gToast showError:error.domain];
        }];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"是否删除该行驶证记录" ActionItems:@[cancel,confirm]];
    [alert show];
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp126_2"];
    BOOL shouldSelected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldSelectedAtIndex:)]) {
        shouldSelected = [self.delegate shouldSelectedAtIndex:indexPath.item];
    }
    if (shouldSelected) {
        self.selectedRecordIndex = indexPath.item;
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedAtIndex:)]) {
            [self.delegate didSelectedAtIndex:indexPath.item];
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.recordList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DrivingLicenseThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbCell" forIndexPath:indexPath];
    UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UIView *bottomV = [cell.contentView viewWithTag:1002];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1003];
    UIImageView *checkV = (UIImageView *)[cell.contentView viewWithTag:1004];
    UIButton *deleteB = (UIButton *)[cell.contentView viewWithTag:1005];
    
    PictureRecord *record = [self.recordList safetyObjectAtIndex:indexPath.item];
    
    [imageV setImageByUrl:record.url withType:ImageURLTypeThumbnail defImage:@"cm_defpic2" errorImage:@"cm_defpic_fail2"];
    imageV.clipsToBounds = YES;
    imageV.contentMode = UIViewContentModeScaleAspectFill;
    bottomV.hidden = record.plateNumber.length == 0;
    titleL.text = record.plateNumber;
    deleteB.hidden = !record.deleteable;

    //点击删除
    @weakify(self);
    [[[deleteB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         [MobClick event:@"rp1002_3"];
         @strongify(self);
         [self actionDeleteRecord:record];
    }];
    
    //选中
    @weakify(cell);
    [[RACObserve(self, selectedRecordIndex) takeUntilForCell:cell] subscribeNext:^(NSNumber *index) {
        
        @strongify(cell);
        @strongify(self);
        NSInteger itemIndex = [self.recordList indexOfObject:record];
        if (itemIndex != NSNotFound && itemIndex == [index integerValue]) {
            [MobClick event:@"rp1002_4"];
            if (record.plateNumber) {
                [MobClick event:@"rp1002_5"];
            }
            cell.contentView.layer.borderWidth = 1.5;
            checkV.hidden = NO;
        }
        else {
            cell.contentView.layer.borderWidth = 0;
            checkV.hidden = YES;
        }
    }];
    return cell;
}

#pragma mark - operation
- (RACSignal *)rac_fetchDrivingLicenseRecords
{
    GetPicHistoryOp *op = [[GetPicHistoryOp alloc] init];
    op.req_picType = 1;
    return [[op rac_postRequest] map:^id(GetPicHistoryOp *rspOp) {
        return rspOp.rsp_records;
    }];
}

- (RACSignal *)rac_deleteDrivingLicenseRecord:(PictureRecord *)record
{
    DeletePicHistoryOp *op = [[DeletePicHistoryOp alloc] init];
    op.req_picID = record.picID;
    return [op rac_postRequest];
}

@end
