Import SQLUser

Class web.DHCPE.AdvancePayment Extends %Persistent [ ClassType = "", Not ProcedureBlock ]
{

// Type:1  Insert

// 	   2  InsertAmount

// 	   3  UpdateStatus

// w ##class(web.DHCPE.AdvancePayment).UpdateData(1,"^00000007^^R^^N^^^^232^&12212^0000033^1")

ClassMethod UpdateData(Type, Strings, UserID As %String = "", CurLocID As %String = "", HospitalID As %String = "")
{
	s Date=+$H
	s Time=$P($H,",",2)
	i $D(%session) d
	.s User=%session.Get("LOGON.USERID")
	.s HospitalID=%session.Get("LOGON.HOSPID")
	e  d
	.s User=UserID
	.s HospitalID=HospitalID
	s Err=""
	s RowID=""
	s SQLCODE=0
	TSTART
	i Type=1 d Insert
	i Type=2 d InsertAmount(Strings,"R")
	i Type=3 d InsertStatus(Strings,"0")
	i Err'=""
	{
		TROLLBACK
		q Err_"^"_SQLCODE
	}
	TCOMMIT
	q 0_"^"_RowID
Insert
	s FeeStrings=$p(Strings,"&",2,3)
	s Strings=$p(Strings,"&",1)
	s i=$l(Strings,"^")
	for j=1:1:i  d
	.s PLIST(j)=$P(Strings,"^",j)
	k PLIST(1)
	s PLIST(7)=+$H
	s PLIST(8)=$p($H,",",2)
	s PLIST(9)=User
	s PLIST(5)=+PLIST(5)
	s PLIST(14)=HospitalID
	i $D(%session) d
	.s PLIST(12)=%session.Get("LOGON.CTLOCID")
	e  d
	.s PLIST(12)=CurLocID
	&SQL(Insert into DHC_PE_AdvancePayment values :PLIST())
	i SQLCODE
	{
		s Err="插入预缴金记录失败"_SQLCODE
		q	
	}
	s RowID=%ROWID
	i +FeeStrings'=0 d InsertAmount(RowID_"^"_FeeStrings,"B")
	i PLIST(4)'="R" d InsertStatus(RowID_"^"_PLIST(6)_"^新建卡","1")
	q
InsertAmount(AStrings,AType)
	s Err=..InsertAPAC(AStrings,AType,User,CurLocID,"N",HospitalID)
	
	q
InsertStatus(Strings,AType)
	s ParRef=$p(Strings,"^",1)
	s Status=$P($G(^DHCPEAP(ParRef)),"^",5)
	s MStatus=$p(Strings,"^",2)
	if AType="0"
	{
		i (Status=MStatus)
		{
			s Err="状态没有改变,不需要更新"
			q
		}
	}
	i Status="A"
	{
		s RegNo=$p($G(^DHCPEAP(ParRef)),"^",1)
		s TType=$p($G(^DHCPEAP(ParRef)),"^",3)
		s RowID=..GetRowIDByRegNo(RegNo,TType)
		i (RowID'="")&&(RowID'=ParRef)
		{
			s Err="此人存在正常状态的卡,不能再修改为正常状态"
			q
		}
	}
	i MStatus="A"
	{
		s Fee=$p($G(^DHCPEAP(ParRef)),"^",4)
		i +Fee'=0
		{
			s Err="卡内有钱,不能作废"
			q
		}
	}
	s Remark=$p(Strings,"^",3)
	s AP1=$p(Strings,"^",4)
	s SCPLIST(0)=ParRef
	s SCPLIST(3)=MStatus
	s SCPLIST(4)=Date
	s SCPLIST(5)=Time
	s SCPLIST(6)=User
	s SCPLIST(7)=Remark
	s SCPLIST(8)=AP1  //账单RowID
	&SQL(Insert Into DHC_PE_APStatusChange values :SCPLIST())
	i SQLCODE
	{
		s Err="插入预缴金状态变动表错误"
		q	
	}
	s RowID=%ROWID
	&SQL(Update DHC_PE_AdvancePayment Set AP_Status=:MStatus where AP_RowID=:ParRef)
	i SQLCODE
	{
		s Err="更新预缴金状态错误"
		q
	}
	q
Err
	TROLLBACK
	q Err
}

ClassMethod InsertAPAC(AStrings, AType, UserID As %String = "", CurLocID As %String = "", ReportFlag As %String = "N", HospitalID As %String = "")
{
	s Date=+$H
	s Time=$P($H,",",2)
	i $D(%session) d
	.s User=%session.Get("LOGON.USERID")
	.s LocID=%session.Get("LOGON.CTLOCID")
	.S HospitalID=%session.Get("LOGON.HOSPID")
	e  d
	.s User=UserID
	.s LocID=CurLocID
	.S HospitalID=HospitalID
	s ParRef=$p(AStrings,"^",1)
	s Status=$P(^DHCPEAP(ParRef),"^",5)
	s Type=$P(^DHCPEAP(ParRef),"^",3)
	i Type="C"
	{
		s Info=$p(AStrings,"&",2)
		s:Info'="" ^DHCPEDataEx("DHCPEAD","Info",ParRef)=Info
	}
	i Status="A"
	{
		q "作废状态不能充值"
		
	}
	

	s Fee=$p(AStrings,"^",2)
	s InvID=$p(AStrings,"^",3)
	s CardInfo=($p($p(AStrings,"&",1),"^",8)) 
	s AStrings=$p(AStrings,"&",1)
	s PayMode=$p(AStrings,"^",4)
	s Remark=$p(AStrings,"^",5)
	s Amount=$P(^DHCPEAP(ParRef),"^",4)
	s NotPrintFlag=$p(AStrings,"^",6)
	i AType="R" s Remark=$p(AStrings,"^",9)
	
	s title=""
	i ((AType="B")||(AType="R")) {
	s title=$P(##class(web.DHCPE.DHCPEPAY).getcurinvno(User),"^",3)
	s InvID=title_""_InvID
	}

	i ((AType="B")||(AType="R"))&&(NotPrintFlag="N")
	{
		s curInvNo=##class(web.DHCPE.DHCPEPAY).getcurinvno(User)
		if InvID'=$p(curInvNo,"^",1)
		{
			q InvID_"传入发票号不正确,请刷新后重试!"_curInvNo
			
		}
	}
	s PADM=$p(AStrings,"^",7)
	s Amount=+Amount+Fee
	&SQL(Update DHC_PE_AdvancePayment Set AP_Amount=:Amount where AP_RowID=:ParRef)
	i AType="R" d
	.&SQL(Update DHC_PE_AdvancePayment Set AP_Remark=:Remark where AP_RowID=:ParRef)

	i SQLCODE
	{
		q "更新预缴金金额错误"
		
	}
	s ACPLIST(0)=ParRef
	s ACPLIST(3)=AType
	s ACPLIST(4)=Fee
	s ACPLIST(5)=Amount
	s ACPLIST(6)=InvID
	//s ACPLIST(6)=title_InvID
	s ACPLIST(7)=Date
	s ACPLIST(8)=Time
	s ACPLIST(9)=User
	s ACPLIST(10)=Remark
	s ACPLIST(12)=PayMode
	s ACPLIST(13)=ReportFlag
	i NotPrintFlag="Y" d
	.;s ACPLIST(13)="Y"
	.s ACPLIST(6)=""
	s ACPLIST(14)=LocID
	s ACPLIST(15)="N"
	s ACPLIST(17)=HospitalID
	&SQL(Insert Into DHC_PE_APAmountChange values :ACPLIST())
	i SQLCODE
	{
		q "插入预缴金金额变动表错误"	
	}
	s APRowID=%ROWID
	i (Type="C") s ^DHCPEDataEx("DHCPEAD","InvID",APRowID)=Info
	
	i PADM'="" d
	.s ^DHCPEDataEx("DHCPEPreIADM","Amount",PADM,APRowID)=""
	.s ^DHCPEDataEx("DHCPEPreIADM","Amount",APRowID,PADM)=""
	S ^DHCPEDataEx("DHCPEAD","paymode",APRowID)=CardInfo 
	q:NotPrintFlag="Y" ""
	i (AType="B")||(AType="R")
	{
		s SQLCODE=..UpdateInv(User)
		i SQLCODE'=0
		{
			q "更新发票错误"
		}
	}
	q ""
}

ClassMethod Refund(AStrings)
{
	s Err=""
	s OldRowID=$p(AStrings,"^",1)
	s ID=..HadRefund(OldRowID)
	q:ID'="" "记录已经退费"
	s LFee=$P(^DHCPEAP(+OldRowID),"^",4)
	s RFee=$p(AStrings,"^",2)
	s OInvID=$p(AStrings,"^",3)
	s PayMode=$p(AStrings,"^",4)
	s Remark=$p(AStrings,"^",5)
	q:LFee<RFee "退费金额大于剩余金额"
	s OldFee=$P(^DHCPEAP(+OldRowID,"AC",$P(OldRowID,"||",2)),"^",2)
	s RRFee=0
	i OldFee>RFee s RRFee=OldFee-RFee
	TSTART
	s InStrings=+OldRowID_"^"_(-OldFee)_"^"_OldRowID_"^"_PayMode_"^"_Remark
	
	s Err=..InsertAPAC(InStrings,"RF")
	i Err'=""
	{
		TROLLBACK
		q Err
	}
	s NInv=""
	
	i RRFee>0
	{
		s InStrings=+OldRowID_"^"_RRFee_"^"_OInvID_"^"_PayMode_"^"_Remark
		s RInvID=$P(^DHCPEAP(+OldRowID,"AC",$P(OldRowID,"||",2)),"^",11)
		s patStr=$G(^DHCPEDataEx("DHCPEAD","InvID",OldRowID))
	
		s InStrings=InStrings_"&"_patStr
		s Err=..InsertAPAC(InStrings,"R")
		s NInv=InvID
	}
	i Err'=""
	{
		TROLLBACK
		q Err
	}
	TCOMMIT
	q 0_"^"_NInv
}

ClassMethod MoveAmount(SourceID, ToID, Amount)
{
	s SourceAmount=$P($g(^DHCPEAP(SourceID)),"^",4)
	i Amount>SourceAmount q "-1^转移金额不能大于剩余金额"_SourceAmount
	TSTART
	s APAmount=$P($g(^DHCPEAP(SourceID)),"^",4)
	S APSAmount=APAmount-Amount
	;&SQL(Update DHC_PE_AdvancePayment set AP_Amount=AP_Amount-:Amount where AP_RowID=:SourceID)
	&SQL(Update DHC_PE_AdvancePayment set AP_Amount=:APSAmount where AP_RowID=:SourceID)
	i SQLCODE'=0{
		TROLLBACK
		q "-1^更新源金额错误"
	}
	s APAmount=$P($g(^DHCPEAP(ToID)),"^",4)
	S APTAmount=APAmount+Amount
	;&SQL(Update DHC_PE_AdvancePayment set AP_Amount=AP_Amount+:Amount where AP_RowID=:ToID)
	&SQL(Update DHC_PE_AdvancePayment set AP_Amount=:APTAmount where AP_RowID=:ToID)
	i SQLCODE'=0{
		TROLLBACK
		q "-1^更新目标金额错误"
	}
	s PLIST(0)=SourceID
	s PLIST(3)="O" ;转出
	s PLIST(4)=-Amount
	s PLIST(5)=$P($g(^DHCPEAP(SourceID)),"^",4)
	;APACSourceNo
	s PLIST(7)=+$H
	s PLIST(8)=$P($H,",",2)
	s PLIST(9)=%session.Get("LOGON.USERID")
	s PLIST(15)="N"
	&sql(Insert into DHC_PE_APAmountChange values :PLIST())
	i SQLCODE'=0{
		TROLLBACK
		q "-1^插入转出明细错误"
	}
	s DRowID=%ROWID
	s PLIST(0)=ToID
	s PLIST(3)="I" ;转入
	s PLIST(4)=Amount
	s PLIST(5)=$P(^DHCPEAP(ToID),"^",4)
	s PLIST(6)=DRowID
	s PLIST(15)="N"
	&sql(Insert into DHC_PE_APAmountChange values :PLIST())
	i SQLCODE'=0{
		TROLLBACK
		q "-1^插入转入明细错误"
	}
	
	k PLIST
	s PLIST(6)=%ROWID
	&sql(Update DHC_PE_APAmountChange values :PLIST() where APAC_RowID=:DRowID)
	i SQLCODE'=0{
		TROLLBACK
		q "-1^更新转出明细错误"
	}
	
	TCOMMIT
	q "0^更新完成"
}

