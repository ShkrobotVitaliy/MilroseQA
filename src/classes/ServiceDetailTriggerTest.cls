/**
 * This class tests:
 * Classes:
 * - ServiceDetailTriggerUtils.cls
 *
 * Triggers:
 * - ServiceDetailTrigger.trigger
 * - ServiceSetupBeforeUpsert.trigger
 */
@isTest
private class ServiceDetailTriggerTest {

    static testMethod void triggerTest1() {
        testWithProposalAmount();
        
                
        // Create service setup
        Service_Setup__c sSetup = new Service_Setup__c();
        sSetup.Name = 'Test';
        sSetup.Billing_Trigger_1__c = 'fieldthatdoesnotexist__c';
        try{
            upsert sSetup;
        }catch(Exception e){
        }

        sSetup.Billing_Trigger_1__c = '';
        sSetup.Billing_Trigger_2__c = 'fieldthatdoesnotexist__c';
        try{
            upsert sSetup;
        }catch(Exception e){
        }
        
        sSetup.Billing_Trigger_1__c = '';
        sSetup.Billing_Trigger_2__c = '';
        sSetup.Billing_Trigger_3__c = 'fieldthatdoesnotexist__c';
        try{
            upsert sSetup;
        }catch(Exception e){
        }
    }

    static testMethod void triggerTest2() {
        testWithNoProposalAmount();
    }

    static void testWithProposalAmount(){
    	Munucipalities__c m = new Munucipalities__c( Name = '1' );
    	insert m;
    	
        // Create project
        Building__c b = new Building__c();
        b.Street__c = 'test';
        b.House_No__c = '1';
        b.City__c = 'test';
        b.PostalCode__c = '100';
        b.Municipality__c = m.Id;
        
        upsert b;
        
        //Account acc = new Account(Name = 'Test Account');
        //upsert acc;
        
        Contact billingCont = new Contact(LastName = 'TestBillingContact', FirstName = 'TestBillingContact');//, AccountID = acc.Id);
        upsert billingCont;
        
        Contact assignedCont = new Contact(LastName = 'TestAssignedContact', FirstName = 'TestBillingContact');
        upsert assignedCont;
        
        //M_Company__c comp = new M_Company__c();
        //upsert comp;
        
        Project__c p = new Project__c();
        p.Building__c = b.Id;
        p.Billing_Contact_SF__c = billingCont.Id;
        //p.Primary_Client_Company__c = //comp.Id;
        p.Assigned_SF__c = assignedCont.Id;
        p.MRC__c = 'testmethod';
        upsert p;
        
        // Create service setup
        Service_Setup__c sSetup = new Service_Setup__c();
        sSetup.Name = 'Test';
        sSetup.Billing_Trigger_1__c = 'Approved_Date__c';
        sSetup.Billing_Trigger_1_Percent__c = 30;
        sSetup.Billing_Trigger_2__c = 'CZ_Review_Submitted__c';
        sSetup.Billing_Trigger_2_Percent__c = 30;
        sSetup.Billing_Trigger_3__c = 'CZ_Review_Submitted__c';
        sSetup.Billing_Trigger_3_Percent__c = 0;
       
        try{
            upsert sSetup;
        }catch(Exception e){//sum is not 100%
        }
        
        sSetup.Billing_Trigger_2_Percent__c = 70;
        upsert sSetup;
        
        
        Service_Detail__c sDetail = new Service_Detail__c();
        sDetail.Service__c = sSetup.Id;
        sDetail.Project__c = p.Id;
        sDetail.Proposal_Amount__c = 100;
        sDetail.Approved_Date__c = Date.today();
        sDetail.CZ_Review_Submitted__c = Date.today();
        
        
        upsert sDetail;
        
        Service_Detail__c sDetail2 = new Service_Detail__c();
        sDetail2.Service__c = sSetup.Id;
        sDetail2.Project__c = p.Id;
        sDetail2.Proposal_Amount__c = 100;
        
        upsert sDetail2;
        
        sDetail2.Approved_Date__c = Date.today();
        sDetail2.CZ_Review_Submitted__c = Date.today();
        
        upsert sDetail2;
    }

    
    static void testWithNoProposalAmount(){
    	Munucipalities__c m = new Munucipalities__c( Name = '1' );
    	insert m;
    	
        // Create project
        Building__c b = new Building__c();
        b.Street__c = 'test';
        b.House_No__c = '1';
        b.City__c = 'test';
        b.PostalCode__c = '100';
        b.Municipality__c = m.Id;
        
        upsert b;
        
        Contact billingCont = new Contact(LastName = 'TestBillingContact', FirstName = 'TestBillingContact');
        upsert billingCont;
        
        Contact assignedCont = new Contact(LastName = 'TestAssignedContact', FirstName = 'TestAssignedContact');
        upsert assignedCont;
        
        //M_Company__c comp = new M_Company__c();
        //upsert comp;
        
        Project__c p = new Project__c();
        p.Building__c = b.Id;
        p.Billing_Contact_SF__c = billingCont.Id;
        //p.Primary_Client_Company__c = comp.Id;
        p.Assigned_SF__c = assignedCont.Id;
        p.MRC__c = 'testmethod';
        upsert p;
        
        // Create service setup
        Service_Setup__c sSetup = new Service_Setup__c();
        sSetup.Name = 'Test';
        upsert sSetup;
        
        
        Service_Detail__c sDetail = new Service_Detail__c();
        sDetail.Service__c = sSetup.Id;
        sDetail.Project__c = p.Id;
        
        upsert sDetail;
        
        Service_Detail__c sDetail2 = new Service_Detail__c();
        sDetail2.Service__c = sSetup.Id;
        sDetail2.Project__c = p.Id;
        
        sDetail2.Billing_Trigger_1_Percent__c = 30;
        sDetail2.Billing_Trigger_2_Percent__c = 30;
        sDetail2.Billing_Trigger_3_Percent__c = 60;
        
        try{
            upsert sDetail2;
        }catch(Exception e){
            System.assert(e.getMessage().contains('The sum of all Billing Trigger Percentages can not be different from 0% or 100%.'));
        }
        
        sSetup.Billing_Trigger_1__c = 'Approved_Date__c';
        upsert sSetup;
        
        Service_Detail__c sDetail3 = new Service_Detail__c();
        sDetail3.Service__c = sSetup.Id;
        sDetail3.Project__c = p.Id;
        sDetail3.Approved_Date__c = Date.today();
        
        upsert sDetail3;
    }
    
}