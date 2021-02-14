Import SQLUser

Include webimport

IncludeGenerator webimport

/// 体检专用 Created by mlh2006-03-20
/// 
Class web.DHCPE.PEApp Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

Parameter BUILD = 1;

/// ClassMethod PEPAADMBroker(itmjs As %Library.String = "", itmjsex As %Library.String = "", pat As %Library.String = "", loc As %Library.String = "", doc As %Library.String = "", seqno As %Library.String = "", examfee As %Library.String = "", regfee As %Library.String = "", user As %Library.String = "", RegType As %Library.String = "", AppStatus As %Library.String = "", NappStatus As %Library.String = "")//at: 1  loc:577   doc1112    seqno3examfee4  regfee:5   user:10125Regtype:ÆÕÍ¨ºÅ  AppStatus:F   nappstatus:F
/// test: w ##Class(web.DHCPE.PEApp).PEPAADMBroker("","",100,577,1112,"",10125)
ClassMethod PEPAADMBroker(itmjs As %Library.String = "", itmjsex As %Library.String = "", pat As %Library.String = "", loc As %Library.String = "", doc As %Library.String = "", seqno As %Library.String = "", user As %Library.String = "", ADMFeeType As %Library.String = "")
{
	
 If $g(pat)="" quit 0
 If $g(loc)="" quit 0
 If $g(doc)="" quit 0
 If $g(user)="" quit 0
 
 set d=0
 Set Date=$ZD(+$H,3)
 Set Time=$ZT($p($H,",",2),3)
 ;
 Set PatientID=pat
 Set AdmDate=+$H
 Set AdmTime=$p($H,",",2)
 Set AdmDoc=doc
 Set AdmDep=loc 
 Set RefDoc=""
 Set RefDate="" 
 Set Payor=""
 Set Plan=""
 Set PayorOffice=""
 Set InsDateFrom=""
 Set InsDateTo="" 
 Set EpisodeID=""
 Set AdmType="H"		 //modified by mlh 原来是"O"-门诊，现在是"H"
 Set Bed=""
 Set P0=""
 Set P1="" 
 Set P2="" 
 Set P3="" 
 Set P4="" 
 Set P5=""
 Set AdmNo=$o(^PAADMi("No",""),-1)
 /*&SQL(Insert into SQLUser.PA_ADM
 (PAADM_ADMNo,PAADM_PAPMI_DR,PAADM_DepCode_DR,PAADM_AdmDate,PAADM_AdmTime,PAADM_TYPE,PAADM_AdmDocCodeDR,
 PAADM_CreateDate,PAADM_CreateTime,PAADM_CreateUser,PAADM_AdmReason_DR)
 values(:AdmNo,:PatientID,:AdmDep,:AdmDate,:AdmTime,:AdmType,:AdmDoc,:AdmDate,:AdmTime,:user,2))*/
 
 ;s ^bob("temp","TransCrm ADMInsert")=PatientID_" , "_AdmDate_" , "_AdmTime_" , "_AdmDoc_" , "_AdmDep_" , "_RefDoc_" , "_RefDate_" , "_Payor_" , "_Plan_" , "_PayorOffice_" , "_InsDateFrom_" , "_InsDateTo_" , "_EpisodeID_" , "_AdmType_" , "_Bed_" , "_" , , , , ,"
 ;b // before ADMInsert
 
 s ParaString=PatientID_"^"_AdmType_"^"_AdmDate_"^"_AdmTime_"^"_AdmDep_"^"_AdmDoc_"^^^^^^^^^^^^^^"
 Set Re=##Class(web.DHCPAADM).ADMInsert(ParaString)
 ;b // after ADMInsert
 
 //tstart
 set PatCatDr=$p($g(^PAPER(PatientID,"PER",1)),"^",10)
 i PatCatDr'="" set DHCPACADMDr=$o(^DHCPACADM(0,"Social",PatCatDr,""))
 set AdmReason=""
 if $g(DHCPACADMDr)'="" Do
 .set AdmReason=$p(^DHCPACADM(DHCPACADMDr),"^",2)

 If d=0 {
 //&SQL(Update SQLUser.PA_Adm Set PAAdm_CreateDate=:AdmDate,PAAdm_CreateTime=:AdmTime,PAAdm_CreateUser=:user,PAADM_AdmReason_DR=:AdmReason
 //       Where PAAdm_RowId=:Re)
      
  &SQL(Update SQLUser.PA_Adm Set PAAdm_CreateDate=:AdmDate,PAAdm_CreateTime=:AdmTime,PAAdm_CreateUser=:user,PAADM_AdmReason_DR=:AdmReason,PAADM_Epissubtype_DR=:ADMFeeType
        Where PAAdm_RowId=:Re)
	/*
 	s d=d+SQLCODE  
 	if d'=0{
	TRollback
	    s ^DHCApp(Re,"PA_Adm")="error"
    	s seqno="error"
 	}*/
 	 
 }
 ;
 //s v=^PAADM(0)//modified by mlh 后面程序没用到
 //2006-01-13 update
 //s PaInrowid=v_"||"_"1",refrowid=v
 s PaInrowid=Re_"||"_"1",refrowid=Re

 S Name=""
 s RegNo=""
 s Name=$p($g(^PAPER(PatientID,"ALL")),"^",1)
 s RegNo=$p($g(^PAPER(PatientID,"PAT",1)),"^",1)
 /*
 if d=0 {
 	TCommit
	}
	*/

 s retval=itmjs_"('"_$ZCVT(seqno,"O","JS")_"');"
 i itmjsex'="""" s retval=retval_itmjsex_"('"_$ZCVT(seqno,"O","JS")_"');"
 &javascript<#(retval)#>
 
 q Re
}