ClassMethod HadRefund(OldRowID)
{
	s ID=$O(^DHCPEAP(0,"SourceNo","RF",OldRowID,0))
	q ID
}

ClassMethod GetData(RowID)
{
	q $G(^DHCPEAP(RowID))
}

// w ##class(web.DHCPE.AdvancePayment).GetPatientInfo(6789,"C")

ClassMethod GetPatientInfo(RegNo, Type)
{
	i Type'="C"
	{
		s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
		s ID=$O(^PAPERi("PAPMI_PatNo",RegNo,0))
		q:ID="" ""
		s Name=$P(^PAPER(ID,"ALL"),"^",1)
		s DOB=$P(^PAPER(ID,"ALL"),"^",6)
		//s DOB=$p(##class(web.DHCLCNUREXCUTE).CalAge(DOB,+$h),"Y",1)
		s DOB=##class(web.DHCBillInterface).GetPapmiAge(ID)
		s Sex=$P(^PAPER(ID,"ALL"),"^",7)
		i Sex'="" s Sex=$p($g(^CT("SEX",Sex)),"^",2)
		s RowID=..GetRowIDByRegNo(RegNo,Type)
		s CardNo=""
		i $G(^DHCPESetting("DHCPE","CardRelate"))="Yes" d
		.s CardNo=##class(web.DHCPE.PreIBIUpdate).GetRelate(RegNo, "R")
		q RegNo_"^"_Name_"^"_DOB_"^"_Sex_"^"_CardNo_"^"_RowID
	}
	else
	{
		s RowID=..GetRowIDByRegNo(RegNo,Type)
		q:RowID="" ""
		s RegNo=""
		s Name=$p($G(^DHCPEDataEx("DHCPEAD","Info",RowID)),"^",1)
		s Sex=$p($G(^DHCPEDataEx("DHCPEAD","Info",RowID)),"^",2)
		s DOB=$p($G(^DHCPEDataEx("DHCPEAD","Info",RowID)),"^",3)
		s CardNo=""
		q RegNo_"^"_Name_"^"_DOB_"^"_Sex_"^"_CardNo_"^"_RowID
	}
}

