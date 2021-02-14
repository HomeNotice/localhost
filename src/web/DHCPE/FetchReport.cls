Class web.DHCPE.FetchReport Extends %Persistent
{

/// w ##class(web.DHCPE.FetchReport).UserAddBackToSpecial("32051||1")
ClassMethod UserAddBackToSpecial(arcid)
{
	;select * from arc_itmmast where ARCIM_Desc like '%C14尿素呼气试验%'	;20515||1
	;select * from arc_itmmast where ARCIM_Desc like '%乳腺超声检查(特需)%' ;22219||1
	s ArcItmId=""
	f  s ArcItmId=$O(^DHCPEDataEx("DHCPEStationOrder","SignItem",ArcItmId)) q:ArcItmId=""  d
	.q:$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ArcItmId))'="Y"
	.q:(""'=arcid)&(arcid'=ArcItmId)
	.w !,"go"
	.s RltId=0
	.f  s RltId=$O(^DHCPERLT(0,"ARCIM",ArcItmId,RltId)) q:RltId=""  d
	..s (CurInfo,BtnUser)=""
	..s CurInfo=$G(^DHCPERLT(RltId))
	..s BtnComDate=$P(CurInfo,"^",6)
	..;q:63134'=BtnComDate
	..s Result=$P(CurInfo,"^",4)
	..;q:"临床诊断:;检查所见:;诊断意见:详见报告"'=Result
	..s paadmid=$P(CurInfo,"^",1)
	..s patmasid=$P(^PAADM(paadmid),"^",1)
	..s patname=$P(^PAPER(patmasid,"ALL"),"^",1)
	..s arcdesc=$P(^ARCIM(+ArcItmId,$P(ArcItmId,"||",2),1),"^",2)
	..s OeOriId=$P(CurInfo,"^",9)
	..s OeOriStatus=$P(^OEORD(+OeOriId,"I",$P(OeOriId,"||",2),1),"^",13)
	..w !,patname_" "_arcdesc_" "_OeOriStatus
	..w !,"Status"_" "_OeOriStatus
	..q:6'=OeOriStatus
	..s BtnUser=+$P(CurInfo,"^",5)
	..q:BtnUser=""
	..s user=$g(^DHCPESpecial("DHCPE","UserID",OeOriId))
	..i user="" d
	...s ^DHCPESpecial("DHCPE","UserID",OeOriId)=BtnUser
	...s arcdesc="OK"_arcdesc
	..e  d
	...s arcdesc="History"_arcdesc
	..s username=$p($g(^SSU("SSUSR",BtnUser)),"^",2)
	..w !,patname_" "_arcdesc_" "_username_" "_$zd(BtnComDate,3)
	q 0
}

ClassMethod FetchReportByHPNo(HPNo, NewStatus As %String = "S")
{
	;d ##class(web.DHCPE.FetchReport).FetchReport("40693660")
	s HPNo=$ZCVT(HPNo,"U")
	s PIADM=$O(^DHCPEPreIADM(0,"HPNo",HPNo,0))
	q:PIADM="" "-1^体检号不存在"
	//s PIADM=$P(PIADM,"^",2)
	s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADM,0))
	q:IADM="" "-1^没有到达"
	s RPTID=$O(^DHCPERPT(0,"IADM",IADM,0))
	b ;
	q:RPTID="" "-1^没有报告"
	s Status=$P(^DHCPERPT(RPTID),"^",2)
	q:Status="NA" "-1^报告没有审核"
	q:Status="A" "-1^报告没有打印"
	q:((Status="C")||(Status="S"))&&(NewStatus="C") "-1^报告已经扫描过"
	q:(Status="S")&&(NewStatus="S") "-1^报告已经取走"
	s InStr=RPTID_"^"_NewStatus_"^"
	b ;InStr
	s ret=##class(web.DHCPE.Report).SetReportStatus("","",InStr)
	
	i ret=0{
		s UserID=%session.Get("LOGON.USERID")
		s DetailType="Complete"
		i NewStatus="S" s DetailType="FetchReport"
		d ##class(web.DHCPE.AdmRecordManager).Insert(PIADM,"P",DetailType,UserID,"")
		q "0^OVER"
		
	}
	q "-1^没有更新成功"_ret
}

/// Date：Add By WZH ON 20201110
/// 根据登记号查询患者所有可以取报告的记录
/// return：HPNo
ClassMethod GetCanFetchReportRecord(RegNo, NewStatus As %String = "S")
{
	i RegNo'="" s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo) 
	q:('($L(RegNo)>0)) "-1^请输入正确的登记号"
	s PIBI=$o(^DHCPEPreIBI(0,"PAPMINo",RegNo,0))
	q:PIBI="" "_1^无该人员的基本信息!"
	s HPNoStr=""
	s PIADM="",PIADMStr="" 
	f  s PIADM=$o(^DHCPEPreIADM(0,"PIBI",PIBI,PIADM),-1) q:(PIADM="")  d
	.s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PIADM) 
    .q:LocFlag=1 
	.s PIADMStutas=$P(^DHCPEPreIADM(PIADM),"^", 8)
	.q:"ARRIVED"'=PIADMStutas
	.s ReCheck=$P(^DHCPEPreIADM(PIADM),"^", 28)
	.;q:ReCheck="Y"
	.s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADM,0))
	.q:IADM="" ;"-1^没有到达"
	.s RPTID=$O(^DHCPERPT(0,"IADM",IADM,0))
	.q:RPTID="" ;"-1^没有报告"
	.;判断是否总检
	.s PAADM=$P(^DHCPEIADM(IADM),"^",1)
	.s SSID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAADM)
	.q:SSID="" ;"-1^没有总检记录"
	.s SSStatus=$p($G(^DHCPEGS(SSID,1)),"^",5)
	.q:SSStatus="" ;"-1^总检还未审核"
	.s LocID=$P(^DHCPEPreIADM(PIADM),"^",26)
	.s MainDoctorFlag=$G(^DHCPESetting("DHCPE","MainDoctorGroup",LocID))
	.q:(MainDoctorFlag="Y")&&('$D(^DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",PAADM))) ;"-1^复检还未审核"
	.q:Status="NA" ;"-1^报告没有审核"
	.q:Status="A" ;"-1^报告没有打印"
	.q:(Status="C")&&(NewStatus="C") ;"-1^报告已经完成"
	.q:(Status="S")&&(NewStatus="C") ;"-1^报告已经取走"
	.q:(Status="S")&&(NewStatus="S") ;"-1^报告已经取走"
	.s HPNo=$P(^DHCPEPreIADM(PIADM),"^",27) ;体检号
	.i HPNoStr=""  d
	..s HPNoStr=HPNo
	.e  d
	..s HPNoStr=HPNoStr_"^"_HPNo
	
	q HPNoStr
}

ClassMethod FetchReport(RegNo, NewStatus As %String = "S")
{
	;d ##class(web.DHCPE.FetchReport).FetchReport("40693660")
	s PIADM=##class(web.DHCPE.DHCPEIAdm).GetPIADMByRegNo(RegNo)
	s Flag=$P(PIADM,"^",1)
	q:Flag'=0 PIADM
	s PIADM=$P(PIADM,"^",2)
	q:PIADM="" "-1^没有预约"
	s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADM,0))
	q:IADM="" "-1^没有到达"
	s RPTID=$O(^DHCPERPT(0,"IADM",IADM,0))
	q:RPTID="" "-1^没有报告"
	//判断是否总检
	s PAADM=$P(^DHCPEIADM(IADM),"^",1)
	s SSID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAADM)
	q:SSID="" "-1^没有总检记录"
	s SSStatus=$p($G(^DHCPEGS(SSID,1)),"^",5)
	q:SSStatus="" "-1^总检还未审核"
	s LocID=$P(^DHCPEPreIADM(PIADM),"^",26)
	s MainDoctorFlag=$G(^DHCPESetting("DHCPE","MainDoctorGroup",LocID))
	q:(MainDoctorFlag="Y")&&('$D(^DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",PAADM))) "-1^复检还未审核"
	//End
	s Status=$P(^DHCPERPT(RPTID),"^",2)
	q:Status="NA" "-1^报告没有审核"
	q:Status="A" "-1^报告没有打印"
	/*
	q:(Status="C")&&(NewStatus="C") "-1^报告已经完成,状态为"_Status
	q:(Status="S")&&(NewStatus="C") "-1^报告已经取走,状态为"_Status
	q:(Status="S")&&(NewStatus="S") "-1^报告已经取走,状态为"_Status
	;q:(Status="P")&&(NewStatus="S") "-1^报告还未完成"_Status
	*/
	q:(Status="C")&&(NewStatus="C") "-1^报告已经完成"
	q:(Status="S")&&(NewStatus="C") "-1^报告已经取走"
	q:(Status="S")&&(NewStatus="S") "-1^报告已经取走"

	s InStr=RPTID_"^"_NewStatus_"^"
	b ;InStr
	s ret=##class(web.DHCPE.Report).SetReportStatus("","",InStr)
	
	i ret=0{
		s UserID=%session.Get("LOGON.USERID")
		s DetailType="Complete"
		i NewStatus="S" s DetailType="FetchReport"
		d ##class(web.DHCPE.AdmRecordManager).Insert(PIADM,"P",DetailType,UserID,"")
		q "0^OVER"
		
	}
	q "-1^没有更新成功"_ret
}

ClassMethod CancelFetchReport(ID, CurStatus As %String = "S")
{
	q:ID="" ""
	s Status=$P(^DHCPERPT(ID),"^",2)
	i CurStatus="S"
	{
		q:Status'="S" "-1^报告不是已发送状态"
		s NewStatus="C"
		s CompleteDate=$P(^DHCPERPT(ID),"^",11)
		s:CompleteDate="" NewStatus="P"

		&sql(Update Sqluser.DHC_PE_Report set RPT_SendUser_DR=null,RPT_SendDate=null,RPT_SendTime=null,RPT_Status=:NewStatus where RPT_RowID=:ID)
	}
	else
	{
		q:Status'="C" "-1^报告不是已完成状态"
		&sql(Update Sqluser.DHC_PE_Report set RPT_CompleteDate=null,RPT_CompleteTime=null,RPT_CompleteUser_DR=null,RPT_Status='P' where RPT_RowID=:ID)
	}
	k ^DHCPEDataEx("FetchReport","Detail",ID)
	q SQLCODE_"^"_SQLCODE
}

ClassMethod CancelFetchButton(ID, CurStatus As %String = "S")
{
	q:ID="" ""
	s Status=$P(^DHCPERPT(ID),"^",2)
	q:Status'=CurStatus ""
	w "<button onclick=CancelFetch(this) id='"_ID_"'>撤销</button>"
}

