Class web.DHCPE.Query.RunQianQuery Extends %RegisteredObject
{

/// d ##class(%ResultSet).RunQuery("web.DHCPE.Query.RunQianQuery","DocWork","2013-01-01","2014-10-01")
Query DocWork(BeginDate As %Library.String = "", EndDate As %Library.String = "") As %Query(ROWSPEC = "RecLoc:%String,DocId:%String,DocName:%String,ARCIMDesc:%String,AccountAmount:%Float,FactAmount:%Float") [ SqlProc ]
{
}

ClassMethod DocWorkExecute(ByRef qHandle As %Binary, BeginDate As %Library.String = "", EndDate As %Library.String = "") As %Status
{
	
	Set repid=$I(^CacheTemp)
	
 	s ind=1
 	
 	i BeginDate="" s BeginDate=+$h
	e  s BeginDate=$zdh(BeginDate,3)
	i EndDate="" s EndDate=+$h
	e  s EndDate=$zdh(EndDate,3)
 	
 	s PreAudits=""
 	f date=BeginDate:1:EndDate d
 	.s rprowid=0
 	.f  s rprowid=$o(^DHCPEUSERREPORT(0,"DATE",date,rprowid)) q:rprowid=""  d
 	..s invrowid=0
 	..f  s invrowid=$o(^DHCPEINVPRT(0,"REPORT",rprowid,invrowid)) q:invrowid=""  d
 	...s billId=$p($g(^DHCPEINVPRT(invrowid)),"^",3)
 	...q:billId=""
 	...s relateid=""
 	...f  s relateid=$o(^DHCPEPAPBR(0,"PBDR",billId,relateid)) q:relateid=""  d
 	....i PreAudits'=""  s PreAudits=PreAudits_","
 	....s PreAudits=PreAudits_$p($g(^DHCPEPAPBR(relateid)),"^",1)
 	s namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
 	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
 	s i=1
	while(i<=$l(PreAudits,",")){
		s preAuditId=$p(PreAudits,",",i)
		q:preAuditId=""
		s preAdmId=""
		s preAdmIds=""
		s i=i+1
		f  s preAdmId=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId)) q:preAdmId=""  d
		.s childsub=""
		.f  s childsub=$o(^DHCPEPreIADM(0,"PAORDITEM",preAuditId,preAdmId,childsub)) q:childsub=""  d
		..q:$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",16)'=1	//判断是否有效
		..s CRMO=$o(^DHCPECRMO(0,"CRMORI",preAdmId_"||"_childsub,0))
		..q:CRMO=""
		..s OEORIRowId=$p(^DHCPECRMO(CRMO),"^",1)
		..q:OEORIRowId=""
		..s OEORIItemStatDR=+$P($G(^OEORD(+OEORIRowId,"I",$p(OEORIRowId,"||",2),1)),"^",13)
		..Q:(6'=OEORIItemStatDR)
		..s RecDepDR=$P($G(^OEORD(+OEORIRowId,"I",$p(OEORIRowId,"||",2),3)),"^",6)
		..s RecLoc=$P($G(^CTLOC(RecDepDR)),"^",2)
		..s ItmMastDR=$P($G(^OEORD(+OEORIRowId,"I",$p(OEORIRowId,"||",2),1)),"^",2)
		..s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ItmMastDR,0))
		..q:STRowId=""
		..s RLTId="",DocId="",DocName=""
		..f  s RLTId=$o(^DHCPERLT(0,"OEORI",OEORIRowId,RLTId)) q:RLTId=""  d
		...s DocId=$p(^DHCPERLT(RLTId),"^",5)
		...q:DocId=""
		...s DocName=$p($g(^SSU("SSUSR",DocId)),"^",2)
		...i STRowId=LabStation s DocName=$p($g(^[namespaceLab]SSU("SSUSR",1,DocId)),"^",2)
		..q:DocId=""
		..s ARCIMDesc=$P($G(^ARCIM(+ItmMastDR,$p(ItmMastDR,"||",2),1)),"^",2)
		..s FactAmount=+##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(preAdmId_"||"_childsub,"","")
 		..s AccountAmount=$p($g(^DHCPEPreIADM(preAdmId,"ORDITEM",childsub)),"^",14)
 		..d DocWork

	}

	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
DocWork
	set Data=$lb(RecLoc,DocId,DocName,ARCIMDesc,AccountAmount,FactAmount)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod DocWorkFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = DocWorkExecute ]
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

ClassMethod DocWorkClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = DocWorkExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// 医嘱数量查询
/// d ##class(%ResultSet).RunQuery("web.DHCPE.Query.RunQianQuery","GetItem","2017-12-13","2017-12-13","13338||1","","","")
Query GetItem(BeginDate As %Library.String = "", EndDate As %Library.String = "", ArcItemID As %String = "", ToDay As %String = "", CheckFlag As %String = "", UserID As %String = "") As %Query(ROWSPEC = "yyyymmddDate:%String,ItemDesc:%String,Flag:%String,Name:%String,RegNo:%String,HPNo:%String,CheckDate:%String,ItemNum:%Float,ItemPrice:%Float") [ SqlProc ]
{
}

