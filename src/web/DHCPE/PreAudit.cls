Class web.DHCPE.PreAudit Extends (%Library.RegisteredObject, websys.Abstract) [ ClassType = "", Not ProcedureBlock ]
{

Parameter BUILD = 144;

ClassMethod GetPreAuditInfo(AuditID)
{
	new AInfo
	i AuditID="" q ""
	s AInfo=$g(^DHCPEPreA(AuditID))
	q AInfo
}

ClassMethod UpdatePreAudit(Type, RowId, AInfo)
{
	new PLIST,i,OldPriMode,OldRebate,PriMode,Rebate,Return
	s (OldPriMode,OldRebate,PriMode,Rebate)=""
	s PriModeNew="",SaleAmount=""
	i Type'="Update"
	{
		i Type="Audited" s i=0
		i Type="CancelAudited" s i=4
		s PLIST(11)=Type
		s PLIST(12+i)=%session.Get("LOGON.USERID")
		s PLIST(13+i)=+$H
		s PLIST(14+i)=$p($h,",",2)
	}
	else
	{
		//s OldRebate=$p($G(^DHCPEPreAudit(RowId)),"^",5)
		//s OldPriMode=$p($G(^DHCPEPreAudit(RowId)),"^",19)
		s OldRebate=$p($G(^DHCPEPreA(RowId)),"^",5)
		s OldPriMode=$p($G(^DHCPEPreA(RowId)),"^",19)
		s PLIST(5)=$p(AInfo,"^",1)
		s PLIST(6)=$p(AInfo,"^",2)
		s Rebate=PLIST(6)
		s PLIST(9)=$p(AInfo,"^",3)
		s PLIST(10)=$p(AInfo,"^",4)
		s PLIST(19)=$p(AInfo,"^",5)
		s PriModeNew=$p(AInfo,"^",6)
		s PLIST(20)=$p(AInfo,"^",6)
		i PLIST(20)="OS" s PLIST(20)="OR"
		s PriMode=PLIST(20)
	}
	TSTART
	s SQLCODE=0
	if Type="Update"
	{
		i (PriMode'=OldPriMode)||((PriMode="OR")&&(OldRebate'=Rebate))
		{
			s SQLCODE=..UpdateGItem(RowId,PriMode,Rebate)
			i SQLCODE
			{
				TROLLBACK
				q SQLCODE
			}
			///如果是项目优惠不修改价格
			///s SQLCODE=..UpdateAmount(RowId,PriMode,Rebate)
			i PriMode'="OP" s SQLCODE=..UpdateAmount(RowId,PriMode,Rebate)
		}
		i SQLCODE
		{
			TROLLBACK
			q SQLCODE
		}
		//s PLIST(7)=$p(Return,"^",3)
		//s PLIST(8)=$p(Return,"^",2)
		//i PLIST(8)=0 s PLIST(8)=""
		//i (PriMode'="TP") s PLIST(10)=PLIST(8)
		//i PLIST(7)=PLIST(10) s PLIST(11)="NoAudited"
		//优惠方式为总价优惠或折扣优惠自动设置状态为  审核
		//i (PriMode'="TP"||PriMode'="RP") s PLIST(11)="Audited"
	}
	&SQL(update sqluser.DHC_PE_PreAudit values :PLIST() where PA_RowId=:RowId)
	i SQLCODE
	{
		TROLLBACK
		q SQLCODE
	}
	s AType=$p(^DHCPEPreA(RowId),"^",1)
	s GID=$p(^DHCPEPreA(RowId),"^",2)
	s PGID=$p(^DHCPEPreA(RowId),"^",3)
	
	s CRMTeam=$p(^DHCPEPreA(RowId),"^",22)
	s:CRMTeam="" CRMTeam=RowId
	
	i AType="G"
	{
		i GID="" s GID=$p(^DHCPEGADM(PGID),"^",2)
		s SQLCODE=##class(web.DHCPE.PreIADM).UpdateGroupAuditAmount(GID)
		d ##class(web.DHCPE.GAdmRecordManager).Insert(PGID,"I","TeamDisCount","",CRMTeam)
		d ..UpdateGroupAuditWuCha(GID)
	}
	else
	{
		i GID="" s GID=$p(^DHCPEIADM(PGID),"^",6)
		s SQLCODE=##class(web.DHCPE.PreIADM).UpdatePersonAuditAmount(GID)
		i PriModeNew="OS" d
	.s wucha=0
	.s Oldwucha=0
	.s AuditID=0
	.f  s AuditID=$o(^DHCPEPreA(0,"CRMADM","I",GID,AuditID)) q:(AuditID=""||SQLCODE'=0)  d
	..s mark=$p(^DHCPEPreA(AuditID),"^",20)
	..i mark'="ADD" d
	...s SaleAmount=$p(^DHCPEPreA(AuditID),"^",8)
	...q:SaleAmount=""
	...s FactAmountTotal=$p(^DHCPEPreA(AuditID),"^",9)
	...s wucha=SaleAmount-FactAmountTotal
	..e  d
	...s Oldwucha=$p(^DHCPEPreA(AuditID),"^",9)
	...s wucha=wucha-Oldwucha
	..s UserID=%session.Get("LOGON.USERID")
	..;s ArcCode="PE011"
	..;s ArcimID=$O(^ARCIM(0,"Code",ArcCode,0))
	..;q:ArcimID=""
	..;s ArcimID=ArcimID_"||1"
	..s ArcimID=$G(^DHCPESetting("DHCPE","RoundingFee"))
	..q:ArcimID=""
	..q:UserID=""
	..i wucha'=0 d
	...d ##class(web.DHCPE.PreItemList).IInsertItem(GID,"PERSON","ADD",ArcimID_"&"_wucha_"&4&","",UserID)
	i PriModeNew="NP" d
	.s wucha=0
	.s AuditID=0
	.f  s AuditID=$o(^DHCPEPreA(0,"CRMADM","I",GID,AuditID)) q:(AuditID=""||SQLCODE'=0)  d
	..s mark=$p(^DHCPEPreA(AuditID),"^",20)
	..i mark="ADD" d
	...s wucha=$P(^DHCPEPreA(AuditID),"^",9)
	...s UserID=%session.Get("LOGON.USERID")
	...s ArcCode="PE011"
	...s ArcimID=$O(^ARCIM(0,"Code",ArcCode,0))
	...q:ArcimID=""
	...s ArcimID=ArcimID_"||1"
	...q:UserID=""
	...i wucha'=0 d
	....s wucha=-wucha
	....d ##class(web.DHCPE.PreItemList).IInsertItem(GID,"PERSON","ADD",ArcimID_"&"_wucha_"&4&","",UserID)

				 
	}
	i SQLCODE
	{
		TROLLBACK
		q SQLCODE
	}
	TCOMMIT
	q SQLCODE
}

// d ##class(web.DHCPE.PreAudit).UpdateAmount("1613","OR","80")

/// 修改费用纪录
ClassMethod UpdateAmount(ARowID, PrivilegeMode, Rebate)
{
	new iAdm,tSub,fSub,AccountAmount,FactAmount,fItemId,aType,OldFactAmount
	s SQLCODE=0
	s iAdm=0
	f  s iAdm=$o(^DHCPEPreIADM(0,"PAORDITEM",ARowID,iAdm)) q:(iAdm="")||(SQLCODE'=0)  d
	.s tSub=0
	.f  s tSub=$o(^DHCPEPreIADM(0,"PAORDITEM",ARowID,iAdm,tSub)) q:(tSub="")||(SQLCODE'=0)  d
	..s fSub=0
	..///排除无效的
	..s Flag=$p(^DHCPEPreIADM(iAdm,"ORDITEM",tSub),"^",16)
	..q:Flag'=1
	..s AccountAmount=$p(^DHCPEPreIADM(iAdm,"ORDITEM",tSub),"^",14)
	..s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	..f  s fSub=$o(^DHCPEPreIADM(0,"PAORDITEM",ARowID,iAdm,tSub,fSub)) q:(fSub="")||(SQLCODE'=0)  d
	...s fItemId=iAdm_"||"_tSub_"||"_fSub
	...q:..IsPartIFee(fItemId,ARowID,"ORDITEM")
	...&SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:FactAmount where PIOIF_RowId=:fItemId)
	..q:SQLCODE'=0
	..d ##class(web.DHCPE.TransAdmInfo).UpdateOrdItemPrice(iAdm_"||"_tSub,"OrdItem")
	
	.q:SQLCODE'=0
	.s aType=$p(^DHCPEPreA(ARowID),"^",20)
	.i aType="ADD" d
	..s SQLCODE=..UpdateFeeRecord(iAdm,"Audit")
	
	s iAdm=0
	f  s iAdm=$o(^DHCPEPreIADM(0,"PAORDENT",ARowID,iAdm)) q:(iAdm="")||(SQLCODE'=0)  d
	.s tSub=0
	.f  s tSub=$o(^DHCPEPreIADM(0,"PAORDENT",ARowID,iAdm,tSub)) q:(tSub="")||(SQLCODE'=0)  d
	..s fSub=0
	..///排除无效的
	..s Flag=$p(^DHCPEPreIADM(iAdm,"ORDENT",tSub),"^",9)
	..q:Flag'=1
	..
	..s AccountAmount=$p(^DHCPEPreIADM(iAdm,"ORDENT",tSub),"^",7)
	..s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	..f  s fSub=$o(^DHCPEPreIADM(0,"PAORDENT",ARowID,iAdm,tSub,fSub)) q:(fSub="")||(SQLCODE'=0)  d
	...s fItemId=iAdm_"||"_tSub_"||"_fSub
	...q:..IsPartIFee(fItemId,ARowID,"ORDENT")
	...&SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:FactAmount where PIOEF_RowId=:fItemId)
	..q:SQLCODE'=0
	..d ##class(web.DHCPE.TransAdmInfo).UpdateOrdItemPrice(iAdm_"||"_tSub,"OrdSets")
	.s aType=$p(^DHCPEPreA(ARowID),"^",20)
	.i aType="ADD" d
	..s SQLCODE=..UpdateFeeRecord(iAdm,"Audit")
	
	q SQLCODE
}

ClassMethod IsPartIFee(fId, AuditId, Type)
{
	new Flag,iAdm,tSub,Sub,i
	s iAdm=$p(fId,"||",1)
	s tSub=$p(fId,"||",2)
	s Sub=0
	s i=0
	s AType=$p(^DHCPEPreA(AuditId),"^",1)
	f  s Sub=$o(^DHCPEPreIADM(iAdm,Type,tSub,"Fee",Sub)) q:Sub=""  d
	.s i=i+1
	i (i>1)&&(AType="I") q 1
	q 0
}

/// 修改分组项目
ClassMethod UpdateGItem(ARowID, PrivilegeMode, Rebate)
{
	new Items,GADM,GTSub,Sub,ID,Info,ItemID,AccountAmount,PLIST,FactAmount
	s Items=""
	s GADM=0,Sub=0
	s SQLCODE=0
	f  s GADM=$o(^DHCPEPreGADM(0,"PGTOIPAudit",ARowID,GADM)) q:(GADM=""||SQLCODE'=0)  d
	.s GTSub=0
	.f  s GTSub=$o(^DHCPEPreGADM(0,"PGTOIPAudit",ARowID,GADM,GTSub)) q:(GTSub=""||SQLCODE'=0)  d
	..s Sub=0
	..f  s Sub=$o(^DHCPEPreGADM(0,"PGTOIPAudit",ARowID,GADM,GTSub,Sub)) q:(Sub=""||SQLCODE'=0)  d
	...s ID=GADM_"||"_GTSub_"||"_Sub
	...s Info=$g(^DHCPEPreGADM(GADM,"Team",GTSub,"ORDITEM",Sub))
	...///排除无效
	...s UFlag=$p(Info,"^",13)
	...q:UFlag'=1
	...s ItemID=$p(Info,"^",2)
	...s AccountAmount=$P(Info,"^",11)
	...s PLIST(7)=PrivilegeMode
	...
	...///修改为项目优惠不更新原来价格
	...i PrivilegeMode="OP" d
	....s OldFact=$P(Info,"^",4)
	....s FactAmount=OldFact
	...e  d
	....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	...s PLIST(8)=Rebate
	...s PLIST(6)=FactAmount
	...&SQL(update sqluser.DHC_PE_PreGTOrdItem values :PLIST() where PGTOI_RowId=:ID)
	...q:SQLCODE'=0
	...i ItemID'="" d
	....q:..StringIsInStrs(Items,ItemID)
	....s Items=Items_"^"_ItemID
	....s SQLCODE=..UpdateGTOrdEnt(ItemID,PrivilegeMode, Rebate)
	q SQLCODE
}

ClassMethod StringIsInStrs(Strs, Str)
{
	new i,j,Arg,Flag
	s Flag=0
	s i=$l(Strs,"^")
	for j=1:1:i
	{
		s Arg=$p(Strs,"^",j)
		i Arg=Str s Flag=1
		q:Flag
	}
	q Flag
}

ClassMethod UpdateGTOrdEnt(ItemID, PrivilegeMode, Rebate)
{
	new PLIST,Info,GADM,TSub,Sub,AccountAmount
	s SQLCODE=0
	s GADM=$p(ItemID,"||",1)
	s TSub=$p(ItemID,"||",2)
	s Sub=$p(ItemID,"||",3)
	s Info=$G(^DHCPEPreGADM(GADM,"Team",TSub,"ORDENT",Sub))
	////如果修改为项目优惠不更新原来最终金额
	i PrivilegeMode="OP" d
	.
	e  d
	.s AccountAmount=$p(Info,"^",6)
	.//s PLIST(7)=PrivilegeMode
	.s PLIST(7)=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	.&SQL(update sqluser.DHC_PE_PreGTOrdEnt values :PLIST() where PGTOE_RowId=:ItemID)
	q SQLCODE
}

ClassMethod UpdateIOrdEnt(ItemID, PrivilegeMode, Rebate)
{
	new PLIST,Info,GADM,TSub,Sub,AccountAmount
	s SQLCODE=0
	s GADM=$p(ItemID,"||",1)
	s TSub=$p(ItemID,"||",2)
	s Info=$G(^DHCPEPreIADM(GADM,"ORDENT",TSub))
	s AccountAmount=$p(Info,"^",7)
	i AccountAmount="" s AccountAmount=0
	//s PLIST(7)=PrivilegeMode
	s PLIST(8)=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	&SQL(update sqluser.DHC_PE_PreIOrdEnt values :PLIST() where PIOE_RowId=:ItemID)
	q SQLCODE_"^"_PLIST(8)_"^"_AccountAmount
}

ClassMethod GetFactAmount(PrivilegeMode, AccountAmount, Rebate)
{
	new FactAmount
	i AccountAmount="" s AccountAmount=0
	i Rebate="" s Rebate=0
	i PrivilegeMode="NP" s FactAmount=AccountAmount
	i PrivilegeMode="OR" s FactAmount=(AccountAmount*Rebate)/100
	i PrivilegeMode="OP" s FactAmount=AccountAmount
	i PrivilegeMode="TP" s FactAmount=""
	q FactAmount
}

ClassMethod GetOneInfo(RowID)
{
	new Info
	s Info=$G(^DHCPEPreA(RowID))
	s ADMType=$P(Info,"^",1)
	S PreGAdm=$P(Info,"^",2)
	s PGADMContractNo=""
	I ADMType="G"  d
	.s TContract=$p($g(^DHCPEPreGADM(PreGAdm)),"^",25)
	.i +TContract'=0 d
	..s PGADMContractNo=$LG(^User.DHCPEContractD(TContract),2)
	q Info_"^"_PGADMContractNo
	//q Info
}

Query SerchPreAudit(ADMType As %String = "", CRMADM As %String = "", GIADM As %String = "", AppType As %String = "", PayedFlag As %String = "") As %Query(ROWSPEC = "TRowId:%String, TADMType:%String, TCRMADM:%String, TGIADM:%String, TContractNo:%String, TRebate:%String,TAccountAmount:%String, TDiscountedAmount:%String, TSaleAmount:%String,TFactAmount:%String, TAuditedStatus:%String, TAuditUserDR:%String,TAuditDate:%String,TAuditTime:%String,TChargedStatus:%String, TCancelUserDR:%String,TCancelDate:%String,TCancelTime:%String, TRemark:%String, TPrivilegeMode:%String, TType:%String,TTeamName:%String,TChargedType:%String")
{
}

ClassMethod SerchPreAuditExecute(ByRef qHandle As %Binary, ADMType As %String = "", CRMADM As %String = "", GIADM As %String = "", AppType As %String = "", PayedFlag As %String = "") As %Status
{
	//s ^tempdhcpe("CRMADM")=ADMType_"^"_CRMADM_"^"_GIADM
    Set repid=$I(^CacheTemp)
 	s ind=1
 	s id=0
 	s GlobalLength=23
 	new PreADM,ADM,ArgType,CRM
 	//w ..GetIFee(Type,CRMADM,GIADM)
 	s ArgType=""
 	s (PreADM,ADM)=""
 	
 	i ADMType="G"
 	{
	 	i CRMADM'=""
	 	{
		 	s PreADM=CRMADM
		 	s ADM=$o(^DHCPEGADM(0,"CRMADM",CRMADM,0))
	 	}
	 	elseif GIADM'=""
	 	{
		 	s ADM=GIADM
		 	s PreADM=$p($G(^DHCPEGADM(GIADM)),"^",2)
	 	}
 	}
 	i ADMType="I"
 	{
	 	i CRMADM'=""
	 	{
		 	s PreADM=CRMADM
		 	s ADM=$o(^DHCPEIADM(0,"CRMADM",CRMADM,0))
	 	}
	 	elseif GIADM'=""
	 	{
		 	s ADM=GIADM
		 	s PreADM=$p($G(^DHCPEIADM(GIADM)),"^",4)
	 	}
	 	
	 	if (ADM=""){	 	
		Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	 	}

	 	s PaadmRowid=$P($G(^DHCPEIADM(ADM)),"^",1)
	 	// 如果有PET则会产生门诊药费,其他特殊情况也会产生门诊药费,此时应则提示需要到门诊收费界面收取药费
 		s PapmiDR=$P($g(^PAADM(PaadmRowid)),"^",1)
 		s UnPayedFlag=$$GetOPUnPayedFlag(PapmiDR)
 		//i UnPayedFlag=1	W "<font color = red size=4 >     存在门诊费用未结算,请到门诊收费页面收取"

 	}
 	//w ##class(web.DHCPE.PreAudit).GetAPAmount(Type,PreADM)
 	i CRMADM'="" s ArgType="CRM"
 	i ADM'=""
 	{
	 	f  s id=$o(^DHCPEPreA(0,"GIADM",ADMType,ADM,id)) q:id=""  d
	 	.s CRM=$p($G(^DHCPEPreA(id)),"^",2)
	 	.q:((ArgType="CRM")&&(CRM'=""))
	 	.d GetOnePreAudit
 	}
 	s id=0
 	i PreADM'=""
 	{
	 	f  s id=$o(^DHCPEPreA(0,"CRMADM",ADMType,PreADM,id)) q:id=""  d
	 	.s CRM=$p($G(^DHCPEPreA(id)),"^",3)
	 	.q:((ArgType="")&&(CRM'=""))
	 	.d GetOnePreAudit
 	}
 	
 	Set qHandle=$lb(0,repid,0)
	Quit $$$OK


GetOPUnPayedFlagByAdm(PaadmRowid)
	s UnPayedFlag=0
	s OrderRowid=$o(^OEORD(0,"Adm",PaadmRowid,0))
	q:OrderRowid="" UnPayedFlag
	s ChildSub=0
	f  s ChildSub=$o(^OEORD(OrderRowid,"I",ChildSub)) q:((ChildSub="")||(UnPayedFlag=1))  d
	.s ItemStatDR=$p($g(^OEORD(OrderRowid,"I",ChildSub,1)),"^",13)
	.q:ItemStatDR'=1
	.//q:(ItemStatDR'=1)&&(ItemStatDR'=10)
	.s Billed=$p($g(^OEORD(OrderRowid,"I",ChildSub,3)),"^",5)
	.q:Billed="B"
	.s ArcimRowid=$p($g(^OEORD(OrderRowid,"I",ChildSub,1)),"^",2)
	.s FeeType=##class(web.DHCOPAdmReg).GetRegArcimBillSubType(ArcimRowid)
	.q:FeeType'="Other"
	.s UnPayedFlag=1
	q UnPayedFlag
	
 // 取得病人当然就诊未结算的门诊医嘱
GetOPUnPayedFlag(PapmiDR)
	q:PapmiDR="" 0
	s UnPayedFlag=0
	s PaadmRowid=0
	f  s PaadmRowid=$o(^PAPERdr(PapmiDR,"ADM","O",PaadmRowid)) q:PaadmRowid=""  d
	.s AdmDate=$p($g(^PAADM(PaadmRowid)),"^",6)
	.q:AdmDate'=+$h
	.s UnPayedFlag=$$GetOPUnPayedFlagByAdm(PaadmRowid)
	q UnPayedFlag
	
	
GetOnePreAudit
	k PLIST
	s AInfo=$G(^DHCPEPreA(id))
	s PLIST(1)=id
	for i=1:1:GlobalLength
	{
		s PLIST(i+1)=$p(AInfo,"^",i)
	}
	//Q:(AppType="Fee")&&((PLIST(10)="")||(PLIST(10)=0))
    Q:(AppType="Fee")&&((PLIST(10)=""))       //Add 20080707
    Q:(AppType="Fee")&&((PLIST(10)=0)&&(##class(web.DHCPE.Cashier).CheckAuditHasList(id)=0))   //Add 20080707
	q:PLIST(22)="NU"
	q:((PayedFlag'="")&&(PayedFlag'=PLIST(15)))
	//Q:(AppType="Fee")&&(PLIST(15)="CHARGED")
	s PLIST(11)=..GetAuditStatu(PLIST(11))
	s PLIST(15)=..GetChargedStatu(PLIST(15))
	s PLIST(20)=..GetPrivilegeMode(PLIST(20))
	if (PLIST(9)>0) s PLIST(20)="销售金额"
	s PLIST(21)=..GetAuditType(PLIST(21))
	s:PLIST(23)'="" PLIST(23)=$P($g(^DHCPEPreGADM(+PLIST(23),"Team",$P(PLIST(23),"||",2))),"^",1)
	s ChargedTypeInfo=$G(^DHCPEPreA("AsCharged",id))
	s ChargedType=$P(ChargedTypeInfo,"^",3)
	s ChargedType=..GetChargedTypeDesc(ChargedType)
	s ChargedRemak=$P(ChargedTypeInfo,"^",4)
	s:ChargedRemak'="" ChargedType=ChargedType_"("_ChargedRemak_")"
	q:($FN(PLIST(10),",",2)="0.00")&&(PLIST(15)="未收费")
	d Build
	q
Build
	
	set Data=$lb( PLIST(1), PLIST(2), PLIST(3), PLIST(4), PLIST(5), PLIST(6),$FN(PLIST(7),",",2), $FN(PLIST(8),",",2), $FN(PLIST(9),",",2),$FN(PLIST(10),",",2), PLIST(11), PLIST(12),PLIST(13),PLIST(14),PLIST(15), PLIST(16),PLIST(17),PLIST(18), PLIST(19), PLIST(20), PLIST(21),PLIST(23),ChargedType)
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SerchPreAuditFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SerchPreAuditExecute ]
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

ClassMethod SerchPreAuditClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SerchPreAuditExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// 得到团体报告发送状态
ClassMethod GetGReportSend(GSStatu)
{
	i GSStatu="" q ""
	i GSStatu="AC" q "挂帐可取"
	i GSStatu="DC" q "结帐取"
	q "没有设定"
}

/// 得到ADM状态
ClassMethod GetADMStatus(Status)
{
	i Status="PREREG" q "预挂号"
	i Status="ARRIVED" q "到达"
	i Status="COMPLETED" q "完成"
	i Status="" q ""
	q "没有设定"
}

/// 得到结算方式状态
ClassMethod GetDisChargedMode(DisChargedMode)
{
	i DisChargedMode="" q ""
	i DisChargedMode="GD" q "统结"
	i DisChargedMode="ID" q "自结"
	q "没有设定"
}

/// 根据审核状态的简码得到审核状态
ClassMethod GetAuditStatu(StatusType)
{
	i StatusType="" q ""
	i StatusType="UnAudited" q "未审核"
	i StatusType="Audited" q "已审核"
	i StatusType="NoAudited" q "不需审核"
	i StatusType="CancelAudited" q "取消审核"
}

/// 得到收费状态
ClassMethod GetChargedStatu(ChargedStatu)
{
	i ChargedStatu="" q ""
	i ChargedStatu="CHARGED" q "已收费"
	i ChargedStatu="UNCHARGED" q "未收费"
}

/// 得到优惠方式
ClassMethod GetPrivilegeMode(PrivilegeMode)
{
	i PrivilegeMode="" q ""
	i PrivilegeMode="NP" q "无优惠"
	i PrivilegeMode="TP" q "总价优惠"
	i PrivilegeMode="OR" q "折扣"
	i PrivilegeMode="OP" q "项目优惠"
}

/// 得到类型
ClassMethod GetAuditType(AuditType)
{
	i AuditType="" q ""
	i AuditType="PRE" q "预约"
	i AuditType="ADD" q "加项"
}

/// d ##class(web.DHCPE.PreAudit).UpdateFeeRecord("637","OPAmount")
/// 根据限额确定哪些是公费加项 Type "LimitFee":修改预约限额
ClassMethod UpdateFeeRecord(IID, Type As %String = "")
{
    K ^DHCPETMP("TwoRecordIForIFee")
	new GID,Return,FeeType,id,iFeeId,gAudit,iAudit,FId,Flag,OneAudit,AuditType
	new ChargedStatus,FactAmount,Sub,LimitFee,ItemId,FSub,AccountAmount
	new User,Date,Time
	s User=%session.Get("LOGON.USERID")
	
	s Date=+$H
	s Time=$P($H,",",2)
	s SQLCODE=0
	s GID=$p($g(^DHCPEPreIADM(IID)),"^",2)
	i GID="" q 0
	s Return=..GetPartItem(IID)  //得到两条审核记录对应的 类型和ID "Ord^"_IID_"||"_ISub
	s iFeeId=""
	i Return'="" d
	.s FeeType=$p(Return,"^",1)
	.s id=$p(Return,"^",2)
	.i FeeType="Ord" d
	..///排除无效的
	..s UFlag=$p(^DHCPEPreIADM($p(id,"||",1),"ORDENT",$p(id,"||",2)),"^",9)
	..q:UFlag'=1
	..
	..s AccountAmount=$p(^DHCPEPreIADM($p(id,"||",1),"ORDENT",$p(id,"||",2)),"^",7)
	..s iFeeId=..GetPartOrdFeeID(id,"I")
	..s gFeeId=..GetPartOrdFeeID(id,"G")
	..s (iFee,gFee)=0
	..i iFeeId'="" s iFee=$p(^DHCPEPreIADM($p(iFeeId,"||",1),"ORDENT",$p(iFeeId,"||",2),"FEE",$p(iFeeId,"||",3)),"^",2)
	..i gFeeId'="" s gFee=$p(^DHCPEPreIADM($p(gFeeId,"||",1),"ORDENT",$p(gFeeId,"||",2),"FEE",$p(gFeeId,"||",3)),"^",2)
	..;i iFeeId'="" d  &SQL(delete from sqluser.DHC_PE_PreIOrdEntFee where PIOEF_RowId=:iFeeId)
	..i iFeeId'=""  d 
    ...d  &SQL(delete from sqluser.DHC_PE_PreIOrdItemFee where PIOIF_RowId=:iFeeId)
    ...s ItemID=$P(iFeeId,"||",1,2)
    ...d  &SQL(update sqluser.DHC_PE_PreIOrdItem set PIOI_AsCharged='Y' where PIOI_RowID=:ItemID)
	..q:SQLCODE
	..i Type="LimitFee" d
	...s Fee=iFee+gFee
	...i gFeeId'="" d  &SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:Fee  where PIOEF_RowId=:gFeeId)
	..i Type="OPAmount"  d
	...s Fee=iFee+gFee
	...i gFeeId'="" d  &SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:Fee  where PIOEF_RowId=:gFeeId)
	.i FeeType="Item" d
	..///排除无效的
	..s UFlag=$p(^DHCPEPreIADM($p(id,"||",1),"ORDITEM",$p(id,"||",2)),"^",16)
	..q:UFlag'=1
	..
	..s AccountAmount=$p(^DHCPEPreIADM($p(id,"||",1),"ORDITEM",$p(id,"||",2)),"^",14)
	..s iFeeId=..GetPartItemFeeID(id,"I")
	..s gFeeId=..GetPartItemFeeID(id,"G")
	..s (iFee,gFee)=0
	..i iFeeId'="" s iFee=$p(^DHCPEPreIADM($p(iFeeId,"||",1),"ORDITEM",$p(iFeeId,"||",2),"FEE",$p(iFeeId,"||",3)),"^",2)
	..i gFeeId'="" s gFee=$p(^DHCPEPreIADM($p(gFeeId,"||",1),"ORDITEM",$p(gFeeId,"||",2),"FEE",$p(gFeeId,"||",3)),"^",2)
	..i iFeeId'="" d  &SQL(delete from sqluser.DHC_PE_PreIOrdItemFee where PIOIF_RowId=:iFeeId)
	..q:SQLCODE
	..i Type="LimitFee" d
	...s Fee=iFee+gFee
	...i gFeeId'="" d  &SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:Fee  where PIOIF_RowId=:gFeeId)
	..i Type="OPAmount"  d
	...s Fee=iFee+gFee
	...i gFeeId'="" d  &SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:Fee  where PIOIF_RowId=:gFeeId)
    
    s GTeamID=$p($g(^DHCPEPreIADM(IID)),"^",3)
    
	s gAudit=+##class(web.DHCPE.PreItemList).GetPARowId("G",GTeamID,"ADD")
	s iAudit=+##class(web.DHCPE.PreItemList).GetPARowId("I",IID,"ADD")
	s Sub=0
	s LimitFee=$p(^DHCPEPreIADM(IID),"^",12)
	s AddOrdItem=$p(^DHCPEPreIADM(IID),"^",10)
	s AddOrdItemLimit=$p(^DHCPEPreIADM(IID),"^",11)
	i LimitFee="" s LimitFee=0
	///更新项目
	f  s Sub=$o(^DHCPEPreIADM(0,"PIOIPAType",IID,"ADD",IID,Sub)) q:(Sub="")||(SQLCODE'=0)  d
	.s ItemId=IID_"||"_Sub
	.s FSub=0
	.///排除无效的
	.s UFlag=$p($G(^DHCPEPreIADM(IID,"ORDITEM",Sub)),"^",16)
	.q:UFlag'=1
	.s AccountAmount=$p($G(^DHCPEPreIADM(IID,"ORDITEM",Sub)),"^",14)
	.f  s FSub=$o(^DHCPEPreIADM(IID,"ORDITEM",Sub,"FEE",FSub)) q:(FSub="")||(SQLCODE'=0)  d
	..s FId=IID_"||"_Sub_"||"_FSub
	..s Flag=0
	..s OneAudit=$p(^DHCPEPreIADM(IID,"ORDITEM",Sub,"FEE",FSub),"^",5)
	..s AuditType=$p(^DHCPEPreA(OneAudit),"^",1)
	..s ChargedStatus=$p(^DHCPEPreA(OneAudit),"^",14)
	..s FactAmount=$p(^DHCPEPreIADM(IID,"ORDITEM",Sub,"FEE",FSub),"^",2)
	..i ChargedStatus="CHARGED" d
	...i AuditType="I" d
	....s Flag=1
	...i AuditType="G" d
	....s LimitFee=LimitFee-FactAmount
	....s Flag=1
	..q:Flag=1
	..i LimitFee>0 d  //还有公费金额
	...i AuditType="G" d  //本费用为公费
	....i LimitFee-FactAmount>0 d  //限额大于本费用
	.....s LimitFee=LimitFee-FactAmount
	.....s Flag=1
	....e  d  //限额小于本费用
	.....&SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:LimitFee where PIOIF_RowId=:FId)
	.....s:SQLCODE Flag=1
	.....q:Flag=1
	.....s Fee=FactAmount-LimitFee
	.....&SQL(insert into sqluser.DHC_PE_PreIOrdItemFee (PIOIF_ParRef,PIOIF_FactAmount,PIOIF_PAudit_DR,PIOIF_UpdateUser_DR,PIOIF_UpdateDate,PIOIF_UpdateTime) values (:ItemId,:Fee,:iAudit,:User,:Date,:Time))
	.....s ^DHCPETMP("TwoRecordIForIFee","Item",%ROWID)=Fee
	.....s LimitFee=0
	...e  d   //本费用为自费
	....s PrivilegeMode=$p(^DHCPEPreA(gAudit),"^",19)
	....s Rebate=$p(^DHCPEPreA(gAudit),"^",5)
	....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	....i LimitFee-FactAmount>0 d  //限额大于本费用
	.....s LimitFee=LimitFee-FactAmount 
	.....&SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:FactAmount,PIOIF_PAudit_DR=:gAudit where PIOIF_RowId=:FId)
	....e  d  //限额小于本费用
	.....s Fee=FactAmount-LimitFee
	.....&SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:LimitFee,PIOIF_PAudit_DR=:gAudit where PIOIF_RowId=:FId)
	.....s:SQLCODE Flag=1
	.....q:Flag=1
	.....&SQL(insert into sqluser.DHC_PE_PreIOrdItemFee (PIOIF_ParRef,PIOIF_FactAmount,PIOIF_PAudit_DR,PIOIF_UpdateUser_DR,PIOIF_UpdateDate,PIOIF_UpdateTime) values (:ItemId,:Fee,:iAudit,:User,:Date,:Time))
	.....s ^DHCPETMP("TwoRecordIForIFee","Item",%ROWID)=Fee
	.....s LimitFee=0
	..e  d  ///没有公费金额
	...s Return=..GetPartItem(IID)
	...i Return=""  d       
	....i AuditType="I" d
	.....s PrivilegeMode=$p(^DHCPEPreA(gAudit),"^",19)
	.....s Rebate=$p(^DHCPEPreA(gAudit),"^",5)
	.....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	.....;&SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:FactAmount ,PIOIF_PAudit_DR=:gAudit where PIOIF_RowId=:FId)
	....e  d
	.....i AddOrdItem="N" s gAudit=iAudit
	.....s PrivilegeMode=$p(^DHCPEPreA(gAudit),"^",19)
	.....s Rebate=$p(^DHCPEPreA(gAudit),"^",5)
	.....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	.....&SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:FactAmount,PIOIF_PAudit_DR=:gAudit where PIOIF_RowId=:FId)
	...else  d
	....i AuditType="I" d
	.....i $D(^DHCPETMP("TwoRecordIForIFee","Item",FId))  d
	......s AccountAmount=$G(^DHCPETMP("TwoRecordIForIFee","Item",FId))
	.....s PrivilegeMode=$p(^DHCPEPreA(iAudit),"^",19)
	.....s Rebate=$p(^DHCPEPreA(iAudit),"^",5)
	.....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	.....&SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:FactAmount where PIOIF_RowId=:FId)
	....e  d
	.....s PrivilegeMode=$p(^DHCPEPreA(iAudit),"^",19)
	.....s Rebate=$p(^DHCPEPreA(iAudit),"^",5)
	.....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	.....&SQL(update sqluser.DHC_PE_PreIOrdItemFee set PIOIF_FactAmount=:FactAmount,PIOIF_PAudit_DR=:iAudit where PIOIF_RowId=:FId)
	.d ##class(web.DHCPE.TransAdmInfo).UpdateOrdItemPrice(ItemId,"OrdItem")
	i SQLCODE q SQLCODE_"aa"
	s Sub=0
	///更新套餐
	f  s Sub=$o(^DHCPEPreIADM(0,"PIOEPAType",IID,"ADD",IID,Sub)) q:(Sub="")||(SQLCODE'=0)  d
	.s ItemId=IID_"||"_Sub
	.s FSub=0
	.///排除无效的
	.s UFlag=$p(^DHCPEPreIADM(IID,"ORDENT",Sub),"^",9)
	.q:UFlag'=1
	.s AccountAmount=$p(^DHCPEPreIADM(IID,"ORDENT",Sub),"^",7)
	.f  s FSub=$o(^DHCPEPreIADM(IID,"ORDENT",Sub,"FEE",FSub)) q:(FSub="")||(SQLCODE'=0)  d
	..s FId=IID_"||"_Sub_"||"_FSub
	..s Flag=0
	..s OneAudit=$p(^DHCPEPreIADM(IID,"ORDENT",Sub,"FEE",FSub),"^",5)
	..s AuditType=$p(^DHCPEPreA(OneAudit),"^",1)
	..s ChargedStatus=$p(^DHCPEPreA(OneAudit),"^",14)
	..s FactAmount=$p(^DHCPEPreIADM(IID,"ORDENT",Sub,"FEE",FSub),"^",2)
	..i ChargedStatus="CHARGED" d
	...i AuditType="I" d
	....s Flag=1
	...i AuditType="G" d
	....s LimitFee=LimitFee-FactAmount
	....s Flag=1
	..q:Flag=1
	..i LimitFee>0 d  //还有公费金额
	...i AuditType="G" d  //本费用为公费
	....i LimitFee-FactAmount>0 d  //限额大于本费用
	.....s LimitFee=LimitFee-FactAmount
	.....s Flag=1
	....e  d  //限额小于本费用
	.....&SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:LimitFee where PIOEF_RowId=:FId)
	.....s:SQLCODE Flag=1
	.....q:Flag=1
	.....s Fee=FactAmount-LimitFee
	.....&SQL(insert into sqluser.DHC_PE_PreIOrdEntFee (PIOEF_ParRef,PIOEF_FactAmount,PIOEF_PAudit_DR,PIOEF_UpdateUser_DR,PIOEF_UpdateDate,PIOEF_UpdateTime) values (:ItemId,:Fee,:iAudit,:User,:Date,:Time))
	.....s ^DHCPETMP("TwoRecordIForIFee","Ent",%ROWID)=Fee
	.....s LimitFee=0
	...e  d   //本费用为自费
	....s PrivilegeMode=$p(^DHCPEPreA(gAudit),"^",19)
	....s Rebate=$p(^DHCPEPreA(gAudit),"^",5)
	....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	....i LimitFee-FactAmount>0 d  //限额大于本费用
	.....s LimitFee=LimitFee-FactAmount 
	.....&SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:FactAmount,PIOEF_PAudit_DR=:gAudit where PIOEF_RowId=:FId)
	....e  d  //限额小于本费用
	.....s Fee=FactAmount-LimitFee
	.....&SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:LimitFee,PIOEF_PAudit_DR=:gAudit where PIOEF_RowId=:FId)
	.....s:SQLCODE Flag=1
	.....q:Flag=1
	.....&SQL(insert into sqluser.DHC_PE_PreIOrdEntFee (PIOEF_ParRef,PIOEF_FactAmount,PIOEF_PAudit_DR,PIOEF_UpdateUser_DR,PIOEF_UpdateDate,PIOEF_UpdateTime) values (:ItemId,:Fee,:iAudit,:User,:Date,:Time))
	.....s LimitFee=0
	.....s ^DHCPETMP("TwoRecordIForIFee","Ent",%ROWID)=Fee
	..e  d  ///没有公费金额
	...s Return=..GetPartItem(IID)
	...i Return="" d     
	....i AuditType="I" d
	.....s PrivilegeMode=$p(^DHCPEPreA(gAudit),"^",19)
	.....s Rebate=$p(^DHCPEPreA(gAudit),"^",5)
	.....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	.....;&SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:FactAmount,PIOEF_PAudit_DR=:gAudit where PIOEF_RowId=:FId)
	....e  d
	.....i AddOrdItem="N" s gAudit=iAudit
	.....s PrivilegeMode=$p(^DHCPEPreA(gAudit),"^",19)
	.....s Rebate=$p(^DHCPEPreA(gAudit),"^",5)
	.....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	.....&SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:FactAmount where PIOEF_RowId=:FId)
	...else  d
	....i AuditType="I" d
	.....i $D(^DHCPETMP("TwoRecordIForIFee","Ent",FId))  d
	......s AccountAmount=$G(^DHCPETMP("TwoRecordIForIFee","Ent",FId))
	......s PrivilegeMode=$p(^DHCPEPreA(iAudit),"^",19)
	......s Rebate=$p(^DHCPEPreA(iAudit),"^",5)
	......s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	......&SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:FactAmount where PIOEF_RowId=:FId)
	....e  d
	.....s PrivilegeMode=$p(^DHCPEPreA(iAudit),"^",19)
	.....s Rebate=$p(^DHCPEPreA(iAudit),"^",5)
	.....s FactAmount=..GetFactAmount(PrivilegeMode,AccountAmount,Rebate)
	.....&SQL(update sqluser.DHC_PE_PreIOrdEntFee set PIOEF_FactAmount=:FactAmount,PIOEF_PAudit_DR=:iAudit where PIOEF_RowId=:FId)
    .d ##class(web.DHCPE.TransAdmInfo).UpdateOrdItemPrice(ItemId,"OrdSets")
   
	q SQLCODE
}

/// 根据项目id,还有Type  "G":得到公费计费id  "I":得到自费计费id
ClassMethod GetPartItemFeeID(Itemid, Type)
{
	new tSub,Sub,iADM,auditId,Flag
	s Flag=""
	s iADM=$p(Itemid,"||",1)
	s tSub=$p(Itemid,"||",2)
	s Sub=0
	f  s Sub=$o(^DHCPEPreIADM(iADM,"ORDITEM",tSub,"FEE",Sub)) q:(Sub="")||(Flag'="")  d
	.s auditId=$p(^DHCPEPreIADM(iADM,"ORDITEM",tSub,"FEE",Sub),"^",5)
	.s aType=$p(^DHCPEPreA(auditId),"^",1)
	.i aType=Type s Flag=Itemid_"||"_Sub
	q Flag
}

/// 根据套餐id,还有Type  "G":得到公费计费id  "I":得到自费计费id
ClassMethod GetPartOrdFeeID(Itemid, Type)
{
	new tSub,Sub,iADM,auditId,Flag
	s Flag=""
	s iADM=$p(Itemid,"||",1)
	s tSub=$p(Itemid,"||",2)
	s Sub=0
	f  s Sub=$o(^DHCPEPreIADM(iADM,"ORDENT",tSub,"FEE",Sub)) q:(Sub="")||(Flag'="")  d
	.s auditId=$p(^DHCPEPreIADM(iADM,"ORDENT",tSub,"FEE",Sub),"^",5)
	.s aType=$p(^DHCPEPreA(auditId),"^",1)
	.i aType=Type s Flag=Itemid_"||"_Sub
	q Flag
}

/// 根据个人ID得到具有两种计费的项目(套餐)id 
ClassMethod GetPartItem(IID)
{
	new Flag,ISub,Sub,i
	
	s Flag=""
	s ISub=0
	f  s ISub=$o(^DHCPEPreIADM(IID,"ORDITEM",ISub)) q:(ISub="")||(Flag'="")  d
	.///排除无效
	.s UFlag=$p($G(^DHCPEPreIADM(IID,"ORDITEM",ISub)),"^",16)
	.q:UFlag'=1
	.
	.s Sub=0
	.s i=0
	.f  s Sub=$o(^DHCPEPreIADM(IID,"ORDITEM",ISub,"FEE",Sub)) q:(Sub="")||(Flag'="")  d
	..s PAuditDR=$p($g(^DHCPEPreIADM(IID,"ORDITEM",ISub,"FEE",Sub)),"^",5)
	..s ChargedStatus=$p($g(^DHCPEPreA(PAuditDR)),"^",14)
	..q:ChargedStatus="CHARGED"
	..s i=i+1
	..i i>1 s Flag="Item^"_IID_"||"_ISub
	q:Flag'="" Flag
	s i=0
	s ISub=0
	f  s ISub=$o(^DHCPEPreIADM(IID,"ORDENT",ISub)) q:(ISub="")||(Flag'="")  d
	.///排除无效的
	.s UFlag=$p($g(^DHCPEPreIADM(IID,"ORDENT",ISub)),"^",9)
	.q:UFlag'=1
	.s Sub=0
	.s i=0
	.f  s Sub=$o(^DHCPEPreIADM(IID,"ORDENT",ISub,"FEE",Sub)) q:(Sub="")||(Flag'="")  d
	..s i=i+1
	..i i>1 s Flag="Ord^"_IID_"||"_ISub
	q Flag
}

/// 得到团体中个人应付金额
ClassMethod GetIFee(ADMType As %String = "", CRMID As %String = "", PEID As %String = "")
{
	n (CRMID,PEID,ADMType)
	s TotalFee=""
	i ADMType="I" q TotalFee
	i PEID'="" s CRMID=$p($G(^DHCPEGADM(PEID)),"^",2)
	q:CRMID="" TotalFee
	s IADM=0
	f  s IADM=$o(^DHCPEPreIADM(0,"PGADM",CRMID,IADM)) q:IADM=""  d
	.s AuditID=0
	.f  s AuditID=$o(^DHCPEPreA(0,"CRMADM","I",IADM,AuditID)) q:AuditID=""  d
	..s Status=$p(^DHCPEPreA(AuditID),"^",21)
	..q:Status="NU"
	..s OneFee=+$p(^DHCPEPreA(AuditID),"^",9)
	..q:OneFee=0
	..s TotalFee=+TotalFee+OneFee
	
	q "团体中个人另外应付为"_+TotalFee_"元"
	//q "<font color = red>团体中个人另外应付为"_+TotalFee_"元!</font>"
}

// 2009-07-24  汪庆权

// 设置打印分类

ClassMethod updateInvPrintCatInfo(itmjs As %Library.String = "", itmjsex As %Library.String = "", InString As %Library.String = "") As %String
{
	s printflag=$g(InString)
	s Data="aa"
	if (printflag="")
	{
	 
	}
    if printflag="true"
    {
	    s ^DHCPESetting("DHCPE","InvPrintCatInfo")="Y"
	   
    }
    if (printflag="false")
    {
	     s ^DHCPESetting("DHCPE","InvPrintCatInfo")="N"
	     
	 }
	 q Data
}

// Type I,G

// ID   PreADM

// w ##class(web.DHCPE.PreAudit).GetAPAmount(Type,ID)

ClassMethod GetAPAmount(Type, ID)
{
	q:ID="" ""
	i Type="I" d
	.s BaseID=$P($G(^DHCPEPreIADM(ID)),"^",1)
	.s RegNo=$P($G(^DHCPEPreIBI(BaseID)),"^",1)
	e  d
	.s BaseID=$P($G(^DHCPEPreGADM(ID)),"^",1)
	.s RegNo=$P($G(^DHCPEPreGBI(BaseID)),"^",13)
	s APID=$O(^DHCPEAP(0,"RegNo",RegNo,0))
	//q:APID="" "<font color=red>没有预缴金</font>"
	q:APID="" "没有预缴金"
	s Amount=$P($G(^DHCPEAP(APID)),"^",4)
	//q "<font color=red>剩余预缴金"_Amount_"元</font>"
	q "剩余预缴金"_Amount_"元"
}

ClassMethod GetPayAmountInfo(Type, ID)
{
	i Type="I" d
	.s BaseID=$P($G(^DHCPEPreIADM(ID)),"^",1)
	.s Name=$P(^DHCPEPreIBI(BaseID),"^",2)
	e  d
	.s BaseID=$P($G(^DHCPEPreGADM(ID)),"^",1)
	.s Name=$P(^DHCPEPreGBI(BaseID),"^",2)
	s id=0
	s amountTotal=0
	f  s id=$o(^DHCPEPreA(0,"CRMADM",Type,ID,id)) q:id=""  d
	.s useFlag=$p(^DHCPEPreA(id),"^",21)
	.q:useFlag="NU"
	
	.s chargeFlag=$p(^DHCPEPreA(id),"^",14)
	.q:chargeFlag'="UNCHARGED"
	.s Amount=$P($G(^DHCPEPreA(id)),"^",9)
	.s amountTotal=+Amount+amountTotal
	q "请收取"_Name_"体检费"_amountTotal_"元。"
}

// 定额卡支付相当于已经付费

ClassMethod AsCharged(PreAuditID, UserID)
{
	q:PreAuditID="" "-1^请选择操作记录"
	s ChargedType=$P(PreAuditID,"^",2)
	s ChargedRemark=$P(PreAuditID,"^",3)
	s PreAuditID=$P(PreAuditID,"^",1)
	s UseFlag=$P(^DHCPEPreA(PreAuditID),"^",21)
	q:UseFlag="NU" "-1^记录不是有效状态"
	s ChargedStatus=$P(^DHCPEPreA(PreAuditID),"^",14)
	q:ChargedStatus="CHARGED" "-1^记录已经是付费状态"
	&SQL(Update Sqluser.DHC_PE_PreAudit Set PA_ChargedStatus='CHARGED' Where PA_RowID=:PreAuditID)
	q:SQLCODE'=0 "-1^更新记录失败:"_SQLCODE
	s DatTime=$H
	s ^DHCPEPreA("AsCharged",PreAuditID)=DatTime_"^"_UserID_"^"_ChargedType_"^"_ChargedRemark
	s ^DHCPEPreAI(DatTime,UserID,PreAuditID)=""
	q 0
}

// 取消定额卡付费

ClassMethod UnAsCharged(PreAuditID)
{
	q:PreAuditID="" "-1^请选择操作记录"
	s UseFlag=$P(^DHCPEPreA(PreAuditID),"^",21)
	q:UseFlag="NU" "-1^记录不是有效状态"
	s ChargedStatus=$P(^DHCPEPreA(PreAuditID),"^",14)
	q:ChargedStatus="UNCHARGED" "-1^记录不是付费状态"
	q:'$D(^DHCPEPreA("AsCharged",PreAuditID)) "-1^记录没有定额卡支付记录"
	&SQL(Update Sqluser.DHC_PE_PreAudit Set PA_ChargedStatus='UNCHARGED' Where PA_RowID=:PreAuditID)
	q:SQLCODE'=0 "-1^更新记录失败:"_SQLCODE
	s OldInfo=$G(^DHCPEPreA("AsCharged",PreAuditID))
	k ^DHCPEPreA("AsCharged",PreAuditID)
	k ^DHCPEPreAI($P(OldInfo,"^",1),$P(OldInfo,"^",2),PreAuditID)
	q 0
}

ClassMethod OutChargedType(ContrlWidth As %String = "")
{
	;d ##class(web.DHCPE.PreAudit).OutChargedType(125)
	s:(""=ContrlWidth) ContrlWidth="125"
	;w "<select name='ChargedType' id='ChargedType' style='width:"_ContrlWidth_"' HEIGHT=0>",!
	 w ##class(web.DHCPE.DHCPECommon).GetDefaultStyle("ChargedType","")
	w "<option value='1'>"_..GetChargedTypeDesc(1)_"</option>",!
	;w "<option value='2'>"_..GetChargedTypeDesc(2)_"</option>",!
	;w "<option value='3'>"_..GetChargedTypeDesc(3)_"</option>",!
	w "<option value='4'>"_..GetChargedTypeDesc(4)_"</option>",!
	;w "<option value='5'>"_..GetChargedTypeDesc(5)_"</option>",!
	w "</select>",!
}

ClassMethod OutprivilegeMode(ContrlWidth As %String = "", DefaultValue As %String = "")
{
	
	s:(""=ContrlWidth) ContrlWidth="125"
	 w ##class(web.DHCPE.DHCPECommon).GetDefaultStyle("privilegeMode","")
	 w "<option value=''> </option>",!
	 w "<option value='OR'>折扣</option>",!
	w "<option value='NP'>无优惠</option>",!
	w "<option value='OP'>项目优惠</option>",!
	w "<option value='OS'>销售金额</option>",!
	w "</select>",!
}

ClassMethod OutTypeToHTML(ContrlWidth As %String = "")
{
	
	s:(""=ContrlWidth) ContrlWidth="125"
	 w ##class(web.DHCPE.DHCPECommon).GetDefaultStyle("Type","")
	w "<option value='PRE'>预约</option>",!
	w "<option value='ADD'>加项</option>",!
	w "</select>",!
}

ClassMethod GetChargedTypeDesc(ChargedType)
{
	q:ChargedType="1" "定额卡"
	q:ChargedType="2" "遗留数据"
	q:ChargedType="3" "西院缴费"
	q:ChargedType="4" "其它"
	q:ChargedType="4" "团体换人"
	q ""
}

ClassMethod UpdateGroupAuditWuCha(GID)
{
	i PriModeNew="OS" d
	.s wucha=0
	.s GPersonID=""
	.s SaleAmount=""
	.s AuditID=0
	.f  s AuditID=$o(^DHCPEPreA(0,"CRMADM","G",GID,AuditID)) q:(AuditID="")  d
	..s UseFlag=$p($G(^DHCPEPreA(AuditID)),"^",21)
	..q:UseFlag="NU"
	..s stutas=$p(^DHCPEPreA(AuditID),"^",14)
	..q:stutas="CHARGED"
	..s IADM=0
	..f  s IADM=$o(^DHCPEPreIADM(0,"PAORDITEM",AuditID,IADM)) q:(IADM="")  d
	...q:SQLCODE'=0
	...s Sub=0
	...f  s Sub=$o(^DHCPEPreIADM(0,"PAORDITEM",AuditID,IADM,Sub)) q:(Sub="")  d
	....///排除无效的
	....s UFlag=$p($G(^DHCPEPreIADM(IADM,"ORDITEM",Sub)),"^",16)
	....q:UFlag'=1
	....q:GPersonID'=""
	....i GPersonID="" s GPersonID=IADM
	..s SaleAmount=$p($G(^DHCPEPreA(AuditID)),"^",8)
	..q:SaleAmount=""
	..q:SaleAmount=0
	..s FactAmountTotal=$p($G(^DHCPEPreA(AuditID)),"^",9)
	..s wucha=SaleAmount-FactAmountTotal
	..i (wucha'=0)&&(GPersonID'="") d
	...s UserID=%session.Get("LOGON.USERID")
	...s ArcCode="PE011" ////体检调整费
	...s ArcimID=$O(^ARCIM(0,"Code",ArcCode,0))
	...q:ArcimID=""
	...s ArcimID=ArcimID_"||1"
	...q:UserID=""
	...d ##class(web.DHCPE.PreItemList).IInsertItem(GPersonID,"PERSON","PRE",ArcimID_"&"_wucha_"&4&","",UserID)
	
	q "0"
}

}
