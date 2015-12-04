//
//  AreaPickerVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/25.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "AreaPickerVC.h"
#import "HKLocationDataModel.h"

@interface AreaPickerVC ()

@property (nonatomic,strong)NSArray * datasource;
@property (nonatomic,strong)NSArray * provincesArr;
@property (nonatomic,strong)NSArray * citiesArr;
@property (nonatomic,strong)NSArray * districtArr;

@property (nonatomic,strong)HKLocationDataModel * hkLocation;

@end

@implementation AreaPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupWithTintColor:(UIColor *)tintColor
{
    self.cancelBtn.tintColor = tintColor;
    self.sureBtn.tintColor = tintColor;
}

- (IBAction)cancelAction:(id)sender {
    
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}
- (IBAction)sureAction:(id)sender {
    
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

+ (RACSignal *)rac_presentPickerVCInView:(UIView *)view withDatasource:(NSArray *)datasource andCurrentValue:(NSArray *)value forStyle:(AreaPickerStyle)style
{
    AreaPickerVC *vc = [UIStoryboard vcWithId:@"AreaPickerVC" inStoryboard:@"Common"];
    return [vc rac_presentPickerVCInView:view withDatasource:datasource andCurrentValue:value forStyle:style];
}

///弹出日期选择器(next:NSData* error:【表示取消选取】)
- (RACSignal *)rac_presentPickerVCInView:(UIView *)view withDatasource:(NSArray *)datasource andCurrentValue:(NSArray *)value forStyle:(AreaPickerStyle)style
{
    self.datasource = datasource;
    CGSize size = CGSizeMake(CGRectGetWidth(view.frame), 280);
    CGRect rect = view.frame;
    rect.size.height += 40;
    MZFormSheetController *sheet = [DefaultStyleModel presentSheetCtrlFromBottomWithSize:size viewController:self targetViewFrame:rect];
    sheet.shouldDismissOnBackgroundViewTap = NO;
    [self setupWithTintColor:kDefTintColor];
    
    RACSubject *subject = [RACSubject subject];
    @weakify(self);
    [[[self rac_signalForSelector:@selector(sureAction:)] take:1] subscribeNext:^(id x) {
        @strongify(self);
        [subject sendNext:self.hkLocation];
        [subject sendCompleted];
    }];
    
    [[[self rac_signalForSelector:@selector(cancelAction:)] take:1] subscribeNext:^(id x) {
        [subject sendError:[NSError errorWithDomain:@"cancel" code:0 userInfo:nil]];
    }];
    
//    for (NSInteger component = 0; component< self.datasource.count;component++)
//    {
//        NSDictionary * dic = [self.datasource safetyObjectAtIndex:component];
//        [self.provincesArr addObject:dic[@"state"]];
//    }
    self.pickerStyle = style;
    self.provincesArr = self.datasource;
    self.citiesArr = [[self.provincesArr objectAtIndex:0] objectForKey:@"cities"];
    self.hkLocation = [[HKLocationDataModel alloc] init];
    
    self.hkLocation.province = [[self.provincesArr objectAtIndex:0] objectForKey:@"state"];
    self.hkLocation.city = [[self.citiesArr objectAtIndex:0] objectForKey:@"city"];
    
    self.districtArr = [[self.citiesArr objectAtIndex:0] objectForKey:@"areas"];
    if (self.districtArr.count > 0) {
        self.hkLocation.district = [self.districtArr objectAtIndex:0];
    } else{
        self.hkLocation.district = @"";
    }
//        for (NSInteger row = 0; row < array.count;row++)
//        {
//            NSObject * obj = [array safetyObjectAtIndex:row];
//            if (obj.customTag)
//            {
//                [self.pickerView selectRow:row inComponent:component animated:YES];
//                
//            }
//        }
    return subject;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.pickerStyle == AreaPickerWithStateAndCityAndDistrict) {
        return 3;
    } else{
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return self.provincesArr.count;
            break;
        case 1:
            return self.citiesArr.count;
            break;
        case 2:
            if (self.pickerStyle == AreaPickerWithStateAndCityAndDistrict) {
                return self.districtArr.count;
                break;
            }
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.pickerStyle == AreaPickerWithStateAndCityAndDistrict) {
        switch (component) {
            case 0:
                return [[self.provincesArr objectAtIndex:row] objectForKey:@"state"];
                break;
            case 1:
                return [[self.citiesArr objectAtIndex:row] objectForKey:@"city"];
                break;
            case 2:
                if ([self.districtArr count] > 0) {
                    return [self.districtArr objectAtIndex:row];
                    break;
                }
            default:
                return  @"";
                break;
        }
    }
    else{
        switch (component) {
            case 0:
                return [[self.provincesArr objectAtIndex:row] objectForKey:@"state"];
                break;
            case 1:
                return [[self.citiesArr objectAtIndex:row] objectForKey:@"city"];
                break;
            default:
                return @"";
                break;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.pickerStyle == AreaPickerWithStateAndCityAndDistrict) {
        switch (component) {
            case 0:
                self.citiesArr = [[self.provincesArr objectAtIndex:row] objectForKey:@"cities"];
                [pickerView selectRow:0 inComponent:1 animated:YES];
                [pickerView reloadComponent:1];
                
                self.districtArr = [[self.citiesArr objectAtIndex:0] objectForKey:@"areas"];
                [pickerView selectRow:0 inComponent:2 animated:YES];
                [pickerView reloadComponent:2];
                
                self.hkLocation.province = [[self.provincesArr objectAtIndex:row] objectForKey:@"state"];
                self.hkLocation.city = [[self.citiesArr objectAtIndex:0] objectForKey:@"city"];
                if ([self.districtArr count] > 0) {
                    self.hkLocation.district = [self.districtArr objectAtIndex:0];
                } else{
                    self.hkLocation.district = @"";
                }
                break;
            case 1:
                self.districtArr = [[self.citiesArr objectAtIndex:row] objectForKey:@"areas"];
                [pickerView selectRow:0 inComponent:2 animated:YES];
                [pickerView reloadComponent:2];
                
                self.hkLocation.city = [[self.citiesArr objectAtIndex:row] objectForKey:@"city"];
                if ([self.districtArr count] > 0) {
                    self.hkLocation.district = [self.districtArr objectAtIndex:0];
                } else{
                    self.hkLocation.district = @"";
                }
                break;
            case 2:
                if ([self.districtArr count] > 0) {
                    self.hkLocation.district = [self.districtArr objectAtIndex:row];
                } else{
                    self.hkLocation.district = @"";
                }
                break;
            default:
                break;
        }
    } else{
        switch (component) {
            case 0:
                self.citiesArr = [[self.provincesArr objectAtIndex:row] objectForKey:@"cities"];
                [pickerView selectRow:0 inComponent:1 animated:YES];
                [pickerView reloadComponent:1];
                
                self.hkLocation.province = [[self.provincesArr objectAtIndex:row] objectForKey:@"state"];
                self.hkLocation.city = [self.citiesArr objectAtIndex:0];
                break;
            case 1:
                self.hkLocation.city = [self.citiesArr objectAtIndex:row];
                break;
            default:
                break;
        }
    }
    
//    if([self.areaPickerDelegate respondsToSelector:@selector(pickerDidChangeStatus:)]) {
//        [self.areaPickerDelegate pickerDidChangeStatus:self];
//    }
}


@end
