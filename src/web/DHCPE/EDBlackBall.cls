Class web.DHCPE.EDBlackBall Extends (%Library.RegisteredObject, websys.Abstract) [ ClassType = "", Inheritance = right, Not ProcedureBlock ]
{

ClassMethod UpdateBlackBall(ID, Parref, EDID)
{
	if (ID=""){
		&SQL(insert into SQLUser.DHC_PE_EDBlackBall (EDBB_ParRef,EDBB_ED_DR) values (:Parref,:EDID))	
	}else{
		&SQL(Update SQLUser.DHC_PE_EDBlackBall set EDBB_ED_DR=:EDID where EDBB_RowID=:ID)
		
	}
	q SQLCODE
}

ClassMethod DeleteBlackBall(ID)
{
	&SQL(Delete from SQLUser.DHC_PE_EDBlackBall where EDBB_RowID=:ID)
	q SQLCODE
}

// d ##class(%ResultSet).RunQuery("web.DHCPE.EDBlackBall", "QueryAll","2528")

Query QueryAll(Parref As %Library.String = "") As %SQLQuery(ROWSPEC = "TID:%String, TCode:%String, TDesc:%String, TDetail:%String")
{
 	select EDBB_RowID,EDBB_ED_DR->ED_Code,EDBB_ED_DR->ED_DiagnoseConclusion,EDBB_ED_DR->ED_Detail from Sqluser.DHC_PE_EDBlackBall where EDBB_Parref=:Parref
}

Storage Default
{
<Data name="EDBlackBallDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.EDBlackBallD</DataLocation>
<DefaultData>EDBlackBallDefaultData</DefaultData>
<IdLocation>^web.DHCPE.EDBlackBallD</IdLocation>
<IndexLocation>^web.DHCPE.EDBlackBallI</IndexLocation>
<StreamLocation>^web.DHCPE.EDBlackBallS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