ClassMethod GetItemExecute(ByRef qHandle As %Binary, BeginDate As %Library.String = "", EndDate As %Library.String = "", ArcItemID As %String = "", ToDay As %String = "", CheckFlag As %String = "", UserID As %String = "") As %Status
{
	s ind=1
 	s id=0
 	Set repid=$I(^CacheTemp)
 	
 	i (ArcItemID="")
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
 	}
 	s Job=$J
 	s:UserID="" UserID=Job
 	k ^TempDHCPE("RegNum",UserID)
 	
 	i BeginDate'="" s BeginDate=##class(websys.Conversions).DateHtmlToLogical(BeginDate) 
	i EndDate'="" s EndDate=##class(websys.Conversions).DateHtmlToLogical(EndDate) 
	i ToDay'="" s ToDay=##class(websys.Conversions).DateHtmlToLogical(ToDay) 
	
	i BeginDate="" s BeginDate=1
	i EndDate="" s EndDate=+$H
	s AdmDate=0
	s:(""'=BeginDate) AdmDate=$O(^DHCPEIADM(0,"AdmDateTime",BeginDate), -1)
	f  s AdmDate=$O(^DHCPEIADM(0,"AdmDateTime",AdmDate)) q:(""=AdmDate)||((""'=EndDate)&&(AdmDate>EndDate))  d
	.;q:(ToDay'="")&&(ToDay'=AdmDate)
	.s AdmTime=0
	.f  s AdmTime=$o(^DHCPEIADM(0,"AdmDateTime",AdmDate,AdmTime)) q:AdmTime=""  d
	..s IADM=""
	..f  s IADM=$o(^DHCPEIADM(0,"AdmDateTime",AdmDate,AdmTime,IADM)) q:IADM=""  d
	...s Status=$p(^DHCPEIADM(IADM),"^",8)
	...q:Status="CANCELPE"
	...s preIADM=$p(^DHCPEIADM(IADM),"^",4)
	...s PIBI=$p(^DHCPEPreIADM(preIADM),"^",1)
	...s RegNo=$p($G(^DHCPEPreIBI(PIBI)),"^",1)
	...s Name=$p($G(^DHCPEPreIBI(PIBI)),"^",2)
	...s HPNo=$p(^DHCPEPreIADM(preIADM),"^",27)
	...s sub=0
	...f  s sub=$o(^DHCPEPreIADM(preIADM,"ORDITEM",sub)) q:sub=""  d
	....s arcItemID=$P(^DHCPEPreIADM(preIADM,"ORDITEM",sub),"^",1)
	....q:ArcItemID'=arcItemID
	....s ItemStatus=$p(^DHCPEPreIADM(preIADM,"ORDITEM",sub),"^",16)
	....q:ItemStatus'="1"
	....s ItemPrice=$p(^DHCPEPreIADM(preIADM,"ORDITEM",sub),"^",14)
	....s PIOIRowID=preIADM_"||"_sub
	....s Flag=0
	....s CheckDate=""
	....s CRMOID=""
	....f  s CRMOID=$o(^DHCPECRMO(0,"CRMORI",PIOIRowID,CRMOID)) q:CRMOID=""  d
	.....s OEORDRowId=$p(^DHCPECRMO(CRMOID),"^",1)
	.....i $D(^DHCPERLT(0,"OEORI",OEORDRowId)) d
	......s Flag=1
	......s RLTRowID=$o(^DHCPERLT(0,"OEORI",OEORDRowId,0))
	......s CheckDate=$p(^DHCPERLT(RLTRowID),"^",6)
	......s:CheckDate'="" CheckDate=##class(websys.Conversions).DateLogicalToHtml(CheckDate)
	....s ^TempDHCPE("RegNum",UserID,"ARCIMTotal",AdmDate,arcItemID,1,preIADM,"Num")=+$G(^TempDHCPE("RegNum",UserID,"ARCIMTotal",AdmDate,arcItemID,1,preIADM,"Num"))+1
	....s ^TempDHCPE("RegNum",UserID,"ARCIMTotal",AdmDate,arcItemID,1,preIADM,"Info")=RegNo_"^"_Name_"^"_HPNo_"^"_ItemPrice_"^"_CheckDate
	....i Flag=1 d
	.....s ^TempDHCPE("RegNum",UserID,"ARCIMTotal",AdmDate,arcItemID,2,preIADM,"Num")=+$G(^TempDHCPE("RegNum",UserID,"ARCIMTotal",AdmDate,arcItemID,2,preIADM,"Num"))+1
	.....s ^TempDHCPE("RegNum",UserID,"ARCIMTotal",AdmDate,arcItemID,2,preIADM,"Info")=RegNo_"^"_Name_"^"_HPNo_"^"_ItemPrice_"^"_CheckDate
	
	s date=0
	f  s date=$O(^TempDHCPE("RegNum",UserID,"ARCIMTotal",date)) q:date=""  d
	.s arc=ArcItemID
	.s ARCIMDesc=$P($G(^ARCIM(+ArcItemID,$p(ArcItemID,"||",2),1)),"^",2)
	.s flag=0
	.f  s flag=$o(^TempDHCPE("RegNum",UserID,"ARCIMTotal",date,arc,flag)) q:flag=""  d
	..q:(CheckFlag'="")&&(CheckFlag'=flag)
	..s preIADM=0
	..f  s preIADM=$o(^TempDHCPE("RegNum",UserID,"ARCIMTotal",date,arc,flag,preIADM)) q:preIADM=""  d
	...s ItemNum=$G(^TempDHCPE("RegNum",UserID,"ARCIMTotal",date,arc,flag,preIADM,"Num"))
    ...s Info=$G(^TempDHCPE("RegNum",UserID,"ARCIMTotal",date,arc,flag,preIADM,"Info"))
	...s RegNo=$p(Info,"^",1)
	...s Name=$p(Info,"^",2)
	...s HPNo=$p(Info,"^",3)
	...s ItemPrice=$p(Info,"^",4)
	...s CheckDate=$p(Info,"^",5)
	...s yyyymmddDate=##class(websys.Conversions).DateLogicalToHtml(date)
	...d GetItemOut
 	 	 
   	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
 	
GetItemOut
    s Data=$LB(yyyymmddDate,ARCIMDesc,flag,Name,RegNo,HPNo,CheckDate,ItemNum,ItemPrice)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod GetItemFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = GetItemExecute ]
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

ClassMethod GetItemClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetItemExecute ]
{
    Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// 统计自费没交钱做了体检的人员信息
/// d ##class(%ResultSet).RunQuery("web.DHCPE.Query.RunQianQuery","ArrNoPay","2013-01-01","2018-1-27")
Query ArrNoPay(BeginDate As %Library.String = "", EndDate As %Library.String = "") As %Query(ROWSPEC = "RegNo:%String,Name:%String,TeamName:%String,NoPayCount:%Float") [ SqlProc ]
{
}

ClassMethod ArrNoPayExecute(ByRef qHandle As %Binary, BeginDate As %Library.String = "", EndDate As %Library.String = "") As %Status
{
	
	Set repid=$I(^CacheTemp)
	
 	s ind=1
 	
 	i BeginDate="" s BeginDate=+$h
	e  s BeginDate=$zdh(BeginDate,3)
	i EndDate="" s EndDate=+$h
	e  s EndDate=$zdh(EndDate,3)
    
    f teamDate=BeginDate:1:EndDate d
	.s teamTime=""
 	.f  s teamTime=$o(^DHCPEIADM(0,"AdmDateTime",teamDate,teamTime)) q:teamTime=""  d
 	..;b ;d
 	..s IADMId=""
    ..f  s IADMId=$O(^DHCPEIADM(0,"AdmDateTime",teamDate,teamTime,IADMId)) q:IADMId=""  d
    ...s TeamId=""
    ...s TeamId=$P($G(^DHCPEIADM(IADMId)),"^",2)
    ...q:TeamId=""
    ...s Status=$P($G(^DHCPEIADM(IADMId)),"^",8) ;ARRIVED
    ...q:Status'="ARRIVED"
    ...s StatusBill=$P($G(^DHCPEIADM(IADMId)),"^",16) ;GD  RegNo,Name,TeamName,NoPayCount
    ...q:StatusBill="ID"
 	...s RegNo="",Name="",TeamName="",NoPayCount=""
 	...s PreteamId=$P($G(^DHCPEGADM(TeamId)),"^",1)
 	...b ;1
 	...s TeamName=$P($G(^DHCPEGBI(PreteamId)),"^",2)
 	...s IADMCRMADM=$P($G(^DHCPEIADM(IADMId)),"^",4)
 	...s PIADMPIBIDR=$P($G(^DHCPEPreIADM(IADMCRMADM)),"^",1)
 	...s Name=$p($g(^DHCPEPreIBI(PIADMPIBIDR)),"^",2)
 	...s RegNo=$p($g(^DHCPEPreIBI(PIADMPIBIDR)),"^",1)
 	...;// 应付金额^最终金额^公费金额^公费已付^公费未付^自费金额^自费已付^自费未付
 	...s NoPayCount=0
 	...s retvalue=##Class(web.DHCPE.InvPrt).GetAdmFee(IADMCRMADM)
	...Q:(""=retvalue)
	...s NoPayCount=+$P(retvalue,"^",8)
	...q:NoPayCount=0
	...//公费已付金额
	...d ArrNoPay
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
ArrNoPay
	set Data=$lb(RegNo,Name,TeamName,NoPayCount)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod ArrNoPayFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = ArrNoPayExecute ]
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

ClassMethod ArrNoPayClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = ArrNoPayExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// 筛选个人及团体的弃检数量及具体科室
/// d ##class(%ResultSet).RunQuery("web.DHCPE.Query.RunQianQuery","PERefuseCheckInfo","2017-09-20","2017-12-31","")
Query PERefuseCheckInfo(BeginDate As %Library.String = "", EndDate As %Library.String = "", GroupID As %Library.String = "") As %Query(ROWSPEC = "GDesc:%String,RegNo:%String,Name:%String,ARCIMDesc:%String,RecLocDesc:%String") [ SqlProc ]
{
}

ClassMethod PERefuseCheckInfoExecute(ByRef qHandle As %Binary, BeginDate As %Library.String = "", EndDate As %Library.String = "", GroupID As %Library.String = "") As %Status
{
	
	Set repid=$I(^CacheTemp)
	
 	s ind=1
 	
 	i BeginDate="" s BeginDate=+$h
	e  s BeginDate=$zdh(BeginDate,3)
	i EndDate="" s EndDate=+$h
	e  s EndDate=$zdh(EndDate,3)
	
 	i GroupID'="" d
	.s GADM=GroupID
	.s Team=0
	.f  s Team=$o(^DHCPEIADM(0,"GADM",GADM,Team)) q:Team=""  d
	..s IADM=0
	..f  s IADM=$o(^DHCPEIADM(0,"GADM",GADM,Team,IADM)) q:IADM=""  d
	...d GetIADMInfo
	e  d
	.s AdmDate=0
	.s:(""'=BeginDate) AdmDate=$O(^DHCPEIADM(0,"AdmDateTime",BeginDate), -1)
	.f  s AdmDate=$O(^DHCPEIADM(0,"AdmDateTime",AdmDate)) q:(""=AdmDate)||((""'=EndDate)&&(AdmDate>EndDate))  d
	..s AdmTime=0
	..f  s AdmTime=$o(^DHCPEIADM(0,"AdmDateTime",AdmDate,AdmTime)) q:AdmTime=""  d
	...s IADM=""
	...f  s IADM=$o(^DHCPEIADM(0,"AdmDateTime",AdmDate,AdmTime,IADM)) q:IADM=""  d
	....d GetIADMInfo
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
GetIADMInfo
	s Status=$p(^DHCPEIADM(IADM),"^",8)
	q:Status'="ARRIVED"
	s PIADM=$p(^DHCPEIADM(IADM),"^",4)
	s GDesc=""
	s PGADM=$p(^DHCPEPreIADM(PIADM),"^",2)
	i PGADM'="" d
	.s PGBI=$p($g(^DHCPEPreGADM(PGADM)),"^",1)
	.i PGBI'="" d
	..s GDesc=$p($g(^DHCPEPreGBI(PGBI)),"^",2)
	s PIBI=$p(^DHCPEPreIADM(PIADM),"^",1)
	q:PIBI=""
	s RegNo=$p($g(^DHCPEPreIBI(PIBI)),"^",1)
	s Name=$p($g(^DHCPEPreIBI(PIBI)),"^",2)
	s CRMOID=""
	f  s CRMOID=$o(^DHCPECRMO(0,"IADM",IADM,CRMOID)) q:CRMOID=""  d
	.s OEORIDR=$p(^DHCPECRMO(CRMOID),"^",1)
	.q:'$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OEORIDR))
	.s CRMORI=$p(^DHCPECRMO(CRMOID),"^",2)
	.s RecLoc=$p(^DHCPEPreIADM(+CRMORI,"ORDITEM",$p(CRMORI,"||",2)),"^",17)
	.s RecLocDesc=$p(^CTLOC(RecLoc),"^",2)
	.s ItmMastDR=$P($G(^OEORD(+OEORIDR,"I",$p(OEORIDR,"||",2),1)),"^",2)
	.s ARCIMSubscript=$P(ItmMastDR,"||",1)
	.s ARCIMVersion=$P(ItmMastDR,"||",2)
	.s ARCIMDesc=$P($G(^ARCIM(ARCIMSubscript,ARCIMVersion,1)),"^",2)
	.d OutRow

	q
OutRow
	set Data=$lb(GDesc,RegNo,Name,ARCIMDesc,RecLocDesc)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod PERefuseCheckInfoFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = PERefuseCheckInfoExecute ]
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

ClassMethod PERefuseCheckInfoClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = PERefuseCheckInfoExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

// 体检收入报表

// d ##class(%ResultSet).RunQuery("web.DHCPE.Query.RunQianQuery","Income","2016-12-1","2016-12-10")

Query Income(BeginDate As %Library.String = "", EndDate As %Library.String = "") As %Query(ROWSPEC = "Type:%String,Desc:%String,Num2:%String,Num:%String,CountAmount:%Float,BillAmount:%Float,NotBillAmount:%Float") [ SqlProc ]
{
}

ClassMethod IncomeExecute(ByRef qHandle As %Binary, BeginDate As %Library.String = "", EndDate As %Library.String = "") As %Status
{
	
	Set repid=$I(^CacheTemp)
	
 	s ind=1
 	k ^DHCPERUNQIANMark
 	i BeginDate="" s BeginDate=+$h
	e  s BeginDate=$zdh(BeginDate,3)
	i EndDate="" s EndDate=+$h
	e  s EndDate=$zdh(EndDate,3)
 
 	f date=BeginDate:1:EndDate d
 	.s Invrowid=0
 	.f  s Invrowid=$o(^DHCPEINVPRT(0,"DATE",date,Invrowid)) q:Invrowid=""  d
 	..s Num2="",Type="",Desc="",Num="",CountAmount="",BillAmount="",NotBillAmount=""
 	..s UserId=$P($G(^DHCPEINVPRT(Invrowid)),"^",10)
 	..s Type="门诊收费"
 	..s paadm=$p($G(^DHCPEINVPRT(Invrowid)),"^",2)
	..s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PAADM",paadm)
  	..;q:(LocFlag=1)	
	..s patid=$p($g(^PAADM(paadm)),"^",1)
	..if patid="" q
	..s giadmid=$o(^DHCPEIADM(0,"PAADM",paadm,""))
	..q:giadmid=""
 	..s personMark=""
 	..s personMark=$P($G(^DHCPEINVPRT(Invrowid)),"^",1)
 	..s Desc=$P($G(^SSU("SSUSR",UserId)),"^",2)
 	..s Num2=1
 	..i $d(^DHCPERUNQIANMark(paadm)) d
 	...s Num2=0
 	..s ^DHCPERUNQIANMark(paadm)=paadm
 	..i personMark="" d
 	...s Num=0
 	..e  d
 	...s Num=1
 	..s CountAmount=$P($G(^DHCPEINVPRT(Invrowid)),"^",7)
 	..s BillAmount=$P($G(^DHCPEINVPRT(Invrowid)),"^",7)
 	..s NotBillAmount=CountAmount-BillAmount
 	..d IncomeOutput
    
    f teamDate=BeginDate:1:EndDate d
	.s teamTime=""
 	.f  s teamTime=$o(^DHCPEIADM(0,"AdmDateTime",teamDate,teamTime)) q:teamTime=""  d
 	..s IADMId=""
    ..f  s IADMId=$O(^DHCPEIADM(0,"AdmDateTime",teamDate,teamTime,IADMId)) q:IADMId=""  d
    ...s TeamId=""
    ...s TeamId=$P($G(^DHCPEIADM(IADMId)),"^",2)
    ...q:TeamId=""
    ...s Status=$P($G(^DHCPEIADM(IADMId)),"^",8) ;ARRIVED
    ...q:'((Status="ARRIVED")||(Status="COMPLETED"))
    ...s Type="",Desc="",Num="",CountAmount="",BillAmount="",NotBillAmount=""
 	...s Num=1
 	...s Num2=1
    ...s StatusBill=""
    ...s StatusBill=$P($G(^DHCPEIADM(IADMId)),"^",3) ;GD
    ...q:StatusBill'["||"
    ...;q:'(StatusBill="GD")
 	...s Type="团体收费"
 	...
 	...;s PreteamId=""
 	...;s PreteamId=$P( $G(^DHCPEGADM(TeamId)),"^",1)
 	...s Desc=##Class(web.DHCPE.DHCPEGAdm).GetGAdmDesc(TeamId) ;;$P($G(^DHCPEPreGBI(PreteamId)),"^",2)_"^"_IADMId
 	...;s CashAmount=""   ;  按照个人预约查询界面的费用取费用
 	...s IADMCRMADM=$P($G(^DHCPEIADM(IADMId)),"^",4)
 	...;// 应付金额^最终金额^公费金额^公费已付^公费未付^自费金额^自费已付^自费未付
 	...s retvalue=##Class(web.DHCPE.InvPrt).GetAdmFee(IADMCRMADM)
	...;Q:(""=retvalue)
	...// 实际金额
	...s CountAmount=+$P(retvalue,"^",3)
	...s NotBillAmount=+$P(retvalue,"^",5)
	...s BillAmount=+$P(retvalue,"^",4)
 	...d IncomeOutput
 	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
IncomeOutput
	set Data=$lb(Type,Desc,Num2,Num,CountAmount,BillAmount,NotBillAmount)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod IncomeFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = IncomeExecute ]
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

ClassMethod IncomeClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = IncomeExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

// 体检应收款报表

// d ##class(%ResultSet).RunQuery("web.DHCPE.Query.RunQianQuery","Arrearage","2016-11-14","2016-11-14")

Query Arrearage(BeginDate As %Library.String = "", EndDate As %Library.String = "") As %Query(ROWSPEC = "Desc:%String,CountAmount:%Float,CashAmount1:%Float,CashAmount2:%Float,CashAmount3:%Float") [ SqlProc ]
{
}

ClassMethod ArrearageExecute(ByRef qHandle As %Binary, BeginDate As %Library.String = "", EndDate As %Library.String = "") As %Status
{
	
	Set repid=$I(^CacheTemp)
 	s ind=1
 	
 	i BeginDate="" s BeginDate=+$h
	e  s BeginDate=$zdh(BeginDate,3)
	i EndDate="" s EndDate=+$h
	e  s EndDate=$zdh(EndDate,3)
    
    f teamDate=BeginDate:1:EndDate d
	.s teamTime=""
 	.f  s teamTime=$o(^DHCPEIADM(0,"AdmDateTime",teamDate,teamTime)) q:teamTime=""  d
 	..s IADMId=""
    ..f  s IADMId=$O(^DHCPEIADM(0,"AdmDateTime",teamDate,teamTime,IADMId)) q:IADMId=""  d
    ...s TeamId=""
    ...s TeamId=$P($G(^DHCPEIADM(IADMId)),"^",2)
    ...q:TeamId=""
    ...s Status=$P($G(^DHCPEIADM(IADMId)),"^",8) ;ARRIVED
    ...q:Status'="ARRIVED"
    ...i TeamId="" d
    ....s Desc="",CountAmount="",CashAmount1="",CashAmount2="",CashAmount3=""
    ....s PreIADMId=$P($G(^DHCPEIADM(IADMId)),"^",4)
    ....s PIADMPIBIDR=$P($G(^DHCPEPreIADM(PreIADMId)),"^",1)
    ....s markid=##class(web.DHCPE.HandlerPreOrds).GetPaiedFlag(PreIADMId)
    ....q:markid="2"
 	....s Desc=$p($g(^DHCPEPreIBI(PIADMPIBIDR)),"^",2)
 	....s CashAmount=""   ;  按照个人预约查询界面的费用取费用
 	....s IADMCRMADM=$P($G(^DHCPEIADM(IADMId)),"^",4)
 	....;// 应付金额^最终金额^公费金额^公费已付^公费未付^自费金额^自费已付^自费未付
 	....s retvalue=##Class(web.DHCPE.InvPrt).GetAdmFee(IADMCRMADM)
	....Q:(""=retvalue)
	....// 作废金额^个人终止金额^公费金额金额
	....s AbortFees="0^0^0^" //##Class(web.DHCPE.InvPrt).GetAdmAbortFee(IADMCRMADM)
	....// 实际金额
	....s CountAmount=+$P(retvalue,"^",2)-$P(AbortFees,"^",1)
	....//自费已付金额
	....s CashAmountMark=""
	....s CashAmountMark=+$P(retvalue,"^",7)
	....i CashAmountMark'="" d
	.....s paadm=$P($G(^DHCPEIADM(IADMId)),"^",1)
	.....s Invrowid=""
	.....f  s Invrowid=$O(^DHCPEINVPRT(0,"ADM",paadm,Invrowid)) q:Invrowid=""  d
 	......s arrcp=$P($G(^DHCPEINVPRT(Invrowid)),"^",4)
 	......s paym="0"
    ......f  s paym=$o(^ARRCP(arrcp,"PAYM",paym)) q:paym=""  d
    .......s ss=^ARRCP(arrcp,"PAYM",paym)
    .......s mode=$p(ss,"^",1)
    .......Q:'$D(^CT("CTPM",mode))
    .......s chequeno=$p(ss,"^",4) 
    .......q:mode=""  
    .......i mode'="" s CashAmountDesc=$p(^CT("CTPM",mode),"^",2)
    .......e  s pmdesc="现金"
    .......s pdamt=+$p(ss,"^",3)
    .......i CashAmountDesc["支付" d 
    ........s CashAmount3=pdamt
    .......e  d
    ........s CashAmount2=CashAmount2+pdamt
    ....d ArrearageOutput
    ...e  d
    ....
    ....s StatusBill=$P($G(^DHCPEIADM(IADMId)),"^",3) ;GD
    ....q:StatusBill'["||"
    ....;q:StatusBill'="GD"
 	....s Desc="",CountAmount="",CashAmount1="",CashAmount2="",CashAmount3=""
 	....;.s PreteamId=$P($G(^DHCPEGADM(TeamId)),"^",1)
 	....s Desc=##Class(web.DHCPE.DHCPEGAdm).GetGAdmDesc(TeamId)  ;$P($G(^DHCPEPreGBI(PreteamId)),"^",2)
 	....s CashAmount=""   ;  按照个人预约查询界面的费用取费用
 	....s IADMCRMADM=$P($G(^DHCPEIADM(IADMId)),"^",4)
 	....s PIADMPIBIDR2=$P($G(^DHCPEPreIADM(IADMCRMADM)),"^",1)
    ....s markid2=##class(web.DHCPE.HandlerPreOrds).GetPaiedFlag(PIADMPIBIDR2)
    ....;q:markid2="2"
    ....s markamount1=""
 	....;// 应付金额^最终金额^公费金额^公费已付^公费未付^自费金额^自费已付^自费未付
 	....s retvalue=##Class(web.DHCPE.InvPrt).GetAdmFee(IADMCRMADM)
 	....s markamount1=+$P(retvalue,"^",5)
 	....q:markamount1=""
 	....q:markamount1=0
	....Q:(""=retvalue)
	....// 作废金额^个人终止金额^公费金额金额
	....s AbortFees="0^0^0^" //##Class(web.DHCPE.InvPrt).GetAdmAbortFee(IADMCRMADM)
	....// 实际金额;
	....s CountAmount=+$P(retvalue,"^",2) ;-$P(AbortFees,"^",1)
	....//公费已付金额
	....s CashAmount1=+$P(retvalue,"^",4)
	....d ArrearageOutput
	
    
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
ArrearageOutput
	set Data=$lb(Desc,CountAmount,CashAmount1,CashAmount2,CashAmount3)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod ArrearageFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = ArrearageExecute ]
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

ClassMethod ArrearageClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = ArrearageExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query StationWorkStatisticNew(DateBegin As %Library.String = "", DateEnd As %Library.String = "") As %Query(ROWSPEC = "Loc:%String:科室, ArcDesc:%String:检查项目, INum:%String:个检人次, IAmount:%String:个检金额, GNum:%String:团检人次,GAmount:%String:团检金额,Num:%String:人次合计,Amount:%String:金额合计") [ SqlProc ]
{
}

ClassMethod StationWorkStatisticNewExecute(ByRef qHandle As %Binary, DateBegin As %Library.String = "", DateEnd As %Library.String = "") As %Status
{
 	s ind=1
 	s id=0	
	Set repid=$I(^CacheTemp)
	
 	if (""=DateBegin)&&(""=DateEnd){
		Set qHandle=$lb(0,repid,0)
		Quit $$$OK
 	}
 	
 	i DateBegin'=""  s DateBegin=##class(websys.Conversions).DateHtmlToLogical(DateBegin)
 	i DateEnd'=""   s DateEnd=##class(websys.Conversions).DateHtmlToLogical(DateEnd)
 	
 	k ^DHCPETMPSTA
 	
 	i (""'=DateBegin)  s SSAduitDate=DateBegin-1
    i (""=DateBegin)   s SSAduitDate=0
    i (""=DateEnd)     s DateEnd=+$h 
    
    ///按到达统计
    i (""'=DateBegin)  s AdmDate=DateBegin-1
    i (""=DateBegin)   s AdmDate=0
    i (""=DateEnd)     s DateEnd=+$h  
	f  s AdmDate=$O(^DHCPEIADM(0, "AdmDateTime", AdmDate)) Q:(""=AdmDate)||((0'=+DateEnd)&(AdmDate>DateEnd))  d
	.s AdmTime=0
	.f  s AdmTime=$O(^DHCPEIADM(0, "AdmDateTime", AdmDate, AdmTime)) Q:(""=AdmTime)  d
	..s IAdmRowId=0
	..f  s IAdmRowId=$O(^DHCPEIADM(0, "AdmDateTime", AdmDate, AdmTime, IAdmRowId))  Q:(""=IAdmRowId)  d
	...s Status=$P($g(^DHCPEIADM(IAdmRowId)),"^",8)
	...Q:'(("ARRIVED"=Status)||("COMPLETED"=Status))
	...s PAADM=$P($g(^DHCPEIADM(IAdmRowId)),"^",1)
	...Q:(""=PAADM)
	...s RLTDR=$o(^DHCPERLT(0,"ADM",PAADM,0))	;已到达没任何结果退出
	...q:RLTDR=""
	...s GADM=$P($g(^DHCPEIADM(IAdmRowId)),"^",2)
	...s PIADM=$p(^DHCPEIADM(IAdmRowId),"^",4)
	...s PIBI=$p(^DHCPEPreIADM(PIADM),"^",1)
	...s Reg=$p(^DHCPEPreIBI(PIBI),"^",1)
	...//用于具体人员信息
	...s OEORDRowId=0
	...f  s OEORDRowId=$O(^OEORD(0,"Adm",PAADM,OEORDRowId)) q:OEORDRowId=""  d
	....s OEORIChildsub=0
	....f  s OEORIChildsub=$O(^OEORD(OEORDRowId,"I",OEORIChildsub)) q:OEORIChildsub=""  d
	.....Q:(""=$O(^DHCPECRMO(0,"OEORI",(OEORDRowId_"||"_OEORIChildsub),0))) //过滤非体检项目
	.....// 过滤非医嘱站点
	.....s OtherSTRowId=$O(^DHCPEST(0,"STORD_ARCIM",(OEORDRowId_"||"_OEORIChildsub),0))
	.....s OEORIStat=$p(^OEORD($p(OEORDRowId,"||",1),"I",OEORIChildsub,1),"^",13)
	.....q:(OEORIStat=4)
	.....s ARCID=$p(^OEORD(OEORDRowId,"I",OEORIChildsub,1),"^",2)
	.....q:(ARCID="")
	.....s RecDepDR=$p(^OEORD(OEORDRowId,"I",OEORIChildsub,3),"^",6)
	.....s STDR=$o(^DHCPEST(0,"STORD_ARCIM",ARCID,0))
	.....q:(STDR=7)
	.....s STDR=RecDepDR
	.....q:(STDR="")
	.....//q:(STIDS'[("^"_STDR_"^"))
	.....s crmodr=$O(^DHCPECRMO(0,"OEORI",OEORDRowId_"||"_OEORIChildsub,0))
	.....q:(crmodr="")
	.....s PIOIDR=$P($G(^DHCPECRMO(crmodr)),"^",2)
	.....s:(GADM'="") FactAmount=1 //##class(web.DHCDocOrderEntry).GetOrderPrice("","",ARCID,AdmDate,"","","","")
	.....s:(GADM="") FactAmount=+##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(PIOIDR,"","")
 	.....s ^DHCPETMPSTA("NewStatistic","allNum",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","allNum",STDR,ARCID))+1
 	.....s ^DHCPETMPSTA("NewStatistic","allAmount",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","allAmount",STDR,ARCID))+FactAmount
 	.....s:(GADM'="") ^DHCPETMPSTA("NewStatistic","GNum",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","GNum",STDR,ARCID))+1
 	.....s:(GADM'="") ^DHCPETMPSTA("NewStatistic","GAmount",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","GAmount",STDR,ARCID))+FactAmount
 	.....s:(GADM="") ^DHCPETMPSTA("NewStatistic","INum",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","INum",STDR,ARCID))+1
 	.....s:(GADM="") ^DHCPETMPSTA("NewStatistic","IAmount",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","IAmount",STDR,ARCID))+FactAmount
 	
    ///检验的按照状态记录检索
    i (""'=DateBegin)  s AdmDate=DateBegin-1
    i (""=DateBegin)   s AdmDate=0
    i (""=DateEnd)     s DateEnd=+$h  
    f  s AdmDate=$o(^OEORDi(0,"StatDate",AdmDate)) q:(AdmDate="")||(AdmDate>DateEnd)  d
    .s Ord=0
    .f  s Ord=$o(^OEORDi(0,"StatDate",AdmDate,Ord)) q:(Ord="")  d
    ..s PAADM=$p($g(^OEORD(Ord)),"^",1)
    ..q:(PAADM="")
    ..s IADM=($o(^DHCPEIADM(0,"PAADM",PAADM,0)))
    ..q:(IADM="")
    ..s GADM=$P($g(^DHCPEIADM(IADM)),"^",2)
    ..s ori=0
    ..f  s ori=$o(^OEORDi(0,"StatDate",AdmDate,Ord,ori)) q:(ori="")  d
    ...s ARCID=$p(^OEORD(Ord,"I",ori,1),"^",2)
    ...s STDR=$o(^DHCPEST(0,"STORD_ARCIM",ARCID,0))
	...q:(STDR'=7)
    ...s OEORIStat=$p(^OEORD(Ord,"I",ori,1),"^",13)
	...q:(OEORIStat'=6)
	...s ssub=$o(^OEORDi(0,"StatDate",AdmDate,Ord,ori,""),-1)
	...q:(ssub="")
	...s curstat=$p(^OEORD(Ord,"I",ori,"ST",ssub),"^",3)
	...q:(curstat'=6)
    ...s RecDepDR=$p(^OEORD(Ord,"I",ori,3),"^",6)
    ...s STDR=RecDepDR
    ...;s STDR="R"_RecDepDR
    ...s crmodr=$O(^DHCPECRMO(0,"OEORI",Ord_"||"_ori,0))
	...q:(crmodr="")
	...s PIOIDR=$P($G(^DHCPECRMO(crmodr)),"^",2)
	...s:(GADM'="") FactAmount=1 //##class(web.DHCDocOrderEntry).GetOrderPrice("","",ARCID,AdmDate,"","","","")
	...s:(GADM="") FactAmount=+##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(PIOIDR,"","")
    ...s ^DHCPETMPSTA("NewStatistic","allNum",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","allNum",STDR,ARCID))+1
 	...s ^DHCPETMPSTA("NewStatistic","allAmount",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","allAmount",STDR,ARCID))+FactAmount
 	...s:(GADM'="") ^DHCPETMPSTA("NewStatistic","GNum",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","GNum",STDR,ARCID))+1
 	...s:(GADM'="") ^DHCPETMPSTA("NewStatistic","GAmount",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","GAmount",STDR,ARCID))+FactAmount
 	...s:(GADM="") ^DHCPETMPSTA("NewStatistic","INum",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","INum",STDR,ARCID))+1
 	...s:(GADM="") ^DHCPETMPSTA("NewStatistic","IAmount",STDR,ARCID)=$g(^DHCPETMPSTA("NewStatistic","IAmount",STDR,ARCID))+FactAmount
    
     
    
 	 	
 	s STDR=0
 	f  s STDR=$o(^DHCPETMPSTA("NewStatistic","allNum",STDR)) q:(STDR="")  d
 	.;s:($l(STDR,"R")>1) STDesc=$p($P($G(^CTLOC($p(STDR,"R",2))),"^",2),"-",2)
 	.;s:($l(STDR,"R")=1) STDesc=$p(^DHCPEST(STDR),"^",2)
 	.s STDesc=$P($G(^CTLOC(STDR)),"^",2)
 	.s ARCID=0
 	.f  s ARCID=$o(^DHCPETMPSTA("NewStatistic","allNum",STDR,ARCID)) q:(ARCID="")  d
 	..s ARCDesc=$p(^ARCIM(+ARCID,1,1),"^",2)
 	..//DateBegin
 	..s CurGAmt=##class(web.DHCDocOrderEntry).GetOrderPrice("","",ARCID,DateBegin,"","","","")
 	..s INum=+$g(^DHCPETMPSTA("NewStatistic","INum",STDR,ARCID))
 	..s IAmount=+$G(^DHCPETMPSTA("NewStatistic","IAmount",STDR,ARCID))
 	..s GNum=+$G(^DHCPETMPSTA("NewStatistic","GNum",STDR,ARCID))
 	..s GAmount=CurGAmt*GNum  //+$G(^DHCPETMPSTA("NewStatistic","GAmount",STDR,ARCID))
 	..s AllNum=+$G(^DHCPETMPSTA("NewStatistic","allNum",STDR,ARCID))
 	..s AllAmount=IAmount+GAmount  //+$G(^DHCPETMPSTA("NewStatistic","allAmount",STDR,ARCID))
 	..s Data=$LB(STDesc, ARCDesc, INum, IAmount, GNum,GAmount,AllNum,AllAmount)
 	..d StationWorkStatisticOutNew2

	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
	
StationWorkStatisticOutNew2
 	Set ^CacheTemp(repid,ind)=Data
    Set ind=ind+1
 	q
}

ClassMethod StationWorkStatisticNewFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = StationWorkStatisticNewExecute ]
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

ClassMethod StationWorkStatisticNewClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = StationWorkStatisticNewExecute ]
{
    Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

}
