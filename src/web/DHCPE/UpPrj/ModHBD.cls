Import SQLUser

/// 处理业务数据
/// 医生站导病人信息d ##class(DHCDoc.Local.InfoImport).ImportPatInfo()
Class web.DHCPE.UpPrj.ModHBD Extends %Persistent
{

Parameter ON = "OLDDATA";

Parameter IdxON = "OLDORDINDEX";

Parameter LabON = "OLDLABDATA";

Parameter LocID = 341;

Parameter Hospital = 2;

Parameter UserID = 3364;

Parameter OneNum = 20000;

/// w ##class(web.DHCPE.UpPrj.ModHBD).ModifyOldHPCRMOrder(1788165)
/// 长治市人民处理导数据   达克罗宁胶浆[10ml:0.1g]
ClassMethod ModifyOldHPCRMOrder(CRMOrdID)
{
	s $ZT="ModifyOldHPCRMOrderErr"
	s IADM=$P(^DHCPECRMO(CRMOrdID),"^",3)
	i IADM'="" d
	.s PAADM=$P(^DHCPEIADM(IADM),"^",1)
	.s OrdId=$O(^OEORD(0,"Adm",PAADM,0))
	s OEORI=$P(^DHCPECRMO(CRMOrdID),"^",1)
	s CMRORI=$P(^DHCPECRMO(CRMOrdID),"^",2)
	
	i +OEORI'=OrdId d
	.&SQL(DELETE FROM  DHC_PE_CRMOrder WHERE CRMO_RowId=:CRMOrdID and CRMO_IADM_DR=:IADM)
	.s $P(^DHCPEPreIADM(+CMRORI,"ORDITEM",$P(CMRORI,"||",2)),"^",16)=4	
	q 0
	
ModifyOldHPCRMOrderErr
	q "-1"
}

/// w ##class(web.DHCPE.UpPrj.ModHBD).mOldHBDRLTData()
ClassMethod mOldHBDRLTData()
{
	w "体检Copy结果数据,请不要关闭Terminal"
	s Job=$J 
	w !,"Job is "_Job
	s CurrRunPID=$I(^DHCPEDataEx("ModHBD"))
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","Start")=$ZD(+$H,3)_" "_$ZT($P($H,",",2)) _"mOldBaseData"
	
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" ^start"
	m ^DHCPERLT=^[..#ON]DHCPERLT
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPERLT"
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","end")=$ZD(+$H,3)_" "_$ZT($P($H,",",2)) _"mOldBaseData"
	q "Over"
}

/// w ##class(web.DHCPE.UpPrj.ModHBD).mOldHBDDataSingle()
ClassMethod mOldHBDDataSingle()
{
	w "体检Copy结果数据,请不要关闭Terminal"
	s Job=$J 
	w !,"Job is "_Job
	s CurrRunPID=$I(^DHCPEDataEx("ModHBD"))
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","Start")=$ZD(+$H,3)_" "_$ZT($P($H,",",2)) _"mOldBaseData"
	
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" ^start"
	m ^DHCPEPreIBI=^[..#ON]DHCPEPreIBI
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" test"
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","end")=$ZD(+$H,3)_" "_$ZT($P($H,",",2)) _"mOldBaseData"
	q "Over"
}

/// w ##class(web.DHCPE.UpPrj.ModHBD).mOldHBDData()
ClassMethod mOldHBDData()
{
	w "体检Copy数据,请不要关闭Terminal"
	s Job=$J 
	w !,"Job is "_Job
	
	s CurrRunPID=$I(^DHCPEDataEx("ModHBD"))
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","Start")=$ZD(+$H,3)_" "_$ZT($P($H,",",2)) _"mOldBaseData"
	
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" ^start"
	m ^DHCPEGBI=^[..#ON]DHCPEGBI
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEGBI"

	m ^DHCPEIADM=^[..#ON]DHCPEIADM
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEIADM"
	
	m ^DHCPEGADM=^[..#ON]DHCPEGADM
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEGADM"
	
	m ^DHCPECRMO=^[..#ON]DHCPECRMO
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPECRMO"
	
	m ^DHCPESS=^[..#ON]DHCPESS
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPESS"
	
	m ^DHCPEGS=^[..#ON]DHCPEGS
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEGS"
	
	m ^DHCPEGSDM=^[..#ON]DHCPEGSDM
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEGSDM"
	
	m ^DHCPEGGS=^[..#ON]DHCPEGGS
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEGGS"
	
	m ^DHCPERPT=^[..#ON]DHCPERPT
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPERPT"
	
	;m ^User.DHCPEAdmRecordManagerD=^[..#ON]User.DHCPEAdmRecordManagerD
	;;m ^User.DHCPEAdmRecordManagerI=^[..#ON]User.DHCPEAdmRecordManagerI
	m ^DHCPEPreIBI=^[..#ON]DHCPEPreIBI
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEPreIBI"
	
	m ^DHCPEPreIADM=^[..#ON]DHCPEPreIADM
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEPreIADM"
	
	m ^DHCPEPreGBI=^[..#ON]DHCPEPreGBI
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEPreGBI"
	
	m ^DHCPEPreGADM=^[..#ON]DHCPEPreGADM
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEPreGADM"
	
	m ^DHCPEPreA=^[..#ON]DHCPEPreA
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEPreA"
	
	m ^DHCPEPAPBR=^[..#ON]DHCPEPAPBR
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEPAPBR"
	
	m ^DHCPEINVPRT=^[..#ON]DHCPEINVPRT
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEINVPRT"
	
	m ^DHCPEOEITEM=^[..#ON]DHCPEOEITEM
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEOEITEM"
	
	;^DHCPEDataEx("DHCPEGSDiagnosis")
	;^DHCPEDataEx("DHCPEGeneralSummarize")
	;m ^DHCPEData=^[..#ON]DHCPEData	
	;m ^DHCPEDataEx=^[..#ON]DHCPEDataEx
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEDataEx"
	
	m ^User.DHCPEGSSumI=^[..#ON]User.DHCPEGSSumI
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" User.DHCPEGSSumI"
	
	m ^User.DHCPEGSSumD=^[..#ON]User.DHCPEGSSumD
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" User.DHCPEGSSumD"
	
	m ^DHCPEAP=^[..#ON]DHCPEAP
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEAP"
	
	m ^DHCPEHPNoRecord=^[..#ON]DHCPEHPNoRecord
	w !,$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" DHCPEHPNoRecord"
	
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","end")=$ZD(+$H,3)_" "_$ZT($P($H,",",2)) _"mOldBaseData"
	q "Over"
}

/*
需要对套餐进行关联
*/
/// Debugger:w ##class(web.DHCPE.UpPrj.ModHBD).GenerateStart()
ClassMethod GenerateStart()
{
	;d ##class(User.DHCPEIADM).%BuildIndices()
	k ^TempDHCPE
	k ^DHCPEDataEx("OldPEData")
	k ^DHCPEDataEx("ModHBD")
	k ^DHCPEIADM(0)
	k ^DHCPEGADM(0)
	k ^DHCPEPreA(0)
	k ^DHCPESS(0)
	k ^DHCPEGS(0)
	k ^DHCPEINVPRT(0,"ADM")
	k ^DHCPEINVPRT(0,"USER")
	k ^DHCPERLT(0)
	q 0
}

/// Debugger:w ##class(web.DHCPE.UpPrj.ModHBD).GenerateOver()
ClassMethod GenerateOver()
{
	w !,"重新生成索引 "_$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" ^start..."
	d ##class(User.DHCPEINVPRT).%BuildIndices()	
	w !,"User.DHCPEINVPRT"_$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	d ##class(User.DHCPEStationSummarize).%BuildIndices()
	w !,"User.DHCPEStationSummarize"_$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	d ##class(User.DHCPEPreAudit).%BuildIndices()
	w !,"User.DHCPEPreAudit"_$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	d ##class(User.DHCPEGeneralSummarize).%BuildIndices()
	w !,"User.DHCPEGeneralSummarize"_$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	d ##class(User.DHCPEGSDiagnosis).%BuildIndices()
	w !,"User.DHCPEGSDiagnosis"_$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	d ##class(User.DHCPEResult).%BuildIndices()
	w !,"User.DHCPEResult"_$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	q "Over"
}

/// Debugger:w ##class(web.DHCPE.UpPrj.ModHBD).GenerateTest() 
ClassMethod GenerateTest()
{
	k ^TempDHCPE("GenerateOnePreIADMErr")
	s PreIADM=0
	for {
		s PreIADM=$O(^DHCPEPreIADM(PreIADM))
		;b ;PreIADM
		q:(PreIADM="")
		s ret=..UpdatePreIOrdItemTest(PreIADM,"Y")

	}
	q "Over"
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      主方法
/// Table:            DHC_PE_PreIADM
/// Input:            DHC_PE_PreIADM
/// 主方法大约跑9小时
/// Debugger:w ##class(web.DHCPE.UpPrj.ModHBD).GenerateMain(1,10000,"") 
ClassMethod GenerateMain(BeginID As %String = "", EndID As %String = "", PIADM As %String = "")
{
	;w ##class(web.DHCPE.ImportOldData).ReplaceSexAndMarried()
	;k ^DHCPEDataEx("ModHBD")
	;d ##class(web.DHCPE.UpPrj.ModHBD).GenerateTest()  
	s InTrouble=..InUpTrouble()
	;b ;InTrouble
	q:InTrouble'="" InTrouble
	
	i PIADM'="" q ..GenerateOnePreIADM(PIADM)
	
	s CurrRunPID=$I(^DHCPEDataEx("ModHBD"))
	w "Job is :"_$J_"  CurrRunPID:"_CurrRunPID
	
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","Start")=$ZD(+$H,3)_" "_$ZT($P($H,",",2))_" BeginID:"_BeginID_" EndID:"_EndID_" Job Is:"_$J
	s $ZT="GenerateMainErr"
	
	s (Count,SuCount,ErrCount)=0
	;d ..GenerateStart()
	i +BeginID'=0 s PreIADM=BeginID-1
	for {
		s PreIADM=$O(^DHCPEPreIADM(PreIADM))
		;w !,PreIADM
		q:(PreIADM="")
		q:PreIADM>EndID
		
		s ret=..GenerateOnePreIADM(PreIADM)
		s Count=Count+1
		s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","RunOver")=PreIADM_"  "_$J_" "_$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	}
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","End")=$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	q Count
GenerateMainErr
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","Err")=PreIADM_"  "_$ZE
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","End")=$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	q Count
}

/// Debugger:w ##class(web.DHCPE.UpPrj.ModHBD).GenerateErrRecord() 
ClassMethod GenerateErrRecord()
{
	
	s CurrRunPID=$I(^DHCPEDataEx("ModHBD"))
	w "Job is :"_$J_"  CurrRunPID:"_CurrRunPID
	s $ZT="GenerateMainErr"
	
	s (Count,SuCount,ErrCount)=0
	;d ..GenerateStart()
	s PreIADM=""
	for {
		s PreIADM=$O(^TempDHCPE("GenerateOnePreIADMErr",PreIADM))
		
		;b ;PreIADM
		q:(PreIADM="")
		
		s ret=..GenerateOnePreIADM(PreIADM)
		w !,PreIADM_" ret "_ret
		s Count=Count+1
		s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","RunOver")=PreIADM_"  "_$J_" "_$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	}
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","End")=$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	q Count
GenerateMainErr
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","Err")=PreIADM_"  "_$ZE
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","End")=$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	q Count
}

/// Debugger:w ##class(web.DHCPE.UpPrj.ModHBD).GenerateOnePreIADM(166473) 
ClassMethod GenerateOnePreIADM(PreIADM As %String)
{
	
	
	s $ZT="GenerateOnePreIADMErr"
	q:$D(^[..#ON]DHCPEPreIADM(PreIADM))=10 ""
	;TS
	s PreGADM=""
	s ret=..UpdatePreIBase(PreIADM)
	i ret'=""  goto GenerateOnePreIADMErr
	
	s ret=..UpdatePreIADM(PreIADM,.PreGADM)
	;b ;UpdatePreIADM
	i ret'=""  goto GenerateOnePreIADMErr
	;b ;PreGADM
	i PreGADM'="" {
		s ret=..UpdatePreGADM(PreGADM)
		i ret'=""  goto GenerateOnePreIADMErr
		
		s ret=..UpdatePreGTOrdItem(PreGADM)
		i ret'=""  goto GenerateOnePreIADMErr

		s ret=..UpdatePreGTOrdEnt(PreGADM)
		i ret'=""  goto GenerateOnePreIADMErr
	
		
		s NGroupPAADM=..GenGroupPAADMByPreGADM(PreGADM)
		i +NGroupPAADM="-1"  goto GenerateOnePreIADMErr
		;b ;NGroupPAADM
		i NGroupPAADM'=""{
			s ret=..UpdateGADM(PreGADM,NGroupPAADM)
			i ret'=""  goto GenerateOnePreIADMErr
			
			s ret=..UpdatePreAudit(PreGADM,"G") //审核表
			i ret'=""  goto GenerateOnePreIADMErr
			
			s ret=..UpdateGINVPRT(PreGADM,NGroupPAADM)
			i ret'=""  goto GenerateOnePreIADMErr

		}

	}
	s ret=..UpdatePreIOrdItem(PreIADM,"N")
	;b ;UpdatePreIOrdItem
	i ret'=""  goto GenerateOnePreIADMErr
	
	s ret=..UpdatePreIOrdEnt(PreIADM)
	;b ;UpdatePreIOrdEnt
	i ret'=""  goto GenerateOnePreIADMErr

	s NPAADM=..GenPAADMByPreIADM(PreIADM)
	;b ;GenPAADMByPreIADM NPAADM
	i ret'=""  goto GenerateOnePreIADMErr
	;b ;NPAADM
	i NPAADM'="" {
		s ret= ..UpdateIADM(PreIADM,NPAADM)
		;b ;UpdateIADM
		i ret'=""  goto GenerateOnePreIADMErr

		
		s ret=..UpdatePreAudit(PreIADM,"I") //审核表
		i ret'=""  goto GenerateOnePreIADMErr
			
		s ret= ..GenOEOrdItemByPreIADM(PreIADM,NPAADM)
		;b ;GenOEOrdItemByPreIADM
		i ret'=""  goto GenerateOnePreIADMErr
		s ret=..UpdateStationSummarize(PreIADM,NPAADM)	
		i ret'=""  goto GenerateOnePreIADMErr
		s ret= ..UpdateGeneralSummarize(PreIADM,NPAADM)
		;b ;UpdateGeneralSummarize
		i ret'=""  goto GenerateOnePreIADMErr
		
		s ret= ..UpdateReport(PreIADM,NPAADM)
		;b ;UpdateReport
		i ret'=""  goto GenerateOnePreIADMErr

		s ret= ..UpdateINVPRT(PreIADM,NPAADM)
		;b ;UpdateINVPRT
		i ret'=""  goto GenerateOnePreIADMErr

		s ret= ..UpdateResult(PreIADM,NPAADM)
		;b ;UpdateResult
		i ret'=""  goto GenerateOnePreIADMErr
			
		;d ##class(web.DHCPE.NetReport.Main).Main(NPAADM)
	}
	;TC
	s Status=""
	s Status=$P($G(^DHCPEIADM(PreIADM)),"^",8)
	i $D(^TempDHCPE("GenerateOnePreIADMErr",PreIADM)) K ^TempDHCPE("GenerateOnePreIADMErr",PreIADM)
	s ^DHCPEDataEx("OldPEData",PreIADM)=$G(NPAADM)_"^"_$G(NGroupPAADM)_"^"_$G(Status)
	q "Over"
GenerateOnePreIADMErr
	;b ;GenerateOnePreIADMErr
	;TRO
	s:ret="" ret=$ZE
	/*
	s GenOEORD=$O(^OEORD(""),-1)
	i (GenOEORD'="")&&($D(^OEORD(GenOEORD))="10") d
	.k ^OEORD(GenOEORD)
	*/
	s CI=$I(^TempDHCPE("GenerateOnePreIADMErr",PreIADM))
	s ^TempDHCPE("GenerateOnePreIADMErr",PreIADM,CI)=ret
	q ret
}

/// Debugger:w ##class(web.DHCPE.UpPrj.ModHBD).UpdatePreIBase(159884) 
ClassMethod UpdatePreIBase(PreIADM)
{
	s $ZT="UpdatePreIBaseErr"
	s ret=""
	s OIBaseID=$P(^[..#ON]DHCPEPreIADM(PreIADM),"^",1)
	s PAPMINo=$P(^[..#ON]DHCPEPreIBI(OIBaseID),"^",1)
	s PAPMINoUP=$$ALPHAUP^SSUTIL4(PAPMINo)
	s NewPAPMIDR=$O(^PAPERi("PAPMI_PatNo",PAPMINoUP,0))
	q:NewPAPMIDR="" "-1^PatMas未生成"
	s $P(^DHCPEPreIBI(OIBaseID),"^",3)=$P($G(^PAPER(NewPAPMIDR,"ALL")),"^",7)		;sex
	s $P(^DHCPEPreIBI(OIBaseID),"^",15)=$P($G(^PAPER(NewPAPMIDR,"PER",2)),"^",1)		;NationDR
	s $P(^DHCPEPreIBI(OIBaseID),"^",17)=$P($G(^PAPER(NewPAPMIDR,"PER",2)),"^",3)		;MarriedDR
	q ""
UpdatePreIBaseErr
	q $ZE
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      1、是否有体检医嘱套子分类
/// Input:            DHC_PE_PreIADM.PIADM_RowId
/// Return:           "-1^错误" 
/// Debugger:	w ##class(web.DHCPE.UpPrj.ModHBD).InUpTrouble() 
ClassMethod InUpTrouble()
{
	k ^DHCPEDataEx("DHCPEGeneralSummarize","MainDate") ;
	s Ret="",TInfo=""
	s SQLCode=0,ARCICDesc="体检医嘱套"
	&SQL(SELECT * FROM ARC_ItemCat WHERE ARCIC_Desc=:ARCICDesc)
	i %ROWCOUNT<1 d
	.s TInfo=TInfo_",新建医嘱子分类 体检医嘱套"
	s docId=$G(^DHCPESetting("DHCPE","PhyExamDrId",..#LocID)) 
	i docId="" s TInfo=TInfo_",设置科室医生PhyExamDrId"
	i '$D(^DHCPESetting("NAMESPACE","MEDDATA")) d
	.s TInfo=TInfo_","_"^DHCPESetting(NAMESPACE,MEDDATA)"
	i '$D(^DHCPESetting("DHCPE","OrderInterface",..#LocID)) d
	.s TInfo=TInfo_","_"OrderInterface"
	
	i '$D(^[..#IdxON]OEORD(0,"Adm")) d
	.s TInfo=TInfo_","_"就诊索引OEOrder不存在"
	q TInfo
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      更新PreIADM的相关信息 PIADM_UpdateUser_DR,PIADM_DepCode_DR
/// Input:            DHC_PE_PreIADM.PIADM_RowId
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).UpdatePreIADM(119)
ClassMethod UpdatePreIADM(PreIADM, PreGADM)
{
	s Err=""
	s OUserId=$P(^[..#ON]DHCPEPreIADM(PreIADM),"^",21)
	s OlocId=$P(^[..#ON]DHCPEPreIADM(PreIADM),"^",26)
	s PreGADM=$P(^[..#ON]DHCPEPreIADM(PreIADM),"^",2)
	s NUserId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	i +NUserId="-1" s Err=$P(NUserId,"^",2)
	q:Err'="" Err
	s $P(^DHCPEPreIADM(PreIADM),"^",21)=NUserId
	s $P(^DHCPEPreIADM(PreIADM),"^",26)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(OlocId)
	q Err
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      更新PreGADM的相关信息 PIADM_UpdateUser_DR,PIADM_DepCode_DR
/// Input:            DHC_PE_PreIADM.PIADM_RowId
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).UpdatePreGADM(119)
ClassMethod UpdatePreGADM(PreGADM)
{
	s Err=""
	s OUserId=$P(^[..#ON]DHCPEPreGADM(PreGADM),"^",19)
	s OlocId=$P(^[..#ON]DHCPEPreGADM(PreGADM),"^",23)
	s NUserId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	i +NUserId="-1" s Err=$P(NUserId,"^",2)
	q:Err'="" Err
	s $P(^DHCPEPreGADM(PreGADM),"^",19)=NUserId
	s $P(^DHCPEPreGADM(PreGADM),"^",23)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(OlocId)
	q Err
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      更新PreGADM的相关信息 PIADM_UpdateUser_DR,PIADM_DepCode_DR
/// Input:            DHC_PE_PreIADM.PIADM_RowId
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).UpdatePreGTOrdItem(1620)
ClassMethod UpdatePreGTOrdItem(PreGADM)
{
	s Err=""
	s Sub=0  f  s Sub=$O(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub)) q:Sub=""  d
	.s ISub=0  f  s ISub=$O(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub,"ORDITEM",ISub)) q:ISub=""  d
	..
	..s OUserId=$P(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub,"ORDITEM",ISub),"^",8)
	..s OArcim=$P(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub,"ORDITEM",ISub),"^",1)
	..s ORecLoc=$P(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub,"ORDITEM",ISub),"^",14)
	..i ORecLoc'="" d
	...s $P(^DHCPEPreGADM(PreGADM,"Team",Sub,"ORDITEM",ISub),"^",14)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(ORecLoc)
	..i OArcim'="" d
	...s $P(^DHCPEPreGADM(PreGADM,"Team",Sub,"ORDITEM",ISub),"^",1)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewArcim(OArcim)
	..i OUserId'="" d
	...s $P(^DHCPEPreGADM(PreGADM,"Team",Sub,"ORDITEM",ISub),"^",8)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	q Err
}

ClassMethod UpdatePreGTOrdEnt(PreGADM)
{
	s Err=""
	s Sub=""  f  s Sub=$O(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub)) q:Sub=""  d
	.s ISub=""  f  s ISub=$O(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub,"ORDENT",ISub)) q:ISub=""  d
	..s OUserId=$P(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub,"ORDENT",ISub),"^",2)
	..s OSets=$P(^[..#ON]DHCPEPreGADM(PreGADM,"Team",Sub,"ORDENT",ISub),"^",1)
	..i OSets'="" d
	...s $P(^DHCPEPreGADM(PreGADM,"Team",Sub,"ORDENT",ISub),"^",1)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewOrdEnt(OSets)
	..i OUserId'="" d
	...s $P(^DHCPEPreGADM(PreGADM,"Team",Sub,"ORDENT",ISub),"^",2)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	q Err
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      更新 DHC_PE_PreIOrdItem的PIADM_UpdateUser_DR,PIADM_DepCode_DR
///  			      更新 DHC_PE_PreIOrdItemFee的PIOI_UpdateUser_DR
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).UpdatePreIOrdItem(163134)
ClassMethod UpdatePreIOrdItem(PreIADM, TestFlag As %String = "N")
{
	s Err=""
	s UnFind=""
	s Sub=0  f  s Sub=$O(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub))  q:(Sub="")||(Err'="")  d
	.s OArcim=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",1)
	.s OUserId=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",11)
	.s OlocId=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",17)
	.s ArcimCode=""
	.s NArcim=##class(web.DHCPE.UpPrj.BaseInfo).GetNewArcim(OArcim,.ArcimCode)
	.i +NArcim="-1" d
	..s Err=$P(NArcim,"^",2)
	..s ^TempDHCPE("UnFindARCItmMastO2N",NArcim)=ArcimCode
	..s UnFind=UnFind_","_ArcimCode
	.;q:Err'=""
	.s NUserId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	.i +NUserId="-1" d
	..s Err=$P(NUserId,"^",2)
	..s UnFind=UnFind_","_OUserId
	.;q:Err'=""
	.i +NArcim'="-1" s $P(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",1)=NArcim
	.s $P(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",11)=NUserId
	.s NlocId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(OlocId)
	.i +NlocId="-1" d
	..s Err=$P(NlocId,"^",2)
	..s UnFind=UnFind_","_OlocId
	.q:TestFlag="Y"
	.;w:Err'="" "OlocId "_OlocId
	.;q:Err'=""
	.s $P(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",17)=NlocId
	.s FSub=0 f  s FSub=$O(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub,"FEE",FSub))  q:FSub=""  d
	..s OFUserId=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub,"FEE",FSub),"^",6)
	..s $P(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub,"FEE",FSub),"^",6)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OFUserId)
	i UnFind'="" s Err=UnFind w !,PreIADM_"  "_UnFind
	q Err
}

ClassMethod UpdatePreIOrdItemTest(PreIADM, TestFlag As %String = "N")
{
	q:$D(^[..#ON]DHCPEPreIADM(PreIADM))=10 ""
	s $ZT="UpdatePreIOrdItemTestErr"
	s Err=""
	s UnFind=""
	s Sub=0  f  s Sub=$O(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub))  q:(Sub="")  d
	.s OArcim=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",1)
	.s OUserId=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",11)
	.s OlocId=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",17)
	.s ArcimCode=""
	.s NArcim=##class(web.DHCPE.UpPrj.BaseInfo).GetNewArcim(OArcim,.ArcimCode)
	.i +NArcim="-1" d
	..s Err=$P(NArcim,"^",2)
	..s ^TempDHCPE("UnFindARCItmMastO2N",NArcim)=ArcimCode
	..s UnFind=UnFind_","_ArcimCode
	.;q:Err'=""
	.s NUserId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	.i +NUserId="-1" d
	..s Err=$P(NUserId,"^",2)
	..s UnFind=UnFind_","_OUserId
	.;q:Err'=""
	.s NlocId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(OlocId)
	.i +NlocId="-1" d
	..s Err=$P(NlocId,"^",2)
	..s UnFind=UnFind_","_OlocId
	.q:TestFlag="Y"
	.;w:Err'="" "OlocId "_OlocId
	.;q:Err'=""
	.i +NArcim'="-1" s $P(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",1)=NArcim
	.s $P(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",11)=NUserId
	.s $P(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub),"^",17)=NlocId
	.s FSub=0 f  s FSub=$O(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub,"FEE",FSub))  q:FSub=""  d
	..s OFUserId=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDITEM",Sub,"FEE",FSub),"^",6)
	..s $P(^DHCPEPreIADM(PreIADM,"ORDITEM",Sub,"FEE",FSub),"^",6)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OFUserId)
	i UnFind'="" s Err=UnFind w !,PreIADM_"  "_UnFind
	q Err
UpdatePreIOrdItemTestErr
	s CI=$I(^TempDHCPE("GenerateOnePreIADMErr",PreIADM))
	s ^TempDHCPE("GenerateOnePreIADMErr",PreIADM,CI)=$ZE

	q ""
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      更新 DHC_PE_PreIOrdEnt的PIADM_UpdateUser_DR,PIADM_DepCode_DR
///  			      更新 DHC_PE_PreIOrdItemFee的PIOI_UpdateUser_DR
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).UpdatePreIADM(117)
ClassMethod UpdatePreIOrdEnt(PreIADM)
{
	s ret=""
	s Sub=0  f  s Sub=$O(^[..#ON]DHCPEPreIADM(PreIADM,"ORDENT",Sub))  q:Sub=""  d
	.s OOrderSets=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDENT",Sub),"^",1)
	.s OUserId=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDENT",Sub),"^",3)
	.s NOrderSets=##class(web.DHCPE.UpPrj.BaseInfo).GetNewOrdEnt(OOrderSets)
	.s $P(^DHCPEPreIADM(PreIADM,"ORDENT",Sub),"^",3)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	.s $P(^DHCPEPreIADM(PreIADM,"ORDENT",Sub),"^",1)=NOrderSets
	.s FSub=0 f  s FSub=$O(^DHCPEPreIADM(PreIADM,"ORDENT",Sub,"FEE",FSub))  q:FSub=""  d
	..s OFUserId=$P(^[..#ON]DHCPEPreIADM(PreIADM,"ORDENT",Sub,"FEE",FSub),"^",6)
	..s $P(^DHCPEPreIADM(PreIADM,"ORDENT",Sub,"FEE",FSub),"^",6)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OFUserId)
	q ret
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      如PreIADM登记过，生成新PAADM
///  			      
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).GeneratePAADMByPreIADM(117)
ClassMethod GenPAADMByPreIADM(PreIADM)
{
	s IADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:IADM="" ""
	s OPAADM=$P(^[..#ON]DHCPEIADM(IADM),"^",1)
	s NPAADM=$P(^DHCPEIADM(IADM),"^",1)
	;b ;GenPAADMByPreIADM NPAADM
	q:(OPAADM'=NPAADM) NPAADM
	s PAPMIDR=$P(^[..#ON]PAADM(OPAADM),"^",1)
	s OLocId=$P(^[..#ON]PAADM(OPAADM),"^",4)
	s NLocId=..#LocID   ;##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(OLocId)
	s OCreateUser=$P(^[..#ON]PAADM(OPAADM),"^",43)
	s NCreateUser=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OCreateUser)
	s OldFeeType=$G(^[..#ON]DHCPEDataEx("DHCPEPreIADM","ADMFeeType",PreIADM))
	s NewFeeType=1
	s:NewFeeType="" NewFeeType=$P(^DHCPESetting("DHCPE","DefPatientType"),"^",1)
	
	s docId=$G(^DHCPESetting("DHCPE","PhyExamDrId",..#LocID))
	s OUserID=$p($g(^[..#ON]DHCPEPreIADM(PreIADM)),"^",21)
	s NUserID=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserID)
	i NUserID'="" d
	.s IDOCID=$p($G(^SSU("SSUSR",NUserID)),"^",14)
	.i IDOCID'="" d
	..s CarPrvTpDR=$p($g(^CTPCP(IDOCID,1)),"^",4)
	..s CTCPTType=""
	..i CarPrvTpDR'="" s CTCPTType=$p($g(^CT("CPT",CarPrvTpDR)),"^",4)
	..i CTCPTType="DOCTOR" S docId=IDOCID
	s AdmType="H"
	s AdmDate=$P(^[..#ON]PAADM(OPAADM),"^",6)
	s AdmTime=$P(^[..#ON]PAADM(OPAADM),"^",7)
	
	// 通过regno取新库的PAPMIDR
	s PAPMINo=$P($g(^[..#ON]PAPER(PAPMIDR,"PAT",1)),"^",1)
	s PAPMINoUP=$$ALPHAUP^SSUTIL4(PAPMINo)
	s NewPAPMIDR=$O(^PAPERi("PAPMI_PatNo",PAPMINoUP,0))
	s PatCatDr=$p($g(^PAPER(NewPAPMIDR,"PER",1)),"^",10)
 	i PatCatDr'="" set DHCPACADMDr=$o(^DHCPACADM(0,"Social",PatCatDr,""))
 	s AdmReason=""
 	if $g(DHCPACADMDr)'="" Do
 	.s AdmReason=$p(^DHCPACADM(DHCPACADMDr),"^",2)
	s:AdmReason="" AdmReason=1
	s ParaString=NewPAPMIDR_"^"_AdmType_"^"_AdmDate_"^"_AdmTime_"^"_NLocId_"^"_docId_"^"_AdmReason_"^"_NCreateUser_"^^^^^2^^^^^^^^^"
 	S Re=##Class(web.DHCPAADM).ADMInsert(ParaString)
 	s ^TempDHCPE("PAAdmO2N",OPAADM)=Re
 	s ^TempDHCPE("PAAdmN2O",Re)=OPAADM
	
	q Re
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      处理医嘱记录
///  			      
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).GenOEOrdItemByPreIADM(166207,1356)
ClassMethod GenOEOrdItemByPreIADM(PreIADM, NPAADM)
{
	s ret=""
	s IADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:IADM="" ""
	s OPAADM=$P(^[..#ON]DHCPEIADM(IADM),"^",1)
	s NIADM=$O(^DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:NIADM="" ""
	s OLocId=$P(^[..#ON]PAADM(OPAADM),"^",4)
	s NLocId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(OLocId)
	s OCreateUser=$P(^[..#ON]PAADM(OPAADM),"^",43)
	s NCreateUser=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OCreateUser)
	s MEDDATA=$G(^DHCPESetting("NAMESPACE","MEDDATA"))
	s FeeFlag=1
	s ret=..InsertItemsUpMode(PreIADM,NPAADM,NIADM,NCreateUser,NLocId,MEDDATA,FeeFlag,OPAADM)
	q ret
}

/// -------插入体检项目------------
/// [Previously private]
ClassMethod InsertItemsUpMode(crmRegId, admId, iAdmId, userId, locId, MEDDATA, FeeFlag As %String = 1, OPAADM)
{
	s $ZT="InsertItemsUpModeErr"
	s retStr=""
	Set HosCode=$g(^DHCPESetting("DHCPE","HospitalCode")) 
	
	k ^DHCPETMPSendPACSApplay("SendPACSApplay",$J)
	
	s NPAADM=admId
	s OOEOrder=$O(^[..#IdxON]OEORD(0,"Adm",OPAADM,""))

	q:OOEOrder="" "-1^未取到OOEOrder"
	
	TS
	
	s CurDate=$P(^[..#ON]OEORD(OOEOrder),"^",2)
	s SttDate=CurDate
	s CurTime=$P(^[..#ON]OEORD(OOEOrder),"^",3)
	s SQLCODE=0
	s ordid=$o(^OEORD(0,"Adm",NPAADM,""))
	i ordid="" d
	.&SQL(Insert Into SQLUser.OE_Order (OEORD_Adm_DR,OEORD_Date,OEORD_Time) values(:admId,:CurDate,:CurTime))
	.q:SQLCODE'=0
	.s ordid=%ROWID
	q:SQLCODE'=0 "插入OE_Order错误"_SQLCODE
	
	s OIADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",crmRegId,0))
	q:OIADM="" ""
	s OStatus=$P(^[..#ON]DHCPEIADM(OIADM),"^",8)
	

	s PreGInfo=""
	s PreGInfo=$P(^DHCPEPreIADM(crmRegId),"^",2)
	i PreGInfo'="" d
	.s PreGInfo=$P(^DHCPEPreGADM(PreGInfo),"^",1)
	.s PreGInfo=$P(^DHCPEPreGBI(PreGInfo),"^",2)
	
	s retStr=""
	s CRMORowId=""  f  s CRMORowId=$O(^[..#ON]DHCPECRMO(0,"IADM",OIADM,CRMORowId))  q:(CRMORowId="")||(retStr'="")  d
	.s OOEOrdItem=$P(^[..#ON]DHCPECRMO(CRMORowId),"^",1)
	.s CRMORI=$P(^[..#ON]DHCPECRMO(CRMORowId),"^",2)
	.s NOEOrdItem=$P(^DHCPECRMO(CRMORowId),"^",1)
	.i ((NOEOrdItem'="")&&(NOEOrdItem'=OOEOrdItem)) d
	..s hisOItemId=NOEOrdItem
	..s ^TempDHCPE("CRMOrderC2O2N",crmRegId,CRMORI)=OOEOrdItem_"^"_hisOItemId
	..s ^TempDHCPE("OEOrdItemO2N",OOEOrdItem)=hisOItemId
	..s ^TempDHCPE("OEOrdItemN2O",hisOItemId)=OOEOrdItem
	..;b ;DHCPE Insert OEORDItem Over
	..&sql(UPDATE sqluser.dhc_pe_crmorder set crmo_oeori_dr=:hisOItemId
		 where crmo_rowid=:CRMORowId)
	..;d ##class(RISService.InvokeRISService).InsertAppPACS(hisOItemId,"")
	..s OItemStatDR=$P(^[..#ON]OEORD(+OOEOrdItem,"I",$P(OOEOrdItem,"||",2),1),"^",13)
	..s OBilled=$P(^[..#ON]OEORD(+OOEOrdItem,"I",$P(OOEOrdItem,"||",2),3),"^",5)
	..s OLabEpisodeNo=$P(^[..#ON]OEORD(+OOEOrdItem,"I",$P(OOEOrdItem,"||",2),3),"^",20)
	..s $P(^OEORD(+hisOItemId,"I",$P(hisOItemId,"||",2),1),"^",13)=OItemStatDR
	..s $P(^OEORD(+hisOItemId,"I",$P(hisOItemId,"||",2),3),"^",5)=OBilled
	..q:OStatus'="ARRIVED"
	..s $P(^OEORD(+hisOItemId,"I",$P(hisOItemId,"||",2),3),"^",20)=OLabEpisodeNo
	..i OLabEpisodeNo'="" s ^OEORD(0,"EpisNo",OLabEpisodeNo,+hisOItemId,$P(hisOItemId,"||",2))=""
	.q:((NOEOrdItem'="")&&(NOEOrdItem'=OOEOrdItem)) ;已经产生过
	.s arcItemId=$p($g(^DHCPEPreIADM(+CRMORI,"ORDITEM",$P(CRMORI,"||",2))),"^",1)
	.s PhcItemAvail=##class(web.DHCPE.PreItemList).ISPhcItemAvail(arcItemId)
	.i PhcItemAvail'="1" d
	..&SQL(DELETE FROM  DHC_PE_CRMOrder WHERE CRMO_RowId=:CRMORowId and CRMO_IADM_DR=:OIADM)
	.s $P(^DHCPEPreIADM(+CRMORI,"ORDITEM",$P(CRMORI,"||",2)),"^",16)=4	

	..
	.q:PhcItemAvail'="1" ;药瓶判断库存
	.;b:((arcItemId="11403||1")||(arcItemId="2377||1"))
	.s Qty=$G(^[..#ON]DHCPEDataEx("DHCPEPreIOrdItem","Qty",CRMORI))
	.i +Qty=0 s Qty=1	
	.s NLoc=$p($g(^DHCPEPreIADM(+CRMORI,"ORDITEM",$P(CRMORI,"||",2))),"^",17)
	.s CurPrice=$p($g(^[..#ON]DHCPEPreIADM(+CRMORI,"ORDITEM",$P(CRMORI,"||",2))),"^",14)
	.s Spec=$G(^[..#ON]DHCPEDataEx("DHCPEPreIOrdItem","PERSON",CRMORI))
	.s Spec=$P(Spec,"^",1)
	.s crmordent=$p($g(^DHCPEPreIADM(+CRMORI,"ORDITEM",$P(CRMORI,"||",2))),"^",2)
	.s arcos1="",OrdEntID=""
	.if crmordent'=""  d
	..s arcos1=##class(web.DHCPE.PEApp).GetArcSets(crmordent,arcItemId)
	..s OrdEntID=$G(^DHCPEDataEx("DHCPEPreIADM","OrdEnt",crmordent))
	..q:OrdEntID'=""
	..s ARCOS=$p($g(^DHCPEPreIADM(crmRegId,"ORDENT",$P(crmordent,"||",2))),"^",1)
	..&SQL(Insert into SQLUser.OE_OrdEnt (OEORN_OEORD_ParRef,OEORN_OrdSets_DR) values (:ordid,:ARCOS))
	..q:SQLCODE'=0
	..s OrdEntID=%ROWID
	..s ^DHCPEDataEx("DHCPEPreIADM","OrdEnt",crmordent)=OrdEntID
	.s PayedFlag=$p(^[..#ON]OEORD(+OOEOrdItem,"I",$p(OOEOrdItem,"||",2),3),"^",5)
	.s arRegArcID=""
	.s hisItem=arcItemId_"^"_Qty_"^"_NLoc_"^"_CurPrice_"^"_Spec_"^^"_arcos1_"^"_SttDate_"^"_PayedFlag_"^"_OrdEntID_"^"_PreGInfo_"^"_arRegArcID	
	.s ret=##class(web.DHCPE.PEApp).InsertOrdItem(admId, hisItem, userId,locId, userId)			
	.s SQLCODE=+ret
	.s:SQLCODE'=0 retStr="插入OE_OrdItem错误"_ret
	.q:SQLCODE'=0
	.s hisOItemId=$p(ret,"^",2)
	.s ^TempDHCPE("CRMOrderC2O2N",crmRegId,CRMORI)=OOEOrdItem_"^"_hisOItemId
	.s ^TempDHCPE("OEOrdItemO2N",OOEOrdItem)=hisOItemId
	.s ^TempDHCPE("OEOrdItemN2O",hisOItemId)=OOEOrdItem
	.;b ;DHCPE Insert OEORDItem Over
	.&sql(UPDATE sqluser.dhc_pe_crmorder set crmo_oeori_dr=:hisOItemId
		 where crmo_rowid=:CRMORowId)
	.;d ##class(RISService.InvokeRISService).InsertAppPACS(hisOItemId,"")
	.s OItemStatDR=$P(^[..#ON]OEORD(+OOEOrdItem,"I",$P(OOEOrdItem,"||",2),1),"^",13)
	.s OBilled=$P(^[..#ON]OEORD(+OOEOrdItem,"I",$P(OOEOrdItem,"||",2),3),"^",5)
	.s OLabEpisodeNo=$P(^[..#ON]OEORD(+OOEOrdItem,"I",$P(OOEOrdItem,"||",2),3),"^",20)
	.s $P(^OEORD(+hisOItemId,"I",$P(hisOItemId,"||",2),1),"^",13)=OItemStatDR
	.s $P(^OEORD(+hisOItemId,"I",$P(hisOItemId,"||",2),3),"^",5)=OBilled
	.q:OStatus'="ARRIVED"
	.s $P(^OEORD(+hisOItemId,"I",$P(hisOItemId,"||",2),3),"^",20)=OLabEpisodeNo
	.i OLabEpisodeNo'="" s ^OEORD(0,"EpisNo",OLabEpisodeNo,+hisOItemId,$P(hisOItemId,"||",2))=""
	i OStatus="REGISTERED" d
    .d ##class(DHCDoc.Interface.Inside.Service).GenPresno(NPAADM,userId,locId_"^")
	TC	
	q retStr
InsertItemsUpModeErr

	TRO
	s:retStr="" retStr=$ZE
	i $G(ordid)>0 k ^OEORD(ordid)
	q retStr
}

/// Creator:          JinLei
/// CreatDate:        2020-8-23
/// Description:      处理DHC_PE_GeneralSummarize,DHC_PE_GSDiagnosis
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).UpdateGeneralSummarize(16839,16964)
ClassMethod UpdateGeneralSummarize(PreIADM, NPAADM)
{
	s ret=""
	s IADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:IADM="" ""
	s OPAADM=$P(^[..#ON]DHCPEIADM(IADM),"^",1)
	s GSRowId=$O(^[..#ON]DHCPEGS(0,"IADM",IADM,0))
	
	i GSRowId'="" d
	.s OAuditUser=$P(^[..#ON]DHCPEGS(GSRowId,1),"^",5)
	.s $P(^DHCPEGS(GSRowId,1),"^",5)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OAuditUser)
	.s OUpdateUser=$P(^[..#ON]DHCPEGS(GSRowId,1),"^",3)
	.s $P(^DHCPEGS(GSRowId,1),"^",3)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUpdateUser)
	.s $P(^DHCPEGS(GSRowId,1),"^",8)=NPAADM
	.s Sub=0  f  s Sub=$O(^DHCPEGS(GSRowId,"Diagnosis",Sub))  q:Sub=""  d
	..s ODUpdateUser=$P(^[..#ON]DHCPEGS(GSRowId,"Diagnosis",Sub),"^",5)
	..s $P(^DHCPEGS(GSRowId,"Diagnosis",Sub),"^",5)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(ODUpdateUser)
	i GSRowId'="" d
	.;d ##class(User.DHCPEGeneralSummarize).%BuildIndices("",1,0,1,GSRowId,GSRowId,"")
	i $D(^[..#ON]DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",OPAADM)) d
	.m ^DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",NPAADM)=^[..#ON]DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",OPAADM)
	.s OMainUser=$P(^[..#ON]DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",OPAADM),"^",1)
	.s NMainUser=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OMainUser)
	.s $P(^DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",NPAADM),"^",1)=NMainUser
	.s ODate=$P(^[..#ON]DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",OPAADM),"^",2)
	.s OTime=$P(^[..#ON]DHCPEDataEx("DHCPEGeneralSummarize","MainDoctor",OPAADM),"^",3)
	.s ^DHCPEDataEx("DHCPEGeneralSummarize","MainDate",ODate,OTime,NPAADM)=NMainUser
	q ret
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      如PreIADM登记过，生成新PAADM
///  			      
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).GeneratePAADMByPreIADM(117)
ClassMethod UpdateIADM(PreIADM, NPAADM)
{
	s ret=""
	s IADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:IADM="" ""
	s OUserId=$P(^[..#ON]DHCPEIADM(IADM),"^",19)
	s $P(^DHCPEIADM(IADM),"^",1)=NPAADM
	s $P(^DHCPEIADM(IADM),"^",19)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	
	d ##class(User.DHCPEIADM).%BuildIndices("",1,0,1,IADM,IADM,"")
	
	q ret
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      如PreIADM登记过，生成新PAADM
///  			      
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).GeneratePAADMByPreIADM(117)
ClassMethod UpdateGADM(PreGADM, NPAADM)
{
	s ret=""
	s GADM=$O(^[..#ON]DHCPEGADM(0,"CRMGADM",PreGADM,0))
	q:GADM="" ""
	s OUserId=$P(^[..#ON]DHCPEGADM(GADM),"^",18)
	s $P(^DHCPEGADM(GADM),"^",3)=NPAADM
	s $P(^DHCPEGADM(GADM),"^",19)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserId)
	d ##class(User.DHCPEGADM).%BuildIndices("",1,0,1,GADM,GADM,"")
	q ret
}

/// Creator:          JinLei
/// CreatDate:        2020-8-24
/// Description:      如PreIADM登记过，生成新PAADM
///  			      
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).GeneratePAADMByPreIADM(117)
ClassMethod UpdatePreAudit(CRMADM, Type)
{
	s ret=""
	s PAFId=""
	s PAEId=""
	;s PARowId=""  f  s PARowId=$O(^[..#ON]DHCPEPreA(0,"CRMADM",Type,CRMADM,PARowId))  q:PARowId=""  d
	.;s:PAFId="" PAFId=PARowId
	.;s PAEId=PARowId
	.;s OPAADM=$P(^[..#ON]DHCPEPreA(PARowId),"^",3)
	.;s NPAADM=$G(^TempDHCPE("PAAdmO2N",OPAADM))
	.;s $P(^DHCPEPreA(PARowId),"^",3)=NPAADM
	;d ##class(User.DHCPEPreAudit).%BuildIndices("",1,0,1,PAFId,PAEId,"")

	q ret
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      DHC_PE_INVPRT
///  			      
/// Debugger:	w ##class(web.DHCPE.UpPrj.ModHBD).UpdateINVPRT(4099,748)
ClassMethod UpdateINVPRT(PreIADM, NPAADM)
{
	s FPRTROWID=""
	s EPRTROWID=""
	s ret=""
	s IADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:IADM="" ""
	s OPAADM=$P(^[..#ON]DHCPEIADM(IADM),"^",1)
	s PRTROWID=""  f  s PRTROWID=$O(^[..#ON]DHCPEINVPRT(0,"ADM",OPAADM,PRTROWID))  q:PRTROWID=""  d
	.s:FPRTROWID="" FPRTROWID=PRTROWID
	.s EPRTROWID=PRTROWID
	.s $P(^DHCPEINVPRT(PRTROWID),"^",2)=NPAADM
	.s OUser=$P(^[..#ON]DHCPEINVPRT(PRTROWID),"^",10)
	.s $P(^DHCPEINVPRT(PRTROWID),"^",10)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUser)
	.s ORpUser=$P(^[..#ON]DHCPEINVPRT(PRTROWID),"^",14)
	.s $P(^DHCPEINVPRT(PRTROWID),"^",14)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(ORpUser)
	.s $P(^DHCPEINVPRT(PRTROWID),"^",26)=..#Hospital
	.s RPRowId=$P(^DHCPEINVPRT(PRTROWID),"^",13)
	.
	.;日报最后单独处理
	;i +FPRTROWID>1  d ##class(User.DHCPEINVPRT).%BuildIndices("",1,0,1,FPRTROWID,EPRTROWID,"")
	q ret
}

/// Debugger:	w ##class(web.DHCPE.UpPrj.ModHBD).UpdateGINVPRT(49,753)
ClassMethod UpdateGINVPRT(PreGADM, NPAADM)
{
	s FPRTROWID=""
	s EPRTROWID=""
	s ret=""
	s GADM=$O(^[..#ON]DHCPEGADM(0,"CRMGADM",PreGADM,0))
	q:GADM="" ""
	s OPAADM=$P(^[..#ON]DHCPEGADM(GADM),"^",3)
	s PRTROWID=""  f  s PRTROWID=$O(^[..#ON]DHCPEINVPRT(0,"ADM",OPAADM,PRTROWID))  q:PRTROWID=""  d
	.s:FPRTROWID="" FPRTROWID=PRTROWID
	.s EPRTROWID=PRTROWID
	.s $P(^DHCPEINVPRT(PRTROWID),"^",2)=NPAADM
	.s OUser=$P(^[..#ON]DHCPEINVPRT(PRTROWID),"^",10)
	.s $P(^DHCPEINVPRT(PRTROWID),"^",10)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUser)
	.s ORpUser=$P(^[..#ON]DHCPEINVPRT(PRTROWID),"^",14)
	.s $P(^DHCPEINVPRT(PRTROWID),"^",14)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(ORpUser)
	.s $P(^DHCPEINVPRT(PRTROWID),"^",26)=..#Hospital
	.s RPRowId=$P(^DHCPEINVPRT(PRTROWID),"^",13)
	.
	.;日报最后单独处理
	;i +FPRTROWID>1  d ##class(User.DHCPEINVPRT).%BuildIndices("",1,0,1,FPRTROWID,EPRTROWID,"")
	q ret
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      如PreIADM登记过，生成新PAADM
///  			      
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).GeneratePAADMByPreIADM(117)
ClassMethod UpdateReport(PreIADM, NPAADM)
{
	s ret=""
	s IADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:IADM="" ""
	s RPTRowID=$O(^[..#ON]DHCPERPT(0,"IADM",IADM,0))
	
	s OAduitUser=$P(^[..#ON]DHCPERPT(RPTRowID),"^",4)
	s OCompleteUser=$P(^[..#ON]DHCPERPT(RPTRowID),"^",12)
	s OPrintUser=$P(^[..#ON]DHCPERPT(RPTRowID),"^",6)
	s OSendUser=$P(^[..#ON]DHCPERPT(RPTRowID),"^",8)
	
	s $P(^DHCPERPT(RPTRowID),"^",4)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OAduitUser)
	s $P(^DHCPERPT(RPTRowID),"^",12)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OCompleteUser)
	s $P(^DHCPERPT(RPTRowID),"^",6)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OPrintUser)
	s $P(^DHCPERPT(RPTRowID),"^",8)=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OSendUser)
	q ret
}

ClassMethod test(PAPMIDR)
{
	;w ##class(web.DHCPE.UpPrj.ModHBD).test(Num)
	// 取新库的
	set PatCatDr=$p($g(^PAPER(PAPMIDR,"PER",1)),"^",10)
 	i PatCatDr'="" set DHCPACADMDr=$o(^DHCPACADM(0,"Social",PatCatDr,""))
 	set AdmReason=""
 	if $g(DHCPACADMDr)'="" Do
 	.set AdmReason=$p(^DHCPACADM(DHCPACADMDr),"^",2)
 	b
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      处理医嘱记录
///  			      
/// Debugger:	d ##class(web.DHCPE.UpPrj.ModHBD).GenGroupPAADMByPreGADM(215)
ClassMethod GenGroupPAADMByPreGADM(PreGADM)
{
	s OGADM=$O(^[..#ON]DHCPEGADM(0,"CRMGADM",PreGADM,0))
	q:OGADM="" ""
	s OPAADM=$P(^[..#ON]DHCPEGADM(OGADM),"^",3)
	s NPAADM=""
	i $D(^DHCPEGADM(0,"CRMGADM",PreGADM)) d
	.s NGADM=$O(^DHCPEGADM(0,"CRMGADM",PreGADM,0))
	.s NPAADM=$P(^DHCPEGADM(NGADM),"^",3)
	q:((NPAADM'="")&(NPAADM'=OPAADM)) NPAADM
	s PAPMIDR=$P(^[..#ON]PAADM(OPAADM),"^",1)
	// 通过regno取新库的PAPMIDR
	s PAPMINo=$P($g(^[..#ON]PAPER(PAPMIDR,"PAT",1)),"^",1)
	s PAPMINoUP=$$ALPHAUP^SSUTIL4(PAPMINo)
	s NewPAPMIDR=$O(^PAPERi("PAPMI_PatNo",PAPMINoUP,0))

	s OLocId=$P(^[..#ON]PAADM(OPAADM),"^",4)
	s NLocId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(OLocId)
	q:+NLocId="-1" NLocId
	s OCreateUser=$P(^[..#ON]PAADM(OPAADM),"^",43)
	s NCreateUser=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OCreateUser)
	s OldFeeType=$G(^[..#ON]DHCPEDataEx("DHCPEPreGADM","ADMFeeType",PreGADM))
	s NewFeeType=OldFeeType
	s:NewFeeType="" NewFeeType=$P(^DHCPESetting("DHCPE","DefPatientType"),"^",1)
	
	s docId=$G(^DHCPESetting("DHCPE","PhyExamDrId",..#LocID))
	s OUserID=$p($g(^[..#ON]DHCPEPreGADM(PreGADM)),"^",19)
	s NUserID=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUserID)
	i NUserID'="" d
	.s IDOCID=$p($G(^SSU("SSUSR",NUserID)),"^",14)
	.i IDOCID'="" d
	..s CarPrvTpDR=$p($g(^CTPCP(IDOCID,1)),"^",4)
	..s CTCPTType=""
	..i CarPrvTpDR'="" s CTCPTType=$p($g(^CT("CPT",CarPrvTpDR)),"^",4)
	..i CTCPTType="DOCTOR" S docId=IDOCID
	s AdmType="H"
	s AdmDate=$P(^[..#ON]PAADM(OPAADM),"^",6)
	s AdmTime=$P(^[..#ON]PAADM(OPAADM),"^",7)
	s AdmReason=1
	s ParaString=NewPAPMIDR_"^"_AdmType_"^"_AdmDate_"^"_AdmTime_"^"_NLocId_"^"_docId_"^"_AdmReason_"^"_NCreateUser_"^^^^^2^^^^^^^^^"
 	S Re=##Class(web.DHCPAADM).ADMInsert(ParaString)
 	s ^TempDHCPE("PAAdmO2N",OPAADM)=Re
 	s ^TempDHCPE("PAAdmN2O",Re)=OPAADM
 	q Re
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      更新DHC_PE_Result的相关信息 
/// Input:            
/// Debugger:	w ##class(web.DHCPE.UpPrj.ModHBD).UpdateResult(4099,748)
ClassMethod UpdateResult(PreIADM, NPAADM)
{
	s Err=""
	s IADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:IADM="" ""
	s OPAADM=$P(^[..#ON]DHCPEIADM(IADM),"^",1)
	s RLTRowIdFId=""
	s RLTRowIdEId=""
	s RLTRowId=0   f  s RLTRowId=$O(^[..#ON]DHCPERLT(0,"ADM",OPAADM,RLTRowId))  q:RLTRowId=""  d
	.s:RLTRowIdFId="" RLTRowIdFId=RLTRowId
	.s RLTRowIdEId=RLTRowId
	.s OArcim=$P(^[..#ON]DHCPERLT(RLTRowId),"^",2)
	.s NArcim=##class(web.DHCPE.UpPrj.BaseInfo).GetNewArcim(OArcim,.ArcimCode)
	.i +NArcim="-1" s Err=$P(NArcim,"^",2)
	.q:Err'=""
	.s $P(^DHCPERLT(RLTRowId),"^",2)=NArcim
	.s Lab=0
	.s OUser=$P(^[..#ON]DHCPERLT(RLTRowId),"^",5)
	.q:OUser=""
	.i $D(^[..#LabON]SSU("SSUSR",1,OUser)) d
	..s Lab=1 ;是否是检验的
	.s NUserId=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUser,Lab)
	.i +NUserId="-1" s Err=$P(NUserId,"^",2)
	.q:Err'="" 
	.s $P(^DHCPERLT(RLTRowId),"^",5)=NUserId
	.s OOEORIDR=$P(^[..#ON]DHCPERLT(RLTRowId),"^",9)
	.s CRMORowId=$O(^[..#ON]DHCPECRMO(0,"OEORI",OOEORIDR,0)) //CRMO医嘱在新生成医嘱时更新过
	.s NOEORIDR=$P(^DHCPECRMO(CRMORowId),"^",1)
	.s $P(^DHCPERLT(RLTRowId),"^",9)=NOEORIDR
	.;b ;RLTRowId  NOEORIDR
	.s ShowSort=$P(^[..#ON]DHCPERLT(RLTRowId),"^",14)
	.s:ShowSort="" $P(^DHCPERLT(RLTRowId),"^",14)="999999999"
	.s $P(^DHCPERLT(RLTRowId),"^",1)=NPAADM
	.;w !,RLTRowId
	;d ##class(User.DHCPEResult).%BuildIndices("",1,0,1,RLTRowIdFId,RLTRowIdEId,"")
	q Err
}

/// Creator:          JinLei
/// CreatDate:        2020-8-22
/// Description:      更新DHC_PE_StationSummarize的相关信息 
/// Input:            
/// Debugger:	w ##class(web.DHCPE.UpPrj.ModHBD).UpdateStationSummarize(16839,"")
ClassMethod UpdateStationSummarize(PreIADM, NPAADM)
{
	s Err=""
	s IADM=$O(^[..#ON]DHCPEIADM(0,"CRMADM",PreIADM,0))
	q:IADM="" ""
	
	s FSSRowId=""
	s ESSRowId=""
	s ST=0  f  s ST=$O(^[..#ON]DHCPESS(0,"IADM",IADM,ST)) q:ST=""  d
	.s SSRowId=0  f  s SSRowId=$O(^[..#ON]DHCPESS(0,"IADM",IADM,ST,SSRowId)) q:SSRowId=""  d
	..s:FSSRowId="" FSSRowId=SSRowId
	..s ESSRowId=SSRowId
	..s OUpdateUser=$P(^[..#ON]DHCPESS(SSRowId,1),"^",4)	
	..s OAduitUser=$P(^[..#ON]DHCPESS(SSRowId,1),"^",5)	
	..s NUpdateUser=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OUpdateUser)
	..i +NUpdateUser="-1" s Err=$P(NUpdateUser,"^",2)
	..q:Err'="" 
	..s $P(^DHCPESS(SSRowId,1),"^",4)=NUpdateUser
	..s NAduitUser=##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId(OAduitUser)
	..i +NAduitUser="-1" s Err=$P(NAduitUser,"^",2)
	..q:Err'="" 
	..s $P(^DHCPESS(SSRowId,1),"^",5)=NAduitUser
	..i NPAADM'="" s $P(^DHCPESS(SSRowId,1),"^",8)=NPAADM
	
	;d ##class(User.DHCPEStationSummarize).%BuildIndices("",1,0,1,FSSRowId,ESSRowId,"")
	q Err
}

/// 设置诊断以及别名产生rowid使用的global
/// d ##class(web.DHCPE.UpPrj.ModHBD).SetHBDEXID()
ClassMethod SetHBDEXID()
{
	
	s ID=0
	&SQL(select max(PIBI_RowId) into :ID from DHC_PE_PreIBaseInfo)
	s ^mdata("DHCPEPREIBASEINFO")=ID
	w "DHC_PE_PreIBaseInfo:"_ID,!

	s ID=0
	&SQL(select max(PIADM_RowId) into :ID from DHC_PE_PreIADM)
	s ^mdata("DHCPEPREIADM")=ID
	w "DHC_PE_PreIADM:"_ID,!

	s ID=0
	&SQL(select max(IADM_RowId) into :ID from DHC_PE_IADM)
	s ^mdata("DHCPEIADM")=ID
	w "DHC_PE_IADM:"_ID,!

	s ID=0
	&SQL(select max(PGBI_RowId) into :ID from DHC_PE_PreGBaseInfo)
	s ^mdata("DHCPEPREGBASEINFO")=ID
	w "DHC_PE_PreGBaseInfo:"_ID,!
	
	s ID=0
	&SQL(select max(GBI_RowId) into :ID from DHC_PE_GBaseInfo)
	s ^mdata("DHCTJGBASEINFO")=ID
	w "DHC_PE_GBaseInfo:"_ID,!

	
	s ID=0
	&SQL(select max(PGADM_RowId) into :ID from DHC_PE_PreGADM)
	s ^mdata("DHCPEPREGADM")=ID
	w "DHC_PE_PreGADM:"_ID,!

	s ID=0
	&SQL(select max(GADM_RowId) into :ID from DHC_PE_GADM)
	s ^mdata("DHCPEGADM")=ID
	w "DHC_PE_GADM:"_ID,!
	
	s ID=0
	&SQL(select max(CRMO_RowId) into :ID from DHC_PE_CRMOrder)
	s ^mdata("DHCPECRMORDER")=ID
	w "DHC_PE_CRMOrder"_ID,!

	s ID=0
	&SQL(select max(RPT_RowId) into :ID from DHC_PE_Report)
	s ^mdata("DHCPEREPORT")=ID
	w "DHC_PE_Report:"_ID,!

	
	s ID=0
	&SQL(select max(AP_RowID) into :ID from DHC_PE_AdvancePayment)
	s ^mdata("DHCPEADVANCEPAYMENT")=ID ;
	w "DHC_PE_AdvancePayment:"_ID,!
		
	s ID=0
	&SQL(select max(GS_RowId) into :ID from DHC_PE_GeneralSummarize)
	s ^mdata("DHCPEGENERALSUMMARIZE")=ID ;
	w "DHC_PE_GeneralSummarize:"_ID,!
	
	s ID=0
	&SQL(select max(GGS_RowId) into :ID from DHC_PE_GGeneralSummarize)
	s ^mdata("DHCPEGGENERALSUMMARIZE")=ID ;
	w "DHC_PE_GGeneralSummarize:"_ID,!

	s ID=0
	&SQL(select max(GSDMR_RowID) into :ID from DHC_PE_GSDModifiedRecords)
	s ^mdata("DHCPEGSDM")=ID ;
	w "DHC_PE_GSDModifiedRecords:"_ID,!

	s ID=0
	&SQL(select max(PRT_ROWID) into :ID from DHC_PE_INVPRT)
	s ^mdata("DHCPEINVPRT")=ID
	w "DHC_PE_INVPRT:"_ID,!

	s ID=0
	&SQL(select max(PAPB_RowId) into :ID from DHC_PE_PAPBRelate)
	s ^mdata("DHCPEPAPBRELATE")=ID
	w "DHC_PE_PAPBRelate:"_ID,!

	s ID=0
	&SQL(select max(PA_RowId) into :ID from DHC_PE_PreAudit)
	s ^mdata("DHCPEPREAUDIT")=ID
	w "DHC_PE_PreAudit:"_ID,!


	s ID=0
	&SQL(select max(SS_RowId) into :ID from DHC_PE_StationSummarize)
	s ^mdata("DHCPESTATIONSUMMARIZE")=ID
	w "DHC_PE_StationSummarize:"_ID,!

	s ID=0
	&SQL(select max(RP_ROWID) into :ID from DHC_PE_USERREPORT)
	s ^mdata("DHCPEUSERREPORT")=ID
	w "DHC_PE_USERREPORT:"_ID,!
	
	s ID=0
	&SQL(select max(RLT_RowId) into :ID from DHC_PE_Result)
	b ;ID
	s ^mdata("DHCTJRESULT")=ID
	w "DHC_PE_Result:"_ID,!

	/*
	His设置
	s ^PAPER(0)=2000000
	s ^PAPER(0,"CNT","I")=2000000
	*/
}

Storage Default
{
<Data name="ModHBDDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.UpPrj.ModHBDD</DataLocation>
<DefaultData>ModHBDDefaultData</DefaultData>
<IdLocation>^web.DHCPE.UpPrj.ModHBDD</IdLocation>
<IndexLocation>^web.DHCPE.UpPrj.ModHBDI</IndexLocation>
<StreamLocation>^web.DHCPE.UpPrj.ModHBDS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
