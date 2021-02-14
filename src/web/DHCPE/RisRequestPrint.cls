Class web.DHCPE.RisRequestPrint Extends %Library.RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

//得到检查申请单信息

//w ##class(web.DHCPE.RisRequestPrint).GetRisRequestInfo(5522,"")

ClassMethod GetRisRequestInfo(PADM, CRMOrder, Type As %String = "PreIADM")
{
	q:PADM="" ""
	if (Type="IADM") d
	.s PADM=$P(^DHCPEIADM(PADM),"^",4)
	.q:CRMOrder=""
	.s CRMOrder=$O(^DHCPECRMO(0,"OEORI",CRMOrder,0))
	.s CRMOrder=$P(^DHCPECRMO(CRMOrder),"^",2)
	if (Type="PAADM") d
	.s PADM=$O(^DHCPEIADM(0,"PAADM",PADM,0))
	.s PADM=$P(^DHCPEIADM(PADM),"^",4)
	.q:CRMOrder=""
	.s CRMOrder=$O(^DHCPECRMO(0,"OEORI",CRMOrder,0))
	.s CRMOrder=$P(^DHCPECRMO(CRMOrder),"^",2)
	s gID=$P(^DHCPEPreIADM(PADM),"^",2)
	s OrderStr=""
	i CRMOrder'="" d
	.s stat=$P(^DHCPEPreIADM(+CRMOrder,"ORDITEM",$P(CRMOrder,"||",2)),"^",16)
	.q:stat'="1"
	.s arcimID=$P(^DHCPEPreIADM(+CRMOrder,"ORDITEM",$P(CRMOrder,"||",2)),"^",1)
	.q:(gID'="")&&($G(^DHCPEDataEx("DHCPEStationOrder","GroupPrint",arcimID))'="1")
	.s tempName=$G(^DHCPEDataEx("DHCPEStationOrder","TempName",arcimID))
	.q:tempName=""
	.s recLoc=$P(^DHCPEPreIADM(+CRMOrder,"ORDITEM",$P(CRMOrder,"||",2)),"^",17)
	.i recLoc'="" s recLoc=$P(^CTLOC(recLoc),"^",2)
	.i $L(recLoc,"-")>1 s recLoc=$P(recLoc,"-",2)
	.s arcimDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(arcimID)
	.s docName=$P(^DHCPEPreIADM(+CRMOrder,"ORDITEM",$P(CRMOrder,"||",2)),"^",11)
	.i docName'="" s docName=$P(^SSU("SSUSR",docName),"^",2)
	.s price=##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(CRMOrder,"","")
	.s OrderStr=tempName_"^"_arcimDesc_"(总"_price_"元)"_"^"_recLoc_"^"_arcimDesc_"(总"_price_"元)"_"^"_docName
	e  d
	.k ^TempDHCPERisRequest(PADM)
	.s sub="" 
	.f  s sub=$O(^DHCPEPreIADM(PADM,"ORDITEM",sub)) q:sub=""  d
	..s stat=$P(^DHCPEPreIADM(PADM,"ORDITEM",sub),"^",16)
	..q:stat'="1"
	..s arcimID=$P(^DHCPEPreIADM(PADM,"ORDITEM",sub),"^",1)
	..q:(gID'="")&&($G(^DHCPEDataEx("DHCPEStationOrder","GroupPrint",arcimID))'="1")
	..s tempName=$G(^DHCPEDataEx("DHCPEStationOrder","TempName",arcimID))
	..q:tempName=""
	..s PrintType=+$G(^DHCPEDataEx("DHCPEStationOrder","RequestPrintType",arcimID))
	..s recLoc=$P(^DHCPEPreIADM(PADM,"ORDITEM",sub),"^",17)
	..i recLoc'="" s recLoc=$P(^CTLOC(recLoc),"^",2)
	..i $L(recLoc,"-")>1 s recLoc=$P(recLoc,"-",2)
	..s arcimDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(arcimID)
	..s docName=$P(^DHCPEPreIADM(PADM,"ORDITEM",sub),"^",11)
	..i docName'="" s docName=$P(^SSU("SSUSR",docName),"^",2)
	..s price=##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(PADM_"||"_sub,"","")
	..s ^TempDHCPERisRequest(PADM,recLoc,tempName,PrintType,arcimID)=tempName_"^"_arcimDesc_"(总"_price_"元)"_"^^^^"_"^"_recLoc_"^"_arcimDesc_"(总"_price_"元)"_"^"_docName_"^"_price_"元"
	.s recLoc=0
	.f  s recLoc=$O(^TempDHCPERisRequest(PADM,recLoc)) q:recLoc=""  d
	..s tempName=""
	..f  s tempName=$O(^TempDHCPERisRequest(PADM,recLoc,tempName)) q:tempName=""  d
	...s PrintType=""
	...f  s PrintType=$O(^TempDHCPERisRequest(PADM,recLoc,tempName,PrintType)) q:PrintType=""  d
	....s oneOrder=""
	....s i=3
	....s arcimID=""
	....f  s arcimID=$O(^TempDHCPERisRequest(PADM,recLoc,tempName,PrintType,arcimID)) q:arcimID=""  d
	.....s OneInfo=$G(^TempDHCPERisRequest(PADM,recLoc,tempName,PrintType,arcimID))
	.....i PrintType=0 d  //不合并打印
	......i OrderStr="" d
	.......s OrderStr=OneInfo
	......e  d
	.......s OrderStr=OrderStr_$C(2)_OneInfo
	.....e  d //合并打印
	......i oneOrder="" d
	.......s oneOrder=OneInfo
	......e  d
	.......s $P(oneOrder,"^",i)=$P(OneInfo,"^",2)
	.......s i=i+1
	....i PrintType=1 d
	.....i OrderStr="" d
	......s OrderStr=oneOrder
	.....e  d
	......s OrderStr=OrderStr_$C(2)_oneOrder
	q:OrderStr="" ""
	s patientInfo=..GetPatientInfo(PADM)
	
	s patientParInfo="RegNo"_"^"_"CardNo"_"^"_"Name"_"^"_"Sex"_"^"_"Age"_"^"_"InLoc"_"^"_"patType"_"^"_"address"_"^"_"TelNo"_"^"_"AppDate"_"^"_"HopeDate"_"^"_"Code"_"^"_"Married"_"^"_"Componey"_"^"_"Vocation"_"^"_"Nation"_"^"_"PEFlag"
	s ParInfo=patientParInfo_"^"_"purpose"_"^PEArcDesc2^PEArcDesc3^PEArcDesc4^PEArcDesc5"_"^"_"RecLoc"_"^"_"ordNameAndPrice"_"^"_"AppDoc"_"^"_"PEPrice"
	
	s rStr=ParInfo_$C(1)_patientInfo_$C(1)_OrderStr
	q rStr
}

