// KDI: 02/03/2013
public with sharing class AttendAppointmentController {
    public Task_Item__c taskItem { get; set; }
    @TestVisible private String appointment_field_id;
    @TestVisible private String activivti_Field_Id;

    public Boolean isUser {get;set;}
    public Boolean isAddNewAppointment {get;set;}

    public List<Appointment__c> appointmentList{get;set;}
    public String appointmentId {get;set;}

    public List<AttendAppointmentWrapp> attendAppointmentWrappList {get;set;}

    public List<SelectOption> appointmentTypeOptions { get { if( appointmentTypeOptions == null ) appointmentTypeOptions = getOptions('Appointment_Type__c'); return appointmentTypeOptions; } set; }
    public Map<Id, Event> appointmentIdToEvent {get;set;}

    public AttendAppointmentController(ApexPages.StandardController stdController) {
        this.taskItem = (Task_Item__c)stdController.getRecord();
        appointmentIdToEvent = new Map<Id, Event>();

        MilroseSetting__c milroseSetting = MilroseSetting__c.getInstance('activitie_field_id');
        activivti_Field_Id = milroseSetting.Activitie_field_id__c;

        milroseSetting = MilroseSetting__c.getInstance('appointmen_field_id');
        appointment_field_id = milroseSetting.Appointmen_field_id__c;
    }

    public void pageLoad() {
        attendAppointmentWrappList = new List<AttendAppointmentWrapp>();
        if(String.isEmpty(taskItem.Id)) return;
        List<Event> events = [ SELECT Id, Appointment_Id__c FROM Event WHERE WhatId = : this.taskItem.Id ];
        system.debug('events: '+ events);
        for(Event event : events) {
            if(!String.isBlank(event.Appointment_Id__c)) {
                appointmentIdToEvent.put(event.Appointment_Id__c, event);
            }
        }
        appointmentList = [SELECT Id, Appointment_Type__c, Notes__c, Task_Item__c,
                                              ( SELECT Id, User__c, isUser__c, Contact__c, Appointment__c, Contact__r.Name, User__r.Name
                                                FROM Attendees__r
                                                ORDER BY Name )
                                             FROM Appointment__c
                                             WHERE Task_Item__c = : this.taskItem.Id];
        if( appointmentList.isEmpty() ) {
            Appointment__c appointment = new Appointment__c( Task_Item__c = taskItem.Id );
            if( !String.isBlank(appointment.Task_Item__c) ) {
                try {
                    INSERT appointment;
                    attendAppointmentWrappList.add( new AttendAppointmentWrapp(appointment, new Event(), new List<Attendee__c>(), new List<Attendee__c>() ));
                } catch( dmlException ex ) {
                    addMessage('An error has occurred while initializing the Appointment.', ex.getMessage());
                    return;
                }
            }
        } else {
            Event event;
            for( Appointment__c appointment : appointmentList) {
                if(appointmentIdToEvent.containsKey(appointment.Id)) {
                    event = appointmentIdToEvent.get(appointment.Id);
                } else {
                    event = new Event();
                }
                AttendAppointmentWrapp attendAppointmentW = new AttendAppointmentWrapp(appointment, event, new List<Attendee__c>(), new List<Attendee__c>() );
                for(Attendee__c  attendee : appointment.Attendees__r) {
                    //if( !String.isBlank(attendee.User__c) ) {
                    if(attendee.isUser__c) {
                        attendAppointmentW.addAttendeeUList(attendee);
                    } else {
                        attendAppointmentW.addAttendeeCList(attendee);
                    }
                    /*if( !String.isBlank(attendee.Contact__c) ) {
                        attendAppointmentW.addAttendeeCList(attendee);
                    }*/
                }
                attendAppointmentWrappList.add(attendAppointmentW);
            }
        }
        isAddNewAppointment = true;
        for(AttendAppointmentWrapp appointment : attendAppointmentWrappList) {
            if(!appointment.isNewEvent) {
                isAddNewAppointment = false;
                break;
            }
        }
    }

    public String createEventLink { get; set; }

    public void createEvent() {
        if( !String.isBlank( appointmentId ) ) {
            Appointment__c appointment;
            AttendAppointmentWrapp attendAppointmentWrapp;
            for(AttendAppointmentWrapp aaW : attendAppointmentWrappList) {
                if( aaW.appointment.Id == appointmentId ) {
                    attendAppointmentWrapp = aaW;
                    break;
                }
            }
            removeAttendee();
            if( !String.isBlank(attendAppointmentWrapp.appointment.Appointment_Type__c) && !String.isBlank(taskItem.Id) ) {
                String municipalAgency, notes;
                if( !String.isBlank(taskItem.X3rd_Party_Authority_ID__c) ) {
                    municipalAgency = ' ' + taskItem.X3rd_Party_Authority_ID__c;
                } else {
                    municipalAgency = '';
                }
                if( !String.isBlank(attendAppointmentWrapp.appointment.Notes__c) ) {
            notes = ' ' + attendAppointmentWrapp.appointment.Notes__c;
                } else {
                    notes = '';
                }
                String internalAttendee = '';
                String appointmentWith = '';
                Id internalAttendeeId;
                if(!attendAppointmentWrapp.attendeeUList.isEmpty()) {
                    for(Attendee__c attendee : attendAppointmentWrapp.attendeeUList) {
                        if( !String.isBlank( attendee.User__c ) ) {
                            internalAttendee = attendee.User__r.Name;
                            internalAttendeeId = attendee.User__c;
                            break;
                        }
                    }

                }
                if(!attendAppointmentWrapp.attendeeCList.isEmpty()) {
                    for(Attendee__c attendee : attendAppointmentWrapp.attendeeCList) {
                        if( !String.isBlank( attendee.Contact__c ) ) {
                            appointmentWith = attendee.Contact__r.Name;
                        }
                    }
                }
                String url = '/00U/e?what_id={$1}&evt6={$2}&{$3}={$4}&retURL={$5}&cancelURL={$6}&evt5={$7}&evt1={$8}&{$9}={$10}&evt1_lkid={$11}';
                url = url.replace( '{$1}', taskItem.Id );
                url = url.replace( '{$2}', EncodingUtil.urlEncode( attendAppointmentWrapp.appointment.Appointment_Type__c, 'UTF-8' ) +
                                           EncodingUtil.urlEncode( municipalAgency, 'UTF-8' ) +
                                           EncodingUtil.urlEncode( notes, 'UTF-8' ).replace('%0A','+') );
                url = url.replace( '{$3}', appointment_field_id );
                url = url.replace( '{$4}', attendAppointmentWrapp.appointment.Id );
                url = url.replace( '{$5}', '/' + taskItem.Id );
                url = url.replace( '{$6}', '/' + taskItem.Id );
                url = url.replace( '{$7}', EncodingUtil.urlEncode( internalAttendee, 'UTF-8' ) + ' with ' + EncodingUtil.urlEncode( appointmentWith, 'UTF-8' ) ); //Subject
                url = url.replace( '{$8}', EncodingUtil.urlEncode( internalAttendee, 'UTF-8' )); //Assigned To
                url = url.replace( '{$9}', activivti_Field_Id);
                url = url.replace( '{$10}', internalAttendeeId);
                url = url.replace( '{$11}', String.valueOf(internalAttendeeId).substring( 0, 15 ));
                createEventLink = url;
                system.debug('createEventLink: ' + createEventLink);
            }
        }
    }
    public void addNewAppointment() {
        Appointment__c appointment = new Appointment__c( Task_Item__c = taskItem.Id );
        //removeAttendee();
        try {
            INSERT appointment;
            attendAppointmentWrappList.add( new AttendAppointmentWrapp(appointment, new Event(), new List<Attendee__c>(), new List<Attendee__c>() ));
        } catch( dmlException ex ) {
            addMessage('An error has occurred while initializing the Appointment.', ex.getMessage());
            return;
        }
        isAddNewAppointment = false;

    }

    public void updateAttendees() {
        List<Attendee__c> attendeesToUpdate = new List<Attendee__c>();
        AttendAppointmentWrapp attendAppointmentWrapp;
        if(String.isEmpty(appointmentId)) return;
        for(AttendAppointmentWrapp aaW : attendAppointmentWrappList) {
            if( aaW.appointment.Id == appointmentId ) {
                attendAppointmentWrapp = aaW;
                break;
            }
        }
        Boolean isattendeesUToUpdate  = false;
        Boolean isattendeesCToUpdate  = false;
        for(Attendee__c attendee : attendAppointmentWrapp.attendeeUList) {
            if( !String.isBlank( attendee.User__c ) ) {
                isattendeesUToUpdate = true;
            }
        }
        for(Attendee__c attendee : attendAppointmentWrapp.attendeeCList) {
            if( !String.isBlank( attendee.Contact__c ) ) {
                attendeesToUpdate.add(attendee);
                isattendeesCToUpdate = true;
            }
        }
        List<Attendee__c> attendeesToUpd = new List<Attendee__c>();
        attendeesToUpd.addAll(attendAppointmentWrapp.attendeeCList);
        attendeesToUpd.addAll(attendAppointmentWrapp.attendeeUList);
        try {
            UPSERT attendeesToUpd;
        } catch( dmlException ex ) {
            addMessage('An error has occurred while updating Attendees.', ex.getMessage());
        }
        if(isattendeesUToUpdate && isattendeesCToUpdate) {
            isAddNewAppointment = true;
            pageLoad();
        } else {
            isAddNewAppointment = false;
            attendAppointmentWrapp.isNewEvent = false;
        }
        system.debug('isAddNewAppointment: ' + isAddNewAppointment);
        appointmentId = null;
        isUser = null;
    }

    public void removeAttendee() {
        List<Attendee__c> attendeesToRemove = new List<Attendee__c>();
        List<Appointment__c> appointments = [SELECT Id, Appointment_Type__c, Notes__c, Task_Item__c,
                                              ( SELECT Id, User__c, Contact__c, Appointment__c, Contact__r.Name, User__r.Name
                                                FROM Attendees__r
                                                ORDER BY Name )
                                             FROM Appointment__c
                                             WHERE Task_Item__c = : this.taskItem.Id];
        for( Appointment__c appointment : appointmentList) {
                for(Attendee__c  attendee : appointment.Attendees__r) {
                    if(String.isBlank(attendee.Contact__c) && String.isBlank(attendee.User__c)) {
                        attendeesToRemove.add(attendee);
                    }
                }
            }
        try {
            Delete attendeesToRemove;
        } catch( dmlException ex ) {
            addMessage('An error has occurred while delete Attendees.', ex.getMessage());
        }
    }

    public void addAttendee() {
        AttendAppointmentWrapp attendAppointmentWrapp;
        if(String.isEmpty(appointmentId)) return;
        for(AttendAppointmentWrapp aaW : attendAppointmentWrappList) {
            if( aaW.appointment.Id == appointmentId ) {
                attendAppointmentWrapp = aaW;
                break;
            }
        }
        List<Attendee__c> attendeesList = new List<Attendee__c>();
        if(isUser) {
            attendAppointmentWrapp.addAttendeeUList(new Attendee__c(Appointment__c = appointmentId, isUser__c = true));
        } else if (!isUser) {
            attendAppointmentWrapp.addAttendeeCList(new Attendee__c(Appointment__c = appointmentId, isUser__c = false));
        }
        List<Attendee__c> attendeesToUpd = new List<Attendee__c>();
        attendeesToUpd.addAll(attendAppointmentWrapp.attendeeCList);
        attendeesToUpd.addAll(attendAppointmentWrapp.attendeeUList);
        try {
            UPSERT attendeesToUpd;
        } catch( dmlException ex ) {
            addMessage('An error has occurred while updating Attendees.', ex.getMessage());
        }
    }
    public void updateAppointment() {
        AttendAppointmentWrapp attendAppointmentWrapp;
        for(AttendAppointmentWrapp aaW : attendAppointmentWrappList) {
            if( aaW.appointment.Id == appointmentId ) {
                attendAppointmentWrapp = aaW;
                break;
            }
        }
        if(attendAppointmentWrapp != null) {
            try {
                UPDATE attendAppointmentWrapp.appointment;
            } catch( dmlException ex ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'An error has occurred while updating Appointment.', ex.getMessage()) );
            }
        }
    }

    public class AttendAppointmentWrapp {

        public Boolean isUser {get;set;}
        public Boolean isAttendeeU;
        public Boolean isAttendeeC;
        public Boolean isNewEvent {
            get {
                if(isNewEvent == null) {
                    if(!this.attendeeUList.isEmpty()) {
                        for(Attendee__c att : this.attendeeUList) {
                            if(!String.isBlank(att.User__r.Name)) {
                                this.isAttendeeU = true;
                            }
                        }
                    }
                    if(!this.attendeeCList.isEmpty()) {
                        for(Attendee__c att : this.attendeeCList) {
                            if(!String.isBlank(att.Contact__r.Name)) {
                                this.isAttendeeC = true;
                            }
                        }
                    }
                    if(this.isAttendeeU && this.isAttendeeC) {
                        this.isNewEvent = true;
                    } else {
                       this.isNewEvent = false;
                    }
                }
                system.debug('isNewEvent: ' + isNewEvent);
                return isNewEvent;
            }
            set;
        }

        public Appointment__c appointment {
            get {
                if(appointment == null) {
                    appointment = new Appointment__c();
                }
                return appointment;
            }
            set;
        }
        public Event event {
            get {
                if(event == null) {
                    event = new Event();
                }
                return event;
            }
            set;
        }
        public List<Attendee__c> attendeeUList {
            get {
                if(attendeeUList == null) {
                    attendeeUList = new List<Attendee__c>();
                }
                return attendeeUList;
            }
            set;
        }
        public List<Attendee__c> attendeeCList {
            get {
                if(attendeeCList == null) {
                    attendeeCList = new List<Attendee__c>();
                }
                return attendeeCList;
            }
            set;
        }

        public AttendAppointmentWrapp(Appointment__c appointment, Event event, List<Attendee__c> attendeeUList, List<Attendee__c> attendeeCList) {
            this.appointment = appointment;
            this.event = event;
            this.attendeeUList = attendeeUList;
            this.attendeeCList = attendeeCList;
            this.isAttendeeU = false;
            this.isAttendeeC = false;
        }
        public void addAttendeeUList(Attendee__c attendeeU) {
            this.attendeeUList.add(attendeeU);
        }
        public void addAttendeeCList(Attendee__c attendeeC) {
            this.attendeeCList.add(attendeeC);
        }
    }

    @TestVisible private List<Integer> getGmtShift() {
        String strOffset = System.now().format('Z');
        String strOffsetHours = strOffset.substring(0,3);
        if( strOffsetHours.startsWith('+') ) {
            strOffsetHours = strOffsetHours.substring(1);
        }
        Integer offsetHours = Integer.valueOf( strOffsetHours );
        Integer offsetMinutes = Integer.valueOf( strOffset.substring(3) ); offsetMinutes *= offsetHours < 0 ? -1 : 1;
        return new List<Integer>{ offsetHours,
                                  offsetMinutes };
    }

    @TestVisible private String getMinute() {
        Integer step = 5;
        Decimal minuteDivByStep = Decimal.valueOf( DateTime.Now().format('m') )/step;
        Integer minute = Integer.valueOf( Math.Round( minuteDivByStep - Integer.valueOf( minuteDivByStep ) == 0 ? minuteDivByStep : minuteDivByStep + 1 )*step );
        if( minute < 10 ) return '0' + String.valueOf( minute );
        return String.valueOf( minute );
    }

    @TestVisible private void addMessage(String message, String type) {
        if( type == 'Error' ) { ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, message ) ); return; }
        if( type == 'Info' ) { ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Info, message ) ); return; }
    }

    @TestVisible private List<SelectOption> getOptions(String field) {
        List<SelectOption> options = new List<SelectOption>();
        for( Schema.PicklistEntry item : Appointment__c.sObjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues() ) {
            options.add( new SelectOption( item.getValue(), item.getValue() ) );
        }
        return options;
    }

}