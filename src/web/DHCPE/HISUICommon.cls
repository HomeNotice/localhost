Class web.DHCPE.HISUICommon Extends %RegisteredObject
{

ClassMethod GetDefaultPAADM()
{
	
	q $G(^DHCPESetting("DHCPE","DefaultPAADM",%session.Get("LOGON.CTLOCID")))
}

Query FindBaseSetting() As websys.Query(ROWSPEC = "Loc,LocDesc,AutoArrived,AutoAuditUserID,AutoAuditUser,CashierSystem,PhyExamDrId,PhyExamDr,OrderInterfaceType,DefPrintType,CallVoice,CancelPEType,AllowCharge,MainDoctorGroup,ReportCode,HPNo,NetReport,SendOrder,ItemAbridgeFlag,AllowPrint,OrderInterface:%String,NewVerReport:%String")
{
}

ClassMethod FindBaseSettingExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	

	s id=0
	s LocList=$g(^DHCPESetting("DHCPE","PELoc"))
	s Length=$l(LocList,"^")
	
	f i=1:1:Length d
	.s Loc=$p(LocList,"^",i)
	.q:Loc=""
	.s LocDesc=""
	.s LocDesc=$p($g(^CTLOC(Loc)),"^",2)
	.s AutoArrived=$g(^DHCPESetting("DHCPE","AutoArrived",Loc))
	.s AutoArrived=$tr(AutoArrived,"Y","是")
	.s AutoArrived=$tr(AutoArrived,"N","否")
	.s AutoAuditUserID=$g(^DHCPESetting("DHCPE","AutoAuditUser",Loc))
	.S AutoAuditUser=""
	.I AutoAuditUserID'="" s AutoAuditUser=$p($g(^SSU("SSUSR",AutoAuditUserID)),"^",2)
   	.s CashierSystem=$g(^DHCPESetting("DHCPE","CashierSystem",Loc))
   	.i CashierSystem="1" s CashierSystem="个人视同收费"
   	.i CashierSystem="2" s CashierSystem="团体视同收费"
   	.i CashierSystem="3" s CashierSystem="都视同收费"
    .s PhyExamDrId=$g(^DHCPESetting("DHCPE","PhyExamDrId",Loc))
    .s PhyExamDr=""
    .i PhyExamDrId'="" s PhyExamDr=$p($g(^CTPCP(PhyExamDrId,1)),"^",2)
    .s OrderInterfaceType=$g(^DHCPESetting("DHCPE","OrderInterfaceType",Loc))
    .i OrderInterfaceType="N" s OrderInterfaceType="类方法"
    .e  s OrderInterfaceType="M程序"
    .s DefPrintType=$g(^DHCPESetting("DHCPE","DefPrintType",Loc))
    .s DefPrintType=$tr(DefPrintType,"Y","是")
	.s DefPrintType=$tr(DefPrintType,"N","否")
    
    .s CallVoice=$g(^DHCPESetting("DHCPE","CallVoice",Loc))
    .s CallVoice=$tr(CallVoice,"Y","是")
	.s CallVoice=$tr(CallVoice,"N","否")
    .s CancelPEType=$g(^DHCPESetting("DHCPE","CancelPEType",Loc))
    .i CancelPEType=1 s CancelPEType="不删除"
	.e  s CancelPEType="删除"
    .s AllowCharge=$g(^DHCPESetting("DHCPE","AllowCharge",Loc))
    .i AllowCharge=1 s AllowCharge="需要"
	.e  s AllowCharge="不需要"
    .s MainDoctorGroup=$g(^DHCPESetting("DHCPE","MainDoctorGroup",Loc))
    .s MainDoctorGroup=$tr(MainDoctorGroup,"Y","是")
	.s MainDoctorGroup=$tr(MainDoctorGroup,"N","否")
    .s ReportCode=$g(^DHCPESetting("DHCPE","ReportCode",Loc))
    .s HPNo=$g(^DHCPESetting("DHCPE","HPNo",Loc))
    .s NetReport=$g(^DHCPESetting("DHCPE","NetReport",Loc)) 
    .s NetReport=$tr(NetReport,"Y","是")
	.s NetReport=$tr(NetReport,"N","否") 
    .s SendOrder=$g(^DHCPESetting("DHCPE","SendOrder",Loc))
    .s SendOrder=$tr(SendOrder,"Y","是")
	.s SendOrder=$tr(SendOrder,"N","否") 
    .s ItemAbridgeFlag=$g(^DHCPESetting("DHCPE","ItemAbridgeFlag",Loc))
    .s AllowPrint=$g(^DHCPESetting("DHCPE","AllowPrint",Loc))
    .s AllowPrint=$tr(AllowPrint,"Y","是")
	.s AllowPrint=$tr(AllowPrint,"N","否")
    .s OrderInterface=$g(^DHCPESetting("DHCPE","OrderInterface",Loc))
    .s OrderInterface=$tr(OrderInterface,"Y","是")
	.s OrderInterface=$tr(OrderInterface,"N","否")
    .s NewVerReport=$g(^DHCPESetting("DHCPE","NewVerReport",Loc))
    .s NewVerReport=$tr(NewVerReport,"Y","是")
	.s NewVerReport=$tr(NewVerReport,"N","否")
	.s ^CacheTemp(repid,ind)=$lb(Loc,LocDesc,AutoArrived,AutoAuditUserID,AutoAuditUser,CashierSystem,PhyExamDrId,PhyExamDr,OrderInterfaceType,DefPrintType,CallVoice,CancelPEType,AllowCharge,MainDoctorGroup,ReportCode,HPNo,NetReport,SendOrder,ItemAbridgeFlag,AllowPrint,OrderInterface,NewVerReport)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

ClassMethod GetGADMByIADM(IADM)
{
	q:IADM="" ""
	
	q $p($G(^DHCPEPreIADM(IADM)),"^",2)
}

ClassMethod GetDefaultVIP(UserID)
{
	s VIPLevel=$g(^DHCPEDataEx("DefaultVIPLevel",UserID))
	i VIPLevel'="" s VIPLevel=$p($g(^DHCPEVIPLevel("VIP",VIPLevel)),"^",2)
	q VIPLevel
}

ClassMethod GetSettingByLoc(locid, parameter)
{
	i (parameter="LABDATA")||(parameter="MEDDATA") q $g(^DHCPESetting("NAMESPACE",parameter))
	i (parameter="SendRisApplication") q $g(^DHCPESetting("DHCPE","StationId_Ris",parameter))
	
	i $d(^DHCPESetting("DHCPE",parameter,locid)) q $g(^DHCPESetting("DHCPE",parameter,locid))
	q $g(^DHCPESetting("DHCPE",parameter))
}

ClassMethod GetDefaultPrintType()
{
	s Loc=%session.Get("LOGON.CTLOCID")
	q $G(^DHCPESetting("DHCPE","DefPrintType",Loc))
}

ClassMethod SetSettingByLoc(locid, parameter, value)
{
	i ("^"_$g(^DHCPESetting("DHCPE","PELoc")))'[("^"_locid_"^") s ^DHCPESetting("DHCPE","PELoc")=locid_"^"_$g(^DHCPESetting("DHCPE","PELoc"))
	s ^DHCPESetting("DHCPE",parameter,locid)=value
	/*
	s ^DHCPESetting("DHCPE","DefADMFeeType",locid)=""
	s ^DHCPESetting("DHCPE","DefaultPAADM",locid)=""
	s ^DHCPESetting("DHCPE","OEItemPrint",locid)="OEItemPrintA4"
	s ^DHCPESetting("DHCPE","PageModel",locid)="A4" 
	s ^DHCPESetting("DHCPE","SetsDefaultTar",locid)=""
	s ^DHCPESetting("DHCPE","PreOrder",locid)="0"
	*/
	q 0
}

ClassMethod SetSettingAllLoc(parameter, value)
{
	s ^DHCPESetting("DHCPE",parameter)=value
	/*
	s ^DHCPESetting("DHCPE","BilledMode")="New" 
	s ^DHCPESetting("DHCPE","BookDateLimit")="No"
	s ^DHCPESetting("DHCPE","CanChangePayModes")="1,2"
	s ^DHCPESetting("DHCPE","CashierMin")="100"
	s ^DHCPESetting("DHCPE","ClassName of CRMGateWay")="web.DHCPE.CRM.GatewayDHC"
	s ^DHCPESetting("DHCPE","GetHWOrder")=""
	s ^DHCPESetting("DHCPE","DefPatientType")="1^^2^1^20"
	s ^DHCPESetting("DHCPE","GroupPatNO_Begin")="00000000" 
	s ^DHCPESetting("DHCPE","GroupPatNO_CurNo")="" 
	s ^DHCPESetting("DHCPE","HospYBCode")="" 
	s ^DHCPESetting("DHCPE","HospitalCode")=""
	s ^DHCPESetting("DHCPE","HospitalName")=""
	s ^DHCPESetting("DHCPE","IAdmStatuses_Resultable")="^ARRIVED^CHARGED^COMPLETED^"
	s ^DHCPESetting("DHCPE","InvColSortType")="3"
	s ^DHCPESetting("DHCPE","InvFlag")="Y"
	s ^DHCPESetting("DHCPE","NoCodeLabItem")=""
	s ^DHCPESetting("DHCPE","NoReportStation")="" 
	s ^DHCPESetting("DHCPE","ODStr")=""
	s ^DHCPESetting("DHCPE","PAPMINo_GenModel")="NoGen"
	s ^DHCPESetting("DHCPE","PEItemCodePrefix")="PE"
	s ^DHCPESetting("DHCPE","PEPatType")="公费"
	s ^DHCPESetting("DHCPE","PESystemStartDate")=""
	s ^DHCPESetting("DHCPE","PatItemSort")=""
	s ^DHCPESetting("DHCPE","PatItemSortTemp")=""
	s ^DHCPESetting("DHCPE","PatNO_Begin")=""
	s ^DHCPESetting("DHCPE","PatOrdFlag")="0^0"
	s ^DHCPESetting("DHCPE","RegNoLength")="10"
	s ^DHCPESetting("DHCPE","ReportTitle")=""
	s ^DHCPESetting("DHCPE","RoundingFeeLimitMin")="50"
	s ^DHCPESetting("DHCPE","SSGroup_SummarizeAudit")=""
	s ^DHCPESetting("DHCPE","SalesDefaultDept")=""
	s ^DHCPESetting("DHCPE","SpecialPayModes")="1,2"
	s ^DHCPESetting("DHCPE","TarOCIsNew")="N"
	s ^DHCPESetting("DHCPE","StationId_NoAdvice")=""
	s ^DHCPESetting("DHCPE","StationId_NoSubmit")=""
	s ^DHCPESetting("DHCPE","TrakVerison")="TrakCare"
	s ^DHCPESetting("DHCPEBaseData","PEARCOS")=""
	s ^DHCPESetting("DHCPE","StationId_Ris","SendRisApplication")=""
	s ^DHCPESetting("DHCPE","AllowAddItem")=""
	*/
	q 0
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindCategory")
Query FindCategory() As websys.Query(ROWSPEC = "id:%String,Category:%String")
{
}

ClassMethod FindCategoryExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^User.DHCPEOMETypeD(id)) q:id=""  d
	.s Active=$LG(^User.DHCPEOMETypeD(id),4)
	.q:Active'="Y"
	.s VipLevel=$LG(^User.DHCPEOMETypeD(id),5)
	.s VIPDesc=""
	.i VipLevel'="" s VIPDesc=##class(web.DHCPE.PreCommon).GetVIPDescBYLevel(VipLevel)
	.q:VIPDesc'["职业病"
	.s Category=$LG(^User.DHCPEOMETypeD(id),3)
   
   

	.s ^CacheTemp(repid,ind)=$lb(id,Category)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindTypeofwork")
Query FindTypeofwork() As websys.Query(ROWSPEC = "id:%String,Typeofwork:%String")
{
}

ClassMethod FindTypeofworkExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	

	s id=0
	f  s id=$O(^User.DHCPEWorkTypeD(id)) q:id=""  d
	.s Active=$LG(^User.DHCPEWorkTypeD(id),4)
	.q:Active'="Y"
	.s Typeofwork=$LG(^User.DHCPEWorkTypeD(id),3)
		
   
   

	.s ^CacheTemp(repid,ind)=$lb(id,Typeofwork)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","ProtectiveMeasure")
Query FindProtectiveMeasure() As websys.Query(ROWSPEC = "id:%String,ProtectiveMeasure:%String")
{
}

ClassMethod FindProtectiveMeasureExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	

	s id=0
	f  s id=$O(^User.DHCPEProtectiveMeasuresD(id)) q:id=""  d

	.s Active=$LG(^User.DHCPEProtectiveMeasuresD(id),4)
	.q:Active'="Y"
	.s ProtectiveMeasure=$LG(^User.DHCPEProtectiveMeasuresD(id),3)
		
   
   

	.s ^CacheTemp(repid,ind)=$lb(id,ProtectiveMeasure)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindIndustry")
Query FindIndustry() As websys.Query(ROWSPEC = "id:%String,Industry:%String")
{
}

ClassMethod FindIndustryExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^User.DHCPEIndustryD(id)) q:id=""  d
	.s Active=$LG(^User.DHCPEIndustryD(id),4)
    .q:Active'="Y"
	.s Industry=$LG(^User.DHCPEIndustryD(id),3)
   
   

	.s ^CacheTemp(repid,ind)=$lb(id,Industry)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindPatFeeTypeName() As websys.Query(ROWSPEC = "id:%String,Desc:%String")
{
}

ClassMethod FindPatFeeTypeNameExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^PAC("SUBT",id)) q:id=""  d
	.s Desc=$P($G(^PAC("SUBT",id)),"^",2)
	.s ^CacheTemp(repid,ind)=$lb(id,Desc)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindSex")
Query FindSex() As websys.Query(ROWSPEC = "id:%String,sex:%String")
{
}

ClassMethod FindSexExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^CT("SEX",id)) q:id=""  d
	.s sex=$P($G(^CT("SEX",id)),"^",2)
	.s ^CacheTemp(repid,ind)=$lb(id,sex)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindPatFeeType() As websys.Query(ROWSPEC = "id:%String,desc:%String")
{
}

ClassMethod FindPatFeeTypeExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    s id=0
   	f  s id=$O(^PAC("SUBT",id)) q:id=""  d
	.s desc=$P($G(^PAC("SUBT",id)),"^",2)	
	.s ^CacheTemp(repid,ind)=$lb(id,desc)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindRoomPlace() As websys.Query(ROWSPEC = "id:%String,desc:%String")
{
}

ClassMethod FindRoomPlaceExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    s CurLoc=%session.Get("LOGON.CTLOCID")
    s id=0
	f  s id=$o(^DHCPEDataEx("RoomPlace",id)) q:id=""  d
	.s locid=$p($g(^DHCPEDataEx("RoomPlace",id)),"^",5)
	.q:locid'=CurLoc
	.s desc=$p($g(^DHCPEDataEx("RoomPlace",id)),"^",2)
	.s ^CacheTemp(repid,ind)=$lb(id,desc)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindPAPMICardType")