// w ##class(web.DHCPE.AdvancePayment).GetRowIDByRegNo("7","R")

ClassMethod GetRowIDByRegNo(RegNo, Type As %String = "R")
{
	;n (RegNo,Type)
	s (NRowID,LRowID,FRowID,RowID)=""
	i Type'="C"
	{
		s ID=0
		f  s ID=$O(^DHCPEAP(0,"RegNo",RegNo,ID)) q:(ID="")  d
		.q:1=##class(web.DHCPE.AdvancePayment).IsCurLocCard(ID)
		.s TType=$p($G(^DHCPEAP(ID)),"^",3)
		.q:TType'=Type
		.s Status=$p($G(^DHCPEAP(ID)),"^",5)
		.s:Status="N" NRowID=ID
		.s:Status="L" LRowID=ID
		.s:Status="F" FRowID=ID
		i NRowID'="" s RowID=NRowID
		q:RowID'="" RowID
		i LRowID'="" s RowID=LRowID
		q:RowID'="" RowID
		i FRowID'="" s RowID=FRowID
		q RowID
	}
	else
	{
		s ID=0
		f  s ID=$O(^DHCPEAP(0,"CardNo",RegNo,ID)) q:(ID="")  d
		.q:1=##class(web.DHCPE.AdvancePayment).IsCurLocCard(ID)
		.s TType=$p($G(^DHCPEAP(ID)),"^",3)
		.q:TType'=Type
		.s Status=$p($G(^DHCPEAP(ID)),"^",5)
		.s:Status="N" NRowID=ID
		.s:Status="L" LRowID=ID
		.s:Status="F" FRowID=ID
		i NRowID'="" s RowID=NRowID
		q:RowID'="" RowID
		i LRowID'="" s RowID=LRowID
		q:RowID'="" RowID
		i FRowID'="" s RowID=FRowID
		q RowID
	}
}

