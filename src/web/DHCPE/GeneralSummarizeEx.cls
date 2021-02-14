/// 总检扩展业务数据操作类
Class web.DHCPE.GeneralSummarizeEx Extends %Persistent
{

ClassMethod Save(GSID, Str)
{
	s Date=+$H
	s Time=$P($H,",",2)
	s GSEXID=$O(^User.DHCPEGeneralSummarizeExI("GeneralSummarizeID",GSID,0))
 	i GSEXID="" d
 	.s obj=##class(User.DHCPEGeneralSummarizeEx).%New()
 	.d obj.GSEGeneralSummarizeIDSetObjectId(GSID)
 	e  d
 	.s obj=##class(User.DHCPEGeneralSummarizeEx).%OpenId(GSEXID)
 	d obj.GSEConclusionIDSetObjectId($P(Str,"^",1))
 	d obj.GSEDCIDSetObjectId($P(Str,"^",2))
	s obj.GSESuggestions=$P(Str,"^",3)
	s obj.GSETestResult=$P(Str,"^",4)
	s obj.GSEClinical=$P(Str,"^",5)
	s obj.GSEOccupationalHistory=$P(Str,"^",6)
	s obj.GSEDate=Date
	s obj.GSETime=Time
	//d obj.GSEUserIDSetObjectId(UserID)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
}

Storage Default
{
<Data name="GeneralSummarizeExDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.GeneralSummarizeExD</DataLocation>
<DefaultData>GeneralSummarizeExDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.GeneralSummarizeExD</IdLocation>
<IndexLocation>^web.DHCPE.GeneralSummarizeExI</IndexLocation>
<StreamLocation>^web.DHCPE.GeneralSummarizeExS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
