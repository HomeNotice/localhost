Class web.DHCPE.AdmRecordManager Extends %Persistent
{

ClassMethod Insert(PreADM, AdmType, Type, User, Remark)
{
	;d ##class(web.DHCPE.AdmRecordManager).Insert(78,"P","PRE","1","备注")
	;AdmType  P;DHCPEPreIADM  I;DHCPEIADM  A:PAADM
	s obj=##class(User.DHCPEAdmRecordManager).%New()
	i AdmType="I" d
	.s PreADM=$P(^DHCPEIADM(PreADM),"^",4)
	i AdmType="A" d
	.s PreADM=$O(^DHCPEIADM(0,"PAADM",PreADM,0))
	.q:PreADM=""
	.s PreADM=$P(^DHCPEIADM(PreADM),"^",4)
	q:PreADM=""
	d obj.ARMADMDRSetObjectId(PreADM)
	s CurStatus=$P(^DHCPEPreIADM(PreADM),"^",8)
	s:User="" User=%session.Get("LOGON.USERID")
	
	i ("Cashier"=Type)&&(CurStatus'="ARRIVED") d ##class(web.DHCPE.NetPre.GetPreInfo).UpdateChargedStatus(PreADM,"4")
	i Type="Arrived" d 
	.d ##class(web.DHCPE.NetPre.GetPreInfo).UpdateChargedStatus(PreADM,"5")
	.;d ##class(web.DHCPE.ItemDetailRecord).InsertByAdm(PreADM,User)
	i Type="CANCELPE" d ##class(web.DHCPE.NetPre.GetPreInfo).UpdateChargedStatus(PreADM,"6")
	;s User=1
	s obj.ARMUser=User
	s obj.ARMDate=+$H
	s obj.ARMTime=$P($H,",",2)
	s obj.ARMType=Type
	s obj.ARMRemark=Remark
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		s LocID=$P(^DHCPEPreIADM(PreADM),"^",26)
		i Type="PrintDJD" d
		.s ArriveFlag=$p(^DHCPESetting("DHCPE","AutoArrived",LocID),"^",4)
		.i ArriveFlag="Y" d
		..d ##class(web.DHCPE.DHCPEIAdm).IAdmArrived(PreADM)
		
		s IADM=$O(^DHCPEIADM(0,"CRMADM",PreADM,0))
		s PAADM=""
		i IADM'="" d
		.s PAADM=$P(^DHCPEIADM(IADM),"^",1)
		s MainDoctorGroup=$G(^DHCPESetting("DHCPE","MainDoctorGroup",LocID))
		i MainDoctorGroup="Y" d  //使用复检
		.i Type="GMainAuditStationS" d  //复检提交
		..d:PAADM'="" ##class(web.DHCPE.ReportExportPDF).AuditReport(PAADM)
		.i Type="CaccelGMainAuditStationS" d
		..d:PAADM'="" ##class(web.DHCPE.ReportExportPDF).CancelReport(PAADM)
		e  d
		.i Type="GAuditStationS" d
		..d:PAADM'="" ##class(web.DHCPE.ReportExportPDF).AuditReport(PAADM)
		.i Type="CaccelGAuditStationS" d
		..d:PAADM'="" ##class(web.DHCPE.ReportExportPDF).CancelReport(PAADM)
		q obj.%Id()
	}
}

ClassMethod GetAdmRecordReMarkInfo(AdmId As %String = "")
{

 	s Info=""
 	//s Info="<font color=red>"
 	s NoAppInfo=##class(web.DHCPE.ResultEdit).GetUnAppedItems("",AdmId)
 	s NoAppInfo=$P(NoAppInfo,"^",2)
 	i NoAppInfo="" s NoAppInfo="无"
 	i NoAppInfo'="" s Info=Info_"未执行项目:"_NoAppInfo
 	s RefuseInfo=##class(web.DHCPE.ResultEdit).GetRefuseItems(AdmId)
 	i RefuseInfo="" s RefuseInfo="无"
 	i RefuseInfo'="" s Info=Info_$C(13)_"谢绝检查项目:"_RefuseInfo
 	//i RefuseInfo'="" s Info=Info_"<br>谢绝检查项目:"_RefuseInfo
 	s CurRoomInfo=##class(web.DHCPE.RoomManager).GetAdmCurRoom(AdmId,"ADM","Desc")
 	s Person=$P(CurRoomInfo,"^",2)
	s Name=$P(CurRoomInfo,"^",3)
	s CurRoomInfo=$P(CurRoomInfo,"^",1)
	s CurRoomInfo="'"_Name_"'在'"_CurRoomInfo_"'处候诊,是第'"_Person_"'位"
 	//i CurRoomInfo'="" s Info=Info_"<br>当前排队诊室:"_CurRoomInfo
 	i CurRoomInfo'="" s Info=Info_$C(13)_"当前排队诊室:"_CurRoomInfo
 	//s Info=Info_"<font>"
 	q Info
}

Query FindAdmRecord(AdmId As %String = "") As %Query(ROWSPEC = "TID:%String,TDate:%String,TTime:%String,TType:%String,TRemark:%String,TUser:%String")
{
}

ClassMethod FindAdmRecordExecute(ByRef qHandle As %Binary, AdmId As %String = "") As %Status
{
	
	;d ##class(%ResultSet).RunQuery("web.DHCPE.AdmRecordManager", "FindAdmRecord",552)
	Set repid=$I(^CacheTemp)
 	s ind=1
 	//w Info,!
 	s PreADM=$O(^DHCPEIADM(0,"PAADM",AdmId,0))
 	s PreADM=$P(^DHCPEIADM(PreADM),"^",4)
 	s id=0
	f  s id=$o(^User.DHCPEAdmRecordManagerI("AdmIndex",PreADM,id)) q:id=""  d
	.s Date=$LG(^User.DHCPEAdmRecordManagerD(id),3)
	.s TDate=##class(websys.Conversions).DateLogicalToHtml(Date)
	.s Time=$LG(^User.DHCPEAdmRecordManagerD(id),5)
	.s TTime=##class(websys.Conversions).TimeLogicalToHtml(Time)
	.s Type=$LG(^User.DHCPEAdmRecordManagerD(id),6)
	.s Remark=$LG(^User.DHCPEAdmRecordManagerD(id),4)
	.s TType=..GetRecordTypeDesc(Type)
	.s TRemark=..GetRemarkDesc(Type,Remark)
	.s User=$LG(^User.DHCPEAdmRecordManagerD(id),7)
	.s TUser=$P(^SSU("SSUSR",User),"^",2)
	.d FindAdmRecordBuild	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindAdmRecordBuild      
	set Data=$lb(id,TDate,TTime,TType,TRemark,TUser)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindAdmRecordFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindAdmRecordExecute ]
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

ClassMethod FindAdmRecordClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindAdmRecordExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod GetBaseInfo(IADM)
{
	;##class(web.DHCPE.AdmRecordManager).GetBaseInfo()
	s PapmiId=+^PAADM(IADM)
	s HIADM=$O(^DHCPEIADM(0,"PAADM",IADM,0))
	i HIADM'="" d
	.s PIADM=$P(^DHCPEIADM(HIADM),"^",4)
	.s GIADM=$P(^DHCPEPreIADM(PIADM),"^",2)
	.i GIADM'="" d
	..s GBID=$P(^DHCPEPreGADM(GIADM),"^",1)
	..s Group=$P(^DHCPEPreGBI(GBID),"^",2)
	.e  d
	..s Group=""
    e  d
    .s Group=""
    .s PIADM=""
    // 登记号 PA_PatMas.{PAPMI_IPNo}
    s RegNo=$p($g(^PAPER(PapmiId,"PAT",1)),"^",1)
	
    // 患者姓名 PA_PatMas.{PAPMI_Name}
    s PatName=$p($g(^PAPER(PapmiId,"ALL")),"^",1)
    
    
    // 性别 PA_PatMas.{PAPMI_Sex_DR}(CT_Sex)
    s Sex=$p($g(^PAPER(PapmiId,"ALL")),"^",7)
    s:Sex'="" Sex=$p($g(^CT("SEX",Sex)),"^",2)
    
    //年龄 PA_PatMas.{PAPMI_DOB}
	s Birth=$p($g(^PAPER(PapmiId,"ALL")),"^",6)
	S:Birth'="" Birth=##class(websys.Conversions).DateLogicalToHtml(Birth)

	s IDCard=$p($g(^PAPER(PapmiId,"PAT",3)),"^",6)
	s DocTel=""
	s DetailCode="040028"
	s DetailID=$O(^DHCPEST(0,"OD_Code",DetailCode,0))
	i DetailID'="" d
	.s Sub=0
	.s Sub=$O(^DHCPEST(0,"OD_Code",DetailCode,DetailID,0))
	.s DetailID=DetailID_"||"_Sub
	.s RLTID=$O(^DHCPERLT(0,"PAADM_OD",IADM,DetailID,0))
	.q:RLTID=""
	.s DocTel=$P(^DHCPERLT(RLTID),"^",4)
	s Tel=""
	i DocTel="" d
	.i PIADM'="" d
	..s Tel=##class(web.DHCPE.PreCommon).GetTelNo("PIADM",PIADM)
	.e  d
	..s Tel=$p($g(^PAPER(PapmiId,"PER",1)),"^",11)
	e  d
	.s Tel=DocTel
	q PatName_"^"_Sex_"^"_Birth_"^"_IDCard_"^"_RegNo_"^"_Tel_"^"_Group_"^"_PapmiId
}

ClassMethod GetRecordTypeDesc(Type)
{
	;w ##class(web.DHCPE.AdmRecordManager).GetRecordTypeDesc("Cashier")
	q:Type="PREInsert" "预约"
	q:Type="Register" "登记"
	q:Type="PrintDJD" "打印导检单"
	q:Type="PrintBar" "打印条码"
	q:Type="SpecCollect" "采集标本"
	q:Type="Arrived" "到达"
	q:Type="CancelArrived" "取消到达"
	q:Type="DeleteItem" "删除项目"
	q:Type="Cashier" "收费"
	q:Type="DropInvPrt" "退费"
	q:Type="AuditStationS" "科室提交"
	q:Type="CaccelAuditStationS" "科室取消提交"
	q:Type="GAuditStationS" "总检提交"
	q:Type="CaccelGAuditStationS" "总检取消提交"
	q:Type="GMainAuditStationS" "复检提交"
	q:Type="CaccelGMainAuditStationS" "复检取消提交"
	q:Type="ReportStatus" "修改报告状态"
	q:Type="RecPaper" "收表"
	q:Type="FetchReport" "取报告"
	q:Type="SendAudit" "送总检"
	q:Type="Complete" "报告完成"
	q:Type="RC" "完成检查"
	q:Type="CacleSendAudit" "取消完成检查"
	q:Type="CRefuseCheck" "取消放弃检查"
	q:Type="RefuseCheck" "放弃检查"
	q:Type="CANCELPE" "取消体检"
	q:Type="PEResult" "保存结果"
	q ""
}

ClassMethod GetRemarkDesc(Type, Remark)
{
	;w ##class(web.DHCPE.AdmRecordManager).GetRemarkDesc("Cashier","285")
	q:Remark="" ""
	i Type="SpecCollect" d
	.s Remark="标本号:"_Remark
	e  i Type="DeleteItem" d
	.s ArcIMID=$P(^DHCPEPreIADM(+Remark,"ORDITEM",$P(Remark,"||",2)),"^",1)
	.s ItemDesc=$P(^ARCIM(+ArcIMID,$P(ArcIMID,"||",2),1),"^",2)
	.s Remark="项目:"_ItemDesc
	e  i Type="Cashier" d
	.s Remark=$P(^DHCPEINVPRT(Remark),"^",1)
	.s Remark="发票号:"_Remark
	e  i Type="DropInvPrt" d
	.s Remark=$P(^DHCPEINVPRT(Remark),"^",1)
	.s Remark="发票号:"_Remark
	e  i Type="AuditStationS" d
	.s Remark=$P(^DHCPEST(Remark),"^",2)
	e  i Type="CaccelAuditStationS" d
	.s Remark=$P(^DHCPEST(Remark),"^",2)
	e  i Type="ReportStatus" d
	.i Remark="S" d
	..s Remark="发送"
	.e  i Remark="A" d
	..s Remark="审核"
	.e  i Remark="P" d
	..s Remark="打印"
	e  i Type="RC" d  //科室确认
	.i Remark'="" s Remark=$LG(^User.DHCPEAreaD(+Remark,"ChildRoom",$P(Remark,"||",2)),3)
	.s Remark=Remark_"科室确认"
	e  i (Type="CRefuseCheck")||(Type="RefuseCheck") d  //放弃检查
	.i Remark'="" d
	..s Remark=$p(^OEORD($P(Remark,"||",1),"I",$p(Remark,"||",2),1),"^",2)
	..s:Remark'="" Remark=##class(web.DHCPE.DHCPECommon).GetArcDesc(Remark)
	.s Remark="项目:"_Remark
	e  i Type="PEResult" d
	.i Remark'="" d
	..s Remark=$p(^OEORD($P(Remark,"||",1),"I",$p(Remark,"||",2),1),"^",2)
	..s:Remark'="" Remark=##class(web.DHCPE.DHCPECommon).GetArcDesc(Remark)
	.s Remark="项目:"_Remark
	
	q Remark
}

Storage Default
{
<Data name="AdmRecordManagerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.AdmRecordManagerD</DataLocation>
<DefaultData>AdmRecordManagerDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.AdmRecordManagerD</IdLocation>
<IndexLocation>^web.DHCPE.AdmRecordManagerI</IndexLocation>
<StreamLocation>^web.DHCPE.AdmRecordManagerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
