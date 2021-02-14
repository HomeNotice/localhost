Class web.DHCPE.StationLoc Extends %Persistent
{

ClassMethod Update(Parref, LocID, LocDesc, LocSort)
{
	i LocID="" d
	.&SQL(insert into Sqluser.DHC_PE_StationLoc (STL_ParRef,STL_LocDesc,STL_LocSort) values (:Parref,:LocDesc,:LocSort))
	e  d
	.&SQL(Update Sqluser.DHC_PE_StationLoc set STL_LocDesc=:LocDesc,STL_LocSort=:LocSort where STL_RowID=:LocID)
	q SQLCODE
}

ClassMethod Delete(LocID)
{
	s Sort=""
	f  s Sort=$o(^DHCPEStationOrder("LocSort",LocID,Sort)) q:Sort=""  d
	.s Index=""
	.f  s Index=$o(^DHCPEStationOrder("LocSort",LocID,Sort,Index)) q:Index=""  d
	..s ARCID=$g(^DHCPEStationOrder("LocSort",LocID,Sort,Index))
	..k ^DHCPEStationOrder("Loc",ARCID)
	k ^DHCPEStationOrder("LocSort",LocID)

	&SQL(Delete From Sqluser.DHC_PE_StationLoc where STL_RowID=:LocID)
	q SQLCODE
}

// d ##class(%ResultSet).RunQuery("web.DHCPE.StationLoc", "SearchStationLoc","7")

Query SearchStationLoc(ParRef As %Library.String = "") As %SQLQuery(ROWSPEC = "Hidden:%String,STL_RowId:%String:ID, Hidden:%String, STL_Desc:%String:名称,STL_Sort:%String:顺序")
{
 select * from Sqluser.DHC_PE_StationLoc where STL_ParRef=:ParRef
}

ClassMethod UpdateDetail(ARCID, Sort, STLocID)
{
	s Info=$G(^DHCPEStationOrder("Loc",ARCID))
	i Info'=""
	{
		s OldSort=$P(Info,"^",2)
		q:OldSort=Sort 0
		s Index=$P(Info,"^",3)
		s STLoc=$P(Info,"^",1)
		k ^DHCPEStationOrder("Loc",ARCID)
		k ^DHCPEStationOrder("LocSort",STLoc,OldSort,Index)
	}
	s Index=$I(^DHCPEStationOrder("LocSort",STLocID,Sort))
	s ^DHCPEStationOrder("Loc",ARCID)=STLocID_"^"_Sort_"^"_Index
 	s ^DHCPEStationOrder("LocSort",STLocID,Sort,Index)=ARCID
 	q 0
}

ClassMethod DeleteDetail(ARCIMID)
{
	;d ##class(web.DHCPE.StationLoc).DeleteDetail("33046||1")
	s Info=$G(^DHCPEStationOrder("Loc",ARCIMID))
	q:Info="" -1
	s STLocID=$P(Info,"^",1)
	s Sort=$P(Info,"^",2)
	s Index=$P(Info,"^",3)
	k ^DHCPEStationOrder("Loc",ARCIMID)
 	k ^DHCPEStationOrder("LocSort",STLocID,Sort,Index)
 	q 0
}

Query SearchStationLocDetail(LocID As %String = "") As %Query(ROWSPEC = "ArcimID:%String,ARCIMDesc:%String,TSort:%String")
{
}

ClassMethod SearchStationLocDetailExecute(ByRef qHandle As %Binary, LocID As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	i LocID=""
 	{
	 	Set qHandle=$lb(0,repid,0)
		Quit $$$OK
 	}
 	s Sort=""
 	f  s Sort=$O(^DHCPEStationOrder("LocSort",LocID,Sort)) q:Sort=""  d
 	.s Index=""
 	.f  s Index=$O(^DHCPEStationOrder("LocSort",LocID,Sort,Index)) q:Index=""  d
 	..s ArcimID=$G(^DHCPEStationOrder("LocSort",LocID,Sort,Index))
	..s ARCIMDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ArcimID)
    ..d SearchStationLocDetailBuild
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
SearchStationLocDetailBuild
	set Data=$lb(ArcimID,ARCIMDesc,Sort)
	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod SearchStationLocDetailClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SearchStationLocDetailExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod SearchStationLocDetailFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = SearchStationLocDetailExecute ]
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

Storage Default
{
<Data name="StationLocDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.StationLocD</DataLocation>
<DefaultData>StationLocDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.StationLocD</IdLocation>
<IndexLocation>^web.DHCPE.StationLocI</IndexLocation>
<StreamLocation>^web.DHCPE.StationLocS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
