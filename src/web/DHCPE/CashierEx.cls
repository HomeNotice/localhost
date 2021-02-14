Class web.DHCPE.CashierEx Extends %Persistent
{

// w ##class(web.DHCPE.CashierEx).GetSSPFlag(101911)

ClassMethod GetSSPFlag(InvoicId)
{
	s SSPFlag=0
	q:InvoicId="" SSPFlag
	s InvNo=$P(^DHCPEINVPRT(InvoicId),"^",1)
	s FocusPrintID=""
	s FocusPrintID=$o(^User.DHCPEINVFocusPrtI("IFPINVDRIndex"," "_InvoicId,""))
	//s:InvNo[("DHCSSP") SSPFlag=1
	s:InvNo[("DHCSSP")&&(FocusPrintID="") SSPFlag=1
	q SSPFlag
}

// w ##class(web.DHCPE.CashierEx).GetListInfo("165793,165794","")

ClassMethod GetListInfo(preAuditIds, listcount As %String)
{
	

	d ##class(web.DHCPE.Cashier).FeeInfoCheck(preAuditIds,0)
	b ;^DHCPEOEITEMTemp(preAuditIds)
	s Job=$J
	s TotalAmt=0
	s j=1
	while(j<=$l(preAuditIds,",")){
		s preAuditId=$p(preAuditIds,",",j)
		s j=j+1
		continue:preAuditId=""
		s TotalAmt=TotalAmt+$P(^DHCPEPreA(preAuditId),"^",9)
	}
	s TotalAmt=$FN(TotalAmt,"",2)
	s PreItemID=""
  	f  s PreItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID)) q:PreItemID=""  d //,"TARITEM",itmsub)
	.s OneAmount=0
	.s TARITEMSub=""
	.f  s TARITEMSub=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID,"TARITEM",TARITEMSub)) q:TARITEMSub=""  d
	..s Info=$G(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID,"TARITEM",TARITEMSub))
	..b ;Info
	..s TARITEMID=$P(Info,"^",1)
	..s OneAmount=+$P(Info,"^",4)
	..s OneAmount=$FN(OneAmount,"",2)
	..i $D(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID,"SetsName")) d
	...s Desc="丙 "_$G(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID,"SetsName"))
	...s Uom=""
	...s Qty=1
	...s ItemSort="1"
	..e  d
	...s YBCode=##class(web.DHCPE.Cashier).GetYBCode(TARITEMID)
	...s Desc=YBCode_" "_$p($g(^DHCTARI(TARITEMID)),"^",2)
	...s Uom=##class(web.DHCPE.Cashier).GetUomByTarItem(TARITEMID)
	...s Qty=$g(^DHCPEDataEx("DHCPEPreIOrdItem","Qty",PreItemID))
	...s ItemSort="2"
	..s ^TempDHCPEListInfo(Job,ItemSort,Desc,"OneAmt",OneAmount)=""
	..s ^TempDHCPEListInfo(Job,ItemSort,Desc,"Amt",OneAmount)=$G(^TempDHCPEListInfo(Job,ItemSort,Desc,"Amt",OneAmount))+OneAmount
	..s ^TempDHCPEListInfo(Job,ItemSort,Desc,"Qty",OneAmount)=$G(^TempDHCPEListInfo(Job,ItemSort,Desc,"Qty",OneAmount))+Qty
	..s ^TempDHCPEListInfo(Job,ItemSort,Desc,"Uom")=Uom
	b ;001
	s RoundFeeFlag=0
	s:$D(^DHCPEOEITEMTemp(preAuditIds,"RoundInfo")) RoundFeeFlag=1
	k ^DHCPEOEITEMTemp(preAuditIds)
	k ^DHCPEOEITEMAccAccTemp(preAuditIds)
	
	s col=$g(^DHCPESetting("DHCPE","InvCol")) ;发票明细打印列数
	if col="" s col=1
	s invcolSet=^DHCPESetting("DHCPE","InvColSortType") ;发票明细显示顺序
	if invcolSet="" s invcolSet=1
	s InvNameMaxLen=+$g(^DHCPESetting("DHCPE","InvNameMaxLen"))
	
	s ItemInfos=""
	s listcount=0
	s Sort=""
	f  s Sort=$O(^TempDHCPEListInfo(Job,Sort)) q:Sort=""  d
	.s ItemName=""
	.f  s ItemName=$O(^TempDHCPEListInfo(Job,Sort,ItemName)) q:ItemName=""  d
	..s OneAmt=""
	..f  s OneAmt=$O(^TempDHCPEListInfo(Job,Sort,ItemName,"OneAmt",OneAmt)) q:OneAmt=""  d
	...i InvNameMaxLen>0 s ItemName=$e(ItemName,1,InvNameMaxLen)
	...s ItemQty=$G(^TempDHCPEListInfo(Job,Sort,ItemName,"Qty",OneAmt))
	...s ItemAmount=$G(^TempDHCPEListInfo(Job,Sort,ItemName,"Amt",OneAmt))
	...s ItemPrice=ItemAmount/ItemQty
	...s UOM=$G(^TempDHCPEListInfo(Job,Sort,ItemName,"Uom"))
	...i (listcount#col)=0  d
	....i ItemInfos'="" s ItemInfos=ItemInfos_$c(2)
	...e  d
	....i ItemInfos'="" s ItemInfos=ItemInfos_"^"
	...s ItemPrice=$FN(ItemPrice,"",2)
	...s ItemAmount=$FN(ItemAmount,"",2)
	...i RoundFeeFlag=1 d
	....s ItemPrice=TotalAmt
	....s ItemAmount=TotalAmt
	...//费用明细单上金额右对齐 start
	...i $L(ItemPrice)<9 d
	....s ItemPrice=$E("         "," ",8-$L(ItemPrice))_ItemPrice
	...i $L(ItemAmount)<9 d
	....s ItemAmount=$E("         "," ",8-$L(ItemAmount))_ItemAmount
	...//费用明细单上金额右对齐 end
	...i invcolSet=1 s ItemInfos=ItemInfos_ItemName_"^"_ItemPrice_"^"_ItemQty_"^"_ItemAmount
	...i invcolSet=2 s ItemInfos=ItemInfos_ItemName_"^"_UOM_"^"_ItemQty_"^"_ItemAmount
	...i invcolSet=3 s ItemInfos=ItemInfos_ItemName_"^"_UOM_"^"_ItemQty_"^"_ItemPrice_"^"_ItemAmount
	...s listcount=listcount+1
	s TotalAmt="合计:"_TotalAmt
	s ItemInfos=ItemInfos_$c(2)_"___________________________________________^^"_TotalAmt_"^^"
	s ItemInfos=ItemInfos_$c(2)_"^"_"[甲:无自付,已:有自付,丙:全自付]"_"^^^"
	s ItemInfos=ItemInfos_$c(2)_"[限北京医保标示]^^^^"
	i ItemInfos'=""
	{
		s j=(listcount#col)
		for k=1:1:j s ItemInfos=ItemInfos_"^^^^"
	}
		
	k ^TempDHCPEListInfo(Job)
	q ItemInfos
}

/// w ##class(web.DHCPE.CashierEx).GetTextInfo("101802,101904")
ClassMethod GetTextInfo(preAuditIds)
{
	s ^DHCXPTest("PE","PreFeeText")=preAuditIds
	s PaySum=0
	s j=1
	while(j<=$l(preAuditIds,",")){
		s preAuditId=$p(preAuditIds,",",j)
		s j=j+1
		continue:preAuditId=""
		s PaySum=PaySum+$P(^DHCPEPreA(preAuditId),"^",9)
	}
	s OneID=+preAuditIds
	s NoPayed=""
	s PayedFlag=$P(^DHCPEPreA(OneID),"^",14)
	s:PayedFlag="UNCHARGED" NoPayed="未结算"
	
	s InvNo=""
	S PAPBRowId=$O(^DHCPEPAPBR(0,"PADR",OneID,0)) 
	I PAPBRowId'="" d
	.s PBID=$p($g(^DHCPEPAPBR(PAPBRowId)),"^",2)
	.i PBID'="" s InvID=$o(^DHCPEINVPRT(0,"PB",PBID,0))
	.i InvID'="" s InvNo=$p($g(^DHCPEINVPRT(InvID)),"^",1)
	
	;RegNo  PatName PaySum  Date
	s CRMID=$P(^DHCPEPreA(OneID),"^",2)
	s Type=$P(^DHCPEPreA(OneID),"^",1)
	i Type="I" d
	.s BaseID=$P(^DHCPEPreIADM(CRMID),"^",1)
	.s RegNo=$P(^DHCPEPreIBI(BaseID),"^",1)
	.s PatName=$P(^DHCPEPreIBI(BaseID),"^",2)
	e  d
	.s BaseID=$P(^DHCPEPreGADM(CRMID),"^",1)
	.s RegNo=$P(^DHCPEPreGBI(BaseID),"^",13)
	.s PatName=$P(^DHCPEPreGBI(BaseID),"^",2)
	s c=$c(2)
	s PatNameHead=$e(PatName,1,10)
	s PatNameExt=$e(PatName,11,$l(PatName))
	s HospitalName=$g(^DHCPESetting("DHCPE","HospitalName"))
	s Info="RegNo"_c_RegNo_"^PatName"_c_PatNameHead_"^PatNameExt"_c_PatNameExt_"^Date"_c_$ZD($H,3)_"^PaySum"_c_PaySum_"^NoPayed"_c_NoPayed_"^InvNo"_c_InvNo_"^HospitalName"_c_HospitalName

	q Info
}

// 0:不打印发票，不走发票号

// 1:打印发票，走发票号

ClassMethod NeedPrintInv(PaymodeStr)
{
	;s ret=##class(web.DHCPE.CashierEx).NeedPrintInv("&673.00&21^^^^^200&1^^^^^473#")
	s InvFlag=0
	s DHCPayMode=""
	s PayModeLength=$L(PaymodeStr,"&")
	b ;PayModeLength
	f i=3:1:PayModeLength  d
	.s OnePayMode=$P(PaymodeStr,"&",i)
	.s PayMode=+OnePayMode
	.s PayCode=$P(^CT("CTPM",PayMode),"^",1)
	.b ;PayCode
	.i '(PayCode[("TJ")) s InvFlag=1
	.s:(PayCode[("TJ")) DHCPayMode=PayCode
	q InvFlag_"^"_DHCPayMode
}

ClassMethod GetInvAmountInfo(InvID)
{
	;w ##class(web.DHCPE.CashierEx).GetInvAmountInfo(370)
	s Amt=0
	s ModeStr=""
	s ArrcpID=$P(^DHCPEINVPRT(InvID),"^",4)
	s PayModeSub=0
	f  s PayModeSub=$O(^ARRCP(ArrcpID,"PAYM",PayModeSub)) q:PayModeSub=""  d
	.s PayModeID=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",1)
	.s Flag=..NeedPrintInv("&&"_PayModeID)
	.s:+Flag=0 NoPrintFlag=1
	.q:+Flag=0
	.s PrintFlag=1
	.s PayDesc=$P(^CT("CTPM",PayModeID),"^",2)
	.s ChequeNo=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",4)
	.s OneAmt=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",3)
	.s Amt=Amt+OneAmt
	.s OneInfo=PayDesc_":"_$J(OneAmt,"",2)
	.;i ChequeNo'="" d
	.;.s OneInfo=OneInfo_"("_ChequeNo_")"
	.i ModeStr="" d
	..s ModeStr=OneInfo
	.e  d
	..s ModeStr=ModeStr_" "_OneInfo
	s Amt=$J(Amt,"",2)
	q Amt_"^"_ModeStr
}

ClassMethod GetDropPaymodeInfo(PayModeInfo, RefInvID)
{
	;w ##class(web.DHCPE.CashierEx).GetDropPaymodeInfo(PayModeInfo,RefInvID)
	s PayedModeLength=$l(PayModeInfo,"^")
	f i=1:1:PayedModeLength  d
	.s OneInfo=$p(PayModeInfo,"^",i)
	.s OnePayMode=$p(OneInfo,",",1)
	.s NewPayMode=$p(OneInfo,",",5)
	
	.s OnePayModeCode="",NewPayModeCode=""
	.i OnePayMode'="" s OnePayModeCode=$p($g(^CT("CTPM",OnePayMode)),"^",1)
	.i NewPayMode'="" s NewPayModeCode=$p($g(^CT("CTPM",NewPayMode)),"^",1)
	.s ssrAmont=##class(web.DHCPE.Cashier).GetssrAmountByInv(RefInvID)
	.i (OnePayModeCode="CASH")&&(NewPayModeCode'="CASH")&&(ssrAmont'=0) d
	..s $p(OneInfo,",",2)=$p(OneInfo,",",2)-ssrAmont

	.s NewNo=$P(OneInfo,",",3)
	.s OtherNo=..GetOldOtherNo(RefInvID,OnePayMode)
	.s:NewNo="" $P(OneInfo,",",3)=OtherNo
	.s:NewPayMode'="" $P(OneInfo,",",1)=NewPayMode
	.s $P(PayModeInfo,"^",i)=OneInfo
	q PayModeInfo
}

/*
ClassMethod GetDropPaymodeInfo(PayModeInfo, RefInvID)
{
	;w ##class(web.DHCPE.CashierEx).GetDropPaymodeInfo(PayModeInfo,RefInvID)
	s PayedModeLength=$l(PayModeInfo,"^")
	f i=1:1:PayedModeLength  d
	.s OneInfo=$p(PayModeInfo,"^",i)
	.s OnePayMode=$p(OneInfo,",",1)
	.s OtherNo=..GetOldOtherNo(RefInvID,OnePayMode)
	.s $P(OneInfo,",",3)=OtherNo
	.s $P(PayModeInfo,"^",i)=OneInfo
	q PayModeInfo
}
*/
ClassMethod GetOldOtherNo(RefInvID, PayMode)
{
	s ArrcpID=$P(^DHCPEINVPRT(RefInvID),"^",4)
	s OtherNo=""
	s PayModeSub=0
	f  s PayModeSub=$O(^ARRCP(ArrcpID,"PAYM",PayModeSub)) q:(PayModeSub="")||(OtherNo'="")  d
	.s PayModeID=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",1)
	.i PayModeID=PayMode d
	..s OtherNo=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",4)
	q OtherNo
}

ClassMethod UpdatePayModeAmtByRefInv(RefInvID, UserID As %String = "")
{
	;w ##class(web.DHCPE.CashierEx).UpdatePayModeAmtByRefInv(370)
	s errs=""
	s ArrcpID=$P(^DHCPEINVPRT(RefInvID),"^",4)
	s BillId=$P(^DHCPEINVPRT(RefInvID),"^",3)
	s AdmId=$P(^DHCPEINVPRT(RefInvID),"^",2)
	s PayModeSub=0
	f  s PayModeSub=$O(^ARRCP(ArrcpID,"PAYM",PayModeSub)) q:(PayModeSub="")||(errs'="")  d
	.s PayModeID=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",1)
	.s PayModeCode=$P(^CT("CTPM",PayModeID),"^",1)
	.s ChequeNo=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",4)
	.s OneAmt=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",3)
	.i PayModeCode="TJYJJ" d
	..s APID=##class(web.DHCPE.AdvancePayment).GetUseID(AdmId,PayModeCode,"N")
	..s:APID="" errs="预交金帐户不存在"
	..q:APID=""
	..;s strings=APID_"^"_(OneAmt)_"^"_RefInvID_"^^"
	..s strings=APID_"^"_(-OneAmt)_"^"_RefInvID_"^^"
	..s errs=##class(web.DHCPE.AdvancePayment).InsertAPAC(strings,"CF")
	.i PayModeCode="TJDJK" d
	..s APID=##class(web.DHCPE.AdvancePayment).GetUseID(ChequeNo,PayModeCode,"N")
	..s:APID="" errs="储值卡帐户不存在"
	..q:APID=""
	..;s strings=APID_"^"_(OneAmt)_"^"_RefInvID_"^^"
	..s strings=APID_"^"_(-OneAmt)_"^"_RefInvID_"^^"
	..s errs=##class(web.DHCPE.AdvancePayment).InsertAPAC(strings,"CF")
	.i (PayModeCode="TJGBK")||(PayModeCode="TJZKK") d
	..s APID=##class(web.DHCPE.AdvancePayment).GetUseID(AdmId,PayModeCode,"F")
	..s:APID="" errs="没有可使用帐户"
	..q:APID=""
	..s strings=APID_"^N^退费产生,退费发票号^"_RefInvID
	..s errs=##class(web.DHCPE.AdvancePayment).UpdateData("3",strings)
	..if $p(errs,"^",1)'="0" d
	...s errs="修改卡状态错误"
	..e  d
	...s errs=""
	.i PayModeCode="CPP" d
	..s papmi=$P(^PAADM(AdmId),"^",1)
	..s CardNo=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",20) ;账户ID
	..s errs=##class(web.DHCPE.DHCQseXmComm).ReduDepos(UserID,papmi,CardNo,OneAmt)
	..s:+errs=0 errs=""

	q errs
}

ClassMethod UpdatePayModeAmtByInv(InvID, UserID As %String = "")
{
	;w ##class(web.DHCPE.CashierEx).UpdatePayModeAmt(370)
	s errs=""
	s ArrcpID=$P(^DHCPEINVPRT(InvID),"^",4)
	s BillId=$P(^DHCPEINVPRT(InvID),"^",3)
	s AdmId=$P(^DHCPEINVPRT(InvID),"^",2)
	s PayModeSub=0
	f  s PayModeSub=$O(^ARRCP(ArrcpID,"PAYM",PayModeSub)) q:(PayModeSub="")||(errs'="")  d
	.s PayModeID=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",1)
	.s PayModeCode=$P(^CT("CTPM",PayModeID),"^",1)
	.s ChequeNo=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",4)
	.s OneAmt=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",3)
	.i PayModeCode="TJYJJ" d
	..s APID=##class(web.DHCPE.AdvancePayment).GetUseID(AdmId,PayModeCode,"N")
	..s strings=APID_"^"_(-OneAmt)_"^"_BillId_"^^"
	..s errs=##class(web.DHCPE.AdvancePayment).InsertAPAC(strings,"C")
	.i PayModeCode="TJDJK" d
	..s APID=##class(web.DHCPE.AdvancePayment).GetUseID(ChequeNo,PayModeCode,"N")
	..s strings=APID_"^"_(-OneAmt)_"^"_BillId_"^^"
	..s errs=##class(web.DHCPE.AdvancePayment).InsertAPAC(strings,"C")
	.i (PayModeCode="TJGBK")||(PayModeCode="TJZKK") d
	..s APID=##class(web.DHCPE.AdvancePayment).GetUseID(AdmId,PayModeCode,"N")
	..s strings=APID_"^F^收费产生,账单号为^"_BillId
	..s errs=##class(web.DHCPE.AdvancePayment).UpdateData("3",strings)
	..if $p(errs,"^",1)'="0" d
	...s errs="修改卡状态错误"
	..e  d
	...s errs=""
	.i PayModeCode="CPP" d
	..s papmi=$P(^PAADM(AdmId),"^",1)
	..s CardNo=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",20)  ;账户ID
	..s errs=##class(web.DHCPE.DHCQseXmComm).ReduDepos(UserID,papmi,CardNo,OneAmt)
	..s:+errs=0 errs=""
	q errs
}

// 得到默认计费项对应的分类金额

// 不打印分类明细时，打印设置的医嘱名称

ClassMethod GetFeeCatInfo(Amount)
{
	s c=$C(2)
	s LocID=%session.Get("LOGON.CTLOCID")
	
	/*
	s TARITEMID=$G(^DHCPESetting("DHCPE","SetsDefaultTar",LocID))
	s OneInfo=##class(web.DHCPE.Cashier).GetTarOC(TARITEMID,"N")
	s TarOCID=$P(OneInfo,"^",1)
	s TarOCDesc=$P(OneInfo,"^",2)
	*/
	s InvFeeID=$G(^DHCPESetting("DHCPE","Group'sOEArcItemId"))
	s OneTar=..GetOneTarItem(InvFeeID)
	s OneInfo=##class(web.DHCPE.Cashier).GetTarOC(OneTar,"N")
	s TarOCID=$P(OneInfo,"^",1)
	s TarOCDesc=$P(OneInfo,"^",2)
	
	s Fee=$FN(Amount,"",2)
	s i=1
	;发票xml中没写明分类标签名称，只是写了标签
	s CatRtn="^"_"Fee"_i_c_Fee_"^"_"FeeLab"_i_c_TarOCDesc
	;发票xml中写明分类标签名称，Setting里面设置了数据对应的标签名称
	;s LabelName=$G(^DHCPESetting("DHCPE","InvFeeCat",TarOCID))
	;s CatRtn="^"_LabelName_c_Fee
	
	q CatRtn
}

// 得到医嘱项对应的收费项

// w ##class(web.DHCPE.CashierEx).GetOneTarItem("4||1")

ClassMethod GetOneTarItem(arcitmid)
{
	s retStr=""
	s TarItem=0
	f  s TarItem=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem)) q:TarItem=""  d
	.s StartDate=0
	.f  s StartDate=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate)) q:(StartDate="")||(StartDate>+$H)  d
	..s OLTID=0
	..f  s OLTID=$o(^DHCOLT(0,"ARTTA",arcitmid,TarItem,StartDate,OLTID)) q:OLTID=""  d
	...s EndDate=$p(^DHCOLT(OLTID),"^",5)
	...q:(EndDate'="")&&(EndDate<+$H)
	...s retStr=TarItem
	q retStr
}

// w ##class(web.DHCPE.CashierEx).GetTarItemCount(101911)

ClassMethod GetTarItemCount(preAuditIds)
{
	s Job=$J
	k ^TempDHCPEListInfo(Job)
	
	s PreItemID=""
  	f  s PreItemID=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID)) q:PreItemID=""  d //,"TARITEM",itmsub)
	.s TARITEMSub=""
	.f  s TARITEMSub=$O(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID,"TARITEM",TARITEMSub)) q:TARITEMSub=""  d
	..s Info=$G(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID,"TARITEM",TARITEMSub))
	..s TARITEMID=$P(Info,"^",1)
	..i $D(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID,"SetsName")) d
	...s Desc="丙 "_$G(^DHCPEOEITEMTemp(preAuditIds,"OEITEM",PreItemID,"SetsName"))
	...s ItemSort="1"
	..e  d
	...s YBCode=##class(web.DHCPE.Cashier).GetYBCode(TARITEMID)
	...s Desc=YBCode_" "_$p($g(^DHCTARI(TARITEMID)),"^",2)
	...s ItemSort="2"
	..s ^TempDHCPEListInfo(Job,ItemSort,Desc)=""
	.b ;003
	
	s listcount=0
	s Sort=""
	f  s Sort=$O(^TempDHCPEListInfo(Job,Sort)) q:Sort=""  d
	.s ItemName=""
	.f  s ItemName=$O(^TempDHCPEListInfo(Job,Sort,ItemName)) q:ItemName=""  d
	..s listcount=listcount+1
		
	k ^TempDHCPEListInfo(Job)
	
	q listcount
}

