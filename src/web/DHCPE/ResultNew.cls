Class web.DHCPE.ResultNew Extends %Persistent
{

Parameter FKStation = 4;

ClassMethod GetAuditInfo(PAADM, StationID)
{
	
	s SSID=##class(web.DHCPE.ResultEdit).GetSSId(PAADM, StationID)
	s AuditUserID=""
	s AuditDate=""
	s AutoAuditUser=""
	s AuditFlag=0
	i SSID'="" d
	.s Status=$P(^DHCPESS(SSID,1),"^",7)
	.q:(Status="NA")
	.s AuditFlag=1
	.s AuditUserID=$P(^DHCPESS(SSID,1),"^",5)
	.i AuditUserID'="" s AutoAuditUser=$p(^SSU("SSUSR",AuditUserID),"^",2)
	.s AuditDate=$P(^DHCPESS(SSID,1),"^",6)
	.s:AuditDate'="" AuditDate=##class(websys.Conversions).DateLogicalToHtml(AuditDate)	
	
    q AuditUserID_"^"_AuditDate_"^"_AuditFlag_"^"_AutoAuditUser
}

ClassMethod OutAuditDocHISUI(PAADM, StationID)
{
	s UserID=%session.Get("LOGON.USERID")
	s LocID=%session.Get("LOGON.CTLOCID")
	s GroupID=%session.Get("LOGON.GROUPID")
	s WriteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))
	
	
	s SuperFlag=0
	s:$G(^DHCPESetting("DHCPE","SuperGroup"))=GroupID SuperFlag="1"
	s CompleteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"WriteWay",StationID))
	s:CompleteFlag="" CompleteFlag=3
	s AuditCpmpleteFlag=0
	s:CompleteFlag="3" AuditCpmpleteFlag=1
	
	s csdisabled=""
	s AutoAudit="N"
	s AutoAudit=$p(^DHCPEST(StationID),"^",6)
	i AutoAudit="Y" s csdisabled="disabled='disabled'"
	
	
	
	s Job=$J
	
	k ^TempDHCPEDoc(Job)
	s LocID=%session.Get("LOGON.CTLOCID")
	s UserID=""
	f  s UserID=$O(^DHCPEDataEx("ChartAssign",UserID)) q:UserID=""  d
	.s GroupID=""
	.f  s GroupID=$O(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID)) q:GroupID=""  d
	..q:$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))'="Y"
	..s ^TempDHCPEDoc(Job,UserID)=""
	s SSID=##class(web.DHCPE.ResultEdit).GetSSId(PAADM, StationID)
	s AuditUserID=""
	s AuditDate=""
	s AuditFlag=0
	i SSID'="" d
	.s Status=$P(^DHCPESS(SSID,1),"^",7)
	.q:(Status="NA")
	.s AuditFlag=1
	.s AuditUserID=$P(^DHCPESS(SSID,1),"^",5)
	.s AuditDate=$P(^DHCPESS(SSID,1),"^",6)
	.s:AuditDate'="" AuditDate=##class(websys.Conversions).DateLogicalToHtml(AuditDate)
	;style='white-space:normal; word-break:break-all;'
	w "<Table border='0' cellspacing='0' cellpadding='0' id='EDTABLE' style='width:100%;white-space:normal; word-break:break-all;'>"
	
	
	s UserID=%session.Get("LOGON.USERID")
	s ShowED=$G(^DHCPEShowEDInfo(UserID))
	;s checked="checked=checked"
	s checked=""
	s:ShowED="1" checked="checked=checked"
	
	w "<TR align='center' bgcolor='' style='white-space:normal; word-break:break-all;'>"
	w "<TD style='width:10%;white-space:normal; word-break:break-all;'></TD>"
	w "<TD style='width:30%;white-space:normal; word-break:break-all;'></TD>"
	w "<TD style='width:60%;white-space:normal; word-break:break-all;'></TD>"
	w "<TD style='width:0%;white-space:normal; word-break:break-all;'></TD>"
	w "</TR>"
	
	if (WriteFlag'="A"){
	
	
	k ^TempDHCPEDoc(Job)
	
	i AuditFlag="1" d
	.w "<tr>"
	.w "<td  colspan=4><button class='hisui-linkbutton' plain=true iconCls='icon-save' onclick='DBUpdate_click(this)' name='DBUpdate' id='DBUpdate' disabled>保存建议</button>"
	.w "<button onclick='AddEDID(this)' id='DBAddResult' class='hisui-linkbutton' plain=true iconCls='icon-add' disabled>添加建议</button>"
	.w "<button onclick='AddRecommEDID(this)' id='DBAddRecommResult' class='hisui-linkbutton' plain=true iconCls='icon-arrow-right-top' disabled>跳出建议</button>"
	.w "</tr>"
	e  d
	.w "<tr>"
	.w "<td  colspan=4><button class='hisui-linkbutton' plain=true iconCls='icon-save' onclick='DBUpdate_click(this)' name='DBUpdate' id='DBUpdate'>保存建议</button>"
	.w "<button onclick='AddEDID(this)' id='DBAddResult' class='hisui-linkbutton' plain=true iconCls='icon-add'>添加建议</button>"
	.w "<button onclick='AddRecommEDID(this)' id='DBAddRecommResult' class='hisui-linkbutton' plain=true iconCls='icon-arrow-right-top'>跳出建议</button>"
	.w "</tr>"
	}
	s colspans=2
	w "<TR align='center' bgcolor='' style='white-space:normal; word-break:break-all;'>"
	w "<TD style='white-space:normal; word-break:break-all;'>操作</TD>"
	w "<TD style='white-space:normal; word-break:break-all;'>结论</TD>"
	w "<TD style='white-space:normal; word-break:break-all;' colspan="_colspans_">建议</TD>"
	w "</TR>"
	
	i SSID'=""  d
	.s Sub=0
	.f  s Sub=$O(^DHCPESS(SSID,"Diagnosis",Sub)) q:Sub=""  d
	..s SDID=SSID_"||"_Sub
	..s DisplayDesc=$G(^DHCPEDataEx("DHCPESSDiagnosis","DisplayDesc",SDID))
	..s Advice=$P(^DHCPESS(SSID,"Diagnosis",Sub),"^",7)
	..w "<TR style='white-space:normal; word-break:break-all;'>"
	..w:AuditFlag="1" "<TD><a href='#' name='DeleteED' id='"_SDID_"'onclick='DeleteEDInfo(this,1)'><img src='../scripts_lib/hisui-0.1.0/dist/css/icons/cancel.png' border=0/></a></TD>"
	..w:AuditFlag="0" "<TD><a href='#' name='DeleteED' id='"_SDID_"'onclick='DeleteEDInfo(this,1)'><img src='../scripts_lib/hisui-0.1.0/dist/css/icons/cancel.png' border=0/></a></TD>"
	..w "<TD style='white-space:normal; word-break:break-all;'><textarea style='width:100%;white-space:normal; word-break:break-all;' rows=3 id='"_SDID_"^Desc' name='Desc'>"_DisplayDesc_"</textarea></TD>"
	..w "<TD colspan="_colspans_" style='white-space:normal; word-break:break-all;'><textarea style='width:85%;white-space:normal; word-break:break-all;' rows=3 id='"_SDID_"^Advice' name='Advice'>"_Advice_"</textarea>"
	..w "</TD>"
	..w "</TR>"
	w "</TABLE>"
	Quit $$$OK
}