ClassMethod GetContent(IFOLD, VIP)
{
	 S HOSPID=%session.Get("LOGON.HOSPID")
     S HospitalName=##class(web.DHCPE.DHCPECommon).GetHospitalName(HOSPID)
     I HospitalName["[" s HospitalName=$p(HospitalName,"[",1)

	s Contentstr="",ID=""
	i IFOLD'="" d
	.s ID=$O(^User.DHCPENewMessageTempletI("TypeDefaultIndex","老年短信",1,""))
	e  i VIP=2 d
	.s ID=$O(^User.DHCPENewMessageTempletI("TypeDefaultIndex","VIP短信",1,""))
	e  d
	.s ID=$O(^User.DHCPENewMessageTempletI("TypeDefaultIndex","普通短信",1,""))
	i ID'="" d
	.s Contentstr=$LG(^User.DHCPENewMessageTempletD(ID),4)
	e  d
	.;s Contentstr="尊敬的[Name]您好！这里是协和医院健康医学部。请您于周一至周五下午1:30-4:00前来九层领取体检报告(节假日除外)。咨询电话:69159840"
	.s Contentstr="尊敬的[Name]您好！这里是"_HospitalName_"。请您于周一至周五下午1:30-4:00前来九层领取体检报告(节假日除外)。咨询电话:69159840。"
	q Contentstr
}

ClassMethod Test(str, strs)
{
	s res=str_"hahaha"_strs
	q res
	q "a"
}

ClassMethod CacleSendAudit(vPAADM)
{
        ;s ^sxt("aaz")=vPAADM
		s PAADM=vPAADM
		s UserID=%session.Get("LOGON.USERID")
		;s User=%session.Get("LOGON.USERID")
		;s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
		;s PIADM=$P(^DHCPEIADM(IADM),"^",4)
		
		q:('$D(^User.DHCPESendAuditI("AdmIndex",PAADM))) "不存在记录"
		&sql(delete from sqluser.DHC_PE_SendAudit where SA_PAAdm_DR=:PAADM)
		i 'SQLCODE  d
		.d ##class(web.DHCPE.AdmRecordManager).Insert(PAADM,"A","CacleSendAudit",UserID,"")	
		q SQLCODE
}

ClassMethod SendAudit(RegNo, UserID, CheckFlag As %String = "0", vPAADM)
{
	s ID=""
	i vPAADM'="" s ID=$o(^User.DHCPEOtherPatientToHPI("OTHPAADMDRIndex",vPAADM,0))
	i ID'="" Q "-4^住院体检不需黏贴"
    I UserID="" s UserID=%session.Get("LOGON.USERID")
	i RegNo'=""
	{
		s PIADM=##class(web.DHCPE.DHCPEIAdm).GetPIADMByRegNo(RegNo)
		s Flag=$P(PIADM,"^",1)
		q:Flag'=0 PIADM_"^"
		s PIADM=$P(PIADM,"^",2)
		s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADM,0))
		q:IADM="" "-1^没有到达^"
		s PAADM=$P(^DHCPEIADM(IADM),"^",1)
	}
	else
	{
		s PAADM=vPAADM
		s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
		s PIADM=$P(^DHCPEIADM(IADM),"^",4)
	}
	q:$D(^User.DHCPESendAuditI("AdmIndex",PAADM)) "-1^已经粘贴，不需要再次粘贴^"
	
	//q:'$D(^DHCPEDataEx("ConfirmRecPaper",PIADM)) "-1^还未收表，不允许粘贴^"
	
	i CheckFlag="0"{
		s ConfirmRecPaper=""
		i '$D(^DHCPEDataEx("ConfirmRecPaper",PIADM)) d
		.s ConfirmRecPaper="此人还未收表"
		s UnDoItems=##class(web.DHCPE.ResultEdit).GetUnAppedItems("",PAADM)
		s UnDoItems=$P(UnDoItems,"^",2)
		i ConfirmRecPaper'="" d
		.i UnDoItems'="" d
		..s UnDoItems=ConfirmRecPaper_$C(13)_"未完成项目为"_$C(13)_UnDoItems
		e  d
		.s:UnDoItems'="" UnDoItems="未完成项目为"_$C(13)_UnDoItems
		i $D(^User.DHCPESendAuditI("AdmIndex",PAADM)){
			q "-2^"_UnDoItems
		}
		i UnDoItems'=""{
			q "-3^"_UnDoItems
		}
	}
	s obj=##class(User.DHCPESendAudit).%New()
	d obj.SAPAAdmDRSetObjectId(PAADM)
	s obj.SASendDate=+$H
	s obj.SASendTime=$P($H,",",2)
	d obj.SASendUserDRSetObjectId(UserID)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		d ##class(web.DHCPE.AdmRecordManager).Insert(PIADM,"P","SendAudit",UserID,"")
		//d ##class(web.DHCPE.HighRisk).GenAdmHighRisk(PAADM)
		q "0^"
	}
}

Query SearchFetchReport(StartDate As %String, EndDate As %String, RegNo As %String, HPNo As %String, NoFetchReport As %String = "", VIPLevel As %String = "", Name As %String = "", GroupID As %String = "", DepartName As %String = "") As %Query(ROWSPEC = "TRegNo:%String,TName:%String,TSex:%String,TAge:%String,TBirth:%String,TSendUser:%String,TSendDate:%String,TSendTime:%String,TReportStatus:%String,TAppDate:%String,TID:%String,TVIPLevel:%String,TGroupName:%String,THPNo:%String,TDepartName:%String")
{
}

