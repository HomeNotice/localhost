/// 选取预约日期
Class web.DHCPE.PreDate Extends (%RegisteredObject, %XML.Adaptor)
{

Query FindPreDate(Month As %String = "", PreIADMID As %String = "") As %Query(ROWSPEC = "TZ1:%String,TZ2:%String,TZ3:%String,TZ4:%String,TZ5:%String,TZ6:%String,TZ7:%String")
{
}

ClassMethod FindPreDateExecute(ByRef qHandle As %Binary, Month As %String = "", PreIADMID As %String = "") As %Status
{
	;d ##class(%ResultSet).RunQuery("web.DHCPE.PreManager","FindPreDate",62607)
	Set repid=$I(^CacheTemp)
 	s ind=1
 	i Month="" d
 	.s Month=+$H
 	e  d
 	.s Month=##class(websys.Conversions).DateHtmlToLogical(Month)
 	s DateStr=##class(websys.Conversions).DateLogicalToHtml(Month)
 	s DateStr=$E(DateStr,0,8)
 	s StartDateStr=DateStr_"01"
 	s StartDate=##class(websys.Conversions).DateHtmlToLogical(StartDateStr)
 	s EndDate=StartDate+32
 	s DateStr=##class(websys.Conversions).DateLogicalToHtml(EndDate)
 	s DateStr=$E(DateStr,0,8)
 	s EndDateStr=DateStr_"01"
 	s EndDate=##class(websys.Conversions).DateHtmlToLogical(EndDateStr)
 	s EndDate=EndDate-1
 	d ClearInfo
 	f Date=StartDate:1:EndDate
 	{	
 		s Week=$ZD(Date,10)
 		i Week=0 s Week=7
		s DateStr=##class(websys.Conversions).DateLogicalToHtml(Date)
		s Flag=1
		s PLIST(Week)=DateStr
		i Week=7 d
		.d FindAreaBuild
		.d ClearInfo
 	}
 	d:Flag=1 FindAreaBuild
 	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
ClearInfo
	s Flag=0
	s (PLIST(1),PLIST(2),PLIST(3),PLIST(4),PLIST(5),PLIST(6),PLIST(7))=""
	q
FindAreaBuild      
	set Data=$lb(PLIST(1),PLIST(2),PLIST(3),PLIST(4),PLIST(5),PLIST(6),PLIST(7))
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindPreDateFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindPreDateExecute ]
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

ClassMethod FindPreDateClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindPreDateExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// d ##class(web.DHCPE.PreDate).OutLink("2014-12-19","53")
ClassMethod OutLink(DateStr, LocID, PreIADMID, ExpStr As %String = "")
{
	i DateStr=""{
		 w ""
		 q
	}
	s Date=##class(websys.Conversions).DateHtmlToLogical(DateStr)
	s IDDate=##class(websys.Conversions).DateLogicalToHtml(Date)
	s Str=DateStr
	i Date<$H
	{
		s Str=DateStr_"<br><font color=red>不可用</font>"
		w "<button type='button' onclick=SetPreDate(this) id='0^"_IDDate_"'>"_Str_"</button>"
		q
	}
	i PreIADMID'="" d
	.s PreGADM=$P(^DHCPEPreIADM(PreIADMID),"^",2)
	.s PIBI=$P(^DHCPEPreIADM(PreIADMID),"^",1)
	.s CurSex=$P(^DHCPEPreIBI(PIBI),"^",3)
	.s CurVIP=$P(^DHCPEPreIADM(PreIADMID),"^",18)
	e  d
	.s PreGADM=""
	.s CurSex=$P(ExpStr,"^",1)
	.s CurVIP=$P(ExpStr,"^",2)
	s:CurVIP="" CurVIP=$G(^DHCPEVIPLevel("VIPapprove"))
	s LevelDesc=$P(^DHCPEVIPLevel("VIP",CurVIP),"^",2)
	s HPosition=6
	s Position=12  ;女
	s:CurSex=$P($G(^DHCPESetting("DHCPE","DefPatientType")),"^",4) Position=11
	s:CurSex=$P($G(^DHCPESetting("DHCPE","DefPatientType")),"^",4) HPosition=5
	
	s PreMID=""
	s PreNum=0
	i PreGADM'="" d ;团队的
	.s LastHomeID=##class(web.DHCPE.PreHome).GetLastHomeIDByGADM(PreGADM)
	.i LastHomeID'="" d
	..s PreType="O"
	..s LastHomeDate=$LG(^User.DHCPEPreHomeInfoD(LastHomeID),10)
	..i LastHomeDate<Date d  ;过期主场
	...s PreMID=$O(^User.DHCPEPreManagerI("LocDateIndex",LocID,Date,CurVIP,"O",""))
	..e  d  ;当天的主场人数
	...s PreType="H"
	...s HomeID=##class(web.DHCPE.PreHome).GetHomeIDByGADM(PreGADM,Date)
	...i HomeID'="" d
	....s PreNum=$LG(^User.DHCPEPreHomeInfoD(HomeID),HPosition)
	.e  d  ;普通团体
	..s PreType="G"
	..s PreMID=$O(^User.DHCPEPreManagerI("LocDateIndex",LocID,Date,CurVIP,"G",""))
	e  d ;个人
	.s PreType="I"
	.s PreMID=$O(^User.DHCPEPreManagerI("LocDateIndex",LocID,Date,CurVIP,"I",""))
	i PreMID'="" d
	.s PreNum=$LG(^User.DHCPEPreManagerD(PreMID),Position)
	
	s HadPreNum=0
	
	s AdmTime=""
	f  s AdmTime=$o(^DHCPEIADM(0,"AdmDateTime",Date,AdmTime)) q:AdmTime=""  d
	.s AdmID=""
	.f  s AdmID=$O(^DHCPEIADM(0,"AdmDateTime",Date,AdmTime,AdmID)) q:AdmID=""  d
	..s Status=$P(^DHCPEIADM(AdmID),"^",8)
	..q:(Status'="ARRIVED")&&(Status'="REGISTERED")
	..q:(Date<+$H)&&(Status'="ARRIVED")
	..s PreADMID=$P(^DHCPEIADM(AdmID),"^",4)
	..s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PreADMID)
	..q:LocFlag="1"
	..s GADMID=$P(^DHCPEPreIADM(PreADMID),"^",2)
	..s LastHomeID=##class(web.DHCPE.PreHome).GetLastHomeIDByGADM(GADMID)
	..q:(PreType="I")&&(GADMID'="")
	..q:((PreType="O")||(PreType="G"))&&(GADMID="") ;过期主场、普通主场、非团体人员退出
	..q:(PreType="H")&&(GADMID'=PreGADM)  ;主场的，非本团体的退出
	..q:(PreType="G")&&(LastHomeID'="") ;普通团体，设置过主场的退出
	..s QFlag=0
	..i PreType="O" d
	...s LastHomeDate=$LG(^User.DHCPEPreHomeInfoD(LastHomeID),10)
	...i (LastHomeDate+1)>Date d
	...s QFlag=1
	..q:QFlag="1"
	..s PIBIID=$P(^DHCPEPreIADM(PreADMID),"^",1)
	..s Sex=$P(^DHCPEPreIBI(PIBIID),"^",3)
	..q:Sex'=CurSex
	..s VIPLevel=$P(^DHCPEPreIADM(PreADMID),"^",18)
	..i VIPLevel="" s VIPLevel=$G(^DHCPEVIPLevel("VIPapprove"))
	..q:VIPLevel'=CurVIP
	..s HadPreNum=HadPreNum+1
	i PreType="I"
	{
		s RecordId = ""
		f  s RecordId = $o(^User.DHCPENetPreRecordI("PreDateIndex",Date,RecordId)) q:RecordId=""  do
		.s Preiadm = $lg(^User.DHCPENetPreRecordD(RecordId),2)
		.q:(Preiadm'="")
		.s Sex=$lg(^User.DHCPENetPreRecordD(RecordId),4)
		.q:Sex'=CurSex
		.s loc = $lg(^User.DHCPENetPreRecordD(RecordId),17)
		.q:(loc'=LocID)
		.s level = $lg(^User.DHCPENetPreRecordD(RecordId),16)
		.q:(level'=LevelDesc)
		.s HadPreNum=HadPreNum+1
	}
	i (HadPreNum+1)>PreNum d
	.s Str=DateStr_"<br><font color=red>不可用</font>"_"-"_PreNum_"-"_HadPreNum
	.w "<button type='button' onclick=SetPreDate(this) id='0^"_IDDate_"'>"_Str_"</button>"
	e  d
	.s Str=DateStr_"<br><font color=blue>可用</font>"_"-"_PreNum_"-"_HadPreNum
	.w "<button type='button' onclick=SetPreDate(this) id='1^"_IDDate_"'>"_Str_"</button>"
}

ClassMethod GetDefaultDate(LocID, PreIADMID, ExpStr As %String = "")
{
	i PreIADMID'="" d
	.s PreGADM=$P(^DHCPEPreIADM(PreIADMID),"^",2)
	.s PIBI=$P(^DHCPEPreIADM(PreIADMID),"^",1)
	.s CurSex=$P(^DHCPEPreIBI(PIBI),"^",3)
	.s CurVIP=$P(^DHCPEPreIADM(PreIADMID),"^",18)
	e  d
	.s PreGADM=""
	.s CurSex=$P(ExpStr,"^",1)
	.s CurVIP=$P(ExpStr,"^",2)
	s:CurVIP="" CurVIP=$G(^DHCPEVIPLevel("VIPapprove"))
	s LevelDesc=$P(^DHCPEVIPLevel("VIP",CurVIP),"^",2)
	/*
	i LevelDesc[("VIP")
	{
		q $ZD(+$H,4)
	}
	*/
	s HPosition=6
	s Position=12  ;女
	s:CurSex=$P($G(^DHCPESetting("DHCPE","DefPatientType")),"^",3) Position=11
	s:CurSex=$P($G(^DHCPESetting("DHCPE","DefPatientType")),"^",3) HPosition=5
	
	s DefaultDate=""
	s Date=+$H-1
	f  s Date=$o(^DHCPEIADM(0,"AdmDateTime",Date)) q:(Date="")||(DefaultDate'="")  d
	.s HadPreNum=0
	.s PreMID=""
	.s PreNum=0
	.i PreGADM'="" d ;团队的
	..i $D(^User.DHCPEPreHomeInfoI("DateRPGADMDrIndex",PreGADM)) d  ;设置过主场
	...s PreType="O"
	...s LastHomeDate=$O(^User.DHCPEPreHomeInfoI("DateRPGADMDrIndex",PreGADM,""),-1)  ;最后一个主场日期
	...i LastHomeDate<Date d  ;过期主场
	....s PreMID=$O(^User.DHCPEPreManagerI("LocDateIndex",LocID,Date,CurVIP,"O",""))
	...e  d  ;当天的主场人数
	....s PreType="H"
	....s HomeID=$O(^User.DHCPEPreHomeInfoI("DateRPGADMDrIndex",PreGADM,Date,""))
	....i HomeID'="" d
	.....s PreNum=$LG(^User.DHCPEPreHomeInfoD(HomeID),HPosition)
	..e  d  ;普通团体
	...s PreType="G"
	...s PreMID=$O(^User.DHCPEPreManagerI("LocDateIndex",LocID,Date,CurVIP,"G",""))
	.e  d ;个人
	..s PreType="I"
	..s PreMID=$O(^User.DHCPEPreManagerI("LocDateIndex",LocID,Date,CurVIP,"I",""))
	.i PreMID'="" d
	..s PreNum=$LG(^User.DHCPEPreManagerD(PreMID),Position)
	.q:+PreNum=0
	.s AdmTime=""
	.f  s AdmTime=$o(^DHCPEIADM(0,"AdmDateTime",Date,AdmTime)) q:AdmTime=""  d
	..s AdmID=""
	..f  s AdmID=$O(^DHCPEIADM(0,"AdmDateTime",Date,AdmTime,AdmID)) q:AdmID=""  d
	...s Status=$P(^DHCPEIADM(AdmID),"^",8)
	...q:(Status'="ARRIVED")&&(Status'="REGISTERED")
	...q:(Date<+$H)&&(Status'="ARRIVED")
	...s PreADMID=$P(^DHCPEIADM(AdmID),"^",4)
	...s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PreADMID)
	...q:LocFlag="1"
	...s GADMID=$P(^DHCPEPreIADM(PreADMID),"^",2)
	...q:(PreType="I")&&(GADMID'="")
	...q:((PreType="O")||(PreType="G"))&&(GADMID="") ;过期主场、普通主场、非团体人员退出
	...q:(PreType="H")&&(GADMID'=PreGADM)  ;主场的，非本团体的退出
	...q:(PreType="G")&&($D(^User.DHCPEPreHomeInfoI("DateRPGADMDrIndex",GADMID))) ;普通团体，设置过主场的退出
	...s QFlag=0
	...i PreType="O" d
	....s LastHomeDate=$O(^User.DHCPEPreHomeInfoI("DateRPGADMDrIndex",GADMID,""),-1)
	....i (LastHomeDate+1)>Date d
	....s QFlag=1
	...q:QFlag="1"
	...s PIBIID=$P(^DHCPEPreIADM(PreADMID),"^",1)
	...s Sex=$P(^DHCPEPreIBI(PIBIID),"^",3)
	...q:Sex'=CurSex
	...s VIPLevel=$P(^DHCPEPreIADM(PreADMID),"^",18)
	...i VIPLevel="" s VIPLevel=$G(^DHCPEVIPLevel("VIPapprove"))
	...q:VIPLevel'=CurVIP
	...s HadPreNum=HadPreNum+1
	.i PreType="I" d
	..s RecordId = ""
	..f  s RecordId = $o(^User.DHCPENetPreRecordI("PreDateIndex",Date,RecordId)) q:RecordId=""  do
	...s Preiadm = $lg(^User.DHCPENetPreRecordD(RecordId),2)
	...q:(Preiadm'="")
	...s Sex=$lg(^User.DHCPENetPreRecordD(RecordId),4)
	...q:Sex'=CurSex
	...s loc = $lg(^User.DHCPENetPreRecordD(RecordId),17)
	...q:(loc'=LocID)
	...s level = $lg(^User.DHCPENetPreRecordD(RecordId),16)
	...q:(level'=LevelDesc)
	...s HadPreNum=HadPreNum+1
	.i HadPreNum<PreNum d
	..s DefaultDate=Date
	s:DefaultDate'="" DefaultDate=##class(websys.Conversions).DateLogicalToHtml(DefaultDate)
	s:DefaultDate="" DefaultDate=##class(websys.Conversions).DateLogicalToHtml(+$h)
	q DefaultDate
}

}
