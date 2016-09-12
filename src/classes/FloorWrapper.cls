public with sharing class FloorWrapper{
    public Floor__c floor { get; set; }
    public String floorType { get; set; }
    public String floorNumber { get; set; }
    public String tenantType { get; set; }
    public String tenantNumber { get; set; }    
    public String specificationName { get; set; }
    public String specificationTenantName { get; set; }
    public String floorId { get; set;}
    public Boolean floorIsShown {get; set;} // MRS 7109
    
    public FloorWrapper( Floor__c floor ) {
        this.floor = floor;
        this.floorId = floor.Id;
        this.floorType = floor.Floor_Type__c;
        this.floorNumber = floor.Floor_Number__c;
        this.tenantType = floor.Tenant_Type__c;
        this.tenantNumber = floor.Tenant_Number__c;
        this.specificationName = floor.Specification_Name__c;
        this.specificationTenantName = floor.Specification_Tenant_Name__c;
        this.floorIsShown = floor.Floor_is_shown__c; // MRS 7109
    }

}