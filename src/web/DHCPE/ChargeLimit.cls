Class web.DHCPE.ChargeLimit Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

ClassMethod GetOPChargeLimitInfo(UserId As %String)
{
	q:UserId="" "0^0"
	s OPFlag=0,ASChargedFlag=0
	i $g(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","OPFlag",UserId))="Y" s OPFlag=1
	i $g(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","ASChargedFlag",UserId))="Y" s ASChargedFlag=1
	q OPFlag_"^"_ASChargedFlag
}

Query FindChargeLimit(UserId As %String = "") As %Query(ROWSPEC = "TUserId:%String,TOPNumber:%String,TName:%String,TDFLimit:%String,TOPFlag:%String,TASChargedFlag:%String")
{
}

ClassMethod FindChargeLimitExecute(ByRef qHandle As %Binary, UserId As %String = "") As %Status
{
	Set repid=$I(^CacheTemp)
 	s ind=1
 	
 	s SSUser=""
 	f  s SSUser=$o(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","DF",SSUser)) q:SSUser=""  d
 	.q:(UserId'="")&&(UserId'=SSUser)
 	.s DFLimit=$g(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","DF",SSUser))_"%"
 	.s OPFlag=$g(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","OPFlag",SSUser)) 
 	.s ASChargedFlag=$g(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","ASChargedFlag",SSUser)) 
 	.s Name=$p($g(^SSU("SSUSR",SSUser)),"^",2)
 	.s Number=$p($g(^SSU("SSUSR",SSUser)),"^",1)
	.d FindBuild	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindBuild      
	set Data=$lb(SSUser,Number,Name,DFLimit,OPFlag,ASChargedFlag)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

ClassMethod FindChargeLimitFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FindChargeLimitExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
 	Set repid=$LIST(qHandle,2)
 	Set ind=$LIST(qHandle,3)
 	Set ind=$o(^CacheTemp(repid,ind))
 	If ind="" {			
 		Set AtEnd=1
 		Set Row=""
 	}
 	Else      {			
 		Set Row=^CacheTemp(repid,ind)
 	}
 	s qHandle=$lb(AtEnd,repid,ind)
	Quit $$$OK
}

ClassMethod FindChargeLimitClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FindChargeLimitExecute ]
{
	Set repid=$LIST(qHandle,2)
 	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod OPChargeLimit(Instring As %String)
{
	s DFLimit=0,UserId=""
	s UserId=$p(Instring,"^",1)
	q:UserId="" "NoUser"
	s DFLimit=+$p(Instring,"^",2)
	s OPFlag=$p(Instring,"^",3)
	s ASChargedFlag=$p(Instring,"^",4)
	s ^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","DF",UserId)=DFLimit
	s ^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","OPFlag",UserId)=OPFlag
	s ^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","ASChargedFlag",UserId)=ASChargedFlag

	q 0
}

ClassMethod DFLimit(UserId As %String)
{
	s DFLimit=0
	i $d(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","DF",UserId)) d
	.s DFLimit=$g(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","DF",UserId))
	q DFLimit
}

ClassMethod DeleteOPChargeLimit(UserId As %String)
{
	q:UserId="" "" 
	s flag=""
	i $d(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","DF",UserId)) d
	.k ^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","DF",UserId)
	.s flag=0
	i $d(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","OPFlag",UserId)) d
	.k ^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","OPFlag",UserId)
	.s flag=0
	i $d(^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","ASChargedFlag",UserId)) d
	.k ^DHCPEDataEx("DHCPEBaseData","OPChargeLimit","ASChargedFlag",UserId)
	.s flag=0
	

	q flag
}

}
