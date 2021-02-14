Class web.DHCPE.NetPre.Pay Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

//w ##class(web.DHCPE.NetPre.Pay).Main("1^N",'0000000057',263)

ClassMethod Main(NetPreID, RegNo, PayAmount)
{
	s UserID="1"  ;默认的操作人员
	s InvUserID="933" ;默认的有发票的操作员
	q:NetPreID="" "-1^网上预约ID不能为空"
	s Type=$P(NetPreID,"^",2)
	s:Type="" Type="N"
	s NetPreID=$P(NetPreID,"^",1)
	i Type="N"
	{
		s NetRegNo=$LG(^User.DHCPENetPreRecordD(NetPreID),2)
		q:(NetRegNo="")&&(RegNo="") "-1^登记号不能为空"
		s:NetRegNo="" NetRegNo=RegNo
		s:RegNo="" RegNo=NetRegNo
		q:RegNo'=NetRegNo "-1^预约记录对应的登记号和传入登记号不一致"
		s PatID=$O(^PAPERi("PAPMI_PatNo",NetRegNo,0))
		q:PatID="" "-1^登记号不存在"
		s PreID=$LG(^User.DHCPENetPreRecordD(NetPreID),13)
	}
	elseif Type="A"
	{
		s IADM=$O(^DHCPEIADM(0,"PAADM",NetPreID,0))
		q:IADM="" "-1^预约记录不存在"
		s PatID=$P(^PAADM(NetPreID),"^",1)
		s NetRegNo=$P(^PAPER(PatID,"PAT",1),"^",1)
		;q:(NetRegNo="")&&(RegNo="") "-1^登记号不能为空"
		q:RegNo'=NetRegNo "-1^预约记录对应的登记号和传入登记号不一致"
		s PreID=$P(^DHCPEIADM(IADM),"^",4)
	}
	elseif Type="P"
	{
		s PreID=NetPreID
	}
	//插入his预约记录、套餐
	i PreID=""
	{
		s PreIBaseID=$O(^DHCPEPreIBI(0,"PAPMINo",NetRegNo,0))
		i PreIBaseID="" d
		.d ##class(web.DHCPE.PreIBIUpdate).UpdatePEInfoByHis(NetRegNo,UserID)   ;需要修改源方法,增加一个用户的参数
		s PreIBaseID=$O(^DHCPEPreIBI(0,"PAPMINo",NetRegNo,0))
		q:PreIBaseID="" "-1^插入体检基本信息表错误"
		;"^1261^^^14/10/70^14/10/70^^^PREREG^N^N^N^^N^N^^DC^ID^1^^^^^^^^^0^0^^1^^^6"
		s PreDate=$LG(^User.DHCPENetPreRecordD(NetPreID),9)
		s:PreDate'="" PreDate=$ZD(PreDate,4) 
		s InString = "^"_PreIBaseID_"^^^"_PreDate_"^"_PreDate_"^^^"_"PREREG^N^N^N^^N^N^^DC^ID^1^^^^^^^^^0^0^^1" ;需要根据具体库确定具体串
		s InString = InString _"$$"_NetPreID
		s LocID=$LG(^User.DHCPENetPreRecordD(NetPreID),17)
		s VIPDesc=$LG(^User.DHCPENetPreRecordD(NetPreID),16)
		s VIPLevel=##class(web.DHCPE.VIPLevel).GetVIPIDByDesc(VIPDesc)  ;需要添加
		s $P(InString,"^",19)=VIPLevel
		s ret=##Class(web.DHCPE.PreIADM).Save("","",InString,UserID,LocID)  ;需要增加用户和科室的参数
		q:$P(ret,"^",1)'=0 "-1^插入his预约记录错误"
		s PreID=$P(ret,"^",2)
		s SetID=$LG(^User.DHCPENetPreRecordD(NetPreID),8)
		i SetID'="" 
		{	
			s ret=##class(web.DHCPE.PreItemList).IInsertItem(PreID,"PERSON","PRE","",SetID,UserID)
			q:ret'="" "-1^插入医嘱套错误"
		} 
	}
	else
	{
		s LocID=$P(^DHCPEPreIADM(PreID),"^",26)
	}
	s Status=$P(^DHCPEPreIADM(PreID),"^",8)
	q:Status="CANCELPE" "-1^his已经取消体检"
	//his登记
	i Status="PREREG"
	{
		s ret=##class(web.DHCPE.DHCPEIAdm).UpdateIADMInfo(PreID, "2",0,UserID)  ;需要添加(修改)此方法，有可能其中一些用到用户的地方也需要修改
		q:ret'="0" "-1^his登记错误"
	}
	//his结算
	b ;PreID
	s AuditInfo=..GetNoPayedAudit(PreID)
	s PreAuditIDs=$P(AuditInfo,"^",1)
	s AuditAmt=$P(AuditInfo,"^",2)
	q:PreAuditIDs="" "-1^没有待收费的记录"
	q:+AuditAmt'=PayAmount "-1^传入金额和his金额不一致"
	s PayModeInfo="1,"_PayAmount_"#"     ;需要设置支付宝支付方式id
	s InvInfo=##class(web.DHCPE.DHCPEPAY).getcurinvno(InvUserID)
	s CurInvNo=$P(InvInfo,"^",1)_"^^1"  ;InvNo_"^^1"  需要修改其中^1是控制不打印发票的
	s invId=$P(InvInfo,"^",2)
	s peAdmType="I"
	s peAdmId=$O(^DHCPEIADM(0,"CRMADM",PreID,0))   ;DHCPEIADM
	s listFlag="1"
	;以下调用需要根据项目实际情况调整参数  方法里面需要再调用计费方法，插入计费发票信息
	s ret=##class(web.DHCPE.Cashier).Cashier("","",PreAuditIDs,"",PayAmount,PayModeInfo,InvUserID,LocID,CurInvNo,invId,peAdmType,peAdmId,listFlag,0)
	s Flag=$P(ret,"^",1)
	s InvID=$P(ret,"^",2)
	q:Flag'="" "-1^"_ret
	q "0^"_InvID
}

