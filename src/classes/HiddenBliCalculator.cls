public with sharing class HiddenBliCalculator {
    public Map<Id, ProjectData> projectIdToProjectData { get { if( projectIdToProjectData == null ) projectIdToProjectData = new Map<Id, ProjectData>(); return projectIdToProjectData; } private set; }
    public List<Billing_Line_Item__c> hiddenBli { get { return getHiddenBli(); } private set; }
    private Datetime functionalityEnableDate = Datetime.valueOfGmt( Label.ProjectCreatedDateForHiddenBli );

    public HiddenBliCalculator( List<Billing_Line_Item__c> allParentBlis ) {
        init( allParentBlis, null, false );
    }

    public HiddenBliCalculator( List<Billing_Line_Item__c> allParentBlis, Boolean isCurrentlyPrebilling ) {
        init( allParentBlis, null, isCurrentlyPrebilling );
    }

    public HiddenBliCalculator( List<Billing_Line_Item__c> allParentBlis, List<Billing_Date__c> billingDates ) {
        init( allParentBlis, billingDates, false );
    }

    public void init( List<Billing_Line_Item__c> allParentBlis, List<Billing_Date__c> currentBillingDates, Boolean isCurrentlyPrebilling ) {
        Map<Id, Billing_Date__c> billingDates;
        if( currentBillingDates != null ) {
            billingDates = new Map<Id, Billing_Date__c>( currentBillingDates );
        }
        Map<Id, List<Billing_Line_Item__c>> projectProfileIdToBillingLineItems = new Map<Id, List<Billing_Line_Item__c>>();
        for( Billing_Line_Item__c bliItem : allParentBlis ) {
            if( projectProfileIdToBillingLineItems.get( bliItem.Project_Profile__c ) == null ) {
                projectProfileIdToBillingLineItems.put( bliItem.Project_Profile__c, new List<Billing_Line_Item__c>() );
            }
            projectProfileIdToBillingLineItems.get( bliItem.Project_Profile__c ).add( bliItem );
        }
        for( Project_Profile__c projectItem : getProjects( projectProfileIdToBillingLineItems.keySet() ) ) {
            if( projectItem.CreatedDate >= functionalityEnableDate ) {
                List<Billing_Line_Item__c> projectRelatedParentBlis = projectProfileIdToBillingLineItems.get( projectItem.Id );
                this.projectIdToProjectData.put( projectItem.Id, new ProjectData( projectItem, projectRelatedParentBlis, billingDates, isCurrentlyPrebilling ) );
            }
        }
    }

    public List<Billing_Line_Item__c> getHiddenBli() {
        List<Billing_Line_Item__c> hiddenBlis = new List<Billing_Line_Item__c>();
        for( ProjectData projectData : projectIdToProjectData.values() ) {
            hiddenBlis.addAll( projectData.hiddenBli );
        }
        return hiddenBlis;
    }


    public class ProjectData {
        public Project_Profile__c project { get { return project; } private set; }
        public List<Billing_Line_Item__c> projectRelatedParentBlis { get { if( projectRelatedParentBlis == null ) projectRelatedParentBlis = new List<Billing_Line_Item__c>(); return projectRelatedParentBlis; } private set; }
        public Boolean isValid { get { return ( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE ) ||
                                              ( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ); } }
        public List<DepartmentData> departmentData { get { if( departmentData == null ) departmentData = new List<departmentData>(); return departmentData; } private set; }
        public List<Billing_Line_Item__c> hiddenBli { get { return getHiddenBli(); } private set; }

        public ProjectData( Project_Profile__c project, List<Billing_Line_Item__c> projectRelatedParentBlis, Map<Id, Billing_Date__c> billingDates, Boolean isCurrentlyPrebilling ) {
            this.project = project;
            this.projectRelatedParentBlis = projectRelatedParentBlis;
            if( isValid ) {
                Map<String, Decimal> departmentNameToBilledAmount = new Map<String, Decimal>();
                Map<String, Decimal> departmentNameToBilledTax1Amount = new Map<String, Decimal>();
                Map<String, Decimal> departmentNameToBilledTax2Amount = new Map<String, Decimal>();

                for( Billing_Line_Item__c projectRelatedParentBliItem : projectRelatedParentBlis ) {
                    DepartmentData newDepartmentData = new DepartmentData( project, projectRelatedParentBliItem, billingDates, isCurrentlyPrebilling );

                    //add amounts billed in previous blis for next bli calculation
                    Map<String, BliData> departmentNameToBliData = newDepartmentData.departmentNameToBliData;
                    for( String departmentNameItem : departmentNameToBliData.keySet() ) {

                        if( departmentNameToBilledAmount.get( departmentNameItem ) == null ) {
                            departmentNameToBilledAmount.put( departmentNameItem, 0.00 );
                        }
                        if( departmentNameToBilledTax1Amount.get( departmentNameItem ) == null ) {
                            departmentNameToBilledTax1Amount.put( departmentNameItem, 0.00 );
                        }
                        if( departmentNameToBilledTax2Amount.get( departmentNameItem ) == null ) {
                            departmentNameToBilledTax2Amount.put( departmentNameItem, 0.00 );
                        }

                        BliData bliDataItem = departmentNameToBliData.get( departmentNameItem );
                        bliDataItem.billedAmount += departmentNameToBilledAmount.get( departmentNameItem );
                        bliDataItem.billedTax1Amount += departmentNameToBilledTax1Amount.get( departmentNameItem );
                        bliDataItem.billedTax2Amount += departmentNameToBilledTax2Amount.get( departmentNameItem );

                        departmentNameToBilledAmount.put( departmentNameItem, departmentNameToBilledAmount.get( departmentNameItem ) + bliDataItem.hiddenBliAmount );
                        departmentNameToBilledTax1Amount.put( departmentNameItem, departmentNameToBilledAmount.get( departmentNameItem ) + bliDataItem.hiddenBliTax1Amount );
                        departmentNameToBilledTax2Amount.put( departmentNameItem, departmentNameToBilledAmount.get( departmentNameItem ) + bliDataItem.hiddenBliTax2Amount );
                    }
                    departmentData.add( newDepartmentData );
                }
            }
        }

        public List<Billing_Line_Item__c> getHiddenBli() {
            List<Billing_Line_Item__c> hiddenBlis = new List<Billing_Line_Item__c>();
            for( DepartmentData departmentDataItem : departmentData ) {
                hiddenBlis.addAll( departmentDataItem.hiddenBli );
            }
            return hiddenBlis;
        }
    }


    public class DepartmentData {
        public Billing_Line_Item__c projectRelatedParentBli { get { return projectRelatedParentBli; } private set; }
        public Map<String, BliData> departmentNameToBliData { get { if( departmentNameToBliData == null ) departmentNameToBliData = new Map<String, BliData>(); return departmentNameToBliData; } private set; }
        public List<Billing_Line_Item__c> hiddenBli { get { return getHiddenBli(); } private set; }

        public DepartmentData( Project_Profile__c project, Billing_Line_Item__c projectRelatedParentBli, Map<Id, Billing_Date__c> billingDates, Boolean isCurrentlyPrebilling ) {
            this.projectRelatedParentBli = projectRelatedParentBli;
            for( Service_Item__c siItem : project.Service_Items__r ) {
                String departmentName = siItem.Department_Name__c;
                BliData newBliData = new BliData( departmentName, project, projectRelatedParentBli, billingDates, isCurrentlyPrebilling );
                if( !this.departmentNameToBliData.containsKey( departmentName ) ) {
                    this.departmentNameToBliData.put( departmentName, newBliData );
                }
            }

            //totals for parent bli should be equal to sum of totals for department (hidden) blis; this part compensates the rounding errors
            Decimal unitPriceTotal = 0.00;
            Decimal tax1Total = 0.00;
            Decimal tax2Total = 0.00;
            List<BliData> bliData = departmentNameToBliData.values();
            if( !bliData.isEmpty() ) {
                for( BliData bliDataItem : bliData ) {
                    unitPriceTotal += bliDataItem.hiddenBliAmount;
                    tax1Total += bliDataItem.hiddenBliTax1Amount;
                    tax2Total += bliDataItem.hiddenBliTax2Amount;
                }

                Decimal billedAmountDifference = projectRelatedParentBli.Amount__c - unitPriceTotal;
                Decimal billedTax1Difference = projectRelatedParentBli.Sales_Tax_Amount_1__c - tax1Total;
                Decimal billedTax2Difference = projectRelatedParentBli.Sales_Tax_Amount_2__c - tax2Total;

                if( billedAmountDifference != 0 || billedTax1Difference != 0 || billedTax2Difference != 0 ) {
                    for( BliData bliDataItem : bliData ) {
                        if( billedAmountDifference != 0 && bliDataItem.hiddenBliAmount != 0 ) {
                            bliDataItem.hiddenBliAmount += billedAmountDifference;
                            bliDataItem.billedAmount += billedAmountDifference;
                            billedAmountDifference = 0;
                        }
                        if( billedTax1Difference != 0 && bliDataItem.hiddenBliTax1Amount != 0 ) {
                            bliDataItem.hiddenBliTax1Amount += billedTax1Difference;
                            bliDataItem.billedTax1Amount += billedTax1Difference;
                            billedTax1Difference = 0;
                        }
                        if( billedTax2Difference != 0 && bliDataItem.hiddenBliTax2Amount != 0 ) {
                            bliDataItem.hiddenBliTax2Amount += billedTax2Difference;
                            bliDataItem.billedTax2Amount += billedTax2Difference;
                            billedTax2Difference = 0;
                        }
                        if( billedAmountDifference == 0 && billedTax1Difference == 0 && billedTax2Difference == 0 ) {
                            break;
                        }
                    }
                }
            }
        }

        public List<Billing_Line_Item__c> getHiddenBli() {
            List<Billing_Line_Item__c> hiddenBlis = new List<Billing_Line_Item__c>();
            for( BliData bliDataItem : departmentNameToBliData.values() ) {
                hiddenBlis.add( bliDataItem.hiddenBli );
            }
            return hiddenBlis;
        }
    }


    public class BliData {
        public Billing_Line_Item__c projectRelatedParentBli { get { return projectRelatedParentBli; } private set; }

        public String departmentName { get { if( departmentName == null ) departmentName = ''; return departmentName; } private set; }
        //public Decimal unbilledPercentage { get { if( unbilledPercentage == null ) unbilledPercentage = 100.00; return unbilledPercentage; } private set; }

        public Decimal billedAmount { get { if( billedAmount == null ) billedAmount = 0.00; return billedAmount; } set; }
        public Decimal billedTax1Amount { get { if( billedTax1Amount == null ) billedTax1Amount = 0.00; return billedTax1Amount; } set; }
        public Decimal billedTax2Amount { get { if( billedTax2Amount == null ) billedTax2Amount = 0.00; return billedTax2Amount; } set; }

        public Decimal totalAmount { get { if( totalAmount == null ) totalAmount = 0.00; return totalAmount; } private set; }
        public Decimal totalTax1Amount { get { if( totalTax1Amount == null ) totalTax1Amount = 0.00; return totalTax1Amount; } private set; }
        public Decimal totalTax2Amount { get { if( totalTax2Amount == null ) totalTax2Amount = 0.00; return totalTax2Amount; } private set; }

        public Decimal hiddenBliAmount { get { if( hiddenBliAmount == null ) hiddenBliAmount = 0.00; return hiddenBliAmount; } set; }
        public Decimal hiddenBliTax1Amount { get { if( hiddenBliTax1Amount == null ) hiddenBliTax1Amount = 0.00; return hiddenBliTax1Amount; } set; }
        public Decimal hiddenBliTax2Amount { get { if( hiddenBliTax2Amount == null ) hiddenBliTax2Amount = 0.00; return hiddenBliTax2Amount; } set; }

        public Decimal remainingPercentage { get { if( remainingPercentage == null ) remainingPercentage = 0.00; return remainingPercentage; } set; }

        public Boolean isValid { get { return hiddenBliAmount != 0.00 || hiddenBliTax1Amount != 0.00 || hiddenBliTax2Amount != 0.00; } }
        public Billing_Line_Item__c hiddenBli { get { return getHiddenBli(); } }

        public BliData( String departmentName, Project_Profile__c project, Billing_Line_Item__c projectRelatedParentBli, Map<Id, Billing_Date__c> billingDates, Boolean isCurrentlyPrebilling ) {
            this.departmentName = departmentName;
            this.projectRelatedParentBli = projectRelatedParentBli;
            /*if( project.Pre_billed__c && !isCurrentlyPrebilling ) {
                unbilledPercentage = 0.00;
            } else if( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && project.Interval__c ) {
                for( Billing_Date__c billingDateItem : project.Billing_Dates__r ) {
                    unbilledPercentage += billingDateItem.Percentage__c;
                }
            }*/

            for( Billing_Line_Item__c bliItem : project.Billing_Line_Items__r ) {
                if( bliItem.Billing_Date__r.Billed__c || bliItem.Billing_Date__c == null ) {
                    /*if( bliItem.Billing_Date__r.Percentage__c != null && bliItem.Billing_Date__r.Percentage__c > 0 && ( !project.Pre_billed__c || isCurrentlyPrebilling ) ) {
                        unbilledPercentage -= bliItem.Billing_Date__r.Percentage__c;
                    }*/
                    if( bliItem.Department_Name_Override__c == departmentName ) {
                        if( bliItem.Unit_Price_for_FF__c != null ) {
                            billedAmount += bliItem.Unit_Price_for_FF__c;
                        }
                        if( bliItem.Tax1_for_FF__c != null ) {
                            billedTax1Amount += bliItem.Tax1_for_FF__c;
                        }
                        if( bliItem.Tax2_for_FF__c != null ) {
                            billedTax2Amount += bliItem.Tax2_for_FF__c;
                        }
                    }
                }
            }

            //Calculate total tax amount for all service items in Project
            for( Service_Item__c siItem : project.Service_Items__r ) {
                if( siItem.Department_Name__c == departmentName ) {
                    if( !siItem.Is_Amendmend_Deleted__c || siItem.Change_Order__r.Status__c != ChangeOrderServices.STATUS_APPROVED ) {
                        if( siItem.Total_Discounted_Price__c != null ) {
                            totalAmount += siItem.Total_Discounted_Price__c;
                        }
                        if( siItem.Sales_Tax_Amount_1__c != null ) {
                            totalTax1Amount += siItem.Sales_Tax_Amount_1__c;
                        }
                        if( siItem.Sales_Tax_Amount_2__c != null ) {
                            totalTax2Amount += siItem.Sales_Tax_Amount_2__c;
                        }
                    }
                }
            }

            if( ( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && project.Interval__c ) ||
                  project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) {
                for( Billing_Date__c billingDate : project.Billing_Dates__r ) {
                    remainingPercentage += billingDate.Percentage__c;
                }
                if( remainingPercentage != 0 ) {
                    Decimal currentPercentage = billingDates.get( projectRelatedParentBli.Billing_Date__c ) != null
                                                ? billingDates.get( projectRelatedParentBli.Billing_Date__c ).Percentage__c
                                                : 0.00;

                    hiddenBliAmount = ( currentPercentage/remainingPercentage ) * ( totalAmount - billedAmount ).setScale( 2 );
                    hiddenBliTax1Amount = ( currentPercentage/remainingPercentage ) * ( totalTax1Amount - billedTax1Amount ).setScale( 2 );
                    hiddenBliTax2Amount = ( currentPercentage/remainingPercentage ) * ( totalTax2Amount - billedTax2Amount ).setScale( 2 );
                }
            } else if( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !project.Interval__c ) {
                Decimal quantity = projectRelatedParentBli.Quantity__c;
                for( Task_Item__c unBilledTaskItem : project.Task_Items__r ) {
                    remainingPercentage += unBilledTaskItem.Billing_Percentage__c;
                    if ( unBilledTaskItem.Id == projectRelatedParentBli.Task_Item__c ){
                        quantity = unBilledTaskItem.Billing_Percentage__c/100;
                    }
                }
                if( remainingPercentage != 0 ) {
                    hiddenBliAmount = 100 * ( quantity/remainingPercentage ) * ( totalAmount - billedAmount ).setScale( 2 ); /*projectRelatedParentBli.Quantity__c = percentage to bill;*/
                    hiddenBliTax1Amount = 100 * ( quantity/remainingPercentage ) * ( totalTax1Amount - billedTax1Amount ).setScale( 2 );
                    hiddenBliTax2Amount = 100 * ( quantity/remainingPercentage ) * ( totalTax2Amount - billedTax2Amount ).setScale( 2 );
                }
            }
        }

        public Billing_Line_Item__c getHiddenBli() {
            Billing_Line_Item__c newHiddenBli = projectRelatedParentBli.clone( false, true, false, false ); //full record copy (no reference) without Id, r/o timestamps and autonumbers
            newHiddenBli.Main_Billing_Line_Item__c = projectRelatedParentBli.Id;
            newHiddenBli.Department_Based__c = true;
            newHiddenBli.Department_Name_Override__c = departmentName;
            newHiddenBli.Amount__c = 0;
            newHiddenBli.Quantity__c = 0;
            newHiddenBli.Sales_Tax_Amount_1__c = 0;
            newHiddenBli.Sales_Tax_Amount_2__c = 0;
            newHiddenBli.Unit_Price_for_FF_Override__c = hiddenBliAmount;
            newHiddenBli.Tax1_for_FF_Override__c = hiddenBliTax1Amount;
            newHiddenBli.Tax2_for_FF_Override__c = hiddenBliTax2Amount;
            newHiddenBli.Is_Manualy_Created__c = false;
            //newHiddenBli.Quantity_for_FF__c = 1;
            return newHiddenBli;
        }
    }


    private List<Project_Profile__c> getProjects( Set<Id> projectProfileIds ) {
        return new List<Project_Profile__c>( [ SELECT CreatedDate, Billing_Method__c, Interval__c, Discounted_Total_Service_Amount__c,
                                                      /*Total_Service_Amount__c, Pre_billed__c, Discounted_Total_Service_Amount__c,*/
                                                      ( SELECT /*Task_Item__r.Billing_Percentage__c, Amount__c,*/
                                                               Tax1_for_FF__c, Tax2_for_FF__c, Unit_Price_for_FF__c, Department_Name_Override__c,
                                                               Billing_Date__c, Billing_Date__r.Billed__c
                                                               /*, Billing_Date__r.Percentage__c,*/
                                                        FROM Billing_Line_Items__r
                                                        WHERE IsReimbursable__c = false
                                                          AND Department_Based__c = true
                                                          AND Active_Billing_Line_Item__c = true
                                                          AND isHourlyConsulting__c = false
                                                          AND Is_Check_Processing_Fee__c = false ),
                                                      ( SELECT Department_Name__c, Total_Discounted_Price__c, Sales_Tax_Amount_1__c, Sales_Tax_Amount_2__c,
                                                               Is_Amendmend_Deleted__c, Change_Order__r.Status__c
                                                        FROM Service_Items__r
                                                        WHERE Is_Alternative__c = false
                                                          /*AND ( ( Is_Amendmend_Deleted__c = false ) OR
                                                                ( Is_Amendmend_Deleted__c = true AND Change_Order__r.Status__c != : ChangeOrderServices.STATUS_APPROVED ) )*/ ),
                                                      ( SELECT Percentage__c
                                                        FROM Billing_Dates__r
                                                        WHERE Billed__c = false ),
                                                      ( SELECT Id, Billing_Percentage__c
                                                        FROM Task_Items__r
                                                        WHERE Billing_Percentage__c != null And Billing_Trigger__c = true And Is_Locked__c = false And
                                                            Service_Item__r.Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE )
                                               FROM Project_Profile__c
                                               WHERE Id IN : projectProfileIds ] );
    }

}