// d ##class(web.DHCPE.AdvancePayment).StatusOutToHtml()

ClassMethod StatusOutToHtml(name, width As %String = 130, Code)
{
	;;下拉列表
	s (NStr,AStr,LStr,FStr)=">"
	s:Code="N" NStr=" selected>"
	s:Code="A" AStr=" selected>"
	s:Code="L" LStr=" selected>"
	s:Code="F" FStr=" selected>"
	w "<select name='"_name_"' id='"_name_"' style='width:"_width_"' HEIGHT=0 >"
	w !,"<option value=>"_..GetStatusDesc("")_"</option>"
	w !,"<option value=N"_NStr_..GetStatusDesc("N")_"</option>"
	w !,"<option value=A"_AStr_..GetStatusDesc("A")_"</option>"
	w !,"<option value=L"_LStr_..GetStatusDesc("L")_"</option>"
	w !,"<option value=F"_FStr_..GetStatusDesc("F")_"</option>"
	w !,"</select>",!
}

ClassMethod GetStatusDesc(Code)
{
	s Desc=""
	S:Code="N" Desc="正常"
	S:Code="A" Desc="作废"
	S:Code="L" Desc="挂失"
	S:Code="F" Desc="冻结"
	q Desc
}

// d ##class(web.DHCPE.AdvancePayment).TypeOutToHtml()

ClassMethod TypeOutToHtml(name, width As %String = 130, Code)
{
	;;下拉列表
	s (BStr,RStr,RFStr,OStr,IStr,CStr,CFStr)=">"
	s:Code="B" BStr=" selected>"
	s:Code="R" RStr=" selected>"
	s:Code="RF" RFStr=" selected>"
	s:Code="O" OStr=" selected>"
	s:Code="I" IStr=" selected>"
	s:Code="C" CStr=" selected>"
	s:Code="CF" CFStr=" selected>"
	w "<select name='"_name_"' id='"_name_"' style='width:"_width_"' HEIGHT=0 >"
	w !,"<option value=>"_..GetTypeDesc("")_"</option>"
	w !,"<option value=B"_BStr_..GetTypeDesc("B")_"</option>"
	w !,"<option value=R"_RStr_..GetTypeDesc("R")_"</option>"
	w !,"<option value=RF"_RFStr_..GetTypeDesc("RF")_"</option>"
	w !,"<option value=O"_OStr_..GetTypeDesc("O")_"</option>"
	w !,"<option value=I"_IStr_..GetTypeDesc("I")_"</option>"
	w !,"<option value=C"_CStr_..GetTypeDesc("C")_"</option>"
	w !,"<option value=CF"_CFStr_..GetTypeDesc("CF")_"</option>"
	w !,"</select>",!
}

