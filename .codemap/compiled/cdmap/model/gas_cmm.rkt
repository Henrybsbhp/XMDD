#lang racket
(require codemap/base)
(provide node-tree)
(import "cdmap/template/netop.cmt")
(import "cdmap/template/dataset.cmt")
(define node-list
  '(file
    (id a3c38aad-ed11-3b89-b7a5-f88762b8a7cc)
    (name "gas.cmm")
    (node
     (attr
      (*def* "获取油卡列表")
      (class GetGascardList)
      (op)
      (auth)
      (path "/user/gascard/list"))
     (node
      (attr (rsp))
      (node (id gascards) (type (array-type GasCard)) (value #f))))
    (node
     (attr
      (*def* "添加油卡")
      (class AddGascard)
      (op)
      (auth)
      (path "/user/gascard/add"))
     (node
      (attr (req))
      (node (attr (*def* "油卡卡号")) (id gascardno) (type #f) (value #f))
      (node (attr (*def* "油卡类型")) (id cardtype) (type int) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "油卡id")) (id gid) (type number) (value #f))
      (node
       (attr (*def* "当月可以充值金额"))
       (id availablechargeamt)
       (type number)
       (value #f))
      (node
       (attr (*def* "当月已经享受优惠金额"))
       (id couponedmoney)
       (type number)
       (value #f))))
    (node
     (attr
      (*def* "移除油卡")
      (class DeleteGascard)
      (op)
      (auth)
      (path "/user/gascard/del"))
     (node
      (attr (req))
      (node (attr (*def* "油卡id")) (id gid) (type number) (value #f))))
    (node
     (attr
      (*def* "获取油卡充值配置信息")
      (class GetGaschargeConfig)
      (op)
      (path "/user/gascharge/config/get"))
     (node
      (attr (rsp))
      (node (attr (*def* "描述")) (id desc) (type #f) (value #f))
      (node (attr (*def* "折扣率")) (id discountrate) (type int) (value #f))
      (node (attr (*def* "有优惠充值上限")) (id couponupplimit) (type int) (value #f))
      (node (attr (*def* "充值上限")) (id chargeupplimit) (type int) (value #f))
      (node (attr (*def* "加油公告")) (id tip) (type #f) (value #f))
      (node (attr (*def* "分期可充值金额列表")) (id supportamt) (type array) (value #f))
      (node
       (attr (*def* "折扣方案"))
       (id packages)
       (type (array-type GasChargePackage))
       (value #f))))
    (node
     (attr
      (*def* "获取油卡当月充值信息")
      (class GetGaschargeInfo)
      (op)
      (auth)
      (path "/user/gascard/chargedinfo/get"))
     (node
      (attr (req))
      (node (attr (*def* "油卡id")) (id gid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "优惠描述")) (id desc) (type #f) (value #f))
      (node
       (attr (*def* "当月可充金额"))
       (id availablechargeamt)
       (type number)
       (value #f))
      (node
       (attr (*def* "已经享受过的优惠"))
       (id couponedmoney)
       (type number)
       (value #f))))
    (node
     (attr
      (*def* "油卡充值")
      (class GascardCharge)
      (op)
      (auth)
      (path "/user/gascard/charge"))
     (node
      (attr (req))
      (node (attr (*def* "油卡id")) (id gid) (type number) (value #f))
      (node (attr (*def* "充值金额")) (id amount) (type int) (value #f))
      (node (attr (*def* "支付方式")) (id paychannel) (type int) (value #f))
      (node (attr (*def* "支付验证码")) (id vcode) (type #f) (value #f))
      (node (attr (*def* "订单id")) (id orderid) (type number) (value #f))
      (node
       (attr (*def* "是否开发票(1:开发票，0:不开)"))
       (id bill)
       (type int)
       (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "交易流水")) (id tradeid) (type #f) (value #f))
      (node (attr (*def* "记录ID")) (id orderid) (type number) (value #f))
      (node (attr (*def* "支付金额")) (id total) (type int) (value #f))
      (node (attr (*def* "优惠金额")) (id couponmoney) (type int) (value #f))))
    (node
     (attr
      (*def* "分期加油")
      (class GascardChargeByStages)
      (op)
      (auth)
      (path "/order/gascard/fqjy/charge"))
     (node
      (attr (req))
      (node (attr (*def* "油卡id")) (id cardid) (type number) (value #f))
      (node (attr (*def* "是否开发票(1:开发票，0:不开)")) (id bill) (type int) (value #f))
      (node (attr (*def* "套餐id")) (id pkgid) (type number) (value #f))
      (node (attr (*def* "每月充值金额")) (id permonthamt) (type int) (value #f))
      (node (attr (*def* "支付方式")) (id paychannel) (type int) (value #f))
      (node (attr (*def* "优惠券记录id")) (id cid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "交易流水")) (id tradeid) (type #f) (value #f))
      (node (attr (*def* "记录id")) (id orderid) (type number) (value #f))
      (node (attr (*def* "支付金额")) (id total) (type float) (value #f))
      (node (attr (*def* "实际优惠金额")) (id couponmoney) (type float) (value #f))
      (node (attr (*def* "支付完成后的提示")) (id tip) (type #f) (value #f))))
    (node
     (attr
      (*def* "取消油卡充值")
      (class CancelGascharge)
      (op)
      (auth)
      (path "/user/gascharge/cancel"))
     (node
      (attr (req))
      (node (attr (*def* "交易流水")) (id tradeid) (type #f) (value #f))))
    (node
     (attr
      (*def* "浙商支付验证码获取")
      (class GetCzbpayVcode)
      (op)
      (auth)
      (path "/czbpay/vcode/get"))
     (node
      (attr (req))
      (node (attr (*def* "银行卡记录ID")) (id cardid) (type number) (value #f))
      (node (attr (*def* "充值金额")) (id chargeamt) (type int) (value #f))
      (node (attr (*def* "油卡id")) (id gid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "订单记录id")) (id orderid) (type number) (value #f))
      (node (attr (*def* "交易流水")) (id tradeid) (type #f) (value #f))
      (node (attr (*def* "支付金额")) (id total) (type int) (value #f))
      (node (attr (*def* "优惠金额")) (id couponmoney) (type int) (value #f))))
    (node
     (attr
      (*def* "获取浙商卡当月优惠信息")
      (class GetCZBGaschargeInfo)
      (op)
      (auth)
      (path "/user/czbcard/couponinfo/get"))
     (node
      (attr (req))
      (node (attr (*def* "油卡id")) (id gid) (type number) (value #f))
      (node (attr (*def* "浙商银行卡ID")) (id cardid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node
       (attr (*def* "当月可充金额"))
       (id availablechargeamt)
       (type int)
       (value #f))
      (node (attr (*def* "已经享受过的优惠")) (id couponedmoney) (type int) (value #f))
      (node (attr (*def* "优惠描述")) (id desc) (type #f) (value #f))
      (node (attr (*def* "折扣率")) (id discountrate) (type int) (value #f))
      (node (attr (*def* "优惠上限")) (id couponupplimit) (type int) (value #f))
      (node
       (attr (*def* "浙商卡已享受优惠"))
       (id czbcouponedmoney)
       (type int)
       (value #f))
      (node (attr (*def* "加油上限")) (id chargeupplimit) (type int) (value #f))))
    (node
     (attr
      (*def* "获取浙商默认打折信息")
      (class GetCZBCouponDefInfo)
      (op)
      (path "/user/czbcoupon/defaultinfo/get"))
     (node
      (attr (rsp))
      (node (attr (*def* "描述")) (id desc) (type #f) (value #f))))
    (node
     (attr
      (*def* "获取用户加油记录列表(按payedtime降序)")
      (class GetGaschargeRecordList)
      (op)
      (auth)
      (path "/user/gascharge/his/get"))
     (node
      (attr (req))
      (node (attr (*def* "支付时间戳")) (id payedtime) (type longlong) (value #f)))
     (node
      (attr (rsp))
      (node
       (attr (*def* "加油记录列表"))
       (id gaschargeddatas)
       (type (array-type GasChargeRecord))
       (value #f))
      (node (attr (*def* "当年充值总额")) (id charegetotal) (type int) (value #f))
      (node (attr (*def* "总计优惠额")) (id couponedtotal) (type int) (value #f))))
    (node
     (attr (*def* "油卡信息") (class GasCard) (data))
     (node (attr (*def* "油卡id")) (id gid) (type number) (value #f))
     (node (attr (*def* "油卡卡号")) (id gascardno) (type #f) (value #f))
     (node
      (attr (*def* "油卡类型 1：石化  2：石油"))
      (id cardtype)
      (type int)
      (value #f))
     (node
      (attr (*def* "当月可充金额"))
      (id availablechargeamt)
      (type number)
      (value #f))
     (node
      (attr (*def* "已经享受过的优惠"))
      (id couponedmoney)
      (type number)
      (value #f))
     (node (attr (*def* "油卡优惠描述")) (id desc) (type #f) (value #f)))
    (node
     (attr (*def* "加油记录") (class GasChargeRecord) (data))
     (node (attr (*def* "支付时间")) (id payedtime) (type longlong) (value #f))
     (node (attr (*def* "油卡名称")) (id gascardname) (type #f) (value #f))
     (node (attr (*def* "油卡卡号")) (id gascardno) (type #f) (value #f))
     (node (attr (*def* "油卡类型")) (id cardtype) (type int) (value #f))
     (node
      (attr (*def* "记录状态 (2:支付成功 3:充值成功 4:充值失败)"))
      (id status)
      (type int)
      (value #f))
     (node (attr (*def* "状态说明")) (id statusdesc) (type #f) (value #f))
     (node (attr (*def* "支付金额")) (id paymoney) (type int) (value #f))
     (node (attr (*def* "充值金额")) (id chargemoney) (type int) (value #f)))
    (node
     (attr (*def* "分期加油配置信息") (class GasChargePackage) (data))
     (node (attr (*def* "折扣率")) (id discount) (type #f) (value #f))
     (node (attr (*def* "分期月份")) (id month) (type int) (value #f))
     (node (attr (套餐id)) (id pkgid) (type number) (value #f)))))
(current-nodes (append (current-nodes) (list node-list)))
(when (pair? (current-templates))
  (for-each
   (lambda (temp)
     (parameterize
      ((current-output-port empty-output-port)
       (temp-output-port empty-output-port)
       (current-node-maker #f))
      (void ((template-parser temp) (current-nodes)))))
   (current-templates)))
(define node-tree
  (if (pair? (current-nodes))
    (filter-map
     (lambda (name)
       (spath-0 (current-nodes) (format "/file/[name='~a']" name)))
     (current-export-info))
    null))
