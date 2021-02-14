Import SQLUser

/// Created by JDL  2007/4
Class web.DHCPE.Cashier Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

/// w ##class(web.DHCPE.Cashier).GetAuditsAmount("");
ClassMethod GetAuditsAmount(itmjs As %Library.String = "", itmjsex As %Library.String = "", preAuditIds As %Library.String = "")
{
	new i,amount,preAuditId
	s amount=0
	s i=1
	
	while(i<=$l(preAuditIds,",")){		
		s preAuditId=$p(preAuditIds,",",i)
		q:preAuditId="" 
		s amount=amount+$p($g(^DHCPEPreA(preAuditId)),"^",9)
		s i=i+1
	}
	q $j(amount,3,2)
}

// w ##class(web.DHCPE.Cashier).InitSetting()

ClassMethod CheckCashierSetting()
{
}

/// 体检结算
/// w ##class(web.DHCPE.Cashier).Cashier("","",preAuditIds,"",amount,payedInfo,userId,locId)
ClassMethod Cashier(itmjs As %Library.String = "", itmjsex As %Library.String = "", preAuditIds As %Library.String = "", crmOrderIds As %Library.String = "", amount As %Library.String = "", payedInfos As %Library.String = "", userId As %Library.String = "", locId As %Library.String = "", InvNo As %Library.String = "", InvID As %Library.String = "", pAdmType As %Library.String = "", pAdmId As %Library.String = "", listFlag As %Library.String = "", CheckFlag As %Library.String = "0", HospitalID As %String)
{
	new total,transFlag,errs,rtn
	new auditData
	new preAdmId,childsub,preAuditId,peOrderId,OEORDRowId
	new AdmId
	new hisOItemId,itemInfo,arcItemId
	new i,payedInfo,paymode,payamount,payno,paymodeinfos
	new InvoicId,BillId
	new curDate,curTime
	new curdatetime,job
	s TaxpayerNum=""
	s curdatetime=$h
	s job=$j
	s transFlag=0
	s errs=""
	s TaxpayerNum=$P(InvNo,"^",5)
	s RealAdmReason=$P(InvNo,"^",4)
	s NoPrintInv=$P(InvNo,"^",3)
	s InvName=$P(InvNo,"^",2)
	s InvNo=$P(InvNo,"^",1)
	s ^DHCPETemp("Cashier","parameter")="preAuditIds:"_preAuditIds_",crmOrderIds:"_crmOrderIds_",amount"_amount_",payedInfos:"_payedInfos_",userId:"_userId_",locId:"_locId
	//Set $ZTRAP="CashierErrTrap"
	//
	//Add by MLH 2008-06-17
	s i=1
	while(i<=$l(preAuditIds,",")){		
		s preAuditId=$p(preAuditIds,",",i)
		q:preAuditId="" 
		s preAdmId=0
		s CanCashier=1
		f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId="")||(CanCashier=0))  d
		.s Status=$p($G(^DHCPEPreIADM(preAdmId)),"^",8)
		.q:(Status'="ARRIVED")&&(Status'="REGISTERED")
		.s childsub=0
		.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub="")||(CanCashier=0))  d
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",16)'=1	//判断是否有效
		..Set PIOI=preAdmId_"||"_childsub
		..Set CRMO=$o(^DHCPECRMO(0,"CRMORI",PIOI,0))
		..If CRMO="" d
		...Set CanCashier=0
		s preAdmId=0
		f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId="")||(CanCashier=0))  d
		.s Status=$p($G(^DHCPEPreIADM(preAdmId)),"^",8)
		.q:(Status'="ARRIVED")&&(Status'="REGISTERED")
		.s childsub=0
		.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub="")||(CanCashier=0))  d
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
		..Set PIOE=preAdmId_"||"_childsub
		..s itemChildSub=0
		..f  s itemChildSub=$o(^DHCPEPreIADM(0,"OrdEnt",PIOE,preAdmId,itemChildSub)) q:((itemChildSub="")||(CanCashier=0))  d
		...q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",itemChildSub)),"^",16)'=1	//判断是否有效
		...s PIOI=preAdmId_"||"_itemChildSub
		...Set CRMO=$o(^DHCPECRMO(0,"CRMORI",PIOI,0))
		...If CRMO="" d
		....Set CanCashier=0
		s i=i+1
	}
	
	Quit:$g(CanCashier)=0 "请先确认所有加项医嘱!"
	//验证分类金额是否和项目金额一致
	//s CheckCatFeeFlag=..FeeInfoCheck(preAuditIds,amount)
	s CheckCatFeeFlag=..FeeInfoCheckNew(preAuditIds,amount)
	//i CheckCatFeeFlag=1 q "存在分类金额和项目金额不符的项目"
	i $P(CheckCatFeeFlag,"$",1)=1 q "存在分类金额和项目金额不符的项目,具体项目:"_$P(CheckCatFeeFlag,"$",2)
	new maxlistcount,listcount
	s maxlistcount=$g(^DHCPESetting("DHCPE","InvMaxListCount"))
    s InvListFlag=$g(^DHCPESetting("DHCPE","InvListFlag"))
	if (maxlistcount="")&&(InvListFlag="1") q "请先设置好发票打印的最大明细数!"
	//if maxlistcount="" q "请先设置好发票打印的最大明细数!"
	
	new curInvNo
	s curInvNo=##class(web.DHCPE.DHCPEPAY).getcurinvno(userId)
	if InvNo'=$p(curInvNo,"^",1) q "传入发票号不正确,请刷新后重试!"
	s title=$P(curInvNo,"^",3)
	new ItemId
	s ItemId=$g(^DHCPESetting("DHCPE", "InvDefaulltFee"))
	if ItemId="" q "请先设置好默认发票打印的项目!"
	if (($p(ItemId,"||",1)="")||($p(ItemId,"||",1)="")) q "默认发票打印的项目设置不正确!"
	
	if ((InvNo="")||(InvID=""))
	{	s errs= "传入的发票号信息不正确!请刷新页面后重试!"
		goto CashierErrTrap}
	
	if ((pAdmType="")||(pAdmId="")) 
	{	s errs="没有找到登记信息！"
		goto CashierErrTrap}
	
	
	i pAdmType="I" d
	.s AdmId=$p($g(^DHCPEIADM(pAdmId)),"^",1)
	.s CRMID=$p($g(^DHCPEIADM(pAdmId)),"^",4)
	e  d
	.s AdmId=$p($g(^DHCPEGADM(pAdmId)),"^",3)
	.s CRMID=$p($g(^DHCPEGADM(pAdmId)),"^",2)
	if AdmId=""
	{	s errs="没有找到对应的Adm号!"
		goto CashierErrTrap
	}
	
	s CardNoW=""						 // 20120718
	s CardNoW=$P(payedInfos,"#",2)      // 20120718                      
	s payedInfos=$P(payedInfos,"#",1)   // 20120718
	
	
	s flag=..JudgePayMode(payedInfos,amount,AdmId)
	q:flag'=0 flag
	s errs=##class(web.DHCPE.OEOrdItem).GetPEArcItem(.arcItemId)
	if errs'="" goto CashierErrTrap	
		
	s curDate=+$h
	s curTime=$p($h,",",2)
	////以上为处理本次结算信息
	////
	////以下为处理发票信息	
	
	///获取审核合计金额
	s total=..GetAuditsAmount("","",preAuditIds)
	if (total=0)
	{
		s errs="合计金额为0，不能结算!"
		goto CashierErrTrap
	}
	s amount=$j(amount,3,2)
	if (+total'=+amount)
	{
		s errs="合计金额有误差，不能结算!"_total_"a"_amount_"b"
		goto CashierErrTrap
	}
	
	if (listFlag=1)
	{
		//if (..CheckAmountDiffer(preAuditIds)=1)
		//{
		//	s errs="有套餐金额与套餐内项目金额合计不一致，不能结算!"
		//	goto CashierErrTrap
		//}
	}
	if (listFlag=1)
	{
		/*
		s listcount=..GetListCount(preAuditIds)
		if (listcount>maxlistcount)
		{
			s errs="明细数量超过"_maxlistcount_"不能打印在一张发票上，请拆分费用!"
			goto CashierErrTrap
		}
		*/		
	}
	s PayModeID=$P(payedInfos,",",1)
	s PayCode=$P($G(^CT("CTPM",PayModeID)),"^",1)
	i PayCode="TJYJJ"
	{
		;i $G(^DHCPEPreADM("AllowAPCharge",pAdmType,CRMID))'="1" q "还未允许预交金结算"
	}
	//s listcount=..GetInvoiceInfoNew(preAuditIds,curdatetime,job,listFlag)
	s PrintDetail=0
	s listcount=..GetListCount(preAuditIds)
	if (listcount>maxlistcount)&&(PayCode'="TJYJJ")&&(PayCode'="TJGBK")&&(PayCode'="TJZKK")&&(PayCode'="TJDJK")&&(PayCode'="TJSSP")
	{
		s PrintDetail=1
		/*
		s errs="明细数量超过"_maxlistcount_"不能打印在一张发票上，请拆分费用aaaa!"
		k ^DHCPECashierTemp("InvListInfo",curdatetime,job)
		goto CashierErrTrap
		*/
	}
	
	
	new haspayed
	s haspayed=..CheckAuditsPayed(preAuditIds)
	if haspayed'=0
	{
		s errs="有记录已经结算，请刷新后再试!"
		goto CashierErrTrap
	}
	q:CheckFlag=1 errs
	s InvNo=title_InvNo
	
	///逐条处理支付方式记录
	s i=1
	s paymodeinfos="&"_amount
	s sswr=0  //四舍五入金额
	while(i<=$l(payedInfos,"^")){
		s payedInfo=$p(payedInfos,"^",i)
		s paymode=$p(payedInfo,",",1)
	    s payamount=$p(payedInfo,",",2)
		//s payamount=amount 
		//i paymode=1 d
		//.s sswramount=$j(amount,3,1)
		//.s sswr=sswramount-amount
		s payno=$p(payedInfo,",",3)
		s paymodeinfos=paymodeinfos_"&"_paymode_"^^"_payno_"^^^"_payamount
		s i=i+1
	}
	

	s paymodeinfos=paymodeinfos_"#"_CardNoW   // 20120718
	
	//preAuditIds, crmOrderIds, amount, payedInfos, userId, locId, InvNo, InvID
	//InvNo:发票号,InvID:发票领取记录的rowid,Adm:就诊表rowid,BillOrdItmID:体检费医嘱rowid(如有多个rowid1^rowid2^rowid3)
	//OrdItmStr:体检费所包括的医嘱明细的rowid串（rowid1^rowid2^rowid3^…)  可空
	//PayModeStr:支付方式串，&支付总金额&支付方式1名称^银行rowid^支票号^支付单位^信用卡号^金额1&支付方式2名称^支票号^支付单位^信用卡号^金额2…
	///生成一笔体检费项目	
	//i paymode=1 s OrdAmount=$j(amount,3,1)
	s itemInfo=arcItemId_"^1^"_locId_"^"_amount_"^^^^^TB"
	//s hisItem=arcItemId_"^"_Qty_"^"_locId_"^"_$p(crmItem,"^",2)_"^^^"_arcos1
	s ^DHCTemp("jdl")="##class(web.DHCPE.PEApp).InsertOrdItem("_AdmId_","_itemInfo_","_userId_","_locId_","_userId_")"	
	
	//TSTART
	
	
	s ret=##class(web.DHCPE.PEApp).InsertOrdItem(AdmId, itemInfo, userId,locId, userId)

	s hisOItemId=$p(ret,"^",2)
	
	if hisOItemId=""{
		s errs="插入体检费医嘱失败"
		goto CashierErrTrap
	}
	
	s transFlag=1
	TSTART
	i RealAdmReason'=""
	{
		&SQL(Update Sqluser.PA_Adm set PAADM_AdmReason_DR=:RealAdmReason where PAADM_RowID=:AdmId)
	}
	S rtn=##Class(web.DHCPE.DHCPEBillCharge).PEBillCharge(InvNo_"^"_NoPrintInv, InvID, AdmId, hisOItemId, "", paymodeinfos, "", amount, userId, locId, "", "", "",HospitalID)
	if $p(rtn,"^",1)'=0
	{	s errs="结算失败00！"_$p(rtn,"^",1)
		goto CashierErrTrap
		}
	s InvoicId=$p(rtn,"^",2)
	i InvoicId'=""{
		s RelInvID=InvoicId
	
		s BillId=$p($g(^DHCPEINVPRT(InvoicId)),"^",3)
		s SQLCODE=..UpdateSswrAmount(InvoicId)
		i SQLCODE'=0{
			s errs="更新四舍五入金额错误"_SQLCODE
			goto CashierErrTrap
		}
		//s $p(^DHCPEINVPRT(InvoicId),"^",21)=sswr   //PRT_NOTE1记录四舍五入的金额
	}
	else{
		s BillId=$p(rtn,"^",3)
		s RelInvID=$O(^DHCPEINVPRT(0,"PB",BillId,0))
	}
	if (BillId="")
	{	s errs="发票没有对应的帐单！"_$p(rtn,"^",1)
		goto CashierErrTrap
	}
	//s transFlag=1
	///逐条处理审核记录
	s i=1
	k ^DHCTemp("jdl","Cashier")
	while(i<=$l(preAuditIds,",")){		
		s preAuditId=$p(preAuditIds,",",i)
		if preAuditId=""
		{	s errs="传入的审核ID有空！"
			goto CashierErrTrap
		}
		s auditData=$g(^DHCPEPreA(preAuditId))
		if auditData="" 
		{	s errs="没有找到审核信息！"
			goto CashierErrTrap
		}
		
		s errs=..UpdatePreAuditPayed(preAuditId,0)
		i errs'="" goto CashierErrTrap
		
		&SQL(Insert into DHC_PE_PAPBRelate(PAPB_PA_DR,PAPB_PB_DR,PAPB_PBType,PAPB_UpdateUser_DR,PAPB_UpdateDate,PAPB_UpdateTime)
				values (:preAuditId,:BillId,'N',:userId,:curDate,:curTime)			)
		if SQLCODE s errs="生成对照记录失败!"
				
		if errs'="" goto CashierErrTrap
		s i=i+1		
	}
	i TaxpayerNum'="" d
	.s ^DHCPEDataEx("TaxpayerNum",InvoicId)=TaxpayerNum
	//需要扣款等支付方式的操作
	s errs=##class(web.DHCPE.CashierEx).UpdatePayModeAmtByInv(RelInvID,userId)
	if errs'="" goto CashierErrTrap
	i InvoicId'="" d
	.i InvName'="" d
	..s ^DHCPEDataEx("InvName",InvoicId)=InvName
	.s ^DHCPECashierTemp("InvListInfo",InvoicId)=curdatetime_"^"_job
	.s InvInfo=##class(web.DHCPE.CashierEx).GetInvAmountInfo(InvoicId)
	.i (+amount)'=(+InvInfo) s PrintDetail="1"
	d GetFeeInfo
	s InvNo=$P(^DHCPEINVPRT(InvoicId),"^",1)
	
	s:InvNo[("DHC") InvoicId=""
	s ret=##class(web.DHCPE.CashierEx).InsertOPInv(RelInvID)
	i ret'=0 goto CashierErrTrap
	TCommit
	i pAdmType="I" d ##class(web.DHCPE.AdmRecordManager).Insert(CRMID,"P","Cashier",userId,InvoicId)
	i pAdmType="G" d ##class(web.DHCPE.GAdmRecordManager).Insert(CRMID,"P","Cashier",userId,InvoicId)
	s transFlag=0	
	q errs_"^"_InvoicId_"^"_RelInvID_"^"_PrintDetail
GetFeeInfo
	s InvoicId=$O(^DHCPEINVPRT(0,"PB",BillId,0))
	s ^DHCPECashierTemp("InvListInfo",InvoicId)=curdatetime_"^"_job
	s invnum=##class(web.DHCPE.CashierEx).GetInvUserNum(userId)
	s ^DHCPEINVPRT(InvoicId,"PEInvNum")=invnum
	d ..GetFeeInfo(InvoicId,preAuditIds,amount)
	s $P(^DHCPEOEITEM(InvoicId),"^",6)=RealAdmReason
	q
CashierErrTrap
	if transFlag=1 TRollback
	if errs="" s errs=$ZERROR
	q errs
}