ClassMethod OutRoundType(ContrlWidth As %String = "")
{
	;d ##class(web.DHCPE.CashierEx).OutRoundType(125)
	s:(""=ContrlWidth) ContrlWidth="125"
	w "<select name='RoundType' id='RoundType' style='width:"_ContrlWidth_"' HEIGHT=0>",!
	w "<option value='1'>"_..GetRoundTypeDesc(1)_"</option>",!
	w "<option value='2'>"_..GetRoundTypeDesc(2)_"</option>",!
	w "<option value='3'>"_..GetRoundTypeDesc(3)_"</option>",!
	w "<option value='4'>"_..GetRoundTypeDesc(4)_"</option>",!
	w "</select>",!
}

ClassMethod GetRoundTypeDesc(RoundType)
{
	q:RoundType="1" "定额卡"
	q:RoundType="2" "西院交费"
	q:RoundType="3" "换套餐补费"
	q:RoundType="4" "其他"
	q ""
}

ClassMethod GetRoundFee(InvID)
{
	q:InvID="" ""
	s FH=1
	s RefInvID=$P(^DHCPEINVPRT(InvID),"^",9)
	i RefInvID'="" d
	.s FH=-1
	.s InvID=RefInvID
	s RetInfo=""
	s PreItemID=""
	f  s PreItemID=$O(^DHCPEOEITEM(InvID,"RoundInfo",PreItemID)) q:PreItemID=""  d
	.s OneInfo=$G(^DHCPEOEITEM(InvID,"RoundInfo",PreItemID))
	.s RoundType=$P(OneInfo,"^",1)
	.s RoundType=..GetRoundTypeDesc(RoundType)
	.s RoundRemak=$P(OneInfo,"^",2)
	.s RoundFee=$P(OneInfo,"^",3)
	.i RetInfo="" d
	..s RetInfo=RoundType_"^"_RoundRemak_"^"_RoundFee
	.e  d
	..s RetInfo=RetInfo_"$$"_RoundType_"^"_RoundRemak_"^"_RoundFee
	q RetInfo
}

