Class web.DHCPE.SetPatItem Extends %Persistent [ ClassType = persistent, ProcedureBlock ]
{

ClassMethod Update(RowID, Strs, isDel, Type As %String = "PatItem")
{
	s loc=%session.Get("LOGON.CTLOCID")
	
	i Type'="PatItem"
	{
		s GlobalType="ReportItem"
	}else{
		s GlobalType="PatItem"
	}
	
	i isDel="1" d
	.i RowID'="" d
	..k ^DHCPEDataEx(Type,RowID)
	e  d
	.if RowID="" d
	..s RowID=+$o(^DHCPEDataEx(Type,RowID),-1)+1
	.s ^DHCPEDataEx(Type,RowID)=Strs
	.s ^DHCPEDataEx(Type,RowID,"Place",loc)=$P(Strs,"^",5)
	q 0
}

ClassMethod UpdateItemInfo(ARCIMID, Str)
{
	s ^DHCPEDataEx("PatItemSort",ARCIMID)=Str
	q 0
}

Query SetPatItem(Type As %String = "PatItem") As %Query(ROWSPEC = "TID:%String,TName:%String,TSort:%String,TDiet,TAutoChange,TPlace:%String,TIFDocSign:%String,TPatSignName:%String")
{
}

ClassMethod SetPatItemExecute(ByRef qHandle As %Binary, Type As %String = "PatItem") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s loc=%session.Get("LOGON.CTLOCID")
 	s:Type="" Type="PatItem"
 	i Type'="PatItem"
	{
		s GlobalType="ReportItem"
	}else{
		s GlobalType="PatItem"
	}
	s Job=$J
	k ^TempDHCPESetPatItem(Job)
 	s id=""
 	f  s id=$o(^DHCPEDataEx(GlobalType,id)) q:id=""  d
 	.s Strs=$G(^DHCPEDataEx(GlobalType,id))
 	.s TName=$p(Strs,"^",1)
 	.s TSort=$p(Strs,"^",2)
 	.s SortIndex=TSort
 	.s:SortIndex="" SortIndex="999999999"
 	.s TDiet=$p(Strs,"^",3)
 	.s TAutoChange=$p(Strs,"^",4)
 	.s TPlace=$G(^DHCPEDataEx("PatItem",id,"Place",loc))
 	.s TIFDocSign=$p(Strs,"^",6)
 	.s TPatSignName=$p(Strs,"^",7)
    .s Data=$lb($g(id),TName,TSort,TDiet,TAutoChange,TPlace,TIFDocSign,TPatSignName)
    .s ^TempDHCPESetPatItem(Job,SortIndex,id)=Data
    s SortIndex=""
    f  s SortIndex=$O(^TempDHCPESetPatItem(Job,SortIndex)) q:SortIndex=""  d
    .s id=""
    .f  s id=$O(^TempDHCPESetPatItem(Job,SortIndex,id)) q:id=""  d
    ..s Data=$G(^TempDHCPESetPatItem(Job,SortIndex,id))
    ..d SetPatItemBuild
	k ^TempDHCPESetPatItem(Job)
	s (id,TName,TSort,TDiet,TAutoChange,TPlace,TIFDocSign,TPatSignName)=""
	s TName="没有分类"
	s Data=$lb($g(id),TName,TSort,TDiet,TAutoChange,TPlace,TIFDocSign,TPatSignName)
	d SetPatItemBuild
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
SetPatItemBuild
	//set Data=$lb($g(id),TName,TSort,TDiet,TAutoChange,TPlace,TIFDocSign)
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SetPatItemClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SetPatItemExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod SetPatItemFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SetPatItemExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else      {			
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind)
	Quit $$$OK
}

Query SetPatItemList(PatItemName As %String = "", StationID As %String = "") As %Query(ROWSPEC = "TARCIMID:%String,TARCIMDesc:%String,TSort:%String,TPrintFlag:%String,TPrintName:%String,Index:%String")
{
}

ClassMethod SetPatItemListExecute(ByRef qHandle As %Binary, PatItemName As %String = "", StationID As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	s Job=$J
 	k ^TempDHCPESetPatItemList(Job)
 	i PatItemName=""
 	{
	 	s ARCIMID=""
	 	f  s ARCIMID=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMID)) q:ARCIMID=""  d
	 	.q:$D(^DHCPEDataEx("PatItemSort",ARCIMID))
	 	.s SortIndex="999999999"
	 	.s ^TempDHCPESetPatItemList(Job,SortIndex,ARCIMID)=""_"^"_"N"_"^"
 	}
 	else
 	{
 		s ARCIMID=""
 		f  s ARCIMID=$O(^DHCPEDataEx("PatItemSort",ARCIMID)) q:ARCIMID=""  d
 		.;i '$D(^DHCPEST(0,"STORD_ARCIM",ARCIMID)) d
 		.;.k ^DHCPEDataEx("PatItemSort",ARCIMID)
 		.s PatInfo=$G(^DHCPEDataEx("PatItemSort",ARCIMID))
 		.q:$P(PatInfo,"^",1)'=PatItemName
 		.s Sort=$P(PatInfo,"^",2)
 		.s SortIndex=Sort
 		.s:SortIndex="" SortIndex="999999999"
 		.s PrintFlag=$P(PatInfo,"^",3)
 		.s PrintName=$P(PatInfo,"^",4)
 		.s ^TempDHCPESetPatItemList(Job,SortIndex,ARCIMID)=Sort_"^"_PrintFlag_"^"_PrintName
 	}
 	s SortIndex=""
 	f  s SortIndex=$O(^TempDHCPESetPatItemList(Job,SortIndex)) q:SortIndex=""  d
 	.s ARCIMID=""
 	.f  s ARCIMID=$O(^TempDHCPESetPatItemList(Job,SortIndex,ARCIMID)) q:ARCIMID=""  d
 	..s ARCIMDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ARCIMID)
 	..s Info=$G(^TempDHCPESetPatItemList(Job,SortIndex,ARCIMID))
 	..s Sort=$P(Info,"^",1)
 	..s PrintFlag=$P(Info,"^",2)
 	..s PrintName=$P(Info,"^",3)
 	..s:PrintName="" PrintName=##class(web.DHCPE.DHCPECommon).GetArcDesc(ARCIMID)
    ..d SetPatItemListBuild
	k ^TempDHCPESetPatItemList(Job)
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
SetPatItemListBuild
	set Data=$lb(ARCIMID,ARCIMDesc,Sort,PrintFlag,PrintName,ind)
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SetPatItemListClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SetPatItemListExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod SetPatItemListFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SetPatItemListExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {				// if there are no more rows, finish fetching
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else      {			
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind)
	Quit $$$OK
}

