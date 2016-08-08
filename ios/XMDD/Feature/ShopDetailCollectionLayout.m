//
//  ShopDetailCollectionLayout.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailCollectionLayout.h"

@interface ShopDetailCollectionLayout ()
@property (nonatomic, strong) NSArray *insetItems;
@property (nonatomic, strong) NSArray *deleteItems;
@property (nonatomic, strong) NSArray *deleteSections;
@property (nonatomic, strong) NSArray *insetSections;
@end

@implementation ShopDetailCollectionLayout

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    NSMutableArray *insetItems = [NSMutableArray array];
    NSMutableArray *deleteItems = [NSMutableArray array];
    NSMutableArray *insetSections = [NSMutableArray array];
    NSMutableArray *deleteSections = [NSMutableArray array];
    for (UICollectionViewUpdateItem *item in updateItems) {
        switch (item.updateAction) {
            case UICollectionUpdateActionInsert:
                if (item.indexPathAfterUpdate.item == NSNotFound) {
                    [insetSections addObject:@(item.indexPathAfterUpdate.section)];
                }
                else {
                    [insetItems addObject:item.indexPathAfterUpdate];
                }
                break;
            case UICollectionUpdateActionDelete:
                if (item.indexPathBeforeUpdate.item == NSNotFound) {
                    [deleteSections addObject:@(item.indexPathBeforeUpdate.section)];
                }
                else {
                    [deleteItems addObject:item.indexPathBeforeUpdate];
                }
            default:
                break;
        }
    }
    self.insetItems = insetItems;
    self.deleteItems = deleteItems;
    self.insetSections = insetSections;
    self.deleteSections = deleteSections;
}

- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attr = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    if ([self.insetSections containsObject:@(itemIndexPath.section)]) {
        CGFloat dx = self.shouldScrollLeftToRight ? -ScreenWidth : ScreenWidth;
        attr.transform = CGAffineTransformMakeTranslation(dx, 0);
        attr.alpha = 1;
    }
    return attr;
}

- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attr = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    if ([self.deleteSections containsObject:@(itemIndexPath.section)]) {
        CGFloat dx = self.shouldScrollLeftToRight ? ScreenWidth : -ScreenWidth;
        attr.transform = CGAffineTransformMakeTranslation(dx, 0);
        attr.alpha = 1;
    }
    return attr;
}

@end
