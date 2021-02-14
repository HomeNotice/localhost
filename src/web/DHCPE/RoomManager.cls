Class web.DHCPE.RoomManager Extends %Persistent
{

ClassMethod UpdateArea(ID, InfoStr)
{
	;w ##class(web.DHCPE.RoomManager).UpdateArea("","01^普通一区^1^40^1")
	if ID="" d
	.s obj=##class(User.DHCPEArea).%New()
	e  d
	.s obj=##class(User.DHCPEArea).%OpenId(ID)
	s obj.ACode=$P(InfoStr,"^",1)
	s obj.ADesc=$P(InfoStr,"^",2)
	s obj.ASort=$P(InfoStr,"^",3)
	s obj.ALocDR=$P(InfoStr,"^",4)
	s obj.APEType=$P(InfoStr,"^",5)
	s obj.AAreaFlag=$P(InfoStr,"^",6)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod UpdateRoom(ID, InfoStr)
{
	;w ##class(web.DHCPE.RoomManager).UpdateRoom("","1^01^内科1诊室^1^M^PRE^EE^1^备注")
	if ID="" d
	.s obj=##class(User.DHCPERoom).%New()
	.d obj.RParrefSetObjectId($P(InfoStr,"^",1))
	e  d
	.s obj=##class(User.DHCPERoom).%OpenId(ID)
	s obj.RCode=$P(InfoStr,"^",2)
	s obj.RDesc=$P(InfoStr,"^",3)
	s obj.RSort=$P(InfoStr,"^",4)
	s obj.RSex=$P(InfoStr,"^",5)
	s obj.RDietFlag=$P(InfoStr,"^",6)
	s obj.REmictionFlag=$P(InfoStr,"^",7)
	s obj.RStationDR=$P(InfoStr,"^",8)
	s obj.RRemark=$P(InfoStr,"^",9)
	s obj.RMinute=$P(InfoStr,"^",10)
	s obj.RDoctor=$P(InfoStr,"^",11)
	s obj.RActiveFlag=$P(InfoStr,"^",12)
	s obj.RShowNum=$P(InfoStr,"^",13)
	s obj.RBindFlag=$p(InfoStr,"^",14)
	s obj.RPEType=$p(InfoStr,"^",15)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod ActiveRoom(RoomID, ActiveFlag)
{
	s obj=##class(User.DHCPERoom).%OpenId(RoomID)
	s obj.RActiveFlag=ActiveFlag
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod UpdateRoomMinute(RoomID, Minute)
{
	;w ##class(web.DHCPE.RoomManager).UpdateRoomMinute("1||2","4")
	s Minute=+Minute
	q:'(Minute>0) "-1^时间设置不正确"
	s obj=##class(User.DHCPERoom).%OpenId(RoomID)
	s obj.RMinute=Minute
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod ModifyRoom(RoomID, StrInfo)
{
	;w ##class(web.DHCPE.RoomManager).ModifyRoom("1||2","F^4^Y")
	s obj=##class(User.DHCPERoom).%OpenId(RoomID)
	s obj.RSex=$P(StrInfo,"^",1)
	s obj.RMinute=$P(StrInfo,"^",2)
	s obj.RActiveFlag=$P(StrInfo,"^",3)
	s BarPrint=$P(StrInfo,"^",4)
	s BGEquipe=$P(StrInfo,"^",5)
	s ^DHCPEDataEx("Room","PrintBar",RoomID)=BarPrint
	s ^DHCPEDataEx("Room","BGEquipe",RoomID)=BGEquipe
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

/*
ClassMethod ModifyRoom(RoomID, StrInfo)
{
	;w ##class(web.DHCPE.RoomManager).ModifyRoom("1||2","F^4^Y")
	s obj=##class(User.DHCPERoom).%OpenId(RoomID)
	s obj.RSex=$P(StrInfo,"^",1)
	s obj.RMinute=$P(StrInfo,"^",2)
	s obj.RActiveFlag=$P(StrInfo,"^",3)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}
*/

/*
ClassMethod UpdateSpecimen(ID, InfoStr, Type)
{
	;w ##class(web.DHCPE.RoomManager).UpdateSpecimen("","1||1^SP01")
	i Type="SP"{
		if ID="" d
		.s obj=##class(User.DHCPERoomSpecimen).%New()
		.d obj.RSParRefSetObjectId($P(InfoStr,"^",1))
		e  d
		.s obj=##class(User.DHCPERoomSpecimen).%OpenId(ID)
		s obj.RSSpecimen=$P(InfoStr,"^",2)
	}elseif Type="IP"{
		if ID="" d
		.s obj=##class(User.DHCPERoomIP).%New()
		.d obj.RIParRefSetObjectId($P(InfoStr,"^",1))
		e  d
		.s obj=##class(User.DHCPERoomIP).%OpenId(ID)
		s obj.RIIP=$P(InfoStr,"^",2)
	}else{
		if ID="" d
		.s obj=##class(User.DHCPERoomSpecialRoom).%New()
		.d obj.RSRParRefSetObjectId($P(InfoStr,"^",1))
		e  d
		.s obj=##class(User.DHCPERoomSpecialRoom).%OpenId(ID)
		s obj.RSRRoomID=$P(InfoStr,"^",2)
	}
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}
*/
ClassMethod UpdateSpecimen(ID, InfoStr, Type)
{
	;w ##class(web.DHCPE.RoomManager).UpdateSpecimen("","1||1^SP01")
	
	S SpecCode=$P(InfoStr,"^",2)
	S Code=""

	i Type="SP"{
		if ID="" d
		.s obj=##class(User.DHCPERoomSpecimen).%New()
		.d obj.RSParRefSetObjectId($P(InfoStr,"^",1))
		e  d
		.s obj=##class(User.DHCPERoomSpecimen).%OpenId(ID)
		.s Code=$LG(^User.DHCPEAreaD(+ID,"ChildRoom",$P(ID,"||",2),"childSpecimen",$P(ID,"||",3)),2)
	    q:(SpecCode'=Code)&&($d(^User.DHCPERoomSpecimenI("SpecimenIndex",$p($p(InfoStr,"^",1),"||",1),$p($p(InfoStr,"^",1),"||",2)," "_SpecCode))) "-1^标本重复!"	
		s obj.RSSpecimen=$P(InfoStr,"^",2)
	}elseif Type="IP"{
		if ID="" d
		.s obj=##class(User.DHCPERoomIP).%New()
		.d obj.RIParRefSetObjectId($P(InfoStr,"^",1))
		e  d
		.s obj=##class(User.DHCPERoomIP).%OpenId(ID)
		q:$d(^User.DHCPERoomIPI("IPIndex"," "_SpecCode)) "-1^电脑IP重复!"
		s obj.RIIP=$P(InfoStr,"^",2)
	}elseif Type="RP"{
		if ID="" d
		.s obj=##class(User.DHCPERoomRoomPlace).%New()
		.d obj.parrefRoomSetObjectId($P(InfoStr,"^",1))
		e  d
		.s obj=##class(User.DHCPERoomRoomPlace).%OpenId(ID)
		s obj.RRPRoomPlace=$P(InfoStr,"^",2)
	}else{
		if ID="" d
		.s obj=##class(User.DHCPERoomSpecialRoom).%New()
		.d obj.RSRParRefSetObjectId($P(InfoStr,"^",1))
		e  d
		.s obj=##class(User.DHCPERoomSpecialRoom).%OpenId(ID)
		s obj.RSRRoomID=$P(InfoStr,"^",2)
	}
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

/*
ClassMethod DeleteSpecimen(ID, Type)
{
	;w ##class(web.DHCPE.RoomManager).UpdateSpecimen("","1||1^SP01")
	i Type="SP"{
		s obj=##class(User.DHCPERoomSpecimen).%New()
	}elseif Type="IP"{
		s obj=##class(User.DHCPERoomIP).%New()
	}else{
		s obj=##class(User.DHCPERoomSpecialRoom).%New()
	}
	s sc=obj.%DeleteId(ID)
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}
*/
ClassMethod DeleteSpecimen(ID, Type)
{
	;w ##class(web.DHCPE.RoomManager).UpdateSpecimen("","1||1^SP01")
	i Type="SP"{
		s obj=##class(User.DHCPERoomSpecimen).%New()
	}elseif Type="IP"{
		s obj=##class(User.DHCPERoomIP).%New()
	}elseif Type="RP"{
		s obj=##class(User.DHCPERoomRoomPlace).%New()
	}else{
		s obj=##class(User.DHCPERoomSpecialRoom).%New()
	}
	s sc=obj.%DeleteId(ID)
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod UpdateRoomRecord(ID, InfoStr, DelayRoomFlag As %String = "")
{
	;w ##class(web.DHCPE.RoomManager).UpdateRoomRecord("70","1||3^^^^^^^1")
	if (ID="")&&($P(InfoStr,"^",3)'="O")
	{
		s CurRoomInfo=..GetAdmCurRoom($P(InfoStr,"^",1),"ADM")
		q:CurRoomInfo'="" "" 
	}
	if ID="" d
	.s obj=##class(User.DHCPEAdmRoomRecord).%New()
	.s OldRoomID=""
	e  d
	.s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(ID)
	.s OldRoomID=obj.ARRRoomDR
	i $P(InfoStr,"^",1)'="" s obj.ARRAdmDR=$P(InfoStr,"^",1)
	i $P(InfoStr,"^",2)'="" s obj.ARRRoomDR=$P(InfoStr,"^",2)
	i $P(InfoStr,"^",3)'="" s obj.ARRStatus=$P(InfoStr,"^",3)
	i $P(InfoStr,"^",4)'="" s obj.ARRStatusDetail=$P(InfoStr,"^",4)
	i DelayRoomFlag'="" s obj.ARRStatusDetail=""  ;顺延
	i $P(InfoStr,"^",5)'="" s obj.ARRDate=$P(InfoStr,"^",5)
	i $P(InfoStr,"^",6)'="" s obj.ARRCreateTime=$P(InfoStr,"^",6)
	i $P(InfoStr,"^",7)'="" s obj.ARRInTime=$P(InfoStr,"^",7)
	i $P(InfoStr,"^",8)'="" s obj.ARROutTime=$P(InfoStr,"^",8)
	i $P(InfoStr,"^",9)'="" s obj.ARRRoomSort=$P(InfoStr,"^",9)
	i $P(InfoStr,"^",10)'="" d obj.ARRUserDRSetObjectId($P(InfoStr,"^",10))
	i $P(InfoStr,"^",11)'="" d obj.ARRCreateUserDRSetObjectId($P(InfoStr,"^",11))
	
	s sc=obj.%Save()
	b ;sc
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		//叫号接口
		s RoomID=$LG(^User.DHCPEAdmRoomRecordD(obj.%Id()),6)
		s:$D(%session) UserID=%session.Get("LOGON.USERID")
		s:'$D(%session) UserID=5930	
		i (OldRoomID'="")&&(OldRoomID'=RoomID) d
		.d ##class(web.DHCPE.CallVoice.Main).SendVoice(OldRoomID,UserID)
		d ##class(web.DHCPE.CallVoice.Main).SendVoice(RoomID,UserID,$P(InfoStr,"^",4))
		//叫号接口OVER
		q obj.%Id()
	}
}

ClassMethod GetOneAreaInfo(ID)
{
	q:ID="" "^^^^^^^^^^^"
	s obj=##class(User.DHCPEArea).%OpenId(ID)
	s Code=obj.ACode
	s Desc=obj.ADesc
	s Sort=obj.ASort
	s LocDR=obj.ALocDR
	s LocDesc=""
	s:LocDR'="" LocDesc=$P(^CTLOC(LocDR),"^",2)
	s PEType=obj.APEType
	s PETypeDesc=""
	s:PEType'="" PETypeDesc=$P($G(^DHCPEVIPLevel("VIP",PEType)),"^",2)
	s AreaFlag=obj.AAreaFlag
	q Code_"^"_Desc_"^"_Sort_"^"_LocDR_"^"_LocDesc_"^"_PEType_"^"_PETypeDesc_"^"_AreaFlag
}

ClassMethod GetOneRoomInfo(ID)
{
	q:ID="" "^^^^^^^^^^^"
	s ID=$P(ID,"$",1)
	s obj=##class(User.DHCPERoom).%OpenId(ID)
	s Code=obj.RCode
	s Desc=obj.RDesc
	s Sort=obj.RSort
	s Sex=obj.RSex
	s SexDesc=..GetSexDesc(Sex)
	s DietFlag=obj.RDietFlag
	s DietDesc=..GetDietDesc(DietFlag)
	s EmictionFlag=obj.REmictionFlag
	s EmictionDesc=..GetEmictionDesc(EmictionFlag)
	s StationDR=obj.RStationDR
	s StationDesc=""
	s:StationDR'="" StationDesc=$P($g(^DHCPEST(StationDR)),"^",2)
	s Remark=obj.RRemark
	s Minute=obj.RMinute
	s DoctorDR=obj.RDoctor
	s DoctorDesc=""
	s:DoctorDR'="" DoctorDesc=$P($G(^SSU("SSUSR",DoctorDR)),"^",2)
	s ActiveFlag=obj.RActiveFlag
	s ShowNum=obj.RShowNum
	s Ifbangding=obj.RBindFlag
	s VIPLevel=obj.RPEType
	s VIPLevelDesc=""
	;s:VIPLevel'="" VIPLevelDesc=$P($G(^DHCPEVIPLevel("VIP",VIPLevel)),"^",2)
	s:VIPLevel'="" VIPLevelDesc=$P($G(^DHCPEDataEx("RoomPlace",VIPLevel)),"^",2)
	q Code_"^"_Desc_"^"_Sort_"^"_Sex_"^"_SexDesc_"^"_DietFlag_"^"_DietDesc_"^"_EmictionFlag_"^"_EmictionDesc_"^"_StationDR_"^"_StationDesc_"^"_Remark_"^"_Minute_"^"_DoctorDR_"^"_DoctorDesc_"^"_ActiveFlag_"^"_ShowNum_"^"_Ifbangding_"^"_VIPLevel_"^"_VIPLevelDesc
}

Query FindArea() As %Query(ROWSPEC = "TID:%String,TCode:%String,TDesc:%String,TSort:%String,TPEType:%String,TAreaFlag:%String")
{
}

ClassMethod FindAreaExecute(ByRef qHandle As %Binary) As %Status
{
	;d ##class(%ResultSet).RunQuery("web.DHCPE.RoomManager", "FindArea")
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s id=0
 	s LocID=%session.Get("LOGON.CTLOCID")
	f  s id=$o(^User.DHCPEAreaI("ALocDRIndex"," "_LocID,id)) q:id=""  d
	.s Str=..GetOneAreaInfo(id)
	.d FindAreaBuild	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindAreaBuild
	//w $P(Str,"^",8),!  
	set Data=$lb(id,$P(Str,"^",1),$P(Str,"^",2),$P(Str,"^",3),$P(Str,"^",7),$P(Str,"^",8))
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindAreaFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindAreaExecute ]
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

ClassMethod FindAreaClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindAreaExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query FindRoom(Parref As %Library.String = "") As %Query(ROWSPEC = "TID:%String,TCode:%String,TDesc:%String,TSort:%String,TSex:%String,TDiet:%String,TEmiction:%String,TStation:%String,TRemark:%String,TMinute:%String,TDoctorDesc:%String,TActiveFlag:%String,TShowNum:%String,TIFBangding:%String,TVIPLevelID:%String,TVIPLevelDesc:%String")
{
}

ClassMethod FindRoomExecute(ByRef qHandle As %Binary, Parref As %Library.String = "") As %Status
{
	;d ##class(%ResultSet).RunQuery("web.DHCPE.RoomManager", "FindRoom","1")
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s id=0
 	f  s id=$o(^User.DHCPEAreaD(Parref,"ChildRoom",id)) q:id=""  d
	.s Str=..GetOneRoomInfo(Parref_"||"_id)
	.d FindRoomBuild	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindRoomBuild 
	;										Code_"^"_Desc_"^"_Sort_"^"_Sex_"^"_SexDesc_"^"_DietFlag_"^"_DietDesc_"^"_EmictionFlag_"^"_EmictionDesc_"^"_StationDR_"^"_StationDesc_"^"_Remark_"^"_Minute_"^"_TDoctorDesc_"^"_TActiveFlag_"^"_TShowNum_"^"_TIFBangding_"^"_TVIPLevelID_"^"_TVIPLevelDesc
	set Data=$lb(Parref_"||"_id,$P(Str,"^",1),$P(Str,"^",2),$P(Str,"^",3),$P(Str,"^",5),$P(Str,"^",7),$P(Str,"^",9),$P(Str,"^",11),$P(Str,"^",12),$P(Str,"^",13),$P(Str,"^",15),$P(Str,"^",16),$P(Str,"^",17),$p(Str,"^",18),$p(Str,"^",19),$p(Str,"^",20))
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindRoomFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindRoomExecute ]
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

ClassMethod FindRoomClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindRoomExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query FindRoomSpecimen(Parref As %Library.String = "", Type As %String = "") As %Query(ROWSPEC = "TID:%String,TSpecimenDR:%String,TSpecimen:%String")
{
}

/*
ClassMethod FindRoomSpecimenExecute(ByRef qHandle As %Binary, Parref As %Library.String = "", Type) As %Status
{
	;d ##class(%ResultSet).RunQuery("web.DHCPE.RoomManager", "FindRoomSpecimen","1||1")
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s id=0
 	
 	i Type="SP" d
 	.f  s id=$o(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childSpecimen",id)) q:id=""  d
	..s SpecimenDR=$LG(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childSpecimen",id),2)
	..s Specimen=$P($G(^TTAB("SPEC",SpecimenDR)),"\",1)
	..d FindRoomSpecimenBuild	
	e  i Type="IP" d
	.f  s id=$o(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childIP",id)) q:id=""  d
	..s SpecimenDR=$LG(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childIP",id),2)
	..s Specimen=SpecimenDR
	..d FindRoomSpecimenBuild	
	e  d
	.f  s id=$o(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childSpecialRoom",id)) q:id=""  d
	..s SpecimenDR=$LG(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childSpecialRoom",id),2)
	..s obj=##class(User.DHCPERoom).%OpenId(SpecimenDR)
	..s Specimen=obj.RDesc
	..d FindRoomSpecimenBuild
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindRoomSpecimenBuild 
	set Data=$lb(Parref_"||"_id,SpecimenDR,Specimen)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}
*/
ClassMethod FindRoomSpecimenExecute(ByRef qHandle As %Binary, Parref As %Library.String = "", Type) As %Status
{
	;d ##class(%ResultSet).RunQuery("web.DHCPE.RoomManager", "FindRoomSpecimen","1||1")
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s id=0
 	s LisNewVersion=$g(^DHCPESetting("DHCPE","LisNewVersion"))
 	i Type="SP" d
 	.f  s id=$o(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childSpecimen",id)) q:id=""  d
	..s SpecimenDR=$LG(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childSpecimen",id),2)
	..i LisNewVersion="Y" D
	...S ID=$O(^dbo.BTSpecimenI("IndexCode",1," "_SpecimenDR,0))
	...I ID'="" S Specimen=$LG(^dbo.BTSpecimenD(ID),3)
	..e  d
	...s:SpecimenDR'="" Specimen=$P($G(^TTAB("SPEC",SpecimenDR)),"\",1)

	..d FindRoomSpecimenBuild	
	e  i Type="IP" d
	.f  s id=$o(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childIP",id)) q:id=""  d
	..s SpecimenDR=$LG(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childIP",id),2)
	
	..s Specimen=SpecimenDR
	..d FindRoomSpecimenBuild	
	e  i Type="RP" d
	.f  s id=$o(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childRoomPlace",id)) q:id=""  d
	..s SpecimenDR=$LG(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childRoomPlace",id),2)
	..s Specimen=""
	..s:SpecimenDR'="" Specimen=$p($g(^DHCPEDataEx("RoomPlace",SpecimenDR)),"^",2)
	..d FindRoomSpecimenBuild	
	e  d
	.f  s id=$o(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childSpecialRoom",id)) q:id=""  d
	..s SpecimenDR=$LG(^User.DHCPEAreaD(+Parref,"ChildRoom",$P(Parref,"||",2),"childSpecialRoom",id),2)
	..i SpecimenDR'="" d
	...s obj=##class(User.DHCPERoom).%OpenId(SpecimenDR)
	...s Specimen=obj.RDesc
	..e  d
	...s Specimen=""
	..d FindRoomSpecimenBuild
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindRoomSpecimenBuild 
	set Data=$lb(Parref_"||"_id,SpecimenDR,Specimen)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindRoomSpecimenFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindRoomSpecimenExecute ]
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

ClassMethod FindRoomSpecimenClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindRoomSpecimenExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query FindRoomRecord() As %Query(ROWSPEC = "PatientID:%String,EpisodeID:%String,TRegNo:%String,TName:%String,TSex:%String,TAge:%String,TGroupDesc:%String,TTeamDesc:%String,TCardID:%String,TVipLevel:%String,TStatus:%String")
{
}

ClassMethod FindRoomRecordExecute(ByRef qHandle As %Binary) As %Status
{
	;d ##class(%ResultSet).RunQuery("web.DHCPE.RoomManager", "FindRoomRecord")
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s IP=..GetIPAndName()
 	w IP,!
 	s IP=$P(IP,"^",1)
 	s AreaID=$O(^User.DHCPERoomIPI("IPIndex"," "_IP,""))
 	i AreaID'=""
 	{
 		s RoomSub=$O(^User.DHCPERoomIPI("IPIndex"," "_IP,AreaID,""))
 		s RoomID=AreaID_"||"_RoomSub
 	}
 	else
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
 	}
 	s TStatus="已叫"
 	s AdmID=""
 	f  s AdmID=$O(^User.DHCPEAdmRoomRecordI("StatusIndex"," P"," "_RoomID,AdmID)) q:AdmID=""  d
	.d OneInfo
	s TStatus="等候"
 	s AdmID=""
 	f  s AdmID=$O(^User.DHCPEAdmRoomRecordI("StatusIndex"," N"," "_RoomID,AdmID)) q:AdmID=""  d
	.s ID=$O(^User.DHCPEAdmRoomRecordI("StatusIndex"," N"," "_RoomID,AdmID,0))
	.d OneInfo
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
OneInfo	
	s EpisodeID=$P(AdmID," ",2)
	s PatientID=$P(^PAADM(EpisodeID),"^",1)
	s TRegNo=$P(^PAPER(PatientID,"PAT",1),"^",1)
	s TName=$P(^PAPER(PatientID,"ALL"),"^",1)
	s TCardID=$P(^PAPER(PatientID,"PAT",3),"^",6)
	s TSex=$P(^PAPER(PatientID,"ALL"),"^",7)
	S:TSex'="" TSex=$P(^CT("SEX",TSex),"^",2)
	s TAge=$P(^PAPER(PatientID,"ALL"),"^",6)
	s:TAge'="" TAge=$ZD(TAge,3)
	s PADM=$O(^DHCPEIADM(0,"PAADM",EpisodeID,0))
	q:PADM=""
	s PreADM=$P(^DHCPEIADM(PADM),"^",4)
	s TGroupDesc=$P(^DHCPEPreIADM(PreADM),"^",2)
	s:TGroupDesc'="" TGroupDesc=$P(^DHCPEPreGADM(TGroupDesc),"^",1)
	s:TGroupDesc'="" TGroupDesc=$P(^DHCPEPreGBI(TGroupDesc),"^",2)
	s TTeamDesc=$P(^DHCPEPreIADM(PreADM),"^",3)
	s:TTeamDesc'="" TTeamDesc=$P(^DHCPEPreGADM(+TTeamDesc,"Team",$P(TTeamDesc,"||",2)),"^",1)
	s TVipLevel=$P(^DHCPEPreIADM(PreADM),"^",18)
	s:TVipLevel'="" TVipLevel=$p($g(^DHCPEVIPLevel("VIP",TVipLevel)),"^",2)
	
	d FindRoomRecordBuild	
	q 
FindRoomRecordBuild 
	set Data=$lb(PatientID,EpisodeID,TRegNo,TName,TSex,TAge,TGroupDesc,TTeamDesc,TCardID,TVipLevel,TStatus)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindRoomRecordFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindRoomRecordExecute ]
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

ClassMethod FindRoomRecordClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindRoomRecordExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query FindRoomPerson(VIPLevel As %String = "", NoActive As %String = "") As %Query(ROWSPEC = "TRoomID:%String,TRoomName:%String,TPersonNum:%String,TNewPerson:%String,TPassPerson:%String,TWaitMiniute:%String,TActive:%String")
{
}

ClassMethod FindRoomPersonExecute(ByRef qHandle As %Binary, VIPLevel As %String = "", NoActive As %String = "") As %Status
{
	;d ##class(%ResultSet).RunQuery("web.DHCPE.RoomManager", "FindRoomPerson","1")
	Set repid=$I(^CacheTemp)
 	s Job=$J
 	d ##class(web.DHCPE.RoomManager).DeleteNoUserRoomInfo()
 	i VIPLevel=""
 	{
	 	
	 	//w "<font color=red><b>诊室位置不能为空</b></font>"
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
 	}
 	i NoActive'="" d
 	.s Active="N"
 	e  d
 	.s Active="Y"
 	s ind=1
 	s Parref=0
 	f  s Parref=$O(^User.DHCPEAreaD(Parref)) q:Parref=""  d
 	.s id=0
 	.f  s id=$o(^User.DHCPEAreaD(Parref,"ChildRoom",id)) q:id=""  d
	..s Str=..GetOneRoomInfo(Parref_"||"_id)
	..s RoomDesc=$P(Str,"^",2)
	..s RoomVIPLevel=$P(Str,"^",19)
	..;q:(RoomVIPLevel'="")&&(VIPLevel'=RoomVIPLevel)
	..q:'$D(^User.DHCPERoomRoomPlaceI("RoomPlaceIndex",Parref,id," "_VIPLevel))
	..;q:RoomDesc["B"
	..s Miniute=$P(Str,"^",13)
	..s ActiveFlag=$P(Str,"^",16)
	..q:Active'=ActiveFlag
	..s ActiveLevel=2
	..i ActiveFlag="Y" d
	...s ActiveLevel=1
	..s RoomID=Parref_"||"_id
	..s NewPerson=..GetTotalPersonByRoom(RoomID,"N")
	..s PassPerson=..GetTotalPersonByRoom(RoomID,"P")
	..s TotalPerson=NewPerson  //+PassPerson
	..s TotalMinute=TotalPerson*Miniute
	..s Sort=$i(^TempDHCPERoomPerson(Job))
	..s ^TempDHCPERoomPerson(Job,ActiveLevel,TotalMinute,TotalPerson,Sort)=RoomID_"^"_RoomDesc_"^"_NewPerson_"^"_PassPerson_"^"_ActiveFlag
	s ActiveLevel=0
	f  s ActiveLevel=$O(^TempDHCPERoomPerson(Job,ActiveLevel)) q:ActiveLevel=""  d
	.s Minute=""
	.f  s Minute=$O(^TempDHCPERoomPerson(Job,ActiveLevel,Minute),-1) q:Minute=""  d
	..s Person=""
	..f  s Person=$O(^TempDHCPERoomPerson(Job,ActiveLevel,Minute,Person)) q:Person=""  d
	...s Sort=0
	...f  s Sort=$O(^TempDHCPERoomPerson(Job,ActiveLevel,Minute,Person,Sort)) q:Sort=""  d
	....s RoomInfo=$G(^TempDHCPERoomPerson(Job,ActiveLevel,Minute,Person,Sort))
	....s RoomID=$P(RoomInfo,"^",1)
	....s RoomDesc=$P(RoomInfo,"^",2)
	....s NewPerson=$P(RoomInfo,"^",3)
	....s PassPerson=$P(RoomInfo,"^",4)
	....s ActiveFlag=$P(RoomInfo,"^",5)
	....;s PersonInfo=Person_"("_NewPerson_","_PassPerson_")"
	....d FindRoomPersonBuild
	k ^TempDHCPERoomPerson(Job)
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindRoomPersonBuild 
	set Data=$lb(RoomID,RoomDesc,Person,NewPerson,PassPerson,Minute,ActiveFlag)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindRoomPersonFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindRoomPersonExecute ]
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

ClassMethod FindRoomPersonClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindRoomPersonExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query FindRoomPersonDetail(RoomID As %String = "") As %Query(ROWSPEC = "TRecordID:%String,TRegNo:%String,TName:%String,TSex:%String,TBirth:%String,TTel:%String,TStatus:%String,TPAADM:%String,TIND:%String,TAge:%String")
{
}

ClassMethod FindRoomPersonDetailExecute(ByRef qHandle As %Binary, RoomID As %String = "") As %Status
{
	;d ##class(%ResultSet).RunQuery("web.DHCPE.RoomManager", "FindRoomPersonDetail","1")
	Set repid=$I(^CacheTemp)
 	s Job=$J
 	s ind=1
 	s RoomID=$P(RoomID,"$",1)
 	if RoomID=""
	{
		Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
	
 	s RecordID=""
 	s TRegNo="等待列表"
 	s (TName,TSex,TBirth,TTel,Status,PaadmID)=""
 	d FindRoomPersonDetailBuild
 	k ^TempDHCPERoomManager(Job,"CheckingInfo")
 	s Index=0
 	s Sort=""
	f  s Sort=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," N"," "_RoomID,Sort)) q:Sort=""  d
	.s AdmID=""
	.f  s AdmID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," N"," "_RoomID,Sort,AdmID)) q:AdmID=""  d
	..s RecordID=""
	..f  s RecordID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," N"," "_RoomID,Sort,AdmID,RecordID)) q:RecordID=""  d
	...s DetailStatus=$LG(^User.DHCPEAdmRoomRecordD(RecordID),9)
	...i DetailStatus="E"  d
	....s ^TempDHCPERoomManager(Job,"CheckingInfo",Sort,RecordID,AdmID)=""
	...q:DetailStatus="E"
	...s PaadmID=$P(AdmID," ",2)
	...s BaseInfo=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PaadmID)
	...;PatName_"^"_Sex_"^"_Birth_"^"_IDCard_"^"_RegNo
	...s TRegNo=$P(BaseInfo,"^",5)
	...s TName=$P(BaseInfo,"^",1)
	...s TSex=$P(BaseInfo,"^",2)
	...s TBirth=$P(BaseInfo,"^",3)
	...s TAge=""
	...s TAge=##class(websys.Conversions).DateHtmlToLogical(TBirth)
	...i TAge'="" s TAge=$P(##class(web.DHCLCNUREXCUTE).CalAge(TAge,+$H),"Y",1)
	...s TTel=$P(BaseInfo,"^",6)
	...s Status="N"
	...s Index=Index+1
	...d FindRoomPersonDetailBuild
	i $D(^TempDHCPERoomManager(Job,"CheckingInfo")) d
	.s Index=""
	.s RecordID=""
 	.s TRegNo="正检列表"
 	.s (TName,TSex,TBirth,TTel,Status,PaadmID)=""
 	.d FindRoomPersonDetailBuild
 	.s Index=0
 	.s Sort=""
 	.f  s Sort=$O(^TempDHCPERoomManager(Job,"CheckingInfo",Sort)) q:Sort=""  d
 	..s RecordID=""
 	..f  s RecordID=$O(^TempDHCPERoomManager(Job,"CheckingInfo",Sort,RecordID)) q:RecordID=""  d
 	...s AdmID=""
 	...f  s AdmID=$O(^TempDHCPERoomManager(Job,"CheckingInfo",Sort,RecordID,AdmID)) q:AdmID=""  d
 	....s PaadmID=$P(AdmID," ",2)
	....s BaseInfo=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PaadmID)
	....;PatName_"^"_Sex_"^"_Birth_"^"_IDCard_"^"_RegNo
	....s TRegNo=$P(BaseInfo,"^",5)
	....s TName=$P(BaseInfo,"^",1)
	....s TSex=$P(BaseInfo,"^",2)
	....s TBirth=$P(BaseInfo,"^",3)
	....s TAge=""
	....s TAge=##class(websys.Conversions).DateHtmlToLogical(TBirth)
	....i TAge'="" s TAge=$P(##class(web.DHCLCNUREXCUTE).CalAge(TAge,+$H),"Y",1)
	....s TTel=$P(BaseInfo,"^",6)
	....s Status="NE"
	....s Index=Index+1
	....d FindRoomPersonDetailBuild
	.k ^TempDHCPERoomManager(Job,"CheckingInfo")
	s Index=""
	s RecordID=""
 	s TRegNo="过号列表"
 	s (TName,TSex,TBirth,TTel,Status,PaadmID,TAge)=""
 	d FindRoomPersonDetailBuild
 	s Index=0
 	s Sort=""
	f  s Sort=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," P"," "_RoomID,Sort)) q:Sort=""  d
	.s AdmID=""
	.f  s AdmID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," P"," "_RoomID,Sort,AdmID)) q:AdmID=""  d
	..s RecordID=""
	..f  s RecordID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," P"," "_RoomID,Sort,AdmID,RecordID)) q:RecordID=""  d
	...s PaadmID=$P(AdmID," ",2)
	...s BaseInfo=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PaadmID)
	...;PatName_"^"_Sex_"^"_Birth_"^"_IDCard_"^"_RegNo
	...s TRegNo=$P(BaseInfo,"^",5)
	...s TName=$P(BaseInfo,"^",1)
	...s TSex=$P(BaseInfo,"^",2)
	...s TBirth=$P(BaseInfo,"^",3)
	...s TTel=$P(BaseInfo,"^",6)
	...s Status="P"
	...s Index=Index+1
	...d FindRoomPersonDetailBuild
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindRoomPersonDetailBuild 
	set Data=$lb(RecordID,TRegNo,TName,TSex,TBirth,TTel,Status,PaadmID,Index,TAge)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindRoomPersonDetailFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindRoomPersonDetailExecute ]
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

ClassMethod FindRoomPersonDetailClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindRoomPersonDetailExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query SerchChartAssign(DoctorDesc As %String = "") As %Query(ROWSPEC = "TUserID:%String,TUserName:%String,TUserinit:%String")
{
}

ClassMethod SerchChartAssignExecute(ByRef qHandle As %Binary, DoctorDesc As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s LocID=%session.Get("LOGON.CTLOCID")
 	s user=""
 	f  s user=$O(^DHCPEDataEx("ChartAssign",user)) q:user=""  d
 	.q:'$D(^DHCPEDataEx("ChartAssign",user,LocID))
 	.s init=$P($G(^SSU("SSUSR",user)),"^",1)
 	.s username=$P($G(^SSU("SSUSR",user)),"^",2) ;_"("_init_")"
 	.d FindBuild
 	
		
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindBuild      
	set Data=$lb(user,username,init)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SerchChartAssignFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SerchChartAssignExecute ]
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

ClassMethod SerchChartAssignClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SerchChartAssignExecute ]
{
	Set repid=$LIST(qHandle,2)
	 Kill ^CacheTemp(repid)
	 Quit $$$OK
}

// 得到是否憋尿的标志

ClassMethod GetEmictionDesc(Emiction)
{
	s rStr="不限"
	s:Emiction="HE" rStr="憋尿"
	s:Emiction="EE" rStr="排尿"
	q rStr
}

// 得到是否餐前的标志

ClassMethod GetDietDesc(Diet)
{
	s rStr="不限"
	s:Diet="PRE" rStr="餐前"
	s:Diet="POST" rStr="餐后"
	q rStr
}

// 得到性别的标志

ClassMethod GetSexDesc(Sex)
{
	s rStr="不限"
	s:Sex="F" rStr="女"
	s:Sex="M" rStr="男"
	q rStr
}

ClassMethod OutSexToHTML(ContrlWidth As %String = "", DefaultValue = "N") As %String
{
	;d ##Class(web.DHCPE.RoomManager).OutSexToHTML("13261677530")
	s:(""=ContrlWidth) ContrlWidth="155"
	
	//w "<select name='Sex' id='Sex' style='width:"_ContrlWidth_"' HEIGHT=0 tabIndex=0>",!
	w ##class(web.DHCPE.DHCPECommon).GetDefaultStyle("Sex","")
	s selected=""
	s:DefaultValue="N" selected="selected"
	w "<option value='N' "_selected_">"_..GetSexDesc("N")_"</option>",!
	s selected=""
	s:DefaultValue="F" selected="selected"
	w "<option value='F' "_selected_">"_..GetSexDesc("F")_"</option>",!
	s selected=""
	s:DefaultValue="M" selected="selected"
	w "<option value='M' "_selected_">"_..GetSexDesc("M")_"</option>",!
	w "</select>",!
	Quit $$$OK
}

ClassMethod OutStopButton(RecordID, Status)
{
	q:RecordID=""
	w "<input type='button' id='"_RecordID_"' name='StopButton' value='取消排队' onclick='StopCurRoom();'>"
	w "<input type='button' id='"_RecordID_"' name='StopButton' value='重新排队' onclick='NewCurRoom();'>"
	if Status="P" d
	.w "<input type='button' id='"_RecordID_"' name='StopButton' value='过号启用' onclick='ReStartCurRoom();'>"
	Quit $$$OK
}

ClassMethod OutSetRoomButton(RecordID, Status, RegNo, ind As %String = 2)
{
	q:RecordID="" ""
	q:(Status="N")&&(ind'=1) ""
	if Status="N" d
	.w "<input type='button' id='"_RecordID_"' name='StopButton' value='  叫号  ' onclick='CallCurRoom();'>"
	.w "<input type='button' id='"_RecordID_"' name='StopButton' value='  顺延  ' onclick='DelayCurRoom();'>"
	.w "<input type='button' id='"_RecordID_"' name='StopButton' value='  过号  ' onclick='PassCurRoom();'>"
	.//w "<input type='button' id='"_RecordID_"^"_RegNo_"' name='StopButton' value='  到达  ' onclick='ArriveCurRoom();'>"
	if Status="P" d
	.w "<input type='button' id='"_RecordID_"' name='StopButton' value='过号启用' onclick='ReStartCurRoom();'>"
	Quit $$$OK
}

ClassMethod GetWaitInfo(PAADM)
{
	s RoomDesc=""
	s WaitInfo=##class(web.DHCPE.RoomManager).GetAdmCurRoom(PAADM,"ADM")
	i WaitInfo="" d
	.s PAdm=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	.s PreIADM=$P(^DHCPEIADM(PAdm),"^",4)
	.s PIBI=$P(^DHCPEPreIADM(PreIADM),"^",1)
	.q:PIBI=""
	.s PatName=$P(^DHCPEPreIBI(PIBI),"^",2)
	.s WaitInfo=PatName_"您的排队项目已全部完成,如尿便已留,请将指引单交回前台"
	e  d
	.s Person=$P(WaitInfo,"^",2)
	.s Name=$P(WaitInfo,"^",3)
	.s WaitInfo=$P(WaitInfo,"^",1)
	.i RoomDesc=WaitInfo d
	..s WaitInfo="正检"_Name
	.e  d
	..s WaitInfo="请"_Name_"到"_WaitInfo_"处候诊,您是第"_Person_"位"
	q WaitInfo
}

ClassMethod OutRoomActiveButton(RoomID)
{
	q:RoomID=""
	s obj=##class(User.DHCPERoom).%OpenId(RoomID)
	s ActiveFlag=obj.RActiveFlag
	i ActiveFlag="N" d
	.w "<input type='button' id='"_RoomID_"' name='ActiveButton' value='启用' onclick='ActiveRoom();'>"
	e  d
	.w "<input type='button' id='"_RoomID_"' name='ActiveButton' value='禁用' onclick='UnActiveRoom();'>"
	Quit $$$OK
}

ClassMethod OutUpdateMinuteButton(RoomID)
{
	q:RoomID=""
	s obj=##class(User.DHCPERoom).%OpenId(RoomID)
	s Minute=obj.RMinute
	w "<table width=80><tr><td><input type='button' id='"_RoomID_"' name='MinuteButton' value='调时' onclick='UpdateRoomMinute(this);'><input style='width=40%' id='"_RoomID_"M' value="_Minute_"></td></tr></table>"
	Quit $$$OK
}

ClassMethod OutDietToHTML(ContrlWidth As %String = "") As %String
{
	;d ##Class(web.DHCPE.RoomManager).OutDietToHTML("130")
	s:(""=ContrlWidth) ContrlWidth="155"
	
	w "<select name='Diet' id='Diet' style='width:"_ContrlWidth_"' HEIGHT=0 tabIndex=0>",!
	w "<option value='N' selected>"_..GetDietDesc("N")_"</option>",!
	w "<option value='PRE'>"_..GetDietDesc("PRE")_"</option>",!
	w "<option value='POST'>"_..GetDietDesc("POST")_"</option>",!
	w "</select>",!
	Quit $$$OK
}

ClassMethod OutEmictionToHTML(ContrlWidth As %String = "") As %String
{
	;d ##Class(web.DHCPE.RoomManager).OutEmictionToHTML("130")
	s:(""=ContrlWidth) ContrlWidth="155"
	
	w "<select name='Emiction' id='Emiction' style='width:"_ContrlWidth_"' HEIGHT=0 tabIndex=0>",!
	w "<option value='N' selected>"_..GetEmictionDesc("N")_"</option>",!
	w "<option value='HE'>"_..GetEmictionDesc("HE")_"</option>",!
	w "<option value='EE'>"_..GetEmictionDesc("EE")_"</option>",!
	w "</select>",!
	Quit $$$OK
}

/*
ClassMethod OutSpecimenToHTML(ContrlWidth As %String = "", Type As %String = "SP") As %String
{
	;d ##Class(web.DHCPE.RoomManager).OutSpecimenToHTML("130")
	s:(""=ContrlWidth) ContrlWidth="155"
	//下拉列表
	w "<select name='Specimen' id='Specimen' style='width:"_ContrlWidth_"' HEIGHT=0  tabIndex=2>",!
	w "<option value=''>  </option>",!
	i Type="SP"
	{
		s id=0
		f  s id=$O(^TTAB("SPEC",id)) q:id=""  d
		.s Desc=$P($G(^TTAB("SPEC",id)),"\",1)
		.q:Desc'["血"
		.w "<option value='"_id_"'>"_Desc_"</option>",!
	}else{
		s Parref=0
 		f  s Parref=$O(^User.DHCPEAreaD(Parref)) q:Parref=""  d
 		.s id=0
 		.f  s id=$o(^User.DHCPEAreaD(Parref,"ChildRoom",id)) q:id=""  d
		..s Str=..GetOneRoomInfo(Parref_"||"_id)
		..s RoomDesc=$P(Str,"^",2)
		..s RoomID=Parref_"||"_id
		..w "<option value='"_RoomID_"'>"_RoomDesc_"</option>",!
	}
		
	w "</select>",!
	Quit $$$OK
}
*/
ClassMethod OutSpecimenToHTML(ContrlWidth As %String = "", Type As %String = "SP") As %String
{
	;d ##Class(web.DHCPE.RoomManager).OutSpecimenToHTML("130")
	s:(""=ContrlWidth) ContrlWidth="155"
	s LisNewVersion=$g(^DHCPESetting("DHCPE","LisNewVersion"))
	//下拉列表
	w "<select name='Specimen' id='Specimen' style='width:"_ContrlWidth_"' HEIGHT=0 tabIndex=2>",!
	w "<option value=''> </option>",!
	i Type="SP"
	{
		i LisNewVersion="Y" D
		.S specid=0
		.f  s specid=$o(^dbo.BTSpecimenD(specid)) q:specid=""  d
		..s id=$LG(^dbo.BTSpecimenD(specid),2)
		..s Desc=$LG(^dbo.BTSpecimenD(specid),3)
		..q:Desc'["血"
		..w "<option value='"_id_"'>"_Desc_"</option>",!
		e  d
		.s id=0
		.f  s id=$O(^TTAB("SPEC",id)) q:id=""  d
		..s Desc=$P($G(^TTAB("SPEC",id)),"\",1)
		..q:Desc'["血"
		..w "<option value='"_id_"'>"_Desc_"</option>",!
	}elseif Type="RP"
	{
		s id=0
		f  s id=$o(^DHCPEDataEx("RoomPlace",id)) q:id=""  d
		.s locid=$p($g(^DHCPEDataEx("RoomPlace",id)),"^",5)
		.;q:locid'=CurLoc
		.s selected=""
		.;s:DefaultValue=id selected="selected"
		.s Desc=$p($g(^DHCPEDataEx("RoomPlace",id)),"^",2) ;_" "_use
		.//i use="Y" d
		.w "<option value='"_id_"'>"_Desc_"</option>",!
	}
	else{
		s Parref=0
 		f  s Parref=$O(^User.DHCPEAreaD(Parref)) q:Parref=""  d
 		.s id=0
 		.f  s id=$o(^User.DHCPEAreaD(Parref,"ChildRoom",id)) q:id=""  d
		..s Str=..GetOneRoomInfo(Parref_"||"_id)
		..s RoomDesc=$P(Str,"^",2)
		..q:RoomDesc[("B")
		..s RoomID=Parref_"||"_id
		..w "<option value='"_RoomID_"'>"_RoomDesc_"</option>",!
	}
		
	w "</select>",!
	Quit $$$OK
}

ClassMethod OutStationToHTML(ContrlWidth As %String = "") As %String
{
	;d ##Class(web.DHCPE.RoomManager).OutStationToHTML("130")
	s:(""=ContrlWidth) ContrlWidth="155"
	//下拉列表
	w "<select name='Station' id='Station' style='width:"_ContrlWidth_"' HEIGHT=0  tabIndex=2>",!
	w "<option value=''>  </option>",!
	s id=0
	f  s id=$O(^DHCPEST(id)) q:id=""  d
	.
	.w "<option value='"_id_"'>"_$P($G(^DHCPEST(id)),"^",2)_"</option>",!
		
	w "</select>",!
	Quit $$$OK
}

ClassMethod InsertRoomByRegNo(RegNo)
{
	i RegNo'="" s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)	
	q:($L(RegNo)=0) "-1^请输入正确的登记号"
	s PIBI=$o(^DHCPEPreIBI(0,"PAPMINo",RegNo,0))
	q:PIBI="" "_1^无该人员的基本信息!"
	s PatName=$P(^DHCPEPreIBI(PIBI),"^",2)
	s PIADM=""
	s PIADMStr="" 
	s PIADMStutas=""
	f  s PIADM=$o(^DHCPEPreIADM(0,"PIBI",PIBI,PIADM),-1) q:(PIADM="")||(PIADMStr'="")  d
	.s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PIADM)         //Add by 090702
    .q:LocFlag=1  
	.s PIADMStutas=$P(^DHCPEPreIADM(PIADM),"^", 8)
	.q:PIADMStutas="CANCELPE"
	.q:("ARRIVED"'=PIADMStutas)&&("REGISTERED"'=PIADMStutas)
	.i "REGISTERED"=PIADMStutas d
	..d ##class(web.DHCPE.DHCPEIAdm).IAdmArrived(PIADM)
	.s PIADMStr=PIADM
	q:PIADMStr="" "-1^'<font color=red>"_PatName_"</font>'没有已经到达的信息"
	s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADMStr,0))
	q:IADM="" ""
	s AdmID=$P(^DHCPEIADM(IADM),"^",1)
	
	s AsCharged=$P(^DHCPEPreIADM(PIADMStr),"^", 9)
	s Flag=1
	i AsCharged="N" d
	.s AuditID=0
	.f  s AuditID=$O(^DHCPEPreA(0,"CRMADM","I",PIADMStr,AuditID)) q:(AuditID="")||(Flag=0)  d
	..s Amount=+$P(^DHCPEPreA(AuditID),"^",9)
	..q:Amount=0
	..s UseFlag=$P(^DHCPEPreA(AuditID),"^",21)
	..q:UseFlag="NU"
	..s ChargeFlag=$P(^DHCPEPreA(AuditID),"^",14)
	..q:ChargeFlag="CHARGED"
	..s Flag=0
	q:Flag=0 "-1^'<font color=red>"_PatName_"</font>'存在未付费的项目,请先付费"
	
	s PAdm=$O(^DHCPEIADM(0,"PAADM",AdmID,0))
	q:PAdm="" ""
	q:$D(^DHCPEIADM(PAdm,"PauseRoom")) "-1^'<font color=red>"_PatName_"</font>'已经暂停排队" ;暂停排队的
	s VIPInfo=##class(web.DHCPE.PreCommon).GetVIPLevel("IADM",PAdm)
	;q:VIPInfo[("VIP") "-1^'<font color=red>"_PatName_"</font>'是VIP,不需要诊室" ;VIP
	
	s CurRoomInfo=..GetAdmCurRoom(AdmID,"ADM")
	q:CurRoomInfo'="" "-1^'<font color=red>"_PatName_"</font>'已经在'"_CurRoomInfo_"'处候诊"
	d ..InsertRoomRecord(AdmID,"")
	s CurRoomInfo=..GetAdmCurRoom(AdmID,"ADM")
	q:CurRoomInfo="" "-1^'<font color=red>"_PatName_"</font>'您的排队项目已全部完成，如身高体重血压已检，请将指引单交回前台"
	
	s Person=$P(CurRoomInfo,"^",2)
	s Name=$P(CurRoomInfo,"^",3)
	s CurRoomInfo=$P(CurRoomInfo,"^",1)
	q "0^请'<font color=red>"_Name_"</font>'到'<font color=red>"_CurRoomInfo_"</font>'处候诊,您是第'"_Person_"'位"
}

ClassMethod InsertRoomRecord(AdmID, RoomRecordID As %String = "")
{
	;w ##Class(web.DHCPE.RoomManager).InsertRoomRecord("4012650")
	d ##class(web.DHCPE.RoomManager).DeleteNoUserRoomInfo()
	s PAdm=$O(^DHCPEIADM(0,"PAADM",AdmID,0))
	q:PAdm="" ""
	
	s PreIADM=$P(^DHCPEIADM(PAdm),"^",4)
	
	s PIBI=$P(^DHCPEPreIADM(PreIADM),"^",1)
	q:PIBI="" "_1^无该人员的基本信息!"
	s PatName=$P(^DHCPEPreIBI(PIBI),"^",2)
	q:$D(^DHCPEIADM(PAdm,"PauseRoom")) "-1^'<font color=red>"_PatName_"</font>'已经暂停排队" ;暂停排队的
	d ##class(User.DHCPECurDateAdmInfo).Insert(AdmID)
	s CurRoom=..GetNextRoomID(AdmID,RoomRecordID)
	i CurRoom'="" d
	.s User=%session.Get("LOGON.USERID")
	.s Sort=$I(^DHCPERoom("Sort",CurRoom,+$H))
	.s InfoStr=AdmID_"^"_CurRoom_"^"_"N"_"^"_""_"^"_+$H_"^"_$P($H,",",2)_"^"_"^"_"^"_Sort_"^"_"^"_User
	.d ##class(web.DHCPE.RoomManager).UpdateRoomRecord("",InfoStr)
}

ClassMethod GetNextRoomIDByRelate(AdmID, RoomRecordID As %String = "")
{
	;^User.DHCPERoomSpecialRoomI("RSRRoomIDIndex"," 1||18"
	s PAPMIID=$P(^PAADM(AdmID),"^",1)
	s Sex=$P(^PAPER(PAPMIID,"ALL"),"^",7)
	
	i Sex=$P($G(^DHCPESetting("DHCPE","DefPatientType")),"^",4) d
	.s SexCode="F"
	e  d
	.s SexCode="M"

	s NextRoom=""
	s MinMinute=9999999999
	s:RoomRecordID="" RoomRecordID=$O(^User.DHCPEAdmRoomRecordI("AdmIndex"," "_AdmID," O",""),-1)
	i RoomRecordID'="" d
	.s OverRoomID=$LG(^User.DHCPEAdmRoomRecordD(RoomRecordID),6)
	.s NextAreaID=""
	.f  s NextAreaID=$O(^User.DHCPERoomSpecialRoomI("RSRRoomIDIndex"," "_OverRoomID,NextAreaID)) q:NextAreaID=""  d
	..s NextRoomSub="0"
	..f  s NextRoomSub=$O(^User.DHCPERoomSpecialRoomI("RSRRoomIDIndex"," "_OverRoomID,NextAreaID,NextRoomSub)) q:NextRoomSub=""  d
	...s BindFlag=$LG(^User.DHCPEAreaD(NextAreaID,"ChildRoom",NextRoomSub),16)
	...q:BindFlag'="Y"
	...s ActiveFlag=$LG(^User.DHCPEAreaD(NextAreaID,"ChildRoom",NextRoomSub),14)
	...q:ActiveFlag="N"
	...s NextRoomID=NextAreaID_"||"_NextRoomSub
	...;q:$D(^User.DHCPEAdmRefuseRoomI("PAADMStatus",AdmID,"RF",NextRoomID))  ;放弃的退出
	...q:##class(web.DHCPE.RoomManagerEx).CheckHadRoom(AdmID,NextRoomID)=0
	...q:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," O"," "_NextRoomID," "_AdmID))
	...s Diet=$LG(^User.DHCPEAreaD(NextAreaID,"ChildRoom",NextRoomSub),4)
	...s Sex=$LG(^User.DHCPEAreaD(NextAreaID,"ChildRoom",NextRoomSub),5)
	...q:(Sex'="N")&&(Sex'=SexCode)
	...s NewPerson=..GetTotalPersonByRoom(NextRoomID,"N")
	...s OneMinute=$LG(^User.DHCPEAreaD(NextAreaID,"ChildRoom",NextRoomSub),12)
	...s Minute=OneMinute*NewPerson
	...i Minute<MinMinute d
	....s NextRoom=NextRoomID
	q NextRoom
}

ClassMethod GetNextRoomID(AdmID, RoomRecordID As %String = "")
{
	;w ##class(web.DHCPE.RoomManager).GetNextRoomID(4775941,42997)
	;n (AdmID, RoomRecordID)
	s PAPMIID=$P(^PAADM(AdmID),"^",1)
	s Sex=$P(^PAPER(PAPMIID,"ALL"),"^",7)
	i Sex=$P($G(^DHCPESetting("DHCPE","DefPatientType")),"^",4) d
	.s SexCode="F"
	e  d
	.s SexCode="M"

	s Loc=$P(^PAADM(AdmID),"^",4)
	s PAdm=$O(^DHCPEIADM(0,"PAADM",AdmID,0))
	s PreAdm=$P(^DHCPEIADM(PAdm),"^",4)
	;s PEType=$P(^DHCPEPreIADM(PreAdm),"^",18)
	;s:PEType="" PEType=$G(^DHCPEVIPLevel("VIPapprove"))
	s PEType=$G(^DHCPEDataEx("DHCPEPreIADM","RoomPlace",PreAdm))
	q:PEType="" ""
	s CurRoom=""
	s CurRoom=..GetNextRoomIDByRelate(AdmID,RoomRecordID)
	q:CurRoom'="" CurRoom
	
	//是否分区、当前区ID
	s AreaFlag="0"
	s CurArea=""
	i RoomRecordID'="" d
	.s OverRoomID=$LG(^User.DHCPEAdmRoomRecordD(RoomRecordID),6)
	.s CurArea=+OverRoomID
	b ;CurArea RoomRecordID
	s MinMinute=10000000000
	b ;MinMinute
	s Job=AdmID_"^"_$J
	k ^TempDHCPERoomInsert(Job)
	s Sort=""
	/*
	f  s Sort=$O(^User.DHCPEAreaI("ALocTypeSortIndex"," "_Loc," "_PEType,Sort)) q:(Sort="")||(CurRoom'="")  d
	.;b ;Sort
	.s AreaID=""
	.f  s AreaID=$O(^User.DHCPEAreaI("ALocTypeSortIndex"," "_Loc," "_PEType,Sort,AreaID)) q:(AreaID="")||(CurRoom'="")  d
	..;b ;AreaID
	*/
	f  s Sort=$O(^User.DHCPEAreaI("ALocDRSortIndex"," "_Loc,Sort)) q:(Sort="")||(CurRoom'="")  d
	.;b ;Sort
	.s AreaID=""
	.f  s AreaID=$O(^User.DHCPEAreaI("ALocDRSortIndex"," "_Loc,Sort,AreaID)) q:(AreaID="")||(CurRoom'="")  d
	..s Sub=0
	..f  s Sub=$O(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub)) q:Sub=""  d
	...s RoomID=AreaID_"||"_Sub
	...s ActiveFlag=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),14)
	...q:ActiveFlag="N"
	...;s RoomPEType=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),17)
	...;q:(RoomPEType'="")&&(RoomPEType'=PEType)
	...q:'$D(^User.DHCPERoomRoomPlaceI("RoomPlaceIndex",AreaID,Sub," "_PEType))
	...s StationID=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),7)
	...s OneMinute=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),12)
	...s Diet=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),4)
	...s Sex=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),5)
	...q:(Sex'="N")&&(Sex'=SexCode)
	...;b ;StationID
	...i StationID="" d
	....q:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," N"," "_RoomID," "_AdmID))
	....q:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," P"," "_RoomID," "_AdmID))
	....q:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," O"," "_RoomID," "_AdmID))
	....i AreaID=CurArea d  ;AreaFlag="1" ;有分区判断
	.....;w "b:"_AreaID_"^"_CurArea_"^"_RoomID,!
	.....s AreaFlag="1" ;有分区判断
	....s PassPerson=..GetTotalPersonByRoom(RoomID,"P")
	....s NewPerson=..GetTotalPersonByRoom(RoomID,"N")
	....s OverPerson=##class(web.DHCPE.RoomManagerEx).GetTotalOverPersonByRoom(RoomID)
	....s TotalPerson=NewPerson  ;+PassPerson
	....s TotalMinute=TotalPerson*OneMinute
	....s HadPersonNum=OverPerson+NewPerson
	....;i TotalMinute<MinMinute d
	....;.s MinMinute=TotalMinute
	....;.s CurRoom=RoomID
	....s SortIndex=$i(^TempDHCPERoomInsert(Job))
	....s ^TempDHCPERoomInsert(Job,"Sort",TotalMinute,HadPersonNum,Sort,SortIndex)=RoomID
	....s ^TempDHCPERoomInsert(Job,"Room",RoomID)=TotalMinute
	...e  d
	....s QFlag=0
	....s FlagArea=""
	....f  s FlagArea=$O(^User.DHCPERoomI("RStationIndex",StationID,FlagArea)) q:(FlagArea="")||(QFlag=1)  d
	.....s FlagRoomSub=""
	.....f  s FlagRoomSub=$O(^User.DHCPERoomI("RStationIndex",StationID,FlagArea,FlagRoomSub)) q:(FlagRoomSub="")||(QFlag=1)  d
	......s FlagRoomID=FlagArea_"||"_FlagRoomSub
	......s:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," N"," "_FlagRoomID," "_AdmID)) QFlag=1
	......s:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," P"," "_FlagRoomID," "_AdmID)) QFlag=1
	......s:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," O"," "_FlagRoomID," "_AdmID)) QFlag=1
	....q:QFlag=1
	....s SpecStr=""
	....i StationID=$G(^DHCPESetting("DHCPE","StationId_Lab")) d
	.....s SpecStr=..GetAllSpec(RoomID)
	.....s SpecStr="^"_SpecStr_"^"
	....s Flag=0
	....s Order=$O(^OEORD(0,"Adm",AdmID,0))
	....s OrdSub=0
	....f  s OrdSub=$O(^DHCPEPreIADM(PreAdm,"ORDITEM",OrdSub)) q:(OrdSub="")||(Flag=1)  d
	.....s DietFlag=$P(^DHCPEPreIADM(PreAdm,"ORDITEM",OrdSub),"^",2)
	.....s Stat=$P(^DHCPEPreIADM(PreAdm,"ORDITEM",OrdSub),"^",16)
	.....q:Stat'="1"
	.....s CrmOrderID=$O(^DHCPECRMO(0,"CRMORI",PreAdm_"||"_OrdSub,0))
	.....q:CrmOrderID=""
	.....s OrdItemID=$P(^DHCPECRMO(CrmOrderID),"^",1)
	.....s Stat=$P($G(^OEORD(+OrdItemID,"I",$P(OrdItemID,"||",2),1)),"^",13)
	.....q:Stat'="1"
	.....q:(Stat="1")&&$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrdItemID))
	.....s ItemMastID=$P(^OEORD(+OrdItemID,"I",$P(OrdItemID,"||",2),1),"^",2)
	.....q:$G(ItemMastID)=""
	.....s STID=$O(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))
	.....q:STID'=StationID
	.....;q:(Diet'="N")&&(DietFlag'=Diet)
	.....i StationID=$G(^DHCPESetting("DHCPE","StationId_Lab")) d
	......s SpecNo=$p($G(^OEORD(+OrdItemID,"I",$P(OrdItemID,"||",2),3)),"^",20)
	......q:SpecNo=""
	......q:$D(^DHCPETempLabEpisodeScan(SpecNo))
	......s CurSpec=$G(^DHCPEDataEx("DHCPEPreIOrdItem","PERSON",PreAdm_"||"_OrdSub))
	......s CurSpec=$P(CurSpec,"^",1)
	......s:SpecStr[("^"_CurSpec_"^") Flag=1
	.....e  d
	......s Flag=1
	....q:Flag=0
	....i AreaID=CurArea d
	.....;w "a:"_AreaID_"^"_CurArea_"^"_RoomID,!
	.....s AreaFlag="1" ;有分区判断
	....s PassPerson=..GetTotalPersonByRoom(RoomID,"P")
	....s OverPerson=##class(web.DHCPE.RoomManagerEx).GetTotalOverPersonByRoom(RoomID)
	....s NewPerson=..GetTotalPersonByRoom(RoomID,"N")
	....s TotalPerson=NewPerson ;+PassPerson
	....s TotalMinute=TotalPerson*OneMinute
	....s HadPersonNum=OverPerson+NewPerson
	....s SortIndex=$i(^TempDHCPERoomInsert(Job))
	....s ^TempDHCPERoomInsert(Job,"Sort",TotalMinute,HadPersonNum,Sort,SortIndex)=RoomID
	....s ^TempDHCPERoomInsert(Job,"Room",RoomID)=TotalMinute
	s Sort=$O(^TempDHCPERoomInsert(Job,"Sort",""))
	q:Sort="" ""
	b ;^TempDHCPERoomInsert
	s Minute=""
	f  s Minute=$O(^TempDHCPERoomInsert(Job,"Sort",Minute)) q:(Minute="")||(CurRoom'="")  d
	.s HadPersonNum=""
	.f  s HadPersonNum=$O(^TempDHCPERoomInsert(Job,"Sort",Minute,HadPersonNum)) q:(HadPersonNum="")||(CurRoom'="")  d
	..s Sort=""
	..f  s Sort=$O(^TempDHCPERoomInsert(Job,"Sort",Minute,HadPersonNum,Sort)) q:(Sort="")||(CurRoom'="")  d
	...s SortIndex=""
	...f  s SortIndex=$O(^TempDHCPERoomInsert(Job,"Sort",Minute,HadPersonNum,Sort,SortIndex)) q:(SortIndex="")||(CurRoom'="")  d
	....s RoomID=$G(^TempDHCPERoomInsert(Job,"Sort",Minute,HadPersonNum,Sort,SortIndex))
	....s UseAreaFlag=$LG(^User.DHCPEAreaD(+RoomID),7)
	....q:(AreaFlag="1")&&(CurArea'=+RoomID)&&(UseAreaFlag="1")  //有分区的优先分区
	....s Flag=..RoomCanInser(RoomID,Job)
	....b ;Flag
	....q:Flag=0
	....s CurRoom=RoomID
	b ;^TempDHCPERoomInsert(Job)
	k ^TempDHCPERoomInsert(Job)
	q CurRoom
}

// 判断此诊室是否已经可以排队,有些诊室必须排在其它诊室的后面

ClassMethod RoomCanInser(RoomID, Job)
{
	s Flag=1  //可以排队
	s OtherRoom=""
	s Main=+RoomID
	s Sub=$P(RoomID,"||",2)
	f  s OtherRoom=$O(^User.DHCPERoomSpecialRoomI("RoomIDIndex",+RoomID,Sub,OtherRoom)) q:(OtherRoom="")||(Flag=0)  d
	.s OtherRoomID=$P(OtherRoom," ",2)
	.s:$D(^TempDHCPERoomInsert(Job,"Room",OtherRoomID)) Flag=0
	q Flag
}

// 暂停、恢复排队

ClassMethod PauseRoom(PAADM)
{
	s UserID=%session.Get("LOGON.USERID")
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" "-1^ADM不存在"
	i $D(^DHCPEIADM(IADM,"PauseRoom")){
		k ^DHCPEIADM(IADM,"PauseRoom")
	}else{
		s ^DHCPEIADM(IADM,"PauseRoom")=$H_"^"_UserID
	}
	q "0^设置成功"
}

// 取消排队

ClassMethod StopCurRoomInfo(CurRoomID)
{
	s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
	s Status=obj.ARRStatus
	q:Status="O" "-1^此诊室已经完成检查"
	s OldRoomID=obj.ARRRoomDR
	s obj=##class(User.DHCPEAdmRoomRecord).%New()
	s sc=obj.%DeleteId(CurRoomID)
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		s UserID=%session.Get("LOGON.USERID")
		d ##class(web.DHCPE.CallVoice.Main).SendVoice(OldRoomID,UserID)
		q "0^取消成功"
	}
}

// 重新排队、停掉原来排队、开始新的排队

ClassMethod ReSetCurRoomInfo(CurRoomID)
{
	s AdmID=$LG(^User.DHCPEAdmRoomRecordD(CurRoomID),2)
	
	s ret=..StopCurRoomInfo(CurRoomID)
	i $P(ret,"^",1)'=0 q ret
	d ..InsertRoomRecord(AdmID,"")
	s CurRoomInfo=..GetAdmCurRoom(AdmID,"ADM")
	q:CurRoomInfo="" "-1^没有需要分配的诊室"
	s Person=$P(CurRoomInfo,"^",2)
	s Name=$P(CurRoomInfo,"^",3)
	s CurRoomInfo=$P(CurRoomInfo,"^",1)
	q "0^请'<font color=red>"_Name_"</font>'到'<font color=red>"_CurRoomInfo_"</font>'处候诊,您是第'"_Person_"'位"
}

ClassMethod ReSetCurRoomInfoNew(CurRoomID)
{
	s AdmID=$LG(^User.DHCPEAdmRoomRecordD(CurRoomID),2)
	
	s ret=..StopCurRoomInfo(CurRoomID)
	i $P(ret,"^",1)'=0 q ret
	d ..InsertRoomRecord(AdmID,"")
	s CurRoomInfo=..GetAdmCurRoom(AdmID,"ADM")
	q:CurRoomInfo="" "-1^没有需要分配的诊室"
	s Person=$P(CurRoomInfo,"^",2)
	s Name=$P(CurRoomInfo,"^",3)
	s CurRoomInfo=$P(CurRoomInfo,"^",1)
	q "0^请"_Name_"到"_CurRoomInfo_"处候诊,您是第'"_Person_"位"
}

// 过号启用

ClassMethod ReStartCurRoomInfo(CurRoomID)
{
	s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
	s Status=obj.ARRStatus
	q:Status="O" "-1^此诊室已经完成检查"
	q:Status="N" "-1^此诊室为排队状态,不需要重新启用"
	s RoomID=obj.ARRRoomDR
	s Sort=$I(^DHCPERoom("Sort",RoomID,+$H))
	s InfoStr="^"_"^"_"N^"_"^"_"^"_"^^^"_Sort
	s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord(CurRoomID,InfoStr)
	q:+ret'=-1 "0^重排成功"_Sort
	q ret
}

// 过号

ClassMethod PassCurRoomInfo(CurRoomID)
{
	s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
	s Status=obj.ARRStatus
	q:Status="O" "-1^此诊室已经完成检查"
	q:Status="P" "-1^此诊室已经是过号状态"
	s InfoStr="^"_"^"_"P^"_"^"_"^"_"^^^"
	s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord(CurRoomID,InfoStr,"1")
	q:+ret'=-1 "0^过号成功"
	q ret
}

// 顺延

ClassMethod DelayCurRoomInfo(CurRoomID)
{
	s DelayNum=4
	s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
	s Status=obj.ARRStatus
	q:Status="O" "-1^此诊室已经完成检查"
	q:Status="P" "-1^此诊室为过号状态,不需要顺延"
	s RoomID=obj.ARRRoomDR
	s OldSort=obj.ARRRoomSort
	s CurSort=+$G(^DHCPERoom("Sort",RoomID,+$H))
	i (OldSort+DelayNum)>CurSort d
	.s Sort=$I(^DHCPERoom("Sort",RoomID,+$H))
	e  d
	.s Sort=OldSort+DelayNum
	s InfoStr="^"_"^"_"N^"_"^"_"^"_"^^^"_Sort
	s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord(CurRoomID,InfoStr,"1")
	q:+ret'=-1 "0^重排成功"_Sort
	q ret
}

// 根据PAADM号到达

ClassMethod ArriveByPAADM(RoomID, PAADM)
{
	q:RoomID="" ""
	s RoomID=$P(RoomID,"$",1)
	
	q:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," O"," "_RoomID," "_PAADM)) "^1" //已完成本科室检查
	s CurRoomInfo=..GetAdmCurRoom(PAADM,"ADM","")
	q:CurRoomInfo="" "" //没有排队信息
	s CurRoomID=+CurRoomInfo
	s CurRoom=$LG(^User.DHCPEAdmRoomRecordD(CurRoomID),6)
	q:CurRoom'=RoomID "^2" //没排在本诊室
	s Status=##class(web.DHCPE.RoomManagerEx).GetRecordStatus(CurRoomID)
	q:Status="" ""
	q CurRoomID_"^"_Status
	
	;s UserID=%session.Get("LOGON.USERID")
	;s ret=..ArriveCurRoom(CurRoomID, UserID)
	i +ret=0 q CurRoomID
}

// 叫号到达

ClassMethod ArriveCurRoom(CurRoomID, UserID, RoomID As %String = "")
{
	;d ##Class(web.DHCPE.RoomManager).ArriveCurRoom("66",3901)
	s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
	
	i RoomID'=""{
		s CRoomID=obj.ARRRoomDR
		s CStation=$LG(^User.DHCPEAreaD(+CRoomID,"ChildRoom",$P(CRoomID,"||",2)),7)
		s RoomID=$P(RoomID,"$",1)
		s Station=$LG(^User.DHCPEAreaD(+RoomID,"ChildRoom",$P(RoomID,"||",2)),7)
		q:CStation'=Station "-1^不是同一站点、不允许到达"
	}
	s Status=obj.ARRStatus
	q:Status="O" "-1^此诊室已经完成检查"
	q:Status="P" "-1^此诊室为过号状态,不需要到达"
	s InfoStr="^"_"^"_"^"_"E"_"^"_"^"_"^"_$P($H,",",2)_"^^^"_UserID
	s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord(CurRoomID,InfoStr)
	q:+ret'=-1 "0^到达成功"
	q ret
}

// 叫号时使用

ClassMethod CallCurRoom(CurRoomID)
{
	s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
	s Status=obj.ARRStatus
	q:Status="O" "-1^此诊室已经完成检查"
	q:Status="P" "-1^此诊室为过号状态,不需要到达"
	s InfoStr="^"_"^"_"^"_"C"_"^"_+$H_"^"_"^"_"^^^"
	s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord(CurRoomID,InfoStr)
	i +ret'=-1
	{
		q "0^叫号成功"
	}
	q ret
}

/// 完成检查   更新未完成  分配下一个检查科室
ClassMethod CompleteCurRoom(CurRoomID, AdmID, RoomID)
{
	;w ##class(web.DHCPE.RoomManager).CompleteCurRoom("","4783162","1||5")
	
	s PAdm=$O(^DHCPEIADM(0,"PAADM",AdmID,0))
	
	s PreIADM=$P(^DHCPEIADM(PAdm),"^",4)
	s PIBI=$P(^DHCPEPreIADM(PreIADM),"^",1)
	q:PIBI="" "_1^无该人员的基本信息!"
	s PatName=$P(^DHCPEPreIBI(PIBI),"^",2)
	
	q:$D(^DHCPEIADM(PAdm,"PauseRoom")) "-1^'<font color=red>"_PatName_"</font>'已经暂停排队"
	s VIPInfo=##class(web.DHCPE.PreCommon).GetVIPLevel("IADM",PAdm)
	;q:VIPInfo[("VIP") "-1^'<font color=red>"_PatName_"</font>'是VIP,不需要诊室" ;VIP
	
	s RoomID=$P(RoomID,"$",1)
	q:(CurRoomID="")&&(AdmID="") "-1^诊室和就诊记录都是空"
	s:$D(%session) UserID=%session.Get("LOGON.USERID")
	s:'$D(%session) UserID=5930		
	if (CurRoomID="")
	{
		s ret=..GetAdmCurRoom(AdmID,"ADM","")
		s CurRoomID=$P(ret,"^",1)
		b ;CurRoomID   1
		i CurRoomID="" d
		.d ..InsertRoomRecord(AdmID,"")
		.s ret=..GetAdmCurRoom(AdmID,"ADM","")
		.s CurRoomID=$P(ret,"^",1)
		
		
		
		b ;CurRoomID   2
		q:CurRoomID="" "-1^'<font color=red>"_PatName_"</font>'您的排队项目已全部完成，如身高体重血压已检，请将指引单交回前台"
		s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
		s OldRoomID=obj.ARRRoomDR
		b ;OldRoomID   1
		i OldRoomID'=RoomID
		{
			//判断是否同一个站点、如果为同一个站点直接更新原记录的科室ID为现ID
			s OldStation=$LG(^User.DHCPEAreaD(+OldRoomID,"ChildRoom",$P(OldRoomID,"||",2)),7)
			s NewStation=$LG(^User.DHCPEAreaD(+RoomID,"ChildRoom",$P(RoomID,"||",2)),7)
			i OldStation=NewStation
			{
				s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
				s obj.ARRRoomDR=RoomID
			}
			else
			{
				s Date=+$H	
				s CurRoomInfo=ret
				i '$D(^User.DHCPEAdmRoomRecordI("UserRoomIndex",Date,UserID," "_RoomID," "_AdmID)) d
				.s InfoStr=AdmID_"^"_RoomID_"^O"_"^"_"^"_+$H_"^"_$P($H,",",2)_"^^^^"_UserID_"^"_UserID
				.b ;InfoStr  NewOver
				.s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord("",InfoStr)
				.d ##class(web.DHCPE.AdmRecordManager).Insert(AdmID,"A","RC",UserID,RoomID)
				;q CurRoomID_"^"_RoomDesc_"^"_NewPerson_"^"_Name
				s Person=$P(CurRoomInfo,"^",3)
				s Name=$P(CurRoomInfo,"^",4)
				s CurRoomInfo=$P(CurRoomInfo,"^",2)
			
				q "0^请'<font color=red>"_Name_"</font>'到'<font color=red>"_CurRoomInfo_"</font>'处候诊,您是第'"_Person_"'位"
				//q CurRoomInfo
			}
		}
		else
		{
			b ;CurRoomID
			s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
		}
	}else{
		b ;CurRoomID  3
		s obj=##class(User.DHCPEAdmRoomRecord).%OpenId(CurRoomID)
	}
	s Status=obj.ARRStatus
	i Status="O" d
	.s ret="0^'<font color=red>"_PatName_"</font>'此诊室已经完成检查"
	.;q:Status="O" "-1^此诊室已经完成检查"
	e  d
	.s AdmID=obj.ARRAdmDR
	.s InfoStr="^"_"^O"_"^"_"^"_+$H_"^"_"^^"_$P($H,",",2)_"^^"_UserID
	.s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord(CurRoomID,InfoStr)
	.d ##class(web.DHCPE.AdmRecordManager).Insert(AdmID,"A","RC",UserID,RoomID)
	;q:Status="P" "-1^此诊室为过号状态,不需要到达"
	q:+ret=-1 "-1^完成错误"
	//d ##class(web.DHCPE.CallVoice.Main).SendVoice(RoomID,UserID)
	b ;ret
	d ##class(web.DHCPE.RoomManager).InsertRoomRecord(AdmID,CurRoomID)
	s CurRoomInfo=..GetAdmCurRoom(AdmID,"ADM")
	q:CurRoomInfo="" "-1^'<font color=red>"_PatName_"</font>'您的排队项目已全部完成，如身高体重血压已检，请将指引单交回前台"
	s Person=$P(CurRoomInfo,"^",2)
	s Name=$P(CurRoomInfo,"^",3)
	s CurRoomInfo=$P(CurRoomInfo,"^",1)
	//d ##class(web.DHCPE.CallVoice.Main).SendVoice(RoomID,UserID)
	//q CurRoomInfo
	q "0^请'<font color=red>"_Name_"</font>'到'<font color=red>"_CurRoomInfo_"</font>'处候诊,您是第'"_Person_"'位"
}

ClassMethod UpdateOneRoomRecord(AdmID, Status)
{
	;d ##Class(web.DHCPE.RoomManager).UpdateOneRoomRecord("5385","O")
	s IP=..GetIPAndName()
 	s IP=$P(IP,"^",1)
 	s AreaID=$O(^User.DHCPERoomIPI("IPIndex"," "_IP,""))
 	i AreaID'=""
 	{
 		s RoomSub=$O(^User.DHCPERoomIPI("IPIndex"," "_IP,AreaID,""))
 		s RoomID=AreaID_"||"_RoomSub
 	}else{
	 	s RoomID=""
 	}
 	q:RoomID="" "0^"
 	s ID=""
 	s ID=$O(^User.DHCPEAdmRoomRecordI("StatusIndex"," N"," "_RoomID," "_AdmID,0))
 	i ID="" d
 	.s ID=$O(^User.DHCPEAdmRoomRecordI("StatusIndex"," P"," "_RoomID," "_AdmID,0))
 	q:ID="" "0^"
 	b ;ID
 	i $L(Status,"^")>1 d
 	.s Str="^^^"_$p(Status,"^",2)_"^^^"_$P($H,",",2)_"^"
 	e  d
 	.s Str="^^"_Status_"^^^^^"_$P($H,",",2)
 	TSTART
 	s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord(ID,Str)
 	i ret<0{
	 	TROLLBACK
	 	q "ret^更新诊室错误"
 	}
 	TCOMMIT
 	i Status="O" d
 	.d ..InsertRoomRecord(AdmID,ID)
}

ClassMethod GetAdmCurRoom(AdmID, Type As %String = "ADM", DescType As %String = "Desc")
{
	//n (AdmID,Type,DescType)
	;w ##class(web.DHCPE.RoomManager).GetAdmCurRoom(13984)
	i Type="PRE"{
		s IADM=$O(^DHCPEIADM(0,"CRMADM",AdmID,0))
		q:IADM="" ""
		s AdmID=$P(^DHCPEIADM(IADM),"^",1)
	}
	s AdmObj=##class(User.PAAdm).%OpenId(AdmID)
	s Name=AdmObj.PAADMPAPMIDR.PAPMIName
	s Status=""
	s CurRoomID=""
	s RoomDesc=""
	f  s Status=$O(^User.DHCPEAdmRoomRecordI("AdmIndex"," "_AdmID,Status)) q:Status=""  d
	.q:Status=" O"
	.s ID=$O(^User.DHCPEAdmRoomRecordI("AdmIndex"," "_AdmID,Status,""))
	.s RoomID=$LG(^User.DHCPEAdmRoomRecordD(ID),6)
	.s CurRoomID=ID
	.s RoomInfo=..GetOneRoomInfo(RoomID)
	.s RoomDesc=$P(RoomInfo,"^",2)
	;s PassPerson=..GetTotalPersonByRoom(CurRoomID,"P")
	;s TotalPerson=NewPerson
	q:CurRoomID="" ""
	s RoomID=$LG(^User.DHCPEAdmRoomRecordD(CurRoomID),6)
	s NewPerson=..GetTotalPersonByRoom(RoomID,"N")
	q:DescType="Desc" RoomDesc_"^"_NewPerson_"^"_Name
	q CurRoomID_"^"_RoomDesc_"^"_NewPerson_"^"_Name
}

// 根据诊室ID以及状态得到当前人数

ClassMethod GetTotalPersonByRoom(RoomID, Status)
{
	//n (RoomID,Status)
	q:RoomID="" ""
	;StatusIndex
	s TotalPerson=0
	s AdmID=""
	f  s AdmID=$O(^User.DHCPEAdmRoomRecordI("StatusIndex"," "_Status," "_RoomID,AdmID)) q:AdmID=""  d
	.;w "a"_AdmID_"b",!
	.;s RecordID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," "_Status," "_RoomID,AdmID,0))
	.;s DetailStatus=$LG(^User.DHCPEAdmRoomRecordD(RecordID),9)
	.;q:RecordID=""
	.;q:DetailStatus="E"
	.s TotalPerson=TotalPerson+1
	q TotalPerson
}

