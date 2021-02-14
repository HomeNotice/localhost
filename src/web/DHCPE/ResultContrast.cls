Import SQLUser

/// 主要功能		：查看历史检验数据
/// 主要功能		：主要使用组件 DHCPEResultContrast.ReportItemList
/// 最后修改时间	：2008-07-24
/// 
Class web.DHCPE.ResultContrast Extends (%Library.RegisteredObject, websys.Abstract)
{

Parameter BUILD = 859;

/// 查找患者的体检记录(按报告－完成的体检) 
/// d ##class(web.DHCPE.ResultContrast).SearchIReport("00000023","","","","")
ClassMethod SearchIReport(RegNo As %String = "", PatName As %String = "", DateFrom As %String = "", DateTo As %String = "", ReportStatus As %String = "")
{
   
	k ^TMPResultContrast("IReport")
 	if (""=RegNo)&(""=PatName)&(""=DateFrom)&(""=DateTo)&(""=ReportStatus) {
		Set qHandle=$lb(0,repid,0)
 		Quit $$$OK
 	}
 	// ^PAPERi("PAPMI_PatNo",$$ALPHAUP({PAPMI_No}),{PAPMI_RowId})
 	s PAPMIRowId=""
 	//由登记号找病人基本信息表的ID
 	i ""'=RegNo  s RegNo=$Extract("00000000",1,8-$LENGTH(RegNo))_RegNo
 	s PAPMIRowId=$O(^PAPERi("PAPMI_PatNo",RegNo,PAPMIRowId))

 	if (""=PAPMIRowId) {
		Set qHandle=$lb(0,repid,0)
 		Quit $$$OK
 	}
	s ReportStatus="^"_ReportStatus_"^"
	s RegNo=+RegNo
	s Ptype=""
	f  s Ptype=$O(^PAPERdr(PAPMIRowId,"ADM",Ptype)) Q:(""=Ptype)  d
	.s IADMPAADMDR=0
	.f  s IADMPAADMDR=$O(^PAPERdr(PAPMIRowId,"ADM",Ptype,IADMPAADMDR)) Q:(""=IADMPAADMDR)  d
	..s IADMDR=0
	..s IADMDR=$O(^DHCPEIADM(0,"PAADM",IADMPAADMDR,IADMDR))
	..Q:(""=IADMDR)
	..//DHC_PE_Report
	..s RPTRowId=0
	..s RPTRowId=$O(^DHCPERPT(0,"IADM",IADMDR,RPTRowId))
	..q:RPTRowId=""
	..s CurData=$g(^DHCPERPT(RPTRowId))	
	..s RegDate=+$p($g(^DHCPEIADM(IADMDR)),"^",5)
	..q:(""'=DateFrom)&(RegDate<DateFrom)
	..q:(""'=DateTo)&(RegDate>DateTo)
	..i ""'=RegDate s RegDate=$ZD(RegDate,3)
	..s Status="^"_$p(CurData,"^",2)_"^"				//报告状态
	..q:(""'=ReportStatus)&('(ReportStatus[Status))
	..//w !,IADMPAADMDR_"&&"
	..// 输出 按登记日期排序
	..s ^TMPResultContrast("IReport","RegDate",RegDate)=IADMPAADMDR_"^"_IADMDR_"^"_RPTRowId
	..
	..// 输出 按ADM号
	..s ^TMPResultContrast("IReport","ADM",IADMPAADMDR)=IADMPAADMDR_"^"_IADMDR_"^"_RPTRowId_"^"_RegDate
	..//w !,IADMPAADMDR_"^"_IADMDR_"^"_RPTRowId_"^"_RegDate
}

/// 获取患者的莫项目(医嘱项目)d的体检结果	DHC_PE_Result
/// d ##Class(web.DHCPE.ResultContrast).GetPatientResult("433236","9976||1")
ClassMethod GetPatientResult(PAAdmRowid, ItmMastID)
{

    s RisID=$G(^DHCPESetting("DHCPE","StationId_Ris"))
    s LisID=$G(^DHCPESetting("DHCPE","StationId_Lab"))
    s namespaceLab=$g(^DHCPESetting("DHCPE","StationId_Lab"))
	s RLTRowid=0 
	s Delimit="^"
	s ret=""
	q:PAAdmRowid=""
	f  s RLTRowid=$o(^DHCPERLT(0,"ADM",PAAdmRowid,RLTRowid)) q:RLTRowid=""  d
	.//w !,RLTRowid
	.//一对多
	.// RLT_OEORI_DR
	.s RLTOEORIDR=$p(^DHCPERLT(RLTRowid),"^",9)
	
	.//RLT_ARCIM_DR 医嘱项目
	.s OEORDRowId=$P(RLTOEORIDR,"||",1) // OE_Order.OEORD_RowId
	.s OEORIChildsub=$P(RLTOEORIDR,"||",2) // OE_Order.OEORI_Childsub
	.s ARCIMDR=$P($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",2)
	.Q:(""'=ItmMastID)&(ARCIMDR'=ItmMastID)
	.s ARCIMSubScript=$p(ARCIMDR,"||",1)	//ARCIM_Desc 医嘱名称 Arc_ItmMast
	.s ARCIMVersion=$p(ARCIMDR,"||",2)
	.s ARCIMCode=$p($g(^ARCIM(ARCIMSubScript,ARCIMVersion,1)),"^",1)
	.s ARCIMDesc=$p($g(^ARCIM(ARCIMSubScript,ARCIMVersion,1)),"^",2)
	.s Normal=$p(^DHCPERLT(RLTRowid),"^",7)  
	.
	.s:(0=+Normal) RLTNormal="异常"
	.//RLT_OD_DR	细项
	.s ODRowId=$p(^DHCPERLT(RLTRowid),"^",3)
	.q:ODRowId=""     
	.s STRowId=$p(ODRowId,"||",1)			//站点编码
	.s ODChildSub=$p(ODRowId,"||",2)		//项目编码
	.s ODDesc=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",1)	//细项名称	DHC_PE_OrderDetail.{ OD_Desc }
	.s TNormalResult=""
	.i STRowId=LisID  s TNormalResult=##class(web.DHCPE.ResultEdit).GetNormal(ODRowId,"M","17")
	.// 单位 OD_Unit
	.s ODUnit=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",4)
	.s RLTResult=$p(^DHCPERLT(RLTRowid),"^",4)
	.s RLTTemp=$p(^DHCPERLT(RLTRowid),"^",10)
	.i RLTTemp'=""  s RLTResult=RLTResult_"("_RLTTemp_")"
	.//RLT_User_DR	检查医师
	.s RLTUser=$p(^DHCPERLT(RLTRowid),"^",5)
  	.i (""'=RLTUser) d
  	..s RLTUser=$p($g(^SSU("SSUSR",RLTUser)),"^",2)	//检查医师名称	SS_User
 	 .
 	 .//检验日期
	.s RLTUpdateDate=$p(^DHCPERLT(RLTRowid),"^",6)
  	.i (""'=RLTUpdateDate) d
 	..s RLTUpdateDate=$ZD(RLTUpdateDate,3)
  	.
 	.//是否正常
	.s RLTNormal=$p(^DHCPERLT(RLTRowid),"^",7)
	.s RLTAdvice=$p(^DHCPERLT(RLTRowid),"^",8)
	.S STDR=$o(^DHCPEST(0,"STORD_ARCIM",ARCIMDR,0))
	.i $G(^TMPResultContrast("Result",ARCIMDR,ODRowId,PAAdmRowid))=""  s ^TMPResultContrast("Result",ARCIMDR,ODRowId,PAAdmRowid)=RLTResult
	.else  s ^TMPResultContrast("Result",ARCIMDR,ODRowId,PAAdmRowid)=$G(^TMPResultContrast("Result",ARCIMDR,ODRowId,PAAdmRowid))_","_RLTResult
	.s RLTResult=$G(^TMPResultContrast("Result",ARCIMDR,ODRowId,PAAdmRowid))															
	.s ^TMPResultContrast("Result","ID",STDR,ARCIMDR,ODRowId,PAAdmRowid)=ODDesc_"^"_RLTResult_"^"_ARCIMDesc_"^"_TNormalResult _"^"_RLTNormal_"^"_ODUnit 
	.s ^TMPResultContrast("Result","CheckData",ARCIMDR,ODRowId,PAAdmRowid)=ODDesc_"^"_RLTResult_"^"_ARCIMDesc_"^"_TNormalResult _"^"_RLTNormal_"^"_ODUnit 
	
   
 
    
	//b // GetPatientResult end
}

/// 获取患者的历史检验结果，比对检验数据
/// d ##class(web.DHCPE.ResultContrast).GetPatResultHistory("00002000","","")
ClassMethod GetPatResultHistory(RegNo As %String = "", DateFrom As %String = "", DateTo As %String = "")
{
	k ^TMPResultContrast("ResultHistory")
	k ^TMPCount
	Q:(""=RegNo) 0
	s PatName=""
	//s ReportStatus="^NA^A^P^S^" //测试阶段，选择查询全部地数据
	s ReportStatus="^A^P^S^" //测试阶段，选择查询全部地数据
	// 查询患者地检验记录  
	d ..SearchIReport(RegNo, PatName, DateFrom, DateTo, ReportStatus) 
	//执行SearchIReport得到下面两个临时Glable

	// 输出 按ADM号                        
    //s ^TMPResultContrast("IReport","ADM",IADMPAADMDR)=IADMPAADMDR_"^"_IADMDR_"^"_RPTRowId_"^"_RegDate
	s PAADMStr=""
	s PAADMdr=""
	f  s PAADMdr=$O(^TMPResultContrast("IReport","ADM",PAADMdr),-1) Q:(""=PAADMdr)  d
	.i PAADMStr=""  s PAADMStr=PAADMdr
	.e  s PAADMStr=PAADMStr_"^"_PAADMdr
	.S RegDate=$P($G(^TMPResultContrast("IReport","ADM",PAADMdr)),"^",4)
	.s ^TMPResultContrast("ResultHistory", "RegDate", RegDate)=RegDate
	.d ..GetARCIMId(RegNo,PAADMStr)
	.s OEORIItmMastDR=0
	.f  s OEORIItmMastDR=$o(^TMPResultContrast("ResultHistory","ARCIM",OEORIItmMastDR)) q:OEORIItmMastDR=""  d 
	..s ^TMPResultContrast("Result","ID",OEORIItmMastDR)=OEORIItmMastDR
	..d ..GetPatientResult(PAADMdr,OEORIItmMastDR)
	..d ..CheckData()
	
	Q 1
}

ClassMethod GetPatResultHistoryNew(PAADMStr As %String = "", ShowAbnormal As %String = "")
{
	k ^TMPResultContrast("ResultHistory")
	k ^TMPCount
	s ^zltmp("0407","PAADMStr")=PAADMStr
	d ..GetARCIMId("",PAADMStr)
	f i=1:1:$l(PAADMStr,"^")
	{
	s IADMPAADMDR=$p(PAADMStr,"^",i)
	s IADMRowID=$o(^DHCPEIADM(0,"PAADM",IADMPAADMDR,0))
	q:IADMRowID=""
	s RegDate=$p(^DHCPEIADM(IADMRowID),"^",5)
	s ^TMPResultContrast("IReport","RegDate",RegDate)=IADMPAADMDR_"^"_IADMRowID_"^"
    s ^TMPResultContrast("IReport","ADM",IADMPAADMDR)=IADMPAADMDR_"^"_IADMRowID_"^^"_RegDate
    
    i RegDate'=""  d
    .s RegDateShow=$zd(RegDate,3)
    .s ^TMPResultContrast("ResultHistory", "RegDate", RegDateShow)=RegDateShow
	s OEORIItmMastDR=0
	f  s OEORIItmMastDR=$o(^TMPResultContrast("ResultHistory","ARCIM",OEORIItmMastDR)) q:OEORIItmMastDR=""  d 
	.S STDR=$o(^DHCPEST(0,"STORD_ARCIM",OEORIItmMastDR,0))
	.s ^TMPResultContrast("Result","ID",STDR,OEORIItmMastDR)=OEORIItmMastDR
	.d ..GetPatientResult(IADMPAADMDR,OEORIItmMastDR)

	}

	d ..CheckData()


	
	
	Q 1
}

// 可取得每个医嘱下的细项个数

ClassMethod CheckData()
{
	//s ^TMPResultContrast("Result","ID",ARCIMDR,ODRowId,PAAdmRowid)=ODDesc_"^"_RLTResult_"^"_ARCIMDesc 
	k ^TMPCount
	s STDR=0
	s ARCIMDR="" 
	f  s ARCIMDR=$o(^TMPResultContrast("Result","CheckData",ARCIMDR)) q:ARCIMDR=""  d
	.s ODRowId= "" f  s ODRowId=$O(^TMPResultContrast("Result","CheckData",ARCIMDR,ODRowId)) q:ODRowId=""  d
	..s Flag=0
	..s ComStr="^$^"
	..s str=""
	..s num=0   //记录结果循环次数
	..s PAAdmRowid="" f  s PAAdmRowid=$O(^TMPResultContrast("Result","CheckData",ARCIMDR,ODRowId,PAAdmRowid)) q:(PAAdmRowid="")||(Flag=1)  d
	...s TResult=$p(^TMPResultContrast("Result","CheckData",ARCIMDR,ODRowId,PAAdmRowid),"^",2)
	...s RTLNomal=$p(^TMPResultContrast("Result","CheckData",ARCIMDR,ODRowId,PAAdmRowid),"^",5)
	...//q:ComStr=TResult
	...i str="" s str=RTLNomal
	...e   s str=str_"^"_RTLNomal
	...
	..Q:str'[0
	..
	..if $d(^TMPCount(ARCIMDR))=0 s ^TMPCount(ARCIMDR)=1 
	..else  s ^TMPCount(ARCIMDR)=^TMPCount(ARCIMDR)+1
}

// 只显示细项结果不同的细项

ClassMethod CheckDataShow(ARCIMDRPara, ODRowIdPara)
{
	s ShowFlag="false"  //ShowFlag=false  说明几次相同  ShowFlag=true  说明几次比较的结果有不同的，有应该显示
	s str=""
	s Flag=0
	s num=0
	s ComStr="^$^"
	s PAAdmRowid="" f  s PAAdmRowid=$O(^TMPResultContrast("Result","CheckData",ARCIMDRPara,ODRowIdPara,PAAdmRowid)) q:(PAAdmRowid="")||(ShowFlag="true")  d
	.s TResult=$p(^TMPResultContrast("Result","CheckData",ARCIMDRPara,ODRowIdPara,PAAdmRowid),"^",2)
	.s RLTNomal=$p(^TMPResultContrast("Result","CheckData",ARCIMDRPara,ODRowIdPara,PAAdmRowid),"^",5)
	.i str=""  s str=RLTNomal
	.e  s str=RLTNomal_"^"_RLTNomal
	.q:str'[0
	.s ShowFlag="true"
	Q ShowFlag
}

// 遍历日期，使用一个临时GLOBLE来存日期循环次数

ClassMethod GetRegDateLoopNum()
{
   k ^TMPRegDateLoopNum
	s LoopNum=0
	s ADM=0
	f  s ADM=$o(^TMPResultContrast("IReport","ADM",ADM)) q:ADM=""  d
	.s ^TMPRegDateLoopNum(LoopNum)=ADM
	.s LoopNum=LoopNum+1
	q
}

/// 功能:结果比对获取时间列信息
/// 创建:2018.10.10
/// 创建人:xy
ClassMethod GetRegColumns(AdmId As %String = "") As %String
{
	
	kill columnAry
	set i=0
	set columnAry($i(i))="ARCIMDesc^医嘱名称"
	
   f i=1:1:$l(AdmId,"^")
   {
	s IADMPAADMDR=$p(AdmId,"^",i)
	s IADMRowID=$o(^DHCPEIADM(0,"PAADM",IADMPAADMDR,0))
	q:IADMRowID=""
	s RegDate=$p(^DHCPEIADM(IADMRowID),"^",5)
	i RegDate'="" s RegDate=##class(websys.Conversions).DateLogicalToHtml(RegDate)
	
	s colField="RegDate"_i
	s colTitle=RegDate
	s columnAry($i(i))=colField_"^"_colTitle
	}
	
	set jsonStr=""
	set index=0
	for  set index=$o(columnAry(index)) quit:(index="")  do
	.set field=$p(columnAry(index),"^",1)
	.set title=$p(columnAry(index),"^",2)
	.set align="left"
	.set myJson="{""field"":"""_field_""",""title"":"""_title_""",""align"":"""_align_""",""halign"":""center"",""width"":"_200_"}"
	.if (jsonStr="") do
	..set jsonStr=myJson
	.else  do
	..set jsonStr=jsonStr_","_myJson

	set jsonStr="["_jsonStr_"]"
	
	quit jsonStr
}

/// 功能:结果比对
/// 创建:2018.10.10
/// 创建人:xy
Query SearchPatResultHistory(AdmId As %String = "", RegNo As %String = "", DateFrom As %String = "", DateTo As %String = "") As %Query(ROWSPEC = "ARCIMDesc:%String,RegDate1:%String,RegDate2:%String,RegDate3:%String,RegDate4:%String,RegDate5:%String,RegDate6:%String,RegDate7:%String")
{
}

ClassMethod SearchPatResultHistoryExecute(ByRef qHandle As %Binary, AdmId As %String = "", RegNo As %String = "", DateFrom As %String = "", DateTo As %String = "") As %Status
{
   Set repid=$I(^CacheTemp)
 	s ind=1
    
    s ^tempdhcpe("RegNo1")=RegNo_"^"_AdmId_"^"_DateFrom_"^"_DateTo
	k ^TMPResultContrast
	d ..GetPatResultHistoryNew(AdmId)
	d ..GetRegDateLoopNum()    //得到日期循环次数的GLOBLE
	
	s Station=0
	f  s Station=$o(^TMPResultContrast("Result","ID",Station)) q:Station=""  d
	.s ARCIMDR=0
	.f  s ARCIMDR=$o(^TMPResultContrast("Result","ID",Station,ARCIMDR))  q:ARCIMDR=""  d  
	..s ARCIMSubscript=$P(ARCIMDR,"||",1)
	..s ARCIMVersion=$P(ARCIMDR,"||",2)
	..Q:$G(^ARCIM(ARCIMSubscript,ARCIMVersion,1))
	..s ARCIMDesc=$P($G(^ARCIM(ARCIMSubscript,ARCIMVersion,1)),"^",2)
	..s RowSum=(+$g(^TMPCount(ARCIMDR))+1)
	..s j=0,ResultStr=""
	..s ODDr=0
	..f  s ODDr=$o(^TMPResultContrast("Result","ID",Station,ARCIMDR,ODDr)) q:ODDr=""  d
	...s ShowFlag=..CheckDataShow(ARCIMDR,ODDr)
	...Q:ShowFlag="false"
	...s ADMRowId=0
	...s CurrenLoopNum=0
	...f  s ADMRowId=$o(^TMPResultContrast("Result","ID",Station,ARCIMDR,ODDr,ADMRowId)) q:ADMRowId=""  d
	....s CurData=$g(^TMPResultContrast("Result","ID",Station,ARCIMDR,ODDr,ADMRowId))
	....s ODDesc=$P(CurData,"^",1)
	....s Result=$P(CurData,"^",2)
	....s Standard=$P(CurData,"^",4)
	....s Normal=$P(CurData,"^",5) 
	....s ODUnit=$P(CurData,"^",6) 
	....s j=j+1
	....i Standard'=""  d
	.....s ODUnit=ODUnit_("_Standard_")
	....i ResultStr="" s ResultStr=ODDesc_":"_Result_""_ODUnit
	....e  s ResultStr=ResultStr_", "_ODDesc_":"_Result_""_ODUnit
	..d OutPatResult
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
OutPatResult
	set Data=$lb(ARCIMDesc,ResultStr)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SearchPatResultHistoryFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SearchPatResultHistoryExecute ]
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

ClassMethod SearchPatResultHistoryClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SearchPatResultHistoryExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// 将患者的历史体检数据输出到HTML中
/// d ##class(web.DHCPE.ResultContrast).OutPatResultHistoryToHTML("10001","","","","^NA^A^P^S^")
/// d ##class(web.DHCPE.ResultContrast).OutPatResultHistoryToHTML("00001225","","","")
ClassMethod OutPatResultHistoryToHTML(AdmId As %String = "", RegNo As %String = "", DateFrom As %String = "", DateTo As %String = "", ShowAbnormal As %String = "Y")
{
	
	k ^TMPResultContrast
	//d ..GetPatResultHistory(RegNo, DateFrom, DateTo)
	d ..GetPatResultHistoryNew(AdmId)
	d ..GetRegDateLoopNum()    //得到日期循环次数的GLOBLE
	//w "<input name=""export"" type=""button"" id=""export"" class='i-btn' value=""导出"" >"
    w "<table class=tblList cellspacing='0' cellpadding='0' style='white-space:normal; word-break:break-all;' id=""tPatResultHistory"" Name=""tPatResultHistory"" width='100%'>",!
	
	 //表格第一行 输出体检登记日期
	w "<TR class='panel-header-gray' height=34px  border=0><td width=80px style='border-radius:4px 0px 0px 0px;border-right:1px solid #ccc;border-left:0px solid #ccc;padding:0px 0px 0px 10px;color:#000000;'>医嘱名称</td>"
	s RegDate=0
    s ADMNum=0
	s IADMPAADMDR=0
	f  s IADMPAADMDR=$o(^TMPResultContrast("IReport","ADM",IADMPAADMDR)) q:IADMPAADMDR=""  d
	.s RegDate=$p(^TMPResultContrast("IReport","ADM",IADMPAADMDR),"^",4)  //IADMPAADMDR_"^"_IADMRowID_"^^"_RegDate
	.i RegDate'=""  s RegDate=##class(websys.Conversions).DateLogicalToHtml(RegDate)
	.s ADMNum=ADMNum+1
	.s ^TMPResultContrast("RegDate",ADMNum)=RegDate
	f i=1:1:ADMNum  d
	.i i=ADMNum d
	..w "<td style='border-right:0px solid #ccc;padding:0px 0px 0px 10px;color:#000000;'>"_$g(^TMPResultContrast("RegDate",i))_"</td>"
	.e  d
	..w "<td style='border-right:1px solid #ccc;padding:0px 0px 0px 10px;color:#000000;'>"_$g(^TMPResultContrast("RegDate",i))_"</td>"
    w "</tr>",!
	w "<tbody  TEXT='#000000'>",!
	s RowType="RowOdd" //区分奇偶行
	s rowstyle="RowOdd"
	s Station=0
	f  s Station=$o(^TMPResultContrast("Result","ID",Station)) q:Station=""  d
	.s ARCIMDR=0
	.f  s ARCIMDR=$o(^TMPResultContrast("Result","ID",Station,ARCIMDR))  q:ARCIMDR=""  d  
	..s ARCIMSubscript=$P(ARCIMDR,"||",1)
	..s ARCIMVersion=$P(ARCIMDR,"||",2)
	..Q:$G(^ARCIM(ARCIMSubscript,ARCIMVersion,1))
	..s ARCIMDesc=$P($G(^ARCIM(ARCIMSubscript,ARCIMVersion,1)),"^",2)
	..s RowSum=(+$g(^TMPCount(ARCIMDR))+1)
	
	..w "<tr height=34px class='"_RowType_"'>",!
	..w "<td  style='padding:0px 0px 0px 10px;border-right:1px solid #ccc;' class='CellCaption' ROWSPAN='"_RowSum_"'>"_ARCIMDesc_"</td>",!
	..s NoResultNum=0
	..s NoResultNum=$o(^TMPResultContrast("Result","ID",Station,ARCIMDR,""))
	..i NoResultNum="" d
	...f num=1:1:ADMNum d
	....i num=ADMNum d
	.....w "<td style='border-right:0px solid #ccc;border-left:1px solid #ccc;'></td>"
	....e  d
	.....w "<td style='border-right:1px solid #ccc;border-left:1px solid #ccc;'></td>"
	..s j=0
	..s ODDr=0
	..f  s ODDr=$o(^TMPResultContrast("Result","ID",Station,ARCIMDR,ODDr)) q:ODDr=""  d
	...s ShowFlag=..CheckDataShow(ARCIMDR,ODDr)
	...Q:ShowFlag="false"
	...w "<tr height=34px>",!
	...w "<center>",!
	...s ADMRowId=0
	...s CurrenLoopNum=0
	...f  s ADMRowId=$o(^TMPResultContrast("Result","ID",Station,ARCIMDR,ODDr,ADMRowId)) q:ADMRowId=""  d
	....s CurData=$g(^TMPResultContrast("Result","ID",Station,ARCIMDR,ODDr,ADMRowId))
	....s ODDesc=$P(CurData,"^",1)
	....s Result=$P(CurData,"^",2)
	....s Standard=$P(CurData,"^",4)
	....s Normal=$P(CurData,"^",5) 
	....s ODUnit=$P(CurData,"^",6) 
	....i rowstyle="RowOdd" s rowstyle="RowEven"
	....e  s rowstyle="RowOdd"
	....s j=j+1
	....//i j>1 w !,"<tr class='"_rowstyle_"'>"
	....
	....s tmpNum=0,CurrentmpNum=0
	....s CurrenRegDate=$p(^TMPResultContrast("IReport","ADM",ADMRowId),"^",4)
	....//w !,ARCIMDR_"$$"_ADMRowId_"$$"_CurrenRegDate
	....//if ^TMPRegDateLoopNum(CurrenLoopNum)'=CurrenRegDate  d       //则说明在同样的循环次数下，它们的日期不一样，就是说这个医嘱并没有每次都开了，而是前面的就诊有没有开这条医嘱的
	....s LoopNum=0
	....f  s LoopNum=$o(^TMPRegDateLoopNum(LoopNum)) q:LoopNum=""  d
	.....if ^TMPRegDateLoopNum(LoopNum)=ADMRowId s CurrentmpNum=LoopNum
	....s tmpNum=CurrentmpNum-CurrenLoopNum      //tmpNum代表当前循环前有多少次没有开此医嘱，CurrentmpNum代表与当前就诊日期相等的^TMPRegDateLoopNum的循环数，CurrenLoopNum当前循环的循环次数
	....f i=1:1:tmpNum  d
	.....w !,"<td></td>"
	.....s CurrenLoopNum=CurrenLoopNum+1
	....//END
	....s CurrenLoopNum=CurrenLoopNum+1
	
	....i Standard'=""  d
	.....i Normal=0 w !,"<td style='padding:0px 0px 0px 10px;border-right:1px solid #ccc;border-left:1px solid #ccc;'><font color='red'>"_ODDesc_": "_Result_" "_ODUnit_" "_"("_Standard_")"_"</font></td>"
	.....e  w !,"<td style='padding:0px 0px 0px 10px;border-right:1px solid #ccc;border-left:1px solid #ccc;'><font color='black'>"_ODDesc_": "_Result_" "_ODUnit_" "_"("_Standard_")"_"</font></td>"
	....e   d
	.....i Normal=0 w !,"<td style='padding:0px 0px 0px 10px;border-right:1px solid #ccc;border-left:1px solid #ccc;'><font color='red'>"_ODDesc_": "_Result_" "_ODUnit_"</font></td>"
	.....e  w !,"<td style='padding:0px 0px 0px 10px;border-right:1px solid #ccc;border-left:1px solid #ccc;'><font color='black'>"_ODDesc_": "_Result_" "_ODUnit_"</font></td>"
	....
	
	....
	....w "</center>" ,!
	....//w "</tr>",!
	...
	...w "</tr>",!
	..w "</tr>",!

	w "</tbody>",!
	w "</table>",!
}

/// d ##Class(web.DHCPE.ResultContrast).OueTestListToWeb("10001")
ClassMethod OueTestListToWeb(RegNo As %String = "")
{
	s PatName=""
	s DateFrom=""
	s DateTo=""
	s ReportStatus="^NA^A^P^S^"
	d ..SearchIReport(RegNo, PatName, DateFrom, DateTo, ReportStatus)
	
	k ^TMPResultContrast("ResultHistory")
	s id=0
	f  s id=$O(^TMPResultContrast("IReport","ADM",id)) Q:(""=id)  d
	.d ..GetPatientResult(id,ARCIM)
	.
}

/// d ##Class(web.DHCPE.ResultContrast).OutResultToWeb()
/// 输出检验检查结果到网页
ClassMethod OutResultToWeb()
{
	
	w "<xml id=xmlReport>",!
	w "<ReportList>"
	
	s ARCIM=""
	f  s ARCIM=$O(^TMPResultContrast("Result",ARCIM)) Q:(""=ARCIM)  d
	.s CurData=$G(^TMPResultContrast("Result",ARCIM))
	.
	.w "<Report>",!
	.w "<ARCIMDesc>"_ARCIM_"</ARCIMDesc>",!
	.w "<Checker>"_$P(CurData,"^",1)_"</Checker>",!
	.w "<TestDate>"_$P(CurData,"^",2)_"</TestDate>",!
	.
	.w "<Result>",!
	.
	.s OD=""
	.f  s OD=$O(^TMPResultContrast("Result",ARCIM,OD)) Q:(""=OD)  d
	..s CurData=$g(^TMPResultContrasts("Result",ARCIM,OD))
	..w " <Value>",!
	..w "  <TestName>"_OD_"</TestName>",!
	..w "  <TestValue>"_$P(CurData,"^",1)_"</TestValue>",!
	..w "  <Standard>"_$P(CurData,"^",2)_"</Standard>",!
	..w "  <TestUnit>"_$P(CurData,"^",3)_"</TestUnit>",!
	..w "  <Normal>"_$P(CurData,"^",4)_"</Normal>",!
	..w "  <Advice>"_$P(CurData,"^",5)_"</Advice>",!
	..w " </Value>",!
	.
	.w " </Result>",!
	.
	.
	.
	.w "</Report>",!
	w "</ReportList>",!
	w "</xml>",!
}

ClassMethod QueryResult(PatientId As %String)
{
	
	k ^xwmTest("GeneralAdvice") 

	s IADMRowId=""
	s IADMRowId=$O(^DHCPEIADM(0,"PAADM",PAAdmRowid,IADMRowId))
	q:(""=IADMRowId) 0
	 
	s RowId=""
	f  s RowId=$o(^DHCPEGA(0,"IADM",IADMRowId,RowId)) q:RowId=""  d
	.
	.//GA_AduitUser_DR
	.s AduitUser=$p(^DHCPEGA(RowId,1),"^",3)	//审核人
  .i (""'=AduitUser) s AduitUser=$p($g(^SSU("SSUSR",AduitUser)),"^",2)	//检查医师名称	SS_User
  .s ^xwmTest("GeneralAdvice","AduitUser")=AduitUser
  .
  .//GA_AduitDate
  .s AduitDate=$p(^DHCPEGA(RowId,1),"^",2)	//审核日期
  .i (""'=AduitDate) s AduitDate=$ZD(AduitDate,3)
	.s ^xwmTest("GeneralAdvice","AduitDate")=AduitDate
	.
	.//
	.s Advice=$G(^DHCPEGA(RowId,"A"))	//建议
	.s ^xwmTest("GeneralAdvice","Advice")=Advice
	q 1
}

/// 获取参考范围 DHC_PE_ODStandard
ClassMethod GetStandard(STRowId, ODChildSub)
{
     
	s RowId=0	
	s Rangs=""
	f  s RowId=$o(^DHCPEST(STRowId,"OD",ODChildSub,"ODS",RowId)) q:RowId=""  d
	.//b //1
	.//w !,RowId
	.s CurData=$g(^DHCPEST(STRowId,"OD",ODChildSub,"ODS",RowId))
	.//w !,CurData
	.s ODSNatureValue=$P(CurData,"^",6)
	.q:("Y"'=ODSNatureValue)
	.//ODS_Min,ODS_Max
	.s Rangs=$P(CurData,"^",4)_"-"_$P(CurData,"^",5)
	.//w !,Rangs_"&&"
	if ("-"=Rangs)  s Rangs=""
	q Rangs
}

/// d ##Class(web.DHCPE.ReportOutToWeb).OutSummarizeToWeb()
ClassMethod OutSummarizeToWeb()
{
 	w "<xml id=xmlSummarize>",!
 	w " <SummarizeList>",!
	
	s id=""
	f  s id=$O(^xwmTest("Summarize",id)) Q:(""=id)  d
	.w " <Summarize>",!
	.w "  <Station>"_id_"</Station>",!
	.w "  <Desc>"_"<![CDATA["_$G(^xwmTest("Summarize",id))_"]]>"_"</Desc>",!
	.w "  <AduitUser>"_$G(^xwmTest("Summarize",id,"AduitUser"))_"</AduitUser>",!
	.w "  <AduitDate>"_$G(^xwmTest("Summarize",id,"AduitDate"))_"</AduitDate>",!
	.w " </Summarize>",!
 	
 	w " </SummarizeList>",!
 	w "</xml>",!
}

/// 科室小结
/// d ##Class(web.DHCPE.ReportOutToWeb).GetSummarize(9642)
ClassMethod GetSummarize(PAAdmRowid)
{
	
	//站点（科室）小结 DHC_PE_StationSummarize （所有阳性体症）
	k ^xwmTest("Summarize") 

	s Delimit="^"
	s IADMRowId=""
	s IADMRowId=$O(^DHCPEIADM(0,"PAADM",PAAdmRowid,IADMRowId))
	q:(""=IADMRowId) 0
	
	s SRowId=""	//科室编码
	s RowId=""	//小结编码	
	f  s SRowId=$o(^DHCPESS(0,"IADM",IADMRowId,SRowId)) q:SRowId=""  d
	.s SDesc=$p($G(^DHCPEST(SRowId)),"^",2)	//站点名称
	.
	.f  s RowId=$o(^DHCPESS(0,"IADM",IADMRowId,SRowId,RowId)) q:RowId=""  d
	..//GA_AduitUser_DR
	..s AduitUser=$p(^DHCPESS(RowId,1),"^",4)	//审核人
  ..i (""'=AduitUser) s AduitUser=$p($g(^SSU("SSUSR",AduitUser)),"^",2)	//检查医师名称	SS_User
  ..
  ..//GA_AduitDate
  ..s AduitDate=$p(^DHCPESS(RowId,1),"^",3)	//审核日期
  ..i (""'=AduitDate) s AduitDate=$ZD(AduitDate,3)
	..
	..s ^xwmTest("Summarize", SDesc)=$p(^DHCPESS(RowId,"S"),"^",5)
	..s ^xwmTest("Summarize", SDesc, "AduitUser")=AduitUser
	..s ^xwmTest("Summarize", SDesc, "AduitDate")=AduitDate
	..
	
	Q 1
}

/// d ##Class(web.DHCPE.ReportOutToWeb).OutGeneralAdviceToWeb()
ClassMethod OutGeneralAdviceToWeb()
{
 	w "<xml id=xmlGeneralAdvice>",!
 	w "	<GeneralAdvice>",!
	
	w "  <AduitUser>"_$G(^xwmTest("GeneralAdvice", "AduitUser"))_"AduitUser",!
	w "  <AduitDate>"_$G(^xwmTest("GeneralAdvice", "AduitDate"))_"</AduitDate>",!
	w "  <Advice>"_"<![CDATA["_$G(^xwmTest("GeneralAdvice", "Advice"))_"]]>"_"</Advice>",!
 	
 	w " </GeneralAdvice>",!
 	w "</xml>",!
}

/// 总检建议 DHC_PE_GeneralAdvice ^DHCPEGA
/// d ##Class(web.DHCPE.ReportOutToWeb).GetGeneralAdvice(9642)
ClassMethod GetGeneralAdvice(PAAdmRowid)
{
	k ^xwmTest("GeneralAdvice") 

	s IADMRowId=""
	s IADMRowId=$O(^DHCPEIADM(0,"PAADM",PAAdmRowid,IADMRowId))
	q:(""=IADMRowId) 0
	 
	s RowId=""
	f  s RowId=$o(^DHCPEGA(0,"IADM",IADMRowId,RowId)) q:RowId=""  d
	.
	.//GA_AduitUser_DR
	.s AduitUser=$p(^DHCPEGA(RowId,1),"^",3)	//审核人
  .i (""'=AduitUser) s AduitUser=$p($g(^SSU("SSUSR",AduitUser)),"^",2)	//检查医师名称	SS_User
  .s ^xwmTest("GeneralAdvice","AduitUser")=AduitUser
  .
  .//GA_AduitDate
  .s AduitDate=$p(^DHCPEGA(RowId,1),"^",2)	//审核日期
  .i (""'=AduitDate) s AduitDate=$ZD(AduitDate,3)
	.s ^xwmTest("GeneralAdvice","AduitDate")=AduitDate
	.
	.//
	.s Advice=$G(^DHCPEGA(RowId,"A"))	//建议
	.s ^xwmTest("GeneralAdvice","Advice")=Advice
	q 1
}

// d ##Class(web.DHCPE.ResultContrast).GetARCIMId("2000","433236^433256")

ClassMethod GetARCIMId(RegNo, Str)
{
  k ^TMPFlag
  s OtherStation=$G(^DHCPESetting("DHCPE","StationId_Other"))
  //q:RegNo=""
  f i=1:1:$l(Str,"^") d
  .s AdmId=$p(Str,"^",i)
  .q:AdmId=0
  .s OEORDRowId=0
  .f  s OEORDRowId=$o(^OEORD(0,"Adm",AdmId,OEORDRowId))   Q:OEORDRowId=""  d
  ..s OEORIChildsub=0
  ..s ret=""
  ..s iLLoop=0
  ..f  s OEORIChildsub=$O(^OEORD(OEORDRowId,"I",OEORIChildsub)) Q:(""=OEORIChildsub)  d
  ...s iLLoop=iLLoop+1
  ...s OEORIRowId=OEORDRowId_"||"_OEORIChildsub
  ...s OEORIItemStatDR=$p($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",13)
  ...//当医嘱为停止状态退出
  ...q:OEORIItemStatDR=4
  ...s OEORIItmMastDR=$p($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",2)
  ...q:OEORIItmMastDR=""
  ...s STDR=$o(^DHCPEST(0,"STORD_ARCIM",OEORIItmMastDR,0))
  ...q:$o(^DHCPEST(0,"STORD_ARCIM",OEORIItmMastDR,0))=""  // 当医嘱在站点与大项中未关联退出
  ...s STID=$o(^DHCPEST(0,"STORD_ARCIM",OEORIItmMastDR,0))
  ...q:("^"_OtherStation_"^")[("^"_STID_"^")
  ...s ARCIMSubscript=$P(OEORIItmMastDR,"||",1)
  ...s ARCIMVersion=$P(OEORIItmMastDR,"||",2)
  ...s ARCIMDesc=$P($G(^ARCIM(ARCIMSubscript,ARCIMVersion,1)),"^",2)
  ...q:($d(^TMPFlag(OEORIItmMastDR))=1)
  ...s ^TMPResultContrast("ResultHistory","ARCIM",OEORIItmMastDR)=ARCIMDesc
  ...s ^TMPFlag(OEORIItmMastDR)=1
}

Query ContrastWithLast(PAADM As %Library.String = "") As %Query(ROWSPEC = "TARCIMItem:%String, TLastTime:%String, TCurrentTime:%String, TLastTime2:%String,")
{
}

ClassMethod ContrastWithLastExecute(ByRef qHandle As %Binary, PAADM As %Library.String = "") As %Status
{


	Set repid=$I(^CacheTemp)
	Set qHandle=$lb(0,repid,0)
 	s ind=1
    k ^DHCPETMPContrast
    k ^DHCPETMPNormalFlag
    s RisStation=$g(^DHCPESetting("DHCPE","StationId_Ris"))
 	Q:(""=PAADM) $$$OK
 	s PAPMIDR=$p(^PAADM(PAADM),"^",1)
 	S Num=0
 	s PAADMRowID=""
 	f  s PAADMRowID=$o(^PAPERdr(PAPMIDR,"ADM","H",PAADMRowID),-1)  Q:((PAADMRowID="")||(PAADMRowID=0)||(Num>=3))  d
 	.q:(PAADMRowID>PAADM)
 	.s IADM=0
 	.s IADM=$O(^DHCPEIADM(0,"PAADM",PAADMRowID,0))
 	.Q:IADM=""
 	.s IADMStatus=$p(^DHCPEIADM(IADM),"^",8)
 	.q:((IADMStatus'="ARRIVED")&&(IADMStatus'="REGISTERED"))
 	.s IADMDate=##class(websys.Conversions).DateLogicalToHtml($p(^DHCPEIADM(IADM),"^",5))
 	.s Num=Num+1
    .s ^DHCPETMPContrast("PAADM",PAADMRowID)=IADMDate
    .s ^DHCPETMPContrast("IADMDate")=$g(^DHCPETMPContrast("IADMDate"))_"^"_IADMDate
    .s ^DHCPETMPContrast("IADM",IADM)=IADMDate
    
    s AdmId="",num=0
    f  s AdmId=$o(^DHCPETMPContrast("PAADM",AdmId),-1)  q:(AdmId="")||(AdmId=0)  d
    .s num=num+1
    .s RLTRowid=0
	.f  s RLTRowid=$o(^DHCPERLT(0,"ADM",AdmId,RLTRowid)) q:RLTRowid=""  d
	..s RLTOEORIDR=$p(^DHCPERLT(RLTRowid),"^",9)
	..s Normal=$p(^DHCPERLT(RLTRowid),"^",7)
	..s ARCIMDR=$p(^DHCPERLT(RLTRowid),"^",2)
	..s STID=0
	..s STID=$o(^DHCPEST(0,"STORD_ARCIM",ARCIMDR,0))
	..s OEORDRowId=$P(RLTOEORIDR,"||",1) 
	..s OEORIChildsub=$P(RLTOEORIDR,"||",2)
	..s OEORIItemStatDR=$p($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",13)
	..q:OEORIItemStatDR=4
    ..s ODDR=$p(^DHCPERLT(RLTRowid),"^",3)
    ..Q:ODDR=""
 	..s ODDesc=$p($g(^DHCPEST($p(ODDR,"||",1),"OD",$p(ODDR,"||",2))),"^",1)
 	..s RLTResult=$p(^DHCPERLT(RLTRowid),"^",4)
 	..s RLTTeplete=$p(^DHCPERLT(RLTRowid),"^",10)
 	..i '$d(^DHCPETMPNormalFlag(STID,ARCIMDR,num)) s ^DHCPETMPNormalFlag(STID,ARCIMDR,num)="N"
 	..i Normal="0"  d
 	...s ^DHCPETMPNormalFlag(STID,ARCIMDR,num)="Y"
 	...i ("^"_RisStation_"^")[("^"_STID_"^")  d
 	....s Str="诊断意见:"_$p(RLTResult,";诊断意见:",2)
 	...else  s Str=ODDesc_"("_RLTResult_"  "_RLTTeplete_")"
    ...s ^DHCPETMPContrast("ARCIM",STID,ARCIMDR,num)=$g(^DHCPETMPContrast("ARCIM",STID,ARCIMDR,num))_"  "_Str
    
    
    
    s STID=0
    f  s STID=$o(^DHCPETMPNormalFlag(STID))  q:STID=""  d
    .s ARCIMDR=0
    .f  s ARCIMDR=$o(^DHCPETMPNormalFlag(STID,ARCIMDR)) q:ARCIMDR=""  d
    ..s num=0
    ..f  s num=$o(^DHCPETMPNormalFlag(STID,ARCIMDR,num))  q:num=""  d
    ...i ^DHCPETMPNormalFlag(STID,ARCIMDR,num)="N"  s ^DHCPETMPContrast("ARCIM",STID,ARCIMDR,num)="未见异常"
    
    s IADM="",num=0
    f  s IADM=$o(^DHCPETMPContrast("IADM",IADM),-1)  q:(IADM="")||(IADM=0)  d
    .s GSRowId=0
    .s DiagnoseConclusStr=""
    .f  s GSRowId=$o(^DHCPEGS(0,"IADM",IADM,GSRowId))  q:GSRowId=""  d
    ..s num=num+1
    ..s GSDChildSub=0
    ..f  s GSDChildSub=$o(^DHCPEGS(GSRowId,"Diagnosis",GSDChildSub))  q:GSDChildSub=""  d
    ...s GSDEDDR=$p(^DHCPEGS(GSRowId,"Diagnosis",GSDChildSub),"^",1)
    ...q:GSDEDDR=""
    ...s EDDiagnoseConclus=$p(^DHCPEED(GSDEDDR,1),"^",1)
    ...i DiagnoseConclusStr=""  s DiagnoseConclusStr=EDDiagnoseConclus
    ...else  s DiagnoseConclusStr=DiagnoseConclusStr_","_EDDiagnoseConclus
    ...s ^DHCPETMPContrast("Diagnose",num)=DiagnoseConclusStr

    
    s DateTitle=$g(^DHCPETMPContrast("IADMDate"))
    s LastResult=$p(DateTitle,"^",3)
    s LastResult2=$p(DateTitle,"^",4)
    s CurrentResult=$p(DateTitle,"^",2)
    s ARCIMDesc="医嘱"
    d OutOItemStatusForAdm
    
    
    s StationID=0
    f  s StationID=$o(^DHCPETMPContrast("ARCIM",StationID))  q:StationID=""  d
    .s ARCIMDR=0
    .f  s ARCIMDR=$o(^DHCPETMPContrast("ARCIM",StationID,ARCIMDR))  q:ARCIMDR=""  d
    ..s CurrentResult=$g(^DHCPETMPContrast("ARCIM",StationID,ARCIMDR,1))
    ..s LastResult=$g(^DHCPETMPContrast("ARCIM",StationID,ARCIMDR,2))
    ..s LastResult2=$g(^DHCPETMPContrast("ARCIM",StationID,ARCIMDR,3))
   	..s ARCIMSubscript=$P(ARCIMDR,"||",1)
	..s ARCIMVersion=$P(ARCIMDR,"||",2)
    ..q:ARCIMVersion=""
	..s ARCIMDesc=$P($G(^ARCIM(ARCIMSubscript,$g(ARCIMVersion),1)),"^",2)
	..d OutOItemStatusForAdm
	

	
	
	s ARCIMDesc="诊断"
    s CurrentResult=$g(^DHCPETMPContrast("Diagnose",1)) 
    s LastResult=$g(^DHCPETMPContrast("Diagnose",2))
    s LastResult2=$g(^DHCPETMPContrast("Diagnose",3))  
    d OutOItemStatusForAdm
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
OutOItemStatusForAdm
			   //TOEORIRowId, TOEORIItmMastDR, TItemName, TSpecNo,TSpecName,TDate,TTime,TUserName,TOSTATDesc)
	set Data=$lb(ARCIMDesc,LastResult, CurrentResult,LastResult2)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod ContrastWithLastFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = ContrastWithLastExecute ]
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

ClassMethod ContrastWithLastClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = ContrastWithLastExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

}