ClassMethod SearchFetchReportExecute(ByRef qHandle As %Binary, StartDate As %String, EndDate As %String, RegNo As %String, HPNo As %String = "", NoFetchReport As %String = "", VIPLevel As %String = "", Name As %String = "", GroupID As %String = "", DepartName As %String = "") As %Status
{

	Set repid=$I(^CacheTemp)
	s Job=$J
	If $g(ind)="" Set ind=2000
	i StartDate="" s StartDate=##class(websys.Conversions).DateLogicalToHtml(+$h)
	i EndDate="" s EndDate=##class(websys.Conversions).DateLogicalToHtml(+$h) 

	i (StartDate="")&&(EndDate="")
	{
		Set qHandle=$lb(0,repid,0) 
		Quit $$$OK 
	}
	
	i StartDate'="" s StartDate=##class(websys.Conversions).DateHtmlToLogical(StartDate)
	i EndDate'="" s EndDate=##class(websys.Conversions).DateHtmlToLogical(EndDate) 
	

	i (StartDate>EndDate)
	{
		Set qHandle=$lb(0,repid,0) 
		Quit $$$OK 
	}
	//w "GroupID:"_GroupID
	i NoFetchReport'="" d
	.s NoFetchReport="Y"
	e  d
	.s NoFetchReport="N"
	s RecordNum=0
	s Date=EndDate+1
	i NoFetchReport="N"{
	f  s Date=$O(^DHCPERPT(0,"SendDate",Date),-1) q:(Date="")||(Date<StartDate)  d
	.s TSendDate=##class(websys.Conversions).DateLogicalToHtml(Date)
	.s Time=""
	.f  s Time=$O(^DHCPERPT(0,"SendDate",Date,Time),-1) q:(Time="")  d
	..s ReportID=0
	..f  s ReportID=$O(^DHCPERPT(0,"SendDate",Date,Time,ReportID)) q:(ReportID="")  d
	...d Clear
	...s IADM=$P(^DHCPERPT(ReportID),"^",1)
	...q:IADM=""
	...s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PEADM",IADM)   //add 2009-07-07 
    ...q:LocFlag=1 
	...s Status=$P(^DHCPERPT(ReportID),"^",2)
	...q:(Status'="S")
	...s PIADM=$P(^DHCPEIADM(IADM),"^",4)
	...s PAADM=$P(^DHCPEIADM(IADM),"^",1)
	...s CurVIPLevel=##class(web.DHCPE.PreCommon).GetVIPLevel("Pre",PIADM)
	...s THPNo=$P(^DHCPEPreIADM(PIADM),"^",27)
	...Q:(HPNo'="")&&(THPNo'=HPNo)
	...q:(VIPLevel'="")&&(VIPLevel'=+CurVIPLevel)
	...s TVIPLevel=$P(CurVIPLevel,"^",2)
	...s PreGAdm=$P(^DHCPEPreIADM(PIADM),"^",2)
	...q:(GroupID="ALLI")&&(PreGAdm'="")
	...q:(GroupID="ALLG")&&(PreGAdm="")
	...q:(GroupID'="")&&(PreGAdm'=GroupID)&&(GroupID'="ALLG")&&(GroupID'="ALLI")
	...i PreGAdm'="" d
	....s PreGBaseInfo=$P(^DHCPEPreGADM(PreGAdm),"^",1)
	....s TGroupName=$P(^DHCPEPreGBI(PreGBaseInfo),"^",2)
	...s TSendUser=$P(^DHCPERPT(ReportID),"^",8)
	...i TSendUser'="" s TSendUser=$P(^SSU("SSUSR",TSendUser),"^",2)
 	...s TSendTime=##class(websys.Conversions).TimeLogicalToHtml(Time)
 	...s TReportStatus=""
 	...s:Status="S" TReportStatus="已取"
 	...s TAppDate=$G(^DHCPEDataEx("DHCPEPreIADM","GetReportDateTime","I",PIADM))
 	...s:TAppDate'="" TAppDate=##class(websys.Conversions).DateLogicalToHtml(+TAppDate)
 	...s PIBIDR=$P(^DHCPEPreIADM(PIADM),"^",1)
 	...s TDepartName=##class(web.DHCPE.PreCommon).GetPosition("PreADM",PIADM)
 	...q:(DepartName'="")&&(TDepartName'[DepartName)
 	...d GetPersonInfo
	}else{
		//^DHCPEDataEx("DHCPEPreIADM","GetReportDateTime","I",KReportDate,KKTime,PIADM)
		//W "310"_$O(^DHCPEDataExi("DHCPEPreIADM","GetReportDateTime","I",Date))
		f  s Date=$O(^DHCPEDataExi("DHCPEPreIADM","GetReportDateTime","I",Date),-1) q:(Date="")||(Date<StartDate)  d
		.s TAppDate=##class(websys.Conversions).DateLogicalToHtml(Date)
		.s TSendDate=""
		.s TSendUser=""
		.s Time=""
		.f  s Time=$O(^DHCPEDataExi("DHCPEPreIADM","GetReportDateTime","I",Date,Time)) q:(Time="")  d
		..s PIADM=0
		..f  s PIADM=$O(^DHCPEDataExi("DHCPEPreIADM","GetReportDateTime","I",Date,Time,PIADM)) q:(PIADM="")  d
		...d Clear
		...s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PIADM)   //add 2009-07-07 
    	...q:LocFlag=1 
		...s THPNo=$P(^DHCPEPreIADM(PIADM),"^",27)
		...s Status=$P(^DHCPEPreIADM(PIADM),"^",8)
		...q:Status'="ARRIVED"
		...s CurVIPLevel=##class(web.DHCPE.PreCommon).GetVIPLevel("Pre",PIADM)
		...q:(VIPLevel'="")&&(VIPLevel'=+CurVIPLevel)
		...s TVIPLevel=$P(CurVIPLevel,"^",2)
		...s PreGAdm=$P(^DHCPEPreIADM(PIADM),"^",2)
		...q:(GroupID="ALLI")&&(PreGAdm'="")
		...q:(GroupID="ALLG")&&(PreGAdm="")
		...q:(GroupID'="")&&(PreGAdm'=GroupID)&&(GroupID'="ALLG")&&(GroupID'="ALLI")
		...i PreGAdm'="" d
		....s PreGBaseInfo=$P(^DHCPEPreGADM(PreGAdm),"^",1)
		....s TGroupName=$P(^DHCPEPreGBI(PreGBaseInfo),"^",2)
		...s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADM,0))
		...s ReportID=$O(^DHCPERPT(0,"IADM",IADM,0))
		...s Status=$P(^DHCPERPT(ReportID),"^",2)
		...q:(Status="S")
		...s ID=""
		...s PAADM=$P(^DHCPEIADM(IADM),"^",1)
		...s TReportStatus=##Class(web.DHCPE.Report).GetStatusDesc(Status,PAADM)_Status
		...s PIBIDR=$P(^DHCPEPreIADM(PIADM),"^",1)
		...//W PIBIDR
		...s TDepartName=##class(web.DHCPE.PreCommon).GetPosition("PreADM",PIADM)
 		...q:(DepartName'="")&&(TDepartName'[DepartName)
 	
		...d GetPersonInfo
	}
	//w "共"_RecordNum_"人"
	Set qHandle=$lb(0,repid,0) 
	Quit $$$OK
GetPersonInfo
    S PAPMI=$P($G(^PAADM(PAADM)),"^",1)
	s TRegNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",1)
	s TName=$p($g(^DHCPEPreIBI(PIBIDR)),"^",2)
	s SexDR=$p($g(^DHCPEPreIBI(PIBIDR)),"^",3)
	s TSex=$p($g(^CT("SEX",SexDR)),"^",2)
	s Birth=$p($g(^DHCPEPreIBI(PIBIDR)),"^",4) 
	s:Birth'="" TBirth=##class(websys.Conversions).DateLogicalToHtml(Birth)
	;s:Age'="" Age=$P(##class(web.DHCLCNUREXCUTE).CalAge(Birth,+$H),"Y",1) 
	s Age=##class(web.DHCBillInterface).GetPapmiAge(PAPMI,PAADM)
	s TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",6)
	s:TelNo="" TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",7)
	s:TelNo="" TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",8)
	d OutPut
	q
Clear
	s (TRegNo,TName,TSex,Age,TBirth,TSendUser,TSendTime,TReportStatus,TAppDate,TVIPLevel,TGroupName,THPNo,TDepartName)=""
	q 
OutPut
	q:(Name'="")&&(TName'[Name)
	s RecordNum=RecordNum+1
	set Data=$lb(TRegNo,TName,TSex,Age,TBirth,TSendUser,TSendDate,TSendTime,TReportStatus,TAppDate,ReportID,TVIPLevel,TGroupName,THPNo,TDepartName)  
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SearchFetchReportFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SearchFetchReportExecute ]
{
	
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else{			
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind) 
	Quit $$$OK
}

ClassMethod SearchFetchReportClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SearchFetchReportExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query SearchCmopleteReport(StartDate As %String, EndDate As %String, RegNo As %String, NoFetchReport As %String = "", HadSendMessage As %String = "", IFOLD As %String = "", VIPLevel As %String = "", Name As %String = "", GroupID As %String = "", GroupName As %String = "") As %Query(ROWSPEC = "TRegNo:%String,TName:%String,TSex:%String,TBirth:%String,TSendUser:%String,TSendDate:%String,TSendTime:%String,TReportStatus:%String,TAppDate:%String,TTel:%String,THadSendMessage:%String,TSendMessage:%String,TID:%String,TVIPLevel:%String,RptPrtDate:%String,TGroupName:%String,TMessageDate:%String")
{
}

ClassMethod SearchCmopleteReportExecute(ByRef qHandle As %Binary, StartDate As %String, EndDate As %String, RegNo As %String, NoFetchReport As %String = "", HadSendMessage As %String = "", IFOLD As %String = "", VIPLevel As %String = "", Name As %String = "", GroupID As %String = "", GroupName As %String = "") As %Status
{


	;s ^tempdhcpe("CmopleteReport")="StartDate"_StartDate_"  EndDate"_EndDate_"   RegNo"_RegNo_"   NoFetchReport"_NoFetchReport_"  HadSendMessage"_HadSendMessage_"  IFOLD"_IFOLD_"  VIPLevel"_VIPLevel
	Set repid=$I(^CacheTemp)
	s Job=$J
	s ind=1
	
	i StartDate'="" s StartDate=##class(websys.Conversions).DateHtmlToLogical(StartDate) 
	i EndDate'="" s EndDate=##class(websys.Conversions).DateHtmlToLogical(EndDate)
	  
	i StartDate="" s StartDate=+$h
	i EndDate="" s EndDate=+$h 
	i (StartDate>EndDate)
	{
		Set qHandle=$lb(0,repid,0) 
		Quit $$$OK 
	}
	i NoFetchReport'="" d
	.s NoFetchReport="Y"
	e  d
	.s NoFetchReport="N"
	
	i HadSendMessage'="" d
	.s HadSendMessage="1"
	e  d
	.s HadSendMessage="0"
	s Date=EndDate+1
	f  s Date=$O(^DHCPERPT(0,"CompleteDate",Date),-1) q:(Date="")||(Date<StartDate)  d
	.s TSendDate=##class(websys.Conversions).DateLogicalToHtml(Date)
	.s Time=""
	.f  s Time=$O(^DHCPERPT(0,"CompleteDate",Date,Time),-1) q:(Time="")  d
	..s ID=0
	..f  s ID=$O(^DHCPERPT(0,"CompleteDate",Date,Time,ID)) q:(ID="")  d
	...s IADM=$P(^DHCPERPT(ID),"^",1)
	...q:IADM=""
	...s Status=$P(^DHCPERPT(ID),"^",2)
	...q:(Status="A")||(Status="NA")||(Status="P")
	...q:(NoFetchReport="N")&&(Status="S")
	...q:(NoFetchReport="Y")&&(Status'="S")
	...s PIADM=$P(^DHCPEIADM(IADM),"^",4)
	...s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PEADM",IADM)
  	...q:LocFlag=1 
	...s TSendUser=$P(^DHCPERPT(ID),"^",12)
	...i TSendUser'="" s TSendUser=$P(^SSU("SSUSR",TSendUser),"^",2)
 	...s TSendTime=""
 	...s TReportStatus=""
 	...s:Status="S" TReportStatus="已取"
 	...s:Status="C" TReportStatus="已完成"
 	...s TAppDate=$G(^DHCPEDataEx("DHCPEPreIADM","GetReportDateTime","I",PIADM))
 	...s:TAppDate'="" TAppDate=##class(websys.Conversions).DateLogicalToHtml(+TAppDate)
 	...s PIBIDR=$P(^DHCPEPreIADM(PIADM),"^",1)
 	...s PreGAdm=$P(^DHCPEPreIADM(PIADM),"^",2)
	...q:(GroupID="ALLI")&&(PreGAdm'="")
	...q:(GroupID="ALLG")&&(PreGAdm="")
	...q:(GroupID'="")&&(PreGAdm'=GroupID)&&(GroupID'="ALLG")&&(GroupID'="ALLI")
	...s IFOLDFlag=""
	...s TGroupName=""
	...i PreGAdm'="" d
	....s PreGBaseInfo=$P(^DHCPEPreGADM(PreGAdm),"^",1)
	....s TGroupName=$P(^DHCPEPreGBI(PreGBaseInfo),"^",2)
 	...s EntDR=##class(web.DHCPE.Query.IAdmItemStatus).GetArcSetDr(PIADM)
 	...s:EntDR'="" IFOLDFlag=$g(^DHCPEDataEx("OrdSetsEx","IFOLD",EntDR))
 	...q:(IFOLDFlag'="Y")&&(IFOLD="on")
 	...s TVIPLevel=$p($g(^DHCPEPreIADM(PIADM)),"^",18)
    ...s:TVIPLevel="" TVIPLevel=$G(^DHCPEVIPLevel("VIPapprove"))
    ...q:(VIPLevel'="")&&(VIPLevel'=TVIPLevel)
    ...s TVIPLevel=$P($G(^DHCPEVIPLevel("VIP",TVIPLevel)),"^",2)
 	...i $D(^User.DHCPENewSendMessageI("TypeSourceIndex","RP",ID)) d
 	....s MessageID=$O(^User.DHCPENewSendMessageI("TypeSourceIndex","RP",ID,""),-1)
 	....s MessageStatus=$LG(^User.DHCPENewSendMessageD(MessageID),13)
 	....s THadSendMessage2="1"
 	....s:MessageStatus=0 THadSendMessage="待发送"
 	....s:MessageStatus=2 THadSendMessage="已发送"
 	....s:MessageStatus=3 THadSendMessage="发送失败"
 	....s TSendMessage="0"
 	....s TDate=$LG(^User.DHCPENewSendMessageD(MessageID),10)
 	....s:TDate'="" TDate=##class(websys.Conversions).DateLogicalToHtml(TDate)
 	....s TTime=$LG(^User.DHCPENewSendMessageD(MessageID),11)
 	....s:TTime'="" TTime=##class(websys.Conversions).TimeLogicalToHtml(TTime)
 	....s TMessageDate=TDate_" "_TTime
 	...e  d
 	....s THadSendMessage="未发送"
 	....s THadSendMessage2="0"
 	....s TSendMessage="1"
 	...q:(HadSendMessage'="0")&(HadSendMessage'=THadSendMessage2)
 	...s RptPrtDate=$P($G(^DHCPERPT(ID)),"^",7)
	...s RptPrtDate=##class(websys.Conversions).DateLogicalToHtml(RptPrtDate)
 	...d GetPersonInfo4
	
	Set qHandle=$lb(0,repid,0) 
	Quit $$$OK
GetPersonInfo4
	s TRegNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",1)
	q:(RegNo'="")&&(TRegNo'=RegNo)
	s TName=$p($g(^DHCPEPreIBI(PIBIDR)),"^",2)
	s SexDR=$p($g(^DHCPEPreIBI(PIBIDR)),"^",3)
	s TSex=$p($g(^CT("SEX",SexDR)),"^",2)
	s Age=$p($g(^DHCPEPreIBI(PIBIDR)),"^",4)
	s:Age'="" TBirth=##class(websys.Conversions).DateLogicalToHtml(Age)
	;s:Age'="" Age=$P(##class(web.DHCLCNUREXCUTE).CalAge(Age,+$H),"Y",1) 
	s Age=""
	s PAPMIRowId=$o(^PAPERi("PAPMI_PatNo",TRegNo,0)) 
	i PAPMIRowId='"" s Age=##class(web.DHCBillInterface).GetPapmiAge(PAPMIRowId)
	s TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",6)
	s:TelNo="" TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",7)
	s:TelNo="" TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",8)
	d OutPut4
	q
Clear4
	s (TRegNo,TName,TSex,TBirth,TSendUser,TSendDate,TSendTime,TReportStatus,TAppDate,RptPrtDate,TMessageDate)=""
	q 
OutPut4
	q:(Name'="")&&(TName'[Name)
	set Data=$lb(TRegNo,TName,TSex,TBirth,TSendUser,TSendDate,TSendTime,TReportStatus,TAppDate,TelNo,THadSendMessage,TSendMessage,ID,TVIPLevel,RptPrtDate,TGroupName,TMessageDate)  
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SearchCmopleteReportFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SearchCmopleteReportExecute ]
{
	
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else{			
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind) 
	Quit $$$OK
}

ClassMethod SearchCmopleteReportClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SearchCmopleteReportExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Query SearchSendAudit(StartDate As %String, EndDate As %String, DoRegNo As %String, NoSend As %String = "", VIPLevel, AutoSend As %String = "", Sex As %String = "", GID As %String = "") As %Query(ROWSPEC = "TRegNo:%String,TName:%String,TSex:%String,TBirth:%String,TSendUser:%String,TSendDate:%String,TSendTime:%String,TReportDate:%String,TAppDate:%String,TNoResultItem:%String,TPAADM:%String,TVIPLevel:%String,TGDesc:%String,TNum:%String,TReportStatus:%String")
{
}

ClassMethod SearchSendAuditExecute(ByRef qHandle As %Binary, StartDate As %String, EndDate As %String, DoRegNo As %String, NoSend As %String = "", VIPLevel As %String, AutoSend As %String = "", Sex As %String = "", GID As %String = "") As %Status
{
    s num=0
	Set repid=$I(^CacheTemp)
	s Job=$J
	If $g(ind)="" Set ind=2000
	i StartDate'="" s StartDate=##class(websys.Conversions).DateHtmlToLogical(StartDate) 
	i EndDate'="" s EndDate=##class(websys.Conversions).DateHtmlToLogical(EndDate) 
	
	i StartDate="" s StartDate=+$h
	i EndDate="" s EndDate=+$h 
	
	i (StartDate>EndDate)
	{
		Set qHandle=$lb(0,repid,0) 
		Quit $$$OK 
	}
	
	i NoSend'="" d
	.s NoSend="Y"
	e  d
	.s NoSend="N"
	//s Date=StartDate-1
	
	s Date=StartDate-1
	//e  s Date=0
	
	i NoSend="N"{
	f  s Date=$O(^User.DHCPESendAuditI("SendDateIndex",Date)) q:(Date="")||(Date>EndDate)  d
	.s TSendDate=##class(websys.Conversions).DateLogicalToHtml(Date)
	.s ID=0
	.f  s ID=$O(^User.DHCPESendAuditI("SendDateIndex",Date,ID)) q:(ID="")  d
	..s PAADM=$LG(^User.DHCPESendAuditD(ID),2)
	..s TSendUser=$LG(^User.DHCPESendAuditD(ID),3)
	..i TSendUser'="" s TSendUser=$P(^SSU("SSUSR",TSendUser),"^",2)
 	..s TSendTime=$LG(^User.DHCPESendAuditD(ID),5)
 	..s:TSendTime'="" TSendTime=##class(websys.Conversions).TimeLogicalToHtml(TSendTime)
 	..;s TNoResultItem=##class(web.DHCPE.ResultEdit).GetUnAppedItems("",PAADM)
 	..;s TNoResultItem=$P(TNoResultItem,"^",2)
 	..s TNoResultItem=##class(web.DHCPE.DHCPEIAdm).OutNoCheckItemByPAADMNew(PAADM)
	..s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	..q:IADM=""
	..s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PEADM",IADM)
    ..q:LocFlag=1
	..s PIADM=$P(^DHCPEIADM(IADM),"^",4)
	..s TReportDate=$P($G(^DHCPEDataEx("DHCPEPreIADM","GetReportDateTime","I",PIADM)),"^",1)
 	..s:TReportDate'="" TReportDate=##class(websys.Conversions).DateLogicalToHtml(TReportDate)
 	..s TAppDate=$P($G(^DHCPEDataEx("ConfirmRecPaper",PIADM)),"^",1)
 	..s:TAppDate'="" TAppDate=##class(websys.Conversions).DateLogicalToHtml(TAppDate)
 	..s PIBIDR=$P(^DHCPEPreIADM(PIADM),"^",1)
 	..d GetPersonInfo2
	}else{
		//^DHCPEDataEx("ConfirmRecPaper","DateTime",KData,KTime,PIADM)
		f  s Date=$O(^DHCPEDataEx("ConfirmRecPaper","DateTime",Date)) q:(Date="")||(Date>EndDate)  d
		.s TAppDate=##class(websys.Conversions).DateLogicalToHtml(Date)
		.s TSendDate=""
		.s TSendUser=""
		.s TSendTime=""
		.s Time=""
		.f  s Time=$O(^DHCPEDataEx("ConfirmRecPaper","DateTime",Date,Time)) q:(Time="")  d
		..s PIADM=0
		..f  s PIADM=$O(^DHCPEDataEx("ConfirmRecPaper","DateTime",Date,Time,PIADM)) q:(PIADM="")  d
		...s TReportDate=$P($G(^DHCPEDataEx("DHCPEPreIADM","GetReportDateTime","I",PIADM)),"^",1)
 		...s:TReportDate'="" TReportDate=##class(websys.Conversions).DateLogicalToHtml(TReportDate)
 		...s IADM=$O(^DHCPEIADM(0,"CRMADM",PIADM,0))
 		...q:IADM=""
 		...s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PEADM",IADM)
    	...q:LocFlag=1
 		...s PAADM=$P(^DHCPEIADM(IADM),"^",1)
 		...q:$D(^User.DHCPESendAuditI("AdmIndex",PAADM))
 		
 		...;s TNoResultItem=##class(web.DHCPE.ResultEdit).GetUnAppedItems("",PAADM)
 		...;s TNoResultItem=$P(TNoResultItem,"^",2)
 		...s TNoResultItem=##class(web.DHCPE.DHCPEIAdm).OutNoCheckItemByPAADMNew(PAADM)
 		...s PIBIDR=$P(^DHCPEPreIADM(PIADM),"^",1)
		...d GetPersonInfo2
	}
	;w "总计: "_num_"人"
	s num=""
	s Name=""
	f  s Name=$O(^TempDHCPESendAudit(Job,Name)) q:Name=""  d
	.d Clear2
	.s TName=Name
	.s TRegNo="合计："_$G(^TempDHCPESendAudit(Job,Name))
	.d OutPut2
	k ^TempDHCPESendAudit(Job)
	Set qHandle=$lb(0,repid,0) 
	Quit $$$OK
GetPersonInfo2
	s TRegNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",1)
	
	q:(DoRegNo'="")&&(TRegNo'=DoRegNo)
	s TVIPLevel=$P(^DHCPEPreIADM(PIADM),"^",18)
	s:TVIPLevel="" TVIPLevel=$G(^DHCPEVIPLevel("VIPapprove"))
	q:(VIPLevel'="")&&(VIPLevel'=TVIPLevel)
	s:TVIPLevel'="" TVIPLevel=$P(^DHCPEVIPLevel("VIP",TVIPLevel),"^",2)
	s TName=$p($g(^DHCPEPreIBI(PIBIDR)),"^",2)
	s SexDR=$p($g(^DHCPEPreIBI(PIBIDR)),"^",3)
	q:(Sex'="")&&(SexDR'=Sex)
	s TSex=$p($g(^CT("SEX",SexDR)),"^",2)
	s Age=$p($g(^DHCPEPreIBI(PIBIDR)),"^",4) 
	s:Age'="" TBirth=##class(websys.Conversions).DateLogicalToHtml(Age)
	//s:Age'="" Age=$P(##class(web.DHCLCNUREXCUTE).CalAge(Age,+$H),"Y",1) 
	i TRegNo'="" s PAPMIDR=$O(^PAPERi("PAPMI_PatNo",TRegNo,0))
	s:PAPMIDR'="" Age=##class(web.DHCBillInterface).GetPapmiAge(PAPMIDR)
	s TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",6)
	s:TelNo="" TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",7)
	s:TelNo="" TelNo=$p($g(^DHCPEPreIBI(PIBIDR)),"^",8)
	s GName=""
	s PGADMID=$P($g(^DHCPEPreIADM(PIADM)),"^",2)
	q:(GID'="")&&(GID'="ALLI")&&(GID'="ALLG")&&(GID'=PGADMID)
	q:(GID="ALLI")&&(PGADMID'="")
	q:(GID="ALLG")&&(PGADMID="")
	//GADMID="ALLI"
	
	i PGADMID'="" d 
	.s GNameDR=$p($g(^DHCPEPreGADM(PGADMID)),"^",1)
	.s GName=$p($g(^DHCPEPreGBI(GNameDR)),"^",2) 
	//q:(GDesc'="")&&('(GName[GDesc)) 
	s ReportStatus=..GetReportStatusNew(PAADM)
	S num=num+1
	i GName="" d
	.s ^TempDHCPESendAudit(Job,"个人")=$G(^TempDHCPESendAudit(Job,"个人"))+1
	e  d
	.s ^TempDHCPESendAudit(Job,GName)=$G(^TempDHCPESendAudit(Job,GName))+1
	
	
	d OutPut2
	q
Clear2
	s (TRegNo,TName,TSex,TBirth,TSendUser,TSendDate,TSendTime,TReportDate,TAppDate,TNoResultItem,PAADM,TVIPLevel,GName,ReportStatus)=""
	q 
OutPut2
	set Data=$lb(TRegNo,TName,TSex,TBirth,TSendUser,TSendDate,TSendTime,TReportDate,TAppDate,TNoResultItem,PAADM,TVIPLevel,GName,num,ReportStatus) 
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SearchSendAuditFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SearchSendAuditExecute ]
{
	
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else{			
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind) 
	Quit $$$OK
}

ClassMethod SearchSendAuditClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SearchSendAuditExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod OutPutSpecial(StartDate As %String, EndDate As %String, Item As %String, Status As %String = "", ShowCollect As %String = "", PreDate As %String = "", VIPLevel As %String = "", RegNo As %String = "", StationID As %String = "") As %Status
{

	;Set repid=$I(^CacheTemp)
	s Job=$J
	;If $g(ind)="" Set ind=2000
	s Datas=""
	s UserID=%session.Get("LOGON.USERID")
	i RegNo'="" s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
	If (RegNo'="")&&(+RegNo'=0)  d
	.Set PIBI=$o(^DHCPEPreIBI(0,"PAPMINo",RegNo,0))
	.Quit:PIBI=""
	.Set PIADM=""
	.For  Set PIADM=$o(^DHCPEPreIADM(0,"PIBI",PIBI,PIADM),-1)  Quit:PIADM=""  Do
	..Set IAdmId=""
	..For  Set IAdmId=$o(^DHCPEIADM(0,"CRMADM",PIADM,IAdmId),-1)  Quit:IAdmId=""  Do
	...Do GetIADMInfo
	e  d
	.
	.d GetInfoBYDate
	.
	s CurStatus=""
	f  s CurStatus=$O(^TempDHCPESpecialItem(Job,CurStatus)) q:CurStatus=""  d
	.s:CurStatus=0 StatusDesc="未登记"
	.s:CurStatus=1 StatusDesc="未完成"
	.s:CurStatus=3 StatusDesc="谢绝检查"
	.s:CurStatus=6 StatusDesc="已完成"
	.d Clear3
	.s TItem=StatusDesc
	.d OutPut3
	.s ItemMastID=""
	.f  s ItemMastID=$O(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID)) q:ItemMastID=""  d
	..//判断是否有权限
	..q:($g(^DHCPESpecialContral("DHCPEXH",UserID,ItemMastID))'="Y")
	..q:(StationID'="")&&($o(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))'=StationID)
	..d Clear3
	..s Total=$O(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID,""),-1)
	..s TItem=##class(web.DHCPE.DHCPECommon).GetArcDesc(ItemMastID)
	..s TRegNo=Total
	..; 
	..i ShowCollect="Y"   d         
	...d OutPut3  
	..;update by sun 20131019
	..q:ShowCollect="Y"
	..s Sort=""
	..f  s Sort=$O(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID,Sort)) q:Sort=""  d
	...s Info=$G(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID,Sort))
	...s TArrivedDate=$P(Info,"^",2)
	...s OIID=$P(Info,"^",1)
	...i OIID'="" d
	....s PAADM=$P(^OEORD(+OIID),"^",1)
	....s RLTID=$O(^DHCPERLT(0,"OEORI",OIID,0))
	....i RLTID'="" d
	.....s TCheckDate=$P(^DHCPERLT(RLTID),"^",6)
	.....s:TCheckDate'="" TCheckDate=$ZD(TCheckDate,3)
	....d GetPersonInfo3
	...e  d
	....s PreItemID=$P(Info,"^",3)
	....d GetPersonInfoByPre
	k ^TempDHCPESpecialItem(Job)
	q Datas
	;Set qHandle=$lb(0,repid,0) 
	;Quit $$$OK

GetInfoBYDate
	i StartDate="" s StartDate=+$h
	i EndDate="" s EndDate=+$h 
	i (StartDate>EndDate)  d
	.q
	
	/*{
		Set qHandle=$lb(0,repid,0) 
		Quit $$$OK 
	}*/
	
	;s ^sxt("ddd")=RegNo
	i ShowCollect'="" d
	.s ShowCollect="Y"
	e  d
	.s ShowCollect="N"
	s Job=$J
	s Date=StartDate-1
	i PreDate=""
	{
		f  s Date=$O(^User.DHCPECurDateAdmInfoI("DateAdmIndex",Date)) q:(Date="")||(Date>EndDate)  d
		.s ArriveDate=$ZD(Date,3)
		.s Adm=""
		.f  s Adm=$O(^User.DHCPECurDateAdmInfoI("DateAdmIndex",Date,Adm)) q:(Adm="")  d
		..s IADM=$O(^DHCPEIADM(0,"PAADM",Adm,0))
		..s AdmStatus=$P(^DHCPEIADM(IADM),"^",8)
		..q:AdmStatus'="ARRIVED"
		..s PADM=$P(^DHCPEIADM(IADM),"^",4)
		..s TVIPLevel=$P(^DHCPEPreIADM(PADM),"^",18)
		..q:(VIPLevel'="")&&(TVIPLevel'=VIPLevel)
		
		..s Order=""
		..s Order=$O(^OEORD(0,"Adm",Adm,0))
		..q:Order=""
		..s Sub="0"
		..f  s Sub=$O(^OEORD(Order,"I",Sub)) q:Sub=""  d
		...q:'$D(^OEORD(Order,"I",Sub,1))
		...s CurStatus=$P(^OEORD(Order,"I",Sub,1),"^",13)
		...q:CurStatus="4"
		...s ItemMastID=$P(^OEORD(Order,"I",Sub,1),"^",2)
		...s Flag=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemMastID))
		...q:Flag'="Y"
		...q:(Item'="")&&(ItemMastID'=Item)
		...s OrdItemID=Order_"||"_Sub
		...i CurStatus=1 d ;核实
		....s:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrdItemID)) CurStatus="3" ;谢绝检查
		...q:(CurStatus'=Status)&&(Status'="")
		...s Sort=$I(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID))
		...s ^TempDHCPESpecialItem(Job,CurStatus,ItemMastID,Sort)=OrdItemID_"^"_ArriveDate
	}
	else
	{
		f  s Date=$O(^DHCPEPreIADM(0,"BookDateTime",Date)) q:(Date="")||(Date>EndDate)  d
		.s ArriveDate=$ZD(Date,3)
		.s EDate=""
		.f  s EDate=$O(^DHCPEPreIADM(0,"BookDateTime",Date,EDate)) q:(EDate="")  d
		..s Time=""
		..f  s Time=$O(^DHCPEPreIADM(0,"BookDateTime",Date,EDate,Time)) q:(Time="")  d
		...s PADM=""
		...f  s PADM=$O(^DHCPEPreIADM(0,"BookDateTime",Date,EDate,Time,PADM)) q:(PADM="")  d
		....s ADMStatus=$P(^DHCPEPreIADM(PADM),"^",8)
		....q:ADMStatus="CANCELPE"
		....//q:AdmStatus'="ARRIVED"
		....s TVIPLevel=$P(^DHCPEPreIADM(PADM),"^",18)
		....q:(VIPLevel'="")&&(TVIPLevel'=VIPLevel)
		....s Sub=0
		....f  s Sub=$O(^DHCPEPreIADM(PADM,"ORDITEM",Sub)) q:Sub=""  d
		.....s Stat=$P($g(^DHCPEPreIADM(PADM,"ORDITEM",Sub)),"^",16)
		.....q:Stat'="1"
		.....s ItemMastID=$P(^DHCPEPreIADM(PADM,"ORDITEM",Sub),"^",1)
		.....s Flag=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemMastID))
		.....q:Flag'="Y"
		.....q:(Item'="")&&(ItemMastID'=Item)
		.....s CurStatus=0
		.....s PItemID=PADM_"||"_Sub
		.....s CRMItemID=$O(^DHCPECRMO(0,"CRMORI",PItemID,0))
		.....s OEID=""
		.....s:CRMItemID'="" OEID=$P(^DHCPECRMO(CRMItemID),"^",1)
		.....i OEID'=""  d
		......s CurStatus=$P(^OEORD(+OEID,"I",$P(OEID,"||",2),1),"^",13)
		......i CurStatus=1 d ;核实
		.......s:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OEID)) CurStatus="3" ;谢绝检查
		.....q:(CurStatus'=Status)&&(Status'="")
		.....s Sort=$I(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID))
		.....s ^TempDHCPESpecialItem(Job,CurStatus,ItemMastID,Sort)=OEID_"^"_ArriveDate_"^"_PItemID
	}
	q