// w ##class(web.DHCPE.CashierEx).GetProveInfo(731)

ClassMethod GetProveInfo(InvID)
{
	//基本信息
	s FocusPrintID=$o(^User.DHCPEINVFocusPrtI("IFPINVDRIndex"," "_InvID,""))
	s invNo=$p($g(^DHCPEINVPRT(InvID)),"^",1)
	i FocusPrintID'="" d
	.s invNo=$LG(^User.DHCPEINVFocusPrtD(FocusPrintID),3)
	
	s invdate=$p($g(^DHCPEINVPRT(InvID)),"^",11)
	//真实打印日期
	i FocusPrintID'="" d
	.s invdate=$LG(^User.DHCPEINVFocusPrtD(FocusPrintID),5)
	s invdate=$zd(invdate,3)
	
	s invtime=$p($g(^DHCPEINVPRT(InvID)),"^",12)
	i FocusPrintID'="" d
	.s invtime=$LG(^User.DHCPEINVFocusPrtD(FocusPrintID),6)
	s invtime=$zt(invtime,3)
	s AdmID=$p($g(^DHCPEINVPRT(InvID)),"^",2)
	s patid=$p($g(^PAADM(AdmID)),"^",1)
	if patid="" q rtn
	s patname=$p($g(^PAPER(patid,"ALL")),"^",1)
	s InvExInfo=##class(web.DHCPE.CashierEx).GetInvAmountInfo(InvID)
	s InvAmt=$P(InvExInfo,"^",1)
	s AmtTotal=$p($g(^DHCPEINVPRT(InvID)),"^",7)
	s AmtTotal=$FN(AmtTotal,"",2)
	s hzamount=##Class(web.DHCPE.DHCPEPAY).RMBDXXZH("","",InvAmt,"2")
	s BaseInfo=patname_"^"_invNo_"^"_invdate_" "_invtime_"^"_AmtTotal_"^"_InvAmt_"^"_hzamount_"^"_$ZD(+$H,3)
	//分类信息
	i +InvAmt=+AmtTotal d
	.s PayModeExStr=""
	e  d
	.s PayModeExStr=$P(InvExInfo,"^",2)
	i $G(^DHCPESetting("DHCPE","InvPrintCatInfo"))="Y"  d
	.i PayModeExStr="" d
	..s CatInfo=..GetFeeCatDataInfo(InvID)
	.e  d
	..s CatInfo="体检费^"_InvAmt
	else  d
	.s CatInfo="体检费^"_InvAmt
	//收费项明细
	s ListFlag=^DHCPESetting("DHCPE","InvListFlag")
	s FeeItemInfo=##class(web.DHCPE.Cashier).GetInvoiceListInfo("I",InvID,ListFlag,0)
	q BaseInfo_$C(3)_CatInfo_$C(3)_FeeItemInfo
}

