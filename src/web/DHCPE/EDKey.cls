Class web.DHCPE.EDKey Extends %Persistent
{

ClassMethod Update(ID, Key, Color)
{
	i ID="" d
	.s obj=##class(User.DHCPEEDKey).%New()
	e  d
	.s obj=##class(User.DHCPEEDKey).%OpenId(ID)
	s obj.EDKDesc=Key
	s obj.EDKColor=Color
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q "0"
	}
}

ClassMethod Delete(ID)
{
	&SQL(Delete From Sqluser.DHC_PE_EDKey where ID=:ID)
	q SQLCODE
}

Query SearchEDKey() As %SQLQuery(ROWSPEC = "TID:%String,TDesc:%String, TColor:%String")
{
 select * from Sqluser.DHC_PE_EDKey
}

Storage Default
{
<Data name="EDKeyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.EDKeyD</DataLocation>
<DefaultData>EDKeyDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.EDKeyD</IdLocation>
<IndexLocation>^web.DHCPE.EDKeyI</IndexLocation>
<StreamLocation>^web.DHCPE.EDKeyS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
