Class web.DHCPE.ReportShowOther Extends %Persistent
{

ClassMethod GetOtherURL(OEORDID)
{
	q ""
	;w ##class(web.DHCPE.ReportShowOther).GetOtherURL("366579||23")
	s $ZT="OtherErr"
	q:OEORDID="" ""
	s ARCIMID=$P(^OEORD(+OEORDID,"I",$P(OEORDID,"||",2),1),"^",2)
	s MethodName=..GetMethodNameByArcID(ARCIMID)
	q:MethodName="" ""
	s Path=$zobjclassmethod("web.DHCPE.ReportShowOther",MethodName,OEORDID)
	q Path
OtherErr
	q ""
}

/// 根据医嘱ID得到对应的返回方法名称
ClassMethod GetMethodNameByArcID(ARCIMID)
{
	s STID=$O(^DHCPEST(0,"STORD_ARCIM",ARCIMID, 0))
	q:STID="" ""
	;心电站点
	i STID=""
	{
		q "GetEkgURL"
	}
	;放射站点
	i STID=""
	{
		q "GetRaxURL"
	}
	;病理站点
	i STID=""
	{
		q "GetPISURL"
	}
	;超声站点
	i STID=""
	{
		q "GetCSURL"
	}
	;动脉硬化站点
	i STID=""
	{
		q "GetOwnImgURL"
	}
	q ""
}

/// 心电调用
ClassMethod GetEkgURL(OEORDID)
{
	s URL=##class(web.DHCPE.EkgInterface.Main).GetEkgImgSrc(OEORDID)
	q:URL="NONE" ""
	q "IMG^"_URL
}

/// 放射调用
ClassMethod GetRaxURL(OEORDID)
{
	s RARRowId=$o(^DHCPACRegInfoi("OEORI",OEORDID,0))
	q:RARRowId="" ""
	s RisStudyNo=$p(^DHCPACRegInfo(RARRowId),"^",2)
	q:RisStudyNo="" ""
	s URL=##class(web.DHCRisCommFunctionEx).GetReportUrl(OEORDID,RisStudyNo)
	q "HTML^"_URL
}

/// 病理调用
ClassMethod GetPISURL(OEORDID)
{
	s curZN=$ZNSpace
	zn "PIS"
	s value=##class(PISApp.PISService).GetRptInfoByOeorditemID(OEORDID)
	zn curZN
	q:value="" ""
	//以上判断是否存在病理结果
	s cLocDr=$P(^OEORD(+OEORDID,"I",$P(OEORDID,"||",2),1),"^",3)
	s URL="http://172.26.201.3/PISWeb/Default.aspx?OID="_OEORDID_"&LOCID="_cLocDr_"&RPTID=6"
	q "HTML^"_URL
}

/// 超声调用
ClassMethod GetCSURL(OEORDID)
{
	;FTP IP地址
	s FTPIP="10.160.17.11"
	;FTP用户名    
	s FTPUser="root"
	;FTP用户密码    
	s PassWord="Root!234"
	;存放图片的路径    
	s Directory="/tem/"   
	s RARRowId=$o(^DHCPACRegInfoi("OEORI",ordItmId,0))
	q:RARRowId="" ""
	s RisStudyNo=$p(^DHCPACRegInfo(RARRowId),"^",2)
	q:RisStudyNo="" ""
	s FileName=RisStudyNo_".jpg"
	s sc=..FTPFileExit(FTPIP,FTPUser,PassWord,Directory,FileName)
	q:sc=0 ""
	s FileName="ftp://"_FTPUser_":"_PassWord_"@"_FTPIP_Directory_FileName
	q "IMG^"_FileName
}

/// 自己上传得调用，如动脉硬化
ClassMethod GetOwnImgURL(OEORDID)
{
	;FTP IP地址
	s FTPIP="10.160.17.11"
	;FTP用户名    
	s FTPUser="root"
	;FTP用户密码    
	s PassWord="Root!234"
	;存放图片的路径    
	s Directory="/tem/"   
	s FileName=OEORDID_".jpg"
	s sc=..FTPFileExit(FTPIP,FTPUser,PassWord,Directory,FileName)
	q:sc=0 ""
	s FileName="ftp://"_FTPUser_":"_PassWord_"@"_FTPIP_Directory_FileName
	q "IMG^"_FileName
}

/// 判断ftp文件是否存在
ClassMethod FTPFileExit(FTPIP, FTPUser, PassWord, Directory, FileName)
{
	;d ##class(web.DHCPE.Tools).FTPTest()
	Set ftp=##class(%Net.FtpSession).%New()
	If 'ftp.Connect(FTPIP,FTPUser,PassWord)  q 0
	s sc=ftp.Rename(Directory_FileName,Directory_FileName)
	If 'ftp.Logout() q 0
	q sc
}

/// 删除文件
ClassMethod DeleteFTPFile(FTPIP, FTPUser, PassWord, Directory, FileName)
{
	;d ##class(web.DHCPE.Tools).DeleteFTPFile("10.0.11.51","root","vplexa34","test","6318888||3.jpg")
	Set ftp=##class(%Net.FtpSession).%New()
	If 'ftp.Connect(FTPIP,FTPUser,PassWord)  q 0
	s sc=ftp.Delete(Directory_FileName)
	If 'ftp.Logout() q 0
	q sc
}

ClassMethod DeleteByOEID(OEID)
{
	;FTP IP地址
	s FTPIP="10.0.11.27"
	;FTP用户名    
	s FTPUser="administrator"
	;FTP用户密码    
	s PassWord="nyfyhis20081"
	;存放图片的路径    
	s Directory="/TJXT/"   
	s FileName=OEID_".jpg"
	q ..DeleteFTPFile(FTPIP, FTPUser, PassWord, Directory, FileName)
}

/// 输出自己上传的按钮
ClassMethod OutUploadButton(OEORDID)
{
	//d ##class(web.DHCPE.ReportShowOther).OutUploadButton("366579||23")
	q:OEORDID="" ""
	w "<input type= 'file' id= 'File' style= 'display:none'>"
	w "<button id='"_OEORDID_"' onclick='UploadImgInfo(this)'>上传</button>"
}

ClassMethod ViewImgInfo(OEORDID)
{
	s OtherInfo=..GetOtherURL(OEORDID)
	q:OtherInfo=""
	s Length=$L(OtherInfo,"^")
	s Flag=$P(OtherInfo,"^",1)
	f i=2:1:Length  d
	.s OneUrl=$P(OtherInfo,"^",i)
	.i Flag="HTML" d
	..w "<iframe src='"_OneUrl_"' width='660' height='940' frameborder='0' scrolling='no'>"
	..w "</iframe>" 
	.i Flag="IMG" d
	..w "<table border=0 cellspacing=0><tr><td><P>"
	..w "<img id='"_ARCIM_i_"' src='"_OneUrl_"' width='660' height='935'>"
	..w "</P></td></tr></table>"
	.i Flag="PDF" d
	..w "<embed width='660' height='935' src='"_OneUrl_"'></embed>"
}

Storage Default
{
<Data name="ReportShowOtherDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.ReportShowOtherD</DataLocation>
<DefaultData>ReportShowOtherDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.ReportShowOtherD</IdLocation>
<IndexLocation>^web.DHCPE.ReportShowOtherI</IndexLocation>
<StreamLocation>^web.DHCPE.ReportShowOtherS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