ClassMethod OutResultToWebHISUI(PAADM, StationID, OEOrdItemID As %String = "")
{
	
    s LisNewVersion=$g(^DHCPESetting("DHCPE","LisNewVersion"))
	s SendPisFBWay=$G(^DHCPESetting("DHCPE","SendPisFBWay"))
	s IDStr=""
	s HighRiskSort="1"
	s UseStation="0"
	s StationDesc=""
	i StationID'="" S StationDesc=$p($g(^DHCPEST(StationID)),"^",2)
	i StationID'="" s UseStation=1
	i OEOrdItemID'="" d
	.s PAADM=$P(^OEORD(+OEOrdItemID),"^",1)
	.s ArcimID=$P(^OEORD(+OEOrdItemID,"I",$P(OEOrdItemID,"||",2),1),"^",2)
	.s StationID=$O(^DHCPEST(0,"STORD_ARCIM",ArcimID,0))
	.s LocInfo=$G(^DHCPEStationOrder("Loc",ArcimID))
	.i LocInfo'="" d
	..s StationID=$P(LocInfo,"^",1)
	s VIPInfo=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PAADM)
	
	s GSID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAADM)
	s AuditUser=""
	s:(GSID'="")&&($D(^DHCPEGS(GSID,1))) AuditUser=$P(^DHCPEGS(GSID,1),"^",5)
	///科室确认的方式
	//s CompleteFlag=3
	s UserID=%session.Get("LOGON.USERID")
	s LocID=%session.Get("LOGON.CTLOCID")
	s GroupID=%session.Get("LOGON.GROUPID")
	s SuperGroup=$g(^DHCPESetting("DHCPE","SuperGroup"))
	s SuperFlag=0
	s:$G(^DHCPESetting("DHCPE","SuperGroup"))=GroupID SuperFlag="1"
	
	s CompleteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"WriteWay",StationID))
	s:CompleteFlag="" CompleteFlag=3
	s SaveCpmpleteFlag=0
	s:CompleteFlag="2" SaveCpmpleteFlag=1
	
	s WriteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))
	
	
	s AddItemFlag=""

	i (OEOrdItemID="")&&(AuditUser="")
	{
	i +StationID=..#FKStation d
	.s HighRiskSort=2
	;i +StationID=CSStation d
	;.s AddItemFlag="0"
	;i +StationID=AddItemStation d
	;.s StationID=CSStation
	;.s AddItemFlag="1"
	}
	s ButtonType=$P(^DHCPEST(+StationID),"^",8)
	s:ButtonType="" ButtonType=1
	s OEORD=$O(^OEORD(0,"Adm",PAADM,0))
	q:OEORD="" ""
	s ResultFormat=..GetResultFormat(+StationID)
	i ResultFormat="1" d
	.s Hidden=""
	e  d
	.s Hidden="style='display:none;'"
	s Job=$J
	k ^TempDHCPEResultNew(Job)
	Set myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(PAADM)
	Set myAge=$p(myStr,"^",1)
	Set mySex=$p(myStr,"^",2)
	s RisStation=$G(^DHCPESetting("DHCPE","StationId_Ris"))
	s LabStation=$G(^DHCPESetting("DHCPE","StationId_Lab"))
	s LisInterface=$G(^DHCPESetting("DHCPE","LisInterface"))
	s SSID=##class(web.DHCPE.ResultEdit).GetSSId(PAADM, +StationID)
	s disabled=""
	s Status="NA"
	i SSID'="" d
	.s Status=$P(^DHCPESS(SSID,1),"^",7)
	.q:Status="NA"
	.s disabled="disabled='disabled'"
	w "<TABLE id='TOutResult' border=1 cellspacing='0' cellpadding='0' width=98% style='white-space:normal; word-break:break-all;'>"
	
	w "<thead><TR align='center' bgcolor='' height=20><th width=18%>项目</th><th style='cursor:hand' onclick='ShowAllResult(this)' width=47%><a href=#>结果</a></th><th width=10%>单位</th><th width=2%>提示</th><th "_Hidden_">参考值</th></TR></thead>"
	s ARCIM=""
	f  s ARCIM=$O(^OEORDi(0,"ARCIM",OEORD,ARCIM)) q:ARCIM=""  d
	.q:'$D(^DHCPEST(0,"STORD_ARCIM",ARCIM,+StationID))
	.s STSub=$O(^DHCPEST(0,"STORD_ARCIM",ARCIM,+StationID,0))
	.s ItemSort=$P(^DHCPEST(+StationID,"O",STSub),"^",7)
	.
	.s:ItemSort="" ItemSort="999999999"
	.s LocInfo=$G(^DHCPEStationOrder("Loc",ARCIM))
	.i LocInfo="" d
	..s LocSort="999999999"
	..s LocID=""
	.e  d
	..s LocID=$P(LocInfo,"^",1)
	..s LocSort=$P($g(^DHCPEST(+LocID,"STLOC",$P(LocID,"||",2))),"^",2)
	..i LocSort="" s LocSort="999999999"
	.q:($L(StationID,"||")>1)&&(LocID'=StationID)
	.s stt=""
	.f  s stt=$O(^OEORDi(0,"ARCIM",OEORD,ARCIM,stt)) q:(stt="")  d
	..s Sub=0
	..f  s Sub=$O(^OEORDi(0,"ARCIM",OEORD,ARCIM,stt,Sub)) q:(Sub="")  d
	...s Stat=$P(^OEORD(OEORD,"I",Sub,1),"^",13)
	...;q:Stat="4"
	...q:(Stat'="1")&(Stat'="6")
	...s OEORDItemID=OEORD_"||"_Sub
	...
	...q:(UseStation=0)&&(OEOrdItemID'="")&&(OEOrdItemID'=OEORDItemID)
	...s IAdm=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	...
	...;s CRMOrdID=$o(^DHCPECRMO(0,"OEORI",OEORDItemID,0))
	...;q:CRMOrdID=""
	...;s CRMOrdID=$p(^DHCPECRMO(CRMOrdID),"^",2)
	...;q:CRMOrdID=""
	...;s OSID=$p($g(^DHCPEPreIADM($p(CRMOrdID,"||",1),"ORDITEM",$p(CRMOrdID,"||",2))),"^",2)
	...;q:(AddItemFlag="0")&&(OSID="")&&(VIPInfo'["VIP")&&(%session.Get("LOGON.CTLOCID")'=572)
	...;q:(AddItemFlag="1")&&(OSID'="")
	...;s LabSpecNo=$p($G(^OEORD(+OEORD,"I",Sub,3)),"^",20)
	...;q:(LabSpecNo'="")&&($D(^TempDHCPEResultNewLabSpecNo(Job,LabSpecNo)))
	...;s:(LabSpecNo'="") ^TempDHCPEResultNewLabSpecNo(Job,LabSpecNo)=""
	...;s OEORDItemInfo=..GetLisOrdItem(OEORDItemID)
	...;s OEORDItemID=$P(OEORDItemInfo,"^",1)
	...;s ARCIMDesc=$P(OEORDItemInfo,"^",2)_"^"_OEORDItemID
	...
	...s ^TempDHCPEResultNew(Job,LocSort,ItemSort,OEORDItemID)=ARCIM_"^"_""
	k ^TempDHCPEResultNewLabSpecNo(Job)
	s PersonID=$P(^PAADM(PAADM),"^",1)
	s PrevPAADM=$O(^PAPERdr(PersonID,"ADM","H",PAADM),-1)
	s namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	s IAdm=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	s i=0
	s TSInfo=""
	s LocSort=""
	f  s LocSort=$O(^TempDHCPEResultNew(Job,LocSort)) q:LocSort=""  d
	.s TSInfo=""
	.s ItemSort=""
	.f  s ItemSort=$O(^TempDHCPEResultNew(Job,LocSort,ItemSort)) q:ItemSort=""  d
	..s OEORDItemID=""
	..f  s OEORDItemID=$O(^TempDHCPEResultNew(Job,LocSort,ItemSort,OEORDItemID)) q:OEORDItemID=""  d
	...s i=i+1
	...s ARCIM=$G(^TempDHCPEResultNew(Job,LocSort,ItemSort,OEORDItemID))
	...s ARCDesc=$P(ARCIM,"^",2)  //$P(^ARCIM(+ARCIM,1,1),"^",2)
	...s:ARCDesc="" ARCDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ARCIM)
	...s ARCIM=$P(ARCIM,"^",1) 
	...s OEORD=+OEORDItemID
	...s Sub=$P(OEORDItemID,"||",2)
	...s PaiedStatus=$p(^OEORD(OEORD,"I",Sub,3),"^",5)
	
	...i (PaiedStatus'="P")&&(IAdm'="") d
	....w "<TR><TD colspan=6>"
	....w ARCDesc_"<B>未付费</B>"
	....w "</TD></TR>"
	...q:(PaiedStatus'="P")&&(IAdm'="")
	...d ##class(web.DHCPE.TransResult).TransExtendItem(PAADM,OEORDItemID,UserID)
	...i (OEOrdItemID="")||((OEOrdItemID'="")&&(+StationID'=LabStation)) d
	....s HiddenStyle=""
	....;s:ARCDesc="LCT" ResultDisabled=""
	....;s:ARCDesc="LCT" HiddenStyle="style='display:none'"
	....;s:ARCDesc="HPV" HiddenStyle="style='display:none'"
	....w "<TR "_HiddenStyle_"><TD>"  //项目名称、录入医生、录入时间
	....s lnk="../csp/dhcpepatresulthistory.old.csp?OEORIRowId="_OEORDItemID
	....w "<a href='#' id='"_OEORDItemID_"^history' onclick='ShowResultHistory(this)'><img src='../scripts_lib/hisui-0.1.0/dist/css/icons/eye.png' border=0/>"_ARCDesc_"</a>"
	....;w "<input type='checkbox' name='PrintFlag' id=Print"_OEORDItemID_">"
	....w "</TD>"
	....s disabled=""
	....s RLTOEType="",DefaultDocStr="",DocUserId=""
	....s RLTID=$O(^DHCPERLT(0,"OEORI",OEORDItemID,0))
	....
	....i RLTID'="" d
	.....s DocName=$P(^DHCPERLT(RLTID),"^",5)
	.....i +StationID'=LabStation d
	......s DocUserId=DocName
	......i DocUserId'="" d
	.......s DocName=$P($g(^SSU("SSUSR",DocUserId)),"^",2)
	.......s DocId=$P($g(^SSU("SSUSR",DocUserId)),"^",14)
	.......i DocId'="" s DocOtherName=$p($G(^CTPCP(DocId,3)),"^",28)
	.......e  s DocOtherName=""
	.......s DefaultDocStr=DocUserId_$C(1)_DocName_"-"_DocOtherName
	.....e  d
	......s RLTOEType="Lab"
	......s:(DocName'="")&&(LisNewVersion'="Y") DocName=$P($G(^[namespaceLab]SSU("SSUSR",1,DocName)),"^",2)
	......s:(DocName'="")&&(LisNewVersion="Y") DocName=$P(^SSU("SSUSR",DocName),"^",2)
	......;s:DocName'="" DocName=$P($G(^[namespaceLab]SSU("SSUSR",1,DocName)),"^",2)
	.....s CheckDate=$P(^DHCPERLT(RLTID),"^",6)
	.....s:CheckDate'="" CheckDate=##class(websys.Conversions).DateLogicalToHtml(CheckDate)
	....e  d
	.....s DocName=""
	.....s CheckDate=""
	....w "<TD colspan=4>" ;style='white-space:normal; word-break:break-all;'
	....w "<TABLE width=100% border=0 cellspacing='0' cellpadding='0'><TR><TD width=0>"
	....w "<input id='RLTOEType' name='RLTOEType' type='hidden' value='"_RLTOEType_"'>"

	....w "<input id='DefaultDocStrz"_OEORDItemID_"' name='DefaultDocStrz"_OEORDItemID_"' type='hidden' value='"_DefaultDocStr_"'>"
	
	....
	....i (OEOrdItemID="") w "<td>医生<input class='hisui-combobox' type='text' id='DocNamez"_OEORDItemID_"' name='DocNamez"_OEORDItemID_"'  style='width:150px;white-space:normal; word-break:break-all;' onkeydown='nextfocus(this);' value='"_DocName_"'></td>"
	....e  w "<td>医生<input id='DocNamez"_OEORDItemID_"' name='DocNamez"_OEORDItemID_"'  style='width:150px;white-space:normal; word-break:break-all;' onkeydown='nextfocus(this);' value='"_DocName_"'></td>"
	....w "<td>日期<input class='hisui-datebox' type='text' id='CheckDatez"_OEORDItemID_"' name='CheckDatez"_OEORDItemID_"'  style='width:120px;white-space:normal; word-break:break-all;' onkeydown='nextfocus(this);' value="_CheckDate_"></td>"
	....;q:WriteFlag'="Y"
	....i +StationID'=LabStation d
	.....
	.....s LabInfo="保存结果"
	.....s Savedisabled=""
	.....s ResultDisabled=""
	.....i RLTID'="" d
	......
	......s ResultDisabled="disabled='disabled'"
	......s ResultDisabled="readonly"
	......i Status'="NA" d
	.......s LabInfo="已提交"
	.......s Savedisabled="disabled='disabled'"
	.......s disabled="disabled='disabled'"
	......e  d
	.......s LabInfo="修改结果"
	.......s Savedisabled=""
	.......s disabled="disabled='disabled'"
	.....
	.....i SuperFlag=1 d
	......s LabInfo="保存结果"
	......s Savedisabled=""
	......s ResultDisabled=""
	.....i WriteFlag="N" d
	......s Savedisabled="disabled='disabled'"
	......s ResultDisabled="disabled='disabled'"
	......s ResultDisabled="readonly"
	.....s:ARCDesc="LCT" LabInfo="保存结果"
	.....s:ARCDesc="HPV" LabInfo="保存结果"
	.....i (SuperFlag'="1")&&(""'=UserID)&&(""'=DocUserId)&&(UserID'=DocUserId)&&(+StationID'=4)&&(+StationID'=26)&&(+StationID'=13)&&(+StationID'=14)&&(+StationID'=8)&&(+StationID'=17)&&(+StationID'=27) d
	......s LabInfo="<b>非本人</b>"
	......s Savedisabled="disabled='disabled'"
	......s disabled="disabled='disabled'"
	
	.....I SendPisFBWay'="F" D
	......s HiddenPis="style='display:none;'"
	.....I SendPisFBWay="F" D
	......s HiddenPis=""

	.....i OEOrdItemID="" d
    ......;w "<tr>"
	......w "<td><button class='hisui-linkbutton' stopAllEventOnDisabled=true plain=true iconCls='icon-save' style='width:80;white-space:normal; word-break:break-all;' onclick='SavePEResult(this,"_SaveCpmpleteFlag_")' id='"_OEORDItemID_"^"_SaveCpmpleteFlag_"^"_WriteFlag_"' name='Update' "_Savedisabled_">"_LabInfo_"</button></td>"
	
	......;w:ButtonType="2" "<button style='width:15%;white-space:normal; word-break:break-all;' onclick='SendPEMessage(this)' id='"_OEORDItemID_"' name='SendMessage'>发送短信</button>"
	......;w:(ButtonType="2") "<td><button class='i-btn' style='width:80;white-space:normal; word-break:break-all;' onclick='PrintPisRequest(this)' id='"_OEORDItemID_"' name='PisRequest' "_disabled_" "_HiddenPis_">打印病理申请</button></td>"
	......w:(StationDesc["病理") "<td><button class='i-btn' style='width:80;white-space:normal; word-break:break-all;' onclick='PrintPisRequest(this)' id='"_OEORDItemID_"' name='PisRequest' "_disabled_" "_HiddenPis_">打印病理申请</button></td>"
	......;w:(ButtonType="3")&&(i=1) "<td><button class='i-btn' style='white-space:normal; word-break:break-all;' onclick='DealPEExe(this)' id='"_OEORDItemID_"' name='DealExe' "_disabled_">影像采集</button>"
	......w "<td><button class='hisui-linkbutton' plain=true iconCls='icon-arrow-left-top' style='width:100;white-space:normal; word-break:break-all;' onclick='SetNormalText(this)' id='"_OEORDItemID_"' name='SetNoramText' "_disabled_">重置默认值</button></td>"
	......s HighRiskLabel="高危上报"
	......w "<td><button class='hisui-linkbutton' plain=true iconCls='icon-star-yellow' style='width:60;white-space:normal; word-break:break-all;' onclick='SendHighRisk(this)' id='"_OEORDItemID_"' name='HighRiskText'>"_HighRiskLabel_"</button></td>"
	......;w "<td><button class='i-btn' style='width:80;white-space:normal; word-break:break-all;' onclick='GetEqData(this)' id='"_OEORDItemID_"' name='GetComData'>获取数据</button></td>"
	......;w "</tr>"
	....w "</TD></TR></TABLE></TD></TR>"
	...;s:ARCDesc="LCT" ResultDisabled="",disabled=""
	...;s:ARCDesc="HPV" ResultDisabled="",disabled=""
	...i LabStation'=+StationID d
	....i $D(^DHCPEODR(0,"Cascade",ARCIM)) d
	.....s Cascade=0
	.....f  s Cascade=$O(^DHCPEODR(0,"Cascade",ARCIM,Cascade)) q:Cascade=""  d
	......s CascadeSort=""
	......f  s CascadeSort=$O(^DHCPEODR(0,"Cascade",ARCIM,Cascade,CascadeSort)) q:CascadeSort=""  d
	.......s ODRRowID=""
	.......f  s ODRRowID=$O(^DHCPEODR(0,"Cascade",ARCIM,Cascade,CascadeSort,ODRRowID)) q:ODRRowID=""  d
	........i $D(^DHCPEODR(0,"ParentDR",ODRRowID)) d
	.........s ODID=$P(^DHCPEODR(ODRRowID),"^",2)
	.........s ODDesc=$P($G(^DHCPEST(+ODID,"OD",$P(ODID,"||",2))),"^",1)
	.........w "<TR><TD>"_ODDesc_"</TD></TR>"
	.........s ParentSort=""
	.........f  s ParentSort=$O(^DHCPEODR(0,"ParentDR",ODRRowID,ParentSort)) q:ParentSort=""  d
	..........s ODRID=0
	..........f  s ODRID=$O(^DHCPEODR(0,"ParentDR",ODRRowID,ParentSort,ODRID)) q:ODRID=""  d
	...........d CreateOneDetail
	........e  d
	.........s ODRID=ODRRowID
	.........q:Cascade=2
	.........d CreateOneDetail
	....e  d
	.....;^DHCPEODR(0,"Sequence",ARCIM,Sequence)
	.....s Sequence=0
	.....f  s Sequence=$O(^DHCPEODR(0,"Sequence",ARCIM,Sequence)) q:Sequence=""  d
	......s ODRID=0
	......f  s ODRID=$O(^DHCPEODR(0,"Sequence",ARCIM,Sequence,ODRID)) q:ODRID=""  d
	.......d CreateOneDetail
	
	...e  d
	....k ^TempDHCPEOD(Job)
	....s ShowSort=""
	....f  s ShowSort=$O(^DHCPERLT(0,"OrdSort",OEORDItemID,ShowSort)) q:ShowSort=""  d
	.....s RLTID=""
	.....f  s RLTID=$O(^DHCPERLT(0,"OrdSort",OEORDItemID,ShowSort,RLTID)) q:RLTID=""  d
	......s ODID=$P(^DHCPERLT(RLTID),"^",3)
	......q:ODID=""
	......q:$D(^TempDHCPEOD(Job,ODID))
	......s ^TempDHCPEOD(Job,ODID)=""
	......q:+ODID=0
	......s ODDesc=$P($G(^DHCPEST(+ODID,"OD",$P(ODID,"||",2))),"^",1)
	......s:ODDesc="tx4(t7,t8,t11,t12,t14)" ODDesc="tx4(白栎,美洲榆,英国梧桐树,柳树,美洲黑杨)"
	......s:ODDesc="tx10(t2,t3,t4,t15)" ODDesc="tx10(灰桤木,疣皮桦,欧洲榛,美国白蜡)"
	......s TSInfo=""
	......s Type=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
	......s DefaultValue=$P(^DHCPERLT(RLTID),"^",4)
	......s DefaultValue=..ChangeHtmlToStr(DefaultValue)
	......s ElementID=OEORDItemID_"^"_ODID
	
	......//i LisInterface="Y" d
	......i $D(^DHCPEDataEx("DHCPEResult",RLTID,"Unit")) d
	.......s Unit=$G(^DHCPEDataEx("DHCPEResult",RLTID,"Unit"))
	.......s NormalStr=$G(^DHCPEDataEx("DHCPEResult",RLTID,"Ranges"))
	......e  d
	.......s Unit=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",4)
	.......s NormalStr=##class(web.DHCPE.ResultEdit).GetNormal(ODID, mySex, myAge)
	......s TSInfo=""
	......s HighFlag=$P(^DHCPERLT(RLTID),"^",12)
	......s NormalFlag=$P(^DHCPERLT(RLTID),"^",7)
	......i NormalFlag=0 d
	.......s TSInfo="<font color=red>*</font>"
	.......s:Type="N" TSInfo=##class(web.DHCPE.TransResult).GetLabResultArrowNew(RLTID)
	.......s:(TSInfo="1") TSInfo=""
	.......s:TSInfo="2" TSInfo="<font color=red>↑</font>"
	.......s:TSInfo="0" TSInfo="<font color=red>↓</font>"
	......s:NormalStr="" NormalStr="&nbsp;"
	......s:Unit="" Unit="&nbsp;"
	......s style=""
	......s:NormalFlag=0 style=";color: #FF0000"
	......;s:NormalFlag=0 ODDesc="<font color=red>"_ODDesc_"</font>"
	......;s:HighFlag="Y" ODDesc="<font color=yellow>"_ODDesc_"</font>"
	......s EnDetailFlag=##class(web.DHCPE.Endanger).IsEDDetail(PAADM,ARCIM,ODID)
	......s BGColor=""
	......s:EnDetailFlag="1" BGColor="#808000"
	......w "<TR bgcolor='"_BGColor_"'><TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_ODDesc_"</TD>"
	......w "<TD>"
	......w "<input style='white-space:normal; word-break:break-all;width:100%;font-size:18px"_style_"' onkeydown='nextfocus(this);' onclick='resultClick(this);' onchange='resultchange(this)' ondblclick='detailStandard(this);' id='"_ElementID_"' name='"_OEORDItemID_" "_disabled_"' value="_DefaultValue_">"
	......w "</TD>"
	......w "<TD onclick='RemoveAllDiv(1)' style='white-space:normal; word-break:break-all;'>"_Unit_"</TD>"
	......w "<TD onclick='RemoveAllDiv(1)' style='white-space:normal; word-break:break-all;'>"_TSInfo_"</TD>"
	......w "<TD onclick='RemoveAllDiv(1)' id="_ElementID_"S style='white-space:normal; word-break:break-all;'>"_NormalStr_"</TD>"
	.....w "</TR>"
	....k ^TempDHCPEOD(Job)
	...w "</TR>"
	w "</TABLE>"
	k ^TempDHCPEResultNew(Job)
	q IDStr
CreateOneDetail
	s ODID=$P(^DHCPEODR(ODRID),"^",2)
	q:ODID=""
	
	s EnDetailFlag=##class(web.DHCPE.Endanger).IsEDDetail(PAADM,ARCIM,ODID)
	s BGColor=""
	s:EnDetailFlag="1" BGColor="#808000"
	
	s PrevCode=""
	i PrevPAADM'="" d
	.s PrevRLTID=0
	.f  s PrevRLTID=$O(^DHCPERLT(0,"PAADM_OD",PrevPAADM,ODID,PrevRLTID)) q:PrevRLTID=""  d
	..s ARCID=$P(^DHCPERLT(PrevRLTID),"^",2)
	..q:ARCID'=ARCIM
	..s Flag=$P(^DHCPERLT(PrevRLTID),"^",7)
	..s:Flag=0 PrevCode="<font color=red>***</font>"
	s MustFlag=$P(^DHCPEODR(ODRID),"^",4)
	s MustInfo=""
	s:MustFlag="Y" MustInfo="<font color=red>*</font>"
	s Type=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
	s DetailDisabled=""
	i Type="C" s DetailDisabled="disabled='disabled'"
	s ODDesc=PrevCode_$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",1)_MustInfo
	s TextRows=1
	s:ODDesc="既往史" TextRows=2
	s Unit=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",4)
	s:Unit="" Unit="&nbsp;"
	s Compute=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",3)
	s Code=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",11)
	s Sex=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",9)
	q:((Sex'="N")&&(Sex'=""))&&(Sex'=mySex)
	s NormalStr=##class(web.DHCPE.ResultEdit).GetNormal(ODID, mySex, myAge)
	s ElementID=OEORDItemID_"^"_ODID
	s DefaultValue=""
	s NumFlag=0
	s:(Type="C")||(Type="N") NumFlag=1
	i $D(^DHCPERLT(0,"ADMOD",PAADM,OEORDItemID)) d
	.s NormalFlag=1
	.s RltID=$O(^DHCPERLT(0,"ADMOD",PAADM,OEORDItemID,ODID,0))
	.i RltID'="" d
	..s DefaultValue=$P(^DHCPERLT(RltID),"^",4)
	..s NormalFlag=$P(^DHCPERLT(RltID),"^",7)
	..s HighFlag=$P(^DHCPERLT(RltID),"^",12)
	..s TSInfo=""
	..i NormalFlag=0 d
	...s TSInfo="<font color=red>*</font>"
	...s:(Type="N")||(Type="C") TSInfo=##class(web.DHCPE.TransResult).GetLabResultArrowNew(RltID)
	...s:(TSInfo="1") TSInfo=""
	...s:TSInfo="2" TSInfo="<font color=red>↑</font>"
	...s:TSInfo="0" TSInfo="<font color=red>↓</font>"
	e  d
	.s NormalFlag=1
	.s HighFlag="N"
	.s TSInfo=""
	.i (Type="S")||(Type="T") s DefaultValue=NormalStr
	.s:OEOrdItemID'="" DefaultValue=""
	s:NormalStr="" NormalStr="&nbsp;"
	s style=""
	s:NormalFlag=0 style=";color: #FF0000"
	i ("^"_RisStation_"^")[("^"_StationID_"^")&(OEOrdItemID'="") d
	.s style=";color: #2c2c2c"
	i ResultFormat="3" d
	.s DetailDesc=$P(ODDesc,"-",1)
	.;w "<TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_DetailDesc_"检查结论"_"</TD>"
	.w "<TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_DetailDesc_"检查所见"_"</TD>"
	.w "<TD colspan=3 style='white-space:normal; word-break:break-all;'>"
	.s DefaultValue=##class(web.DHCPE.Public.Setting).Replace(DefaultValue,"@@",$c(13,10))
	.s ZDDefaultValue=""
	.s EyeSeeDefaultValue=""
	.i $L(DefaultValue,";诊断意见:")>1 d
	..s ZDYJ=$p(DefaultValue,";诊断意见:",2)
	..s ZDYJ=##class(web.DHCPE.Public.Setting).Replace(ZDYJ,"_$c(13,10)_","  ")
	..s ZDYJ=##class(web.DHCPE.Public.Setting).Replace(ZDYJ,"_$c_","  ")
	..s Other=$p(DefaultValue,";诊断意见:",1)
	..s ZDDefaultValue=ZDYJ
	..i ZDYJ'="" s ZDYJ="诊断意见:"_ZDYJ
	..s JCSJ=$p(Other,";检查所见:",2)
	..s JCSJ=##class(web.DHCPE.Public.Setting).Replace(JCSJ,"_$c(13,10)_","  ")
	..s JCSJ=##class(web.DHCPE.Public.Setting).Replace(JCSJ,"_$c_","  ")
	..s EyeSeeDefaultValue=JCSJ
	..i JCSJ'="" s JCSJ="检查所见:"_JCSJ
	..s Other=$p(Other,";检查所见:",1)
	..s LCZD=$p(Other,"临床诊断:",2)
	..s LCZD=##class(web.DHCPE.Public.Setting).Replace(LCZD,"_$c(13,10)_","  ")
	..s LCZD=##class(web.DHCPE.Public.Setting).Replace(LCZD,"_$c_","  ")
	..i LCZD'="" s LCZD="临床诊断:"_LCZD
	..s JCJG=""
	..i LCZD'="" s JCJG=LCZD_$C(13)
	..i JCSJ'="" s JCJG=JCJG_JCSJ_$C(13)
	..i ZDYJ'="" s JCJG=JCJG_ZDYJ_$C(13)
	..s DefaultValue=JCJG ;style='white-space:normal; word-break:break-all;'
	.e  d
	..s ZDDefaultValue=DefaultValue
	..s EyeSeeDefaultValue=""
	.s DefaultValue=..ChangeHtmlToStr(DefaultValue)
	.s ZDDefaultValue=..ChangeHtmlToStr(ZDDefaultValue)
	.s EyeSeefaultValue=..ChangeHtmlToStr(EyeSeeDefaultValue)
	.w "<textarea style='white-space:normal; word-break:break-all;width:100%"_style_"' rows=6 onkeydown='resultClick(this);' onclick='resultClick(this);' onselectstart='resultSelectStart(this)' onchange='resultchange(this)' ondblclick='detailStandard(this);' "_DetailDisabled_" id='"_ElementID_"^EyeSee"_"' name='"_OEORDItemID_"^EyeSee' "_$G(ResultDisabled)_">"_EyeSeeDefaultValue_"</textarea>"
	.w "<TD "_Hidden_"onclick='RemoveAllDiv(1)' id="_ElementID_"S style='white-space:normal; word-break:break-all;'>"_NormalStr_"</TD>"
	.w "</TD>"
	.w "</TR><TR>"
	.;w "<TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_DetailDesc_"检查所见"_"</TD>"
	.w "<TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_DetailDesc_"诊断意见"_"</TD>"
	.w "<TD colspan=3 style='white-space:normal; word-break:break-all;'>"
	.w "<textarea style='white-space:normal; word-break:break-all;width:100%"_style_"' rows=6 onkeydown='resultClick(this);' onclick='resultClick(this);' onselectstart='resultSelectStart(this)' onchange='resultchange(this)' ondblclick='detailStandard(this);' "_DetailDisabled_" id='"_ElementID_"' name='"_OEORDItemID_"' "_$G(ResultDisabled)_">"_ZDDefaultValue_"</textarea>"
	
	.w "<TD "_Hidden_"onclick='RemoveAllDiv(1)' id="_ElementID_"S style='white-space:normal; word-break:break-all;'>"_NormalStr_"</TD>"
	.w "</TD>"
	.q:Type="C"
	.i IDStr="" d
	..s IDStr=ElementID_"&"_ElementID_"^EyeSee"
	.e  d
	..s IDStr=IDStr_"&"_ElementID_"&"_ElementID_"^EyeSee"
	
	e  d
	.;s:NormalFlag=0 ODDesc="<font color=red>"_ODDesc_"</font>"
	.;s:HighFlag="Y" ODDesc="<font color=yellow>"_ODDesc_"</font>"
	.w "<TR bgcolor='"_BGColor_"' style='white-space:normal; word-break:break-all;'><TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_ODDesc_"</TD>"
	
	.i ResultFormat="1" d
	..s DefaultValue=..ChangeHtmlToStr(DefaultValue)
	..w "<TD style='white-space:normal; word-break:break-all;'>"
	..w "<textarea style='white-space:normal; word-break:break-all;width:97%"_style_"' rows='"_TextRows_"' onkeydown='MoveFocus(this,"_NumFlag_");' onclick='resultClick(this);' onselectstart='resultSelectStart(this)' onchange='resultchange(this)' ondblclick='detailStandard(this);' "_DetailDisabled_" id='"_ElementID_"' name='"_OEORDItemID_"' "_$G(ResultDisabled)_">"_DefaultValue_"</textarea>"
	..w "</TD>"
	..w "<TD onclick='RemoveAllDiv(1)'>"_Unit_"</TD>"
	..s:$G(TSInfo)="" TSInfo="&nbsp;"
	..w "<TD onclick='RemoveAllDiv(1)'>"_TSInfo_"</TD>"
	..w "<TD onclick='RemoveAllDiv(1)' id="_ElementID_"S>"_NormalStr_"</TD>"
	.e  d
	..s DefaultValue=..ChangeHtmlToStr(DefaultValue)
	..w "<TD colspan=3 style='white-space:normal; word-break:break-all;'>"
	..w "<textarea style='white-space:normal; word-break:break-all;width:100%"_style_"' rows='"_TextRows_"' onkeydown='MoveFocus(this,"_NumFlag_");' onclick='resultClick(this);' onselectstart='resultSelectStart(this)' onchange='resultchange(this)' ondblclick='detailStandard(this);' "_DetailDisabled_" id='"_ElementID_"' name='"_OEORDItemID_"' "_$G(ResultDisabled)_">"_DefaultValue_"</textarea>"
	..w "<TD "_Hidden_"onclick='RemoveAllDiv(1)' id="_ElementID_"S style='white-space:normal; word-break:break-all;'>"_NormalStr_"</TD>"
	..w "</TD>"
	.q:Type="C"
	.i IDStr="" d
	..s IDStr=ElementID
	.e  d
	..s IDStr=IDStr_"&"_ElementID
	w "</TR>"
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.ResultNew","FindDiagnosisPatInfo","","2018-10-29")
Query FindDiagnosisPatInfo(RegNo, BDate, EDate, VIP) As websys.Query(ROWSPEC = "PaadmID:%String,PAPMINo:%String,AdmDate:%String,Name:%String,Age:%String,Sex:%String,VIPLevel:%String,VIPDesc:%String")
{
}

ClassMethod FindDiagnosisPatInfoExecute(ByRef qHandle As %Binary, RegNo, BDate, EDate, VIP) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    
     if (RegNo="")
    {
	i (BDate="") s BDate=+$h-7
	i (EDate="") s EDate=+$h
	i BDate'="" s BDate=##class(websys.Conversions).DateHtmlToLogical(BDate) 
	i EDate'=""  s EDate=##class(websys.Conversions).DateHtmlToLogical(EDate) 
	
	    
	s Date=BDate-1
 	f  s Date=$o(^DHCPEIADM(0,"AdmDateTime",Date)) q:(Date="")||(Date>EDate)  d
 	.s time=0
 	.f  s time=$o(^DHCPEIADM(0,"AdmDateTime",Date,time)) q:(time="")  d
 	..s IADM=0
 	..f  s IADM=$o(^DHCPEIADM(0,"AdmDateTime",Date,time,IADM)) q:(IADM="")  d
 	...s PIADM=$p(^DHCPEIADM(IADM),"^",4)
 	...s Status=$p(^DHCPEIADM(IADM),"^",8)
 	...q:Status'="ARRIVED"
 	...s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PIADM)
 	...q:LocFlag="1" 
	...s PBID=$p(^DHCPEPreIADM(PIADM),"^",1) 
	...s VIPLevel=+##class(web.DHCPE.PreCommon).GetVIPLevel("Pre",PIADM)
 	...q:(VIP'="")&&(VIP'=VIPLevel)
 	...s PAPMINo=$p(^DHCPEPreIBI(PBID),"^",1)
 	...s Name=$p(^DHCPEPreIBI(PBID),"^",2)
 	...s PaadmID=##class(web.DHCPE.DHCPEIAdm).GetPAADMByPADM(PIADM)  
 	...s PaPatID=$P(^PAADM(PaadmID),"^",1)
 	...s Sex=$P(^PAPER(PaPatID,"ALL"),"^",7)
	...s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
    ...s Age=##class(web.DHCBillInterface).GetPapmiAge(PaPatID,"")
    ...s (VIPLevel,VIPDesc)=""
 	...s AdmDate=$P(^PAADM(PaadmID),"^",6)
	...s AdmDate=##class(websys.Conversions).DateLogicalToHtml(AdmDate)
	...s VIPStr=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PaadmID)
	...i VIPStr'="" d
	....s VIPLevel=$p(VIPStr,"^",1)
	....s VIPDesc=$p(VIPStr,"^",2)
    ...s ^CacheTemp(repid,ind)=$lb(PaadmID,PAPMINo,AdmDate,Name,Age,Sex,VIPLevel,VIPDesc)
	...s ind=ind+1
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
 	
 	  
	}
    
    else
    {
   	s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
	s RegNoIndex=RegNo
	s RegNoIndex=$ZCVT(RegNoIndex,"U")
	s PaPatID=$O(^PAPERi("PAPMI_PatNo",RegNoIndex,0))
	if (PaPatID="")
    {
	  	Set qHandle=$lb(0,repid,0)
		Quit $$$OK  
	}
    s PAPMINo=$P(^PAPER(PaPatID,"PAT",1),"^",1)
    s Name=$P(^PAPER(PaPatID,"ALL"),"^",1)
	s Sex=$P(^PAPER(PaPatID,"ALL"),"^",7)
	s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
    s Age=##class(web.DHCBillInterface).GetPapmiAge(PaPatID,"")
    s (VIPLevel,VIPDesc)=""
    s ArriveFlag=0
	s LocID=%session.Get("LOGON.CTLOCID")
	s PaadmID=""
	f  s PaadmID=$O(^PAPERdr(PaPatID,"ADM","H",PaadmID),-1) q:PaadmID=""  d
	.s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PAADM",PaadmID)
	.q:(LocFlag=1)&&($D(^DHCPESetting("DHCPE","DefaultPAADM",LocID)))
	.s PIADM=$O(^DHCPEIADM(0,"PAADM",PaadmID,0))
	.q:PIADM=""
	.s PreIADM=$P(^DHCPEIADM(PIADM),"^",4)
	.//第一个为医生界面自动到达\第二个为打印条码自动到达
	.s AutoArrived=$G(^DHCPESetting("DHCPE","AutoArrived",LocID))
	.s AutoArrived=$p(AutoArrived,"^",1)
	.i AutoArrived="Y" d
	..d:ArriveFlag=0 ##class(web.DHCPE.DHCPEIAdm).IAdmArrived(PreIADM)
	.s ArriveFlag=1
	.q:##class(web.DHCPE.ResultEdit).IsArrivedStatu(PaadmID)="0"
	.s AdmDate=$P(^PAADM(PaadmID),"^",6)
	.;q:(AdmDate<StartDate)||(AdmDate>EndDate)
	.s AdmDate=##class(websys.Conversions).DateLogicalToHtml(AdmDate)
	.;d ##class(web.DHCPE.TransResult).TransMain(PaadmID)
	.s VIPStr=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PaadmID)
	.i VIPStr'="" d
	..s VIPLevel=$p(VIPStr,"^",1)
	..s VIPDesc=$p(VIPStr,"^",2)
    .s ^CacheTemp(repid,ind)=$lb(PaadmID,PAPMINo,AdmDate,Name,Age,Sex,VIPLevel,VIPDesc)
	.s ind=ind+1
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
    }
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.ResultNew","FindCallVoicePatInfo","1","")
Query FindCallVoicePatInfo(RegNo, RoomID) As websys.Query(ROWSPEC = "PaadmID:%String,PAPMINo:%String,AdmDate:%String,Name:%String,Age:%String,Sex:%String,VIPLevel:%String,VIPDesc:%String,Status:%String,RecordID:%String,DetailStatus:%String")
{
}

ClassMethod FindCallVoicePatInfoExecute(ByRef qHandle As %Binary, RegNo, RoomID) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    s Job=$J
   s ^tempdhcpe("CanCheck","1")=RegNo_"^"_RoomID
    if (RegNo="")
    {

 	s RoomID=$P(RoomID,"$",1)
 	if RoomID=""
	{
		Set qHandle=$lb(0,repid,0)
		Quit $$$OK
	}
	
 	k ^TempDHCPERoomManager(Job,"CheckingInfo")
 	
 	s Index=0
 	s Sort=""
	f  s Sort=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," N"," "_RoomID,Sort)) q:Sort=""  d
	.s AdmID=""
	.f  s AdmID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," N"," "_RoomID,Sort,AdmID)) q:AdmID=""  d
	..s RecordID=""
	..f  s RecordID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," N"," "_RoomID,Sort,AdmID,RecordID)) q:RecordID=""  d
	...s DetailStatus=$LG(^User.DHCPEAdmRoomRecordD(RecordID),9)
	...i DetailStatus="E"  d
	....s ^TempDHCPERoomManager(Job,"CheckingInfo",Sort,RecordID,AdmID)=""
	...q:DetailStatus="E"
	...s PaadmID=$P(AdmID," ",2)
	...s BaseInfo=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PaadmID)
	...s TRegNo=$P(BaseInfo,"^",5)
	...s TName=$P(BaseInfo,"^",1)
	...s TSex=$P(BaseInfo,"^",2)
	...s TBirth=$P(BaseInfo,"^",3)
	...s TAge=""
	...s TAge=##class(websys.Conversions).DateHtmlToLogical(TBirth)
	...i TAge'="" s TAge=$P(##class(web.DHCLCNUREXCUTE).CalAge(TAge,+$H),"Y",1)
	...s TTel=$P(BaseInfo,"^",6)
	...s Status="N"
	...s Index=Index+1
	...d FindRoomPersonDetailBuild
	
	i $D(^TempDHCPERoomManager(Job,"CheckingInfo")) d
 	.s Index=0
 	.s Sort=""
 	.f  s Sort=$O(^TempDHCPERoomManager(Job,"CheckingInfo",Sort)) q:Sort=""  d
 	..s RecordID=""
 	..f  s RecordID=$O(^TempDHCPERoomManager(Job,"CheckingInfo",Sort,RecordID)) q:RecordID=""  d
 	...s AdmID=""
 	...f  s AdmID=$O(^TempDHCPERoomManager(Job,"CheckingInfo",Sort,RecordID,AdmID)) q:AdmID=""  d
 	....s PaadmID=$P(AdmID," ",2)
 	....s DetailStatus=$LG(^User.DHCPEAdmRoomRecordD(RecordID),9)
	....s BaseInfo=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PaadmID)
	....s TRegNo=$P(BaseInfo,"^",5)
	....s TName=$P(BaseInfo,"^",1)
	....s TSex=$P(BaseInfo,"^",2)
	....s TBirth=$P(BaseInfo,"^",3)
	....s TAge=""
	....s TAge=##class(websys.Conversions).DateHtmlToLogical(TBirth)
	....i TAge'="" s TAge=$P(##class(web.DHCLCNUREXCUTE).CalAge(TAge,+$H),"Y",1)
	....s TTel=$P(BaseInfo,"^",6)
	....s Status="NE"
	....s Index=Index+1
	....d FindRoomPersonDetailBuild
	.k ^TempDHCPERoomManager(Job,"CheckingInfo")
	
 	s Index=0
 	s Sort=""
	f  s Sort=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," P"," "_RoomID,Sort)) q:Sort=""  d
	.s AdmID=""
	.f  s AdmID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," P"," "_RoomID,Sort,AdmID)) q:AdmID=""  d
	..s RecordID=""
	..f  s RecordID=$O(^User.DHCPEAdmRoomRecordI("StatusSortIndex"," P"," "_RoomID,Sort,AdmID,RecordID)) q:RecordID=""  d
	...s PaadmID=$P(AdmID," ",2)
	...s BaseInfo=##class(web.DHCPE.AdmRecordManager).GetBaseInfo(PaadmID)
	...s TRegNo=$P(BaseInfo,"^",5)
	...s TName=$P(BaseInfo,"^",1)
	...s TSex=$P(BaseInfo,"^",2)
	...s TBirth=$P(BaseInfo,"^",3)
	...s TAge=##class(websys.Conversions).DateHtmlToLogical(TBirth)
	...i TAge'="" s TAge=$P(##class(web.DHCLCNUREXCUTE).CalAge(TAge,+$H),"Y",1)
	...s TTel=$P(BaseInfo,"^",6)
	...s Status="P"
	...s Index=Index+1
	...d FindRoomPersonDetailBuild
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
FindRoomPersonDetailBuild 
	s AdmDate=$P(^PAADM(PaadmID),"^",6)
	s AdmDate=##class(websys.Conversions).DateLogicalToHtml(AdmDate)
	s VIPStr=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PaadmID)
	i VIPStr'="" d
	.s VIPLevel=$p(VIPStr,"^",1)
	.s VIPDesc=$p(VIPStr,"^",2)
	s ^CacheTemp(repid,ind)=$lb(PaadmID,TRegNo,AdmDate,TName,TAge_"岁",TSex,VIPLevel,VIPDesc,Status,RecordID,DetailStatus)
	s ind=ind+1
     
 	
 	  
	}
    
    else
    {
   	s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
	s RegNoIndex=RegNo
	s RegNoIndex=$ZCVT(RegNoIndex,"U")
	s PaPatID=$O(^PAPERi("PAPMI_PatNo",RegNoIndex,0))
	if (PaPatID="")
    {
	  	Set qHandle=$lb(0,repid,0)
		Quit $$$OK  
	}
    s PAPMINo=$P(^PAPER(PaPatID,"PAT",1),"^",1)
    s Name=$P(^PAPER(PaPatID,"ALL"),"^",1)
	s Sex=$P(^PAPER(PaPatID,"ALL"),"^",7)
	s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
    s Age=##class(web.DHCBillInterface).GetPapmiAge(PaPatID,"")
    s (VIPLevel,VIPDesc)=""
    s ArriveFlag=0
	s LocID=%session.Get("LOGON.CTLOCID")
	s PaadmID=""
	f  s PaadmID=$O(^PAPERdr(PaPatID,"ADM","H",PaadmID),-1) q:PaadmID=""  d
	.s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PAADM",PaadmID)
	.q:(LocFlag=1)&&($D(^DHCPESetting("DHCPE","DefaultPAADM",LocID)))
	.s PIADM=$O(^DHCPEIADM(0,"PAADM",PaadmID,0))
	.q:PIADM=""
	.s PreIADM=$P(^DHCPEIADM(PIADM),"^",4)
	.//第一个为医生界面自动到达\第二个为打印条码自动到达
	.s AutoArrived=$G(^DHCPESetting("DHCPE","AutoArrived",LocID))
	.s AutoArrived=$p(AutoArrived,"^",1)
	.i AutoArrived="Y" d
	..d:ArriveFlag=0 ##class(web.DHCPE.DHCPEIAdm).IAdmArrived(PreIADM)
	.s ArriveFlag=1
	.q:##class(web.DHCPE.ResultEdit).IsArrivedStatu(PaadmID)="0"
	.s AdmDate=$P(^PAADM(PaadmID),"^",6)
	.s AdmDate=##class(websys.Conversions).DateLogicalToHtml(AdmDate)
	.;d ##class(web.DHCPE.TransResult).TransMain(PaadmID)
	.s VIPStr=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PaadmID)
	.i VIPStr'="" d
	..s VIPLevel=$p(VIPStr,"^",1)
	..s VIPDesc=$p(VIPStr,"^",2)
    .s ^CacheTemp(repid,ind)=$lb(PaadmID,PAPMINo,AdmDate,Name,Age,Sex,VIPLevel,VIPDesc)
	.s ind=ind+1
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
    }
}