ClassMethod CommitPatDetail(itmjs As %Library.String = "", itmjsex As %Library.String = "", val As %Library.String = "")
{
 s (id,code,desc)=""
 ; Try and find a matching code
 ;取参数
 s IDpar=$ZCVT($p($g(val),"^",1),"U")
 s Namepar=$p($g(val),"^",2)
 s Sexpar=$p($g(val),"^",3)
 s Birthpar=$p($g(val),"^",4)
 s TelNopar=$p($g(val),"^",5)
 s OpMedicare=$p($g(val),"^",6)
 s InMedicare=$p($g(val),"^",7)
 s PatType=$p($g(val),"^",8)
 s IDCardNo1=$p($g(val),"^",9)
 s Vocation=$p($g(val),"^",10)
 s Company=$p($g(val),"^",11)
 s Address=$p($g(val),"^",12)
 
  //s SexDr=0           //Modified by MLH
  //s SexDr=$o(^CT("SEX",0,"Desc",Sexpar,SexDr))   //Modified by MLH
  s PatTypeDr=0
  s PatTypeDr=$o(^CT("SS",0,"Desc",$g(PatType),PatTypeDr))
  
  s Birthpar=$ZDH(Birthpar,3)
  //s =$p($g(val),"^",4)
  S IDrowid=0
  s IDrowid=$o(^PAPERi("PAPMI_PatNo",IDpar,IDrowid))
 //s ^DHCApp=Company_"^"_Address
 //&sql(update sqluser.pa_person set paper_name =:Namepar,
 //                                  paper_sex_dr =:SexDr,
 //                                  paper_dob =:Birthpar,
 //                                  paper_id=:IDCardNo1,
 //                                  paper_governcardno=:OpMedicare,
 //                                   paper_socialstatus_dr =:PatTypeDr,    
 //                                  paper_telh=:TelNopar,
 //                                  paper_secondphone=:Company
 //	where paper_rowid=:IDrowid)   
 
 Set Config=##Class(websys.Configuration).%OpenId(1)
 Set MEDDATA=Config.DataNamespace            
 Set LABDATA=Config.LabDataNamespace         
 Set CurrentNS=$ZNSPACE                     
 ZN MEDDATA              
 b //CommitPatDetail 071944444444 
 s ^lisatest("0720CommitPatDetail")=IDrowid_"^"_Namepar_"^"_Sexpar_"^"_Birthpar_"^"_IDCardNo1_"^"_OpMedicare_"^"_PatTypeDr_"^"_TelNopar_"^"_Company                  
 //d UpdatePatInfo^DHCOPUpdatePatInfo(IDrowid,Namepar,SexDr,Birthpar,IDCardNo1,OpMedicare,PatTypeDr,TelNopar,Company) 
 d UpdatePatInfo^DHCOPUpdatePatInfo(IDrowid,Namepar,Sexpar,Birthpar,IDCardNo1,OpMedicare,PatTypeDr,TelNopar,Company) //Modified by MLH 0720
 ZN CurrentNS  
  b //CommitPatDetail 07195555555 
 S ^PAPER(IDrowid,"PER","ADD",0)=1
 S ^PAPER(IDrowid,"PER","ADD",1)=Address
  b //CommitPatDetail 0719666666666 
 &sql(update sqluser.pa_patmas set papmi_medicare =:InMedicare
   	where papmi_no=:IDpar)
  ;
  
	 s retval=itmjs_"('"_$ZCVT(desc,"O","JS")_"');"
	 i itmjsex'="""" s retval=retval_itmjsex_"('"_$ZCVT(desc,"O","JS")_"^"_id_"^"_$ZCVT(code,"O","JS")_"');"
 	&javascript<#(retval)#>
	 q 1
 //}
}

