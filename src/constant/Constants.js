"use strict";

const constants = {
    MutualIns: {
        Status: {
            NoCar: 0,                     // 团长无车
            NeedDriveLicense: 1,          // 完善行驶证信息
            NeedInsList: 2,               // 完善保险列表
            UnderReview: 3,               // 资料审核中
            NeedQuote: 4,                 // 审核通过，等待团长报价
            ToBePaid: 5,                  // 待支付
            PaidForSelf: 6,               // 自己支付成功
            GettedAgreement: 7,           // 协议已出
            AgreementTakingEffect: 8,     // 协议生效中
            GroupDissolved: 9,            // 团结散
            GroupExpired: 10,             // 团过期
            JoinFailed: 11,               // 入团失败
            NeewReviewAgain: 20,          // 资料审核失败，需要重新提交
            ReviewFailed: 21,             // 资料审核失败，无法入团
            AccountingPrice: 100,         // 审核通过，可精准核价(团长特有)
            PaidForAll: 101,              // 全部人支付成功
            PeopleNumberUment: 101,       // 审核通过未达5人，继续邀请好友(团长特有)
        },
    },
    Link: {
        Phone: 'tel://4007111111',
        MutualInsUsingHelp: "http://xiaomadada.com/xmdd-web/xmdd-app/qa.html",
        MutualInsDetailUsingHelp: "http://www.xiaomadada.com/apphtml/tuan-help.html",
        MutualInsCompensation: "xmdd://j?t=coincldtlo",
        MutualInsCalculate: 'xmdd://j?t=coinscalc&channel=apphzsy',
        MutualInsOrder: id => 'xmdd://j?t=coinso&id=' + id,
        MutualInsInvite: id => 'xmdd://j?t=coinvite&id=' + id,
    }
};

export default constants;