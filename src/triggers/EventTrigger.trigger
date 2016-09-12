trigger EventTrigger on Event (before insert) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            EventServices.updateAssignedTo(Trigger.new);
            EventServices.updateEventsIsReminderSetForSignatureSealsTaskItem(Trigger.new);
        }
    }
}