/// add by jdl
/// Move From web.DHCOPCashier--->CashierInsertOrdItem
/// OrdItemStr
///      arcim^qty^recloc^price^specimen^admreason^arcos
///      w ##class(web.DHCPE.PEApp).InsertOrdItem(28967,"18124||1^1^1128^1171^^^",1,1128,1)
ClassMethod InsertOrdItem(Adm As %String, OrdItemStr As %String, User As %String, Loc As %String, DocUserId As %String) As %Status
{
	Set Config=##Class(websys.Configuration).%OpenId(1)
	Set MEDDATA=Config.DataNamespace
	Set LABDATA=Config.LabDataNamespace
	
	s locid=$P($G(^PAADM(Adm)),"^",4)
	
	s OrderInterface=$G(^DHCPESetting("DHCPE","OrderInterface",locid))
	i OrderInterface="Y"{
	q ..InsertOrdItemByInterface(Adm, OrdItemStr, User, locid, DocUserId,LABDATA)
	}
   
	if (OrderInterface'="Y"){
		
    //住院体检插入会诊费使用
	s ID=$o(^User.DHCPEOtherPatientToHPI("OTHPAADMDRIndex",Adm,0))
	i ID'=""{
	q ..InsertOrdItemByInterface(Adm, OrdItemStr, User, Loc, DocUserId,LABDATA)
	}
	
	Set CurrentNS=$ZNSPACE
	ZN MEDDATA		
	Set Ret=$$INSERT^DHCPEOrdItem(Adm,OrdItemStr,User,Loc,LABDATA,DocUserId)
	ZN CurrentNS
	QUIT Ret
    }
}

