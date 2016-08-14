//
//  ShopDetailCollectionLayout.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailCollectionLayout.h"

@interface ShopDetailCollectionLayout ()
@property (nonatomic, strong) NSArray *deleteSections;
@property (nonatomic, strong) NSArray *insetSections;
@end

@implementation ShopDetailCollectionLayout

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    NSMutableArray *insetSections = [NSMutableArray array];
    NSMutableArray *deleteSections = [NSMutableArray array];
    for (UICollectionViewUpdateItem *item in updateItems) {
        switch (item.updateAction) {
            case UICollectionUpdateActionInsert:
                if (item.indexPathAfterUpdate.item == NSNotFound) {
                    [insetSections addObject:@(item.indexPathAfterUpdate.section)];
                }
                break;
            case UICollectionUpdateActionDelete:
                if (item.indexPathBeforeUpdate.item == NSNotFound) {
                    [deleteSections addObject:@(item.indexPathBeforeUpdate.section)];
                }
                break;
            case UICollectionUpdateActionReload:
                if (item.indexPathBeforeUpdate.item == NSNotFound) {
                    [deleteSections addObject:@(item.indexPathBeforeUpdate.section)];
                }
                if (item.indexPathAfterUpdate.item == NSNotFound) {
                    [insetSections addObject:@(item.indexPathAfterUpdate.section)];
                }
                break;
            default:
                break;
        }
    }
    self.insetSections = insetSections;
    self.deleteSections = deleteSections;
}

- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attr = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    if ([self.insetSections containsObject:@(itemIndexPath.section)]) {
        switch (self.animationType) {
            case ShopDetailCollectionScrollLeftToRight:
                attr.transform = CGAffineTransformMakeTranslation(-ScreenWidth, 0);
                attr.alpha = 1;
                break;
            case ShopDetailCollectionScrollRightToLeft:
                attr.transform = CGAffineTransformMakeTranslation(ScreenWidth, 0);
                attr.alpha = 1;
                break;
            default:
                break;
        }
    }
    return attr;
}

- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attr = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    if ([self.deleteSections containsObject:@(itemIndexPath.section)]) {
        switch (self.animationType) {
            case ShopDetailCollectionScrollLeftToRight:
                attr.transform = CGAffineTransformMakeTranslation(ScreenWidth, 0);
                attr.alpha = 1;
                break;
            case ShopDetailCollectionScrollRightToLeft:
                attr.transform = CGAffineTransformMakeTranslation(-ScreenWidth, 0);
                attr.alpha = 1;
                break;
            default:
                break;
        }
    }
    return attr;
}

@end
