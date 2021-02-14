Class web.DHCPE.OccupationalDisease Extends %Persistent
{

ClassMethod OutMain(PreIADM)
{
	q:PreIADM="" ""
	s VIPLevel=$p(^DHCPEPreIADM(PreIADM),"^",18)
	s IADMEx=""
	s IADMEx=$o(^User.DHCPEPreIADMExI("PreIADMID",PreIADM,IADMEx))
	w "<b>危害因素  "
	w "<button class='i-btn' style='width:10%;white-space:normal; word-break:break-all;' onclick='SaveEndanger()'>保存</button>"
	w "<TABLE border=1 cellspacing='0' cellpadding='0' style='white-space:normal; word-break:break-all;'>"
	s ETRowId=0
	f  s ETRowId=$o(^User.DHCPEEndangerTypeI("VIPLevelIndex",VIPLevel,ETRowId)) q:ETRowId=""  d
	.s ETDesc=$LG(^User.DHCPEEndangerTypeD(ETRowId),3)
	.s ETActive=$LG(^User.DHCPEEndangerTypeD(ETRowId),4)
	.Q:ETActive'="Y"

	.w "<TR><TD><b>"_ETDesc_"</TD></TR>"
	.w "<TR>"
	.s EDRowId=0
	.f  s EDRowId=$o(^User.DHCPEEndangerI("EDTypeIndex",ETRowId,EDRowId)) q:EDRowId=""  d
	..s EDDesc=$LG(^User.DHCPEEndangerD(EDRowId),3)
	..s Active=$LG(^User.DHCPEEndangerD(EDRowId),4)
	..q:Active'="Y"
	..s checked=""
	..i IADMEx'="" d
	...s obj=##class(User.DHCPEPreIADMEx).%OpenId(IADMEx)
	...s IADMED=$LG(^User.DHCPEPreIADMExD(IADMEx),9)
	...s EDLength=$LL(IADMED)
	...f i=1:1:EDLength d
	....s IADMEDId=$LG(IADMED,i)
	....i IADMEDId=EDRowId s checked="checked=checked"
	..w "<TD style='white-space:normal; word-break:break-all;'>"
	..w "<div style='width:100%;height:100%'>"
	..w "<input id="_EDRowId_" name="_EDDesc_"  type='checkbox'"_checked_">"_EDDesc
	..w "</TD>"
	.w "</TR>"
	w "</TABLE>"
}

ClassMethod SerchEndangerItemClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SerchEndangerItemExecute ]
{
	Set repid=$LIST(qHandle,2)
	 Kill ^CacheTemp(repid)
	 Quit $$$OK
}