ClassMethod GetTypeDesc(Code)
{
	s Desc=""
	S:Code="B" Desc="开户"
	S:Code="R" Desc="交预缴金"
	S:Code="RF" Desc="退预缴金"
	S:Code="O" Desc="转出"
	S:Code="I" Desc="转入"
	S:Code="C" Desc="结算"
	S:Code="CF" Desc="结算退费"
	q Desc
}

// d ##class(web.DHCPE.AdvancePayment).PayModeOutToHtml()

ClassMethod PayModeOutToHtml(name, width As %String = 130)
{
	s:(""=width) width="130"
	w "<select name='"_name_"' id='"_name_"' style='width:"_width_"' HEIGHT=0 >"
	s id=0
	f  s id=$O(^CT("CTPM",id)) q:id=""  d
	.q:$g(^DHCPESetting("DHCPE","CardMode",id))'="Y"
	.s Str=">"
	.i id=$G(^DHCPESetting("DHCPE","InvDefaultPayMode")) d

	..s Str=" selected>"
	.w "<option value="_id_Str_$P($G(^CT("CTPM",id)),"^",2)_"</option>",!
		
	w "</select>",!
	Quit $$$OK
}

// d ##class(web.DHCPE.AdvancePayment).CardTypeOutToHtml()

ClassMethod CardTypeOutToHtml(name, width As %String = 130, Code, Type As %String = "1")
{
	;;下拉列表
	s (BStr,RStr,RFStr,OStr,IStr,CStr,CFStr)=">"
	//s:Code="R" RStr=" selected>"
	//s:Code="I" IStr=" selected>"
	//s:Code="O" OStr=" selected>"
	s:Code="C" CStr=" selected>"
	w "<select name='"_name_"' id='"_name_"' style='width:"_width_"' HEIGHT=0 >"
	w:Type="1" !,"<option value=>"_..GetCardTypeDesc("")_"</option>"
	//w:Type="1" !,"<option value=I"_IStr_..GetCardTypeDesc("I")_"</option>"
	//w:Type="1" !,"<option value=O"_OStr_..GetCardTypeDesc("O")_"</option>"
	w !,"<option value=C"_CStr_..GetCardTypeDesc("C")_"</option>"
	//w !,"<option value=R"_RStr_..GetCardTypeDesc("R")_"</option>"
	w !,"</select>",!
}

ClassMethod GetCardTypeDesc(Code)
{
	s Desc=""
	S:Code="R" Desc="预缴金"
	S:Code="I" Desc="贵宾卡"
	S:Code="O" Desc="折扣卡"
	S:Code="C" Desc="代金卡"
	q Desc
}

// d ##class(web.DHCPE.AdvancePayment).UpdateInv(3774)

// 走发票号

ClassMethod UpdateInv(UserID)
{
	n (UserID)
	s finalflag=##Class(web.DHCPE.DHCPEPAY).GetFinalFlag()
	s tmpno=##Class(web.DHCPE.DHCPEPAY).getcurinvno(UserID)
	s invno=$p(tmpno,"^",1)
	s rid=$p(tmpno,"^",2)
	i invno="" q "null"
	///注释掉一句?下面的去掉一个.
	//i invflag="Y" d
	i invno'="" d
	.s err=##CLASS(web.UDHCJFINV).SELECT(rid),endinv=+PLIST(3)
	.;&sql(select inv_endinv into:endinv from DHC_INVOICE where inv_rowid=:rid)
	.s tmpinvno=+invno
	.i tmpinvno=endinv d      ;如果是最后一张领取的发票??标记为已用完
	..;b
	..s err=##Class(web.DHCPE.DHCPEPAY).invrefund(rid,invno,UserID)
	..s err=err+SQLCODE
	..;&sql(update DHC_INVOICE set inv_lastnum=:invno,inv_finalflag="N" where inv_rowid=:rid)
	.i +invno<endinv d
	..i finalflag="Y" s lastnum=##Class(web.DHCPE.DHCPEPAY).incre(invno)
	..e  s lastnum=invno
	..&sql(update DHC_INVOICE set inv_lastnum=:lastnum where inv_rowid=:rid)   
	..s err=err+SQLCODE
	///End
	
	q:err'=0 "SQLErr"
	q 0
}

// w ##class(web.DHCPE.AdvancePayment).GetInvoiceInfo("0000039","1")

// 得到发票信息