Query FindPAPMICardType() As websys.Query(ROWSPEC = "id:%String,type:%String")
{
}

ClassMethod FindPAPMICardTypeExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^PAC("CARD",id)) q:id=""  d
	.s type=$P($G(^PAC("CARD",id)),"^",2)
	.s ^CacheTemp(repid,ind)=$lb(id,type)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindVIP() As websys.Query(ROWSPEC = "id:%String,desc:%String")
{
}

ClassMethod FindVIPExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$o(^DHCPEVIPLevel("VIP",id)) q:id=""  d
	.s use=$p($g(^DHCPEVIPLevel("VIP",id)),"^",4)
	.q:use'="Y"
	.s desc=$p($g(^DHCPEVIPLevel("VIP",id)),"^",2)
	.s ^CacheTemp(repid,ind)=$lb(id,desc)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindRPFlag() As websys.Query(ROWSPEC = "id:%String,desc:%String")
{
}

ClassMethod FindRPFlagExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    s ^CacheTemp(repid,1)=$lb("Y","是")
    s ^CacheTemp(repid,2)=$lb("N","否")
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindMarried() As websys.Query(ROWSPEC = "id:%String,married:%String")
{
}

ClassMethod FindMarriedExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^CT("MAR",id)) q:id=""  d
	.
	.s married=$P($G(^CT("MAR",id)),"^",2)
	.
	.s ^CacheTemp(repid,ind)=$lb(id,married)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindCardType")