/*
/// d ##class(%ResultSet).RunQuery("web.DHCPE.OccupationalDisease","SerchEndangerItem","54144")
ClassMethod SerchEndangerItemExecute(ByRef qHandle As %Binary, PreIADM As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	i PreIADM=""
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
 	}
 	k ^DHCPEOccutmp
 	s VIPLevel=$p(^DHCPEPreIADM(PreIADM),"^",18)
 	s IADMEx=""
	s IADMEx=$o(^User.DHCPEPreIADMExI("PreIADMID",PreIADM,IADMEx))
	s ETRowId=0
 	f  s ETRowId=$o(^User.DHCPEEndangerTypeI("VIPLevelIndex",VIPLevel,ETRowId)) q:ETRowId=""  d
	.s ETDesc=$LG(^User.DHCPEEndangerTypeD(ETRowId),3)
	.
	.s EDRowId=0
	.f  s EDRowId=$o(^User.DHCPEEndangerI("EDTypeIndex",ETRowId,EDRowId)) q:EDRowId=""  d
	..s EDDesc=$LG(^User.DHCPEEndangerD(EDRowId),3)
	..s checked=""
	..i IADMEx'="" d
	...s obj=##class(User.DHCPEPreIADMEx).%OpenId(IADMEx)
	...s IADMED=$LG(^User.DHCPEPreIADMExD(IADMEx),9)
	...s IADMType=$LG(^User.DHCPEPreIADMExD(IADMEx),3)
	...s EDLength=$LL(IADMED)
	...f i=1:1:EDLength d
	....s IADMEDId=$LG(IADMED,i)
	....i IADMEDId=EDRowId s checked="checked=checked"
 	....s ID=0
 	....f  s ID=$O(^User.DHCPEEndangerD(IADMEDId,"EDItemChild",ID)) q:ID=""  d
 	.....s Str=..GetOneItemInfo(IADMEDId_"||"_ID)
 	.....d FindBuild
		
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindBuild      
	//set Data=$lb(ArcimID,ArcimDesc,ArcimCode,Sort,ItemFlag,SetsSort)
	
	q:$P(Str,"^",4)'=IADMType
	q:($d(^DHCPEOccutmp("NeedItem",$P(Str,"^",5),$P(Str,"^",9))))
	s ^DHCPEOccutmp("NeedItem",$P(Str,"^",5),$P(Str,"^",9))=1
	
	set Data=$lb($P(Str,"^",9),$P(Str,"^",2),$P(Str,"^",1),$P(Str,"^",3),"",$P(Str,"^",5))
 	
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}*/
/// d ##class(%ResultSet).RunQuery("web.DHCPE.OccupationalDisease","SerchEndangerItem","282||1")
ClassMethod SerchEndangerItemExecute(ByRef qHandle As %Binary, PreIADM As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	i PreIADM=""
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
 	}
 	k ^DHCPEOccutmp
 	i '(PreIADM["||") d
 	.s VIPLevel=$p(^DHCPEPreIADM(PreIADM),"^",18)
 	.s IADMEx=""
	.s IADMEx=$o(^User.DHCPEPreIADMExI("PreIADMID",PreIADM,IADMEx))
	.s ETRowId=0
 	.f  s ETRowId=$o(^User.DHCPEEndangerTypeI("VIPLevelIndex",VIPLevel,ETRowId)) q:ETRowId=""  d
	..s ETDesc=$LG(^User.DHCPEEndangerTypeD(ETRowId),3)
	..
	..s EDRowId=0
	..f  s EDRowId=$o(^User.DHCPEEndangerI("EDTypeIndex",ETRowId,EDRowId)) q:EDRowId=""  d
	...s EDDesc=$LG(^User.DHCPEEndangerD(EDRowId),3)
	...s checked=""
	...i IADMEx'="" d
	....s obj=##class(User.DHCPEPreIADMEx).%OpenId(IADMEx)
	....s IADMED=$LG(^User.DHCPEPreIADMExD(IADMEx),9)
	....s IADMType=$LG(^User.DHCPEPreIADMExD(IADMEx),3)
	....s EDLength=$LL(IADMED)
	....f i=1:1:EDLength d
	.....s IADMEDId=$LG(IADMED,i)
	.....i IADMEDId=EDRowId s checked="checked=checked"
 	.....s ID=0
 	.....f  s ID=$O(^User.DHCPEEndangerD(IADMEDId,"EDItemChild",ID)) q:ID=""  d
 	......s Str=..GetOneItemInfo(IADMEDId_"||"_ID)
 	......d FindBuild
 	e  d
 	.s VIPLevel=$g(^DHCPEVIPLevel("PGT",PreIADM))
 	.s IADMED=$g(^DHCPEDataEx("DHCPEPreGADM","TeamEndanger",PreIADM))
 	.s IADMType=$g(^DHCPEDataEx("DHCPEPreGADM","OMEType",PreIADM))
 	.s ETRowId=0
 	.f  s ETRowId=$o(^User.DHCPEEndangerTypeI("VIPLevelIndex",VIPLevel,ETRowId)) q:ETRowId=""  d
	..s ETDesc=$LG(^User.DHCPEEndangerTypeD(ETRowId),3)
	..
	..s EDRowId=0
	..f  s EDRowId=$o(^User.DHCPEEndangerI("EDTypeIndex",ETRowId,EDRowId)) q:EDRowId=""  d
	...s EDDesc=$LG(^User.DHCPEEndangerD(EDRowId),3)
	...s checked=""
	...s EDLength=$L(IADMED,",")
	...f i=1:1:EDLength d
	....s IADMEDId=$p(IADMED,",",i)
	....i IADMEDId=EDRowId s checked="checked=checked"
 	....s ID=0
 	....f  s ID=$O(^User.DHCPEEndangerD(IADMEDId,"EDItemChild",ID)) q:ID=""  d
 	.....s Str=..GetOneItemInfo(IADMEDId_"||"_ID)
 	.....d FindBuild
		
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindBuild      
	//set Data=$lb(ArcimID,ArcimDesc,ArcimCode,Sort,ItemFlag,SetsSort)
	
	q:$P(Str,"^",4)'=IADMType
	q:($d(^DHCPEOccutmp("NeedItem",$P(Str,"^",5),$P(Str,"^",9))))
	s ^DHCPEOccutmp("NeedItem",$P(Str,"^",5),$P(Str,"^",9))=1
	
	set Data=$lb($P(Str,"^",9),$P(Str,"^",2),$P(Str,"^",1),$P(Str,"^",3),"",$P(Str,"^",5))
 	
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SerchEndangerItemFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SerchEndangerItemExecute ]
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
 	// , PatientNo As %String, SurName As %String, CurrentDept As %String, CurrentBed As %String, CurrentWard As %String, CurrentDoctor As %String, StartDate As %Date, EndDate As %Date, CurrentAdmType As %String, CONTEXT As %String
 	// Save QHandlePatientNo As %String, SurName As %String, CurrentDept As %String, CurrentBed As %String, CurrentWard As %String, CurrentDoctor As %String, StartDate As %Date, EndDate As %Date, CurrentAdmType As %String	
 	s qHandle=$lb(AtEnd,repid,ind)
 	Quit $$$OK
}

