public with sharing class MilstoneRelatedListController {
    private final Project_Profile__c project { get; set; }
    public Task_Item__c newMilestone{ get; set; }
    public String taskIdToUpdate{get; set;}
    private List<Task_Item__c> taskItemList;
    public List<Task_Item__c> milestoneTaskItemList { get; set; }
    @TestVisible private Map<String, Task_Item__c> taskItemNameTaskItemMap;
    public List<MilestoneWraper> milestonesWraperList {get; set;}

    public Boolean creatingOn{ get; set; }

    public MilstoneRelatedListController(ApexPages.StandardController controller) {
        this.project = (Project_Profile__c)controller.getRecord();
        creatingOn = false;
        initPage();
        taskIdToUpdate = project.Id;
    }

    @TestVisible private void initPage (){
        taskItemList = [SELECT Id, Name, Expected_Start_Date__c, Planned_Start_Date__c, Actual_Start_Date__c,
                                (Select Id, Expected_Start_Date__c, Service_Item__r.Milestone_Sequence_Number__c, Planned_Start_Date__c, Actual_Start_Date__c
                                 From Task_Items1__r limit 1),
                                (Select Id, Expected_Start_Date__c, Service_Item__r.Milestone_Sequence_Number__c, Planned_Start_Date__c, Actual_Start_Date__c
                                 From Successor_Milestones__r limit 1)
                        FROM Task_Item__c
                        WHERE RecordType.Name =: TaskManagementServices.MILESTONE_RECORDTYPE_NAME
                            AND Project_Profile__c = : project.Id];
        milestonesWraperList = new List<MilestoneWraper>();
        if (!taskItemList.isEmpty()){
            milestoneTaskItemList = new List<Task_Item__c>();
            taskItemNameTaskItemMap = new Map<String, Task_Item__c>();
            for (Task_Item__c milestoneTaskItem : taskItemList){
                if (taskItemNameTaskItemMap.containsKey(milestoneTaskItem.Name)){
                    continue;
                }

                if (milestoneTaskItem.Task_Items1__r.isEmpty() && milestoneTaskItem.Successor_Milestones__r.isEmpty()){
                    taskItemNameTaskItemMap.put(milestoneTaskItem.Name, milestoneTaskItem);
                    continue;
                }

                Task_Item__c taskItem = milestoneTaskItem.Task_Items1__r.isEmpty() ?  milestoneTaskItem.Successor_Milestones__r[0] : milestoneTaskItem.Task_Items1__r[0];

                milestoneTaskItem.Actual_Start_Date__c = taskItem.Actual_Start_Date__c;
                milestoneTaskItem.Expected_Start_Date__c = taskItem.Expected_Start_Date__c;
                milestoneTaskItem.Planned_Start_Date__c = taskItem.Planned_Start_Date__c;
                milestoneTaskItem.Sequence_Number__c = taskItem.Service_Item__r.Milestone_Sequence_Number__c;
                taskItemNameTaskItemMap.put(milestoneTaskItem.Name, milestoneTaskItem);
            }
            milestoneTaskItemList = taskItemNameTaskItemMap.values();
            milestoneTaskItemList.sort();
            milestonesWraperList = new List<MilestoneWraper>();
            for (Task_Item__c taskItem : milestoneTaskItemList){
                milestonesWraperList.add(new MilestoneWraper(taskItem));
            }
        }
    }

    public Pagereference creatingActionOn(){
        newMilestone = new Task_Item__c();
        creatingOn = true;
        return null;
    }

    public Pagereference cancelNewMilestoneAction(){
        creatingOn = false;
        return null;
    }

    public Pagereference saveNewMilestoneAction(){
        saveMilestone();
        initPage();
        creatingOn = false;
        return null;
    }


    public Pagereference saveAndNewMilestoneAction(){
        saveMilestone();
        initPage();
        creatingOn = true;
        return null;
    }


    @TestVisible private void saveMilestone(){
        if (!String.isEmpty(newMilestone.Name) && !taskItemNameTaskItemMap.containsKey(newMilestone.Name)){
            newMilestone.Project_Profile__c = project.Id;
            newMilestone.RecordTypeId = TaskManagementServices.MILESTONE_RECORDTYPE_ID;
            try{
                insert newMilestone;
            } catch (DMLException dmlEx){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, dmlEx.getMessage()) );
            }
        } else {
            if (String.isEmpty(newMilestone.Name)){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Please input new Milestones name' ) );
            }
            if (taskItemNameTaskItemMap.containsKey(newMilestone.Name)){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Milestones with ' + newMilestone.Name + ' name is alrady exist' ) );
            }
        }
    }

    public PageReference setEditbeValue(){
        for (MilestoneWraper milItem : milestonesWraperList){
            milItem.isDisabled = !(milItem.milestone.Id == taskIdToUpdate);
        }
        return null;
    }

    public PageReference unSetEditbeValue(){
        for (MilestoneWraper milItem : milestonesWraperList){
            milItem.isDisabled = true;
        }
        return null;
    }

    @TestVisible private void updateName(){
        Task_Item__c taskItem;
        for (MilestoneWraper milItem : milestonesWraperList){
            if(milItem.milestone.Id == taskIdToUpdate){
                if(!String.isEmpty(milItem.milestone.Name) && milItem.oldName != milItem.milestone.Name && !taskItemNameTaskItemMap.containsKey(milItem.milestone.Name)){
                    taskItem = new Task_Item__c(Id = milItem.milestone.Id, Name = milItem.milestone.Name, RecordTypeId = TaskManagementServices.MILESTONE_RECORDTYPE_ID);
                } else {
                    If (milItem.oldName != milItem.milestone.Name && taskItemNameTaskItemMap.containsKey(milItem.milestone.Name)){
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Milestones with ' + milItem.milestone.Name + ' name is alrady exist' ) );
                    }
                    If (String.isEmpty(milItem.milestone.Name)){
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Please input new name' ) );
                    }
                }
                break;
            }
        }
        if (taskItem == null) return;
        List<sObject> listServiceItemTaskItemForUpdate = new List<sObject>();
        listServiceItemTaskItemForUpdate.add(taskItem);
        Map<Id, Service_Item__c> serviceItemMapForUpdate = new Map<Id, Service_Item__c>();
        for (Task_Item__c taskItemWithServices : [SELECT Id, Service_Item__r.Predecessor_Milestone__c, Service_Item__r.Successor_Milestone__c,
                                                        Predecessor_Milestone__c, Successor_Milestone__c, Service_Item__c
                                                  FROM Task_Item__c
                                                  WHERE (Predecessor_Milestone__c =: taskItem.Id OR Successor_Milestone__c =: taskItem.Id)]){
            Service_Item__c serviceItem = serviceItemMapForUpdate.containsKey(taskItemWithServices.Service_Item__c) ? serviceItemMapForUpdate.get(taskItemWithServices.Service_Item__c) :
                                                                    new Service_Item__c(Id = taskItemWithServices.Service_Item__c);
            if (taskItemWithServices.Predecessor_Milestone__c == taskItem.Id){
                serviceItem.Predecessor_Milestone__c = taskItem.Name;
            }
            if (taskItemWithServices.Successor_Milestone__c == taskItem.Id){
                serviceItem.Successor_Milestone__c = taskItem.Name;
            }
            serviceItemMapForUpdate.put(serviceItem.Id, serviceItem);
        }
        for (Service_Item__c serviceItem : serviceItemMapForUpdate.values()){
            listServiceItemTaskItemForUpdate.add(serviceItem);
        }
        try{
            update listServiceItemTaskItemForUpdate;
        } catch (DMLException dmlEx){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, dmlEx.getMessage()) );
        }
    }

    public Pagereference updateNameAction(){
        updateName();
        initPage();
        return null;
    }

    @TestVisible private void deleteMilestone(){
        Task_Item__c  taskItem = [SELECT Id FROM Task_Item__c WHERE Predecessor_Milestone__c =: taskIdToUpdate OR Successor_Milestone__c =: taskIdToUpdate].isEmpty() ?
                                            new Task_Item__c(Id = taskIdToUpdate) : null;
        if(taskItem != NULL){
            try{
                delete taskItem;
            } catch (DMLException dmlEx){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, dmlEx.getMessage()) );
            }
        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'You can not delete this Milestone') );
        }
    }

    public Pagereference deleteMilestoneAction(){
        deleteMilestone();
        initPage();
        return null;
    }

    public class MilestoneWraper{
        public Task_Item__c milestone{get; set;}
        private String dateTimeFormat = 'MM/dd/yyyy HH:mm:ss';
        public String planedDate{get; set;}
        public String expectedDate{get; set;}
        public String actualDate{get; set;}
        public Boolean isDisabled{get; set;}
        private String oldName;

        MilestoneWraper (Task_Item__c taskItem){
            this.milestone = taskItem;
            this.planedDate = taskItem.Planned_Start_Date__c != null ? taskItem.Planned_Start_Date__c.format(dateTimeFormat) : '';
            this.expectedDate = taskItem.Expected_Start_Date__c != null ? taskItem.Expected_Start_Date__c.format(dateTimeFormat) : '';
            this.actualDate = taskItem.Actual_Start_Date__c != null ? taskItem.Actual_Start_Date__c.format(dateTimeFormat) : '';
            this.oldName = taskItem.Name;
            this.isDisabled = true;
        }
    }
}