ClassMethod GetFeeCatDataInfo(invid)
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
	..s OneInfo=##class(web.DHCPE.Cashier).GetTarOC(TARITEMID)
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
	.i CatRtn="" d
	..s CatRtn=Desc_"^"_Fee
	.e  d
	..s CatRtn=CatRtn_c_Desc_"^"_Fee
	k ^TempDHCPECatInfo(Job)
	q CatRtn
}

// w ##class(web.DHCPE.CashierEx).GetInvUserNum(3881)

ClassMethod GetInvUserNum(userId)
{
	s invnum=$i(^DHCIPBill("InvNum","OPBill",+$h))
	s numLength=$L(invnum)
	s invnum=$E("00000",1,5-numLength)_invnum
	s invnum=$E($ZD(+$H,8),3,8)_invnum
	s HospYBCode=$G(^DHCPESetting("DHCPE","HospYBCode"))
	s invnum=HospYBCode_invnum
	q invnum
}

ClassMethod DeleteRoundFee(preAuditIds)
{
	s ret=""
	s j=1
	while(j<=$l(preAuditIds,",")){
		s preAuditId=$p(preAuditIds,",",j)
		s j=j+1
		continue:preAuditId=""
		s preAdmId=0
		f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:((preAdmId="")||(ret'=""))  d
		.q:'$D(^DHCPEDataEx("InsertRoundFee",preAdmId))
		.s childsub=0
		.f  s childsub=$O(^DHCPEDataEx("InsertRoundFee",preAdmId,childsub)) q:childsub=""  d
		..s PreItemID=preAdmId_"||"_childsub
		..s ret=##class(web.DHCPE.PreItemList).IDeleteItem(preAdmId,"PERSON",PreItemID,"")
		..q:ret'=""
		..k ^DHCPEDataEx("InsertRoundFee",preAdmId,childsub)
	}
	q ret
}

// 多个支付方式时用$c(2)隔(格式：支付方式表指针^支付金额^银行表指针(CMC_BankMas)^支票号^银行卡类型指针(ARC_BankCardType)^合同单指针^支票日期^支票对方账户号码^账户支付明细表指针)

ClassMethod GetPayInfoByInvID(PEInvID)
{
	s ret=""
	s ARRCPID=$P(^DHCPEINVPRT(PEInvID),"^",4)
	q:ARRCPID="" ret
	s PAYMSub=0
	f  s PAYMSub=$O(^ARRCP(ARRCPID,"PAYM",PAYMSub)) q:PAYMSub=""  d
	.s PayMode=$P(^ARRCP(ARRCPID,"PAYM",PAYMSub),"^",1)
	.s Amt=$P(^ARRCP(ARRCPID,"PAYM",PAYMSub),"^",3)
	.s BankID=$P(^ARRCP(ARRCPID,"PAYM",PAYMSub),"^",2)
	.s ChequeNo=$P(^ARRCP(ARRCPID,"PAYM",PAYMSub),"^",4)
	.s OneInfo=PayMode_"^"_Amt_"^"_BankID_"^"_ChequeNo
	.i ret="" d
	..s ret=OneInfo
	.e  d
	..s ret=ret_$C(2)_OneInfo
	q ret
}

ClassMethod InsertOPInv(PEInvID, groupID As %String = "", locID As %String = "")
{
	//w ##class(web.DHCPE.CashierEx).InsertOPInv(88)
	;ISaveInv(papmi, billStr, payInfo, receipNO, instype, sFlag, oldInvDr, prtDate, prtTime, expStr)
	s $ZT="InsertOPInvErr"
	q:$G(^DHCPESetting("DHCPE","InsertOPInv"))'="Y" 0
	s paadm=$P(^DHCPEINVPRT(PEInvID),"^",2)
	s papmi=$P(^PAADM(paadm),"^",1)
	s billStr=$P(^DHCPEINVPRT(PEInvID),"^",3)
	//多个支付方式时用$c(2)隔(格式：支付方式表指针^支付金额^银行表指针(CMC_BankMas)^支票号^银行卡类型指针(ARC_BankCardType)^合同单指针^支票日期^支票对方账户号码^账户支付明细表指针)
	s payInfo=..GetPayInfoByInvID(PEInvID)
	s receipNO=$P(^DHCPEINVPRT(PEInvID),"^",1)
	s:receipNO[("DHC") receipNO=""
	s instype=$P(^PAADM(paadm,1),"^",7)
	s oldInvDr=$P(^DHCPEINVPRT(PEInvID),"^",9)
	i oldInvDr="" d
	.s sFlag="0"  ;收费  1退费
	e  d
	.s sFlag="1"
	s prtDate=$P(^DHCPEINVPRT(PEInvID),"^",11)
	s prtTime=$P(^DHCPEINVPRT(PEInvID),"^",12)
	s:groupID="" groupID=%session.Get("LOGON.LANGID")
	s:locID="" locID=%session.Get("LOGON.CTLOCID")
	s accID=""
	s runInvNo="N"
	s feeType="H"
	s userID=$P(^DHCPEINVPRT(PEInvID),"^",10)
	s hospitalID=$P(^CTLOC(locID),"^",22)
	s ip=""
	i oldInvDr=""  ;收费
	{
		//安全组^登录科室^账户rowid^是否走发票(Y:走发票，N:不走发票)^费用类型(F:收费,R:过号,H:体检)
		//^预收额^找零^分币误差^收费员^医院指针^收费员电脑IP地址
	
		s expStr=groupID_"^"_locID_"^"_accID_"^"_runInvNo_"^"_feeType
		s expStr=expStr_"^"_""_"^"_""_"^"_""_"^"_userID_"^"_hospitalID_"^"_ip
		s ret=##class(web.DHCOPBillPhysicalInv).ISaveInv(papmi,billStr,payInfo,receipNO,instype,sFlag,oldInvDr,prtDate,prtTime,expStr)
	}
	else ;退费
	{
		//expStr:安全组^登录科室^收费员^医院指针^IP地址
		s expStr=groupID_"^"_locID_"^"_userID_"^"_hospitalID_"^"_ip
		s OPOldInvID=$G(^DHCPEDataEx("DHCPEINVPRT","H2O",oldInvDr))  ;找出原来门诊收据id
		q:OPOldInvID="" 0
		s invFlag="A"
		s ret=##class(web.DHCOPBillPhysicalInv).IRefundInv(OPOldInvID,billStr,invFlag,payInfo,receipNO,prtDate,prtTime,expStr)
	}
	i +ret=0{
		s OPInvID=$P(ret,"^",2)
		s ^DHCPEDataEx("DHCPEINVPRT","H2O",PEInvID)=OPInvID
		s ^DHCPEDataEx("DHCPEINVPRT","O2H",OPInvID)=PEInvID
	}
	q +ret
InsertOPInvErr
	q 0
}

ClassMethod UpdatePayMode(InvID, PaymodeInfo)
{
	;s ret=##class(web.DHCPE.CashierEx).UpdatePayMode(InvID,PaymodeInfo)
	s SQLCODE=0
	s ArrcpID=$P(^DHCPEINVPRT(InvID),"^",4)
	s i=0
	s PayModeSub=0
	f  s PayModeSub=$O(^ARRCP(ArrcpID,"PAYM",PayModeSub)) q:(PayModeSub="")||(SQLCODE'=0)  d
	.s PayModeID=$P(^ARRCP(ArrcpID,"PAYM",PayModeSub),"^",1)
	.s i=i+1
	.s OneInfo=$P(PaymodeInfo,"^",i)
	.s NewPayMode=$P(OneInfo,",",5)
	.i (NewPayMode'="")&&(NewPayMode'=PayModeID) d
	..s PAYMRowID=ArrcpID_"||"_PayModeSub
	..&SQL(Update Sqluser.ar_rcptpaymode set PAYM_PayMode_DR=:NewPayMode where PAYM_RowId=:PAYMRowID)
	q SQLCODE
}

ClassMethod ReCalAmt(GADM)
{
	q:GADM="" 0
	s GADM=$P(^DHCPEGADM(GADM),"^",2)
	q ##class(web.DHCPE.PreIADM).UpdateGroupAuditAmount(GADM,1)
}

// d ##class(web.DHCPE.CashierEx).DailyReport(1,"")

// 门诊日结调用结算方法

ClassMethod DailyReport(UserID, HospitalID)
{
	s $ZT="DailyReportErr"
	s ret=##class(web.DHCPE.DHCPEUSERREPORT).FootPDbyUser(UserID,"","") 
	i +ret>0 q "0^"_ret
	q "-1^"
DailyReportErr
	q "-1^"
}

// d ##class(web.DHCPE.CashierEx).GetTarItemInfoByInvID(11047222)

// 根据门诊发票id，存对应的收费项明细

ClassMethod GetTarItemInfoByInvID(InvID)
{
	s $ZT="GetTarItemErr"
	q:InvID="" "-1^发票为空"
	q:$D(^DHCPEDataEx("MZInvID",InvID)) ""
	s HPInvNo=$G(^DHCPEDataEx("DHCPEINVPRT","O2H",InvID))
	q:HPInvNo="" "-1^非体检发票"
	s OldInvID=$P(^DHCPEINVPRT(HPInvNo),"^",9)
	s FH=1
	i OldInvID'="" d
	.s HPInvNo=OldInvID
	.s FH=-1

	s Sort=0
	s PreItemID=""
	f  s PreItemID=$O(^DHCPEOEITEM(HPInvNo,"OEITEM",PreItemID)) q:PreItemID=""  d
	.s TARITEMSub=""
	.f  s TARITEMSub=$O(^DHCPEOEITEM(HPInvNo,"OEITEM",PreItemID,"TARITEM",TARITEMSub)) q:TARITEMSub=""  d
	..s Info=$G(^DHCPEOEITEM(HPInvNo,"OEITEM",PreItemID,"TARITEM",TARITEMSub))
	..s TARITEMID=$P(Info,"^",1)
	..s Qty=$P(Info,"^",3)
	..s Price=$P(Info,"^",2)*FH
	..s Price=$FN(Price,"",2)
	..s Amount=$P(Info,"^",4)*FH
	..s Amount=$FN(Amount,"",2)
	..s Sort=Sort+1
	..s ^DHCPEDataEx("MZInvID",InvID,Sort)=TARITEMID_"^"_Qty_"^"_Price_"^"_Amount
	q 0
	//s ^DHCPEDataEx("MZInvID",InvID,Sort)="收费项ID^收费项数量^收费项单价^总金额"
GetTarItemErr
	q "-1^发生异常"
}

/// Creator: xueying
/// CreateDate: 2018-03-29
/// Descript: 判断体检代金卡、预交金的余额和账户是否存在
/// w ##class(web.DHCPE.CashierEx).JudgeTJKRemainAmount()
ClassMethod JudgeTJKRemainAmount(AdmId, OneAmt, PayModeID, No, OldPayModeID)
{
	
	s errs=""
	s PayModeCode=""
	if (OldPayModeID'=PayModeID){
	i PayModeID'="" s PayModeCode=$p($g(^CT("CTPM",PayModeID)),"^",1)
	i PayModeCode="TJYJJ" d
	.s APID=##class(web.DHCPE.AdvancePayment).GetUseID(AdmId,PayModeCode,"N")
	..s:APID="" errs="预交金帐户不存在"
	i PayModeCode="TJDJK" d
	.s:No="" errs="没有输入代金卡号"
	.q:No=""
	.s APID=##class(web.DHCPE.AdvancePayment).GetUseID(No,PayModeCode,"N")
	.s:APID="" errs="储值卡帐户不存在"
	.q:APID=""
	.s errs=##class(web.DHCPE.AdvancePayment).JudgeUse(No,OneAmt,PayModeCode)
	}
	Q errs
}

Storage Default
{
<Data name="CashierExDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.CashierExD</DataLocation>
<DefaultData>CashierExDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.CashierExD</IdLocation>
<IndexLocation>^web.DHCPE.CashierExI</IndexLocation>
<StreamLocation>^web.DHCPE.CashierExS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
