/// Created by SongDeBo 2006/6/6
/// Description: 对有关DHC_PE_OrdSetsEx的简单处理,如查询
Class web.DHCPE.HandlerOrdSetsEx Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

Parameter BUILD = 1;

/// 功能：查询套餐子项
/// parameter:  
/// 			AdmType: "TEAM"/"PERSON"
/// d ##class(%ResultSet).RunQuery("web.DHCPE.HandlerOrdSetsEx","queryOrdSet","","ItemSet")
Query queryOrdSet(Set As %String = "", Type As %String = "", AdmId As %String = "", TargetFrame As %String = "") As %Query(ROWSPEC = "OrderSetId:%String:ID,OrderSetDesc:%String:名称,IsBreakable:%String:是否拆分,OrderSetPrice:%String:价格")
{
}

ClassMethod queryOrdSetExecute(ByRef qHandle As %Binary, Set As %String = "", Type As %String = "", AdmId As %String = "", TargetFrame As %String = "") As %Status
{
 	Set repid=$I(^CacheTemp)
 	If $g(ind)="" Set ind=1
 	
 	if ((Set="")&&(Type="")&&(AdmId="")&&(TargetFrame="")){
	 Set qHandle=$lb(0,repid,0)
	Quit $$$OK	
 	}
    s vPatFeeType=""
 	s orderSetDesc=##class(web.DHCPE.DHCPECommon).UnEscape(Set)
	s orderSetDesc=$ZCVT(orderSetDesc,"U")
	s PELabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s PECodePrefix=^DHCPESetting("DHCPE","PEItemCodePrefix")
	s TrakVerison=$g(^DHCPESetting("DHCPE","TrakVerison"))
	
	s vVIPID=$G(^DHCPEVIPLevel("VIPapprove"))
 	s vPatFeeType=##class(web.DHCPE.VIPLevel).GetPatFeeType(vVIPID)
 	s AdmId=$P(AdmId,"^",1)
 	i AdmId'="" d
 	.i $L(AdmId,"||")>1 d
 	..s vVIPID=^DHCPEVIPLevel("PGT",AdmId)
 	..i vVIPID'="" d
 	...;s vVIPID=$P(^DHCPEVIPLevel("VIP",vVIPID),"^",7)
 	...s vVIPID=$P(^DHCPEVIPLevel("VIP",vVIPID),"^",8)
	..s vPatFeeType=$g(^DHCPEDataEx("DHCPEPreGADM","ADMFeeType",AdmId))
 	.e  d
 	..s vVIPID=##class(web.DHCPE.PreCommon).GetVIPLevel("Pre",AdmId)
 	..s vVIPID=$P(vVIPID,"^",1)
 	..i vVIPID'="" d
 	...;s vVIPID=$P(^DHCPEVIPLevel("VIP",vVIPID),"^",7)
 	...s vVIPID=$P(^DHCPEVIPLevel("VIP",vVIPID),"^",8)
 	...s vPatFeeType=$G(^DHCPEDataEx("DHCPEPreIADM","ADMFeeType",AdmId))
	e  d
	.s vVIPID=""
	.s vPatFeeType=""
	
	s AdmSex=##class(web.DHCPE.PreItemList).JustAdmSex(AdmId)
	s Sort=""
 	f  s Sort=$o(^DHCPEItemSort("Set",Sort)) q:Sort=""  d
 	.s Sub=0
 	.f  s Sub=$o(^DHCPEItemSort("Set",Sort,Sub)) q:Sub=""  d
 	..s Flag=0
 	..s SetId=$G(^DHCPEItemSort("Set",Sort,Sub))
 	..s ST=$O(^DHCPEST(0,"STORD_ARCOS",SetId,0))
 	..i ST=PELabStation s Flag=1
 	..q:(ST=PELabStation)&&(Type'="Lab")&&(Type'="")
 	..q:(ST'=PELabStation)&&(Type="Lab")&&(Type'="")
 	..d GetOneInfo
	s Sub=0
	f  s Sub=$o(^DHCPEST(PELabStation,"O",Sub)) q:(Sub="")||(TrakVerison'="MedTrak")||((Type'="")&&(Type="ItemSet"))  d
	.s Flag=1
	.s iARCIMDR=$p($g(^DHCPEST(PELabStation,"O",Sub)),"^",1)
	.s SetId=$p($g(^DHCPEST(PELabStation,"O",Sub)),"^",3)
	.s CurSort=$G(^DHCPEItemSort("Sort","Set",SetId))
	.q:CurSort'=""
	.d GetOneInfo
	
	s SetId="0"
	f  s SetId=$o(^ARCOS(SetId)) q:(SetId="")||((Type'="")&&(Type="Lab"))  d
	.s Flag=0
	.s CurSort=$G(^DHCPEItemSort("Sort","Set",SetId))
	.q:CurSort'=""
	.d GetOneInfo
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
GetOneInfo
	s myStr=$g(^ARCOS(SetId))
	Q:(""=myStr)
	///////判断医嘱套有效期
	s datefrom=$p(myStr,"^",15)
	if datefrom'=""
	{
		s datefrom=+datefrom
		q:(+datefrom>+$h)
	}
	s dateto=$p(myStr,"^",16)
	q:((dateto'="")&&(dateto<+$h))
	
	i Flag=0             
	{
		s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("ORDSET",SetId)
	}
	else
	{
		s StationID=0
		s StationID=$O(^DHCPEST(0,"STORD_ARCOS",SetId,0))
		q:StationID=""
		s ItemChildSub=$O(^DHCPEST(0,"STORD_ARCOS",SetId,StationID,0))
		s ItemID=StationID_"||"_ItemChildSub
		s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("ITEM",ItemID)
	}
	q:LocFlag=1  
	
	If $d(^DHCPESetting("DHCPEBaseData","PEARCOS",SetId))=1 Set Flag=1
	
	
	s myCode="", myDesc="",myBreakable="", mySetId=""
	s myCode=$p(myStr,"^",1)
	s myDesc=$p(myStr,"^",2)
	s myDesc=$ZCVT(myDesc,"U")
	S OrdSubCatDR=$p(myStr,"^",9)
	S ARCICDesc=""
	S:OrdSubCatDR'="" ARCICDesc=$p($g(^ARC("IC",OrdSubCatDR)),"^",2)
	q:ARCICDesc'["体检医嘱套"
	
	s SetSexDesc=""
	S SetSexID=$g(^DHCPEDataEx("DHCPEBaseData","Sex",SetId))
	i SetSexID'="" s SetSexDesc=$P($G(^CT("SEX",SetSexID)),"^",2)

	q:(myCode'[vVIPID)&&(vVIPID'="")
	//q:(myCode["IP")&&(vVIPID'["IP")&&(vVIPID'="")
	q:(AdmSex'=SetSexDesc)&&(SetSexDesc'="")&&(AdmId'="")
	
	
	//q:($extract(myCode,1,$l(PECodePrefix))'=PECodePrefix)&&(Flag=0)
	
	
	s ALIASRowId="0"
	s Flag=0
	f  s ALIASRowId=$O(^ARC("ALIAS",0,"ARCOS",SetId,ALIASRowId)) q:ALIASRowId=""  d
	.// ARC_Alias.ALIAS_Text
	.s ALIAS=""
	.s:(""'=ALIASRowId) ALIAS=$P($G(^ARC("ALIAS",ALIASRowId)),"^",6)
	.s ALIAS=$ZCVT(ALIAS,"U")
	.s:((""'=orderSetDesc)&(ALIAS[orderSetDesc)) Flag=1 
	s:((""'=orderSetDesc)&(myDesc[orderSetDesc)) Flag=1 
	i orderSetDesc="" s Flag=1
	q:Flag=0
	
	s mySetId=SetId
	;q:'$D(^DHCPEDataEx("DHCPEBaseData","taritem",mySetId))
	
	s mySetExId=$o(^DHCPEOSE(0,"OrdSets",mySetId,"0"))
	i mySetExId'="" s myBreakable=$p(^DHCPEOSE(mySetExId),"^",2)
	i $G(myBreakable)=""  s myBreakable="Y"
	
	//s:(""'=iARCIMDR)&&(Flag=1) ItemSetPrice=##class(web.DHCPE.Handle.ARCItmMast).GetItmPrice(iARCIMDR)
	//s:(""'=SetId)&&(Flag=0) ItemSetPrice=##class(web.DHCPE.Handle.ARCOrdSets).GetPrice(SetId)
	s:""'=SetId ItemSetPrice=##class(web.DHCPE.Handle.ARCOrdSets).GetPrice(SetId)
	i ItemSetPrice="" s ItemSetPrice=0
	do OutputRow1	
	q
 	
OutputRow1
	set Data=$lb(mySetId, myDesc, myBreakable, $j(ItemSetPrice,"",2))  //todo: Modify
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
	quit
}

ClassMethod queryOrdSetFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = queryOrdSetExecute ]
{
 	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {			
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else      {				
 		Set Row=^CacheTemp(repid,ind)
 	}
 	
 	s qHandle=$lb(AtEnd,repid,ind)
	Quit $$$OK
}

ClassMethod queryOrdSetClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = queryOrdSetFetch ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
 	Quit $$$OK
}

}