/*
ClassMethod UpdateSswrAmount(InvID)
{
	;d ##class(web.DHCPE.Cashier).UpdateSswrAmount(6096)
	s RoundManager=$G(^DHCPESetting("DHCPE","RoundManager"))
	q:RoundManager'="Y" 0
	s ArrcID=$P(^DHCPEINVPRT(InvID),"^",4)
	s SswrAmount=0
	s SQLCODE=0
	s Sub=0
	f  s Sub=$O(^ARRCP(ArrcID,"PAYM",Sub)) q:(Sub="")||(SQLCODE'=0)  d
	.s PayMode=$P(^ARRCP(ArrcID,"PAYM",Sub),"^",1)
	.i PayMode="1" d
	..s Amount=$P(^ARRCP(ArrcID,"PAYM",Sub),"^",3)
	..s NewAmount=$J(Amount,"",2)
	..s SswrAmount=SswrAmount+NewAmount-Amount
	..;s ID=ArrcID_"||"_Sub
	..;&SQL(Update Sqluser.AR_RcptPayMode set PAYM_Amt=:NewAmount where PAYM_RowID=:ID)
	q:SQLCODE'=0
	&SQL(Update Sqluser.DHC_PE_Invprt set PRT_NOTE1=:SswrAmount where PRT_RowID=:InvID)
	q SQLCODE
}
*/
/// w ##class(web.DHCPE.Cashier).UpdateSswrAmount(1404)
/// 根据发票ID计算分币误差
ClassMethod UpdateSswrAmount(InvID)
{
	s RoundManager=$G(^DHCPESetting("DHCPE","RoundManager"))
	q:(RoundManager="")||(RoundManager=0)||(RoundManager="N") 0
	s ArrcID=$P(^DHCPEINVPRT(InvID),"^",4)
	s SswrAmount=0
	s SQLCODE=0
	s Sub=0
	f  s Sub=$O(^ARRCP(ArrcID,"PAYM",Sub)) q:(Sub="")||(SQLCODE'=0)  d
	.s PayMode=$P(^ARRCP(ArrcID,"PAYM",Sub),"^",1)
	.s PayModrCode=$p($g(^CT("CTPM",PayMode)),"^",1)
	.i PayModrCode="CASH" d
	..s Amount=$P(^ARRCP(ArrcID,"PAYM",Sub),"^",3)
	..S NewAmount=..Round(Amount,1,RoundManager)
	..s SswrAmount=SswrAmount++NewAmount-Amount
	..s ID=ArrcID_"||"_Sub
	..&SQL(Update Sqluser.AR_RcptPayMode set PAYM_Amt=:NewAmount where PAYM_RowID=:ID)
	&SQL(Update Sqluser.DHC_PE_Invprt set PRT_NOTE1=:SswrAmount where PRT_RowID=:InvID)
	q SQLCODE
}

/// 计算分币误差
/// input: FNum:总金额; Len:舍入小数点后位数; RNum:5 四舍五入,6 五舍六入
ClassMethod Round(FNum As %String, Len As %String, RNum As %String) As %String
{
	;设置不同的舍入进制
	n (FNum,Len,RNum)
	;w ##class(web.DHCPE.Cashier).Round(12.678,1,6)
	s myNum=0
	i Len="" d
	.s Len=0
	
	s Len=+$g(Len)
	s FNum=+$g(FNum)
	s RNum=+$g(RNum)
	
	s myNum=$fn(FNum,"", Len)
	
	;求幂
	s myzp=$zpower(10,Len)

	;取整数取4舍五入, 增加了矫正
	s myRtnInt=$fn(((FNum*myzp*10)-(RNum-5))/10,"",0)
	s myNum=$fn((myRtnInt/myzp),"",Len)
	q myNum
}

ClassMethod UpdateOrderPayed(peOrderId, payed) As %String
{
	new errs,oepayed
	new crmorderid,preadmid,prechidsub
	
	s errs=""
	i ((payed="P")||(payed="OC"))
	{	s oepayed="P"}
	elseif((payed="PP"))
	{
		s oepayed="TB"
		s crmorderid=$p($g(^DHCPECRMO(peOrderId)),"^",2)
		s preadmid=$p(crmorderid,"||",1)
		s prechidsub=$p(crmorderid,"||",2)
		if ((prechidsub'="")&&(preadmid'=""))
		{   
		   s oepayed="P"
		//if $p($g(^DHCPEPreIADM(preadmid,"ORDITEM",prechidsub)),"^",9)="Y" s oepayed="P"
		
		}
	}
	else
	{	//s oepayed="TB"
		s oepayed="R"
	}
	
	i peOrderId="" s errs="没有找到对照的体检项目!"
	q:errs'="" errs
	&SQL(Update DHC_PE_CRMOrder Set CRMO_BillStatus=:payed Where CRMO_RowId=:peOrderId)
	if SQLCODE s errs="更新体检项目表状态失败!"
	q:errs'="" errs
	s OEORDRowId=$p($g(^DHCPECRMO(peOrderId)),"^",1)
	i OEORDRowId="" q errs
	&SQL(Update sqluser.OE_OrdItem set Oeori_Billed=:oepayed where oeori_rowid=:OEORDRowId)
	if SQLCODE  s errs="更新医瞩状态失败!"
	
	I oepayed="P"  d ##class(web.DHCPE.CRM.RisGateway).SendInfo("R",OEORDRowId)    //add 20100307
	
	
	//原来撤销医嘱调用
	;I oepayed="TB" d ##class(web.DHCPE.CRM.RisGateway).SendInfo("D",OEORDRowId)
	//有部位撤销调用新产品组
	;I oepayed="TB" d ##Class(web.DHCEMInterface).SetExaReqExeStatus(OEORDRowId,"","D")
	//没部位调用pacs组
	;I oepayed="TB" d ##Class(RISService.InvokeRISService).DiscontinueAppInfoPACS(OEORDRowId,"","D")
	I oepayed="R" d ##Class(RISService.InvokeRISService).DiscontinueAppInfoPACS(OEORDRowId,"","D")
	
	/*//////Add For Ris接口 当未付费    20090321
	//s PreIADM=+peOrderId                                       //by zhouli 调Ris接口 当未付费
	s crmorderid=$p($g(^DHCPECRMO(peOrderId)),"^",2)  //wrz
	s PreIADM=+crmorderid   //wrz
	s AsCharged=""                                            //by zhouli
	s AsCharged=$P(^DHCPEPreIADM(PreIADM),"^",9)                //by zhouli
	//i (AsCharged="N")&&((payed'="P")&&(payed'="OC")&&(payed'="PP"))  d ##class(web.DHCDOCHL7PROT).SendStopOrdertoRIS(OEORDRowId) //by zhouli
	i ((AsCharged="N")&&((payed="P")||(payed="OC")||(payed="PP")))       //by zhouli  进行结算时调Ris接口 
	{
		s crmorderid=$p($g(^DHCPECRMO(peOrderId)),"^",2)
		s oeorditemrowid=$p($g(^DHCPECRMO(peOrderId)),"^",1)
		s preadmid=$p(crmorderid,"||",1)
		s prechidsub=$p(crmorderid,"||",2)
		s OEORDRowId=$p(oeorditemrowid,"||",1)
		s ChildOEORDRowId=$p(oeorditemrowid,"||",2)
		s PIADM=0
		f   s PIADM=$o(^DHCPEIADM(0,"CRMADM",preadmid,PIADM))   q:PIADM=""  d
    	.s PADAdmRowid=$p(^DHCPEIADM(PIADM),"^",1)
    	.s PapmiRowid=$P(^PAADM(PADAdmRowid),"^",1)
    	.s PapmiInfo=##class(web.DHCDocOrderEntry).GetPatientByRowid(PapmiRowid)
    	.s MessageID="", PatientID="", PatientName="", DOB="", Sex="", Address="", HomeTel="", BussinessTel="", MaritalStatus="", PatientClass="", Ward="", Room="", Bed="", AttendingDoctor="", ReferringDoctor="", VIPIndicator="", AdmittingDoctor="", PatientType="", VisitNumber=""
    	.S PatientID=$p(^PAPER(PapmiRowid,"PAT",1),"^",1)
    	.S PatientName=$p((PapmiInfo),"^",3)
    	.S DOB=$p((PapmiInfo),"^",6)
    	.S Sex=$p((PapmiInfo),"^",4)
    	.S Address=$p((PapmiInfo),"^",11)
    	.S HomeTel=$p((PapmiInfo),"^",25)
    	.S BussinessTel=""
    	.S MaritalStatus=$p((PapmiInfo),"^",17)
    	.S PatientClass=$P(^PAADM(PADAdmRowid),"^",2)     //病人类型，??   体检是直接写死为“H”?
    	.s AdmittingDoctor=$P((^PAADM(PADAdmRowid)),"^",9)
  	  	.s Ward=$P((^PAADM(PADAdmRowid)),"^",4)
    	.s Room=$P(^CTLOC(Ward),"^",1)
    	.s VisitNumber=PADAdmRowid
    	.s Via=0
    	.q:'$D(^OEORD(OEORDRowId,"I",ChildOEORDRowId))
    	.s ItmMast=$p($G(^OEORD(OEORDRowId,"I",ChildOEORDRowId,1)),"^",2)
   		.s OEORIItemStat=$p($G(^OEORD(OEORDRowId,"I",ChildOEORDRowId,1)),"^",13)
   		.q:OEORIItemStat=4
   		.s ServerCat=$p(^ARCIM($p(ItmMast,"||",1),$p(ItmMast,"||",2),7),"^",6)
   		.Q:ServerCat'="S"  
   		.s ARCIMItemCat=$p(^ARCIM($p(ItmMast,"||",1),$p(ItmMast,"||",2),1),"^",10)
   		.Q:(ARCIMItemCat'=43)&(ARCIMItemCat'=17)&(ARCIMItemCat'=18)&(ARCIMItemCat'=19)&(ARCIMItemCat'=20)&(ARCIMItemCat'=21)&(ARCIMItemCat'=22)&(ARCIMItemCat'=126)&(ARCIMItemCat'=129)&(ARCIMItemCat'=131)&(ARCIMItemCat'=132)&(ARCIMItemCat'=133)&(ARCIMItemCat'=134)&(ARCIMItemCat'=135)&(ARCIMItemCat'=136)&(ARCIMItemCat'=137)&(ARCIMItemCat'=138)&(ARCIMItemCat'=139)&(ARCIMItemCat'=140)&(ARCIMItemCat'=141)&(ARCIMItemCat'=142)&(ARCIMItemCat'=143)&(ARCIMItemCat'=144)&(ARCIMItemCat'=145)&(ARCIMItemCat'=146)&(ARCIMItemCat'=147)&(ARCIMItemCat'=148)&(ARCIMItemCat'=149)&(ARCIMItemCat'=150)&(ARCIMItemCat'=151)&(ARCIMItemCat'=152)&(ARCIMItemCat'=153)
   		.s ControlID="NW"
   		.s OrderProvider=$p($G(^OEORD(OEORDRowId,"I",ChildOEORDRowId,1)),"^",11)
   		.s ArcItemName=$p(^ARCIM($p(ItmMast,"||",1),$p(ItmMast,"||",2),1),"^",2)
   		.s ArcItmCode=$p(^ARCIM($p(ItmMast,"||",1),$p(ItmMast,"||",2),1),"^",1)
   		.s RecLoc=$p($G(^OEORD(OEORDRowId,"I",ChildOEORDRowId,3)),"^",6)
   		.s RelevantInfo=##class(web.DHCRisApplicationBill).GetAppInfo(oeorditemrowid)
   		.hang 2
   		.s Via=0
   		.I (ARCIMItemCat=17)!(ARCIMItemCat=18)!(ARCIMItemCat=19)!(ARCIMItemCat=20)!(ARCIMItemCat=21)!(ARCIMItemCat=22)!(ARCIMItemCat=126)!(ARCIMItemCat=129)!(ARCIMItemCat=131)!(ARCIMItemCat=132)!(ARCIMItemCat=133)!(ARCIMItemCat=134)!(ARCIMItemCat=135)!(ARCIMItemCat=136)!(ARCIMItemCat=137)!(ARCIMItemCat=138)!(ARCIMItemCat=139)!(ARCIMItemCat=140)!(ARCIMItemCat=141)!(ARCIMItemCat=142)!(ARCIMItemCat=143)!(ARCIMItemCat=144)!(ARCIMItemCat=145)!(ARCIMItemCat=146)!(ARCIMItemCat=147)!(ARCIMItemCat=148)!(ARCIMItemCat=149)!(ARCIMItemCat=150)!(ARCIMItemCat=151)!(ARCIMItemCat=152)!(ARCIMItemCat=153) d
   		..; 发送放射医嘱的消息
   		..i Via=0 s PapmiHl7Ret=##class(web.DHCRisHL7).SendPatientInfo(MessageID, PatientID, PatientName, DOB, Sex, Address, HomeTel, BussinessTel, MaritalStatus, PatientClass, Ward, Room, Bed, AttendingDoctor, ReferringDoctor, VIPIndicator, AdmittingDoctor, PatientType, VisitNumber,"1")
   		..s RetOrder=##class(web.DHCRisHL7).SendORMO01Message(MessageID, ControlID, PatientID, PatientName, oeorditemrowid, PatientClass, OrderProvider, VisitNumber, ArcItmCode, ArcItemName, RecLoc, RelevantInfo,"",Room,"","1")
   		..s Via=Via+1
   		.else  if (ARCIMItemCat=25)!(ARCIMItemCat=24)!(ARCIMItemCat=127)!(ARCIMItemCat=23) d
   		..; 发送超声医嘱
   		..i Via=0 s PapmiHl7Ret=##class(web.DHCRisHL7).SendPatientInfo(MessageID, PatientID, PatientName, DOB, Sex, Address, HomeTel, BussinessTel, MaritalStatus, PatientClass, Ward, Room, Bed, AttendingDoctor, ReferringDoctor, VIPIndicator, AdmittingDoctor, PatientType, VisitNumber,"2")
   		..s RetOrder=##class(web.DHCRisHL7).SendORMO01Message(MessageID, ControlID, PatientID, PatientName, oeorditemrowid, PatientClass, OrderProvider, VisitNumber, ArcItmCode, ArcItemName, RecLoc, RelevantInfo,"",Room,"","2")
   		..s Via=Via+1
  		.else  if (ARCIMItemCat=43) d
  		..; 发送内镜医嘱
  		..i Via=0 s PapmiHl7Ret=##class(web.DHCRisHL7).SendPatientInfo(MessageID, PatientID, PatientName, DOB, Sex, Address, HomeTel, BussinessTel, MaritalStatus, PatientClass, Ward, Room, Bed, AttendingDoctor, ReferringDoctor, VIPIndicator, AdmittingDoctor, PatientType, VisitNumber,"3")
  		..s RetOrder=##class(web.DHCRisHL7).SendORMO01Message(MessageID, ControlID, PatientID, PatientName, oeorditemrowid, PatientClass, OrderProvider, VisitNumber, ArcItmCode, ArcItemName, RecLoc, RelevantInfo,"",Room,"","3")
  		..s Via=Via+1
	}
	//////////////End For Ris 20090321*/
	q errs
}

/// isDrop:1退费  0收费
/// d ##class(web.DHCPE.Cashier).UpdatePreAuditPayed("32558","0")
ClassMethod UpdatePreAuditPayed(preAuditId, isDrop)
{
	new errs,chargedStatus,condition
	new preAdmId,childsub,feesub
	new payed,k
	s errs=""
	if isDrop=0  d
	.s chargedStatus="CHARGED"
	.s condition="UNCHARGED"
	e  d
	.s chargedStatus="UNCHARGED"
	.s condition="CHARGED"	
	
	&SQL(Update DHC_PE_PreAudit set PA_ChargedStatus=:chargedStatus where PA_RowId=:preAuditId and PA_ChargedStatus=:condition)
	if SQLCODE 
	{	s errs="更新审核表状态失败!"_SQLCODE_"  preAuditId:"_preAuditId
		q errs
	}
	/*
	s AType=$P($G(^DHCPEPreA(preAuditId)),"^",1)	
	if (AType="G")
	{
		s PreGADM=$P($G(^DHCPEPreA(preAuditId)),"^",2)
		s AsCharged=$P($G(^DHCPEPreGADM(PreGADM)),"^",7)
		q:AsCharged="Y" errs
			
	}
	*/	
	///处理审核记录对应的医瞩记录
	s k=0
	s preAdmId=""
	f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId="")||(errs'=""))  d
	.s Status=$p($g(^DHCPEPreIADM(preAdmId)),"^",8)
    .q:(Status'="ARRIVED")&&(Status'="REGISTERED")
	.s childsub=""
	.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub="")||(errs'=""))  d
	..
	..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",16)'=1	//判断是否有效
	..
	..s preOrderId=preAdmId_"||"_childsub
	..s peOrderId=$o(^DHCPECRMO(0,"CRMORI",preOrderId,""))
	..s feesub=0
	..i isDrop=0  d
	...s payed="P"
	..e  d
	...i $p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",9)="Y" d
	....s payed="OC"
	...e  d
	....s payed="NP"
	..f  s feesub=$o(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub,"FEE",feesub)) q:((feesub="")||(errs'=""))  d
	...s feeData=$g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub,"FEE",feesub))
	...q:feeData=""
	...s otherAuditId=$p(feeData,"^",5)
	...q:otherAuditId=""
	...q:$p($g(^DHCPEPreA(otherAuditId)),"^",21)="NU"
	...i otherAuditId'=preAuditId d
	....i $p(^DHCPEPreA(otherAuditId),"^",14)="UNCHARGED"  d
	.....i payed="P" s payed="PP"
	....e  d
	.....i payed="NP" s payed="PP"
	.....i payed="OC" s payed="PP"
	..s k=k+1
	..s ^DHCTemp("jdl","Cashier",preAuditId,"Order",k)="peOrderId:"_peOrderId_"  payed:"_payed_"  "
	..q:peOrderId=""
	..s errs=..UpdateOrderPayed(peOrderId,payed)
		
	if errs'=""  q errs
	
	///处理审核记录对应的医瞩套记录
	s preAdmId=""
	s k=0
	f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId="")||(errs'=""))  d
	.s Status=$p($g(^DHCPEPreIADM(preAdmId)),"^",8)
    .q:(Status'="ARRIVED")&&(Status'="REGISTERED")
	.s childsub=""
	.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub="")||(errs'=""))  d
	..
	..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
	..
	..s preEntId=preAdmId_"||"_childsub
	..s feesub=0
	..i isDrop=0  d
	...s payed="P"
	..e  d
	...i $p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",9)="Y" d
	....s payed="OC"
	...e  d
	....s payed="NP"
	..f  s feesub=$o(^DHCPEPreIADM(preAdmId,"ORDENT",childsub,"FEE",feesub)) q:((feesub="")||(errs'=""))  d
	...s feeData=$g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub,"FEE",feesub))
	...q:feeData=""
	...s otherAuditId=$p(feeData,"^",5)
	...q:otherAuditId=""
	...q:$p($g(^DHCPEPreA(otherAuditId)),"^",21)="NU"
	...i otherAuditId'=preAuditId d
	....i $p(^DHCPEPreA(otherAuditId),"^",14)="UNCHARGED"   d
	.....i payed="P" s payed="PP"
	....e  d
	.....i payed="NP" s payed="PP"
	.....i payed="OC" s payed="PP"
	..s preItmSub=""
	..f  s preItmSub=$o(^DHCPEPreIADM(0,"OrdEnt",preEntId,preAdmId,preItmSub))  q:((preItmSub="")||(errs'=""))  d
	...q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",preItmSub)),"^",16)'=1	//判断是否有效
	...
	...s peOrderId=$o(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_preItmSub,""))
	...s k=k+1
	...s ^DHCTemp("jdl","Cashier",preAuditId,"OrderSet",k)="peOrderId:"_peOrderId_"  payed:"_payed_"  "
	...q:peOrderId=""
	...s errs=..UpdateOrderPayed(peOrderId,payed)
	q errs
}

/// 检测审核记录是否已经收费
/// 返回0:未收费  1：有收费和未收费的  2.已经全部收费
/// w ##class(web.DHCPE.Cashier).CheckAuditsPayed(Audits)
ClassMethod CheckAuditsPayed(Audits)
{
	new auditId,hasPayed,status
	s hasPayed=""
	s auditId=""
	s i=1
	while(i<=$l(Audits,",")){
		s auditId=$p(Audits,",",i)
		q:auditId=""
		s status=$p($g(^DHCPEPreA(auditId)),"^",14)
		i status="CHARGED"  d
		.i hasPayed="" s hasPayed=2
		.i hasPayed=0 s hasPayed=1
		e  d
		.i hasPayed="" s hasPayed=0
		.i hasPayed=2 s hasPayed=1
		s i=i+1
	}
	q hasPayed
}

// 得到体检预交金的余额

ClassMethod PABalance(Type, ADM)
{
    s Amount=""
	q:ADM="" ""
	i Type="I" d
	.s ID=$p(^DHCPEIADM(ADM),"^",4)
	.q:ID=""
	.s BaseID=$P($G(^DHCPEPreIADM(ID)),"^",1)
	.s RegNo=$P($G(^DHCPEPreIBI(BaseID)),"^",1)
	e  d
	.s ID=$p(^DHCPEGADM(ADM),"^",2) 
	.q:ID=""
	.s BaseID=$P($G(^DHCPEPreGADM(ID)),"^",1)
	.s RegNo=$P($G(^DHCPEPreGBI(BaseID)),"^",13)
	s APID=$O(^DHCPEAP(0,"RegNo",RegNo,0))
	q:APID="" ""
	s Amount=$P($G(^DHCPEAP(APID)),"^",4)
	q Amount
}

/// 检测该Adm是否已经有收费记录
/// 返回0:未收费  1：有收费和未收费的  2.已经全部收费
/// w ##class(web.DHCPE.Cashier).CheckPayed(AdmType,AdmId)
ClassMethod CheckPayed(AdmType, AdmId)
{
	new auditId,hasPayed,status
	s hasPayed=""
	s auditId=""
	f  s auditId=$o(^DHCPEPreA(0,"GIADM",AdmType,AdmId,auditId)) q:((auditId="")||(hasPayed=1))  d
	.s status=$p($g(^DHCPEPreA(auditId)),"^",14)
	.i $p($g(^DHCPEPreA(auditId)),"^",21)'="NU"  d  //Add 20080707
	..i status="CHARGED"  d
	...i hasPayed="" s hasPayed=2
	...i hasPayed=0 s hasPayed=1
	..e  d
	...i hasPayed="" s hasPayed=0
	...i hasPayed=2 s hasPayed=1
	q hasPayed
}

/// w ##class(web.DHCPE.Cashier).CheckPayedCRMOrder(crmOrder)
/// 返回医瞩收费状态
ClassMethod CheckPayedCRMOrder(crmOrder)
{
	new preAdmId,childsub,subdesc,crmEntId,payed,auditId
	if crmOrder="" q "没有传入预约体检项目!"
	s payed=""
	s preAdmId=$p(crmOrder,"||",1)
	s childsub=$p(crmOrder,"||",2)
	s subdesc="ORDITEM"
	s crmEntId=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",2)
	if crmEntId'=""  d 
	.s childsub=$p(crmEntId,"||",2)
	.s subdesc="ORDENT"
	s feesub=0
	f  s feesub=$o(^DHCPEPreIADM(preAdmId,subdesc,childsub,"FEE",feesub)) q:(feesub="")  d
	.s feeData=$g(^DHCPEPreIADM(preAdmId,subdesc,childsub,"FEE",feesub))
	.q:feeData=""
	.s auditId=$p(feeData,"^",5)
	.i $p(^DHCPEPreA(auditId),"^",14)="UNCHARGED"  d
	..i payed="P"  s payed="PP"
	..i payed=""	s payed="NP"
	.e  d
	..i (payed="")  s payed="P"
	..i (payed="NP") s payed="PP"
	
	q payed
}

ClassMethod GetReportStatus(AdmType, AdmId)
{
	new reportStatus,reportid
	s reportStatus=""
	s AdmType=AdmType_"ADM"
	s reportid=$o(^DHCPERPT(0,AdmType,AdmId,""))
	if reportid="" q reportStatus
	s reportStatus=$p($g(^DHCPERPT(reportid)),"^",2)
	q ..ParseStatus(reportStatus)
	
	
	
	//s TReportStatus
}

ClassMethod ParseStatus(status)
{
	if status="NA"  q "未审核"
	if status="A"  q "已审核"
	if status="P"  q "已打印"
	if status="S"  q "已发送"
	q ""
}

/// w ##class(web.DHCPE.Cashier).GetInvoiceInfo(12)
ClassMethod GetInvoiceInfoOld(admtype, invid)
{
	new paadm,patid,patname,regno,amount,invdate,userno,hzamount
	new sex,dob,age,pattype,compony,invNo,c
	new iadm,crmadm
	new rtn,invData
	s rtn=""
	if invid="" q rtn
	s invData=$g(^DHCPEINVPRT(invid))
	if invData="" q rtn
	s (patid,patname,regno,amount,invdate,userno)=""
	s paadm=$p(invData,"^",2)
	s patid=$p($g(^PAADM(paadm)),"^",1)
	if patid="" q rtn
	s patname=$p($g(^PAPER(patid,"ALL")),"^",1)
	s age=""
	s sex=""
	s pattype=""
	s compony=""
	if admtype="I"
	{
		s sex=$p($g(^PAPER(patid,"ALL")),"^",7)
		if sex'="" s sex=$p($g(^CT("SEX",sex)),"^",2)
		s dob=$p($g(^PAPER(patid,"ALL")),"^",6)
		if dob'=""
		{	s dob=$zd(dob,3)
			s age=$p($zd(+$h,3),"-",1)-$p(dob,"-",1)
		}
		s iadm=$o(^DHCPEIADM(0,"PAADM",paadm,""))
		if iadm'=""
		{	s crmadm=$p($g(^DHCPEIADM(iadm)),"^",4)
			s crmpibi=$p($g(^DHCPEPreIADM(crmadm)),"^",1)
			if crmpibi'=""
			{
				s pattype=$p($g(^DHCPEPreIBI(crmpibi)),"^",5)
				if pattype'="" s pattype=$p($g(^CT("SS",pattype)),"^",2)
				s compony=$p($g(^DHCPEPreIBI(crmpibi)),"^",12)
			}
		}
	}
	s regno=$p($g(^PAPER(patid,"PAT",1)),"^",1)
	s invNo=$p(invData,"^",1)
	s amount=$p(invData,"^",7)
	s invdate=$p(invData,"^",11)
	s invdate=$zd(invdate,3)
	s userno=$p(invData,"^",10)
	if userno'=""  s userno=$p($g(^SSU("SSUSR",userno)),"^",1)
	
	s hzamount=##Class(web.DHCPE.DHCPEPAY).RMBDXXZH("","",amount,2)
	s amount=$j(amount,3,2)
	s c=$c(2)
	s rtn="PatName"_c_patname
	s rtn=rtn_"^"_"RegNo"_c_regno
	s rtn=rtn_"^"_"CGJC"_c_amount
	s rtn=rtn_"^"_"PaySumPY"_c_hzamount
	s rtn=rtn_"^"_"PaySum"_c_amount
	s rtn=rtn_"^"_"OpenID"_c_userno
	s rtn=rtn_"^"_"InvNo"_c_invNo
	s rtn=rtn_"^"_"Date"_c_invdate
	
	s rtn=rtn_"^"_"Sex"_c_sex
	s rtn=rtn_"^"_"Age"_c_age
	s rtn=rtn_"^"_"Type"_c_pattype
	s rtn=rtn_"^"_"Company"_c_compony

	///s rtn=patname_"^"_regno_"^"_amount_"^"_hzamount_"^"_invdate_"^"_userno
	q rtn
}

/// w ##class(web.DHCPE.Cashier).GetInvoiceInfo("I",379,"List")
ClassMethod GetInvoiceInfo(admtype, invid, PrintType As %String = "INV")
{
	
	new paadm,patid,patname,regno,amount,invdate,userno,hzamount,paymode
	new sex,dob,age,pattype,compony,invNo,c
	new iadm,crmadm
	new rtn,invData
	new defaultfeeid,defaultfeename
	s (defaultfeeid,defaultfeename)=""
	
	d ..GetDefaultFee(.defaultfeeid,.defaultfeename)
	
	s rtn=""
	if invid="" q rtn
	s FocusPrintID=$o(^User.DHCPEINVFocusPrtI("IFPINVDRIndex"," "_invid,""))
	s invData=$g(^DHCPEINVPRT(invid))
	if invData="" q rtn
	s (patid,patname,regno,amount,invdate,userno)=""
	s paadm=$p(invData,"^",2)
	s patid=$p($g(^PAADM(paadm)),"^",1)
	if patid="" q rtn
	s patname=$p($g(^PAPER(patid,"ALL")),"^",1)
	//20120713 by rxb
	s InvName=$G(^DHCPEDataEx("InvName",invid))
	s:InvName'="" patname=InvName
	s TaxpayerNum=$G(^DHCPEDataEx("TaxpayerNum",invid))
	s age=""
	s sex=""
	s pattype=""
	s compony=""
	if admtype="I"
	{
		s sex=$p($g(^PAPER(patid,"ALL")),"^",7)
		if sex'="" s sex=$p($g(^CT("SEX",sex)),"^",2)
		s dob=$p($g(^PAPER(patid,"ALL")),"^",6)
		if dob'=""
		{	s dob=$zd(dob,3)
			s age=$p($zd(+$h,3),"-",1)-$p(dob,"-",1)
		}
		s iadm=$o(^DHCPEIADM(0,"PAADM",paadm,""))
		if iadm'=""
		{	s crmadm=$p($g(^DHCPEIADM(iadm)),"^",4)
			s crmpibi=$p($g(^DHCPEPreIADM(crmadm)),"^",1)
			if crmpibi'=""
			{
				s pattype=$p($g(^DHCPEPreIBI(crmpibi)),"^",5)
				if pattype'="" s pattype=$p($g(^CT("SS",pattype)),"^",2)
				s compony=$p($g(^DHCPEPreIBI(crmpibi)),"^",12)
			}
		}
	}
	s:$G(InvName)'="" sex=""
	s regno=$p($g(^PAPER(patid,"PAT",1)),"^",1)
	s CardNo=##class(web.DHCPE.PreIBIUpdate).GetRelate(regno,"R")
	i (CardNo'="")&&($G(^DHCPESetting("DHCPE","HospitalCode"))="SZNSFY") s regno=CardNo
	
	s idno=$p($g(^PAPER(patid,"ALL")),"^",9)
	s invNo=$p(invData,"^",1)
	//真实发票号
	i FocusPrintID'="" d
	.s invNo=$LG(^User.DHCPEINVFocusPrtD(FocusPrintID),3)
	s amount=$p(invData,"^",7)
	s InvExInfo=##class(web.DHCPE.CashierEx).GetInvAmountInfo(invid)
	i +$P(InvExInfo,"^",1)=+amount d
	.s PayModeExStr=""
	e  d
	.s PayModeExStr=""
	.q:PrintType'="INV"
	.s amount=$P(InvExInfo,"^",1)
	.s PayModeExStr=$P(InvExInfo,"^",2)
	s sswr=$p(invData,"^",21)
	i sswr'="" s sswr=$J(sswr,3,2)
	s srf="",srfLable=""
	i +sswr'=0  d 
	.s srf=sswr
	.s srfLable="发票调整费"
	s amount=amount
	//s PaySum=$j((amount+sswr),3,2)
	s PaySum=$j((amount),3,2)
	s invdate=$p(invData,"^",11)
	//真实打印日期
	i FocusPrintID'="" d
	.s invdate=$LG(^User.DHCPEINVFocusPrtD(FocusPrintID),5)
	s invtime=$p(invData,"^",12)
	//真实打印时间
	i FocusPrintID'="" d
	.s invtime=$LG(^User.DHCPEINVFocusPrtD(FocusPrintID),6)
	s invtime=$ZT(invtime,1)
	s invdate=$zd(invdate,3)
	s PAADM=$p(invData,"^",2)
	s OldInvID=$O(^DHCPEINVPRT(0,"ADM",PAADM,0))
	i OldInvID'=""  d
	.;s invdate=$p($g(^DHCPEINVPRT(OldInvID)),"^",11)
	.;s invdate=$zd(invdate,3)
	.;s invtime=$p($g(^DHCPEINVPRT(OldInvID)),"^",12)
	.;s invtime=$zt(invtime,3)	
	s username=""
	s userno=$p(invData,"^",10)
	//真实发票人
	i FocusPrintID'="" d
	.s userno=$LG(^User.DHCPEINVFocusPrtD(FocusPrintID),4)
	if userno'=""   d
	.s username=$p($g(^SSU("SSUSR",userno)),"^",2)
	.s userno=$p($g(^SSU("SSUSR",userno)),"^",1)
	
	
	s paymode=..GetPayModeInfo(invid,"3","0")
	s SYBXPayMode=$p(paymode,"%%",2)  // 保险支付
	s IPayPayMode=$p(paymode,"%%",3)   //自付
	
	s hzamount=##Class(web.DHCPE.DHCPEPAY).RMBDXXZH("","",amount,"2")
	
	s amount=$j(amount,3,2)
	s c=$c(2)	 
	if (PrintType="INV"){
			s rtn="PatName"_c_patname	
	}else{
		s rtn="PatName"_c_$e(patname,1,10)
		s rtn=rtn_"^"_"PatNameExt"_c_$e(patname,11,$l(patname))
	}
	if admtype="I"
		{s rtn=rtn_"^"_"RegNo"_c_regno
		 s rtn=rtn_"^"_"RegNoG"_c_""
		 s rtn=rtn_"^"_"PatCaption"_c_"姓名:"
		 s rtn=rtn_"^"_"SexCaption"_c_"性别:"
		 s rtn=rtn_"^"_"AgeCaption"_c_"年龄:"
		 s rtn=rtn_"^"_"RegNoCaption"_c_"登记号:"
		 s rtn=rtn_"^"_"RegNoGCaption"_c_""}
	else
		{s rtn=rtn_"^"_"RegNo"_c_regno
		 s rtn=rtn_"^"_"RegNoG"_c_regno
		 s rtn=rtn_"^"_"PatCaption"_c_"姓名:"
		 s rtn=rtn_"^"_"SexCaption"_c_""
		 s rtn=rtn_"^"_"AgeCaption"_c_""
		 s rtn=rtn_"^"_"RegNoCaption"_c_""
		 s rtn=rtn_"^"_"RegNoGCaption"_c_"登记号:"}
	s rtn=rtn_"^"_"PAAdm"_c_paadm
	s rtn=rtn_"^"_"IDNo"_c_idno_"^"_"TaxpayerNum"_c_"纳税人识别号:"_TaxpayerNum
	
	i $G(^DHCPESetting("DHCPE","InvPrintCatInfo"))="Y"  d
	.i PayModeExStr="" d
	..s rtn=rtn_..GetFeeCatInfo(invid)
	.e  d
	..s rtn=rtn_##class(web.DHCPE.CashierEx).GetFeeCatInfo(amount)
	else  d
	.s rtn=rtn_"^"_"FB1"_c_defaultfeename
	.s rtn=rtn_"^"_"FBSum1"_c_amount
	
	//s LocDesc=%session.Get("LOGON.CTLOCDESC")
	s LocDesc="JKYXB-健康医学部"

	s rtn=rtn_"^"_"LocDesc"_c_LocDesc
	//s rtn=rtn_"^"_"FB1"_c_defaultfeename
	//s rtn=rtn_"^"_"FBSum1"_c_amount
	
	s rtn=rtn_"^"_"PaySumAll"_c_hzamount_" "_amount
	s rtn=rtn_"^"_"PaySumPY"_c_hzamount
	s rtn=rtn_"^"_"PaySum"_c_PaySum
	s PayModeStr=$P(paymode,"%%",1)
	s $P(PayModeStr,":",2)=PaySum
	s InsTypeNew=""
	s InsTypeNew=$P(PayModeStr,":",1)
	s YBPayModeAmount=$P($G(^DHCPEOEITEM(invid)),"^",5)
	i YBPayModeAmount'="" s InsTypeNew="医保"
	else  s InsTypeNew="自费"
	i PayModeExStr="" d
	.s rtn=rtn_"^"_"PayMode"_c_$P(paymode,"%%",1)
	e  d
	.s rtn=rtn_"^"_"PayMode"_c_PayModeExStr
	s rtn=rtn_"^"_"InsTypeNew"_c_InsTypeNew
	s rtn=rtn_"^"_"OpenID"_c_userno
	s rtn=rtn_"^"_"OpenName"_c_username
	s rtn=rtn_"^"_"InvNo"_c_invNo
	s UsrInvNum=$G(^DHCPEINVPRT(invid,"PEInvNum"))
	s rtn=rtn_"^"_"UsrInvNum"_c_UsrInvNum
	s rtn=rtn_"^"_"YBPayModeAmount"_c_YBPayModeAmount
	s cashAmount=$j((amount-(+YBPayModeAmount)+sswr),3,2)

	s rtn=rtn_"^"_"cashAmount"_c_cashAmount
	
	s rtn=rtn_"^"_"Date"_c_invdate
	s rtn=rtn_"^"_"Year"_c_$p(invdate,"-",1)
	s rtn=rtn_"^"_"Month"_c_$p(invdate,"-",2)
	s rtn=rtn_"^"_"Day"_c_$p(invdate,"-",3)
	s rtn=rtn_"^"_"Time"_c_invtime
	s rtn=rtn_"^"_"Sex"_c_sex
	s rtn=rtn_"^"_"Age"_c_age
	s rtn=rtn_"^"_"Type"_c_pattype
	s rtn=rtn_"^"_"Company"_c_compony
	s rtn=rtn_"^"_"CurTime"_c_$ZT($P($H,",",2),1)
	s rtn=rtn_"^"_"DocDesc"_c_..GetDocNameByInvoice(invid)
	
	//原票据信息
	s OldInvID=$G(^DHCPEPRT(invid,"RefInvID"))
	i OldInvID="" d
	.s PRTOldInvInfo=""
	e  d
	.s OldInvNo=$P($g(^DHCPEINVPRT(OldInvID)),"^",1)
	.s OldAmt=$P($g(^DHCPEINVPRT(OldInvID)),"^",7)
	.s Oldinvdate=$p($g(^DHCPEINVPRT(OldInvID)),"^",11)
	.s Oldinvdate=$zd(invdate,3)
	.s Oldinvtime=$p($g(^DHCPEINVPRT(OldInvID)),"^",12)
	.s Oldinvtime=$zt(invtime,3)	
	.s PRTOldInvInfo="原交易时间:"_Oldinvdate_" "_Oldinvtime_" 原发票号:"_OldInvNo
	s rtn=rtn_"^"_"PRTOldInvInfo"_c_PRTOldInvInfo
	
	///Add For wf
	s rtn=rtn_"^"_"PatNo1"_c_regno_"  "_patname
	s rtn=rtn_"^"_"PayMode1"_c_paymode_": "_amount
	
	s rtn=rtn_"^"_"SYBXPayMode"_c_SYBXPayMode
	s rtn=rtn_"^"_"IPayPayMode"_c_IPayPayMode
	s rtn=rtn_"^"_"srf"_c_srf_"^"_"CurTime"_c_$H_"^"_"srfLable"_c_srfLable
	///End  CurTime
	
	
	//s rtn=rtn_..GetInvFeeCatInfo(invid)
	s rtn=rtn_..GetINSUInfo(invid)
	s paymodeList=..GetPayModeInfo(invid,"1","0")
	s PayModeStrNew=$P(paymodeList,"%%",1)
	s PayModeStrLeg=$l(PayModeStrNew,"&")
	s PayModeOut=""
	for k=1:1:PayModeStrLeg
	{ 
	s PayMode=$p(PayModeStrNew,"&",k)
	s PayModeDesc=$p(PayMode,"^",2)
	//s PayModeDesc=PayModeDesc_":"
	s PayModeAmont=$p(PayMode,"^",3)

	s PayModeAmont=##Class(web.DHCPE.DHCPEPAY).RMBDXXZH("","",PayModeAmont,"2")

	//i PayModeOut="" s PayModeOut="PayModeDesc"_k_$c(2)_PayModeDesc_"^"_"PayModeAmount"_k_$c(2)_PayModeAmont
	//else  s PayModeOut=PayModeOut_"^"_"PayModeDesc"_k_$c(2)_PayModeDesc_"^"_"PayModeAmount"_k_$c(2)_PayModeAmont
	i PayModeOut="" s PayModeOut=PayModeDesc
	else  s PayModeOut=PayModeOut_"/"_PayModeDesc
	
	 }
	// rxb 20121022
	s PayModeOut="PayModeDesc"_$c(2)_PayModeOut
	s rtn=rtn_"^"_PayModeOut
	s HospitalName=^DHCPESetting("DHCPE","HospitalName")
	s Hospital="HospitalName"_$c(2)_HospitalName
	s rtn=rtn_"^"_Hospital
	
	//发票补打标识
	i $d(^DHCPEDataEx("Invprt",invid)) s PrintFlag="PrintFlag"_$c(2)_"【补打】"
	E  s PrintFlag="PrintFlag"_$c(2)_""
	s rtn=rtn_"^"_PrintFlag
	s ^DHCPEDataEx("Invprt",invid)=$h_"^"_%session.Get("LOGON.USERID")

	q rtn
}

// 根据发票号取得医保信息

// w ##class(web.DHCPE.Cashier).GetINSUInfo(4)

ClassMethod GetINSUInfo(invid)
{
	n (invid)
	s c=$c(2)
	s InsuID=$P($G(^DHCPEOEITEM(invid)),"^",4)  //医保结算insu_divide表的ID
	q:InsuID="" ""
	s INSUInfo=$G(^DHCINDIV(InsuID))
	s INSUAfterAmount=$P(INSUInfo,"^",44) //结算后余额
	s INSUBeforeAmount=$P(INSUInfo,"^",43) //结算前余额
	s INSUCardNo=$P(INSUInfo,"^",18)  //结算医保卡号
	s INSUName=$P(INSUInfo,"^",27)  //结算医保卡姓名
	q "^INSUAfterAmount"_c_INSUAfterAmount_"^INSUBeforeAmount"_c_INSUBeforeAmount_"^INSUCardNo"_c_INSUCardNo_"^INSUName"_c_INSUName
	q ""
}

/// invid:发票ID
/// listFlag:是否打印明细
/// w ##class(web.DHCPE.Cashier).GetInvoiceListInfo("I",16,1)
ClassMethod GetInvoiceListInfoOld(admtype, invid, listFlag)
{
	new amount,ItemName,FactAmount
	new rtn,invData
	new billId,relateId
	new i,preAuditId,FeeType,subroot,preAdmId,childsub,feesub,errs
	s rtn=""
	if invid="" q rtn
	s invData=$g(^DHCPEINVPRT(invid))
	if invData="" q rtn
	s amount=$p(invData,"^",7)
	s amount=$j(amount,3,2)
	if listFlag=1
	{
		s i=1
		s billId=$p(invData,"^",3)
		s relateId=""
		f  s relateId=$o(^DHCPEPAPBR(0,"PBDR",billId,relateId)) q:(relateId="")  d
		.s preAuditId=$p($g(^DHCPEPAPBR(relateId)),"^",1)
		.q:preAuditId=""
		.///取项目
		.s FeeType=1
		.s subroot="ORDITEM"
		.s preAdmId=""
		.f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId=""))  d
		..s childsub=""
		..f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub=""))  d
		...s feesub=0
		...f  s feesub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub,feesub)) q:((feesub=""))  d
		....s feeData=$g(^DHCPEPreIADM(preAdmId,subroot,childsub,"FEE",feesub))	
		....s ItemName=##class(web.DHCPE.ItemFeeList).GetItemNameByFeeID(preAdmId_"||"_childsub_"||"_feesub,FeeType)
		....s FactAmount=$p(feeData,"^",2)
		....if FactAmount'="" s FactAmount=$j(FactAmount,3,2)
		....i (i#2)=1  d
		.....i rtn'="" s rtn=rtn_$c(2)
		....e  d
		.....i rtn'="" s rtn=rtn_"^"
		....s rtn=rtn_ItemName_"^"_FactAmount_"^1^"_FactAmount
		....s i=i+1
		.///取套餐
		.s FeeType=2
		.s subroot="ORDENT"
		.s preAdmId=""
		.f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId=""))  d
		..s childsub=""
		..f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub=""))  d
		...
		...q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
		...
		...s feesub=0
		...f  s feesub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub,feesub)) q:((feesub=""))  d
		....s feeData=$g(^DHCPEPreIADM(preAdmId,subroot,childsub,"FEE",feesub))	
		....s ItemName=##class(web.DHCPE.ItemFeeList).GetItemNameByFeeID(preAdmId_"||"_childsub_"||"_feesub,FeeType)
		....s FactAmount=$p(feeData,"^",2)
		....if FactAmount'="" s FactAmount=$j(FactAmount,3,2)
		....i (i#2)=1  d
		.....i rtn'="" s rtn=rtn_$c(2)
		....e  d
		.....i rtn'="" s rtn=rtn_"^"
		....s rtn=rtn_ItemName_"^"_FactAmount_"^1^"_FactAmount
		....s i=i+1
		i rtn'=""  d
		.i (i#2)=0 s rtn=rtn_"^^^^"		
		//s rtn="检查费^"_amount_"^1^"_amount_"^^^^"
	}
	else
	{	s rtn="检查费^"_amount_"^1^"_amount_"^^^^"
	}
	
	q rtn
}