ClassMethod GetInvoiceInfo(InvID, Type, InvName As %String = "")
{
	s Info=""
	s APID=$O(^DHCPEAP(0,"SourceNo","B",InvID,0))
	i APID="" d
	.s APID=0
	.s APID=$O(^DHCPEAP(0,"SourceNo","R",InvID,0))
	.q:APID=""
	.s Sub=0
	.s Sub=$O(^DHCPEAP(0,"SourceNo","R",InvID,APID,0))
	e  d
	.s Sub=$O(^DHCPEAP(0,"SourceNo","B",InvID,APID,0))
	q:APID="" Info
	s Fee=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",2)
	s RegNo=$p($G(^DHCPEAP(APID)),"^",1)
	s (defaultfeeid,defaultfeename)=""
	i $D(^DHCPEDataEx("AdvancePayment","InvName",InvID)) d
	.s InvName=^DHCPEDataEx("AdvancePayment","InvName",InvID)
	e  d
	.s:InvName'="" ^DHCPEDataEx("AdvancePayment","InvName",InvID)=InvName

	d ##class(web.DHCPE.Cashier).GetDefaultFee(.defaultfeeid,.defaultfeename)
	if Type=2
	{   
		s invcolSet=^DHCPESetting("DHCPE","InvColSortType")
		s Fee=$j(Fee,3,2)
		//s Info=defaultfeename_"^"_Fee_"^1^"_Fee_"^^^^"
		i invcolSet=1 s Info=defaultfeename_"^"_Fee_"^"_1_"^"_Fee
		i invcolSet=2 s Info=defaultfeename_"^"_"次"_"^"_1_"^"_Fee
		i invcolSet=3 s Info=defaultfeename_"^"_"次"_"^"_1_"^"_Fee_"^"_Fee
	
	}
	
	else
	{  
		//发票号
		s InvNo=InvID
		//发票人
		s username=""
		s userno=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",7)
		if userno'=""   d
		.s username=$p($g(^SSU("SSUSR",userno)),"^",2)
		.s userno=$p($g(^SSU("SSUSR",userno)),"^",1)
		//发票日期
		s invdate=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",5)
		i invdate'="" s invdate=$zd(invdate,3)
		//金额大写
		s hzamount=##Class(web.DHCPE.DHCPEPAY).RMBDXXZH("","",Fee)
		//金额
		s amount=$j(Fee,3,2)
		//支付方式
	
		s paymode="" 
		s paymode=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",10)
		i paymode'="" s paymode=$p($g(^CT("CTPM",paymode)),"^",2)
		//基本信息
		
		s AType=$p($G(^DHCPEAP(APID)),"^",3)
		
		i RegNo'=""
		{  
			s patid=$O(^PAPERi("PAPMI_PatNo",RegNo,0))
			s patname=$p($g(^PAPER(patid,"ALL")),"^",1)
		
			s age=""
			s sex=""
			s pattype=""
			s compony=""
			s sex=$p($g(^PAPER(patid,"ALL")),"^",7)
			if sex'="" s sex=$p($g(^CT("SEX",sex)),"^",2)
			s dob=$p($g(^PAPER(patid,"ALL")),"^",6)
			if dob'=""
		
			{
					
				s dob=$zd(dob,3)
				s age=$p($zd(+$h,3),"-",1)-$p(dob,"-",1)
			}
			s pattype=$p($g(^PAPER(patid,"PER",5)),"^",1)
			i pattype'="" s pattype=$P($G(^CT("SS",pattype)),"^",2)
		}
		else
		{
			s patid=""
			s patStr=$G(^DHCPEDataEx("DHCPEAD","InvID",APID_"||"_Sub))
			s patname=$p(patStr,"^",1)
			s age=$p(patStr,"^",3)
			s sex=$p(patStr,"^",2)
			s pattype=""
			s compony=""
			
		}
		//$p($G(^DHCACD("AccM",+DepositID,"AccPD",$p(DepositID,"||",2))),"^",3)\
		s:InvName'="" patname=InvName
		s c=$c(2)
		s rtn="PatName"_c_patname        
		s rtn=rtn_"^"_"RegNo"_c_RegNo
		s rtn=rtn_"^"_"PAAdm"_c_"" //patid     //
		
		s rtn=rtn_"^"_"FB1"_c_defaultfeename
		s rtn=rtn_"^"_"FBSum1"_c_amount
		
		s rtn=rtn_"^"_"PaySumAll"_c_hzamount_" "_amount
		s rtn=rtn_"^"_"PaySumPY"_c_hzamount
		s rtn=rtn_"^"_"PaySum"_c_amount
		s rtn=rtn_"^"_"PayMode"_c_paymode
		
		s rtn=rtn_"^"_"OpenID"_c_userno    
		s rtn=rtn_"^"_"OpenName"_c_username  
		s rtn=rtn_"^"_"InvNo"_c_InvNo
		
		s rtn=rtn_"^"_"Date"_c_invdate
		s rtn=rtn_"^"_"Year"_c_$p(invdate,"-",1)
		s rtn=rtn_"^"_"Month"_c_$p(invdate,"-",2)
		s rtn=rtn_"^"_"Day"_c_$p(invdate,"-",3)
		
		s rtn=rtn_"^"_"Sex"_c_sex  //
		s rtn=rtn_"^"_"Age"_c_age  //
		s rtn=rtn_"^"_"Type"_c_pattype  //
		s rtn=rtn_"^"_"Company"_c_compony  //
	
		///s rtn=patname_"^"_regno_"^"_amount_"^"_hzamount_"^"_invdate_"^"_userno
		s Info=rtn
	}
	q Info
}

