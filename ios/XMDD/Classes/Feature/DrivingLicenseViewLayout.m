//
//  DrivingLicenseViewLayout.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DrivingLicenseViewLayout.h"

@implementation DrivingLicenseViewLayout

-(CGSize)collectionViewContentSize
{
    float width = (100+5) * [self.collectionView numberOfItemsInSection:0];
    float height= self.collectionView.frame.size.height;
    CGSize  size = CGSizeMake(width, height);
    return size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
#pragma mark - UICollectionViewLayout
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes* attributes = attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    UICollectionView *collection = self.collectionView;
    CGRect bounds = collection.bounds;
    CGFloat x = indexPath.item * (100 + 5);
    attributes.frame = CGRectMake(x, 0, 100, bounds.size.height);
    return attributes;
}
-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *arr = [super layoutAttributesForElementsInRect:rect];
    if ([arr count] >0) {
        return arr;
    }
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i=0 ; i < [self.collectionView numberOfItemsInSection:0 ]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}


@end