ClassMethod GetNoPayedAudit(PreIADM)
{
	s RetAudit=""
	s TotalAmt=0
	s AuditID=""
	f  s AuditID=$O(^DHCPEPreA(0,"CRMADM","I",PreIADM,AuditID)) q:AuditID=""  d
	.s PayFlag=$P(^DHCPEPreA(AuditID),"^",14)
	.q:PayFlag="CHARGED"
	.s Amt=$P(^DHCPEPreA(AuditID),"^",9)
	.q:+Amt=0
	.s UseFlag=$P(^DHCPEPreA(AuditID),"^",21)
	.q:UseFlag="NU"
	.i RetAudit="" d
	..s RetAudit=AuditID
	.e  d
	..s RetAudit=RetAudit_","_AuditID
	.s TotalAmt=TotalAmt+Amt
	s TotalAmt=$J(TotalAmt,"",2)
	q RetAudit_"^"_TotalAmt
}

//w ##class(web.DHCPE.NetPre.Pay).GetHisTradNo("")

ClassMethod GetHisTradNo(Input As %String)
{
	n (Input)
	s:Input="" Input="<Request><phoneNo>18610513055</phoneNo><terminalId>010</terminalId><terminalType>01</terminalType><hospitalId>2</hospitalId><patientCard></patientCard><patientId>58</patientId><admId></admId><userCode>tj</userCode><patAmt>200</patAmt></Request>"
	s $ZT="GetHisTradNoErr"
	s inputObj=##class(DHCAliPay.DHCEntity.PCA.AliPayRequest).%New()
    d inputObj.XMLNodeDeserialize(.inputObj,"Request",Input)
    s CardNO=inputObj.patientCard
    s TerminalId=inputObj.terminalId
    s TerminalType=inputObj.terminalType
    s HospitalId=inputObj.hospitalId 
    s PhoneNo=inputObj.phoneNo
    s PatientId=inputObj.patientId 
    s AdmInfo=inputObj.admId
    s UserCode=inputObj.userCode
    s PatPaySum=inputObj.patAmt
    d inputObj.%Close() 
    s outputObj=##class(DHCAliPay.DHCEntity.PCA.HisTradeNoResponse).%New()
    s OutputXML=""  
    i UserCode="" s UserCode="alipay001"
	s TradeType="C"
	s:UserCode'="" UserCode=$$ALPHAUP^SSUTIL4(UserCode)
	s:UserCode'="" Userid=$o(^SSU("SSUSR",0,"SSUSR_Initials",UserCode,""))
	s gLoc=$p($g(^SSU("SSUSR",Userid)),"^",4)
	s Grup=$p($g(^SSU("SSUSR",Userid)),"^",5)
	s OPGS=$o(^DHCOPGSi("GS",0,"GSDR",Grup,""))
	s Expstr=Userid_"^3^OP"_"^"_PatPaySum ;user^3^交易来源^金额^原订单号
	i HospitalId="" s HospitalId=##class(web.UDHCHospitalGroup).GetHospitalIDByLocID(gLoc) ;根据科室取院区 
	i (AdmInfo="")&&(PatientId="")
	{
		s outputObj.ResultCode=-1
		s outputObj.ErrorMsg="就诊不存在,无法生成订单号"
		d outputObj.XMLExportToString(.OutputXML,"Response")
		d outputObj.%Close()
		q OutputXML
	}
	i PatientId="" s PatientId=$P(^PAADM(AdmInfo),"^",1)
	s AdmInfo=""
	;w ##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).SetHisTradeNoInfo("","58","","C","2","933^3^HP^200")
	s rtn=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).SetHisTradeNoInfo(AdmInfo,PatientId,CardNO,TradeType,HospitalId,Expstr)
	b ;rtn
	i (+rtn'=0) {
		s outputObj.ResultCode=-2
	  	s outputObj.ErrorMsg="生成订单号失败!"
		d outputObj.XMLExportToString(.OutputXML,"Response")
		d outputObj.%Close()
		q OutputXML
	}
	s HisTradeNo=$p(rtn,"^",3)
	s HisTradeAdm=$p(rtn,"^",4)
	s HisTradeAmt=$p(rtn,"^",5)
	s HisTradeAmt=$fn(HisTradeAmt,"",2)
	s outputObj.ResultCode=0
	s outputObj.ErrorMsg="生成订单号成功!"
	s outputObj.AdmId=HisTradeAdm
	s outputObj.PatientId=PatientId
	s outputObj.HisTradeNo=HisTradeNo
	s outputObj.HisTradeAmt=HisTradeAmt
	d outputObj.XMLExportToString(.OutputXML,"Response")
	d outputObj.%Close()
	q OutputXML