/// invid:发票ID
/// listFlag:是否打印明细
/// flag: 0发票打印  1明细清单打印
/// w ##class(web.DHCPE.Cashier).GetInvoiceListInfo("I",3263,1)
ClassMethod GetInvoiceListInfo(admtype, invid, listFlag, flag As %Library.String = "0")
{
	//s listcount=..GetListCount(invid)
	if (flag=0){
		s maxlistcount=$g(^DHCPESetting("DHCPE","InvMaxListCount"))
		//if maxlistcount="" q "请先设置好发票打印的最大明细数!"
		I maxlistcount=""  S maxlistcount="1"
		s ItemInfos=..GetInvFeeListInfo(invid,1,1,.listcount)
		if (listcount>maxlistcount) s listFlag=0	
	}
	
	i flag=1
	{
		q ..GetInvFeeListInfo(invid,listFlag,flag)
	}else{
		s invData=$g(^DHCPEINVPRT(invid))
		s amount=$P(invData,"^",7)
		s InvExInfo=##class(web.DHCPE.CashierEx).GetInvAmountInfo(invid)
		i +$P(InvExInfo,"^",1)'=+amount d
		.s listFlag=0
		q ..GetInvFeeListInfo(invid,listFlag,flag)
	}
	new curdatetime,job,tmpdata
	new amount,ItemName,ItemId,FactAmount,qty,Uom
	new itmsub,itmdata,itmFactAmount,itmSumAmount,itmAccountAmount,sumAccount
	new rtn,invData
	new billId,relateId
	new i,preAuditId,FeeType,subroot,preAdmId,childsub,feesub,errs
	new defaultfeeid,defaultfeename
	s (defaultfeeid,defaultfeename)=""
	
	s col=$g(^DHCPESetting("DHCPE","InvCol"))
	if col="" s col=1
	s invcolSet=^DHCPESetting("DHCPE","InvColSortType")
	if invcolSet="" s invcolSet=1
	
	s rtn=""
	if invid="" q rtn
	s invData=$g(^DHCPEINVPRT(invid))
	if invData="" q rtn
	s amount=$p(invData,"^",7)
	b //a
	s amount=$j(amount,3,2)
	
	d ..GetDefaultFee(.defaultfeeid,.defaultfeename)
	
	if listFlag=1
	{
		s i=0
		s billId=$p(invData,"^",3)
		s relateId=""
		
		s curdatetime=$h
		s job=$j
		k ^DHCTemp("GetInvoiceListInfo",curdatetime,job)
		f  s relateId=$o(^DHCPEPAPBR(0,"PBDR",billId,relateId)) q:(relateId="")  d
		.s preAuditId=$p($g(^DHCPEPAPBR(relateId)),"^",1)
		.q:preAuditId=""
		.///取项目
		.s FeeType=1
		.s subroot="ORDITEM"
		.s preAdmId=""
		.f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId=""))  d
		..s childsub=""
		..f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub=""))  d
		...
		...q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",16)'=1	//判断是否有效
		...s itmAccountAmount=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",14)
		...if itmAccountAmount'="" s itmAccountAmount=$j(itmAccountAmount,3,2)
		...s feesub=0
		...f  s feesub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub,feesub)) q:((feesub=""))  d
		....s feeData=$g(^DHCPEPreIADM(preAdmId,subroot,childsub,"FEE",feesub))	
		....s ItemName=##class(web.DHCPE.ItemFeeList).GetItemNameByFeeID(preAdmId_"||"_childsub,FeeType,1)
		....
		....s ItemName=..TransItem2PrintInvItem(ItemName)
		....
		....s FactAmount=$p(feeData,"^",2)
		....if FactAmount'="" s FactAmount=$j(FactAmount,3,2)
		....s ItemId=$p(ItemName,"^",2)
		....s ItemName=$p(ItemName,"^",1)
		....s Uom=..GetUomByArcItem(ItemId)
		....s itmFactAmount=FactAmount
		....d FillTmpData		
		.///取套餐
		.s FeeType=2
		.s subroot="ORDENT"
		.s preAdmId=""
		.f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId=""))  d
		..s childsub=""
		..f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub=""))  d
		...
		...q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
		...s itmAccountAmount=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",7)
		...if itmAccountAmount'="" s itmAccountAmount=$j(itmAccountAmount,3,2)
		...s feesub=0
		...f  s feesub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub,feesub)) q:((feesub=""))  d
		....s feeData=$g(^DHCPEPreIADM(preAdmId,subroot,childsub,"FEE",feesub))	
		....s ItemName=##class(web.DHCPE.ItemFeeList).GetItemNameByFeeID(preAdmId_"||"_childsub,FeeType,1)
		....s FactAmount=$p(feeData,"^",2)
		....if FactAmount'="" s FactAmount=$j(FactAmount,3,2)
		....
		....s itmSumAmount=##class(web.DHCPE.Cashier).GetEntSumAmount(preAdmId_"||"_childsub)
		....s itmSumAmount=$j(itmSumAmount,3,2)
		....i itmSumAmount'=FactAmount  d
		.....s itmFactAmount=FactAmount
		.....i flag=0  d
		......//s ItemId=$g(^DHCPESetting("DHCPE", "InvDefaulltFee"))
		......//s ItemName=$p($g(^ARCIM($p(ItemId,"||",1),$p(ItemId,"||",2),1)),"^",2)
		......s ItemId=defaultfeeid
		......s ItemName=defaultfeename
		......s Uom=..GetUomByArcItem(ItemId)
		.....e  d
		......s ItemId=$p(ItemName,"^",2)
		......s ItemName=$p(ItemName,"^",1)
		......s Uom=""
		.....//b
		.....d FillTmpData 
		....q:itmSumAmount'=FactAmount
		....//
		....s itmSumAmount=0
		....s itmsub=""
		....f  s itmsub=$o(^DHCPEPreIADM(0,"OrdEnt",preAdmId_"||"_childsub,preAdmId,itmsub)) q:((itmsub=""))  d
		.....
		.....q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",itmsub)),"^",16)'=1	//判断是否有效
		.....
		.....q:FactAmount=itmSumAmount
		.....s itmdata=$g(^DHCPEPreIADM(preAdmId,"ORDITEM",itmsub))
		.....s ItemName=##class(web.DHCPE.ItemFeeList).GetItemNameByFeeID(preAdmId_"||"_itmsub,1,1)
		.....s ItemName=..TransItem2PrintInvItem(ItemName)
		.....s ItemId=$p(ItemName,"^",2)
		.....s ItemName=$p(ItemName,"^",1)
		.....s Uom=..GetUomByArcItem(ItemId)
		.....s ADMFeeType=$G(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_itmsub)) 
		.....s itmFactAmount=##class(web.DHCPE.Handle.ARCItmMast).GetItmPrice(ItemId,"","","","","","","",preAdmId,ADMFeeType)
		.....s itmFactAmount=+itmFactAmount
		.....//b
		.....//if itmFactAmount>(FactAmount-itmSumAmount)  d
		.....//.s itmFactAmount=FactAmount-itmSumAmount
		.....//s itmSumAmount=itmSumAmount+itmFactAmount
		.....d FillTmpData
			
		d TmpDataToString
		i rtn'=""  d
		.s j=(i#col)		
	}
	else
	{
		s j=col-1
		if invcolSet=1 s rtn=defaultfeename_"^"_amount_"^1^"_amount
		if invcolSet=2 s rtn=defaultfeename_"^"_"次"_"^1^"_amount
	}
	i rtn'=""
	{
		for k=1:1:j s rtn=rtn_"^^^^"
	}
	b  //1
	q rtn
	
FillTmpData
	//w "itmFactAmount:"_itmFactAmount
	s tmpdata=$g(^DHCTemp("GetInvoiceListInfo",curdatetime,job,ItemId,itmFactAmount))
	if tmpdata=""  d
	.s tmpdata=ItemName_"^"_1_"^"_itmFactAmount_"^"_itmFactAmount_"^"_Uom_"^"_itmAccountAmount
	e  d
	.s $p(tmpdata,"^",2)=+$p(tmpdata,"^",2)+1
	.s $p(tmpdata,"^",3)=+$p(tmpdata,"^",3)+itmFactAmount
	s ^DHCTemp("GetInvoiceListInfo",curdatetime,job,ItemId,itmFactAmount)=tmpdata
	q
TmpDataToString
	new ItemPrice
	s ItemId=""
	s rtn=""
	s i=0
	
	f  s ItemId=$o(^DHCTemp("GetInvoiceListInfo",curdatetime,job,ItemId)) q:((ItemId=""))  d
	.s ItemPrice=""
	.f  s ItemPrice=$o(^DHCTemp("GetInvoiceListInfo",curdatetime,job,ItemId,ItemPrice)) q:((ItemPrice=""))  d
	..s tmpdata=$g(^DHCTemp("GetInvoiceListInfo",curdatetime,job,ItemId,ItemPrice))
	..s ItemName=$p(tmpdata,"^",1)
	..s qty=$p(tmpdata,"^",2)
	..s FactAmount=$p(tmpdata,"^",3)
	..s Uom=$p(tmpdata,"^",5)
	..s AccountAmount=$p(tmpdata,"^",6)
	..i (i#col)=0  d
	...i rtn'="" s rtn=rtn_$c(2)
	..e  d
	...i rtn'="" s rtn=rtn_"^"
	..i flag=1 d
	...s rtn=rtn_ItemName_"^"_Uom_"^"_ItemPrice_"^"_qty_"^"_FactAmount
	..e  d
	...i invcolSet=1 s rtn=rtn_ItemName_"^"_ItemPrice_"^"_qty_"^"_FactAmount
	...i invcolSet=2 s rtn=rtn_ItemName_"^"_Uom_"^"_qty_"^"_FactAmount
	...i invcolSet=3 s rtn=rtn_ItemName_"^"_Uom_"^"_ItemPrice_"^"_qty_"^"_FactAmount
	..s i=i+1
	k ^DHCTemp("GetInvoiceListInfo",curdatetime,job)
	q
}

ClassMethod GetDefaultFee(ItemId, ItemName)
{
	s ItemName=""
	s ItemId=$g(^DHCPESetting("DHCPE", "InvDefaulltFee"))
	i ItemId'="" s ItemName=$p($g(^ARCIM($p(ItemId,"||",1),$p(ItemId,"||",2),1)),"^",2)
	i $g(^DHCPESetting("DHCPE", "HospitalCode"))="SYYD" s ItemName="检查费"
	q ItemId_"^"_ItemName
}

ClassMethod GetUomByArcItem(arcitemid)
{
	q ""
	new sub,ver,uom
	if arcitemid="" q ""
	s sub=$p(arcitemid,"||",1)
	s ver=$p(arcitemid,"||",2)
	if ((sub="")||(ver="")) q ""
	///BillingUOM
	s uom=$p($g(^ARCIM(sub,ver,8)),"^",14)
	if uom'="" s uom=$p($g(^CT("UOM",uom)),"^",2)
	q uom
}

/// w ##class(web.DHCPE.Cashier).GetUomByTarItem(14216)
ClassMethod GetUomByTarItem(TarItemDR)
{
	s Uom=""
	q:TarItemDR="" ""
	s UomDR=$p($g(^DHCTARI(TarItemDR)),"^",3)
	i UomDR'="" s Uom=$p($g(^CT("UOM",UomDR)),"^",2)
	q Uom
}

/// w ##class(web.DHCPE.Cashier).GetEntSumAmount("363||1")
/// 根据医瞩套餐内包含各项医瞩的单价计算套餐合计
ClassMethod GetEntSumAmount(preEntId)
{
	new preAdmId,childsub,itmsub,sumAount,itmAmount
	new ItemName,ItemId
	s preAdmId=$p(preEntId,"||",1)
	s childsub=$p(preEntId,"||",2)
	if ((preAdmId="")||(childsub="")) q 0
	s sumAount=0
	s itmsub=""
	f  s itmsub=$o(^DHCPEPreIADM(0,"OrdEnt",preEntId,preAdmId,itmsub)) q:((itmsub=""))  d
	.
	.q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",itmsub)),"^",16)'=1	//判断是否有效
	.
	.s ItemName=##class(web.DHCPE.ItemFeeList).GetItemNameByFeeID(preAdmId_"||"_itmsub,1,1)
	.s ItemId=$p(ItemName,"^",2)
	.s ADMFeeType=$G(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_itmsub))
	.s itmAmount=##class(web.DHCPE.Handle.ARCItmMast).GetItmPrice(ItemId,"","","","","","","",preAdmId,ADMFeeType)
	.s sumAount=sumAount+itmAmount
	q sumAount
}