GetIADMInfo
	q:(IAdmId="")
	s PAADM=$P(^DHCPEIADM(IAdmId),"^",1)
	s Info=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PAADM)
	s PADM=$P(^DHCPEIADM(IAdmId),"^",4)
	
	s ArriveDate=$zd($p(^DHCPEPreIADM(PADM),"^",4))
	s TVIPLevel=$P(^DHCPEPreIADM(PADM),"^",18)
	;TItem,TRegNo,TName,TGroup,TTel,TArrivedDate,TCheckDate
	s TRegNo=$p(Info,"^",5)
	s TName=$p(Info,"^",1)
	s TTel=$p(Info,"^",6)
	s TGroup=$p(Info,"^",7)
	s Sub=0
	f  s Sub=$O(^DHCPEPreIADM(PADM,"ORDITEM",Sub)) q:Sub=""  d
	.s Stat=$P($G(^DHCPEPreIADM(PADM,"ORDITEM",Sub)),"^",16)
	.q:Stat'="1"
	.s ItemMastID=$P(^DHCPEPreIADM(PADM,"ORDITEM",Sub),"^",1)
	.s Flag=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemMastID))
	.q:Flag'="Y"
	.q:(Item'="")&&(ItemMastID'=Item)
	.q:(StationID'="")&&($o(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))'=StationID)
	.s CurStatus=0
	.s PItemID=PADM_"||"_Sub
	.s CRMItemID=$O(^DHCPECRMO(0,"CRMORI",PItemID,0))
	.s OEID=""
	.s:CRMItemID'="" OEID=$P(^DHCPECRMO(CRMItemID),"^",1)
	.i OEID'=""  d
	..s CurStatus=$P(^OEORD(+OEID,"I",$P(OEID,"||",2),1),"^",13)
	..i CurStatus=1 d ;核实
	...s:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OEID)) CurStatus="3" ;谢绝检查
	.q:(CurStatus'=Status)&&(Status'="")
	.s Sort=$I(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID))
	.s ^TempDHCPESpecialItem(Job,CurStatus,ItemMastID,Sort)=OEID_"^"_ArriveDate_"^"_PItemID
	;d OutPut3
	