// 判断帐户是否可用

// ##class(web.DHCPE.AdvancePayment).JudgeUse(AdmID,Amount)

ClassMethod JudgeUse(AdmID, Amount, PayCode As %Library.String = "TJYJJ")
{
	s APRowID=..GetUseID(AdmID,PayCode)
	
	q:APRowID="" "没有可以使用帐户"
	i (PayCode="TJYJJ")||(PayCode="TJDJK")
	{
		s CAmount=$P(^DHCPEAP(APRowID),"^",4)
		q:(+CAmount)<(+Amount) "帐户金额不足:"_CAmount
	}
	q 0
}

// 得到帐户余额

ClassMethod GetAPAmount(PayModeID, ExpStr)
{
	//w ##class(web.DHCPE.AdvancePayment).GetAPAmount(PayModeID,ExpStr)
	s Type=$P(PayModeID,"^",2)
	s PayModeID=$P(PayModeID,"^",1)
	//s Type=$P(^CT("CTPM",PayModeID),"^",2)
	i Type'="" d
	.s:Type="C" PayCode="TJDJK"
	.s:Type="R" PayCode="TJYJJ"
	.s:Type="I" PayCode="TJGBK"
	.s:Type="O" PayCode="TJZKK"
	e  d
	.s PayCode=$P(^CT("CTPM",PayModeID),"^",1)
	i PayCode="TJDJK"
	{
		s APRowID=..GetUseID(ExpStr,PayCode)
		q:APRowID="" "没有可以使用帐户"
		s CAmount=$P(^DHCPEAP(APRowID),"^",4)
		s CAmount=$FN(CAmount,"",2)
		q CAmount
	}
	q ""
}

/// 得到卡号对应的信息
ClassMethod GetAPCompanyName(PayModeID, CardNO)
{
	//w ##class(web.DHCPE.AdvancePayment).GetAPCompanyName("21","000001650217")
	s rtn=""
	s PayCode=$P(^CT("CTPM",PayModeID),"^",1)
	i PayCode="TJYJJ" s PayCode="TJDJK"
	i PayCode="TJDJK"
	{
		s APRowID=..GetUseID(CardNO,PayCode)
		q:APRowID="" "没有可以使用帐户^^^^^"
		s CompanyName=$p($G(^DHCPEDataEx("DHCPEAD","Info",APRowID)),"^",1)
		s rtn=CompanyName_"^^^^^"
		q rtn
	}
	q "^^^^^"
}

// w ##class(web.DHCPE.AdvancePayment).GetUseID(108886,"TJGBK","F")

