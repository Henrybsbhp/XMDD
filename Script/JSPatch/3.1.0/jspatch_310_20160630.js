require('JPEngine').addExtensions(['JPMacroSupport'])
require('GetGeneralActivityLefttimeOp')

defineClass('GetGeneralActivityLefttimeOp',[payChannel,tradeNum,rsp_payInfoModel],{

  rac_postRequest:function () {
    
    self.setReq__method("/general/activity/lefttime/get");
    var params = require('NSMutableDictionary').dictionary();
    params.setObject_forKey(self.tradeType(),"tradetype");
    params.setObject_forKey(self.payChannel(),"paychannel");
    params.setObject_forKey(self.tradeNum(),"tradeno");

    var signal = self.rac__invokeWithRPCClient_params_security(require('NetworkManager').sharedManager(),params,true);
    return signal;
  }

  parseResponseObject:function(rspobj)
  {
    self.setRsp_lefttime(rspObj.integerParamForName("lefttime"));
    self.setRsp_payInfoModel(require('PayInfoModel').payInfoWithJSONResponse(rspObj.paramForName("payinfo"));

    return self;
  }
});

defineClass('PaymentCenterViewController',{

  setupPayBtn:function () {
    
    self.payBtn().rac__signalForControlEvents(1<<6).subscribeNext(block("UIButton *",function(x){

        var op = require('GetGeneralActivityLefttimeOp').alloc();
        op.setTradeType(self.tradeType());
        op.setPayChannel(self.paychannel());
        op.setTradeNum(self.tradeNo());

        op.rac__postRequest().initially
    }));
  }
});