GetPersonInfo3
	s Flag=0
	;PatName_"^"_Sex_"^"_Birth_"^"_IDCard_"^"_RegNo_"^"_Tel
	
	s Info=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PAADM)
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	s PADM=$P(^DHCPEIADM(IADM),"^",4)
	s AdmID=$P(^DHCPEIADM(IADM),"^",1)
	s TVIPLevel=$P(^DHCPEPreIADM(PADM),"^",18)
	;s ^sxt("dd")=PADM
	i (TVIPLevel'="")&&(+TVIPLevel'=0)  d
	.s:($P($g(^DHCPEVIPLevel("VIP",TVIPLevel)),"^",2)[("VIP")) Flag=1
	s AsCharged=$P(^DHCPEPreIADM(PADM),"^", 9)
	
	i ((AsCharged'="Y")&&(Flag'=1))  d
	.s AuditID=0
	.f  s AuditID=$O(^DHCPEPreA(0,"CRMADM","I",PADM,AuditID)) q:(AuditID="")||(Flag=1)  d
	..s Amount=+$P(^DHCPEPreA(AuditID),"^",9)
	..q:Amount=0
	..s UseFlag=$P(^DHCPEPreA(AuditID),"^",21)
	..q:UseFlag="NU"
	..s ChargeFlag=$P(^DHCPEPreA(AuditID),"^",14)
	..q:ChargeFlag="CHARGED"
	..s Flag=1
	s:(Flag=1) TPosition=""
	s:(Flag=0) TPosition=##class(web.DHCPE.RoomManager).GetAdmCurRoom(AdmID,"ADM","")
	
	s TPosition=$p(TPosition,"^",2)
	;TItem,TRegNo,TName,TGroup,TTel,TArrivedDate,TCheckDate
	s TRegNo=$p(Info,"^",5)
	s TName=$p(Info,"^",1)
	s TTel=$p(Info,"^",6)
	s TGroup=$p(Info,"^",7)
	d OutPut3
	q
GetPersonInfoByPre
	s PADM=+PreItemID
	s Obj=##class(User.DHCPEPreIADM).%OpenId(PADM)
	s TRegNo=Obj.PIADMPIBIDR.PIBIPAPMINo
	s TName=Obj.PIADMPIBIDR.PIBIName
	s TTel=Obj.PIADMPIBIDR.PIBIMobilePhone
	s:TTel="" TTel=Obj.PIADMPIBIDR.PIBITel1
	s:TTel="" TTel=Obj.PIADMPIBIDR.PIBITel2
	s TGroup=Obj.PIADMPGADMDR.PGADMPGBIDR.PGBIDesc
	s TVIPLevel=Obj.PIADMVip
	d OutPut3
	q
Clear3
	s (TItem,TRegNo,TName,TGroup,TTel,TArrivedDate,TCheckDate,OIID,TVIPLevel,TReCheck,TPosition)=""
	q 
OutPut3
	q:((RegNo'="")&&(RegNo'=TRegNo))
	i OIID'="" s OIID=OIID_"^"_CurStatus
	s:TVIPLevel'="" TVIPLevel=$P(^DHCPEVIPLevel("VIP",TVIPLevel),"^",2)
	s TReCheck=""
	s:PADM'="" TReCheck=##class(web.DHCPE.PreCommon).IsReCheck(PADM,"Pre")
	s:TReCheck="1" TReCheck="是"
	s:TReCheck="0" TReCheck="否"
	s:TName="" TReCheck=""
	;w:TName'="" TReCheck
	set Data=TItem_"^"_TRegNo_"^"_TName_"^"_TGroup_"^"_TTel_"^"_TArrivedDate_"^"_TCheckDate_"^"_TVIPLevel_"^"_TReCheck 
	;Set ^CacheTemp(repid,ind)=Data
 	;Set ind=ind+1
 	s Datas=Datas_"$$"_Data
 	q
}

Query SearchSpecialItem(StartDate As %String, EndDate As %String, Item As %String, ItemDesc As %String, Status As %String = "", ShowCollect As %String = "", PreDate As %String = "", VIPLevel As %String = "", RegNo As %String = "", StationID As %String = "", ExamDate As %String = "", UserNo As %String = "", Name As %String = "") As %Query(ROWSPEC = "TItem:%String,TRegNo:%String,TName:%String,TGroup:%String,TTel:%String,TArrivedDate:%String,TCheckDate:%String,TOIID:%String,TVIPLevel:%String,TReCheck:%String,TPosition:%String,TReCheck:%String,TAge:%String,PIADMPIBIDRSEX:%String,CardID:%String,UserName:%String,THPNo:%String,TBirth:%String")
{
}

