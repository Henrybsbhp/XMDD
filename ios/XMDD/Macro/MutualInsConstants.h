//
//  MutualInsConstants.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#ifndef MutualInsConstants_h
#define MutualInsConstants_h


typedef enum : NSInteger {
    MutInsStatusNeedCar = 0,                //团长无车，完善爱车信息
    MutInsStatusNeedDriveLicense = 1,       //完善行驶证信息
    MutInsStatusNeedInsList = 2,            //完善保险列表
    MutInsStatusUnderReview = 3,            //资料审核中
    MutInsStatusNeedReviewAgain = 20,       //资料审核失败，需要重新提交
    MutInsStatusReviewFailed = 21,          //资料审核失败，无法入团
    MutInsStatusNeedQuote = 4,              //审核通过，等待团长报价
    MutInsStatusAccountingPrice = 100,      //审核通过，可精准核价(团长特有)
    MutInsStatusPeopleNumberUment = 200,    //审核通过未达5人，继续邀请好友(团长特有)
    MutInsStatusToBePaid = 5,               //待支付
    MutInsStatusPaidForSelf = 6,            //自己支付成功
    MutInsStatusPaidForAll  = 101,          //全部人支付成功
    MutInsStatusGettedAgreement = 7,        //协议已出
    MutInsStatusAgreementTakingEffect = 8,  //协议生效中
    MutInsStatusGroupDissolved = 9,         //团解散
    MutInsStatusGroupExpired = 10,          //团过期
    MutInsStatusJoinFailed = 11             //入团失败
}MutInsStatus;

//key定义
#define kMutInsGroupID      @"groupID"
#define kMutInsMemberID     @"memberID"
#define kMutInsGroupName    @"groupName"

//storyboard定义
#define kMutInsGroupDetailStoryboard    @"MutualInsGroupDetail"

#endif /* MutualInsConstants_h */
