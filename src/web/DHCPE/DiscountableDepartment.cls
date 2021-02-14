Class web.DHCPE.DiscountableDepartment Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

/// 判断科室是否存在
/// w ##class(web.DHCPE.DiscountableDepartment).LocExist()
ClassMethod LocExist(LocId As %String = "")
{
	q $g(^DHCPESetting("DHCPE","DiscountableDepartment","LocId",LocId))
}

/// 添加\修改打折科室
/// w ##class(web.DHCPE.DiscountableDepartment).AddOrUpdateDiscountDepartment()
ClassMethod AddOrUpdateDiscountDepartment(LocId As %String = "", Activation As %String = "Y")
{
	q:LocId="" "-1"
	s Date=+$h
	s Time=$p($h,",",2)
	s User=%session.Get("LOGON.USERID")
	s ^DHCPESetting("DHCPE","DiscountableDepartment","LocId",LocId)=Activation
	s ^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",LocId,"DateTime",Date,Time,User)=Activation
	q 0
}

/// 删除打折科室
/// w ##class(web.DHCPE.DiscountableDepartment).DeleteDiscountDepartment()
ClassMethod DeleteDiscountDepartment(LocId As %String = "")
{
	q:LocId="" "-1"
	s Date=+$h
	s Time=$p($h,",",2)
	s User=%session.Get("LOGON.USERID")
	k ^DHCPESetting("DHCPE","DiscountableDepartment","LocId",LocId)
	s ^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",LocId,"DateTime",Date,Time,User)="K"
	q 0
}

/// w ##class(web.DHCPE.DiscountableDepartment).FindLastLog(1)
ClassMethod FindLastLog(Loc As %String = "")
{
	q:Loc="" ""
	s Data=""
	s LocId=Loc
	s Date=""
	f  s Date=$o(^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",LocId,"DateTime",Date)) q:Date=""  d
	.s Time=""
	.f  s Time=$o(^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",LocId,"DateTime",Date,Time)) q:Time=""  d
	..s User=""
	..f  s User=$o(^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",LocId,"DateTime",Date,Time,User)) q:User=""  d
	...s Action=$g(^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",LocId,"DateTime",Date,Time,User))
	...q:Action="K"
	...;b ;Data
	...s Data=$lb(Date,Time,User)
	q Data
}

///  搜索打折科室信息
///  d ##class(%ResultSet).RunQuery("web.DHCPE.DiscountableDepartment","SearchDiscountDepartment")
Query SearchDiscountDepartment(Loc As %String = "", Status As %String = "") As websys.Query(ROWSPEC = "TLocId:%String,TLocDesc:%String,TActivation:%String,TUpdateDate:%String,TUpdateTime:%String,TUpdateUser:%String")
{
}

ClassMethod SearchDiscountDepartmentExecute(ByRef qHandle As %Binary, Loc As %String = "", Status As %String = "") As %Status
{
	s ^tempwzh("SearchDiscountDepartmentExecute")=$lb(Loc,Status)
	k ^TempWZH("DiscountableDepartment","OrderByDate")
	s ind=1
	Set repid=$I(^CacheTemp)
	s LocId=""
	f  s LocId=$o(^DHCPESetting("DHCPE","DiscountableDepartment","LocId",LocId)) q:LocId=""  d
	.q:(Loc'="")&&(Loc'=LocId)
	.s Activation=$g(^DHCPESetting("DHCPE","DiscountableDepartment","LocId",LocId))
	.q:(Status'="")&&(Status'=Activation)
	.s LogLB=..FindLastLog(LocId)
	.b ;LogLB
	.s ^TempWZH("DiscountableDepartment","OrderByDate",$lg(LogLB,1),$lg(LogLB,2),LocId,$lg(LogLB,3))=Activation
	d OrderByDate
 	Set qHandle=$lb(0,repid,0)
 	Quit $$$OK
OrderByDate
	s Activation="",UpdateDate="",UpdateTime="",UpdateUser=""
	s Date=""
	f  s Date=$o(^TempWZH("DiscountableDepartment","OrderByDate",Date),-1) q:Date=""  d
	.b ;1
	.s Time=""
	.f  s Time=$o(^TempWZH("DiscountableDepartment","OrderByDate",Date,Time),-1) q:Time=""  d
	..b ;2
	..s LocId=""
	..f  s LocId=$o(^TempWZH("DiscountableDepartment","OrderByDate",Date,Time,LocId)) q:LocId=""  d
	...b ;3
	...s LocDesc=$p(^CTLOC(LocId),"^",2)
	...s User=""
	...f  s User=$o(^TempWZH("DiscountableDepartment","OrderByDate",Date,Time,LocId,User),-1) q:User=""  d
	....b ;4
	....s Activation=$g(^TempWZH("DiscountableDepartment","OrderByDate",Date,Time,LocId,User))
	....s UpdateDate=$zd(Date,3)
	....s UpdateTime=$zt(Time)
	....s UpdateUser=$p(^SSU("SSUSR",User),"^",2)
	....b ;5
	....d FindBuild
	q
FindBuild   
	set Data=$lb(LocId,LocDesc,Activation,UpdateDate,UpdateTime,UpdateUser)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

///  搜索打折科室操作日志
///  d ##class(%ResultSet).RunQuery("web.DHCPE.DiscountableDepartment","SearchOperationLog")
Query SearchOperationLog(Loc As %String = "") As websys.Query(ROWSPEC = "TLocId:%String,TLocDesc:%String,TStatusDesc:%String,TUpdateDate:%String,TUpdateTime:%String,TUpdateUser:%String")
{
}

ClassMethod SearchOperationLogExecute(ByRef qHandle As %Binary, Loc As %String = "") As %Status
{
	s ^tempwzh("SearchOperationLogExecute")=$lb(Loc)
	s ind=1
	Set repid=$I(^CacheTemp)
	
	i (Loc=""){
		Set qHandle=$lb(0,repid,0)
 		Quit $$$OK
		}
	
	;^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",LocId,"DateTime",Date,Time,User)
	s LocDesc=$p(^CTLOC(Loc),"^",2)
	s Date=""
	f  s Date=$o(^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",Loc,"DateTime",Date),-1) q:Date=""  d
	.s Time=""
	.f  s Time=$o(^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",Loc,"DateTime",Date,Time),-1) q:Time=""  d
	..s User=""
	..f  s User=$o(^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",Loc,"DateTime",Date,Time,User),-1) q:User=""  d
	...s Status=$g(^DHCPESetting("DHCPE","DiscountableDepartment","UpdateLog",Loc,"DateTime",Date,Time,User))
	...s StatusDesc=""
	...s:Status="Y" StatusDesc="启用"
	...s:Status="N" StatusDesc="禁用"
	...s:Status="K" StatusDesc="删除"
	...s UpdateDate=$zd(Date,3)
	...s UpdateTime=$zt(Time)
	...s UpdateUser=$p(^SSU("SSUSR",User),"^",2)
	...d FindLogBuild
 	Set qHandle=$lb(0,repid,0)
 	Quit $$$OK
FindLogBuild   
	set Data=$lb(Loc,LocDesc,StatusDesc,UpdateDate,UpdateTime,UpdateUser)
 	Set ^CacheTemp(repid,ind)=Data
 	Set ind=ind+1
 	q
}

}
