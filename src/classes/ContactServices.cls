public class ContactServices {

    public static List<Contact> getContactsByIds(Set<Id> ids) {
        if ( null == ids || ids.isEmpty() ) {
            return new List<Contact>();

        }

        return new List<Contact>([SELECT Id, Email, Name, Salutation, LastName, Account.Name, Name_Full__c,
                                         MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                                  FROM Contact
                                  WHERE Id IN: ids]);

    }

    public static Map<Id, Contact> getContactsByIdsFromProjectRosters( Set<Id> ids ) {
        if ( null == ids || ids.isEmpty() ) {
            return new Map<Id, Contact>();
        }

        return new Map<Id, Contact>([SELECT Id, Email, Name, Salutation, LastName, Account.Name, Name_Full__c, DND__c,
                                         MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                                  FROM Contact
                                  WHERE Id IN: ids]);

    }

    //MRS-7207
    public static List<Contact> filterContactWithChangesAlternateARStatementRecipient(List<Contact> contactListNew, Map<Id, Contact> contactMapOld){
        List<Contact> filteredContactList = new List<Contact>();
        for (Contact contactItem : contactListNew){
            if ( contactItem.Alternate_A_R_Statement_Recipient__c != null
            	&& contactMapOld.get(contactItem.Id).Alternate_A_R_Statement_Recipient__c != contactItem.Alternate_A_R_Statement_Recipient__c )
            {
                filteredContactList.add( contactItem );
            }
        }

        return filteredContactList;
    }

    public static void validateContactsAlternateARStatementRecipient(List<Contact> filteredContactList){
        if (filteredContactList.isEmpty()){
            return;
        }

        Map<Id, Contact> contactsWithAlternateARStatementRecipientMap = new Map<Id, Contact>([SELECT Id, (Select Id, Name_Full__c From Contacts1__r)
                                                                                              FROM Contact
                                                                                              WHERE Id IN : filteredContactList]);

        for (Contact contactItem : filteredContactList){
            if ( !(contactsWithalternateARStatementRecipientMap.get(contactItem.id)).Contacts1__r.isEmpty() ){
                List<String> contactNames = new List<String>();
                for (Contact chieldContact : contactsWithalternateARStatementRecipientMap.get(contactItem.id).Contacts1__r){
                    contactNames.add(chieldContact.Name_Full__c);
                }
                  contactItem.addError(String.format(Label.Alternate_A_R_Statement_Recipient, new List<String>{String.join(contactNames, ', ')}));
            }
        }
    }

    //MRS-7337
    public static List<Contact> filterContactWithChangesActiveField (List<Contact> contactListNew, Map<Id, Contact> contactMapOld){
        List<Contact> filteredContactList = new List<Contact>();
        for( Contact contactItem : contactListNew ){
            if ( !contactItem.Is_Active__c && contactMapOld.get(contactItem.Id).Is_Active__c ){
                filteredContactList.add( contactItem );
            }
        }

        return filteredContactList;
    }

    public static void validateInactiveContactsWithAlternateARStatementRecipient( List<Contact> filteredContactList ){
        if( filteredContactList.isEmpty() ){
            return;
        }

        Map<Id, Contact> contactsWithAlternateARStatementRecipientMap = new Map<Id, Contact>([SELECT Id, (Select Id, Name_Full__c From Contacts1__r)
                                                                                              FROM Contact
                                                                                              WHERE Id IN : filteredContactList]);

        for( Contact contactItem : filteredContactList ){
            if ( !(contactsWithAlternateARStatementRecipientMap.get(contactItem.id)).Contacts1__r.isEmpty() ){

                List<String> contactNames = new List<String>();

                for( Contact chieldContact: contactsWithAlternateARStatementRecipientMap.get(contactItem.id).Contacts1__r ){
                    contactNames.add( chieldContact.Name_Full__c );
                }

                contactItem.addError( String.format(Label.Alternate_ASR_is_Inactive_Validation, new List<String>{String.join(contactNames, ', ')}) );
            }
        }
    }
}