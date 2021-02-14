Class web.DHCPE.PreIADMReplace Extends %RegisteredObject
{

// w ##class(web.DHCPE.PreIADMReplace).Save("116^0000000056^备注^933")

// StrInfo  PreIADM^新登记号^备注^用户ID

ClassMethod Save(StrInfo)
{
	s PreIADM=$P(StrInfo,"^",1)
	s OldPIBI=$P(^DHCPEPreIADM(PreIADM),"^",1)
	s NewRegNo=$P(StrInfo,"^",2)
	s NewRegNoIndex=$$ALPHAUP^SSUTIL4(NewRegNo)
	s NewPatID=$O(^PAPERi("PAPMI_PatNo",NewRegNoIndex,""))
	q:NewPatID="" "-1^his信息不存在"
	s IADM=$O(^DHCPEIADM(0,"CRMADM",PreIADM,0))
	s PAADM=""
	i IADM'="" d
	.s PAADM=$P(^DHCPEIADM(IADM),"^",1)
	s NewPIBI=$O(^DHCPEPreIBI(0,"PAPMINo",NewRegNo,0))
	s UserID=$P(StrInfo,"^",4)
	TSTART
	i NewPIBI=""
	{
		s ret=##class(web.DHCPE.PreIBIUpdate).UpdatePEInfoByHis(NewRegNo, UserID)
		s NewPIBI=$O(^DHCPEPreIBI(0,"PAPMINo",NewRegNo,0))
		if NewPIBI=""
		{
			TROLLBACK
			q "-1^插入体检基本信息错误"
		}
	}
	&SQL(Update Sqluser.DHC_PE_PreIAdm set PIADM_PIBI_DR=:NewPIBI where PIADM_RowID=:PreIADM)
	
	i SQLCODE'=0
	{
		TROLLBACK
		q "-1^更新预约记录失败"
	}
	i PAADM'=""
	{ 
		&SQL(Update Sqluser.PA_Adm set PAADM_PAPMI_DR=:NewPatID where PAADM_RowID=:PAADM)
		i SQLCODE'=0
		{
			TROLLBACK
			q "-1^更新PAADM记录失败"
		}
	}
	s obj=##class(User.DHCPEPreIADMReplace).%New()
	d obj.PRPreIADMDRSetObjectId(PreIADM)
	d obj.PROldIBIDRSetObjectId(OldPIBI)
	d obj.PRNewIBIDRSetObjectId(NewPIBI)
	s obj.PRRemark=$P(StrInfo,"^",3)
	d obj.PRUserDRSetObjectId(UserID)
	s obj.PRUpdateDate=+$H
	s obj.PRUpdateTime=$P($H,",",2)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		TROLLBACK
		q "-1^插入替换记录错误:"_$System.Status.GetErrorText(sc)
	}else{
		TCOMMIT
		q obj.%Id()
	}
}

// w ##class(web.DHCPE.PreIADMReplace).GetPreInfo("116")

ClassMethod GetPreInfo(PreIADM)
{
	q:PreIADM="" ""
	s PIBI=$P(^DHCPEPreIADM(PreIADM),"^",1)
	s Status=$P(^DHCPEPreIADM(PreIADM),"^",8)
	s Status=##Class(web.DHCPE.PreCommon).TransStatus(Status)
	s PreGADM=$P(^DHCPEPreIADM(PreIADM),"^",2)
	s PreGTeam=$P(^DHCPEPreIADM(PreIADM),"^",3)
	s GDesc="",TeamDesc=""
	i PreGADM'="" d
	.s GBaseInfo=$P(^DHCPEPreGADM(PreGADM),"^",1)
	.s GDesc=$P(^DHCPEPreGBI(GBaseInfo),"^",2)
	.s TeamDesc=$P(^DHCPEPreGADM(PreGADM,"Team",$P(PreGTeam,"||",2)),"^",1)
	s VIPLevel=$P(^DHCPEPreIADM(PreIADM),"^",18)
	i VIPLevel="" s VIPLevel=$G(^DHCPEVIPLevel("VIPapprove"))
	s:VIPLevel'="" VIPLevel=$P(^DHCPEVIPLevel("VIP",VIPLevel),"^",2)
	s HPNo=$P(^DHCPEPreIADM(PreIADM),"^",27)
	s OldRegNo=$P(^DHCPEPreIBI(PIBI),"^",1)
	s RoomPlace=$G(^DHCPEDataEx("DHCPEPreIADM","RoomPlace",PreIADM))
	s:RoomPlace'="" RoomPlace=$P($G(^DHCPEDataEx("RoomPlace",RoomPlace)),"^",2)
	;q Status_"^"_GDesc_"^"_TeamDesc_"^"_VIPLevel_"^"_HPNo_"^"_..GetBaseInfoByRegNo(OldRegNo)
	q Status_"^"_GDesc_"^"_TeamDesc_"^"_VIPLevel_"^"_HPNo_"^"_RoomPlace_"^"_..GetBaseInfoByRegNo(OldRegNo)
}