ClassMethod GetUseID(AdmID, PayCode As %Library.String = "TJYJJ", vStatus As %String = "N")
{
	s:PayCode="TJYJJ" Type="R"
	s:PayCode="TJZKK" Type="O"
	s:PayCode="TJGBK" Type="I"
	s:PayCode="TJDJK" Type="C"
	s APRowID=""
	s APID=0
	i Type'="C"
	{
		s PID=$P(^PAADM(AdmID),"^",1)
		s RegNo=$P(^PAPER(PID,"PAT",1),"^",1)	
		f  s APID=$O(^DHCPEAP(0,"RegNo",RegNo,APID)) q:(APID="")||(APRowID'="")  d
		.;q:1=##class(web.DHCPE.AdvancePayment).IsCurLocCard(APID)
		.s TType=$P(^DHCPEAP(APID),"^",3)
		.q:TType'=Type
		.s Status=$P(^DHCPEAP(APID),"^",5)
		.q:Status'=vStatus
		.s APRowID=APID
	}
	else
	{
		f  s APID=$O(^DHCPEAP(0,"CardNo",AdmID,APID)) q:(APID="")||(APRowID'="")  d
		.;q:1=##class(web.DHCPE.AdvancePayment).IsCurLocCard(APID)
		.s TType=$P(^DHCPEAP(APID),"^",3)
		.q:TType'=Type
		.s Status=$P(^DHCPEAP(APID),"^",5)
		.q:Status'=vStatus
		.s APRowID=APID
	}
	q APRowID
}

ClassMethod GetDataByInv(InvID)
{
	s APID=0
	s Type="B"
	s APID=$O(^DHCPEAP(0,"SourceNo","B",InvID,APID))
	i APID="" d
	.s APID=0
	.s Type="R"
	.s APID=$O(^DHCPEAP(0,"SourceNo","R",InvID,APID))
	q:APID="" "对应的发票不存在"
	s Sub=$O(^DHCPEAP(0,"SourceNo",Type,InvID,APID,0))
	s RowID=APID_"||"_Sub
	s RAPID=$O(^DHCPEAP(0,"SourceNo","RF",RowID,0))
	q:RAPID'="" "发票已经退费"
	s RegNo=$p($G(^DHCPEAP(APID)),"^",1)
	i RegNo'=""
	{
		s ID=$O(^PAPERi("PAPMI_PatNo",RegNo,0))
		s Name=$P(^PAPER(ID,"ALL"),"^",1)
	}
	else
	{
		s patStr=$G(^DHCPEDataEx("DHCPEAD","InvID",RowID))
		s Name=$p(patStr,"^",1)
	}
	s ReminAmount=$p($G(^DHCPEAP(APID)),"^",4)
	s Amount=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",2)
	s PayMode=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",10)
	s Remark=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",8)
	s InvName=""
	s:InvID'="" InvName=$G(^DHCPEDataEx("AdvancePayment","InvName",InvID))
	q "0^"_RowID_"^"_RegNo_"^"_Name_"^"_Amount_"^"_PayMode_"^"_Remark_"^"_ReminAmount_"^"_InvName
}

// q:1=##class(web.DHCPE.AdvancePayment).IsCurLocCard(APID)

ClassMethod IsCurLocCard(APID)
{
	s OldLOc=$P(^DHCPEAP(APID),"^",11)
	q:OldLOc'=%session.Get("LOGON.CTLOCID") 1
	q 0
}

ClassMethod GetInfoByNo(No, Type)
{
	s ret=""
	s Info=..GetPatientInfo(No, Type)
	;q RegNo_"^"_Name_"^"_DOB_"^"_Sex_"^"_CardNo_"^"_RowID
	s BaseInfo=$P(Info,"^",2)_" "_$P(Info,"^",4)
	i Type="R" d
	.s ret=$P(Info,"^",1)_"^"_BaseInfo
	e  d 
	.s ret=$P(Info,"^",5)_"^"_BaseInfo
	s ID=$P(Info,"^",6)
	s ret=ret_"^"_ID
	q:ID="" "-1^"_ret
	s CardInfo=..GetData(ID)
	s Amount=$P(CardInfo,"^",4)
	s Status=$P(CardInfo,"^",5)
	s Status=..GetStatusDesc(Status)
	s ret=ret_"^"_Status_"^"_Amount_"^"_No
	;0^RegNo^Info^ID^Status^Amount
	q "0^"_ret
}

ClassMethod UpdatePayMode(ACID, PayMode)
{
	q:ACID="" "-1^原记录不能为空"
	q:PayMode="" "-1^修改为的支付方式不能为空"
	s ReportID=$P(^DHCPEAP(+ACID,"AC",$P(ACID,"||",2)),"^",9)
	q:ReportID'="" "-1^已经结算，不能修改"
	&SQL(Update Sqluser.DHC_PE_APAmountChange set APAC_PayMode_DR=:PayMode where APAC_RowID=:ACID)
	q SQLCODE_"^更新错误"_SQLCODE
}

ClassMethod GetInfo(RowID)
{
	s APID=$p(RowID,"||",1)
	s Sub=$p(RowID,"||",2)
	s RAPID=$O(^DHCPEAP(0,"SourceNo","RF",RowID,0))
	q:RAPID'="" "发票已经退费"
	s RegNo=$p($G(^DHCPEAP(APID)),"^",1)
	i RegNo'=""
	{
		s ID=$O(^PAPERi("PAPMI_PatNo",RegNo,0))
		s Name=$P(^PAPER(ID,"ALL"),"^",1)
	}
	else
	{
		s patStr=$G(^DHCPEDataEx("DHCPEAD","InvID",RowID))
		s Name=$p(patStr,"^",1)
	}
	s ReminAmount=$p($G(^DHCPEAP(APID)),"^",4)
	s Amount=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",2)
	s SourceNo=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",4)
	s PayMode=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",10)
	s Remark=$p($G(^DHCPEAP(APID,"AC",Sub)),"^",8)
	q "0^"_RowID_"^"_RegNo_"^"_Name_"^"_Amount_"^"_PayMode_"^"_Remark_"^"_ReminAmount_"^"_SourceNo
}

}