// 根据诊室ID得到所有对应的化验标本类型

ClassMethod GetAllSpec(RoomID)
{
	s SpecStr=""
	s SpecSub=0
	f  s SpecSub=$O(^User.DHCPEAreaD(+RoomID,"ChildRoom",$P(RoomID,"||",2),"childSpecimen",SpecSub)) q:SpecSub=""  d
	.s Spec=$LG(^User.DHCPEAreaD(+RoomID,"ChildRoom",$P(RoomID,"||",2),"childSpecimen",SpecSub),2)
	.i SpecStr="" d
	..s SpecStr=Spec
	.e  d
	..s SpecStr=SpecStr_"^"_Spec
	q SpecStr
}

// w ##class(web.DHCPE.RoomManager).GetIPAndName()

ClassMethod GetIPAndName() As %String
{
	Set IPAddress=$ZUTIL(67,15,$JOB)
	Set CompName=$ZUTIL(67,12,$JOB)
	//s IPAddress="10.10.141.107"
	Quit IPAddress_"^"_CompName
}

ClassMethod GetAdmRecordInfo(RegNo)
{
	;w ##class(web.DHCPE.RoomManager).GetAdmRecordInfo(40653889)
	i RegNo'="" s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
	s PersonID=$O(^PAPERi("PAPMI_PatNo",RegNo,0))
	q:PersonID="" "-1^病人ID不存在"
	s CurAdmID=""
	s AdmID=""
	f  s AdmID=$O(^PAPERdr(PersonID,"ADM","H",AdmID),-1) q:(AdmID="")||(CurAdmID'="")  d
	.s PIADM=$O(^DHCPEIADM(0,"PAADM",AdmID,0))
	.q:PIADM=""
	.s Status=$P(^DHCPEIADM(PIADM),"^",8)
	.q:Status'="ARRIVED"
	.s CurAdmID=AdmID
	q:CurAdmID="" "-1^病人未做过体检"
	s CurRoomInfo=..GetAdmCurRoom(CurAdmID,"ADM","IDDesc")
	;q:+CurRoomInfo=0 "-1^病人现在不在诊室里面"
	i +CurRoomInfo=0 d
	.s CurRoomInfo="^^^^^"
	
	s PauseFlag=$D(^DHCPEIADM(PIADM,"PauseRoom"))
	b ;AdmID
	s BaseInfo=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(CurAdmID)
	q "0^"_BaseInfo_"^"_CurAdmID_"^"_PauseFlag_$c(1)_CurRoomInfo
}

ClassMethod UpdateAdmRoomRecord(ID, RoomID)
{
	/*
	i $P(InfoStr,"^",1)'="" s obj.ARRAdmDR=$P(InfoStr,"^",1)
	i $P(InfoStr,"^",2)'="" s obj.ARRRoomDR=$P(InfoStr,"^",2)
	i $P(InfoStr,"^",3)'="" s obj.ARRStatus=$P(InfoStr,"^",3)
	i $P(InfoStr,"^",4)'="" s obj.ARRStatusDetail=$P(InfoStr,"^",4)
	i $P(InfoStr,"^",5)'="" s obj.ARRDate=$P(InfoStr,"^",5)
	i $P(InfoStr,"^",6)'="" s obj.ARRCreateTime=$P(InfoStr,"^",6)
	i $P(InfoStr,"^",7)'="" s obj.ARRInTime=$P(InfoStr,"^",7)
	i $P(InfoStr,"^",8)'="" s obj.ARROutTime=$P(InfoStr,"^",8)
	*/
	s Sort=$I(^DHCPERoom("Sort",RoomID,+$H))
	s Str="^"_RoomID_"^^^^^^^"_Sort
	s ret=##class(web.DHCPE.RoomManager).UpdateRoomRecord(ID,Str)
	q ret
}

// 根据计算机信息得到当前房间

ClassMethod GetRoomIDByCompute(IP)
{
	s RoomInfo=""
	s AreaID=""
	f  s AreaID=$O(^User.DHCPERoomIPI("IPIndex"," "_IP,AreaID)) q:AreaID=""  d
	.s RoomSub=""
	.f  s RoomSub=$O(^User.DHCPERoomIPI("IPIndex"," "_IP,AreaID,RoomSub)) q:RoomSub=""  d
	..s Flag=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",RoomSub),14)
	..;q:Flag="N"
	..s RoomID=AreaID_"||"_RoomSub_"$"_Flag
	..i RoomInfo="" d
	...s RoomInfo=RoomID
	..e  d
	...s RoomInfo=RoomInfo_"^"_RoomID
 	q RoomInfo
}

ClassMethod GetTitleName(Type)
{
	q:Type="SP" "诊室标本"
	q:Type="IP" "诊室电脑IP"
	;q:Type="RP" "前面诊室标本"
	q:Type="RP" "诊室位置"
	q "前面诊室"
}

Query AdmNeedRoom(PAADM As %String = "") As %Query(ROWSPEC = "TRoomID:%String,TRoomDesc:%String,TWaitNum:%String,TWaitMinute:%String,TAreaDesc:%String,TPAADM:%String,TRefuseRoom:%String")
{
}

ClassMethod AdmNeedRoomExecute(ByRef qHandle As %Binary, PAADM As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
	;s Loc=%session.Get("LOGON.CTLOCID")
 	s ind=1
 	K ^tempdhcpe("PAADM")
 	s ^tempdhcpe("PAADM")=PAADM
 	//s PAADM=2950
 	i PAADM=""
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
 	}
 	;s PAADM=$LG(^User.DHCPEAdmRoomRecordD(CurRoomID),2)
 	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
 	q:IADM="" ""
 	s Loc=$P(^PAADM(PAADM),"^",4)
 	s PreAdm=$P(^DHCPEIADM(IADM),"^",4)
 	s PAPMIID=$P(^PAADM(PAADM),"^",1)
	s Sex=$P(^PAPER(PAPMIID,"ALL"),"^",7)
	s SexCode="N"
	//s:Sex'="" SexCode=$P(^CT("SEX",Sex),"^",1)
	i Sex'="" d
	.s SexDesc=$P(^CT("SEX",Sex),"^",2)
	.i SexDesc="男" s SexCode="M"
	.i SexDesc="女" s SexCode="F"

 	s Job=$J
 	k ^TempDHCPERoomInsert(Job)
 	s VIPInfo=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PAADM)
 	;s PEType=$P(VIPInfo,"^",1)
 	;s:PEType="" PEType=$G(^DHCPEVIPLevel("VIPapprove"))
 	s PEType=$G(^DHCPEDataEx("DHCPEPreIADM","RoomPlace",PreAdm))
	q:PEType="" ""
	
 	s Sort=""
 
	f  s Sort=$O(^User.DHCPEAreaI("ALocDRSortIndex"," "_Loc,Sort)) q:(Sort="")  d
	.s AreaID=""
	.f  s AreaID=$O(^User.DHCPEAreaI("ALocDRSortIndex"," "_Loc,Sort,AreaID)) q:(AreaID="")  d
	..s Sub=0
	..f  s Sub=$O(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub)) q:Sub=""  d
	...s RoomID=AreaID_"||"_Sub
	...s ActiveFlag=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),14)
	...q:ActiveFlag="N"
	...;s RoomPEType=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),17)
	...;q:(RoomPEType'="")&&(RoomPEType'=PEType)
	...q:'$D(^User.DHCPERoomRoomPlaceI("RoomPlaceIndex",AreaID,Sub," "_PEType))
	...s StationID=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),7)
	...s OneMinute=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),12)
	...s Diet=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),4)
	...s Sex=$LG(^User.DHCPEAreaD(AreaID,"ChildRoom",Sub),5)
	...q:(Sex'="N")&&(Sex'=SexCode)
	...i StationID="" d
	....s Flag=0
	....q:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," N"," "_RoomID," "_PAADM))
	....q:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," P"," "_RoomID," "_PAADM))
	....q:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," O"," "_RoomID," "_PAADM))
	....s Flag=1
	...e  d
	....s QFlag=0
	....s FlagArea=""
	....f  s FlagArea=$O(^User.DHCPERoomI("RStationIndex",StationID,FlagArea)) q:(FlagArea="")||(QFlag=1)  d
	.....s FlagRoomSub=""
	.....f  s FlagRoomSub=$O(^User.DHCPERoomI("RStationIndex",StationID,FlagArea,FlagRoomSub)) q:(FlagRoomSub="")||(QFlag=1)  d
	......s FlagRoomID=FlagArea_"||"_FlagRoomSub
	......;s:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," N"," "_FlagRoomID," "_PAADM)) QFlag=1
	......;s:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," P"," "_FlagRoomID," "_PAADM)) QFlag=1
	......s:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," O"," "_FlagRoomID," "_PAADM)) QFlag=1
	....q:QFlag=1
	....s SpecStr=""
	....i StationID=$G(^DHCPESetting("DHCPE","StationId_Lab")) d
	.....s SpecStr=..GetAllSpec(RoomID)
	.....s SpecStr="^"_SpecStr_"^"
	....s Flag=0
	....s OrdSub=0
	....f  s OrdSub=$O(^DHCPEPreIADM(PreAdm,"ORDITEM",OrdSub)) q:(OrdSub="")||(Flag=1)  d
	.....s DietFlag=$P(^DHCPEPreIADM(PreAdm,"ORDITEM",OrdSub),"^",2)
	.....s Stat=$P(^DHCPEPreIADM(PreAdm,"ORDITEM",OrdSub),"^",16)
	.....q:Stat'="1"
	.....s CrmOrderID=$O(^DHCPECRMO(0,"CRMORI",PreAdm_"||"_OrdSub,0))
	.....q:CrmOrderID=""
	.....s OrdItemID=$P(^DHCPECRMO(CrmOrderID),"^",1)
	.....s Stat=$P(^OEORD(+OrdItemID,"I",$P(OrdItemID,"||",2),1),"^",13)
	.....q:Stat="6" ;执行的退出
	.....q:(Stat="1")&&$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrdItemID)) ;谢绝检查的退出
	.....s ItemMastID=$P(^OEORD(+OrdItemID,"I",$P(OrdItemID,"||",2),1),"^",2)
	.....
	.....q:ItemMastID=""
	.....s STID=$O(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))
	
	.....q:STID'=StationID
	
	.....;q:(Diet'="N")&&(DietFlag'=Diet)
	.....i StationID=$G(^DHCPESetting("DHCPE","StationId_Lab")) d
	......s SpecNo=$p($G(^OEORD(+OrdItemID,"I",$P(OrdItemID,"||",2),3)),"^",20)
	......q:SpecNo=""
	......q:$D(^DHCPETempLabEpisodeScan(SpecNo))   //已经抽血确认的退出
	......s CurSpec=$G(^DHCPEDataEx("DHCPEPreIOrdItem","PERSON",PreAdm_"||"_OrdSub))
	......s CurSpec=$P(CurSpec,"^",1)
	......s:SpecStr[("^"_CurSpec_"^") Flag=1
	.....e  d
	......s Flag=1
	....q:Flag=0
    ....s PassPerson=..GetTotalPersonByRoom(RoomID,"P")
	....s NewPerson=..GetTotalPersonByRoom(RoomID,"N")
	....s TotalPerson=NewPerson  ;+PassPerson
	....s TotalMinute=TotalPerson*OneMinute
	....s SortIndex=$i(^TempDHCPERoomInsert(Job))
	....s ^TempDHCPERoomInsert(Job,"Sort",Sort,TotalMinute,SortIndex)=RoomID_"^"_NewPerson
	s Sort=""
	f  s Sort=$O(^TempDHCPERoomInsert(Job,"Sort",Sort)) q:Sort=""  d
	.s TWaitMinute=""
	.f  s TWaitMinute=$O(^TempDHCPERoomInsert(Job,"Sort",Sort,TWaitMinute)) q:TWaitMinute=""  d
	..s SortIndex=""
	..f  s SortIndex=$O(^TempDHCPERoomInsert(Job,"Sort",Sort,TWaitMinute,SortIndex)) q:SortIndex=""  d
	...s Info=$G(^TempDHCPERoomInsert(Job,"Sort",Sort,TWaitMinute,SortIndex))
	...s TRoomID=$P(Info,"^",1)
	...q:$D(^User.DHCPEAdmRefuseRoomI("PAADMStatus",PAADM,"RF",TRoomID))
	...s TWaitNum=$P(Info,"^",2)
	...s TRoomDesc=$LG(^User.DHCPEAreaD(+TRoomID,"ChildRoom",$P(TRoomID,"||",2)),3)
	...s TAreaDesc=$LG(^User.DHCPEAreaD(+TRoomID),3)
	...d AdmNeedRoomBuild
	s TRoomID=""
	f  s TRoomID=$O(^User.DHCPEAdmRefuseRoomI("PAADMStatus",PAADM,"RF",TRoomID)) q:TRoomID=""  d
	.s TRoomDesc=$LG(^User.DHCPEAreaD(+TRoomID,"ChildRoom",$P(TRoomID,"||",2)),3)
	.s TAreaDesc=$LG(^User.DHCPEAreaD(+TRoomID),3)
	.s PassPerson=..GetTotalPersonByRoom(TRoomID,"P")
	.s NewPerson=..GetTotalPersonByRoom(TRoomID,"N")
	.s TotalPerson=NewPerson  ;+PassPerson
	.s TWaitNum=TotalPerson
	.s OneMinute=$LG(^User.DHCPEAreaD(+TRoomID,"ChildRoom",$P(TRoomID,"||",2)),12)
	.s TWaitMinute=(TotalPerson*OneMinute)
    .I $D(^User.DHCPEAdmRefuseRoomI("PAADMStatus",PAADM,"RF",TRoomID)) s TRefuseRoom="放弃"
  
	.d AdmNeedRoomBuild
	k ^TempDHCPERoomInsert(Job)
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
AdmNeedRoomBuild
	set Data=$lb(TRoomID,TRoomDesc,TWaitNum,TWaitMinute,TAreaDesc,PAADM,TRefuseRoom)
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod AdmNeedRoomClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = AdmNeedRoomExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod AdmNeedRoomFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = AdmNeedRoomExecute ]
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

