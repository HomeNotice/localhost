/// Modified by MLH 20060904
/// 自动接收检验结果
Class web.DHCPE.TransResult Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

Parameter BUILD = 1;

ClassMethod LabResultMainAll() As %String
{
	s admId=%request.Get("EpisodeID")

	s userId=%session.Get("LOGON.USERID")
	s OEORDRowId=0
	f  s OEORDRowId=$O(^OEORD(0,"Adm",admId,OEORDRowId)) q:OEORDRowId=""  d
	.s OEORIChildsub=0
	.f  s OEORIChildsub=$O(^OEORD(OEORDRowId,"I",OEORIChildsub)) Q:(""=OEORIChildsub)  d
	..s ordItmId=OEORDRowId_"||"_OEORIChildsub
	..s ret=##class(web.DHCPE.TransResult).TransALabItem(admId, userId,ordItmId)

	q ret
}

/// Description: main function, the preCondition is %request.Get("EpisodeID") is exists.
/// return: "":Correct;  Else:Error occured.
ClassMethod LabResultMain() As %String
{
	s admId=%request.Get("EpisodeID")
	s ordItmId=%request.Get("OEORIRowId")
	s userId=%session.Get("LOGON.USERID")
	s ret=##class(web.DHCPE.TransResult).TransALabItem(admId, userId,ordItmId)
	//d ##class(web.DHCPE.TransResult).TransExtendItem(admId,ordItmId,userId)
	q ret
}

