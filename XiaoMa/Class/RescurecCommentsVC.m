//
//  RescurecCommentsVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescurecCommentsVC.h"
#import "GetRescueCommentRescueOp.h"
#import "HKBigRatingView.h"
#import "JTRatingView.h"
#import "GetRescueCommentOp.h"
#define kWidth [UIScreen mainScreen].bounds.size.width

@interface RescurecCommentsVC ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView        * headerView;
@property (nonatomic, strong) UIImageView   * titleImg;
@property (nonatomic, strong) UILabel       * titleLb;

@property (nonatomic, strong) UIView        * footerView;
@property (nonatomic, strong) UITextView    * commentsTV;
@property (nonatomic, strong) UILabel       * placeholderLb;
@property (nonatomic, strong) UIButton      * submitBtn;
@property (nonatomic, strong) JTRatingView  * ratingView;
@property (nonatomic, strong) NSMutableArray * dataSourceArray;
@property (nonatomic, strong) NSMutableArray * evaluationArray;
@property (nonatomic, strong) NSNumber      * starNum1;
@property (nonatomic, strong) NSNumber      * starNum2;
@property (nonatomic, strong) NSNumber      * starNum3;

@property (nonatomic, assign) NSInteger       mark;
@end

@implementation RescurecCommentsVC

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(deallocInfo);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setImageAndLbText];
    [self.headerView addSubview:self.titleImg];
    [self.headerView addSubview:self.titleLb];
    [self.footerView addSubview:self.commentsTV];
    [self.commentsTV addSubview:self.placeholderLb];
    [self.footerView addSubview:self.submitBtn];
    self.tableView.separatorStyle = NO;
    self.tableView.tableHeaderView = self.headerView;
   
    
   
    //textView占位符（label要关掉交互）
    @weakify(self)
    [[self.commentsTV.rac_textSignal filter:^BOOL(NSString *value) {
        @strongify(self)
        if (value.length > 0) {
            self.placeholderLb.text = @"";
        }else {
            self.placeholderLb.text = @"其他建议或意见";
        }
        return nil;
    }] subscribeNext:^(NSString * x) {
        NSLog(@"%@", x);
        self.commentsTV.text = x;
    }];
    
    if (self.isLog == 1) {
        [self alreadyNetwork];
    }else if (self.isLog == 0){
        
         self.tableView.tableFooterView = self.footerView;
    }
}
- (void)setImageAndLbText {
    if (self.type == 1) {
        self.titleImg.image = [UIImage imageNamed:@"拖车服务"];
        self.titleLb.text = @"拖车服务";
    }else if (self.type == 2){
        self.titleImg.image = [UIImage imageNamed:@"泵电服务"];
        self.titleLb.text = @"泵电服务";
    }else if (self.type == 3){
        self.titleImg.image = [UIImage imageNamed:@"换胎服务"];
        self.titleLb.text = @"换胎服务";
    }
}

- (void) alreadyNetwork {
    GetRescueCommentOp *op = [GetRescueCommentOp operation];
    op.applyId = self.applyId;
    op.type = [NSNumber numberWithInteger:1];
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
 
        [gToast showText:@"加载中"];
        
    }] finally:^{
        
        
    }] subscribeNext:^(GetRescueCommentOp *op) {
        
        
        @strongify(self)
        [gToast dismiss];
        self.evaluationArray = op.rescueDetailArray;
        
        self.mark = 3;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [gToast showError:@"获取评论内容失败"];
    }] ;
    

}
- (void) network {
    GetRescueCommentRescueOp *op = [GetRescueCommentRescueOp operation];
    if (self.starNum1 > 0 && self.starNum2 > 0 && self.starNum3 >0) {
        op.applyId = self.applyId;
        op.responseSpeed = self.starNum1;
        op.arriveSpeed = self.starNum2;
        op.serviceAttitude = self.starNum3;
        if (self.commentsTV.text != nil) {
            op.comment = self.commentsTV.text;
        }else {
            op.comment = @"";
        }
        op.rescueType = [NSNumber numberWithInteger:1];
        
        NSLog(@"-------%@", self.starNum1);
    }else {
        [gToast showText:@"您还没有评价"];
    }
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
        [gToast showText:@"提交中"];
    }] finally:^{
        
        
    }] subscribeNext:^(GetRescueCommentRescueOp *op) {
        @strongify(self)
        [gToast dismiss];
        [gToast showText:@"评论成功"];
        self.isLog = 1;
        [self alreadyNetwork];
//        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [gToast showError:@"评论失败, 请尝试重新提交"];
        NSLog(@"%@", error.description);
    }] ;
    
    
 

}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isLog == 1 && self.evaluationArray.count != 0){
        return 8;
    }else {
    return 7;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    if (indexPath.row < 3) {
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"RescurecCommentsVC1" forIndexPath:indexPath];
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *nameLabel = [cell1.contentView viewWithTag:1000];
        UILabel *textLb = [cell1.contentView viewWithTag:1001];
   
        if (indexPath.row == 0) {
            nameLabel.text = @"申请时间";
            NSString *timeStr = [NSString stringWithFormat:@"%@", self.applyTime];
            NSString *tempStr = [timeStr substringToIndex:10];
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[tempStr intValue]];
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
            textLb.text = [dateFormat stringFromDate:confromTimesp];
            
        }else if (indexPath.row == 1){
            nameLabel.text = @"申请服务";
            textLb.text = self.serviceName;
        }else if (indexPath.row == 2){
            nameLabel.text = @"服务车牌";
            textLb.text = self.licenceNumber;
        }
        
        return cell1;
    }else if (indexPath.row == 3){
        UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:@"RescurecCommentsVC3" forIndexPath:indexPath];
        cell3.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *stateLb = [cell3.contentView viewWithTag:1010];
        UILabel *evaluationLb = [cell3.contentView viewWithTag:1011];
        
        if (self.isLog == 1 && self.evaluationArray.count != 0) {
            
            stateLb.text = @"感谢您的评价";
            evaluationLb.hidden = YES;
        }
        
        return cell3;
    }else  if(indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6){
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"RescurecCommentsVC2" forIndexPath:indexPath];
        cell2.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *serviceLb = [cell2.contentView viewWithTag:1002];
        self.ratingView = [cell2.contentView viewWithTag:1003];
        self.ratingView.imgWidth = 20;
        self.ratingView.imgHeight = 20;
        self.ratingView.imgSpacing = (kWidth - 128 - 20 * 5)/6;
        self.ratingView.ratingValue = 3;
        [[self.ratingView rac_subject] subscribeNext:^(NSNumber * number) {
            if (indexPath.row == 4) {
                self.starNum1 = number;
            }else if (indexPath.row == 5){
                self.starNum2  = number;
            }else if (indexPath.row == 6){
                self.starNum3 = number;
            }
    }];
        
        if (self.isLog == 1 && self.evaluationArray.count != 0) {
            if (indexPath.row == 4) {                
                self.ratingView.ratingValue = [self.evaluationArray[0] floatValue];
            }else if (indexPath.row == 5){
                self.ratingView.ratingValue = [self.evaluationArray[1] floatValue];
            }else if (indexPath.row == 6){
                self.ratingView.ratingValue = [self.evaluationArray[2] floatValue];
            }
    }

        if (indexPath.row == 4) {
            serviceLb.text = @"客服反映速度:";
        }else if (indexPath.row == 5){
            serviceLb.text = @"救援到达速度:";
        }else if (indexPath.row == 6){
            serviceLb.text = @"救援服务态度:";
        }
        return cell2;
    } else{
       
            UITableViewCell *cell4 = [tableView dequeueReusableCellWithIdentifier:@"RescurecCommentsVC4" forIndexPath:indexPath];
           UILabel *textLb = [cell4.contentView viewWithTag:1004];
           textLb.text = self.evaluationArray[3];
        return cell4;
    }
}

