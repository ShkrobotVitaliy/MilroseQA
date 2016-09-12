public class FilterFields {
   
    public Boolean isFilterEmpty {
        get {
            return String.isBlank(this.projectNamber) && String.isBlank(this.address) && String.isBlank(this.serviceItemNumber) && String.isBlank(this.proposalNumber) && String.isBlank(this.createdByName) && 
                   String.isBlank(this.proposalDraftNumber) && String.isBlank(this.taskItemNumber) && String.isBlank(this.typeObjectKeyPrefix) && String.isBlank(this.accountingDocTypeObjectKeyPrefix) && 
                   String.isBlank(this.author) && String.isBlank(this.purcaseOrder) && String.isBlank(this.projectName) && String.isBlank(this.municipalFormTypeName) && String.isBlank(this.municipalAgencyId) && 
                   String.isBlank(this.formNamber) && String.isBlank(this.longName) && String.isBlank(this.shortName) && String.isBlank(this.formRegion) && String.isBlank(this.statusProposal) &&
                   String.isBlank(this.changeOrderNumber) && String.isBlank(this.municipalDescription) && String.isBlank(this.artifactsCategory) && String.isBlank(this.accountingClient) && String.isBlank(this.billingClient) && String.isBlank(this.primaryClient);
            
        }
        private set;
    
    }
   
    public String projectNamber {
        get {
            if(projectNamber == null) {
                projectNamber = '';
            }
            return projectNamber;
        }
        set;
    }

    public String address {
        get {
            if(address == null) {
                address = '';
            }
            return address;
        }
        set;
    }

    public String serviceItemNumber {
        get {
            if(serviceItemNumber == null) {
                serviceItemNumber = '';
            }
            return serviceItemNumber;
        }
        set;
    }

    public String proposalNumber {
        get {
            if(proposalNumber == null) {
                proposalNumber = '';
            }
            return proposalNumber;
        }
        set;
    }
    
    public String createdByName {
        get {
            if(createdByName == null) {
                createdByName = '';
            }
            return createdByName;
        }
        set;
    }
    
    public String proposalDraftNumber {
        get {
            if(proposalDraftNumber == null) {
                proposalDraftNumber = '';
            }
            return proposalDraftNumber;
        }
        set;
    }

    public String taskItemNumber {
        get {
            if(taskItemNumber == null) {
                taskItemNumber = '';
            }
            return taskItemNumber;
        }
        set;
    }    

    public String typeObjectKeyPrefix {
        get {
            if(typeObjectKeyPrefix == null) {
                typeObjectKeyPrefix = '';
            }
            return typeObjectKeyPrefix;
        }
        set;
    }

    public String accountingDocTypeObjectKeyPrefix {
        get {
            if(accountingDocTypeObjectKeyPrefix == null) {
                accountingDocTypeObjectKeyPrefix = '';
            }
            return accountingDocTypeObjectKeyPrefix;
        }
        set;
    }

    public String artifactsCategory {
        get {
            if(artifactsCategory == null) {
                artifactsCategory = '';
            }
            return artifactsCategory;
        }
        set;
    }
    public String author {
        get {
            if(author == null) {
                author = '';
            }
            return author;
        }
        set;
    }
    public String purcaseOrder {
        get {
            if(purcaseOrder == null) {
                purcaseOrder = '';
            }
            return purcaseOrder;
        }
        set;
    }
    public String projectName {
        get {
            if(projectName == null) {
                projectName = '';
            }
            return projectName;
        }
        set;
    } 

    public String municipalFormTypeName {
        get {
            if(municipalFormTypeName == null) {
                municipalFormTypeName = '';
            }
            return municipalFormTypeName;
        }
        set;
    } 

    public String municipalAgencyId {
        get {
            if(municipalAgencyId == null) {
                municipalAgencyId = '';
            }
            return municipalAgencyId;
        }
        set;
    }

    public String formNamber {
        get {
            if(formNamber == null) {
                formNamber = '';
            }
            return formNamber;
        }
        set;
    }

    public String longName {
        get {
            if(longName == null) {
                longName = '';
            }
            return longName;
        }
        set;
    }

    public String shortName {
        get {
            if(shortName == null) {
                shortName = '';
            }
            return shortName;
        }
        set;
    }

    public String formRegion {
        get {
            if(formRegion == null) {
                formRegion = '';
            }
            return formRegion;
        }
        set;
    }    

    public String statusProposal {
        get {
            if(statusProposal == null) {
                statusProposal = '';
            }
            return statusProposal;
        }
        set;
    }

    public String changeOrderNumber {
        get {
            if(changeOrderNumber == null) {
                changeOrderNumber = '';
            }
            return changeOrderNumber;
        }
        set;
    }  

    public String municipalDescription {
        get {
            if(municipalDescription == null) {
                municipalDescription = '';
            }
            return municipalDescription;
        }
        set;
    }

    public String accountingClient {
        get {
            if(accountingClient == null) {
                accountingClient = '';
            }
            return accountingClient;
        }
        set;
    }

    public String billingClient {
        get {
            if(billingClient == null) {
                billingClient = '';
            }
            return billingClient;
        }
        set;
    }

    public String primaryClient {
        get {
            if(primaryClient == null) {
                primaryClient = '';
            }
            return primaryClient;
        }
        set;
    }

    public FilterFields() { }       

}