/// w ##class(web.DHCPE.TempTools).SetTempSortStr(20)
/// 使用前首先根据导检单的顺序设置一个字符串s ^DHCPESetting("DHCPE","PatItemSort")="1^1&2^2&3^3&4^4@4"
///                                        1^1   导检单打印顺序ID^打印顺序   @4每隔多少人变化
/// d ##class(web.DHCPE.SetPatItem).UpdatePatItemSort()
ClassMethod UpdatePatItemSort()
{
	s Str=$G(^DHCPESetting("DHCPE","PatItemSort"))
	s StrTemp=$G(^DHCPESetting("DHCPE","PatItemSortTemp"))
	q:Str=""   //没有设置不操作
	s OneTypeTotal=$p(Str,"@",2)   //多少人一次轮换
	s Str=$p(Str,"@",1)
	s PersonTotal=+$G(^DHCPEDataEx("PatItemSort",+$H))
	i PersonTotal=0 d
	.s i=$l(Str,"&")
	.s ^DHCPESetting("DHCPE","PatItemSortTemp")=Str
	.for j=1:1:i  d
	..s OneStr=$p(Str,"&",j)
	..s RowID=$p(OneStr,"^",1)
	..s Sort=$p(OneStr,"^",2)
	..q:$p($G(^DHCPEDataEx("PatItem",RowID)),"^",4)'="Y"
	..s $p(^DHCPEDataEx("PatItem",RowID),"^",2)=Sort
	.s Date=+$H
	.s ^DHCPEDataEx("PatItemSort",Date)=1
	.f  s Date=$o(^DHCPEDataEx("PatItemSort",Date),-1) q:Date=""  d
	..k ^DHCPEDataEx("PatItemSort",Date) 
	e  d
	.s k=+$p(PersonTotal/OneTypeTotal,".",2)
	.i k=0 d
	..s i=$l(StrTemp,"&")
	..s LastSort=$p($p(StrTemp,"&",i),"^",2)
	..f j=i:-1:1 d
	...s OneStr=$p(StrTemp,"&",j)
	...s RowID=$P(OneStr,"^",1)
	...q:$G(^DHCPEDataEx("PatItem",RowID))=""
	...i j>1 d
	....s PreStr=$p(StrTemp,"&",j-1)
	....s PreSort=$p(PreStr,"^",2)
	....s $p(OneStr,"^",2)=PreSort
	....q:$p($G(^DHCPEDataEx("PatItem",RowID)),"^",4)'="Y"
	....s $p(^DHCPEDataEx("PatItem",RowID),"^",2)=PreSort
	...e  d
	....s $p(OneStr,"^",2)=LastSort
	....q:$p($G(^DHCPEDataEx("PatItem",RowID)),"^",4)'="Y"
	....s $p(^DHCPEDataEx("PatItem",RowID),"^",2)=LastSort
	...s $p(StrTmep,"&",j)=OneStr
	...
	..s ^DHCPESetting("DHCPE","PatItemSortTemp")=StrTmep
	.s ^DHCPEDataEx("PatItemSort",+$H)=+$G(^DHCPEDataEx("PatItemSort",+$H))+1
}

//d ##class(web.DHCPE.SetPatItem).SetPatItemSort("20")

ClassMethod SetPatItemSort(STRowId)
{
	s STORDChildSub=0
	f  s STORDChildSub=$o(^DHCPEST(STRowId,"O",STORDChildSub))  q:STORDChildSub=""  d
	.s STORDARCIMDR=$p(^DHCPEST(STRowId,"O",STORDChildSub),"^",1)
	.q:$D(^DHCPEDataEx("PatItemSort",STORDARCIMDR))
	.s ^DHCPEDataEx("PatItemSort",STORDARCIMDR)="10"
}

Storage Default
{
<Data name="SetPatItemDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.SetPatItemD</DataLocation>
<DefaultData>SetPatItemDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.SetPatItemD</IdLocation>
<IndexLocation>^web.DHCPE.SetPatItemI</IndexLocation>
<StreamLocation>^web.DHCPE.SetPatItemS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