GetHisTradNoErr	
	s outputObj=##class(DHCAliPay.DHCEntity.PCA.HisTradeNoResponse).%New()
   	s outputObj.ResultCode=-10
   	s outputObj.ErrorMsg="程序处理出错:"_$ZERROR
  	s OutputXML=""
   	d outputObj.XMLExportToString(.OutputXML,"Response")
   	d outputObj.%Close()
	q OutputXML
}

//w ##class(web.DHCPE.NetPre.Pay).UpdateTradNo("")

ClassMethod UpdateTradNo(Input As %String)
{
	n (Input)
	s $zt="UpdateTradNoErr"
	s err=0,HospDR=""
    s inputObj=##class(DHCAliPay.DHCEntity.PCA.AliPayRequest).%New()
	s AliTradeInfoObj=##class(DHCAliPay.DHCEntity.PCA.BankPayResult).%New()
    d inputObj.XMLNodeDeserialize(.inputObj,"Request",Input)
    s CardNO=inputObj.patientCard
    s TerminalId=inputObj.terminalId
    s TerminalType=inputObj.terminalType
    s HospitalId=inputObj.hospitalId 
    s PhoneNo=inputObj.phoneNo
    s PatientId=inputObj.patientId 
    s AdmInfo=inputObj.admId
    s UserCode=inputObj.userCode
    s PatPaySum=inputObj.patAmt 
    s HisTradeNo=inputObj.hisTradeNo
   
    s AliTradeInfoObj=inputObj.bankTradeInfo
    b ;支付宝返回信息
    s AliPayResultCode=AliTradeInfoObj.ResultCode ;交易结果,错误代码表0000：成功
    s AliPayRevTranFlag=AliTradeInfoObj.RevTranFlag ;正反交易标志0-扣费，1-退费
    s AliPayTradeNo=AliTradeInfoObj.BankTradeNo ;支付宝交易流水号
    s AliPayAccountNo=AliTradeInfoObj.PayCardNo ;支付宝账户
    s AliPayPaySum=AliTradeInfoObj.PayAmt ;扣款总金额
    s AliPayHISTradeNo=AliTradeInfoObj.HISTradeNo ;HIS流水号--订单号
    s AliPayPatientID=AliTradeInfoObj.PatientID ;病人登记号
    s AliPayOrgHISTradeNo=AliTradeInfoObj.OrgHISTradeNo ;原交易流水号(暂不用)
    s AliPayTradeDateTime=AliTradeInfoObj.BankDate
    s AliPayTradeDate=$p(AliPayTradeDateTime," ",1)
    s AliPayTradeTime=$p(AliPayTradeDateTime," ",2)
    i AliPayTradeDate'="" Set AliPayTradeDate=$zdh(AliPayTradeDate,3)
    i AliPayTradeTime'="" Set AliPayTradeTime=$zth(AliPayTradeTime,1)
    ;交易信息
 	s AliPayTradeInfo=AliPayHISTradeNo_"^"_AliPayPaySum_"^"_AliPayTradeNo_"^"_AliPayAccountNo_"^^"_AliPayTradeDate_"^"_AliPayTradeTime
    d AliTradeInfoObj.%Close()
    d inputObj.%Close()
    ;获取必要信息
    i UserCode="" Set UserCode="alipay001"
    ;Set UserCode="alipay001"
	i TradeType="C"
	s:UserCode'="" UserCode=$$ALPHAUP^SSUTIL4(UserCode)
	s:UserCode'="" Userid=$o(^SSU("SSUSR",0,"SSUSR_Initials",UserCode,""))
	s gLoc=$p($g(^SSU("SSUSR",Userid)),"^",4)
	s Grup=$p($g(^SSU("SSUSR",Userid)),"^",5)
	s OPGS=$o(^DHCOPGSi("GS",0,"GSDR",Grup,""))
	s Expstr=Userid_"^3^OP"
	i HospitalId="" s HospitalId=##class(web.UDHCHospitalGroup).GetHospitalIDByLocID(gLoc) ;根据科室取院区 
	
	s ChargeObj=##class(DHCAliPay.DHCEntity.PCA.AutoPayChargeResult).%New()
    s OutputXML=""
    s Paymode=$o(^CT("CTPM",0,"Code","ALIPAY",""))
    s myPayinfo=Paymode_"^^^^"
    If (HisTradeNo=""){
		s ChargeObj.ResultCode=-2
		s ChargeObj.ErrorMsg="订单号不能为空"
		d ChargeObj.XMLExportToString(.OutputXML,"Response")
		d ChargeObj.%Close()
		q OutputXML
    }
    s IBPRowid=$o(^DHCINVALITPi(0,"PTN",HisTradeNo,""))
	s IBPRc=""
	i (+IBPRowid'=0) {
		s IBPRc=$p(^DHCINVALITP(IBPRowid),"^",1)
		i (IBPRc="0000"){
			s ChargeObj.ResultCode=-4
	  		s ChargeObj.ErrorMsg="此订单已经付款成功"
	   		d ChargeObj.XMLExportToString(.OutputXML,"Response")
	   		d ChargeObj.%Close()
	   		q OutputXML
		}
	}else {
		s ChargeObj.ResultCode=-3
	  	s ChargeObj.ErrorMsg="无效订单号"
	  	b ;1
	  	s rollrtn=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).RollBack(AliPayTradeInfo,Userid,TradeType,"",Paymode,"无效订单号",$g(AdmInfo))
	   	d ChargeObj.XMLExportToString(.OutputXML,"Response")
	   	d ChargeObj.%Close()
	   	q OutputXML
	}
	If (+AdmInfo=0) {
		s ChargeObj.ResultCode=-1
		s ChargeObj.ErrorMsg="就诊记录不存在,不能结算"
		b ;2
		s rollrtn=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).RollBack(AliPayTradeInfo,Userid,TradeType,"",Paymode,"就诊记录不存在",$g(AdmInfo))
		d ChargeObj.XMLExportToString(.OutputXML,"Response")
		d ChargeObj.%Close()
		q OutputXML
	}
	;获取订单状态
	Set HisTradeNoStutas=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).GetHisTradelockInfo(HisTradeNo)
	If (HisTradeNoStutas'=""){
		s:HisTradeNoStutas=1 ChargeObj.ResultCode=-5
		s:HisTradeNoStutas=1 ChargeObj.ErrorMsg="此订单在交易中"
		s:HisTradeNoStutas=-1 ChargeObj.ResultCode=-6
		s:HisTradeNoStutas=-1 ChargeObj.ErrorMsg="此订单已交易失败"
		s:HisTradeNoStutas=0 ChargeObj.ResultCode=-4
		s:HisTradeNoStutas=0 ChargeObj.ErrorMsg="此订单已经付款成功"
		s ChargeObj.ErrorMsg="此订单已交易失败"
		d ChargeObj.XMLExportToString(.OutputXML,"Response")
		d ChargeObj.%Close()
		q OutputXML
	}
	s rtn=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).SetHisTradelockInfo(HisTradeNo,1)
    //结算
   
    s RegNo=$P(^PAPER(PatientId,"PAT",1),"^",1)
    s rtn=##class(web.DHCPE.NetPre.Pay).Main(AdmInfo,RegNo,AliPayPaySum)
    i $P(rtn,"^",1)'=0
    {
	    s rollrtn=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).RollBack(AliPayTradeInfo,Userid,TradeType,"",Paymode,ErrCode,$g(AdmInfo))
		s ChargeObj.ResultCode=102
		s ChargeObj.ErrorMsg=$P(rtn,"^",2)
		d ChargeObj.XMLExportToString(.OutputXML,"Response")
		d ChargeObj.%Close()
		q OutputXML
    }
    s InvID=$P(rtn,"^",2)  ;多张发票ID看如何返回，暂时写的&分割
    s AdmInfo=$P(^DHCPEINVPRT(InvID),"^",2)  //得到就诊id
   	s InvRowidStr=""
    f i=1:1:$l(InvID,"&") d
    .s PrtInvRowid=$p(InvID,"&",i)
    .q:+PrtInvRowid=0
    .s InvRowidStr=InvRowidStr_"^"_PrtInvRowid
    .;获取发药窗口
    .s WinInfo=""
    .;Set WinInfo=##class(web.UDHCOPINVPrtData12).GetPrescWinByPrtRowID(PrtInvRowid)
    .s invAmt=##class(DHCAliPay.ChargeInterface.AliPayLogic).GetOPInvAliPayAmt(PrtInvRowid)
    .s HospDR=""
  	.s InvoiceObj=##class(DHCAliPay.DHCEntity.PCA.Invoice).%New()
    .s InvoiceObj.TransactionId=HisTradeNo
 	.s InvoiceObj.InvoiceNO=PrtInvRowid
 	.s InvoiceObj.InvoiceAmt=$J(invAmt,3,2)
 	.s InvoiceObj.PrescWindow=WinInfo
 	.;Set InvoiceObj.InvocieExpStr=""
 	.d ChargeObj.Invoices.Insert(InvoiceObj)
 	.d InvoiceObj.%Close()
     Set rtn=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).UpdateAliPayInfo(AdmInfo,AliPayTradeInfo,Userid,"",InvRowidStr,Paymode,"结算成功")
 	//Set Mesrtn=##class(DHCAliPay.ChargeInterface.AliPayLogic).SendOrderMessageToAli(InvRowidStr)
 	Set rtn1=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).SetHisTradelockInfo(HisTradeNo,0)
    Set ChargeObj.ResultCode=0
	Set ChargeObj.ErrorMsg="结算成功" 
    ;
    Do ChargeObj.XMLExportToString(.OutputXML,"Response")
	Do ChargeObj.%Close()
    Quit OutputXML
