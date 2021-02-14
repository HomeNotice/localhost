Class web.DHCPE.ReportGetInfor Extends %Library.RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

Parameter BUILD = 335;

/// d ##Class(web.DHCPE.ReportGetInfor).GetReportInfo()
ClassMethod GetReportInfo()
{
	Q ""
}

/// 取得患者信息GetPatientInfo()
/// 使用：
/// 	dhcpesendsms.csp	短信发送
/// 	
/// 	
/// d ##Class(web.DHCPE.ReportGetInfor).GetPatient()
ClassMethod GetPatient(PAAdmRowid As %String, UserID As %String)
{
    //Set UserID=%session.Get("LOGON.USERID")
    s:UserID="" UserID=PAAdmRowid
	Q:(""=PAAdmRowid) "0"
	k ^TMPReport(UserID,"PatInfo")
	s PAPMIdr=$p(^PAADM(PAAdmRowid),"^",1)
	// DHC_PE_IADM.{ IADM_RowId }
	s IADMDR=$O(^DHCPEIADM(0,"PAADM",PAAdmRowid,0))
	i IADMDR="" d
	.d ..GetPatientByPAADM(PAAdmRowid)
	Q:(""=IADMDR) "1"
	
	s CurData=$G(^DHCPEIADM(IADMDR))
	// DHC_PE_IADM.{ IADM_AdmDate } 体检日期
	s AdmDate=$P(CurData,"^",5)
	s ArrDate=+AdmDate
	s:(""'=AdmDate) AdmDate=$ZD(AdmDate,3)
	s ^TMPReport(UserID,"PatInfo","AdmDate")=""
	s:(""'=AdmDate) ^TMPReport(UserID,"PatInfo","AdmDate")=AdmDate
	
	// DHC_PE_IADM.{ IADM_CRMADM } = DHC_PE_PreIADM.{ PIADM_RowId }
	s PIADMDR=$P(CurData,"^",4)
	Q:(""=PIADMDR) "0"
	
	
	s CurData=$G(^DHCPEPreIADM(PIADMDR))
	s VIPLevel=$P(CurData,"^",18)
	s:VIPLevel'="" VIPLevel=$P($G(^DHCPEVIPLevel("VIP",VIPLevel)),"^",2)
	s ^TMPReport(UserID,"PatInfo","VIPLevel")=VIPLevel
	// DHC_PE_PreIADM.{ PIADM_PIBI_DR } = DHC_PE_PreIBaseInfo.{  }
	s PIBIDR=$P(CurData,"^",1)
	Q:(""=PIBIDR) "0"
	s OrderSetsDesc=##class(web.DHCPE.Query.IAdmItemStatus).GetArcSetDesc(PIADMDR)
	s ^TMPReport(UserID,"PatInfo","OrderSetsDesc")=OrderSetsDesc
	s GADM=$P(CurData,"^",2)
	
	s HPNo=$P(CurData,"^",27)
	s ^TMPReport(UserID,"PatInfo","PatRegNo")=HPNo	
	
	s TeamID=$P(CurData,"^",3)
	i TeamID'="" d
	.s Char=##class(web.DHCPE.PreIADM).NumToChar($p(TeamID,"||",2))
	.s SortNo=Char_$G(^DHCPEDataEx("DHCPEPreIADM","GTEAM","IADM",PIADMDR))
	e  d
	.s SortNo=""
	s CurData=$G(^DHCPEPreIBI(PIBIDR))
	// PIBI_PAPMINo		登记号
	s PAPMINo=$p(CurData,"^",1)
	
	
		s ^TMPReport(UserID,"PatInfo","PatHPNo")=PAPMINo
	
	// PIBI_Name	姓名
	s Name=$p(CurData,"^",2)
	s ^TMPReport(UserID,"PatInfo","PatName")=Name
	
	// PIBI_Sex_DR = CT_Sex.{}	性别
	s SexDR=$p(CurData,"^",3)
	s:(""'=SexDR) ^TMPReport(UserID,"PatInfo","PatSexDR")=$p(^CT("SEX",SexDR),"^",1)
	s:(""'=SexDR) SexDRName=$p(^CT("SEX",SexDR),"^",2)
	s ^TMPReport(UserID,"PatInfo","PatSex")=SexDRName


	// PIBI_DOB		出生日期
	s Dob=$p(CurData,"^",4)
 	i Dob'="" s PAPERDob=$ZD(Dob,3)
 	s ^TMPReport(UserID,"PatInfo","PatBirthday")=Dob
 	i ArrDate=0 s ArrDate=+$h
 	// 年龄 
 	s Age=""
 	s:(""'=Dob) Age=##class(web.DHCBillInterface).GetPapmiAge(PAPMIdr,PAAdmRowid)
 	//s:(""'=Dob) Age=##class(web.DHCLCNUREXCUTE).CalAge(Dob,ArrDate)
 	s Age=$P(Age,"Y")
 	//s ^TMPReport(UserID,"PatInfo","PatAge")=Age_" 岁"
 	s ^TMPReport(UserID,"PatInfo","PatAge")=Age
	
	// PIBI_PatType_DR 客户类型
	s PatTypeDR=$p(CurData,"^",5)
 	s ^TMPReport(UserID,"PatInfo","PatType")=PatTypeDR
	
	// PIBI_Tel1 电话1 
	s Tel1=$p(CurData,"^",6)
 	s ^TMPReport(UserID,"PatInfo","PatTel1")=Tel1
	
	// PIBI_Tel2 电话1
	s Tel2=$p(CurData,"^",7)
 	s ^TMPReport(UserID,"PatInfo","PatTel2")=Tel2
	
	// PIBI_MobilePhone 手机
	s MobilePhone=$p(CurData,"^",8)
 	s ^TMPReport(UserID,"PatInfo","MobilePhone")=MobilePhone
	s MobilePhone=##class(web.DHCPE.PreCommon).GetTelNo("PIBI",PIBIDR)
	s:(""'=Tel1) ^TMPReport(UserID,"PatInfo","PatTel")=Tel1
	s:(""'=MobilePhone) ^TMPReport(UserID,"PatInfo","PatTel")=MobilePhone
	
	
	// PIBI_IDCard 身份证号
	s IDCard=$p(CurData,"^",9)
 	s ^TMPReport(UserID,"PatInfo","PatID")=IDCard
	
	// PIBI_Vocation 职业
	s Vocation=$p(CurData,"^",10)
 	s ^TMPReport(UserID,"PatInfo","Vocation")=Vocation

	// PIBI_Position 职位
	s Position=$p(CurData,"^",11)
 	s ^TMPReport(UserID,"PatInfo","Position")=Position
 	i Position'="" s Position="["_Position_"]"
 	
 	// PIBI_Company	工作单位
 	i GADM="" d
 	.s Company=$p(CurData,"^",12)
 	.i (Company="")&&($G(^DHCPESetting("DHCPE","HospitalCode"))="SYYD") s Company="个人"
 	e  d
 	.s PreGBaseInfo=$p(^DHCPEPreGADM(GADM),"^",1)
 	.s Company=$p(^DHCPEPreGBI(PreGBaseInfo),"^",2)
 	.
 	s ^TMPReport(UserID,"PatInfo","PatCompany")=Company_Position
	
 	// PIBI_Postalcode	邮编
 	s Postalcode=$p(CurData,"^",13)
 	s ^TMPReport(UserID,"PatInfo","Postalcode")=Postalcode
 	
 	// PIBI_Address	地址
 	s Address=$p(CurData,"^",14)
 	s ^TMPReport(UserID,"PatInfo","PatAddress")=Address
 	
 	
	// PIBI_Nation 民族
	s Nation=$p(CurData,"^",15)
 	s ^TMPReport(UserID,"PatInfo","Nation")=Nation
 	
	// PIBI_Email 电子邮件
	s Email=$p(CurData,"^",16)
 	s ^TMPReport(UserID,"PatInfo","Email")=Email
 	
	// PIBI_Married_DR 婚姻状况
	s MarriedDR=$p(CurData,"^",17)
 	s ^TMPReport(UserID,"PatInfo","Married")=MarriedDR
  	
	// PIBI_Blood_DR	血型
	s BloodDR=$p(CurData,"^",18)
 	s ^TMPReport(UserID,"PatInfo","Blood")=BloodDR	
 	 	
 	Q 1
}

ClassMethod GetPatientByPAADM(PAAdmRowid)
{
	s PAPMIdr=$p(^PAADM(PAAdmRowid),"^",1)
	s AdmDate=$p(^PAADM(PAAdmRowid),"^",6)
	s ArrDate=+AdmDate
	s:(""'=AdmDate) AdmDate=$ZD(AdmDate,3)
	s ^TMPReport(UserID,"PatInfo","AdmDate")=""
	s:(""'=AdmDate) ^TMPReport(UserID,"PatInfo","AdmDate")=AdmDate
	Q:(""=PAPMIdr) "0"
	
	// PAPER_Name	姓名
	s PAPERName=$p(^PAPER(PAPMIdr,"ALL"),"^",1)		
	s ^TMPReport(UserID,"PatInfo","PatName")=PAPERName
	Q:(""=PAPERName) 0
	
	// PAPER_Sex_DR	性别
	s PAPERSexDR=$p(^PAPER(PAPMIdr,"ALL"),"^",7)
	i PAPERSexDR'="" s PAPERSexDRName=$p(^CT("SEX",PAPERSexDR),"^",2)
	s ^TMPReport(UserID,"PatInfo","PatSex")=PAPERSexDRName

	// PAPER_No		登记号
	s PAPERNo=$p(^PAPER(PAPMIdr,"PAT",1),"^",1)
	s ^TMPReport(UserID,"PatInfo","PatRegNo")=PAPERNo

	// PAPER_Dob		出生日期
	s PAPERDob=$p(^PAPER(PAPMIdr,"ALL"),"^",6)
 	// 年龄 
 	s Age=""
 	s Age=##class(web.DHCBillInterface).GetPapmiAge(PAPMIdr,PAAdmRowid)
 	//s:(""'=PAPERDob) Age=+##class(web.DHCLCNUREXCUTE).CalAge(PAPERDob,+$h)
	s ^TMPReport(UserID,"PatInfo","PatAge")=Age
	i PAPERDob'="" s PAPERDob=$ZD(PAPERDob,3)
 	s ^TMPReport(UserID,"PatInfo","PatBirthday")=PAPERDob
 	
	// PAPER_TelH	电话号码
	s PAPERTelH=$p(^PAPER(PAPMIdr,"PER",1),"^",1)
	s ^TMPReport(UserID,"PatInfo","PatTel")=PAPERTelH

	// PAPER_ID		身份证号
	s PAPERID=$p(^PAPER(PAPMIdr,"ALL"),"^",9)
	s ^TMPReport(UserID,"PatInfo","PatID")=PAPERID

 	// PAPER_SecondPhone	工作单位
 	s PAPERSecondPhone=$p(^PAPER(PAPMIdr,"PER",4),"^",1)
 	s ^TMPReport(UserID,"PatInfo","PatCompany")=PAPERSecondPhone

 	// PAPER_StName	地址
 	s PAPERStName=$g(^PAPER(PAPMIdr,"PER","ADD"))
 	s ^TMPReport(UserID,"PatInfo","PatAddress")=PAPERStName
 	
 	Q 1
}

/*
/// 取得患者信息GetPatientInfo()
/// d ##Class(web.DHCPE.ReportGetInfor).GetPatient()
ClassMethod GetPatient(PAAdmRowid As %String)
{
	k ^TMPReport(UserID,"PatInfo")
	s PAPMIdr=$p(^PAADM(PAAdmRowid),"^",1)
	Q:(""=PAPMIdr) "0"
	
	// PAPER_Name	姓名
	s PAPERName=$p(^PAPER(PAPMIdr,"ALL"),"^",1)		
	s ^TMPReport(UserID,"PatInfo","PatName")=PAPERName
	Q:(""=PAPERName) 0
	
	// PAPER_Sex_DR	性别
	s PAPERSexDR=$p(^PAPER(PAPMIdr,"ALL"),"^",7)
	i PAPERSexDR'="" s PAPERSexDRName=$p(^CT("SEX",PAPERSexDR),"^",2)
	s ^TMPReport(UserID,"PatInfo","PatSex")=PAPERSexDRName

	// PAPER_No		登记号
	s PAPERNo=$p(^PAPER(PAPMIdr,"PAT",1),"^",1)
	s ^TMPReport(UserID,"PatInfo","PatRegNo")=PAPERNo

	// PAPER_Dob		出生日期
	s PAPERDob=$p(^PAPER(PAPMIdr,"ALL"),"^",6)
 	i PAPERDob'="" s PAPERDob=$ZD(PAPERDob,3)
 	s ^TMPReport(UserID,"PatInfo","PatBirthday")=PAPERDob
 	// 年龄 
 	s Age=""
 	s:(""'=PAPERDob) Age=##class(web.DHCLCNUREXCUTE).CalAge(PAPERDob,+$h)
	s ^TMPReport(UserID,"PatInfo","PatAge")=Age
	
	// PAPER_TelH	电话号码
	s PAPERTelH=$p(^PAPER(PAPMIdr,"PER",1),"^",1)
	s ^TMPReport(UserID,"PatInfo","PatTel")=PAPERTelH

	// PAPER_ID		身份证号
	s PAPERID=$p(^PAPER(PAPMIdr,"ALL"),"^",9)
	s ^TMPReport(UserID,"PatInfo","PatID")=PAPERID

 	// PAPER_SecondPhone	工作单位
 	s PAPERSecondPhone=$p(^PAPER(PAPMIdr,"PER",4),"^",1)
 	s ^TMPReport(UserID,"PatInfo","PatCompany")=PAPERID

 	// PAPER_StName	地址
 	s PAPERStName=$g(^PAPER(PAPMIdr,"PER","ADD"))
 	s ^TMPReport(UserID,"PatInfo","PatAddress")=PAPERID
 	
 	Q 1
}

*/
/// 获得体检结果表	DHC_PE_Result
/// d ##Class(web.DHCPE.ReportGetInfor).GetReportResult(5748147)
ClassMethod GetReportResult(PAAdmRowid As %String, UserID As %String)
{
   	//s UserID=%session.Get("LOGON.USERID")
   	s:UserID="" UserID=PAAdmRowid
	s LisNewVersion=$g(^DHCPESetting("DHCPE","LisNewVersion"))
	d ..GetHistoryResult(PAAdmRowid, "", "")
   	k ^TMPReport(UserID,"Result")
	;k ^TMPReport(UserID,"HistoryResult")
	k ^TMPReport(UserID,"LabSpecNo")
	k ^TMPReport(UserID,"GetResultByLoc")
	k ^TMPReport(UserID,"NoResult")
	k ^TMPReport(UserID,"RefuseCheck")
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	
	s PAPMIdr=$p(^PAADM(PAAdmRowid),"^",1)
	Q:(""=PAPMIdr) "0"
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAAdmRowid,0))
	// PAPER_Sex_DR	性别
	//s PAPERSexDR=$p(^PAPER(PAPMIdr,"ALL"),"^",7)
	s ^TMPReport(UserID,"Result","Sex")=$G(^TMPReport(UserID,"PatInfo","PatSexDR"))
	
	// PAPER_Dob		出生日期
	//s PAPERDob=$p(^PAPER(PAPMIdr,"ALL"),"^",6)
 	//i PAPERDob'="" s PAPERDob=$ZD(PAPERDob,3)
 	//s Age=""
 	//s:(""'=PAPERDob) Age=##class(web.DHCLCNUREXCUTE).CalAge(PAPERDob,+$h)
 	//s Age=+$P(Age,"Y")
    s ^TMPReport(UserID,"Result","Age")=$G(^TMPReport(UserID,"PatInfo","PatAge"))

	///得到既往病史等内容
	s ODStr=$G(^DHCPESetting("DHCPE","ODStr"))
	s i=$L(ODStr,"^")
	f j=1:1:i
	{
		
		s ODDR=$p(ODStr,"^",j)
		Continue:ODDR=""
		s RLID=0
		s ResultStr=""
		f  s RLID=$o(^DHCPERLT(0,"PAADM_OD",PAAdmRowid,ODDR,RLID)) q:RLID=""  d
		.s Result=$p(^DHCPERLT(RLID),"^",4)
		.i Result'="" s ResultStr=ResultStr_Result_" "
		s Split="JZS"
		i j=1 s Split="YWGMS"
		i j=2 s Split="JWS"
		i j=3 s Split="JZS"
		
		s ^TMPReport(UserID,"PatInfo",Split)=ResultStr
	}
	s LisMerge=$G(^DHCPESetting("DHCPE","LisReportMerge"))
	s FKOrderID=..GetFKOrder(PAAdmRowid,4)
	s YKOrderID=..GetFKOrder(PAAdmRowid,5)
	s COrderID=$O(^OEORD(0,"Adm",PAAdmRowid,0))
	s FKFlag=0
	s YKFlag=0
	q:COrderID="" ""
	s COrderSub="0"
	f  s COrderSub=$O(^OEORD(COrderID,"I",COrderSub)) q:COrderSub=""  d
	.s Stat=$P($g(^OEORD(COrderID,"I",COrderSub,1)),"^",13)
	.q:Stat="4"
	.s PayedFlag=$P($g(^OEORD(COrderID,"I",COrderSub,3)),"^",5)
	.q:(PayedFlag'="P")&&(IADM'="")
	.s TestId=COrderID_"||"_COrderSub
	.//f  s TestId=$o(^DHCPERLT(0,"ADMOD", PAAdmRowid, TestId)) q:(""=TestId)  d
	.;s CRMID=$O(^DHCPECRMO(0,"OEORI",TestId,0))
	.;q:CRMID=""
	.;s ItemID=$p(^DHCPECRMO(CRMID),"^",2)
	.;q:ItemID=""
	.;s ItemStat=$p(^DHCPEPreIADM(+ItemID,"ORDITEM",$P(ItemID,"||",2)),"^",16)
	.;q:ItemStat'="1"
	.s OEORDRowId=$P(TestId,"||",1) // OE_Order.OEORD_RowId
	.s OEORIChildsub=$P(TestId,"||",2) // OE_Order.OEORI_Childsub
	.//在报告上不打印某些医嘱
	.s NoPrintFlag=""
	.s NoPrintFlag=$g(^DHCPEDataEx("DHCPEOrdItem","NotPrint",TestId))
	.q:NoPrintFlag="Y"
	.s ARCIMDR=$P($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",2)
	.Q:(""=ARCIMDR)
	.//RLT_ARCIM_DR 医嘱项目
	.s ARCIMSubScript=$p(ARCIMDR,"||",1)	//ARCIM_Desc 医嘱名称 Arc_ItmMast
	.s ARCIMVersion=$p(ARCIMDR,"||",2)
	.s ARCIMCode=$p($g(^ARCIM(ARCIMSubScript,ARCIMVersion,1)),"^",1)
	.s ARCIMDesc=$p($g(^ARCIM(ARCIMSubScript,ARCIMVersion,1)),"^",2)
	.//s ARCIMDesc=$p(ARCIMDesc,"(",1)
	.// 获取打印格式
	.s STRowId=0
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, STRowId))
	.Q:(""=STRowId)
	.Q:STRowId=$G(^DHCPESetting("DHCPE","StationId_Other"))
	.//站点顺序
	.s STSequence=$p(^DHCPEST(STRowId),"^",9)
	.q:STSequence=""
	.//项目顺序
	.s ARCSequence=$G(^DHCPEDataEx("DHCPEStationOrder","Sequence",ARCIMDR))
	.i ARCSequence="" d
	..s ARCSequence="999999999"
	..s LocInfo=$G(^DHCPEStationOrder("Loc",ARCIMDR))
	..s LocID=$P(LocInfo,"^",1)
	..i LocID'=""  d
	...s ARCSequence=$P($g(^DHCPEST(+LocID,"STLOC",$P(LocID,"||",2))),"^",2)
	...s:ARCSequence="" ARCSequence="999999999"
	..e  d
	...s ARCSequence="999999999"
	.s STORDChildSub=0
	.s STORDChildSub=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, STRowId, STORDChildSub))
	.Q:(""=STORDChildSub)
	.;s CrmSets=$p(^DHCPEPreIADM(+ItemID,"ORDITEM",$P(ItemID,"||",2)),"^",2)
	.s CrmSets=$P($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",1)
	.i CrmSets="" d
	..i $D(^TMPReport(UserID,"Result","AddItem")) d
	...s ^TMPReport(UserID,"Result","AddItem")=^TMPReport(UserID,"Result","AddItem")_"、"_ARCIMDesc
	..e  d
	...s ^TMPReport(UserID,"Result","AddItem")=ARCIMDesc
	.s ReportFormat=$P(^DHCPEST(STRowId,"O",STORDChildSub),"^",4)
	.s:(""=ReportFormat) ReportFormat="RF_NOR"
	.s RFlag=0
	.i (ReportFormat[("RIS")) s RFlag=..GetRisARCDesc(TestId)
	.q:RFlag="1"
	.// 报告单属性 检验人/检查人 体检日期
	.s LabSpecNo=$p($G(^OEORD(+TestId,"I",$P(TestId,"||",2),3)),"^",20)
  	.s QFlag=0
  	.s STRowId=0                                                       //add by zl start
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, STRowId))
	.Q:(""=STRowId)                                                    //add by zl end
  	.
  	.i $D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",TestId)) d
   	..s RefuseSort=$I(^TMPReport(UserID,"RefuseCheck",STSequence,STRowId,ARCSequence))
   	..s ^TMPReport(UserID,"RefuseCheck",STSequence,STRowId,ARCSequence,RefuseSort)=ARCIMDesc
  	..s ARCIMDesc=ARCIMDesc_"（放弃）"
  	..s QFlag=1
  	.;q:QFlag=1
  	.i '$D(^DHCPERLT(0,"ADMOD", PAAdmRowid, TestId)) d
  	..s RefuseSort=$I(^TMPReport(UserID,"NoResult",STSequence,STRowId,ARCSequence))
   	..s ^TMPReport(UserID,"NoResult",STSequence,STRowId,ARCSequence,RefuseSort)=ARCIMDesc
  	..s QFlag=1
  	.q:'$D(^DHCPERLT(0,"ADMOD", PAAdmRowid, TestId))
  	.;q:QFlag=1
  	.s SpecItem=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ARCIMDR))
  	.s PrintFlag=..NeedPrintInReport(TestId)
  	.q:PrintFlag=0
  	.;q:(SpecItem="Y")&&(LabSpecNo="")&&(STRowId'=9)
  	.//为了协和化验接口数据都传入到一个医嘱上使用
  	.q:(LisMerge="Y")&&(LabSpecNo'="")&&($D(^TMPReport(UserID,"LabSpecNo",LabSpecNo)))
  	.s:(LisMerge="Y")&&(LabSpecNo'="") ^TMPReport(UserID,"LabSpecNo",LabSpecNo)=""
  	.s:(LisMerge="Y")&&(LabSpecNo'="") ARCIMDesc=##class(web.DHCPE.ResultDiagnosis).GetAllNameBySpecNo(LabSpecNo)
  	.s ExTestID=""
  	.i STRowId="4" d
  	..s ARCIMDesc="妇科"
  	..q:FKFlag=1
  	..s FKFlag=1
  	..s ExTestID=$P(FKOrderID,"^",1)
  	..s Length=$L(FKOrderID,"^")
  	..f FKSort=1:1:Length  d
  	...s OneOrder=$P(FKOrderID,"^",FKSort)
  	...s OneArcID=$P($G(^OEORD(+OneOrder,"I",$P(OneOrder,"||",2),1)),"^",2)
  	...d ..GetRISResult(PAAdmRowid,OneOrder, OneArcID,ExTestID)
  	.e  i STRowId="5" d
  	..s ARCIMDesc="眼科"
  	..q:YKFlag=1
  	..s YKFlag=1
  	..s ExTestID=$P(YKOrderID,"^",1)
  	..s Length=$L(YKOrderID,"^")
  	..f FKSort=1:1:Length  d
  	...s OneOrder=$P(YKOrderID,"^",FKSort)
  	...s OneArcID=$P($G(^OEORD(+OneOrder,"I",$P(OneOrder,"||",2),1)),"^",2)
  	...d ..GetRISResult(PAAdmRowid,OneOrder, OneArcID,ExTestID)
  	
  	.e  d
  	..d:(ReportFormat["LIS") ..GetLISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["NOR") ..GetRISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["RIS") ..GetRISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["CAT") ..GetLISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["EKG") ..GetRISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["PIS") ..GetRISResult(PAAdmRowid,TestId, ARCIMDR)
	.s STRowId=0                                                       //add by zl start
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, STRowId))
	.Q:(""=STRowId)                                                    //add by zl end
  	.s RLTRowid=0
	.s RLTRowid=$o(^DHCPERLT(0,"OEORI",TestId,RLTRowid))
	.//RLT_User_DR	检查医师
	.i RLTRowid'="" d
	..s RLTUser=$p(^DHCPERLT(RLTRowid),"^",5)
  	..i (""'=RLTUser) d
  	...i STRowId'=LabStation d
  	....s RLTUser=$p($g(^SSU("SSUSR",RLTUser)),"^",2)	//检查医师名称	SS_User
  	...e  d
  	....//s RLTUser=$p($g(^[namespaceLab]SSU("SSUSR",1,RLTUser)),"^",2)
  	....s:(LisNewVersion'="Y") RLTUser=$p($g(^[namespaceLab]SSU("SSUSR",1,RLTUser)),"^",2)
    ....s:(LisNewVersion="Y") RLTUser=$P(^SSU("SSUSR",RLTUser),"^",2)
  	..e  d
  	...i STRowId=LabStation d
  	....s RLTUser=$G(^DHCENSCheckHeal("CHECKTHEAL",LabSpecNo))
  	..s AuditUser=$G(^DHCPEDataEx("Report","DHCPEIReport","LisAuditUser",TestId))
  	..//i AuditUser'="" s AuditUser=$p($g(^[namespaceLab]SSU("SSUSR",1,AuditUser)),"^",2)
  	..s:(AuditUser'="")&&(LisNewVersion'="Y") AuditUser=$p($g(^[namespaceLab]SSU("SSUSR",1,AuditUser)),"^",2)
  	..s:(AuditUser'="")&&(LisNewVersion="Y") AuditUser=$P(^SSU("SSUSR",AuditUser),"^",2)
	..s RLTUpdateDate=$p(^DHCPERLT(RLTRowid),"^",6)
    ..i (""'=RLTUpdateDate) d
    ...s RLTUpdateDate=$ZD(RLTUpdateDate,3)
	..s AuditUser=AuditUser
	.e  d
  	..s RLTUser=""
  	..s AuditUser=""
  	..s RLTUpdateDate=""
	.q:(ExTestID'="")&&(ExTestID'=TestId)
	.// 按打印格式索引
	.s ^TMPReport(UserID,"Result","ReportFormat",ReportFormat,TestId)=ARCIMDesc
	.
	.// 按站点索引 
	.s ^TMPReport(UserID,"Result","Station",STSequence,STRowId,ARCSequence)=+$G(^TMPReport(UserID,"Result","Station",STSequence,STRowId,ARCSequence))+1
	.s ^TMPReport(UserID,"Result","Station",STSequence,STRowId,ARCSequence,^TMPReport(UserID,"Result","Station",STSequence,STRowId,ARCSequence))=TestId
	.
	.// 按项目索引  增加AuditUser 2008-06-04
	.s ^TMPReport(UserID,"Result","ARCIM",TestId)=ARCIMDesc_"^"_RLTUser_"^"_RLTUpdateDate_"^"_ReportFormat_"^"_$G(AuditUser)


	Q ""
}

ClassMethod GetReportResultQM(PAAdmRowid As %String)
{
   	s UserID=%session.Get("LOGON.USERID")
   	s:UserID="" UserID=PAAdmRowid
	s LisNewVersion=$g(^DHCPESetting("DHCPE","LisNewVersion"))
	;d ..GetHistoryResult(PAAdmRowid, "", "")
   	k ^TMPReport(UserID,"Result")
	;k ^TMPReport(UserID,"HistoryResult")
	k ^TMPReport(UserID,"LabSpecNo")
	k ^TMPReport(UserID,"GetResultByLoc")
	k ^TMPReport(UserID,"NoResult")
	k ^TMPReport(UserID,"RefuseCheck")
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	
	s PAPMIdr=$p(^PAADM(PAAdmRowid),"^",1)
	Q:(""=PAPMIdr) "0"
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAAdmRowid,0))
	// PAPER_Sex_DR	性别
	//s PAPERSexDR=$p(^PAPER(PAPMIdr,"ALL"),"^",7)
	s ^TMPReport(UserID,"Result","Sex")=$G(^TMPReport(UserID,"PatInfo","PatSexDR"))
	
	// PAPER_Dob		出生日期
	//s PAPERDob=$p(^PAPER(PAPMIdr,"ALL"),"^",6)
 	//i PAPERDob'="" s PAPERDob=$ZD(PAPERDob,3)
 	//s Age=""
 	//s:(""'=PAPERDob) Age=##class(web.DHCLCNUREXCUTE).CalAge(PAPERDob,+$h)
 	//s Age=+$P(Age,"Y")
    s ^TMPReport(UserID,"Result","Age")=$G(^TMPReport(UserID,"PatInfo","PatAge"))

	///得到既往病史等内容
	s ODStr=$G(^DHCPESetting("DHCPE","ODStr"))
	s i=$L(ODStr,"^")
	f j=1:1:i
	{
		
		s ODDR=$p(ODStr,"^",j)
		Continue:ODDR=""
		s RLID=0
		s ResultStr=""
		f  s RLID=$o(^DHCPERLT(0,"PAADM_OD",PAAdmRowid,ODDR,RLID)) q:RLID=""  d
		.s Result=$p(^DHCPERLT(RLID),"^",4)
		.i Result'="" s ResultStr=ResultStr_Result_" "
		s Split="JZS"
		i j=1 s Split="YWGMS"
		i j=2 s Split="JWS"
		i j=3 s Split="JZS"
		
		s ^TMPReport(UserID,"PatInfo",Split)=ResultStr
	}
	s LisMerge=$G(^DHCPESetting("DHCPE","LisReportMerge"))
	s FKOrderID=..GetFKOrder(PAAdmRowid,4)
	s YKOrderID=..GetFKOrder(PAAdmRowid,5)
	s COrderID=$O(^OEORD(0,"Adm",PAAdmRowid,0))
	s FKFlag=0
	s YKFlag=0
	q:COrderID="" ""
	s COrderSub="0"
	f  s COrderSub=$O(^OEORD(COrderID,"I",COrderSub)) q:COrderSub=""  d
	.s Stat=$P($g(^OEORD(COrderID,"I",COrderSub,1)),"^",13)
	.q:Stat="4"
	.s PayedFlag=$P($g(^OEORD(COrderID,"I",COrderSub,3)),"^",5)
	.q:(PayedFlag'="P")&&(IADM'="")
	.s TestId=COrderID_"||"_COrderSub
	.//f  s TestId=$o(^DHCPERLT(0,"ADMOD", PAAdmRowid, TestId)) q:(""=TestId)  d
	.;s CRMID=$O(^DHCPECRMO(0,"OEORI",TestId,0))
	.;q:CRMID=""
	.;s ItemID=$p(^DHCPECRMO(CRMID),"^",2)
	.;q:ItemID=""
	.;s ItemStat=$p(^DHCPEPreIADM(+ItemID,"ORDITEM",$P(ItemID,"||",2)),"^",16)
	.;q:ItemStat'="1"
	.s OEORDRowId=$P(TestId,"||",1) // OE_Order.OEORD_RowId
	.s OEORIChildsub=$P(TestId,"||",2) // OE_Order.OEORI_Childsub
	.//在报告上不打印某些医嘱
	.s NoPrintFlag=""
	.s NoPrintFlag=$g(^DHCPEDataEx("DHCPEOrdItem","NotPrint",TestId))
	.q:NoPrintFlag="Y"
	.s ARCIMDR=$P($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",2)
	.Q:(""=ARCIMDR)
	.//RLT_ARCIM_DR 医嘱项目
	.s ARCIMSubScript=$p(ARCIMDR,"||",1)	//ARCIM_Desc 医嘱名称 Arc_ItmMast
	.s ARCIMVersion=$p(ARCIMDR,"||",2)
	.s ARCIMCode=$p($g(^ARCIM(ARCIMSubScript,ARCIMVersion,1)),"^",1)
	.s ARCIMDesc=$p($g(^ARCIM(ARCIMSubScript,ARCIMVersion,1)),"^",2)
	.s ARCIMDesc=$p(ARCIMDesc,"(",1)
	.// 获取打印格式
	.s STRowId=0
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, STRowId))
	.Q:(""=STRowId)
	.Q:STRowId=$G(^DHCPESetting("DHCPE","StationId_Other"))
	.//站点顺序
	.s STSequence=$p(^DHCPEST(STRowId),"^",9)
	.q:STSequence=""
	.//项目顺序
	.s ARCSequence=$G(^DHCPEDataEx("DHCPEStationOrder","Sequence",ARCIMDR))
	.i ARCSequence="" d
	..s ARCSequence="999999999"
	..s LocInfo=$G(^DHCPEStationOrder("Loc",ARCIMDR))
	..s LocID=$P(LocInfo,"^",1)
	..i LocID'=""  d
	...s ARCSequence=$P($g(^DHCPEST(+LocID,"STLOC",$P(LocID,"||",2))),"^",2)
	...s:ARCSequence="" ARCSequence="999999999"
	..e  d
	...s ARCSequence="999999999"
	.s STORDChildSub=0
	.s STORDChildSub=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, STRowId, STORDChildSub))
	.Q:(""=STORDChildSub)
	.;s CrmSets=$p(^DHCPEPreIADM(+ItemID,"ORDITEM",$P(ItemID,"||",2)),"^",2)
	.s CrmSets=$P($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",1)
	.i CrmSets="" d
	..i $D(^TMPReport(UserID,"Result","AddItem")) d
	...s ^TMPReport(UserID,"Result","AddItem")=^TMPReport(UserID,"Result","AddItem")_"、"_ARCIMDesc
	..e  d
	...s ^TMPReport(UserID,"Result","AddItem")=ARCIMDesc
	.s ReportFormat=$P(^DHCPEST(STRowId,"O",STORDChildSub),"^",4)
	.s:(""=ReportFormat) ReportFormat="RF_NOR"
	.s RFlag=0
	.i (ReportFormat[("RIS")) s RFlag=..GetRisARCDesc(TestId)
	.q:RFlag="1"
	.// 报告单属性 检验人/检查人 体检日期
	.s LabSpecNo=$p($G(^OEORD(+TestId,"I",$P(TestId,"||",2),3)),"^",20)
  	.s QFlag=0
  	.s STRowId=0                                                       //add by zl start
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, STRowId))
	.Q:(""=STRowId)                                                    //add by zl end
  	.
  	.i $D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",TestId)) d
   	..s RefuseSort=$I(^TMPReport(UserID,"RefuseCheck",STSequence,STRowId,ARCSequence))
   	..s ^TMPReport(UserID,"RefuseCheck",STSequence,STRowId,ARCSequence,RefuseSort)=ARCIMDesc
  	..s ARCIMDesc=ARCIMDesc_"（放弃）"
  	..s QFlag=1
  	.;q:QFlag=1
  	.i '$D(^DHCPERLT(0,"ADMOD", PAAdmRowid, TestId)) d
  	..s RefuseSort=$I(^TMPReport(UserID,"NoResult",STSequence,STRowId,ARCSequence))
   	..s ^TMPReport(UserID,"NoResult",STSequence,STRowId,ARCSequence,RefuseSort)=ARCIMDesc
  	..s QFlag=1
  	.q:'$D(^DHCPERLT(0,"ADMOD", PAAdmRowid, TestId))
  	.;q:QFlag=1
  	.s SpecItem=$G(^DHCPEDataEx("DHCPEStationOrder","SignItem",ARCIMDR))
  	.s PrintFlag=..NeedPrintInReport(TestId)
  	.q:PrintFlag=0
  	.;q:(SpecItem="Y")&&(LabSpecNo="")&&(STRowId'=9)
  	.//为了协和化验接口数据都传入到一个医嘱上使用
  	.q:(LisMerge="Y")&&(LabSpecNo'="")&&($D(^TMPReport(UserID,"LabSpecNo",LabSpecNo)))
  	.s:(LisMerge="Y")&&(LabSpecNo'="") ^TMPReport(UserID,"LabSpecNo",LabSpecNo)=""
  	.s:(LisMerge="Y")&&(LabSpecNo'="") ARCIMDesc=##class(web.DHCPE.ResultDiagnosis).GetAllNameBySpecNo(LabSpecNo)
  	.s ExTestID=""
  	.i STRowId="4" d
  	..s ARCIMDesc="妇科"
  	..q:FKFlag=1
  	..s FKFlag=1
  	..s ExTestID=$P(FKOrderID,"^",1)
  	..s Length=$L(FKOrderID,"^")
  	..f FKSort=1:1:Length  d
  	...s OneOrder=$P(FKOrderID,"^",FKSort)
  	...s OneArcID=$P($G(^OEORD(+OneOrder,"I",$P(OneOrder,"||",2),1)),"^",2)
  	...d ..GetRISResult(PAAdmRowid,OneOrder, OneArcID,ExTestID)
  	.e  i STRowId="5" d
  	..s ARCIMDesc="眼科"
  	..q:YKFlag=1
  	..s YKFlag=1
  	..s ExTestID=$P(YKOrderID,"^",1)
  	..s Length=$L(YKOrderID,"^")
  	..f FKSort=1:1:Length  d
  	...s OneOrder=$P(YKOrderID,"^",FKSort)
  	...s OneArcID=$P($G(^OEORD(+OneOrder,"I",$P(OneOrder,"||",2),1)),"^",2)
  	...d ..GetRISResult(PAAdmRowid,OneOrder, OneArcID,ExTestID)
  	
  	.e  d
  	..d:(ReportFormat["LIS") ..GetLISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["NOR") ..GetRISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["RIS") ..GetRISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["CAT") ..GetLISResult(PAAdmRowid,TestId, ARCIMDR)
	..d:(ReportFormat["EKG") ..GetRISResult(PAAdmRowid,TestId, ARCIMDR)
	.s STRowId=0                                                       //add by zl start
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, STRowId))
	.Q:(""=STRowId)                                                    //add by zl end
  	.s RLTRowid=0
	.s RLTRowid=$o(^DHCPERLT(0,"OEORI",TestId,RLTRowid))
	.//RLT_User_DR	检查医师
	.i RLTRowid'="" d
	..s RLTUser=$p(^DHCPERLT(RLTRowid),"^",5)
  	..i (""'=RLTUser) d
  	...i STRowId'=LabStation d
  	....s RLTUser=$p($g(^SSU("SSUSR",RLTUser)),"^",2)	//检查医师名称	SS_User
  	...e  d
  	....//s RLTUser=$p($g(^[namespaceLab]SSU("SSUSR",1,RLTUser)),"^",2)
  	....s:(LisNewVersion'="Y") RLTUser=$p($g(^[namespaceLab]SSU("SSUSR",1,RLTUser)),"^",2)
    ....s:(LisNewVersion="Y") RLTUser=$P(^SSU("SSUSR",RLTUser),"^",2)
  	..e  d
  	...i STRowId=LabStation d
  	....s RLTUser=$G(^DHCENSCheckHeal("CHECKTHEAL",LabSpecNo))
  	..s AuditUser=$G(^DHCPEDataEx("Report","DHCPEIReport","LisAuditUser",TestId))
  	..//i AuditUser'="" s AuditUser=$p($g(^[namespaceLab]SSU("SSUSR",1,AuditUser)),"^",2)
  	..s:(AuditUser'="")&&(LisNewVersion'="Y") AuditUser=$p($g(^[namespaceLab]SSU("SSUSR",1,AuditUser)),"^",2)
  	..s:(AuditUser'="")&&(LisNewVersion="Y") AuditUser=$P(^SSU("SSUSR",AuditUser),"^",2)
	..s RLTUpdateDate=$p(^DHCPERLT(RLTRowid),"^",6)
    ..i (""'=RLTUpdateDate) d
    ...s RLTUpdateDate=$ZD(RLTUpdateDate,3)
	..s AuditUser=AuditUser
	.e  d
  	..s RLTUser=""
  	..s AuditUser=""
  	..s RLTUpdateDate=""
	.q:(ExTestID'="")&&(ExTestID'=TestId)
	.// 按打印格式索引
	.s ^TMPReport(UserID,"Result","ReportFormat",ReportFormat,TestId)=ARCIMDesc
	.
	.// 按站点索引 
	.s ^TMPReport(UserID,"Result","Station",STSequence,STRowId,ARCSequence)=+$G(^TMPReport(UserID,"Result","Station",STSequence,STRowId,ARCSequence))+1
	.s ^TMPReport(UserID,"Result","Station",STSequence,STRowId,ARCSequence,^TMPReport(UserID,"Result","Station",STSequence,STRowId,ARCSequence))=TestId
	.
	.// 按项目索引  增加AuditUser 2008-06-04
	.s ^TMPReport(UserID,"Result","ARCIM",TestId)=ARCIMDesc_"^"_RLTUser_"^"_RLTUpdateDate_"^"_ReportFormat_"^"_$G(AuditUser)


	Q ""
}

// 判断项目是否需要打印在体检报告上，现在是如果结果包含详见报告就不打印

ClassMethod NeedPrintInReport(OEID)
{
	s Ret=""
	s ResultID=$O(^DHCPERLT(0,"OEORI",OEID,0))
	q:ResultID="" 1
	s Ret=$P(^DHCPERLT(ResultID),"^",4)
	q:Ret[("详见报告") 0
	q 1
	;临床诊断:;检查所见:;诊断意见:详见报告
}

ClassMethod GetFKOrder(PAAdmRowid, FKStation As %String = "4")
{
	k ^TempDHCPE(PAAdmRowid)
	s COrderID=$O(^OEORD(0,"Adm",PAAdmRowid,0))
	q:COrderID="" ""
	s COrderSub="0"
	f  s COrderSub=$O(^OEORD(COrderID,"I",COrderSub)) q:COrderSub=""  d
	.s Stat=$P(^OEORD(COrderID,"I",COrderSub,1),"^",13)
	.q:Stat="4"
	.s PayedFlag=$P($g(^OEORD(COrderID,"I",COrderSub,3)),"^",5)
	.q:PayedFlag'="P"
	.s ARCIMDR=$P($G(^OEORD(COrderID,"I",COrderSub,1)),"^",2)
	.Q:(""=ARCIMDR)
	.s ARCSequence=$G(^DHCPEDataEx("DHCPEStationOrder","Sequence",ARCIMDR))
	.i ARCSequence="" d
	..s ARCSequence="999999999"
	..s LocInfo=$G(^DHCPEStationOrder("Loc",ARCIMDR))
	..s LocID=$P(LocInfo,"^",1)
	..i LocID'=""  d
	...s ARCSequence=$P($g(^DHCPEST(+LocID,"STLOC",$P(LocID,"||",2))),"^",2)
	...s:ARCSequence="" ARCSequence="999999999"
	..e  d
	...s ARCSequence="999999999"
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMDR, 0))
	.q:STRowId'=FKStation
	.s ^TempDHCPE(PAAdmRowid,ARCSequence,COrderID,COrderSub)=""
	s ret=""
	s ARCSequence=""
	f  s ARCSequence=$O(^TempDHCPE(PAAdmRowid,ARCSequence)) q:ARCSequence=""  d
	.s OrderSub=""
	.f  s OrderSub=$O(^TempDHCPE(PAAdmRowid,ARCSequence,COrderID,OrderSub)) q:OrderSub=""  d
	..s OneOrder=COrderID_"||"_OrderSub
	..i ret="" d
	...s ret=OneOrder
	..e  d
	...s ret=ret_"^"_OneOrder
	k ^TempDHCPE(PAAdmRowid)
	q ret
}

/// 检验项目根据科室获取结果  0需要向下运行  1不需要向下运行
ClassMethod GetResultByLoc(OEORDItemID)
{
	s ARCID=$P(^OEORD(+OEORDItemID,"I",$P(OEORDItemID,"||",2),1),"^",2)
	s LocInfo=$G(^DHCPEStationOrder("Loc",ARCID))
	s LocID=$P(LocInfo,"^",1)
	q:LocID="" "0^"
	s LocDesc=$P(^DHCPEST(+LocID,"STLOC",$P(LocID,"||",2)),"^",1)
	i $D(^TMPReport(UserID,"GetResultByLoc",LocID)) q "1^"_LocDesc_"^"_$G(^TMPReport(UserID,"GetResultByLoc",LocID))
	s ^TMPReport(UserID,"GetResultByLoc",LocID)=OEORDItemID
	q "0^"_LocDesc_"^"_OEORDItemID
}

/// 获取LIS格式数据
/// d ##Class(web.DHCPE.ReportGetInfor).GetLISResult(5748147,"5152911||14","3870||1")
ClassMethod GetLISResult(PAAdmRowid As %String, arcimRowID As %String, ARCIMDR As %String, ExTestId As %String = "")
{
	//w PAAdmRowid_","_arcimRowID_","_ARCIMDR_":"
	s iLLoop=1
	s STRowId=""
	s LisMerge=$G(^DHCPESetting("DHCPE","LisReportMerge"))
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s LisNewVersion=$g(^DHCPESetting("DHCPE","LisNewVersion"))
	Set CurNS=$ZNSPACE
	s episodeNo=$p(^OEORD($p(arcimRowID,"||",1),"I",$p(arcimRowID,"||",2),3),"^",20)
	s NotNormalResult=""
	i episodeNo'="" 
	{
		
		i $D(^DHCPERLT("LabSpecNo",episodeNo)) d 
		.s ^TMPReport(UserID,"Result", "Content",arcimRowID)=$G(^DHCPERLT("LabSpecNo",episodeNo))
		
		s OrderSub=0
		f  s OrderSub=$O(^OEORD(0,"EpisNo",episodeNo,+arcimRowID,OrderSub)) q:OrderSub=""  d
		.s ItemStat=$p($G(^OEORD(+arcimRowID,"I",OrderSub,1)),"^",13)
		.q:ItemStat="4"
		.s OneOrder=+arcimRowID_"||"_OrderSub
		.q:(LisMerge'="Y")&&(OneOrder'=arcimRowID)
		.s ShowSort=""
		.f  s ShowSort=$O(^DHCPERLT(0,"OrdSort",OneOrder,ShowSort)) q:ShowSort=""  d
		..s RLTId=0
		..f  s RLTId=$O(^DHCPERLT(0,"OrdSort",OneOrder,ShowSort,RLTId)) q:RLTId=""  d
		...s Item=$p($G(^DHCPERLT(RLTId)),"^",3)
		...s STRowId=+Item
		
		...;q:$D(^TempDHPCEResultEdit(UserID,"Result",OneOrder,Item))
		...;s ^TempDHPCEResultEdit(UserID,"Result",OneOrder,Item)=""
		
		
		...;d ..GetHistoryResult(PAAdmRowid,Item,ARCIMDR)
		...s ODDesc=$P($g(^DHCPEST(+Item,"OD",$P(Item,"||",2))),"^",1)
		...s:ODDesc="tx4(t7,t8,t11,t12,t14)" ODDesc="tx4(白栎,美洲榆,英国梧桐树,柳树,美洲黑杨)"
		...s:ODDesc="tx10(t2,t3,t4,t15)" ODDesc="tx10(灰桤木,疣皮桦,欧洲榛,美国白蜡)"
	
		...s RLTResult=$p($G(^DHCPERLT(RLTId)),"^",4)
		...s ODUnit=$G(^DHCPEDataEx("DHCPEResult",RLTId,"Unit"))
		...s Standard=$G(^DHCPEDataEx("DHCPEResult",RLTId,"Ranges"))
		...s RLTNormal=$P(^DHCPERLT(RLTId),"^",7)
		...i RLTNormal="0" d
		....i NotNormalResult="" d
		.....s NotNormalResult=ODDesc_":"_RLTResult
		....e  d
		.....s NotNormalResult=NotNormalResult_";"_ODDesc_":"_RLTResult
		...;s Arrow=##class(web.DHCPE.TransResult).GetLabResultArrow(Standard,RLTResult)
		...s Arrow=##class(web.DHCPE.TransResult).GetLabResultArrowNew(RLTId)
		...;i (Arrow="1")&&(RLTNormal=0) s Arrow=3
		...//s NormalFlag=Arrow
		...s ItemCode=$P($g(^DHCPEST(+Item,"OD",$P(Item,"||",2))),"^",11)
		...;s CTTCSynonym=$p($g(^TTAB("TC",ItemCode)),"\",12)
		...s:LisNewVersion="Y" CTTCSynonym=$g(^DHCPEDataEx("DHCPEResult",RLTId,"Sync"))
		...s:LisNewVersion'="Y" CTTCSynonym=$p($g(^TTAB("TC",ItemCode)),"\",12)
		...s RLTTemplateDesc=""
		...s ^TMPReport(UserID,"Result", "Content", arcimRowID,iLLoop)=ODDesc_"^"_RLTResult_"^"_RLTNormal_"^"_ODUnit_"^"_Standard_"^"_Arrow_"^"_RLTTemplateDesc_"^"_$G(CTTCSynonym)_"^"_RLTId
		...s iLLoop=1+iLLoop
	}
	else
	{
		s Sequence=""
		f  s Sequence=$O(^DHCPEODR(0,"Sequence",ARCIMDR,Sequence)) q:Sequence=""  d
		.s RowId=""
		.f  s RowId=$O(^DHCPEODR(0,"Sequence",ARCIMDR,Sequence,RowId)) q:RowId=""  d
		..Set RLTODDR=$P($g(^DHCPEODR(RowId)),"^",2)
		..s Standard=""
		..q:RLTODDR=""
		..;d ..GetHistoryResult(PAAdmRowid,RLTODDR,ARCIMDR)
		..s RLTRowid=0
		..s RLTResult=""
		..s RLTTemplateDesc=""
		..s Flag=1
		..S Result=""
		..s ODDesc=$p($G(^DHCPEST(+RLTODDR,"OD",$P(RLTODDR,"||",2))),"^",1)	//细项名称	DHC_PE_OrderDetail
		..Q:(""=ODDesc)
		..i $D(^DHCPERLT(0,"OEORI",arcimRowID)) d
		...s RLTID=""
		...f  s RLTRowid=$o(^DHCPERLT(0,"ADMOD", PAAdmRowid, arcimRowID,RLTODDR, RLTRowid))  q:(RLTRowid="")  d  
		....s RLTID=RLTRowid
		....//RLT_OD_DR	细项
		....s ODRowId=$p(^DHCPERLT(RLTRowid),"^",3)
		....q:$G(^DHCPEDataEx("DHCPEOrderDetail","NoPrint",ODRowId))="Y"    
		....s STRowId=$p(ODRowId,"||",1)			//站点编码
		....s ODChildSub=$p(ODRowId,"||",2)		//项目编码
		....s ODLabCode=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",10)	//检验细项代码	DHC_PE_OrderDetail
		....//OD_Desc
		....//s Standard=..GetStandard(STRowId,ODChildSub)
		....s Standard=..GetStandard(STRowId_"||"_ODChildSub,^TMPReport(UserID,"Result","Sex"),^TMPReport(UserID,"Result","Age"))
		....//OD_Unit
		....s ODUnit=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",4)
		....//s:(""'=ODUnit) ODUnit=$p($g(^CT(ODUnit)),"^",2)	//CT_UOM
		....
		....//检验结果
		....s Result=$p(^DHCPERLT(RLTRowid),"^",4)
		....q:Result=""
		....s RLTResult=$G(RLTResult)_Result
        ....s RLTTemplateDesc=RLTTemplateDesc_$p($G(^DHCPERLT(RLTRowid)),"^",10)_$C(13)_$C(10)
		....s IsNormal=$p(^DHCPERLT(RLTRowid),"^",7)
		....i IsNormal="0" d
		.....i NotNormalResult="" d
		......s NotNormalResult=ODDesc_":"_Result
		.....e  d
		......s NotNormalResult=NotNormalResult_";"_ODDesc_":"_Result
		....s Arrow="1"
		....i LabStation=STRowId d
		.....;s Arrow=##class(web.DHCPE.TransResult).GetLabResultArrow(Standard,RLTResult)
		.....s Arrow=##class(web.DHCPE.TransResult).GetLabResultArrowNew(RLTRowid)
		.....i (Standard="")&&(IsNormal=0) s Arrow=3
		.....Set namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
		.....Set CTTCCode=$p(^DHCPEST(STRowId,"OD",ODChildSub),"^",10)
		.....Set ResultFormat=$p($g(^[namespaceLab]TTAB("TC",CTTCCode)),"\",3)
		.....If ($e(ResultFormat,1)'="N"&&(Arrow'="3")) s Arrow=1
		.....;Set CTTCSynonym=$p($g(^[namespaceLab]TTAB("TC",CTTCCode)),"\",12)
		.....s:LisNewVersion="Y" CTTCSynonym=$g(^DHCPEDataEx("DHCPEResult",RLTId,"Sync"))
		.....s:LisNewVersion'="Y" CTTCSynonym=$p($g(^TTAB("TC",ItemCode)),"\",12)

		.....zn CurNS
    	....e  d
    	.....s Arrow=##class(web.DHCPE.TransResult).GetLabResultArrowNew(RLTRowid)
		.....i (Standard="")&&(IsNormal=0) s Arrow=1
    	
		....s RLTNormal=$p(^DHCPERLT(RLTRowid),"^",7)
		..e  d
		...s (RLTRowid,RLTResult,RLTNormal,ODUnit,Standard,Arrow,RLTTemplateDesc,CTTCSynonym,RLTID)=""
		..q:($G(Result)="")&&($D(^DHCPERLT(0,"OEORI",arcimRowID)))
		..s ^TMPReport(UserID,"Result", "Content", arcimRowID,iLLoop)=ODDesc_"^"_RLTResult_"^"_$G(RLTNormal)_"^"_ODUnit_"^"_Standard_"^"_Arrow_"^"_RLTTemplateDesc_"^"_$G(CTTCSynonym)_"^"_RLTID
		..
		..s iLLoop=1+iLLoop
	}
	q:STRowId=""
	s ReportType=$G(^DHCPEDataEx("ReportItemSort",ARCIMDR))
	i ReportType="" d
	.s ReportSort="99"
	.s ReportTypeDesc="没有分类"
	e  d
	.s ReportSort=$P($G(^DHCPEDataEx("ReportItem",ReportType)),"^",2)
	.s ReportTypeDesc=$P($G(^DHCPEDataEx("ReportItem",ReportType)),"^",1)
	i NotNormalResult="" s NotNormalResult="未见异常"
	s ^TMPReport(UserID,"Result", "NotNormalResult",ReportSort,ReportTypeDesc,STRowId,arcimRowID)=NotNormalResult
	
	/*
	// RLT_OD_DR
	s RLTODDR=0
	f  s RLTODDR=$o(^DHCPERLT(0,"ADMOD", PAAdmRowid, arcimRowID, RLTODDR)) q:RLTODDR=""  d
	.s RLTRowid=0
	.s RLTRowid=$o(^DHCPERLT(0,"ADMOD", PAAdmRowid, arcimRowID, RLTODDR, RLTRowid))
	.Q:(""=RLTRowid)
	.
	.//RLT_OD_DR	细项
	.s ODRowId=$p(^DHCPERLT(RLTRowid),"^",3)     
	.s STRowId=$p(ODRowId,"||",1)			//站点编码
	.
	.s ODChildSub=$p(ODRowId,"||",2)		//项目编码
	.
	.//OD_Desc
	.s ODDesc=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",1)	//细项名称	DHC_PE_OrderDetail
	.s ODLabCode=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",10)	//检验细项代码	DHC_PE_OrderDetail
	.Q:(""=ODDesc)
	.//s Standard=..GetStandard(STRowId,ODChildSub)
	.s Standard=..GetStandard(STRowId_"||"_ODChildSub,^TMPReport(UserID,"Result","Sex"),^TMPReport(UserID,"Result","Age"))
	.
	.//OD_Unit
	.s ODUnit=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",4)
	.//s:(""'=ODUnit) ODUnit=$p($g(^CT(ODUnit)),"^",2)	//CT_UOM
	.
	.//检验结果
	.s RLTResult=$p(^DHCPERLT(RLTRowid),"^",4)
	.s Arrow="1"
	.i LabStation=STRowId d
	..s Arrow=##class(web.DHCPE.TransResult).GetLabResultArrow(Standard,RLTResult)
	..Set namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	..Set CTTCCode=$p(^DHCPEST(STRowId,"OD",ODChildSub),"^",10)
	..Set ResultFormat=$p($g(^[namespaceLab]TTAB("TC",CTTCCode)),"\",3)
	..If $e(ResultFormat,1)'="N" s Arrow=1
	..zn "websource"
	..//s RLTResult=##class(web.DHCPE.TransResult).trans(ODLabCode,RLTResult) //$p(..,$C(1),2)
	..//i $l(RLTResult,$C(1))>1 d
	..//.s RLTResult=$p(RLTResult,$C(1),2)
    .//s RLTResult=RLTResult
    .//是否正常
	.s RLTNormal=$p(^DHCPERLT(RLTRowid),"^",7)
	.// RLT_TemplateDesc 模板描述
	.s RLTTemplateDesc=$p(^DHCPERLT(RLTRowid),"^",10)
	.//s ^TMPReport(UserID,"Result", "Station", STRowId)=ARCIMDR
	.s ^TMPReport(UserID,"Result", "Content", ARCIMDR,iLLoop)=ODDesc_"^"_RLTResult_"^"_RLTNormal_"^"_ODUnit_"^"_Standard_"^"_Arrow_"^"_RLTTemplateDesc
	.
	.s iLLoop=1+iLLoop*/
}

/// 获取参考范围 DHC_PE_ODStandard
/// w ##Class(web.DHCPE.ReportGetInfor).GetStandard("10||1",F,17)
/// w ##Class(web.DHCPE.ReportGetInfor).GetStandard("1||2",F,17)
ClassMethod GetStandard(ItemID As %String, sex As %String, age As %String)
{
	s:sex="1" sex="M"
	s:sex="2" sex="F"
	q ##class(web.DHCPE.ResultEdit).GetNormal(ItemID,sex,+age)
}

/*

/// 获取参考范围 DHC_PE_ODStandard
/// d ##Class(web.DHCPE.ReportGetInfor).GetStandard()
ClassMethod GetStandard(STRowId As %String, ODChildSub As %String)
{
	s RowId=""	
	s Rangs=""
	f  s RowId=$o(^DHCPEST(STRowId,"OD",ODChildSub,"ODS",RowId)) q:RowId=""  d
	.s CurData=$g(^DHCPEST(STRowId,"OD",ODChildSub,"ODS",RowId))
	.s ODSNatureValue=$P(CurData,"^",6)
	.q:("Y"'=ODSNatureValue)
	.//ODS_Min,ODS_Max
	.s Rangs=$P(CurData,"^",4)_"-"_$P(CurData,"^",5)
	if ("-"=Rangs)  s Rangs=""
	q Rangs
}
*/
/// test: w ##Class(web.DHCPE.ReportGetInfor).GetResultStatus("10||1","F",17)
ClassMethod GetResultStatus(ItemID, sex, age) As %String
{
	Quit:(($g(ItemID)="")||($g(sex)="")||(age="")) ""
	
	Set NormalStr=""
	Set age=+age
	Set ItemType=$P($g(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2))),"^",2)
	Set ItemUOMDr=$P($g(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2))),"^",4)
	Set ItemUOM=""
	If ItemUOMDr'="" Set ItemUOM=$P($G(^CT("UOM",ItemUOMDr)),"^",2)
	Set Chl=0
	Set Normal="N"
	For  Set Chl=$O(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",Chl)) Quit:(Chl="")!(Normal="Y")  Do
	.set myData=^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",Chl)
	.Set tempNormal=$P(myData,"^",6)
	.
	.set tempSex=$P(myData,"^",1)
	.set tempAgeMin=+$P(myData,"^",7)
	.set tempAgeMax=+$P(myData,"^",8)
	.
	.i ("N"=ItemType)||("C"=ItemType) d
	..// 有年龄性别的限制
	..i (""'=tempSex)&&((""'=tempAgeMin)||(""'=tempAgeMax)) d
	...
	...i (sex=tempSex)&&(+age>=+tempAgeMin)&&(+age<=+tempAgeMax) d
	....s ^TMPResultStatus("Range",1)=tempAgeMin_"-"_tempAgeMax
	...
	..
	..
	..// 有性别，无年龄限制
	..i (""'=tempSex)&&(""=tempAgeMin)&&(""'=tempAgeMax) d
	...
	...i (sex=tempSex) d
	....s ^TMPResultStatus("Range",2)=tempAgeMin_"-"_tempAgeMax
	...
	...
	..
	..
	..// 无性别，有年龄限制
	..i (""=tempSex)&&((""'=tempAgeMin)||(""'=tempAgeMax)) d
	...Q:(""'=tempAgeMin)&&(age>=+tempAgeMin)
	...Q:(""'=tempAgeMax)&&(age<=+tempAgeMax)
	...s ^TMPResultStatus("Range",3)=tempAgeMin_"-"_tempAgeMax
	..
	..
	..// 无年龄性别的限制 通用
	..i (""'=tempSex)&&(""'=tempAgeMin)&&(""'=tempAgeMax) d
	...
	...s ^TMPResultStatus("Range",4)=tempAgeMin_"-"_tempAgeMax
	...
	..
	..
	.
	.Quit:tempNormal'="Y"
	.Quit:(((tempAgeMin>age)||(tempAgeMax<age))&&((tempAgeMin'=0)&&(tempAgeMax'=0)))
	.Quit:(tempSex'="N")&&(tempSex'=sex)
	.set Normal="Y"
	.If ItemType="N" Do
	..Set Min=+$P(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",Chl),"^",4)
	..Set Max=+$P(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",Chl),"^",5)
	..Set NormalStr=Min_ItemUOM_" - "_Max_ItemUOM
	.Else  Do
	..Set NormalStr=$P(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",Chl),"^",2)

	Quit NormalStr
}

ClassMethod GetResultNormal(ItemID, sex, age) As %String
{
	q:(($g(ItemID)="")||($g(sex)="")||(age="")) ""
	
	Set NormalStr=""
	
	s age=+age
	
	// DHC_PE_OrderDetail.{ OD_Type }
	s ODType=$P($g(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2))),"^",2)

	s ind=0
	f  s ind=$O(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",ind)) q:(ind="")  d
	.s CurData=^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",ind)
	.// ODS_NatureValue_
	.s ODSNatureValue=$P(CurData,"^",6)
	.
	.s ODSSex=$P(CurData,"^",1)
	.s ODSAgeMin=+$P(CurData,"^",7)
	.s ODSAgeMax=+$P(CurData,"^",8)
	.s ODSMin=+$P(CurData,"^",4)
	.s ODSMax=+$P(CurData,"^",5)
	.
	.// 有年龄性别的限制
	.i (""'=ODSSex)&&((""'=ODSAgeMin)||(""'=ODSAgeMax)) d
	..
	..i (sex=ODSSex)&&(+age>=+ODSAgeMin)&&(+age<=+ODSAgeMax) d
	...s:("N"=ODType)||("C"=ODType) ^TMPResultStatus("Range",1)=ODSMin_"-"_ODSMax
	..
	.
	.
	.// 有性别，无年龄限制
	.i (""'=ODSSex)&&(""=ODSAgeMin)&&(""'=ODSAgeMax) d
	..
	..i (sex=ODSSex) d
	...s:("N"=ODType)||("C"=ODType) ^TMPResultStatus("Range",2)=ODSMin_"-"_ODSMax
	..
	..
	.
	.
	.// 无性别，有年龄限制
	.i (""=ODSSex)&&((""'=ODSAgeMin)||(""'=ODSAgeMax)) d
	..Q:(""'=ODSAgeMin)&&(age>=+ODSAgeMin)
	..Q:(""'=ODSAgeMax)&&(age<=+ODSAgeMax)
	..s:("N"=ODType)||("C"=ODType) ^TMPResultStatus("Range",3)=ODSMin_"-"_ODSMax
	.
	.
	.// 无年龄性别的限制 通用
	.i (""'=ODSSex)&&(""'=ODSAgeMin)&&(""'=ODSAgeMax) d
	..
	..s:("N"=ODType)||("C"=ODType) ^TMPResultStatus("Range",4)=ODSMin_"-"_ODSMax
	..
	.
	.
	.
	.Quit:tempNormal'="Y"
	.Quit:(((tempAgeMin>age)||(tempAgeMax<age))&&((tempAgeMin'=0)&&(tempAgeMax'=0)))
	.Quit:(tempSex'="N")&&(tempSex'=sex)
	.set Normal="Y"
	.If ItemType="N" Do
	..
	..
	..Set NormalStr=Min_ItemUOM_" - "_Max_ItemUOM
	.Else  Do
	..Set NormalStr=$P(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",Chl),"^",2)
	//
	Quit NormalStr
}

/// 获取LIS格式数据
ClassMethod GetRISResult(PAAdmRowid As %String, arcimRowID As %String, ARCIMDR As %String, ExTestId As %String = "")
{
	
	i ExTestId="" s ExTestId=arcimRowID
	s iLLoop=+$O(^TMPReport(UserID,"Result", "Content", ExTestId,""),-1)
	s iLLoop=iLLoop+1
	s RisStation="^"_$g(^DHCPESetting("DHCPE","StationId_Ris"))_"^"
	s NotNormalResult=""
	s STRowId=""
	// RLT_OD_DR
	s Sequence=""
	f  s Sequence=$O(^DHCPEODR(0,"Sequence",ARCIMDR,Sequence)) q:Sequence=""  d
	.s RowId=""
	.f  s RowId=$O(^DHCPEODR(0,"Sequence",ARCIMDR,Sequence,RowId)) q:RowId=""  d
	..Set RLTODDR=$P($g(^DHCPEODR(RowId)),"^",2)
	..s ODDesc=$p($G(^DHCPEST(+RLTODDR,"OD",$P(RLTODDR,"||",2))),"^",1)	//细项名称	DHC_PE_OrderDetail
	..Q:(""=ODDesc)
	..i $D(^DHCPERLT(0,"OEORI",ExTestId)) d
	...s RLTRowid=0
	...s RLTResult=""
	...s RLTTemplateDesc=""
	...s ODUnit=""
	...s RLTNormal=""
	...s Flag=0
	...s RLTID=""
	...f  s RLTRowid=$o(^DHCPERLT(0,"ADMOD", PAAdmRowid, arcimRowID,RLTODDR, RLTRowid)) Q:(""=RLTRowid)||(Flag=2)  d 
	....//RLT_OD_DR	细项
	....s RLTID=RLTRowid
	....s ODRowId=$p(^DHCPERLT(RLTRowid),"^",3)
	....q:ODRowId=""
	....;d ..GetHistoryResult(PAAdmRowid,ODRowId,ARCIMDR)
	....s:$G(^DHCPEDataEx("DHCPEOrderDetail","NoPrint",ODRowId))="Y" Flag=2
	....q:Flag=2     
	....s STRowId=$p(ODRowId,"||",1)			//站点编码
	....s Station="^"_STRowId_"^"
	....s ODChildSub=$p(ODRowId,"||",2)		//项目编码
	....//OD_Desc
	....s ODType=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",2)
	....s Standard=..GetStandard(STRowId_"||"_ODChildSub,$G(^TMPReport(UserID,"Result","Sex")),$G(^TMPReport(UserID,"Result","Age")))
	....//OD_Unit
	....s ODUnit=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",4)
	....
	....//if (""'=ODUnit) s ODUnit=$p($g(^CT(ODUnit)),"^",2)	//CT_UOM
	....s:'(("N"=ODType)||("Number"=ODType)||("C"=ODType)||("Calcul"=ODType)) ODUnit=""
	....//检验结果
	....s Result=$p($G(^DHCPERLT(RLTRowid)),"^",4)
	....q:Result=" "
	....i Result="" d
	.....s Result=$g(^DHCPETempResult(arcimRowID))
	....q:Result=""
	....s RLTResult=$G(RLTResult)_Result_$C(13)_$C(10)
    ....s RLTTemplateDesc=RLTTemplateDesc_$p($G(^DHCPERLT(RLTRowid)),"^",10)_$C(13)_$C(10)
    ....//是否正常
	....s RLTNormal=$p(^DHCPERLT(RLTRowid),"^",7)
	....i (+RLTNormal=1)  d
	.....s RLTNormal="正常"
	....e  d
	.....s RLTNormal="异常"
	.....i RisStation[Station d
	......s OneInfo=$P(Result,";诊断意见:",2)
	.....e  d
	......s OneInfo=ODDesc_":"_Result
	.....i NotNormalResult="" d
	......s NotNormalResult=OneInfo
	.....e  d
	......s NotNormalResult=NotNormalResult_";"_OneInfo
	....s Flag=1
	...q:Flag'=1
	...s RLTTemplateDesc=$P(RLTTemplateDesc,$C(13)_$c(10),1,$L(RLTTemplateDesc,$C(13)_$C(10))-1)
	...s RLTResult=$P(RLTResult,$C(13)_$c(10),1,$L(RLTResult,$C(13)_$C(10))-1)
	..e  d
	...s (RLTResult,RLTNormal,ODUnit,RLTTemplateDesc,RLTID)=""
	..q:(RLTResult="")&&($D(^DHCPERLT(0,"OEORI",ExTestId)))
	..;s ^wrzResult(ExTestId)=RLTResult
	..s ^TMPReport(UserID,"Result", "Content", ExTestId,iLLoop)=ODDesc_"^"_RLTResult_"^"_RLTNormal_"^"_ODUnit_"^"_RLTTemplateDesc_"^"_RLTID_"^"_$G(Standard)
	..s iLLoop=1+iLLoop
	
	q:STRowId=""
	s ReportType=$G(^DHCPEDataEx("ReportItemSort",ARCIMDR))
	i ReportType="" d
	.s ReportSort="99"
	.s ReportTypeDesc="没有分类"
	e  d
	.s ReportSort=$P($G(^DHCPEDataEx("ReportItem",ReportType)),"^",2)
	.s ReportTypeDesc=$P($G(^DHCPEDataEx("ReportItem",ReportType)),"^",1)
	i NotNormalResult="" s NotNormalResult="未见异常"
	s ^TMPReport(UserID,"Result", "NotNormalResult",ReportSort,ReportTypeDesc,STRowId,ExTestId)=$G(^TMPReport(UserID,"Result", "NotNormalResult",ReportSort,ReportTypeDesc,STRowId,ExTestId))_NotNormalResult
}

/// /0 继续向下执行
/// /1 返回
ClassMethod GetRisARCDesc(OEOrdItemID)
{
	s $ZT="Error"
	s curArcimID=$P(^OEORD(+OEOrdItemID,"I",$P(OEOrdItemID,"||",2),1),"^",2)
	s StationID=$O(^DHCPEST(0,"STORD_ARCIM",curArcimID,0))
	;q 0
	;q:StationID'="8" 0
	s curResult=$O(^DHCPERLT(0,"OEORI",OEOrdItemID,0))
	q:curResult="" 0
	s resultDesc=$P(^DHCPERLT(curResult),"^",4)
	q:resultDesc="" 0
	q:resultDesc["详见报告" 0
	
	Set RARRowId=$o(^DHCPACRegInfoi("OEORI",OEOrdItemID,0))
	
	q:RARRowId="" 0
	Set RisStudyNo=$p(^DHCPACRegInfo(RARRowId),"^",2)
	i $D(^TMPReport(UserID,"Result","RisStudyNo",RisStudyNo))
	{
		s OEIID=$G(^TMPReport(UserID,"Result","RisStudyNo",RisStudyNo))
		s OldDesc=$p(^TMPReport(UserID,"Result","ARCIM",OEIID),"^",1)
		s $p(^TMPReport(UserID,"Result","ARCIM",OEIID),"^",1)=OldDesc_"、"_ARCIMDesc
		q "1"
	}else{
		s OldStudyNo=""
		s StudyNo=""
		f  s StudyNo=$O(^TMPReport(UserID,"Result","RisStudyNoResult",StationID,StudyNo)) q:(StudyNo="")||(OldStudyNo'="")  d
		.s OldResult=$G(^TMPReport(UserID,"Result","RisStudyNoResult",StationID,StudyNo))
		.i OldResult=resultDesc d
		..s OldStudyNo=StudyNo
		i OldStudyNo'=""{
			s OEIID=$G(^TMPReport(UserID,"Result","RisStudyNo",OldStudyNo))
			s OldDesc=$p(^TMPReport(UserID,"Result","ARCIM",OEIID),"^",1)
			s $p(^TMPReport(UserID,"Result","ARCIM",OEIID),"^",1)=OldDesc_"、"_ARCIMDesc
			q "1"
		}
	}
	s ^TMPReport(UserID,"Result","RisStudyNo",RisStudyNo)=OEOrdItemID
	s ^TMPReport(UserID,"Result","RisStudyNoResult",StationID,RisStudyNo)=resultDesc
	q 0
Error
	q 0
}

/// 科室小结
/// d ##Class(web.DHCPE.ReportGetInfor).GetSummarize(5747947)
ClassMethod GetSummarize(PAAdmRowid As %String, UserID As %String)
{
	 //Set UserID=%session.Get("LOGON.USERID")
	 s:UserID="" UserID=PAAdmRowid
	//站点（科室）小结 DHC_PE_StationSummarize （所有阳性体症）
	k ^TMPReport(UserID,"Summarize")

	s Delimit="^"
	s IADMRowId=""
	s IADMRowId=$O(^DHCPEIADM(0,"PAADM",PAAdmRowid,IADMRowId))
	i ""'=IADMRowId d
	.s STRowId=""	//科室编码
	.f  s STRowId=$o(^DHCPESS(0,"IADM",IADMRowId,STRowId)) q:STRowId=""  d
	..s SDesc=$p($G(^DHCPEST(STRowId)),"^",2)	//站点名称
	..Q:(""=SDesc)
	..s RowId=""	//小结编码	
	..f  s RowId=$o(^DHCPESS(0,"IADM",IADMRowId,STRowId,RowId)) q:RowId=""  d
	...d GetOneInfo
	e  d
	.s STRowId=""	//科室编码
	.f  s STRowId=$o(^DHCPESS(0,"PAADM",PAAdmRowid,STRowId)) q:STRowId=""  d
	..s SDesc=$p($G(^DHCPEST(STRowId)),"^",2)	//站点名称
	..Q:(""=SDesc)
	..s RowId=""	//小结编码	
	..f  s RowId=$o(^DHCPESS(0,"PAADM",PAAdmRowid,STRowId,RowId)) q:RowId=""  d
	...d GetOneInfo
	s gSSID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAAdmRowid)
	s ^TMPReport(UserID,"Summarize", "Contentgather")=..GetStationSummarizegather(gSSID)
	Q 1
GetOneInfo	
	s AduitUser=$p(^DHCPESS(RowId,1),"^",4)	//审核人
  	i (""'=AduitUser) s AduitUser=$p($g(^SSU("SSUSR",AduitUser)),"^",2)	//检查医师名称	SS_User
  	
  	//GA_AduitDate
  	s AduitDate=$p(^DHCPESS(RowId,1),"^",3)	//审核日期
    i (""'=AduitDate) s AduitDate=$ZD(AduitDate,3)
	
	s ^TMPReport(UserID,"Summarize", "Station", STRowId)=SDesc
	
	// 科室小结   原来调用阳性体征现改为建议
	s ^TMPReport(UserID,"Summarize", "Content", SDesc)=..GetStationAdvice(RowId)
	//$p($G(^DHCPESS(RowId,"S")),"^",5)
	// 科室检查人
	s ^TMPReport(UserID,"Summarize", "Content", SDesc, "AduitUser")=AduitUser
	
	// 科室检查日期
	s ^TMPReport(UserID,"Summarize", "Content", SDesc, "AduitDate")=AduitDate
	
	q
}

/// 得到总检的阳性体征
ClassMethod GetStationSummarizegather(SSID)
{
	q:SSID="" ""
	s Sub=0
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s RisStation="^"_$g(^DHCPESetting("DHCPE","StationId_Ris"))_"^"
	s Job=$j
	k ^TempDHCPE("StationSummarize",Job)
	s Result=""
	f  s Sub=$o(^DHCPEGS(SSID,"Result",Sub)) q:Sub=""  d
 	.s Report=$p(^DHCPEGS(SSID,"Result",Sub),"^",6)
 	.q:Report="N"
 	.s SSRId=SSID_"||"_Sub
 	.s SRID=$p(^DHCPEGS(SSID,"Result",Sub),"^",1)
 	.s RLID=$p($G(^DHCPESS($p(SRID,"||",1),"Result",$p(SRID,"||",2))),"^",1)
 	.s stationID=$p($G(^DHCPESS(+SRID,1)),"^",2)
 	.q:RLID=""
 	.s RIDDesc=$p($g(^DHCPERLT(RLID)),"^",4)
 	.s TempDesc=$p($g(^DHCPERLT(RLID)),"^",10)
 	.i TempDesc'="" s TempDesc=" 模版:"_TempDesc
 	.s OrderDetailID=$p($g(^DHCPERLT(RLID)),"^",3)
 	.s ARCIM=$p($g(^DHCPERLT(RLID)),"^",3)
 	.i ARCIM'="" d
 	..s ItemDesc=$p($g(^DHCPEST(+ARCIM,"OD",$p(ARCIM,"||",2))),"^",1)
 	..s ItemUOMDr=$P($g(^DHCPEST(+ARCIM,"OD",$P(ARCIM,"||",2))),"^",4)
 	.e  d
 	..s ItemDesc=""
 	..s ItemUOMDr=""
 	.s Station="^"_stationID_"^"
 	.
 	.//如果是检查结果、转换结果
    .i RisStation[Station d
    ..s RIDDesc=##class(web.DHCPE.ResultDiagnosis).GetRisResult(RIDDesc)
 	.
 	.
 	.s RIDDesc=RIDDesc_" "_ItemUOMDr
 	.s Remark=$p(^DHCPEGS(SSID,"Result",Sub),"^",2)
 	.i Remark'="" s Remark=" 备注:"_Remark
 	.s i=+$o(^TempDHCPE("StationSummarize",Job,stationID,""),-1)+1
 	.s ^TempDHCPE("StationSummarize",Job,stationID,i)=ItemDesc_": "_RIDDesc_" "_TempDesc_" "_Remark
 	
 	s station=0
 	f  s station=$o(^TempDHCPE("StationSummarize",Job,station)) q:station=""  d
 	.s stationDesc="<b>"_$p($G(^DHCPEST(station)),"^",2)_"</b>"
 	.i Result="" d
	..s Result=stationDesc
	.e  d
	..s Result=Result_stationDesc
 	.s i=0
 	.f  s i=$o(^TempDHCPE("StationSummarize",Job,station,i)) q:i=""  d
 	..s j=$o(^TempDHCPE("StationSummarize",Job,station,""),-1)
 	..i j>1 d
 	...s desc=i_"、"_$G(^TempDHCPE("StationSummarize",Job,station,i))
 	..e  d
 	...s desc=$G(^TempDHCPE("StationSummarize",Job,station,i))
 	..i Result="" d
	...s Result=desc
	..e  d
	...s Result=Result_$C(13,10)_desc
	.s Result=Result_"<br>"
 	
 	
 	k ^TempDHCPE("StationSummarize",Job)

	
	q Result
}

/// 得到各个科室的建议
ClassMethod GetStationAdvice(SSID)
{
	s Advice=""
	s SSub=0
	f  s SSub=$o(^DHCPESS(SSID,"Diagnosis",SSub)) q:SSub=""  d
	.s EDID=$p($G(^DHCPESS(SSID,"Diagnosis",SSub)),"^",1)
	.s EDDesc=$p($g(^DHCPEED(EDID,"Detail")),"^",1)
	.s DiagnoseConclusion=$p($g(^DHCPEED(EDID,"1")),"^",1)
	.s EDDesc=DiagnoseConclusion
	.s Suggest=$p($G(^DHCPESS(SSID,"Diagnosis",SSub)),"^",7)
	.// _": "_EDDesc
	.s Remark=$p($G(^DHCPESS(SSID,"Diagnosis",SSub)),"^",2)
	.i Remark'="" s Remark=" 备注:"_Remark
	.i Advice="" d
	..s Advice="<b>"_EDDesc_":</b>"_Suggest
	..//_" "_SRemark
	.e  d
	..s Advice=Advice_$C(13,10)_"<b>"_EDDesc_":</b>"_Suggest
	..//_" "_SRemark
	q Advice
}

/// 得到各个科室的小结
ClassMethod GetStationSummarize(SSID)
{
	s SSub=0
	s Result=""
	s Station=$p(^DHCPESS(SSID,1),"^",2)
	s Station="^"_Station_"^"
	s RisStation="^"_$g(^DHCPESetting("DHCPE","StationId_Ris"))_"^"
	q:RisStation[Station Result
	f  s SSub=$o(^DHCPESS(SSID,"Result",SSub))  q:SSub=""  d
	.s RLTDR=$p(^DHCPESS(SSID,"Result",SSub),"^",1)
	.s RLDesc=$p($g(^DHCPERLT(RLTDR)),"^",4)
	.s TempDesc=$p($g(^DHCPERLT(RLTDR)),"^",10)
	.i TempDesc'="" s TempDesc=" 模版:"_TempDesc
	.s SSRemark=$p(^DHCPESS(SSID,"Result",SSub),"^",2)
	.i SSRemark'="" s SSRemark=" 备注:"_SSRemark
	.s ARCIM=$p($g(^DHCPERLT(RLTDR)),"^",3)
 	.i ARCIM'="" d
 	..s ItemDesc=$p($g(^DHCPEST(+ARCIM,"OD",$p(ARCIM,"||",2))),"^",1)
 	..s ItemUOMDr=$P($g(^DHCPEST(+ARCIM,"OD",$P(ARCIM,"||",2))),"^",4)
 	.e  d
 	..s ItemDesc=""
 	..s ItemUOMDr=""
	.i Result="" d
	..s Result=ItemDesc_": "_RLDesc_" "_ItemUOMDr_" "_SSRemark
	.e  d
	..s Result=Result_$C(13,10)_ItemDesc_": "_RLDesc_" "_ItemUOMDr_" "_TempDesc_" "_SSRemark
	s Remark=$p($g(^DHCPESS(SSID,"S")),"^",1)
	i Result="" d
	.s Result=Remark
	e  d
	.s Result=Result_$C(13,10)_Remark
	q Result
}

/// 总检建议 DHC_PE_GeneralAdvice ^DHCPEGA
/// d ##Class(web.DHCPE.ReportGetInfor).GetGeneralAdvice(5747947)
ClassMethod GetGeneralAdvice(PAAdmRowid As %String, UserID As %String, NeedMainDoctorFlag As %String = "Y")
{
  
    //Set UserID=%session.Get("LOGON.USERID")
    s:UserID="" UserID=PAAdmRowid
	k ^TMPReport(UserID,"GeneralAdvice")
	s CurLocID=$P(^PAADM(PAAdmRowid),"^",4)
	s MainDoctorFlag=$G(^DHCPESetting("DHCPE","MainDoctorGroup",CurLocID))
	s:NeedMainDoctorFlag'="Y" MainDoctorFlag="N"
	s Advice=""
	s gSSID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAAdmRowid)
	q:gSSID=""
	s ID=$O(^User.DHCPEGSSumI("IndexParref",gSSID,0))
	i ID'=""
	{
		s obj=##class(User.DHCPEGSSum).%OpenId(ID)
		s Stream=obj.GSSDetail
		s len=Stream.SizeGet()
    	d Stream.Rewind()
		s Advice=Stream.Read(len)
		i Advice="" d
		.s Advice=" 1、[在您本次体检项目中，未发现明显异常]"_$C(13,10)_"       珍惜生命，关注健康，请您继续坚持定期健康体检。"
		i $L(Advice,"、[")="2" d
		.i Advice[("、[体重正常]") d
		..s Advice=Advice_$C(13,10)_$C(13,10)_" 2、[在您本次体检项目中，未发现明显异常]"_$C(13,10)_"       珍惜生命，关注健康，请您继续坚持定期健康体检。"
		
		
	}
	else
	{
		s Sort=0
		f  s Sort=$o(^DHCPEGS(0,"GSDSort",gSSID,Sort)) q:Sort=""  d
 		.s gSub=0
 		.f  s gSub=$o(^DHCPEGS(0,"GSDSort",gSSID,Sort,gSub)) q:gSub=""  d
		..q:'$D(^DHCPEDataEx("DHCPEGeneralSummarize","ReCheckDetail",gSSID_"||"_gSub))&&(MainDoctorFlag="Y")
		..s Status=$p(^DHCPEGS(gSSID,"Diagnosis",gSub),"^",11)
		..q:Status'="0"
		..s EDID=$p(^DHCPEGS(gSSID,"Diagnosis",gSub),"^",1)
		..q:EDID=""
		..s EDCDR=$G(^DHCPEDataEx("DHCPEGSDiagnosis","EDCDR",gSSID_"||"_gSub))
		..i EDCDR="" s EDCDR="0"
		..s EDCode=$p($G(^DHCPEEDC(EDCDR)),"^",1)
		..i EDCode="" s EDCode="0"
		..s EDDesc=$p(^DHCPEGS(gSSID,"Diagnosis",gSub),"^",9)
		..s EDDesc=..ReplaceXH(EDDesc)
		..//$p($g(^DHCPEED(EDID,"Detail")),"^",1)
		..s DiagnoseConclusion=$p($g(^DHCPEED(EDID,"1")),"^",1)
		..Set GSDRowId=gSSID_"||"_gSub   //Add 20080728
		..If $d(^DHCPEDataEx("DHCPEGSDiagnosis","DisplayDesc",GSDRowId))'=0 Do   //Add 20080728
		...Set DiagnoseConclusion=$g(^DHCPEDataEx("DHCPEGSDiagnosis","DisplayDesc",GSDRowId))   //Add 20080728
		..s AdviceResult=..GetAdviceResult(EDID,PAAdmRowid)
		..i AdviceResult'="" d
		...s EDDesc=AdviceResult_"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"_EDDesc
		.. s DiagnoseConclusion="<b>"_DiagnoseConclusion_"</b>"
  		..i DiagnoseConclusion["未见异常"  d
  		...s EDDesc=DiagnoseConclusion_" "_EDDesc
  		..e  d
  		...s EDDesc=DiagnoseConclusion_"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"_EDDesc
		..s SRemark=$p(^DHCPEGS(gSSID,"Diagnosis",gSub),"^",3)
		..i SRemark'="" s SRemark=" 备注:"_SRemark
		..s Sub=+$o(^TMPReport(UserID,"GeneralAdvice","Temp",EDCode,EDCDR,Sort,""),-1)+1
		..s ^TMPReport(UserID,"GeneralAdvice","Temp",EDCode,EDCDR,Sort,Sub)=EDDesc
		..//上海贵宾客户每个项目的建议
		..s OEItemID=$G(^DHCPEDataEx("GDiaginosis",gSSID_"||"_gSub))
		..i OEItemID'="" d
		...s OESub=+$o(^TMPReport(UserID,"GeneralAdvice","OEItemTemp",OEItemID,EDCode,EDCDR,Sort,""),-1)+1
		...s ^TMPReport(UserID,"GeneralAdvice","OEItemTemp",OEItemID,EDCode,EDCDR,Sort,OESub)=EDDesc
	
		s i=0
		s EDCode=""
		f  s EDCode=$o(^TMPReport(UserID,"GeneralAdvice","Temp",EDCode)) q:EDCode=""  d 
		.s EDCDR=""
		.f  s EDCDR=$o(^TMPReport(UserID,"GeneralAdvice","Temp",EDCode,EDCDR)) q:EDCDR=""  d
		..s EDCDesc=$p($G(^DHCPEEDC(EDCDR)),"^",2)
		..i EDCDesc'="" d
		...s EDCDesc="<b>"_EDCDesc_"</b>"
		...i Advice="" d
		....s Advice=EDCDesc
		...e  d
		....s Advice=Advice_$C(13,10)_EDCDesc
		..s Sort=""
		..f  s Sort=$o(^TMPReport(UserID,"GeneralAdvice","Temp",EDCode,EDCDR,Sort)) q:Sort=""  d
		...s Sub=""
		...f  s Sub=$o(^TMPReport(UserID,"GeneralAdvice","Temp",EDCode,EDCDR,Sort,Sub)) q:Sub=""  d
		....s EDDesc=$G(^TMPReport(UserID,"GeneralAdvice","Temp",EDCode,EDCDR,Sort,Sub))
		....s i=i+1
		....i Advice="" d
		.....s Advice=i_"、"_EDDesc
		....e  d
		.....s Advice=Advice_"<br>"_i_"、"_EDDesc
		s Remark=$p($g(^DHCPEGS(gSSID,"S")),"^",1)
		i Advice="" d
		.s Advice=Remark
		e  d
		.s Advice=Advice_$C(13,10)_Remark
	}
	
	s ^TMPReport(UserID,"GeneralAdvice","Advice")=Advice
	
	////每个项目的建议  20090531 sh
	s OEItemID=""
	f  s OEItemID=$o(^TMPReport(UserID,"GeneralAdvice","OEItemTemp",OEItemID))  q:OEItemID=""  d //,EDCode,EDCDR,Sort,OESub)
	.s i=0
	.s Advice=""
	.s EDCode=""
	.f  s EDCode=$o(^TMPReport(UserID,"GeneralAdvice","OEItemTemp",OEItemID,EDCode))  q:EDCode=""  d //,EDCode,EDCDR,Sort,OESub)
	..s EDCDR=""
	..f  s EDCDR=$o(^TMPReport(UserID,"GeneralAdvice","OEItemTemp",OEItemID,EDCode,EDCDR)) q:EDCDR=""  d
	...s EDCDesc=$p($G(^DHCPEEDC(EDCDR)),"^",2)
	...i EDCDesc'="" d
	....s EDCDesc="<b>"_EDCDesc_"</b>"
	....i Advice="" d
	.....s Advice=EDCDesc
	....e  d
	.....s Advice=Advice_$C(13,10)_EDCDesc
	...s Sort=""
	...f  s Sort=$o(^TMPReport(UserID,"GeneralAdvice","OEItemTemp",OEItemID,EDCode,EDCDR,Sort)) q:Sort=""  d
	....s Sub=""
	....f  s Sub=$o(^TMPReport(UserID,"GeneralAdvice","OEItemTemp",OEItemID,EDCode,EDCDR,Sort,Sub)) q:Sub=""  d
	.....s EDDesc=$G(^TMPReport(UserID,"GeneralAdvice","OEItemTemp",OEItemID,EDCode,EDCDR,Sort,Sub))
	.....s i=i+1
	.....i Advice="" d
	......s Advice=i_"、"_EDDesc
	.....e  d
	......s Advice=Advice_$C(13,10)_i_"、"_EDDesc
	.s ^TMPReport(UserID,"GeneralAdvice","OEItemAdvice",OEItemID)=Advice
	////
	
	s RowId=gSSID
	s AduitUserDate=""
	s AduitUser=""
	i RowId'="" s AduitUserDate=$p(^DHCPEGS(RowId,1),"^",6)
	i AduitUserDate'=""  s AduitUserDate=$zd(AduitUserDate,3)
	i RowId'="" s AduitUser=$p(^DHCPEGS(RowId,1),"^",5)
	i AduitUser'="" s AduitUser=$p($g(^SSU("SSUSR",AduitUser)),"^",2)
	s MainDoctorInfo=$G(^DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",PAAdmRowid))    //add 
	s MainDoctor=$p(MainDoctorInfo,"^",1)                                                 //add 
	i MainDoctor'="" s MainDoctor=$p($g(^SSU("SSUSR",MainDoctor)),"^",2)                  //add 
	s MainDoctorDate=$p(MainDoctorInfo,"^",2)                                             //add 
	i MainDoctorDate'=""  s MainDoctorDate=$zd(MainDoctorDate,3)                          //add 
	s ^TMPReport(UserID,"GeneralAdvice","AduitUser")=AduitUser
	s ^TMPReport(UserID,"GeneralAdvice","AduitUserDate")=AduitUserDate
	s ^TMPReport(UserID,"GeneralAdvice","MainDoctor")=MainDoctor                                 //add 
	s ^TMPReport(UserID,"GeneralAdvice","MainDoctorDate")=MainDoctorDate                        //add 

	q 1
}

ClassMethod GetAdviceResult(EDRowId, EpisodeID)
{
	;w ##class(web.DHCPE.ReportGetInfor).GetAdviceResult(5161,6692127)
	s ret=""
	s Job=$J
	k ^TempDHCPE(Job,"EDRelate",EDRowId)
	s LabStation=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s RisStation=$g(^DHCPESetting("DHCPE","StationId_Ris"))
	s myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(EpisodeID)
	s myAge=$p(myStr,"^",1)
	s mySex=$p(myStr,"^",2)
	s ExpressID=$O(^User.DHCPEExpressI("SourceIDIndex","ED",EDRowId,0))
	i ExpressID'=""  d
	.s Express=""
	.s ExpressID=0
	.f  s ExpressID=$O(^User.DHCPEExpressI("SourceIDIndex","ED",EDRowId,ExpressID)) q:ExpressID=""  d
	..s obj=##class(User.DHCPEExpress).%OpenId(ExpressID)
	..s Express=Express_obj.EPreBracket
	..s ItemID=obj.EItemDRGetObjectId()
	..s ItemID=##class(web.DHCPE.ResultEdit).GetUseItemID(EpisodeID,ItemID,EDRowId)
	..q:ItemID=""
	..q:$D(^TempDHCPE(Job,"EDRelate",EDRowId,ItemID))
	..s ItemDesc=obj.EItemDR.ODDesc
	..s OneResult=""
	..i $D(^DHCPERLT(0,"PAADM_OD",EpisodeID,ItemID)) d  ;;逐个判断此细项是否满足
	...s ^TempDHCPE(Job,"EDRelate",EDRowId,ItemID)=""
	...s RLTID=0
	...f  s RLTID=$O(^DHCPERLT(0,"PAADM_OD",EpisodeID,ItemID,RLTID)) q:(RLTID="")  d
 	....s NormalFlag=$P(^DHCPERLT(RLTID),"^",7)
 	....q:NormalFlag=1
 	....s Result=..GetBloodPressureResult(EpisodeID,ItemID,Job,EDRowId)
 	....s:Result'="" OneResult=Result
 	....q:Result'=""
 	....s ODID=$P(^DHCPERLT(RLTID),"^",3)
	....s ODType=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
	....q:(ODType="T")||(ODType="S")
	....s Result=$P(^DHCPERLT(RLTID),"^",4)
 	....s ResultApp=Result
 	....;s Unit=$G(^DHCPEDataEx("DHCPEResult",RLTID,"Unit"))
 	....;s Ranges=$G(^DHCPEDataEx("DHCPEResult",RLTID,"Ranges"))
 	....i LabStation=+ODID d
 	.....s Ranges=$G(^DHCPEDataEx("DHCPEResult",RLTID,"Ranges"))
 	.....s Unit=$G(^DHCPEDataEx("DHCPEResult",RLTID,"Unit"))
 	....e  d
 	.....s Ranges=##class(web.DHCPE.ResultEdit).GetNormal(ODID,mySex,myAge)
 	.....b ;ODID
 	.....s Unit=$P($g(^DHCPEST(+ODID,"OD",$P(ODID,"||",2))),"^",4)
	
 	
 	....s:Ranges'="" Ranges=Ranges_" "_Unit
 	....s:(Ranges'="")&&(Ranges'[("阴性")) Result=Result_" "_Unit_"("_Ranges_")"
 	....i OneResult="" d
 	.....s OneResult=Result
 	....e  d
 	.....s OneResult=OneResult_";"_Result
 	....;得到检验异常箭头
 	....s TSInfo="1"
	....s:(ODType="N")||(ODType="C") TSInfo=##class(web.DHCPE.TransResult).GetLabResultArrowNew(RLTID)
	....s:TSInfo="2" TSInfo="↑"
	....s:TSInfo="0" TSInfo="↓"
	....s:TSInfo'="1" OneResult=OneResult_" "_TSInfo
 	...q:ItemDesc="收缩压"
 	...q:ItemDesc="舒张压"
 	...s:OneResult'="" OneResult=ItemDesc_"："_OneResult
 	..q:OneResult=""
 	..i ret=""  d
 	...s ret=$C(13,10)_"               "_OneResult
 	..e  d
 	...s ret=ret_$C(13,10)_"               "_OneResult
 	s ret=..Replace(ret,"*","")
 	k ^TempDHCPE(Job,"EDRelate",EDRowId)
 	q ret //_"^"_EDRowId_"^"_EpisodeID
}

// w ##class(web.DHCPE.ReportGetInfor).GetBloodPressureResult("4041906","1||24",1)

ClassMethod GetBloodPressureResult(EpisodeID, ItemID, Job, EDRowId)
{
	s HItemID="1||24"
	s LItemID="1||25"
	q:(LItemID'=ItemID)&&(HItemID'=ItemID) ""
	s HRLT=$O(^DHCPERLT(0,"PAADM_OD",EpisodeID,HItemID,""))
	q:HRLT="" ""
	s HResult=$P(^DHCPERLT(HRLT),"^",4)
	s LRLT=$O(^DHCPERLT(0,"PAADM_OD",EpisodeID,LItemID,""))
	q:LRLT="" ""
	s LResult=$P(^DHCPERLT(LRLT),"^",4)
	s Result="血压："_HResult_"/"_LResult_"mmHg"
	s ^TempDHCPE(Job,"EDRelate",EDRowId,HItemID)=""
	s ^TempDHCPE(Job,"EDRelate",EDRowId,LItemID)=""
	q Result
}

/// 根据医嘱得到对应Ris图片
/// w ##class(web.DHCPE.ReportGetInfor).GetPhotoPath("211340||12")
ClassMethod GetPhotoPath(OeordId)
{
	//##class(web.DHCRisStorage).GetLocInfo("1140")
	//##class(web.DHCRisclinicQueryOEItemDo).GetFTPByStudyNo(RisStudyNo)
	s RetStr=""
	Set RARRowId=$o(^DHCPACRegInfoi("OEORI",OeordId,0))
	Quit:$g(RARRowId)="" RetStr
	Set RisStudyNo=$p(^DHCPACRegInfo(RARRowId),"^",2)
	Quit:$g(RisStudyNo)="" RetStr
	s CurZN=$ZNSPACE
	s ReportId=##class(web.DHCPE.TransResult).GetMaxRisReportID(RisStudyNo)
	Quit:$g(ReportId)="" RetStr
	
	s ReportSub=0
	f  s ReportSub=$o(^DHCRBStudy(0,"ReportFiles",ReportId,ReportSub)) q:(ReportSub="")  d
	.s ImageId=$p($g(^DHCRBStudy(0,"ReportFiles",ReportId,ReportSub)),"^",4)
	.//i ImageId="" d
	.//.s GetMediumDR=$p($G(^DHCRBStudy(0,"ReportFiles",ReportId,ReportSub)),"^",3)
	.//.s GetDRMName=""
	.//.i GetMediumDR'="" s GetDRMName=$p(^DHCRBCServer("Medium",GetMediumDR),"^",2)
	.q:ImageId=""
	.s Width=$p(^DHCRBStudy(0,"StudyImages",ImageId),"^",4)
	.s GetMediumDR=$p(^DHCRBStudy(0,"StudyImages",ImageId),"^",6)
	.s GetDRMName=""
	.i GetMediumDR'="" s GetDRMName=$p(^DHCRBCServer("Medium",GetMediumDR),"^",2)
	.s Height=$p(^DHCRBStudy(0,"StudyImages",ImageId),"^",3)
	.s FileName=$p($g(^DHCRBStudy(0,"StudyImages",ImageId)),"^",1)
	.s FileName=##class(web.DHCPE.ReportGetInfor).Replace(FileName,"\","/")
	.s ImageDesc=$p($g(^DHCRBStudy(0,"StudyImages",ImageId)),"^",8)
	.zn "RIS"
	.s ServerInfo=##class(web.DHCRisStorage).GetServerInfo(GetMediumDR)
	.zn CurZN
	.s IP=$p(ServerInfo,"^",2)
	.s Port=$p(ServerInfo,"^",3)
	.s User=$p(ServerInfo,"^",5)
	.s PWD=$p(ServerInfo,"^",6)
	.q:IP=""
	.s ServerInfo="ftp://"_User_":"_PWD_"@"_IP_":"_Port_"/"
	.s ServerInfo=ServerInfo_GetDRMName_""
	.i FileName'="" d
	..s FileName=ServerInfo_FileName_"^"_Width_"^"_Height_"^"_ImageDesc
	..i RetStr="" d
	...s RetStr=FileName
	..e  d
	...s RetStr=RetStr_$C(1)_FileName
	
	Quit RetStr
}

ClassMethod GetReportStatusByPAADM(PAADM)
{
	if (""=PAADM) q "0"	//无效 Adm
	s IADMRowId=0
	s IADMRowId=$O(^DHCPEIADM(0,"PAADM",PAADM,IADMRowId))
	q:(""=IADMRowId) "0"	//未找到体检人信息
	s RowId=0
	s RowId=$O(^DHCPERPT(0,"IADM",IADMRowId,RowId))
	q:(""=RowId) "0"		//未找到报告信息
	s CurData=$g(^DHCPERPT(RowId))	
	
	s Status=$p(CurData,"^",2)				//报告状态
	q:Status="NA" "0"
	q "1"
}

ClassMethod Replace(Strings, Str, Rep) As %String [ Language = basic ]
{
	return Replace(Strings,Str,Rep)
}

ClassMethod GetPatInfo(str)
{
	q $G(^TMPReport(UserID,"PatInfo",str))
}

ClassMethod GetRefuseItem(PAADM)
{
 s Items=##class(web.DHCPE.ResultEdit).GetRefuseItems(PAADM)
 i Items="" d
 .s RefuseItem="无"
 e  d
 .s RefuseItem=Items
}

// 

ClassMethod GetRZReportInfo(PIADM, Type As %String = "")
{
	i Type="IADM" d
	.s PIADM=$P(^DHCPEIADM(PIADM),"^",4)
	q ##class(web.DHCPE.RisRequestPrint).GetPatientInfo(PIADM)
}

ClassMethod ReplaceXH(EDDesc)
{
	q EDDesc
	s EDDesc=..Replace(EDDesc, "②", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;②")
	s EDDesc=..Replace(EDDesc, "③", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;③")
	s EDDesc=..Replace(EDDesc, "④", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;④")
	s EDDesc=..Replace(EDDesc, "⑤", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;⑤")
	s EDDesc=..Replace(EDDesc, "⑥", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;⑥")
	s EDDesc=..Replace(EDDesc, "⑦", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;⑦")
	s EDDesc=..Replace(EDDesc, "⑧", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;⑧")
	s EDDesc=..Replace(EDDesc, "⑨", "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;⑨")
	s EDDesc=..Replace(EDDesc, $C(13), "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
	q EDDesc
}

// w ##class(web.DHCPE.ReportGetInfor).GetIllExplain("531")

/// 得到诊所关联的疾病解释
ClassMethod GetIllExplain(PAADM, UserID As %String)
{
  

    //Set UserID=%session.Get("LOGON.USERID")
    s:UserID="" UserID=PAADM
    k ^TMPReport(UserID,"IllExplain") 
    s GSRowID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAADM)
	q:GSRowID=""
	s IllRowID=0,String=""
	f  s IllRowID=$o(^DHCPEDataEx("BaseData","IllnessStandard","GeneralDiagnosis",PAADM,IllRowID)) q:IllRowID=""  d
	.s IllExplain="",SportGuide="",DietGuide="",IllDesc="",IllStr=""
	.s IllDesc=$p(^DHCPEILLS(IllRowID),"^",2)
	.s IllExplain=$p($g(^DHCPEDataEx("BaseData","IllnessStandard","GeneralDiagnosis",PAADM,IllRowID)),"##",1)
 	.s SportGuide=$p($g(^DHCPEDataEx("BaseData","IllnessStandard","GeneralDiagnosis",PAADM,IllRowID)),"##",2)
 	.s DietGuide=$p($g(^DHCPEDataEx("BaseData","IllnessStandard","GeneralDiagnosis",PAADM,IllRowID)),"##",3)
    .q:$p($g(^DHCPEDataEx("BaseData","IllnessStandard","GeneralDiagnosis",PAADM,IllRowID)),"##",4)'="Y"
    .q:(IllExplain="")&&(SportGuide="")&&(DietGuide="")
    .s IllDesc="<b>"_IllDesc_":"_"</b>"
    .i IllExplain'=""  s IllStr=IllStr_"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"_IllExplain_$C(13,10)
    .i SportGuide'=""  s IllStr=IllStr_"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"_SportGuide_$C(13,10)
    .i DietGuide'=""  s IllStr=IllStr_"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"_DietGuide_$C(13,10)
    .s IllDesc=IllDesc_"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"_IllStr
    .i String=""  s String=IllDesc
    .else  s String=String_$C(13,10)_IllDesc
    s ^TMPReport(UserID,"IllExplain")=String
	q ""
}

// 0不可以打印  1可以打印

ClassMethod CanPrintSpecial(PAADM, Type)
{
	s ret=0
	i Type="DHCPEPISRequest" d
	.s Order=$O(^OEORD(0,"Adm",PAADM,0))
	.q:Order=""
	.//33059||1 HPV
	.s ItemID="33059||1"
	.s:$D(^OEORDi(0,"ARCIM",Order,ItemID)) ret=1
	.//33058||1 LCT
	.s ItemID="33058||1"
	.s:$D(^OEORDi(0,"ARCIM",Order,ItemID)) ret=1
	q ret
}

ClassMethod GetSpecialReportInfo(PAADM As %Library.String, Type As %Library.String) As %Library.String
{
	;w ##class(web.DHCPE.ReportGetInfor).GetSpecialReportInfo(273890,"DHCPEPISRequest")
	;固定信息写一个方法得到(基本信息、体检医生、体检日期等)
	;s ^DHCPESpecialReportInfo(Type,"Detail",ElementName)=ARCIMCode_"^"_DetailCode_"^"_ShowNormalDesc
	;s ^DHCPESpecialReportInfo("DHCPEPISRequest","Detail","JWS")="PE010^40001^N"  第三个报告中是否显示 正常、异常
	;s ^DHCPESpecialReportInfo(Type,"DetailStandard",ElementName)=ARCIMCode_"^"_DetailCode_"^"_StandardDesc^HadValue^NoValue
	;s ^DHCPESpecialReportInfo("NSFYYE","DetailStandard","GMS")="JC20126^1002^青霉素过敏^有(√)^无(×)"
	;s ^DHCPESpecialReportInfo(Type,"Template",ElementName)=ARCIMCode_"^"_DetailCode_"^"_StandardDesc^DefaultValue
	;s ^DHCPESpecialReportInfo("NSFYYE","Template","GMSMS")="JC20126^1002^青霉素过敏^DefaultValue"
	;s ^DHCPESpecialReportInfo(Type,"Order",ElementName)=ARCIMCode1^ARCIMCode2
	;s ^DHCPESpecialReportInfo("NSFYYE","Order","YKJCJG")="JC20040"
	n (PAADM,Type,%session)
	k ^DHCPESpecialReport(PAADM)
	s ret=..CanPrintSpecial(PAADM,Type)
	q:ret=0 ""
	s Flag=##class(web.DHCPE.DHCPEIAdm).HaveNoPayedItem(PAADM)
	q:Flag="1" "NoPayed"
	
	
	;k ^TEMPSpecialReport($J,PAADM,Type,"OrderStandard")
	Set myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(PAADM)
	Set myAge=$p(myStr,"^",1)
	Set mySex=$p(myStr,"^",2)
	
	s (JWS,YCS,JJNL,BYFS)=""
	
	
	s ResultInfo=""
	s InfoType=""
	f  s InfoType=$O(^DHCPESpecialReportInfo(Type,InfoType))  q:InfoType=""  d
	.s ElementName=""
	.f  s ElementName=$O(^DHCPESpecialReportInfo(Type,InfoType,ElementName))  q:ElementName=""  d
	..s Info=$G(^DHCPESpecialReportInfo(Type,InfoType,ElementName))
	..s Result=""
	..i InfoType'="Order"  d ;非大项对应的结果
	...s ARCCode=$P(Info,"^",1)
	...s ARCCode=$$ALPHAUP^SSUTIL4(ARCCode)
	...q:ARCCode=""
	...s ARCID=$O(^ARCIM(0,"Code",ARCCode,""))
	...q:ARCID=""
	...s RealArcCode=$P(^ARCIM(ARCID,1,1),"^",1)
	...s ARCID=ARCID_"||1"
	...s DetailCode=$P(Info,"^",2)
	...q:DetailCode=""
	...s DetailCode=$$ALPHAUP^SSUTIL4(DetailCode)
	...q:DetailCode=""
	...s STID=$O(^DHCPEST(0,"OD_Code",DetailCode,""))
	...q:STID=""
	...s Sub=$O(^DHCPEST(0,"OD_Code",DetailCode,STID,""))
	...s DetailID=STID_"||"_Sub
	...s DetailType=$P(^DHCPEST(STID,"OD",Sub),"^",2)
	...s RLTID=0
	...f  s RLTID=$O(^DHCPERLT(0,"PAADM_OD",PAADM,DetailID,RLTID)) q:RLTID=""  d
	....s CurARC=$P(^DHCPERLT(RLTID),"^",2)
	....q:CurARC'=ARCID
	....s CurResultInfo=$P(^DHCPERLT(RLTID),"^",4)
	....q:CurResultInfo=""
	
	....s DocUserID=$P(^DHCPERLT(RLTID),"^",5)
	....i DocUserID'="" d
	.....s DocUser=$P($G(^SSU("SSUSR",DocUserID)),"^",2)
	.....s ^DHCPESpecialReport(PAADM,RealArcCode)=DocUser
	
	....s HLFlag=""
	....i (DetailType="N")||(DetailType="C") d
	.....s Standard=..GetStandard(DetailID,mySex,myAge)
	.....s Arrow=##class(web.DHCPE.TransResult).GetLabResultArrow(Standard,CurResultInfo)
	.....s:Arrow="2" HLFlag="↑"
	.....s:Arrow="0" HLFlag="↓"
	.....s CurResultInfo=CurResultInfo_HLFlag
	....i InfoType="Detail" d  ;细项对应的结果
	.....s NormalFlag=$P(^DHCPERLT(RLTID),"^",7)
	.....s ShowFlag=$P(Info,"^",3)
	.....s:NormalFlag="1" NormalFlag="正常"
	.....s:NormalFlag="0" NormalFlag="异常"
	.....s:ShowFlag="Y" CurResultInfo=NormalFlag_"("_CurResultInfo_")"
	.....s CurResult=CurResultInfo
	.....i Result="" d
	......s Result=CurResult
	.....e  d
	......s Result=Result_" "_CurResult
	....e  i InfoType="DetailStandard"  d ;细项选择对应的结果
	.....s StandardDesc=$P(Info,"^",3)
	.....;q:$D(^TEMPSpecialReport($J,PAADM,Type,"OrderStandard",StandardDesc))
	.....;s ^TEMPSpecialReport($J,PAADM,Type,"OrderStandard",StandardDesc)=""
	.....s CurResult=""
	.....;w CurResultInfo_"^"_StandardDesc,!
	.....i CurResultInfo=StandardDesc d
	......s CurResult=$P(Info,"^",4)
	.....q:CurResult=""
	.....i Result="" d
	......s Result=CurResult
	.....e  d
	......s Result=Result_" "_CurResult
	....e  d ;模板对应的结果
	.....s CurResult=""
	.....s StandardDesc=$P(Info,"^",3)
	.....q:StandardDesc=""
	.....i CurResultInfo=StandardDesc d
	......s CurResult=$P(^DHCPERLT(RLTID),"^",10)
	.....i Result="" d
	......s Result=CurResult
	.....e  d
	......s Result=Result_" "_CurResult
	..e  d  ;大项对应的结果
	...s Length=$L(Info,"^")
	...f i=1:1:Length  d
	....s ARCCode=$P(Info,"^",i)
	....s ARCCode=$$ALPHAUP^SSUTIL4(ARCCode)
	....q:ARCCode=""
	....s ARCID=$O(^ARCIM(0,"Code",ARCCode,""))
	....q:ARCID=""
	....s RealArcCode=$P(^ARCIM(ARCID,1,1),"^",1)
	....s ARCID=ARCID_"||1"
	....s OrderID=$O(^OEORD(0,"Adm",PAADM,""))
	....q:OrderID=""
	....s SttDat=""
	....f  s SttDat=$O(^OEORDi(0,"ARCIM",OrderID,ARCID,SttDat)) q:SttDat=""  d
	.....s Sub=""
	.....f  s Sub=$O(^OEORDi(0,"ARCIM",OrderID,ARCID,SttDat,Sub)) q:Sub=""  d
	......s Stat=$P(^OEORD(OrderID,"I",Sub,1),"^",13)
	......q:Stat'="6"  ;不是执行退出
	......s ResultID=0
	......f  s ResultID=$O(^DHCPERLT(0,"OEORI",OrderID_"||"_Sub,ResultID)) q:ResultID=""  d
	.......s NormalFlag=$P(^DHCPERLT(ResultID),"^",7)
	.......q:NormalFlag="1" ;不是异常结果退出
	.......s CurResultInfo=$P(^DHCPERLT(ResultID),"^",4)
	.......s ODID=$P(^DHCPERLT(ResultID),"^",3)
	.......s StID=+ODID
	.......q:CurResultInfo=""
	
	.......s DocUserID=$P(^DHCPERLT(ResultID),"^",5)
	.......i DocUserID'="" d
	........s DocUser=$P($G(^SSU("SSUSR",DocUserID)),"^",2)
	........s ^DHCPESpecialReport(PAADM,RealArcCode)=DocUser
	
	
	.......s DetailType=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
	.......s HLFlag=""
	.......i (DetailType="N")||(DetailType="C") d
	........s Standard=..GetStandard(ODID,mySex,myAge)
	........s Arrow=##class(web.DHCPE.Trans1Result).GetLabResultArrow(Standard,CurResultInfo)
	........s:Arrow="2" HLFlag="↑"
	........s:Arrow="0" HLFlag="↓"
	........s CurResultInfo=CurResultInfo_HLFlag
	.......i ("^"_$G(^DHCPESetting("DHCPE","StationId_Ris"))_"^")[("^"_StID_"^") d ;检查项目的结果
	........s CurResultInfo=$P(CurResultInfo,";诊断意见:",2)
	.......e  d
	........s ODDesc=$P($g(^DHCPEST(+ODID,"OD",$P(ODID,"||",2))),"^",1)
	........s CurResultInfo=ODDesc_":"_CurResultInfo
	.......i Result="" d
	........s Result=CurResultInfo
	.......e  d
	........s Result=Result_" "_CurResultInfo
	..s:(Result="")&&(InfoType="Order") Result="正常"
	..s:(Result="")&&(InfoType="DetailStandard") Result=$P(Info,"^",5)  ;细项选择型的没有结果设置的值
	..s:(Result="")&&(InfoType="Template") Result=$P(Info,"^",4)  ;细项选择型的描述如果没有设置的默认值
	..q:Result=""
	
	..i ElementName="JWS"  d
	...s JWS=Result
	..e  i ElementName="JJNL"  d
	...s JJNL=Result
	..e  i ElementName="BYFS"  d
	...s BYFS=Result
	..e  i ElementName="YCS"  d
	...s YCS=Result
	..e  d
	...s OneInfo=ElementName_$C(2)_Result
	...i ResultInfo="" d
	....s ResultInfo=ElementName_$C(2)_Result
	...e  d
	....s ResultInfo=ResultInfo_"^"_ElementName_$C(2)_Result
	;s:JJNL'="" JJNL=" 绝经年龄："_JJNL
	;s:BYFS'="" BYFS=" 避孕方式："_BYFS
	;s:YCS'="" YCS=" 孕产史："_YCS
	;s JWS=JWS_JJNL_BYFS_YCS
	/*
	s BYFS=BYFS_"  "_YCS_"  "_JJNL ;显示顺序
	b ;JWS
	i $L(JWS)>24 d
	.s JWS1=$E(JWS,1,24)
	.s JWS2=$E(JWS,25,$L(JWS))
	.s OneInfo="JWS"_$C(2)_JWS1_"^JWS2"_$C(2)_JWS2
	e  d
	.s OneInfo="JWS"_$C(2)_JWS

	i $L(BYFS)>14 d
	.s BYFS1=$E(BYFS,1,20)
	.s BYFS2=$E(BYFS,21,$L(BYFS))
	.s OneInfo=OneInfo_"^"_"BYFS"_$C(2)_BYFS1_"^BYFS2"_$C(2)_BYFS2
	e  d
	.s OneInfo=OneInfo_"^"_"BYFS"_$C(2)_BYFS
	
	*/
	
	i ResultInfo="" d
	.s ResultInfo=OneInfo
	e  d
	.s ResultInfo=ResultInfo_"^"_OneInfo
	
	
	s PatInfo=..GetSpecialPatInfo(PAADM,Type)
	i ResultInfo="" d
	.s ResultInfo=PatInfo
	e  d
	.s ResultInfo=ResultInfo_"^"_PatInfo
	s ^tempxy("OneInfo22")=ResultInfo
	;k ^TEMPSpecialReport($J,PAADM,Type,"OrderStandard")
	q ResultInfo
}

ClassMethod GetSpecialDocInfo(PAADM, Type)
{
	s Ret=""
	s ArcCode=""
	f  s ArcCode=$O(^DHCPESpecialReport(PAADM,ArcCode)) q:ArcCode=""  d
	.q:'$D(^DHCPESpecialReportInfoBase(Type,ArcCode))
	.;..GetElementName(Type,"CurDate")_$C(2)_CurDate
	.s DocName=$G(^DHCPESpecialReport(PAADM,ArcCode))
	.q:DocName=""
	.i Ret="" d
	..s Ret=..GetElementName(Type,ArcCode)_$C(2)_DocName
	.e  d
	..s Ret=Ret_"^"_..GetElementName(Type,ArcCode)_$C(2)_DocName
	q Ret
}

// w ##class(web.DHCPE.ReportGetInfor).GetSpecialPatInfo(2245125,"DHCPEXRayReport.xls")

ClassMethod GetSpecialPatInfo(PAADM, Type)
{
	
	s Info=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PAADM)
	//q PatName_"^"_Sex_"^"_Birth_"^"_IDCard_"^"_RegNo_"^"_Tel_"^"_Group
	
	s Name=$P(Info,"^",1)
	s RegNo=$P(Info,"^",5)
	s Sex=$P(Info,"^",2)
	s Dob=$P(Info,"^",3)
	s Age=""
	s:Dob'="" Age=$ZDH(Dob,3)
	s:Age'="" Age=+$P(##class(web.DHCLCNUREXCUTE).CalAge(Age,+$H),"Y",1)
	s Tel=$P(Info,"^",6)
	/*
	s PAPMIID=$P(^PAADM(PAADM),"^",1)
	s Name=$P(^PAPER(PAPMIID,"ALL"),"^",1)
	s RegNo=$P(^PAPER(PAPMIID,"PAT",1),"^",1)
	s Sex=$P(^PAPER(PAPMIID,"ALL"),"^",7)
	i Sex'="" s Sex=$P(^CT("SEX",Sex),"^",2)
	s Dob=$P(^PAPER(PAPMIID,"ALL"),"^",6)
	s DIER=$P(^PAPER(PAPMIID,"ALL"),"^",6)
	s Dob=$ZD(Dob,3)
	S Age=""
	i DIER'="" s Age=$P(##class(web.DHCLCNUREXCUTE).CalAge(DIER,+$H),"Y",1)
	
	s BaseID=$O(^DHCPEPreIBI(0,"PAPMINo",RegNo,0))
	s Tel=""
	i BaseID'="" d
	.s Tel=$P(^DHCPEPreIBI(BaseID),"^",8)
	.s:Tel="" Tel=$P(^DHCPEPreIBI(BaseID),"^",6)
	.s:Tel="" Tel=$P(^DHCPEPreIBI(BaseID),"^",7)
	s:Tel="" Tel=$P(^PAPER(PAPMIID,"PER",4),"^",21)
	s:Tel="" Tel=$P(^PAPER(PAPMIID,"PER",1),"^",11)
	s:Tel="" Tel=$P(^PAPER(PAPMIID,"PER",1),"^",9)
	*/
	s Advice=""
	s DocName=""
	s CheckDate=""
	s IADMRowId=""
	s IADMRowId=$O(^DHCPEIADM(0,"PAADM",PAADM,""))
	s gSSID=$o(^DHCPEGS(0,"IADM",IADMRowId,0))
	i gSSID'="" d
	.s DocName=$P(^DHCPEGS(gSSID,1),"^",5)
	.S:DocName'="" DocName=$P(^SSU("SSUSR",DocName),"^",2)
	.s CheckDate=$P(^DHCPEGS(gSSID,1),"^",6)
	.S:CheckDate'="" CheckDate=$ZD(CheckDate,3)
	.s Sort=0
	.f  s Sort=$o(^DHCPEGS(0,"GSDSort",gSSID,Sort)) q:Sort=""  d
 	..s gSub=0
 	..f  s gSub=$o(^DHCPEGS(0,"GSDSort",gSSID,Sort,gSub)) q:gSub=""  d
	...s EDID=$p(^DHCPEGS(gSSID,"Diagnosis",gSub),"^",1)
	...q:EDID=""
	...s DiagnoseConclusion=$p($g(^DHCPEED(EDID,"1")),"^",1)
	...Set GSDRowId=gSSID_"||"_gSub
	...set advice=$P(^DHCPEGS(gSSID,"Diagnosis",gSub),"^",9)
	...If $d(^DHCPEDataEx("DHCPEGSDiagnosis","DisplayDesc",GSDRowId))'=0 Do
	....Set DiagnoseConclusion=$g(^DHCPEDataEx("DHCPEGSDiagnosis","DisplayDesc",GSDRowId))
	....i advice'="" d
	.....s DiagnoseConclusion=DiagnoseConclusion_":"_advice
	...i Advice="" d
	....s Advice=DiagnoseConclusion
	...e  d
	....s Advice=Advice_" "_DiagnoseConclusion
	s CurDate=$ZD($H,3)
	s Sort=$I(^DHCPESpecialReportPrintRecord(PAADM, Type))
	s ^DHCPESpecialReportPrintRecord(PAADM, Type,Sort)=$H_"^"_%session.Get("LOGON.USERID")
	s GroupDesc=%session.Get("LOGON.GROUPDESC")
	i GroupDesc[("医生") d
	.s DocName=%session.Get("LOGON.USERNAME")
	e  d
	.s DocName=""
	
	s BaseInfo=..GetElementName(Type,"CurDate")_$C(2)_CurDate_"^"_..GetElementName(Type,"Tel")_$C(2)_Tel_"^"_..GetElementName(Type,"RegNo")_$C(2)_RegNo_"^"_..GetElementName(Type,"Name")_$C(2)_Name_"^"_..GetElementName(Type,"Sex")_$C(2)_Sex_"^"_..GetElementName(Type,"Dob")_$C(2)_Dob_"^"_..GetElementName(Type,"Advice")_$C(2)_Advice_"^"_..GetElementName(Type,"DocName")_$C(2)_DocName_"^"_..GetElementName(Type,"CheckDate")_$C(2)_CheckDate_"^"_..GetElementName(Type,"Age")_$C(2)_Age
	s BaseInfo=BaseInfo_"^"_..GetSpecialDocInfo(PAADM, Type)
}

ClassMethod GetElementName(Type, Name)
{
	q:Type="" ""
	s RetStr=""
	if $L(Type,".xls")>1 d
	.s RetStr=$G(^DHCPESpecialReportInfoBase(Type,Name))
	e  d
	.s RetStr=Name
	q RetStr
}

/*
ClassMethod GetHistoryResult(PAADM, ODID, ARCIM)
{
	;d ##class(web.DHCPE.ReportGetInfor).GetHistoryResult("12692301","","")
	;s ^TMPReport(UserID,"HistoryResult",1)="项目^2009-10-10^2010-10-10^2011-10-10"
	;s ^TMPReport(UserID,"HistoryResult",2)="血压^89^90^100"
	;s ^TMPReport(UserID,"HistoryResult",3)="血脂^189^190^1100"
	
	;q:(%session.Get("LOGON.USERID")'=5) ""
	k ^TMPReport(UserID,"HistoryResult")
	k ^TMPReport(UserID,"PAADM")
	q:$G(^TMPReport(UserID,"PatInfo","PatCompany"))'[("北京协和医院") ""
	s PersonID=$P(^PAADM(PAADM),"^",1)
	s PAADM=PAADM+1
	s DateStr=""
	s i=0
	f  s PAADM=$O(^PAPERdr(PersonID,"ADM","H",PAADM),-1) q:(PAADM="")||(i>2)  d
	.s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	.q:IADM=""
	.s Status=$P(^DHCPEIADM(IADM),"^",8)
	.q:Status'="ARRIVED"
	.s i=i+1
	.s ^TMPReport(UserID,"PAADM",i)=PAADM
	.s OneDate=$P(^PAADM(PAADM),"^",6)
	.s OneDate=$ZD(OneDate,3)
	.i DateStr="" d
	..s DateStr=OneDate
	.e  d
	..s DateStr=DateStr_"^"_OneDate
	s ^TMPReport(UserID,"HistoryResult",1,1)="项目^"_DateStr
	q:i=1 ""
	s OrderNum=1
	s ARCItemMastID=""
	f  s ARCItemMastID=$O(^DHCPEDataEx("DHCPEOrderDetailRelate","History",ARCItemMastID)) q:ARCItemMastID=""  d
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCItemMastID, 0))
	.Q:(""=STRowId)
	.;w ARCItemMastID
	.//站点顺序
	.s STSequence=$p(^DHCPEST(STRowId),"^",9)
	.q:STSequence=""
	.s STSequence=STSequence*10000
	.s OrderDetailID=""
	.f  s OrderDetailID=$O(^DHCPEDataEx("DHCPEOrderDetailRelate","History",ARCItemMastID,OrderDetailID)) q:OrderDetailID=""  d
	..q:$G(^DHCPEDataEx("DHCPEOrderDetailRelate","History",ARCItemMastID,OrderDetailID))="0"
	..s OrderNum=OrderNum+1
	..s ODDesc=$p($g(^DHCPEST(+OrderDetailID,"OD",$p(OrderDetailID,"||",2))),"^",1)
	..s ODDesc=$P(ODDesc,"-检查结果",1)
	..s i=""
	..f  s i=$O(^TMPReport(UserID,"PAADM",i)) q:i=""  d
	...s CurADM=$G(^TMPReport(UserID,"PAADM",i))
	...s RLTID=0
	...s OneReslut=""
	...f  s RLTID=$O(^DHCPERLT(0,"PAADM_OD",CurADM,OrderDetailID,RLTID)) q:RLTID=""  d
	....s ARCID=$P(^DHCPERLT(RLTID),"^",2)
	....q:ARCID'=ARCItemMastID
	....s OneReslut=$P(^DHCPERLT(RLTID),"^",4)
	....s Result=""
	....i OneReslut["诊断意见"  s OneReslut=$p(OneReslut,"诊断意见:",2) s OneReslut="诊断意见："_OneReslut
	....s OneReslut=##class(web.DHCPE.Public.Setting).Replace(OneReslut,"\X000a\","<br>")
	....q:OneReslut=""
	....s $P(^TMPReport(UserID,"HistoryResult",STSequence,OrderDetailID),"^",1)=ODDesc
	....s $P(^TMPReport(UserID,"HistoryResult",STSequence,OrderDetailID),"^",i+1)=OneReslut
	....s $P(^TMPReport(UserID,"HistoryResult",STSequence,OrderDetailID),"^",5)=OrderDetailID
	q ""
}
*/
ClassMethod GetHistoryResult(PAADM, ODID, ARCIM)
{
	;d ##class(web.DHCPE.ReportGetInfor).GetHistoryResult("12692301","","")
	;s ^TMPReport(UserID,"HistoryResult",1)="项目^2009-10-10^2010-10-10^2011-10-10"
	;s ^TMPReport(UserID,"HistoryResult",2)="血压^89^90^100"
	;s ^TMPReport(UserID,"HistoryResult",3)="血脂^189^190^1100"
	
	k ^TMPReport(UserID,"HistoryResult")
	k ^TMPReport(UserID,"PAADM")
	
	s PersonID=$P(^PAADM(PAADM),"^",1)
	s PAADM=PAADM+1
	s DateStr=""
	s i=0
	f  s PAADM=$O(^PAPERdr(PersonID,"ADM","H",PAADM),-1) q:(PAADM="")||(i>2)  d
	.s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	.q:IADM=""
	.s PreIADM=$P(^DHCPEIADM(IADM),"^",4)
	.q:PreIADM=""
	.s ReCheckFlag=$P(^DHCPEPreIADM(PreIADM),"^",28)
	.q:ReCheckFlag="Y"
	.s Status=$P(^DHCPEIADM(IADM),"^",8)
	.q:Status'="ARRIVED"
	.s i=i+1
	.s ^TMPReport(UserID,"PAADM",i)=PAADM
	.s OneDate=$P(^PAADM(PAADM),"^",6)
	.s OneDate=$ZD(OneDate,3)
	.i DateStr="" d
	..s DateStr=OneDate
	.e  d
	..s DateStr=DateStr_"^"_OneDate
	s ^TMPReport(UserID,"HistoryResult",1,1)="项目^"_DateStr
	q:i=1 ""
	s OrderNum=1
	s ARCItemMastID=""
	f  s ARCItemMastID=$O(^DHCPEDataEx("DHCPEOrderDetailRelate","History",ARCItemMastID)) q:ARCItemMastID=""  d
	.s STRowId=$O(^DHCPEST(0,"STORD_ARCIM",ARCItemMastID, 0))
	.Q:(""=STRowId)
	.;w ARCItemMastID
	.//站点顺序
	.s STSequence=$p(^DHCPEST(STRowId),"^",9)
	.q:STSequence=""
	.s STSequence=STSequence*10000
	.s OrderDetailID=""
	.f  s OrderDetailID=$O(^DHCPEDataEx("DHCPEOrderDetailRelate","History",ARCItemMastID,OrderDetailID)) q:OrderDetailID=""  d
	..q:$G(^DHCPEDataEx("DHCPEOrderDetailRelate","History",ARCItemMastID,OrderDetailID))="0"
	..s OrderNum=OrderNum+1
	..s ODDesc=$p($g(^DHCPEST(+OrderDetailID,"OD",$p(OrderDetailID,"||",2))),"^",1)
	..s ODDesc=$P(ODDesc,"-检查结果",1)
	..s i=""
	..f  s i=$O(^TMPReport(UserID,"PAADM",i)) q:i=""  d
	...s CurADM=$G(^TMPReport(UserID,"PAADM",i))
	...s RLTID=0
	...s OneReslut=""
	...f  s RLTID=$O(^DHCPERLT(0,"PAADM_OD",CurADM,OrderDetailID,RLTID)) q:RLTID=""  d
	....s ARCID=$P(^DHCPERLT(RLTID),"^",2)
	....;q:ARCID'=ARCItemMastID
	....s OneReslut=$P(^DHCPERLT(RLTID),"^",4)
	....s Result=""
	....i OneReslut["诊断意见"  s OneReslut=$p(OneReslut,"诊断意见:",2) s OneReslut="诊断意见："_OneReslut
	....s OneReslut=##class(web.DHCPE.Public.Setting).Replace(OneReslut,"\X000a\","<br>")
	....q:OneReslut=""
	....s $P(^TMPReport(UserID,"HistoryResult",STSequence,OrderDetailID),"^",1)=ODDesc
	....s $P(^TMPReport(UserID,"HistoryResult",STSequence,OrderDetailID),"^",i+1)=OneReslut
	....s $P(^TMPReport(UserID,"HistoryResult",STSequence,OrderDetailID),"^",5)=OrderDetailID
	q ""
}

ClassMethod GetGeneralAdviceByReportID(ReportID)
{
	S UserID=""
	s IADM=$P( ^DHCPERPT(ReportID),"^",1)
	s PatientID=$P(^DHCPEIADM(IADM),"^",1)
	d ..GetGeneralAdvice(PatientID,UserID)
	s Info=$G(^TMPReport(UserID,"GeneralAdvice","Advice"))
	k ^TMPReport(UserID)
	w Info
}

ClassMethod GetGeneralAdviceByAdm(PAADM)
{
	//S UserID=""
	s UserID=PAADM
	d ..GetGeneralAdvice(PAADM,UserID)
	s Info=$G(^TMPReport(UserID,"GeneralAdvice","Advice"))
	k ^TMPReport(UserID)
	s Info=..Replace(Info,$C(13,10)_$C(13,10)_$C(13,10),$C(13,10))
	s Info=..Replace(Info,$C(13,10)_$C(13,10),$C(13,10))
	s Info=..Replace(Info,$C(13,10)_$C(13,10),$C(13,10))
	q Info
}

/// w ##Class(web.DHCPE.ReportGetInfor).SelectMarkDesc("704")
ClassMethod SelectMarkDesc(PAADM)
{
	s ManStr="前列腺^包茎^精索静脉曲张^睾丸^附睾^阴茎^隐睾^PSA^包皮"
	s WoManStr="阴道^宫颈^卵巢^乳腺^痛经^外阴^乳房^子宫^输卵管^巧克力囊肿^妊娠试验(HCG)^HCG^妇科^液基薄层细胞学^TCT^刮片^弓形体^弓形虫^人乳头瘤病毒（HPV）阳性^HPV^活检^乳房肿物^LCT"
    s SexDesc="" 
	q:PAADM="" ""
	s ret=""
	s ResultId=""
	f  s ResultId=$O(^DHCPERLT(0,"ADM",PAADM,ResultId)) q:ResultId=""  d
	.s ResultDesc=$P($G(^DHCPERLT(ResultId)),"^",4)
	.s papmiid=$p(^PAADM(PAADM),"^",1)
	.s SexId=$p($G(^PAPER(papmiid,"ALL")),"^",7)
	.i SexId'="" s SexDesc=$p(^CT("SEX",SexId),"^",2)
	.i SexDesc="男" d
	..for i=1:1:$L(WoManStr,"^") d
    ...i ResultDesc[$P(WoManStr,"^",i) d 
    ....i ret="" d
    .....s ret=$P(WoManStr,"^",i) 
    ....e  d
    .....s ret=ret_","_$P(WoManStr,"^",i)
	.i SexDesc="女" d
	..for i=1:1:$L(ManStr,"^") d
    ...i ResultDesc[$P(ManStr,"^",i) d 
    ....i ret="" d
    .....s ret=$P(ManStr,"^",i) 
    ....e  d
    .....s ret=ret_","_$P(ManStr,"^",i) 
	q ret
}

}
