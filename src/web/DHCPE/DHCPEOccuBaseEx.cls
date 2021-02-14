Class web.DHCPE.DHCPEOccuBaseEx Extends %Persistent
{

ClassMethod GetData(ID)
{
	q:(ID="") ID
	
	q:'$d(^User.DHCPEPreIADMExI("PreIADMID",ID)) ""
	s ID=$o(^User.DHCPEPreIADMExI("PreIADMID",ID,0))
	s HarmInfo=..GetHarmInfo(ID)
	s EndangerWorkAge=$lg(^User.DHCPEPreIADMExD(ID),6)      ,IndustryID=$lg(^User.DHCPEPreIADMExD(ID),7)  , JobNumber=$lg(^User.DHCPEPreIADMExD(ID),4)  ,  OMETTypeID=$lg(^User.DHCPEPreIADMExD(ID),3)   , PreIADM=$lg(^User.DHCPEPreIADMExD(ID),1)    , Remark=$lg(^User.DHCPEPreIADMExD(ID),10)    ,  WorkAge=$lg(^User.DHCPEPreIADMExD(ID),5)  ,    WorkTypeID=$lg(^User.DHCPEPreIADMExD(ID),8)   
	q EndangerWorkAge_"^"_IndustryID_"^"_ JobNumber_"^"_  OMETTypeID _"^"_ PreIADM  _"^"_ Remark  _"^"_  WorkAge_"^"_    WorkTypeID_"^"_HarmInfo
}

ClassMethod Insert(String)
{
	s PreIADM=$p(String,"^",1)
	q:(PreIADM="") "更新错误,没有对应预约号"
	s EndangerWorkAge=$p(String,"^",5), IndustryID=$p(String,"^",6), JobNumber=$p(String,"^",3), OMETTypeID=$p(String,"^",2), WorkAge=$p(String,"^",4), WorkTypeID =$p(String,"^",7),Remark=""
	i $d(^User.DHCPEPreIADMExI("PreIADMID",PreIADM)) d
	.&SQL(Update Sqluser.DHC_PE_PreIADMEx set PIE_EndangerWorkAge=:EndangerWorkAge, PIE_IndustryID=:IndustryID ,PIE_JobNumber=:JobNumber, PIE_OMETTypeID=:OMETTypeID, PIE_PreIADMID=:PreIADM, PIE_Remark=:Remark, PIE_WorkAge=:WorkAge,PIE_WorkTypeID=:WorkTypeID  where PIE_PreIADMID=:PreIADM)
	else  d
	.
	.&SQL(Insert into Sqluser.DHC_PE_PreIADMEx (PIE_EndangerWorkAge,PIE_IndustryID,PIE_JobNumber,PIE_OMETTypeID,PIE_PreIADMID,PIE_Remark,PIE_WorkAge,PIE_WorkTypeID)  values
	                                                 (:EndangerWorkAge      ,:IndustryID, :JobNumber,  :OMETTypeID , :PreIADM  , :Remark  ,  :WorkAge,    :WorkTypeID ))
	q SQLCODE
	
	// ,PIE_PreIADMID,PIE_Remark,PIE_WorkAge,PIE_WorkTypeID)
	// , :PreIADMID  , :Remark  ,  :WorkAge,    :WorkTypeID ))
}

ClassMethod GetHarmInfo(IADMEx)
{
	q:(IADMEx="") IADMEx
	s Desc=""
	s IADMED=$LG(^User.DHCPEPreIADMExD(IADMEx),9)
	s EDLength=$LL(IADMED)
	f i=1:1:EDLength d
	.s IADMEDId=$LG(IADMED,i)
	.s Tmpdesc=$LG(^User.DHCPEEndangerD(IADMEDId),3)
	.s:(Desc'="") Desc=Desc_","_Tmpdesc
	.s:(Desc="") Desc=Tmpdesc
	q Desc
}

Storage Default
{
<Data name="DHCPEOccuBaseExDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.DHCPEOccuBaseExD</DataLocation>
<DefaultData>DHCPEOccuBaseExDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.DHCPEOccuBaseExD</IdLocation>
<IndexLocation>^web.DHCPE.DHCPEOccuBaseExI</IndexLocation>
<StreamLocation>^web.DHCPE.DHCPEOccuBaseExS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
