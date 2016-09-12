trigger UserTrigger on User ( after insert, after update ) {
	if ( Trigger.isAfter && ( Trigger.isInsert || Trigger.isUpdate ) ) {
		UserServices.updateDeliveryOptionsForUsers( Trigger.new, Trigger.oldMap );
	}
	//MRS-7483
	if ( Trigger.isAfter && Trigger.isUpdate ) {
		UserServices.sendHelperEmailAboutDeactivateUser( UserServices.deactivatedUsersList( Trigger.new, Trigger.oldMap ) );
	}
}