/// 检查是否有套餐金额和单项合计金额不一致的
/// w ##class(web.DHCPE.Cashier).CheckAmountDiffer()
ClassMethod CheckAmountDiffer(preAuditIds)
{
	new itmsub,itmdata,itmFactAmount,itmSumAmount,FactAmount
	new j,preAuditId,FeeType,subroot,preAdmId,childsub,feesub,errs
	new differFlag
	s differFlag=0
	s j=1
	while(j<=$l(preAuditIds,"^")){
			s preAuditId=$p(preAuditIds,",",j)
			q:preAuditId=""
			///取套餐
			s FeeType=2
			s subroot="ORDENT"
			s preAdmId=""
			f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId="")||(differFlag=1))  d
			.s childsub=""
			.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub="")||(differFlag=1))  d
			..
			..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
			..
			..s feesub=0
			..f  s feesub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub,feesub)) q:((feesub=""))  d
			...s feeData=$g(^DHCPEPreIADM(preAdmId,subroot,childsub,"FEE",feesub))	
			...s FactAmount=$p(feeData,"^",2)
			...s itmSumAmount=..GetEntSumAmount(preAdmId_"||"_childsub)
			...if itmSumAmount'=FactAmount s differFlag=1
			if (differFlag=1) q
			s j=j+1
	}
	q differFlag
}

/// 获取审核对应的明细各数
/// w ##class(web.DHCPE.Cashier).GetListCount(16)
ClassMethod GetListCount(preAuditIds)
{
	s TarItemCount=##class(web.DHCPE.CashierEx).GetTarItemCount(preAuditIds)
	q TarItemCount
	

	n (preAuditIds)
	s j=1
	s count=0
	while(j<=$l(preAuditIds,",")){
			s preAuditId=$p(preAuditIds,",",j)
			q:preAuditId=""
			s GIType=$P(^DHCPEPreA(preAuditId),"^",1)
			q:GIType="G"
			///取项目
			s FeeType=1
			s subroot="ORDITEM"
			s preAdmId=""
			f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId=""))  d
			.s childsub=""
			.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub=""))  d
			..
			..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",16)'=1	//判断是否有效
			..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",2)'=""	//判断是否套餐项目
			..s count=count+1
			
			///取套餐
			s FeeType=2
			s subroot="ORDENT"
			s preAdmId=""
			f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId=""))  d
			.s childsub=""
			.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub=""))  d
			..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
			..s count=count+1
			s j=j+1
	}
	q count
}

/// 作废发票，并生成新的发票
/// invprtid发票id
/// itemfeeids:退的费用明细
/// payedInfos：新发票的支付方式信息
/// remainamount：新发票的金额
ClassMethod DropInvPrt(invprtid, userId, locId, itemfeeids, payedInfos, remainamount, InvNo As %Library.String = "", InvID As %Library.String = "", pAdmType As %Library.String = "", pAdmId As %Library.String = "", isReprint As %Library.String = "0", listFlag As %Library.String = "", AllRefund As %Library.String = "", RefuntInfo As %String = "", HospitalID As %String = "")
{
	new errs
	new billid,relateid,preAuditId,itemfeeid
	new curDate,curTime
	new FeeType,subroot,preAdmId,childsub,feesub
	new newIds,ToIds,newflag,toflag,newid,toid
	new i,amount
	s curDate=+$h
	s curTime=$p($h,",",2)
	s errs=""
	s billid=""	
	s TaxpayerNum=$P(InvNo,"^",5)
	s RealAdmReason=$P(InvNo,"^",4)
	s NoPrintInv=$P(InvNo,"^",3)
	s InvName=$P(InvNo,"^",2)
	s InvNo=$P(InvNo,"^",1)
	
	i invprtid="" q "请传入要作废的发票！"
	if $p($g(^DHCPEINVPRT(invprtid)),"^",9)'="" q "该发票已经作废!"
	i $o(^DHCPEINVPRT(0,"REF",invprtid,""))'="" q "该发票已经作废!"
	
	i ((itemfeeids="")&&(isReprint=0)) q "请选择要退费的项目!"
	i ((itemfeeids'="")&&(isReprint=1)) q "重打发票不能选择退费的项目!"
	
	s billid =$p($g(^DHCPEINVPRT(invprtid)),"^",3)
	i billid="" q "找不到对应的帐单！"	
	s isCanRefund=..judgeItmesCanRefund(itemfeeids)
	q:isCanRefund=1 "申请退费项目被执行,请重新申请!"
	s OldInvNo=$p($g(^DHCPEINVPRT(invprtid)),"^",1)
	s FocusPrintID=""
	s FocusPrintID=$o(^User.DHCPEINVFocusPrtI("IFPINVDRIndex"," "_invprtid,""))

	//i ($L(OldInvNo,"DHC")=2)&&(isReprint=1)&&(AllRefund'=1)
	i ($L(OldInvNo,"DHC")=2)&&(isReprint=1)&&(AllRefund'=1)&&(FocusPrintID="")
	{
		s preAuditIds=""
		s relateid=""	
		f  s relateid=$o(^DHCPEPAPBR(0,"PBDR",billid,relateid)) q:(relateid="")  d
		.s preAuditId=$p($g(^DHCPEPAPBR(relateid)),"^",1)
		.s preAuditIdStatus=$p($G(^DHCPEPreA(preAuditId)),"^",21)
		.q:preAuditIdStatus="NU"
		.i preAuditIds="" d
		..s preAuditIds=preAuditId
		.e  d
		..s preAuditIds=preAuditIds_","_preAuditId
		q "^^"_preAuditIds
	}
	
	new curInvNo
	s curInvNo=##class(web.DHCPE.DHCPEPAY).getcurinvno(userId)
	if InvNo'=$p(curInvNo,"^",1) q "传入发票号不正确,请刷新后重试!"
	
	
	///调用作废发票方法		
	s dropInvId=##Class(web.DHCPE.DHCPEBillCharge).CancelPEBillCharge(invprtid, "",userId,RefuntInfo,HospitalID)
	i $p(dropInvId,"^",1)'=0 q "作废原来发票失败!"
	s dropInvId=$p(dropInvId,"^",2)
	i dropInvId="" q "作废原来发票失败!"
	s newbillid =$p($g(^DHCPEINVPRT(dropInvId)),"^",3)
	i newbillid="" q "作废发票没有对应的帐单！"
	/*
	s Flag=##class(web.DHCPE.DHCPEPAY).isReportInv("",invprtid,userId)
	i Flag=1 d
	.s i=$L(payedInfos,"^")
	.f k=1:1:i  d
	..s OneInfo=$P(payedInfos,"^",i)
	..i ($P(OneInfo,",",1)="4")||($P(OneInfo,",",1)="15") d
	...i $P(OneInfo,",",4)<500 d
	....s OneInfo="1,"_$P(OneInfo,",",2)
	....s $P(payedInfos,"^",i)=OneInfo
	....s arcrcpt=$P(^DHCPEINVPRT(dropInvId),"^",4)
	....&sql(update ar_rcptpaymode set paym_paymode_dr=1 where paym_parref=:arcrcpt)
	....s ^wrz(1)=SQLCODE
	....//s ^wrz(1)=OtherRefundFlag
	...e  d
	....s ^DHCPEDataEx("DHCPEINVPRT","RedRcp","YHK",invprtid,$P(OneInfo,",",1))=$P(OneInfo,",",4)
	*/
	s errs=##class(web.DHCPE.CashierEx).UpdatePayModeAmtByRefInv(dropInvId,userId)
	;s errs=##class(web.DHCPE.CashierEx).UpdatePayModeAmtByInv(dropInvId,userId)
	i errs'="" q errs
	s status="A"
	s (newIds,ToIds)=""
	s relateid=""	
	f  s relateid=$o(^DHCPEPAPBR(0,"PBDR",billid,relateid)) q:((relateid="")||(errs'=""))  d
	.s preAuditId=$p($g(^DHCPEPAPBR(relateid)),"^",1)
	.//&SQL(Update DHC_PE_PreAudit set PA_Status='NU' where PA_RowId=:preAuditId and PA_Status='U')
	.&SQL(Update DHC_PE_PreAudit set PA_Status='NU' where PA_RowId=:preAuditId)
	.i SQLCODE s errs="作废审核记录失败!"
	.q:errs'=""
	.&SQL(Insert into DHC_PE_PAPBRelate(PAPB_PA_DR,PAPB_PB_DR,PAPB_PBType,PAPB_UpdateUser_DR,PAPB_UpdateDate,PAPB_UpdateTime) values (:preAuditId,:newbillid,:status,:userId,:curDate,:curTime))
	.if SQLCODE s errs="生成作废发票的帐单对照记录失败!"
	.q:errs'=""
	.///分拆审核表，并处理其状态
	.s (newflag,toflag,newid,toid)=""
	.///取项目
	.s FeeType=1
	.s subroot="ORDITEM"
	.s preAdmId=""
	.f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId="")||(errs'=""))  d
	..s childsub=""
	..f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub="")||(errs'=""))  d
	...s feesub=0
	...f  s feesub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub,feesub)) q:((feesub="")||(errs'=""))  d
	....s itemfeeid=preAdmId_"||"_childsub_"||"_feesub
	....i itemfeeids[(",1^"_itemfeeid_",")  d
	.....i toflag=""  d
	......&SQL(Insert Into DHC_PE_PreAudit(PA_ADMType,PA_CRMADM,PA_GIADM,PA_ContractNo,PA_Rebate,PA_AccountAmount,PA_DiscountedAmount,PA_SaleAmount,PA_FactAmount,PA_AuditedStatus,PA_AuditUser_DR,PA_AuditDate,PA_AuditTime,PA_ChargedStatus,PA_CancelUser_DR,PA_CancelDate,PA_CancelTime,PA_Remark,PA_PrivilegeMode,PA_Type,PA_Status) select PA_ADMType,PA_CRMADM,PA_GIADM,PA_ContractNo,PA_Rebate,PA_AccountAmount,PA_DiscountedAmount,PA_SaleAmount,PA_FactAmount,PA_AuditedStatus,PA_AuditUser_DR,PA_AuditDate,PA_AuditTime,PA_ChargedStatus,PA_CancelUser_DR,PA_CancelDate,PA_CancelTime,PA_Remark,PA_PrivilegeMode,PA_Type,'U' from DHC_PE_PreAudit Where PA_RowId=:preAuditId)
	......if SQLCODE s errs="拆分审核表失败!"
	......q:errs'=""
	......s toflag=1
	......s toid=%ROWID
	......i ToIds'="" s ToIds=ToIds_","
	......s ToIds=ToIds_toid
	.....q:errs'=""
	.....&SQL(Insert Into DHC_PE_PreIOrdItemFee(PIOIF_ParRef,PIOIF_AddOrdItem,PIOIF_FactAmount,PIOIF_PrivilegeMode,PIOIF_Privilege,PIOIF_PAudit_DR,PIOIF_UpdateUser_DR,PIOIF_UpdateDate,PIOIF_UpdateTime) Select PIOIF_ParRef,PIOIF_AddOrdItem,PIOIF_FactAmount,PIOIF_PrivilegeMode,PIOIF_Privilege,:toid,:userId,:curDate,:curTime From DHC_PE_PreIOrdItemFee where PIOIF_RowId=:itemfeeid) 
	.....if SQLCODE s errs="重新生成费用明细失败!"
	....e  d
	.....i newflag=""  d
	......&SQL(Insert Into DHC_PE_PreAudit(PA_ADMType,PA_CRMADM,PA_GIADM,PA_ContractNo,PA_Rebate,PA_AccountAmount,PA_DiscountedAmount,PA_SaleAmount,PA_FactAmount,PA_AuditedStatus,PA_AuditUser_DR,PA_AuditDate,PA_AuditTime,PA_ChargedStatus,PA_CancelUser_DR,PA_CancelDate,PA_CancelTime,PA_Remark,PA_PrivilegeMode,PA_Type,PA_Status) select PA_ADMType,PA_CRMADM,PA_GIADM,PA_ContractNo,PA_Rebate,PA_AccountAmount,PA_DiscountedAmount,PA_SaleAmount,PA_FactAmount,PA_AuditedStatus,PA_AuditUser_DR,PA_AuditDate,PA_AuditTime,PA_ChargedStatus,PA_CancelUser_DR,PA_CancelDate,PA_CancelTime,PA_Remark,PA_PrivilegeMode,PA_Type,'U' from DHC_PE_PreAudit Where PA_RowId=:preAuditId)
	......if SQLCODE s errs="生成新审核表失败!"
	......q:errs'=""
	......s newflag=1
	......s newid=%ROWID
	......i newIds'="" s newIds=newIds_","
	......s newIds=newIds_newid
	.....q:errs'=""
	.....&SQL(Insert Into DHC_PE_PreIOrdItemFee(PIOIF_ParRef,PIOIF_AddOrdItem,PIOIF_FactAmount,PIOIF_PrivilegeMode,PIOIF_Privilege,PIOIF_PAudit_DR,PIOIF_UpdateUser_DR,PIOIF_UpdateDate,PIOIF_UpdateTime) Select PIOIF_ParRef,PIOIF_AddOrdItem,PIOIF_FactAmount,PIOIF_PrivilegeMode,PIOIF_Privilege,:newid,:userId,:curDate,:curTime From DHC_PE_PreIOrdItemFee where PIOIF_RowId=:itemfeeid) 
	.....if SQLCODE s errs="重新生成费用明细失败!"
	.q:errs'=""
	.s FeeType=2
	.s subroot="ORDENT"
	.s preAdmId=""
	.f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId="")||(errs'=""))  d
	..s childsub=""
	..f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub="")||(errs'=""))  d
	...s feesub=0
	...f  s feesub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub,feesub)) q:((feesub="")||(errs'=""))  d
	....s itemfeeid=preAdmId_"||"_childsub_"||"_feesub
	....i itemfeeids[(",2^"_itemfeeid_",")  d
	.....i toflag=""  d
	......&SQL(Insert Into DHC_PE_PreAudit(PA_ADMType,PA_CRMADM,PA_GIADM,PA_ContractNo,PA_Rebate,PA_AccountAmount,PA_DiscountedAmount,PA_SaleAmount,PA_FactAmount,PA_AuditedStatus,PA_AuditUser_DR,PA_AuditDate,PA_AuditTime,PA_ChargedStatus,PA_CancelUser_DR,PA_CancelDate,PA_CancelTime,PA_Remark,PA_PrivilegeMode,PA_Type,PA_Status) select PA_ADMType,PA_CRMADM,PA_GIADM,PA_ContractNo,PA_Rebate,PA_AccountAmount,PA_DiscountedAmount,PA_SaleAmount,PA_FactAmount,PA_AuditedStatus,PA_AuditUser_DR,PA_AuditDate,PA_AuditTime,PA_ChargedStatus,PA_CancelUser_DR,PA_CancelDate,PA_CancelTime,PA_Remark,PA_PrivilegeMode,PA_Type,'U' from DHC_PE_PreAudit Where PA_RowId=:preAuditId)
	......if SQLCODE s errs="拆分审核表失败!"
	......q:errs'=""
	......s toflag=1
	......s toid=%ROWID
	......i ToIds'="" s ToIds=ToIds_","
	......s ToIds=ToIds_toid
	.....q:errs'=""
	.....&SQL(Insert Into DHC_PE_PreIOrdEntFee(PIOEF_ParRef,PIOEF_AddOrdItem,PIOEF_FactAmount,PIOEF_PrivilegeMode,PIOEF_Privilege,PIOEF_PAudit_DR,PIOEF_UpdateUser_DR,PIOEF_UpdateDate,PIOEF_UpdateTime) Select PIOEF_ParRef,PIOEF_AddOrdItem,PIOEF_FactAmount,PIOEF_PrivilegeMode,PIOEF_Privilege,:toid,:userId,:curDate,:curTime From DHC_PE_PreIOrdEntFee where PIOEF_RowId=:itemfeeid) 
	.....if SQLCODE s errs="重新生成费用明细失败!"
	....e  d
	.....i newflag=""  d
	......&SQL(Insert Into DHC_PE_PreAudit(PA_ADMType,PA_CRMADM,PA_GIADM,PA_ContractNo,PA_Rebate,PA_AccountAmount,PA_DiscountedAmount,PA_SaleAmount,PA_FactAmount,PA_AuditedStatus,PA_AuditUser_DR,PA_AuditDate,PA_AuditTime,PA_ChargedStatus,PA_CancelUser_DR,PA_CancelDate,PA_CancelTime,PA_Remark,PA_PrivilegeMode,PA_Type,PA_Status) select PA_ADMType,PA_CRMADM,PA_GIADM,PA_ContractNo,PA_Rebate,PA_AccountAmount,PA_DiscountedAmount,PA_SaleAmount,PA_FactAmount,PA_AuditedStatus,PA_AuditUser_DR,PA_AuditDate,PA_AuditTime,PA_ChargedStatus,PA_CancelUser_DR,PA_CancelDate,PA_CancelTime,PA_Remark,PA_PrivilegeMode,PA_Type,'U' from DHC_PE_PreAudit Where PA_RowId=:preAuditId)
	......if SQLCODE s errs="生成新审核表失败!"
	......q:errs'=""
	......s newflag=1
	......s newid=%ROWID
	......i newIds'="" s newIds=newIds_","
	......s newIds=newIds_newid
	.....q:errs'=""
	.....&SQL(Insert Into DHC_PE_PreIOrdEntFee(PIOEF_ParRef,PIOEF_AddOrdItem,PIOEF_FactAmount,PIOEF_PrivilegeMode,PIOEF_Privilege,PIOEF_PAudit_DR,PIOEF_UpdateUser_DR,PIOEF_UpdateDate,PIOEF_UpdateTime) Select PIOEF_ParRef,PIOEF_AddOrdItem,PIOEF_FactAmount,PIOEF_PrivilegeMode,PIOEF_Privilege,:newid,:userId,:curDate,:curTime From DHC_PE_PreIOrdEntFee where PIOEF_RowId=:itemfeeid) 
	.....if SQLCODE s errs="重新生成费用明细失败!"
	///更新退费对应的医瞩状态
	i ToIds'="" 
	s i=1
	while(i<=$l(ToIds,",")){		
		s toid=$p(ToIds,",",i)
		if toid'=""  s errs=..UpdatePreAuditPayed(toid,1)
		q:errs'=""
		s i=i+1
	}
	i errs'="" q errs
	i pAdmType'="G" d ##class(web.DHCPE.AdmRecordManager).Insert(pAdmId,"I","DropInvPrt",userId,invprtid)
	i pAdmType="G" d ##class(web.DHCPE.GAdmRecordManager).Insert(pAdmId,"I","DropInvPrt",userId,invprtid)
	//插入his发票信息
	s ret=##class(web.DHCPE.CashierEx).InsertOPInv(dropInvId)
	
	//更新支付方式
	s SQLCODE=##class(web.DHCPE.CashierEx).UpdatePayMode(dropInvId,payedInfos)
	
	s feeids=$P(itemfeeids,";",1)
	s i=$l(feeids,",")-1
	f k=2:1:i d
	.s oneFeeid=$P(feeids,",",k)
	.s type=$P(oneFeeid,"^",1)
	.s oneFee=$P(oneFeeid,"^",2)
	.q:+oneFee=0
	.s itemid="",orditemid=""
	.i type=1 d
	..s itemid=$P(oneFee,"||",1,2)
	.e  d
	..s orditemid=$P(oneFee,"||",1,2)
	.d ##class(web.DHCPE.PreItemList).IDeleteItem(+oneFee,"PERSON",itemid,orditemid)

	
	///全退则直接返回
	if newIds="" q errs
	s i=1
	while(i<=$l(newIds,",")){
				
		s newid=$p(newIds,",",i)
		if newid'=""  s errs=..UpdatePreAuditPayed(newid,1)
		q:errs'=""
		s i=i+1
	}
	i errs'="" q errs
	///重新计算审核表费用	
	i pAdmType="G" 
	{	s preAdmId=$p($g(^DHCPEGADM(pAdmId)),"^",2)
		d ##class(web.DHCPE.PreIADM).UpdateGroupAuditAmount(preAdmId,"")}
	else
	{	s preAdmId=$p($g(^DHCPEIADM(pAdmId)),"^",4)	
		d ##class(web.DHCPE.PreIADM).UpdatePersonAuditAmount(preAdmId)
	}
	i AllRefund="1" q errs
	
	
	
	///重新结算打印发票
	new amount,rtn
	s rtn=""
	s amount=..GetAuditsAmount("","",newIds)
	s remainamount=$j(remainamount,3,2)
	s amount=$j(amount,3,2)
	if (+remainamount'=+amount)&&(isReprint=0) q "重新结算的金额不一致!"_remainamount_"  "_amount
	///当金额大于0，结算
	if amount>0  d
	.s CardAccDR=$P(RefuntInfo,"^",2) 
	.s InsuFlag=##class(web.DHCPE.DHCPEBillCharge).GetInsuID(invprtid,0)
	.//如果存在医保，全归到第一种支付方式里面
	.if InsuFlag'="" d
	..s CashMode=$p($p(payedInfos,"^",1),",",1)
	..s OtherNo=$p($p(payedInfos,"^",1),",",3)
	..s NewPayMode=$p($p(payedInfos,"^",1),",",5)
	..s:NewPayMode'="" CashMode=NewPayMode
	..s TotalAmountNew=0
	..s PayedModeLength=$l(payedInfos,"^")
	..f i=1:1:PayedModeLength  d
	...s OneAmount=$p($p(payedInfos,"^",i),",",2)
	...s TotalAmountNew=TotalAmountNew+OneAmount
	..s payedInfos=CashMode_","_TotalAmountNew_","_OtherNo_"#"_CardAccDR
	.e  d
	..s payedInfos=##class(web.DHCPE.CashierEx).GetDropPaymodeInfo(payedInfos,invprtid)_"#"_CardAccDR
	.s rtn=..Cashier("","",newIds,"",amount,payedInfos,userId,locId,InvNo_"^"_InvName_"^"_NoPrintInv_"^"_RealAdmReason_"^"_TaxpayerNum,InvID_"^"_invprtid,pAdmType,pAdmId,listFlag,"",HospitalID)	
	.i +rtn=0 d
	..//s ret=##class(web.DHCPE.NetPre.Pay).Refund($P(rtn,"^",3),dropInvId)
	q rtn
	/*
	new amount,rtn
	s rtn=""
	s amount=..GetAuditsAmount("","",newIds)
	s remainamount=$j(remainamount,3,2)
	s amount=$j(amount,3,2)
	if (+remainamount'=+amount)&&(isReprint=0) q "重新结算的金额不一致!"_remainamount_"  "_amount
	///当金额大于0，结算
	if amount>0  d
	.s CardAccDR=$P(RefuntInfo,"^",2) 
	.s InsuFlag=##class(web.DHCPE.DHCPEBillCharge).GetInsuID(invprtid,0)
	.if InsuFlag'="" d
	..s CashMode=$p($p(payedInfos,"^",1),",",1)
	..s OtherNo=$p($p(payedInfos,"^",1),",",3)
	..s TotalAmountNew=0
	..s PayedModeLength=$l(payedInfos,"^")
	..f i=1:1:PayedModeLength  d
	...s OneAmount=$p($p(payedInfos,"^",i),",",2)
	...s TotalAmountNew=TotalAmountNew+OneAmount
	..s payedInfos=CashMode_","_TotalAmountNew_","_OtherNo_"#"_CardAccDR
	.e  d
	..s payedInfos=##class(web.DHCPE.CashierEx).GetDropPaymodeInfo(payedInfos,invprtid)
	.;s SSPFlag=##class(web.DHCPE.CashierEx).GetSSPFlag(invprtid)
	.;_"^"_SSPFlag
	.s rtn=..Cashier("","",newIds,"",amount,payedInfos,userId,locId,InvNo_"^"_InvName_"^"_NoPrintInv_"^"_RealAdmReason,InvID,pAdmType,pAdmId,listFlag)	
	.;errs_"^"_InvoicId_"^"_RelInvID_"^"_PrintDetail
	.i $P(rtn,"^",1)="" d
	..s NewInvID=$P(rtn,"^",3) ;记录原交易票据
	..s:NewInvID'="" ^DHCPEPRT(NewInvID,"RefInvID")=invprtid
	..s ^DHCPEPRT(invprtid,"NewRefInvID")=NewInvID
	q rtn
	*/
}

// 1500*5%+300*10%+1100*20

/// feetype=  1:项目费  2:套餐费
/// newauditid:作废原来审核记录后，新生成的审核记录id
ClassMethod RecreateItemFee(feetype, itemfeeid, newauditid)
{
	/*
	if feetype=1
	{
		&SQL(Update DHC_PE_PreIOrdItemFee set PIOIF_Flag='' Where PIOIF_RowId=:itemfeeid)
		if SQLCODE q "作废费用明细状态失败!"
		&SQL(Insert Into DHC_PE_PreIOrdItemFee(PIOIF_ParRef,PIOIF_AddOrdItem,PIOIF_FactAmount,PIOIF_PrivilegeMode,PIOIF_Privilege,PIOIF_PAudit_DR,PIOIF_UpdateUser_DR,PIOIF_UpdateDate,PIOIF_UpdateTime)
			Select PIOIF_ParRef,PIOIF_AddOrdItem,PIOIF_FactAmount,PIOIF_PrivilegeMode,PIOIF_Privilege,:newauditid,PIOIF_UpdateUser_DR,PIOIF_UpdateDate,PIOIF_UpdateTime
				from DHC_PE_PreIOrdItemFee Where PIOIF_RowId=:itemfeeid
				)
		if SQLCODE q "重新生成费用明细失败!"
	}
	elseif feetype=2
	{
	}
	else
	{	q "项目费用类型不正确!" }
	*/
	q ""
}

/// format:返回格式
/// 	1: paymodedr1^paymode1^amount1^cardno1&paymodedr2^paymode2^amount2^cardno2..
/// 	2: paymode1 paymode2..
/// AllFlag:1 全部返回
/// 		0 过滤掉金额小于零的
/// w ##class(web.DHCPE.Cashier).GetPayModeInfo(15)
ClassMethod GetPayModeInfo(invprtid, format As %Library.String = "1", AllFlag As %Library.String = "1")
{
	new billId
	new receiptId,childsub
	new receiptdata,paymodeinfo,paymodeinfos
	new paymodedr,paymodedesc,payamount,payno,linkChr
	if invprtid="" q ""
	if format=1  d
	.s linkChr="&"
	e  i format=2  d
	.s linkChr=" "
	e  i format=3  d
	.s linkChr=" "
	s paymodeinfos=""
	s SYBXStr="",IPayStr=""
	s billId=$p($g(^DHCPEINVPRT(invprtid)),"^",3)
	s InvPrtAmount=$p($g(^DHCPEINVPRT(invprtid)),"^",7)
	i billId="" q ""
	s receiptId=$p($g(^DHCPEINVPRT(invprtid)),"^",4)
	i receiptId="" q ""
	s childsub=0
	f  s childsub=$o(^ARRCP(receiptId,"PAYM",childsub)) q:((childsub=""))  d
	.s receiptdata=$g(^ARRCP(receiptId,"PAYM",childsub))
	.s paymodedr=$p(receiptdata,"^",1)
	.s paymodedesc=""
	.i paymodedr'="" s paymodedesc=$p($g(^CT("CTPM",paymodedr)),"^",2)
	.i paymodedr'="" s paymodecode=$p($g(^CT("CTPM",paymodedr)),"^",1)
	.s payamount=$p(receiptdata,"^",3)
	.s payamount=$FN(payamount,"",2)
	.i paymodecode="SYBX"   d
	..S SYBXPayAmount=payamount
	..s SYBXStr="商业保险:"_SYBXPayAmount
	..S IPayAmount=InvPrtAmount-SYBXPayAmount
	..s IPayStr="自付:"_IPayAmount
	.q:((AllFlag="0")&(+payamount<0))
	.s payno=$p(receiptdata,"^",4)
	.i paymodedesc
	.i format=1  d
	..s paymodeinfo=paymodedr_"^"_paymodedesc_"^"_payamount_"^"_payno
	.e  i format=2  d
	..s paymodeinfo=paymodedesc
	.e  i format=3  d
	..;i payno'="" s payamount=payamount_"("_payno_")"
	..s paymodeinfo=paymodedesc_":"_payamount
	.i paymodeinfos'="" s paymodeinfos=paymodeinfos_linkChr
	.s paymodeinfos=paymodeinfos_paymodeinfo
	q paymodeinfos_"%%"_SYBXStr_"%%"_IPayStr
}

// ADMFeeType：医嘱套对用的体检费别

/// 根据套餐下的项目计算套餐价格
/// w ##class(web.DHCPE.Cashier).GetARCSetPrice(205)
ClassMethod GetARCSetPrice(arcsetid, AdmId, ADMFeeType = "")
{
   
	new arcsetdateid,arcsetdateitemid,arcdata
	new arcitemid,arcitemsub,arcitemver,subcatid
	new datefrom,dateto
	new amount,itmamount
	s OType=$p(arcsetid,"&",2)
	s arcsetid=$p(arcsetid,"&",1)
	s amount=0
	s arcitemid=""
	s arcdata=$g(^ARCOS(arcsetid))
	i arcdata="" q 0
	s datefrom=$p(arcdata,"^",15)
	if datefrom'=""
	{
		s datefrom=+datefrom
		if (+datefrom>+$h) q amount
	}
	s dateto=$p(arcdata,"^",16)
	i ((dateto'="")&&(dateto<+$h)) q 0
	s arcsetdateid=""
	f  s arcsetdateid=$o(^ARCOS(arcsetid,"DATE",arcsetdateid)) q:((arcsetdateid="")||(arcitemid'=""))  d
	.s arcdata=$g(^ARCOS(arcsetid,"DATE",arcsetdateid))
	.q:arcdata=""
	.s datefrom=$p(arcdata,"^",1)
	.q:datefrom>+$h
	.s dateto=$p(arcdata,"^",2)
	.q:((dateto'="")&&(dateto<+$h))
	.s arcsetdateitemid=0
	.///取项目
	.f  s arcsetdateitemid=$o(^ARCOS(arcsetid,"DATE",arcsetdateid,"ITM",arcsetdateitemid)) q:((arcsetdateitemid=""))  d
	..s arcdata=$g(^ARCOS(arcsetid,"DATE",arcsetdateid,"ITM",arcsetdateitemid))
	..s arcitemid=$p(arcdata,"^",1)
	..s arcitemqty=$p(arcdata,"^",2)
	..i arcitemqty="" s arcitemqty=1
	..s arcitemsub=$p(arcitemid,"||",1)
	..s arcitemver=$p(arcitemid,"||",2)
	..s itmamount=##class(web.DHCPE.PreItemList).GetOrderPrice(arcitemid_"&"_OType,AdmId,"",ADMFeeType)
	..s itmamount=itmamount*arcitemqty
	..//b
	..s amount=amount+itmamount
	.///取套餐
	.s arcsetdateitemid=0
	.f  s arcsetdateitemid=$o(^ARCOS(arcsetid,"DATE",arcsetdateid,"OS",arcsetdateitemid)) q:((arcsetdateitemid=""))  d
	..s arcdata=$g(^ARCOS(arcsetid,"DATE",arcsetdateid,"OS",arcsetdateitemid))
	..s arcitemid=$p(arcdata,"^",1)
	..//s itmamount=..GetARCSetPrice(arcitemid)
	..s itmamount=##class(web.DHCPE.Handle.ARCOrdSets).GetPrice(arcitemid_"&"_OType,AdmId,"",ADMFeeType)
	..//b
	..s amount=amount+itmamount
	q amount
}

/// w ##class(web.DHCPE.Cashier).TransItem2PrintInvItem("abc^23537||1");
ClassMethod TransItem2PrintInvItem(iteminfo)
{
	new newitemid,newitemname,itemid
	s itemid=$p(iteminfo,"^",2)
	i itemid="" q ""
	s newitemid=$g(^DHCPESetting("DHCPE","InvSpecialOrderMap",itemid))
	if newitemid'="" 
	{
		s newitemname=$p($g(^ARCIM($p(newitemid,"||",1),$p(newitemid,"||",2),1)),"^",2)
		q newitemname_"^"_newitemid
	}
	q iteminfo
}

/// w ##class(web.DHCPE.Cashier).GetPreIAdmID("I",1)
ClassMethod GetPreIAdmID(admtype, admid, PreAuditID As %String = "")
{
	new preadmid,teamid	,iadmid
	q:admid="" ""
	s preadmid=""
	i PreAuditID'=""
	{
		s preadmid=$O(^DHCPEPreIADM(0,"PAORDITEM",PreAuditID,0))
		i preadmid="" d
		.s preadmid=$O(^DHCPEPreIADM(0,"PAORDENT",PreAuditID,0))
	}
	else
	{
		if (admtype="I")  d
		.s preadmid=$p($g(^DHCPEIADM(admid)),"^",4)
		e  d
		.s teamid=0
		.f  s teamid=$o(^DHCPEGADM(admid,"Team",teamid)) q:((teamid="")||(preadmid'=""))  d
		..s iadmid=0
		..f  s iadmid=$o(^DHCPEIADM(0,"GADM",admid,admid_"||"_teamid,iadmid)) q:((iadmid="")||(preadmid'=""))  d
		...If $p($g(^DHCPEIADM(iadmid)),"^",8)'="CANCELPE" s preadmid=$p($g(^DHCPEIADM(iadmid)),"^",4)	
	}
	q preadmid
}

ClassMethod GetPreGIAdmID(admtype, admid)
{
	new preadmid	
	q:admid="" ""
	s preadmid=""
	if (admtype="I")  d
	.s preadmid=$p($g(^DHCPEIADM(admid)),"^",4)
	e  d
	.s preadmid=$p($g(^DHCPEGADM(admid)),"^",2)
	q preadmid
}

/// 返回iadmid^paadmid
ClassMethod GetIAdmId(preadmid)
{
	new admid,paadmid
	q:preadmid="" "^"
	s admid=$o(^DHCPEIADM(0,"CRMADM",preadmid,0))
	s paadmid=""
	if admid'="" s paadmid=$p($g(^DHCPEIADM(admid)),"^",1)
	q admid_"^"_paadmid
}

Query GetPayMode(vFlag As %Library.String = "") As %Query(ROWSPEC = "Description:%String,Hidden:%String,Code:%String")
{
}

ClassMethod GetPayModeExecute(ByRef qHandle As %Binary, vFlag As %Library.String = "") As %Status
{
	
	new id,desc,code,notuseflag
	new CanChangePayModes,tmpid,passflag
	
	Set repid=$I(^CacheTemp)
	Set qHandle=$lb(0,repid,0)
 	s ind=1
 
 	s id=0
 	s CanChangePayModes=$g(^DHCPESetting("DHCPE","CanChangePayModes"))
 	s CanChangePayModes=","_CanChangePayModes_","
 	f  s id=$o(^CT("CTPM",id)) q:((id=""))  d
 	.s notuseflag=$p($g(^CT("CTPM",id)),"^",3)
 	.d CheckPayMode
 	.q:passflag=0
 	.s code=$p($g(^CT("CTPM",id)),"^",1)
 	.s desc=$p($g(^CT("CTPM",id)),"^",2)
	.d OutPayMode
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
	
CheckPayMode
	s passflag=0
	i notuseflag="N" q
	if vFlag=1
	{
		s tmpid=","_id_","
		if CanChangePayModes[tmpid s passflag=1
	}
	else
	{	s passflag=1	}
	q
OutPayMode
	set Data=$lb(desc,id,code)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod GetPayModeFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = GetPayModeExecute ]
{

	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else      {
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind)
	Quit $$$OK
}

ClassMethod GetPayModeClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetPayModeExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// w ##class(web.DHCPE.Cashier).GetInvoiceInfoNew("1061",123456,1234,1)
ClassMethod GetInvoiceInfoNew(preAuditIds, curdatetime, job, listFlag)
{
	new preAuditId,FeeType,subroot,preAdmId,childsub,feesub,errs
	
	new j,k,sortno
	new itemtype,tarItems,tarItem,tarItemId,tarItemQty,tarItemPrice,tarItemAmount,feecat,feecatamount
	new FactAmount,tarlen,AddItemFlag,tmpPrice
	new auditAmount
	new defaultfeeid,defaultfeename
	new listflagsub
	s (defaultfeeid,defaultfeename)=""
	d ..GetDefaultFee(.defaultfeeid,.defaultfeename)
	
	s j=1
	s sortno=0
	s auditAmount=0
	s listflagsub=1	
	k ^DHCPECashierTemp("InvListInfo",curdatetime,job)
	s ^DHCPECashierTemp("InvListInfo",curdatetime,job,"Para")="preAuditIds:"_preAuditIds_"^"_"listFlag:"_listFlag
	
	while(j<=$l(preAuditIds,",")){
			s preAuditId=$p(preAuditIds,",",j)
			s j=j+1
			q:preAuditId=""
			s auditAmount=auditAmount+$p($g(^DHCPEPreA(preAuditId)),"^",9)
			//q:listFlag=0
			///取项目
			s FeeType=1
			s subroot="ORDITEM"
			s preAdmId=0
			f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId=""))  d
			.s childsub=0
			.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub=""))  d
			..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",16)'=1	//判断是否有效
			..s arcitmid=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",1)
			..s FactAmount=..GetFactAmount(FeeType,preAdmId_"||"_childsub,preAuditId)
			..s ^DHCPECashierTemp("InvListInfo",curdatetime,job,"NoEq_Ord",arcitmid,"Info")="FeeType:"_FeeType_" preAdmId:"_preAdmId_" childsub:"_childsub_" FactAmount:"_FactAmount
			..s tmpPrice=..GetArcFactAmount(arcitmid,FactAmount)
			..s ADMFeeType=$G(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_childsub)) 
			..s arcitmPrice=##class(web.DHCPE.Handle.ARCItmMast).GetItmPrice(arcitmid,+$h, "", "", "", "", "",tmpPrice,preAdmId,ADMFeeType)
			..//w arcitmid_" "_arcitmPrice,!
			..s arcitmPrice=$j(arcitmPrice,3,2)
			..s FactAmount=$j(FactAmount,3,2)
			..i FactAmount'=arcitmPrice  d
			...s listFlag=0
			...s ^DHCPECashierTemp("InvListInfo",curdatetime,job,"NoEq_Ord",arcitmid)=FactAmount_"^"_arcitmPrice
			...s arcitmid=defaultfeeid
			...s arcitmPrice=FactAmount
			...d GetOrderInfo	
			..e  d
			...d GetOrderInfo
			
			///取套餐
			s FeeType=2
			s subroot="ORDENT"
			s preAdmId=""
			f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId=""))  d
			.s childsub=""
			.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub=""))  d
			..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
			..s FactAmount=..GetFactAmount(FeeType,preAdmId_"||"_childsub,preAuditId)
			..s FactAmount=$j(FactAmount,3,2)
			..s arcitmPrice=##class(web.DHCPE.Cashier).GetEntSumAmount(preAdmId_"||"_childsub)
			..s arcitmPrice=$j(arcitmPrice,3,2)
			..//w "FactAmount:"_FactAmount_"  arcitmPrice:"_arcitmPrice,!
			..i FactAmount'=arcitmPrice  d
			...s listFlag=0
			...s ^DHCPECashierTemp("InvListInfo",curdatetime,job,"NoEq_Ent",preAdmId_"||"_childsub)=FactAmount_"^"_arcitmPrice
			...s arcitmid=defaultfeeid
			...s arcitmPrice=FactAmount
			...d GetOrderInfo
			..e  d
			...s ordEnt=preAdmId_"||"_childsub
			...s childsub1=""
			...//w "ent:"_ordEnt,!
			...f  s childsub1=$o(^DHCPEPreIADM(0,"OrdEnt",ordEnt,preAdmId,childsub1)) q:((childsub1=""))  d
			....q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub1)),"^",16)'=1	//判断是否有效
			....s arcitmid=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub1)),"^",1)
			....s ADMFeeType=$G(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_childsub1)) 
			....s arcitmPrice=##class(web.DHCPE.Handle.ARCItmMast).GetItmPrice(arcitmid,+$h, "", "", "", "", "","",preAdmId,ADMFeeType)
			....s arcitmPrice=$j(arcitmPrice,3,2)
			....s FactAmount=arcitmPrice
			....d GetOrderInfo			
	}
	s ^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"ItemCount")=sortno
	s ^DHCPECashierTemp("InvListInfo",curdatetime,job,"ListFlag")=listFlag
	i (listFlag=0)  d
	.s sortno=0
	
	s listflagsub=0
	s arcitmid=defaultfeeid
	s arcitmPrice=$j(auditAmount,3,2)
	s FactAmount=arcitmPrice
	d GetOrderInfo	
	s ^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"ItemCount")=1
	q sortno
GetOrderInfo
	s orditmType=..GetArcItemType(arcitmid)
	i orditmType="L"  d
	.s AddItemFlag=1
	.d GetArcItemInfo
	e  d
	.s AddItemFlag=1
	.b //bbb
	.d GetTarItemInfo
	quit
GetArcItemInfo
	//获取医嘱项信息	
	s itemtype=1
	s tarItemId=arcitmid
	s tarItemQty=1
	s tarItemPrice=FactAmount
	s tarItemAmount=FactAmount
	//s ^lisatest("20080709","GetArcItemInfo",preAdmId_"||"_childsub)=tarItemAmount
	//b ///tarItemId
	i AddItemFlag=1 d AddItemInfo
	s AddItemFlag=0
	b //aaa
	d GetTarItemInfo
	quit
GetTarItemInfo
	//获取费用项信息
	//b //222
	s itemtype=2
	s tarItems=..ArcItem2TarItem("","",arcitmid,+$h,"","","",arcitmPrice)
	//w "tarItems:"_tarItems,!
	//b //333
	s tarlen=$l(tarItems,"&")
	for k=1:1:tarlen  d
	.s tarItem=$p(tarItems,"&",k)
	.s tarItemId=$p(tarItem,"^",1)
	.q:tarItemId=""
	.s tarItemQty=$p(tarItem,"^",2)
	.s tarItemPrice=$p(tarItem,"^",3)
	.s tarItemAmount=tarItemPrice*tarItemQty
	.//s ^lisatest("20080709","GetTarItemInfo",preAdmId_"||"_childsub)=tarItemAmount
	.d AddFeeCatInfo
	.i AddItemFlag=1 d AddItemInfo
	quit
AddItemInfo
	i '$d(^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"ItemData",tarItemId)) d
	.s sortno=1+sortno
	.s ^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"Index",sortno)=tarItemId
	e  d
	.s tarItemAmount=+tarItemAmount+$p(^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"ItemData",tarItemId),"^",5)
	.s tarItemQty=+tarItemQty+$p(^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"ItemData",tarItemId),"^",3)
	s ^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"ItemData",tarItemId)=itemtype_"^"_tarItemId_"^"_tarItemQty_"^"_tarItemPrice_"^"_tarItemAmount
	s ^lisatest("20080709","DHCPECashierTemp",$h)=itemtype_"^"_tarItemId_"^"_tarItemQty_"^"_tarItemPrice_"^"_tarItemAmount
	//s ^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"ItemData",tarItemId)=itemtype_"^"_tarItemId_"^"_tarItemQty_"^"_"32"_"^"_"66"
	quit
