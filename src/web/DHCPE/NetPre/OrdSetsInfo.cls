Class web.DHCPE.NetPre.OrdSetsInfo Extends %RegisteredObject
{

ClassMethod SaveSetsItemType(ID, StrInfo)
{
	i ID="" d
	.s obj=##class(User.DHCPENetSetsItemType).%New()
	.d obj.NSITParRefSetObjectId($P(StrInfo,"^",1))
	e  d
	.s obj=##class(User.DHCPENetSetsItemType).%OpenId(ID)
	d obj.NSITItemTypeIDSetObjectId($P(StrInfo,"^",2))
	s obj.NSITSort=$P(StrInfo,"^",3)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod DeleteSetsItemType(ID)
{
	&SQL(Delete From Sqluser.DHCPENetSetsItemType where ID=:ID)
	q SQLCODE
}

ClassMethod SaveSetsItem(ID, StrInfo)
{
	i ID="" d
	.s obj=##class(User.DHCPENetSetsItem).%New()
	.d obj.NSIParRefSetObjectId($P(StrInfo,"^",1))
	e  d
	.s obj=##class(User.DHCPENetSetsItem).%OpenId(ID)
	s obj.NSIItemDesc=$P(StrInfo,"^",2)
	s obj.NSISort=$P(StrInfo,"^",3)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod DeleteSetsItem(ID)
{
	&SQL(Delete From Sqluser.DHCPENetSetsItem where ID=:ID)
	q SQLCODE
}

ClassMethod SaveSetsItemDetail(ID, StrInfo)
{
	i ID="" d
	.s obj=##class(User.DHCPENetSetsItemDetail).%New()
	.d obj.NSIDParRefSetObjectId($P(StrInfo,"^",1))
	e  d
	.s obj=##class(User.DHCPENetSetsItemDetail).%OpenId(ID)
	s obj.NSIDDesc=$P(StrInfo,"^",2)
	s obj.NSIDIntent=$P(StrInfo,"^",3)
	s obj.NSIDSort=$P(StrInfo,"^",4)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod DeleteSetsItemDetail(ID)
{
	&SQL(Delete From Sqluser.DHCPENetSetsItemDetail where ID=:ID)
	q SQLCODE
}

ClassMethod SaveOrdSets(ID, StrInfo)
{
	i ID="" d
	.s obj=##class(User.DHCPENetOrdSets).%New()
	e  d
	.s obj=##class(User.DHCPENetOrdSets).%OpenId(ID)
	s obj.NOSHisSetsID=$P(StrInfo,"^",1)
	s obj.NOSDesc=$P(StrInfo,"^",2)
	s obj.NOSPrice=$P(StrInfo,"^",3)
	s obj.NOSVIPLevel=$P(StrInfo,"^",4)
	s Sex=$P(StrInfo,"^",5)
	i Sex'="" s Sex=$P(^CT("SEX",Sex),"^",2)
	s obj.NOSSex=Sex
	s obj.NOSRemak=$P(StrInfo,"^",6)
	s obj.NOSSort=$P(StrInfo,"^",7)
	s obj.NOSGIFlag=$P(StrInfo,"^",8)
	s obj.NOSLocID=$P(StrInfo,"^",9)
	s obj.NOSActive=$P(StrInfo,"^",10)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

ClassMethod DeleteOrdSets(ID)
{
	&SQL(Delete From Sqluser.DHC_PE_NetOrdSets where ID=:ID)
	q SQLCODE
}

ClassMethod GetHisSetsInfo(SetsID, LocID)
{
	;d ##class(web.DHCPE.NetPre.OrdSetsInfo).GetHisSetsInfo(SetsID)
	s ret=""
	q:SetsID="" ret
	s ID=..GetNetSetsID(SetsID,LocID)
	i ID="" d
	.s Desc=$P(^ARCOS(SetsID),"^",2)
	.s Price=##class(web.DHCPE.Handle.ARCOrdSets).GetPrice(SetsID_"&O","","")
	.s Code=$P(^ARCOS(SetsID),"^",1)
	.s VIPLevel=""
	.s Sex=$g(^DHCPEDataEx("DHCPEBaseData","Sex",SetsID))
	.s Remark=""
	.s Sort=""
	.s GIFlag="I"
	.s ActiveFlag=""
	e  d
	.s Desc=$LG(^User.DHCPENetOrdSetsD(ID),3)
	.s Price=$LG(^User.DHCPENetOrdSetsD(ID),4)
	.s VIPLevel=$LG(^User.DHCPENetOrdSetsD(ID),5)
	.s Sex=$LG(^User.DHCPENetOrdSetsD(ID),6)
	.s:Sex'="" Sex=$O(^CT("SEX",0,"Desc",Sex,0))
	.s Remark=$LG(^User.DHCPENetOrdSetsD(ID),7)
	.s Sort=$LG(^User.DHCPENetOrdSetsD(ID),10)
	.s GIFlag=$LG(^User.DHCPENetOrdSetsD(ID),12)
	.s ActiveFlag=$LG(^User.DHCPENetOrdSetsD(ID),13)
	q ID_"^"_Desc_"^"_Price_"^"_VIPLevel_"^"_Sex_"^"_Remark_"^"_Sort_"^"_GIFlag_"^"_ActiveFlag
}

ClassMethod GetNetSetsID(HisSetsID, LocID)
{
	s ret=""
	s ID=""
	f  s ID=$O(^User.DHCPENetOrdSetsI("HisSetsIndex",HisSetsID,ID)) q:ID=""  d
	.s CurLocID=$LG(^User.DHCPENetOrdSetsD(ID),11)
	.q:CurLocID'=LocID
	.s ret=ID
	q ret
}

ClassMethod OutItemTypeToHTML(ContrlWidth As %String = "", DefaultValue As %String = "", tabIndex As %String = "0") As %String
{
  	;d ##class(web.DHCPE.NetPre.OrdSetsInfo).OutItemTypeToHTML(130,"")
	s:(""=ContrlWidth) ContrlWidth="155"
	//下拉列表
	w "<select name='ItemType' id='ItemType' style='width:"_ContrlWidth_"' HEIGHT=0  tabIndex="_tabIndex_">",!
	w "<option value=''>  </option>",!
	s id=0
	f  s id=$O(^User.DHCPENetItemTypeD(id)) q:id=""  d
	.s selected=""
	.s:DefaultValue=id selected="selected"
	.w "<option value='"_id_"'>"_$LG(^User.DHCPENetItemTypeD(id),2)_"</option>",!
		
	w "</select>",!
	Quit $$$OK
}

Query SearchSetsItemType(ParRef As %Library.String = "") As %SQLQuery(ROWSPEC = "TID:%String,TItemTypeID:%String, TItemTypeDesc:%String, TSort:%String")
{
 select ID,NSIT_ItemTypeID,NSIT_ItemTypeID->NIT_Desc,NSIT_Sort from Sqluser.DHCPENetSetsItemType where NSITParRef=:ParRef
}

Query SearchSetsItem(ParRef As %Library.String = "") As %SQLQuery(ROWSPEC = "TID:%String,TDesc:%String, TSort:%String")
{
 select ID,NSI_ItemDesc,NSI_Sort from Sqluser.DHCPENetSetsItem where NSIParRef=:ParRef
}

Query SearchSetsItemDetail(ParRef As %Library.String = "") As %SQLQuery(ROWSPEC = "TID:%String,TDesc:%String,TIntent:%String,TSort:%String")
{
 select ID,NSID_Desc,NSID_Intent,NSID_Sort from Sqluser.DHCPENetSetsItemDetail where NSIDParRef=:ParRef
}

}
