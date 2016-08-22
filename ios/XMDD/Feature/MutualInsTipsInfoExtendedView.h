//
//  MutualInsTipsInfoExtendedView.h
//  XMDD
//
//  Created by St.Jimmy on 8/22/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutualInsTipsInfoExtendedView : UIView

@property (nonatomic, copy) NSString *peopleSumString;

@property (nonatomic, copy) NSString *moneySumString;

@property (nonatomic, copy) NSString *countingString;

@property (nonatomic, copy) NSString *claimSumString;

- (void)showInfo;

@end