AddFeeCatInfo
	s feecat=$p($g(^DHCTARI(tarItemId)),"^",15)
	i feecat="" s ^DHCCashierTemp("InvListInfo","NoCatTarItem",job,tarItemId)=$g(^DHCCashierTemp("InvListInfo","NoCatTarItem",job,tarItemId))_"^"_tarItemId
	q:feecat=""
	//s feecat=$g(^DHCPESetting("DHCPE","InvFeeCat",feecat))
	//i feecat="" s feecat="Other"
	//i feecat="" s feecat="Other"
	//s ^DHCPECashierTemp("InvListInfo","tarItemId",tarItemId)=tarItemId_"^"_tarItemAmount
	
	s feecat=$p($g(^DHCTarC("OC",feecat)),"^",3)
	s feecatamount=$g(^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"FeeCatData",feecat))
	s feecatamount=+feecatamount+tarItemAmount
	//S feecatamount="98"  //??
	s ^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"FeeCatData",feecat)=feecatamount
	quit
}

ClassMethod GetArcFactAmount(arcitmid, oeprice)
{
	new itmsubCat,factamount
	s factamount=oeprice
	s itmsubCat=$p($g(^ARCIM(+arcitmid,$p(arcitmid,"||",2),1)),"^",10)
	if itmsubCat'=""  d
	.s itmsubCat=$p($g(^ARC("IC",itmsubCat)),"^",7)
	.i itmsubCat'="P" s factamount=""
	q factamount
}

/// 获取发票费别分类信息
/// w ##class(web.DHCPE.Cashier).GetInvFeeCatInfo()
ClassMethod GetInvFeeCatInfo(invid)
{
	
	new curdatetime,job
	new feecat,feeCatInfos,c,feeamount
	new freeNum
	new listflagsub
	if invid="" q ""
	s feeCatInfos=""
	s c=$c(2)
	s curdatetime=$p($g(^DHCPECashierTemp("InvListInfo",invid)),"^",1)
	s job=$p($g(^DHCPECashierTemp("InvListInfo",invid)),"^",2)
	if ((curdatetime="")||(job="")) q ""
	s freeNum=0
	s feecat=""
	s listflagsub=^DHCPECashierTemp("InvListInfo",curdatetime,job,"ListFlag")
	f  s feecat=$o(^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"FeeCatData",feecat)) q:((feecat=""))  d
	.//s feeCatInfos=feeCatInfos_"^"_"FB1"_c_defaultfeename
	.s feeamount=$g(^DHCPECashierTemp("InvListInfo",curdatetime,job,listflagsub,"FeeCatData",feecat))
	.s feeamount=$j(feeamount,3,2)
	.s feecatcode=$g(^DHCPESetting("DHCPE","InvFeeCat",feecat))
	.i feecatcode=""  d
	..s freeNum=1+freeNum
	..s feecatdesc=$p($g(^DHCTarC("TOC",feecat)),"^",2)
	..s feeCatInfos=feeCatInfos_"^"_"FreeFeeDesc"_freeNum_c_feecatdesc
	..s feeCatInfos=feeCatInfos_"^"_"FreeFee"_freeNum_c_feeamount
	.e  d
	..s feeCatInfos=feeCatInfos_"^"_feecatcode_c_feeamount
	q feeCatInfos
}

