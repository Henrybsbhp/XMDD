//
//  HKCollectionViewCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKLine.h"

@interface HKCollectionViewCell : UICollectionViewCell

- (CKLine *)addOrUpdateBorderLineWithAlignment:(CKLineAlignment)alignment insets:(UIEdgeInsets)insets;
- (void)removeBorderLineWithAlignment:(CKLineAlignment)alignment;
- (void)removeAllBorderLines;

@end