ClassMethod TransExtendItem(admId As %String, ordItmId As %String, userId As %String)
{
	s arcItemId="",itemStatusDr=""
	s myCount=+$o(^DHCPERLT(0,"OEORI",ordItmId,0))
	q:myCount>0 
	q:##class(web.DHCPE.ResultPermission).GetReportStatus(admId)="Audited" 
	
	s itemStatusDr=$p(^OEORD($p(ordItmId,"||",1),"I",$p(ordItmId,"||",2),1),"^",13)
	q:itemStatusDr="4" "Error: orderItem's status is stopped."	//已停止
	s arcItemId=$p(^OEORD($p(ordItmId,"||",1),"I",$p(ordItmId,"||",2),1),"^",2)
	s ExtendFlag=$g(^DHCPEDataEx("DHCPEStationOrder","Extend",arcItemId)) 
	i ExtendFlag'="Y"
	{
		d ..InsertNormalResult(admId,ordItmId,userId)
	}
	q:ExtendFlag'="Y"
	s IADMID=$o(^DHCPEIADM(0,"PAADM",admId,0)) //DHC_PE_IADM
	s ICRMID=$p(^DHCPEIADM(IADMID),"^",4) //PIADM_RowId
	s PIBIID=$p(^DHCPEPreIADM(ICRMID),"^",1) //DHC_PE_PreIBaseInfo
	s PreAdmId=ICRMID
	s SQLCODE=0
	s Flag=1
	f  s PreAdmId=$o(^DHCPEPreIADM(0,"PIBI",PIBIID,PreAdmId),-1) q:(PreAdmId="")||(SQLCODE'=0)||(Flag=0)  d
	.s DHCPEIADM=$o(^DHCPEIADM(0,"CRMADM",PreAdmId,0)) //DHC_PE_IADM
	.q:DHCPEIADM="" 
	.s PAADM=$p(^DHCPEIADM(DHCPEIADM),"^",1) //PA_ADM
	.s OEORIDR=""
	.//&sql(select RLT_OEORI_DR into :OEORIDR from SQLUser.dhc_pe_result
	.// where rlt_adm_dr=:PAADM and RLT_ARCIM_DR=:arcItemId)
	.s OrderItemID=""
	.f  s OrderItemID=$O(^DHCPERLT(0,"ADMOD",PAADM,OrderItemID),-1) q:(OrderItemID="")||(OEORIDR'="")  d
	..s CurArcItemID=$p(^OEORD($p(OrderItemID,"||",1),"I",$p(OrderItemID,"||",2),1),"^",2)
	..s:CurArcItemID=arcItemId OEORIDR=OrderItemID
	.q:OEORIDR=""
	.s Flag=0
	.s ODID=0
	.f  s ODID=$o(^DHCPERLT(0,"ADMOD",PAADM,OEORIDR,ODID)) q:(ODID="")||(SQLCODE'=0)  d
	..s ResultID=$o(^DHCPERLT(0,"ADMOD",PAADM,OEORIDR,ODID,0)) //DHC_PE_Result
	..s ResultDesc=$p(^DHCPERLT(ResultID),"^",4)
	..s Normal=$p(^DHCPERLT(ResultID),"^",7)
	..s Advice=$p(^DHCPERLT(ResultID),"^",8)
	..s TemplateDesc=$p(^DHCPERLT(ResultID),"^",10)
	..s updateDt=+$h
	..&sql(insert into SQLUser.dhc_pe_result
	 (rlt_adm_dr, rlt_ARCIM_DR, rlt_OD_DR, rlt_user_dr,rlt_updateDate,rlt_OEORI_DR,RLT_Result,RLT_Normal,RLT_TemplateDesc,RLT_Advice)
	 values(:admId, :arcItemId, :ODID, :userId, :updateDt,:ordItmId,:ResultDesc,:Normal,:TemplateDesc,:Advice))
	..q:SQLCODE'=0
	q:SQLCODE'=0
	i Flag=1
	.d ..InsertNormalResult(admId,ordItmId,userId)
	q:Flag=1 SQLCODE
	&SQL(update sqluser.OE_ORDItem set OEORI_ItemStat_DR='6' where OEORI_RowID=:ordItmId)
	q
}

// w ##class(web.DHCPE.TransResult).trans("A0001",1)

ClassMethod LabResultLast(admId As %String) As %String
{
	Set userId=%session.Get("LOGON.USERID")
	Set ret=""
	Set orderRowId=0
	For  Set orderRowId=$O(^OEORD(0,"Adm",admId,orderRowId)) Quit:orderRowId=""  Do
	.Set ordItmChd=0
	.For  Set ordItmChd=$O(^OEORD(orderRowId,"I",ordItmChd)) Quit:ordItmChd=""  Do
	..Set LabNo=$P($G(^OEORD(orderRowId,"I",ordItmChd,3)),"^",20)
	..If $g(LabNo)'="" Do
	...Set ordItmId=orderRowId_"||"_ordItmChd
	...Set ret=##class(web.DHCPE.TransResult).TransALabItem(admId, userId,ordItmId)
	q ret
}

/// return: "":Correct;  Else:Error occured.
/// test: s ret=##class(web.DHCPE.TransResult).TransALabItem("4031448","3901","3960681||38")
ClassMethod TransALabItem(admId As %String, UserId As %String, ordItmId As %String)
{
	q ##class(web.DHCPE.TransResultEx).TransLabResultForXH(admId,UserId,ordItmId)
	s episodeNo="", itemStatusDr="", OEIId=""
	s labItemCode=""
	i admId="" s admId=$P(^OEORD(+ordItmId),"^",1)
	s namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	s CurSpace=$ZNSpace
	s OEIId=ordItmId
	//Q:($P(^OEORD(+ordItmId,"I",$p(ordItmId,"||",2),3),"^",35)) ""
	
	/*   
    &sql(SELECT  OEORI_LabEpisodeNo	, oeori_itemstat_dr, OEORI_ItmMast_DR
		 into :episodeNo,  :itemStatusDr, :arcItemId
		 FROM  SQLUser.OE_OrdItem
		 where oeori_RowId=:ordItmId and oeori_itemstat_dr<>4 )
	*/
	q:(OEIId="") "Error: No correct OEORDItem!"	//已停止
	
	s itemStatusDr=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),1),"^",13)
	q:itemStatusDr="4" "Error: orderItem's status is stopped."	//已停止
	s arcItemId=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),1),"^",2)
	s episodeNo=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),3),"^",20)
	
	q:($g(episodeNo)="") "Error: EpisodeNo is Null!"
	
	q:(##class(web.DHCPE.ResultPermission).GetReportStatus(admId)="Audited") "" //总检已经审核
	//是否是检验医嘱
	//q:(..CheckIsLabItem(OEIId)=0) "Error: the Item is not a labItem!"
	s TrakVerison=$g(^DHCPESetting("DHCPE","TrakVerison"))
	i TrakVerison="" s TrakVerison="TrakCare"
	//取检验外部代码
	s labItemCode=""
	s LabItemSetID=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),3),"^",35)
	q:LabItemSetID="" ""
	s labItemCode=$p(LabItemSetID,"||",2)
	q:labItemCode="" ""
	/*
	i TrakVerison="TrakCare" d
	.Quit:'$d(^ARCIM(+arcItemId,1,"EXT"))
	.Set Ext=$o(^ARCIM(+arcItemId,1,"EXT",0))
	.Quit:$g(Ext)=""
	.Set labItemCode=$p(^ARCIM(+arcItemId,1,"EXT",Ext),"^",4)
	*/
	
	
	/*
	i "MedTrak"=TrakVerison d
	.s arcos=$p(^OEORD(+ordItmId,"I",$p(ordItmId,"||",2),3),"^",10)
	.Quit:$g(arcos)=""
	.s labItemCode=$P($G(^ARCOS(arcos)), "^", 11)
   
	i ((TrakVerison="TrakCare")&&($g(arcItemId)'="")) Set labItemCode=##Class(web.DHCPE.TransResult).GetLabExtCode("TrakCare",arcItemId)
	q:((labItemCode="")||(episodeNo="")) "Error: the arcItem's Ext_code is null."
	*/
	//判断检验状态
	
	s labItemStatus=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",31)
	q:(labItemStatus'="A") "Error: the result is not send by labDepartment."	//A: Authorised, 已发送
	
	
	//取检验录入日期   2007-07-27
	//s UpdateDate=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",4)
	s AuditDate=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",4)
	s AuditTime=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",5)
	s AuditTime=AuditTime*60
	s IfTraned=$g(^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId))
	s TranedDate=+IfTraned
	s TranedTime=$p(IfTraned,",",2)
	Quit:(AuditDate<TranedDate) "Date"  //判断是否传输过
	Quit:((AuditDate=TranedDate)&(AuditTime<TranedTime)) "Time"
	s sex=$P($g(^TEPI(episodeNo)),"\",3)
    s age=$P($g(^TEPI(episodeNo)),"\",25)
	Set myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(admId)
	Set mySex=$p(myStr,"^",2)
	Set myAge=$p(myStr,"^",1)    
	//审核人 2008-06-04
	s AuditUser=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",6)
	/*
	i AuditUser'="" d
	.s AuditUser=$ZCVT(AuditUser,"U")
	.s AuditUser=$O(^[namespaceLab]SSU("SSUSR",0,"SSUSR_Initials",AuditUser,""))
	*/
	s ^DHCPEDataEx("Report","DHCPEIReport","LisAuditUser",ordItmId)=AuditUser
	
	s LisInterface=$g(^DHCPESetting("DHCPE","LisInterface"))
	i LisInterface="N"  d
	.s num=""
  	.f  s num=$o(^TTAB("TS",labItemCode,0,num))  q:num=""  d
  	..s LabItemDetailCode=$p($g(^TTAB("TS",labItemCode,0,num)),"\",8)
  	..d TransResult
  	else  d
	.s LabItemDetailCode=""
	.f  s LabItemDetailCode=$O(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode)) q:LabItemDetailCode=""  d
	..d TransResult
	Q ""
TransResult

	s IsNormal=1
	s Code=$$ALPHAUP^SSUTIL4(LabItemDetailCode)
	s ItemID=""
	q:Code=""
	s stationID=$O(^DHCPEST(0,"OD_Code",Code,0))
	i stationID="" d
	.s ItemID=##class(web.DHCPE.OrderDetail).ImpOneLabDetail(LabItemDetailCode)
	e  d
	.s sub=$O(^DHCPEST(0,"OD_Code",Code,stationID,0))
	.s ItemID=stationID_"||"_sub
	q:ItemID=""
	s labResult=$g(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode))
	s ResultSort=$p(labResult,"\",9)
	s:ResultSort="" ResultSort="999999999"
	S labResult=$p(labResult,"\",1)
	q:labResult=""
	s LabResultStr=""
	
	/*
	s LisInterface=$g(^DHCPESetting("DHCPE","LisInterface"))
	if LisInterface="N" d
	.If $g(labResult)'="" Do
	..s CurSpace=$ZNSpace
	..zn namespaceLab
	..;s LabResultStr=$$TestItmRes^CHDhcLabReport(episodeNo,LabItemDetailCode,labResult,AuditDate)
	
	..s LabResultStr=$$TestItmRes^DHCLtkReport(episodeNo,LabItemDetailCode,labResult,AuditDate,"")
	
	..//s retvalue=itmcode_$c(2)_itmname_$c(2)_synonym_$c(2)_$tr(itmres,$c(13,10),"")_$c(2)_itmunits
	..//s retvalue=retvalue_$c(2)_resflag_$c(2)_ranges_$c(2)_otherres_$c(2)_rangcolor_$c(2)_itmtype_$c(2)_resflag1
	..//代码_$c(2)_名称_$c(2)_英文缩写_$c(2)_结果_$c(2)_单位_$c(2)_异常标记（U警告标记P警告标记M荒诞值N正常H高L低A异常）_$c(2)_参考范围_$c(2)_其它结果_$c(2)_颜色
	..;s LabresultStr=##class(web.DHCLabTestCode).GetTestCodeResult(episodeNo,LabItemDetailCode,labResult,AuditDate)
	..zn CurSpace
    ..i LabResultStr'="" s labResult=$p(LabResultStr,$c(2),4)
	..s NormalStr=##class(web.DHCPE.ResultEdit).GetNormal(ItemID,mySex,myAge)
	..s Unit=$p(^DHCPEST(+ItemID,"OD",$p(ItemID,"||",2)),"^",4)
	else  d
	.s NormalStr=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Ranges"))
	.s Unit=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Unit"))
	s IsNormal=..LabIsNormal(NormalStr,LabItemDetailCode,labResult)
	*/
	s HLFlag=""
	s CurSpace=$ZNSpace
	zn namespaceLab
	s LabResultStr=$$TestItmRes^DHCLtkReport(episodeNo,LabItemDetailCode,labResult,AuditDate,"")
	i LabResultStr'="" d
	.s labResult=$p(LabResultStr,$c(2),4)
	.s NormalStr=$p(LabResultStr,$c(2),7)
	.s Unit=$p(LabResultStr,$c(2),5)
	.s IsNormal=$p(LabResultStr,$c(2),6)
	.s HLFlag=IsNormal
	.i IsNormal="N" d
	..s IsNormal="1"
	.e  d
	..s IsNormal="0"
	e  d
	.s NormalStr=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Ranges"))
	.s Unit=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Unit"))
	.s IsNormal=..LabIsNormal(NormalStr,LabItemDetailCode,labResult)
	
	//s CTTCTComm=$s(IsNormal=0:1,IsNormal=1:0)
	/*
	i LabResultStr'=""   d
	.s NormalFlag=$p(LabResultStr,$c(2),11)
	.i (NormalFlag="A")||(NormalFlag="P") s IsNormal="0"
	.else  s IsNormal="1"
	*/
	s UserId=$p($g(^TEPI(episodeNo,1,labItemCode,1)),"\",3)
	/*
	i (UserId'="")&&(LisInterface="Y") d
	.s UserId=$ZCVT(UserId,"U")
	.s UserId=$O(^SSU("SSUSR",0,"SSUSR_Initials",UserId,""))
	*/
	i UserId="" s UserId=AuditUser

	s PLIST(2)=admId
	s PLIST(3)=arcItemId
	s PLIST(4)=ItemID
	s PLIST(5)=labResult
	s PLIST(6)=UserId
	s PLIST(7)=AuditDate //+$h
	s PLIST(8)=IsNormal
	s PLIST(11)=OEIId
	s PLIST(13)=$p($h,",",2)
	s PLIST(16)=ResultSort
	b ;ResultSort
	s RLTID=$O(^DHCPERLT(0,"ADMOD",admId,OEIId,ItemID,0))
	i RLTID="" d
	.&SQL(Insert into sqluser.DHC_PE_Result values :PLIST())
	e  d
	.&SQL(update sqluser.DHC_PE_Result values :PLIST() where RLT_RowID=:RLTID)
	i SQLCODE=0  d
	.s RLTID=%ROWID
	.s ^DHCPEDataEx("DHCPEResult",RLTID,"Ranges")=NormalStr
	.s ^DHCPEDataEx("DHCPEResult",RLTID,"Unit")=Unit
	.s ^DHCPEDataEx("DHCPEResult",RLTID,"HLFlag")=HLFlag
	.s SQLCODE=##class(web.DHCPE.HighRisk).GetHighRiskFlag(RLTID) 
	s ^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId)=$h
	q 
	////Modified  Over
	
	///为了检验没有布局等信息修改
	s LabItemDetailCode=""
	f  s LabItemDetailCode=$O(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode)) q:LabItemDetailCode=""  d
	.s IsNormal=1
	.s Code=$ZCVT(LabItemDetailCode,"U")
	.s ItemID=""
	.s stationID=$O(^DHCPEST(0,"OD_Code",Code,0))
	.i stationID="" d
	..s ItemID=##class(web.DHCPE.OrderDetail).ImpOneLabDetail(LabItemDetailCode)
	.e  d
	..s sub=$O(^DHCPEST(0,"OD_Code",Code,stationID,0))
	..s ItemID=stationID_"||"_sub
	.q:ItemID=""
	.s labResult=$g(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode))
	.S labResult=$p(labResult,"\",1)
	.s labResult=$p(labResult,$C(13,10),1)
	.i labResult[("阴性") d
	..s labResult=$P(labResult,"@",1)
	.e  d
	..s labResult=##class(web.DHCPE.Public.Setting).Replace(labResult,"@"," ")
	.//s labResult=$p(..trans(LabItemDetailCode,labResult),$c(1),2)
	.s NormalStr=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Ranges"))
	.;b ;NormalStr,LabItemDetailCode,labResult
	.s IsNormal=..LabIsNormal(NormalStr,LabItemDetailCode,labResult)
	.//s CTTCTComm=$s(IsNormal=0:1,IsNormal=1:0)
	.s UserId=$p($g(^TEPI(episodeNo,1,labItemCode,1)),"\",3)
	.i UserId'="" d
	..s UserId=$ZCVT(UserId,"U")
	..s UserId=$O(^SSU("SSUSR",0,"SSUSR_Initials",UserId,""))
	
	.i UserId="" s UserId=AuditUser
	.// If $g(labResult)'="" Do
	.//.zn namespaceLab
	.//.s LabResultStr=$$TestItmRes^CHDhcLabReport(episodeNo,LabItemDetailCode,labResult,61062)
	.//.zn CurSpace
	.//. Set flag=$p(LabResultStr,$c(2),11)
	.//.If (flag'="")&(flag'="N") Set IsNormal="0"
	.s PLIST(2)=admId
	.s PLIST(3)=arcItemId
	.s PLIST(4)=ItemID
	.s PLIST(5)=labResult
	.s PLIST(6)=UserId
	.s PLIST(7)=AuditDate //+$h
	.s PLIST(8)=IsNormal
	.s PLIST(11)=OEIId
	.s PLIST(13)=$p($h,",",2)
	.s RLTID=$O(^DHCPERLT(0,"ADMOD",admId,OEIId,ItemID,0))
	.i RLTID="" d
	..&SQL(Insert into sqluser.DHC_PE_Result values :PLIST())
	.e  d
	..&SQL(update sqluser.DHC_PE_Result values :PLIST() where RLT_RowID=:RLTID)
	.i SQLCODE=0  d
	..s RLTID=%ROWID
	..s ^DHCPEDataEx("DHCPEResult",RLTID,"Ranges")=NormalStr
	..s ^DHCPEDataEx("DHCPEResult",RLTID,"Unit")=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Unit"))
	..s SQLCODE=##class(web.DHCPE.HighRisk).GetHighRiskFlag(RLTID)         //add
	s ^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId)=$h
	q ""
	////Modified  Over
}

/// description: 判断指定医嘱是否是一个检验医嘱
/// return: 0-not a labItem;  1-Is a LabItem
/// test: w ##class(web.DHCPE.TransResult).CheckIsLabItem("48885||6")
ClassMethod CheckIsLabItem(OEIId As %String)
{
	s episodeNo=""
	&sql(SELECT  OEORI_LabEpisodeNo
				into :episodeNo
		FROM  SQLUser.OE_OrdItem
		where oeori_RowId=:OEIId)
	
	q:(episodeNo="") 0
	q 1
}

/// Modified by MLH 11-07
/// description: 插入空的检验结果记录
/// return: "": correct 	else: Error infomation
/// test: w ##class(web.DHCPE.TransResult).InsertBlankLabItem("48885||6",1)
ClassMethod InsertBlankLabItem(OEIId, UserId, episodeNo, labItemCode)
{
	s admId="", arcItemId="", itemStatusDr=""
	/*&sql(SELECT  OEORI_OEORD_ParRef->OEORD_Adm_DR, oeori_itmMast_dr, oeori_itemstat_dr
		 			into  :admId, :arcItemId, :itemStatusDr
		 FROM  SQLUser.OE_OrdItem
		 where oeori_RowId=:OEIId)*/
	s itemStatusDr=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),1),"^",13)
	q:itemStatusDr="4" "Error: orderItem's status is stopped."	//已停止
	s admId=$p(^OEORD(+OEIId),"^",1)
	Set arcItemId=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),1),"^",2)
			
	s myCount=0
	
	Set updateDt=+$h
	Set ODRRowId=0
	For  Set ODRRowId=$O(^DHCPEODR(0,"ARCIM",arcItemId,ODRRowId)) q:(ODRRowId="")  d
	.s ODDR=$p(^DHCPEODR(ODRRowId),"^",2)
	.q:ODDR=""
	.Set RLTRowId=""
	.//&sql(select rlt_RowId into :RLTRowId from SQLUser.dhc_pe_result 
  	.// where rlt_adm_dr=:admId and  rlt_OEORI_DR=:OEIId and rlt_OD_DR=:ODDR)
  	.s RLTRowId=$o(^DHCPERLT(0,"ADMOD",admId,OEIId,ODDR,0))
  	.If RLTRowId="" Do
	..&sql(insert into SQLUser.dhc_pe_result
	 (rlt_adm_dr, rlt_ARCIM_DR, rlt_OD_DR, rlt_user_dr,rlt_updateDate, rlt_OEORI_DR)
	  values(:admId, :arcItemId, :ODDR, :UserId, :updateDt,:OEIId))
	..q:(SQLCODE'=0)
	
	s namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	Set RLTRowId=0
	For  Set RLTRowId=$O(^DHCPERLT(0,"OEORI",OEIId,RLTRowId)) Quit:RLTRowId=""  Do
	.Set RLTODDR=$p(^DHCPERLT(RLTRowId),"^",3)
	.Set ODLabtrakCode=$p(^DHCPEST($P(RLTODDR,"||",1),"OD",$P(RLTODDR,"||",2)),"^",10)
	.q:labItemCode=""       //20090305 c
    .q:ODLabtrakCode=""    //20090305 c
	.Set labResult=$d(^TEPI(episodeNo,1,labItemCode,1,"DATA",ODLabtrakCode))
	.If labResult=0 Do
	..&sql(delete from SQLUser.dhc_pe_result where rlt_rowid=:RLTRowId)
	q ""
}

