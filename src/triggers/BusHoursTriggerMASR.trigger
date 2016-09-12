trigger BusHoursTriggerMASR on Municipal_Approval_Scanning_Request__c (before update)
{
For(Municipal_Approval_Scanning_Request__c m : Trigger.New)
{
If(m.Start_Time__c !=null && m.Completion_Time__c!=null)
{
//m.Total_Time_New__c = String.ValueOf(BusinessHours.Diff('01mA0000000RbMI',m.Start_Time__c,m.Completion_Time__c)/1000/60/60);
Long DiffMilliseconds = BusinessHours.Diff('01mA0000000RbMI',m.Start_Time__c,m.Completion_Time__c);

Double d = (Double)DiffMilliseconds;
Double result = (d/1000)/3600;
Integer hours = Integer.ValueOf(result);
Integer mnutes = Integer.ValueOf(( result - hours  )*60);
m.Total_Time_New__c = String.ValueOf(hours ) +' ' + 'Hour(s) '+ mnutes  + ' minutes';
}
}
}