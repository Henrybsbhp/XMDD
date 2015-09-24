//
//  DrivingLicenseHistoryView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureRecord.h"

@protocol DrivingLicenseHistoryViewDelegate <NSObject>

@optional
- (BOOL)shouldSelectedAtIndex:(NSInteger)index;
- (void)didSelectedAtIndex:(NSInteger)index;

@end

@interface DrivingLicenseHistoryView : UIView
@property (nonatomic, strong) NSArray *recordList;
@property (nonatomic, assign) NSInteger selectedRecordIndex;
@property (nonatomic, weak) id<DrivingLicenseHistoryViewDelegate>delegate;

- (PictureRecord *)currentSelectedRecord;
/// (sendNext:(NSArray *)drivingLicenseRecords)
- (RACSignal *)rac_reloadDataWithSelectedRecord:(PictureRecord *)selectedRecord;

@end