/// w ##class(web.DHCPE.FetchReport).SearchSpecialItemExecute("",63151,63151,"","","","","","","","ERROR!")
ClassMethod SearchSpecialItemExecute(ByRef qHandle As %Binary, StartDate As %String, EndDate As %String, Item As %String, ItemDesc As %String, Status As %String = "", ShowCollect As %String = "", PreDate As %String = "", VIPLevel As %String = "", RegNo As %String = "", StationID As %String = "", ExamDate As %String = "", UserNo As %String = "", Name As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
	s Job=$J
	If $g(ind)="" Set ind=2000
	s UserID=%session.Get("LOGON.USERID")
	s ^DHCXPTest("PE","Specail")=StartDate_","_EndDate_","_Item_","_Status_","_ShowCollect_","_PreDate_","_VIPLevel_","_RegNo_","_StationID_","_ExamDate_","_UserID
	s ExportName="DHCPESpecial"
	k ^TempDHCPEExportCommon(UserID,ExportName)
	
	i StartDate'="" s StartDate=##class(websys.Conversions).DateHtmlToLogical(StartDate)
	i EndDate'=""   s EndDate=##class(websys.Conversions).DateHtmlToLogical(EndDate)
	
	i RegNo'="" s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
	If (RegNo'="")&&(+RegNo'=0)  d
	.Set PIBI=$o(^DHCPEPreIBI(0,"PAPMINo",RegNo,0))
	.Quit:PIBI=""
	.Set PIADM=""
	.For  Set PIADM=$o(^DHCPEPreIADM(0,"PIBI",PIBI,PIADM),-1)  Quit:PIADM=""  Do
	..Set IAdmId=""
	..For  Set IAdmId=$o(^DHCPEIADM(0,"CRMADM",PIADM,IAdmId),-1)  Quit:IAdmId=""  Do
	...Do GetIADMInfo
	e  i Name'=""  d
	.S Name=$$ALPHAUP^SSUTIL4(Name)
	.S NameIndex=$O(^DHCPEPreIBI(0,"Name",Name),-1)
	.f  S NameIndex=$O(^DHCPEPreIBI(0,"Name",NameIndex)) q:(NameIndex="")||(NameIndex'[Name)  d
	..s PIBI=""
	..f  s PIBI=$o(^DHCPEPreIBI(0,"Name",NameIndex,PIBI),-1) q:PIBI=""  d
	...s PIADM=""
	...f  s PIADM=$o(^DHCPEPreIADM(0,"PIBI",PIBI,PIADM),-1) q:PIADM=""  d
	....Set IAdmId=""
	....For  Set IAdmId=$o(^DHCPEIADM(0,"CRMADM",PIADM,IAdmId),-1)  Quit:IAdmId=""  Do
	.....Do GetIADMInfo
	e  d
	.
	.d GetInfoBYDate
	.
	s CurStatus1=""
	f  s CurStatus1=$O(^TempDHCPESpecialItem(Job,CurStatus1)) q:CurStatus1=""  d
	.s:CurStatus1=0 StatusDesc="未登记"
	.s:CurStatus1=1 StatusDesc="未完成"
	.s:CurStatus1=3 StatusDesc="谢绝检查"
	.s:CurStatus1=6 StatusDesc="已完成"
	.;q:CurStatus1="3"
	.d Clear3
	.s TItem=StatusDesc
	.d OutPut3
	.s STSort=""
	.f  s STSort=$O(^TempDHCPESpecialItem(Job,CurStatus1,STSort)) q:STSort=""  d
	..s ItemMastID=""
	..f  s ItemMastID=$O(^TempDHCPESpecialItem(Job,CurStatus1,STSort,ItemMastID)) q:ItemMastID=""  d
	...//判断是否有权限
	...q:($g(^DHCPESpecialContral("DHCPEXH",UserID,ItemMastID))'="Y")
	...q:(StationID'="")&&($o(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))'=StationID)
	...d Clear3
	...s Total=$G(^TempDHCPESpecialItem(Job,CurStatus1,ItemMastID))
	...s TItem=##class(web.DHCPE.DHCPECommon).GetArcDesc(ItemMastID)
	...s TRegNo=Total
	...; 
	...;i ShowCollect="Y"   d         
	...d OutPut3  
	...;update by sun 20131019
	...q:ShowCollect="Y"
	...s Sort=""
	...f  s Sort=$O(^TempDHCPESpecialItem(Job,CurStatus1,STSort,ItemMastID,Sort)) q:Sort=""  d
	....s Info=$G(^TempDHCPESpecialItem(Job,CurStatus1,STSort,ItemMastID,Sort))
	....s TArrivedDate=$P(Info,"^",2)
	....s OIID=$P(Info,"^",1)
	....i OIID'="" d
	.....s PAADM=$P(^OEORD(+OIID),"^",1)
	.....s RLTID=$O(^DHCPERLT(0,"OEORI",OIID,0))
	.....s TCheckDate=""
	.....i RLTID'="" d
	......s TCheckDate=$P(^DHCPERLT(RLTID),"^",6)
	......s:TCheckDate'="" TCheckDate=##class(websys.Conversions).DateLogicalToHtml(TCheckDate)
	.....d GetPersonInfo3
	....e  d
	.....s PreItemID=$P(Info,"^",3)
	.....d GetPersonInfoByPre
	k ^TempDHCPESpecialItem(Job)
	Set qHandle=$lb(0,repid,0) 
	Quit $$$OK

GetInfoBYDate
	i StartDate="" s StartDate=+$h
	i EndDate="" s EndDate=+$h 
	i (StartDate>EndDate)
	{
		Set qHandle=$lb(0,repid,0) 
		Quit $$$OK 
	}
	
	
	i ShowCollect'="" d
	.s ShowCollect="Y"
	e  d
	.s ShowCollect="N"
	s Job=$J
	s Date=StartDate-1
	
	if (ExamDate'="")
	{
		// ***************************** 按照检查日期查询 Start *****************************
		
		
		f  s Date=$O(^DHCPESpecial("DHCPE","DateIndex",Date)) q:(Date="")||(Date>EndDate)  d //,CurTime,OEID)=""
		.s Time=""
		.f  s Time=$O(^DHCPESpecial("DHCPE","DateIndex",Date,Time)) q:(Time="")  d
		..s OEORIRowid=""	
		..;f  s OEORIRowid=$o(^DHCPERLT("0","DateOrder",Date,OEORIRowid)) q:OEORIRowid=""  d
		..f  s OEORIRowid=$o(^DHCPESpecial("DHCPE","DateIndex",Date,Time,OEORIRowid)) q:OEORIRowid=""  d
		...s Adm=$p($G(^OEORD(+OEORIRowid)),"^",1)
		...q:Adm=""
		...s IADM=$O(^DHCPEIADM(0,"PAADM",Adm,0))
		...s AdmDate=$p($g(^DHCPEIADM(IADM)),"^",5)
		...s ArriveDate=##class(websys.Conversions).DateLogicalToHtml(AdmDate)
		...s AdmStatus=$P(^DHCPEIADM(IADM),"^",8)
		...s Order=+OEORIRowid
		...s Sub=$p(OEORIRowid,"||",2)
		...q:'$D(^OEORD(Order,"I",Sub,1))
		...s CurStatus=$P(^OEORD(Order,"I",Sub,1),"^",13)
		...q:CurStatus="4"
		...s:(CurStatus="6")&&('$D(^DHCPESpecial("DHCPE","UserID",OEORIRowid))) CurStatus=1
		...s ItemMastID=$P(^OEORD(Order,"I",Sub,1),"^",2)
		...s Flag=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemMastID))
		...q:Flag'="Y"
		...q:(Item'="")&&(ItemMastID'=Item)
		...s OrdItemID=OEORIRowid
		...i CurStatus=1 d ;核实
		....s:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrdItemID)) CurStatus="3" ;谢绝检查
		...q:(CurStatus'=Status)&&(Status'="")
		...s STID=$O(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))
		...q:STID=""
		...s STSort=$P(^DHCPEST(STID),"^",9)
		...s:STSort="" STSort="999999999"
		...s (UserName,UserInit)=""
		...i OrdItemID'=""  d
		....s user=+$g(^DHCPESpecial("DHCPE","UserID",OrdItemID))
		....i (user'="") d
		.....s UserName=$p($g(^SSU("SSUSR",user)),"^",2)
		.....s UserInit=$p($g(^SSU("SSUSR",user)),"^",1)
		...q:(UserName'="")&&(UserNo'="")&&(UserName'[UserNo)&&(UserInit'[UserNo)
	
		...s Sort=$I(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID))
		
		...s ^TempDHCPESpecialItem(Job,CurStatus,STSort,ItemMastID,Sort)=OrdItemID_"^"_ArriveDate
		// ***************************** 按照检查日期查询 End *****************************
	}
	elseif (PreDate="")
	{
		;f  s Date=$O(^User.DHCPECurDateAdmInfoI("DateAdmIndex",Date)) q:(Date="")||(Date>EndDate)  d
		f  s Date=$O(^DHCPEIADM(0,"AdmDateTime",Date)) q:(Date="")||(Date>EndDate)  d
		.s ArriveDate=##class(websys.Conversions).DateLogicalToHtml(Date)
		.s Time=""
		.f  s Time=$O(^DHCPEIADM(0,"AdmDateTime",Date,Time)) q:(Time="")  d
		..;s Adm=""
		..;f  s Adm=$O(^User.DHCPECurDateAdmInfoI("DateAdmIndex",Date,Adm)) q:(Adm="")  d
		..;s IADM=$O(^DHCPEIADM(0,"PAADM",Adm,0))
		..s IADM=""
		..f  s IADM=$O(^DHCPEIADM(0,"AdmDateTime",Date,Time,IADM)) q:(IADM="")  d
		...s Adm=$P(^DHCPEIADM(IADM),"^",1)
		...s AdmStatus=$P(^DHCPEIADM(IADM),"^",8)
		...q:AdmStatus'="ARRIVED"
		...s PADM=$P(^DHCPEIADM(IADM),"^",4)
		...s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PADM)
	    ...q:LocFlag=1
		...s TVIPLevel=$P(^DHCPEPreIADM(PADM),"^",18)
		...q:(VIPLevel'="")&&(TVIPLevel'=VIPLevel)
		...s Order=""
		...s Order=$O(^OEORD(0,"Adm",Adm,0))
		...q:Order=""
		...s Sub="0"
		...f  s Sub=$O(^OEORD(Order,"I",Sub)) q:Sub=""  d
		....q:'$D(^OEORD(Order,"I",Sub,1))
		....s CurStatus=$P(^OEORD(Order,"I",Sub,1),"^",13)
		....q:CurStatus="4"
		....s ItemMastID=$P(^OEORD(Order,"I",Sub,1),"^",2)
		....s Flag=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemMastID))
		....q:Flag'="Y"
		....q:(Item'="")&&(ItemMastID'=Item)
		....s OrdItemID=Order_"||"_Sub
		....s:(CurStatus="6")&&('$D(^DHCPESpecial("DHCPE","UserID",OrdItemID))) CurStatus=1
		....i CurStatus=1 d ;核实
		.....s:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrdItemID)) CurStatus="3" ;谢绝检查
		....q:(CurStatus'=Status)&&(Status'="")
		....s STID=$O(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))
		....q:STID=""
		....s STSort=$P(^DHCPEST(STID),"^",9)
		....s:STSort="" STSort="999999999"
		....s (UserName,UserInit)=""
		....i OrdItemID'=""  d
		.....s user=+$g(^DHCPESpecial("DHCPE","UserID",OrdItemID))
		.....i (user'="") d
		......s UserName=$p($g(^SSU("SSUSR",user)),"^",2)
		......s UserInit=$p($g(^SSU("SSUSR",user)),"^",1)
		....q:(UserName'="")&&(UserNo'="")&&(UserName'[UserNo)&&(UserInit'[UserNo)
	
		....s Sort=$I(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID))
		....s ^TempDHCPESpecialItem(Job,CurStatus,STSort,ItemMastID,Sort)=OrdItemID_"^"_ArriveDate
	}
	else
	{
		f  s Date=$O(^DHCPEPreIADM(0,"BookDateTime",Date)) q:(Date="")||(Date>EndDate)  d
		.s ArriveDate=##class(websys.Conversions).DateLogicalToHtml(Date)
		.s EDate=""
		.f  s EDate=$O(^DHCPEPreIADM(0,"BookDateTime",Date,EDate)) q:(EDate="")  d
		..s Time=""
		..f  s Time=$O(^DHCPEPreIADM(0,"BookDateTime",Date,EDate,Time)) q:(Time="")  d
		...s PADM=""
		...f  s PADM=$O(^DHCPEPreIADM(0,"BookDateTime",Date,EDate,Time,PADM)) q:(PADM="")  d
		....s ADMStatus=$P(^DHCPEPreIADM(PADM),"^",8)
		....q:ADMStatus="CANCELPE"
		....s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PADM)
	    ....q:LocFlag=1
		....//q:ADMStatus'="ARRIVED"
		....s TVIPLevel=$P(^DHCPEPreIADM(PADM),"^",18)
		....q:(VIPLevel'="")&&(TVIPLevel'=VIPLevel)
		....s Sub=0
		....f  s Sub=$O(^DHCPEPreIADM(PADM,"ORDITEM",Sub)) q:Sub=""  d
		.....s Stat=$P(^DHCPEPreIADM(PADM,"ORDITEM",Sub),"^",16)
		.....q:Stat'="1"
		.....s ItemMastID=$P(^DHCPEPreIADM(PADM,"ORDITEM",Sub),"^",1)
		.....s Flag=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemMastID))
		.....q:Flag'="Y"
		.....q:(Item'="")&&(ItemMastID'=Item)
		.....s CurStatus=0
		.....s PItemID=PADM_"||"_Sub
		.....s CRMItemID=$O(^DHCPECRMO(0,"CRMORI",PItemID,0))
		.....s OEID=""
		.....s:CRMItemID'="" OEID=$P(^DHCPECRMO(CRMItemID),"^",1)
		.....i OEID'=""  d
		......s CurStatus=$P(^OEORD(+OEID,"I",$P(OEID,"||",2),1),"^",13)
		......i CurStatus=1 d ;核实
		.......s:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OEID)) CurStatus="3" ;谢绝检查
		.....s:(CurStatus="6")&&('$D(^DHCPESpecial("DHCPE","UserID",OEID))) CurStatus=1
		.....s (UserName,UserInit)=""
		.....i OEID'=""  d
		......s user=+$g(^DHCPESpecial("DHCPE","UserID",OEID))
		......i (user'="") d
		.......s UserName=$p($g(^SSU("SSUSR",user)),"^",2)
		.......s UserInit=$p($g(^SSU("SSUSR",user)),"^",1)
		.....q:(UserName'="")&&(UserNo'="")&&(UserName'[UserNo)&&(UserInit'[UserNo)
	
		
		.....q:(CurStatus'=Status)&&(Status'="")
		.....s STID=$O(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))
		.....q:STID=""
		.....s STSort=$P(^DHCPEST(STID),"^",9)
		.....s:STSort="" STSort="999999999"
		
		.....s Sort=$I(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID))
		.....s ^TempDHCPESpecialItem(Job,CurStatus,STSort,ItemMastID,Sort)=OEID_"^"_ArriveDate_"^"_PItemID
	}
	q

