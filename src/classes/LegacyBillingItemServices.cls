public with sharing class LegacyBillingItemServices {
    private static final String LEGACY_DESCRIPTION_BLI_NO_MET_DATA_SCANNING_DESCRIPTION  = 'Digital Asset Management - Document Scanning';
    private static final String LEGACY_DESCRIPTION_DOCUMENT_SHREDDING                    = 'Document Shredding';
    private static final String LEGACY_PRODUCT_METROPOLITAN_ARCHIVES                     = '20105 - A\\P Metropolitan Archives';
    private static final String LEGACY_PRODUCT_NET_REIMBURSABLE_INCOME_OTHER             = '41108 - Net Reimbursable Income:Other';
    private static final String LEGACY_REIMBURSABLE                                      = 'Reimbursable';
    
    /* ----------------------------- Begin Bussiness Logic Methods ---------------------------- */
    public static void validationLegaycBillingItems(List<Legacy_Billing_Item__c> newList, Map<Id, Legacy_Billing_Item__c> oldMap) {
        for (Legacy_Billing_Item__c legacy : newList) {
            if (legacy.MRC__c != oldMap.get(legacy.Id).MRC__c) {
                legacy.addError(ErrorException.LEGACY_MRC_FIELD_NOT_EDITABLE);
            
            }
        }
    
    }
    
    public static void populateDimensions(List<Legacy_Billing_Item__c> legacyItems) {
        Set<String> departments = new Set<String>();
        Set<String> products    = new Set<String>();
        Set<String> territories = new Set<String>();
        List<Legacy_Billing_Item__c> legacyToUpdate = new List<Legacy_Billing_Item__c>();
        
        for (Legacy_Billing_Item__c item : legacyItems) {
            if (String.isBlank(item.Department__c) && String.isBlank(item.Department_DL__c)) {
                item.addError(ErrorException.LEGACY_DEPARTMENT_FIELD_IS_REQUIRED);
            
            }
            
            if (String.isBlank(item.Product_Name__c) && String.isBlank(item.Product_Name_DL__c)) {
                item.addError(ErrorException.LEGACY_PRODUCT_FIELD_IS_REQUIRED);
            
            }
            
            if (String.isBlank(item.Territory__c) && String.isBlank(item.Territory_DL__c)) {
                item.addError(ErrorException.LEGACY_TERRITORY_FIELD_IS_REQUIRED);
            
            }
            
            if ((String.isBlank(item.Department__c) && !String.isBlank(item.Department_DL__c)) || 
                (String.isBlank(item.Product_Name__c) && !String.isBlank(item.Product_Name_DL__c)) || 
                (String.isBlank(item.Territory__c) && !String.isBlank(item.Territory_DL__c))) {
                    departments.add(item.Department_DL__c);
                    products.add(item.Product_Name_DL__c);
                    territories.add(item.Territory_DL__c);
                    legacyToUpdate.add(item);
            
            }
        
        }
        
        if (legacyToUpdate.isEmpty()) {
            return;
        
        }
        departments.remove(null);
        products.remove(null);
        territories.remove(null);
        
        List<c2g__codaDimension1__c> dimension1List = [SELECT Id, Name FROM c2g__codaDimension1__c WHERE Name IN: departments];
        List<c2g__codaDimension2__c> dimension2List = [SELECT Id, Name FROM c2g__codaDimension2__c WHERE Name IN: territories];
        List<Product2> productList = [SELECT Id, Name FROM Product2 WHERE Name IN: products];
        
        for (Legacy_Billing_Item__c item : legacyToUpdate) {
            for (c2g__codaDimension1__c d1 : dimension1List) {
                if (item.Department_DL__c == d1.Name) {
                    item.Department__c = d1.Id;
                    break;
                    
                }
            
            }

            for (c2g__codaDimension2__c d2 : dimension2List) {
                if (item.Territory_DL__c == d2.Name) {
                    item.Territory__c = d2.Id;
                    break;
                
                }
            
            }

            for (Product2 p : productList) {
                if (item.Product_Name_DL__c == p.Name) {
                    item.Product_Name__c = p.Id;
                    break;
                
                }
            
            }
        
        }
        
    }
    
    public static List<Legacy_Billing_Item__c> filterLegacyBillingItem(List<Legacy_Billing_Item__c> legacyBillingItems) {
        List<Legacy_Billing_Item__c> filteredLegacyBillingLines = new List<Legacy_Billing_Item__c>();
        
        for (Legacy_Billing_Item__c legacyItem : legacyBillingItems) {
            if (!legacyItem.Created_by_ClickLink__c) {
                filteredLegacyBillingLines.add(legacyItem);
            
            }
        
        }
        return filteredLegacyBillingLines;
    
    }
    
    public static void updateManuallyCreatedLegacyItem(List<Legacy_Billing_Item__c> legacyBillingItems) {
        Set<String> mrc = new Set<String>();
        for (Legacy_Billing_Item__c legacyItem : legacyBillingItems) {
            mrc.add(legacyItem.MRC__c);
        
        }
        mrc.remove(null);
        Map<String, Project__c> mrcToProjectName = getMRCNumberToProjectNameMi7ByMrc(mrc);
        Project__c projectMi7;
        
        for (Legacy_Billing_Item__c legacyItem : legacyBillingItems) {
            if (!mrcToProjectName.containsKey(legacyItem.MRC__c) && !String.isBlank(legacyItem.MRC__c)) {
                legacyItem.addError(ErrorException.MRC_NUMBER_DOES_NOT_EXIST);
                
            }
            
            if (!String.isBlank(legacyItem.Accounting_Contact__c)) {
                legacyItem.addError(ErrorException.ACCOUNT_CONTACT_CANNOT_POPULATED_MANUALLY);
            
            }
            
            if (!String.isBlank(legacyItem.Accounting_Contact_Company__c)) {
                legacyItem.addError(ErrorException.ACCOUNTING_COMPANY_CANNOT_POPULATED_MANUALLY);
            
            }
            
            if (!String.isBlank(legacyItem.Billing_Client__c)) {
                legacyItem.addError(ErrorException.BILLING_CLIENT_CANNOT_POPULATED_MANUALLY);
            
            }
            
            if (!String.isBlank(legacyItem.Project_Address__c)) {
                legacyItem.addError(ErrorException.PROJETC_ADDRESS_CANNOT_POPULATED_MANUALLY);
            
            }
            
            legacyItem.Initial__c                    = String.isBlank(legacyItem.Initial__c) ? 'Initial' : legacyItem.Initial__c;
            legacyItem.Data_Source_Type__c           = String.isBlank(legacyItem.Data_Source_Type__c) ? 'Manual created' : legacyItem.Data_Source_Type__c;
            legacyItem.Added_By__c                   = String.isBlank(legacyItem.Added_By__c) ? UserInfo.getFirstName() + ' ' + UserInfo.getLastName() : legacyItem.Added_By__c;
            
            if (mrcToProjectName.containsKey(legacyItem.MRC__c)) {
                projectMi7 = mrcToProjectName.get(legacyItem.MRC__c);
                
                legacyItem.Project_Name_Mi7__c           = projectMi7.Id; 
                legacyItem.Accounting_Contact__c         = projectMi7.Accounting_Contact__c;
                legacyItem.Accounting_Contact_Company__c = projectMi7.Accounting_Contact_Company__c;
                legacyItem.Billing_Client__c             = projectMi7.Billing_Client_Company__c;
                legacyItem.Project_Address__c            = projectMi7.Building__c;
            
            }
            
        }
    
    }
    
    public static List<Legacy_Billing_Item__c> filterClickLinkLegacyBillingItem(List<Legacy_Billing_Item__c> legacyBillingItems) {
        List<Legacy_Billing_Item__c> filteredLegacyBillingLines = new List<Legacy_Billing_Item__c>();
        
        for (Legacy_Billing_Item__c legacyItem : legacyBillingItems) {
            if (legacyItem.Created_by_ClickLink__c) {
                filteredLegacyBillingLines.add(legacyItem);
            
            }
        
        }
        return filteredLegacyBillingLines;
    
    }
    
    public static void updateClickLinkCreatedLegacyItem(List<Legacy_Billing_Item__c> legacyBillingItems) {
        Set<String> mrc = new Set<String>();
        
        for (Legacy_Billing_Item__c legacyItem : legacyBillingItems) {
            
            mrc.add(legacyItem.MRC__c);
        
        }
        mrc.remove(null);
        Map<String, Project__c> mrcToProjectName = getMRCNumberToProjectNameMi7ByMrc(mrc);
        Project__c projectMi7;
        
        for (Legacy_Billing_Item__c legacyItem : legacyBillingItems) { 
            if (mrcToProjectName.containsKey(legacyItem.MRC__c)) {
                projectMi7 = mrcToProjectName.get(legacyItem.MRC__c);
                
                legacyItem.Accounting_Contact__c         = projectMi7.Accounting_Contact__c;
                legacyItem.Accounting_Contact_Company__c = projectMi7.Accounting_Contact_Company__c;
                legacyItem.Billing_Client__c             = projectMi7.Billing_Client_Company__c;
                legacyItem.Project_Address__c            = projectMi7.Building__c;
            
            }
        
        }
    
    }
    
    public static void updateAggregatedFieldsOnLegacyProformInvoice(Map<Id, Legacy_Pro_forma_Invoice__c> legacyInvoices) {
        if (null == legacyInvoices || legacyInvoices.isEmpty()) {
            return;
        
        }
    
        for (AggregateResult aggItem : getAggregatedLegacyLineItemsByInvoiceIds(legacyInvoices.keySet())) {
            legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')).Subtotal__c = (Decimal)aggItem.get('expr0');
            legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')).Tax__c      = (Decimal)aggItem.get('expr1');
            //Sum up credit 1
            legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')).Subtotal_Credit1__c = (Decimal)aggItem.get('expr2');
            legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')).Tax_Credit1__c      = (Decimal)aggItem.get('expr3') + (Decimal)aggItem.get('expr4');
            //Sum up credit 2
            legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')).Subtotal_Credit2__c = (Decimal)aggItem.get('expr5');
            legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')).Tax_Credit2__c      = (Decimal)aggItem.get('expr6') + (Decimal)aggItem.get('expr7');
         
        }
        update legacyInvoices.values();
    
    }
    
    public static Map<Id, Legacy_Pro_forma_Invoice__c> filterLegacyInvoiceForUpdateAggregate(Map<Id, Legacy_Billing_Item__c> legaycLineItemsMap, List<Legacy_Billing_Item__c> legaycLineItems) {
        Set<Id> invoiceIds = new Set<Id>();
        
        for (Legacy_Billing_Item__c lineItem : legaycLineItems) {
            if (legaycLineItemsMap.get(lineItem.Id).Tax__c != lineItem.Tax__c || legaycLineItemsMap.get(lineItem.Id).Extended_Fee__c != lineItem.Extended_Fee__c ||
                //Credit 1
                legaycLineItemsMap.get(lineItem.Id).cl_Credit_1_Amount__c != lineItem.cl_Credit_1_Amount__c || 
                legaycLineItemsMap.get(lineItem.Id).cl_Credit_1_Tax_1_Amount__c != lineItem.cl_Credit_1_Tax_1_Amount__c || 
                legaycLineItemsMap.get(lineItem.Id).cl_Credit_1_Tax_2_Amount__c != lineItem.cl_Credit_1_Tax_2_Amount__c ||
                //Credit 2
                legaycLineItemsMap.get(lineItem.Id).cl_Credit_2_Amount__c != lineItem.cl_Credit_2_Amount__c || 
                legaycLineItemsMap.get(lineItem.Id).cl_Credit_2_Tax_1_Amount__c != lineItem.cl_Credit_2_Tax_1_Amount__c || 
                legaycLineItemsMap.get(lineItem.Id).cl_Credit_2_Tax_2_Amount__c != lineItem.cl_Credit_2_Tax_2_Amount__c ||
                //Create Proforma Invoice
                (!legaycLineItemsMap.get(lineItem.Id).Billed__c && lineItem.Billed__c) ||
                //Remove BLI from proforma
                (legaycLineItemsMap.get(lineItem.Id).Billed__c && !lineItem.Billed__c)) {
                    invoiceIds.add(legaycLineItemsMap.get(lineItem.Id).Legacy_Pro_forma_Invoice__c);
            
            }
        
        }
        invoiceIds.remove(null);
        
        return new Map<Id, Legacy_Pro_forma_Invoice__c>(LegacyProformaInvoiceServices.getLegacyProformaInvoicesById(invoiceIds));
    
    }
    
    public static Map<Id, Legacy_Pro_forma_Invoice__c> filterLegacyInvoiceForUpdateAggregate(List<Legacy_Billing_Item__c> legaycLineItems) {
        Set<Id> invoiceIds = new Set<Id>();
        
        for (Legacy_Billing_Item__c lineItem : legaycLineItems) {
            invoiceIds.add(lineItem.Legacy_Pro_forma_Invoice__c);
        
        }
        invoiceIds.remove(null);
        
        return new Map<Id, Legacy_Pro_forma_Invoice__c>(LegacyProformaInvoiceServices.getLegacyProformaInvoicesById(invoiceIds));
    
    }
    
    public static List<Legacy_Billing_Item__c> filteredLegacyItemForUpdateBillingPreference(List<Legacy_Billing_Item__c> newList, Map<Id, Legacy_Billing_Item__c> oldMap) {
        List<Legacy_Billing_Item__c> legacyItems = new List<Legacy_Billing_Item__c>();
        
        for (Legacy_Billing_Item__c legacy : newList) {
            if (legacy.Accounting_Contact_Company__c != oldMap.get(legacy.Id).Accounting_Contact_Company__c) {
                legacyItems.add(legacy);
            
            } else if (null == legacy.Accounting_Contact_Company__c && legacy.Billing_Client__c != oldMap.get(legacy.Id).Billing_Client__c) {
                legacyItems.add(legacy);
                
            }
        
        }
        return legacyItems;
    
    }
    
    public static void generateLegacyBLIForAddidtionalFees(List<Legacy_Billing_Item__c> legacyItems) {
        if (null == legacyItems || legacyItems.isEmpty()) {
            return;
        
        }
        
        List<Legacy_Billing_Item__c> additionalBLIs = new List<Legacy_Billing_Item__c>();
        
        for (Legacy_Billing_Item__c item : legacyItems) {
            if (!item.No_Met_Data_Scanning_Formula__c && null != item.Scanning_Fees__c) {
                additionalBLIs.add(LegacyBillingItemServices.newInstance(item, true, false));
                
            }
            
            if (!item.No_Document_Shredding_Formula__c && null != item.Shredding_Fees__c) {
                additionalBLIs.add(LegacyBillingItemServices.newInstance(item, false, true));
                
            }
        
        }
        insert additionalBLIs;
    
    }
    
    public static Legacy_Billing_Item__c newInstance(Legacy_Billing_Item__c legacyBLITemplate, Boolean isScanning, Boolean isShredding) {
        return new Legacy_Billing_Item__c(Invoice_Line_Description__c = isScanning ? LEGACY_DESCRIPTION_BLI_NO_MET_DATA_SCANNING_DESCRIPTION : (isShredding ? LEGACY_DESCRIPTION_DOCUMENT_SHREDDING : null),
                                          Product_Name_DL__c          = isScanning ? LEGACY_PRODUCT_METROPOLITAN_ARCHIVES : (isShredding ? LEGACY_PRODUCT_NET_REIMBURSABLE_INCOME_OTHER : null),
                                          Territory_DL__c             = legacyBLITemplate.Territory_DL__c,
                                          Department_DL__c            = legacyBLITemplate.Department_DL__c,
                                          Client_PO__c                = legacyBLITemplate.Client_PO__c,
                                          Type__c                     = LEGACY_REIMBURSABLE,
                                          Quantity__c                 = 1,
                                          Price__c                    = isScanning ? legacyBLITemplate.Scanning_Fees__c : (isShredding ? legacyBLITemplate.Shredding_Fees__c : null),
                                          MRC__c                      = legacyBLITemplate.MRC__c,
                                          External_ID__c              = null,
                                          Is_Scanning__c              = isScanning,
                                          Is_Shredding__c             = isShredding,
                                          Detail_Description__c       = legacyBLITemplate.Detail_Description__c,
                                          Municipal_Agency_ID__c      = legacyBLITemplate.Municipal_Agency_ID__c,
                                          Date_Added__c               = legacyBLITemplate.Date_Added__c,
                                          Territory__c                = legacyBLITemplate.Territory__c,
                                          Department__c               = legacyBLITemplate.Department__c,
                                          Product_Name__c             = legacyBLITemplate.Product_Name__c);
    
    }
    
    public static void updateTotalCommissionableAmount(Map<Id, Legacy_Pro_forma_Invoice__c> legacyInvoices) {
         if (null == legacyInvoices || legacyInvoices.isEmpty()) {
            return;
        
        }
        
        List<Legacy_Pro_forma_Invoice__c> legacyInvoiceToUpdate = new List<Legacy_Pro_forma_Invoice__c>();
        Set<Id> recalcualteInvoices = new Set<Id>();
        
        for (AggregateResult aggItem : getAggregatedLegacyLineItemsTotalCommissionableAmountByInvoiceIds(legacyInvoices.keySet())) {
            recalcualteInvoices.add(legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')).Id);
            legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')).Total_Commissionable_Amount__c = (Decimal)aggItem.get('expr0');
            legacyInvoiceToUpdate.add(legacyInvoices.get((Id)aggItem.get('Legacy_Pro_forma_Invoice__c')));
            
        }
        
        for (Legacy_Pro_forma_Invoice__c invoice : legacyInvoices.values()) {
            if (!recalcualteInvoices.contains(invoice.Id) && !invoice.Create_FFA_Invoice__c) {
                invoice.Total_Commissionable_Amount__c = 0.00;
                legacyInvoiceToUpdate.add(invoice);
            
            }
        
        }
        
        update legacyInvoiceToUpdate;
    
    }
    
    public static Map<Id, Legacy_Pro_forma_Invoice__c> filteredLegacyItemForTotalCommissionableAmount(List<Legacy_Billing_Item__c> legaycLineItems) {
        Set<Id> invoiceIds = new Set<Id>();
        
        for (Legacy_Billing_Item__c lineItem : legaycLineItems) {
            invoiceIds.add(lineItem.Legacy_Pro_forma_Invoice__c);
        
        }
        invoiceIds.remove(null);
        
        return new Map<Id, Legacy_Pro_forma_Invoice__c>(LegacyProformaInvoiceServices.getLegacyProformaInvoicesById(invoiceIds));
    
    }
    
    public static void buildRelationsBetweenMailroomAndLBIs(List<Legacy_Mailroom__c> mairooms) {
        Map<String, Id> pakcageIdToMailroomId = new Map<String, Id>();
        
        for (Legacy_Mailroom__c mailroom : mairooms) {
            pakcageIdToMailroomId.put(mailroom.Package_Id__c, mailroom.Id);
            
        }
        pakcageIdToMailroomId.remove(null);
        
        List<Legacy_Billing_Item__c> lbis = LegacyBillingItemServices.getLegacyBillingItemsByExternalIDs(pakcageIdToMailroomId.keySet());
        
        for (Legacy_Billing_Item__c lbi : lbis) {
            if (pakcageIdToMailroomId.containsKey(lbi.External_ID__c)) {
                lbi.Legacy_Mailroom__c = pakcageIdToMailroomId.get(lbi.External_ID__c);
            
            }
        
        }
        update lbis;
        
    }
    /* ----------------------------- End Bussiness Logic Methods ---------------------------- */

    /* ----------------------------- Begin DAO Methods ---------------------------- */
    @TestVisible
    private static List<Legacy_Billing_Item__c> getLegacyBillingItemsByExternalIDs(Set<String> externalIDs) {
        if (null == externalIDs || externalIDs.isEmpty()) {
            return new List<Legacy_Billing_Item__c>();
        
        }
        return new List<Legacy_Billing_Item__c>([SELECT Id, External_ID__c, Legacy_Mailroom__c
                                                 FROM Legacy_Billing_Item__c 
                                                 WHERE External_ID__c IN: externalIDs]);
                                                                              
    }
    
    @TestVisible
    private static AggregateResult[] getAggregatedLegacyLineItemsByInvoiceIds(Set<Id> invoiceIds) {
        if (null == invoiceIds || invoiceIds.isEmpty()) {
            return new AggregateResult[] { };
        
        }
        
        AggregateResult[] groupedResults = [SELECT Legacy_Pro_forma_Invoice__c, SUM(Extended_Fee__c), SUM(Tax__c),
                                                   SUM(cl_Credit_1_Amount__c), SUM(cl_Credit_1_Tax_1_Amount__c), SUM(cl_Credit_1_Tax_2_Amount__c),
                                                   SUM(cl_Credit_2_Amount__c), SUM(cl_Credit_2_Tax_1_Amount__c), SUM(cl_Credit_2_Tax_2_Amount__c)
                                            FROM Legacy_Billing_Item__c
                                            WHERE Legacy_Pro_forma_Invoice__c IN: invoiceIds
                                            GROUP BY Legacy_Pro_forma_Invoice__c];
        
        return groupedResults;
    
    }
    
    @TestVisible
    private static AggregateResult[] getAggregatedLegacyLineItemsTotalCommissionableAmountByInvoiceIds(Set<Id> invoiceIds) {
        if (null == invoiceIds || invoiceIds.isEmpty()) {
            return new AggregateResult[] { };
        
        }
        
        AggregateResult[] groupedResults = [SELECT Legacy_Pro_forma_Invoice__c, SUM(Extended_Fee__c)
                                            FROM Legacy_Billing_Item__c
                                            WHERE Legacy_Pro_forma_Invoice__c IN: invoiceIds AND Product_Name__r.Name LIKE '401%' AND  Legacy_Pro_forma_Invoice__r.Create_FFA_Invoice__c =: false
                                            GROUP BY Legacy_Pro_forma_Invoice__c];
        
        return groupedResults;
    
    }
    
    public static String buildQueryWhere(final String billingClientCompanyFilter, final String accountingContactCompanyFilter, final String mrcFilter, 
                                         final String projectAddressFilter, final String deliveryMethodFilter, final Boolean notBilliableFilter) {
        String queryWhere = '';
        if (!String.isBlank(accountingContactCompanyFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Accounting_Contact_Company__r.Name LIKE \'%' + accountingContactCompanyFilter + '%\' ';

        }

        if (!String.isBlank(billingClientCompanyFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Billing_Client__r.Name LIKE \'%' + billingClientCompanyFilter + '%\' ';

        }

        if (!String.isBlank(projectAddressFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Project_Address__r.Name LIKE \'%' + projectAddressFilter + '%\' ';

        }

        if (!String.isBlank(mrcFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' MRC__c LIKE \'%' + mrcFilter + '%\' ';

        }

        if (!String.isBlank(deliveryMethodFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Delivery_Method_Formula__c LIKE \'' + deliveryMethodFilter + '%\' ';

        }

        queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
        queryWhere += ' Billed__c = false ';

        queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
        queryWhere += notBilliableFilter ? ' Not_Billable__c = true ' : ' Not_Billable__c = false ';
        
        return queryWhere;
    
    }
    
    public static String buildQuerySelect(String queryWhere, String sortBy) {
        return 'SELECT Type__c, Quantity__c, Price__c, Not_Billable__c, Accounting_Contact__c, Project_Address__c, ' + 
                       ' Name, Municipal_Agency_ID__c, MRC__c, Invoice_Line_Description__c, Id, Accounting_Contact_Company__c, CreatedDate, ' + 
                       ' Detail_Description__c, Department__c, Date_Added__c, Data_Source_Type__c, Project_Name_Mi7__r.Prebilled__c, ' +
                       ' Project_Name_Mi7__r.Billing_Client_Company__c, Project_Name_Mi7__r.Sales_Exec_SF__c, Project_Name_Mi7__r.Billing_Contact_SF__c, ' +
                       ' Tax_Code_1__c, Sales_Tax_Amount_1__c, Tax_Code_2__c, Sales_Tax_Amount_2__c, Project_Name_Mi7__r.Client_Project__c, ' +
                       ' Project_Name_Mi7__r.Building__c, Project_Name_Mi7__r.Floor_s__c, Project_Name_Mi7__r.MRC__c, Client_PO__c, PO_Required__c, ' +
                       ' Delivery_Method_Formula__c, Frequency_Formula__c, Quarterly_Month_Formula__c, Billing_Day_Formula__c, Separate_Reimbursables_Formula__c, ' +
                       ' No_Document_Shredding_Formula__c, No_Met_Data_Scanning_Formula__c ' + 
               ' FROM Legacy_Billing_Item__c ' + queryWhere  +' ORDER BY ' + sortBy + ' LIMIT 1000';
                   
    }
    
    public static Map<String, Project__c> getMRCNumberToProjectNameMi7ByMrc(Set<String> mrc) {    
        if (null == mrc || mrc.isEmpty()) {
            return new Map<String, Project__c>();
        
        }
        
        List<Project__c> projectMi7 = new List<Project__c>([SELECT Id, Name, MRC__c, Accounting_Contact__c, Accounting_Contact_Company__c, Sales_Exec_SF__c,
                                                                   Billing_Client_Company__c, Billing_Contact_SF__c, Building__c 
                                                            FROM Project__c WHERE MRC__c IN: mrc]);
        Map<String, Project__c> mrcToProjectName = new Map<String, Project__c>();
        
        for (Project__c p : projectMi7) {
            mrcToProjectName.put(p.MRC__c, p);
        
        }
        mrcToProjectName.remove(null);
        return mrcToProjectName;
        
    }

    public static List<Legacy_Billing_Item__c> getAllLegacyLineItemByInvoiceIds(Id invoiceId) {
        if (null == invoiceId) {
            throw new ErrorException(ErrorException.INVOICE_ID_EMPTY);

        }

        return [SELECT Id, Name, Invoice_Line_Description__c, Date_Added__c, Legacy_Pro_forma_Invoice__c, Billed__c
                FROM Legacy_Billing_Item__c
                WHERE Legacy_Pro_forma_Invoice__c =: invoiceId];


    }

    public static List<Legacy_Billing_Item__c> getLegacyLineItemByInvoiceIds(Set<Id> invoiceIds) {
        if (null == invoiceIds || invoiceIds.isEmpty()) {
            return new List<Legacy_Billing_Item__c>();
        
        }
        return new List<Legacy_Billing_Item__c>([SELECT Id, Legacy_Pro_forma_Invoice__c, Billed__c
                                                 FROM Legacy_Billing_Item__c
                                                 WHERE Legacy_Pro_forma_Invoice__c IN: invoiceIds AND Billed__c =: true]);
    
    }
    
    public static List<Legacy_Billing_Item__c> getMailroomLBIs(Set<Id> invoiceIds) {
        return new List<Legacy_Billing_Item__c>([SELECT Type__c, Legacy_Pro_forma_Invoice__c, Legacy_Mailroom_COSTCATID_Service_Type__c, Id, Invoice_Line_Description__c 
                                                 FROM Legacy_Billing_Item__c
                                                 WHERE Legacy_Pro_forma_Invoice__c IN: invoiceIds AND
                                                       (Legacy_Mailroom_COSTCATID_Service_Type__c =: LegacyProformaInvoiceServices.FEDEX_FILTER OR
                                                        Legacy_Mailroom_COSTCATID_Service_Type__c =: LegacyProformaInvoiceServices.FEDEX_AIRBORNE_FILTER OR
                                                        Legacy_Mailroom_COSTCATID_Service_Type__c LIKE: LegacyProformaInvoiceServices.SUPREME_SYSTEMS_FILTER + '%' OR
                                                        Invoice_Line_Description__c =: LegacyProformaInvoiceServices.REIMBURSABLE_DOCUMENT_SHREDDING OR
                                                        Invoice_Line_Description__c =: LegacyProformaInvoiceServices.REIMBURSABLE_DOCUMENT_SCANNING)]);
    }
    /* ----------------------------- End DAO Methods ---------------------------- */

}