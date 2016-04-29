//
//  ValuationCarSubView.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/4/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ValuationCarSubView.h"
#import "PickAutomobileBrandVC.h"
#import "DatePickerVC.h"

@interface ValuationCarSubView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) DatePickerVC *datePicker;

@end

@implementation ValuationCarSubView

- (void)dealloc
{
    DebugLog(@"ValuationCarSubView dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
    
    [self setCarView];
}

- (void)setCarView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"CarCell";
    CarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CarInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell setTitleLabel:@"行驶里程" withField:[NSString formatForPrice:self.car.odo / 10000.00] andLabel:@"万公里"];
            if (self.car.odo > 0) {
                cell.contentField.text = [NSString formatForPrice:self.car.odo / 10000.00];
            }
            self.cellContentField = cell.contentField;
            self.cellContentField.delegate = self;
            self.cellContentField.keyboardType = UIKeyboardTypeDecimalPad;
        }
        else if (indexPath.row == 1){
            NSString *carModelString = self.car.detailModel.modelname.length ? [NSString stringWithFormat:@"%@", self.car.detailModel.modelname] : @"";
            [cell setTitleLabel:@"爱车车型" withLabelContent:carModelString];
            self.cellContentLabel = cell.contentLabel;
        }
        else {
            NSString * dataStr = [self.car.purchasedate dateFormatForYYMM];
            [cell setTitleLabel:@"购车时间" withLabelContent:dataStr];
            self.cellContentLabel = cell.contentLabel;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    CarInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        [self.cellContentField becomeFirstResponder];
    }
    else if (indexPath.row == 1) {
        PickAutomobileBrandVC *vc = [UIStoryboard vcWithId:@"PickerAutomobileBrandVC" inStoryboard:@"Car"];
        vc.originVC = self.parentViewController;
        @weakify(self);
        [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel * series, AutoDetailModel * model) {
            
            @strongify(self);
            self.car.brand = brand.brandname;
            self.car.brandLogo = brand.brandLogo;
            self.car.seriesModel = series;
            self.car.detailModel = model;
            
            cell.contentLabel.text = model.modelname;
            if (self.contentDidChangeBlock) {
                self.contentDidChangeBlock();
            }
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2) {
        [MobClick event:@"rp601_8"];
        self.datePicker.maximumDate = [NSDate date];
        NSDate *selectedDate = self.car.purchasedate ? self.car.purchasedate : [NSDate date];

        @weakify(self);
        [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:selectedDate]
         subscribeNext:^(NSDate *date) {
             
             @strongify(self);
             self.car.purchasedate = date;
             
             cell.contentLabel.text = [date dateFormatForYYMM];
             if (self.contentDidChangeBlock) {
                 self.contentDidChangeBlock();
             }
         }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [MobClick event:@"rp601_6"];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text.length > 7) {
        textField.text = @"";
        [gToast showText:@"请输入正确的行驶里程"];
    }
    else if (textField.text.length == 0)
    {
        textField.text = @"";
    }
    else {
        textField.text = [NSString formatForPrice:[textField.text floatValue]];
        CGFloat miles = [textField.text floatValue];
        self.car.odo = miles * 10000;
        if (self.contentDidChangeBlock) {
            self.contentDidChangeBlock();
        }
    }
}

@end

@implementation CarInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = kGrayTextColor;
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.left.equalTo(self.contentView).offset(15);
        }];
        
        self.contentField = [[UITextField alloc] init];
        self.contentField.textColor = kDarkTextColor;
        self.contentField.font = [UIFont systemFontOfSize:15];
        self.contentField.textAlignment = NSTextAlignmentRight;
        
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.textColor = kDarkTextColor;
        self.contentLabel.font = [UIFont systemFontOfSize:15];
        self.contentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.contentLabel];
        
        arrowImageView = [[UIImageView alloc] init];
        arrowImageView.image = [UIImage imageNamed:@"cm_arrow_r"];
        [self.contentView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.right.equalTo(self.contentView).offset(-10);
            make.width.mas_equalTo(9);
            make.height.mas_equalTo(15);
        }];
    }
    return self;
}

- (void)setTitleLabel:(NSString *)infoTitleString withLabelContent:(NSString *)infoContentString
{
    titleLabel.text = infoTitleString;
    self.contentLabel.text = infoContentString;
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView).offset(-25);
        make.left.equalTo(self.contentView).offset(80);
    }];
}

- (void)setTitleLabel:(NSString *)infoTitleString withField:(NSString *)fieldString andLabel:(NSString *)labelString
{
    titleLabel.text = infoTitleString;
    self.contentLabel.text = labelString;
    arrowImageView.hidden = YES;
    [self.contentView addSubview:self.contentField];
    
    if ([fieldString isEqualToString:@"0"])
    {
        self.contentField.placeholder = @"请输入行驶里程  ";
    }
    else
    {
        self.contentField.placeholder = @"";
    }
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView).offset(-25);
        make.width.mas_equalTo(48);
    }];
    
    [self.contentField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentLabel.mas_left);
        make.left.equalTo(titleLabel.mas_right).offset(5);
        make.height.mas_equalTo(25);
    }];
}

@end