UpdateTradNoErr
	s PatOrderObj=##class(DHCAliPay.DHCEntity.PCA.AutoPayChargeResult).%New()
   	s PatOrderObj.ResultCode=-10
   	s PatOrderObj.ErrorMsg="程序处理出错:"_$ZERROR
   	s rollrtn=##class(DHCAliPay.ChargeInterface.DHCOPBillAliPayExp).RollBack(AliPayTradeInfo,Userid,TradeType,"",Paymode,"程序异常",$g(AdmInfo))
  	s OutputXML=""
   	d PatOrderObj.XMLExportToString(.OutputXML,"Response")
   	d PatOrderObj.%Close()
	q OutputXML
}

ClassMethod Refund(NewPrtRowid As %String, AbortPrtRowid As %String)
{
	//PatType As %String, NewPrtRowid As %String, AbortPrtRowID As %String, BankCardNO As %String, BankTradeType As %String, ExpStr As %String
	n (NewPrtRowid,AbortPrtRowid,%session)
	s PatType="OP"
	s BankCardNO=""
	s BankTradeType="D"
	s LocID=%session.Get("LOGON.CTLOCID")
	s GroupID=%session.Get("LOGON.GROUPID")
	s HospitalID=$P(^CTLOC(LocID),"^",22)
	s terminalType=""
	s LocCode=$P(^CTLOC(LocID),"^",1)
	s UserID=%session.Get("LOGON.USERID")
	s RefundReason=""	
	s ExpStr=LocID_"^"_GroupID_"^"_HospitalID_"^"_terminalType_"^"_LocCode_"^"_UserID_"^"_RefundReason  ;科室^安全组^医院^渠道代码^科室代码^操作员ID^退费原因
	s ret=##class(DHCAliPay.ChargeInterface.AliPayLogic).AliPay(PatType,NewPrtRowid,AbortPrtRowid,BankCardNO,BankTradeType,ExpStr)
	q ret
}