ClassMethod DeleteNoUserRoomInfo(Type As %String = 0)
{
	;d ##class(web.DHCPE.RoomManager).DeleteNoUserRoomInfo(1)
	 
	s $ZT="DeleteErr"
	s Date=+$H
	q:(Type=0)&&($D(^DHCPEDataEx("DeleteNoUserRoomInfo",Date))) 0
	s ^DHCPEDataEx("DeleteNoUserRoomInfo",Date)=$H
	&SQL(Delete From Sqluser.DHC_PE_AdmRoomRecord where ((ARR_Status='N') or (ARR_Status='P')))
	q:SQLCODE<0 SQLCODE
	&SQL(Delete From Sqluser.DHC_PE_CurDateAdmInfo where CDA_Date=:Date)
	q SQLCODE
DeleteErr
	q "Err"
}

ClassMethod IsHadCT(RoomID, AdmId)
{
	
	s RoomID=$P(RoomID,"$",1)
	q:RoomID="" 0
	s Station=$LG(^User.DHCPEAreaD(+RoomID,"ChildRoom",$P(RoomID,"||",2)),7)
	q:(Station'=8) "0"
	
	;s ^sxt("staa")=AdmId
	s peid=$o(^DHCPEIADM(0,"PAADM",AdmId,0))
	q:peid="" "0"
	s preid=$p(^DHCPEIADM(peid),"^",4)
 	q:preid="" "0"
 	s AdmId=preid
	;q "1"
	q:(AdmId="") "0"
	s Flag="",sub2=0
	f  s sub2=$o(^DHCPEPreIADM(AdmId,"ORDITEM",sub2))  q:sub2=""  d
	.s status=$p($g(^DHCPEPreIADM(AdmId,"ORDITEM",sub2)),"^",16)
	.;q:(status'=1)
	.
	.s MastDr=$p($g(^DHCPEPreIADM(AdmId,"ORDITEM",sub2)),"^",1)
	.s CTSta=$o(^DHCPEST(0,"STORD_ARCIM",MastDr,0))
	.s:((status=1)&&(CTSta=13)) Flag="1"
	;q status
	;;q "1"
	q:(Flag="1") "1"
	q "0"
}

ClassMethod CanCheck(RoomID, PAADM)
{
	;0可以检查1不可以检查
	;w ##class(web.DHCPE.RoomManager).CanCheck("1||21$Y",3512669)
	q:RoomID="" ""
	s RoomID=$P(RoomID,"$",1)
	q:$D(^User.DHCPEAdmRefuseRoomI("PAADMStatus",PAADM,"RF",RoomID)) "-1"
	
 

 
	s VIPLevel=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM", PAADM)
	q:VIPLevel[("VIP") 0
	s Flag=1
	s HadFlag=0  //判断是否进入了特殊真实判断0：没进入可以检查
	s OtherRoom=""
	s LabStation=$G(^DHCPESetting("DHCPE","StationId_Lab"))
	s OrderID=$O(^OEORD(0,"Adm",PAADM,0))
	//s RoomID=$P(RoomID,"$",1)
	s StationIDs=##class(web.DHCPE.ResultDiagnosis).AdmNeedStation(PAADM)
	s StationIDs="^"_StationIDs_"^"
	s Main=+RoomID
	s Sub=$P(RoomID,"||",2)
	f  s OtherRoom=$O(^User.DHCPERoomSpecialRoomI("RoomIDIndex",+RoomID,Sub,OtherRoom)) q:(OtherRoom="")||(Flag=0)  d
	.s OtherRoomID=$P(OtherRoom," ",2)
	.s RoomActiveFlag=$LG(^User.DHCPEAreaD(+OtherRoomID,"ChildRoom",$P(OtherRoomID,"||",2)),14)
	.s Station=$LG(^User.DHCPEAreaD(+OtherRoomID,"ChildRoom",$P(OtherRoomID,"||",2)),7)
	.s:Station="" Flag=0
	.q:StationIDs'[("^"_Station_"^")
	.i RoomActiveFlag="Y" d
	..s HadFlag=1
	.b ;^User.DHCPEAdmRoomRecordI("StatusIndex"," O"," "_OtherRoomID," "_PAADM)
	.s:$D(^User.DHCPEAdmRoomRecordI("StatusIndex"," O"," "_OtherRoomID," "_PAADM)) Flag=0
	.s:$D(^User.DHCPEAdmRefuseRoomI("PAADMStatus",PAADM,"RF",OtherRoomID)) Flag=0
	q:HadFlag=0 0
	
	q Flag
	
	
	
	.i LabStation=Station d
	..s SpecStr=..GetAllSpec(OtherRoomID)
	..s SpecStr="^"_SpecStr_"^"
	..;q:$D(^DHCPETempLabEpisodeScan(SpecNo))
	..s ItemSub=0
	..f  s ItemSub=$O(^OEORD(OrderID,"I",ItemSub)) q:(ItemSub="")||(Flag=0)  d
	...s ItemStat=$p($G(^OEORD(OrderID,"I",ItemSub,1)),"^",13)
	...q:ItemStat'="1"
	...q:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrderID_"||"_ItemSub))
	...s LabNo=$p($G(^OEORD(+OrderID,"I",ItemSub,3)),"^",20)
	...q:LabNo=""
	...q:$D(^DHCPETempLabEpisodeScan(LabNo))   //已经抽血确认的退出
	...s CRMOrderID=$O(^DHCPECRMO(0,"OEORI",OrderID_"||"_ItemSub,0))
	...q:CRMOrderID=""
	...s PreItemID=$P(^DHCPECRMO(CRMOrderID),"^",2)
	...q:PreItemID=""
	...s CurSpec=$G(^DHCPEDataEx("DHCPEPreIOrdItem","PERSON",PreItemID))
	...s CurSpec=$P(CurSpec,"^",1)
	...s:SpecStr[("^"_CurSpec_"^") Flag=0
	.e  d
	..s ItemSub=0
	..f  s ItemSub=$O(^OEORD(OrderID,"I",ItemSub)) q:(ItemSub="")||(Flag=0)  d
	...s ItemStat=$p($G(^OEORD(OrderID,"I",ItemSub,1)),"^",13)
	...q:ItemStat'="1"
	...s ArcIMID=$p($G(^OEORD(OrderID,"I",ItemSub,1)),"^",2)
	...s STID=$O(^DHCPEST(0,"STORD_ARCIM",ArcIMID,0))
	...q:STID'=Station
	...s Flag=0
	q Flag
}

ClassMethod NeedDeleteOldRoom(PreID)
{
	s OldRoomID=..GetAdmCurRoom(PreID, "PRE","")
	q:OldRoomID="" 0
	
	s RoomPlace=$G(^DHCPEDataEx("DHCPEPreIADM","RoomPlace",PreID))
	s OldRoomID=$LG(^User.DHCPEAdmRoomRecordD($P(OldRoomID,"^",1)),6)
	q:'$D(^User.DHCPERoomRoomPlaceI("RoomPlaceIndex",+OldRoomID,$P(OldRoomID,"||",2)," "_RoomPlace)) 1
	q 0
}

// w ##class(web.DHCPE.RoomManager).DeleteOldRoom(182441)

ClassMethod DeleteOldRoom(PreID)
{
	s OldRoomID=..GetAdmCurRoom(PreID, "PRE","")
	q:OldRoomID="" 0
	b ;OldRoomID
	s CurInfo=..StopCurRoomInfo($P(OldRoomID,"^",1))
	b ;CurInfo
	s IADM=$O(^DHCPEIADM(0,"CRMADM",PreID,0))
	q:IADM="" ""
	s PAADM=$P(^DHCPEIADM(IADM),"^",1)
	
	i +CurInfo="0" d
	.d ..InsertRoomRecord(PAADM)
	s CurRoomInfo=..GetAdmCurRoom(PreID, "PRE","")
	q:CurRoomInfo="" "0^操作成功"
	q "0^请'"_$P(CurRoomInfo,"^",4)_"'到'"_$P(CurRoomInfo,"^",2)_"'处候诊,您是第'"_$P(CurRoomInfo,"^",3)_"'位"
		//CurRoomID_"^"_RoomDesc_"^"_NewPerson_"^"_Name
}

ClassMethod GetBarPrintFlag(RoomID)
{
	q:RoomID="" 0
	q $G(^DHCPEDataEx("Room","PrintBar",RoomID))_"^"_$G(^DHCPEDataEx("Room","BGEquipe",RoomID))
}

ClassMethod Test1()
{
	;d ##class(web.DHCPE.RoomManager).Test1()
	s Status="a"
	w Status,!
	d ..Test2()
	w Status,!
}

ClassMethod Test2()
{
	s Status="b"
}

Storage Default
{
<Data name="RoomManagerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.RoomManagerD</DataLocation>
<DefaultData>RoomManagerDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.RoomManagerD</IdLocation>
<IndexLocation>^web.DHCPE.RoomManagerI</IndexLocation>
<StreamLocation>^web.DHCPE.RoomManagerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
