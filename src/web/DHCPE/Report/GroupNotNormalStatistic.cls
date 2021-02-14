/// zhouli
///  团体人员异常值统计
/// 组件：
Class web.DHCPE.Report.GroupNotNormalStatistic Extends (%Library.RegisteredObject, websys.Abstract) [ ClassType = "", Inheritance = right, Not ProcedureBlock ]
{

Parameter BUILD = 472;

//d ##class(web.DHCPE.Report.GroupNotNormalStatistic).GetIADM("28")

ClassMethod GetIADM(GADM)
{
    
   Q:GADM=""
   k ^DHCPETMP("Position")
   k ^DHCPETMP("IADMRowId","ODRowId")
   k ^DHCPETMP("NotNromal","Num")
   k ^DHCPETMP("NotNromalength")
   s GBIDR=$p(^DHCPEGADM(GADM),"^",1)
   s GDesc=$p(^DHCPEGBI(GBIDR),"^",2)
   
   s GDesc=GDesc_"体检异常统计"
   s ^DHCPETMP("GDesc")=GDesc
   s iLoop=1 
   s GTeamDR=0
   f  s GTeamDR=$o(^DHCPEIADM(0,"GADM",GADM,GTeamDR))  q:GTeamDR=""  d
   .
   .s IADMRowId=0
   .f  s IADMRowId=$o(^DHCPEIADM(0,"GADM",GADM,GTeamDR,IADMRowId))  q:IADMRowId=""  d
   ..
   ..s PIADMRowId=$p(^DHCPEIADM(IADMRowId),"^",4)
   ..s ADM=$p(^DHCPEIADM(IADMRowId),"^",1)
   ..s PIBIDR=""
   ..i PIADMRowId'=""  s PIBIDR=$p($g(^DHCPEPreIADM(PIADMRowId)),"^",1)
   ..Q:PIBIDR=""
   ..s PAPMINo=$p(^DHCPEPreIBI(PIBIDR),"^",1)
   ..s Name=$p(^DHCPEPreIBI(PIBIDR),"^",2)
   ..i Name="" s Name="无姓名"
   ..s Position=$p(^DHCPEPreIBI(PIBIDR),"^",11)
   ..i Position=""  s Position="无部门"
   ..s Seqflag=1
   ..i Position="无部门" s Seqflag=2
   ..s ^DHCPETMP("Position",Seqflag,Position,iLoop)=IADMRowId
   ..s iLoop=iLoop+1
   .. 
   ..
   ..s RLTRowId=0
   ..Q:ADM=""
   ..s num=0
   ..s tmpItem=0
   ..f  s RLTRowId=$o(^DHCPERLT(0,"ADM",ADM,RLTRowId))   Q:(RLTRowId="")  d
   ...s ItmMastDR=$P(^DHCPERLT(RLTRowId), "^", 2)
   ...s STID=$o(^DHCPEST(0,"STORD_ARCIM",ItmMastDR,0))
   ...s Subscript=$p(ItmMastDR,"||",1)
   ...s Version=$p(ItmMastDR,"||",2)
   ...s ItmMastDesc=$p($g(^ARCIM(Subscript,Version,1)),"^",2)
   ...s Normal=$p($g(^DHCPERLT(RLTRowId)), "^", 7)
   ...Q:Normal="1"
   ...s Result=$P($g(^DHCPERLT(RLTRowId)), "^", 4)
   ...s ODRowId=""
   ...s ODRowId=$p($g(^DHCPERLT(RLTRowId)),"^",3)
   ...q:ODRowId=""     
   ...s STRowId=$p(ODRowId,"||",1)			//站点编码
   ...s ODChildSub=$p(ODRowId,"||",2)		    
   ...s ODDesc=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",1)	//细项名称	DHC_PE_OrderDetail.{ OD_Desc }
   ...s TNormalRange=""
   ...s TNormalRange=##class(web.DHCPE.ResultEdit).GetNormal(ODRowId,"M","17")
   ...s OEOrder=0
   ...f  s OEOrder=$o(^OEORD(0,"Adm",ADM,OEOrder))  Q:(OEOrder="")  d
   ....s OEORISttDat=0
   ....f  s OEORISttDat=$o(^OEORDi(0,"ARCIM",OEOrder,ItmMastDR,OEORISttDat)) Q:(OEORISttDat="")  d
   .....s childsub=0
   .....f  s childsub=$o(^OEORDi(0,"ARCIM",OEOrder,ItmMastDR,OEORISttDat,childsub)) Q:(childsub="")  d 
   ......s OEOrdItemID=OEOrder_"||"_childsub
   ......i ("^"_^DHCPESetting("DHCPE","StationId_Ris")_"^")'[("^"_STID_"^")  s Abnormity=ODDesc_":"_Result
   ......e  s Abnormity=Result
   ......i (("^"_^DHCPESetting("DHCPE","StationId_Ris")_"^")[("^"_STID_"^"))&(Abnormity="")  s Abnormity=$G(^DHCPETempResult(OEOrdItemID))
   ......Q:Position=""
   ......//s ^DHCPETMP("IADMRowId","ODRowId",IADMRowId,ItmMastDR,ODRowId)=Abnormity_"^"_TNormalRange_"^"_Name
   ......s ^DHCPETMP("NotNromal","Num",Position,IADMRowId,ItmMastDR)=1+$g(^DHCPETMP("NotNromal","Num",Position,IADMRowId,ItmMastDR))
   ......s ^DHCPETMP("IADMRowId","ODRowId",IADMRowId,ItmMastDR,^DHCPETMP("NotNromal","Num",Position,IADMRowId,ItmMastDR))=Abnormity_"^"_TNormalRange_"^"_Name_"^"_ODRowId
   ......s ^DHCPETMP("NotNromalength",IADMRowId,num)=Abnormity_"^"_TNormalRange
   ......s num=num+1
  
  
 
   
  
   s iLoop=0
   s str=""
   s GDesc=$G(^DHCPETMP("GDesc"))
   s TName="姓名",TPosition="部门",TNotNormal="不正常值",TRange="参考值"
   s flag=0
   f  s flag=$o(^DHCPETMP("Position",flag)) q:flag=""  d
   .s Position=0
   .f  s Position=$o(^DHCPETMP("Position",flag,Position)) q:Position=""  d
   ..i str="" s str=Position
   ..e   s str=str_"^"_Position
   
   q str_";"_GDesc_";"_TName_";"_TPosition_";"_TNotNormal_";"_TRange  //_";"_iLoop
}

//d ##class(web.DHCPE.Report.GroupNotNormalStatistic).GetPositionIAdm("无部门")

ClassMethod GetPositionIAdm(Position)
{
    Q:Position=""
    i Position="无部门"    s flag=2
    e  s flag=1
 	s str=""
	s iLoop=0    f  s iLoop=$o(^DHCPETMP("Position",flag,Position,iLoop))  q:iLoop=""  d
    .if str="" s str=$g(^DHCPETMP("Position",flag,Position,iLoop))
    .else  s str=str_"^"_$g(^DHCPETMP("Position",flag,Position,iLoop))
   
    Q str
}

//d ##class(web.DHCPE.Report.GroupNotNormalStatistic).GetPersonLength("下应派出所","14442","1596||1")

ClassMethod GetPersonLength(Position, IADMRowId, ItmMastDR)
{
  
	s PersonLength=$o(^DHCPETMP("IADMRowId","ODRowId",IADMRowId,ItmMastDR,""),-1)
    if PersonLength="" s PersonLength=0
	Q PersonLength+1
}

//d ##class(web.DHCPE.Report.GroupNotNormalStatistic).GetItemInfo("无部门")

ClassMethod GetItemInfo(Position)
{
   
   k ^TMPResultContrast("TotleARCIM")
   k ^TMPResultContrast("ARCIM")
   k ^TMPFlag
   Q:Position=""
   i Position="无部门"    s flag=2
   e  s flag=1
   s count=0
   f  s count=$o(^DHCPETMP("Position",flag,Position,count))  Q:count=""  d
    .s IADMRowId=$g(^DHCPETMP("Position",flag,Position,count))
    .s PAAdm=$p(^DHCPEIADM(IADMRowId),"^",1)
    .s OEORDRowId=0
	.f  s OEORDRowId=$o(^OEORD(0,"Adm",PAAdm,OEORDRowId))   Q:OEORDRowId=""  d
	..
	..s OEORIChildsub=0
	..s ret=""
	..s iLLoop=0
	..f  s OEORIChildsub=$O(^OEORD(OEORDRowId,"I",OEORIChildsub)) Q:(""=OEORIChildsub)  d
	...
    ...s OEORIRowId=OEORDRowId_"||"_OEORIChildsub
	...s OEORIItemStatDR=$p($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",13)
	...//当医嘱为停止状态退出
	...q:OEORIItemStatDR=4
	...s OEORIItmMastDR=$p($G(^OEORD(OEORDRowId,"I",OEORIChildsub,1)),"^",2)
	...q:$o(^DHCPEST(0,"STORD_ARCIM",OEORIItmMastDR,0))=""  // 当医嘱在站点与大项中未关联退出
	...s STID=$o(^DHCPEST(0,"STORD_ARCIM",OEORIItmMastDR,0))
	...s ARCIMSubscript=$P(OEORIItmMastDR,"||",1)
	...s ARCIMVersion=$P(OEORIItmMastDR,"||",2)
	...s ARCIMDesc=$P($G(^ARCIM(ARCIMSubscript,ARCIMVersion,1)),"^",2)
	...
	...q:($d(^TMPFlag(OEORIItmMastDR))=1)
	...
    ...s ^TMPResultContrast("TotleARCIM",STID,OEORIItmMastDR)=ARCIMDesc
    ...s ^TMPFlag(OEORIItmMastDR)=1
    ...
    
    s STDR=0
    s str=""
    f  s STDR=$O(^TMPResultContrast("TotleARCIM",STDR))  Q:STDR=""  d
    .s ItmMastDR=0
    .f  s ItmMastDR=$o(^TMPResultContrast("TotleARCIM",STDR,ItmMastDR))  Q:ItmMastDR=""  d
    ..s ARCIMSubscript=$P(ItmMastDR,"||",1)
	..s ARCIMVersion=$P(ItmMastDR,"||",2)
    ..s ARCIMDesc=$P($G(^ARCIM(ARCIMSubscript,ARCIMVersion,1)),"^",2)
    ..i str="" s str=ItmMastDR_"!"_ARCIMDesc
    ..e   s str=str_"^"_ItmMastDR_"!"_ARCIMDesc
    ..
    s ^TMPResultContrast("ARCIM")=str
    
    q str
}

//d ##class(web.DHCPE.Report.GroupNotNormalStatistic).GetAbnormity("无部门",4980)

ClassMethod GetAbnormity(Position, IADMRowId)
{
  if Position="" s Position="无部门"
  s str=""
  s ItmMastDR=0
  f  s ItmMastDR=$o(^DHCPETMP("NotNromal","Num",Position,IADMRowId,ItmMastDR))  Q:ItmMastDR=""  d
  .s num=$g(^DHCPETMP("NotNromal","Num",Position,IADMRowId,ItmMastDR))
  .i str=""  s str=num
  .e  s str=str_"^"_num
  
  s MaxLength=0 
  for L=1:1:$l(str,"^")
		  {
			  if $p(str,"^",L)>MaxLength s MaxLength=$p(str,"^",L)
		  }
 q MaxLength
}

ClassMethod GetHaveItemFlag(PAAdm, ItmMastDR)
{
	s RLTRowId=0,retflag="false"
    f  s RLTRowId=$o(^DHCPERLT(0,"ARCIM",ItmMastDR,RLTRowId)) Q:RLTRowId=""  d
    .s ADMDR=$P(^DHCPERLT(RLTRowId),"^",1)
    .s Normal=$p(^DHCPERLT(RLTRowId), "^", 7)
    .i ADMDR=PAAdm  s retflag="true"
    
    Q retflag
}

//d ##class(web.DHCPE.Report.GroupNotNormalStatistic).GetIAdmRlt("9913||1","276",0)

ClassMethod GetIAdmRlt(ItmMastDR, IADMRowId, ODlength As %String = "")
{
   
	s str=$g(^DHCPETMP("IADMRowId","ODRowId",IADMRowId,ItmMastDR,ODlength))	
	//w !,str
	Q str
}

/// Creator：        zhouyong
/// CreatDate：      2009-5-18
/// Description:：   用于查找团体人员的体检异常值信息
/// Input：          团体ADM号
/// Return：         团体人员的体检异常值信息
ClassMethod GetResultByIADMs(IADMs As %String = "", StationID As %String = "")
{
  
	s length=$L(IADMs,"^")
	s ret=""
	s i=0
	for i=1:1:length
	{
		s iadm=$p(IADMs,"^",i)
		q:$g(iadm)=""   //20090608
		s PIADMRowId=$p(^DHCPEIADM(iadm),"^",4) //对应的预约个人ADM号
   		s ADM=$p(^DHCPEIADM(iadm),"^",1)  //对应的medtrak的ADM号
   		s PIBIDR=""
   		i PIADMRowId'=""  s PIBIDR=$p($g(^DHCPEPreIADM(PIADMRowId)),"^",1)
   		Q:PIBIDR=""
   		s PAPMINo=$p(^DHCPEPreIBI(PIBIDR),"^",1)  //登记号
   		s Name=$p(^DHCPEPreIBI(PIBIDR),"^",2)  //姓名
   		s Position=$p(^DHCPEPreIBI(PIBIDR),"^",11)
   		i Position=""  s Position="无部门"
   		;q:i>30
   		s RLTRowId=0
   		Q:ADM=""
   		s checkResult=""
   		f  s RLTRowId=$o(^DHCPERLT(0,"ADM",ADM,RLTRowId))   Q:(RLTRowId="")  d
   		.s ItmMastDR=$P(^DHCPERLT(RLTRowId), "^", 2)
  		.s Subscript=$p(ItmMastDR,"||",1)
   		.s Version=$p(ItmMastDR,"||",2)
   		.s ItmMastDesc=$p($g(^ARCIM(Subscript,Version,1)),"^",2)  //医嘱名称
   		.s Normal=$p($g(^DHCPERLT(RLTRowId)), "^", 7)
   		.Q:(Normal="1")&&((StationID=""))  //结果正常就退出
   		.s Result=$P($g(^DHCPERLT(RLTRowId)), "^", 4)  //诊断结果(阳性体征)
   		.s ODRowId=""
   		.s ODRowId=$p($g(^DHCPERLT(RLTRowId)),"^",3)  //指向DHC_PE_OrderDetail
   		.q:ODRowId=""     
   		.s STRowId=$p(ODRowId,"||",1)			//站点编码
   		.q:(StationID'="")&&(STRowId'=StationID)
   		.s ODChildSub=$p(ODRowId,"||",2)		    
   		.s ODDesc=$p($G(^DHCPEST(STRowId,"OD",ODChildSub)),"^",1)	//细项名称	DHC_PE_OrderDetail.{ OD_Desc }
   		.s checkResult=checkResult_"$"_ItmMastDesc_"^"_ODDesc_"^"_Result
   		if ret=""  d
   		.s ret=PAPMINo_"^"_Name_"^"_Position_"^"_checkResult
   		else  d
   		.s ret=ret_"&"_PAPMINo_"^"_Name_"^"_Position_"^"_checkResult
	}
	q ret
}

}
