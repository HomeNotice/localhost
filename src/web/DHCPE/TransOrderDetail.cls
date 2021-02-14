/// Description: 取有关检验的细项明细
Class web.DHCPE.TransOrderDetail Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

Parameter BUILD = 1;

/// d ##class(web.DHCPE.TransOrderDetail).FormatODCode(1)
ClassMethod FormatODCode(SID)
{
	s id=0
	f  s id=$O(^DHCPEST(SID,"OD",id)) Q:(""=id)  d
	.s Code=SID_$Extract("0000",1,4-$Length(id))_id
	.&sql(
				update SQLUSER.DHC_PE_OrderDetail 
				set OD_Code=:Code
					, OD_Sequence=:Code
				where OD_ParRef=:SID and OD_ChildSub=:id
				
			)
	.s ODDR=SID_"||"_id
	.&sql(
				update SQLUSER.DHC_PE_OrderDetailRelate 
				set ODR_Sequence=:Code
				where ODR_OD_DR=:ODDR
				
			)
			
	.Q:("0"'=SQLCODE)
}

ClassMethod DeleteOldDetail(ARCITEMID)
{
	&SQL(delete from sqluser.DHC_PE_OrderDetail where od_rowid in (select ODR_OD_DR from sqluser.DHC_PE_OrderDetailRelate where ODR_ARCIM_DR=:ARCITEMID))
	s:SQLCODE=100 SQLCODE=0
	q:(SQLCODE'=0) SQLCODE
	&SQL(delete from sqluser.DHC_PE_OrderDetailRelate where ODR_ARCIM_DR=:ARCITEMID)
	s:SQLCODE=100 SQLCODE=0
	q SQLCODE
}

/// test: w ##class(web.DHCPE.TransOrderDetail).Main("9978||1")
/// return: "":Correct, else:Error.
ClassMethod Main(arcItemId As %String, StationID As %String = "")
{
	s ^lisatest("1107","TransOrderDetail")=arcItemId
	s labItemCode="", myCount="", retStr=""
	
	i StationID="" s labStationId=^DHCPESetting("DHCPE","StationId_Lab")
	i StationID'="" s labStationId=StationID
	
	s TrakVerison=##class(web.DHCPE.Public.Setting).GetTrakVerison()
	
	////取检验医嘱的外部代码
	// 新版本
  	i "TrakCare"=TrakVerison d
 	.i ((TrakVerison="TrakCare")&&($g(arcItemId)'="")) Set labItemCode=##Class(web.DHCPE.TransResult).GetLabExtCode("TrakCare",arcItemId)
 	// 旧版本
	i "MedTrak"=TrakVerison d
	.// DHC_PE_StationOrder.{ STORD_ChildSub }
	.s STORDChildSub=""
	.s STORDChildSub=$O(^DHCPEST(0,"STORD_ARCIM",arcItemId, labStationId,STORDChildSub))
	.Q:(""=STORDChildSub)
	.// DHC_PE_StationOrder.{ STORD_ARCOS_DR }
	.s STORDARCOSDR=$P($G(^DHCPEST(labStationId, "O", STORDChildSub)),"^",3)
	.Q:(""=STORDARCOSDR)
	.// ARC_OrdSets.{ ARCOS_LabTrakTestSet }
	.s labItemCode=$P($G(^ARCOS(STORDARCOSDR)), "^", 11)
	;w labItemCode
	q:(""=labItemCode) "No Item"
	s detailIds="'zzz'"
  	s num=""
  	f  s num=$o(^TTAB("TS",labItemCode,0,num))  q:num=""  d
  	.s detailCode=$p($g(^TTAB("TS",labItemCode,0,num)),"\",8)
  	.//s str=$g(^TTAB("TC",CTTCCode))
  	.q:detailCode=""
  	.s detailDesc=$p($g(^TTAB("TC",detailCode)),"\",1)
  	.s detailUnits=$p($g(^TTAB("TC",detailCode)),"\",2)
  	.s detailActiveFlag=$p($g(^TTAB("TC",detailCode)),"\",19)
  	.i detailActiveFlag="Y"  d
	..s myId=""
	..&sql(select OD_RowId into :myId from SQLUSER.DHC_PE_OrderDetail where OD_LabTrakCode=:detailCode)
	..i myId="" d
	...&sql( insert into SQLUSER.DHC_PE_OrderDetail(
				OD_Parref, OD_Code, OD_Type,  OD_Unit,  OD_DESC, OD_LabTrakCode
			) values(:labStationId,:detailCode, 'N',:detailUnits,:detailDesc,:detailCode))
	...i SQLCODE'=0  s retStr=retStr_$c(10)_$c(13)_SQLCODE_"  insert into SQLUSER.DHC_PE_OrderDetail"
	...s myId=%ROWID
	..e  d
	...&sql(update SQLUSER.DHC_PE_OrderDetail 
				set  OD_Unit=:detailUnits, OD_DESC=:detailDesc, OD_LabTrakCode=:detailCode 
			where OD_RowID=:myId
			)
	..If myId'="" Do
	...Set ODDR=""
	...//b //1
	...&sql(select ODR_OD_DR into :ODDR from SQLUSER.DHC_PE_OrderDetailRelate where ODR_ARCIM_DR=:arcItemId and ODR_OD_DR->OD_LabtrakCode=:detailCode)
	...//b //2
	...If (SQLCODE=100) Do
	....s Order1=$p($G(^TTAB("TC",detailCode,1,labItemCode)),"\",1)
	....q:Order1=""
	....s LayOut=$p($G(^TTAB("TC",detailCode,1,labItemCode)),"\",2)
	....q:LayOut=""
	....s Sequence=$p($G(^TTAB("TS",labItemCode,LayOut,Order1)),"\",15)
	....&sql(insert into SQLUSER.DHC_PE_OrderDetailRelate(
				ODR_ARCIM_DR, ODR_OD_DR, ODR_Required,odr_sequence
			) values(:arcItemId, :myId, 'Y',:Sequence))
	....If SQLCODE'=0  s retStr=retStr_$c(10)_$c(13)_SQLCODE_"  insert into SQLUSER.DHC_PE_OrderDetailRelate"
	..
	..s SQLCODE=..TransStandard(myId)
	..i SQLCODE'=0  s retStr=retStr_$c(10)_$c(13)_SQLCODE_" ..TransStandard"
	..s detailIds=detailIds_", '"_myId_"'"
	//i detailIds="'zzz'" q "No ItemDetail"

	//-----删除多余的项目明细及对应表记录----
	s sqlWhere=" ODR_ARCIM_DR='"_arcItemId_"' and odr_OD_dr not in ("_detailIds_")" 
	//s sqlDeleteDetail="delete from SQLUSER.DHC_PE_OrderDetail where od_rowid in ( "
	//								_"select odr_od_dr from  SQLUSER.DHC_PE_OrderDetailRelate where "_sqlWhere_")"
	s sqlDeleteRelation="delete from SQLUSER.DHC_PE_OrderDetailRelate where "_sqlWhere
	
	Set result=##class(%ResultSet).%New("%DynamicQuery:SQL")
	Do result.Prepare(sqlDeleteRelation)
	s retStatus=result.Execute()
	//b:($$$ISOK(retStatus)'=1)	;sqlDeleteRelation
	//s retStr=##class(web.DHCPE.StationOrder).UpdateODRSequence(labStationId)
	q retStr
}

/// return: SQLCODE, 0-Correct;  else-error
ClassMethod TransStandard(OrderDetailId As %String)
{
	s labDetailId=""
	&sql(select OD_LabTrakCode into :labDetailId from SQLUSER.DHC_PE_OrderDetail where OD_RowId=:OrderDetailId)
	q:labDetailId="" 0
	s Flag="Y"
	&sql(delete from SQLUSER.DHC_PE_ODStandard where ODS_ParRef=:OrderDetailId )
	s Date=0
	f  s Date=$o(^TTAB("TC",labDetailId,4,Date)) q:Date=""  d
	.s Type=""
	.f  s Type=$o(^TTAB("TC",labDetailId,4,Date,Type)) q:Type=""  d
	..s Order=""
	..f  s Order=$o(^TTAB("TC",labDetailId,4,Date,Type,Order)) q:Order=""  d
	...s Sex=$p(^TTAB("TC",labDetailId,4,Date,Type,Order),"\",22)
	...s Min=$p(^TTAB("TC",labDetailId,4,Date,Type,Order),"\",1)
	...s Max=$p(^TTAB("TC",labDetailId,4,Date,Type,Order),"\",2)
	...s Age=$p(^TTAB("TC",labDetailId,4,Date,Type,Order),"\",23)
	...s MinAge=$p(Age,"-",1)
	...s MaxAge=$p(Age,"-",2)
	...&SQL(insert into SQLUSER.DHC_PE_ODStandard(
    			  ODS_ParRef, ODS_NatureValue, ODS_Sex
    			, ODS_min , ODS_Max, ODS_AgeMin, ODS_AgeMax) 
    			values (:OrderDetailId,:Flag,:Sex,:Min,:Max,:MinAge,:MaxAge))
	
	
	
	q 0
}

ClassMethod GetLisInterface()
{
 
    s flag="N"
	s flag=$g(^DHCPESetting("DHCPE","LisInterface"))
	Q flag
}

}