/// Description: RisResultMain function, the preCondition is %request.Get("EpisodeID") is exists.
/// return: "":Correct;  Else:Error occured.
ClassMethod RisResultMain() As %String
{
	s admId=%request.Get("EpisodeID")
	//s arcItmId=%request.Get("ARCIMID")n
	s ordItmId=%request.Get("OEORIRowId")
	s userId=%session.Get("LOGON.USERID")
	s ret=##class(web.DHCPE.TransResult).TransARisItem(admId, ordItmId, userId)
	q ret
}

/// Create by MLH
/// return: "":Correct;  Else:Error occured.
/// test: w ##class(web.DHCPE.TransResult).TransARisItem("50677","44809||5",10691)
ClassMethod TransARisItem1(admId As %String, ordItmId As %String, UserId As %String)
{
	
	q:(ordItmId="") "Error: No correct OEORDItem!"
	s itemStatusDr=""
	s labItemCode=""

	&sql(SELECT   oeori_itemstat_dr, OEORI_ItmMast_DR
		 into  :itemStatusDr, :arcItemId
		 FROM  SQLUser.OE_OrdItem
		 where oeori_rowid=:ordItmId and OEORI_OEORD_ParRef->OEORD_Adm_DR=:admId		 
      			and oeori_itemstat_dr<>4 )
	q:(arcItemId="") "Error: No correct arcItemId" //已停止

	//q:(##class(web.DHCPE.ResultPermission).GetGeneAdviserStatus(admId)="Audited") "" //总检已经审核

	s DCMRPTRowId=$o(^DicomRpti("oeorditem",ordItmId,0))
	q:($g(DCMRPTRowId)="") ""
		
	s RisItemStatus=$P(^DicomRpt(DCMRPTRowId),"^",9)
	q:(RisItemStatus="") "Error: the result is not Verify."	//未审核
	
	s ExamDesc=$P(^DicomRpt(DCMRPTRowId),"^",3)  //3,检查所见
	s ExamResult=$P(^DicomRpt(DCMRPTRowId),"^",4)  //4,诊断意见
	s ClinicInfo=$P(^DicomRpt(DCMRPTRowId),"^",17)  //17,临床诊断
	q:((ExamDesc="")&(ExamResult)&(ClinicInfo)) "Error: No RisData" //没有Ris数据
	
	s DCMUserId=$P(^DicomRpt(DCMRPTRowId),"^",7)
	i DCMUserId'="" s UserId=$p(^DicomCT(DCMUserId),"^",1)
	
	s retStr=..InsertBlankRisItem(ordItmId, UserId)
	q:(retStr'="") retStr
	s resultId="", orderDetailId=""
	f  s orderDetailId=$o(^DHCPERLT(0,"ADMOD",admId,ordItmId,orderDetailId))  q:(orderDetailId="")  d
	.s resultId=$o(^DHCPERLT(0,"ADMOD",admId,ordItmId,orderDetailId,"0"))
	.s objResult=##class(User.DHCPEResult).%OpenId(resultId)
	.s RisItemDesc=objResult.RLTODDR.ODDesc	//细项的名称
	.s ODDesc=$p(RisItemDesc,"-",2)
	.i ODDesc="检查结果" d 
	..
	..s ClinicInfo=##Class(web.DHCPE.ResultEdit).GetRisDataClinicInfo(ordItmId)
	..s ExamDesc=##Class(web.DHCPE.ResultEdit).GetRisDataExamDesc(ordItmId)
	..s ExamResult=##Class(web.DHCPE.ResultEdit).GetRisDataExamResult(ordItmId)
	..s ResultStr="临床诊断:"_ClinicInfo
	..s ResultStr=ResultStr_";检查所见:"_ExamDesc
	..s ResultStr=ResultStr_";诊断意见:"_ExamResult
	..s objResult.RLTResult=ResultStr
	.s objResult.RLTUpdateDate=+$h
	.s objResult.RLTUpdateTime=$p($h,",",2)
	.s objResult.RLTUserDR=UserId
	.s retStatus=objResult.%Save()
	.b:($$$ISOK(retStatus)'=1)	;objResult.%Save()
	q ""
}

/// Create by MLH
/// return: "":Correct;  Else:Error occured.
/// test: w ##class(web.DHCPE.TransResult).TransARisItem("7731283","7588738||43",1)
ClassMethod TransARisItem(admId As %String, ordItmId As %String, UserId As %String)
{
	Quit:($G(ordItmId)="") "Error: No correct OEORDItem!"
	Set itemStatusDr=""
	Set labItemCode=""
	/*&sql(SELECT   oeori_itemstat_dr, OEORI_ItmMast_DR
		 into  :itemStatusDr, :arcItemId
		 FROM  SQLUser.OE_OrdItem
		 where oeori_rowid=:ordItmId and OEORI_OEORD_ParRef->OEORD_Adm_DR=:admId		 
      			and oeori_itemstat_dr<>4 )
	Quit:($g(arcItemId)="") "Error: No correct arcItemId" //已停止
	*/
	q:ordItmId="" ""
	s itemStatusDr=$p(^OEORD($p(ordItmId,"||",1),"I",$p(ordItmId,"||",2),1),"^",13)
	q:itemStatusDr="4" "Error: orderItem's status is stopped."	//已停止
	s arcItemId=$p(^OEORD($p(ordItmId,"||",1),"I",$p(ordItmId,"||",2),1),"^",2)
	q:arcItemId="" "arcItemId is null"
	
	///Add by wrz for xdt
	s STRowId=0
	s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",arcItemId, STRowId))
	Q:(""=STRowId) 0
	s STORDChildSub=0
	s STORDChildSub=$O(^DHCPEST(0,"STORD_ARCIM",arcItemId, STRowId, STORDChildSub))
	Q:(""=STORDChildSub) 0
	s ReportFormat=$P(^DHCPEST(STRowId,"O",STORDChildSub),"^",4)
	q:ReportFormat["EKG" 0
	s admId=$P(^OEORD(+ordItmId),"^",1)
	///Add End
	i ReportFormat="RF_PIS"
	{
		;获取病理结果
		d ..TransAPISItem(admId,ordItmId,UserId)
		q 0
	}
	
	q:(##class(web.DHCPE.ResultPermission).GetGeneAdviserStatus(admId)="Audited") "HadAudit" //总检已经审核
	Set RARRowId=$o(^DHCPACRegInfoi("OEORI",ordItmId,0))
	Quit:$g(RARRowId)="" "NoReport"
	Set RisStudyNo=$p(^DHCPACRegInfo(RARRowId),"^",2)
	//Set DRPTRowId=$o(^DHCRBStudyi("Report","StudyNo",RisStudyNo,0))
	set DRPTRowId=##class(web.DHCPE.TransResult).GetMaxRisReportID(RisStudyNo)
	b ;RisStudyNo DRPTRowId
	Quit:($g(DRPTRowId)="") "NoReportID"
	Set RisItemStatus=$P(^DHCRBStudy("Report",DRPTRowId),"^",4)
	Quit:(RisItemStatus'="5")&&(RisItemStatus'="4") "Error: the result is not Verify."_RisItemStatus	//未发布
	b ;DRPTRowId
	///Add by MLH 2008-05-13  判断最后发布时间
	s AuditDate=$P(^DHCRBStudy("Report",DRPTRowId),"^",12)
	//超声一般不审核，pacs默认审核日期1990-01-01，放射必须审核
	i ((AuditDate="21915")||(AuditDate="")) s AuditDate=$P(^DHCRBStudy("Report",DRPTRowId),"^",9)
	s AuditTime=$P(^DHCRBStudy("Report",DRPTRowId),"^",13)
	i AuditTime=""  s AuditTime=$P(^DHCRBStudy("Report",DRPTRowId),"^",10)
	s IfTraned=$g(^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId))
	s TranedDate=+IfTraned
	s TranedTime=$p(IfTraned,",",2)
	Quit:(AuditDate<TranedDate) ""  //判断是否传输过
	Quit:((AuditDate=TranedDate)&(AuditTime<TranedTime)) ""
	////////////
	Set ExamDesc=^DHCRBStudy("Report",DRPTRowId,"ExamDescEx")  //3,检查所见
	s ExamDesc=##class(web.DHCPE.Public.Setting).Replace(ExamDesc,"检查所见:","")
	Set ExamResult=^DHCRBStudy("Report",DRPTRowId,"ResultDescEx")  //4,诊断意见
	s ExamResult=##class(web.DHCPE.Public.Setting).Replace(ExamResult,"检查意见:","")
	//Set ExamDesc=$G(^DHCRBStudy("Report",DRPTRowId,"ResultDescEx"))  //3,检查所见
	//Set ExamResult=$G(^DHCRBStudy("Report",DRPTRowId,"ExamDescEx"))  //4,诊断意见
	s OneStr=""
	/*
	i ExamResult["检查所见:" d
	.s OneStr=$P(ExamDesc,"检查意见:",2)
	.s ExamDesc=$P(ExamResult,"检查所见:",2)
	.s ExamResult=OneStr
	*/
	Set ClinicInfo=""
	//s ClinicInfo=$P(^DicomRpt(DRPTRowId),"^",17)  //17,临床诊断
	b ;ClinicInfo
	q:((ExamDesc="")&(ExamResult="")&(ClinicInfo="")) "Error: No RisData" //没有Ris数据
	s DCMUserId=$P(^DHCRBStudy("Report",DRPTRowId),"^",11)  ;审核医生
	s ReportUserId=$P($G(^DHCRBStudy("Report",DRPTRowId)),"^",8)  ;报告医生
	s:DCMUserId="" DCMUserId=ReportUserId
	//是否正常的判断
	s result=$P(^DHCRBStudy("Report",DRPTRowId),"^",7)
	i result="N" d
	.s result=1
	e  d
	.s result=0
	
	//i DCMUserId'="" s UserId=$p(^DicomCT(DCMUserId),"^",1)
	s UserId=DCMUserId
		
	s retStr=..InsertBlankRisItem(ordItmId, UserId)
	
	q:(retStr'="") retStr
	s resultId="", orderDetailId=""
	f  s orderDetailId=$o(^DHCPERLT(0,"ADMOD",admId,ordItmId,orderDetailId))  q:(orderDetailId="")  d
	.s resultId=$o(^DHCPERLT(0,"ADMOD",admId,ordItmId,orderDetailId,"0"))
	.s objResult=##class(User.DHCPEResult).%OpenId(resultId)
	.s RisItemDesc=objResult.RLTODDR.ODDesc	//细项的名称
	.s RisItemDescLength=$l(RisItemDesc,"-")
	.s ODDesc=$p(RisItemDesc,"-",RisItemDescLength)
	.s ResultStr=""
	.i ODDesc="检查结果" d 
	..;s ClinicInfo=##class(web.DHCPE.ReportGetInfor).Replace(ClinicInfo,"_$c(13,10)_","  ")
	..;s ClinicInfo=##class(web.DHCPE.ReportGetInfor).Replace(ClinicInfo,"_$c_","  ")
	..;s ExamDesc=##class(web.DHCPE.ReportGetInfor).Replace(ExamDesc,"_$c(13,10)_","  ")
	..;s ExamDesc=##class(web.DHCPE.ReportGetInfor).Replace(ExamDesc,"_$c_","  ")
	..;s ExamResult=##class(web.DHCPE.ReportGetInfor).Replace(ExamResult,"_$c(13,10)_","  ")
	..;s ExamResult=##class(web.DHCPE.ReportGetInfor).Replace(ExamResult,"_$c_","  ")
	..s ResultStr="临床诊断:"_ClinicInfo
	..s ResultStr=ResultStr_";检查所见:"_ExamDesc
	..s ResultStr=ResultStr_";诊断意见:"_ExamResult
	..s ^DHCPETempResult(ordItmId)=ResultStr
	..s objResult.RLTResult=ResultStr
	.i AuditDate'="" d
	..s objResult.RLTUpdateDate=AuditDate
	.e  s objResult.RLTUpdateDate=+$h 
	.i AuditTime'="" d 
	..s objResult.RLTUpdateTime=AuditTime
	.e  s objResult.RLTUpdateTime=$p($h,",",2)
	.s:UserId'="" objResult.RLTUserDR=UserId
	.s objResult.RLTNormal=result
	.s retStatus=objResult.%Save()
	.b:($$$ISOK(retStatus)'=1)	;objResult.%Save()
	.s $p(^DHCPERLT(resultId),"^",4)=ResultStr
	.s SQLCODE=##class(web.DHCPE.HighRisk).GetHighRiskFlag(resultId)         //add
	.k ^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",ordItmId)
	
	s ^DHCPEData("DHCPEResult","RIS","ReportUser",ordItmId)=ReportUserId
	s ^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId)=$h
	q ""
}

/// description: 插入空的RIS结果记录  //mlh
/// return: "": correct 	else: Error infomation
/// test: w ##class(web.DHCPE.TransResult).InsertBlankRisItem("44809||5",1)
ClassMethod InsertBlankRisItem(ordItmId, UserId)
{
	s admId="", arcItemId="", itemStatusDr=""
	
	/*&sql(SELECT  OEORI_OEORD_ParRef->OEORD_Adm_DR, oeori_itmMast_dr, oeori_itemstat_dr
		 			into  :admId, :arcItemId, :itemStatusDr
		 FROM  SQLUser.OE_OrdItem
		 where oeori_RowId=:ordItmId)
	q:itemStatusDr="4" "Error: orderItem's status is stopped."	//已停止
	*/
	
	q:ordItmId="" ""
	s itemStatusDr=$p(^OEORD($p(ordItmId,"||",1),"I",$p(ordItmId,"||",2),1),"^",13)
	q:itemStatusDr="4" "Error: orderItem's status is stopped."	//已停止
	s arcItemId=$p(^OEORD($p(ordItmId,"||",1),"I",$p(ordItmId,"||",2),1),"^",2)
	q:arcItemId="" ""
	s admId=$p(^OEORD(+ordItmId),"^",1)
	
	
	s myCount=0
	s myCount=+$o(^DHCPERLT(0,"OEORI",ordItmId,myCount))
	
	/*&sql(select count(*) into :myCount from SQLUser.dhc_pe_result 
		 where rlt_adm_dr=:admId and rlt_OEORI_DR=:ordItmId)
	*/
	q:(myCount>0) ""		//已经存在记录  //还要修改，MLH0904
	
	s updateDt=+$h
	s updateTt=$p($h,",",2)
    s num=0
	s ODRRowId=0
	f  s ODRRowId=$O(^DHCPEODR(0,"ARCIM",arcItemId,ODRRowId)) q:(ODRRowId="")  d
	.s ODDR=$p(^DHCPEODR(ODRRowId),"^",2)
	.s num=num+1
    .&sql(insert into SQLUser.dhc_pe_result
	 (rlt_adm_dr, rlt_ARCIM_DR, rlt_OD_DR, rlt_user_dr,rlt_updateDate,rlt_OEORI_DR,RLT_UpdateTime)
	  values(:admId, :arcItemId, :ODDR, :UserId, :updateDt,:ordItmId,:updateTt))
	.q:(SQLCODE'=0)
	q ""
}

ClassMethod trans(tc, ret)
{
   s itmtype=$p($g(^TTAB("TC",tc)),"\",3)
   b //1
   i itmtype["N" d    ;numeric
   .s decimal=$e(itmtype,2)
   .i decimal="" s decimal="0"
   .s temres=..CheckResDecimal(ret,decimal)
   .s ret=temres_$c(1)_temres
   .b //2
   .;标准备注
   e  i itmtype["S" d
   .s preres=""
   .i $l(ret),$d(^TTAB("TC",tc,2,ret,1))  d
   ..s preres=$g(^TTAB("TC",tc,2,ret,1))
   .s ret=ret_$c(1)_preres
   .;血型
   e  i itmtype["B" d
   .s preres=""
   .i $l(ret),$d(^TTAB("BB-BG",ret)) d
   ..s preres=$p(^TTAB("BB-BG",ret),"\",1)
   .s ret=ret_$c(1)_preres
   .;bug
   e  i itmtype="V" d
   .i $l(ret),$d(^TTAB("BUG",ret)) d
   ..s preres=$p(^TTAB("BUG",ret),"\",1)
   ..s ret=ret_$c(1)_preres
   e  d
   .s ret=ret_$c(1)_ret
   q ret
}

ClassMethod CheckResDecimal(res, dec)
{
	//n (res,dec)
	s res=$g(res),dec=+$g(dec)
	s ret=""
	i res="" q ret
	i dec="" q ret
	s flag=""
	i ($e(res)="<")!($e(res)=">") s flag=$e(res),res=$tr(res,"<>")
	s res=+res
	s ret=$fn(res,"",dec)
	q flag_ret
}

// w ##class(web.DHCPE.TransResult).GetLabResultArrowNew(55616)

ClassMethod GetLabResultArrowNew(ResultID)
{
	s Arrow="1"
	i $D(^DHCPEDataEx("DHCPEResult",ResultID,"HLFlag")) d
	.s Info=$G(^DHCPEDataEx("DHCPEResult",ResultID,"HLFlag"))
	.s:(Info="H")||(Info="PH") Arrow="2"      
	.s:(Info="L")||(Info="PL") Arrow="0"
	e  d
	.s NormalFlag=$P($G(^DHCPERLT(ResultID)),"^",7)
	.q:NormalFlag="1"
	.s ODID=$P($G(^DHCPERLT(ResultID)),"^",3)
	.i +ODID=$G(^DHCPESetting("DHCPE","StationId_Lab")) d
	..s NormalResult=$G(^DHCPEDataEx("DHCPEResult",ResultID,"Ranges"))
	.e  d
	..s EpisodeID=$P($G(^DHCPERLT(ResultID)),"^",1)
	..s myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(EpisodeID)
	..s myAge=$p(myStr,"^",1)
	..s mySex=$p(myStr,"^",2)
	..s NormalResult=##class(web.DHCPE.ResultEdit).GetNormal(ODID,mySex,myAge)
	.s ResultValue=$P($G(^DHCPERLT(ResultID)),"^",4)
	.s Arrow=..GetLabResultArrow(NormalResult, ResultValue)
	q Arrow
}

// w ##class(web.DHCPE.TransResult).GetLabResultArrow(">3","0.4")

ClassMethod GetLabResultArrow(NormalResult, ResultValue)
{
	s Arrow="1"
	q:ResultValue["阴性" 1
	q:ResultValue["阳性" 1
	q:ResultValue="大于=1.030" 2
	q:ResultValue[(">") 2
	q:ResultValue[("大于") 2
	q:ResultValue[("<") 0
	q:ResultValue[("小于") 0
	q:ResultValue[("≥") 2
	q:ResultValue[("≤") 0
	i NormalResult="" q Arrow
	s:NormalResult[("正常人群应:<3.37") NormalResult="<3.37"
	i NormalResult["<" d
	.s NormalResult=$p(NormalResult,"<",2)
	.i $e(NormalResult,1)="=" d
	..s NormalResult=$p(NormalResult,"=",2)
	.i ResultValue>+NormalResult s Arrow=2
	e  i NormalResult[">" d
	.s NormalResult=$p(NormalResult,">",2)
	.e  i $e(NormalResult,1)="=" d
	..s NormalResult=$p(NormalResult,"=",2)
	.i +ResultValue<+NormalResult s Arrow=0
	e  i NormalResult["小于" d
	.s NormalResult=$p(NormalResult,"小于",2)
	.i $e(NormalResult,1)="=" d
	..s NormalResult=$p(NormalResult,"=",2)
	.i ResultValue>+NormalResult s Arrow=2
	e  i NormalResult["大于" d
	.s NormalResult=$p(NormalResult,"大于",2)
	.e  i $e(NormalResult,1)="=" d
	..s NormalResult=$p(NormalResult,"=",2)
	.i ResultValue<+NormalResult s Arrow=0
	e  d
	.q:NormalResult'["-"
	.s Min=$p(NormalResult,"-",1)
	.s Max=$p(NormalResult,"-",2)
	.q:(Min="")&&(Max="")
	.i Min>ResultValue s Arrow="0"
	.i Max<ResultValue s Arrow="2"
	q Arrow
}

/*
ClassMethod TransMain(PAADM As %String = "")
{
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s RisStation=$g(^DHCPESetting("DHCPE","StationId_Ris"))
	s RisStation="^"_RisStation_"^"
	s admId=%request.Get("EpisodeID")
	;s admId=%request.Get("PAADM")
	i admId="" s admId=PAADM
	q:admId="" ""
	s ret=""
	s userId=%session.Get("LOGON.USERID")
	s OEOrder=0
	f  s OEOrder=$O(^OEORD(0,"Adm",admId,OEOrder))  q:(OEOrder="")  d
	.s OEOrdItem=0
	.f  s OEOrdItem=$O(^OEORD(OEOrder,"I",OEOrdItem))  q:(OEOrdItem="")  d
	..s CurData=$G(^OEORD(OEOrder,"I",OEOrdItem,1))
	..Q:(""=CurData)
	..s ORIStat=$p(CurData,"^",13)
	..q:ORIStat'=6
	..s ordItmId=OEOrder_"||"_OEOrdItem
	..s ItemMastId=$p(CurData,"^",2)
	..s StationId=$o(^DHCPEST(0,"STORD_ARCIM",ItemMastId,0))
	..q:StationId=""
	..;s RLTRowid=$o(^DHCPERLT(0,"OEORI",ordItmId,0))
	
	..s LabSpec=$p($G(^OEORD(+ordItmId,"I",$P(ordItmId,"||",2),3)),"^",20)
	..i (LabSpec'="") d  ;标本号不是空就回传
	...s ret=##class(web.DHCPE.TransResult).TransALabItem(admId, userId,ordItmId)
	..e  i (RisStation[("^"_StationId_"^")) d
	...s ret=##class(web.DHCPE.TransResult).TransARisItem(admId, ordItmId, userId)
	;d ##class(web.DHCPE.ResultDiagnosis).UpdateStationS(admId, 0,"")
	
	q ret
	
	;w ##class(web.DHCPE.TransResult).TransMain(4012662)
	q:PAADM="" ""
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s RisStation=$g(^DHCPESetting("DHCPE","StationId_Ris"))
	s RisStation="^"_RisStation_"^"
	s admId=%request.Get("EpisodeID")
	i admId="" s admId=PAADM
	s IADM=$o(^DHCPEIADM(0,"PAADM",admId,0))
	s PreIADM=$p(^DHCPEIADM(IADM),"^",4)
	s userId=%session.Get("LOGON.USERID")
	s GroupId=%session.Get("LOGON.GROUPID")
	s ret=""
	s ItemSub=0
	f  s ItemSub=$o(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub)) q:(ItemSub="")  d
	.s Flag=$p($g(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub)),"^",16)
	.q:Flag'=1
	.s ItemId=PreIADM_"||"_ItemSub
	.s ItemMastId=$p(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub),"^",1)
	.s StationId=$o(^DHCPEST(0,"STORD_ARCIM",ItemMastId,0))
	.s CrmOrderId=$o(^DHCPECRMO(0,"CRMORI",ItemId,0))
	.q:CrmOrderId=""
	.s ordItmId=$p(^DHCPECRMO(CrmOrderId),"^",1)
	.s RLTRowid=$o(^DHCPERLT(0,"OEORI",ordItmId,0))
	.s LabSpec=$p($G(^OEORD(+ordItmId,"I",$P(ordItmId,"||",2),3)),"^",20)
	.i (LabSpec'="") d  ;标本号不是空就回传
	..s ret=##class(web.DHCPE.TransResult).TransALabItem(admId, userId,ordItmId)
	.e  i (RisStation[("^"_StationId_"^")) d
	..s ret=##class(web.DHCPE.TransResult).TransARisItem(admId, ordItmId, userId)
	i (","_GroupId_",")=$G(^DHCPESetting("DHCPE","SSGroup_SummarizeAudit")) d
	.d ##class(web.DHCPE.ResultDiagnosis).UpdateStationS(admId, 0,"")

	i ret'="" 
	{
		q ret
	}
	q ret
}
*/
ClassMethod TransMain(PAADM As %String = "")
{
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s RisStation=$g(^DHCPESetting("DHCPE","StationId_Ris"))
	s RisStation="^"_RisStation_"^"
	s LisNewVersion=$g(^DHCPESetting("DHCPE","LisNewVersion"))
	s admId=%request.Get("EpisodeID")
	i admId="" s admId=PAADM
	q:admId="" ""
	s ret=""
	s userId=%session.Get("LOGON.USERID")
	s OEOrder=0
	f  s OEOrder=$O(^OEORD(0,"Adm",admId,OEOrder))  q:(OEOrder="")  d
	.s OEOrdItem=0
	.f  s OEOrdItem=$O(^OEORD(OEOrder,"I",OEOrdItem))  q:(OEOrdItem="")  d
	..s CurData=$G(^OEORD(OEOrder,"I",OEOrdItem,1))
	..Q:(""=CurData)
	..s ORIStat=$p(CurData,"^",13)
	..q:ORIStat'=6
	..s ordItmId=OEOrder_"||"_OEOrdItem
	..s ItemMastId=$p(CurData,"^",2)
	..s StationId=$o(^DHCPEST(0,"STORD_ARCIM",ItemMastId,0))
	..q:StationId=""
	..;s RLTRowid=$o(^DHCPERLT(0,"OEORI",ordItmId,0))
	
	..s LabSpec=$p($G(^OEORD(+ordItmId,"I",$P(ordItmId,"||",2),3)),"^",20)
	..i (LabSpec'="")&&(LisNewVersion'="Y") d  ;标本号不是空就回传
	...s ret=##class(web.DHCPE.TransResult).TransALabItem(admId, userId,ordItmId)
	..e  i (LabSpec'="")&&(LisNewVersion="Y") d
	...s ret=##class(web.DHCPE.TransResult).TransALabItemNew(admId, userId,ordItmId)
	..e  i (RisStation[("^"_StationId_"^")) d
	...s ret=##class(web.DHCPE.TransResult).TransARisItem(admId, ordItmId, userId)
	;d ##class(web.DHCPE.ResultDiagnosis).UpdateStationS(admId, 0,"")
	
	q ret
}

ClassMethod Test()
{
	s id=0
	s i=0
	f  s id=$o(^DicomRpt(id)) q:i>30  d
	.s UserId=""
	.s DCMUserId=$P(^DicomRpt(DCMRPTRowId),"^",7)
	.i DCMUserId'="" s UserId=$p(^DicomCT(DCMUserId),"^",1)
	.w DCMUserID_"^"_UserId
}

/// 获取外部代码
/// w ##Class(web.DHCPE.TransResult).GetLabExtCode("TrakCare","2152||1")
ClassMethod GetLabExtCode(TrakVerison, arcItemId, OEORIID As %String = "")
{
	s LabExtCode=""
	i OEORIID=""
	{
		i TrakVerison="TrakCare" d
		.Quit:'$d(^ARCIM(+arcItemId,1,"EXT"))
		.s Ext=0
		.f  s Ext=$o(^ARCIM(+arcItemId,1,"EXT",Ext))  q:(Ext="")  d
		..s fromdate=$p(^ARCIM(+arcItemId,1,"EXT",Ext),"^",1)
		..q:(+fromdate>+$H)
		..s todate=$p(^ARCIM(+arcItemId,1,"EXT",Ext),"^",2)
		..q:((todate'="")&&(+todate<+$H))
		..Set LabExtCode=$p(^ARCIM(+arcItemId,1,"EXT",Ext),"^",4)
	}
	else
	{
		s Ext=$P(^OEORD(+OEORIID,"I",$p(OEORIID,"||",2),3),"^",35)
		s LabExtCode=$P(Ext,"||",2)
		i LabExtCode="" s LabExtCode=..GetLabExtCode(TrakVerison, arcItemId)
	}
	q LabExtCode
}

/// 复兴医院 2008.03.03 xuwm
/// 获取身高体重仪的结果并填入到结果表中
/// stature avoirdupois
/// w ##Class(web.DHCPE.TransResult).GetBaseData(1)
ClassMethod GetBaseData(admid As %String = "")
{
	s namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	// 获取当前的仪器值: 身高^体重
	s ResultValues=$G(^DHCTRAKTJ)
	Q:(""=ResultValues) "Error:Current No Data" //没有找到结果
	s ResultItems=$G(^DHCPESetting("DHCPE","GetBaseData"))
	Q:(""=ResultItems) "Error:No Test Item" //没有找到结果
	
	// 身高
	s stature=$P(ResultValues,"^",1)
	s:(stature>100) stature=stature
	s ret="^"_$P(ResultItems,"^",1)_":"_stature_";"
	
	// 体重
	s stature=$P(ResultValues,"^",2)
	s ret=ret_"^"_$P(ResultItems,"^",2)_":"_stature_";"
	
	Q ret
}

ClassMethod GetMaxRisReportID(RisStudyNo)
{
	q:RisStudyNo="" ""
	s maxDRPTRowId=$o(^DHCRBStudyi("Report","StudyNo",RisStudyNo,""),-1)
	/*
	s maxDRPTRowId=0
	s dptRowId=0
	f  s dptRowId=$o(^DHCRBStudyi("Report","StudyNo",RisStudyNo,dptRowId))  q:dptRowId=""  d
	.b ;dptRowId
	.s maxDRPTRowId=dptRowId
	i maxDRPTRowId=0 s maxDRPTRowId=""
	*/
	q maxDRPTRowId
}

ClassMethod InsertNormalResult(admId, ordItmId, userId)
{
	s locId=%session.Get("LOGON.CTLOCID")
	q:$G(^DHCPESetting("DHCPE","AutoNormalResult",locId))'="Y"
	s C1=$C(1)
	s C2=$C(2)
	s ResultStr=""
	s PAPMI=$p(^PAADM(admId),"^",1)
	s SexID=$P(^PAPER(PAPMI,"ALL"),"^",7)
	s SexCode=$P(^CT("SEX",SexID),"^",1)
	s ARCIMID=$p(^OEORD($p(ordItmId,"||",1),"I",$p(ordItmId,"||",2),1),"^",2)
	s ODRelateID=0
	f  s ODRelateID=$o(^DHCPEODR(0,"ARCIM",ARCIMID,ODRelateID)) q:ODRelateID=""  d
	.s Sort=$p($G(^DHCPEODR(ODRelateID)),"^",3)
	.q:Sort=""
	.s DetailID=$p($G(^DHCPEODR(ODRelateID)),"^",2)
	.s DType=$P($G(^DHCPEST(+DetailID,"OD",$p(DetailID,"||",2))),"^",2)
	.q:DType'="S"
	.s SexType=$P($G(^DHCPEST(+DetailID,"OD",$p(DetailID,"||",2))),"^",9)
	.q:(SexType'="N")&&(SexType'=SexCode)
	.s NormalStr=##class(web.DHCPE.ResultEdit).GetNormal(DetailID,SexCode,"17")
	.q:NormalStr=""
	.i ResultStr="" d
	..s ResultStr=DetailID_C1_NormalStr
	.e  d
	..s ResultStr=ResultStr_C2_DetailID_C1_NormalStr
	q:ResultStr=""
	//d ##class(web.DHCPE.ResultEdit).SavePEResult(admId, ordItmId, ResultStr)
}

ClassMethod TransAPISItem(admId As %String, ordItmId As %String, UserId As %String)
{
	s curZN=$ZNSpace
	s IfTraned=$g(^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId))
	s TranedDate=+IfTraned
	
	s PisInterfaceFlag=$g(^DHCPESetting("DHCPE","SendPisInterface"))
	if (PisInterfaceFlag="Y") {
		///8.2.0新产品组方法
		///结果内容串:病理号^报告医生代码^报告医生^审核医生代码^审核医生^报告日期^审核日期
         ///^报告时间^审核时间^备注^肉眼所见^检查所见^诊断结果^检查结果^结果异常^PIS报告ID
		S value=##Class(web.DHCAPPPisInterface).GetPisItmRes(ordItmId)
		q:value="" ""
		 //检查所见
		s JCresult=$p(value,"^",12)
		i (JCresult="")||(JCresult=$c(0)) s JCresult=$p(value,"^",11)
		//诊断意见
		s ZDresult=$p(value,"^",13)
		//医生工号 
		s doc=$p(value,"^",5)
		s UserId=""
		i doc'="" d
		.s doc=$$ALPHAUP^SSUTIL4(doc)
		.s UserId=$o(^SSU("SSUSR",0,"SSUSR_Initials",doc,""))
	

    	//报告发布日期
		s date=$zdh($p(value,"^",7),3) 
		
	}
	if (PisInterfaceFlag'="Y") {	
	zn "PIS"
	//病理8.0.2新版接口
	//PathID_"^"_RptClass_"^"_RptDiagnosis1_"^"_RptDiagnosis2_"^"_RptDoctor_"^"_RptDate_"^"_RptTime_"^"_RptLoc_"^"_PatName_"^"_sexDesc_"^"_PatBirth_"^"_AppDate_"^"_AppLoc_"^"_SurRoomNO
	//s value=##class(PISApp.PISService).GetRptInfoByTJOeorditemID(ordItmId)
	//病理8.1.1版接口
	//diagnosis_"^"_UserDR_"^"_rptDate
	s value=##class(Src.DPIS3OutInterface).GetPisDiagToTJ(ordItmId)
	zn curZN
	q:value="" ""
	//检查所见
	s JCresult=""
	//诊断意见
	s ZDresult=$p(value,"^",1)
	//医生工号 
	s doc=$p(value,"^",2)
	s UserId=""
	i doc'="" s UserId=doc
    //报告发布日期
	s date=$zdh($p(value,"^",3),3)
	}
	
	//q:TranedDate>date ""  //判断是否传输过
		
	s retStr=..InsertBlankRisItem(ordItmId, UserId)
	q:(retStr'="") retStr
	s resultId="", orderDetailId=""
	f  s orderDetailId=$o(^DHCPERLT(0,"ADMOD",admId,ordItmId,orderDetailId))  q:(orderDetailId="")  d
	.s resultId=$o(^DHCPERLT(0,"ADMOD",admId,ordItmId,orderDetailId,"0"))
	.s objResult=##class(User.DHCPEResult).%OpenId(resultId)
	.s RisItemDesc=objResult.RLTODDR.ODDesc	//细项的名称
	.s ODDesc=$p(RisItemDesc,"-",$l(RisItemDesc,"-"))
	.s ResultStr=""
	.i ODDesc="检查结果" d 
	..s JCresult=##class(web.DHCPE.ReportGetInfor).Replace(JCresult,"_$c(13,10)_","  ")
	..s JCresult=##class(web.DHCPE.ReportGetInfor).Replace(JCresult,"_$c_","  ")
	..s JCresult=##class(web.DHCPE.ReportGetInfor).Replace(JCresult,"\n","  ")
	..s ZDresult=##class(web.DHCPE.ReportGetInfor).Replace(ZDresult,"_$c(13,10)_","  ")
	..s ZDresult=##class(web.DHCPE.ReportGetInfor).Replace(ZDresult,"_$c_","  ")
	..s ZDresult=##class(web.DHCPE.ReportGetInfor).Replace(ZDresult,"\n","  ")
	..s ResultStr="临床诊断:"
	..s ResultStr=ResultStr_";检查所见:"_JCresult
	..s ResultStr=ResultStr_";诊断意见:"_ZDresult
	..s ^DHCPETempResult(ordItmId)=ResultStr
	..s objResult.RLTResult=ResultStr
	.s objResult.RLTUpdateDate=date
	.s objResult.RLTUpdateTime=$p($h,",",2)
	.s objResult.RLTUserDR=UserId
	.s objResult.RLTNormal=0
	.s retStatus=objResult.%Save()
	.b:($$$ISOK(retStatus)'=1)	;objResult.%Save()
	.s $p(^DHCPERLT(resultId),"^",4)=ResultStr
	
	s ^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId)=$h
}

// w ##class(web.DHCPE.TransResult).LabIsNormal("正常人群应:<3.37 高危人群应:<2.59 极高危人群应:<2.07","J6028","3.55")

ClassMethod LabIsNormal(NormalStr, CTTCCode, ItemValue)
{
	Quit:(($g(CTTCCode)="")||($g(ItemValue)="")) 1
	q:ItemValue[("阳性") 0
	q:ItemValue[("可疑") 0
	q:ItemValue[(">") 0
	q:ItemValue[("<") 0
	q:ItemValue[("阴性") 1
	
	q:ItemValue="TRACE" 0
	q:(NormalStr="NEG")&&(ItemValue'=NormalStr) 0
	q:ItemValue[("+") 0
	q:(NormalStr="")&&(ItemValue[("级)"))&&(ItemValue'[("0级)")) 0
	s RetFlag=0
	s:NormalStr[("正常人群应:<3.37") RetFlag=1
	s:NormalStr[("卵泡期:4.4-7.1") RetFlag=1
	s:NormalStr[("卵泡期:5.1-7.0") RetFlag=1
	s:NormalStr[("卵泡期:50-154.4") RetFlag=1
	s:NormalStr[("卵泡期:7.2-9.2") RetFlag=1
	s:NormalStr[("卵泡期:25.6-42.6") RetFlag=1
	s:NormalStr[("卵泡期:0.35-0.81") RetFlag=1
	;q:RetFlag=0 1
	s:NormalStr[("正常人群应:<3.37") NormalStr="<3.37"
	s:NormalStr[("卵泡期:4.4-7.1") NormalStr="2.6-49.7"
	s:NormalStr[("卵泡期:5.1-7.0") NormalStr="2.5-93.1"
	s:NormalStr[("卵泡期:50-154.4") NormalStr="20.7-460"
	s:NormalStr[("卵泡期:7.2-9.2") NormalStr="3.1-25"
	s:NormalStr[("卵泡期:25.6-42.6") NormalStr="6.1-55"
	s:NormalStr[("卵泡期:0.35-0.81") NormalStr="0.35-24"
	q:CTTCCode="" 1
	s NormalStr=##class(web.DHCPE.Public.Setting).Replace(NormalStr,"≤","<=")
	s NormalStr=##class(web.DHCPE.Public.Setting).Replace(NormalStr,"≥",">=")
	;s NormalStr=##class(web.DHCPE.Public.Setting).Replace(NormalStr,">=","")
	;s NormalStr=##class(web.DHCPE.Public.Setting).Replace(NormalStr,"<=","")
	;s NormalStr=##class(web.DHCPE.Public.Setting).Replace(NormalStr,">","")
	;s NormalStr=##class(web.DHCPE.Public.Setting).Replace(NormalStr,"<","")
	Set Normal=0
	Set ResultFormat=""
	s HospCode=$G(^DHCPESetting("DHCPE","HospitalCode"))
	i (ItemValue="NEGATIVE")&&(HospCode="SHHS") s ItemValue="阴性"
	Set namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	Set ResultFormat=$p($g(^[namespaceLab]TTAB("TC",CTTCCode)),"\",3)
	
	s:ResultFormat="X" ResultFormat="N"
	If ResultFormat="X" Do
	.If NormalStr=ItemValue Set Normal=1
	.///尿常规正常值临时等马
	.//If $o(^TTAB("TC",CTTCCode,4,""))'="" Do
	.If $L(NormalStr,"-")>1 Do
	..Set Min=$p(NormalStr,"-",1)
	..Set Max=$p(NormalStr,"-",2)
	..If (ItemValue>=Min)&&(ItemValue<=Max) Set Normal=1
	.if (ItemValue)="-" Set Normal=1
	If $e(ResultFormat,1)="N" Do
	.//Modified
	.i NormalStr["<" d
	..s NormalStr=$p(NormalStr,"<",2)
	..s EqualFlag=0
	..i NormalStr["=" d
	...s NormalStr=$p(NormalStr,"=",2)
	...s EqualFlag=1
	..s NormalStr=+NormalStr
	..s:(EqualFlag=1)&&(ItemValue<=NormalStr) Normal=1
	..s:(EqualFlag=0)&&(ItemValue<NormalStr) Normal=1
	.e  i NormalStr[">" d
	..s NormalStr=$p(NormalStr,">",2)
	..s EqualFlag=0
	..i NormalStr["=" d
	...s NormalStr=$p(NormalStr,"=",2)
	...s EqualFlag=1
	..s NormalStr=+NormalStr
	..s:(EqualFlag=1)&&(ItemValue>=NormalStr) Normal=1
	..s:(EqualFlag=0)&&(ItemValue>NormalStr) Normal=1
	.e  d
	..Set Min=$p(NormalStr,"-",1)
	..Set Max=$p(NormalStr,"-",2)
	..If (ItemValue>=Min)&&(ItemValue<=Max) Set Normal=1
	//End
	If ResultFormat="S" Do
	.Set CTTCTCode=""
	.Set ResultDesc=""
	.Set NotNormal=""
	.For  Set CTTCTCode=$o(^[namespaceLab]TTAB("TC",CTTCCode,2,CTTCTCode)) Quit:((CTTCTCode="")||(Normal=1))  Do
	..Set NotNormal=$p(^[namespaceLab]TTAB("TC",CTTCCode,2,CTTCTCode),"\",1)
	..Set Format=$p(^[namespaceLab]TTAB("TC",CTTCCode,2,CTTCTCode),"\",3)
	..Set ResultDesc=^[namespaceLab]TTAB("TC",CTTCCode,2,CTTCTCode,1)
	..If (ResultDesc=ItemValue)&(NotNormal="A") Set Normal=0
	..If ((ResultDesc=ItemValue)&(NotNormal'="A")) Set Normal=1
	b ;ResultFormat,!,NormalStr,!,ItemValue,!
	Quit:($g(ItemType)'="T")&(NormalStr="")&(ResultFormat="") 1
	Quit Normal
}

ClassMethod GetZBRISResult(PAADM, OEORDItemID)
{
	
	;w ##class(web.DHCPE.TransResult).GetZBRISResult("6619654","6497615||46")
	
	;s:OEORDItemID="4203815||4" OEORDItemID="4185938||4"
	;s:PAADM="4279105" PAADM="4260793"
	
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	
	s PIADM=$P(^DHCPEIADM(IADM),"^",4)
	s LocID=$P(^DHCPEPreIADM(PIADM),"^",26)
	s PIADM=$P(^DHCPEPreIADM(PIADM),"^",27) ;体检号
	s LocCode="1610000"
	s:LocID'="" LocCode=$P(^CTLOC(LocID),"^",1)
	
	i PIADM="VV0000432" s PIADM="FV0000432"
	i PIADM="P00006834" s PIADM="PAAKQ0003"
	s PIADM=PIADM_"^"_LocCode
	s ResultStream=##class(DHCENS.CheckHeal.BS.CheckHealService).GetZBTJRisResult(PIADM)
	q:ResultStream="" ""
	/*流转为字符串
	s StreamLen=ResultStream.SizeGet()
    d ResultStream.Rewind()
	s XML = ResultStream.Read(StreamLen)
	s Obj=##class(DHCENS.CheckHeal.Msg.TJRisReportList).%New()
	*/
	//流直接转换为对象
	b ;10
	s reader=##class(%XML.Reader).%New()
	s sc=reader.OpenStream(ResultStream)
	d reader.Correlate("TJRisReportList","DHCENS.CheckHeal.Msg.TJRisReportList")
	s obj=##class(DHCENS.CheckHeal.Msg.TJRisReportList).%New()
	s ResultCode="",ResultContent="",ResultInfo=""
	b ;11
	While reader.Next(.obj,.sc) {
		b ;12
		set Count=obj.TJRisReports.Count()
		q:Count=0
		b ;13
		set ResultCode=obj.ResultCode
		q:ResultCode'=0
		set ResultContent=obj.ResultContent
		;for i=1:1:Count
		;{
			set TJRisReport=##class(DHCENS.CheckHeal.Msg.TJRisReport).%New()
			set TJRisReport=obj.TJRisReports.GetAt(Count)
			b ;TJRisReport.ExamSee_";诊断意见:"_TJRisReport.Diagnose
			s ResultInfo="临床诊断:"_""_";检查所见:"_TJRisReport.ExamSee_";诊断意见:"_TJRisReport.Diagnose
			q:ResultInfo="临床诊断:;检查所见:;诊断意见:"
			s:TJRisReport.Auditor'="" TJRisReport.Auditor=$O(^SSU("SSUSR",0,"SSUSR_Name",TJRisReport.Auditor,0))
			b ;TJRisReport.Auditor
			
			s:TJRisReport.Writer'="" TJRisReport.Writer=$O(^SSU("SSUSR",0,"SSUSR_Name",TJRisReport.Writer,0))
			b ;TJRisReport.Writer
			
			s TJRisReport.AuditorDate=##class(web.DHCPE.Public.Setting).Replace(TJRisReport.AuditorDate,".","-")
			s:TJRisReport.AuditorDate'="" TJRisReport.AuditorDate=$ZDH(TJRisReport.AuditorDate,3)
			s:TJRisReport.AuditorTime'="" TJRisReport.AuditorTime=$ZTH(TJRisReport.AuditorTime)
			s TJRisReport.WriteRepotDate=##class(web.DHCPE.Public.Setting).Replace(TJRisReport.WriteRepotDate,".","-")
			s:TJRisReport.WriteRepotDate'="" TJRisReport.WriteRepotDate=$ZDH(TJRisReport.WriteRepotDate,3)
			s OEORDID=+OEORDItemID
			s OEORDID=$O(^OEORD(0,"Adm",PAADM,0))
			q:OEORDID=""
			s Sub=$P(OEORDItemID,"||",2)
			//f  s Sub=$O(^OEORD(OEORDID,"I",Sub)) q:Sub=""  d
			s Stat=$p($G(^OEORD(OEORDID,"I",Sub,1)),"^",13)
			q:Stat=4
			s arcItemId=$p(^OEORD(OEORDID,"I",Sub,1),"^",2)
			q:arcItemId=""
			s STRowId=0
			s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",arcItemId, STRowId))
			q:STRowId'="8"
			s RowID=OEORDID_"||"_Sub
			&SQL(Update Sqluser.OE_OrdItem set OEORI_ItemStat_DR='6' where OEORI_RowID=:RowID)
			q:SQLCODE'=0
			s RLTID=$o(^DHCPERLT(0,"OEORI",RowID,0))
			i RLTID="" d
			.s RLTObj=##class(User.DHCPEResult).%New()
			.s RLTObj.RLTADMDR=PAADM
			.s RLTObj.RLTARCIMDR=arcItemId
			.s RLTObj.RLTOEORIDR=RowID
			.s ODRID=$O(^DHCPEODR(0,"ARCIM",arcItemId, 0))
			.q:ODRID=""
			.s ODID=$P(^DHCPEODR(ODRID),"^",2)
			.d RLTObj.RLTODDRSetObjectId(ODID)
			e  d
			.s RLTObj=##class(User.DHCPEResult).%OpenId(RLTID)
			s RLTObj.RLTResult=""
			s RLTObj.RLTUpdateDate=TJRisReport.WriteRepotDate
			s RLTObj.RLTUpdateTime=$P($H,",",2)
			s RLTObj.RLTUserDR=TJRisReport.Writer
			s RLTObj.RLTNormal=0
			s retStatus=RLTObj.%Save()
			q:($$$ISOK(retStatus)'=1)
			s RLTID=RLTObj.%Id()
			s $p(^DHCPERLT(RLTID),"^",4)=ResultInfo
			k ^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",RowID)
			s SQLCODE=##class(web.DHCPE.HighRisk).GetHighRiskFlag(RLTID) 
			
			//set Result1=TJRisReport.AdmOPNo_"^"_TJRisReport.Auditor_"^"_TJRisReport.AuditorDate_"^"_TJRisReport.AuditorTime_"^"_TJRisReport.Diagnose
			//set Result2=TJRisReport.ExamSee_"^"_TJRisReport.PatName_"^"_TJRisReport.PatRowId_"^"_TJRisReport.Writer_"^"_TJRisReport.WriteRepotDate
			//set Result3=TJRisReport.PatRowId
			
		;}
	}
	if ResultCode="0"
	{
		q 0
	}
	else
	{
		q ResultCode_"^"_ResultContent
	}
}

// d ##class(web.DHCPE.TransResult).EportNormalRange("1000000195")

ClassMethod EportNormalRange(ARCIMCode)
{
	s Par=$O(^ARCIM(0,"Code",ARCIMCode,0))
	q:Par="" "代码不存在"
	s ARCIMID=Par_"||1"
	s Flag=0
	s Order=""
	f  s Order=$O(^OEORDi(0,"ARCIM",Order),-1) q:(Order="")||(Flag=1)  d
	.s SttDat=""
	.f  s SttDat=$O(^OEORDi(0,"ARCIM",Order,ARCIMID,SttDat),-1) q:(SttDat="")||(Flag=1)  d
	..s Sub=""
	..f  s Sub=$O(^OEORDi(0,"ARCIM",Order,ARCIMID,SttDat,Sub),-1) q:(Sub="")||(Flag=1)  d
	...s LabItemSetID=$p($G(^OEORD(Order,"I",Sub,3)),"^",35)
	...q:LabItemSetID=""
	...s labItemCode=$p(LabItemSetID,"||",2)
	...s episodeNo=$p(^OEORD(Order,"I",Sub,3),"^",20)
	...s LabItemDetailCode=""
	...s i=0
	...f  s LabItemDetailCode=$O(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode)) q:LabItemDetailCode=""  d
	....w:i=0 "代码"_$C(9)_"描述"_$C(9)_"正常范围"_$C(9)_"单位",!
	....s i=i+1
	....s NormalStr=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Ranges"))
	....s Unit=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Unit"))
	....s Info=$G(^TTAB("TC",LabItemDetailCode))
	....s Desc=$P(Info,"\",1)
	....w LabItemDetailCode_$C(9)_Desc_$C(9)_NormalStr_$C(9)_Unit,!
	....s Flag=1
}

/*
s LabItemSetID=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),3),"^",35)
	q:LabItemSetID="" ""

	i TrakVerison="TrakCare" d
	.Quit:'$d(^ARCIM(+arcItemId,1,"EXT"))
	.Set Ext=$o(^ARCIM(+arcItemId,1,"EXT",0))
	.Quit:$g(Ext)=""
	.Set labItemCode=$p(^ARCIM(+arcItemId,1,"EXT",Ext),"^",4)

	
	

	i "MedTrak"=TrakVerison d
	.s arcos=$p(^OEORD(+ordItmId,"I",$p(ordItmId,"||",2),3),"^",10)
	.Quit:$g(arcos)=""
	.s labItemCode=$P($G(^ARCOS(arcos)), "^", 11)
   
	i ((TrakVerison="TrakCare")&&($g(arcItemId)'="")) Set labItemCode=##Class(web.DHCPE.TransResult).GetLabExtCode("TrakCare",arcItemId)
	q:((labItemCode="")||(episodeNo="")) "Error: the arcItem's Ext_code is null."

	//判断检验状态
	s labItemStatus=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",31)
	q:(labItemStatus'="A") "Error: the result is not send by labDepartment."	//A: Authorised, 已发送
	
	
	//取检验录入日期   2007-07-27
	//s UpdateDate=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",4)
	s AuditDate=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",4)
	s AuditTime=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",5)
	s AuditTime=AuditTime*60
	s IfTraned=$g(^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId))
	s TranedDate=+IfTraned
	s TranedTime=$p(IfTraned,",",2)
	Quit:(AuditDate<TranedDate) "Date"  //判断是否传输过
	Quit:((AuditDate=TranedDate)&(AuditTime<TranedTime)) "Time"
	s sex=$P($g(^TEPI(episodeNo)),"\",3)
    s age=$P($g(^TEPI(episodeNo)),"\",25)
	Set myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(admId)
	Set mySex=$p(myStr,"^",2)
	Set myAge=$p(myStr,"^",1)    
	//审核人 2008-06-04
	s AuditUser=$P($g(^TEPI(episodeNo,1,labItemCode,1)),"\",6)
	i AuditUser'="" d
	.s AuditUser=$ZCVT(AuditUser,"U")
	.s AuditUser=$O(^SSU("SSUSR",0,"SSUSR_Initials",AuditUser,""))
	s ^DHCPEDataEx("Report","DHCPEIReport","LisAuditUser",ordItmId)=AuditUser
	
	s LisInterface=$g(^DHCPESetting("DHCPE","LisInterface"))
	i LisInterface="N"  d
	.s num=""
  	.f  s num=$o(^TTAB("TS",labItemCode,0,num))  q:num=""  d
  	..s LabItemDetailCode=$p($g(^TTAB("TS",labItemCode,0,num)),"\",8)
  	..d TransResult
  	else  d
	.s LabItemDetailCode=""
	.f  s LabItemDetailCode=$O(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode)) q:LabItemDetailCode=""  d
	..d TransResult
	Q ""
TransResult

	s IsNormal=1
	s Code=$ZCVT(LabItemDetailCode,"U")
	s ItemID=""
	q:Code=""
	s stationID=$O(^DHCPEST(0,"OD_Code",Code,0))
	i stationID="" d
	.s ItemID=##class(web.DHCPE.OrderDetail).ImpOneLabDetail(LabItemDetailCode)
	e  d
	.s sub=$O(^DHCPEST(0,"OD_Code",Code,stationID,0))
	.s ItemID=stationID_"||"_sub
	q:ItemID=""
	s labResult=$g(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode))
	S labResult=$p(labResult,"\",1)
	q:labResult=""
	s LabResultStr=""
	s LisInterface=$g(^DHCPESetting("DHCPE","LisInterface"))
	if LisInterface="N" d
	.If $g(labResult)'="" Do
	..s CurSpace=$ZNSpace
	..zn namespaceLab
	..s LabResultStr=$$TestItmRes^CHDhcLabReport(episodeNo,LabItemDetailCode,labResult,AuditDate)
	..zn CurSpace
    ..i LabResultStr'="" s labResult=$p(LabResultStr,$c(2),4)
	..s NormalStr=##class(web.DHCPE.ResultEdit).GetNormal(ItemID,mySex,myAge)
	..s Unit=$p(^DHCPEST(+ItemID,"OD",$p(ItemID,"||",2)),"^",4)
	else  d
	.s NormalStr=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Ranges"))
	.s Unit=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Unit"))
	s IsNormal=..LabIsNormal(NormalStr,LabItemDetailCode,labResult)
	//s CTTCTComm=$s(IsNormal=0:1,IsNormal=1:0)
	i LabResultStr'=""   d
	.s NormalFlag=$p(LabResultStr,$c(2),11)
	.i (NormalFlag="A")||(NormalFlag="P") s IsNormal="0"
	.else  s IsNormal="1"
	
	s UserId=$p($g(^TEPI(episodeNo,1,labItemCode,1)),"\",3)
	i (UserId'="")&&(LisInterface="Y") d
	.s UserId=$ZCVT(UserId,"U")
	.s UserId=$O(^SSU("SSUSR",0,"SSUSR_Initials",UserId,""))
	
	i UserId="" s UserId=AuditUser

	s PLIST(2)=admId
	s PLIST(3)=arcItemId
	s PLIST(4)=ItemID
	s PLIST(5)=labResult
	s PLIST(6)=UserId
	s PLIST(7)=AuditDate //+$h
	s PLIST(8)=IsNormal
	s PLIST(11)=OEIId
	s PLIST(13)=$p($h,",",2)
	s RLTID=$O(^DHCPERLT(0,"ADMOD",admId,OEIId,ItemID,0))
	i RLTID="" d
	.&SQL(Insert into sqluser.DHC_PE_Result values :PLIST())
	e  d
	.&SQL(update sqluser.DHC_PE_Result values :PLIST() where RLT_RowID=:RLTID)
	i SQLCODE=0  d
	.s RLTID=%ROWID
	.s ^DHCPEDataEx("DHCPEResult",RLTID,"Ranges")=NormalStr
	.s ^DHCPEDataEx("DHCPEResult",RLTID,"Unit")=Unit
	.s SQLCODE=##class(web.DHCPE.HighRisk).GetHighRiskFlag(RLTID) 
	s ^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId)=$h
	q 
	////Modified  Over
	
	///为了检验没有布局等信息修改
	s LabItemDetailCode=""
	f  s LabItemDetailCode=$O(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode)) q:LabItemDetailCode=""  d
	.s IsNormal=1
	.s Code=$ZCVT(LabItemDetailCode,"U")
	.s ItemID=""
	.s stationID=$O(^DHCPEST(0,"OD_Code",Code,0))
	.i stationID="" d
	..s ItemID=##class(web.DHCPE.OrderDetail).ImpOneLabDetail(LabItemDetailCode)
	.e  d
	..s sub=$O(^DHCPEST(0,"OD_Code",Code,stationID,0))
	..s ItemID=stationID_"||"_sub
	.q:ItemID=""
	.s labResult=$g(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode))
	.S labResult=$p(labResult,"\",1)
	.s labResult=$p(labResult,$C(13,10),1)
	.i labResult[("阴性") d
	..s labResult=$P(labResult,"@",1)
	.e  d
	..s labResult=##class(web.DHCPE.Public.Setting).Replace(labResult,"@"," ")
	.//s labResult=$p(..trans(LabItemDetailCode,labResult),$c(1),2)
	.s NormalStr=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Ranges"))
	.;b ;NormalStr,LabItemDetailCode,labResult
	.s IsNormal=..LabIsNormal(NormalStr,LabItemDetailCode,labResult)
	.//s CTTCTComm=$s(IsNormal=0:1,IsNormal=1:0)
	.s UserId=$p($g(^TEPI(episodeNo,1,labItemCode,1)),"\",3)
	.i UserId'="" d
	..s UserId=$ZCVT(UserId,"U")
	..s UserId=$O(^SSU("SSUSR",0,"SSUSR_Initials",UserId,""))
	
	.i UserId="" s UserId=AuditUser
	.// If $g(labResult)'="" Do
	.//.zn namespaceLab
	.//.s LabResultStr=$$TestItmRes^CHDhcLabReport(episodeNo,LabItemDetailCode,labResult,61062)
	.//.zn CurSpace
	.//. Set flag=$p(LabResultStr,$c(2),11)
	.//.If (flag'="")&(flag'="N") Set IsNormal="0"
	.s PLIST(2)=admId
	.s PLIST(3)=arcItemId
	.s PLIST(4)=ItemID
	.s PLIST(5)=labResult
	.s PLIST(6)=UserId
	.s PLIST(7)=AuditDate //+$h
	.s PLIST(8)=IsNormal
	.s PLIST(11)=OEIId
	.s PLIST(13)=$p($h,",",2)
	.s RLTID=$O(^DHCPERLT(0,"ADMOD",admId,OEIId,ItemID,0))
	.i RLTID="" d
	..&SQL(Insert into sqluser.DHC_PE_Result values :PLIST())
	.e  d
	..&SQL(update sqluser.DHC_PE_Result values :PLIST() where RLT_RowID=:RLTID)
	.i SQLCODE=0  d
	..s RLTID=%ROWID
	..s ^DHCPEDataEx("DHCPEResult",RLTID,"Ranges")=NormalStr
	..s ^DHCPEDataEx("DHCPEResult",RLTID,"Unit")=$G(^TEPI(episodeNo,1,labItemCode,1,"DATA",LabItemDetailCode,"Unit"))
	..s SQLCODE=##class(web.DHCPE.HighRisk).GetHighRiskFlag(RLTID)         //add
	s ^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId)=$h
	q ""

*/

// d ##class(web.DHCPE.TransResult).GetReg("7285000||29")

ClassMethod GetReg(ordItmId)
{
	Set RARRowId=$o(^DHCPACRegInfoi("OEORI",ordItmId,0))
	Quit:$g(RARRowId)="" "NoReport"
	Set RisStudyNo=$p(^DHCPACRegInfo(RARRowId),"^",2)
	w RisStudyNo
}

ClassMethod TransALabItemNew(admId As %String, UserId As %String, ordItmId As %String)
{
	
	s episodeNo="", itemStatusDr="", OEIId=""
	i admId="" s admId=$P(^OEORD(+ordItmId),"^",1)
	s OEIId=ordItmId
	q:(OEIId="") "Error: No correct OEORDItem!"	//已停止
	s itemStatusDr=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),1),"^",13)
	q:itemStatusDr="4" "Error: orderItem's status is stopped."	//已停止
	s arcItemId=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),1),"^",2)
	s episodeNo=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),3),"^",20)
	q:($g(episodeNo)="") "Error: EpisodeNo is Null!"
	
	q:(##class(web.DHCPE.ResultPermission).GetReportStatus(admId)="Audited") "" //总检已经审核
	//是否是检验医嘱
	//q:(..CheckIsLabItem(OEIId)=0) "Error: the Item is not a labItem!"
	s TrakVerison=$g(^DHCPESetting("DHCPE","TrakVerison"))
	i TrakVerison="" s TrakVerison="TrakCare"
	//取检验外部代码
	s LabItemSetID=$p(^OEORD($p(OEIId,"||",1),"I",$p(OEIId,"||",2),3),"^",35)
	q:LabItemSetID="" ""
	
	//取检验报告信息
	s LisReportInfo=##Class(LabService.TSInfomation).GetLabInfo(ordItmId)
	
	
	
	//判断检验状态
	
	s labItemStatus=$P(LisReportInfo,$c(2),73)
	q:(labItemStatus'="3") "Error: the result is not send by labDepartment."	//A: Authorised, 已发送
	
	
	//取检验录入日期 2007-07-27
	s AuditDate=$P(LisReportInfo,$c(2),64)
	s AuditDate=$zdh(AuditDate,3)
	s AuditTime=$P(LisReportInfo,$c(2),65)
	s AuditTime=$zth(AuditTime,3)
	
	s IfTraned=$g(^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId))
	s TranedDate=+IfTraned
	s TranedTime=$p(IfTraned,",",2)
	//Quit:(AuditDate<TranedDate) "Date" //判断是否传输过
	//Quit:((AuditDate=TranedDate)&(AuditTime<TranedTime)) "Time"
	
	
	//审核人 2008-06-04
	s AuditUser=$P(LisReportInfo,$c(2),66)

	s AuditUser=$o(^SSU("SSUSR",0,"SSUSR_Initials",$$ALPHAUP^SSUTIL4(AuditUser),0))
	//录入人
	s DoctorId=$P(LisReportInfo,$c(2),62)
	s DoctorId=$o(^SSU("SSUSR",0,"SSUSR_Initials",$$ALPHAUP^SSUTIL4(DoctorId),0))
	s ^DHCPEDataEx("Report","DHCPEIReport","LisAuditUser",ordItmId)=AuditUser
	
	//备注
	s Remark=$P(LisReportInfo,$c(2),70)
	i Remark'="" d
	.s ^DHCPERLT("LabSpecNo",episodeNo)=Remark
	e  d
	.k ^DHCPERLT("LabSpecNo",episodeNo)

	s rs=##class(%ResultSet).%New("LabService.TSResult:GetResultByOrderId") 
	d rs.Execute(ordItmId)
	s ResultSort=0

	while(rs.Next())
	{
		s ResultSort=ResultSort+1
		s IsNormal=1
		s ItemID=""
		s Code=rs.Get("Code")
		q:Code=""
		b ;4
		s stationID=$O(^DHCPEST(0,"OD_Code",Code,0))
		i stationID="" d
		.s ItemID=##class(web.DHCPE.OrderDetail).ImpOneLabDetailNew(Code,rs.Get("Name"),rs.Get("Unit"),rs.Get("Sync"))
		e  d
		.s sub=$O(^DHCPEST(0,"OD_Code",Code,stationID,0))
		.s ItemID=stationID_"||"_sub
		.i '$D(^DHCPEDataEx("BaseData","ZhToEn",ItemID)) d
		..s ^DHCPEDataEx("BaseData","ZhToEn",ItemID)=rs.Get("Sync")
		q:ItemID=""
		s labResult=rs.Get("Result")
		q:labResult=""
		s NormalStr=rs.Get("Ranges")
		s NormalStr=##class(web.DHCPE.ReportGetInfor).Replace(NormalStr,"^","S")
		s Unit=rs.Get("Unit")
		s Unit=##class(web.DHCPE.ReportGetInfor).Replace(Unit,"^","S")
		s Flag=rs.Get("Flag")
		
		s HighRiskFlag="N"
		i (Flag="PL")||(Flag="PH")||(Flag="S") s HighRiskFlag="Y"
		i Flag'="" s IsNormal=0
		i DoctorId="" s DoctorId=AuditUser
		s Sequence=rs.Get("Sequence")
		i Sequence'="" s ResultSort=Sequence
		s PLIST(2)=admId
		s PLIST(3)=arcItemId
		s PLIST(4)=ItemID
		s PLIST(5)=labResult
		s PLIST(6)=DoctorId
		s PLIST(7)=AuditDate
		s PLIST(8)=IsNormal
		s PLIST(11)=OEIId
		s PLIST(13)=AuditTime
		s PLIST(14)=HighRiskFlag
		s PLIST(16)=ResultSort
		s PLIST(17)=AuditUser
		s RLTID=$O(^DHCPERLT(0,"ADMOD",admId,OEIId,ItemID,0))
		i RLTID="" d
		.&SQL(Insert into sqluser.DHC_PE_Result values:PLIST())
		e  d
		.&SQL(update sqluser.DHC_PE_Result values :PLIST() where RLT_RowID=:RLTID)
		i SQLCODE=0 d
		.s RLTID=%ROWID
		.s ^DHCPEDataEx("DHCPEResult",RLTID,"Ranges")=NormalStr
		.s ^DHCPEDataEx("DHCPEResult",RLTID,"Unit")=Unit
		.s ^DHCPEDataEx("DHCPEResult",RLTID,"HLFlag")=Flag
		.s ^DHCPEDataEx("DHCPEResult",RLTID,"Sync")=rs.Get("Sync")
		.;s SQLCODE=##class(web.DHCPE.HighRisk).GetHighRiskFlag(RLTID) 
		s ^DHCPEDataEx("DHC_PE_PreIOrdItem","PIOITranDateTime",ordItmId)=$h
		
	}
		
	Q ""
}

ClassMethod GetStatus(PAADM)
{
	s ostid=$g(^DHCPESetting("DHCPE","StationId_Other"))
	s OEOrder=0,sta=0
	f  s OEOrder=$O(^OEORD(0,"Adm",PAADM,OEOrder))  q:(OEOrder="")||(sta=2)  d
	.s OEOrdItem=0
	.f  s OEOrdItem=$O(^OEORD(OEOrder,"I",OEOrdItem))  q:(OEOrdItem="")||(sta=2)  d
	..s CurData=$G(^OEORD(OEOrder,"I",OEOrdItem,1))
	..Q:(""=CurData)
	..s ORIStat=$p(CurData,"^",13)
	..q:(ORIStat=4)
	..Quit:$d(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OEOrder_"||"_OEOrdItem))
	..s ItemMastId=$p(CurData,"^",2)
	..s StationId=$o(^DHCPEST(0,"STORD_ARCIM",ItemMastId,0))
	..q:StationId=""
	..q:(StationId=ostid)
	..s:(sta'=1)&&('$d(^DHCPERLT(0,"OEORI",OEOrder_"||"_OEOrdItem))) sta=3
	..s:(sta'=3)&&($d(^DHCPERLT(0,"OEORI",OEOrder_"||"_OEOrdItem))) sta=1
	..s:(sta=1)&&('$d(^DHCPERLT(0,"OEORI",OEOrder_"||"_OEOrdItem))) sta=2
	..s:(sta=3)&&($d(^DHCPERLT(0,"OEORI",OEOrder_"||"_OEOrdItem))) sta=2
	s ^DHCPEDataEx("TransResult",PAADM,"S")=sta
 	s ^DHCPEDataEx("TransResult",PAADM)=$h
	q sta
}

ClassMethod GetResultCount(OEID)
{
	//w ##class(web.DHCPE.TransResult).GetResultCount("5899667||22")
	s Count=0
	s ResultID=""
	s Job=$J
	k ^TempDHCPETransResult(Job,"Desc",OEID)
	f  s ResultID=$O(^DHCPERLT(0,"OEORI",OEID,ResultID)) q:ResultID=""  d
	.s ODID=$P(^DHCPERLT(ResultID),"^",3)
	.s ODDesc=$P($g(^DHCPEST(+ODID,"OD",$P(ODID,"||",2))),"^",1)
	.q:$D(^TempDHCPETransResult(Job,"Desc",OEID,ODDesc))
	.s ^TempDHCPETransResult(Job,"Desc",OEID,ODDesc)=""
	.s Count=Count+1
	k ^TempDHCPETransResult(Job,"Desc",OEID)
	q Count
}

}
