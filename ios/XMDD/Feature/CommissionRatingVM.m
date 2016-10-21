//
//  CommissionRatingVM.m
//  XMDD
//
//  Created by St.Jimmy on 20/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CommissionRatingVM.h"
#import "NSString+RectSize.h"
#import "JTRatingView.h"

@interface CommissionRatingVM () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIViewController *targetVC;

@property (nonatomic, strong) NSNumber *commentStar1;
@property (nonatomic, strong) NSNumber *commentStar2;
@property (nonatomic, strong) NSNumber *commentStar3;

@end

@implementation CommissionRatingVM

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC
{
    if (self = [super init]) {
        self.tableView = tableView;
        self.targetVC = targetVC;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    return self;
}

#pragma mark - Initial setup
- (void)initialSetup
{
    self.dataSource = $($([self setupTitleCell], [self setupPaymentInfoCellWithArray:@[@"申请服务", @"拖车服务"] isHighlighted:NO], [self setupPaymentInfoCellWithArray:@[@"项目价格", @"￥300.00"] isHighlighted:YES],  [self setupPaymentInfoCellWithArray:@[@"我的车辆", @"浙AJC625"] isHighlighted:NO], [self setupBlankCell]), $([self setupRatingTitleCell], [self setupRescueRatingCell], [self setupRescueRatingCell], [self setupRescueRatingCell], [self setupTextCommentCell]), $([self setupSendCommentCell]));
}

#pragma mark - Actions
/// 发表评论
- (void)actionSendComment
{
    
}

#pragma mark - The settings of the UITableViewCell
/// 顶部 Title Cell
- (CKDict *)setupTitleCell
{
    CKDict *titleCell = [CKDict dictWith:@{kCKItemKey: @"TitleCell", kCKCellID: @"TitleCell"}];
    
    titleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 56;
    });
    
    titleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return titleCell;
}

/// 支付的信息 Cell
- (CKDict *)setupPaymentInfoCellWithArray:(NSArray *)infoArray isHighlighted:(BOOL)isHighlighted
{
    CKDict *paymentInfoCell = [CKDict dictWith:@{kCKItemKey: @"PaymentInfoCell", kCKCellID: @"PaymentInfoCell"}];
    paymentInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 25;
    });
    paymentInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        if (isHighlighted) {
            infoLabel.textColor = HEXCOLOR(@"#FF7428");
        }
        
        descLabel.text = infoArray[0];
        infoLabel.text = infoArray[1];
    });
    
    return paymentInfoCell;
}

/// 空白的占位 Cell
- (CKDict *)setupBlankCell
{
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"BlankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 10;
    });
    blankCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return blankCell;
}

/// 评论的 Title cell
- (CKDict *)setupRatingTitleCell
{
    CKDict *ratingTitleCell = [CKDict dictWith:@{kCKItemKey: @"RatingTitleCell", kCKCellID: @"RatingTitleCell"}];
    ratingTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    
    ratingTitleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UIView *cell, NSIndexPath *indexPath) {
        
    });
    
    return ratingTitleCell;
}

/// 评星打分 Cell
- (CKDict *)setupRescueRatingCell
{
    CKDict *rescueRatingCell = [CKDict dictWith:@{kCKItemKey: @"RescueRatingCell", kCKCellID: @"RescueRatingCell"}];
    
    rescueRatingCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    rescueRatingCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView searchViewWithTag:1002];
        JTRatingView *ratingView = (JTRatingView *)[cell.contentView searchViewWithTag:1003];
        CGFloat space = (gAppMgr.deviceInfo.screenSize.width - 173 - 27 * 5) / 4;
        
        [ratingView setupImgWidth:27 andImgHeight:27 andSpace:space];
        
        @weakify(self)
        [[ratingView rac_subject] subscribeNext:^(NSNumber * number) {
            @strongify(self)
            if (indexPath.row == 1) {
                self.commentStar1 = number;
            }else if (indexPath.row == 2){
                self.commentStar2  = number;
            }else if (indexPath.row == 2){
                self.commentStar3 = number;
            }
        }];
        
        if (indexPath.row == 1) {
            titleLabel.text = @"客服反应速度：";
        }else if (indexPath.row == 2){
            titleLabel.text = @"协办服务速度：";
        }else if (indexPath.row == 3){
            titleLabel.text = @"协办服务态度：";
        }
    });
    
    return rescueRatingCell;
}

/// 文字评价 Cell
- (CKDict *)setupTextCommentCell
{
    CKDict *textCommentCell = [CKDict dictWith:@{kCKItemKey: @"TextCommentCell", kCKCellID: @"TextCommentCell"}];
    
    textCommentCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 136;
    });
    
    textCommentCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UITextView *commentTextView = (UITextView *)[cell.contentView searchViewWithTag:100];
        UIView *containerView = (UIView *)[cell searchViewWithTag:1001];
        commentTextView.layer.borderColor = HEXCOLOR(@"#DEDFE0").CGColor;
        commentTextView.layer.borderWidth = 0.5;
        commentTextView.layer.cornerRadius = 3;
        commentTextView.layer.masksToBounds = YES;
        commentTextView.textContainerInset = UIEdgeInsetsMake(10, 7, 7, 7);
        
        if (!containerView) {
            containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 7, commentTextView.frame.size.width - 17, 21)];
            containerView.tag = 1001;
            UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, 21)];
            containerView.userInteractionEnabled = NO; // 防止视图截取 textView 获取焦点
            [containerView addSubview:placeholderLabel];
            placeholderLabel.text = @"您的评论将是其他用户的重要参考！";
            placeholderLabel.font = [UIFont systemFontOfSize:13];
            placeholderLabel.textColor = HEXCOLOR(@"#C6C6CC");
            [commentTextView addSubview:containerView];
        }
        
        [[commentTextView rac_textSignal] subscribeNext:^(id x) {
            if (commentTextView.text.length < 1) {
                containerView.hidden = NO;
            } else {
                containerView.hidden = YES;
            }
        }];
    });
    
    return textCommentCell;
}

/// 发表评论 Cell
- (CKDict *)setupSendCommentCell
{
    CKDict *sendCommentCell = [CKDict dictWith:@{kCKItemKey: @"ButtonCell", kCKCellID: @"ButtonCell"}];
    
    sendCommentCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 68;
    });
    
    sendCommentCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *sendButton = (UIButton *)[cell.contentView viewWithTag:100];
        sendButton.backgroundColor = HEXCOLOR(@"#FF7428");
        [sendButton setTitle:@"发表评论" forState:UIControlStateNormal];
        
        @weakify(self);
        [[[sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            [self actionSendComment];
        }];
    });
    
    return sendCommentCell;
}

#pragma mark - UITableViewDelagate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