#pragma mark - UITableViewdelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 25;
    }else if (indexPath.row < 4){
        if (self.evaluationArray.count != 0) {
            return 36;
        }else{
        return 50;
        }
    }else {
        return 36;
    }
}
#pragma mark - lazyLoading
- (UIView *)headerView {
    if (!_headerView) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.193 * kWidth)];
    }
    return _headerView;
}

- (UIImageView *)titleImg {
    if (!_titleImg) {
        self.titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(13, 15, 35, 35)];
    }
    return _titleImg;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        self.titleLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleImg.frame) + 15, CGRectGetMinY(self.titleImg.frame), kWidth - 35 - 26 - 15, self.titleImg.frame.size.height)];
        _titleLb.font = [UIFont systemFontOfSize:18];
        _titleLb.textColor = [UIColor colorWithHex:@"#111111" alpha:1.0];
    }
    return _titleLb;
}

- (UIView *)footerView {
    if (!_footerView) {
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.4 * kWidth)];
    }
    return _footerView;
}

- (UITextView *)commentsTV {
    if (!_commentsTV) {
        self.commentsTV = [[UITextView alloc] initWithFrame:CGRectMake(9, 0, kWidth - 18, 0.24 * (kWidth - 18))];
    }
    return _commentsTV;
}

- (UILabel *)placeholderLb {
    if (!_placeholderLb) {
        self.placeholderLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.commentsTV.frame), CGRectGetMinY(self.commentsTV.frame), 100, 20)];
        _placeholderLb.text = @"其他建议或意见";
        _placeholderLb.textColor = [UIColor colorWithHex:@"#e3e3e3" alpha:1.0];
        _placeholderLb.font = [UIFont systemFontOfSize:12];
        _placeholderLb.hidden = NO;
    }
    return _placeholderLb;
}

- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        self.dataSourceArray = [@[] mutableCopy];
    }
    return _dataSourceArray;
}

- (NSMutableArray *)evaluationArray {
    if (!_evaluationArray) {
        self.evaluationArray = [@[] mutableCopy];
    }
    return _evaluationArray;
}

- (JTRatingView *)ratingView {
    if (!_ratingView) {
        self.ratingView = [self.tableView viewWithTag:1003];
    }
    return _ratingView;
}

- (UIButton *)submitBtn {
    if (!_submitBtn) {
        self.submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _submitBtn.frame = CGRectMake(5, CGRectGetMaxY(self.commentsTV.frame) + 12, kWidth - 10, (kWidth - 10) * 0.128);
        _submitBtn.backgroundColor = [UIColor colorWithHex:@"#ffa800" alpha:1.0];
        [_submitBtn addTarget:self action:@selector(network) forControlEvents:UIControlEventTouchUpInside];
        _submitBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_submitBtn setTintColor:[UIColor whiteColor]];
        _submitBtn.cornerRadius = 5;
        [_submitBtn setTitle:@"发表评论" forState:UIControlStateNormal];
    }
    return _submitBtn;
}


+(NSString *)nsdateToString:(NSDate *)date{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* string=[dateFormat stringFromDate:date];
    return string;
}
@end
