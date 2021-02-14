/// 体检发证管理
Class web.DHCPE.CardManager Extends %RegisteredObject
{

ClassMethod Save(PAADM, Conclusion, Suggestions)
{
	s ret=##class(web.DHCPE.ResultDiagnosis).UpdateStationS(PAADM,0,"")
	s SSID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAADM)
	q:SSID="" "没有总检记录"
	
	s ret=##class(web.DHCPE.ResultDiagnosis).AuditStationS(PAADM,"Submit",0,"N")
	q:ret'=0 "总检审核失败"
	
	
	s Str=Conclusion_"^"_""_"^"_Suggestions_"^"_""_"^"_""_"^"_""
	s ^wrz=Str
	//var UserID=#(UserID)#;
	s ret=##class(web.DHCPE.GeneralSummarizeEx).Save(SSID,Str)
	i ret>0 q 0
	q ret
}

/// w ##class(web.DHCPE.CardManager).UpdateResult("1251383",2502)
ClassMethod UpdateResult(PAADM, DocID)
{
	s OEOrdID=$O(^OEORD(0,"Adm",PAADM,0))
	q:OEOrdID="" "NoOrd"
	s CheckDate=+$H
	s ItemSub=0
	f  s ItemSub=$O(^OEORD(OEOrdID,"I",ItemSub)) q:ItemSub=""  d
	.s Stat=$P(^OEORD(OEOrdID,"I",ItemSub,1),"^",13)
	.q:Stat="4"
	.s ArcItemID=$P(^OEORD(OEOrdID,"I",ItemSub,1),"^",2)
	.s StationID=$o(^DHCPEST(0,"STORD_ARCIM",ArcItemID,0))
	.q:StationID=""
	.;s Flag=$G(^DHCPEDataEx("ChartAssign",DocID,LocID,GroupID,"Write",StationID))
	.;q:Flag'="Y"
	.s OEID=OEOrdID_"||"_ItemSub
	.b ;OEID
	.q:$D(^DHCPERLT(0,"OEORI",OEID))
	.s ResultStr=##class(web.DHCPE.DoctorBatchRecord).GetDefaultResult(OEID)
	.q:ResultStr=""
	.s Ret=##class(web.DHCPE.ResultNew).SaveResult(ResultStr,DocID,"",CheckDate)
	q "Over"
}

ClassMethod UpdateOneResult(ResultID, Result, Normal)
{
	&SQL(Update Sqluser.DHC_PE_Result set RLT_Result=:Result,RLT_Normal=:Normal where RLT_RowID=:ResultID)
}

ClassMethod GetODTemplate(ResultID, IsNormal)
{
	s ODID=$P(^DHCPERLT(ResultID),"^",3)
	q:ODID="" ""
	s ret=""
	s StandSub=0
	f  s StandSub=$O(^DHCPEST(+ODID,"OD",$P(ODID,"||",2),"ODS",StandSub)) q:StandSub=""  d
	.s NormalFlag=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2),"ODS",StandSub),"^","6")
	.q:(NormalFlag="Y")&&(IsNormal="0")
	.q:(NormalFlag="N")&&(IsNormal="1")
	.s ret=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2),"ODS",StandSub),"^","2")
	q ret
}

// w ##class(web.DHCPE.CardManager).GetResultInfo(1256108)

ClassMethod GetResultInfo(PAADM)
{
	s ret=""
	s OEID=""
	f  s OEID=$O(^DHCPERLT(0,"ADMOD",PAADM,OEID),-1) q:OEID=""  d
	.s ArcimID=$P(^OEORD(+OEID,"I",$P(OEID,"||",2),1),"^",2)
	.b ;ArcimID
	.q:ArcimID'="2185||1"
	.s ODID=$O(^DHCPERLT(0,"ADMOD",PAADM,OEID,""))
	.q:ODID=""
	.s ResultID=$O(^DHCPERLT(0,"ADMOD",PAADM,OEID,ODID,0))
	.s Result=$P(^DHCPERLT(ResultID),"^",4)
	.s Range=$G(^DHCPEDataEx("DHCPEResult",ResultID,"Ranges"))
	.s ODUnit=$G(^DHCPEDataEx("DHCPEResult",ResultID,"Unit"))
	.s Arrow=##class(web.DHCPE.TransResult).GetLabResultArrowNew(ResultID)
	.s TSInfo=""
	.s:Arrow=2 TSInfo="偏高"
	.s:Arrow=0 TSInfo="偏低"
	.s ret=TSInfo_"^"_Result_"^"_ODUnit_"^"_Range
	q ret
}