/// 获取发票明细信息
/// w ##class(web.DHCPE.Cashier).GetInvFeeListInfo(112,1,0)
ClassMethod GetInvFeeListInfo(invid, listflag, PrintDetail As %String = "0", listcount As %String = "0")
{
	
	n (invid, listflag,PrintDetail,listcount)
	
	if invid="" q ""
	
	s Job=$J
	s c=$C(2)
  	s col=$g(^DHCPESetting("DHCPE","InvCol")) ;发票明细打印列数
	if col="" s col=1
	
	s invcolSet=^DHCPESetting("DHCPE","InvColSortType") ;发票明细显示顺序
	if invcolSet="" s invcolSet=1
  	if listflag=0
  	{
	  	s (defaultfeeid,defaultfeename)=""
  		d ..GetDefaultFee(.defaultfeeid,.defaultfeename)
		s invData=$g(^DHCPEINVPRT(invid))
		if invData="" q ""
		/*
		i PrintDetail="0"
		{
			s invData=##class(web.DHCPE.CashierEx).GetInvAmountInfo(invid)
			s amount=$p(invData,"^",1)
		}else{
			s amount=$p(invData,"^",7)
		}
		*/
		s amount=$p(invData,"^",7)
		s amount=$j(amount,3,2)
		s Uom="次"
		s j=col-1
		if invcolSet=1 s rtn=defaultfeename_"^"_amount_"^1^"_amount
		if invcolSet=2 s rtn=defaultfeename_"^"_Uom_"^1^"_amount
		if invcolSet=3 s rtn=defaultfeename_"^"_Uom_"^"_1_"^"_amount_"^"_amount
		q rtn
  	}
  	B ;006
	s PreItemID=""
  	f  s PreItemID=$O(^DHCPEOEITEM(invid,"OEITEM",PreItemID)) q:PreItemID=""  d //,"TARITEM",itmsub)
	.s TARITEMSub=""
	.f  s TARITEMSub=$O(^DHCPEOEITEM(invid,"OEITEM",PreItemID,"TARITEM",TARITEMSub)) q:TARITEMSub=""  d
	..s Info=$G(^DHCPEOEITEM(invid,"OEITEM",PreItemID,"TARITEM",TARITEMSub))
	..s TARITEMID=$P(Info,"^",1)
	..s OneAmount=+$P(Info,"^",4)
	..i $D(^DHCPEOEITEM(invid,"OEITEM",PreItemID,"SetsName")) d
	...s Desc="丙 "_$G(^DHCPEOEITEM(invid,"OEITEM",PreItemID,"SetsName"))
	...s Uom=""
	...s Qty=1
	..e  d
	...s YBCode=..GetYBCode(TARITEMID)
	...s Desc=YBCode_" "_$p($g(^DHCTARI(TARITEMID)),"^",2)
	...s Uom=..GetUomByTarItem(TARITEMID)
	...s Qty=$g(^DHCPEDataEx("DHCPEPreIOrdItem","Qty",PreItemID))
	..//s Sort=$I(^TempDHCPEListInfo(Job))
	..s Sort=Desc
	..s ^TempDHCPEListInfo(Job,Sort,OneAmount,"OneAmount")=$g(^TempDHCPEListInfo(Job,Sort,OneAmount,"OneAmount"))+OneAmount
	..s ^TempDHCPEListInfo(Job,Sort,OneAmount,"Qty")=$g(^TempDHCPEListInfo(Job,Sort,OneAmount,"Qty"))+Qty
	..s TotalAmount=$g(^TempDHCPEListInfo(Job,Sort,OneAmount,"OneAmount"))
	..s TotalQty=$g(^TempDHCPEListInfo(Job,Sort,OneAmount,"Qty"))
	..s ^TempDHCPEListInfo(Job,Sort,OneAmount)=Desc_"^"_OneAmount_"^"_TotalQty_"^"_TotalAmount_"^"_Uom
	b ;001
	s ItemInfos=""
	s listcount=0
	s Sort=""
	f  s Sort=$O(^TempDHCPEListInfo(Job,Sort)) q:Sort=""  d
	.s OneAmount=""
	.f  s OneAmount=$O(^TempDHCPEListInfo(Job,Sort,OneAmount)) q:OneAmount=""  d
	..s Info=$G(^TempDHCPEListInfo(Job,Sort,OneAmount))
	..s ItemName=$P(Info,"^",1)
	..s YBCode=""
	..i PrintDetail'=1 d
	...s YBCode=$P(ItemName," ",1)
	...s ItemName=$P(ItemName," ",2,$L(ItemName," "))
	..s ItemQty=$P(Info,"^",3)
	..s ItemPrice=$P(Info,"^",2)
	..s ItemAmount=$P(Info,"^",4)
	..s UOM=$P(Info,"^",5)
	..s InvNameMaxLen=+$g(^DHCPESetting("DHCPE","InvNameMaxLen"))
	..i InvNameMaxLen>0 s ItemName=$e(ItemName,1,InvNameMaxLen)
	..i (listcount#col)=0  d
	...i ItemInfos'="" s ItemInfos=ItemInfos_$c(2)
	..e  d
	...i ItemInfos'="" s ItemInfos=ItemInfos_"^"
	..s ItemPrice=$FN(ItemPrice,"",2)
	..s ItemAmount=$FN(ItemAmount,"",2)
	
	..i PrintDetail'=1 d
	...s ItemAmount=ItemAmount_$E("          ",1,12-$L(ItemAmount))
	...s ItemAmount=ItemAmount_"  "_YBCode
	..//明细上金额右对齐 start
	..i $L(ItemPrice)<9 d
	...s ItemPrice=$E("         "," ",8-$L(ItemPrice))_ItemPrice
	..i $L(ItemAmount)<9 d
	...s ItemAmount=$E("        "," ",8-$L(ItemAmount))_ItemAmount
	..//明细上金额右对齐 end
	..i invcolSet=1 s ItemInfos=ItemInfos_ItemName_"^"_ItemPrice_"^"_ItemQty_"^"_ItemAmount
	..i invcolSet=2 s ItemInfos=ItemInfos_ItemName_"^"_UOM_"^"_ItemQty_"^"_ItemAmount
	..i invcolSet=3 s ItemInfos=ItemInfos_ItemName_"^"_UOM_"^"_ItemQty_"^"_ItemPrice_"^"_ItemAmount
	..s listcount=listcount+1
	s invData=$g(^DHCPEINVPRT(invid))
	s invNo=$P(invData,"^",1)
	s PBDR=$P(invData,"^",3)
	;明细数量大于最大值或者体检卡结算
	i (listcount>$G(^DHCPESetting("DHCPE","InvMaxListCount")))||(invNo[("DHC"))||(PrintDetail=1)
	{
		s TotalAmt=$p(invData,"^",7)
		s TotalAmt=$FN(TotalAmt,"",2)
		s TotalAmt="合计:"_TotalAmt
		s APAmount=""
		i invNo[("DHC") d
		.s APID=$O(^DHCPEAP(0,"SourceNo","C",PBDR,0))
		.i APID'="" d
		..;s APAmount=$P(^DHCPEAP(APID),"^",4)
		..;s APAmount="卡余额:"_$FN(APAmount,"",2)
		s ItemInfos=ItemInfos_$c(2)_"___________________________________________^"_APAmount_"^"_TotalAmt_"^^"
		s ItemInfos=ItemInfos_$c(2)_"^"_"[甲:无自付,已:有自付,丙:全自付]"_"^^^"
		s ItemInfos=ItemInfos_$c(2)_"[限北京医保标示]^^^^"
	}
	
	
	i ItemInfos'=""
	{
		new k,j
		s j=(listcount#col)
		for k=1:1:j s ItemInfos=ItemInfos_"^^^^^^"
	}
	
	k ^TempDHCPEListInfo(Job)
	//s ^wrz=ItemInfos
	q ItemInfos
}

ClassMethod GetFactAmount(ordtype, preOrdId, AuditID As %String = "")
{
	new preAdmId1,childsub1,feesub1,subroot1
	
	s subroot1="ORDITEM"
	if ordtype=2  d
	.s subroot1="ORDENT"
	
	s preAdmId1=$p(preOrdId,"||",1)
	s childsub1=$p(preOrdId,"||",2)
	 
	s factAmount=0
	s feesub1=0
	f  s feesub1=$o(^DHCPEPreIADM(preAdmId1,subroot1,childsub1,"FEE",feesub1)) q:((feesub1=""))  d
	.s feeData=$g(^DHCPEPreIADM(preAdmId1,subroot1,childsub1,"FEE",feesub1))
	.//b //feeData
	.q:$p(feeData,"^",5)=""
	.q:(AuditID="")&&($p(^DHCPEPreA($p(feeData,"^",5)),"^",21)="NU")
	.q:(AuditID'="")&&($p(feeData,"^",5)'=AuditID)
	.s factAmount=+$p(feeData,"^",2)+factAmount
	s factAmount=+factAmount
	s factAmount=$j(factAmount,3,2)
	q factAmount
}

ClassMethod GetArcItemType(arcitmid)
{
	new arcCatId,orditmType
	if arcitmid="" q ""
	s arcCatId=$p(^ARCIM(+arcitmid,$p(arcitmid,"||",2),1),"^",10)
	s orditmType=$p(^ARC("IC",arcCatId),"^",7)
	q orditmType
}

/// 将医嘱项转换为收费项信息 taritemid1^qty1^price1&taritemid2^qty2^price2....
/// w ##class(web.DHCPE.Cashier).ArcItem2TarItem("","",arcim,+$H,"","","",itemPrice)
ClassMethod ArcItem2TarItem(pattype, instype, arcim, sttdate, prior, instr, linkto, oeprice)
{
	
	n (pattype,instype,arcim,sttdate,prior,instr,linkto,oeprice)
	
	s tarItemInfos=""
	;
	s pattype=$g(pattype),instype=$g(instype),arcim=$g(arcim),sttdate=$g(sttdate)
	s prior=$g(prior),instr=$g(instr),linkto=$g(linkto),oeprice=$g(oeprice)
	;
	s Price=0,DiscPrice=0,InsPrice=0,PatPrice=0
	s Conf=$o(^DHCTarC("CF","")) q:Conf="" Price_"^"_DiscPrice_"^"_InsPrice_"^"_PatPrice
	;
	s ExecuDate=""
	q:$g(arcim)="" ""_"^"_""_"^"_""_"^"_""
	q:'$d(^DHCOLT(0,"ARCIM",arcim)) ""_"^"_""_"^"_""_"^"_""
	//b //?-0
	if oeprice="" s oeprice=..GetArcFactAmount(arcim,oeprice)	
	//b //?-1
	f  s ExecuDate=$o(^DHCOLT(0,"ARCIM",arcim,"Z",ExecuDate)) q:ExecuDate=""  d
	.q:ExecuDate>sttdate
	.s OLT=""
	.f  s OLT=$o(^DHCOLT(0,"ARCIM",arcim,"Z",ExecuDate,OLT)) q:OLT=""  d
	..d AddTarItem
	;
	i ($p($g(^DHCTarC("CF",Conf)),"^",6)="Y")&(linkto="")&(instr'="") d
	.s ExecuDate=""
	.f  s ExecuDate=$o(^DHCOLT(0,"ARCIM",arcim,instr_"Z",ExecuDate)) q:ExecuDate=""  d
	..q:ExecuDate>sttdate
	..s OLT=""
	..f  s OLT=$o(^DHCOLT(0,"ARCIM",arcim,instr_"Z",ExecuDate,OLT)) q:OLT=""  d
	...d AddTarItem
	q tarItemInfos
	
AddTarItem
	s EndDate=$p(^DHCOLT(OLT),"^",5)
	i EndDate="" s EndDate=+$H+1
	q:EndDate<sttdate
	s qty0=$p(^DHCOLT(OLT),"^",3)
	s Itm=$p(^DHCOLT(OLT),"^",2)
	s err=##class(web.UDHCJFPRICE).GetItmPrice(Itm,sttdate,instype,pattype,oeprice)
	s Price=oeprice
	if Price="" s Price=$p(err,"^",1)
	s Price=+Price
	i tarItemInfos'=""  d
	.s tarItemInfos=tarItemInfos_"&"
	s tarItemInfos=tarItemInfos_Itm_"^"_qty0_"^"_Price
	//b //?-2
	quit
}

/// w ##class(web.DHCPE.Cashier).UpdateInvalidOrder(60960)
ClassMethod UpdateInvalidOrder(begindate)
{
	new gAdmId,gTeamId,gChildSub
	new arcSetid,enddate,a,count,falseflag
	s count=0
	s gAdmId=0
	TStart
	s falseflag=0
	f  s gAdmId=$o(^DHCPEPreGADM(gAdmId)) q:((gAdmId="")||(falseflag=1))  d
 	.s gTeamId=0
 	.f  s gTeamId=$o(^DHCPEPreGADM(gAdmId,"Team",gTeamId)) q:((gTeamId="")||(falseflag=1))  d
 	..s gChildSub=0
 	..f  s gChildSub=$o(^DHCPEPreGADM(gAdmId,"Team",gTeamId,"ORDENT",gChildSub)) q:((gChildSub="")||(falseflag=1))  d
 	...s arcSetid=$p($g(^DHCPEPreGADM(gAdmId,"Team",gTeamId,"ORDENT",gChildSub)),"^",1)
 	...s enddate=$p(^ARCOS(arcSetid),"^",16)
 	...i ((+enddate>+begindate)&&(+$h>+enddate))  d
 	....w arcSetid_$p(^ARCOS(arcSetid),"^",2),!
 	....s PGTOERowId=gAdmId_"||"_gTeamId_"||"_gChildSub
 	....//&SQL(Update DHC_PE_PreGTOrdEnt set pgtoe_ordersets_dr=2865 where PGTOE_RowId=:PGTOERowId)
 	....//i SQLCODE s falseflag=1
 	....s count=count+1
 	w count
 	i falseflag=1
 	{
	 	TRollBack
	 	w "failed"
	}
	else
	{
		TCommit
		w "success"
	}
}

ClassMethod InitSetting()
{
	s ^DHCPESetting("DHCPE","InvListFlag")=1	//打印发票时是否打印明细
	s ^DHCPESetting("DHCPE", "InvMaxListCount")=24		//单张发票打印明细的最大数量
	s ^DHCPESetting("DHCPE","CashierMin")=100		///收费时其他支付方式现金找零最大的金额
	s ^DHCPESetting("DHCPE","SpecialPayModes")="3,4"	//收费时，可以找零的特殊支付方式
	s ^DHCPESetting("DHCPE","CanChangePayModes")="2,14"  //收费找零时，可以用那种方式找零
	s ^DHCPESetting("DHCPE","InvNameMaxLen")=16
	s ^DHCPESetting("DHCPE","InvDefaulltFee")="7082||1"

	s ^DHCPESetting("DHCPE","InvFeeCat",64)="FEE1A"		///打印发票分类位置对照
	s ^DHCPESetting("DHCPE","InvFeeCat",65)="FEE1B"
	s ^DHCPESetting("DHCPE","InvFeeCat",66)="FEE1C"
	s ^DHCPESetting("DHCPE","InvFeeCat",67)="FEE1D"
	
	s ^DHCPESetting("DHCPE","InvFeeCat",56)="FEE2A"
	s ^DHCPESetting("DHCPE","InvFeeCat",52)="FEE2B"
	s ^DHCPESetting("DHCPE","InvFeeCat",53)="FEE2C"
	s ^DHCPESetting("DHCPE","InvFeeCat",68)="FEE2D"
	
	s ^DHCPESetting("DHCPE","InvFeeCat",55)="FEE3A"
	s ^DHCPESetting("DHCPE","InvFeeCat",51)="FEE3B"
	s ^DHCPESetting("DHCPE","InvFeeCat",1) ="FEE3C"
	s ^DHCPESetting("DHCPE","InvFeeCat",60)="FEE3D"
	
	s ^DHCPESetting("DHCPE","InvFeeCat",61)="FEE4A"
	s ^DHCPESetting("DHCPE","InvFeeCat",5) ="FEE4B"
	s ^DHCPESetting("DHCPE","InvFeeCat",2) ="FEE4C"
	s ^DHCPESetting("DHCPE","InvFeeCat",3) ="FEE4D"
	
	s ^DHCPESetting("DHCPE","InvFeeCat",4) ="FEE5A"
	s ^DHCPESetting("DHCPE","InvFeeCat",59)="FEE5B"
}

/// 判断该审核是否有有效项目
ClassMethod CheckAuditHasList(preauditid)
{
	new checkadmid,checkchild,haslist
	s checkadmid=0
	s haslist=0
	f  s checkadmid=$o(^DHCPEPreIADM(0,"PAORDITEM",preauditid,checkadmid)) q:((checkadmid="")||(haslist=1))  d
	.s checkchild=0
	.f  s checkchild=$o(^DHCPEPreIADM(0,"PAORDITEM",preauditid,checkadmid,checkchild)) q:((checkchild="")||(haslist=1))  d
	..q:$p($g(^DHCPEPreIADM(checkadmid,"ORDITEM",checkchild)),"^",16)'=1	//判断是否有效
	..s haslist=1
	i haslist=1 q haslist
	
	s checkadmid=0
	f  s checkadmid=$o(^DHCPEPreIADM(0,"PAORDENT",preauditid,checkadmid)) q:((checkadmid="")||(haslist=1))  d
	.s checkchild=0
	.f  s checkchild=$o(^DHCPEPreIADM(0,"PAORDENT",preauditid,checkadmid,checkchild)) q:((checkchild="")||(haslist=1))  d
	..q:$p($g(^DHCPEPreIADM(checkadmid,"ORDENT",checkchild)),"^",9)'=1	//判断是否有效
	..s haslist=1
	q haslist
}

// d ##class(web.DHCPE.Cashier).Test(64)

ClassMethod Test(invid)
{
	 s InvAmount= $p($g(^DHCPEINVPRT(invid)),"^",7)
	 s CatAmount=0
	 s TarOCID=""
	 f  s TarOCID=$O(^DHCPEDataEX("DHCPEInvice",invid,TarOCID)) q:TarOCID=""  d //=TarOCFee
	 .s OneAmount= $G(^DHCPEDataEX("DHCPEInvice",invid,TarOCID))
	 .s CatAmount=CatAmount+OneAmount
	 i (+CatAmount)'=(+InvAmount) w invid,!
}

/// w ##class(web.DHCPE.Cashier).GetFeeCatInfo("243")
ClassMethod GetFeeCatInfo(invid)
{
	
	s Job=$J
	s c=$C(2)
  	s PreItemID=""
  	f  s PreItemID=$O(^DHCPEOEITEM(invid,"OEITEM",PreItemID)) q:PreItemID=""  d //,"TARITEM",itmsub)
	.s TARITEMSub=""
	.f  s TARITEMSub=$O(^DHCPEOEITEM(invid,"OEITEM",PreItemID,"TARITEM",TARITEMSub)) q:TARITEMSub=""  d
	..;TarItem_"^"_$j((CurCatFee/(qty*orderQty)),3,2)_"^"_(qty*orderQty)_"^"_$j(CurCatFee,3,2)
	..s Info=$G(^DHCPEOEITEM(invid,"OEITEM",PreItemID,"TARITEM",TARITEMSub))
	..s TARITEMID=$P(Info,"^",1)
	..s Amount=$P(Info,"^",4)
	..s OneInfo=..GetTarOC(TARITEMID,"N")
	..s TarOCID=$P(OneInfo,"^",1)
	..s ^TempDHCPECatInfo(Job,TarOCID)=+($G(^TempDHCPECatInfo(Job,TarOCID)))+Amount
	..s ^TempDHCPECatInfo(Job,TarOCID,"Desc")=$P(OneInfo,"^",2)
	s CatRtn=""
	s i=0
	s TarOCID=""
	f  s TarOCID=$O(^TempDHCPECatInfo(Job,TarOCID)) q:TarOCID=""  d
	.s Desc=$G(^TempDHCPECatInfo(Job,TarOCID,"Desc"))
	.s i=i+1
	.s Fee=$G(^TempDHCPECatInfo(Job,TarOCID))
	.s Fee=$FN(Fee,"",2)
	.s LabelName=$G(^DHCPESetting("DHCPE","InvFeeCat",TarOCID))
	.;发票xml中没写明分类标签名称，只是写了标签
	.s CatRtn=CatRtn_"^"_"Fee"_i_c_Fee_"^"_"FeeLab"_i_c_Desc
	.;发票xml中写明分类标签名称，Setting里面设置了数据对应的标签名称
	.;s CatRtn=CatRtn_"^"_LabelName_c_Fee
	k ^TempDHCPECatInfo(Job)
	
	q CatRtn
}

ClassMethod GetTarOC(TarItem, OldType As %String = "Y")
{
	;d ##class(web.DHCPE.Cashier).GetTarOC("20965","N")
	;DHC_TarOutpatCate
	s (TarOCID,TarOCDesc)=""
	s OldType=$G(^DHCPESetting("DHCPE","TarOCIsNew"))
	i OldType'="Y" d
	.s OutPatCate=$p($G(^DHCTARI(TarItem)),"^",15)
	.s TAROCDesc=$p($G(^DHCTarC("OC",OutPatCate)),"^",1)
	.;DHC_TarOC
	.s TarOCID=$p($G(^DHCTarC("OC",OutPatCate)),"^",3)
	.s TarOCDesc=$p($G(^DHCTarC("TOC",TarOCID)),"^",2)
	e  d
	.s OutPatCate=$p(^DHCTARI(TarItem),"^",30)
	.q:$g(OutPatCate)=""
	.s TarOCID=$p(^DHCTarC("MCNew",OutPatCate),"^",4)
	.q:$g(TarOCID)=""
	.if TarOCID'="" s TarOCDesc=$p($g(^DHCTarC("TOCNEW",TarOCID)),"^",2)
	q TarOCID_"^"_TarOCDesc
	;q OutPatCate_"^"_TAROCDesc
}

ClassMethod GetTarEC(TarItem)
{
   //^DHCTarC("EC",{TAREC_RowId})  
	s TarECID=$p($G(^DHCTARI(TarItem)),"^",16)
	Q:TarECID=""
	s TarECDesc=$p($G(^DHCTarC("EC",TarECID)),"^",2)
	q TarECID_"^"_TarECDesc
}

ClassMethod GetTarSub(TarItem)
{
   //^DHCTarC("EC",{TAREC_RowId})  
	s TarSCID=$p($G(^DHCTARI(TarItem)),"^",4)
	Q:TarSCID=""
	s TarSCDesc=$p($G(^DHCTarC("SC",TarSCID)),"^",2)
	q TarSCID_"^"_TarSCDesc
}

/// creator:wangfujian
/// createDate:2009-06-12
/// itemfeeids:需要退费的项目或套餐:,1^1||6||1,1^1||5||1,1^1||8||1,
/// return:0:可以退费，1：有项目被执行过来，不能退费
ClassMethod judgeItmesCanRefund(itemfeeids)
{
	q:itemfeeids="" 0
	s result=0
	s itemNums=$L(itemfeeids,",")
	f i=1:1:itemNums  {
		continue:$p(itemfeeids,",",i)=""
		s itemOrEntFlag=$P($p(itemfeeids,",",i),"^",1)
		s feeRowId=$P($p(itemfeeids,",",i),"^",2)
		s itemOrEntRowid=$p(feeRowId,"||",1)_"||"_$p(feeRowId,"||",2)
		i itemOrEntFlag=1 d
		.//按项目循环
		.s itemRowid=itemOrEntRowid
		.d itemCanRufund
		e  d
		.//按套餐循环
		.s childSub=""
		.f  s childSub=$o(^DHCPEPreIADM(0,"OrdEnt",itemOrEntRowid,+itemOrEntRowid,childSub)) q:childSub=""||result=1  d
		..s itemRowid=+itemOrEntRowid_"||"_childSub
		..d itemCanRufund
		q:result=1

	}
	q result
itemCanRufund
	s CRMRowId=""
	s CRMRowId=$o(^DHCPECRMO(0,"CRMORI",itemRowid,CRMRowId))
	q:CRMRowId=""
	s OEOrdItemRowid=$p($g(^DHCPECRMO(CRMRowId)),"^",1)
	q:OEOrdItemRowid=""
	s OEORDRowid=$p(OEOrdItemRowid,"||",1)
	s OEchildSub=$p(OEOrdItemRowid,"||",2)
	s itemStatus=$p(^OEORD(OEORDRowid,"I",OEchildSub,1),"^",13)
	s:itemStatus=6 result=1
	
	q
}

/// w ##class(web.DHCPE.Cashier).GetAdmType("357")
ClassMethod GetAdmType(PEinvID As %Library.String = "")
{
	s AdmType=""
	s PBDR=$p(^DHCPEINVPRT(PEinvID),"^",3)
	s PAPBRowId="" f  s PAPBRowId=$o(^DHCPEPAPBR(0,"PBDR",PBDR,PAPBRowId)) q:PAPBRowId=""  d
	.s PADR=$p(^DHCPEPAPBR(PAPBRowId),"^",1)
	.s AdmType=$p(^DHCPEPreA(PADR),"^",1)
	q AdmType
}

// w ##class(web.DHCPE)

ClassMethod JudgePayMode(PayModeInfos, Amount, AdmID)
{
	;n (PayModeInfos,Amount,AdmID)
	s i=$L(PayModeInfos,"^")
	s ErrInfo=""
	s Flag=0
	f j=1:1:i d
	.s PayInfos=$P(PayModeInfos,"^",j)
	.s PayModeID=$P(PayInfos,",",1)
	.s PayCode=$P($G(^CT("CTPM",PayModeID)),"^",1)
	.s OneAmt=$P(PayInfos,",",2)
	.i PayCode="ZP" d
	..s CardNo=$P(PayInfos,",",3)
	..s:CardNo="" ErrInfo="支票号不能为空"
	..q:ErrInfo'=""
	.i PayCode="TJYJJ" d
	..s ret=##class(web.DHCPE.AdvancePayment).JudgeUse(AdmID,OneAmt,PayCode)
	..s:ret'=0 ErrInfo=ret
	.i PayCode="TJDJK" d
	..s CardNo=$P(PayInfos,",",3)
	..s:CardNo="" ErrInfo="代金卡号不能为空"
	..q:ErrInfo'=""
	..s ret=##class(web.DHCPE.AdvancePayment).JudgeUse(CardNo,OneAmt,PayCode)
	..s:ret'=0 ErrInfo=ret
	.break:ErrInfo'=""
	q:ErrInfo'="" ErrInfo
	q 0
	q ##class(web.DHCPE.AdvancePayment).JudgeUse(AdmID,Amount,PayCode)
}

// ##class(web.DHCPE.Cashier).GetInsurance(Type,ADM)

ClassMethod GetInsurance(Type, ADM)
{
	q:Type'="I" ""
	s PreIADM=$p(^DHCPEIADM(ADM),"^",4)
	q $G(^DHCPEDataEx("DHCPEPreIADM","InsureUnit",PreIADM))
}

ClassMethod GetPAADM(InvPrtID As %Library.String = "", peAdmType As %Library.String = "") As %Status
{
   k ^DHCPETMP
    s PAADMStr=""
    Q:InvPrtID="" ""
    i peAdmType="I"
    {s PAADM=$P(^DHCPEINVPRT(InvPrtID),"^",2)
      s ^DHCPETMP(InvPrtID,PAADM)=""}
      
    i peAdmType="G"
    {  
   s PBRowId=$P(^DHCPEINVPRT(InvPrtID),"^",3)
   S PAPBRowId=0
   f  s PAPBRowId=$o(^DHCPEPAPBR(0,"PBDR",PBRowId,PAPBRowId)) q:PAPBRowId=""  d
   .s PIOIFPAuditDR=$p(^DHCPEPAPBR(PAPBRowId),"^",1)
   .s PIADMRowId=0
   .f  s PIADMRowId=$o(^DHCPEPreIADM(0,"PAORDITEM",PIOIFPAuditDR,PIADMRowId))  q:PIADMRowId=""  d
   ..s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADMRowId,0))
   ..q:IADM="" 
   ..s PAADM=$P(^DHCPEIADM(IADM),"^",1)
   ..s ^DHCPETMP(InvPrtID,PAADM)=""
   .
   .s PIADMRowId=0 
   .f  s PIADMRowId=$o(^DHCPEPreIADM(0,"PAORDENT",PIOIFPAuditDR,PIADMRowId)) q:PIADMRowId=""  d
   ..s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADMRowId,0))
   ..q:IADM="" 
   ..s PAADM=$P(^DHCPEIADM(IADM),"^",1)
   ..s ^DHCPETMP(InvPrtID,PAADM)=""
    }
  
    s PAADM=0
    f  s PAADM=$o(^DHCPETMP(InvPrtID,PAADM))  q:PAADM=""  d
    .i PAADMStr=""  s PAADMStr=PAADM
    .else  s PAADMStr=PAADMStr_"^"_PAADM
	quit PAADMStr
}

ClassMethod GetCashierModeClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetCashierModeExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
 	Quit $$$OK
}