GetIADMInfo
	q:(IAdmId="")
	s PAADM=$P(^DHCPEIADM(IAdmId),"^",1)
	s Info=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PAADM)
	s PADM=$P(^DHCPEIADM(IAdmId),"^",4)
	s ArriveDate=##class(websys.Conversions).DateLogicalToHtml($p(^DHCPEPreIADM(PADM),"^",4))
	s TVIPLevel=$P(^DHCPEPreIADM(PADM),"^",18)
	;TItem,TRegNo,TName,TGroup,TTel,TArrivedDate,TCheckDate
	s TRegNo=$p(Info,"^",5)
	s TName=$p(Info,"^",1)
	s TTel=$p(Info,"^",6)
	s TGroup=$p(Info,"^",7)
	s Sub=0
	f  s Sub=$O(^DHCPEPreIADM(PADM,"ORDITEM",Sub)) q:Sub=""  d
	.s Stat=$P($g(^DHCPEPreIADM(PADM,"ORDITEM",Sub)),"^",16)
	.q:Stat'="1"
	.s ItemMastID=$P(^DHCPEPreIADM(PADM,"ORDITEM",Sub),"^",1)
	.s Flag=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemMastID))
	.q:Flag'="Y"
	.q:(Item'="")&&(ItemMastID'=Item)
	.q:(StationID'="")&&($o(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))'=StationID)
	.s CurStatus=0
	.s PItemID=PADM_"||"_Sub
	.s CRMItemID=$O(^DHCPECRMO(0,"CRMORI",PItemID,0))
	.s OEID=""
	.s:CRMItemID'="" OEID=$P(^DHCPECRMO(CRMItemID),"^",1)
	.i OEID'=""  d
	..s CurStatus=$P(^OEORD(+OEID,"I",$P(OEID,"||",2),1),"^",13)
	..i CurStatus=1 d ;核实
	...s:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OEID)) CurStatus="3" ;谢绝检查
	.q:(CurStatus'=Status)&&(Status'="")
	.s STID=$O(^DHCPEST(0,"STORD_ARCIM",ItemMastID,0))
	.q:STID=""
	.s STSort=$P(^DHCPEST(STID),"^",9)
	.s:STSort="" STSort="999999999"
	.//s:(CurStatus="6")&&('$D(^DHCPESpecial("DHCPE","UserID",OEID))) CurStatus=1
	.s (UserName,UserInit)=""
	.i OEID'=""  d
	..s user=+$g(^DHCPESpecial("DHCPE","UserID",OEID))
	..i (user'="") d
	...s UserName=$p($g(^SSU("SSUSR",user)),"^",2)
	...s UserInit=$p($g(^SSU("SSUSR",user)),"^",1)
	.q:(UserName'="")&&(UserNo'="")&&(UserName'[UserNo)&&(UserInit'[UserNo)
	.s Sort=$I(^TempDHCPESpecialItem(Job,CurStatus,ItemMastID))
		
	.s ^TempDHCPESpecialItem(Job,CurStatus,STSort,ItemMastID,Sort)=OEID_"^"_ArriveDate_"^"_PItemID
	;d OutPut3
	q

GetPersonInfo3
	
	s Flag=0
	s Info=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PAADM)
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	s PADM=$P(^DHCPEIADM(IADM),"^",4)
	s AdmID=$P(^DHCPEIADM(IADM),"^",1)
	s TVIPLevel=$P(^DHCPEPreIADM(PADM),"^",18)
	i (TVIPLevel'="")&&(+TVIPLevel'=0)  d
	.s:($P($g(^DHCPEVIPLevel("VIP",TVIPLevel)),"^",2)[("VIP")) Flag=1
	s AsCharged=$P(^DHCPEPreIADM(PADM),"^", 9)
	
	i ((AsCharged'="Y")&&(Flag'=1))  d
	.s AuditID=0
	.f  s AuditID=$O(^DHCPEPreA(0,"CRMADM","I",PADM,AuditID)) q:(AuditID="")||(Flag=1)  d
	..s Amount=+$P(^DHCPEPreA(AuditID),"^",9)
	..q:Amount=0
	..s UseFlag=$P(^DHCPEPreA(AuditID),"^",21)
	..q:UseFlag="NU"
	..s ChargeFlag=$P(^DHCPEPreA(AuditID),"^",14)
	..q:ChargeFlag="CHARGED"
	..s Flag=1
	s:(Flag=1) TPosition=""
	s:(Flag=0) TPosition=##class(web.DHCPE.RoomManager).GetAdmCurRoom(AdmID,"ADM","")
	
	s TPosition=$p(TPosition,"^",2)
	;TItem,TRegNo,TName,TGroup,TTel,TArrivedDate,TCheckDate
	s TRegNo=$p(Info,"^",5)
	s TName=$p(Info,"^",1)
	s TTel=$p(Info,"^",6)
	s TGroup=$p(Info,"^",7)
	d OutPut3
	q
GetPersonInfoByPre
	//d Clear3
	s PADM=+PreItemID
	s Obj=##class(User.DHCPEPreIADM).%OpenId(PADM)
	s TRegNo=Obj.PIADMPIBIDR.PIBIPAPMINo
	s TName=Obj.PIADMPIBIDR.PIBIName
	s TTel=Obj.PIADMPIBIDR.PIBIMobilePhone
	s:TTel="" TTel=Obj.PIADMPIBIDR.PIBITel1
	s:TTel="" TTel=Obj.PIADMPIBIDR.PIBITel2
	s TAge=Obj.PIADMPIBIDR.PIBIDOB
	s:(TAge'="") TAge=$P(##class(web.DHCLCNUREXCUTE).CalAge(TAge,+$H),"Y",1) //$P(##class(web.DHCLCNUREXCUTE))
	s TGroup=Obj.PIADMPGADMDR.PGADMPGBIDR.PGBIDesc
	s TVIPLevel=Obj.PIADMVip
	d OutPut3
	q
Clear3
	s (TItem,TRegNo,TName,TGroup,TTel,TArrivedDate,TCheckDate,OIID,TVIPLevel,TReCheck,TPosition,TAge,PIADMPIBIDRSEX,CardID,PADM,THPNo,TCheckDate)=""
	q 
OutPut3
	q:((RegNo'="")&&(RegNo'=TRegNo))
	s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PADM)
	q:LocFlag=1
	s UserName=""
	s UserInit=""
	i OIID'=""  d
	.s user=+$g(^DHCPESpecial("DHCPE","UserID",OIID))
	.i (user'="") d
	..s UserName=$p($g(^SSU("SSUSR",user)),"^",2)
	..s UserInit=$p($g(^SSU("SSUSR",user)),"^",1)
	.s TCheckDate=$P($g(^DHCPESpecial("DHCPE","UserID",OIID)),"^",2)
	.s:TCheckDate'="" TCheckDate=##class(websys.Conversions).DateLogicalToHtml(TCheckDate)
	.s OIID=OIID_"^"_CurStatus
	;q:(UserName'="")&&(UserNo'="")&&(UserName'[UserNo)&&(UserInit'[UserNo)
	s:TVIPLevel'="" TVIPLevel=$P(^DHCPEVIPLevel("VIP",TVIPLevel),"^",2)
	s TReCheck=""
	i PADM'=""  d
	.s TReCheck=##class(web.DHCPE.PreCommon).IsReCheck(PADM,"Pre")
	.s PIBIID=$p($g(^DHCPEPreIADM(PADM)),"^",1)
	.s THPNo=$p($g(^DHCPEPreIADM(PADM)),"^",27)
	.i PIBIID'=""  d
	..s PIADMPIBIDRSEX="",CardID="",TAge=""
	..s CardID=$p($g(^DHCPEPreIBI(PIBIID)),"^",9)
	..s PIADMPIBIDRSEX=$p($g(^DHCPEPreIBI(PIBIID)),"^",3)
	..i PIADMPIBIDRSEX'="" s PIADMPIBIDRSEX=$P(^CT("SEX",PIADMPIBIDRSEX),"^",2)
	..s TAge=$p($g(^DHCPEPreIBI(PIBIID)),"^",4)
	..s age=""
	..i TAge'=""  d
	...s age=$P(##class(web.DHCLCNUREXCUTE).CalAge(TAge,+$H),"Y",1) //$P(##class(web.DHCLCNUREXCUTE))
	...s TAge=##class(websys.Conversions).DateLogicalToHtml(TAge)
	...//s TAge=TAge_"("_age_")"
	
	s:TReCheck="1" TReCheck="是"
	s:TReCheck="0" TReCheck="否"
	s:TName="" TReCheck=""
	;w:TName'="" TReCheck
	set Data=$lb(TItem,TRegNo,TName,TGroup,TTel,TArrivedDate,TCheckDate,OIID,TVIPLevel,TReCheck,TPosition,TReCheck,TAge,PIADMPIBIDRSEX,CardID,UserName,THPNo,age)  
	s ^TempDHCPEExportCommon(UserID,ExportName,ind)=TItem_"^"_TRegNo_"^"_TName_"^"_TReCheck_"^"_TVIPLevel_"^"_TGroup_"^"_TTel_"^"_TArrivedDate_"^"_TCheckDate
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SearchSpecialItemFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SearchSpecialItemExecute ]
{
	
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else{			
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind) 
	Quit $$$OK
}

ClassMethod SearchSpecialItemClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SearchSpecialItemExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod OutStatusToHTML(ContrlWidth As %String = "") As %String
{
	;d ##Class(web.DHCPE.FetchReport).OutStatusToHTML("130")
	s:(""=ContrlWidth) ContrlWidth="155"
	//下拉列表
	w "<select name='Status' id='Status' style='width:"_ContrlWidth_"' HEIGHT=0  tabIndex=2>",!
	w "<option value=''></option>",!
	w "<option value='0'>预约</option>",!
	w "<option value='1'>未完成</option>",!
	w "<option value='3'>谢绝检查</option>",!
	w "<option value='6'>已完成</option>",!
	w "</select>",!
	Quit $$$OK
}

ClassMethod OutItemToHTML(ContrlWidth As %String = "") As %String
{
	;d ##Class(web.DHCPE.FetchReport).OutItemToHTML("130")
	s:(""=ContrlWidth) ContrlWidth="155"
	//下拉列表
	s UserID=%session.Get("LOGON.USERID")
	w "<select name='Item' id='Item' style='width:"_ContrlWidth_"' HEIGHT=0  tabIndex=2>",!
	w "<option value=''></option>",!
	
	s Job=$J
	k ^TempDHCPESpecialItem(Job)
	s ItemID=""
	f  s ItemID=$O(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemID)) q:ItemID=""  d
	.q:$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemID))'="Y"
	.q:$g(^DHCPESpecialContral("DHCPEXH",UserID,ItemID))'="Y"
	.s STID=$O(^DHCPEST(0,"STORD_ARCIM",ItemID,0))
	.s STSort=$P(^DHCPEST(STID),"^",9)
	.s:STSort="" STSort="999999999"
	.s ^TempDHCPESpecialItem(Job,STSort,ItemID)=""
	
	s STSort=""
	f  s STSort=$O(^TempDHCPESpecialItem(Job,STSort)) q:STSort=""  d
	.s ItemID=""
	.f  s ItemID=$O(^TempDHCPESpecialItem(Job,STSort,ItemID)) q:ItemID=""  d
	..s Desc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ItemID)
	..w "<option value='"_ItemID_"'>"_Desc_"</option>",!
	w "</select>",!
	
	k ^TempDHCPESpecialItem(Job)
	Quit $$$OK
}

Query GetSpecialItem(StationID As %String = "", Item As %String = "") As %Query(ROWSPEC = "ItemDesc:%String:项目名称,ItemID:%String")
{
}

ClassMethod GetSpecialItemExecute(ByRef qHandle As %Binary, StationID As %String = "", Item As %String = "") As %Status
{
	
	s ind=1
	Set repid=$I(^CacheTemp)
	s UserID=%session.Get("LOGON.USERID")
	s ItemID=""
	f  s ItemID=$O(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemID)) q:ItemID=""  d
	.q:$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ItemID))'="Y"
	.q:$g(^DHCPESpecialContral("DHCPEXH",UserID,ItemID))'="Y"
	.s STID=$O(^DHCPEST(0,"STORD_ARCIM",ItemID,0))
	.q:(StationID'="")&&(StationID'=STID)
	.s STSort=$P(^DHCPEST(STID),"^",9)
	.s ItemDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ItemID)
	.q:ItemDesc'[Item
    .d FindBuild	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindBuild      
	set Data=$lb(ItemDesc,ItemID)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod GetSpecialItemFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = GetSpecialItemExecute ]
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