ClassMethod GetBaseInfoByRegNo(RegNo)
{
	q:RegNo="" "^^^^^^^"
	s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
	s NewRegNoIndex=$$ALPHAUP^SSUTIL4(RegNo)
	s NewPatID=$O(^PAPERi("PAPMI_PatNo",NewRegNoIndex,""))
	q:NewPatID="" "^^^^^^^"
	
	s Name=$P($g(^PAPER(NewPatID,"ALL")),"^",1)
	s Dob=$P($g(^PAPER(NewPatID,"ALL")),"^",6)
	//s Age=##class(web.DHCPE.DHCPECommon).GetCurAge(Dob)
	i Dob'="" s Age=##class(web.DHCBillInterface).GetPapmiAge(NewPatID)
	s Sex=$P($g(^PAPER(NewPatID,"ALL")),"^",7)
	s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
	//s IDCard=$P($g(^PAPER(NewPatID,"PAT",3)),"^",6)
	S PACCardDesc="",IDCard=""
	S PACCardTypeDR=$P($G(^PAPER(NewPatID,"PAT",3)),"^",7)
	I PACCardTypeDR'=""  S PACCardDesc=$p($g(^PAC("CARD",PACCardTypeDR)),"^",2)
	i PACCardDesc["身份证" s IDCard=$P($G(^PAPER(NewPatID,"PAT",3)),"^",6)
    s MaritalDesc=""
	s Marital=$P($G(^PAPER(NewPatID,"PER",2)),"^",3)
	//s:Marital'="" Marital=$P(^CT("MAR",Marital),"^",2)
	s:Marital'="" MaritalDesc=$P(^CT("MAR",Marital),"^",2)
	s PIBIRowId=$o(^DHCPEPreIBI(0,"PAPMINo",RegNo,0))
	i (PIBIRowId'="")&(MaritalDesc="") d
    .s PIBIMarriedDR=$p($g(^DHCPEPreIBI(PIBIRowId)),"^",17)
    .i PIBIMarriedDR'="" s MaritalDesc=$P(^CT("MAR",PIBIMarriedDR),"^",2)

	q NewPatID_"^"_RegNo_"^"_Name_"^"_Sex_"/"_Age_"^"_MaritalDesc_"^"_IDCard
}

/// 提供给Web页面 显示站点的的列表 DHCPEStationListCom
Query ReplaceList(PreIADM As %Library.String = "") As %SQLQuery(ROWSPEC = "TUpdateDate:%String,TUpdateTime:%String,TUpdateUser:%String,TRemark:%String,TOldInfo:%String,TNewInfo:%String")
{
	select PR_UpdateDate,PR_UpdateTime,PR_User_DR->SSUSR_Name||'('||PR_User_DR->SSUSR_Initials||')',PR_Remark,PR_OldIBI_DR->PIBI_Name||'('||PR_OldIBI_DR->PIBI_PAPMINo||')',PR_NewIBI_DR->PIBI_Name||'('||PR_NewIBI_DR->PIBI_PAPMINo||')'
	from Sqluser.DHC_PE_PreIADMReplace where PR_PreIADM_DR=:PreIADM
}

}