Query FindCardType() As websys.Query(ROWSPEC = "id:%String,cardtype:%String")
{
}

ClassMethod FindCardTypeExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^DHCCARDTYPEDef(id)) q:id=""  d
	.
	.s cardtype=$P($G(^DHCCARDTYPEDef(id)),"^",2)
	.s dateto=$P($G(^DHCCARDTYPEDef(id)),"^",10)
	.
	.q:(dateto'="")&&(dateto<+$h)
	.s ^CacheTemp(repid,ind)=$lb(id,cardtype)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindPayMode() As websys.Query(ROWSPEC = "id:%String,text:%String")
{
}

ClassMethod FindPayModeExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^CT("CTPM",id)) q:id=""  d
	.
	.s paymode=$P($G(^CT("CTPM",id)),"^",2)
	.
	.s ^CacheTemp(repid,ind)=$lb(id,paymode)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindUser() As websys.Query(ROWSPEC = "id:%String,name:%String")
{
}

ClassMethod FindUserExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^SSU("SSUSR",id)) q:id=""  d
	.s name=$p(^SSU("SSUSR",id),"^",2)
	.S Initials=$p(^SSU("SSUSR",id),"^",1)
	.s name=name_"("_Initials_")"
	.s ^CacheTemp(repid,ind)=$lb(id,name)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindAuditUser",1)
