#lang racket
(require codemap/base)
(provide node-tree)
(import "cdmap/template/netop.cmt")
(import "cdmap/template/dataset.cmt")
(define node-list
  '(file
    (id a81aef9d-70e3-3a4f-bada-b11a3456695e)
    (name "mutualIns.cmm")
    (node
     (attr
      (*def* "团申请")
      (class ApplyCooperationGroup)
      (op)
      (auth)
      (path "/cooperation/group/apply"))
     (node (attr (rsp)) (node (id name) (type #f) (value #f))))
    (node
     (attr
      (*def* "创建团")
      (class AddCooperationGroupJoin)
      (op)
      (auth)
      (path "/cooperation/group/join/add"))
     (node (attr (req)) (node (id name) (type #f) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "暗号")) (id cipher) (type #f) (value #f))
      (node (attr (*def* "团ID")) (id groupid) (type number) (value #f))))
    (node
     (attr
      (*def* "通过暗号查询团")
      (class SearchCooperationGroup)
      (op)
      (auth)
      (path "/cooperation/group/search"))
     (node
      (attr (req))
      (node (attr (*def* "暗号")) (id cipher) (type #f) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "团名称")) (id name) (type #f) (value #f))
      (node (attr (*def* "团长昵称")) (id creatorname) (type #f) (value #f))
      (node (attr (*def* "团ID")) (id groupid) (type number) (value #f))))
    (node
     (attr
      (*def* "申请加入一个团")
      (class ApplyCooperationGroupJoin)
      (op)
      (auth)
      (path "/cooperation/group/join/apply"))
     (node
      (attr (req))
      (node (attr (*def* "团ID")) (id groupid) (type number) (value #f))
      (node (attr (*def* "爱车记录ID")) (id carid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "团员记录ID")) (id memberid) (type number) (value #f))))
    (node
     (attr
      (*def* "照片信息完善")
      (class UpdateCooperationIdlicenseInfo)
      (op)
      (auth)
      (path "/cooperation/idlicense/info/update"))
     (node
      (attr (req))
      (node (attr (*def* "身份证地址")) (id idurl) (type #f) (value #f))
      (node (attr (*def* "行驶证地址")) (id licenseurl) (type #f) (value #f))
      (node (attr (*def* "最近一次保险公司名字")) (id firstinscomp) (type #f) (value #f))
      (node (attr (*def* "再上一次保险公司名字")) (id secinscomp) (type #f) (value #f))
      (node (attr (*def* "团员记录ID")) (id memberid) (type #f) (value #f))
      (node (attr (*def* "商业险到期日")) (id insenddate) (type #f) (value #f))))
    (node
     (attr
      (*def* "保险信息完善")
      (class UpdateCooperationInsInfo)
      (op)
      (auth)
      (path "/cooperation/insurance/info/update"))
     (node
      (attr (req))
      (node (attr (*def* "投保保险信息列表")) (id inslist) (type #f) (value #f))
      (node (attr (*def* "团员记录ID")) (id memberid) (type #f) (value #f))
      (node (attr (*def* "是否愿意代买")) (id proxybuy) (type #f) (value #f))))
    (node
     (attr
      (*def* "照片信息完善页面信息获取")
      (class GetCooperationIdlicenseInfo)
      (op)
      (auth)
      (path "/cooperation/idlicense/info/get"))
     (node
      (attr (req))
      (node (attr (*def* "团ID")) (id groupid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "行驶证图片")) (id licenseurl) (type #f) (value #f))
      (node (attr (*def* "身份证图片")) (id idnourl) (type #f) (value #f))
      (node (attr (*def* "上期保险公司名字")) (id lstinscomp) (type #f) (value #f))
      (node
       (attr (*def* "商业险到期日") (date DT10))
       (id insenddate)
       (type #f)
       (value #f))))
    (node
     (attr
      (*def* "团详情查看")
      (class GetCooperationMygroupDetail)
      (op)
      (auth)
      (path "/cooperation/mygroup/detail/get"))
     (node
      (attr (req))
      (node (attr (*def* "团员记录ID")) (id memberid) (type number) (value #f))
      (node (attr (*def* "团ID")) (id groupid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node
       (attr (*def* "团员其他人的信息"))
       (id members)
       (type (array-type MutualInsMemberInfo))
       (value #f))
      (node (attr (*def* "各阶段有效时间")) (id timeperiod) (type #f) (value #f))
      (node (attr (*def* "自己记录状态描述")) (id selfstatusdesc) (type #f) (value #f))
      (node (attr (*def* "控制状态栏显示")) (id barstatus) (type int) (value #f))
      (node (id status) (type int) (value #f))
      (node (attr (*def* "协议记录ID")) (id contractid) (type #f) (value #f))
      (node (attr (*def* "剩余时间倒计时提示语")) (id timetip) (type #f) (value #f))
      (node (attr (*def* "池子最大金额")) (id totalpoolamt) (type #f) (value #f))
      (node (attr (*def* "池子当前金额")) (id presentpoolamt) (type #f) (value #f))
      (node
       (attr (*def* "各种状态倒计时剩余时间"))
       (id lefttime)
       (type longlong)
       (value #f))
      (node
       (attr (*def* "没有车直接报价按钮是否显示"))
       (id pricebuttonflag)
       (type int)
       (value #f))
      (node (attr (*def* "按钮名字")) (id buttonname) (type #f) (value #f))
      (node
       (attr (*def* "是否当前人是团长本人"))
       (id ifgroupowner)
       (type bool)
       (value #f))
      (node (attr (*def* "团记录ID")) (id groupid) (type number) (value #f))))
    (node
     (attr
      (*def* "互助协议查看")
      (class GetCooperationContractDetail)
      (op)
      (auth)
      (path "/cooperation/contract/detail/get"))
     (node
      (attr (req))
      (node (attr (*def* "协议记录ID")) (id contractid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node
       (attr (*def* "协议详情"))
       (id contractorder)
       (type MutualInsContract)
       (value #f))))
    (node
     (attr
      (*def* "更新地址信息")
      (class UpdateCooperationContractDeliveryinfo)
      (op)
      (auth)
      (path "/cooperation/contract/deliveryinfo/update"))
     (node
      (attr (req))
      (node (attr (*def* "协议记录ID")) (id contractid) (type number) (value #f))
      (node (attr (*def* "联系人名")) (id contactname) (type #f) (value #f))
      (node (attr (*def* "联系人手机")) (id contactphone) (type #f) (value #f))
      (node (attr (*def* "联系地址")) (id address) (type #f) (value #f))))
    (node
     (attr
      (*def* "理赔记录列表")
      (class GetCooperationClaimsList)
      (op)
      (auth)
      (path "/cooperation/claims/list"))
     (node
      (attr (rsp))
      (node
       (attr (*def* "理赔详情"))
       (id claimlist)
       (type (array-type MutualInsClaimInfo))
       (value #f))))
    (node
     (attr
      (*def* "查看成员互助池信息")
      (class GetCooperationMemberDetail)
      (op)
      (auth)
      (path "/cooperation/member/detail/get"))
     (node
      (attr (req))
      (node (attr (*def* "团员记录ID")) (id memberid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "车牌")) (id licensenumber) (type #f) (value #f))
      (node (attr (*def* "车主手机")) (id phone) (type #f) (value #f))
      (node (attr (*def* "品牌车系信息")) (id carbrand) (type #f) (value #f))
      (node (attr (*def* "互助资金")) (id sharemoney) (type float) (value #f))
      (node (attr (*def* "所占比例")) (id rate) (type #f) (value #f))
      (node (attr (*def* "理赔次数")) (id claimcount) (type int) (value #f))
      (node (attr (*def* "可返金额")) (id returnmoney) (type float) (value #f))
      (node (attr (*def* "理赔金额")) (id claimamount) (type float) (value #f))))
    (node
     (attr
      (*def* "退出团")
      (class ExitCooperation)
      (op)
      (auth)
      (path "/cooperation/member/exit"))
     (node
      (attr (req))
      (node (attr (*def* "团员记录ID")) (id memberid) (type number) (value #f))))
    (node
     (attr
      (*def* "团长报价")
      (class ApplyCooperationPremiumCalculate)
      (op)
      (auth)
      (path "/cooperation/premium/calculate/apply"))
     (node
      (attr (req))
      (node (attr (*def* "团记录ID")) (id groupid) (type number) (value #f))))
    (node
     (attr
      (*def* "协议订单支付")
      (class PayCooperationContractOrder)
      (op)
      (auth)
      (path "/cooperation/contract/order/pay"))
     (node
      (attr (req))
      (node (attr (*def* "协议记录ID")) (id contractid) (type number) (value #f))
      (node (attr (*def* "是否代买交强险")) (id proxybuy) (type number) (value #f))
      (node (attr (*def* "优惠券ID")) (id cid) (type number) (value #f))
      (node (attr (*def* "支付渠道")) (id paychannel) (type #f) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "实付金额")) (id total) (type float) (value #f))
      (node (attr (*def* "交易号")) (id tradeno) (type #f) (value #f))))
    (node
     (attr
      (*def* "获取互助首页文案信息")
      (class GetCooperationConfi)
      (op)
      (path "/cooperation/config/get"))
     (node
      (attr (rsp))
      (node (attr (*def* "匹配团的名字")) (id autogroupname) (type #f) (value #f))
      (node (attr (*def* "自组团的名字")) (id selfgroupname) (type #f) (value #f))
      (node (attr (*def* "匹配团描述")) (id autogroupdesc) (type #f) (value #f))
      (node (attr (*def* "自组团描述")) (id selfgroupdesc) (type #f) (value #f))))
    (node
     (attr
      (*def* "理赔申请")
      (class ApplyCooperationClaim)
      (op)
      (auth)
      (path "/cooperation/claim/apply"))
     (node
      (attr (req))
      (node (attr (*def* "协议记录ID")) (id licensenumber) (type #f) (value #f))
      (node (attr (*def* "现场图片")) (id scene) (type array) (value #f))
      (node (attr (*def* "车辆损失图片")) (id cardamage) (type array) (value #f))
      (node (attr (*def* "车辆信息图片")) (id carinfo) (type array) (value #f))
      (node (attr (*def* "Id信息图片")) (id idinfo) (type array) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "实付金额")) (id total) (type float) (value #f))
      (node (attr (*def* "交易号")) (id tradeno) (type #f) (value #f))))
    (node
     (attr
      (*def* "获取可以理赔的车辆列表,获取车列表，在快速理赔的时候需要选择一辆车")
      (class GetCooperationMyCar)
      (op)
      (auth)
      (path "/cooperation/mycar/get"))
     (node
      (attr (rsp))
      (node
       (attr (*def* "车牌,字符串数组"))
       (id licensenumbers)
       (type array)
       (value #f))))
    (node
     (attr
      (*def* "获取理赔页面配置信息")
      (class GetCoorperationClaimConfig)
      (op)
      (path "/cooperation/claim/config/get"))
     (node
      (attr (rsp))
      (node (attr (*def* "现场照片注意事项描述")) (id scenedesc) (type #f) (value #f))
      (node
       (attr (*def* "车损信息注意事项描述"))
       (id cardamagedesc)
       (type #f)
       (value #f))
      (node (attr (*def* "车辆信息注意事项描述")) (id carinfodesc) (type #f) (value #f))
      (node
       (attr (*def* "身份证信息注意事项描述"))
       (id idinfodesc)
       (type #f)
       (value #f))))
    (node
     (attr
      (*def* "理赔详情")
      (class GetCooperationClaimDetail)
      (op)
      (auth)
      (path "/cooperation/claim/detail"))
     (node
      (attr (req))
      (node (attr (*def* "理赔记录ID")) (id claimid) (type number) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "statusdesc")) (id statusdesc) (type #f) (value #f))
      (node (attr (*def* "status")) (id status) (type #f) (value #f))
      (node
       (attr (*def* "事故时间") (date DT10))
       (id accidenttime)
       (type #f)
       (value #f))
      (node (attr (*def* "事故地点")) (id accidentaddress) (type #f) (value #f))
      (node (attr (*def* "事故责任方")) (id chargepart) (type #f) (value #f))
      (node (attr (*def* "车损概况")) (id cardmgdesc) (type #f) (value #f))))
    (node
     (attr
      (*def* "添加一张理赔银行卡")
      (class AddCooperationClaimBankcard)
      (op)
      (auth)
      (path "/cooperation/claim/bankcard/add"))
     (node
      (attr (req))
      (node (attr (*def* "理赔记录ID")) (id cardno) (type #f) (value #f))
      (node (attr (*def* "发卡行")) (id issuebank) (type #f) (value #f)))
     (node
      (attr (rsp))
      (node (attr (*def* "银行卡记录ID")) (id cardid) (type #f) (value #f))))
    (node
     (attr
      (*def* "获取理赔银行卡列表")
      (class GetCooperationClaimBankcard)
      (op)
      (auth)
      (path "/cooperation/claim/bankcard/get"))
     (node (attr (rsp)) (node (id cardlist) (type array) (value #f))))
    (node
     (attr (*def* "团员信息") (class MutualInsMemberInfo) (data))
     (node (attr (*def* "车牌")) (id licensenumber) (type #f) (value #f))
     (node (attr (*def* "车的品牌logo地址")) (id brandurl) (type #f) (value #f))
     (node (attr (*def* "团员记录ID")) (id memberid) (type number) (value #f))
     (node (attr (*def* "其他人的状态描述")) (id statusdesc) (type #f) (value #f)))
    (node
     (attr (*def* "协议详情") (class MutualInsContract) (data))
     (node (attr (*def* "协议记录ID")) (id contractid) (type number) (value #f))
     (node
      (attr (*def* "协议状态 1：待支付，2：支付完成，3待协议寄出。4协议已寄出"))
      (id status)
      (type int)
      (value #f))
     (node (attr (*def* "受益人")) (id insurancedname) (type #f) (value #f))
     (node (attr (*def* "车牌")) (id licencenumber) (type #f) (value #f))
     (node (attr (*def* "证件号")) (id idno) (type #f) (value #f))
     (node (attr (*def* "共计保费")) (id total) (type float) (value #f))
     (node (attr (*def* "优惠金额")) (id couponmoney) (type float) (value #f))
     (node
      (attr (*def* "保险列表 {insname:sum}"))
      (id inslist)
      (type array)
      (value #f))
     (node
      (attr (*def* "交强险期限,如果查出了该车可以代买交强险则有值"))
      (id insperiod)
      (type #f)
      (value #f))
     (node (attr (*def* "交强险")) (id forcefee) (type float) (value #f))
     (node (attr (*def* "车船税")) (id taxshipfee) (type float) (value #f))
     (node (attr (*def* "协议期限")) (id inscomp) (type array) (value #f))
     (node (attr (*def* "投保月份数")) (id totalmonth) (type #f) (value #f)))
    (node
     (attr (*def* "理赔记录详情") (class MutualInsClaimInfo) (data))
     (node (attr (*def* "理赔记录ID")) (id claimid) (type number) (value #f))
     (node
      (attr (*def* "理赔详细状态 1：理赔记录待处理 2：待确认金额 3：理赔待打款 4：理赔完成打款，已结束"))
      (id detailstatus)
      (type int)
      (value #f))
     (node (attr (*def* "理赔状态描述")) (id detailstatusdesc) (type #f) (value #f))
     (node (attr (*def* "理赔概要状态描述")) (id statusdesc) (type #f) (value #f))
     (node (attr (*def* "事故描述")) (id accidentdesc) (type #f) (value #f))
     (node (attr (*def* "理赔费用")) (id claimfee) (type float) (value #f))
     (node
      (attr (*def* "记录最近更新时间") (date DT10))
      (id lstupdatetime)
      (type #f)
      (value #f)))))
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
