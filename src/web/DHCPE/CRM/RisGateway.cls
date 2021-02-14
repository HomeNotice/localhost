Class web.DHCPE.CRM.RisGateway Extends %Persistent
{

// w ##class(web.DHCPE.CRM.RisGateway).GetRequestOEORIStrByOrd("321||5")

ClassMethod GetRequestOEORIStrByOrd(ID)
{
	q:'$D(^OEORD(+ID,"I",$p(ID,"||",2),1)) ""
	s LocID=$p($G(^OEORD(+ID,"I",$p(ID,"||",2),1)),"^",3)
	q:LocID="" ""
	s OEOrderID=+ID,IADMStatus=""
    s PAADM=$p(^OEORD(OEOrderID),"^",1)
    s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
    s Status=$p(^DHCPEIADM(IADM),"^",8)
    Q:Status'="ARRIVED" ""
    //不是到达退出
	q:$D(^DHCPEDataEx("SendRisRequest",ID)) ""
	s PayFlag=$p(^OEORD(+ID,"I",$p(ID,"||",2),3),"^",5)
	q:PayFlag'="P" ""
	s ExFlag=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",13)
	q:ExFlag'="1" ""
	s SendOrderFlag=$G(^DHCPESetting("DHCPE","SendOrder",LocID))
	q:SendOrderFlag'="Y" ""
	s arcid=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",2)
	s ServMaterial=$P(^ARCIM(+arcid,$P(arcid,"||",2),7),"^",6)
    q:ServMaterial'="S"
	s STID=$o(^DHCPEST(0,"STORD_ARCIM",arcid,0))
	s RisStation=$g(^DHCPESetting("DHCPE","StationId_Ris"))
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	q:("^"_LabStation_"^"_RisStation_"^27^4^")'[("^"_STID_"^") ""
	s ^DHCPEDataEx("SendRisRequest",ID)=$H
	q ID
}

ClassMethod GetDropOEORIStrByOrd(ID)
{
  
	q:'$D(^DHCPEDataEx("SendRisRequest",ID)) ""
	s ExFlag=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",13)
	q:ExFlag'="1" ""
	k ^DHCPEDataEx("SendRisRequest",ID)
	q ID
}

/// 发送登记消息
/// d ##class(web.DHCPE.CRM.RisGateway).SendRequestInfo("4087711||40")
ClassMethod SendRequestInfo(OEORIStrs)
{
	s ret=""
	;b ;OEORIStrs
	s:$d(%session) LocID=%session.Get("LOGON.CTLOCID")
	s SendOrderFlag=$G(^DHCPESetting("DHCPE","SendOrder",LocID)) 
	//q:SendOrderFlag'="Y" ""
	q:SendOrderFlag'="Y" "-1^不是第三方,不发送申请消息"
	s ret=##class(DHCENS.BILL.BS.WebBILLService).OPChargeSend(OEORIStrs)
	q ret
	;d ##class(web.DHCBL.CI.ServiceBuilder).OPOEORIService("OPChageADT",OEORIStrs)
	;d ##class(web.DHCBL.CI.ServiceBuilder).OPOEORIService("OPCharge",OEORIStrs)
}

/// 发送取消消息
/// d ##class(web.DHCPE.CRM.RisGateway).SendDropInfo("3964049||44")
ClassMethod SendDropInfo(OEORIStrs)
{
   
	s:$d(%session) LocID=%session.Get("LOGON.CTLOCID")
	s SendOrderFlag=$G(^DHCPESetting("DHCPE","SendOrder",LocID)) 
	q:SendOrderFlag'="Y" "-1^不是第三方,不发送撤销申请消息"
	q ##class(DHCENS.BILL.BS.WebBILLService).OPRefundChargeSend(OEORIStrs)
	;d ##class(web.DHCBL.CI.ServiceBuilder).OPOEORIService("OPCRefund",OEORIStrs)
}

// d ##class(web.DHCPE.CRM.RisGateway).SendInfo("R",ID)

// d ##class(web.DHCPE.CRM.RisGateway).SendInfo("D",ID)

// InfoType:R  申请

//         D  取消

// ID      :  OE_ORDItem

/*
ClassMethod SendInfo(InfoType, ID)
{
 	s ret=""
	i InfoType="R" d
	.s Strs=..GetRequestOEORIStrByOrd(ID)
	.q:Strs=""
	.s ret=..SendRequestInfo(Strs)
	e  d
	.s Strs=..GetDropOEORIStrByOrd(ID)
	.q:Strs=""
	.s ret=..SendDropInfo(Strs)
	q ret
}
*/
ClassMethod SendInfo(InfoType, ID)
{
 	s ret=""
	i InfoType="R" d
	.s arcid=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",2)
	.s STID=$o(^DHCPEST(0,"STORD_ARCIM",arcid,0))
	.s STDesc=""
	.i STID'="" s STDesc=$P($G(^DHCPEST(STID)),"^",2)
	.i STDesc["病理" d
	..i ($g(^DHCPESetting("DHCPE","SendPisApplication"))="Y")&&($g(^DHCPESetting("DHCPE","SendPisFBWay"))="B")&&($g(^DHCPESetting("DHCPE","SendPisInterface"))'="Y") d
	...d ..SendPisApplicationOld(ID)
	.e  d
	..s Strs=..GetRequestOEORIStrByOrd(ID)
	..q:Strs=""
	..s ret=..SendRequestInfo(Strs)
	e  d
	.s arcid=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",2)
	.s STID=$o(^DHCPEST(0,"STORD_ARCIM",arcid,0))
	.s STDesc=""
	.i STID'="" s STDesc=$P($G(^DHCPEST(STID)),"^",2)
	.i STDesc["病理" d
	..i ($g(^DHCPESetting("DHCPE","SendPisApplication"))="Y")&&($g(^DHCPESetting("DHCPE","SendPisInterface"))="Y") d
	...d ##Class(web.DHCEMInterface).revPisNo(ID,%session.Get("LOGON.USERID"))
    .e  d
	..s Strs=..GetDropOEORIStrByOrd(ID)
	..q:Strs=""
	..s ret=..SendDropInfo(Strs)
	q ret
}

ClassMethod GetPISPAADMOld(PAADM)
{
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" ""
	s oeord=$O(^OEORD(0,"Adm",PAADM,0))
	q:oeord="" ""
	s ordInfo=""
	s Ord=$O(^OEORD(0,"Adm",PAADM,0))
	q:Ord="" ""
	s OrdItemID=""
	s Sub=0
	f  s Sub=$O(^OEORD(Ord,"I",Sub)) q:Sub=""  d
	.s OrdItemID=Ord_"||"_Sub
	.s markid=$p($G(^OEORD(Ord,"I",Sub,1)),"^",2)
	.q:markid=""
	.s ordtype=$p($G(^OEORD(Ord,"I",Sub,1)),"^",13)
	.q:ordtype'="1"
	.s stationid="",STDesc=""
	.s stationid=$o(^DHCPEST(0,"STORD_ARCIM",markid,0)) 
	.i stationid'="" s STDesc=$P($G(^DHCPEST(stationid)),"^",2)
	.q:STDesc'["病理" 
	.s ^DHCPEYDPIS(PAADM)=OrdItemID
	.q:$d(^DHCPEMarkPisTemp("mark",OrdItemID,PAADM))
	.s ARCIMID=$p(markid,"||",1)
	.s ARCIMDesc=$p(^ARCIM(+ARCIMID,1,1),"^",2)
	.i ARCIMDesc="脱落细胞学检查与诊断" d
    ..zn "PIS"
    ..;d ##class(Src.PIS3Interface).TJBatchSendApp(OrdItemID,PAADM,"20","宫颈涂片")
    ..zn "DHC-APP"
	.e  d
	..zn "PIS"
    ..d ##class(Src.PIS3Interface).TJBatchSendApp(OrdItemID,PAADM,"23","液基细胞")
    ..zn "DHC-APP"
    .s ^DHCPEMarkPisTemp("mark",OrdItemID,PAADM)=PAADM
    q "ok"
}

ClassMethod GetPISPAADM(PAADM)
{
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" ""
	s Status=$p(^DHCPEIADM(IADM),"^",8)
    q:$g(^DHCPESetting("DHCPE","SendPisApplication"))'="Y"
    q:$g(^DHCPESetting("DHCPE","SendPisFBWay"))'="B"
   	s Ord=$O(^OEORD(0,"Adm",PAADM,0))
	q:Ord="" ""
	s locid=$P($G(^PAADM(PAADM)),"^",4) //就诊科室ID
	s PreIADM=$P($g(^DHCPEIADM(IADM)),"^",4)
	s OrdItemID=""
	s Sub=0
	f  s Sub=$O(^OEORD(Ord,"I",Sub)) q:Sub=""  d
	.s OrdItemID=Ord_"||"_Sub
	.s arcid=$p(^OEORD(+OrdItemID,"I",$p(OrdItemID,"||",2),1),"^",2)
	.s STID=$o(^DHCPEST(0,"STORD_ARCIM",arcid,0))
	.s STDesc=""
	.i STID'="" s STDesc=$P($G(^DHCPEST(STID)),"^",2)
	.q:STDesc'["病理" 
	.d ..SendPisApplication(OrdItemID)
}

ClassMethod SendPisApplication(ID)
{
	q:'$D(^OEORD(+ID,"I",$p(ID,"||",2),1)) ""
	s OEOrderID=+ID
    s PAADM=$p(^OEORD(OEOrderID),"^",1)
    s locid=$P($G(^PAADM(PAADM)),"^",4) //就诊科室ID
    s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" ""
	s Status=$p(^DHCPEIADM(IADM),"^",8)
	s markid=$p($G(^OEORD(+ID,"I",$p(ID,"||",2),1)),"^",2)
	q:markid="" ""
	s PayFlag=$p(^OEORD(+ID,"I",$p(ID,"||",2),3),"^",5)
	s ExFlag=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",13)
	q:ExFlag'="1" ""
	S CRMORowId=$O(^DHCPECRMO(0,"OEORI",ID,""))
	Q:CRMORowId="" ""
	S PreIOrdItem=$p($g(^DHCPECRMO(CRMORowId)),"^",2)
	s DocUserID=$p($g(^DHCPEPreIADM(+PreIOrdItem,"ORDITEM",$p(PreIOrdItem,"||",2))),"^",11) //申请医生ID
	If $g(DocUserID)'="" d
	.Set doctor=$p(^SSU("SSUSR",DocUserID),"^",14)
	.i doctor'="" d
	..s CarPrvTpDR=$p($g(^CTPCP(doctor,1)),"^",4)
	..i CarPrvTpDR'="" s CTCPTType=$p($g(^CT("CPT",CarPrvTpDR)),"^",4)
	..i CTCPTType="DOCTOR" S doctor=doctor
	..E  S doctor=$G(^DHCPESetting("DHCPE","PhyExamDrId",locid))
	i doctor="" s doctor=$G(^DHCPESetting("DHCPE","PhyExamDrId",locid))
	s DocUserID=$o(^SSU("SSUSR",0,"CTPCP",doctor,""))

	S RecLocID=$p($G(^OEORD(+ID,"I",$p(ID,"||",2),3)),"^",6) //接收科室ID
	q:RecLocID="" ""
	Q:$d(^DHCPEMarkPisTemp("mark",ID,PAADM))
	s ARCIMID=$p(markid,"||",1)
	s ARCIMDesc=$p(^ARCIM(+ARCIMID,1,1),"^",2)
	s PISTypeDesc="",PISTypeID="",arNo=""
	s PISTypeID=$g(^DHCPEDataEx("DHCPEStationOrder","PISCodeType",markid))
    i PISTypeID'="" d
    .s PISTypeDesc=$P($G(^DHCAPPTS(PISTypeID)),"^",2)
    .s arNo="1"
	 s flag=""
	/// InPut:mListData - 医嘱项ID^接收科室ID^就诊ID^申请医生ID^申请科室ID^加急标志^冰冻标志^人乳头病毒发现日期^临床病历^临床诊断^^^申请类型^医嘱ID
    ///                    &标本序号^标本标识^标本名字^标本部位^标本数量^拨片/蜡片^原病历号^备注
    s mListData=markid_"^"_RecLocID_"^"_PAADM_"^"_DocUserID_"^"_locid_"^"_""_"^"_""_"^"_""_"^"_""_"^"_""_"^"_""_"^"_""_"^"_""_"^"_ID_"&"_arNo_"^"_PISTypeID_"^"_PISTypeDesc_"^"_""_"^1"_"^"_""_"^"_""_"^"_""
    s flag=##Class(web.DHCAPPPisInterface).InsPisMas(mListData)
    s ^DHCPEMarkPisTemp("mark",ID,PAADM)=flag
    q "OK"
}

ClassMethod SendPisApplicationOld(ID)
{
	q:'$D(^OEORD(+ID,"I",$p(ID,"||",2),1)) ""
	s OEOrderID=+ID
    s PAADM=$p(^OEORD(OEOrderID),"^",1)
    s locid=$P($G(^PAADM(PAADM)),"^",4) //就诊科室ID
    s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" ""
	s Status=$p(^DHCPEIADM(IADM),"^",8)
	s markid=$p($G(^OEORD(+ID,"I",$p(ID,"||",2),1)),"^",2)
	q:markid="" ""
	s PayFlag=$p(^OEORD(+ID,"I",$p(ID,"||",2),3),"^",5)
	q:PayFlag'="P" ""
	s ExFlag=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",13)
	q:ExFlag'="1" ""
	S CRMORowId=$O(^DHCPECRMO(0,"OEORI",ID,""))
	Q:CRMORowId="" ""
	S PreIOrdItem=$p($g(^DHCPECRMO(CRMORowId)),"^",2)
	s DocUserID=$p($g(^DHCPEPreIADM(+PreIOrdItem,"ORDITEM",$p(PreIOrdItem,"||",2))),"^",11) //申请医生ID
	S RecLocID=$p($G(^OEORD(+ID,"I",$p(ID,"||",2),3)),"^",6) //接收科室ID
	q:RecLocID="" ""
	Q:$d(^DHCPEMarkPisTemp("mark",ID,PAADM))
	s ARCIMID=$p(markid,"||",1)
	s ARCIMDesc=$p(^ARCIM(+ARCIMID,1,1),"^",2) 
	i ARCIMDesc="脱落细胞学检查与诊断" d
    .zn "PIS"
    .;d ##class(Src.PIS3Interface).TJBatchSendApp(OrdItemID,PAADM,"20","宫颈涂片")
    .zn "DHC-APP"
	e  d
	.zn "PIS"
    .d ##class(Src.PIS3Interface).TJBatchSendApp(OrdItemID,PAADM,"23","液基细胞")
    .zn "DHC-APP"
    s ^DHCPEMarkPisTemp("mark",ID,PAADM)=PAADM
    q "OK"
}

// s val=##class(web.DHCPE.CRM.RisGateway).GetPAADM(7271458, "ARRIVED")

ClassMethod GetPAADM(PAADM, IADMStatus)
{
   	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" ""
    s Status=$p(^DHCPEIADM(IADM),"^",8)
    Q:Status'="ARRIVED" "" 
	;d ##class(web.DHCPE.CRM.Gateway).GetPatientInfoForHH(PAADM)
	s oeord=$O(^OEORD(0,"Adm",PAADM,0))
	q:oeord="" ""
	s ordInfo=""
	;"医嘱RowId^医嘱RowId@发票ID"
	;w ##class(DHCENS.BILL.BS.WebBILLService).OPChargeSend("8733||3")
	s Ord=$O(^OEORD(0,"Adm",PAADM,0))
	q:Ord="" ""
	
	i ($g(^DHCPESetting("DHCPE","SendPisApplication"))="Y")&&($g(^DHCPESetting("DHCPE","SendPisFBWay"))="B")&&($g(^DHCPESetting("DHCPE","SendPisInterface"))'="Y") d
	.d ..GetPISPAADMOld(PAADM) //发送病理申请

	s Sub=0
	f  s Sub=$O(^OEORD(Ord,"I",Sub)) q:Sub=""  d
	.s OrdItemID=Ord_"||"_Sub
	.s OrdItemID=..GetRequestOEORIStrByOrd(OrdItemID)
	.q:OrdItemID=""
	.i ordInfo="" d
	..s ordInfo=OrdItemID
	.e  d
	..s ordInfo=ordInfo_"^"_OrdItemID
	;b ;ordInfo
	q:ordInfo="" ""
	s ret=..SendRequestInfo(ordInfo)
	q ret
}

// 单独发送放射消息 第一个参数为病人的就诊记录PAADM  EpisodeID

// d ##class(web.DHCPE.CRM.RisGateway).ReSendInfo(12386, "ARRIVED")

ClassMethod ReSendInfo(PAADM As %String, IADMStatus As %String = "ARRIVED")
{
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" ""
    s Status=$p(^DHCPEIADM(IADM),"^",8)
    Q:Status'="ARRIVED" "" 
	s pmi=$P(^PAADM(PAADM),"^",1)
	s XML="<Request><Patients><PaPatMas><ClassName>web.DHCService.CI.ZSYY.PACS</ClassName><Instruction>SendPACSRequest</Instruction><InterfaceType>ECGDITAN</InterfaceType><PAADMs><PaAdm><EpsodeId>***</EpsodeId><OrdItems><OrdItem><OrdId>***</OrdId></OrdItem></OrdItems></PaAdm></PAADMs><PMI>***</PMI></PaPatMas></Patients><Service>OPCharge</Service></Request>"
	s XML=##class(web.DHCPE.DHCPECommon).Replace(XML,"<EpsodeId>***</EpsodeId>","<EpsodeId>"_PAADM_"</EpsodeId>")
	s XML=##class(web.DHCPE.DHCPECommon).Replace(XML,"<PMI>***</PMI>","<PMI>"_pmi_"</PMI>")
	s oeord=$O(^OEORD(0,"Adm",PAADM,0))
	q:oeord="" ""
	s ordInfo=""
	s locStr=##class(web.DHCPE.CRM.RisGateway).GetXrayLoc(1)
	s locLength=$L(locStr,"^")
	f j=1:1:locLength d
	.s oeordsub=0
	.s loc=$P(locStr,"^",j)
	.f  s oeordsub=$O(^OEORDi(0,"RecDepOrd",oeord,loc,oeordsub)) q:oeordsub=""  d
	..s oeorditem=oeord_"||"_oeordsub
	..//q:$D(^DHCPEOrdItem("RisInfo",oeorditem)) //=$H
	..s stat=$p(^OEORD(oeord,"I",oeordsub,1),"^",13)
	..q:stat'="1"
	..//i ordInfo="" d
	..s ordInfo="<OrdItem><OrdId>"_oeorditem_"</OrdId></OrdItem>"
	..s ^DHCPEOrdItem("RisInfo",oeorditem)=$H
	..s OneXml=##class(web.DHCPE.DHCPECommon).Replace(XML,"<OrdItem><OrdId>***</OrdId></OrdItem>",ordInfo)
	..d ##class(web.DHCService.CI.ZSYY.PACS).DHCPESendPacsInfo(OneXml)
	q ""
}

// w ##class(web.DHCPE.CRM.RisGateway).GetXrayLoc(1)

ClassMethod GetXrayLoc(ParRef)
{
	s locInfo=""
	s childsub=0
	f  s childsub=$O(^User.DHCCITypeDefineD(ParRef,"OrdRule",childsub)) q:childsub=""  d
	.s id=ParRef_"||"_childsub
	.s obj=##class(User.DHCCITypeDefineOrderRule).%OpenId(id)
	.s activeFlag=obj.TORActiveFlag
	.q:activeFlag'="Y"
	.s startDate=obj.TORDateFrom
	.q:(startDate="")||(startDate>+$H)
	.s endDate=obj.TORDateTo
	.q:(endDate'="")&&(endDate<+$H)
	.s recLoc=obj.TORRecLocDR.%Id()
	.q:recLoc=""
	.i locInfo="" d
	..s locInfo=recLoc
	.e  d
	..s locInfo=locInfo_"^"_recLoc
	q locInfo
}

ClassMethod GetItemPrice(OEOrdItemID)
{
	;w ##class(web.DHCPE.CRM.RisGateway).GetItemPrice("286574||25")
	s $ZT="ItemPriceErr"
	q:OEOrdItemID="" ""
	s CRMOrderID=$O(^DHCPECRMO(0,"OEORI",OEOrdItemID,0))
	q:CRMOrderID="" ""
	s PEOrderID=$P(^DHCPECRMO(CRMOrderID),"^",2)
	q:PEOrderID="" ""
	s PreSetsID=$P(^DHCPEPreIADM(+PEOrderID,"ORDITEM",$P(PEOrderID,"||",2)),"^",2)
	s Price=""
	i PreSetsID=""  d
	.s Price=##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(PEOrderID,"","")
	e  d
	.s Price=$P(^DHCPEPreIADM(+PEOrderID,"ORDITEM",$P(PEOrderID,"||",2)),"^",14)
	q Price
	//q ##class(web.DHCPE.HandlerPreOrds).GetFactAmountByItem(PEOrderID,"","")
ItemPriceErr
	q ""
}

ClassMethod IsRISOrdItem(ID)
{
	s flag=0
	s RisStation=$g(^DHCPESetting("DHCPE","StationId_Ris"))
	Q:ID="" "0"
	s arcid=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",2)
	s STID=$o(^DHCPEST(0,"STORD_ARCIM",arcid,0))
	s STDesc=""
	i STID'="" s STDesc=$P($G(^DHCPEST(STID)),"^",2)
	Q:RisStation'[STID "0"
	Q:STDesc["病理" "0"
	i STDesc'["病理" d
	.s flag=1
	q flag
}

ClassMethod IsPISOrdItem(ID)
{
	s flag=0
	Q:ID="" "0"
	s arcid=$p(^OEORD(+ID,"I",$p(ID,"||",2),1),"^",2)
	s STID=$o(^DHCPEST(0,"STORD_ARCIM",arcid,0))
	s STDesc=""
	i STID'="" s STDesc=$P($G(^DHCPEST(STID)),"^",2)
	i STDesc["病理" d
	.s flag=1
	q flag
}

Storage Default
{
<Data name="RisGatewayDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.CRM.RisGatewayD</DataLocation>
<DefaultData>RisGatewayDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.CRM.RisGatewayD</IdLocation>
<IndexLocation>^web.DHCPE.CRM.RisGatewayI</IndexLocation>
<StreamLocation>^web.DHCPE.CRM.RisGatewayS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
