//
//  PickerVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerVC : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sureBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, copy) NSString *(^getTitleBlock)(NSInteger row, NSInteger component);

- (void)setupWithTintColor:(UIColor *)tintColor;
+ (instancetype)pickerVC;
///(next: {selected datas})
- (RACSignal *)rac_presentInView:(UIView *)view datasource:(NSArray *)datasource curRows:(NSArray *)rows;

@end
