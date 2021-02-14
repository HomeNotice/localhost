Class web.DHCPE.ItemExtend Extends %Persistent
{

ClassMethod InsertIE(ID)
{
	s IEID=$O(^DHCPEIE(0,"ARCIM",ID,0))
	q:+IEID>0 "项目已经添加"
	k PLIST
	s PLIST(2)=ID
	s User=%session.Get("LOGON.USERID")
	s PLIST(3)=User
	s Date=+$H
	s Time=$P($H,",",2)
	s PLIST(4)=Date
	s PLIST(5)=Time
	&SQL(Insert into sqluser.DHC_PE_ItemExtend values :PLIST())
	i SQLCODE'="0" q "插入失败,SQLCODE:"_SQLCODE
	q SQLCODE
}

ClassMethod UpdateIEPrice(ID, Strs)
{
	k PLIST
	
	s PLIST(3)=$P(Strs,"^",2)
	s PLIST(4)=$P(Strs,"^",3)
	i PLIST(4)'="" s PLIST(4)=##class(websys.Conversions).DateHtmlToLogical(PLIST(4))
	s PLIST(5)=$P(Strs,"^",4)
	i PLIST(5)'="" s PLIST(5)=##class(websys.Conversions).DateHtmlToLogical(PLIST(5))
	
	s PLIST(7)=$P(Strs,"^",5)
	s PLIST(8)=$P(Strs,"^",6)
	i (ID'="") d
	.&SQL(update Sqluser.DHC_PE_IEPrice values :PLIST() where P_RowID=:ID)
	e  d
	.s PLIST(6)=%session.Get("LOGON.CTLOCID")
	.s PLIST(9)=%session.Get("LOGON.USERID")
	.s PLIST(10)=+$H
	.s PLIST(11)=$p($H,",",2)
	.s PLIST(0)=$P(Strs,"^",1)
	.&SQL(Insert into Sqluser.DHC_PE_IEPrice values :PLIST())
	i SQLCODE'=0 q "更新错误,SQLCODE:"_SQLCODE
	q SQLCODE
}

ClassMethod UpdateIESendItem(ID, Strs)
{
	k PLIST
	
	s PLIST(3)=$P(Strs,"^",2)
	s PLIST(4)=+$P(Strs,"^",3)
	s PLIST(5)=$P(Strs,"^",4)
	i PLIST(5)'="" s PLIST(5)=##class(websys.Conversions).DateHtmlToLogical(PLIST(5))
	s PLIST(6)=$P(Strs,"^",5)
	i PLIST(6)'="" s PLIST(6)=##class(websys.Conversions).DateHtmlToLogical(PLIST(6))
	
	s PLIST(8)=$P(Strs,"^",6)
	s PLIST(9)=$P(Strs,"^",7)
	i (ID'="") d
	.&SQL(update Sqluser.DHC_PE_IESendItem values :PLIST() where SI_RowID=:ID)
	e  d
	.s PLIST(7)=%session.Get("LOGON.CTLOCID")
	.s PLIST(10)=%session.Get("LOGON.USERID")
	.s PLIST(11)=+$H
	.s PLIST(12)=$p($H,",",2)
	.s PLIST(0)=$P(Strs,"^",1)
	.&SQL(Insert into Sqluser.DHC_PE_IESendItem values :PLIST())
	i SQLCODE'=0 q "更新错误,SQLCODE:"_SQLCODE
	q SQLCODE
}

ClassMethod GetOneInfo(ID, Type)
{
	s Strs=""
	i Type="P" d
	.s Price=$P(^DHCPEIE(+ID,"P",$p(ID,"||",2)),"^",1)
	.s BDate=$P(^DHCPEIE(+ID,"P",$p(ID,"||",2)),"^",2)
	.s EDate=$P(^DHCPEIE(+ID,"P",$p(ID,"||",2)),"^",3)
	.s SetsFlag=$P(^DHCPEIE(+ID,"P",$p(ID,"||",2)),"^",5)
	.i BDate'="" s BDate=##class(websys.Conversions).DateLogicalToHtml(BDate)
	.i EDate'="" s EDate=##class(websys.Conversions).DateLogicalToHtml(EDate)
	.s Strs=Price_"^"_BDate_"^"_EDate_"^"_SetsFlag
	e  d
	.s CostFeeMin=$P(^DHCPEIE(+ID,"SI",$p(ID,"||",2)),"^",1)
	.s CostFeeMax=$P(^DHCPEIE(+ID,"SI",$p(ID,"||",2)),"^",2)
	.s BDate=$P(^DHCPEIE(+ID,"SI",$p(ID,"||",2)),"^",3)
	.s EDate=$P(^DHCPEIE(+ID,"SI",$p(ID,"||",2)),"^",4)
	.s GroupFlag=$P(^DHCPEIE(+ID,"SI",$p(ID,"||",2)),"^",6)
	.i BDate'="" s BDate=##class(websys.Conversions).DateLogicalToHtml(BDate)
	.i EDate'="" s EDate=##class(websys.Conversions).DateLogicalToHtml(EDate)
	.s Strs=CostFeeMin_"^"_CostFeeMax_"^"_BDate_"^"_EDate_"^"_GroupFlag
	
	
	q Strs
}

// w ##class(web.DHCPE.ItemExtend).GetARCPrice("7555||1","297")

ClassMethod GetARCPrice(ARCID, PreIADM)
{
	s CFee=""
	;s Loc=%session.Get("LOGON.CTLOCID")
	s Date=+$H
	i PreIADM'=""
	{
		i PreIADM["||"
		{
			s Loc=$P(^DHCPEPreGADM(+PreIADM),"^",23)
		}
		else
		{
			s Fee=##class(web.DHCPE.HandlerPreOrds).IGetAmount4Person(PreIADM)
			s Loc=$P(^DHCPEPreIADM(+PreIADM),"^",26)
			s Fee=+$P(Fee,"^",2)
			s IEID=0
			f  s IEID=$O(^DHCPEIE(0,"ARCIM",ARCID,IEID)) q:(IEID="")||(CFee'="")  d
			.s Sub=0
			.f  s Sub=$o(^DHCPEIE(IEID,"SI",Sub)) q:(Sub="")||(CFee'="")  d
			..s CLoc=$p(^DHCPEIE(IEID,"SI",Sub),"^",5)
			..q:CLoc'=Loc
			..s BDate=$p(^DHCPEIE(IEID,"SI",Sub),"^",3)
			..q:BDate>Date
			..s EDate=$p(^DHCPEIE(IEID,"SI",Sub),"^",4)
			..q:(EDate<Date)&&(EDate'="")
			..s FeeMin=$p(^DHCPEIE(IEID,"SI",Sub),"^",1)
			..q:FeeMin>Fee
			..s CFee=0
		}
	}
	else
	{
		s Loc=%session.Get("LOGON.CTLOCID")
	
	}
	q:CFee'="" CFee
	s IEID=0
	f  s IEID=$O(^DHCPEIE(0,"ARCIM",ARCID,IEID)) q:(IEID="")||(CFee'="")  d
	.s Sub=0
	.f  s Sub=$o(^DHCPEIE(IEID,"P",Sub)) q:(Sub="")||(CFee'="")  d
	..s CLoc=$p(^DHCPEIE(IEID,"P",Sub),"^",4)
	..q:CLoc'=Loc
	..s BDate=$p(^DHCPEIE(IEID,"P",Sub),"^",2)
	..q:BDate>Date
	..s EDate=$p(^DHCPEIE(IEID,"P",Sub),"^",3)
	..q:(EDate<Date)&&(EDate'="")
	..s CFee=$p(^DHCPEIE(IEID,"P",Sub),"^",1)
	
	q CFee
}

ClassMethod GetARCDesc(ParRef)
{
	s ARCID=$P(^DHCPEIE(ParRef),"^",2)
	s Desc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ARCID)
	s Price=+##class(web.UDHCJFPRICE).GetOrderPrice("","",ARCID,+$H,"","","","")
	q Desc_"^"_Price
}

ClassMethod SerchItemExtendClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SerchItemExtendExecute ]
{
	Set repid=$LIST(qHandle,2)
	 Kill ^CacheTemp(repid)
	 Quit $$$OK
}

ClassMethod SerchItemExtendExecute(ByRef qHandle As %Binary, ARCDesc As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	
	 	s ID=0
	 	f  s ID=$O(^DHCPEIE(ID)) q:ID=""  d
	 	.s ARCIMID=$P($g(^DHCPEIE(ID)),"^",2)
	 	.s Name=##class(web.DHCPE.DHCPECommon).GetArcDesc(ARCIMID)
	 	.q:(ARCDesc'="")&&(Name'[ARCDesc)
	 	.s User=$P($g(^DHCPEIE(ID)),"^",3)
	 	.i User'="" s User=$P($g(^SSU("SSUSR",User)),"^",2)
	 	.s Date=$P($g(^DHCPEIE(ID)),"^",4)
	 	.i Date'="" s Date=##class(websys.Conversions).DateLogicalToHtml(Date)
	 	.d FindBuild
 	
		
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindBuild      
	set Data=$lb(ID,Name,User,Date)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SerchItemExtendFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SerchItemExtendExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	//
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 	Set AtEnd=1
 	Set Row=""
 	}
 	Else      {				// fetch row
 	Set Row=^CacheTemp(repid,ind)
 	}
 	// , PatientNo As %String, SurName As %String, CurrentDept As %String, CurrentBed As %String, CurrentWard As %String, CurrentDoctor As %String, StartDate As %Date, EndDate As %Date, CurrentAdmType As %String, CONTEXT As %String
 	// Save QHandlePatientNo As %String, SurName As %String, CurrentDept As %String, CurrentBed As %String, CurrentWard As %String, CurrentDoctor As %String, StartDate As %Date, EndDate As %Date, CurrentAdmType As %String	
 	s qHandle=$lb(AtEnd,repid,ind)
 	Quit $$$OK
}

Query SerchItemExtend(ARCDesc As %String = "") As %Query(ROWSPEC = "TRowID:%String,TARCDesc:%String:名称,TCreateUser:%String:排序,TCreateDate:%String:类型")
{
}

ClassMethod SerchIEPriceClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SerchIEPriceExecute ]
{
	Set repid=$LIST(qHandle,2)
	 Kill ^CacheTemp(repid)
	 Quit $$$OK
}

ClassMethod SerchIEPriceExecute(ByRef qHandle As %Binary, ParRef As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s CurLoc=%session.Get("LOGON.CTLOCID")
	s Sub=0
	
	f  s Sub=$O(^DHCPEIE(ParRef,"P",Sub)) q:Sub=""  d
	.s Loc=$p($g(^DHCPEIE(ParRef,"P",Sub)),"^",4)
	.q:Loc'=CurLoc
	.s ID=ParRef_"||"_Sub
	.s Price=$p($g(^DHCPEIE(ParRef,"P",Sub)),"^",1)
	.s BeginDate=$p($g(^DHCPEIE(ParRef,"P",Sub)),"^",2)
	.i BeginDate'="" s BeginDate=##class(websys.Conversions).DateLogicalToHtml(BeginDate)
	.s EndDate=$p($g(^DHCPEIE(ParRef,"P",Sub)),"^",3)
	.i EndDate'="" s EndDate=##class(websys.Conversions).DateLogicalToHtml(EndDate)
	.s SetsFlag=$p($g(^DHCPEIE(ParRef,"P",Sub)),"^",5)
	.s User=$p($g(^DHCPEIE(ParRef,"P",Sub)),"^",7)
	.i User'="" s User=$P($g(^SSU("SSUSR",User)),"^",2)
	.s Date=$p($g(^DHCPEIE(ParRef,"P",Sub)),"^",8)
	.i Date'="" s Date=##class(websys.Conversions).DateLogicalToHtml(Date)
	.d IEPriceBuild
		
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
IEPriceBuild
	set Data=$lb(ID,Price,BeginDate,EndDate,SetsFlag,User,Date)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SerchIEPriceFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SerchIEPriceExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	//
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 	Set AtEnd=1
 	Set Row=""
 	}
 	Else      {				// fetch row
 	Set Row=^CacheTemp(repid,ind)
 	}
 	// , PatientNo As %String, SurName As %String, CurrentDept As %String, CurrentBed As %String, CurrentWard As %String, CurrentDoctor As %String, StartDate As %Date, EndDate As %Date, CurrentAdmType As %String, CONTEXT As %String
 	// Save QHandlePatientNo As %String, SurName As %String, CurrentDept As %String, CurrentBed As %String, CurrentWard As %String, CurrentDoctor As %String, StartDate As %Date, EndDate As %Date, CurrentAdmType As %String	
 	s qHandle=$lb(AtEnd,repid,ind)
 	Quit $$$OK
}

Query SerchIEPrice(ParRef As %String = "") As %Query(ROWSPEC = "TRowID:%String,TPrice:%String,TBeginDate:%String,TEndDate:%String,TSetsFlag:%String,TCreateUser:%String,TCreateDate:%String")
{
}

ClassMethod SerchIESendItemClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SerchIESendItemExecute ]
{
	Set repid=$LIST(qHandle,2)
	 Kill ^CacheTemp(repid)
	 Quit $$$OK
}

ClassMethod SerchIESendItemExecute(ByRef qHandle As %Binary, ParRef As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s CurLoc=%session.Get("LOGON.CTLOCID")
	s Sub=0
	
	f  s Sub=$O(^DHCPEIE(ParRef,"SI",Sub)) q:Sub=""  d
	.s Loc=$p(^DHCPEIE(ParRef,"SI",Sub),"^",5)
	.q:Loc'=CurLoc
	.s ID=ParRef_"||"_Sub
	.s CostFeeMin=$p(^DHCPEIE(ParRef,"SI",Sub),"^",1)
	.s BeginDate=$p(^DHCPEIE(ParRef,"SI",Sub),"^",3)
	.i BeginDate'="" s BeginDate=##class(websys.Conversions).DateLogicalToHtml(BeginDate)
	.s EndDate=$p(^DHCPEIE(ParRef,"SI",Sub),"^",4)
	.i EndDate'="" s EndDate=##class(websys.Conversions).DateLogicalToHtml(EndDate)
	.s GroupFlag=$p(^DHCPEIE(ParRef,"SI",Sub),"^",6)
	.s User=$p(^DHCPEIE(ParRef,"SI",Sub),"^",8)
	.i User'="" s User=$P(^SSU("SSUSR",User),"^",2)
	.s Date=$p(^DHCPEIE(ParRef,"SI",Sub),"^",9)
	.i Date'="" s Date=##class(websys.Conversions).DateLogicalToHtml(Date)
	.s CostFeeMax=$p(^DHCPEIE(ParRef,"SI",Sub),"^",2)
	.d IESendItemBuild
		
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
IESendItemBuild      
	set Data=$lb(ID,CostFeeMin,BeginDate,EndDate,SetsFlag,User,Date,CostFeeMax)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SerchIESendItemFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SerchIESendItemExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	//
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 	Set AtEnd=1
 	Set Row=""
 	}
 	Else      {				// fetch row
 	Set Row=^CacheTemp(repid,ind)
 	}
 	// , PatientNo As %String, SurName As %String, CurrentDept As %String, CurrentBed As %String, CurrentWard As %String, CurrentDoctor As %String, StartDate As %Date, EndDate As %Date, CurrentAdmType As %String, CONTEXT As %String
 	// Save QHandlePatientNo As %String, SurName As %String, CurrentDept As %String, CurrentBed As %String, CurrentWard As %String, CurrentDoctor As %String, StartDate As %Date, EndDate As %Date, CurrentAdmType As %String	
 	s qHandle=$lb(AtEnd,repid,ind)
 	Quit $$$OK
}

Query SerchIESendItem(ParRef As %String = "") As %Query(ROWSPEC = "TRowID:%String,TCostFeeMin:%String,TBeginDate:%String,TEndDate:%String,TGroupFlag:%String,TCreateUser:%String,TCreateDate:%String,TCostFeeMax:%String")
{
}

Storage Default
{
<Data name="ItemExtendDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.ItemExtendD</DataLocation>
<DefaultData>ItemExtendDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.ItemExtendD</IdLocation>
<IndexLocation>^web.DHCPE.ItemExtendI</IndexLocation>
<StreamLocation>^web.DHCPE.ItemExtendS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