ClassMethod GetCashierModeExecute(ByRef qHandle As %Binary) As %Status
{
 	Set repid=$I(^CacheTemp)
   s ind=1
   s CTPMRowId=0
   f  s CTPMRowId=$o(^CT("CTPM",CTPMRowId))  q:CTPMRowId=""  d
   .s CTPMDesc=$p(^CT("CTPM",CTPMRowId),"^",2)
   .s CTPMCode=$p(^CT("CTPM",CTPMRowId),"^",1)
   .q:$g(^DHCPESetting("DHCPE","CashierMode",CTPMRowId))'="Y"
   .d OutPut
   
   Set qHandle=$lb(0,repid,0)
   Quit $$$OK
OutPut      
	set Data=$lb(CTPMDesc,CTPMRowId,CTPMCode)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod GetCashierModeFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = GetCashierModeExecute ]
{
 	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
	//
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else      {				// fetch row
 		Set Row=^CacheTemp(repid,ind)
 	}
 	// Save QHandle
 	s qHandle=$lb(AtEnd,repid,ind)
	Quit $$$OK
}

Query GetCashierMode() As %Query(ROWSPEC = "Description:%String,Hidden:%String,Code:%String")
{
}

ClassMethod SaveCaShierData(ADMType, ADM, Amount)
{

	s Date=+$h
	s CurUserID=%session.Get("LOGON.USERID")
	i ADMType="I"
	{
		 i $d(^DHCPEDataEx("DHCPEPreIADM","CaShierData","ADM",ADM))  d
          .s OldDate=$g(^DHCPEDataEx("DHCPEPreIADM","CaShierData","ADM",ADM))
          .k ^DHCPEDataEx("DHCPEPreIADM","CaShierData",OldDate,ADM) 
	   s ^DHCPEDataEx("DHCPEPreIADM","CaShierData","ADM",ADM)=Date
	   s ^DHCPEDataEx("DHCPEPreIADM","CaShierData",Date,ADM)=Amount_"^"_CurUserID
		q 
	}	
	i ADMType="G"
	{
		
	   i $d(^DHCPEDataEx("DHCPEPreGADM","CaShierData","ADM",ADM))  d
          .s OldDate=$g(^DHCPEDataEx("DHCPEPreGADM","CaShierData","ADM",ADM))
          .k ^DHCPEDataEx("DHCPEPreGADM","CaShierData",OldDate,ADM) 
	   s ^DHCPEDataEx("DHCPEPreGADM","CaShierData","ADM",ADM)=Date
	   s ^DHCPEDataEx("DHCPEPreGADM","CaShierData",Date,ADM)=Amount_"^"_CurUserID
	   
	   	q
	}
}

ClassMethod CancelCashierNotes(ADMType, ADM, Amount)
{

	s Date=+$h
	s CurUserID=%session.Get("LOGON.USERID")
	
	i ADMType="I"
	{
		  q:'$d(^DHCPEDataEx("DHCPEPreIADM","CaShierData","ADM",ADM)) "NoCashier" 
          s Date=$g(^DHCPEDataEx("DHCPEPreIADM","CaShierData","ADM",ADM))
          k ^DHCPEDataEx("DHCPEPreIADM","CaShierData",Date,ADM) 
          k ^DHCPEDataEx("DHCPEPreIADM","CaShierData","ADM",ADM)
	
		q ""
	}	
	i ADMType="G"
	{
		 q:'$d(^DHCPEDataEx("DHCPEPreGADM","CaShierData","ADM",ADM)) "NoCashier" 
	      s Date=$g(^DHCPEDataEx("DHCPEPreGADM","CaShierData","ADM",ADM))
          k ^DHCPEDataEx("DHCPEPreGADM","CaShierData",Date,ADM) 
          k ^DHCPEDataEx("DHCPEPreGADM","CaShierData","ADM",ADM)
	   
	   	q ""
	}
}

ClassMethod GetDocNameByInvoice(invid)
{
	q ""
	s docName=""
	s PBID=$P($g(^DHCPEINVPRT(invid)),"^",3)
	q:PBID="" ""
	s relateId=$o(^DHCPEPAPBR(0,"PBDR",PBID,0))
	q:relateId="" ""
	s preAuditId=$p($g(^DHCPEPAPBR(relateId)),"^",1)
	q:preAuditId="" ""
	s PreIADMID=$O(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,0))
	q:PreIADMID="" ""
	s sub=0
	s flag=0
	f  s sub=$O(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,PreIADMID,sub)) q:(sub="")||(flag=1)  d
	.s stat=$P(^DHCPEPreIADM(PreIADMID,"ORDITEM",sub),"^",16)
	.q:stat'="1"
	.s userID=$P(^DHCPEPreIADM(PreIADMID,"ORDITEM",sub),"^",11)
	.q:userID=""
	.s docName=$P(^SSU("SSUSR",userID),"^",2)
	.s flag=1
	q docName
}

// 验证收费分类金额和总金额是否一致

// d ##class(web.DHCPE.Cashier).FeeInfoCheck("599",106)

ClassMethod FeeInfoCheck(preAuditIds, totalFee)
{
	s ^TEMPDHCPE("FeeInfoCheck")=preAuditIds_","_totalFee
	k ^DHCPEOEITEMTemp(preAuditIds)
	k ^DHCPEOEITEMAccAccTemp(preAuditIds)
	//s LocID=%session.Get("LOGON.CTLOCID")
	n (preAuditIds,totalFee)
	q:(preAuditIds="") 1
	s MAmount=0.03 ;允许的差额范围
	s RoundFeeFlag=0
	s RoundFeeItemID=""
	s ErrInfo=""
	s Flag=0
	s j=1
	while(j<=$l(preAuditIds,",")){
		s preAuditId=$p(preAuditIds,",",j)
		s j=j+1
		continue:preAuditId=""
		s preAdmId=0
		f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId="")||(Flag=1))  d
		.s LocID=$P(^DHCPEPreIADM(preAdmId),"^",26)
		.s childsub=0
		.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub="")||(Flag=1))  d
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",2)'=""	//判断是否是套餐中的项目
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",16)'=1	//判断是否有效
		..s userID=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",11)
		..s date=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",12)
		..s time=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",13)
		..s orderQty=+$G(^DHCPEDataEx("DHCPEPreIOrdItem","Qty",preAdmId_"||"_childsub))
		..i orderQty=0 s orderQty=1
		..s arcitmid=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",1)
		..s ARCIMDesc=$p($g(^ARCIM($p(arcitmid,"||",1),$p(arcitmid,"||",2),1)),"^",2)
		..i arcitmid=$G(^DHCPESetting("DHCPE","RoundingFee")) d
		...;s RoundFeeFlag="1"
		...s RoundFeeItemID=preAdmId_"||"_childsub
		...s RoundInfo=$G(^DHCPEDataEx("InsertRoundFee",preAdmId,childsub))
		...s ^DHCPEOEITEMTemp(preAuditIds,"RoundInfo",RoundFeeItemID)=RoundInfo
		..s Amount=+$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",14)
		..s CurDate=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",12)
		..s GroupItemID=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",4)
		..i GroupItemID'="" d
		...s CurDate=$p($g(^DHCPEPreGADM(+GroupItemID,"Team",$p(GroupItemID,"||",2),"ORDITEM",$p(GroupItemID,"||",3))),"^",9)
		..//-------modify by zl for 药品
		..//得到医嘱类型，是药品则药品医嘱收费项目价格等于药品医嘱价格
		..s ItemADMType=""
		..s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_childsub))
		..s ARCICOrderType=""  
		..s ItemCatDR=$p(^ARCIM(+arcitmid,$p(arcitmid,"||",2),1),"^",10)  
		..i ItemCatDR'=""  s ARCICOrderType=$p(^ARC("IC",ItemCatDR),"^",7)
		..s ARCIMPrice=##class(web.DHCPE.PreItemList).GetOrderPrice(arcitmid,preAdmId,"",ItemADMType,CurDate)
		..//-----------
		..s FactAmount=+..GetFactAmount("1",preAdmId_"||"_childsub,preAuditId)
		..//q:FactAmount=0
		..;s Flag=0
		..s OneFactAmount=0
		
		..s FSub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub,0))
		..s CurFact=+$p($G(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub,"FEE",FSub)),"^",2)
		..//q:CurFact=0
		..s TarItem=0
		..f  s TarItem=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem)) q:TarItem=""  d
		...s StartDate=0
		...f  s StartDate=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate)) q:(StartDate="")||(StartDate>CurDate)  d
		....s OLTID=0
		....f  s OLTID=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate,OLTID)) q:OLTID=""  d
		.....s EndDate=$p(^DHCOLT(OLTID),"^",5)
		.....q:(EndDate'="")&&(EndDate<CurDate)
		.....s qty=$p(^DHCOLT(OLTID),"^",3)
		.....s ADMFeeType=""
		.....//s ADMFeeType=$G(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType",preAdmId))
	    .....s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_childsub))
		.....s CurPrice=+##class(web.UDHCJFPRICE).GetItmPrice(TarItem,CurDate,"",ItemADMType,"")   //得到当前计费项金额
		.....i ARCICOrderType="R"  s CurPrice=ARCIMPrice
		.....b:arcitmid="33206||1" ;qty orderQty CurPrice Amount CurFact
		.....i arcitmid'=$G(^DHCPESetting("DHCPE","RoundingFee")) d
		......i Amount>0 d
		.......i CurPrice'="0" d
		........s CurCatFee=(CurPrice/Amount)*CurFact*qty*orderQty
		.......e  s CurCatFee=0
		......e  s CurCatFee=CurFact
		.....e  d
		......s CurCatFee=CurFact
		.....s OneFactAmount=OneFactAmount+CurCatFee
		.....s itmsub=+$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",""),-1)+1
		.....s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",itmsub)=TarItem_"^"_$j((CurCatFee/(qty*orderQty)),3,2)_"^"_(qty*orderQty)_"^"_$j(CurCatFee,3,2)
		.....//w TarItem_"^"_(CurCatFee/(qty*orderQty))_"^"_(qty*orderQty)_"^"_CurCatFee,!
		.....s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",itmsub)=TarItem_"^"_$p(CurPrice,"^")_"^"_(qty*orderQty)_"^"_($p(CurPrice,"^")*qty*orderQty)  //Yx
		..i $zabs(OneFactAmount-FactAmount)>MAmount d
		...b ;OneFactAmount-FactAmount arcitmid
		...s Flag=1
		...i ErrInfo="" s ErrInfo=ARCIMDesc_"(开医嘱时间:"_$zd(CurDate,3)_")"
		...e  s ErrInfo=ErrInfo_","_ARCIMDesc_"(开医嘱时间:"_$zd(CurDate,3)_")"
		..e  d
		...s LimitAmount=OneFactAmount-FactAmount
		...q:+LimitAmount=0
		...s ItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",""),-1)
		...q:ItemID=""
		...s TarItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",""),-1)
		...q:TarItemID=""
		...s OldInfo=$G(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",TarItemID))
		...s Qty=$P(OldInfo,"^",3)
		...s Price=$P(OldInfo,"^",2)-$j(LimitAmount/Qty,3,2)
		...s $P(OldInfo,"^",2)=Price
		...s Amount=$P(OldInfo,"^",4)-$j(LimitAmount,3,2)
		...s $P(OldInfo,"^",4)=Amount
		...s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",TarItemID)=OldInfo
		
		..s OEORIROWID=""
		..s crmOrderID=$O(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_childsub,0))
		..i crmOrderID'="" d
		...s OEORIROWID=$P(^DHCPECRMO(crmOrderID),"^",1)
		..s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub)=OEORIROWID_"^"_$j((FactAmount/orderQty),3,2)_"^"_orderQty_"^"_$j(FactAmount,3,2)_"^"_arcitmid_"^"_userID_"^"_date_"^"_time
		b ;Flag
		q:Flag=1
		s preAdmId=0
		f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId="")||(Flag=1))  d
		.s LocID=$P(^DHCPEPreIADM(preAdmId),"^",26)
		.s childsub=0
		.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub="")||(Flag=1))  d
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
		..s Amount=+$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",7)
		..s CurDate=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",4)
		..s OrdSetsDR=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",1)
		..s GroupEntID=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",2)
		..i GroupEntID'="" d
		...s CurDate=$P(^DHCPEPreGADM(+GroupEntID,"Team",$P(GroupEntID,"||",2),"ORDENT",$P(GroupEntID,"||",3)),"^",3)
		..s FactAmount=+..GetFactAmount("2",preAdmId_"||"_childsub,preAuditId)
		..;s SetsDefaultTar=$G(^DHCPESetting("DHCPE","SetsDefaultTar",LocID))
		..s SetsDefaultTar=$G(^DHCPEDataEx("DHCPEBaseData","taritem",OrdSetsDR))
		..
		..i SetsDefaultTar'="" d  //体检医嘱套归到一个固定的收费项上
		...s OneFactAmount=FactAmount
		...s ItemSub=$o(^DHCPEPreIADM(0,"OrdEnt",preAdmId_"||"_childsub,preAdmId,0))
		...s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",1)=SetsDefaultTar_"^"_$j((FactAmount),3,2)_"^"_(1)_"^"_$j(FactAmount,3,2)
		...s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",1)=SetsDefaultTar_"^"_Amount_"^"_(1)_"^"_(Amount)  //yx
		...s SetsID=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",1)
		...s SetsDesc=$P($G(^ARCOS(SetsID)),"^",2)
		...s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"SetsName")=SetsDesc
		..e  d //按照真实的分类统计
		...;w OrdSetsDR,!
		...//套餐里面当时项目价格真实合计
		...s RealAmount=##class(web.DHCPE.TransAdmInfo).GetOrdSetsAmount(preAdmId_"||"_childsub)
		...s Amount=RealAmount
		
		...s FSub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub,0))
		...s CurFact=+$p($G(^DHCPEPreIADM(preAdmId,"ORDENT",childsub,"FEE",FSub)),"^",2)
		...s userID=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",3)
		...s date=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",4)
		...s time=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",5)
		...s OneFactAmount=0
		...s LastItemSub=""
		...s ItemSub=0
		...f  s ItemSub=$o(^DHCPEPreIADM(0,"OrdEnt",preAdmId_"||"_childsub,preAdmId,ItemSub)) q:ItemSub=""  d
		....q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",ItemSub)),"^",16)'=1
		....s arcitmid=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",ItemSub)),"^",1)
		....s ARCIMDesc=$p($g(^ARCIM($p(arcitmid,"||",1),$p(arcitmid,"||",2),1)),"^",2)
		....s orderQty=+$G(^DHCPEDataEx("DHCPEPreIOrdItem","Qty",preAdmId_"||"_ItemSub))
		....i orderQty=0 s orderQty=1
		....//-------------------------modify by zl for 药品
		....//得到医嘱类型，是药品则药品医嘱收费项目价格等于药品医嘱价格
		....s ItemADMType=""
		....s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_ItemSub))
		....s ARCIMPrice=##class(web.DHCPE.PreItemList).GetOrderPrice(arcitmid,preAdmId,"",ItemADMType,CurDate)
		....s ARCICOrderType=""  
		....s ItemCatDR=$p(^ARCIM(+arcitmid,$p(arcitmid,"||",2),1),"^",10)  
		....i ItemCatDR'=""  s ARCICOrderType=$p(^ARC("IC",ItemCatDR),"^",7)
		....s ItemAmount=+$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",ItemSub)),"^",14)
		....q:ItemAmount=0
		....//s PriceInfo=##class(web.DHCPE.PreItemList).GetOrderPrice(arcitmid,"",1)
		....//i (+$P(PriceInfo,"^",1))=(+$P(PriceInfo,"^",2)) d
		....//.s relate=1
		....//e  d
		....//.s relate=(+$P(PriceInfo,"^",2))/(+$P(PriceInfo,"^",1))
		....s TarItem=0
		....f  s TarItem=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem)) q:TarItem=""  d
		.....s StartDate=0
		.....f  s StartDate=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate)) q:(StartDate="")||(StartDate>CurDate)  d
		......s OLTID=0
		......f  s OLTID=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate,OLTID)) q:OLTID=""  d
		.......s EndDate=$p(^DHCOLT(OLTID),"^",5)
		.......q:(EndDate'="")&&(EndDate<CurDate)
		.......s qty=$p(^DHCOLT(OLTID),"^",3)
		.......s ADMFeeType=""
		.......//s ADMFeeType=$G(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType",preAdmId))
		.......s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_ItemSub))
		.......s CurPrice=+##class(web.UDHCJFPRICE).GetItmPrice(TarItem,CurDate,"",ItemADMType,"")   //得到当前计费项金额
		.......i ARCICOrderType="R"  s CurPrice=ARCIMPrice
		.......i Amount>0 d
		........i ItemAmount'=0 d
		.........i CurPrice'=0  d
		..........s CurCatFee=(CurPrice/Amount)*qty*CurFact*orderQty
		.........e  d
		..........s CurCatFee=0
		.......e  d
		........s CurCatFee=CurFact
		.......s itmsub=+$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",""),-1)+1
		.......s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",itmsub)=TarItem_"^"_$j((CurCatFee/(qty*orderQty)),3,2)_"^"_(qty*orderQty)_"^"_$j(CurCatFee,3,2)
		.......s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",itmsub)=TarItem_"^"_$P(CurPrice,"^")_"^"_(qty*orderQty)_"^"_($p(CurPrice,"^")*qty*orderQty)  //yx
		....i Amount'=0 d
		.....s FactAmount2=(CurFact/Amount)*ItemAmount
		....e  d
		.....s FactAmount2=CurFact
		....s OneFactAmount=OneFactAmount+FactAmount2
		....s OEORIROWID=""
		....s crmOrderID=$O(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_ItemSub,0))
		....i crmOrderID'="" d
		.....s OEORIROWID=$P(^DHCPECRMO(crmOrderID),"^",1)
		....s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub)=OEORIROWID_"^"_$j((FactAmount/orderQty),3,2)_"^"_orderQty_"^"_$j(FactAmount,3,2)_"^"_arcitmid_"^"_userID_"^"_date_"^"_time
		..i $zabs(OneFactAmount-FactAmount)>MAmount d
		...b ;OneFactAmount-FactAmount2 arcitmid
		...s Flag=1 b ;OneFactAmount-FactAmount
		...i ErrInfo="" s ErrInfo=ARCIMDesc_"(开医嘱时间:"_$zd(CurDate,3)_")"
		...e  s ErrInfo=ErrInfo_","_ARCIMDesc_"(开医嘱时间:"_$zd(CurDate,3)_")"
		..e  d
		...s LimitAmount=OneFactAmount-FactAmount
		...q:+LimitAmount=0
		...s ItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",""),-1)
		...q:ItemID=""
		...s TarItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",""),-1)
		...q:TarItemID=""
		...s OldInfo=$G(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",TarItemID))
		...s Qty=$P(OldInfo,"^",3)
		...s Price=$P(OldInfo,"^",2)-$j(LimitAmount/Qty,3,2)
		...s $P(OldInfo,"^",2)=Price
		...s Amount=$P(OldInfo,"^",4)-$j(LimitAmount,3,2)
		...s $P(OldInfo,"^",4)=Amount
		...s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",TarItemID)=OldInfo
	}
	i Flag=1 d
	.k ^DHCPEOEITEMTemp(preAuditIds)
	.k ^DHCPEOEITEMAccAccTemp(preAuditIds)
	i RoundFeeFlag=1 d
	.s crmOrderID=$O(^DHCPECRMO(0,"CRMORI",RoundFeeItemID,0))
	.s RoundFeeOrderID=$P(^DHCPECRMO(crmOrderID),"^",1)
	.s arcitmid=$p($g(^DHCPEPreIADM(+RoundFeeItemID,"ORDITEM",$P(RoundFeeItemID,"||",2))),"^",1)
	.s userID=$p($g(^DHCPEPreIADM(+RoundFeeItemID,"ORDITEM",$P(RoundFeeItemID,"||",2))),"^",11)
	.s date=$p($g(^DHCPEPreIADM(+RoundFeeItemID,"ORDITEM",$P(RoundFeeItemID,"||",2))),"^",12)
	.s time=$p($g(^DHCPEPreIADM(+RoundFeeItemID,"ORDITEM",$P(RoundFeeItemID,"||",2))),"^",13)
	.m ^DHCPEOEITEMTempSource(preAuditIds)=^DHCPEOEITEMTemp(preAuditIds)
	.k ^DHCPEOEITEMTemp(preAuditIds,"OEITEM")
	.s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",RoundFeeItemID)=RoundFeeOrderID_"^"_$j((totalFee),3,2)_"^"_1_"^"_$j(totalFee,3,2)_"^"_arcitmid_"^"_userID_"^"_date_"^"_time
	.;s TarItem=$G(^DHCPESetting("DHCPE","SetsDefaultTar",LocID))
	.s TarItem=##class(web.DHCPE.CashierEx).GetOneTarItem(arcitmid)
	.m ^DHCPEOEITEMAccAccTempSource(preAuditIds)=^DHCPEOEITEMAccAccTemp(preAuditIds)
	.k ^DHCPEOEITEMAccAccTemp(preAuditIds)
	.s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",RoundFeeItemID,"TARITEM",1)=TarItem_"^"_$j(totalFee,3,2)_"^"_1_"^"_$j(totalFee,3,2)
	.s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",RoundFeeItemID,"TARITEM",1)=TarItem_"^"_$j(totalFee,3,2)_"^"_1_"^"_$j(totalFee,3,2)
	//q Flag
	q Flag_"$"_ErrInfo
}

// 验证收费分类金额和总金额是否一致(8.3版本药品走批次价：医嘱项——库存项——收费项)

// d ##class(web.DHCPE.Cashier).FeeInfoCheckNew("25237",212.50)