//d ##class(web.DHCPE.NetPre.Pay).ExportCom()

ClassMethod ExportCom()
{
	
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPEContract","D:/NetPre/")
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPEPreGADM.Home","D:/NetPre/")
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPEPreTemplateTime","D:/NetPre/")
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPEPreManagerList","D:/NetPre/")
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPEPreTemplate","D:/NetPre/")
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPEPreManager","D:/NetPre/")
	
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPENetOrdSetsInfo","D:/NetPre/")
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPENetOrdSetsItemType","D:/NetPre/")
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPENetOrdSetsItem","D:/NetPre/")
	d ##Class(web.Util.UtilService).GetExportComponents("DHCPENetOrdSetsItemDetail","D:/NetPre/")
}

ClassMethod UpdateCom()
{
	s path="D:/NetPre/"
	//d ##Class(web.Util.UtilService).PutComponent(XMLName,"True")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPEContract"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPEPreGADM.Home"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPEPreTemplateTime"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPEPreManagerList"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPEPreTemplate"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPEPreManager"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPENetOrdSetsInfo"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPENetOrdSetsItem"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPENetOrdSetsItemType"_".xml")
	d ##Class(web.Util.UtilService).PutComponent(path_"DHCPENetOrdSetsItemDetail"_".xml")
}

