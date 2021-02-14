Import SQLUser

/// 处理基础数据
Class web.DHCPE.UpPrj.BaseInfo Extends %Persistent
{

Parameter ON = "OLDDATA";

Parameter LocID = 341;

Parameter Hospital = 2;

Parameter UserID = 12166;

/// w ##class(web.DHCPE.UpPrj.BaseInfo).test()
ClassMethod test()
{
	s Str="deviceInfo=HIS窗口设备&fee=-45&flowId=21381120201227204605000020&hospitalId=2&operId=13811&outRefundNo=607&outTradeNo=03007030020201227102203679311323&reason=HIS主动退款&service=yuantu.wap.back.fee.user.cash&sourceCode=HIS&terminalNo=HIS&tradeTime=20201227204605"
	Set publicKey = "MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAJWsLsfeSXA++pfgFNzRm0jKu7csTNx4Xlmmjjvhmk9vLE/jVo/hsY3JcGaFmPQh4ZTizAyGDCszBLuhCqjOBDsw/wpCkSJod2+L56esv5kfvfQWI9wwfoe7cIjb7rg99qwUpaDZYX6YV98ijf1RibN6cwe8Ca25+L3LaJW3dBrJAgMBAAECgYBw3fglFpaQw51bnEp/Pr14BhHKjuijNU4JExWdSIKCNlbXI5uqQssPHgHZ/hMavtYK3YB8TTWt+fout8F/DGSZSxIbULan7f0/mVgvPYxqyfYTkedsn3vSWBkTsScsPkujKFOUTrPg6iZaNqhLb1t4D3VFkASMOWC+pvIm8W4Q9QJBAMdi7uWftWyVknuh7WAXX3jpVZE85L4aDGd0+TcirsqUTtzzPPbu14eFE9HzXG9gWDksAcDffaY5jWH2FbvKGVsCQQDAK6HdjGBeCB1ava7KeGmF7Dy4nTDGMnmee/QKfxDDLrj3M8RxdLYGfj6fCrkLCPut8lScnS1RDANnlV9GDHGrAkAcTx6uOZvPu/jdVuNWJltm1nJQub2chCRIuCH+Qw1gM+hylJKOWOD/G9TxlUUFhz9fdrEVCmZTqI47X248iHhLAkAtEY6Ml/150BliUJ4PqhHFcNQE0AjCUtAnFRb05zv9KpYCk8d8fEy8VRtGnXMsXVz5PJ4PZOVd3p1ly6hee0ilAkBp7iMTnAU//4ioYxZqqVgx0590znTcL+79+gkvsbFEHP+f0u8ajSTUwomnaw+961G3aH9Y082S+8+DKvkWJ+kw"
	Set Ciphertext=##class(%SYSTEM.Encryption).RSAEncrypt(Str,publicKey)
	Set Ciphertext=##class(%SYSTEM.Encryption).Base64Encode(Ciphertext)
	q Ciphertext
}

/// d ##class(web.DHCPE.Init).KillAllPEGlobal()
/// 1.100对应 d ##class(web.DHCPE.Temp).ExportBaseData("D:/DHCPEJL/")
/// 导入体检基础数据
/// w ##class(web.DHCPE.UpPrj.BaseInfo).ImportBaseData("CT",275,341)
ClassMethod ImportBaseData(ExGlobalName As %String = "CT", OldLocID, NewLocID)
{
	w !,"体检处理基础数据-start..."_$ZT($P($H,",",2))
	k ^DHCPECZOhMyGod("UnFindARCItmMast")
	k ^TempDHCPE("ARCItmMastO2N")
	w !,"mOldBaseData-start..."_$ZT($P($H,",",2))
	d ..mOldBaseData("CT", OldLocID, NewLocID)
	w !,"mOldBaseData-end"_$ZT($P($H,",",2))
	w !,"mOldPreData-start..."
	d ..mOldPreData()
	w !,"mOldPreData-end"_$ZT($P($H,",",2))
	d ##class(web.DHCPE.TempTools).SetEXID()
	w !,"验证ARC_ItmMast,SS_User,CT_Loc-start..."_$ZT($P($H,",",2))
	s hasnor= ..RelateArcimNew()
	d ##class(web.DHCPE.UpPrj.ModHBD).GenerateTest() 
	s UnFind=0
	i $D(^DHCPECZOhMyGod) d
	.w "有未对照内容"
	.d ..GenUnFindTxt()
	.s UnFind=1
	w !,"验证ARC_ItmMast,SS_User,CT_Loc-end"_$ZT($P($H,",",2))
	q:UnFind=1 "有未对照项目"
	d ..UpdateStationOrderNew()  
	&SQL(update sqluser.dhc_pe_ExpertDiagnosis set ED_StationLocID=1)
	&SQL(update sqluser.dhc_pe_ExpertDiagnosis set ED_StationLocID=null)
	//DHCPESetting
	&SQL(Update Sqluser.DHC_PE_EDLoc set EDL_Loc_DR=:NewLocID where EDL_Loc_DR=:OldLocID)
	d ..SetSetting(OldLocID,NewLocID,1)
	d ..ChartAssignSet()
	k ^DHCPEVIPLevel("PGT")
	w !,"计数器设置..."
	d ##class(web.DHCPE.UpPrj.ModHBD).SetHBDEXID()
	w !,"体检处理基础数据-end"_$ZT($P($H,",",2))
	q "Over"
}

/// 设置诊断以及别名产生rowid使用的global
/// d ##class(web.DHCPE.UpPrj.BaseInfo).SetBaseEXID()
ClassMethod SetBaseEXID()
{
	
	s ID=0
	&SQL(select max(ED_RowId) into :ID from DHC_PE_ExpertDiagnosis)
	s ^mdata("DHCPEEXPERTDIAGNOSIS")=ID
	w "DHC_PE_ExpertDiagnosis:"_ID,!

	s ID=0
	&SQL(select max(ILLS_RowId) into :ID from DHC_PE_IllnessStandard)
	s ^mdata("DHCPEILLNESSSTANDARD")=ID
	w "DHC_PE_IllnessStandard:"_ID,!


	s ID=0
	&SQL(select max(EDA_RowId) into :ID from DHC_PE_EDAlias)
	s ^mdata("DHCPEEDALIAS")=ID
	w "DHC_PE_EDAlias"_ID,!
	
	s ID=0
	&SQL(select max(IDR_RowId) into :ID from DHC_PE_IDRelate)
	s ^mdata("DHCPEIDRELATE")=ID
	w "DHC_PE_IDRelate"_ID,!
}

/// w ##class(web.DHCPE.UpPrj.BaseInfo).GenUnFindTxt()
ClassMethod GenUnFindTxt()
{
	s DirName="D:/DHCPEA/"
	s DirName=##class(web.DHCPE.IMPMenuAndCompont).Replace(DirName,"\","/")
 	s flag=##class(web.DHCPE.IMPMenuAndCompont).CreateDirectory(DirName)
	s f=##class(%File).%New(DirName_"DHCPEUnFindArcim.txt")
	d f.Open("WSN")
	s Code="" f  s Code=$O(^DHCPECZOhMyGod("UnFindARCItmMast",Code))  q:Code=""  d
	.s ArcimID=""  f  s ArcimID=$O(^DHCPECZOhMyGod("UnFindARCItmMast",Code,ArcimID))  q:ArcimID=""  d
	..s (ARCIMCode,ARCIMDesc,ALIASText)=""
	..s str=""
	..s ARCIMCode=$P($G(^[..#ON]ARCIM(+ArcimID,1,1)),"^",1)
	..s ARCIMDesc=$P($G(^[..#ON]ARCIM(+ArcimID,1,1)),"^",2)
	..s Desc=$$ALPHAUP^SSUTIL4(ARCIMDesc)
	..s ALIASText=##class(web.DHCINSUPort).GetCNCODE(Desc,"4")
	..s str=ARCIMCode_$C(9)_ARCIMDesc_$C(9)_ALIASText
	..d f.WriteLine(str)
	d f.Close()
	
	q 0
}

/// w ##class(web.DHCPE.UpPrj.BaseInfo).mOldBaseData("CT",275,341)
ClassMethod mOldBaseData(ExGlobalName As %String = "CT", OldLocID, NewLocID)
{
	s Job=$J 
	w Job
	s CurrRunPID=$I(^DHCPEDataEx("ModHBD"))
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","Start")=$ZD(+$H,3)_" "_$ZT($P($H,",",2)) _"mOldBaseData"
	
	m ^DHCPEED=^[..#ON]DHCPEED
	m ^DHCPEEDA=^[..#ON]DHCPEEDA
	m ^DHCPEEDC=^[..#ON]DHCPEEDC
	m ^DHCPEEDCR=^[..#ON]DHCPEEDCR
	
	m ^DHCPEIDR=^[..#ON]DHCPEIDR
	m ^DHCPEILLS=^[..#ON]DHCPEILLS
	m ^DHCPEILLSA=^[..#ON]DHCPEILLSA
	
	m ^DHCPEODR=^[..#ON]DHCPEODR
	m ^DHCPEOSE=^[..#ON]DHCPEOSE
	
	m ^DHCPEST=^[..#ON]DHCPEST
	
	m ^DHCPEVIPLevel=^[..#ON]DHCPEVIPLevel
	m ^DHCPESetting=^[..#ON]DHCPESetting
	
	m ^User.DHCPENetItemTypeD=^[..#ON]User.DHCPENetItemTypeD
	m ^User.DHCPENetItemTypeI=^[..#ON]User.DHCPENetItemTypeI
	m ^User.DHCPENetOrdSetsC=^[..#ON]User.DHCPENetOrdSetsC
	m ^User.DHCPENetOrdSetsD=^[..#ON]User.DHCPENetOrdSetsD
	m ^User.DHCPENetOrdSetsI=^[..#ON]User.DHCPENetOrdSetsI
	
	i ExGlobalName="CT"{
		;m ^DHCPECTDataEx=^[..#ON]DHCPEExportBaseData("DHCPEDataEx")
		m ^DHCPECTDataEx("DHCPEODStandard")=^[..#ON]DHCPEDataEx("DHCPEODStandard")
		m ^DHCPECTDataEx("BaseData")=^[..#ON]DHCPEDataEx("BaseData")
		m ^DHCPECTDataEx("DHCPEODStandard")=^[..#ON]DHCPEDataEx("DHCPEODStandard")
		m ^DHCPECTDataEx("DHCPEOrderDetail")=^[..#ON]DHCPEDataEx("DHCPEOrderDetail")
		m ^DHCPECTDataEx("DHCPEOrderDetailRelate")=^[..#ON]DHCPEDataEx("DHCPEOrderDetailRelate")
		m ^DHCPECTDataEx("PatItem")=^[..#ON]DHCPEDataEx("PatItem")
		m ^DHCPECTDataEx("PatItemSort")=^[..#ON]DHCPEDataEx("PatItemSort")
		m ^DHCPECTDataEx("PatItemSortOld")=^[..#ON]DHCPEDataEx("PatItemSortOld")
		m ^DHCPECTDataEx("ReportItem")=^[..#ON]DHCPEDataEx("ReportItem")
		m ^DHCPECTDataEx("ReportItemSort")=^[..#ON]DHCPEDataEx("ReportItemSort")
		m ^DHCPECTDataEx("SpecailItem")=^[..#ON]DHCPEDataEx("SpecailItem")
		m ^DHCPECTDataEx("RelatedItem")=^[..#ON]DHCPEDataEx("RelatedItem")
		m ^DHCPECTDataEx("SpecailItemIndex")=^[..#ON]DHCPEDataEx("SpecailItemIndex")
		m ^DHCPECTDataEx("DHCPEStation")=^[..#ON]DHCPEDataEx("DHCPEStation")
		m ^DHCPECTDataEx("DHCPEStationOrder")=^[..#ON]DHCPEDataEx("DHCPEStationOrder")
	}else{
		;m ^DHCPEDataEx=^DHCPEExportBaseData("DHCPEDataEx")
		m ^DHCPEDataEx("DHCPEODStandard")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEODStandard")
		m ^DHCPEDataEx("BaseData")=^DHCPEExportBaseData("DHCPEDataEx","BaseData")
		m ^DHCPEDataEx("DHCPEOrderDetail")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEOrderDetail")
		m ^DHCPEDataEx("DHCPEOrderDetailRelate")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEOrderDetailRelate")
		m ^DHCPEDataEx("PatItem")=^DHCPEExportBaseData("DHCPEDataEx","PatItem")
		m ^DHCPEDataEx("PatItemSort")=^DHCPEExportBaseData("DHCPEDataEx","PatItemSort")
		m ^DHCPEDataEx("PatItemSortOld")=^DHCPEExportBaseData("DHCPEDataEx","PatItemSortOld")
		m ^DHCPEDataEx("ReportItem")=^DHCPEExportBaseData("DHCPEDataEx","ReportItem")
		m ^DHCPEDataEx("ReportItemSort")=^DHCPEExportBaseData("DHCPEDataEx","ReportItemSort")
		m ^DHCPEDataEx("SpecailItem")=^DHCPEExportBaseData("DHCPEDataEx","SpecailItem")
		m ^DHCPEDataEx("SpecailItemIndex")=^DHCPEExportBaseData("DHCPEDataEx","SpecailItemIndex")
	}
	
	m ^User.DHCPEExpressD=^[..#ON]User.DHCPEExpressD
	m ^User.DHCPEExpressI=^[..#ON]User.DHCPEExpressI
	m ^User.DHCPENetItemTypeD=^[..#ON]User.DHCPENetItemTypeD
	m ^User.DHCPENetItemTypeI=^[..#ON]User.DHCPENetItemTypeI
	m ^User.DHCPENetOrdSetsD=^[..#ON]User.DHCPENetOrdSetsD
	m ^User.DHCPENetOrdSetsI=^[..#ON]User.DHCPENetOrdSetsI
	//体检号连续
	m ^DHCPEHPNoRecord("DHCPE","HPNoSort",NewLocID)=^[..#ON]DHCPEExportBaseData("DHCPE","HPNoSort",OldLocID)
	
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","end")=$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	q "OVER"
}

ClassMethod mOldPreData()
{
	s Job=$J 
	w Job
	s CurrRunPID=$I(^DHCPEDataEx("ModHBD"))
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","Start")=$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	m ^DHCPEPreIADM=^[..#ON]DHCPEPreIADM
	s ^DHCPEDataEx("ModHBD",CurrRunPID,"RunTime","end")=$ZD(+$H,3)_" "_$ZT($P($H,",",2))
	q "OVER"
}

/// 1.100对应 d ##class(web.DHCPE.Temp).ExportBaseData("D:/DHCPEJL/")
/// 导入体检基础数据
/// 需要跟新一些类方法  6、7、8、9、10
/// d ##class(web.DHCPE.UpPrj.BaseInfo).ImportBaseData("D:/DHCPEJL/","CT",275,341)
ClassMethod ImportBaseDataOld(DirName, ExGlobalName As %String = "CT", OldLocID, NewLocID)
{
	k ^DHCPECZOhMyGod("UnFindARCItmMast")
	s qspec=""
	s Errorlog=""
	s loadedlist=""
	;d ##class(web.DHCPE.Init).ExportBaseData(DirName_"BAK/")
	
	d ..DeleteOldData()
	b ;
	s OneDir=DirName_"Progress\GBL\"
	s recurse=1
	Do $system.OBJ.LoadDir(OneDir, .qspec, .Errorlog, recurse,.loadedlist)
	Do $system.OBJ.CompileList(loadedlist, .qspec,.Errorlog)
	
	d ..CopyBaseDataGlo(DirName, "CT", OldLocID, NewLocID)
	
	d ##class(web.DHCPE.TempTools).SetEXID()
	//需要跟新一些类方法  6、7、8、9、10
	s hasnor= ..RelateArcimNew()
	b ;a
	q:hasnor=1 "有未对照项目"
	d ..UpdateStationOrderNew()  
	&SQL(update sqluser.dhc_pe_ExpertDiagnosis set ED_StationLocID=1)
	&SQL(update sqluser.dhc_pe_ExpertDiagnosis set ED_StationLocID=null)
	//DHCPESetting
	&SQL(Update Sqluser.DHC_PE_EDLoc set EDL_Loc_DR=:NewLocID where EDL_Loc_DR=:OldLocID)
	d ..SetSetting(OldLocID,NewLocID,1)
	d ..ChartAssignSet()
	k ^DHCPEVIPLevel("PGT")
}

/// d ##class(web.DHCPE.UpPrj.BaseInfo).ChartAssignSet()
ClassMethod ChartAssignSet()
{
	m ^DHCPEDataEx("ChartAssign")=^[..#ON]DHCPEDataEx("ChartAssign")
	k ^DHCPECFDataEx("ChartAssign")
	s OUser=""  f  s OUser=$O(^DHCPEDataEx("ChartAssign",OUser))  q:OUser=""  d
	.s OLoc="" f  s OLoc=$O(^DHCPEDataEx("ChartAssign",OUser,OLoc))  q:OLoc=""  d
	..s OSSGroup=""  f  s OSSGroup=$O(^DHCPEDataEx("ChartAssign",OUser,OLoc,OSSGroup))  q:OSSGroup=""  d
	...s CData=$G(^DHCPEDataEx("ChartAssign",OUser,OLoc,OSSGroup))
	...s $P(CData,"^",1)=..GetNewUserId($P(CData,"^",1))
	...s NLoc=..GetNewLocId(OLoc)
	...s NUser=..GetNewUserId(OUser)
	...i OSSGroup=336 s NSSGroup=74 ;体检医生
	...q:OSSGroup=337 ;不处理总检
	...s ^DHCPECFDataEx("ChartAssign",NUser,NLoc,NSSGroup)=CData
	...s Type="" f  s Type=$O(^DHCPEDataEx("ChartAssign",OUser,OLoc,OSSGroup,Type)) q:Type=""  d
	....s Station=""  f  s Station=$O(^DHCPEDataEx("ChartAssign",OUser,OLoc,OSSGroup,Type,Station))  q:Station=""  d
	.....s ^DHCPECFDataEx("ChartAssign",NUser,NLoc,NSSGroup,Type,Station)=$G(^DHCPEDataEx("ChartAssign",OUser,OLoc,OSSGroup,Type,Station))
	
	;k ^DHCPEDataEx("ChartAssign")
}

ClassMethod DeleteOldData(ExGlobalName As %String = "CT")
{
	;删除以往数据
	k ^DHCPEED
	k ^DHCPEILLSA
	k ^DHCPEILLS
	k ^DHCPEIDR
	k ^DHCPEOSE
	k ^DHCPEODR
	k ^DHCPEST
	k ^User.DHCPENetItemTypeD
	k ^User.DHCPENetItemTypeI
	k ^User.DHCPENetOrdSetsC
	k ^User.DHCPENetOrdSetsD
	k ^User.DHCPENetOrdSetsI
	k ^DHCPEVIPLevel
	k ^DHCPEDataEX
	k ^DHCPEDataEx("DHCPEODStandard")
	k ^DHCPEDataEx("BaseData")
	k ^DHCPEDataEx("DHCPEOrderDetail")
	k ^DHCPEDataEx("DHCPEOrderDetailRelate")
	k ^DHCPEDataEx("PatItem")
	k ^DHCPEDataEx("PatItemSort")
	k ^DHCPEDataEx("PatItemSortOld")
	k ^DHCPEDataEx("ReportItem")
	k ^DHCPEDataEx("ReportItemSort")
	k ^DHCPEDataEx("SpecailItem")
	k ^DHCPEDataEx("SpecailItemIndex")
	k ^DHCPEHPNoRecord("DHCPE","HPNoSort")
}

ClassMethod CopyBaseDataGlo(DirName, ExGlobalName As %String = "CT", OldLocID, NewLocID)
{
	
	m ^DHCPEED=^DHCPEExportBaseData("DHCPEED")
	m ^DHCPEEDA=^DHCPEExportBaseData("DHCPEEDA")
	m ^DHCPEEDC=^DHCPEExportBaseData("DHCPEEDC")
	m ^DHCPEEDCR=^DHCPEExportBaseData("DHCPEEDCR")
	
	m ^DHCPEIDR=^DHCPEExportBaseData("DHCPEIDR")
	m ^DHCPEILLS=^DHCPEExportBaseData("DHCPEILLS")
	m ^DHCPEILLSA=^DHCPEExportBaseData("DHCPEILLSA")
	
	m ^DHCPEODR=^DHCPEExportBaseData("DHCPEODR")
	m ^DHCPEOSE=^DHCPEExportBaseData("DHCPEOSE")
	
	m ^DHCPEST=^DHCPEExportBaseData("DHCPEST")
	
	m ^DHCPEVIPLevel=^DHCPEExportBaseData("DHCPEVIPLevel")
	m ^DHCPESetting=^DHCPEExportBaseData("DHCPESetting")
	
	m ^User.DHCPENetItemTypeD=^DHCPEExportBaseData("User.DHCPENetItemTypeD")
	m ^User.DHCPENetItemTypeI=^DHCPEExportBaseData("User.DHCPENetItemTypeI")
	m ^User.DHCPENetOrdSetsC=^DHCPEExportBaseData("User.DHCPENetOrdSetsC")
	m ^User.DHCPENetOrdSetsD=^DHCPEExportBaseData("User.DHCPENetOrdSetsD")
	m ^User.DHCPENetOrdSetsI=^DHCPEExportBaseData("User.DHCPENetOrdSetsI")
	
	i ExGlobalName="CT"{
		m ^DHCPECTDataEx=^DHCPEExportBaseData("DHCPEDataEx")
		m ^DHCPECTDataEx("DHCPEODStandard")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEODStandard")
		m ^DHCPECTDataEx("BaseData")=^DHCPEExportBaseData("DHCPEDataEx","BaseData")
		m ^DHCPECTDataEx("DHCPEOrderDetail")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEOrderDetail")
		m ^DHCPECTDataEx("DHCPEOrderDetailRelate")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEOrderDetailRelate")
		m ^DHCPECTDataEx("PatItem")=^DHCPEExportBaseData("DHCPEDataEx","PatItem")
		m ^DHCPECTDataEx("PatItemSort")=^DHCPEExportBaseData("DHCPEDataEx","PatItemSort")
		m ^DHCPECTDataEx("PatItemSortOld")=^DHCPEExportBaseData("DHCPEDataEx","PatItemSortOld")
		m ^DHCPECTDataEx("ReportItem")=^DHCPEExportBaseData("DHCPEDataEx","ReportItem")
		m ^DHCPECTDataEx("ReportItemSort")=^DHCPEExportBaseData("DHCPEDataEx","ReportItemSort")
		m ^DHCPECTDataEx("SpecailItem")=^DHCPEExportBaseData("DHCPEDataEx","SpecailItem")
		m ^DHCPECTDataEx("SpecailItemIndex")=^DHCPEExportBaseData("DHCPEDataEx","SpecailItemIndex")
	}else{
		m ^DHCPEDataEx=^DHCPEExportBaseData("DHCPEDataEx")
		m ^DHCPEDataEx("DHCPEODStandard")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEODStandard")
		m ^DHCPEDataEx("BaseData")=^DHCPEExportBaseData("DHCPEDataEx","BaseData")
		m ^DHCPEDataEx("DHCPEOrderDetail")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEOrderDetail")
		m ^DHCPEDataEx("DHCPEOrderDetailRelate")=^DHCPEExportBaseData("DHCPEDataEx","DHCPEOrderDetailRelate")
		m ^DHCPEDataEx("PatItem")=^DHCPEExportBaseData("DHCPEDataEx","PatItem")
		m ^DHCPEDataEx("PatItemSort")=^DHCPEExportBaseData("DHCPEDataEx","PatItemSort")
		m ^DHCPEDataEx("PatItemSortOld")=^DHCPEExportBaseData("DHCPEDataEx","PatItemSortOld")
		m ^DHCPEDataEx("ReportItem")=^DHCPEExportBaseData("DHCPEDataEx","ReportItem")
		m ^DHCPEDataEx("ReportItemSort")=^DHCPEExportBaseData("DHCPEDataEx","ReportItemSort")
		m ^DHCPEDataEx("SpecailItem")=^DHCPEExportBaseData("DHCPEDataEx","SpecailItem")
		m ^DHCPEDataEx("SpecailItemIndex")=^DHCPEExportBaseData("DHCPEDataEx","SpecailItemIndex")
	}
	
	m ^User.DHCPEExpressD=^DHCPEExportBaseData("User.DHCPEExpressD")
	m ^User.DHCPEExpressI=^DHCPEExportBaseData("User.DHCPEExpressI")
	m ^User.DHCPENetItemTypeD=^DHCPEExportBaseData("User.DHCPENetItemTypeD")
	m ^User.DHCPENetItemTypeI=^DHCPEExportBaseData("User.DHCPENetItemTypeI")
	m ^User.DHCPENetOrdSetsD=^DHCPEExportBaseData("User.DHCPENetOrdSetsD")
	m ^User.DHCPENetOrdSetsI=^DHCPEExportBaseData("User.DHCPENetOrdSetsI")
	//体检号连续
	m ^DHCPEHPNoRecord("DHCPE","HPNoSort",NewLocID)=^DHCPEExportBaseData("DHCPE","HPNoSort",OldLocID)
}

/// 获取新老库的一些对应关系
ClassMethod RelateAll()
{
	//医嘱ARC_ItmMast
	//性别CT_Sex
	//婚姻CT_Marital
}

/// d ##class(web.DHCPE.UpPrj.BaseInfo).RelateArcimNew()
ClassMethod RelateArcimNew()
{
	k ^DHCPECZOhMyGod("UnFindARCItmMast")
	s HsFlag=0
	s ParARCIMDR=""
	f  s ParARCIMDR=$o(^[..#ON]DHCPEODR(0,"ARCIM",ParARCIMDR)) q:ParARCIMDR=""  d
	.s ArcimCode=""
	.s NewARCIMDR=..GetNewArcim(ParARCIMDR,.ArcimCode)
	.i +NewARCIMDR="-1" d
	..s HsFlag=1
	..w NewARCIMDR
	
	s STID=0
	f  s STID=$O(^[..#ON]DHCPEST(STID)) q:STID=""  d
	.s OSub=0
	.f  s OSub=$O(^[..#ON]DHCPEST(STID,"O",OSub)) q:OSub=""  d
	..s ARCIMID=$P(^[..#ON]DHCPEST(STID,"O",OSub),"^",1)
	..q:$D(^TempDHCPE("ARCItmMastO2N"))
	..s ArcimCode=""
	..s NewARCIMID=..GetNewArcim(ARCIMID,.ArcimCode)
	..i +NewARCIMID="-1" d
	...s HsFlag=1
	...w !,NewARCIMID
	q HsFlag
}

/// http://172.16.1.100:57772/dthealth/web/%25SOAP.WebServiceInvoke.cls?CLS=web.DHCPE.GetCodeCZ&OP=GetCode
/// http://172.16.1.100/dthealth/web/web.DHCPE.GetCode.cls
/// d ##class(web.DHCPE.UpPrj.BaseInfo).RelateArcim()
ClassMethod RelateArcim()
{
	k ^TempDHCPE
	s ParARCIMDR=""
	f  s ParARCIMDR=$o(^DHCPEODR(0,"ARCIM",ParARCIMDR)) q:ParARCIMDR=""  d
	.s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	.s Ret=obj.GetCode(ParARCIMDR,"")
	.s ARCIMCode=$P(Ret,"^",1)
	.s NewARCIMID=""
	.i ARCIMCode'="" d
	..s CodeIndex=$$ALPHAUP^SSUTIL4(ARCIMCode)
	..s NewARCIMID=$O(^ARCIM(0,"Code",CodeIndex,0))
	..q:NewARCIMID=""
	..s NewARCIMID=NewARCIMID_"||1"
	..i NewARCIMID="" d
	...s ^TempDHCPE("NoExist",ParARCIMDR)=ARCIMCode
	..e  d
	...s ^TempDHCPE("Exist",ParARCIMDR)=NewARCIMID
	
	s STID=0
	f  s STID=$O(^DHCPEST(STID)) q:STID=""  d
	.s OSub=0
	.f  s OSub=$O(^DHCPEST(STID,"O",OSub)) q:OSub=""  d
	..s ARCIMID=$P(^DHCPEST(STID,"O",OSub),"^",1)
	..q:$D(^TempDHCPE("Exist",ARCIMID))
	..s SetsID=$P(^DHCPEST(STID,"O",OSub),"^",3)
	..s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	..s Ret=obj.GetCode(ARCIMID,SetsID)
	..s ARCIMCode=$P(Ret,"^",1)
	..s SetsCode=$P(Ret,"^",2)
	..s NewARCIMID="",NewSetsID=""
	..i ARCIMCode'="" d
	...s CodeIndex=$$ALPHAUP^SSUTIL4(ARCIMCode)
	...s NewARCIMID=$O(^ARCIM(0,"Code",CodeIndex,0))
	...i NewARCIMID="" d
 	....s ^TempDHCPE("NoExist",ARCIMID)=ARCIMCode
	...e  d
	....s ^TempDHCPE("Exist",ARCIMID)=NewARCIMID_"||"_1
	
	i $D(^TempDHCPE("NoExist")) q 1
	e  q 0
}

/// http://172.16.1.100/dthealth/web/web.DHCPE.GetCode.cls
/// w ##class(web.DHCPE.UpPrj.BaseInfo).GetNewArcim("JY000108")
/// d ##class(User.DHCPEAdmRecordManager).%BuildIndices()
/// 关联医嘱
ClassMethod GetNewArcim(OArcim, ArcimCode)
{
	s NArcim=""
	i $D(^TempDHCPE("ARCItmMastO2N",OArcim)) d
	.s NArcim=$G(^TempDHCPE("ARCItmMastO2N",OArcim))
	e  d
	.;s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	.;s ArcimCode=obj.GetCode(OArcim,"")
	.s ArcimCode=..GetCodeByID(OArcim,"")
	.s:ArcimCode["^" ArcimCode=$P(ArcimCode,"^",1)
	.;b:ArcimCode="PE001" ;GetNewArcim
	.s:ArcimCode="" ^TempDHCPE("UnFindARCItmMastO2N",OArcim)=""
	.q:ArcimCode=""
	.s CodeIndex=$$ALPHAUP^SSUTIL4(ArcimCode)
	.i CodeIndex'="" d
	..s NewARCIMID=$O(^ARCIM(0,"Code",CodeIndex,0))
	..i NewARCIMID="" d
	...s ^TempDHCPE("UnFindARCItmMastO2N",OArcim)=""
	...s ^DHCPECZOhMyGod("UnFindARCItmMast",ArcimCode,OArcim)=""
	..e  d
	...s NArcim=NewARCIMID_"||"_1
	...s ^TempDHCPE("ARCItmMastO2N",OArcim)=NArcim
	q:NArcim="" "-1^ARC_ItmMast "_ArcimCode_" 未找到新RowId"
	q NArcim
}

/// http://172.16.1.100/dthealth/web/web.DHCPE.GetCode.cls
/// d ##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId()
/// d ##class(User.DHCPEAdmRecordManager).%BuildIndices()
/// 关联医嘱套
ClassMethod GetNewOrdEnt(OSetsId)
{
	 
	 //(UserRowid , ARCOSCode , ARCOSDesc , ARCOSCatID , ARCOSSubCatID , ARCOSEffectDate , ARCOSAlias , UserID , FavDepList , DocMedUnit , HospID , InString , LogonHospID)
	 //("","z8vzmt2","tj-升级测试","18","353","65614","SJCs","13414","341","","","1^Y^1^N^UN","2")
	 s UserRowid=""
	 s ARCOSCatID="18" //医嘱大类
	 s ARCOSSubCatID="353" //医嘱子类
	 s ARCOSCode=$P(^[..#ON]ARCOS(OSetsId),"^",1)
	 s ARCOSDesc=$P(^[..#ON]ARCOS(OSetsId),"^",2)
	 s ARCOSEffectDate=""
	 s ARCOSAlias=##class(web.DHCINSUPort).GetCNCODE(ARCOSDesc,4)
	 s UserID=..#UserID
	 s FavDepList=..#LocID
	 s DocMedUnit=""
	 s HospID=..#Hospital
	 s sex=$G(^[..#ON]DHCPEDataEx("DHCPEBaseData","Sex",OSetsId))  //web.DHCPE.DHCPEOrdSetsEx.cls
	 s NewSex=""
	 s:sex'="" NewSex=..GetNewSex(sex)
	 s InString="1^Y^"_NewSex_"^N^UN"  //VIPLevel + "^" + Break + "^" + Sex + "^" + Deit + "^" + PGBId;
	 s LogonHospID=..#Hospital
	 
	 s NSetsId=""
	 i $D(^TempDHCPE("ARCOrdSetsO2N",OSetsId)) d
	 .s NSetsId=$G(^TempDHCPE("ARCOrdSetsO2N",OSetsId))
	 e  d
	 .d ##Class(web.DHCPE.HISUIOrderSets).InsertUserARCOS(UserRowid , ARCOSCode , ARCOSDesc , ARCOSCatID , ARCOSSubCatID , ARCOSEffectDate , ARCOSAlias , UserID , FavDepList , DocMedUnit , HospID , InString , LogonHospID)
	 .s CodeIndex=$$ALPHAUP^SSUTIL4(ARCOSCode)
	 .s NSetsId=$O(^ARCOS(0,"Code",CodeIndex,""))
	 .q:NSetsId=""
	 .s ^TempDHCPE("ARCOrdSetsO2N",OSetsId)=NSetsId
		
	 q NSetsId
}

/// http://172.16.1.100/dthealth/web/web.DHCPE.GetCode.cls
/// d ##class(web.DHCPE.UpPrj.BaseInfo).GetNewUserId()
/// d ##class(User.DHCPEAdmRecordManager).%BuildIndices()
/// 关联User及医护
ClassMethod GetNewUserId(OUserId, LabFlag As %String = 0)
{
	q:OUserId="" ""
	s NUserId=""
	i $D(^TempDHCPE("SSUserO2N",OUserId)) d
	.s NUserId=$G(^TempDHCPE("SSUserO2N",OUserId))
	e  d
	.;s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	.;s UserCode=obj.GetUserCode(OUserId)
	.i LabFlag="0" d
	..s UserCode=$P(^[..#ON]SSU("SSUSR",OUserId),"^",1)
	.e  d
	..s UserCode=OUserId
	.q:UserCode=""
	.s:UserCode="" ^TempDHCPE("UnFindSSUserO2N",OUserId)=""
	.s CodeIndex=$$ALPHAUP^SSUTIL4(UserCode)
	.s NUserId=$O(^SSU("SSUSR",0,"SSUSR_Initials",CodeIndex,""))
	.i NUserId="" d
	..s ^TempDHCPE("UnFindSSUserO2N",OUserId)=""
	..s ^DHCPECZOhMyGod("UnFindSSUser",CodeIndex,OUserId)=""

	.e  s ^TempDHCPE("SSUserO2N",OUserId)=NUserId
	q:NUserId="" "-1^SSUser未找到新RowId"
	q NUserId
}

/// 关联User及医护
/// w ##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId(275)
ClassMethod GetNewLocId(OLocId)
{
	q:(OLocId="177") "373" ;普放
	q:(OLocId="42") "380" ;心电
	q:(OLocId="41") "355" ;超声
	q:(OLocId="40") "352" ;CT
	q:(OLocId="41") "355" ;B超
	q:(OLocId="40") "352" ;CT
	q:(OLocId="42") "380" ;心电
	q:(OLocId="82") "341" ;普外,已不存在此科室
	q:(OLocId="177") "373" ;普放
	q:(OLocId="184") "138" ;眼科四病区
	q:(OLocId="159") "137" ;眼科病区
	q:(OLocId="97") "318" ;眼科门诊
	q:(OLocId="152") "91" ;耳鼻喉病区
	q:(OLocId="107") "226" ;计划生育门诊
	q:(OLocId="181") "341" ;已不存在此科室
	q:(("^88^94^105^187^^^")[("^"_OLocId_"^")) "341"

	s NLocId=""
	i $D(^TempDHCPE("CTLocO2N",OLocId)) d
	.s NLocId=$G(^TempDHCPE("CTLocO2N",OLocId))
	e  d
	.;s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	.;s LocCode=obj.GetLocCode(OLocId)
	.s LocCode=$P(^[..#ON]CTLOC(OLocId),"^",1)
	.s:LocCode="" ^TempDHCPE("UnFindCTLocO2N",OLocId)=""
	.q:LocCode=""
	.s CodeIndex=$$ALPHAUP^SSUTIL4(LocCode)
	.s NLocId=$O(^CTLOC(0,"Code",CodeIndex,""))
	.i NLocId="" d
	..s ^TempDHCPE("UnFindCTLocO2N",OLocId)=""
	..s ^DHCPECZOhMyGod("UnFindCTLoc",CodeIndex,OLocId)=""
	.e  s ^TempDHCPE("CTLocO2N",OLocId)=NLocId
	q:NLocId="" "-1^CTLoc未找到新RowId"
	q NLocId
}

/// 关联User及医护
/// d ##class(web.DHCPE.UpPrj.BaseInfo).GetNewLocId()
ClassMethod GetNewSex(OSex)
{
	q OSex
}

ClassMethod UpdateRelate()
{
	s ParARCIMDR=""
	f  s ParARCIMDR=$O(^TempDHCPE("NoExist",ParARCIMDR)) q:ParARCIMDR=""  d
	.;&sql(Delete sqluser.DHC_PE_OrderDetailRelate where ODR_ARCIM_DR=:ParARCIMDR)
	s ParARCIMDR=""
	f  s ParARCIMDR=$O(^TempDHCPE("Exist",ParARCIMDR)) q:ParARCIMDR=""  d
	.s NewARCIMID=$G(^TempDHCPE("Exist",ParARCIMDR))
	.&sql(update sqluser.DHC_PE_OrderDetailRelate set ODR_ARCIM_DR=:NewARCIMID where ODR_ARCIM_DR=:ParARCIMDR)
	
	s STID=0
	f  s STID=$O(^DHCPEST(STID)) q:STID=""  d
	.s OSub=0
	.f  s OSub=$O(^DHCPEST(STID,"O",OSub)) q:OSub=""  d
	..s ARCIMID=$P(^DHCPEST(STID,"O",OSub),"^",1)
	..s NewARCIMID=$G(^TempDHCPE("Exist",ARCIMID))
	..s ODRowID=STID_"||"_OSub
	..s SetsID=$P(^DHCPEST(STID,"O",OSub),"^",3)
	..s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	..s Ret=obj.GetCode(ARCIMID,SetsID)
	..s ARCIMCode=$P(Ret,"^",1)
	..s SetsCode=$P(Ret,"^",2)
	..i SetsCode'="" d
	...s CodeIndex=$$ALPHAUP^SSUTIL4(SetsCode)
	...s NewSetsID=$O(^ARCOS(0,"Code",CodeIndex,0))
	..&SQL(Update sqluser.DHC_PE_StationOrder set STORD_ARCIM_DR=:NewARCIMID,STORD_ARCOS_DR=:NewSetsID where STORD_RowId=:ODRowID)
}

ClassMethod GetCodeByID(ARCIMID, SetsID)
{
	s ^TMPDHCPE("GetCodeByID")=$LB(ARCIMID, SetsID)
	s ARCCode="",SetsCode=""
	s:ARCIMID'="" ARCCode=$P($G(^[..#ON]ARCIM(+ARCIMID,1,1)),"^",1)
	s:SetsID'="" SetsCode=$P($G(^[..#ON]ARCOS(+SetsID)),"^",1)
	q ARCCode_"^"_SetsCode
}

/// d ##class(web.DHCPE.UpPrj.BaseInfo).PatItemSetting()
ClassMethod PatItemSetting()
{
	
	k ^DHCPECTDataEx("PatItemSort")
	s ArcimId=""
	f  s ArcimId=$O(^[..#ON]DHCPEDataEx("PatItemSort",ArcimId)) q:ArcimId=""  d
	.s NewArcimId=..GetNewArcim(ArcimId)
	.i +NewArcimId'="-1" d
	..s ^DHCPECTDataEx("PatItemSort",NewArcimId)=$G(^[..#ON]DHCPEDataEx("PatItemSort",ArcimId))
	
	s PatItem=0
	f  s PatItem=$O(^[..#ON]DHCPEDataEx("PatItem",PatItem)) q:PatItem=""  d
	.s ^DHCPECTDataEx("PatItem",PatItem)=$G(^[..#ON]DHCPEDataEx("PatItem",PatItem))
	.s ^DHCPECTDataEx("PatItem",PatItem,"Place",..#LocID)=$G(^[..#ON]DHCPEDataEx("PatItem",PatItem,"Place",275))
	.k ^DHCPEDataEx("PatItem")
	q 0
}

ClassMethod SetSetting(SourceLocID, ToLocID, killFlag As %String = "0")
{
	q:(SourceLocID="")||(ToLocID="") "科室不能为空"
	s SQLCODE=0
	//Setting设置
	s Node1=""
	f  s Node1=$O(^DHCPESetting(Node1)) q:Node1=""  d
	.s Node2=""
	.f  s Node2=$O(^DHCPESetting(Node1,Node2)) q:Node2=""  d
	..s Node3=""
	..f  s Node3=$O(^DHCPESetting(Node1,Node2,Node3)) q:Node3=""  d
	...q:Node3'=SourceLocID
	...i $D(^DHCPESetting(Node1,Node2,ToLocID))=1 d
	....s ^DHCPESetting(Node1,Node2,ToLocID)=^DHCPESetting(Node1,Node2,Node3)
	...k:killFlag=1 ^DHCPESetting(Node1,Node2,Node3)
	
	s ^DHCPESetting("DHCPE","DefaultPAADM",ToLocID)=1
	d ..PatItemSetting()
}

ClassMethod UpdateStationOrderNew()
{
	//更新大项和细项关联

	s ParARCIMDR=""
	f  s ParARCIMDR=$O(^TempDHCPE("ARCItmMastO2N",ParARCIMDR)) q:ParARCIMDR=""  d
	.s NewARCIMID=$G(^TempDHCPE("ARCItmMastO2N",ParARCIMDR))
	.&sql(update sqluser.DHC_PE_OrderDetailRelate set ODR_ARCIM_DR=:NewARCIMID where ODR_ARCIM_DR=:ParARCIMDR)
	
	//更新大项
	s STID=0
	f  s STID=$O(^[..#ON]DHCPEST(STID)) q:STID=""  d
	.s OSub=0
	.f  s OSub=$O(^[..#ON]DHCPEST(STID,"O",OSub)) q:OSub=""  d
	..s ARCIMID=$P(^[..#ON]DHCPEST(STID,"O",OSub),"^",1)
	..q:ARCIMID=""
	..s NewARCIMID=..GetNewArcim(ARCIMID)		;$G(^TempDHCPE("ARCItmMastO2N",ARCIMID))
	..s NewSetsID=""
	..s SetsID=$P(^[..#ON]DHCPEST(STID,"O",OSub),"^",3)
	..i SetsID'="" d
	...s NewSetsID=..GetNewOrdEnt(SetsID)
	..s ODRowID=STID_"||"_OSub
	..i +NewARCIMID="-1" d
	...b ;a
	...w !,NewARCIMID
	..e  d
	...&SQL(Update sqluser.DHC_PE_StationOrder set STORD_ARCIM_DR=:NewARCIMID,STORD_ARCOS_DR=:NewSetsID where STORD_RowId=:ODRowID)
}

ClassMethod UpdateStationOrder()
{
	s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	k ^TempDHCPEUpdateStationOrder
	m ^TempDHCPEUpdateStationOrder=^DHCPESetting("DHCPEBaseData","PEARCOS")
	k ^DHCPESetting("DHCPEBaseData","PEARCOS")
	s SetID=""
	f  s SetID=$O(^TempDHCPEUpdateStationOrder(SetID)) q:SetID=""  d
	.s SetCode=obj.GetCode("",SetID)
	.q:SetCode=""
	.s Info=^TempDHCPEUpdateStationOrder(SetID)
	.;k ^DHCPESetting("DHCPEBaseData","PEARCOS",SetID)
	.s CodeIndex=$$ALPHAUP^SSUTIL4(SetCode)
	.s NewSetsID=$O(^ARCOS(0,"Code",CodeIndex,0))
	.q:NewSetsID=""
	.s ^DHCPESetting("DHCPEBaseData","PEARCOS",NewSetsID)=Info
	
	k ^TempDHCPEUpdateStationOrder
	m ^TempDHCPEUpdateStationOrder=^DHCPEItemSort("Sort","Set")
	k ^DHCPEItemSort("Set")
	k ^DHCPEItemSort("Sort","Set")
	s SetID=""
	f  s SetID=$O(^TempDHCPEUpdateStationOrder("Sort","Set",SetID)) q:SetID=""  d
	.s SetCode=obj.GetCode("",SetID)
	.s SetCode=$P(SetCode,"^",2)
	.s SortInfo=$G(^TempDHCPEUpdateStationOrder("Sort","Set",SetID))
	.s Sort=$P(SortInfo,"^",1)
	.s SortIndex=$P(SortInfo,"^",2)
	.i SetCode'="" d
	..s CodeIndex=$$ALPHAUP^SSUTIL4(SetCode)
	..s NewSetsID=$O(^ARCOS(0,"Code",CodeIndex,0))
	..q:NewSetsID=""
	..s ^DHCPEItemSort("Sort","Set",NewSetsID)=SortInfo
	..i (Sort'="")&&(SortIndex'="") d
	...s ^DHCPEItemSort("Set",Sort,SortIndex)=NewSetsID
	
	k ^TempDHCPEUpdateStationOrder
	m ^TempDHCPEUpdateStationOrder=^DHCPEItemSort("Sort","Item")
	k ^DHCPEItemSort("Item")
	k ^DHCPEItemSort("Sort","Item")
	s SetID=""
	f  s SetID=$O(^TempDHCPEUpdateStationOrder("Sort","Item",SetID)) q:SetID=""  d
	.s SetCode=obj.GetCode(SetID,"")
	.s SetCode=$P(SetCode,"^",1)
	.s SortInfo=$G(^TempDHCPEUpdateStationOrder("Sort","Item",SetID))
	.s Sort=$P(SortInfo,"^",1)
	.s SortIndex=$P(SortInfo,"^",2)
	.i SetCode'="" d
	..s CodeIndex=$$ALPHAUP^SSUTIL4(SetCode)
	..s NewSetsID=$O(^ARCIM(0,"Code",CodeIndex,0))
	..q:NewSetsID=""
	..s NewSetsID=NewSetsID_"||1"
	..s ^DHCPEItemSort("Sort","Item",NewSetsID)=SortInfo
	..i (Sort'="")&&(SortIndex'="") d
	...s ^DHCPEItemSort("Item",Sort,SortIndex)=NewSetsID
	k ^TempDHCPEUpdateStationOrder
	
	//更新大项和细项关联
	;k ^TempDHCPE
	s ParARCIMDR=""
	f  s ParARCIMDR=$o(^DHCPEODR(0,"ARCIM",ParARCIMDR)) q:ParARCIMDR=""  d
	.s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	.s Ret=obj.GetCode(ParARCIMDR,"")
	.s ARCIMCode=$P(Ret,"^",1)
	.;w ARCIMCode,!
	.s NewARCIMID=""
	.i ARCIMCode'="" d
	..s CodeIndex=$$ALPHAUP^SSUTIL4(ARCIMCode)
	..s NewARCIMID=$O(^ARCIM(0,"Code",CodeIndex,0))
	..q:NewARCIMID=""
	..s NewARCIMID=NewARCIMID_"||1"
	.i NewARCIMID="" d
	..s ^TempDHCPE("NoExist",ParARCIMDR)=""
	.e  d
	..s ^TempDHCPE("Exist",ParARCIMDR)=NewARCIMID
	s ParARCIMDR=""
	f  s ParARCIMDR=$O(^TempDHCPE("NoExist",ParARCIMDR)) q:ParARCIMDR=""  d
	.;&sql(Delete sqluser.DHC_PE_OrderDetailRelate where ODR_ARCIM_DR=:ParARCIMDR)
	s ParARCIMDR=""
	f  s ParARCIMDR=$O(^TempDHCPE("Exist",ParARCIMDR)) q:ParARCIMDR=""  d
	.s NewARCIMID=$G(^TempDHCPE("Exist",ParARCIMDR))
	.&sql(update sqluser.DHC_PE_OrderDetailRelate set ODR_ARCIM_DR=:NewARCIMID where ODR_ARCIM_DR=:ParARCIMDR)
	;k ^TempDHCPE
	//更新大项
	s STID=0
	f  s STID=$O(^DHCPEST(STID)) q:STID=""  d
	.s OSub=0
	.f  s OSub=$O(^DHCPEST(STID,"O",OSub)) q:OSub=""  d
	..s ARCIMID=$P(^DHCPEST(STID,"O",OSub),"^",1)
	..s SetsID=$P(^DHCPEST(STID,"O",OSub),"^",3)
	..s obj=##class(web.DHCPE.UpPrj.GetCodeSoap).%New()
	..s Ret=obj.GetCode(ARCIMID,SetsID)
	..s ARCIMCode=$P(Ret,"^",1)
	..s SetsCode=$P(Ret,"^",2)
	..s NewARCIMID="",NewSetsID=""
	..i ARCIMCode'="" d
	...s CodeIndex=$$ALPHAUP^SSUTIL4(ARCIMCode)
	...s NewARCIMID=$O(^ARCIM(0,"Code",CodeIndex,0))
	...;w:NewARCIMID="" "ARC:"_ARCIMCode,!
	...q:NewARCIMID=""
	...s NewARCIMID=NewARCIMID_"||1"
	..i SetsCode'="" d
	...s CodeIndex=$$ALPHAUP^SSUTIL4(SetsCode)
	...s NewSetsID=$O(^ARCOS(0,"Code",CodeIndex,0))
	...;w:NewSetsID="" "Sets:"_SetsCode,!
	..s ODRowID=STID_"||"_OSub
	..&SQL(Update sqluser.DHC_PE_StationOrder set STORD_ARCIM_DR=:NewARCIMID,STORD_ARCOS_DR=:NewSetsID where STORD_RowId=:ODRowID)
}

Storage Default
{
<Data name="BaseInfoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.UpPrj.BaseInfoD</DataLocation>
<DefaultData>BaseInfoDefaultData</DefaultData>
<IdLocation>^web.DHCPE.UpPrj.BaseInfoD</IdLocation>
<IndexLocation>^web.DHCPE.UpPrj.BaseInfoI</IndexLocation>
<StreamLocation>^web.DHCPE.UpPrj.BaseInfoS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
