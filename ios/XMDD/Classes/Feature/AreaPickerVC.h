//
//  AreaPickerVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/25.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, AreaPickerStyle){
    AreaPickerWithStateAndCity,
    AreaPickerWithStateAndCityAndDistrict
} ;

@interface AreaPickerVC : HKViewController <UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sureBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (assign, nonatomic) AreaPickerStyle pickerStyle;

- (void)setupWithTintColor:(UIColor *)tintColor;

+ (RACSignal *)rac_presentPickerVCInView:(UIView *)view withDatasource:(NSArray *)datasource andCurrentValue:(NSArray *)value forStyle:(AreaPickerStyle)style;
- (RACSignal *)rac_presentPickerVCInView:(UIView *)view withDatasource:(NSArray *)datasource andCurrentValue:(NSArray *)value forStyle:(AreaPickerStyle)style;

@end