//w ##class(web.DHCPE.NetPre.Pay).GetNeedPayedRecord(10)

ClassMethod GetNeedPayedRecord(PatientID)
{
	n (PatientID)
	s RegNo=$P(^PAPER(PatientID,"PAT",1),"^",1)
	s IDCard=$P(^PAPER(PatientID,"PAT",3),"^",6)
	s Name=$P(^PAPER(PatientID,"ALL"),"^",1)
	s Sex=$P(^PAPER(PatientID,"ALL"),"^",7)
	s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
	s IBI=$O(^DHCPEPreIBI(0,"PAPMINo",RegNo,0))
	s obj=##class(web.DHCPE.NetPre.Entity.NeedPayRecord).%New()
	s obj.Name=Name
	s obj.Sex=Sex
	i IBI'=""
	{
		s PreIADM=0
 		f  s PreIADM=$o(^DHCPEPreIADM(0,"PIBI",IBI,PreIADM)) q:PreIADM=""  d
 		.s Status=$P(^DHCPEPreIADM(PreIADM),"^",8)
 		.q:Status="CANCELPE"
 		.s Amt=0
 		.s AuditID=0
 		.f  s AuditID=$O(^DHCPEPreA(0,"CRMADM","I",PreIADM,AuditID)) q:AuditID=""  d
 		..s Status=$P(^DHCPEPreA(AuditID),"^",21)
 		..q:Status="NU"
 		..s ChargedStatus=$P(^DHCPEPreA(AuditID),"^",14)
 		..q:ChargedStatus="CHARGED"
 		..s OneAmt=$P(^DHCPEPreA(AuditID),"^",9)
 		..s Amt=Amt+OneAmt
 		.q:+Amt=0
 		.s CheckDate=$P(^DHCPEPreIADM(PreIADM),"^",4)
 		.s:CheckDate'="" CheckDate=$ZD(CheckDate,3)
 		.s childObj=##class(web.DHCPE.NetPre.Entity.PayRecord).%New()
 		.s childObj.Amt=$j(Amt,"",2)
 		.s childObj.CheckDate=CheckDate
 		.s childObj.RecordID=PreIADM_"^P"
 		.d obj.PayRecords.Insert(childObj)
	}
	i IDCard'=""
	{
		s NetPreID=0
		f  s NetPreID=$O(^User.DHCPENetPreRecordI("IDCardIndex",IDCard,NetPreID)) q:NetPreID=""  d
		.s PreIADM=$LG(^User.DHCPENetPreRecordD(NetPreID),13)
		.q:PreIADM'=""
		.s Status=$LG(^User.DHCPENetPreRecordD(NetPreID),7)
		.q:Status'="0"
		.s SetsID=$LG(^User.DHCPENetPreRecordD(NetPreID),8)
		.s NetSetsID=$O(^User.DHCPENetOrdSetsI("HisSetsIndex",SetsID,0))
		.s Amt=0
		.s:NetSetsID'="" Amt=$LG(^User.DHCPENetOrdSetsD(NetSetsID),4)
		.s CheckDate=$LG(^User.DHCPENetPreRecordD(NetPreID),9)
		.s:CheckDate'="" CheckDate=$ZD(CheckDate,3)
		.s childObj=##class(web.DHCPE.NetPre.Entity.PayRecord).%New()
 		.s childObj.Amt=$j(Amt,"",2)
 		.s childObj.CheckDate=CheckDate
 		.s childObj.RecordID=NetPreID_"^N"
 		.d obj.PayRecords.Insert(childObj)
	}
	s OutputXML=""
	d obj.XMLExportToString(.OutputXML,"Response")
	d obj.%Close()
	q OutputXML
}

