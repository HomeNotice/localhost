Class web.DHCPE.ModifyRecord Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

ClassMethod Save(SourceID, SourceType, OldInfo, NewInfo, UserID)
{
	n (SourceID, SourceType, OldInfo, NewInfo, UserID)
	s $ZT="MRecordErr"
	q:OldInfo=NewInfo 0
	s obj=##class(User.DHCPEModifyRecord).%New()
	s obj.MRNewInfo=NewInfo
	s obj.MROldInfo=OldInfo
	s obj.MRDate=+$H
	s obj.MRTime=$P($H,",",2)
	s obj.MRSourceID=SourceID
	s obj.MRSourceType=SourceType
	d obj.MRUserDRSetObjectId(UserID)
	s sc=obj.%Save()
	d obj.%Close()
	If ($System.Status.IsError(sc))	
	{
		;s ^wrzRecord=SourceID_","_SourceType_","_OldInfo_","_NewInfo_","_UserID_"^"_$System.Status.GetErrorText(sc)
		q "-1^"_$System.Status.GetErrorText(sc)
	}else{
		q obj.%Id()
	}
MRecordErr
	q 0
}

ClassMethod GetInfo(SourceID, SourceType)
{
	;w ##class(web.DHCPE.ModifyRecord).GetInfo("100","IBaseInfo")
	n (SourceID,SourceType)
	s $ZT="MRGetInfoErr"
	s Info=""
	q:SourceID="" Info
	i SourceType="IBaseInfo"
	{
		s Name=$P(^DHCPEPreIBI(SourceID),"^",2)
		s Info="姓名:"_Name
		s Sex=$P(^DHCPEPreIBI(SourceID),"^",3)
		s:Sex'="" Sex=$P(^CT("SEX",Sex),"^",2)
		s:Sex'="" Info=Info_";性别:"_Sex
		s Dob=$P(^DHCPEPreIBI(SourceID),"^",4)
		s:Dob'="" Dob=$ZD(Dob,3)
		s:Dob'="" Info=Info_";生日:"_Dob
		s PatType=$P(^DHCPEPreIBI(SourceID),"^",5)
		s:PatType'="" PatType=$P(^CT("SS",PatType),"^",2)
		s:PatType'="" Info=Info_";类型:"_PatType
		s Tel1=$P(^DHCPEPreIBI(SourceID),"^",6)
		s:Tel1'="" Info=Info_";电话1:"_Tel1
		s Tel2=$P(^DHCPEPreIBI(SourceID),"^",7)
		s:Tel2'="" Info=Info_";电话2:"_Tel2
		s Mob=$P(^DHCPEPreIBI(SourceID),"^",8)
		s:Mob'="" Info=Info_";手机:"_Mob
		s IDCard=$P(^DHCPEPreIBI(SourceID),"^",9)
		s:IDCard'="" Info=Info_";身份证:"_IDCard
		s EMail=$P(^DHCPEPreIBI(SourceID),"^",16)
		s:EMail'="" Info=Info_";EMail:"_EMail
		s Married=$P(^DHCPEPreIBI(SourceID),"^",17)
		s:Married'="" Married=$P(^CT("MAR",Married),"^",2)
		s:Married'="" Info=Info_";婚姻:"_Married
		s Address=$P(^DHCPEPreIBI(SourceID),"^",14)
		s:Address'="" Info=Info_";住址:"_Address
		s Position=$P(^DHCPEPreIBI(SourceID),"^",11)
		s:Position'="" Info=Info_";部门:"_Position
		s Company=$P(^DHCPEPreIBI(SourceID),"^",12)
		s:Company'="" Info=Info_";公司:"_Company

	}
	
	q Info
MRGetInfoErr
	q ""
}

}