//w ##class(web.DHCPE.RisRequestPrint).GetPatientInfo(29)

ClassMethod GetPatientInfo(PADM)
{
	s ibaseInfoID=$P(^DHCPEPreIADM(PADM),"^",1)
	q:ibaseInfoID="" ""
	s RegNo=$P(^DHCPEPreIBI(ibaseInfoID),"^",1)
	s CardNo=##class(web.DHCPE.PreIBIUpdate).GetRelate(RegNo,"R")
	s Name=$P(^DHCPEPreIBI(ibaseInfoID),"^",2)
	s Sex=$P(^DHCPEPreIBI(ibaseInfoID),"^",3)
	i Sex'="" s Sex=$p($g(^CT("SEX",Sex)),"^",2)
	s Age=$P(^DHCPEPreIBI(ibaseInfoID),"^",4)
	i Age'="" s Age=##class(web.DHCLCNUREXCUTE).CalAge(Age,+$h)
	s Age=$P(Age,"Y",1)
	s InLoc=$P(^DHCPEPreIADM(PADM),"^",26)
	s InLoc=$P(^CTLOC(InLoc),"^",2)
	i $L(InLoc,"-")>1 s InLoc=$P(InLoc,"-",2)
	s patType="自费"
	s address=$P(^DHCPEPreIBI(ibaseInfoID),"^",14)
	s TelNo=$P(^DHCPEPreIBI(ibaseInfoID),"^",8)
	i TelNo="" s TelNo=$P(^DHCPEPreIBI(ibaseInfoID),"^",6)
	i TelNo="" s TelNo=$P(^DHCPEPreIBI(ibaseInfoID),"^",7)
	s AppDate=$ZD($H,3)
	s HopeDate=$ZD($H,3)
	s Code=$P(^DHCPEPreIBI(ibaseInfoID),"^",13)
	
	s Married=$P(^DHCPEPreIBI(ibaseInfoID),"^",17)
	i Married'="" s Married=$P($G(^CT("MAR",Married)),"^",2)
	s Componey=$P(^DHCPEPreIBI(ibaseInfoID),"^",12)
	s Vocation=$P(^DHCPEPreIBI(ibaseInfoID),"^",10)
	s Nation=$P(^DHCPEPreIBI(ibaseInfoID),"^",15)
	
	s info=RegNo_"^"_CardNo_"^"_Name_"^"_Sex_"^"_Age_"^"_InLoc_"^"_patType_"^"_address_"^"_TelNo_"^"_AppDate_"^"_HopeDate_"^"_Code_"^"_Married_"^"_Componey_"^"_Vocation_"^"_Nation_"^"_"体检"
	q info
}

ClassMethod PISPrintFlag(PAADM)
{
	;w ##class(web.DHCPE.RisRequestPrint).PISPrintFlag("274070")
	;0不打印  1打印
	s VIPLevel="2"
	s Flag=0
	s ARCIM="21130||1"
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	s PIADM=$P(^DHCPEIADM(IADM),"^",4)
	s Level=$P(^DHCPEPreIADM(PIADM),"^",18)
	//q:VIPLevel'=Level Flag
	s OEORD=$O(^OEORD(0,"Adm",PAADM,0))
	q:OEORD="" Flag
	;^OEORDi(0,"ARCIM",OEORD,ARCIM,STTDat,Sub)
	s STTDat=""
	f  s STTDat=$O(^OEORDi(0,"ARCIM",OEORD,ARCIM,STTDat)) q:(STTDat="")||(Flag=1)  d
	.s Sub=0
	.f  s Sub=$O(^OEORDi(0,"ARCIM",OEORD,ARCIM,STTDat,Sub)) q:(Sub="")||(Flag=1)  d
	..s Stat=$p($G(^OEORD(OEORD,"I",Sub,1)),"^",13)
	..q:Stat'=1
	..s Flag=1
	;s ^sxt("fff")=Flag
	q Flag
}

}