ClassMethod GetBaseInfo(PAADM)
{
	s AdmId=$o(^DHCPEIADM(0,"PAADM",PAADM,0))
	s AdmId=$p($g(^DHCPEIADM(AdmId)),"^",4)
	q ##class(web.DHCPE.PrintNewDirect).GetPatBaseInfo(AdmId)
}

// w ##class(web.DHCPE.CardManager).GetReportInfo(1199860)

ClassMethod GetReportInfo(PAADM)
{
	s SSID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAADM)
	q:SSID="" "-1^没有总检信息"
	s AuditUser=$p(^DHCPEGS(SSID,1),"^",5)
	q:AuditUser="" "-1^总检没有审核,不能打印"
	b ;AuditUser
	s GSEXID=$O(^User.DHCPEGeneralSummarizeExI("GeneralSummarizeID",SSID,0))
	q:GSEXID="" "-1^健康证保存数据失败,不能打印,重新保存"
	s Flag=0  //判断是否可以打印，0不能打印
	i GSEXID'="" d
	.s Conclusion=$LG(^User.DHCPEGeneralSummarizeExD(GSEXID),3)
	.q:Conclusion=""
	.s Level=$LG(^User.DHCPEConclusionD(Conclusion),7)
	.s:Level=0 Flag=1
	q:Flag=0 "-2^健康情况不合格，不能打印"
	i $D(^DHCPEDataEx("CardNo",PAADM)) d
	.s CardNo=$G(^DHCPEDataEx("CardNo",PAADM))
	e  d
	.s VIPLevel=+##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PAADM)
	.s Year=+$ZD(+$H,"3")
	.s CardNo=$I(^DHCPEDataEx("CardNo","SortNum",Year))
	.s CardNo=$E("000000",0,6-$L(CardNo))_CardNo
	.s ^DHCPEDataEx("CardNo",PAADM)=CardNo
	.s ^DHCPEDataEx("CardNoIndex",CardNo)=PAADM
	s obj=##class(User.PAAdm).%OpenId(PAADM)
	s PatID=obj.PAADMPAPMIDRGetObjectId()
	s PhotoFTP=$G(^DHCPESetting("DHCPE","PhotoFTP"))
	s IP=$P(PhotoFTP,"^",1)
	s User=$P(PhotoFTP,"^",2)
	s PassWord=$P(PhotoFTP,"^",3)
	s Port=$P(PhotoFTP,"^",4)
	s Dir=$P(PhotoFTP,"^",5)
	s File=Dir_"/"_PatID_".jpg"
	s Flag=##class(web.DHCPE.FTPManager).FTPFileExit(IP,User,PassWord,Port,File)
	q:Flag="0" "-1^没有照片不能打印"
	s Name=obj.PAADMPAPMIDR.PAPMIName
	s Sex=obj.PAADMPAPMIDR.PAPMISexDR.CTSEXDesc
	s Dob=obj.PAADMPAPMIDR.PAPMIDOB
	s:Dob'="" Dob=+##class(web.DHCLCNUREXCUTE).CalAge(Dob,+$H)
	s RegNo=obj.PAADMPAPMIDR.PAPMINo
	q PatID_"^"_Name_"^"_Sex_"^"_Dob_"^"_RegNo_"^"_CardNo
}

/// 通过证件号码，获取就诊ID
ClassMethod GetPAADMByZJNo(ZJNo)
{
	q:ZJNo="" ""
	s PAADM=$G(^DHCPEDataEx("CardNoIndex",ZJNo))
	q:PAADM="" ""
	s obj=##class(User.PAAdm).%OpenId(PAADM)
	s RegNo=obj.PAADMPAPMIDR.PAPMINo
	q RegNo_"^"_PAADM
}

}