ClassMethod FeeInfoCheckNew(preAuditIds, totalFee)
{
	k ^TEMPDHCPE("FeeInfoCheckNew")
	s ^TEMPDHCPE("FeeInfoCheckNew")=preAuditIds_","_totalFee
	k ^DHCPEOEITEMTemp(preAuditIds)
	k ^DHCPEOEITEMAccAccTemp(preAuditIds)
	//s LocID=%session.Get("LOGON.CTLOCID")
	n (preAuditIds,totalFee)
	q:(preAuditIds="") 1
	s MAmount=0.03 ;允许的差额范围
	s RoundFeeFlag=0
	s RoundFeeItemID=""
	s ErrInfo=""
	s Flag=0
	s j=1
	while(j<=$l(preAuditIds,",")){
		s preAuditId=$p(preAuditIds,",",j)
		s j=j+1
		continue:preAuditId=""
		s preAdmId=0
		f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId="")||(Flag=1))  d
		.s LocID=$P(^DHCPEPreIADM(preAdmId),"^",26)
		.S IADM=$O(^DHCPEIADM(0,"CRMADM",preAdmId,0))
		.q:IADM=""
		.S PAADM=$P($G(^DHCPEIADM(IADM)),"^",1)
		.q:PAADM=""
		.s HospID=##class(web.UDHCHospitalGroup).GetHospitalByAdm(PAADM) //获取当前客户所在院区
		.s childsub=0
		.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:((childsub="")||(Flag=1))  d
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",2)'=""	//判断是否是套餐中的项目
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",16)'=1	//判断是否有效
		..s userID=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",11)
		..s date=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",12)
		..s time=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",13)
		..s orderQty=+$G(^DHCPEDataEx("DHCPEPreIOrdItem","Qty",preAdmId_"||"_childsub))
		..i orderQty=0 s orderQty=1
		..s arcitmid=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",1)
		..s ARCIMDesc=$p($g(^ARCIM($p(arcitmid,"||",1),$p(arcitmid,"||",2),1)),"^",2) 
		..
		..i arcitmid=$G(^DHCPESetting("DHCPE","RoundingFee")) d
		...;s RoundFeeFlag="1"
		...s RoundFeeItemID=preAdmId_"||"_childsub
		...s RoundInfo=$G(^DHCPEDataEx("InsertRoundFee",preAdmId,childsub))
		...s ^DHCPEOEITEMTemp(preAuditIds,"RoundInfo",RoundFeeItemID)=RoundInfo
		..s Amount=+$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",14)
		..s CurDate=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",12)
		..s GroupItemID=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",4)
		..i GroupItemID'="" d
		...s CurDate=$p($g(^DHCPEPreGADM(+GroupItemID,"Team",$p(GroupItemID,"||",2),"ORDITEM",$p(GroupItemID,"||",3))),"^",9)
		..s ItemADMType=""
		..s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_childsub))
		..s ARCICOrderType=""  
		..s ItemCatDR=$p(^ARCIM(+arcitmid,$p(arcitmid,"||",2),1),"^",10)  
		..i ItemCatDR'=""  s ARCICOrderType=$p(^ARC("IC",ItemCatDR),"^",7)
		..s ARCIMPrice=##class(web.DHCPE.PreItemList).GetOrderPrice(arcitmid,preAdmId,"",ItemADMType,CurDate)
		..s FactAmount=+..GetFactAmount("1",preAdmId_"||"_childsub,preAuditId)
		..s OneFactAmount=0
		..s FSub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub,0))
		..s CurFact=+$p($G(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub,"FEE",FSub)),"^",2)
		..
		..s CRMORowId=$o(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_childsub,0))
		..s oeitm=$p($g(^DHCPECRMO(CRMORowId)),"^",1)
		..s oeore=oeitm_"||1"
		..S regLoc=""
		..s itmPriceExpStr=""_"^"_oeitm_"^"_oeore_"^"_PAADM_"^"_regLoc_"^"_arcitmid_"^"_""_"^"_""
		..b ;
		..i ARCICOrderType="R" d
		...
		...set dspDr="0"
		...for  set dspDr=$o(^DHCOEDISQTY(0,"OEORI",oeitm,dspDr)) quit:(dspDr="")  do
		....;b ;01
		....set dspInfo=$g(^DHCOEDISQTY(dspDr))
		....quit:(dspInfo="")
		....;b ;dspInfo
		....set dspbSub="0"
		....for  set dspbSub=$o(^DHCOEDISQTY(dspDr,"I",dspbSub)) quit:(dspbSub="")  do
		.....;b ;02
		.....set tmp=$g(^DHCOEDISQTY(dspDr,"I",dspbSub))
		.....quit:(tmp="")
		.....set dspbDr=dspDr_"||"_dspbSub
		.....set inciDr=$p(tmp,"^",5) ;DSPB_INCI_DR  库存表
		.....set cltDr="0"
		.....for  set cltDr=$o(^DHCINCTARi("INCI",inciDr,cltDr)) quit:(cltDr="")  do
		......set stDate=$p(^DHCINCTAR(cltDr),"^",4)
		......set endDate=$p(^DHCINCTAR(cltDr),"^",5)
		......quit:((CurDate<stDate)||((endDate'="")&&(CurDate>endDate)))
		......set TarItem=$p(^DHCINCTAR(cltDr),"^",2)  ;收费项
		......set qty=$p(^DHCINCTAR(cltDr),"^",3)  ;收费项数量
		......set $p(itmPriceExpStr,"^",8)=dspbDr
		......set CurPrice=+##class(web.UDHCJFPRICE).GetItmPrice(TarItem,CurDate,"",ItemADMType,"",HospID,itmPriceExpStr)
		......;b ;CurPrice
		......i arcitmid'=$G(^DHCPESetting("DHCPE","RoundingFee")) d
		.......i Amount>0 d
		........i CurPrice'="0" d
		.........s CurCatFee=(CurPrice/Amount)*CurFact*qty*orderQty
		........e  s CurCatFee=0
		.......e  s CurCatFee=CurFact
		......e  d
		.......s CurCatFee=CurFact
		......s OneFactAmount=OneFactAmount+CurCatFee
		......s itmsub=+$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",""),-1)+1
		......s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",itmsub)=TarItem_"^"_$j((CurCatFee/(qty*orderQty)),3,2)_"^"_(qty*orderQty)_"^"_$j(CurCatFee,3,2)
		......s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",itmsub)=TarItem_"^"_$p(CurPrice,"^")_"^"_(qty*orderQty)_"^"_($p(CurPrice,"^")*qty*orderQty)  
		..e  d
		...b ;arcitmid
		...s TarItem=0
		...f  s TarItem=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem)) q:TarItem=""  d
		....s StartDate=0
		....f  s StartDate=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate)) q:(StartDate="")||(StartDate>CurDate)  d
		.....s OLTID=0
		.....f  s OLTID=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate,OLTID)) q:OLTID=""  d
		......b ;EndDate  CurDate
		......s EndDate=$p(^DHCOLT(OLTID),"^",5)
		......q:(EndDate'="")&&(EndDate<CurDate)
		......s qty=$p(^DHCOLT(OLTID),"^",3)
		......s CurPrice=+##class(web.UDHCJFPRICE).GetItmPrice(TarItem,CurDate,"",ItemADMType,"")   //得到当前计费项金额
		......b ;CurPrice
		......i arcitmid'=$G(^DHCPESetting("DHCPE","RoundingFee")) d
		.......i Amount>0 d
		........i CurPrice'="0" d
		.........s CurCatFee=(CurPrice/Amount)*CurFact*qty*orderQty
		........e  s CurCatFee=0
		.......e  s CurCatFee=CurFact
		......e  d
		.......s CurCatFee=CurFact
		......s OneFactAmount=OneFactAmount+CurCatFee
		......s itmsub=+$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",""),-1)+1
		......s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",itmsub)=TarItem_"^"_$j((CurCatFee/(qty*orderQty)),3,2)_"^"_(qty*orderQty)_"^"_$j(CurCatFee,3,2)
		......s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub,"TARITEM",itmsub)=TarItem_"^"_$p(CurPrice,"^")_"^"_(qty*orderQty)_"^"_($p(CurPrice,"^")*qty*orderQty)  //Yx
		
		..i $zabs(OneFactAmount-FactAmount)>MAmount d
		...b ;OneFactAmount-FactAmount arcitmid
		...s Flag=1
		...i ErrInfo="" s ErrInfo=ARCIMDesc_"(开医嘱时间:"_$zd(CurDate,3)_")"
		...e  s ErrInfo=ErrInfo_","_ARCIMDesc_"(开医嘱时间:"_$zd(CurDate,3)_")"
		..e  d
		...s LimitAmount=OneFactAmount-FactAmount
		...q:+LimitAmount=0
		...s ItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",""),-1)
		...q:ItemID=""
		...s TarItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",""),-1)
		...q:TarItemID=""
		...s OldInfo=$G(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",TarItemID))
		...s Qty=$P(OldInfo,"^",3)
		...s Price=$P(OldInfo,"^",2)-$j(LimitAmount/Qty,3,2)
		...s $P(OldInfo,"^",2)=Price
		...s Amount=$P(OldInfo,"^",4)-$j(LimitAmount,3,2)
		...s $P(OldInfo,"^",4)=Amount
		...s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",TarItemID)=OldInfo
		..
		..s OEORIROWID=""
		..s crmOrderID=$O(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_childsub,0))
		..i crmOrderID'="" d
		...s OEORIROWID=$P(^DHCPECRMO(crmOrderID),"^",1)
		..s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_childsub)=OEORIROWID_"^"_$j((FactAmount/orderQty),3,2)_"^"_orderQty_"^"_$j(FactAmount,3,2)_"^"_arcitmid_"^"_userID_"^"_date_"^"_time
		b ;Flag
		q:Flag=1
		
		
		s preAdmId=0
		f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId)) q:((preAdmId="")||(Flag=1))  d
		.s LocID=$P(^DHCPEPreIADM(preAdmId),"^",26)
		.S IADM=$O(^DHCPEIADM(0,"CRMADM",preAdmId,0))
		.q:IADM=""
		.S PAADM=$P($G(^DHCPEIADM(IADM)),"^",1)
		.q:PAADM=""
		.s HospID=##class(web.UDHCHospitalGroup).GetHospitalByAdm(PAADM) //获取当前客户所在院区
		.s childsub=0
		.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub)) q:((childsub="")||(Flag=1))  d
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",9)'=1	//判断是否有效
		..s Amount=+$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",7)
		..s CurDate=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",4)
		..s OrdSetsDR=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",1)
		..s GroupEntID=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",2)
		..i GroupEntID'="" d
		...s CurDate=$P(^DHCPEPreGADM(+GroupEntID,"Team",$P(GroupEntID,"||",2),"ORDENT",$P(GroupEntID,"||",3)),"^",3)
		..s FactAmount=+..GetFactAmount("2",preAdmId_"||"_childsub,preAuditId)
		..s SetsDefaultTar=$G(^DHCPEDataEx("DHCPEBaseData","taritem",OrdSetsDR))
		..
		..i SetsDefaultTar'="" d  //体检医嘱套归到一个固定的收费项上
		...s OneFactAmount=FactAmount
		...s ItemSub=$o(^DHCPEPreIADM(0,"OrdEnt",preAdmId_"||"_childsub,preAdmId,0))
		...s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",1)=SetsDefaultTar_"^"_$j((FactAmount),3,2)_"^"_(1)_"^"_$j(FactAmount,3,2)
		...s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",1)=SetsDefaultTar_"^"_Amount_"^"_(1)_"^"_(Amount)  //yx
		...s SetsID=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",1)
		...s SetsDesc=$P($G(^ARCOS(SetsID)),"^",2)
		...s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"SetsName")=SetsDesc
		..e  d //按照真实的分类统计
		...//套餐里面当时项目价格真实合计
		...s RealAmount=##class(web.DHCPE.TransAdmInfo).GetOrdSetsAmount(preAdmId_"||"_childsub)
		...s Amount=RealAmount
		...s FSub=$o(^DHCPEPreIADM(0,"PAORDENT",preAuditId,preAdmId,childsub,0))
		...s CurFact=+$p($G(^DHCPEPreIADM(preAdmId,"ORDENT",childsub,"FEE",FSub)),"^",2)
		...s userID=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",3)
		...s date=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",4)
		...s time=$p($g(^DHCPEPreIADM(preAdmId,"ORDENT",childsub)),"^",5)
		...s OneFactAmount=0
		...s LastItemSub=""
		...s ItemSub=0
		...f  s ItemSub=$o(^DHCPEPreIADM(0,"OrdEnt",preAdmId_"||"_childsub,preAdmId,ItemSub)) q:ItemSub=""  d
		....q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",ItemSub)),"^",16)'=1
		....s arcitmid=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",ItemSub)),"^",1)
		....s ARCIMDesc=$p($g(^ARCIM($p(arcitmid,"||",1),$p(arcitmid,"||",2),1)),"^",2) 
		....s orderQty=+$G(^DHCPEDataEx("DHCPEPreIOrdItem","Qty",preAdmId_"||"_ItemSub))
		....i orderQty=0 s orderQty=1
		....
		....s ItemADMType=""
		....s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_ItemSub))
		....s ARCIMPrice=##class(web.DHCPE.PreItemList).GetOrderPrice(arcitmid,preAdmId,"",ItemADMType,CurDate)
		....s ARCICOrderType=""  
		....s ItemCatDR=$p(^ARCIM(+arcitmid,$p(arcitmid,"||",2),1),"^",10)  
		....i ItemCatDR'=""  s ARCICOrderType=$p(^ARC("IC",ItemCatDR),"^",7)
		....s ItemAmount=+$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",ItemSub)),"^",14)
		....q:ItemAmount=0
	 	....
	    ....s CRMORowId=$o(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_ItemSub,0))
		....s oeitm=$p($g(^DHCPECRMO(CRMORowId)),"^",1)
		....s oeore=oeitm_"||1"
		....S regLoc=""
		....s itmPriceExpStr=""_"^"_oeitm_"^"_oeore_"^"_PAADM_"^"_regLoc_"^"_arcitmid_"^"_""_"^"_""
		....i ARCICOrderType="R" d
		....set dspDr="0"
		....for  set dspDr=$o(^DHCOEDISQTY(0,"OEORI",oeitm,dspDr)) quit:(dspDr="")  do
		.....set dspInfo=$g(^DHCOEDISQTY(dspDr))
		.....quit:(dspInfo="")
		.....set dspbSub="0"
		.....for  set dspbSub=$o(^DHCOEDISQTY(dspDr,"I",dspbSub)) quit:(dspbSub="")  do
		......set tmp=$g(^DHCOEDISQTY(dspDr,"I",dspbSub))
		......quit:(tmp="")
		......set dspbDr=dspDr_"||"_dspbSub
		......set inciDr=$p(tmp,"^",5) ;DSPB_INCI_DR  库存表
		......set cltDr="0"
		......for  set cltDr=$o(^DHCINCTARi("INCI",inciDr,cltDr)) quit:(cltDr="")  do
		.......set stDate=$p(^DHCINCTAR(cltDr),"^",4)
		.......set endDate=$p(^DHCINCTAR(cltDr),"^",5)
		.......quit:((CurDate<stDate)||((endDate'="")&&(CurDate>endDate)))
		.......set TarItem=$p(^DHCINCTAR(cltDr),"^",2)  ;收费项
		.......set qty=$p(^DHCINCTAR(cltDr),"^",3)  ;收费项数量
		.......set $p(itmPriceExpStr,"^",8)=dspbDr
		.......set CurPrice=+##class(web.UDHCJFPRICE).GetItmPrice(TarItem,CurDate,"",ItemADMType,"",HospID,itmPriceExpStr)
		.......i Amount>0 d
		........i ItemAmount'=0 d
		.........i CurPrice'=0  d
		..........s CurCatFee=(CurPrice/Amount)*qty*CurFact*orderQty
		.........e  d
		..........s CurCatFee=0
		.......e  d
		........s CurCatFee=CurFact
		.......s itmsub=+$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",""),-1)+1
		.......s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",itmsub)=TarItem_"^"_$j((CurCatFee/(qty*orderQty)),3,2)_"^"_(qty*orderQty)_"^"_$j(CurCatFee,3,2)
		.......s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",itmsub)=TarItem_"^"_$P(CurPrice,"^")_"^"_(qty*orderQty)_"^"_($p(CurPrice,"^")*qty*orderQty)  //yx
		.....i Amount'=0 d
		......s FactAmount2=(CurFact/Amount)*ItemAmount
		.....e  d
		......s FactAmount2=CurFact
		.....s OneFactAmount=OneFactAmount+FactAmount2
		.....s OEORIROWID=""
		.....s crmOrderID=$O(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_ItemSub,0))
		.....i crmOrderID'="" d
		......s OEORIROWID=$P(^DHCPECRMO(crmOrderID),"^",1)
		.....s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub)=OEORIROWID_"^"_$j((FactAmount/orderQty),3,2)_"^"_orderQty_"^"_$j(FactAmount,3,2)_"^"_arcitmid_"^"_userID_"^"_date_"^"_time
		
		
	
	    ....e  d
		.....s TarItem=0
		.....f  s TarItem=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem)) q:TarItem=""  d
		......s StartDate=0
		......f  s StartDate=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate)) q:(StartDate="")||(StartDate>CurDate)  d
		.......s OLTID=0
		.......f  s OLTID=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate,OLTID)) q:OLTID=""  d
		........s EndDate=$p(^DHCOLT(OLTID),"^",5)
		........q:(EndDate'="")&&(EndDate<CurDate)
		........s qty=$p(^DHCOLT(OLTID),"^",3)
		........s ADMFeeType=""
		........//s ADMFeeType=$G(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType",preAdmId))
		........s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",preAdmId_"||"_ItemSub))
		........s CurPrice=+##class(web.UDHCJFPRICE).GetItmPrice(TarItem,CurDate,"",ItemADMType,"")   //得到当前计费项金额
		........b ;CurPrice
		........i Amount>0 d
		.........i ItemAmount'=0 d
		..........i CurPrice'=0  d
		...........s CurCatFee=(CurPrice/Amount)*qty*CurFact*orderQty
		..........e  d
		...........s CurCatFee=0
		........e  d
		.........s CurCatFee=CurFact
		
		........s itmsub=+$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",""),-1)+1
		........s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",itmsub)=TarItem_"^"_$j((CurCatFee/(qty*orderQty)),3,2)_"^"_(qty*orderQty)_"^"_$j(CurCatFee,3,2)
		........s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub,"TARITEM",itmsub)=TarItem_"^"_$P(CurPrice,"^")_"^"_(qty*orderQty)_"^"_($p(CurPrice,"^")*qty*orderQty)  //yx
		.....i Amount'=0 d
		......s FactAmount2=(CurFact/Amount)*ItemAmount
		.....e  d
		......s FactAmount2=CurFact
		.....s OneFactAmount=OneFactAmount+FactAmount2
		.....s OEORIROWID=""
		.....s crmOrderID=$O(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_ItemSub,0))
		.....i crmOrderID'="" d
		......s OEORIROWID=$P(^DHCPECRMO(crmOrderID),"^",1)
		.....s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",preAdmId_"||"_ItemSub)=OEORIROWID_"^"_$j((FactAmount/orderQty),3,2)_"^"_orderQty_"^"_$j(FactAmount,3,2)_"^"_arcitmid_"^"_userID_"^"_date_"^"_time
		
		..i $zabs(OneFactAmount-FactAmount)>MAmount d
		...b ;OneFactAmount-FactAmount2 arcitmid
		...s Flag=1 b ;OneFactAmount-FactAmount
		...i ErrInfo="" s ErrInfo=ARCIMDesc_"(开医嘱时间:"_$zd(CurDate,3)_")"
		...e  s ErrInfo=ErrInfo_","_ARCIMDesc_"(开医嘱时间:"_$zd(CurDate,3)_")"

		..e  d
		
		...s LimitAmount=OneFactAmount-FactAmount
		...q:+LimitAmount=0
		...s ItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",""),-1)
		...q:ItemID=""
		...s TarItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",""),-1)
		...q:TarItemID=""
		...s OldInfo=$G(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",TarItemID))
		...s Qty=$P(OldInfo,"^",3)
		...s Price=$P(OldInfo,"^",2)-$j(LimitAmount/Qty,3,2)
		...s $P(OldInfo,"^",2)=Price
		...s Amount=$P(OldInfo,"^",4)-$j(LimitAmount,3,2)
		...s $P(OldInfo,"^",4)=Amount
		...s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",ItemID,"TARITEM",TarItemID)=OldInfo
	}
	i Flag=1 d
	.k ^DHCPEOEITEMTemp(preAuditIds)
	.k ^DHCPEOEITEMAccAccTemp(preAuditIds)
	i RoundFeeFlag=1 d
	.s crmOrderID=$O(^DHCPECRMO(0,"CRMORI",RoundFeeItemID,0))
	.s RoundFeeOrderID=$P(^DHCPECRMO(crmOrderID),"^",1)
	.s arcitmid=$p($g(^DHCPEPreIADM(+RoundFeeItemID,"ORDITEM",$P(RoundFeeItemID,"||",2))),"^",1)
	.s userID=$p($g(^DHCPEPreIADM(+RoundFeeItemID,"ORDITEM",$P(RoundFeeItemID,"||",2))),"^",11)
	.s date=$p($g(^DHCPEPreIADM(+RoundFeeItemID,"ORDITEM",$P(RoundFeeItemID,"||",2))),"^",12)
	.s time=$p($g(^DHCPEPreIADM(+RoundFeeItemID,"ORDITEM",$P(RoundFeeItemID,"||",2))),"^",13)
	.m ^DHCPEOEITEMTempSource(preAuditIds)=^DHCPEOEITEMTemp(preAuditIds)
	.k ^DHCPEOEITEMTemp(preAuditIds,"OEITEM")
	.s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",RoundFeeItemID)=RoundFeeOrderID_"^"_$j((totalFee),3,2)_"^"_1_"^"_$j(totalFee,3,2)_"^"_arcitmid_"^"_userID_"^"_date_"^"_time
	.;s TarItem=$G(^DHCPESetting("DHCPE","SetsDefaultTar",LocID))
	.s TarItem=##class(web.DHCPE.CashierEx).GetOneTarItem(arcitmid)
	.m ^DHCPEOEITEMAccAccTempSource(preAuditIds)=^DHCPEOEITEMAccAccTemp(preAuditIds)
	.k ^DHCPEOEITEMAccAccTemp(preAuditIds)
	.s ^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM",RoundFeeItemID,"TARITEM",1)=TarItem_"^"_$j(totalFee,3,2)_"^"_1_"^"_$j(totalFee,3,2)
	.s ^DHCPEOEITEMTemp(preAuditIds,"OEITEM",RoundFeeItemID,"TARITEM",1)=TarItem_"^"_$j(totalFee,3,2)_"^"_1_"^"_$j(totalFee,3,2)
	q Flag_"$"_ErrInfo
}

// d ##class(web.DHCPE.Cashier).GetFeeInfo(239,1913,2334.77)

ClassMethod GetFeeInfo(invID, preAuditIds, totalFee)
{
	n (invID,preAuditIds,totalFee)
	q:(invID="")||(preAuditIds="") 0
	s invNo=$P(^DHCPEINVPRT(invID),"^",1)
	s paadm=$P(^DHCPEINVPRT(invID),"^",2)
	s ^DHCPEOEITEM(invID)=totalFee_"^"_invNo_"^"_paadm
	m ^DHCPEOEITEM(invID,"OEITEM")=^DHCPEOEITEMTemp(preAuditIds,"OEITEM")
	m ^DHCPEOEITEM(invID,"RoundInfo")= ^DHCPEOEITEMTemp(preAuditIds,"RoundInfo")
	k ^DHCPEOEITEMTemp(preAuditIds)
	m ^DHCPEOEITEMAccAcc(invID,"OEITEM")=^DHCPEOEITEMAccAccTemp(preAuditIds,"OEITEM")
	k ^DHCPEOEITEMAccAccTemp(preAuditIds)
	i $D(^DHCPEOEITEMTempSource(preAuditIds)) d
	.m ^DHCPEOEITEMSource(invID,"OEITEM")=^DHCPEOEITEMTempSource(preAuditIds,"OEITEM")
	.m ^DHCPEOEITEMAccAccSource(invID,"OEITEM")=^DHCPEOEITEMAccAccTempSource(preAuditIds,"OEITEM")
	.k ^DHCPEOEITEMTempSource(preAuditIds)
	.k ^DHCPEOEITEMAccAccTempSource(preAuditIds)
	d ..FBWCOeItem(invID)
	q 0
}

/// 四舍五入导致的分类金额不符
/// d ##class(web.DHCPE.Cashier).FBWCOeItem(165)
ClassMethod FBWCOeItem(invID)
{
	s InvAmt=$P(^DHCPEOEITEM(invID),"^",1)
	s Amt=0
	s PreItemID=""
	f  s PreItemID=$O(^DHCPEOEITEM(invID,"OEITEM",PreItemID)) q:PreItemID=""  d
	.s TarItemSub=""
	.f  s TarItemSub=$O(^DHCPEOEITEM(invID,"OEITEM",PreItemID,"TARITEM",TarItemSub)) q:TarItemSub=""  d
	..s OneAmt=$P(^DHCPEOEITEM(invID,"OEITEM",PreItemID,"TARITEM",TarItemSub),"^",4)
	..s Amt=Amt+OneAmt
	i +InvAmt'=+Amt d
	.s Amt=InvAmt-Amt
	.s PreItemID=$O(^DHCPEOEITEM(invID,"OEITEM",""))
	.s TarItemSub=$O(^DHCPEOEITEM(invID,"OEITEM",PreItemID,"TARITEM",""))
	.q:TarItemSub=""
	.s OneAmt=$P(^DHCPEOEITEM(invID,"OEITEM",PreItemID,"TARITEM",TarItemSub),"^",4)
	.s OneAmt=OneAmt+Amt
	.s $P(^DHCPEOEITEM(invID,"OEITEM",PreItemID,"TARITEM",TarItemSub),"^",4)=$FN(OneAmt,"",2)
	.s Count=$P(^DHCPEOEITEM(invID,"OEITEM",PreItemID,"TARITEM",TarItemSub),"^",3)
	.s $P(^DHCPEOEITEM(invID,"OEITEM",PreItemID,"TARITEM",TarItemSub),"^",2)=$FN((OneAmt)/Count,"",2) 
	q ""
}

/// ##class(web.DHCPE.Cashier).GetInvNameById("I","13526")
ClassMethod GetInvNameById(pAdmType, pAdmId)
{
	q:pAdmId="" ""
	s Name=""
	i pAdmType="I" d
	.s CRMID=$p($g(^DHCPEIADM(pAdmId)),"^",4)
	.s BaseInfo=$p($g(^DHCPEPreIADM(CRMID)),"^",1)
	.s Name=$P($G(^DHCPEPreIBI(BaseInfo)),"^",2)
	e  d
	.s CRMID=$p($g(^DHCPEGADM(pAdmId)),"^",2)
	.s BaseInfo=$p($g(^DHCPEPreGADM(CRMID)),"^",1)
	.s Name=$P($G(^DHCPEPreGBI(BaseInfo)),"^",2)
	q Name
}

ClassMethod GetYBCode(TARITEMID)
{
	s $ZT="GetYBCodeErr"
	s myYBCode=##class(web.DHCINSUFacade).GetInusTarInfo(TARITEMID)
	q myYBCode
GetYBCodeErr
	q ""
}

/// w ##class(web.DHCPE.Cashier).GetDateTimeStr()
/// s val=##Class(%CSP.Page).Encrypt($lb("web.DHCPE.Cashier.GetDateTimeStr"))
ClassMethod GetDateTimeStr()
{
	s DateTimeStr=$zd(+$h,3)_" "_$zt($p($h,",",2))
	q DateTimeStr
}

ClassMethod GetPayModeDesc(paymodeID)
{
	q:paymodeID="" ""
	S PayDesc=""
	s PayDesc=$p($g(^CT("CTPM",paymodeID)),"^",2)
	Q PayDesc
}

ClassMethod GetssrAmountByInv(InvID)
{
   s ssr=0
   S ssr=$p($g(^DHCPEINVPRT(InvID)),"^",21)
   q ssr
}

}
