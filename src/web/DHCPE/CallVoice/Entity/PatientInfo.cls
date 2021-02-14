Class web.DHCPE.CallVoice.Entity.PatientInfo Extends (%Persistent, %XML.Adaptor, DHCCPM.BLL.DHCXMLReader) [ ClassType = persistent, Inheritance = right ]
{

Parameter XMLIGNOREINVALIDTAG = 1;

/// 窗口诊室名称
Property WindowName As %String(TRUNCATE = 1);

/// 计算机名称
Property WindowIP As %String(TRUNCATE = 1);

/// 技师
Property WindowDoctor As %String(TRUNCATE = 1);

/// 主任医师
Property WindowDocPro As %String(TRUNCATE = 1);

/// 外科
Property WindowDept As %String(TRUNCATE = 1);

/// 说明
Property WindowNote As %String(TRUNCATE = 1);

/// 当前呼叫患者信息2513052724
Property VisitingPatients As list Of VisitingPatient;

/// 等候患者信息
Property WaitingPatients As list Of WaitingPatient;

/// 过号患者信息
Property SkipPatients As list Of SkipPatient;

Storage Default
{
<Data name="PatientInfoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SkipPatients</Value>
</Value>
<Value name="3">
<Value>VisitingPatients</Value>
</Value>
<Value name="4">
<Value>WaitingPatients</Value>
</Value>
<Value name="5">
<Value>WindowDept</Value>
</Value>
<Value name="6">
<Value>WindowDocPro</Value>
</Value>
<Value name="7">
<Value>WindowDoctor</Value>
</Value>
<Value name="8">
<Value>WindowIP</Value>
</Value>
<Value name="9">
<Value>WindowName</Value>
</Value>
<Value name="10">
<Value>WindowNote</Value>
</Value>
</Data>
<DataLocation>^web.DHCPE.CallV91B.PatientInfoD</DataLocation>
<DefaultData>PatientInfoDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^web.DHCPE.CallV91B.PatientInfoD</IdLocation>
<IndexLocation>^web.DHCPE.CallV91B.PatientInfoI</IndexLocation>
<StreamLocation>^web.DHCPE.CallV91B.PatientInfoS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
