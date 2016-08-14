//
//  ShopDetailCollectionLayout.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

typedef enum {
    ShopDetailCollectionAnimateDefault = 0,
    ShopDetailCollectionScrollLeftToRight = 1,
    ShopDetailCollectionScrollRightToLeft = 2,
}ShopDetailCollectionAnimationType;

#import <UIKit/UIKit.h>

@interface ShopDetailCollectionLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) ShopDetailCollectionAnimationType animationType;

@end