//w ##class(web.DHCPE.NetPre.Pay).GetNeedPayItem("417^P")

ClassMethod GetNeedPayItem(AdmID)
{
	n (AdmID)
	s Type=$P(AdmID,"^",2)
	s AdmID=$P(AdmID,"^",1)
	s obj=##class(web.DHCPE.NetPre.Entity.PayItem).%New()
	i Type="N"
	{
		s SetsID=$LG(^User.DHCPENetPreRecordD(AdmID),8)
		s ArcimDesc=$P(^ARCOS(SetsID),"^",2)
		s NetSetsID=$O(^User.DHCPENetOrdSetsI("HisSetsIndex",SetsID,0))
		s Amt=0
		s:NetSetsID'="" Amt=$LG(^User.DHCPENetOrdSetsD(NetSetsID),4)
		s childobj=##class(web.DHCPE.NetPre.Entity.Item).%New()
		s childobj.ArcmiDesc=ArcimDesc
		s childobj.Amt=$j(Amt,"",2)
		d obj.Items.Insert(childobj)
	}
	elseif Type="P"
	{
		s AuditID=0
 		f  s AuditID=$O(^DHCPEPreA(0,"CRMADM","I",AdmID,AuditID)) q:AuditID=""  d
 		.s Status=$P(^DHCPEPreA(AuditID),"^",21)
 		.q:Status="NU"
 		.s ChargedStatus=$P(^DHCPEPreA(AuditID),"^",14)
 		.q:ChargedStatus="CHARGED"
 		.s OrdEntSub=0
 		.f  s OrdEntSub=$O(^DHCPEPreIADM(0,"PAORDENT",AuditID,AdmID,OrdEntSub)) q:OrdEntSub=""  d
 		..s SetsID=$P(^DHCPEPreIADM(AdmID,"ORDENT",OrdEntSub),"^",1)
 		..s ArcimDesc=$P(^ARCOS(SetsID),"^",2)
 		..s Amt=0
 		..s FeeSub=0
 		..f  s FeeSub=$O(^DHCPEPreIADM(0,"PAORDENT",AuditID,AdmID,OrdEntSub,FeeSub)) q:FeeSub=""  d
 		...s OneAmt=$P(^DHCPEPreIADM(AdmID,"ORDENT",OrdEntSub,"FEE",FeeSub),"^",2)
 		...s Amt=Amt+OneAmt
 		..s childobj=##class(web.DHCPE.NetPre.Entity.Item).%New()
 		..s childobj.ArcmiDesc=ArcimDesc
 		..s childobj.Amt=$j(Amt,"",2)
 		..d obj.Items.Insert(childobj)
 		
 		.s OrdItemSub=0
 		.f  s OrdItemSub=$O(^DHCPEPreIADM(0,"PAORDITEM",AuditID,AdmID,OrdItemSub)) q:OrdItemSub=""  d
 		..s SetsID=$P(^DHCPEPreIADM(AdmID,"ORDITEM",OrdItemSub),"^",1)
 		..s ArcimDesc=$P(^ARCIM(+SetsID,1,1),"^",2)
 		..s Amt=0
 		..s FeeSub=0
 		..f  s FeeSub=$O(^DHCPEPreIADM(0,"PAORDITEM",AuditID,AdmID,OrdItemSub,FeeSub)) q:FeeSub=""  d
 		...s OneAmt=$P(^DHCPEPreIADM(AdmID,"ORDITEM",OrdItemSub,"FEE",FeeSub),"^",2)
 		...s Amt=Amt+OneAmt
 		..s childobj=##class(web.DHCPE.NetPre.Entity.Item).%New()
 		..s childobj.ArcmiDesc=ArcimDesc
 		..s childobj.Amt=$j(Amt,"",2)
 		..d obj.Items.Insert(childobj)
	}
	
	s OutputXML=""
	d obj.XMLExportToString(.OutputXML,"Response")
	d obj.%Close()
	q OutputXML
}

Storage Default
{
<Data name="PayDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.NetPre.PayD</DataLocation>
<DefaultData>PayDefaultData</DefaultData>
<IdLocation>^web.DHCPE.NetPre.PayD</IdLocation>
<IndexLocation>^web.DHCPE.NetPre.PayI</IndexLocation>
<StreamLocation>^web.DHCPE.NetPre.PayS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