/// d ##class(%ResultSet).RunQuery("web.DHCPE.ResultNew","FindPatInfo","","","","","")
Query FindPatInfo(RegNo, BDate, EDate, VIP, CFlag As %String = "N", OtherPAADM As %String = "") As websys.Query(ROWSPEC = "PaadmID:%String,PAPMINo:%String,AdmDate:%String,Name:%String,Age:%String,Sex:%String,VIPLevel:%String,VIPDesc:%String")
{
}

ClassMethod FindPatInfoExecute(ByRef qHandle As %Binary, RegNo, BDate, EDate, VIP, CFlag, OtherPAADM) As %Status
{
	Set repid=$I(^CacheTemp)
    If $g(ind)="" Set ind=1	
    
    
     
    if (OtherPAADM'="")
    
    {
	s PaPatID=+^PAADM(OtherPAADM)
    s PAPMINo=$P(^PAPER(PaPatID,"PAT",1),"^",1)
    s Name=$P(^PAPER(PaPatID,"ALL"),"^",1)
	s Sex=$P(^PAPER(PaPatID,"ALL"),"^",7)
	s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
    s Age=##class(web.DHCBillInterface).GetPapmiAge(PaPatID,"")
    s (VIPLevel,VIPDesc)=""
    s ArriveFlag=0
	s PaadmID=OtherPAADM
	q:($D(^DHCPERLT(0,"ADM",PaadmID)))&&(CFlag="N")
	q:('$D(^DHCPERLT(0,"ADM",PaadmID)))&&(CFlag="Y")
    s ^CacheTemp(repid,ind)=$lb(PaadmID,PAPMINo,AdmDate,Name,Age,Sex,VIPLevel,VIPDesc)
	s ind=ind+1
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
	    
	    
	}
    else
    {
    if (RegNo="")
    {
	i (BDate="") s BDate=+$h-7
	i (EDate="") s EDate=+$h
	i BDate'="" s BDate=##class(websys.Conversions).DateHtmlToLogical(BDate) 
	i EDate'=""  s EDate=##class(websys.Conversions).DateHtmlToLogical(EDate) 
	
	    
	s Date=BDate-1
 	f  s Date=$o(^DHCPEIADM(0,"AdmDateTime",Date)) q:(Date="")||(Date>EDate)  d
 	.s time=0
 	.f  s time=$o(^DHCPEIADM(0,"AdmDateTime",Date,time)) q:(time="")  d
 	..s IADM=0
 	..f  s IADM=$o(^DHCPEIADM(0,"AdmDateTime",Date,time,IADM)) q:(IADM="")  d
 	...s PIADM=$p(^DHCPEIADM(IADM),"^",4)
 	...s Status=$p(^DHCPEIADM(IADM),"^",8)
 	...q:Status'="ARRIVED"
 	...s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PreADM",PIADM)
 	...q:LocFlag="1" 
	...s PBID=$p(^DHCPEPreIADM(PIADM),"^",1) 
	...s VIPLevel=+##class(web.DHCPE.PreCommon).GetVIPLevel("Pre",PIADM)
 	...q:(VIP'="")&&(VIP'=VIPLevel)
 	...s PAPMINo=$p(^DHCPEPreIBI(PBID),"^",1)
 	...s Name=$p(^DHCPEPreIBI(PBID),"^",2)
 	...s PaadmID=##class(web.DHCPE.DHCPEIAdm).GetPAADMByPADM(PIADM)  
 	...s PaPatID=$P(^PAADM(PaadmID),"^",1)
 	...s Sex=$P(^PAPER(PaPatID,"ALL"),"^",7)
	...s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
    ...s Age=##class(web.DHCBillInterface).GetPapmiAge(PaPatID,"")
    ...s (VIPLevel,VIPDesc)=""
 	...s AdmDate=$P(^PAADM(PaadmID),"^",6)
	...s AdmDate=##class(websys.Conversions).DateLogicalToHtml(AdmDate)
	...s VIPStr=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PaadmID)
	...i VIPStr'="" d
	....s VIPLevel=$p(VIPStr,"^",1)
	....s VIPDesc=$p(VIPStr,"^",2)
	...q:($D(^DHCPERLT(0,"ADM",PaadmID)))&&(CFlag="N")
	...q:('$D(^DHCPERLT(0,"ADM",PaadmID)))&&(CFlag="Y")
    ...s ^CacheTemp(repid,ind)=$lb(PaadmID,PAPMINo,AdmDate,Name,Age,Sex,VIPLevel,VIPDesc)
	...s ind=ind+1
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
 	
 	  
	}
   
    
    else
    {
   	s RegNo=##class(web.DHCPE.DHCPECommon).RegNoMask(RegNo)
	s RegNoIndex=RegNo
	s RegNoIndex=$ZCVT(RegNoIndex,"U")
	s PaPatID=$O(^PAPERi("PAPMI_PatNo",RegNoIndex,0))
	if (PaPatID="")
    {
	  	Set qHandle=$lb(0,repid,0)
		Quit $$$OK  
	}
    s PAPMINo=$P(^PAPER(PaPatID,"PAT",1),"^",1)
    s Name=$P(^PAPER(PaPatID,"ALL"),"^",1)
	s Sex=$P(^PAPER(PaPatID,"ALL"),"^",7)
	s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
    s Age=##class(web.DHCBillInterface).GetPapmiAge(PaPatID,"")
    s (VIPLevel,VIPDesc)=""
    s ArriveFlag=0
	s LocID=%session.Get("LOGON.CTLOCID")
	s PaadmID=""
	f  s PaadmID=$O(^PAPERdr(PaPatID,"ADM","H",PaadmID),-1) q:PaadmID=""  d
	.s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PAADM",PaadmID)
	.q:(LocFlag=1)&&($D(^DHCPESetting("DHCPE","DefaultPAADM",LocID)))
	.s PIADM=$O(^DHCPEIADM(0,"PAADM",PaadmID,0))
	.q:PIADM=""
	.s PreIADM=$P(^DHCPEIADM(PIADM),"^",4)
	.//第一个为医生界面自动到达\第二个为打印条码自动到达
	.s AutoArrived=$G(^DHCPESetting("DHCPE","AutoArrived",LocID))
	.s AutoArrived=$p(AutoArrived,"^",1)
	.i AutoArrived="Y" d
	..d:ArriveFlag=0 ##class(web.DHCPE.DHCPEIAdm).IAdmArrived(PreIADM)
	.s ArriveFlag=1
	.q:##class(web.DHCPE.ResultEdit).IsArrivedStatu(PaadmID)="0"
	.s AdmDate=$P(^PAADM(PaadmID),"^",6)
	.;q:(AdmDate<StartDate)||(AdmDate>EndDate)
	.s AdmDate=##class(websys.Conversions).DateLogicalToHtml(AdmDate)
	.;d ##class(web.DHCPE.TransResult).TransMain(PaadmID)
	.s VIPStr=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PaadmID)
	.i VIPStr'="" d
	..s VIPLevel=$p(VIPStr,"^",1)
	..s VIPDesc=$p(VIPStr,"^",2)
	.q:($D(^DHCPERLT(0,"ADM",PaadmID)))&&(CFlag="N")
	.q:('$D(^DHCPERLT(0,"ADM",PaadmID)))&&(CFlag="Y")
    .s ^CacheTemp(repid,ind)=$lb(PaadmID,PAPMINo,AdmDate,Name,Age,Sex,VIPLevel,VIPDesc)
	.s ind=ind+1
	
	Set qHandle=$lb(0,repid,0)
	Quit $$$OK
    }
    }
}

ClassMethod OutMain(PAADM, StationID)
{
	;s AddItemStation="24"  //协和特殊写死的加项超声算到站点里面
	;s CSStation="9"  //超声站点
	q:PAADM=""
	s obj=##class(User.PAAdm).%OpenId(PAADM)
	;w 
	w "<TABLE border=0 cellspacing='0' cellpadding='0' style='width:100%;height:100%;white-space:normal; word-break:break-all;'>"
	w "<TR>"
	
		w "<TD height=100% style='width:65%;white-space:normal; word-break:break-all;' valign='top'>"
			w "<br>"_"正检：<b>"_obj.PAADMPAPMIDR.PAPMIName_"</b>",!
			s IDStr=..OutResultToWeb(PAADM, StationID)
			;w IDStr
		w "</TD>"
		w "<TD height=100% valign='top'>"
			w "<TABLE border=0 width=100% style='white-space:normal; word-break:break-all;'><TR><TD style='white-space:normal; word-break:break-all;'>"
				d ..OutAuditDoc(StationID, PAADM)
			w "</TD></TR></TABLE>"
			
			w "<TABLE border=1 cellspacing='0' cellpadding='0' width=100% height=500 style='white-space:normal; word-break:break-all;'>"
			w "<TR><TD style='white-space:normal; word-break:break-all;'>"
				w "<div style='overflow-y:auto; width:100%;height:100%;white-space:normal; word-break:break-all;'>"
				;i StationID=AddItemStation s StationID=CSStation
				d ##class(web.DHCPE.DocPatientFind).OutEDInfo(StationID,"",PAADM,"1")
				w "</div>"
			w "</TD></TR></TABLE>"
			
		w "</TD>"
	w "</TR>"
	w "</TABLE>"
	w "<input id='IDStr' name='IDStr' type='hidden' value='"_IDStr_"'>"
	q
	
	
	w "<TABLE style='width:100%;height:100%'><TR style='valign:top'>"
	w "<TD rowspan=2 style='width:65%'><div style='overflow-y:auto; width:100%;height:100%'>"
	d ..OutResultToWeb(PAADM, StationID)
	w "</div></TD>"
	w "<TD style='width:35%'><div style='width:100%;height:100%'>"
	d ..OutAuditDoc(StationID, PAADM)
	w "</div></TD>"
	w "<TD>"
	w "<div id='edprefix' style='overflow-y:auto; width:100%;height:100%;white-space:normal; word-break:break-all;'>"
	i StationID=AddItemStation s StationID=CSStation
	d ##class(web.DHCPE.DocPatientFind).OutEDInfo(StationID,"",PAADM,"1")
	w "</TD>"
	w "</TR></TABLE>"
}

ClassMethod OutResultToWeb(PAADM, StationID, OEOrdItemID As %String = "")
{
	s LisNewVersion=$g(^DHCPESetting("DHCPE","LisNewVersion"))
	S SendPisFBWay=$G(^DHCPESetting("DHCPE","SendPisFBWay"))
	s IDStr=""
	s HighRiskSort="1"
	s UseStation="0"
	s StationDesc=""
	i StationID'="" S StationDesc=$p($g(^DHCPEST(StationID)),"^",2)
	i StationID'="" s UseStation=1
	i OEOrdItemID'="" d
	.s PAADM=$P(^OEORD(+OEOrdItemID),"^",1)
	.s ArcimID=$P(^OEORD(+OEOrdItemID,"I",$P(OEOrdItemID,"||",2),1),"^",2)
	.s StationID=$O(^DHCPEST(0,"STORD_ARCIM",ArcimID,0))
	.s LocInfo=$G(^DHCPEStationOrder("Loc",ArcimID))
	.i LocInfo'="" d
	..s StationID=$P(LocInfo,"^",1)
	s VIPInfo=##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PAADM)
	
	s GSID=##class(web.DHCPE.ResultDiagnosis).GetSSId(PAADM)
	s AuditUser=""
	s:(GSID'="")&&($D(^DHCPEGS(GSID,1))) AuditUser=$P(^DHCPEGS(GSID,1),"^",5)
	///科室确认的方式
	//s CompleteFlag=3
	s UserID=%session.Get("LOGON.USERID")
	s LocID=%session.Get("LOGON.CTLOCID")
	s GroupID=%session.Get("LOGON.GROUPID")
	s SuperGroup=$g(^DHCPESetting("DHCPE","SuperGroup"))
	s SuperFlag=0
	s:$G(^DHCPESetting("DHCPE","SuperGroup"))=GroupID SuperFlag="1"
	
	s CompleteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"WriteWay",StationID))
	s:CompleteFlag="" CompleteFlag=3
	s SaveCpmpleteFlag=0
	s:CompleteFlag="2" SaveCpmpleteFlag=1
	
	s WriteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))
	
	;s AddItemStation="24"  //协和特殊写死的加项超声算到站点里面
	;s CSStation="9"  //超声站点
	s AddItemFlag=""

	i (OEOrdItemID="")&&(AuditUser="")
	{
	i +StationID=..#FKStation d
	.s HighRiskSort=2
	;i +StationID=CSStation d
	;.s AddItemFlag="0"
	;i +StationID=AddItemStation d
	;.s StationID=CSStation
	;.s AddItemFlag="1"
	}
	s ButtonType=$P(^DHCPEST(+StationID),"^",8)
	s:ButtonType="" ButtonType=1
	s OEORD=$O(^OEORD(0,"Adm",PAADM,0))
	q:OEORD="" ""
	s ResultFormat=..GetResultFormat(+StationID)
	i ResultFormat="1" d
	.s Hidden=""
	e  d
	.s Hidden="style='display:none;'"
	s Job=$J
	k ^TempDHCPEResultNew(Job)
	Set myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(PAADM)
	Set myAge=$p(myStr,"^",1)
	Set mySex=$p(myStr,"^",2)
	s RisStation=$G(^DHCPESetting("DHCPE","StationId_Ris"))
	s LabStation=$G(^DHCPESetting("DHCPE","StationId_Lab"))
	s LisInterface=$G(^DHCPESetting("DHCPE","LisInterface"))
	s SSID=##class(web.DHCPE.ResultEdit).GetSSId(PAADM, +StationID)
	s disabled=""
	s Status="NA"
	i SSID'="" d
	.s Status=$P(^DHCPESS(SSID,1),"^",7)
	.q:Status="NA"
	.s disabled="disabled='disabled'"
	w "<TABLE id='TOutResult' border=1 cellspacing='0' cellpadding='0' width=100% style='white-space:normal; word-break:break-all;'>"
	;w "<TR align='center' bgcolor='' height=20><TD width=18%>项目</TD><TD style='cursor:hand' onclick='ShowAllResult(this)' width=47%><a href=#>结果</a></TD><TD width=10%>单位</TD><TD style='cursor:hand' onclick='PrintBChaoApp(this)' width=2%><a href=#>提示</a></TD><TD "_Hidden_">参考值</TD></TR>"
	w "<TR align='center' bgcolor='' height=20><TD width=18%>项目</TD><TD style='cursor:hand' onclick='ShowAllResult(this)' width=47%><a href=#>结果</a></TD><TD width=10%>单位</TD><TD width=2%>提示</TD><TD "_Hidden_">参考值</TD></TR>"
	s ARCIM=""
	f  s ARCIM=$O(^OEORDi(0,"ARCIM",OEORD,ARCIM)) q:ARCIM=""  d
	.q:'$D(^DHCPEST(0,"STORD_ARCIM",ARCIM,+StationID))
	.s STSub=$O(^DHCPEST(0,"STORD_ARCIM",ARCIM,+StationID,0))
	.s ItemSort=$P(^DHCPEST(+StationID,"O",STSub),"^",7)
	.s:ItemSort="" ItemSort="999999999"
	.s LocInfo=$G(^DHCPEStationOrder("Loc",ARCIM))
	.i LocInfo="" d
	..s LocSort="999999999"
	..s LocID=""
	.e  d
	..s LocID=$P(LocInfo,"^",1)
	..s LocSort=$P($g(^DHCPEST(+LocID,"STLOC",$P(LocID,"||",2))),"^",2)
	..i LocSort="" s LocSort="999999999"
	.q:($L(StationID,"||")>1)&&(LocID'=StationID)
	.s stt=""
	.f  s stt=$O(^OEORDi(0,"ARCIM",OEORD,ARCIM,stt)) q:(stt="")  d
	..s Sub=0
	..f  s Sub=$O(^OEORDi(0,"ARCIM",OEORD,ARCIM,stt,Sub)) q:(Sub="")  d
	...s Stat=$P(^OEORD(OEORD,"I",Sub,1),"^",13)
	...;q:Stat="4"
	...q:(Stat'="1")&(Stat'="6")
	...s OEORDItemID=OEORD_"||"_Sub
	...q:(UseStation=0)&&(OEOrdItemID'="")&&(OEOrdItemID'=OEORDItemID)
	...s IAdm=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	...
	...;s CRMOrdID=$o(^DHCPECRMO(0,"OEORI",OEORDItemID,0))
	...;q:CRMOrdID=""
	...;s CRMOrdID=$p(^DHCPECRMO(CRMOrdID),"^",2)
	...;q:CRMOrdID=""
	...;s OSID=$p($g(^DHCPEPreIADM($p(CRMOrdID,"||",1),"ORDITEM",$p(CRMOrdID,"||",2))),"^",2)
	...;q:(AddItemFlag="0")&&(OSID="")&&(VIPInfo'["VIP")&&(%session.Get("LOGON.CTLOCID")'=572)
	...;q:(AddItemFlag="1")&&(OSID'="")
	...;s LabSpecNo=$p($G(^OEORD(+OEORD,"I",Sub,3)),"^",20)
	...;q:(LabSpecNo'="")&&($D(^TempDHCPEResultNewLabSpecNo(Job,LabSpecNo)))
	...;s:(LabSpecNo'="") ^TempDHCPEResultNewLabSpecNo(Job,LabSpecNo)=""
	...;s OEORDItemInfo=..GetLisOrdItem(OEORDItemID)
	...;s OEORDItemID=$P(OEORDItemInfo,"^",1)
	...;s ARCIMDesc=$P(OEORDItemInfo,"^",2)_"^"_OEORDItemID
	...s ^TempDHCPEResultNew(Job,LocSort,ItemSort,OEORDItemID)=ARCIM_"^"_""
	k ^TempDHCPEResultNewLabSpecNo(Job)
	s PersonID=$P(^PAADM(PAADM),"^",1)
	s PrevPAADM=$O(^PAPERdr(PersonID,"ADM","H",PAADM),-1)
	s namespaceLab=^DHCPESetting("NAMESPACE","LABDATA")
	s IAdm=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	s i=0
	s TSInfo=""
	s LocSort=""
	f  s LocSort=$O(^TempDHCPEResultNew(Job,LocSort)) q:LocSort=""  d
	.s TSInfo=""
	.s ItemSort=""
	.f  s ItemSort=$O(^TempDHCPEResultNew(Job,LocSort,ItemSort)) q:ItemSort=""  d
	..s OEORDItemID=""
	..f  s OEORDItemID=$O(^TempDHCPEResultNew(Job,LocSort,ItemSort,OEORDItemID)) q:OEORDItemID=""  d
	...s i=i+1
	...s ARCIM=$G(^TempDHCPEResultNew(Job,LocSort,ItemSort,OEORDItemID))
	...s ARCDesc=$P(ARCIM,"^",2)  //$P(^ARCIM(+ARCIM,1,1),"^",2)
	...s:ARCDesc="" ARCDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ARCIM)
	...s ARCIM=$P(ARCIM,"^",1) 
	...s OEORD=+OEORDItemID
	...s Sub=$P(OEORDItemID,"||",2)
	...s PaiedStatus=$p(^OEORD(OEORD,"I",Sub,3),"^",5)
	
	...;q:PaiedStatus'="P"
	...i (PaiedStatus'="P")&&(IAdm'="") d
	....w "<TR><TD colspan=6>"
	....w ARCDesc_"<B>未付费</B>"
	....w "</TD></TR>"
	...q:(PaiedStatus'="P")&&(IAdm'="")
	...d ##class(web.DHCPE.TransResult).TransExtendItem(PAADM,OEORDItemID,UserID)
	...i (OEOrdItemID="")||((OEOrdItemID'="")&&(+StationID'=LabStation)) d
	....s HiddenStyle=""
	....;s:ARCDesc="LCT" ResultDisabled=""
	....;s:ARCDesc="LCT" HiddenStyle="style='display:none'"
	....;s:ARCDesc="HPV" HiddenStyle="style='display:none'"
	....w "<TR "_HiddenStyle_"><TD>"  //项目名称、录入医生、录入时间
	....s lnk="../csp/dhcpepatresulthistory.old.csp?OEORIRowId="_OEORDItemID
	....w "<a href="_lnk_" target='_blank' >"_ARCDesc_"</a>"
	....;w "<input type='checkbox' name='PrintFlag' id=Print"_OEORDItemID_">"
	....w "</TD>"
	....s disabled=""
	....s RLTOEType="",DefaultDocStr="",DocUserId=""
	....s RLTID=$O(^DHCPERLT(0,"OEORI",OEORDItemID,0))
	....i RLTID'="" d
	.....s DocName=$P(^DHCPERLT(RLTID),"^",5)
	.....i +StationID'=LabStation d
	......;i +StationID=4 s RLTOEType="Lab"  ;暂时妇科不让选择医生
	......s DocUserId=DocName
	......i DocUserId'="" d
	.......s DocName=$P($g(^SSU("SSUSR",DocUserId)),"^",2)
	.......s DocId=$P($g(^SSU("SSUSR",DocUserId)),"^",14)
	.......i DocId'="" s DocOtherName=$p($G(^CTPCP(DocId,3)),"^",28)
	.......e  s DocOtherName=""
	.......s DefaultDocStr=DocUserId_$C(1)_DocName_"-"_DocOtherName
	.....e  d
	......s RLTOEType="Lab"
	......s:(DocName'="")&&(LisNewVersion'="Y") DocName=$P($G(^[namespaceLab]SSU("SSUSR",1,DocName)),"^",2)
	......s:(DocName'="")&&(LisNewVersion="Y") DocName=$P(^SSU("SSUSR",DocName),"^",2)
	......;s:DocName'="" DocName=$P($G(^[namespaceLab]SSU("SSUSR",1,DocName)),"^",2)
	.....s CheckDate=$P(^DHCPERLT(RLTID),"^",6)
	.....s:CheckDate'="" CheckDate=##class(websys.Conversions).DateLogicalToHtml(CheckDate)
	....e  d
	.....s DocName=""
	.....s CheckDate=""
	....w "<TD colspan=4>" ;style='white-space:normal; word-break:break-all;'
	....w "<TABLE width=100% border=1 cellspacing='0' cellpadding='0'><TR><TD width=0>"
	....w "<input id='RLTOEType' name='RLTOEType' type='hidden' value='"_RLTOEType_"'>"

	....w "<input id='DefaultDocStrz"_OEORDItemID_"' name='DefaultDocStrz"_OEORDItemID_"' type='hidden' value='"_DefaultDocStr_"'>"
	....;w "<tr>"
	....;w "<td align='right'>医生</td>"
	....w "<td>医生</td><td><input id='DocNamez"_OEORDItemID_"' name='DocNamez"_OEORDItemID_"'  style='width:60%;white-space:normal; word-break:break-all;' onkeydown='nextfocus(this);' value='"_DocName_"'></td>"
	....;w "<TD align='right'>日期</TD>"
	....w "<td>日期<input id='CheckDatez"_OEORDItemID_"' name='CheckDatez"_OEORDItemID_"'  style='width:60%;white-space:normal; word-break:break-all;' onkeydown='nextfocus(this);' value="_CheckDate_"></td>"
	....q:WriteFlag'="Y"
	....i +StationID'=LabStation d
	.....s LabInfo="保存结果"
	.....s Savedisabled=""
	.....s ResultDisabled=""
	.....i RLTID'="" d
	......s ResultDisabled="disabled='disabled'"
	......s ResultDisabled="readonly"
	......i Status'="NA" d
	.......s LabInfo="已提交"
	.......s Savedisabled="disabled='disabled'"
	.......s disabled="disabled='disabled'"
	......e  d
	.......s LabInfo="修改结果"
	.......s Savedisabled=""
	.......s disabled="disabled='disabled'"
	.....i SuperFlag=1 d
	......s LabInfo="保存结果"
	......s Savedisabled=""
	......s ResultDisabled=""
	.....i WriteFlag="N" d
	......s Savedisabled="disabled='disabled'"
	......s ResultDisabled="disabled='disabled'"
	......s ResultDisabled="readonly"
	.....s:ARCDesc="LCT" LabInfo="保存结果"
	.....s:ARCDesc="HPV" LabInfo="保存结果"
	.....i (SuperFlag'="1")&&(""'=UserID)&&(""'=DocUserId)&&(UserID'=DocUserId)&&(+StationID'=4)&&(+StationID'=26)&&(+StationID'=13)&&(+StationID'=14)&&(+StationID'=8)&&(+StationID'=17)&&(+StationID'=27) d
	......s LabInfo="<b>非本人</b>"
	......s Savedisabled="disabled='disabled'"
	......s disabled="disabled='disabled'"
	
	.....I SendPisFBWay'="F" D
	......s HiddenPis="style='display:none;'"
	.....I SendPisFBWay="F" D
	......s HiddenPis=""

	.....i OEOrdItemID="" d
    ......;w "<tr>"
	......w "<td><button class='i-btn' style='width:80;white-space:normal; word-break:break-all;' onclick='SavePEResult(this,"_SaveCpmpleteFlag_")' id='"_OEORDItemID_"^"_SaveCpmpleteFlag_"^"_WriteFlag_"' name='Update' "_Savedisabled_">"_LabInfo_"</button></td>"
	......;w:ButtonType="2" "<button style='width:15%;white-space:normal; word-break:break-all;' onclick='SendPEMessage(this)' id='"_OEORDItemID_"' name='SendMessage'>发送短信</button>"
	......;w:(ButtonType="2") "<td><button class='i-btn' style='width:80;white-space:normal; word-break:break-all;' onclick='PrintPisRequest(this)' id='"_OEORDItemID_"' name='PisRequest' "_disabled_" "_HiddenPis_">打印病理申请</button></td>"
	......w:(StationDesc["病理") "<td><button class='i-btn' style='width:80;white-space:normal; word-break:break-all;' onclick='PrintPisRequest(this)' id='"_OEORDItemID_"' name='PisRequest' "_disabled_" "_HiddenPis_">打印病理申请</button></td>"
	......;w:(ButtonType="3")&&(i=1) "<td><button class='i-btn' style='white-space:normal; word-break:break-all;' onclick='DealPEExe(this)' id='"_OEORDItemID_"' name='DealExe' "_disabled_">影像采集</button>"
	......w "<td><button class='i-btn' style='width:100;white-space:normal; word-break:break-all;' onclick='SetNormalText(this)' id='"_OEORDItemID_"' name='SetNoramText' "_disabled_">重置默认值</button></td>"
	......s HighRiskLabel="高危"
	......w "<td><button class='i-btn' style='width:60;white-space:normal; word-break:break-all;' onclick='SendHighRisk(this)' id='"_OEORDItemID_"' name='HighRiskText'>"_HighRiskLabel_"</button></td>"
	......w "<td><button class='i-btn' style='width:80;white-space:normal; word-break:break-all;' onclick='GetEqData(this)' id='"_OEORDItemID_"' name='GetComData'>获取数据</button></td>"
	......;w "</tr>"
	....w "</TD></TR></TABLE></TD></TR>"
	...;s:ARCDesc="LCT" ResultDisabled="",disabled=""
	...;s:ARCDesc="HPV" ResultDisabled="",disabled=""
	...i LabStation'=+StationID d
	....i $D(^DHCPEODR(0,"Cascade",ARCIM)) d
	.....s Cascade=0
	.....f  s Cascade=$O(^DHCPEODR(0,"Cascade",ARCIM,Cascade)) q:Cascade=""  d
	......s CascadeSort=""
	......f  s CascadeSort=$O(^DHCPEODR(0,"Cascade",ARCIM,Cascade,CascadeSort)) q:CascadeSort=""  d
	.......s ODRRowID=""
	.......f  s ODRRowID=$O(^DHCPEODR(0,"Cascade",ARCIM,Cascade,CascadeSort,ODRRowID)) q:ODRRowID=""  d
	........i $D(^DHCPEODR(0,"ParentDR",ODRRowID)) d
	.........s ODID=$P(^DHCPEODR(ODRRowID),"^",2)
	.........s ODDesc=$P($G(^DHCPEST(+ODID,"OD",$P(ODID,"||",2))),"^",1)
	.........w "<TR><TD>"_ODDesc_"</TD></TR>"
	.........s ParentSort=""
	.........f  s ParentSort=$O(^DHCPEODR(0,"ParentDR",ODRRowID,ParentSort)) q:ParentSort=""  d
	..........s ODRID=0
	..........f  s ODRID=$O(^DHCPEODR(0,"ParentDR",ODRRowID,ParentSort,ODRID)) q:ODRID=""  d
	...........d CreateOneDetail
	........e  d
	.........s ODRID=ODRRowID
	.........q:Cascade=2
	.........d CreateOneDetail
	....e  d
	.....;^DHCPEODR(0,"Sequence",ARCIM,Sequence)
	.....s Sequence=0
	.....f  s Sequence=$O(^DHCPEODR(0,"Sequence",ARCIM,Sequence)) q:Sequence=""  d
	......s ODRID=0
	......f  s ODRID=$O(^DHCPEODR(0,"Sequence",ARCIM,Sequence,ODRID)) q:ODRID=""  d
	.......d CreateOneDetail
	
	...e  d
	....k ^TempDHCPEOD(Job)
	....s ShowSort=""
	....f  s ShowSort=$O(^DHCPERLT(0,"OrdSort",OEORDItemID,ShowSort)) q:ShowSort=""  d
	.....s RLTID=""
	.....f  s RLTID=$O(^DHCPERLT(0,"OrdSort",OEORDItemID,ShowSort,RLTID)) q:RLTID=""  d
	......s ODID=$P(^DHCPERLT(RLTID),"^",3)
	......q:ODID=""
	......q:$D(^TempDHCPEOD(Job,ODID))
	......s ^TempDHCPEOD(Job,ODID)=""
	......q:+ODID=0
	......s ODDesc=$P($G(^DHCPEST(+ODID,"OD",$P(ODID,"||",2))),"^",1)
	......s:ODDesc="tx4(t7,t8,t11,t12,t14)" ODDesc="tx4(白栎,美洲榆,英国梧桐树,柳树,美洲黑杨)"
	......s:ODDesc="tx10(t2,t3,t4,t15)" ODDesc="tx10(灰桤木,疣皮桦,欧洲榛,美国白蜡)"
	......s TSInfo=""
	......s Type=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
	......s DefaultValue=$P(^DHCPERLT(RLTID),"^",4)
	......s DefaultValue=..ChangeHtmlToStr(DefaultValue)
	......s ElementID=OEORDItemID_"^"_ODID
	
	......//i LisInterface="Y" d
	......i $D(^DHCPEDataEx("DHCPEResult",RLTID,"Unit")) d
	.......s Unit=$G(^DHCPEDataEx("DHCPEResult",RLTID,"Unit"))
	.......s NormalStr=$G(^DHCPEDataEx("DHCPEResult",RLTID,"Ranges"))
	......e  d
	.......s Unit=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",4)
	.......s NormalStr=##class(web.DHCPE.ResultEdit).GetNormal(ODID, mySex, myAge)
	......s TSInfo=""
	......s HighFlag=$P(^DHCPERLT(RLTID),"^",12)
	......s NormalFlag=$P(^DHCPERLT(RLTID),"^",7)
	......i NormalFlag=0 d
	.......s TSInfo="<font color=red>*</font>"
	.......s:Type="N" TSInfo=##class(web.DHCPE.TransResult).GetLabResultArrowNew(RLTID)
	.......s:(TSInfo="1") TSInfo=""
	.......s:TSInfo="2" TSInfo="<font color=red>↑</font>"
	.......s:TSInfo="0" TSInfo="<font color=red>↓</font>"
	......s:NormalStr="" NormalStr="&nbsp;"
	......s:Unit="" Unit="&nbsp;"
	......s style=""
	......s:NormalFlag=0 style=";color: #FF0000"
	......;s:NormalFlag=0 ODDesc="<font color=red>"_ODDesc_"</font>"
	......;s:HighFlag="Y" ODDesc="<font color=yellow>"_ODDesc_"</font>"
	......s EnDetailFlag=##class(web.DHCPE.Endanger).IsEDDetail(PAADM,ARCIM,ODID)
	......s BGColor=""
	......s:EnDetailFlag="1" BGColor="#808000"
	......w "<TR bgcolor='"_BGColor_"'><TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_ODDesc_"</TD>"
	......w "<TD>"
	......w "<input style='white-space:normal; word-break:break-all;width:100%;font-size:18px"_style_"' onkeydown='nextfocus(this);' onclick='resultClick(this);' onchange='resultchange(this)' ondblclick='detailStandard(this);' id='"_ElementID_"' name='"_OEORDItemID_" "_disabled_"' value="_DefaultValue_">"
	......w "</TD>"
	......w "<TD onclick='RemoveAllDiv(1)' style='white-space:normal; word-break:break-all;'>"_Unit_"</TD>"
	......w "<TD onclick='RemoveAllDiv(1)' style='white-space:normal; word-break:break-all;'>"_TSInfo_"</TD>"
	......w "<TD onclick='RemoveAllDiv(1)' id="_ElementID_"S style='white-space:normal; word-break:break-all;'>"_NormalStr_"</TD>"
	.....w "</TR>"
	....k ^TempDHCPEOD(Job)
	...w "</TR>"
	w "</TABLE>"
	k ^TempDHCPEResultNew(Job)
	q IDStr
CreateOneDetail
	s ODID=$P(^DHCPEODR(ODRID),"^",2)
	q:ODID=""
	
	s EnDetailFlag=##class(web.DHCPE.Endanger).IsEDDetail(PAADM,ARCIM,ODID)
	s BGColor=""
	s:EnDetailFlag="1" BGColor="#808000"
	
	s PrevCode=""
	i PrevPAADM'="" d
	.s PrevRLTID=0
	.f  s PrevRLTID=$O(^DHCPERLT(0,"PAADM_OD",PrevPAADM,ODID,PrevRLTID)) q:PrevRLTID=""  d
	..s ARCID=$P(^DHCPERLT(PrevRLTID),"^",2)
	..q:ARCID'=ARCIM
	..s Flag=$P(^DHCPERLT(PrevRLTID),"^",7)
	..s:Flag=0 PrevCode="<font color=red>***</font>"
	s MustFlag=$P(^DHCPEODR(ODRID),"^",4)
	s MustInfo=""
	s:MustFlag="Y" MustInfo="<font color=red>*</font>"
	s Type=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
	s DetailDisabled=""
	i Type="C" s DetailDisabled="disabled='disabled'"
	s ODDesc=PrevCode_$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",1)_MustInfo
	s TextRows=1
	s:ODDesc="既往史" TextRows=2
	s Unit=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",4)
	s:Unit="" Unit="&nbsp;"
	s Compute=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",3)
	s Code=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",11)
	s Sex=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",9)
	q:((Sex'="N")&&(Sex'=""))&&(Sex'=mySex)
	s NormalStr=##class(web.DHCPE.ResultEdit).GetNormal(ODID, mySex, myAge)
	s ElementID=OEORDItemID_"^"_ODID
	s DefaultValue=""
	s NumFlag=0
	s:(Type="C")||(Type="N") NumFlag=1
	i $D(^DHCPERLT(0,"ADMOD",PAADM,OEORDItemID)) d
	.s NormalFlag=1
	.s RltID=$O(^DHCPERLT(0,"ADMOD",PAADM,OEORDItemID,ODID,0))
	.i RltID'="" d
	..s DefaultValue=$P(^DHCPERLT(RltID),"^",4)
	..s NormalFlag=$P(^DHCPERLT(RltID),"^",7)
	..s HighFlag=$P(^DHCPERLT(RltID),"^",12)
	..s TSInfo=""
	..i NormalFlag=0 d
	...s TSInfo="<font color=red>*</font>"
	...s:(Type="N")||(Type="C") TSInfo=##class(web.DHCPE.TransResult).GetLabResultArrowNew(RltID)
	...s:(TSInfo="1") TSInfo=""
	...s:TSInfo="2" TSInfo="<font color=red>↑</font>"
	...s:TSInfo="0" TSInfo="<font color=red>↓</font>"
	e  d
	.s NormalFlag=1
	.s HighFlag="N"
	.s TSInfo=""
	.i (Type="S")||(Type="T") s DefaultValue=NormalStr
	.s:OEOrdItemID'="" DefaultValue=""
	s:NormalStr="" NormalStr="&nbsp;"
	s style=""
	s:NormalFlag=0 style=";color: #FF0000"
	i ("^"_RisStation_"^")[("^"_StationID_"^")&(OEOrdItemID'="") d
	.s style=";color: #2c2c2c"
	i ResultFormat="3" d
	.s DetailDesc=$P(ODDesc,"-",1)
	.;w "<TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_DetailDesc_"检查结论"_"</TD>"
	.w "<TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_DetailDesc_"检查所见"_"</TD>"
	.w "<TD colspan=3 style='white-space:normal; word-break:break-all;'>"
	.s DefaultValue=##class(web.DHCPE.Public.Setting).Replace(DefaultValue,"@@",$c(13,10))
	.s ZDDefaultValue=""
	.s EyeSeeDefaultValue=""
	.i $L(DefaultValue,";诊断意见:")>1 d
	..s ZDYJ=$p(DefaultValue,";诊断意见:",2)
	..s ZDYJ=##class(web.DHCPE.Public.Setting).Replace(ZDYJ,"_$c(13,10)_","  ")
	..s ZDYJ=##class(web.DHCPE.Public.Setting).Replace(ZDYJ,"_$c_","  ")
	..s Other=$p(DefaultValue,";诊断意见:",1)
	..s ZDDefaultValue=ZDYJ
	..i ZDYJ'="" s ZDYJ="诊断意见:"_ZDYJ
	..s JCSJ=$p(Other,";检查所见:",2)
	..s JCSJ=##class(web.DHCPE.Public.Setting).Replace(JCSJ,"_$c(13,10)_","  ")
	..s JCSJ=##class(web.DHCPE.Public.Setting).Replace(JCSJ,"_$c_","  ")
	..s EyeSeeDefaultValue=JCSJ
	..i JCSJ'="" s JCSJ="检查所见:"_JCSJ
	..s Other=$p(Other,";检查所见:",1)
	..s LCZD=$p(Other,"临床诊断:",2)
	..s LCZD=##class(web.DHCPE.Public.Setting).Replace(LCZD,"_$c(13,10)_","  ")
	..s LCZD=##class(web.DHCPE.Public.Setting).Replace(LCZD,"_$c_","  ")
	..i LCZD'="" s LCZD="临床诊断:"_LCZD
	..s JCJG=""
	..i LCZD'="" s JCJG=LCZD_$C(13)
	..i JCSJ'="" s JCJG=JCJG_JCSJ_$C(13)
	..i ZDYJ'="" s JCJG=JCJG_ZDYJ_$C(13)
	..s DefaultValue=JCJG ;style='white-space:normal; word-break:break-all;'
	.e  d
	..s ZDDefaultValue=DefaultValue
	..s EyeSeeDefaultValue=""
	.s DefaultValue=..ChangeHtmlToStr(DefaultValue)
	.s ZDDefaultValue=..ChangeHtmlToStr(ZDDefaultValue)
	.s EyeSeefaultValue=..ChangeHtmlToStr(EyeSeeDefaultValue)
	.w "<textarea style='white-space:normal; word-break:break-all;width:100%"_style_"' rows=6 onkeydown='resultClick(this);' onclick='resultClick(this);' onselectstart='resultSelectStart(this)' onchange='resultchange(this)' ondblclick='detailStandard(this);' "_DetailDisabled_" id='"_ElementID_"^EyeSee"_"' name='"_OEORDItemID_"^EyeSee' "_$G(ResultDisabled)_">"_EyeSeeDefaultValue_"</textarea>"
	.w "<TD "_Hidden_"onclick='RemoveAllDiv(1)' id="_ElementID_"S style='white-space:normal; word-break:break-all;'>"_NormalStr_"</TD>"
	.w "</TD>"
	.w "</TR><TR>"
	.;w "<TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_DetailDesc_"检查所见"_"</TD>"
	.w "<TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_DetailDesc_"诊断意见"_"</TD>"
	.w "<TD colspan=3 style='white-space:normal; word-break:break-all;'>"
	.w "<textarea style='white-space:normal; word-break:break-all;width:100%"_style_"' rows=6 onkeydown='resultClick(this);' onclick='resultClick(this);' onselectstart='resultSelectStart(this)' onchange='resultchange(this)' ondblclick='detailStandard(this);' "_DetailDisabled_" id='"_ElementID_"' name='"_OEORDItemID_"' "_$G(ResultDisabled)_">"_ZDDefaultValue_"</textarea>"
	
	.w "<TD "_Hidden_"onclick='RemoveAllDiv(1)' id="_ElementID_"S style='white-space:normal; word-break:break-all;'>"_NormalStr_"</TD>"
	.w "</TD>"
	.q:Type="C"
	.i IDStr="" d
	..s IDStr=ElementID_"&"_ElementID_"^EyeSee"
	.e  d
	..s IDStr=IDStr_"&"_ElementID_"&"_ElementID_"^EyeSee"
	
	e  d
	.;s:NormalFlag=0 ODDesc="<font color=red>"_ODDesc_"</font>"
	.;s:HighFlag="Y" ODDesc="<font color=yellow>"_ODDesc_"</font>"
	.w "<TR bgcolor='"_BGColor_"' style='white-space:normal; word-break:break-all;'><TD style='cursor:hand;white-space:normal; word-break:break-all;' onclick='detailClick(this);' id="_ElementID_"^OD>"_ODDesc_"</TD>"
	.i ResultFormat="1" d
	..s DefaultValue=..ChangeHtmlToStr(DefaultValue)
	..w "<TD style='white-space:normal; word-break:break-all;'>"
	..w "<textarea style='white-space:normal; word-break:break-all;width:97%"_style_"' rows='"_TextRows_"' onkeydown='MoveFocus(this,"_NumFlag_");' onclick='resultClick(this);' onselectstart='resultSelectStart(this)' onchange='resultchange(this)' ondblclick='detailStandard(this);' "_DetailDisabled_" id='"_ElementID_"' name='"_OEORDItemID_"' "_$G(ResultDisabled)_">"_DefaultValue_"</textarea>"
	..w "</TD>"
	..w "<TD onclick='RemoveAllDiv(1)'>"_Unit_"</TD>"
	..s:$G(TSInfo)="" TSInfo="&nbsp;"
	..w "<TD onclick='RemoveAllDiv(1)'>"_TSInfo_"</TD>"
	..w "<TD onclick='RemoveAllDiv(1)' id="_ElementID_"S>"_NormalStr_"</TD>"
	.e  d
	..s DefaultValue=..ChangeHtmlToStr(DefaultValue)
	..w "<TD colspan=3 style='white-space:normal; word-break:break-all;'>"
	..w "<textarea style='white-space:normal; word-break:break-all;width:100%"_style_"' rows='"_TextRows_"' onkeydown='MoveFocus(this,"_NumFlag_");' onclick='resultClick(this);' onselectstart='resultSelectStart(this)' onchange='resultchange(this)' ondblclick='detailStandard(this);' "_DetailDisabled_" id='"_ElementID_"' name='"_OEORDItemID_"' "_$G(ResultDisabled)_">"_DefaultValue_"</textarea>"
	..w "<TD "_Hidden_"onclick='RemoveAllDiv(1)' id="_ElementID_"S style='white-space:normal; word-break:break-all;'>"_NormalStr_"</TD>"
	..w "</TD>"
	.q:Type="C"
	.i IDStr="" d
	..s IDStr=ElementID
	.e  d
	..s IDStr=IDStr_"&"_ElementID
	w "</TR>"
}

ClassMethod ChangeHtmlToStr(Str)
{
	s Str=##class(web.DHCPE.Public.Setting).Replace(Str,"""","&quot;")
	s Str=##class(web.DHCPE.Public.Setting).Replace(Str,"&","&amp;")
	s Str=##class(web.DHCPE.Public.Setting).Replace(Str,"<","&lt;")
	s Str=##class(web.DHCPE.Public.Setting).Replace(Str,">","&gt;")
	s Str=##class(web.DHCPE.Public.Setting).Replace(Str," ","&nbsp;")
	q Str
}

ClassMethod GetResultFormat(StationID)
{
	q:StationID="" ""
	//不是
	s LayOutType=$P(^DHCPEST(StationID),"^",7)
	//详细的带参考范围
	q:(LayOutType="2")||(LayOutType="3")||(LayOutType="4") 1
	//检查
	q:(LayOutType="5")||(LayOutType="6") 3
	q 2
}

ClassMethod OutDisToWeb(PAADM, Station)
{
	;s ^sxt("PAADMa")=PAADM_"sta:"_Station
	s SSID=##class(web.DHCPE.ResultEdit).GetSSId(PAADM, Station)
	w "<TABLE border=1 cellspacing='0' cellpadding='0'>"
	;w "12222222"
	w "<TR><TD width=30%>结论</TD><TD>建议</TD></TR>"
	
	w "</TABLE>"
}

ClassMethod GetAuditStatus(StationID, PAADM)
{
	s SSID=##class(web.DHCPE.ResultEdit).GetSSId(PAADM, StationID)
	s AuditFlag=0
	i SSID'="" d
	.s Status=$P(^DHCPESS(SSID,1),"^",7)
	.q:(Status="NA")
	.s AuditFlag=1
	q AuditFlag
}

ClassMethod GetNormalStr(Item)
{
	Set NormalStr=##class(web.DHCPE.ResultEdit).GetNormal(Item, mySex, myAge)
}

ClassMethod GetItemStr(InfoStr)
{
	s OEORDItemID=$P(InfoStr,"^",1)
	s PAADM=$P(^OEORD(+OEORDItemID),"^",1)
	Set myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(PAADM)
	Set myAge=$p(myStr,"^",1)
	Set mySex=$p(myStr,"^",2)
	s ItemID=$P(InfoStr,"^",2)
	s Job=$J
	
	k ^DHCPETemp("ItemResult",Job)
	s ValueId=0
	For  Set ValueId=$O(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",ValueId)) Quit:ValueId=""  Do
	.s RowId=ItemID_"||"_ValueId
	.s StrData=$G(^DHCPEST(+ItemID,"OD",$P(ItemID,"||",2),"ODS",ValueId))
	.s ODSSex=$p(StrData,"^",1)
	.
	.s ODSAgeMin=$p(StrData,"^",7)
	.s ODSAgeMax=$p(StrData,"^",8)
	.q:(((ODSAgeMin>myAge)||(ODSAgeMax<myAge))&&((ODSAgeMin'="")&&(ODSAgeMax'="")))
    .
	.q:(ODSSex'="N")&&(ODSSex'=mySex)
	.s Template=$p(StrData,"^",9)
	.i Template="" s Template="999999999"
	.s ^DHCPETemp("ItemResult",Job,Template,RowId)=StrData
	s data=""
	s Sort=""
	f  s Sort=$o(^DHCPETemp("ItemResult",Job,Sort)) q:Sort=""  d
	.s RowID=""
	.f  s RowID=$o(^DHCPETemp("ItemResult",Job,Sort,RowID)) q:RowID=""  d
	..s StrData=$G(^DHCPETemp("ItemResult",Job,Sort,RowID))
	..s HighRisk=$G(^DHCPEDataEx("DHCPEODStandard","HighRiskFlag",RowID))
	..s TextVal=$p(StrData,"^",2)
	..s NatureValue=$p(StrData,"^",6)
	..q:NatureValue="Y"
	..i NatureValue="Y" d
	...s NatureValue=1
	..e  d
	...s NatureValue=0
	..s OneStr=TextVal_$C(1)_NatureValue
	..i data="" d
	...s data=OneStr
	..e  d
	...s data=data_$C(2)_OneStr
	k ^DHCPETemp("ItemResult",$j)
	s data=##class(web.DHCPE.Public.Setting).Replace(data,$C(13,10),"<br>")
	Q data
}

// w ##class(web.DHCPE.ResultNew).IsResultAllNull("561||4^1||22^"_$c(1)_"561||4^1||21^")

ClassMethod IsResultAllNull(ResultStr)
{
   S flag=0
	s ResultLength=$L(ResultStr,$C(1))
	f i=1:1:ResultLength
	{
		s OneResult=$P(ResultStr,$C(1),i)
	    s Result=$P(OneResult,"^",3)
	    i Result'="" S flag=1
	}
	q flag
}

ClassMethod SaveResult(ResultStr, DocID, AuditDocID, BaseEntryInfo = "")
{
	s IsAllResultNullFlag=..IsResultAllNull(ResultStr)
	q:IsAllResultNullFlag=0 "-1^结果不能全是空"
	//if (ResultStr="") q "-1^结果不能全是空"
	s OrderItemID=$P(ResultStr,"^",1)
	q:$D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrderItemID)) "-1^项目已放弃,不能保存"
	s CheckDate=$p(BaseEntryInfo,"^",1)
	s RecordUserID=$p(BaseEntryInfo,"^",2)
	s ResultStr=..ChangeResultStr(ResultStr)
	s HDValue=..IsHDValue(ResultStr)
	q:+HDValue<0 HDValue
	i $l(CheckDate,"-")=3 s Date=$zdh(CheckDate,3)
	i $l(CheckDate,"/")=3 s Date=$zdh(CheckDate,4)
	i $g(Date)="" s Date=+$H
	s Time=$P($H,",",2)
	i DocID="" s DocID=%session.Get("LOGON.USERID")
	s:RecordUserID="" RecordUserID=%session.Get("LOGON.USERID")
	s PAADM=$P(^OEORD(+ResultStr),"^",1)
	
	s AuditUser="",Status=""
	s flag=0
	s ID=$o(^User.DHCPEOtherPatientToHPI("OTHPAADMDRIndex",PAADM,0))
	i ID'=""  D
	.S AuditUser=$LG(^User.DHCPEOtherPatientToHPD(ID),13)
	.s Status=$LG(^User.DHCPEOtherPatientToHPD(ID),12)
	E  D
	.s IADMDR=$o(^DHCPEIADM(0,"PAADM",PAADM,0))
	.i (ID="")&(IADMDR="") s flag=1
	.q:flag=1
	.s GSRowId=$o(^DHCPEGS(0,"IADM",IADMDR,0))
	.i GSRowId'="" s AuditUser=$P($G(^DHCPEGS(GSRowId,1)),"^",5)
	.i AuditUser'="" s Status="2"
	//Q:AuditUser'="" "-1^已初检,不能修改结果"
    Q:(AuditUser'="")&(Status="2") "-1^已初检,不能修改结果"
    q:(flag=1) "-1^住院病人需在体检列表设置为体检类型"

	Set myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(PAADM)
	Set sex=$p(myStr,"^",2)
	s ResultLength=$L(ResultStr,$C(1))
	f i=1:1:ResultLength
	{
		s OneResult=$P(ResultStr,$C(1),i)
		//s OrderItemID=$P(OneResult,"^",1)
		i $D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrderItemID)) k ^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrderItemID)
		s ARCIM=$P(^OEORD(+OrderItemID,"I",$P(OrderItemID,"||",2),1),"^",2)
		s ODID=$P(OneResult,"^",2)
		continue:+ODID=0
		s Value=$P(OneResult,"^",3)
		s RltID=$O(^DHCPERLT(0,"ADMOD",PAADM,OrderItemID,ODID,0))
		i RltID=""  d
		.s obj=##class(User.DHCPEResult).%New()
		.s obj.RLTADMDR=PAADM
		.d obj.RLTODDRSetObjectId(ODID)
		.s obj.RLTOEORIDR=OrderItemID
		.s obj.RLTARCIMDR=ARCIM
		.s obj.RLTUpdateDate=Date
		.s obj.RLTUpdateTime=Time
		.s obj.RLTUserDR=DocID
		.s obj.RLTFollowUpFlag="N"
		.s obj.RLTAdvice=""
		.s obj.RLTTemplateDesc=""
		.s obj.RLTShowSort="999999999"
		e  d
		.s obj=##class(User.DHCPEResult).%OpenId(RltID)
		.s $p(^DHCPERLT(RltID),"^",4)=""
		.s obj.RLTUserDR=DocID
		.s obj.RLTUpdateDate=Date
		.s obj.RLTUpdateTime=Time
		s Normal=##class(web.DHCPE.ResultEdit).IsNormal(ODID,Value,sex,"")
		//不进入小结
		s Summary=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",5)
		s:Summary="N" Normal="1"
		s obj.RLTRecordUserDR=RecordUserID
		//End不进入小结
		s obj.RLTNormal=Normal
		s obj.RLTResult=""
		s sc=obj.%Save()
		d obj.%Close()
		If ($System.Status.IsError(sc))	
		{
			s RltID=""
		}else{
			s RltID=obj.%Id()
			
		}
		q:RltID=""
		s $p(^DHCPERLT(RltID),"^",4)=Value
		;d ##class(web.DHCPE.HighRisk).GetHighRiskFlag(RltID)
		;s obj.RLTResult=Value
	}
	i RltID="" q "-1^更新错误"
	d ##class(web.DHCPE.AdmRecordManager).Insert(PAADM,"A","PEResult",RecordUserID,OrderItemID)
	s IsExecuted=##class(web.DHCPE.ResultEdit).OrderIsExec(PAADM,OrderItemID)
	d ##class(web.DHCPE.ResultEdit).ChangeOrdItemStatus(PAADM, OrderItemID, IsExecuted)
	s ret=..AutoAudit($P(ResultStr,"^",1))
	
	q "0^更新成功^"_ret
}

// 根据医嘱判断是否自动提交

ClassMethod AutoAudit(OEOrdItemID)
{
	s PAADM=$P(^OEORD(+OEOrdItemID),"^",1)
	s ARCIM=$P(^OEORD(+OEOrdItemID,"I",$P(OEOrdItemID,"||",2),1),"^",2)
	s STID=$O(^DHCPEST(0,"STORD_ARCIM",ARCIM,0))
	q:STID="" ""
	s AutoAudit=$P(^DHCPEST(STID),"^",6)
	i AutoAudit="Y" d
	.s LocID=%session.Get("LOGON.CTLOCID")
	.s AutoAuditUser=$G(^DHCPESetting("DHCPE","AutoAuditUser",LocID))
	.d ##class(web.DHCPE.ResultEdit).AuditStationS(PAADM, STID, "Submit", AutoAuditUser)
	s SSID=##class(web.DHCPE.ResultEdit).GetSSId(PAADM, STID)
	s Status="NA"
	i SSID'="" d
	.s Status=$P(^DHCPESS(SSID,1),"^",7)
	q Status
}

/*
ClassMethod ChangeResultStr(ResultStr)
{
	;w ##class(web.DHCPE.ResultNew).ChangeResultStr("")
	s ResultLength=$L(ResultStr,$C(1))
	s Job=$J
	k ^TempDHCPEChangeReult(Job)
	f i=1:1:ResultLength
	{
		s OneResult=$P(ResultStr,$C(1),i)
		s OrderItemID=$P(OneResult,"^",1)
		s ODID=$P(OneResult,"^",2)
		continue:+ODID=0
		s Value=$P(OneResult,"^",3)
		s Type=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
		s ODCode=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",11)
		i Type="C" d
		.s Express=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",3)
		.s ^TempDHCPEChangeReult(Job,"C",ODCode,i)=Express
		s ^TempDHCPEChangeReult(Job,"R",ODCode,i)=OneResult
	}
	;i '$D(^TempDHCPEChangeReult(Job,"C")) q ResultStr
	s ODCode=""
	f  s ODCode=$O(^TempDHCPEChangeReult(Job,"C",ODCode)) q:ODCode=""  d
	.s i=0
	.f  s i=$O(^TempDHCPEChangeReult(Job,"C",ODCode,i)) q:i=""  d
	..s Express=$G(^TempDHCPEChangeReult(Job,"C",ODCode,i))
	..s Length=$L(Express,"[")
	..f k=1:1:Length  d
	...s OneInfo=$P(Express,"[",k)
	...s OneCode=$P(OneInfo,"]",1)
	...q:OneCode=""
	...s j=$O(^TempDHCPEChangeReult(Job,"R",OneCode,0))
	...q:j=""
	...i j>0 d
	....s value=$P($G(^TempDHCPEChangeReult(Job,"R",OneCode,j)),"^",3)
	...e  d
	....s value=""
	...s Express=##class(web.DHCPE.Public.Setting).Replace(Express,"["_OneCode_"]",value)
	..s value=##class(web.DHCPE.ExcuteExpress).ExcuteExpress(Express)
	..s value=$FN(value,"",2)
	..s $P(^TempDHCPEChangeReult(Job,"R",ODCode,i),"^",3)=value
	..s value=$G(^TempDHCPEChangeReult(Job,"R",ODCode,i))
	
	..s $P(ResultStr,$C(1),i)=value
	q ResultStr
}
*/
ClassMethod ChangeResultStr(ResultStr)
{
	;w ##class(web.DHCPE.ResultNew).ChangeResultStr("")
	s ResultLength=$L(ResultStr,$C(1))
	s Job=$J
	k ^TempDHCPEChangeReult(Job)
	f i=1:1:ResultLength
	{
		s OneResult=$P(ResultStr,$C(1),i)
		s OrderItemID=$P(OneResult,"^",1)
		s ODID=$P(OneResult,"^",2)
		continue:+ODID=0
		s Value=$P(OneResult,"^",3)
		s Type=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
		s ODCode=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",11)
		i Type="N" d
		.s Value=##class(web.DHCPE.Public.Setting).Replace(Value,$C(13),"")
		.s Value=##class(web.DHCPE.Public.Setting).Replace(Value,$C(10),"")
		.s $P(OneResult,"^",3)=Value
		.s $P(ResultStr,$C(1),i)=OneResult
		i Type="C" d
		.s Express=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",3)
		.s ^TempDHCPEChangeReult(Job,"C",ODCode,i)=Express
		s ^TempDHCPEChangeReult(Job,"R",ODCode,i)=OneResult
	}
	;i '$D(^TempDHCPEChangeReult(Job,"C")) q ResultStr
	s ODCode=""
	f  s ODCode=$O(^TempDHCPEChangeReult(Job,"C",ODCode)) q:ODCode=""  d
	.s i=0
	.f  s i=$O(^TempDHCPEChangeReult(Job,"C",ODCode,i)) q:i=""  d
	..s Express=$G(^TempDHCPEChangeReult(Job,"C",ODCode,i))
	..s Express2=Express
	..s Length=$L(Express,"[")
	..s NeedCom=1
	..f k=1:1:Length  d
	...s OneInfo=$P(Express,"[",k)
	...s OneCode=$P(OneInfo,"]",1)
	...q:OneCode=""
	...s j=$O(^TempDHCPEChangeReult(Job,"R",OneCode,0))
	...q:j=""
	...i j>0 d
	....s value=$P($G(^TempDHCPEChangeReult(Job,"R",OneCode,j)),"^",3)
	...e  d
	....s value=""
	...s:value="" NeedCom=0
	...s Express2=##class(web.DHCPE.Public.Setting).Replace(Express2,"["_OneCode_"]",value)
	..s Express=Express2
	..b ;Express
	..s value=##class(web.DHCPE.ExcuteExpress).ExcuteExpress(Express)
	..b ;value
	..s value=$FN(value,"",2)
	..s:NeedCom=0 value=""
	..s $P(^TempDHCPEChangeReult(Job,"R",ODCode,i),"^",3)=value
	..s value=$G(^TempDHCPEChangeReult(Job,"R",ODCode,i))
	..b ;value 2 ResultStr
	..s $P(ResultStr,$C(1),i)=value
	q ResultStr
}

ClassMethod GetEDInfo(OEOrdItemID, PAADM, ODStandardID, ChartID, OtherDesc As %String = "")
{
	;w ##class(web.DHCPE.ResultNew).GetEDInfo("6497615||29","6619654","33||1","33","")
	s ^wrz=OEOrdItemID_"^"_PAADM_"^"_ODStandardID_"^"_ChartID_"^"_OtherDesc
	s Job=$J
	k ^TempDHCPEEDDesc(Job)
	k ^TempDHCPEEDInfo(Job)
	s ArcimID=$P(^OEORD(+OEOrdItemID,"I",$P(OEOrdItemID,"||",2),1),"^",2)
	s ItemStation=$O(^DHCPEST(0,"STORD_ARCIM",ArcimID,0))
	s LayoutType=$P(^DHCPEST(ItemStation),"^",7)
	b ;LayoutType
	s RisStation=$G(^DHCPESetting("DHCPE","StationId_Ris"))
	s LabStation=$G(^DHCPESetting("DHCPE","StationId_Lab"))
	s Stations="^"_RisStation_"^"_LabStation_"^"
	s LocInfo=$G(^DHCPEStationOrder("Loc",ArcimID))
	s LocID=$P(LocInfo,"^",1)
	s AdmLocID="a"
	i PAADM="" d
	.s:OEOrdItemID'="" PAADM=$P(^OEORD(+OEOrdItemID),"^",1)
	s:PAADM'="" AdmLocID=$P(^PAADM(PAADM),"^",4)
	//i Stations[("^"_ItemStation_"^") d
	q:ODStandardID=""
	i LayoutType>2 d
	.s ODDesc=$P(^ARCIM(+ArcimID,1,1),"^",1)
	e  d
	.s ODDesc=$P(^DHCPEST(+ODStandardID,"OD",$P(ODStandardID,"||",2)),"^",1)
	.s:$L(ODStandardID,"||")>2 ODDesc=$P(^DHCPEST(+ODStandardID,"OD",$P(ODStandardID,"||",2),"ODS",$P(ODStandardID,"||",3)),"^",2)
	b ;ODDesc
	i OtherDesc="" s OtherDesc=ODDesc
	s HospitalCode=$G(^DHCPESetting("DHCPE","HospitalCode"))
	s vStationID=""
	If ChartID'="" s vStationID=##class(web.DHCPE.ResultEdit).GetPEStation($g(ChartID))
	i vStationID="" d
	.s vStationID=ItemStation
	s CurUser=%session.Get("LOGON.USERID")
	s str=""
	s EDID=0
	i OtherDesc=""{
		f  s EDID=$o(^DHCPEED(EDID)) q:EDID=""  d
		.d GetOneInfo
	}else{
		s Desc=$ZCVT(OtherDesc,"U")
		b ;Desc
		s RowIds="^"
	 	s TextDesc=$O(^DHCPEEDA(0,"Alias",Desc),-1)
	 	f  s TextDesc=$O(^DHCPEEDA(0,"Alias",TextDesc)) Q:(""=TextDesc)||(TextDesc'[Desc)  d
		.s ARowId=0
		.f  s ARowId=$O(^DHCPEEDA(0,"Alias",TextDesc,ARowId)) q:ARowId=""  d
		..s EDID=$p($g(^DHCPEEDA(ARowId)),"^",1)
		..q:EDID=""
		..q:RowIds[("^"_EDID_"^")
		..s RowIds=RowIds_EDID_"^"
		..d GetOneInfo
		s TextDesc=$O(^DHCPEED(0,"CODE",Desc),-1)
	 	f  s TextDesc=$O(^DHCPEED(0,"CODE",TextDesc)) Q:((""=TextDesc)||(TextDesc'[Desc))  d
		.s EDID=0
		.f  s EDID=$O(^DHCPEED(0,"CODE",TextDesc,EDID)) q:EDID=""  d
		..q:EDID=""
		..q:RowIds[("^"_EDID_"^")
		..s RowIds=RowIds_EDID_"^"
		..d GetOneInfo
	 	s TextDesc=$O(^DHCPEED(0,"Conclusion",Desc),-1)
	 	f  s TextDesc=$O(^DHCPEED(0,"Conclusion",TextDesc)) Q:(""=TextDesc)||(TextDesc'[Desc)  d
		.s EDID=0
		.f  s EDID=$O(^DHCPEED(0,"Conclusion",TextDesc,EDID)) q:EDID=""  d
		..q:EDID=""
		..q:RowIds[("^"_EDID_"^")
		..s RowIds=RowIds_EDID_"^"
		..d GetOneInfo
	}
	k ^TempDHCPEEDDesc(Job)
	d GetStrs
	
	q str
	
GetOneInfo	
	s (Detail,DC,Code)=""
	Set Cancle=0
	s RowId=EDID
	q:RowId=""
	q:'$D(^DHCPEED(RowId))
	s EDLoc=##class(web.DHCPE.DHCPECommon).GetEDloc(AdmLocID)
	q:'$D(^DHCPEED(0,"EDLOC",EDLoc,RowId))
	s:$g(^DHCPEDataEx("BaseData","DHCPEExpertDiagnosis","Active",RowId))'="Y" Cancle=1
	//s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("ED",RowId)         //Add by 090702
  	//q:LocFlag=1 
	s Str=##class(web.DHCPE.ResultEdit).GetAgeSex(PAADM)
	s SexID=""
	s SexID=$p(Str,"^",3)
	//s SexCode=$p(Str,"^",2)
	//i SexCode'=""  s SexID=$o(^CT("SEX",0,"Code",SexCode,0))
	s Sex=$g(^DHCPEDataEx("BaseData","DHCPEExpertDiagnosis","Sex",RowId))
	Quit:(Sex'="")&&(Sex'=SexID)
	s Detail=$P($G(^DHCPEED(RowId,"Detail")),"^",1)
	s DC=$P($G(^DHCPEED(RowId,"1")),"^",1)
	
	s Code=$P($G(^DHCPEED(RowId,"1")),"^",6)
	s StationID=$P($G(^DHCPEED(RowId,"1")),"^",7)
	q:(StationID="")
	s CurLocID=$P($G(^DHCPEED(RowId,"1")),"^",10)
	q:(CurLocID'=LocID)&&(CurLocID'="")&&(LocID'="")
	;s User=$p(^DHCPEED(RowId,1),"^",2)   //Add
	i (vStationID'="")&&(vStationID'=StationID)&&(StationID'="") s Cancle=1 ;&&(("^"_NormalED_"^")'[("^"_RowId_"^"))
	;b ;Cancle2
	Quit:(Cancle=1)
	q:$D(^TempDHCPEEDDesc(Job,DC))
	s ^TempDHCPEEDDesc(Job,DC)=""
	
	s Sort=$p(^DHCPEED(RowId,1),"^",9) //+$G(^DHCPEED(RowId,"UseCount"))
	i Sort="" s Sort="999999999"
	s OneInfo=RowId_"^"_Detail_"^"_DC_"^"_Code
	s ^TempDHCPEEDInfo(Job,Sort,DC)=OneInfo
	q
GetStrs
	s Sort=""
	f  s Sort=$O(^TempDHCPEEDInfo(Job,Sort)) q:Sort=""  d
	.s RowID=""
	.f  s RowID=$O(^TempDHCPEEDInfo(Job,Sort,RowID)) q:RowID=""  d
	..i str="" d
	...s str=RowID
	..e  d
	...s str=str_$c(1)_RowID
	
	k ^TempDHCPEEDInfo(Job)
	q
}

ClassMethod GetWriteWay(StationID)
{
	s UserID=%session.Get("LOGON.USERID")
	s LocID=%session.Get("LOGON.CTLOCID")
	s GroupID=%session.Get("LOGON.GROUPID")
	s WriteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))
	
	
	s SuperFlag=0
	s:$G(^DHCPESetting("DHCPE","SuperGroup"))=GroupID SuperFlag="1"
	s CompleteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"WriteWay",StationID))
	s:CompleteFlag="" CompleteFlag=3
	s AuditCpmpleteFlag=0
	s:CompleteFlag="3" AuditCpmpleteFlag=1
	q AuditCpmpleteFlag
}

ClassMethod OutAuditDoc(StationID, PAADM)
{
	
	s UserID=%session.Get("LOGON.USERID")
	s LocID=%session.Get("LOGON.CTLOCID")
	s GroupID=%session.Get("LOGON.GROUPID")
	s WriteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))
	
	
	s SuperFlag=0
	s:$G(^DHCPESetting("DHCPE","SuperGroup"))=GroupID SuperFlag="1"
	s CompleteFlag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"WriteWay",StationID))
	s:CompleteFlag="" CompleteFlag=3
	s AuditCpmpleteFlag=0
	s:CompleteFlag="3" AuditCpmpleteFlag=1
	
	s csdisabled=""
	s AutoAudit="N"
	s AutoAudit=$p(^DHCPEST(StationID),"^",6)
	i AutoAudit="Y" s csdisabled="disabled='disabled'"
	i AutoAudit="Y" w "<font color=red>自动提交站点请不要点提交</font>"
	;i StationID=9 s csdisabled="disabled='disabled'"
	;i StationID=9 w "<font color=red>超声项目请不要点提交</font>"
	
	;s AddItemStation="24"  //协和特殊写死的加项超声算到站点里面
	;s CSStation="9"  //超声站点
	
	;i StationID=AddItemStation d
	;.s StationID=CSStation
	.;s AddItemFlag="1"
	
	;^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",chartID)
	
	s Job=$J
	//w "<TR><TD colspan=3 style='white-space:normal; word-break:break-all;'>"
	k ^TempDHCPEDoc(Job)
	s LocID=%session.Get("LOGON.CTLOCID")
	s UserID=""
	f  s UserID=$O(^DHCPEDataEx("ChartAssign",UserID)) q:UserID=""  d
	.s GroupID=""
	.f  s GroupID=$O(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID)) q:GroupID=""  d
	..q:$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))'="Y"
	..s ^TempDHCPEDoc(Job,UserID)=""
	s SSID=##class(web.DHCPE.ResultEdit).GetSSId(PAADM, StationID)
	s AuditUserID=""
	s AuditDate=""
	s AuditFlag=0
	i SSID'="" d
	.s Status=$P(^DHCPESS(SSID,1),"^",7)
	.q:(Status="NA")
	.s AuditFlag=1
	.s AuditUserID=$P(^DHCPESS(SSID,1),"^",5)
	.s AuditDate=$P(^DHCPESS(SSID,1),"^",6)
	.s:AuditDate'="" AuditDate=##class(websys.Conversions).DateLogicalToHtml(AuditDate)
	;style='white-space:normal; word-break:break-all;'
	w "<Table border=1 cellspacing='0' cellpadding='0' id='EDTABLE' style='width:100%;white-space:normal; word-break:break-all;'>"
	
	///输出提交医生
	w "<TR>"
	w "<TD colspan=2 style='width:50%;white-space:normal; word-break:break-all;'>"
	//下拉列表
	w "提交医生"
	w "<select name='AuditUser' id='AuditUser' style='width:60%;white-space:normal; word-break:break-all;' HEIGHT=0>",!
	w "<option value=''></option>",!
	s UserID=""
	f  s UserID=$O(^TempDHCPEDoc(Job,UserID)) q:UserID=""  d
	.s selected=""
	.s:UserID=AuditUserID selected="selected"
	.w "<option value='"_UserID_"' "_selected_">"_$P($G(^SSU("SSUSR",UserID)),"^",2)_"</option>",!
	w "</select>",!
	;w "</TD><TD rowspan=3><button id='imgPic'></button></TD>"
	w "</TD><TD rowspan=3><img id='imgPic' src='../images/uiimages/patdefault.png' style='WIDTH: 109px; HEIGHT: 110px'></TD>"
	w "</TR>"
	
	w "<TR><TD colspan=2>"
	w "提交日期<input id='AuditDate'  style='white-space:normal; word-break:break-all;' value="_AuditDate_">"
	w "</TD></TR>"
	
	
	s UserID=%session.Get("LOGON.USERID")
	s ShowED=$G(^DHCPEShowEDInfo(UserID))
	;s checked="checked=checked"
	s checked=""
	s:ShowED="1" checked="checked=checked"
	if (WriteFlag="Y"){
	w "<TR><TD colspan=2>"
	w "显示建议<input type='checkbox' onchange='ShowEDInfo_change(this)' id='ShowEDInfo'"_checked_">"
	w "</TD></TR>"
	
	k ^TempDHCPEDoc(Job)
	
	i AuditFlag="1" d
	.w "<tr>"
	.w "<td colspan=2><button class='i-btn';white-space:normal; word-break:break-all;' onclick='StationSCancelSub(this)' id='DBAudit'><B>取消</B></button></td>"
	.;w "<td><font color=red>已提交</font></td>"
	.w:SuperFlag=1 "<td><button class='i-btn' onclick='DBUpdate_click(this)' name='DBUpdate' id='DBUpdate'>保存建议</button></td>"
	.w:SuperFlag'=1 "<td>&nbsp</td>"
	.w "</tr>"
	e  d
	.w "<tr>"
	.w "<td><button class='i-btn'; onclick='Audit_click(this,"_AuditCpmpleteFlag_")' id='DBRAudit'"_csdisabled_"><B>提交(F4)</B></button></td>"
	.w "<td><button class='i-btn'; onclick='DBUpdate_click(this)' name='DBUpdate' id='DBUpdate'>保存建议</button></td>"

	.w "<td><button onclick='AddDefaultEDID(this)' id='DBAddResult' class='i-btn'>添加建议</button></td>"
	.w "</tr><tr>"
	.w "<td><button onclick='AddRecommEDID(this)' id='DBAddRecommResult' class='i-btn'>跳出建议</button></td>"
	.w "<td>建议模糊查询</td><td><input id='QueryED'  style='width:80%;white-space:normal; word-break:break-all;' onkeydown='QueryED_KeyDown(this,"_StationID_","_PAADM_")'></td>"
	.w "</tr>"
	}
	s colspans=2
	s:AuditFlag=1 colspans=2
	w "<TR align='center' bgcolor='' style='white-space:normal; word-break:break-all;'>"
	w "<TD style='width=30%;white-space:normal; word-break:break-all;'>结论</TD>"
	w "<TD style='width=65%;white-space:normal; word-break:break-all;' colspan="_colspans_">建议</TD>"
	;w:AuditFlag'="1" "<TD style='width=10%;white-space:normal; word-break:break-all;'>&nbsp;</TD>"
	w "</TR>"
	
	i SSID'=""  d
	.s Sub=0
	.f  s Sub=$O(^DHCPESS(SSID,"Diagnosis",Sub)) q:Sub=""  d
	..s SDID=SSID_"||"_Sub
	..s DisplayDesc=$G(^DHCPEDataEx("DHCPESSDiagnosis","DisplayDesc",SDID))
	..s Advice=$P(^DHCPESS(SSID,"Diagnosis",Sub),"^",7)
	..w "<TR style='white-space:normal; word-break:break-all;'>"
	..w "<TD style='white-space:normal; word-break:break-all;'><textarea style='width:100%;white-space:normal; word-break:break-all;' rows=3 id='"_SDID_"^Desc' name='Desc'>"_DisplayDesc_"</textarea></TD>"
	..w "<TD colspan="_colspans_" style='white-space:normal; word-break:break-all;'><textarea style='width:85%;white-space:normal; word-break:break-all;' rows=3 id='"_SDID_"^Advice' name='Advice'>"_Advice_"</textarea>"
	..w:AuditFlag'="1" "<button name='DeleteED' id='"_SDID_"' onclick='DeleteEDInfo(this,1)'><font color=red>×</font></button>"
	..w "</TD>"
	..w "</TR>"
	w "<TABLE>"
	Quit $$$OK
}

ClassMethod GetLisOrdItem(OrdItemID)
{
	s SpecNo=$p($G(^OEORD(+OrdItemID,"I",$P(OrdItemID,"||",2),3)),"^",20)
	q:SpecNo="" OrdItemID
	s retOrdItemID=""
	s OrdSub=0
	f  s OrdSub=$O(^OEORD(0,"EpisNo",SpecNo,+OrdItemID,OrdSub)) q:(OrdSub="")||(retOrdItemID'="")  d
	.s ItemID=+OrdItemID_"||"_OrdSub
	.i $D(^DHCPERLT(0,"OEORI",ItemID)) d
	..s retOrdItemID=ItemID
	i retOrdItemID="" d
	.s retOrdItemID=OrdItemID
	
	//s OrdName=##class(web.DHCPE.ResultDiagnosis).GetAllNameBySpecNo(SpecNo)
	s OrdName=##class(web.DHCPE.BarPrint).GetARCIMDesc(SpecNo,+OrdItemID,",")
	s OrdName=$P(OrdName,$C(1),1)
	q retOrdItemID_"^"_OrdName
}

ClassMethod SetDealExe(PAADM)
{
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	q:$D(^DHCPEIADM(IADM,"DealExe")) "1"
	s ^DHCPEIADM(IADM,"DealExe")=$H_"^"_%session.Get("LOGON.USERID")
	q "0"
}

ClassMethod CancelExecute(OEORDItemID)
{
	s $p(^OEORD($p(OEORDItemID,"||",1),"I",$p(OEORDItemID,"||",2),1),"^",13)=1	//status: 1-verified  4-stopped  6-executed
	q 0
}

/// 返回给医生Combo的值(挂号,排班调整) ;w ##class(web.DHCPE.ResultNew).GetAllUserDocBroker("Wl","")
ClassMethod GetAllUserDocBroker(Desc As %String = "", UserID As %String = "") As %String
{
	s ^tmpgry("GetResEQBroker")=Desc_","_UserID
	s ret1=""
	Set rset=##class(%ResultSet).%New("web.DHCPE.ResultNew:FindAllUserDocCustom")
	do rset.Execute(Desc)
	While (rset.Next()) {
		s DocDesc=rset.GetData(1)
		s DocCode=rset.GetData(2)
		s DocID=rset.GetData(3)
		s UseRowid=rset.GetData(4)
		s DocOtherName="" 
		i DocID'="" {
			i $d(^CTPCP(DocID,3)) s DocOtherName=$p(^CTPCP(DocID,3),"^",28)
		}
		i DocOtherName'="" s DocDesc=DocDesc_"-"_DocOtherName
		s ret=UseRowid_$C(1)_DocDesc
	   i ret1="" s ret1=ret
	   e  s ret1=ret1_"^"_ret
	   ;超长截取控制
	   Q:$l(ret1)>10000
	}
	d rset.Close()
	Q ret1
}

// SSUSR_CareProv_DR IS NOT NULL AND 

Query FindAllUserDocCustom(desc As %String) As %Library.SQLQuery(CONTAINID = 3, ROWSPEC = "Desc:%String,Code:%String,HIDDEN:%String,HIDDEN:%String")
{
	SELECT SSUSR_Name, SSUSR_Initials , SSUSR_CareProv_DR, SSUSR_RowId  FROM SQLUser.SS_User
    WHERE ((%STRING(SSUSR_CareProv_DR->CTPCP_OtherName) %STARTSWITH %STRING(:desc))
    OR (%STRING(SSUSR_Name) %STARTSWITH %STRING(:desc)))
}

ClassMethod getDiagAdvice(SDID)
{
  //qshe 2013-11-20  取 诊断意见
   	s SSID=$P(SDID,"||")
   	s Sub=$P(SDID,"||",2)
   	s DisplayDesc=$G(^DHCPEDataEx("DHCPESSDiagnosis","DisplayDesc",SDID))
	s Advice=$P(^DHCPESS(SSID,"Diagnosis",Sub),"^",7)
	q DisplayDesc_"^"_Advice
}

ClassMethod GetResultItem(admId, ordId, itmid, EyeSeeFlag As %String = 0) As %String
{
  //qshe 2013-11-20  取细项值
   //##class(web.DHCPE.ResultNew).GetResultItem()
   q:$P(itmid,"||",2)="" ""
   	s rw=$O(^DHCPERLT(0,"ADMOD",admId,ordId,itmid,""))
   	i rw'="" d
   	.s val=$P(^DHCPERLT(rw),"^",4)
   	e  d
   	.s ODType=$P(^DHCPEST(+itmid,"OD",$P(itmid,"||",2)),"^",2)
   	.q:(ODType="C")||(ODType="N")
   	.s myStr=##class(web.DHCPE.ResultEdit).GetAgeSex(admId)
	.s myAge=$p(myStr,"^",1)
	.s mySex=$p(myStr,"^",2)
	.s val=##class(web.DHCPE.ResultEdit).GetNormal(itmid, mySex, myAge)
   	s val=$G(val)
   	q:EyeSeeFlag=0 val
   	i $L(val,";诊断意见:")>1 d
	.s ZDYJ=$p(val,";诊断意见:",2)
	.s Other=$p(val,";诊断意见:",1)
	.s ZDDefaultValue=ZDYJ
	.s JCSJ=$p(Other,";检查所见:",2)
	.s EyeSeeDefaultValue=JCSJ
	.s val=ZDDefaultValue_"^"_EyeSeeDefaultValue
	e  d
	.s val=val_"^"
	q val
}

ClassMethod GetDefaultEDByStation(StationID)
{
	//w ##class(web.DHCPE.ResultNew).GetDefaultEDByStation(1)
	s ret=""
	s EDID=""
	f  s EDID=$O(^DHCPEED(0,"Conclusion","默认",EDID)) q:(EDID="")||(ret'="")  d
	.s CurStation=$P(^DHCPEED(EDID,1),"^",7)
	.q:CurStation'=StationID
	.s ret=EDID
	q ret
}

ClassMethod DeleteResultByOrder(OrderID, EpisodeID)
{
	q:OrderID="" ""
	q:EpisodeID="" ""
	s RLTID=0
	f  s RLTID=$o(^DHCPERLT(0,"OEORI",OrderID,RLTID)) q:RLTID=""  d
	.&sql(DELETE FROM SQLUser.DHC_PE_Result WHERE RLT_RowId=:RLTID)
	
	q 0
}

/// d ##class(web.DHCPE.ResultNew).GetNowItemSum(2489)
ClassMethod GetNowItemSum(Date As %String = "")
{
	s UserID=%session.Get("LOGON.USERID")
	s LocID=%session.Get("LOGON.CTLOCID")
	s GroupID=%session.Get("LOGON.GROUPID")
	s:Date="" Date=+$H
	k ^TempDHCPE("NowItemSum",UserID)
	s Info=""
	s Time=0
	f  s Time=$o(^DHCPEIADM(0,"AdmDateTime",Date,Time)) q:Time=""  d
	.s IADM=0
	.f  s IADM=$o(^DHCPEIADM(0,"AdmDateTime",Date,Time,IADM)) q:IADM=""  d
	..s Status=$p($G(^DHCPEIADM(IADM)),"^",8)
	..q:Status'="ARRIVED"
	..s PAADM=$p(^DHCPEIADM(IADM),"^",1)
	..s LocFlag=##class(web.DHCPE.PreCommon).GetLocFlag("PAADM",PAADM)
	..q:LocFlag=1
	..s VIPLevel=+##class(web.DHCPE.PreCommon).GetVIPLevel("PAADM",PAADM)
	..;s VIP
	..s OEOrdID=$O(^OEORD(0,"Adm",PAADM,0))
	..q:OEOrdID=""
	..s ItemSub=0
	..f  s ItemSub=$O(^OEORD(OEOrdID,"I",ItemSub)) q:ItemSub=""  d
	...s ArcItemID=$P($G(^OEORD(OEOrdID,"I",ItemSub,1)),"^",2)
	...Q:ArcItemID=""
	...s Stat=$P(^OEORD(OEOrdID,"I",ItemSub,1),"^",13)

	...q:Stat="4"
	...s ArcItemID=$P(^OEORD(OEOrdID,"I",ItemSub,1),"^",2)
	...s StationID=$o(^DHCPEST(0,"STORD_ARCIM",ArcItemID,0))
	...q:StationID=""
	...s Flag=$G(^DHCPEDataEx("ChartAssign",UserID,LocID,GroupID,"Write",StationID))
	...q:Flag'="Y"
	...;w 2
	...s OrdItemID=OEOrdID_"||"_ItemSub
	...//下面两句控制只显示已检的
	...s RLTID=$O(^DHCPERLT(0,"OEORI",OrdItemID,0))
	...;q:RLTID=""
	...i $D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrdItemID)) d
	....s Count=$I(^TempDHCPE("NowItemSum",UserID,ArcItemID,"RefuseCheck"))
	....s ^TempDHCPE("NowItemSum",UserID,ArcItemID,"RefuseCheck",VIPLevel,OrdItemID)=""
	...e  d
	....s RLTID=$O(^DHCPERLT(0,"OEORI",OrdItemID,0))
	....i RLTID="" d
	.....s Count=$I(^TempDHCPE("NowItemSum",UserID,ArcItemID,"NoCheck"))
	.....s ^TempDHCPE("NowItemSum",UserID,ArcItemID,"NoCheck",VIPLevel,OrdItemID)=""
	....e  d
	.....s CurUser=$P(^DHCPERLT(RLTID),"^",5)
	.....q:CurUser'=UserID
	.....s Count=$I(^TempDHCPE("NowItemSum",UserID,ArcItemID,"HadCheck"))
	.....s ^TempDHCPE("NowItemSum",UserID,ArcItemID,"HadCheck",VIPLevel,RLTID)=""
	q:'$D(^TempDHCPE("NowItemSum",UserID)) Info

	s Info=Info_"<DIV height=120 width=100%><TABLE border=1 width=100% font-size=1 cellspacing='0' cellpadding='0'><TR><TD width=85%>项目</TD><TD width=10%>已</TD><TD width=10%>未</TD><TD width=10%>弃</TD><TR>"
	;s Info=Info_"<DIV height=140><TABLE border=1 width=140 font-size=1 cellspacing='0' cellpadding='0'><TR><TD width=110>项目</TD><TD width=30>已检</TD><TR>"
	
	s ArcItemID=""
	f  s ArcItemID=$O(^TempDHCPE("NowItemSum",UserID,ArcItemID)) q:ArcItemID=""  d
	.s Info=Info_"<TR>"
	.s ArcItemDesc=##class(web.DHCPE.DHCPECommon).GetArcDesc(ArcItemID)
	.s HadCheck=$G(^TempDHCPE("NowItemSum",UserID,ArcItemID,"HadCheck"))
	.s:HadCheck="" HadCheck="&nbsp;"
	.s NoCheck=$G(^TempDHCPE("NowItemSum",UserID,ArcItemID,"NoCheck"))
	.s:NoCheck="" NoCheck="&nbsp;"
	.s RefuseCheck=$G(^TempDHCPE("NowItemSum",UserID,ArcItemID,"RefuseCheck"))
	.s:RefuseCheck="" RefuseCheck="&nbsp;"
	.s Info=Info_"<TD>"_ArcItemDesc_"</TD><TD style='cursor:hand' id="_ArcItemID_" onclick=ShowHadCheck(this)>"_HadCheck_"</TD><TD style='cursor:hand' id="_ArcItemID_" onclick=ShowNoCheck(this)>"_NoCheck_"</TD><TD style='cursor:hand' id="_ArcItemID_" onclick=ShowRefuseCheck(this)>"_RefuseCheck_"</TD>"
	.;s Info=Info_"<TD>"_ArcItemDesc_"</TD><TD style='cursor:hand' id="_ArcItemID_" onclick=ShowHadCheck(this)>"_HadCheck_"</TD>"
	.s Info=Info_"</TR>"
	s Info=Info_"</TABLE></DIV>"
	q Info
}

ClassMethod OutCheckInfo(Type, ArcimID)
{
	s UserID=%session.Get("LOGON.USERID")
	
	s Info="<TABLE width=100% Border=1 cellspacing='0' cellpadding='0'>"
	s Info=Info_"<TR><TD>VIP等级</TD><TD>登记号</TD><TD>姓名</TD><TD>性别</TD><TD>年龄</TD><TD>电话</TD><TD>单位</TD><TD>部门</TD><TD>医生</TD></TR>"
	i Type="HadCheck" d
	.s VIPLevel=""
	.f  s VIPLevel=$O(^TempDHCPE("NowItemSum",UserID,ArcimID,"HadCheck",VIPLevel)) q:VIPLevel=""  d
	..s VIPDesc=$P(^DHCPEVIPLevel("VIP",VIPLevel),"^",2)
	..s RLTID=""
	..f  s RLTID=$O(^TempDHCPE("NowItemSum",UserID,ArcimID,"HadCheck",VIPLevel,RLTID),-1) q:RLTID=""  d
	...s OEOrdItemID=$P(^DHCPERLT(RLTID),"^",9)
	...d GetCheckInfo
	e  d
	.s VIPLevel=""
	.f  s VIPLevel=$O(^TempDHCPE("NowItemSum",UserID,ArcimID,Type,VIPLevel)) q:VIPLevel=""  d
	..s VIPDesc=$P(^DHCPEVIPLevel("VIP",VIPLevel),"^",2)
	..s OEOrdItemID=""
	..f  s OEOrdItemID=$O(^TempDHCPE("NowItemSum",UserID,ArcimID,Type,VIPLevel,OEOrdItemID)) q:OEOrdItemID=""  d
	...d GetCheckInfo
	s Info=Info_"</TABLE>"
	w Info
	q
GetCheckInfo
	s PAADM=$P(^OEORD(+OEOrdItemID),"^",1)
	s DepartName=##class(web.DHCPE.PreCommon).GetPosition("PAADM",PAADM)
	s:DepartName="" DepartName="&nbsp;"
	s IADM=$O(^DHCPEIADM(0,"PAADM",PAADM,0))
	s GADM=$P(^DHCPEIADM(IADM),"^",2)
	s GDesc="&nbsp;"
	i GADM'="" d
	.s GBaseID=$P(^DHCPEGADM(GADM),"^",1)
	.s GDesc=$P(^DHCPEGBI(GBaseID),"^",2)
	s PaPatID=$P(^PAADM(PAADM),"^",1)
	s RegNo=$P(^PAPER(PaPatID,"PAT",1),"^",1)
	s BaseID=$O(^DHCPEPreIBI(0,"PAPMINo",RegNo,0))
	b ;BaseID
	s Name=$P(^PAPER(PaPatID,"ALL"),"^",1)
	s Sex=$P(^PAPER(PaPatID,"ALL"),"^",7)
	s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
	s IDCard=$P($g(^PAPER(PaPatID,"PAT",3)),"^",6)
	;s Name=Name_" "_Sex
	s Dob=$P(^PAPER(PaPatID,"ALL"),"^",6)
	s Dob=$ZD(Dob,3)
	s Age=##class(web.DHCPE.DHCPECommon).GetCurAge(Dob)
	s Tel=""
	i BaseID'="" d
	.s Tel=$P(^DHCPEPreIBI(BaseID),"^",8)
	.s:Tel="" Tel=$P(^DHCPEPreIBI(BaseID),"^",6)
	.s:Tel="" Tel=$P(^DHCPEPreIBI(BaseID),"^",7)
	s:Tel="" Tel=$P(^PAPER(PaPatID,"PER",4),"^",21)
	//s:Tel="" Tel=$P(^PAPER(PaPatID,"PER",4),"^",18)
	s:Tel="" Tel=$P(^PAPER(PaPatID,"PER",1),"^",11)
	s:Tel="" Tel=$P(^PAPER(PaPatID,"PER",1),"^",9)
	s:Tel="" Tel="&nbsp;"
	s DocName=""
	s RLTID=$O(^DHCPERLT(0,"OEORI",OEOrdItemID,0))
	i RLTID'="" d
	.s DocUserId=$P(^DHCPERLT(RLTID),"^",5)
	.i DocUserId'="" d
	..s DocName=$P(^SSU("SSUSR",DocUserId),"^",2)

	s Info=Info_"<TR><TD>"_VIPDesc_"</TD><TD>"_RegNo_"</TD><TD>"_Name_"</TD><TD>"_Sex_"</TD><TD>"_Age_"</TD><TD>"_Tel_"</TD><TD>"_GDesc_"</TD><TD>"_DepartName_"</TD><TD>"_DocName_"</TD></TR>"
	s VIPDesc="&nbsp;"
	q
}

// 判断是否存在荒诞值，不允许保存

ClassMethod IsHDValue(ResultStr)
{
	s ResultLength=$L(ResultStr,$C(1))
	s HDFlag=0
	f i=1:1:ResultLength
	{
		s OneResult=$P(ResultStr,$C(1),i)
		s ODID=$P(OneResult,"^",2)
		continue:+ODID=0
		s Value=$P(OneResult,"^",3)
		continue:Value=""
		s ItemType=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",2)
		s ItemDesc=$P(^DHCPEST(+ODID,"OD",$P(ODID,"||",2)),"^",1)
		s ValueId=0
		For  Set ValueId=$O(^DHCPEST(+ODID,"OD",$P(ODID,"||",2),"ODS",ValueId)) Quit:(ValueId="")||(HDFlag=1)  Do
		.s RowId=ODID_"||"_ValueId
		.s StrData=$G(^DHCPEST(+ODID,"OD",$P(ODID,"||",2),"ODS",ValueId))
		.q:$G(^DHCPEDataEx("DHCPEODStandard","HDValue",RowId))'="Y"
		.i (ItemType="C")||(ItemType="N") d
		..s MinNum=$P(StrData,"^",4)
		..s MaxNum=$P(StrData,"^",5)
		..i (MinNum<=Value)&&(MaxNum>=Value) s HDFlag=1
		.e  d
		..s HDValue=$P(StrData,"^",2)
		..s:Value[HDValue HDFlag=1
		q:HDFlag=1
	}
	q:HDFlag=1 "-1^"_ItemDesc_"结果为荒诞值不允许保存"
	q 0
}

ClassMethod GetPisCode(OrdItemID)
{
    s code=""
    s ArcItemId=$p(^OEORD($p(OrdItemID,"||",1),"I",$p(OrdItemID,"||",2),1),"^",2)
    s Stat=$P($g(^OEORD($p(OrdItemID,"||",1),"I",$p(OrdItemID,"||",2),1)),"^",13)
	q:Stat="4" "-1^该医嘱已停"
    i $D(^DHCPEDataEx("DHCPEPreIOrdItem","RefuseCheck",OrdItemID)) q "-1^该医嘱已经放弃"
    s code=$g(^DHCPEDataEx("DHCPEStationOrder","PISCodeType",ArcItemId))
	q 0_"^"_code
}

ClassMethod IsOtherPatientToHP(PAADM)
{
	s ID="",IADMDR=""
	s ID=$o(^User.DHCPEOtherPatientToHPI("OTHPAADMDRIndex",PAADM,0))
	s flag=0
	i ID'=""  D
	.S AuditUser=$LG(^User.DHCPEOtherPatientToHPD(ID),13)
	E  D
	.s IADMDR=$o(^DHCPEIADM(0,"PAADM",PAADM,0))
	i (ID="")&(IADMDR="") s flag=1
	q flag
}

ClassMethod GetPatientID(PAADM)
{
	q:PAADM="" ""
	q $P(^PAADM(PAADM),"^",1)
}

Storage Default
{
<Data name="ResultNewDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.ResultNewD</DataLocation>
<DefaultData>ResultNewDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.ResultNewD</IdLocation>
<IndexLocation>^web.DHCPE.ResultNewI</IndexLocation>
<StreamLocation>^web.DHCPE.ResultNewS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