Query SerchEndangerItem(PreIADM As %String = "") As %Query(ROWSPEC = "ArcimID:%String,ArcimDesc:%String,ArcimCode:%String,NeedFlag:%String,ItemFlag:%String,SetsFlag:%String")
{
}

/// w ##class(web.DHCPE.OccupationalDisease).GetOneItemInfo("1||1")
ClassMethod GetOneItemInfo(ID)
{
	q:ID="" "^^^^^^^^^^^"
	s ID=$P(ID,"$",1)
	s obj=##class(User.DHCPEEDItem).%OpenId(ID)
	s ArcimID=obj.EDIItemMastID
	s TNeedFlag=obj.EDINeedFlag
	s TSetsFlag=obj.EDISetsFlag
	i TSetsFlag="Y" d
 	.s TArcimCode=$P(^ARCOS(+ArcimID),"^",1)
 	.s TArcimDesc=$P(^ARCOS(+ArcimID),"^",2)
 	e  d
 	.s TArcimCode=$P(^ARCIM(+ArcimID,1,1),"^",1)
 	.s TArcimDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ArcimID)
	s TOMEType=obj.EDIOMETypeDRGetObjectId() 
	s TActive=obj.EDIActive
	s TExpInfo=obj.EDIExpInfo
	s TRemark=obj.EDIRemark
	q TArcimCode_"^"_TArcimDesc_"^"_TNeedFlag_"^"_TOMEType_"^"_TSetsFlag_"^"_TActive_"^"_TExpInfo_"^"_TRemark_"^"_ArcimID
}

/// w ##class(web.DHCPE.OccupationalDisease).SaveOccu(51101,"1^2")
ClassMethod SaveOccu(PreIADM, Str)
{
	q:PreIADM="" "-1^无效病人ID"
	q:Str="" "-1^未选择危害因素"
	s IADMEx=""
	s IADMEx=$o(^User.DHCPEPreIADMExI("PreIADMID",PreIADM,IADMEx))
	i (IADMEx="") s obj=##class(User.DHCPEPreIADMEx).%New()
	e  s obj=##class(User.DHCPEPreIADMEx).%OpenId(IADMEx)
	d obj.PIEEndangers.Clear()
	d obj.PIEPreIADMIDSetObjectId(PreIADM)
	for i=1:1:$l(Str,"^") d
	.s EDRowId=$p(Str,"^",i)
	.q:EDRowId=""
	.d obj.PIEEndangers.Insert(EDRowId)
	s sc=obj.%Save()
	If ($System.Status.IsError(sc))	
	{
		Set myrtn = "-1^"_$System.Status.GetErrorText(sc)
	}
	else
	{
		s myrtn = obj.%Id()
	}
	d obj.%Close()
	q myrtn
}

/// w ##class(web.DHCPE.OccupationalDisease).SaveOccu2(51101,"1,2",1)
ClassMethod SaveOccu2(PreIADM, Str, Type, WorkType As %String = "", EndangerWorkAge As %String = "")
{
	q:PreIADM="" "-1^无效病人ID"
	q:Str="" "-1^未选择危害因素"
	s IADMEx=""
	s IADMEx=$o(^User.DHCPEPreIADMExI("PreIADMID",PreIADM,IADMEx))
	i (IADMEx="") s obj=##class(User.DHCPEPreIADMEx).%New()
	e  s obj=##class(User.DHCPEPreIADMEx).%OpenId(IADMEx)
	d obj.PIEEndangers.Clear()
	d obj.PIEPreIADMIDSetObjectId(PreIADM)
	for i=1:1:$l(Str,",") d
	.s EDRowId=$p(Str,",",i)
	.q:EDRowId=""
	.d obj.PIEEndangers.Insert(EDRowId)
	i Type'="" d
	.d obj.PIEOMETTypeIDSetObjectId(Type)
	i WorkType'="" d
	.d obj.PIEWorkTypeIDSetObjectId(WorkType)   //add 0731
	i EndangerWorkAge'="" d
	.s obj.PIEEndangerWorkAge=EndangerWorkAge    //add 0731
	s sc=obj.%Save()
	If ($System.Status.IsError(sc))	
	{
		Set myrtn = "-1^"_$System.Status.GetErrorText(sc)
	}
	else
	{
		s myrtn = obj.%Id()
	}
	d obj.%Close()
	q myrtn
}