ClassMethod GetSpecialItemClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetSpecialItemExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod OutCompleteButton(OEID)
{
	;d ##class(web.DHCPE.FetchReport).OutCompleteButton(OEID)
	s CurStatus=$P(OEID,"^",2)
	s OEID=$P(OEID,"^",1)
	q:OEID=""
	
	s CRMORowId=$o(^DHCPECRMO(0,"OEORI",OEID,0))
	s status=$p(^DHCPECRMO(CRMORowId),"^",4)
	s StatusDesc=CurStatus
	//s:CurStatus=1 StatusDesc="核实"
	//s:CurStatus=6 StatusDesc="执行"
	q:CurStatus="3" 
	s CheckDate=""
	i '$D(^DHCPESpecial("DHCPE","UserID",OEID)) d
	.//s CurStatus="1"
	.;s CheckDate=$ZD(+$H,3)
	e  d
	.s CheckDate=$P(^DHCPESpecial("DHCPE","UserID",OEID),"^",2)
	.s:CheckDate'="" CheckDate=##class(websys.Conversions).DateLogicalToHtml(CheckDate)
	.s CheckTime=$P(^DHCPESpecial("DHCPE","UserID",OEID),"^",3)
	.s CheckTime=$ZT(CheckTime,1)
	.;s:CheckDate'="" CheckDate=CheckDate_" "_CheckTime
	i (%session.Get("LOGON.GROUPDESC"))[("特殊")  d
	.i (CurStatus="1")&&((status="OC")||(status="P")) d
	..w "<Table><tr><td>"
	..w "<input type='button' id='"_OEID_"' name='ActiveButton' value='完成("_StatusDesc_")' onclick='CompleteItem();'>"
	..w "<input size=10 id='D"_OEID_"' value="_CheckDate_">"
	..w "</td></tr></Table>"
	.e  i (status="OC")||(status="P")  d
	..w "<Table><tr><td>"
	..w "<input type='button' id='"_OEID_"' name='ActiveButton' value='取消完成' onclick='UnCompleteItem();'>"
	..w "<input size=10 disabled id='D"_OEID_"' value="_CheckDate_">"
	..w "</td></tr></Table>"
	
	e  d
	.i (CurStatus="1")&&((status="OC")||(status="P")) d
	..w "未完成 "_CheckDate
	.e  i (status="OC")||(status="P")  d
	..w "已完成 "_CheckDate
	
	Quit $$$OK
}

ClassMethod OutReportButton(OEID)
{
	;d ##class(web.DHCPE.FetchReport).OutCompleteButton(OEID)
	s CurStatus=$P(OEID,"^",2)
	s OEID=$P(OEID,"^",1)
	w:OEID="" "医嘱ID为空"
	q:OEID="" 
	
	s CRMORowId=$o(^DHCPECRMO(0,"OEORI",OEID,0))
	s status=$p(^DHCPECRMO(CRMORowId),"^",4)
	s StatusDesc=CurStatus
	w:CurStatus="3" "医嘱已谢绝检查"
	q:CurStatus="3" 
	s CheckDate=""
	i $D(^DHCPESpecial("DHCPE","Report",OEID)) d
	.s CheckDate=$P(^DHCPESpecial("DHCPE","Report",OEID),"^",2)
	.s:CheckDate'="" CheckDate=##class(websys.Conversions).DateLogicalToHtml(CheckDate)
	i (%session.Get("LOGON.GROUPDESC"))[("特殊")  d
	.i '$D(^DHCPESpecial("DHCPE","Report",OEID)) d
	..w "<Table><tr><td>"
	..w "<input type='button' id='"_OEID_"' name='ReportButton' value='报告' onclick='ReportItem();'>"
	..w "<input size=10 id='R"_OEID_"' value="_CheckDate_">"
	..w "</td></tr></Table>"
	.e  d
	..w "<Table><tr><td>"
	..w "<input type='button' id='"_OEID_"' name='ReportButton' value='取消报告' onclick='UnReportItem();'>"
	..w "<input size=10 disabled id='R"_OEID_"' value="_CheckDate_">"
	..w "</td></tr></Table>"
	e  d
	.i '$D(^DHCPESpecial("DHCPE","Report",OEID)) d
	..w "无报告"_CheckDate
	.e  d
	..w "已报告"_CheckDate
	
	Quit $$$OK
}

ClassMethod ChangeDate(ComDate)
{
	s $ZT="DateErr"
	//q $ZDH(ComDate,3)
	q ##class(websys.Conversions).DateHtmlToLogical(ComDate) 
DateErr
	q ""
}

// d ##class(web.DHCPE.FetchReport).UpdateComplete("","")

ClassMethod UpdateComplete(OEID, Type)
{
	s curUser=%session.Get("LOGON.USERID")
	s ComDate=$P(OEID,"^",2)
	s OEID=$P(OEID,"^",1)
	s EpisodeID=$P(^OEORD(+OEID),"^",1)
	s arcimId=$p(^OEORD(+OEID,"I",$p(OEID,"||",2),1),"^",2)
	s ODRID=$o(^DHCPEODR(0,"ARCIM",arcimId,0))
	s ODID=""
	i ODRID'="" s ODID=$p(^DHCPEODR(ODRID),"^",2)
	i ODID="" s ODID="a||b"
	s ResultStr="临床诊断:"
	s Result="详见报告"
	s:Type="0" Result=""
	s ResultStr=ResultStr_";检查所见:"
	s ResultStr=ResultStr_";诊断意见:"_Result
	i ComDate="" d
	.s CurDate=+$H
	e  d
	.s CurDate=..ChangeDate(ComDate)
	q:CurDate="" "日期格式不正确,应该为'YYYY-MM-DD'"
	s CurTime=$P($H,",",2)
	s ret=##class(web.DHCPE.ResultEdit).UpdateRisResult(EpisodeID, OEID, ResultStr, curUser)
	;s CurDate=+$H
	s CurTime=$P($H,",",2)
	i (Type="1")  d
	.s ^DHCPESpecial("DHCPE","UserID",OEID)=curUser_"^"_CurDate_"^"_CurTime
	.s ^DHCPESpecial("DHCPE","DateIndex",CurDate,CurTime,OEID)=""
	i Type="0"  d
	.s Info=$G(^DHCPESpecial("DHCPE","UserID",OEID))
	.i Info'="" d
	..s Date=$P(Info,"^",2)
	..i Date'="" d
	...s Time=$P(Info,"^",3)
	...k ^DHCPESpecial("DHCPE","DateIndex",Date,Time,OEID)
	.k ^DHCPESpecial("DHCPE","UserID",OEID) 
	q ""
}

// d ##class(web.DHCPE.FetchReport).UpdateComplete("","")

ClassMethod UpdateReport(OEID, Type)
{
	s curUser=%session.Get("LOGON.USERID")
	s ComDate=$P(OEID,"^",2)
	s OEID=$P(OEID,"^",1)
	s EpisodeID=$P(^OEORD(+OEID),"^",1)
	i ComDate="" d
	.s CurDate=+$H
	e  d
	.s CurDate=..ChangeDate(ComDate)
	q:CurDate="" "日期格式不正确,应该为'YYYY-MM-DD'"
	s CurTime=$P($H,",",2)
	i (Type="1")  d
	.s ^DHCPESpecial("DHCPE","Report",OEID)=curUser_"^"_CurDate_"^"_CurTime
	.s ^DHCPESpecial("DHCPE","ReportDateIndex",CurDate,CurTime,OEID)=""
	i Type="0"  d
	.s Info=$G(^DHCPESpecial("DHCPE","Report",OEID))
	.i Info'="" d
	..s Date=$P(Info,"^",2)
	..i Date'="" d
	...s Time=$P(Info,"^",3)
	...k ^DHCPESpecial("DHCPE","ReportDateIndex",Date,Time,OEID)
	.k ^DHCPESpecial("DHCPE","Report",OEID) 
	q ""
}

ClassMethod GetReportStatusNew(PAADM)
{
	;##class(web.DHCPE.FetchReport)GetReportStatusNew(PAADM)
	q:PAADM="" "" 
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" "0&收表^0&黏贴^0&初检^0&复检^0&打印^0&已取"
	
	s PIADM=$P(^DHCPEIADM(IADM),"^",4)
	s RecFlag=0
	s:$D(^DHCPEDataEx("DHCPEPreIADM","GetReportDateTime","I",PIADM)) RecFlag=1
	s SendAudit=0
	s:$D(^User.DHCPESendAuditI("AdmIndex",PAADM)) SendAudit=1
	s GSID=$O(^DHCPEGS(0,"IADM",IADM,0))
	s AuditUser=""
	i GSID'="" d
	.s AuditUser=$P(^DHCPEGS(GSID,1),"^",5)
	s ReportAudit=0
	s:AuditUser'="" ReportAudit=1
	s MainAudit=0
	s:$D(^DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",PAADM)) MainAudit=1
	s PrintFlag=""
	s SendFlag=0
	s ReportID=$O(^DHCPERPT(0,"IADM",IADM,0))
	i ReportID'="" d
	.s Status=$P(^DHCPERPT(ReportID),"^",2)
	.i Status="S" d
	..s PrintFlag="1"
	..s SendFlag="1"
	.e  i Status="P" d
	..s PrintFlag="1"
	.e  i Status="C" d
	..s PrintFlag="1"
	s:PrintFlag="1" PrintFlag=$P(^DHCPERPT(ReportID),"^",7)
	s:PrintFlag'="" PrintFlag=##class(websys.Conversions).DateLogicalToHtml(PrintFlag)   
	q RecFlag_"&收表"_"^"_SendAudit_"&黏贴"_"^"_ReportAudit_"&初检"_"^"_MainAudit_"&复检"_"^"_PrintFlag_"&打印"_"^"_SendFlag_"&已取"
}

ClassMethod GetReportStatus(PAADM)
{
	;##class(web.DHCPE.FetchReport).GetReportStatus(PAADM)
	q:PAADM="" ""
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:IADM="" "0^0^0^0^0^0^0^0^0^0^0^0"
	s PIADM=$P(^DHCPEIADM(IADM),"^",4)
	s RecFlag=0
	s:$D(^DHCPEDataEx("DHCPEPreIADM","GetReportDateTime","I",PIADM)) RecFlag=1
	s SendAudit=0
	s:$D(^User.DHCPESendAuditI("AdmIndex",PAADM)) SendAudit=1
	s GSID=$O(^DHCPEGS(0,"IADM",IADM,0))
	s AuditUser=""
	i GSID'="" d
	.s AuditUser=$P(^DHCPEGS(GSID,1),"^",5)
	s ReportAudit=0
	s:AuditUser'="" ReportAudit=1
	s MainAudit=0
	s:$D(^DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",PAADM)) MainAudit=1
	s PrintFlag=""
	s SendFlag=0
	s ReportID=$O(^DHCPERPT(0,"IADM",IADM,0))
	i ReportID'="" d
	.s Status=$P(^DHCPERPT(ReportID),"^",2)
	.i Status="S" d
	..s PrintFlag="1"
	..s SendFlag="1"
	.e  i Status="P" d
	..s PrintFlag="1"
	.e  i Status="C" d
	..s PrintFlag="1"
	s:PrintFlag="1" PrintFlag=$P(^DHCPERPT(ReportID),"^",7)
	s:PrintFlag'="" PrintFlag=##class(websys.Conversions).DateLogicalToHtml(PrintFlag)
	q RecFlag_"^"_SendAudit_"^"_ReportAudit_"^"_MainAudit_"^"_PrintFlag_"^"_SendFlag
}

ClassMethod OutReportStatus(PAADM)
{
	q:PAADM="" ""
	s ReportStatus=..GetReportStatus(PAADM)
	w "<table><TR>"
	i $P(ReportStatus,"^",1)=1 d
	.s checked="checked"
	e  d
	.s checked=""
	w "<TD><label>收表</label><input type='checkbox' disabled "_checked_"></TD>"
	
	i $P(ReportStatus,"^",2)=1 d
	.s checked="checked"
	e  d
	.s checked=""
	w "<TD><label>&nbsp;&nbsp;&nbsp;&nbsp;粘贴</label><input type='checkbox' disabled "_checked_"></TD>"
	
	i $P(ReportStatus,"^",3)=1 d
	.s checked="checked"
	e  d
	.s checked=""
	w "<TD><label>总检</label><input type='checkbox' disabled "_checked_"></TD>"
	
	i $P(ReportStatus,"^",4)=1 d
	.s checked="checked"
	e  d
	.s checked=""
	w "</TR><TR><TD><label>复检</label><input type='checkbox' disabled "_checked_"></TD>"
	i $P(ReportStatus,"^",5)'="" d
	.s checked="checked"
	e  d
	.s checked=""
	w "<TD><label>已打印</label><input type='checkbox' disabled "_checked_"></TD>"
	i $P(ReportStatus,"^",6)=1 d
	.s checked="checked"
	e  d
	.s checked=""
	w "<TD><label>已取</label><input type='checkbox' disabled "_checked_"></TD>"
	w "</TR></table>"
}

ClassMethod OutResultLink(PAADM)
{
	q:PAADM=""
	s lnk="../csp/websys.default.csp?WEBSYS.TCOMPONENT=DHCPENewDiagnosis&EpisodeID="_PAADM_"&OnlyRead=Y"
	w "<a href="_lnk_" target='_blank' >结果预览</a><br>"
	s lnk="../csp/dhcpeireport.normal.csp?PatientID="_PAADM_"&OnlyRead=Y"
	w "<a href="_lnk_" target='_blank' >报告预览</a><br>"
	s lnk="websys.default.csp?WEBSYS.TCOMPONENT=DHCPEContrastWithLast&PAADM="_PAADM
	w "<a href="_lnk_" target='_blank' >结果比对</a>"
}

ClassMethod GetComNumByDate(Date, User)
{
	//s Date=EndDate+1
	;w ##class(web.DHCPE.FetchReport).GetComNumByDate(+$H-1,"")
	s ComNum=0
	s ID=0
	f  s ID=$O(^User.DHCPESendAuditI("SendDateIndex",Date,ID)) q:(ID="")  d
	.s CurPAADM=$LG(^User.DHCPESendAuditD(ID),2)
	.s CurIADM=$O(^DHCPEIADM(0,"PAADM",CurPAADM,0))
	.q:CurIADM=""
	.s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PEADM",CurIADM)
    .q:LocFlag=1
	.s TSendUser=$LG(^User.DHCPESendAuditD(ID),3)
	.q:(User'="")&&(TSendUser'=User)
	.s ComNum=ComNum+1
	q ComNum
}

ClassMethod UpdateFetchReportInfo(Instring, Flag)
{
	s User=%session.Get("LOGON.USERID")
	s Date=+$H
	s Time=$P($H,",",2)
	i Flag="1"  d
	.s ReportID=$P(Instring,"^",1)
	.s Name=$P(Instring,"^",2)
	.s Tel=$P(Instring,"^",3)
	.s IDCard=$P(Instring,"^",4)
	.s ^DHCPEDataEx("FetchReport","Detail",ReportID)=Name_"^"_Tel_"^"_IDCard_"^"_User_"^"_Date_"^"_Time
	i Flag="0"  d
	.k ^DHCPEDataEx("FetchReport","Detail",ReportID)
	Q 0
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.FetchReport","SearchFetchReportDetail","4746")
Query SearchFetchReportDetail(ReportID As %String = "") As %Query(ROWSPEC = "TReportID:%String,TName:%String,TTel:%String,TIDCard:%String")
{
}

ClassMethod SearchFetchReportDetailExecute(ByRef qHandle As %Binary, ReportID As %String = "") As %Status
{
   
	Set repid=$I(^CacheTemp)
	s ind=1
	s ID="",Name="",Tel="",IDCard=""
	if ($d(^DHCPEDataEx("FetchReport","Detail",ReportID))) d
	.s Data=$g(^DHCPEDataEx("FetchReport","Detail",ReportID))
	.s Name=$P(Data,"^",1)
	.s Tel=$P(Data,"^",2)
	.s IDCard=$P(Data,"^",3)
	.s ID=ReportID
	.d OutPutDetail
	
	Set qHandle=$lb(0,repid,0) 
	Quit $$$OK

OutPutDetail
	set Data=$lb(ID,Name,Tel,IDCard) 
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SearchFetchReportDetailFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SearchFetchReportDetailExecute ]
{
	
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else{			
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind) 
	Quit $$$OK
}

ClassMethod SearchFetchReportDetailClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SearchFetchReportDetailExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

Storage Default
{
<Data name="FetchReportDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.FetchReportD</DataLocation>
<DefaultData>FetchReportDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.FetchReportD</IdLocation>
<IndexLocation>^web.DHCPE.FetchReportI</IndexLocation>
<StreamLocation>^web.DHCPE.FetchReportS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