ClassMethod InsertOrdItemByInterface(Adm As %String, OrdItemStr As %String, User As %String, Loc As %String, DocUserId As %String, LABDATA As %String = "")
{
	//付费状态
	s PayedFlag=$P(OrdItemStr,"^",9)
	s arRegArcID=$P(OrdItemStr,"^",12)
	//是否预开状态
	s ordstatus=""
	;s ordstatus=$o(^OEC("OSTAT",0,"Code","V",""))
	s IADM=$O(^DHCPEIADM(0,"PAADM",Adm,0))
	i IADM'="" d
	.s ADMStatus=$P(^DHCPEIADM(IADM),"^",8)
	.i ADMStatus="REGISTERED" d
	..q:$G(^DHCPESetting("DHCPE","PreOrder",Loc))'="1"
	..s ordstatus=$o(^OEC("OSTAT",0,"Code","P",""))
	s:ordstatus="" ordstatus=$o(^OEC("OSTAT",0,"Code","V",""))
	
	
	s ArcIMID=$P(OrdItemStr,"^",1)
	s ItemCat=$P(^ARCIM(+ArcIMID,1,1),"^",10)
	//s OrderType=$P(^ARC("IC",ItemCat),"^",1)
	s OrderType=$P(^ARC("IC",ItemCat),"^",7)
	s ItemStr=ArcIMID_"^"_OrderType   //1,2
	
	Set priority=$o(^OECPR(0,"Code","NORM","")) //临时
	If priority="" Set priority=$o(^OECPR(0))
	
	s ItemStr=ItemStr_"^"_priority  //优先级，临时,3
	s SttDate=$P(OrdItemStr,"^",8)
	s:SttDate="" SttDate=+$H
	s:SttDate'="" SttDate=$ZD(SttDate,4)
	s ItemStr=ItemStr_"^"_$P(OrdItemStr,"^",8) //开始日期 ,4
	s ItemStr=ItemStr_"^"_$Zt($P($H,",",2)) //5
	s ItemStr=ItemStr_"^"_$P(OrdItemStr,"^",2) //数量，6
	s ItemStr=ItemStr_"^"_$P(OrdItemStr,"^",4) //价格，7
	s ItemStr=ItemStr_"^"_$P(OrdItemStr,"^",3) //接受科室，8
	s AdmReason=$P(^PAADM(Adm,1),"^",7)
	s:AdmReason="" AdmReason=$O(^PAC("ADMREA",0))
	s ItemStr=ItemStr_"^"_AdmReason  //费别，9
	s ItemStr=ItemStr_"^"_""  //药学关联项 10
	s ItemStr=ItemStr_"^"_$P(OrdItemStr,"^",10) //备注 团体信息 11
	s ItemStr=ItemStr_"^"_""  //单次剂量 12
	s ItemStr=ItemStr_"^"_""  //单次剂量单位 13
	s ItemStr=ItemStr_"^"_""  //基本单位总数量 14
	s ItemStr=ItemStr_"^"_""  //频次指针( 15
	s ItemStr=ItemStr_"^"_""  //疗程指针( 16
	s ItemStr=ItemStr_"^"_""  //用法指针( 17
	s ItemStr=ItemStr_"^"_""  //处方类型( 18
	s ItemStr=ItemStr_"^"_""  //关联的主医嘱序号，数字型 19
	s ItemStr=ItemStr_"^"_"1"  //医嘱序号，数字型 20
	s ItemStr=ItemStr_"^"_""  //是否皮试 21
	s ItemStr=ItemStr_"^"_""  //草药用法备注 22
	s ItemStr=ItemStr_"^"_""  //是否医保 23
	s ItemStr=ItemStr_"^"_""  //皮试备注 24
	s ItemStr=ItemStr_"^"_$P(OrdItemStr,"^",7) //医嘱套(ARC_OrdSets) 25
	s ItemStr=ItemStr_"^"_""  //预停日期(格式: DD/MM/YYYY) 26
	s ItemStr=ItemStr_"^"_""  //预停时间(格式: HH:MM) 27
	s ItemStr=ItemStr_"^"_$P(OrdItemStr,"^",5) //标本指针 28
	s $p(ItemStr,"^",60)= arRegArcID //申请记录子表
	Set doctor=""
	
	If $g(DocUserId)'="" d
	.Set doctor=$p(^SSU("SSUSR",DocUserId),"^",14)
	.i doctor'="" d
	..s CarPrvTpDR=$p($g(^CTPCP(doctor,1)),"^",4)
	..i CarPrvTpDR'="" s CTCPTType=$p($g(^CT("CPT",CarPrvTpDR)),"^",4)
	..i CTCPTType="DOCTOR" S doctor=doctor
	..E  S doctor=$G(^DHCPESetting("DHCPE","PhyExamDrId",Loc))
	i doctor="" s doctor=$G(^DHCPESetting("DHCPE","PhyExamDrId",Loc))

	s OrderInterfaceType=$G(^DHCPESetting("DHCPE","OrderInterfaceType",Loc))
	i OrderInterfaceType="M"{
		s ret=$$InsertMultiple^DHCDocOrderCommonNew(Adm,ItemStr,User,Loc,doctor,LABDATA,"^^N")
		q:ret=0 "-1"
		s oeitm=$P(ret,"*",2)
	}else{
		b ;ItemStr
		s ret=##class(web.DHCOEOrdItem).SaveOrderItems(Adm,ItemStr,User,Loc,doctor,"","^^N")
		q:ret=100 "-1"
		s oeitm=$P(ret,"*",2)
	}
	
	i ((ArcIMID'=$g(^DHCPESetting("DHCPE","InvDefaulltFee"))&&(ArcIMID'=$g(^DHCPESetting("DHCPE","RoundingFee"))))&&(arRegArcID'="")) d
	.S ^DHCPEDataEx("DHCPESendPACSApplay","OEORDID",oeitm)=arRegArcID

	
	//Set $p(^OEORD(+oeitm,"I",$p(oeitm,"||",2),3),"^",5)=PayedFlag
	Set:PayedFlag'="" $p(^OEORD(+oeitm,"I",$p(oeitm,"||",2),3),"^",5)=PayedFlag
	//登记状态的非收费账单医嘱设置为预开状态
	i ArcIMID'=$G(^DHCPESetting("DHCPE","Group'sOEArcItemId"))
	{
		s ordstatus=""
		;s ordstatus=$o(^OEC("OSTAT",0,"Code","V",""))
		s IADM=$O(^DHCPEIADM(0,"PAADM",Adm,0))
		i IADM'="" d
		.s ADMStatus=$P(^DHCPEIADM(IADM),"^",8)
		.i ADMStatus="REGISTERED" d
		..q:$G(^DHCPESetting("DHCPE","PreOrder",Loc))'="1"
		..s ordstatus=$o(^OEC("OSTAT",0,"Code","P",""))
		..q:ordstatus=""
		..&SQL(update sqluser.OE_OrdItem set OEORI_ItemStat_DR=:ordstatus where OEORI_RowID=:oeitm)
	
	}
	q "0^"_oeitm
}

ClassMethod CreatePrescNo(Adm As %String) As %Status
{
	s ^lisatest("0422","CreatePrescNo")=Adm
 	Do presno^aOET1(Adm)
 	;
 	Set Config=##Class(websys.Configuration).%OpenId(1)
 	Set MEDDATA=Config.DataNamespace
 	Set LABDATA=Config.LabDataNamespace
 	Set CurrentNS=$ZNSPACE
 	ZN MEDDATA
 	;Do presno^aOET1(Adm)
 	;Do SetLabNo^DHCPELabNo("78733","LABDATA")
 	//s ^lisatest("0519","DHCLabNo")=Adm
 	Do SetLabNo^DHCPELabNo(Adm,LABDATA)
	ZN CurrentNS
	QUIT 0
}

/// ##class(web.DHCPE.PEApp).GetArcSets(crmordent, arcItemId)
ClassMethod GetArcSets(crmordent, arcItemId)
{
	s arcos=""
	s TrakVerson=$G(^DHCPESetting("DHCPE","TrakVerison"))
	s LabStation=$G(^DHCPESetting("DHCPE","StationId_Lab"))
	i crmordent'=""  s arcos=$p($g(^DHCPEPreIADM($p(crmordent,"||",1),"ORDENT",$p(crmordent,"||",2))),"^",1)
	i TrakVerson="MedTrak"
	{
		s StationID=$o(^DHCPEST(0,"STORD_ARCIM",arcItemId,0))
		i LabStation=StationID
		{
			s Sub=$o(^DHCPEST(0,"STORD_ARCIM",arcItemId,StationID,0))
			s arcos=$p(^DHCPEST(StationID,"O",Sub),"^",3)
		}
		
	}
	q arcos
}

}
