//
//  ValuationCarSubView.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/4/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ValuationCarSubView : UIViewController

@property (nonatomic, strong) UIViewController *originVC;

@property (nonatomic, strong) HKMyCar *car;

@property (nonatomic, strong) UITextField *cellContentField;
@property (nonatomic, strong) UILabel *cellContentLabel;

@property (nonatomic, copy) void(^contentDidChangeBlock)(void);

@end



@interface CarInfoCell : UITableViewCell
{
    UILabel *titleLabel;
    UIImageView *arrowImageView;
}

@property (nonatomic, strong) UITextField *contentField;
@property (nonatomic, strong) UILabel *contentLabel;

//设置输入框和label组合的cell（行驶里程）
- (void)setTitleLabel:(NSString *)infoTitleString withField:(NSString *)fieldString andLabel:(NSString *)labelString;

- (void)setTitleLabel:(NSString *)infoTitleString withLabelContent:(NSString *)infoContentString;

@end