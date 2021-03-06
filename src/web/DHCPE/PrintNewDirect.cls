Class web.DHCPE.PrintNewDirect Extends %Persistent
{

/// w ##class(web.DHCPE.PrintNewDirect).GetPrintInfo("708^^CRM")
ClassMethod GetPrintInfo(InString, IsPreview As %String = "N")
{
	s AdmId=$P(InString,"^",1)
	s AdmType=$P(InString,"^",3)
	s curLoc=%session.Get("LOGON.CTLOCID")
	s curUser=%session.Get("LOGON.USERID")
	i AdmType'="CRM"
	{
		i AdmType="IADM"
		{
			s Flag=##class(web.DHCPE.DHCPEIAdm).HaveNoPayedItem(AdmId)
			//q:(Flag="1")&&(IsPreview="Y") "NoPayed"
			q:(Flag="1") "NoPayed"
			s AdmId=$p($g(^DHCPEIADM(AdmId)),"^",4)
		}else{
			s AdmId=$o(^DHCPEIADM(0,"PAADM",AdmId,0))
			s Flag=##class(web.DHCPE.DHCPEIAdm).HaveNoPayedItem(AdmId)
			//q:(Flag="1")&&(IsPreview="Y") "NoPayed"
			q:(Flag="1") "NoPayed"
			s AdmId=$p($g(^DHCPEIADM(AdmId)),"^",4)
		}
	}
	
	s BaseInfo=..GetPatBaseInfo(AdmId)
	s ItemInfo=..GetItemInfo(AdmId)
	s CTNum=$P(ItemInfo,$C(5),2)
	s ItemInfo=$P(ItemInfo,$C(5),1)
	s AddItem=$P(ItemInfo,$C(4),1)
	s ItemInfo=$P(ItemInfo,$C(4),2)
	//s AddItem="1+2+3"
	s BaseInfo=BaseInfo_"^"_AddItem_"^"_CTNum
	
	d ##class(web.DHCPE.AdmRecordManager).Insert(AdmId,"P","PrintDJD",curUser,"")
	
	s iadm=$O(^DHCPEIADM(0,"CRMADM",AdmId,0))
	i iadm'="" d
	.s PAADM=$P(^DHCPEIADM(iadm),"^",1)
	.d:PAADM'="" ..PatItemPrintFlag(PAADM)
	
	q BaseInfo_$C(4)_ItemInfo
}

ClassMethod GetPatBaseInfo(PreIADMID, NetPreFlag As %String = "0")
{
	;w ##class(web.DHCPE.PrintNewDirect).GetPatBaseInfo(977)
	s BaseId=$p(^DHCPEPreIADM(PreIADMID),"^",1)  //预登记个人基本信息表
	q:BaseId=""
	s ParInfo=$g(^DHCPEPreIBI(BaseId))
	s recheck=##class(web.DHCPE.PreCommon).GetReCheckFlag(PreIADMID,"PreADM")
	s recheck=recheck+1
	s recheck="第"_recheck_"次"
	s RegNo=$P(ParInfo,"^",1)
	s BarRegNo="*"_RegNo_"*"
	s RegNo=$p(^DHCPEPreIADM(PreIADMID),"^",27) //体检号
	s PatName = $P(ParInfo,"^",2)	// 姓名
	
	s PatMasID=$O(^PAPERi("PAPMI_PatNo",RegNo,0))
	i PatMasID'="" d
	.s PatName=$P(^PAPER(PatMasID,"ALL"),"^",1)
	
	s Position=$G(^DHCPEDataEx("DHCPEPreIADM","Position",PreIADMID))  //$P(ParInfo,"^",11)	// 部门
	i Position="" s Position=$P(ParInfo,"^",11)	// 部门
	s MobilePhone=##class(web.DHCPE.PreCommon).GetTelNo("PIBI",BaseId)
	;i MobilePhone="" s MobilePhone=$P(ParInfo,"^",7)
	;i MobilePhone="" s MobilePhone=$P(ParInfo,"^",6)
	s Sex = $P(ParInfo,"^",3)		// 性别
	i Sex'="" d
	.s Sex=$p($g(^CT("SEX",Sex)),"^",2)
	
	s PatAge = $P(ParInfo,"^",4)	// 年龄
	s PatAge=##class(web.DHCLCNUREXCUTE).CalAge(PatAge,+$h)
	s PatAge=$P(PatAge,"Y",1)
	s RegDate=""
	s iadm=$O(^DHCPEIADM(0,"CRMADM",PreIADMID,0))
	i iadm'="" d
	.s Status=$p(^DHCPEIADM(iadm),"^",8)
	.i Status="ARRIVED" d
	..s RegDate=$p(^DHCPEIADM(iadm),"^",5)
	..i RegDate'="" s RegDate=$ZD(RegDate,3)
	.e  d
	..s RegDate=$p(^DHCPEPreIADM(PreIADMID),"^",4)  //+$H
	..s VIPID="",VIPDesc=""
	..s VIPID=$p($g(^DHCPEPreIADM(PreIADMID)),"^",18)
	..s:(VIPID'="") VIPDesc=$p($G(^DHCPEVIPLevel("VIP",VIPID)),"^",2)
	..s:((VIPDesc["VIP")||(VIPDesc["vip"))&&((VIPID'="")) RegDate=$p($g(^DHCPEPreIADM(PreIADMID)),"^",4)
	..
	..i RegDate'="" s RegDate=$ZD(RegDate,3)
	s GADMDR=$P($G(^DHCPEPreIADM(PreIADMID)),"^",2)
	s GTeam=$P($G(^DHCPEPreIADM(PreIADMID)),"^",3)
	s SortNo=""
	s GTeamDesc=""
	s Company="个人"
	
	i ""'=GADMDR d
	.;s RegDate=$ZD(+$H,3)
	.s GBIDR=$P($G(^DHCPEPreGADM(GADMDR)),"^",1)
	.s Company=$P($G(^DHCPEPreGBI(GBIDR)),"^",2)
	.s GTeamDesc=""
	.i GTeam'="" d
	..s GTeamDesc=$p(^DHCPEPreGADM(+GTeam,"Team",$p(GTeam,"||",2)),"^",1)
	..s Char=##class(web.DHCPE.PreIADM).NumToChar($p(GTeam,"||",2))
	..s SortNo=Char_$G(^DHCPEDataEx("DHCPEPreIADM","GTEAM","IADM",PreIADMID))
	.s Company=Company
	s:NetPreFlag=0 RegDate=$ZD(+$H,3)  ;打印当前日期  2014-05-06
	s OrderSetsDesc=##class(web.DHCPE.Query.IAdmItemStatus).GetArcSetDesc(PreIADMID)
	
	s TotalFee=0
	s TotalFee=##class(web.DHCPE.PreItemList).IGetOrdAmount(PreIADMID,"PERSON")
	s i=$l(TotalFee,$C(13))
	s TotalFee=$p(TotalFee,$C(13),4)
	s TotalFee=$j(TotalFee,3,2)
	s TotalFee="总金额"_TotalFee

	
	s DietDesc=""
	s Diet=##class(web.DHCPE.PreIADM).GetDietFlagByID(PreIADMID)
	i Diet=1 d
	.s DietDesc="早餐"
	s PhotoDesc=""
	s PhotoFlag=##class(web.DHCPE.PreIADM).GetPhotoFlag(PreIADMID)
	if PhotoFlag>0 d
	.s PhotoDesc="出片"
	s VIPLevel=##class(web.DHCPE.PreCommon).GetVIPLevel("Pre",PreIADMID)
	s VIPType=$P(VIPLevel,"^",2)
	
	s RoomPlace=$G(^DHCPEDataEx("DHCPEPreIADM","RoomPlace",PreIADMID))
	s:RoomPlace'="" RoomPlace=$P($G(^DHCPEDataEx("RoomPlace",RoomPlace)),"^",2)
	s:RoomPlace'="" VIPType=VIPType_" "_RoomPlace
	
	
	s SortForNorCus=""
	i VIPType'[("VIP")  d
	.;s TotalFee=""
	.s CurLoc=$P(^DHCPEPreIADM(PreIADMID),"^",26)
	.q:CurLoc'=53
	.s SortForNorCus=..GetPatSortForNorCus(PreIADMID)
	e  d
	.s PhotoDesc=""
	.s DietDesc=""
	s Position=##class(web.DHCPE.PreCommon).GetPosition("PreADM",PreIADMID)
	
	s BaseInfo=PatName_"^"_Sex_"^"_PatAge_"^"_MobilePhone_"^"_RegNo_"^"_BarRegNo
	s BaseInfo=BaseInfo_"^"_RegDate_"^"_OrderSetsDesc_"^"_Company_"^"_VIPType
	;s DietDesc="早餐"
	;s PhotoDesc="片子"
	s BaseInfo=BaseInfo_"^"_Position_"^"_TotalFee_"^"_DietDesc_"^"_PhotoDesc
	s BaseInfo=BaseInfo_"^"_SortForNorCus
	q BaseInfo
}

// w ##class(web.DHCPE.PrintNewDirect).GetPayedAmt(51060)

ClassMethod GetPayedAmt(PreIADM)
{
	s TotalAmt=0
	s PAID=0
	f  s PAID=$O(^DHCPEPreA(0,"CRMADM","I",PreIADM,PAID)) q:PAID=""  d
	.s Status=$P(^DHCPEPreA(PAID),"^",21)
	.q:Status="NU"
	.s Status=$P(^DHCPEPreA(PAID),"^",14)
	.q:Status'="UNCHARGED"
	.s OneAmt=$P(^DHCPEPreA(PAID),"^",9)
	.s TotalAmt=TotalAmt+OneAmt
	q TotalAmt
}

/// w ##(web.DHCPE.PrintNewDirect).GetPatSortForNorCus()
ClassMethod GetPatSortForNorCus(PreIADM)
{
	
	;获取一个普通客户的排队序号，打印指引单的时候存在TCD25754||1和心脏彩超33055||1
	s Sort=""
	i ""'=$G(^DHCPEPatSortForNorCus(PreIADM,"Sort",+$h)) q $G(^DHCPEPatSortForNorCus(PreIADM,"Sort",+$h))
	
	s OtherStation=$G(^DHCPESetting("DHCPE","StationId_Other"))
	s NeedSortArcIdStr="^"_"25754||1"_"^"_"33055||1"_"^"
	s Flag=0
	s ItemSub=0
	f  s ItemSub=$O(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub)) q:ItemSub=""  d
	.s Stat=$P(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub),"^",16)
	.q:Stat'="1"
	.s ArcimID=$P(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub),"^",1)
	.s STID=$O(^DHCPEST(0,"STORD_ARCIM",ArcimID,""))
	.q:(STID="")||(STID=OtherStation)
	.s ArcimID="^"_ArcimID_"^"
	.s:NeedSortArcIdStr[ArcimID Flag=1
	.q
	i Flag=1 d
	.s Sort=$I(^DHCPEPatSortForNorCus("PatSortForNorCus",+$h))+40
	.s ^DHCPEPatSortForNorCus(PreIADM,"Sort",+$h)=Sort
	q Sort
}

ClassMethod GetItemInfo(PreIADM)
{
	/*
	.s PatItemID=$P(PatItemInfo,"^",1)
	.s ItemSort=$P(PatItemInfo,"^",2)
	.s IsPrint=$P(PatItemInfo,"^",3)
	.s PrintName=$P(PatItemInfo,"^",4)
	*/
	s ArcimIDStr="^"_"22172||1^33774||1"_"^"
	s NoPhotoArcimID="33649||1"
	s CTStation="13"
	s RaxStation="14"
	s NJStation="15"
	s CTNum=0
	s RaxNum=0
	s NJNum=0
	s CTAppNum=0
	s RaxAppNum=0
	s NJAppNum=0
	s IBInfoId=$p(^DHCPEPreIADM(PreIADM),"^",1)  //预登记个人基本信息表
	q:IBInfoId=""
	s IBInfo=$g(^DHCPEPreIBI(IBInfoId))
	s IBSex = $P(IBInfo,"^",3)		// 性别
	i IBSex'="" d
	.s IBSex=$p($g(^CT("SEX",IBSex)),"^",2)
	s curUser=%session.Get("LOGON.USERID")
	s BloodSpecNum=0
	s OtherSpecNum=0
	s BloodPatItemID=""
	s OtherPatItemID=""
	s AddItem=""
	s Job=$J
	k ^TempDHCPEPrintDirect(Job)
	k ^TempDHCPEPrintDirectSpecNum(Job)
	k ^TempDHCPEPrintDirectItemNum("PrintNewDirect","Qty",Job)
	s OtherStation=$G(^DHCPESetting("DHCPE","StationId_Other"))
	s LocID=%session.Get("LOGON.CTLOCID")
	s NoPhotoFlag=0
	s ItemSub=0
	f  s ItemSub=$O(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub)) q:ItemSub=""  d
	.s Stat=$P($G(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub)),"^",16)
	.q:Stat'="1"
	.s PrintRecord=+$O(^DHCPEDataEx("OEOrder","PatTtemHadPrint",PreIADM_"||"_ItemSub,""),-1)+1
	.s ^DHCPEDataEx("OEOrder","PatTtemHadPrint",PreIADM_"||"_ItemSub,PrintRecord)=$H_"^"_curUser
	.s ItemNum=+$G(^DHCPEDataEx("DHCPEPreIOrdItem","Qty",PreIADM_"||"_ItemSub))
	.s ArcimID=$P(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub),"^",1)
	.S ^TempDHCPEPrintDirectItemNum("PrintNewDirect","Qty",Job,PreIADM,ArcimID)=$g(^TempDHCPEPrintDirectItemNum("PrintNewDirect","Qty",Job,PreIADM,ArcimID))+ItemNum
	.i ArcimID=NoPhotoArcimID s NoPhotoFlag="1"
	.s STID=$O(^DHCPEST(0,"STORD_ARCIM",ArcimID,""))
	.q:(STID="")||(STID=OtherStation)
	.i STID=CTStation d
	..s CTNum=CTNum+1
	.i STID=RaxStation d
	..s RaxNum=RaxNum+1
	.i STID=NJStation d
	..s NJNum=NJNum+1
	.;PatItemID^ItemSort^ItemIsPrint^ItemPrintName
	.s PatItemInfo=$G(^DHCPEDataEx("PatItemSort",ArcimID))
	.s PatItemID=$P(PatItemInfo,"^",1)
	.s CrmOrdID=$O(^DHCPECRMO(0,"CRMORI",PreIADM_"||"_ItemSub,0))
	.s AppFlag=0
	.i CrmOrdID'="" d
	..s OrderItemID=$P(^DHCPECRMO(CrmOrdID),"^",1)
	..i OrderItemID'=""  d
	...s SpecNo=$P(^OEORD(+OrderItemID,"I",$P(OrderItemID,"||",2),3),"^",20)
	...s OEORIItemStatDR=$p($G(^OEORD(+OrderItemID,"I",$p(OrderItemID,"||",2),1)),"^",13)
	...s:OEORIItemStatDR=6 AppFlag=1
	...q:SpecNo=""
	...q:$D(^TempDHCPEPrintDirectSpecNum(Job,SpecNo))
	...s ^TempDHCPEPrintDirectSpecNum(Job,SpecNo)=""
	...s SpecName=##class(web.DHCPE.BarPrint).GetSpecName(OrderItemID)
	...i SpecName[("血") d
	....s BloodSpecNum=BloodSpecNum+1
	....s BloodPatItemID=PatItemID
	...e  d
	....s OtherSpecNum=OtherSpecNum+1
	....s OtherPatItemID=PatItemID
	.i AppFlag=1 d
	..i STID=CTStation d
	...s CTAppNum=CTNum+1
	..i STID=RaxStation d
	...s RaxAppNum=RaxNum+1
	..i STID=NJStation d
	...s NJAppNum=NJNum+1
	.s ItemSort=$P(PatItemInfo,"^",2)
	.s IsPrint=$P(PatItemInfo,"^",3)
	.s PrintName=$P(PatItemInfo,"^",4)
	.i PatItemID'="" d
	..s PatItemSort=$P($G(^DHCPEDataEx("PatItem",PatItemID)),"^",2)
	..s:PatItemSort="" PatItemSort="99999"
	.e  d
	..s PatItemSort="99999"
	.s:PatItemID="" PatItemID="99999"
	.s:ItemSort="" ItemSort="9999999999"
	.s:IsPrint="" IsPrint="Y"
	.s:PrintName="" PrintName=##class(web.DHCPE.DHCPECommon).GetArcDesc(ArcimID)
	
	
	.s SetID=$P(^DHCPEPreIADM(PreIADM,"ORDITEM",ItemSub),"^",2)
	.s AddFlag=0
	.i SetID="" d
	..i AddItem="" d
	...s AddItem=PrintName
	..e  d
	...s AddItem=AddItem_"+"_PrintName
	..s AddFlag=1
	.s:IsPrint="N" PrintName=""
	.s ^TempDHCPEPrintDirect(Job,PatItemSort,PatItemID,ItemSort,ArcimID)=PrintName_"^"_AddFlag
	k ^TempDHCPEPrintDirectSpecNum(Job)
	s ItemInfo=""
	s PatItemSort=""
	f  s PatItemSort=$O(^TempDHCPEPrintDirect(Job,PatItemSort)) q:PatItemSort=""  d
	.s PatItemID=""
	.f  s PatItemID=$O(^TempDHCPEPrintDirect(Job,PatItemSort,PatItemID)) q:PatItemID=""  d
	..s OneInfo=""
	..s PatItemName=$P($G(^DHCPEDataEx("PatItem",PatItemID)),"^",1)
	..i PatItemName="" s PatItemName="没有分类"
	
	..i PatItemID="5" d  ;放射不出片
	...i NoPhotoFlag="1" d
	....s PatItemName=PatItemName_"(不出片)"
	
	..i PatItemID=BloodPatItemID d
	...s PatItemName=PatItemName_"("_BloodSpecNum_")"
	..;i PatItemID=OtherPatItemID d
	..;.s PatItemName=PatItemName_"("_OtherSpecNum_")"
	..s PatItemNotice=$G(^DHCPEDataEx("PatItem",PatItemID,"Place",LocID))
	..s DocFlag=$P($G(^DHCPEDataEx("PatItem",PatItemID)),"^",6)
	..s PatSignName=$P($G(^DHCPEDataEx("PatItem",PatItemID)),"^",7)
	..s PatInfo=PatItemName_"^"_PatItemNotice_"^"_DocFlag_"^"_PatSignName
	..s OneItemInfo=""
	..s PrtFlag=0
	..s ItemSort=""
	..f  s ItemSort=$O(^TempDHCPEPrintDirect(Job,PatItemSort,PatItemID,ItemSort)) q:ItemSort=""  d
	...s ArcimID=""
	...f  s ArcimID=$O(^TempDHCPEPrintDirect(Job,PatItemSort,PatItemID,ItemSort,ArcimID)) q:ArcimID=""  d
	....
	....i (PatItemID=6)&(IBSex="男") d
	.....s:LocID="53" $P(PatInfo,"^",2)="★腹部超声需要空腹、前列腺超声需要憋尿"
	....i (PatItemID=6)&(IBSex="女") d
	.....s:LocID="53" $P(PatInfo,"^",2)="★腹部超声需要空腹、妇科B超需要憋尿"
	....i (ArcimIDStr[("^"_ArcimID_"^")) d
	.....s PrtFlag=1
	....
	....s OneArcInfo=$G(^TempDHCPEPrintDirect(Job,PatItemSort,PatItemID,ItemSort,ArcimID))
	....q:$P(OneArcInfo,"^",1)=""
	....s ItemNum=$g(^TempDHCPEPrintDirectItemNum("PrintNewDirect","Qty",Job,PreIADM,ArcimID))
	....i ItemNum>1 s $p(OneArcInfo,"^",1)=$p(OneArcInfo,"^",1)_"*"_ItemNum
	....i OneItemInfo="" d
	.....s OneItemInfo=OneArcInfo
	....e  d
	.....s OneItemInfo=OneItemInfo_$C(3)_OneArcInfo
	...s:(PrtFlag=1) $P(PatInfo,"^",2)="★阴式B超请先行妇科检查"
	..s OneInfo=PatInfo_$C(2)_OneItemInfo
	..i ItemInfo="" d
	...s ItemInfo=OneInfo
	..e  d
	...s ItemInfo=ItemInfo_$C(1)_OneInfo
	k ^TempDHCPEPrintDirect(Job)
	K ^TempDHCPEPrintDirectItemNum("PrintNewDirect","Qty",Job)
	q AddItem_$C(4)_ItemInfo_$C(5)_CTNum_"("_CTAppNum_")"_"^"_RaxNum_"("_RaxAppNum_")"_"^"_NJNum_"("_NJAppNum_")"
}

ClassMethod PatItemPrintFlag(PAADM)
{
	Q:PAADM=""
	s ^DHCPEPatItemPrintFlag("PatItem","PrintFlag",PAADM)="Y"
	q ""
}

ClassMethod GetPhotoPathByPAADM(PAADM)
{
	s PatMasID=""
	s PatMasID=$P(^PAADM(PAADM),"^",1)
	q "http://100.100.96.248:8080/"_PatMasID_".jpg"
	s FTPInfo=$G(^DHCPESetting("DHCPE","PhotoFTP"))
	//var imgStr="ftp://"+FTPArr[1]+":"+FTPArr[2]+"@"+FTPArr[0]+":"+FTPArr[3]+"/"+FTPArr[4]+"/"+BaseInfo[7]+".jpg"
    s imgStr="ftp://"_$P(FTPInfo,"^",2)_":"_$P(FTPInfo,"^",3)_"@"_$P(FTPInfo,"^",1)_":"_$P(FTPInfo,"^",4)_"/"_$P(FTPInfo,"^",5)_"/"_PatMasID_".jpg"
    q imgStr
}

ClassMethod GetTemplateName(VIPLevelDesc)
{
	s VIPLevelID=##class(web.DHCPE.VIPLevel).GetVIPIDByDesc(VIPLevelDesc)
	q:VIPLevelID="" ""
	q $P($G(^DHCPEVIPLevel("VIP",VIPLevelID)),"^",13)
}

/// w ##class(web.DHCPE.PrintNewDirect).GetPhotoPath(0003147387)
ClassMethod GetPhotoPath(RegNo)
{
	s PatMasID=""
	/*
	i Type="RegNo" d
	.//s ID=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
	.s PatMasID=$O(^PAPERi("PAPMI_PatNo",RegNo,0))
	b ;PatMasID
	i Type="PAADM" d
	.s PatMasID=$P(^PAADM(RegNo),"^",1)
	*/
	s PatMasID=$O(^PAPERi("PAPMI_PatNo",RegNo,0))
	q:PatMasID="" ""
	//s PatMasID="3147393"
	q "http://100.100.96.248:8080/"_PatMasID_".jpg"
	s FTPInfo=$G(^DHCPESetting("DHCPE","PhotoFTP"))
	//var imgStr="ftp://"+FTPArr[1]+":"+FTPArr[2]+"@"+FTPArr[0]+":"+FTPArr[3]+"/"+FTPArr[4]+"/"+BaseInfo[7]+".jpg"
    s imgStr="ftp://"_$P(FTPInfo,"^",2)_":"_$P(FTPInfo,"^",3)_"@"_$P(FTPInfo,"^",1)_":"_$P(FTPInfo,"^",4)_"/"_$P(FTPInfo,"^",5)_"/"_PatMasID_".jpg"
    q imgStr
}

Storage Default
{
<Data name="PrintNewDirectDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.PrintNewDirectD</DataLocation>
<DefaultData>PrintNewDirectDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.PrintNewDirectD</IdLocation>
<IndexLocation>^web.DHCPE.PrintNewDirectI</IndexLocation>
<StreamLocation>^web.DHCPE.PrintNewDirectS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
