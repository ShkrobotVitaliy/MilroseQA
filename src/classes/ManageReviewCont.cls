public with sharing class ManageReviewCont {
     private List<Project_Roster__c> rosters {
        get {
            if (null == this.rosters) {
                this.rosters = ProjectRosterServices.getRosterByProjectId(this.currentTaskItem.Project_Profile__c);

            }
            return this.rosters;

        }
        set;
    }
    
    public List<SelectOption> rosterIdToContact {
        get {
            if (null == this.rosterIdToContact) {
                this.rosterIdToContact = new List<SelectOption>();
                this.rosterIdToContact.add(new SelectOption ('', '-- None --'));

                for (Project_Roster__c roster : this.rosters) {
                    if (!String.isBlank(roster.Role__c)) {
                        this.rosterIdToContact.add(new SelectOption(roster.Id, (roster.Role__c + ' - ' + roster.Name__c), !roster.Active__c));

                    }

                }

            }
            return this.rosterIdToContact;
        
        }
        set;
    }
    
    public List<Review__c> reviewList {
        get {
            if(reviewList == null) {
                reviewList = new List<Review__c>();
            }
            return reviewList;
        }
        set;
    }
    
    public Task_Item__c currentTaskItem {get;set;}

    public ManageReviewCont(ApexPages.StandardController controller) {
        currentTaskItem = (Task_Item__c)controller.getRecord();
        //getReviewList();
    }

    public void getReviewList() {
        if(currentTaskItem != null && String.isNotBlank(currentTaskItem.id)) {
           reviewList = [SELECT Artifact__c, Results__c, Review_End_Date__c, Review_Start_Date__c, Reviewer__c, Task_Item__c, Id FROM Review__c where Task_Item__c = :currentTaskItem.Id];
            if( reviewList.isEmpty() ) {
                addNew();
            }
        }
    }

    public void addNew() {
        try {
            if (currentTaskItem == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ErrorException.TASK_ITEM_EMPTY));
                return;
            }
            Review__c review = new Review__c(Task_Item__c = currentTaskItem.Id, Project__c = currentTaskItem.Project_Profile__c);
            insert review;
            reviewList.add(review);
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        }
    }

    public void save() {
        for(Review__c review : reviewList) {
            if(review.Review_Start_Date__c != null && review.Review_End_Date__c != null) {
                if(review.Review_Start_Date__c > review.Review_End_Date__c) {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Review Start Date cannot be more than Review End Date'));
                    return;
                }
            }
        }
        try {
            update reviewList;
            getReviewList();
        } catch (DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Review was not updated: ' + ex.getDmlMessage(0)));
        }
    }

}