/// w ##class(web.DHCPE.OccupationalDisease).GetOccuHistory("51092")
ClassMethod GetOccuHistory(PreIADM)
{
	s oldinfo=""
	q:PreIADM="" ""
	s PreBase=$p(^DHCPEPreIADM(PreIADM),"^",1)
	s BaseEx=""
	s BaseEx=$o(^User.DHCPEPreIBaseInfoExI("BaseInfoID",PreBase,BaseEx))
	q:(BaseEx="") ""
	s History=$LG(^User.DHCPEPreIBaseInfoExD(BaseEx),9)
 	s Length=$LL(History)
 	f i=1:1:Length d
	.s Str=$LG(History,i)
	.q:Str=""
	.s Str=$LISTTOSTRING(Str,"^")
	.i oldinfo="" s oldinfo=Str
	.e  s oldinfo=oldinfo_"$"_Str
	
	q oldinfo
}

ClassMethod GetOccuDiseaseHistory(PreIADM)
{
	s oldinfo=""
	q:PreIADM="" ""
	s PreBase=$p(^DHCPEPreIADM(PreIADM),"^",1)
	s BaseEx=""
	s BaseEx=$o(^User.DHCPEPreIBaseInfoExI("BaseInfoID",PreBase,BaseEx))
	q:(BaseEx="") ""
	s History=$LG(^User.DHCPEPreIBaseInfoExD(BaseEx),8)
 	s Length=$LL(History)
 	f i=1:1:Length d
	.s Str=$LG(History,i)
	.s Str=$LISTTOSTRING(Str,"^")
	.i oldinfo="" s oldinfo=Str
	.e  s oldinfo=oldinfo_"$"_Str
	
	q oldinfo
}

ClassMethod GetListDataByData(String)
{
	s ^sxt("S",String)=String
	q:(String="") ""
	s RealStr=$LISTFROMSTRING(String,"^")
	q RealStr
}