Query FindAuditUser(StationID) As websys.Query(ROWSPEC = "id:%String,name:%String")
{
}

ClassMethod FindAuditUserExecute(ByRef qHandle As %Binary, StationID) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    s Job=$j
    
    k ^TempDHCPEDoc(Job)
    s UserID=%session.Get("LOGON.USERID")
	s LocID=%session.Get("LOGON.CTLOCID")
	s GroupID=%session.Get("LOGON.GROUPID")
	s ^tempdhcpe("FindAuditUser")=StationID_"^"_UserID
	s UserID=""
	f  s UserID=$O(^DHCPEDataEx("ChartAssign",UserID)) q:UserID=""  d
	.s GroupID=""
	.f  s GroupID=$O(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID)) q:GroupID=""  d
	..q:$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))'="Y"
	..s ^TempDHCPEDoc(Job,UserID)=""
    
    s id=""
	f  s id=$O(^TempDHCPEDoc(Job,id)) q:id=""  d
	.s name=$P($G(^SSU("SSUSR",id)),"^",2)
	.
	.s ^CacheTemp(repid,ind)=$lb(id,name)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindFeeTypeSuperGroup() As websys.Query(ROWSPEC = "id:%String,desc:%String")
{
}

ClassMethod FindFeeTypeSuperGroupExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^SSU("SSGRP",id)) q:id=""  d
	.
	.s desc=$p(^SSU("SSGRP",id),"^",1)
	.
	.s ^CacheTemp(repid,ind)=$lb(id,desc)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindLoc() As websys.Query(ROWSPEC = "id:%String,loc:%String")
{
}

ClassMethod FindLocExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s id=0
	f  s id=$O(^CTLOC(id)) q:id=""  d
	.
	.s loc=$p(^CTLOC(id),"^",2)
	.
	.s ^CacheTemp(repid,ind)=$lb(id,loc)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindStation() As websys.Query(ROWSPEC = "id:%String,desc:%String")
{
}

ClassMethod FindStationExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
    s id=0
	f  s id=$O(^DHCPEST(id)) q:id=""  d
	.s Active=$p($g(^DHCPEST(id)),"^",5)
	.q:Active'="Y"
	.q:LabStation=id
	.s desc=$P($G(^DHCPEST(id)),"^",2)
	.s ^CacheTemp(repid,ind)=$lb(id,desc)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

Query FindStationBase() As websys.Query(ROWSPEC = "id:%String,desc:%String")
{
}

ClassMethod FindStationBaseExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
    s id=0
	f  s id=$O(^DHCPEST(id)) q:id=""  d
	.s Active=$p($g(^DHCPEST(id)),"^",5)
	.q:Active'="Y"
	.s desc=$P($G(^DHCPEST(id)),"^",2)
	.s ^CacheTemp(repid,ind)=$lb(id,desc)
	.s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

/// w ##class(web.DHCPE.HISUICommon).GetVIP()
ClassMethod GetVIP()
{
	s val=$G(^DHCPEDataEx("DefaultVIPLevel",%session.Get("LOGON.USERID"))) 
	s:val="" val=$G(^DHCPEVIPLevel("VIPapprove"))
	q val
}

