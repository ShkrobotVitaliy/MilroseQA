trigger NoteTrigger on Note (before delete, before update ) {
    if( Trigger.isUpdate ){
        for( Note noteItem: Trigger.newMap.values() ){
            noteItem.Body = Trigger.oldMap.get(noteItem.Id).Body;
            noteItem.Title = Trigger.oldMap.get(noteItem.Id).Title;
            noteItem.IsPrivate = Trigger.oldMap.get(noteItem.Id).IsPrivate;
            
        }    
    }
    if( Trigger.isDelete ){
        for( Note noteItem: Trigger.oldMap.values() ){
            noteItem.addError('Notes can not be edited or deleted');
        }
    }
}