ClassMethod GetHisData(PreIADM)
{
	s ^sxt("a")=PreIADM
	q:PreIADM="" "无信息"
	s Str=""
	s PreBase=$p(^DHCPEPreIADM(PreIADM),"^",1)
	s BaseEx=""
	s BaseEx=$o(^User.DHCPEPreIBaseInfoExI("BaseInfoID",PreBase,BaseEx))
	q:(BaseEx="") "无信息"
	s ^sxt("b")=BaseEx
	s Str1=$LG(^User.DHCPEPreIBaseInfoExD(BaseEx),3)
	s Str2=$LG(^User.DHCPEPreIBaseInfoExD(BaseEx),4)
	s Str3=$lg($LG(^User.DHCPEPreIBaseInfoExD(BaseEx),5),1)
	s Str4=$lg($LG(^User.DHCPEPreIBaseInfoExD(BaseEx),6),1)
	s Str5=$lg($LG(^User.DHCPEPreIBaseInfoExD(BaseEx),7),1)
	s Str9=$lg($LG(^User.DHCPEPreIBaseInfoExD(BaseEx),12),1)
	s:(Str3="") Str6="^^^^"
	s ^sxt("data3")=Str3
	s:(Str3'="") Str6=$LISTTOSTRING(Str3,"^")	
	s:(Str4'="") Str7=$LISTTOSTRING(Str4,"^")
	s:(Str4="") Str7="^^"
	s:(Str5'="") Str8=$LISTTOSTRING(Str5,"^")
	s:(Str5="") Str8="^^"
	s:(Str9'="") Str10=$LISTTOSTRING(Str9,"^")
	s:(Str9="") Str10="^^^"
	
	s ^sxt("data2")=Str10
	s Str=Str1_"^"_Str2_"^"_Str6_"^"_Str7_"^"_Str8_"^"_Str10
	s ^sxt("data")=Str
	q Str
}

ClassMethod SaveDiseaseHistory(PreIADM, Str)
{
	q:PreIADM="" "-1^无效病人ID"
	
	s Str1=$p(Str,"^",1)
	s Str2=$p(Str,"^",2)
	s Str3=$p(Str,"^",3)
	s Str4=$p(Str,"^",4)
	s Str5=$p(Str,"^",5)
	s Str6=$p(Str,"^",6)
	s PreBase=$p(^DHCPEPreIADM(PreIADM),"^",1)
	s BaseEx=""
	s BaseEx=$o(^User.DHCPEPreIBaseInfoExI("BaseInfoID",PreBase,BaseEx))
	i (BaseEx="") s obj=##class(User.DHCPEPreIBaseInfoEx).%New()
	e  s obj=##class(User.DHCPEPreIBaseInfoEx).%OpenId(BaseEx)
	
	d obj.BIEBaseInfoIDSetObjectId(PreBase)
	
	
	
	s obj.BIEPastHistory=Str1
	
	
	s obj.BIEFamilyHistory=Str2
	
	d obj.BIEBearingHistory.Clear()
	d:('Str3) obj.BIEBearingHistory.Insert(Str3)
	
	d obj.BIESmokingHistory.Clear()
	
	d:('Str4) obj.BIESmokingHistory.Insert(Str4)
	
	d obj.BIEDrinkingHistory.Clear()
	d:('Str5) obj.BIEDrinkingHistory.Insert(Str5)
	
	d obj.BIEMenstrualHistory.Clear()
	d:('Str6) obj.BIEMenstrualHistory.Insert(Str6)
	
	s sc=obj.%Save()
	If ($System.Status.IsError(sc))	
	{
		Set myrtn = "-1^"_$System.Status.GetErrorText(sc)
	}
	else
	{
		s myrtn = obj.%Id()
	}
	d obj.%Close()
	q myrtn
}

ClassMethod SaveOccuHistory(PreIADM, Str)
{
	q:PreIADM="" "-1^无效病人ID"
	
	s StrLength=$L(Str,"$")
	s PreBase=$p(^DHCPEPreIADM(PreIADM),"^",1)
	s BaseEx=""
	s BaseEx=$o(^User.DHCPEPreIBaseInfoExI("BaseInfoID",PreBase,BaseEx))
	i (BaseEx="") s obj=##class(User.DHCPEPreIBaseInfoEx).%New()
	e  s obj=##class(User.DHCPEPreIBaseInfoEx).%OpenId(BaseEx)
	d obj.BIEOccupationalHistory.Clear()
	d obj.BIEBaseInfoIDSetObjectId(PreBase)
	for i=1:1:StrLength  d
	.q:$p(Str,"$",i)=""
	.s RealStr=""
	.s RealStr=$LISTFROMSTRING($p(Str,"$",i),"^")
	.d obj.BIEOccupationalHistory.Insert(RealStr)
	s sc=obj.%Save()
	If ($System.Status.IsError(sc))	
	{
		Set myrtn = "-1^"_$System.Status.GetErrorText(sc)
	}
	else
	{
		s myrtn = obj.%Id()
	}
	d obj.%Close()
	q myrtn
}

ClassMethod SaveOccuDiseaseHistory(PreIADM, Str)
{
	q:PreIADM="" "-1^无效病人ID"
	
	s StrLength=$L(Str,"$")
	s PreBase=$p(^DHCPEPreIADM(PreIADM),"^",1)
	s BaseEx=""
	s BaseEx=$o(^User.DHCPEPreIBaseInfoExI("BaseInfoID",PreBase,BaseEx))
	i (BaseEx="") s obj=##class(User.DHCPEPreIBaseInfoEx).%New()
	e  s obj=##class(User.DHCPEPreIBaseInfoEx).%OpenId(BaseEx)
	d obj.BIEOccupationalDiseaseHistory.Clear()
	d obj.BIEBaseInfoIDSetObjectId(PreBase)
	
	for i=1:1:StrLength  d
	.q:$p(Str,"$",i)=""
	.s RealStr=""
	.s RealStr=$LISTFROMSTRING($p(Str,"$",i),"^")
	.d obj.BIEOccupationalDiseaseHistory.Insert(RealStr)
	s sc=obj.%Save()
	If ($System.Status.IsError(sc))	
	{
		Set myrtn = "-1^"_$System.Status.GetErrorText(sc)
	}
	else
	{
		s myrtn = obj.%Id()
	}
	d obj.%Close()
	q myrtn
}

Query FindOccuHistory(PreIADM As %Library.String = "") As %Query(ROWSPEC = "TStartDate:%String,TEndDate:%String,TWorkPlace:%String,TWorkShop:%String,TWorkTeam:%String,TWorkTypeID:%String,TWorkType:%String,THarmfulFactor:%String, TProtectiveMeasureID:%String,TProtectiveMeasure:%String")
{
}

ClassMethod FindOccuHistoryExecute(ByRef qHandle As %Binary, PreIADM As %Library.String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	
 	if (PreIADM="")
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
 	
 	s PreBase=$p(^DHCPEPreIADM(PreIADM),"^",1)
 	if (PreBase="")
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
	s BaseEx=""
	s BaseEx=$o(^User.DHCPEPreIBaseInfoExI("BaseInfoID",PreBase,BaseEx))
	if (BaseEx="")
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
 	s History=$LG(^User.DHCPEPreIBaseInfoExD(BaseEx),9)
 	s Length=$LL(History)
 	f i=1:1:Length d
	.s Str=$LG(History,i)
	.s StartDate=##class(websys.Conversions).DateLogicalToHtml($LG(Str,1))
	.s EndDate=##class(websys.Conversions).DateLogicalToHtml($LG(Str,2))
	.s WorkPlace=$LG(Str,3)
	.s WorkShop=$LG(Str,4)
	.s WorkTeam=$LG(Str,5)
	.S WorkType=""
	.s WorkTypeID=$LG(Str,6)
	.I WorkTypeID'="" S WorkType=$LG(^User.DHCPEWorkTypeD(WorkTypeID),3)
	.s HarmfulFactor=$LG(Str,7)
	.S ProtectiveMeasure=""
	.s ProtectiveMeasureID=$LG(Str,8)
	.i ProtectiveMeasureID'="" s ProtectiveMeasure=$LG(^User.DHCPEProtectiveMeasuresD(ProtectiveMeasureID),3)
 	.d FindBuild	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindBuild      
	;set Data=Str
	set Data=$lb(StartDate,EndDate,WorkPlace,WorkShop,WorkTeam,WorkTypeID,WorkType,HarmfulFactor, ProtectiveMeasureID,ProtectiveMeasure)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindOccuHistoryFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindOccuHistoryExecute ]
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

ClassMethod FindOccuHistoryClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindOccuHistoryExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query FindOccuDiseaseHistory(PreIADM As %Library.String = "") As %Query(ROWSPEC = "TDiseaseDesc:%String,TDiagnosisDate:%String,TDiagnosisPlace:%String,TIsRecovery:%String")
{
}

ClassMethod FindOccuDiseaseHistoryExecute(ByRef qHandle As %Binary, PreIADM As %Library.String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	
 	if (PreIADM="")
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
 	
 	s PreBase=$p(^DHCPEPreIADM(PreIADM),"^",1)
 	if (PreBase="")
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
	s BaseEx=""
	s BaseEx=$o(^User.DHCPEPreIBaseInfoExI("BaseInfoID",PreBase,BaseEx))
	if (BaseEx="")
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
 	s History=$LG(^User.DHCPEPreIBaseInfoExD(BaseEx),8)
 	s Length=$LL(History)
 	f i=1:1:Length d
	.s Str=$LG(History,i)
	.s DiseaseDesc=$LG(Str,1) 
 	.s DiagnosisDate=$LG(Str,2) 
 	.s DiagnosisPlace=$LG(Str,3) 
 	.s IsRecovery=$LG(Str,4)
 	.s IsRecoveryDesc=""
 	.i IsRecovery="0" s IsRecoveryDesc="否"
 	.i IsRecovery="1" s IsRecoveryDesc="是"
 	.d FindBuild	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindBuild      
	//set Data=Str
	 set Data=$lb(DiseaseDesc,DiagnosisDate,DiagnosisPlace,IsRecoveryDesc) 
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindOccuDiseaseHistoryFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindOccuDiseaseHistoryExecute ]
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

ClassMethod FindOccuDiseaseHistoryClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindOccuDiseaseHistoryExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// 职业健康检查结果统计
Query OccuDiseaseSummary(GDesc As %Library.String = "") As %Query(ROWSPEC = "HPNo:%String,Name:%String,Sex:%String,Age:%String,EndangerWorkAge:%String,WorkType:%String,Endangers:%String,GeneralSummarize:%String,Suggestions:%String,Conclusion:%String") [ SqlProc ]
{
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.OccupationalDisease","OccuDiseaseSummary","职业病朱威")
ClassMethod OccuDiseaseSummaryExecute(ByRef qHandle As %Binary, GDesc As %Library.String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	
 	if (GDesc="")
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
	s GBID=$o(^DHCPEPreGBI(0,"Desc",GDesc,0))
	
	s GDesc=$o(^DHCPEPreGADM(0,"PGBI",GBID,0))
	;b ;hyl
	
	s TeamDR=0
	f  s TeamDR=$o(^DHCPEPreGADM(GDesc,"Team",TeamDR)) q:TeamDR=""  d
	.s PGTeamDR=GDesc_"||"_TeamDR
	.s PreIADM=0
	.f  s PreIADM=$o(^DHCPEPreIADM(0,"PGTeam",PGTeamDR,PreIADM)) q:PreIADM=""  d
 	..s VIP=$p(^DHCPEPreIADM(PreIADM),"^",18)
 	..i VIP=2 d
 	...;s HPNo=$p(^DHCPEPreIADM(PreIADM),"^",27)
  	...s PIBIDR=$p(^DHCPEPreIADM(PreIADM),"^",1)
  	...s HPNo=$p(^DHCPEPreIBI(PIBIDR),"^",1)
 	...s Name=$p(^DHCPEPreIBI(PIBIDR),"^",2)
 	...s SexDR=$p(^DHCPEPreIBI(PIBIDR),"^",3)
 	...s:SexDR'="" Sex=$p(^CT("SEX",SexDR),"^",2)
 	...s Age=$p($g(^DHCPEPreIBI(PIBIDR)),"^",4)
	...i Age'="" s Age=$P(##class(web.DHCLCNUREXCUTE).CalAge(Age,+$H),"Y",1)
	...s PreIADMEx=$o(^User.DHCPEPreIADMExI("PreIADMID",PreIADM,0))
	...s EndangerWorkAge=$LG(^User.DHCPEPreIADMExD(PreIADMEx),6)
	...s WorkType=$LG(^User.DHCPEPreIADMExD(PreIADMEx),8)
	...s:WorkType'="" WorkType=$LG(^User.DHCPEWorkTypeD(WorkType),3)
	...s IADMDR=$o(^DHCPEIADM(0,"CRMADM",PreIADM,0))
	...q:IADMDR=""
	...s GSID=$o(^DHCPEGS(0,"IADM",IADMDR,0))
	...q:GSID=""
	...s EndangersDR=$LG(^User.DHCPEPreIADMExD(PreIADMEx),9)
	...s Length=$LL(EndangersDR)
	...s Endangers=""
	...f j=1:1:Length d
	....s Str=$LG(EndangersDR,j)
	....s:Endangers'="" Endangers=Endangers_","_$LG(^User.DHCPEEndangerD(Str),3)
	....s:Endangers="" Endangers=$LG(^User.DHCPEEndangerD(Str),3)
	...s GSExID=$o(^User.DHCPEGeneralSummarizeExI("GeneralSummarizeID",GSID,0))
	...s TestResult=$LG(^User.DHCPEGeneralSummarizeExD(GSExID),7)
	...s Suggestions=$LG(^User.DHCPEGeneralSummarizeExD(GSExID),6)
	...s Conclusion=$LG(^User.DHCPEGeneralSummarizeExD(GSExID),3)
	...;s Conclusion=$LG(^User.DHCPEConclusionD(ConclusionID),3)
	...d OutputRow

	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
OutputRow      
	set Data=$lb(HPNo,Name,Sex,Age,EndangerWorkAge,WorkType,Endangers,TestResult,Suggestions,Conclusion)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod OccuDiseaseSummaryFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = OccuDiseaseSummaryExecute ]
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

ClassMethod OccuDiseaseSummaryClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = OccuDiseaseSummaryExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// 分组界面的危害因素
/// d ##class(web.DHCPE.OccupationalDisease).OutEndangers("64||1")
ClassMethod OutEndangers(TeamID)
{
	s VipLevel=""
	s ID=0
	f  s ID=$o(^DHCPEVIPLevel("VIP",ID)) q:ID=""  d
	.s Info=$G(^DHCPEVIPLevel("VIP",ID))
	.s VipDesc=$p(Info,"^",2)
	.s:VipDesc="职业病" VipLevel=ID
	w "<b>危害因素"
	w "<button class='i-btn' style='width:10%;white-space:normal; word-break:break-all;' onclick='SaveEndanger1()'>保存</button>"
	w "<TABLE border=1 cellspacing='0' cellpadding='0' style='white-space:normal; word-break:break-all;'>"
	s ETRowId=0
	f  s ETRowId=$o(^User.DHCPEEndangerTypeI("VIPLevelIndex",VipLevel,ETRowId)) q:ETRowId=""  d
	.s ETDesc=$LG(^User.DHCPEEndangerTypeD(ETRowId),3)
	.s Active=$LG(^User.DHCPEEndangerTypeD(ETRowId),4)
	.Q:Active'="Y"
	.w "<TR><TD><b>"_ETDesc_"</TD></TR>"
	.w "<TR>"
	.s EDRowId=0
	.f  s EDRowId=$o(^User.DHCPEEndangerI("EDTypeIndex",ETRowId,EDRowId)) q:EDRowId=""  d
	..s EDDesc=$LG(^User.DHCPEEndangerD(EDRowId),3)
	..s EDActive=$LG(^User.DHCPEEndangerD(EDRowId),4)
	..Q:EDActive'="Y"
	..s checked=""
	..i TeamID'="" d
	...s GTeamED=$g(^DHCPEDataEx("DHCPEPreGADM","TeamEndanger",TeamID))
	...s EDLength=$L(GTeamED,",")
	...f i=1:1:EDLength d
	....s GTeamEDId=$p(GTeamED,",",i)
	....i GTeamEDId=EDRowId s checked="checked=checked"
	..w "<TD style='white-space:normal; word-break:break-all;'>"
	..w "<div style='width:100%;height:100%'>"
	..w "<input id="_EDRowId_" name="_EDDesc_"  type='checkbox'"_checked_">"_EDDesc
	..w "</TD>"
	.w "</TR>"
	w "</TABLE>"
}

/// w ##class(web.DHCPE.OccupationalDisease).SaveTeam("274||1","1||2")
ClassMethod SaveTeam(RowId, Str)
{
	q:RowId="" "未选择团体"
	q:Str="" "-1^未选择危害因素"
	for i=1:1:$l(Str,"^") d
	.s EDRowId=$p(Str,"^",i)
	.q:EDRowId=""
	.s:^TeamEndanger("TeamED",RowId)'="" ^TeamEndanger("TeamED",RowId)=^TeamEndanger("TeamED",TeamID)_","_EDRowId
	.s:^TeamEndanger("TeamED",RowId)="" ^TeamEndanger("TeamED",RowId)=EDRowId
	q 0
}

/// w ##class(web.DHCPE.OccupationalDisease).GetEndanger("274","1")
ClassMethod GetEndanger(ParRef, ID)
{
	q:ParRef=""
	q:ID=""
	s TeamID=ParRef_"||"_ID 
	s Desc=""
	s IADMED=$g(^TeamEndanger("TeamED",TeamID))
	s EDLength=$L(IADMED,",")
	f i=1:1:EDLength d
	.s IADMEDId=$p(IADMED,",",i)
	.s Tmpdesc=$LG(^User.DHCPEEndangerD(IADMEDId),3)
	.s:(Desc'="") Desc=Desc_","_Tmpdesc
	.s:(Desc="") Desc=Tmpdesc
	q Desc
}

/// w ##class(web.DHCPE.OccupationalDisease).GetEndanger2("化学A,化学B")
ClassMethod GetEndanger2(Desc)
{
	q:Desc="" ""
	s EDLength=$l(Desc,",")
	s EDRowID=""
	f i=1:1:EDLength d
	.s EDDesc=$p(Desc,",",i)
	.s EDID=$o(^User.DHCPEEndangerI("EDDescIndex"," "_EDDesc,0))
	.s:(EDRowID'="") EDRowID=EDRowID_","_EDID
	.s:(EDRowID="") EDRowID=EDID
	q EDRowID
}

/// w ##class(web.DHCPE.OccupationalDisease).SetEndanger2("1,3")
ClassMethod SetEndanger2(ID)
{
	q:ID="" ""
	s EDLength=$l(ID,",")
	s EDDesc=""
	f i=1:1:EDLength d
	.s EDID=$p(ID,",",i)
	.s Desc=$LG(^User.DHCPEEndangerD(EDID),3)
	.s:(EDDesc'="") EDDesc=EDDesc_","_Desc
	.s:(EDDesc="") EDDesc=Desc
	q EDDesc
}

ClassMethod DateChangeNum(Date)
{
	Q:Date="" ""
	//s Date=$zdh(Date,1)
	s Date=##class(websys.Conversions).DateHtmlToLogical(Date)
	q Date
}

Storage Default
{
<Data name="OccupationalDiseaseDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.OccupationalDiseaseD</DataLocation>
<DefaultData>OccupationalDiseaseDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.OccupationalDiseaseD</IdLocation>
<IndexLocation>^web.DHCPE.OccupationalDiseaseI</IndexLocation>
<StreamLocation>^web.DHCPE.OccupationalDiseaseS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
