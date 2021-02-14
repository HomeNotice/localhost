/// 取预约登记的个人/团体的体检项目
/// test: d ##class(%ResultSet).RunQuery("web.DHCPE.Query.PreItemList", "QueryPreItemList","33","PERSON")
Class web.DHCPE.Query.PreItemList Extends (%Library.RegisteredObject, websys.Abstract) [ ClassType = "", Inheritance = right, Not ProcedureBlock ]
{

Parameter BUILD = 190;

// d ##class(%ResultSet).RunQuery("web.DHCPE.Query.PreItemList","QueryPreItemList","205||1","ADD")

/// 使用组件	DHCPEPreItemList
/// parameter:  AdmType: "TEAM"/"PERSON/Group/Audit"
Query QueryPreItemList(AdmId As %String = "", AdmType As %String = "", PreOrAdd As %String = "", AddType As %String = "", SelectType As %String = "", ShowFlag As %String = "", Control As %String = "") As %Query(ROWSPEC = "RowId:%String, ItemId:%String, ItemSetId:%String, ItemDesc:%String,ItemSetDesc:%String,IsBreakable:%String, OrderEntId:%String, TItemStat:%String, TAddOrdItem:%String, TItemNum:%String,TPreOrAdd:%String,PrivilegeModeID:%String,PrivilegeMode:%String,TFactAmount:%String,TAccountAmount:%String,TItemType:%String,TPersonAmount:%String,TItemStat:%String,TRecLoc:%String,TSpecName:%String,TAddUser:%String,TQty:%String,TTotalAmount:%String,TTotalFactAmount:%String,TIsMedical:%String,TCanChange:%String,ARCIM_OEMessage:%String,TModifiedFlag:%String,TUOM:%String,TItemColName:%String,TItemFeeType:%String,TFeeStatus:%String,OeordDateTime:%String,TItemFeeTypeDesc:%String,TRecLocDesc:%String,TSpecCode:%String")
{
}

ClassMethod QueryPreItemListExecute(ByRef qHandle As %Binary, AdmId As %String = "", AdmType As %String = "", PreOrAdd As %String = "", AddType As %String = "", SelectType As %String = "", ShowFlag As %String = "", Control As %String = "") As %Status
{
	k ^tempdhcpe("PreItemList")
	S ^tempdhcpe("PreItemList")=AdmType_"^"_AdmId_"^"_PreOrAdd_"^"_Control
	s AdmId=$p(AdmId,"^",1)   
	Set repid=$I(^CacheTemp)
 	If $g(ind)="" Set ind=1
	s PrivilegeMode=""
	s PrivilegeModeID=""
	s myBreakable=""
	s ModifiedFlag="0"
	s RecLoc=""
	s AdmId=$g(AdmId),  AdmType=$g(AdmType)
	i ((AdmId="")||(AdmType="")){
		Set qHandle=$lb(0,repid,0)
		q $$$OK
	}
	s LocID=%session.Get("LOGON.CTLOCID")
	s Strings=""
	s ChildId="0"
	if AdmType="PERSON" {
		f  s ChildId=$o(^DHCPEPreIADM(AdmId,"ORDITEM",ChildId)) q:ChildId=""  d 
		.s myQty=1,myRowId="", myItemId="", myItemSetId="",myItemDesc="", myOrdEntId="",TPreOrAdd=""
		.s myItemSetDesc="", myBreakable="Y"
		.s myQty=$G(^DHCPEDataEx("DHCPEPreIOrdItem","Qty",AdmId_"||"_ChildId))
		.i +myQty=0 s myQty=1
		.s myStr=$G(^DHCPEPreIADM(AdmId,"ORDITEM",ChildId))
		.s myRowId=AdmId_"||"_ChildId
		.// PIOI_ItmMast_DR
		.s myItemId=$p(myStr,"^",1)
		.// PIOI_OrdEnt_DR
		.s myOrdEntId=$p(myStr,"^",2)
		.s TItemStat=$p(myStr,"^",16)
		.s TAddUser=$p(myStr,"^",11)
		.i TAddUser'="" s TAddUser=$P($G(^SSU("SSUSR",TAddUser)),"^",2)
		.s RecLoc=$p(myStr,"^",17)
		.i RecLoc'="" d
		..s RecLocDesc=$p($G(^CTLOC(RecLoc)),"^",2)
		.s Flag=0
		.i myOrdEntId'="" d
		..s ModifiedFlag=..GetIsModifiedFlag(myOrdEntId, "ISets")
		..s RecLoc=""
		..s tempData=$g(^DHCPEPreIADM($p(myOrdEntId,"||",1),"ORDENT",$p(myOrdEntId,"||",2)))
		..s myItemSetId=$p(tempData,"^",1)
		..s TItemStat=$p(tempData,"^",9)
		..s AccountAmount=$p(tempData,"^",7)
		..s FactAmount=##class(web.DHCPE.HandlerPreOrds).GetFactAmountByOrd(myOrdEntId,"","")
		..///Modified by wrz 2009-01-06   
		..s myQty=$G(^DHCPEDataEx("DHCPEPreIOrdEnt","Qty",myOrdEntId))
		..i +myQty=0 s myQty=1
		..s TTotalFactAmount=FactAmount
		..s TTotalAmount=AccountAmount  //*myQty
		..s FactAmount=FactAmount/myQty
		..s AccountAmount=AccountAmount/myQty
		../// Modified End
		..s TPersonAmount=##class(web.DHCPE.HandlerPreOrds).GetFactAmountByOrd(myOrdEntId,"I","")
		..s Flag=##class(web.DHCPE.PreAudit).StringIsInStrs(Strings,myOrdEntId)
		..q:Flag="1"
		..s ItemType="Ent"
		..s TwoFeeRecord=##class(web.DHCPE.PreIADM).IsHaveTwoFeeRecord(myOrdEntId,"ORDENT")
		..i TwoFeeRecord>0 d
		...s AddOrdItem="公+自"
		...s gFeeId=##class(web.DHCPE.PreAudit).GetPartOrdFeeID(myOrdEntId, "G")
		...s AuditID=$p(^DHCPEPreIADM($p(gFeeId,"||",1),"ORDENT",$p(gFeeId,"||",2),"FEE",$p(gFeeId,"||",3)),"^",5)
		..e  d
		...s gFeeId=$o(^DHCPEPreIADM($p(myOrdEntId,"||",1),"ORDENT",$p(myOrdEntId,"||",2),"FEE",0))
		...i gFeeId'="" d
		....s gFeeId=myOrdEntId_"||"_gFeeId
		....s AuditID=$p(^DHCPEPreIADM($p(gFeeId,"||",1),"ORDENT",$p(gFeeId,"||",2),"FEE",$p(gFeeId,"||",3)),"^",5)
		....q:AuditID="" 
		....s AddOrdItem=$p(^DHCPEPreA(AuditID),"^",1)
		....s:AddOrdItem="G" AddOrdItem="公费"
		....s:AddOrdItem="I" AddOrdItem="自费"
		..s TPreOrAdd=$p(tempData,"^",8)
		..s TPreOrAdd=##class(web.DHCPE.PreAudit).GetAuditType(TPreOrAdd)
		..s Strings=Strings_"^"_myOrdEntId
		.e  d
		..s ModifiedFlag=..GetIsModifiedFlag(myRowId, "IItem")
		..s AccountAmount=$p(myStr,"^",14)
		..s FactAmount=##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(myRowId,"","")
		..s TPersonAmount=##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(myRowId,"I","")
		..///Modified by wrz 2009-01-06   
		..s TTotalFactAmount=FactAmount
		..s TTotalAmount=AccountAmount  //*myQty
		..s FactAmount=FactAmount/myQty
		..s AccountAmount=AccountAmount/myQty
		../// Modified End
		..s ItemType="Item"
		..s TwoFeeRecord=##class(web.DHCPE.PreIADM).IsHaveTwoFeeRecord(myRowId,"ORDITEM")
		..i TwoFeeRecord>0 d
		...s AddOrdItem="公+自"
		...s gFeeId=##class(web.DHCPE.PreAudit).GetPartItemFeeID(myRowId,"G")
		...//q:gFeeId=""
		...s AuditID=$p(^DHCPEPreIADM($p(gFeeId,"||",1),"ORDITEM",$p(gFeeId,"||",2),"FEE",$p(gFeeId,"||",3)),"^",5)
		..e  d
		...s gFeeId=$o(^DHCPEPreIADM($p(myRowId,"||",1),"ORDITEM",$p(myRowId,"||",2),"FEE",0))   //modify by zl 2010-12-01
		...i gFeeId'="" d
		....s gFeeId=myRowId_"||"_gFeeId
		....//q:gFeeId=""
		....s AuditID=$p(^DHCPEPreIADM($p(gFeeId,"||",1),"ORDITEM",$p(gFeeId,"||",2),"FEE",$p(gFeeId,"||",3)),"^",5)
		....q:AuditID=""
		....s AddOrdItem=$p(^DHCPEPreA(AuditID),"^",1)
		....s:AddOrdItem="G" AddOrdItem="公费"
		....s:AddOrdItem="I" AddOrdItem="自费"
		..s TPreOrAdd=$p(myStr,"^",15)
		..s TPreOrAdd=##class(web.DHCPE.PreAudit).GetAuditType(TPreOrAdd)
		.q:Flag="1"
		.s ItemStatus=""
		.s ItemNum=1
		.//s TPreOrAdd=##class(web.DHCPE.PreAudit).GetAuditType($p(myStr,"^",15))
		.i AuditID'="" d
		..s PrivilegeModeID=$p($G(^DHCPEPreA(AuditID)),"^",19)
		..s PrivilegeMode=##class(web.DHCPE.PreAudit).GetPrivilegeMode(PrivilegeModeID)
		.do OutputRow1	
	}
	
	i $g(AdmType)="TEAM" {
		b //TEAM
		f  s ChildId=$o(^DHCPEPreGADM($p(AdmId,"||",1),"Team",$p(AdmId,"||",2),"ORDITEM",ChildId))  q:ChildId=""  d
		.s myRowId="", myItemId="", myItemSetId="",myItemDesc="", myOrdEntId=""
		.s myItemSetDesc="", myBreakable="Y"
		.s myStr=^DHCPEPreGADM($p(AdmId,"||",1),"Team",$p(AdmId,"||",2),"ORDITEM",ChildId)
		.s myQty=$G(^DHCPEDataEx("DHCPEPreGTOrdItem","Qty",AdmId_"||"_ChildId))
		.i +myQty=0 s myQty=1
		.// PIOI_AddOrdItem	加项类别
		.s AddOrdItem="公费"
		.
		.s TPreOrAdd="预约"
		.s FactAmount=$p(myStr,"^",4)
		.s AccountAmount=$p(myStr,"^",11)
		.///Modified by wrz 2009-01-06   
		.s TTotalFactAmount=FactAmount
		.s TTotalAmount=AccountAmount  //*myQty
		.s FactAmount=FactAmount/myQty
		.s AccountAmount=AccountAmount/myQty
		./// Modified End
		.s TItemStat=$p(myStr,"^",13)
		.s TAddUser=$p(myStr,"^",8)
		.i TAddUser'="" s TAddUser=$P($G(^SSU("SSUSR",TAddUser)),"^",2)
		.s Flag=0
		.s ItemType="Item"
		.s myRowId=AdmId_"||"_ChildId
		.s myItemId=$p(myStr,"^",1)
		.s myOrdEntId=$p(myStr,"^",2)
		.s TItemStat=$p(myStr,"^",13)
		.s RecLoc=$p(myStr,"^",14)
		.i RecLoc'="" d
		..s RecLocDesc=$p(^CTLOC(RecLoc),"^",2)
		.i myOrdEntId'=""  d
		.. s ModifiedFlag="0"
		.. s RecLoc=""
		.. s tempData=$g(^DHCPEPreGADM($p(myOrdEntId,"||",1),"Team",$p(myOrdEntId,"||",2),"ORDENT",$p(myOrdEntId,"||",3)))
		.. s myItemSetId=$p(tempData,"^",1)
		.. s TItemStat=$p(tempData,"^",7)
		.. s ItemType="Ent"
		.. s FactAmount=$p(tempData,"^",5)
		.. s AccountAmount=$p(tempData,"^",6)
		..///Modified by wrz 2009-01-06   
		..s myQty=$G(^DHCPEDataEx("DHCPEPreGTOrdEnt","Qty",myOrdEntId))
		..i +myQty=0 s myQty=1
		..s TTotalFactAmount=FactAmount
		..s TTotalAmount=AccountAmount  //*myQty
		..s FactAmount=FactAmount/myQty
		..s AccountAmount=AccountAmount/myQty
		../// Modified End
		.. s Flag=##class(web.DHCPE.PreAudit).StringIsInStrs(Strings,myOrdEntId)
		.. q:Flag="1"
		.. s Strings=Strings_"^"_myOrdEntId
		.e  d
		..s ModifiedFlag=..GetIsModifiedFlag(myRowId, "TItem")
		.q:Flag="1"
		.s ItemStatus=""
		.//s AddOrdItem=""
		.s ItemNum=1
		.s AuditID=$p(myStr,"^",12)
		.//S PreGADM=$p(AdmId,"||",1)
		.//s AuditID=$o(^DHCPEPreA(0,"CRMADM","G",PreGADM,""),-1)   
		.i AuditID'="" d
		..s PrivilegeModeID=$p($G(^DHCPEPreA(AuditID)),"^",19)
		..s PrivilegeMode=##class(web.DHCPE.PreAudit).GetPrivilegeMode(PrivilegeModeID)

		.do OutputRow1	
	}
	
	i AdmType="Group" {
		
		k ^TMPItemList
		s PIADMDR=0
		f  s PIADMDR=$O(^DHCPEPreIADM(0,"PGADM", AdmId, PIADMDR)) Q:(""=PIADMDR)  d //
		.s PIOIChildSub=0
		.f  s PIADMDR=$O(^DHCPEPreIADM(PIADMDR,"ORDITEM", PIOIChildSub)) Q:(""=PIOIChildSub)  d
		..s CurData=$G(^DHCPEPreIADM(PIADMDR,"ORDITEM",PIOIChildSub))
		..//  PIOI_ItmMast_DR
		..s ItmMastDR=$P(CurData,"^",1)
		..s ^TMPItemList("PreItemList",ItmMastDR)=+$G(^TMPItemList("PreItemList",ItmMastDR))+1
		..s TItemStat=$p(CurData,"^",16)
		
		s myItemId=0
		f  s myItemId=$O(^TMPItemList("PreItemList",myItemId)) Q:(""=myItemId)  d
		.s ItemNum=+$G(^TMPItemList("PreItemList",myItemId))
		.s myItemSetId=""
		.s myOrdEntId=""
		.s AddOrdItem=""
		.s ItemStatus=""
		.s ItemType=""
		.do OutputRow1	
	
	}
	
	i AdmType="Audit" {
		k ^TMPItemList
		s PIADMDR=0
		f  s PIADMDR=$O(^DHCPEPreIADM(0,"PAudit", AdmId, PIADMDR)) Q:(""=PIADMDR)  d
		.s PIOIChildSub=0
		.f  s PIADMDR=$O(^DHCPEPreIADM(0,"PAudit", AdmId, PIADMDR, PIOIChildSub)) Q:(""=PIOIChildSub)  d
		..s CurData=$G(^DHCPEPreIADM(PIADMDR,"ORDITEM",PIOIChildSub))
		..//  PIOI_ItmMast_DR
		..s ItmMastDR=$P(CurData,"^",1)
		..s TItemStat=$p(CurData,"^",16) 
		..s ^TMPItemList("PreItemList",ItmMastDR)=+$G(^TMPItemList("PreItemList",ItmMastDR))+1
		
		s myItemId=0
		f  s myItemId=$O(^TMPItemList("PreItemList",myItemId)) Q:(""=myItemId)  d
		.s ItemNum=+$G(^TMPItemList("PreItemList",myItemId))
		.s myItemSetId=""
		.s myOrdEntId=""
		.s AddOrdItem=""
		.s ItemStatus=""
		.s ItemType=""
		.do OutputRow1	
	
	}
	i AdmType="PERSONOrd"
	{
		s IAdm=0
		f  s IAdm=$o(^DHCPEPreIADM(0,"OrdEnt",AdmId,IAdm)) q:IAdm=""  d
		.s myItemSetId=$p(^DHCPEPreIADM($p(AdmId,"||",1),"ORDENT",$p(AdmId,"||",2)),"^",1)
		.s Sub=0
		.f  s Sub=$o(^DHCPEPreIADM(0,"OrdEnt",AdmId,IAdm,Sub)) q:Sub=""  d
		..s (myRowId, myItemId, myItemDesc, myItemSetDesc, myBreakable, myOrdEntId, ItemStatus, AddOrdItem,FactAmount,TPreOrAdd,PrivilegeModeID,PrivilegeMode,FactAmount,AccountAmount,ItemType)=""
		..s myOrdEntId=AdmId
		..s TempData=$g(^DHCPEPreIADM(IAdm,"ORDITEM",Sub))
		..s myRowId=IAdm_"||"_Sub
		..s myItemId=$p(TempData,"^",1)
		..s TItemStat=$p(TempData,"^",16)
		..s TAddUser=$p(TempData,"^",11)
		..i TAddUser'="" s TAddUser=$P($G(^SSU("SSUSR",TAddUser)),"^",2)
		..s RecLoc=$p(TempData,"^",17)
		..i RecLoc'="" d
		...s RecLocDesc=$p(^CTLOC(RecLoc),"^",2)
		..//s itemPrice=##class(web.UDHCJFPRICE).GetOrderPrice("","",myItemId,+$H,"","","","")
		..Set itemPrice=##class(web.DHCPE.PreItemList).GetOrderPrice(myItemId)
		..s AccountAmount=+itemPrice
		..s FactAmount=$p(TempData,"^",6)
		..s AddOrdItem=$p(TempData,"^",5)
		..i AddOrdItem="Y" s AddOrdItem="公费"
		..i AddOrdItem="N" s AddOrdItem="自费"
		..s TPreOrAdd=##class(web.DHCPE.PreAudit).GetAuditType($p(TempData,"^",15))
		..s AuditID=$p(TempData,"^",10)
		..i AuditID'="" d
		...s PrivilegeModeID=$p($G(^DHCPEPreA(AuditID)),"^",19)
		...s PrivilegeMode=##class(web.DHCPE.PreAudit).GetPrivilegeMode(PrivilegeModeID)
		...
		..do OutputRow1
		
	}
	i AdmType="TEAMOrd"
	{
		s GAdm=0
		f  s GAdm=$o(^DHCPEPreGADM(0,"OrdEnt",AdmId,GAdm)) q:GAdm=""  d
		.s myItemSetId=$p(^DHCPEPreGADM($p(AdmId,"||",1),"Team",$p(AdmId,"||",2),"ORDENT",$p(AdmId,"||",3)),"^",1)
		.s TSub=0
		.f  s TSub=$o(^DHCPEPreGADM(0,"OrdEnt",AdmId,GAdm,TSub)) q:TSub=""  d
		..s Sub=0
		..f  s Sub=$o(^DHCPEPreGADM(0,"OrdEnt",AdmId,GAdm,TSub,Sub)) q:Sub=""  d
		...s (myRowId, myItemId, myItemDesc, myItemSetDesc, myBreakable, myOrdEntId, ItemStatus, AddOrdItem,FactAmount,TPreOrAdd,PrivilegeModeID,PrivilegeMode,FactAmount,AccountAmount,ItemType)=""
		...s TempData=$G(^DHCPEPreGADM(GAdm,"Team",TSub,"ORDITEM",Sub))
		...s myRowId=GAdm_"||"_TSub_"||"_Sub
		...s myItemId=$p(TempData,"^",1)
		...s myOrdEntId=AdmId
		...s TItemStat=$p(TempData,"^",13)
		...s FactAmount=$p(TempData,"^",4)
		...s TAddUser=$p(TempData,"^",8)
		...i TAddUser'="" s TAddUser=$P($G(^SSU("SSUSR",TAddUser)),"^",2)
		
		...s RecLoc=$p(TempData,"^",14)
		...i RecLoc'="" d
		....s RecLocDesc=$p(^CTLOC(RecLoc),"^",2)
		
		...//s itemPrice=##class(web.UDHCJFPRICE).GetOrderPrice("","",myItemId,+$H,"","","","")
		...Set itemPrice=##class(web.DHCPE.PreItemList).GetOrderPrice(myItemId)
		...s AccountAmount=+itemPrice
		...//s AccountAmount=$p(TempData,"^",11)
		...s AddOrdItem="公费"
		...s TPreOrAdd="预约"
		...s AuditID=$p(TempData,"^",12)
		...i AuditID'="" d
		....s PrivilegeModeID=$p($G(^DHCPEPreA(AuditID)),"^",19)
		....s PrivilegeMode=##class(web.DHCPE.PreAudit).GetPrivilegeMode(PrivilegeModeID)
		...do OutputRow1
	}
	i AdmType="Ord"
	{
		do OrdSetsItem(AdmId)
		/*s itemIds=""
		s today=+$h
		s dateChildId="0"
		s myItemSetId=AdmId
		f  s dateChildId=$o(^ARCOS(AdmId,"DATE",dateChildId))  q:dateChildId=""  d
		.set strData=^ARCOS(AdmId,"DATE",dateChildId)
		.q:(($p(strData,"^",1)>today)&&($p(strData,"^",2)<today))
		.s itemChildId="0"
		.f  s itemChildId=$o(^ARCOS(AdmId,"DATE",dateChildId,"ITM",itemChildId))  q:itemChildId=""  d
		..s strDataItm=$g(^ARCOS(AdmId,"DATE",dateChildId,"ITM",itemChildId))
		..s myItemId=$p(strDataItm,"^",1)
		..s itemPrice=##class(web.UDHCJFPRICE).GetOrderPrice("","",myItemId,+$H,"","","","")
		..s AccountAmount=+itemPrice
		..do OutputRow1*/
	}
	
 	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
	//ROWSPEC = "RowId:%String, ItemId:%String, ItemSetId:%String, ItemDesc:%String,ItemSetDesc:%String，IsBreakable:%String"
OrdSetsItem(OrdSetsID)
	new SetsSub,ItemChildId,SetsID,dateChildId
	s itemIds=""
	s today=+$h
	s dateChildId="0"
	s TItemStat="1"
	s myItemSetId=OrdSetsID
	f  s dateChildId=$o(^ARCOS(OrdSetsID,"DATE",dateChildId))  q:dateChildId=""  d
	.set strData=^ARCOS(OrdSetsID,"DATE",dateChildId)
	.q:(($p(strData,"^",1)>today)&&($p(strData,"^",2)<today))
	.s itemChildId="0"
	.f  s itemChildId=$o(^ARCOS(OrdSetsID,"DATE",dateChildId,"ITM",itemChildId))  q:itemChildId=""  d
	..s strDataItm=$g(^ARCOS(OrdSetsID,"DATE",dateChildId,"ITM",itemChildId))
	..s myItemId=$p(strDataItm,"^",1)
	..//s itemPrice=##class(web.UDHCJFPRICE).GetOrderPrice("","",myItemId,+$H,"","","","")
	..s itemPrice=##class(web.DHCPE.PreItemList).GetOrderPrice(myItemId)
	..s AccountAmount=+itemPrice
	..do OutputRow1
	.s SetsSub="0"
	.f  s SetsSub=$o(^ARCOS(OrdSetsID,"DATE",dateChildId,"OS",SetsSub))  q:SetsSub=""  d
	..s SetsData=$g(^ARCOS(OrdSetsID,"DATE",dateChildId,"OS",SetsSub))
	..s SetsID=$p(SetsData,"^",1)
	..do OrdSetsItem(SetsID)
	quit
OutputRow1
	s TFeeStatus="",Status="",OeordDateTime="",OeordDate="",OeordTime=""
	//Quit:$g(myItemStr)=""       080325  wrz 注释
	q:myItemId=""
	s myItemStr=^ARCIM($p(myItemId,"||",1),$p(myItemId,"||",2),1)
	i $G(myRowId)="" d
	.s CRMOrdID=""
	e  d
	.s CRMOrdID=$o(^DHCPECRMO(0,"CRMORI",myRowId,0))
	
	
	//add strat
	i CRMOrdID'="" d
	.s Oeordid=$p($g(^DHCPECRMO(CRMOrdID)),"^",1)
	.q:Oeordid=""
	.s OeordDate=$p(^OEORD(+Oeordid,"I",$p(Oeordid,"||",2),3),"^",7)
	.i OeordDate'="" s OeordDate=$zd(OeordDate,3)
	.s OeordTime=$p(^OEORD(+Oeordid,"I",$p(Oeordid,"||",2),1),"^",17)
	.i OeordTime'="" s OeordTime=$zt(OeordTime,2)
	.s OeordDateTime=OeordDate_" "_OeordTime
	//add end
	
	
	
	s:(CRMOrdID'="") Status=$p($g(^DHCPECRMO(CRMOrdID)),"^",4)
	s:(Status="P") TFeeStatus="已付费"
	s:(Status="NP") TFeeStatus="未付费"
	s:(Status="OC") TFeeStatus="挂账"
	s:(Status="PP") TFeeStatus="部分付费"
	s TUOM=$p($g(^ARCIM(myItemId,1,8)),"^",14)     ;ARCIM_BillingUOM_DR
	i TUOM'="" s TUOM=$p($g(^CT("UOM",TUOM)),"^",2)
	
	s StationID=$o(^DHCPEST(0,"STORD_ARCIM",myItemId,0))
	s ARCIMOEMessage=$g(^ARCIM($p(myItemId,"||",1),$p(myItemId,"||",2),"OEM",1))
	i $G(myRowId)'="" s TCanChange=##class(web.DHCPE.PreItemList).MayDeleteItem(AdmType,myRowId,"")
	s TIsMedical="0"
	s:StationID=$G(^DHCPESetting("DHCPE","StationId_Medical")) TIsMedical="1"
	
	s myItemDesc=$p(myItemStr,"^",2)
	s SpecName="",SpecCode=""
	s SPType=AdmType
	i SPType["PERSON" s SPType="PERSON"
	i SPType["TEAM" s SPType="TEAM"
	if ($G(myRowId)'="") d
	.s SpecName=$P($G(^DHCPEDataEx("DHCPEPreIOrdItem",SPType,myRowId)),"^",2)
	.s SpecCode=$P($G(^DHCPEDataEx("DHCPEPreIOrdItem",SPType,myRowId)),"^",1)
	i myItemSetId'=""  d
	. s myItemSetDesc=$p($g(^ARCOS(myItemSetId)),"^",2)
	. s myItemSetExId=$o(^DHCPEOSE(0,"OrdSets",myItemSetId,""))
	.i (AdmType'="PERSONOrd")&&(AdmType'="TEAMOrd")&&(AdmType'="Ord") s myItemDesc=""
	.s TUOM=""
	.s TIsMedical="0"
	.
	.i $G(myOrdEntId)'="" s TCanChange=##class(web.DHCPE.PreItemList).MayDeleteItem(AdmType,"",myOrdEntId)
	. i myItemSetExId'=""  d
	.. s myBreakable=$p(^DHCPEOSE(myItemSetExId),"^",2)
	
	i TItemStat'="1" d
	.i myOrdEntId'="" d
	..s DUserID=$G(^DHCPEDataEx("DHCPEPreIOrdEnt","XDate","XTime",myOrdEntId))
	.e  d
	..s DUserID=$G(^DHCPEDataEx("DHCPEPreIOrdItem","XDate","XTime",myRowId))
	.s DUserID=$p(DUserID,"^",3)
	.i DUserID'="" d
	..s TAddUser=$P($G(^SSU("SSUSR",DUserID)),"^",2)
	//用于体检费用类别 20110902
	s ItemColName="TItemFeeTypez"_ind
	i SPType="PERSON"  d
	.s ADMFeeType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType",AdmId))
	.i ItemType="Ent" s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Ent",myOrdEntId))
	.else  s ItemADMType=$g(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType","Item",myRowId))
	.i ItemADMType="" s ItemADMType=ADMFeeType
	.i ItemADMType'=""  s ItemADMTypeDesc=$P($G(^PAC("SUBT",ItemADMType)),"^",2)
    i SPType="Team"   d
    .s ADMFeeType=$g(^DHCPEDataEx("DHCPEPreGADM","ADMFeeType",AdmId))
	.i ItemType="Ent" s ItemADMType=$g(^DHCPEDataEx("DHCPEPreGADM","ADMFeeType","Ent",myOrdEntId))
	.else  s ItemADMType=$g(^DHCPEDataEx("DHCPEPreGADM","ADMFeeType","Item",myRowId))
	.i ItemADMType="" s ItemADMType=ADMFeeType
	.i ItemADMType'=""  s ItemADMTypeDesc=$P($G(^PAC("SUBT",ItemADMType)),"^",2)
	q:((TItemStat'="")&&(TItemStat'="1"))
	i myBreakable="N" S myItemId=""
	
	i $d(FactAmount) d
	 .i $p(FactAmount,".",1)=""  s FactAmount=0_FactAmount
	 .s FactAmount=$fn(FactAmount,"",2)
	 
	 i $d(AccountAmount) d
	 .i $p(AccountAmount,".",1)=""  s AccountAmount=0_AccountAmount
	 .s AccountAmount=$fn(AccountAmount,"",2)
	 
	  i $d(TPersonAmount) d
	 .i $p(TPersonAmount,".",1)="" s TPersonAmount=0_TPersonAmount
	 .s TPersonAmount=$fn(TPersonAmount,"",2)
     
	  i $d(TTotalAmount) d
	  .i $p(TTotalAmount,".",1)="" s TTotalAmount=0_TTotalAmount
	  .s TTotalAmount=$fn(TTotalAmount,"",2)
	  
	  i $d(TTotalFactAmount) d
      .i $p(TTotalFactAmount,".",1)="" s TTotalFactAmount=0_TTotalFactAmount
	  .s TTotalFactAmount=$fn(TTotalFactAmount,"",2)


	set Data=$lb(myRowId, myItemId, myItemSetId, myItemDesc, myItemSetDesc, myBreakable, myOrdEntId, ItemStatus, AddOrdItem,FactAmount,TPreOrAdd,PrivilegeModeID,PrivilegeMode,FactAmount,AccountAmount,ItemType,TPersonAmount,TItemStat,RecLoc,SpecName,$G(TAddUser),$G(myQty),$G(TTotalAmount),$G(TTotalFactAmount),$G(TIsMedical),$G(TCanChange),ARCIMOEMessage,ModifiedFlag,TUOM,ItemColName,ItemADMType,TFeeStatus,OeordDateTime,ItemADMTypeDesc,RecLocDesc,SpecCode)  //todo: Modify
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
	quit
}

ClassMethod QueryPreItemListFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = QueryPreItemListExecute ]
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

ClassMethod QueryPreItemListClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = QueryPreItemListExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
 	Quit $$$OK
}

Query QueryPreItemByOrdList(Ord As %String = "", Date As %String = "") As %Query(ROWSPEC = "RowId:%String, ItemId:%String, ItemSetId:%String, ItemDesc:%String,ItemSetDesc:%String,IsBreakable:%String, OrderEntId:%String, TStatus:%String, TAddOrdItem:%String, TItemNum:%String,TPreOrAdd:%String,PrivilegeModeID:%String,PrivilegeMode:%String,TFactAmount:%String,TAccountAmount:%String,TItemType:%String")
{
}

ClassMethod QueryPreItemByOrdListExecute(ByRef qHandle As %Binary, Ord As %String = "", Date As %String = "") As %Status
{
    Set repid=$I(^CacheTemp)
 	If $g(ind)="" Set ind=1
	s Ord=$g(Ord),  Date=$g(Date)
	i (Ord=""){
		Set qHandle=$lb(0,repid,0)
		q $$$OK
	}
	s Date=$ZDH(Date,4)
	s ORDSub=0
	f  s ORDSub=$o(^ARCOS(Ord,"DATE",ORDSub)) q:ORDSub=""  d
	.s StartDate=$p($g(^ARCOS(Ord,"DATE",ORDSub)),"^",1)
	.q:StartDate>Date
	.s EndDate=$p($g(^ARCOS(Ord,"DATE",ORDSub)),"^",2)
	.q:EndDate<Date
	.s ISub=0
	.f  s ISub=$o(^ARCOS(Ord,"DATE",ORDSub,"ITM",ISub)) q:ISub=""  d
	..s OrdItemID=$p(^ARCOS(Ord,"DATE",ORDSub,"ITM",ISub),"^",1)
	..
	
	
 	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
	//ROWSPEC = "RowId:%String, ItemId:%String, ItemSetId:%String, ItemDesc:%String,ItemSetDesc:%String，IsBreakable:%String"
	
OutputRow
	set Data=$lb(myRowId, myItemId, myItemSetId, myItemDesc, myItemSetDesc, myBreakable, myOrdEntId, ItemStatus, AddOrdItem,FactAmount,TPreOrAdd,PrivilegeModeID,PrivilegeMode,FactAmount,AccountAmount,ItemType)  //todo: Modify
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
	quit
}

ClassMethod QueryPreItemByOrdListFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = QueryPreItemByOrdListExecute ]
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

ClassMethod QueryPreItemByOrdListClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = QueryPreItemByOrdListExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
 	Quit $$$OK
}

ClassMethod judgeFeeType(PreIAdm As %String, OEORDRowId As %String, Sub As %String) As %Integer
{

    s FeeType=""
    s GADMDR=$P($G(^DHCPEPreIADM(PreIAdm)),"^",2)

    s ARCIMID=$p(^OEORD(OEORDRowId,"I",Sub,1),"^",2)
    s PreIOrdItemDR=0
    f  s PreIOrdItemDR=$o(^DHCPEPreIADM(0,"ItmMast",ARCIMID,PreIAdm,PreIOrdItemDR))  q:PreIOrdItemDR=""  d
    .i GADMDR'="" d
    ..s PIOIType=$p(^DHCPEPreIADM(PreIAdm,"ORDITEM",PreIOrdItemDR),"^",15)
 
    ..i PIOIType="PRE"  s FeeType="公费"
   
    ..//若为加项，则可能为"公费加项"、"自费加项"、"公+自"
    ..i PIOIType="ADD"  d
    ...s OrdItemFeeID=0
    ...f  s OrdItemFeeID=$o(^DHCPEPreIADM(PreIAdm,"ORDITEM",PreIOrdItemDR,"FEE",OrdItemFeeID))  q:OrdItemFeeID=""  d
    ....//i 当对应两个费用ID  s FeeType="公+自" 
    ....i OrdItemFeeID["2"  s FeeType="公+自"
    ....else  d
    .....s PAuditDR=$p(^DHCPEPreIADM(PreIAdm,"ORDITEM",PreIOrdItemDR,"FEE",OrdItemFeeID),"^",5)
    .....s PAADMType=$p(^DHCPEPreA(PAuditDR),"^",1)
    .....i PAADMType="G"   s FeeType="公费"
	.....i PAADMType="I"   s FeeType="自费"
	.else  d
	..s FeeType="自费"
	
	 q FeeType
}

/// 得到是否自定义价格的遗嘱
/// 1 是  0  不是
/// w ##class(web.DHCPE.Query.PreItemList).GetItemTypeByID("21102||1")
ClassMethod GetItemTypeByID(ItmMastID)
{
	s ItemCat=$P($G(^ARCIM(+ItmMastID,$p(ItmMastID,"||",2),1)),"^",10)
	q:ItemCat="" 0
	s ItemType1=$p($G(^ARC("IC",ItemCat)),"^",7)
	q:ItemType1="P" 1
	q 0
}

/// PreID   预约项目ID   预约套餐ID
/// Type    IItem  个人项目   ISets  个人套餐
/// 		   TItem  分组项目   TSets  分组套餐
/// 1  可以修改  0  不可以修改
/// w ##class(web.DHCPE.Query.PreItemList).GetIsModifiedFlag("10||3","IItem")
ClassMethod GetIsModifiedFlag(PreID, Type)
{
	s ModifiedFlag=0
	i Type="IItem" d
	.s PreIADM=+PreID
	.s Sub=$p(PreID,"||",2)
	.s Stat=$p($G(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub)),"^",16)
	.q:Stat'="1"
	.s FSub=0
	.f  s FSub=$o(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub,"FEE",FSub)) q:(FSub="")||(ModifiedFlag=1)  d
	..s AuditID=$p(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub,"FEE",FSub),"^",5)
	..q:AuditID=""
	..s AuditStatus=$P(^DHCPEPreA(AuditID),"^",21)
	..q:AuditStatus="NU"
	..s ChargeStatus=$P(^DHCPEPreA(AuditID),"^",14)
	..q:ChargeStatus="CHARGED"
	..s PrivilegeMode=$P(^DHCPEPreA(AuditID),"^",19)
	..S:PrivilegeMode="OP" ModifiedFlag=1
	.q:ModifiedFlag=1
	.s ItmMastID=$p(^DHCPEPreIADM(+PreID,"ORDITEM",Sub),"^",1)
	.s ModifiedFlag=..GetItemTypeByID(ItmMastID)
	e  i Type="ISets" d
	.s PreIADM=+PreID
	.s Sub=$p(PreID,"||",2)
	.s Stat=$p(^DHCPEPreIADM(PreIADM,"ORDENT",Sub),"^",9)
	.q:Stat'="1"
	.s FSub=0
	.f  s FSub=$o(^DHCPEPreIADM(PreIADM,"ORDENT",Sub,"FEE",FSub)) q:(FSub="")||(Flag=1)  d
	..s AuditID=$p(^DHCPEPreIADM(PreIADM,"ORDENT",Sub,"FEE",FSub),"^",5)
	..q:AuditID=""
	..s AuditStatus=$P(^DHCPEPreA(AuditID),"^",21)
	..q:AuditStatus="NU"
	..s ChargeStatus=$P(^DHCPEPreA(AuditID),"^",14)
	..q:ChargeStatus="CHARGED"
	..s PrivilegeMode=$P(^DHCPEPreA(AuditID),"^",19)
	..S:PrivilegeMode="OP" ModifiedFlag=1
	e  i Type="TItem" d
	.s GADM=+PreID
	.s TSub=$p(PreID,"||",2)
	.s ISub=$p(PreID,"||",3)
	.s Stat=$p(^DHCPEPreGADM(GADM,"Team",TSub,"ORDITEM",ISub),"^",13)
	.q:Stat'="1"
	.s AuditID=$p(^DHCPEPreGADM(GADM,"Team",TSub,"ORDITEM",ISub),"^",12)
	.;s AuditID=$o(^DHCPEPreA(0,"CRMADM","G",GADM,""),-1) 
	.s AuditStatus=$P(^DHCPEPreA(AuditID),"^",21)
	.q:AuditStatus="NU"
	.s ChargeStatus=$P(^DHCPEPreA(AuditID),"^",14)
	.q:ChargeStatus="CHARGED"
	.s PrivilegeMode=$P(^DHCPEPreA(AuditID),"^",19)
	.S:PrivilegeMode="OP" ModifiedFlag=1
	.i PrivilegeMode="NP"  d                                                  
	..s ItmMastID=$p(^DHCPEPreGADM(GADM,"Team",TSub,"ORDITEM",ISub),"^",1)    
	..s ModifiedFlag=..GetItemTypeByID(ItmMastID)                            
	q ModifiedFlag
}

}
