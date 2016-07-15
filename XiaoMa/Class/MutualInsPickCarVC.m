//
//  MutualInsPickCarVC.m
//  XiaoMa
//
//  Created by fuqi on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsPickCarVC.h"
#import "MutualInsPicUpdateVC.h"
#import "GetCooperationUsercarListOp.h"



@interface MutualInsPickCarVC ()

@property (nonatomic,strong)CKList * datasource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MutualInsPickCarVC

- (void)dealloc
{
    DebugLog(@"MutualInsPickCarVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"互助团";
    self.tableView.backgroundColor = kBackgroundColor;

    [self setupDatasource:self.mutualInsCarArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup
- (void)setupDatasource:(NSArray *)array
{
    CKList * list = [CKList list];
    
    for (NSDictionary * dict  in array)
    {
        NSString * logoUrl = dict[@"carlogourl"];
        NSString * licensenNumber = dict[@"licensenumber"];
        NSNumber * carId = dict[@"usercarid"];
        CKDict * carCell = [CKDict dictWith:@{kCKCellID:@"CarCell"}];
        
        @weakify(self)
        carCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            
            return 82;
        });
        
        carCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            
            UIImageView * imageView = [cell.contentView viewWithTag:101];
            UILabel * lb = [cell.contentView viewWithTag:102];
            UILabel * tagLb = [cell.contentView viewWithTag:103];
            
            [imageView setImageByUrl:logoUrl
                        withType:ImageURLTypeThumbnail defImage:@"avatar_default" errorImage:@"avatar_default"];
            lb.text = licensenNumber;
            tagLb.text = @"未参团";
            tagLb.layer.cornerRadius = 12.0f;
            tagLb.layer.borderColor = kOrangeColor.CGColor;
            tagLb.layer.borderWidth = 1.0f;
            tagLb.layer.masksToBounds = YES;
        });
        
        carCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
            
            @strongify(self)
            HKMyCar * car = [[HKMyCar alloc] init];
            car.carId = carId;
            car.licencenumber = licensenNumber;
            
            if (self.finishPickCar)
            {
                self.finishPickCar(car);
            }
        });
        
        [list addObject:carCell forKey:nil];
    }
    
    @weakify(self)
    CKDict * addCell = [CKDict dictWith:@{kCKCellID:@"AddCell"}];
    addCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 50;
    });
    
    addCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        if (self.finishPickCar)
        {
            self.finishPickCar(nil);
        }
    });
    
    [list addObject:addCell forKey:nil];
    
    self.datasource = $(list);
}


#pragma mark - Utilitly
- (void)requestGetUserMutualInsCars
{
    GetCooperationUsercarListOp * op = [[GetCooperationUsercarListOp alloc] init];
    [[[op rac_postRequest] initially:^{
        
        self.tableView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetCooperationUsercarListOp * x) {
        
        
        self.tableView.hidden = NO;
        [self.view hideDefaultEmptyView];
        [self.view stopActivityAnimation];
        
    } error:^(NSError *error) {
        
        @weakify(self)
        self.tableView.hidden = YES;
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:[NSString stringWithFormat:@"%@ \n点击再试一次",error.domain] tapBlock:^{
            @strongify(self)
            [self requestGetUserMutualInsCars];
        }];
    }];
}

-(UILabel *)setCornerWithView:(UILabel *)view
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
    
    return view;
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource objectAtIndex:section] count];
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
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block) {
        return block(data,indexPath);
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block) {
        block(data, cell, indexPath);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block) {
        block(data, indexPath);
    }
}


@end