ClassMethod GetDefault()
{
	s ret=$G(^DHCPESetting("DHCPE","DefPatientType"))
	q "{""ret"":"""_ret_"""}"
}

ClassMethod GetOpenCharge()
{
	s ret=$G(^DHCPEDataEx("OpenCharge",%session.Get("LOGON.USERID")))
	q ret
}

ClassMethod SetOpenCharge(flag)
{
	s ^DHCPEDataEx("OpenCharge",%session.Get("LOGON.USERID"))=flag
	q 0
}

/// w ##class(web.DHCPE.HISUICommon).GetHarmInfo()
ClassMethod GetHarmInfo()
{
	s VIPLevel=3
	s ETRowId=0,str=""
	f  s ETRowId=$o(^User.DHCPEEndangerTypeI("VIPLevelIndex",VIPLevel,ETRowId)) q:ETRowId=""  d
	.s ETDesc=$LG(^User.DHCPEEndangerTypeD(ETRowId),3)
	.s ETActive=$LG(^User.DHCPEEndangerTypeD(ETRowId),4)
	.Q:ETActive'="Y"
	.s children=""
	.s EDRowId=0
	.f  s EDRowId=$o(^User.DHCPEEndangerI("EDTypeIndex",ETRowId,EDRowId)) q:EDRowId=""  d
	..s EDDesc=$LG(^User.DHCPEEndangerD(EDRowId),3)
	..s Active=$LG(^User.DHCPEEndangerD(EDRowId),4)
	..q:Active'="Y"
	..i children="" s children="{"_"""id"":"_EDRowId_","_"""text"":"""_EDDesc_"""}"
	..e  s children=children_",{"_"""id"":"_EDRowId_","_"""text"":"""_EDDesc_"""}"
	.s:children'="" children="["_children_"]"
	.i str="" s str="{"_"""id"":"_ETRowId_","_"""text"":"""_ETDesc_""","_"""children"":"_children_"}"
	.e  s str=str_","_"{"_"""id"":"_ETRowId_","_"""text"":"""_ETDesc_""","_"""children"":"_children_"}"
	s str="["_str_"]"
	q str
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindStationInfo")
Query FindStationInfo() As websys.Query(ROWSPEC = "StationID:%String,StationDesc:%String")
{
}

ClassMethod FindStationInfoExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    s StationID=1
	s StationDesc=$p($g(^DHCPEST(StationID)),"^",2)			
	s ^CacheTemp(repid,ind)=$lb(StationID,StationDesc)
	s ind=ind+1
    
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

ClassMethod GetCashierPayMode()
{
	s PayMode=0,PayModeStr=""
	f  s PayMode=$o(^DHCPESetting("DHCPE","CashierMode",PayMode)) q:PayMode=""  d
	.i $g(^DHCPESetting("DHCPE","CashierMode",PayMode))="Y" d
	..i PayModeStr="" s PayModeStr=PayMode
	..e  s PayModeStr=PayModeStr_"^"_PayMode
	q PayModeStr
}

ClassMethod SetCashierPayMode(str)
{
	k ^DHCPESetting("DHCPE","CashierMode")
	s strlength=$L(str,"^")
	f i=1:1:strlength d
	.s paymode=$p(str,"^",i)
	.i paymode'="" s ^DHCPESetting("DHCPE","CashierMode",paymode)="Y"
	
	q 0
}

ClassMethod GetCardPayMode()
{
	s PayMode=0,PayModeStr=""
	f  s PayMode=$o(^DHCPESetting("DHCPE","CardMode",PayMode)) q:PayMode=""  d
	.i $g(^DHCPESetting("DHCPE","CardMode",PayMode))="Y" d
	..i PayModeStr="" s PayModeStr=PayMode
	..e  s PayModeStr=PayModeStr_"^"_PayMode
	q PayModeStr
}

ClassMethod SetCardPayMode(str)
{
	k ^DHCPESetting("DHCPE","CardMode")
	s strlength=$L(str,"^")
	f i=1:1:strlength d
	.s paymode=$p(str,"^",i)
	.i paymode'="" s ^DHCPESetting("DHCPE","CardMode",paymode)="Y"
	
	q 0
}

ClassMethod GetRefundPayMode()
{
	s PayMode=0,PayModeStr=""
	f  s PayMode=$o(^DHCPESetting("DHCPE","RefundMode",PayMode)) q:PayMode=""  d
	.i $g(^DHCPESetting("DHCPE","RefundMode",PayMode))="Y" d
	..i PayModeStr="" s PayModeStr=PayMode
	..e  s PayModeStr=PayModeStr_"^"_PayMode
	q PayModeStr
}

ClassMethod SetRefundPayMode(str)
{
	k ^DHCPESetting("DHCPE","RefundMode")
	s strlength=$L(str,"^")
	f i=1:1:strlength d
	.s paymode=$p(str,"^",i)
	.i paymode'="" s ^DHCPESetting("DHCPE","RefundMode",paymode)="Y"
	
	q 0
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.HISUICommon","FindOMEType")
Query FindOMEType() As websys.Query(ROWSPEC = "id:%String,Desc:%String")
{
}

ClassMethod FindOMETypeExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1 
    
    s id=0
    f  s id=$o(^User.DHCPEOMETypeD(id)) q:id=""  d
    .s Desc=$LG($g(^User.DHCPEOMETypeD(id)),3)
	.s ^CacheTemp(repid,ind)=$lb(id,Desc)
	.s ind=ind+1 
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
}

}
