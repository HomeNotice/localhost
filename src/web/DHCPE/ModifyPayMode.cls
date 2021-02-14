Import SQLUser

Class web.DHCPE.ModifyPayMode Extends %RegisteredObject
{

/// w ##class(web.DHCPE.ModifyPayMode).GetInvInfoByInvNo(51644001,"")
ClassMethod GetInvInfoByInvNo(InvNo, Type, UserID)
{
	s ID=$O(^DHCPEINVPRT(0,"INV",InvNo,0))
	q:ID="" "NoData"
	s InvName=$G(^DHCPEDataEx("InvName",ID))
	i Type="R"{
		s ID=$O(^DHCPEINVPRT(0,"REF",ID,0))
		q:ID="" "NoRefData"
	}
	s ReportID=$P(^DHCPEINVPRT(ID),"^",13)
	q:ReportID'="" "HadReport"
	s CurUserID=$P(^DHCPEINVPRT(ID),"^",10)
	q:CurUserID'=UserID "UserNotOne"
	s Amount=$P(^DHCPEINVPRT(ID),"^",7)
	s paadm=$p(^DHCPEINVPRT(ID),"^",2)	
	s patid=$p($g(^PAADM(paadm)),"^",1)
	s PatName=$p($g(^PAPER(patid,"ALL")),"^",1)
	i InvName'="" s PatName=PatName_"("_InvName_")"
	s ARRCP=$p(^DHCPEINVPRT(ID),"^",4)
	s PayModeInfo=""
	s Sub=0
	f  s Sub=$O(^ARRCP(ARRCP,"PAYM",Sub)) q:Sub=""  d
	.s PayModeID=$P(^ARRCP(ARRCP,"PAYM",Sub),"^",1)
	.s PayMode=$P(^CT("CTPM",PayModeID),"^",2)
	.s Amt=$P(^ARRCP(ARRCP,"PAYM",Sub),"^",3)
	.s OneInfo=ARRCP_"||"_Sub_$C(2)_PayMode_" "_Amt
	.i PayModeInfo="" d
	..s PayModeInfo=OneInfo
	.e  d
	..s PayModeInfo=PayModeInfo_$C(1)_OneInfo
	q PatName_"^"_Amount_"^"_PayModeInfo
}

ClassMethod Update(ARCCPayModeDR, PayModeDR)
{
	s OldPayMode=$P(^ARRCP(+ARCCPayModeDR,"PAYM",$P(ARCCPayModeDR,"||",2)),"^",1)
	&sql(update AR_RcptPayMode set PAYM_PayMode_DR=:PayModeDR where PAYM_RowID=:ARCCPayModeDR)
	i SQLCODE=0{
		s Sub=$i(^DHCPEDataEx("DHCPEInvPrt","ModifyPayMode",ARCCPayModeDR))
		s ^DHCPEDataEx("DHCPEInvPrt","ModifyPayMode",ARCCPayModeDR,Sub)=OldPayMode_"^"_PayModeDR
	}
	q SQLCODE
}

}
