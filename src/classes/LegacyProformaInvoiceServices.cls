public with sharing class LegacyProformaInvoiceServices {
    public static final String INVOICE_WAS_NOT_SEND             = 'Invoice {0} was not sent. You may only send invoices after they have been created in FinancialForce.';
    public static final String LEGACY_REIMBURSABLE              = 'Reimbursable';
    public static final String REIMBURSABLE_DOCUMENT_SHREDDING = 'Document Shredding';
    public static final String REIMBURSABLE_DOCUMENT_SCANNING  = 'Digital Asset Management - Document Scanning';
    
    public static final String FEDEX_FILTER                    = 'FED EX';
    public static final String FEDEX_AIRBORNE_FILTER           = 'AIRBORNE';
    public static final String SUPREME_SYSTEMS_FILTER          = 'MESS';
    public static final String REIMBURSABLE_TYPE_SHREDDING     = 'Shredding';
    public static final String REIMBURSABLE_TYPE_SCANNING      = 'Scanning';
         
    /* ------------------------------------- Begin Business Logic Methods ------------------------------------------------ */
    public static void validationCreateFFACreditNote(Map<Id, Legacy_Pro_forma_Invoice__c> newInvoicesMap, List<Legacy_Pro_forma_Invoice__c> oldInvoices) {
        Set<Id> invoiceIds = new Set<Id>();

        for (Legacy_Pro_forma_Invoice__c invoice : oldInvoices) {
            if (newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_1__c && !invoice.cl_Create_FFA_Credit_Note_1__c ||
                newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_2__c && !invoice.cl_Create_FFA_Credit_Note_2__c) {
                    invoiceIds.add(invoice.Id);

            }

        }

        for (Legacy_Pro_forma_Invoice__c invoice : getLegacyProformaInvoicesById(invoiceIds)) {
            if (newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_1__c && !invoice.cl_Create_FFA_Credit_Note_1__c) {
                newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_1__c = allowCheckFFACreditNote1(invoice.Legacy_Billing_Items__r);

                if (!newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_1__c) {
                    newInvoicesMap.get(invoice.Id).addError(ErrorException.LEGACY_PRO_FORMA_REQUIRED_FIELDS_ON_BLI);

                }

            }

            if (newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_2__c && !invoice.cl_Create_FFA_Credit_Note_2__c) {
                newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_2__c = allowCheckFFACreditNote2(invoice.Legacy_Billing_Items__r);

                if (!newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_2__c) {
                    newInvoicesMap.get(invoice.Id).addError(ErrorException.LEGACY_PRO_FORMA_REQUIRED_FIELDS_ON_BLI);

                }

            }
            
        }

    }

    private static Boolean allowCheckFFACreditNote1(List<Legacy_Billing_Item__c> billingLineItems) {
        for (Legacy_Billing_Item__c bli : billingLineItems) {
            if (null == bli.cl_Credit_1_Amount__c) {
                return false;

            }

        }
        return true;

    }

    private static Boolean allowCheckFFACreditNote2(List<Legacy_Billing_Item__c> billingLineItems) {
        for (Legacy_Billing_Item__c bli : billingLineItems) {
            if (null == bli.cl_Credit_2_Amount__c) {
                return false;

            }

        }
        return true;

    }
    
    public static void generateLegacyInvoices(List<Legacy_Billing_Item__c> legacyItems) {
        if (null == legacyItems || legacyItems.isEmpty()) {
            return;
        
        }
        //Group Invoices by MRC number
        Map<String, List<Legacy_Billing_Item__c>> mrcToLBIs = LegacyProformaInvoiceServices.groupMrcToLgacyBillingItems(legacyItems);
        
        Map<String, Legacy_Pro_forma_Invoice__c> mrcToInvoices                        = new Map<String, Legacy_Pro_forma_Invoice__c>();
        Map<String, Legacy_Pro_forma_Invoice__c> reimbursableMRCToLegacyItems         = new Map<String, Legacy_Pro_forma_Invoice__c>();
        Map<String, Map<String, Legacy_Pro_forma_Invoice__c>> mrcToClientPOToInvoices = new Map<String, Map<String, Legacy_Pro_forma_Invoice__c>>();
        
        /* -------------- Begin create legacy invoices ---------------------- */
        for (String mrc : mrcToLBIs.keySet()) {
            for (Legacy_Billing_Item__c lbi : mrcToLBIs.get(mrc)) {
                
                //Do not add LBI to LPFI if the LBI 'Date Added' is after the last valid billing day
                if (null != lbi.Frequency_Formula__c && lbi.Date_Added__c > getLastValidBillingDate(lbi)) {
                    continue;
                
                }
                
                //MRS-5516: Created reimbursable LBIs should not be added to the Invoice if No Document Shredding = TRUE and No Met Data Scanning = TRUE
                if (lbi.Type__c == LEGACY_REIMBURSABLE && (lbi.No_Document_Shredding_Formula__c && lbi.Invoice_Line_Description__c == REIMBURSABLE_DOCUMENT_SHREDDING) || 
                                                          (lbi.No_Met_Data_Scanning_Formula__c && lbi.Invoice_Line_Description__c == REIMBURSABLE_DOCUMENT_SCANNING) ) {
                    continue;
                    
                }
                
                //MRS-5319: If PO Required is checked & Client PO is empty then the LBI should not be added to a Legacy Pro-forma Invoice
                if (lbi.PO_Required__c && String.isBlank(lbi.Client_PO__c)) {
                    continue;
                    
                }
                
                //If Type equals Reimbursable & Separate Reimbursables is true, system generates separate invoice.
                if (!reimbursableMRCToLegacyItems.containsKey(mrc) && lbi.Type__c == LEGACY_REIMBURSABLE && lbi.Separate_Reimbursables_Formula__c) {
                    reimbursableMRCToLegacyItems.put(mrc, LegacyProformaInvoiceServices.newInstance(lbi));
                    continue;
                    
                } else if (reimbursableMRCToLegacyItems.containsKey(mrc) && lbi.Type__c == LEGACY_REIMBURSABLE && lbi.Separate_Reimbursables_Formula__c && String.isBlank(lbi.Client_PO__c)) {
                    continue;

                }
                
                //Create Unique Invoice per MRC Number And Empty Client PO
                if (!mrcToInvoices.containsKey(lbi.MRC__c) && String.isBlank(lbi.Client_PO__c)) {
                    mrcToInvoices.put(lbi.MRC__c, LegacyProformaInvoiceServices.newInstance(lbi));
                    
                } else if (mrcToInvoices.containsKey(lbi.MRC__c) && String.isBlank(lbi.Client_PO__c)) {
                    continue;
                    
                }
                
                //Create Invoice For Unique Client PO Numbers per MRC Number
                if (!String.isBlank(lbi.Client_PO__c)) {                
                    if (!mrcToClientPOToInvoices.containsKey(mrc)) {
                        mrcToClientPOToInvoices.put(mrc, new Map<String, Legacy_Pro_forma_Invoice__c>());
                    
                    }
                    
                    if (!mrcToClientPOToInvoices.get(mrc).containsKey(lbi.Client_PO__c)) {
                        mrcToClientPOToInvoices.get(mrc).put(lbi.Client_PO__c, LegacyProformaInvoiceServices.newInstance(lbi));
                    
                    }
                    
                }
            
            }
        }
        /* -------------- End create legacy invoices ---------------------- */
        
        /* -------------- Begin insert legacy invoices ---------------------- */
        List<Legacy_Pro_forma_Invoice__c> invoicesToCreate = new List<Legacy_Pro_forma_Invoice__c>();
        invoicesToCreate.addall(mrcToInvoices.values());
        invoicesToCreate.addall(reimbursableMRCToLegacyItems.values());
        
        for (String mrc : mrcToClientPOToInvoices.keySet()) {
            invoicesToCreate.addall(mrcToClientPOToInvoices.get(mrc).values());
            
        }
        
        if (invoicesToCreate.isEmpty()) {
            return;
        
        }
        insert invoicesToCreate;
        /* -------------- End insert legacy invoices ---------------------- */

        /* -------------- Begin assign lbis to legacy invoices ---------------------- */
        //This variable is used for determine if system generates separate reimbursable invoices for different Client PO numbers.
        String clientPOForReimbusable;
        
        for (String mrc : mrcToLBIs.keySet()) {
            clientPOForReimbusable = '';
            
            for (Legacy_Billing_Item__c lbi : mrcToLBIs.get(mrc)) {
                
                //Do not add LBI to LPFI if the LBI 'Date Added' is after the last valid billing day
                if (null != lbi.Frequency_Formula__c && lbi.Date_Added__c > getLastValidBillingDate(lbi)) {
                    continue;
                
                }
                
                //MRS-5516: Created reimbursable LBIs should not be added to the Invoice if No Document Shredding = TRUE and No Met Data Scanning = TRUE
                if (lbi.Type__c == LEGACY_REIMBURSABLE && (lbi.No_Document_Shredding_Formula__c && lbi.Invoice_Line_Description__c == REIMBURSABLE_DOCUMENT_SHREDDING) || 
                                                          (lbi.No_Met_Data_Scanning_Formula__c && lbi.Invoice_Line_Description__c == REIMBURSABLE_DOCUMENT_SCANNING) ) {
                    continue;
                    
                }
                
                //MRS-5319: If PO Required is checked & Client PO is empty then the LBI should not be added to a Legacy Pro-forma Invoice
                if (lbi.PO_Required__c && String.isBlank(lbi.Client_PO__c)) {
                    continue;
                    
                }

                //If Type equals Reimbursable & Separate Reimbursables is true, system generates separate invoice.
                if (reimbursableMRCToLegacyItems.containsKey(mrc) && lbi.Type__c == LEGACY_REIMBURSABLE && lbi.Separate_Reimbursables_Formula__c && (String.isBlank(clientPOForReimbusable) || clientPOForReimbusable == lbi.Client_PO__c)) {
                    clientPOForReimbusable = lbi.Client_PO__c;
                    
                    lbi.Legacy_Pro_forma_Invoice__c = reimbursableMRCToLegacyItems.get(lbi.MRC__c).Id;
                    lbi.Billed__c                   = true;
                    continue;

                }
                
                //Assign Unique Invoice per MRC Number And Empty Client PO to LBI
                if (mrcToInvoices.containsKey(lbi.MRC__c) && String.isBlank(lbi.Client_PO__c)) {
                    lbi.Legacy_Pro_forma_Invoice__c = mrcToInvoices.get(lbi.MRC__c).Id;
                    lbi.Billed__c                   = true;
                    continue;
                    
                }
                
                //Assign Invoice For Unique Client PO Numbers per MRC Number to LBI
                if (!String.isBlank(lbi.Client_PO__c) && mrcToClientPOToInvoices.containsKey(mrc) && mrcToClientPOToInvoices.get(mrc).containsKey(lbi.Client_PO__c)) {
                    lbi.Legacy_Pro_forma_Invoice__c = mrcToClientPOToInvoices.get(mrc).get(lbi.Client_PO__c).Id;
                    lbi.Billed__c                   = true;
                    continue;
                
                }
            
            }
        }
        
        update legacyItems;
        /* -------------- End assign lbis to legacy invoices ---------------------- */
        
        //Update Aggregate Fields on Invoices
        LegacyBillingItemServices.updateAggregatedFieldsOnLegacyProformInvoice(new Map<Id, Legacy_Pro_forma_Invoice__c>(invoicesToCreate));
    
    }
    
    @testVisible
    private static Date getLastValidBillingDate(final Legacy_Billing_Item__c lbi) {
         if (ProjectProfileServices.FREQUENCY_WEEKLY == lbi.Frequency_Formula__c) {
            Integer day = DateUtils.WEEK_DAY_NUMBER_MAP.get(lbi.Billing_Day_Formula__c);
            return date.newinstance(Date.today().year(), Date.today().month(), Date.today().toStartofWeek().day() + day);
            
        } else if (ProjectProfileServices.FREQUENCY_MONTHLY == lbi.Frequency_Formula__c) {
            return date.newinstance(Date.today().year(), Date.today().month(), Integer.valueOf(lbi.Billing_Day_Formula__c)) > date.today() ? 
                   date.newinstance(Date.today().year(), Date.today().month(), Integer.valueOf(lbi.Billing_Day_Formula__c)).addMonths(-1) :
                   date.newinstance(Date.today().year(), Date.today().month(), Integer.valueOf(lbi.Billing_Day_Formula__c));
        
        } else if (ProjectProfileServices.FREQUENCY_QUARTERLY == lbi.Frequency_Formula__c) {
            if (1 <= Date.today().month() && Date.today().month() <= 3) {
                Integer monthVal;
                if ('1' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 1;
                
                } else if ('2' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 2;
                
                } else if ('3' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 3;
                
                }
                return date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c)) > date.today() ? 
                       date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c)).addMonths(-3) :
                       date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c));
                
            } else if (4 <= Date.today().month() && Date.today().month() <= 6) {
                Integer monthVal;
                if ('1' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 4;
                
                } else if ('2' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 5;
                
                } else if ('3' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 6;
                
                }
                return date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c))> date.today() ? 
                       date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c)).addMonths(-3) : 
                       date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c));
                
            } else if (7 <= Date.today().month() && Date.today().month() <= 9) {
                Integer monthVal;
                if ('1' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 7;
                
                } else if ('2' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 8;
                
                } else if ('3' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 9;
                
                }
                return date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c)) > date.today() ? 
                       date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c)).addMonths(-3) : 
                       date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c));
                
            } else if (10 <= Date.today().month() && Date.today().month() <= 12) {
                Integer monthVal;
                if ('1' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 10;
                
                } else if ('2' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 11;
                
                } else if ('3' == lbi.Quarterly_Month_Formula__c.substring(0,1)) {
                    monthVal = 12;
                
                }
                return date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c)) > date.today() ? 
                       date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c)).addMonths(-3) : 
                       date.newinstance(Date.today().year(), monthVal, Integer.valueOf(lbi.Billing_Day_Formula__c));
                
            }
                        
        }
        return Date.today();
    
    }
    
    @testVisible
    private static Map<String, List<Legacy_Billing_Item__c>> groupMrcToLgacyBillingItems(List<Legacy_Billing_Item__c> legacyItems) {
        Map<String, List<Legacy_Billing_Item__c>> mrcToLegacyBillingItems = new Map<String, List<Legacy_Billing_Item__c>>();
        
        for (Legacy_Billing_Item__c item : legacyItems) {
            if (!mrcToLegacyBillingItems.containsKey(item.MRC__c)) {
                mrcToLegacyBillingItems.put(item.MRC__c, new List<Legacy_Billing_Item__c>());
                
            }
            mrcToLegacyBillingItems.get(item.MRC__c).add(item);
        
        }
        return mrcToLegacyBillingItems;
    
    }
    
    @testVisible    
    private static Legacy_Pro_forma_Invoice__c newInstance(Legacy_Billing_Item__c legacyItem) {
        return new Legacy_Pro_forma_Invoice__c(Accounting_Contact__c         = legacyItem.Accounting_Contact__c,
                                               Accounting_Contact_Company__c = legacyItem.Accounting_Contact_Company__c,
                                               Account_Manager__c            = legacyItem.Project_Name_Mi7__r.Sales_Exec_SF__c,
                                               Billing_Client_Company__c     = legacyItem.Project_Name_Mi7__r.Billing_Client_Company__c,
                                               Billing_Contact__c            = legacyItem.Project_Name_Mi7__r.Billing_Contact_SF__c,
                                               Project_Native__c             = legacyItem.Project_Name_Mi7__c,
                                               Project_Address__c            = legacyItem.Project_Address__c,
                                               Invoice_Date__c               = date.today(),
                                               Client_PO__c                  = legacyItem.Client_PO__c);

    }
    
    public static void unbilledLegacyItemForLegacyInvoices(Map<Id, Legacy_Pro_forma_Invoice__c> invoicesMap) {
        if (null == invoicesMap || invoicesMap.isEmpty()) {
            return;
        
        }
        
        Set<Id> legacyProformaIds = new Set<Id>();
        for (Legacy_Pro_forma_Invoice__c proforma : invoicesMap.values()) {
            if (!String.isBlank(proforma.FF_Sales_Invoice__c)) {
                proforma.addError('Legacy Proforma Invoice ' + proforma.Name + ' cannot be deleted if FF Sales Invoice has been already created.');
            
            } else {
                legacyProformaIds.add(proforma.Id);
 
            }
        }
        
        List<Legacy_Billing_Item__c> billedLegacyItems = LegacyBillingItemServices.getLegacyLineItemByInvoiceIds(legacyProformaIds);
        
        for (Legacy_Billing_Item__c lineItem : billedLegacyItems) {
            lineItem.Billed__c = false;
        
        }
        update billedLegacyItems;
    
    }
    
    public static void updateSentToClientField(List<Legacy_Pro_forma_Invoice__c> invoicesList) {
        if (invoicesList.isEmpty()) {
            return;
        
        }
        
        List<Legacy_Pro_forma_Invoice__c> invoicesToUpdate = new List<Legacy_Pro_forma_Invoice__c>();
        
        for (Legacy_Pro_forma_Invoice__c invoice: invoicesList) {
            if (!invoice.Sent_To_Client__c) {
                invoice.Sent_To_Client__c = true;
                invoicesToUpdate.add(invoice);
            
            }
        
        }
        
        try {
            update invoicesToUpdate;
        
        } catch (dmlException dmlEx) {        
            for (Integer i = 0; i < dmlEx.getNumDml(); i++) {
                invoicesToUpdate[dmlEx.getDmlIndex(i)].addError('Error Occured While Updating Legacy Invoices: ' + dmlEx.getMessage());
            
            }
        
        }    
    
    }
    
    public static void updateMailroomProperties(Map<Id, Legacy_Pro_forma_Invoice__c> legacyInvoiceMap) {
        if (null == legacyInvoiceMap) {
            return;
        }
        
        Boolean isInvoiceChanged = false;
        Legacy_Pro_forma_Invoice__c legacyInvoice;
        Map<Id, Legacy_Pro_forma_Invoice__c> legacyToUpdate = new Map<Id, Legacy_Pro_forma_Invoice__c>(); 
        List<Legacy_Billing_Item__c> lbis                   = LegacyBillingItemServices.getMailroomLBIs(legacyInvoiceMap.keySet());     
        
        for (Legacy_Billing_Item__c lbi : lbis) {
            legacyInvoice = legacyInvoiceMap.get(lbi.Legacy_Pro_forma_Invoice__c);
            
            if ((FEDEX_FILTER == lbi.Legacy_Mailroom_COSTCATID_Service_Type__c || FEDEX_AIRBORNE_FILTER == lbi.Legacy_Mailroom_COSTCATID_Service_Type__c) && !legacyInvoice.Contains_Fedex_Mailroom__c) {
                legacyInvoice.Contains_Fedex_Mailroom__c = true;
                isInvoiceChanged                         = true;
            
            }
            
            if (null != lbi.Legacy_Mailroom_COSTCATID_Service_Type__c && lbi.Legacy_Mailroom_COSTCATID_Service_Type__c.startsWith(SUPREME_SYSTEMS_FILTER) && !legacyInvoice.Contains_Mess_Meilroom__c) {
                legacyInvoice.Contains_Mess_Meilroom__c = true;
                isInvoiceChanged                        = true;
            
            }
            
            if (REIMBURSABLE_DOCUMENT_SHREDDING == String.valueOf(lbi.Invoice_Line_Description__c) && !legacyInvoice.Contains_Shredding__c) {
                legacyInvoice.Contains_Shredding__c = true;
                isInvoiceChanged                    = true;
            
            }
            
            if (REIMBURSABLE_DOCUMENT_SCANNING == String.valueOf(lbi.Invoice_Line_Description__c) && !legacyInvoice.Contains_Scanning__c) {
                legacyInvoice.Contains_Scanning__c = true;
                isInvoiceChanged                   = true;
            
            }
            
            if (isInvoiceChanged) {
                isInvoiceChanged = false;
                legacyToUpdate.put(legacyInvoice.Id, legacyInvoice);
                
            }
        
        }

        if (!legacyToUpdate.isEmpty()) { 
            update legacyToUpdate.values();
        
        }
    
    }
    /* ------------------------------------- End Business Logic Methods ------------------------------------------------ */

    /* ------------------------------------- Begin DAO Methods ------------------------------------------------ */
    public static Legacy_Pro_forma_Invoice__c getLegacyProformaInvoiceById(Id invoiceId) {
        if (null == invoiceId ) {
            throw new ErrorException(ErrorException.LEGACY_ID_IS_EMPTY);
        
        }
        
        List<Legacy_Pro_forma_Invoice__c> invoices = new List<Legacy_Pro_forma_Invoice__c>([SELECT Project_Native__c, Project_Address__c, Outstanding_Amount_Today__c, Project_Name__c,
                                                                                                   Outstanding_Amount_90_Days__c, Outstanding_Amount_61_To_90_Days__c, Project_Address__r.Name,
                                                                                                   Outstanding_Amount_31_To_60_Days__c, Outstanding_Amount_1_To_30_Days__c, Invoice_Date__c,
                                                                                                   Name_without_Prefix__c, Id, Floor_s__c, Amount_Due__c, A_R_Coordinator_Phone__c, Project_Native__r.MRC__c,
                                                                                                   A_R_Coordinator_Full_Name__c, A_R_Coordinator_Email__c, Project_Native__r.Total_Due__c,
                                                                                                   Project_Number__c, Client_Project__c, Client_PO__c, Account_Manager__c, Account_Manager__r.Name,
                                                                                                   Tax__c, Subtotal__c, Credit__c, Accounting_Contact__r.Name, Sent_To_Client__c, 
                                                                                                   Accounting_Contact_Company__r.Name, Accounting_Contact_Company__c, Accounting_Contact_Address__c, 
                                                                                                   Accounting_Contact_Address_Details__c, Accounting_Contact_Address_1__c,
                                                                                                   Billing_Contact__r.Name, Billing_Contact_Detail_Address__c,
                                                                                                   cl_FF_Sales_Credit_Note_1__r.c2g__CreditNoteDate__c, cl_FF_Sales_Credit_Note_2__r.c2g__CreditNoteDate__c, 
                                                                                                   Billing_Contact_Address_1__c, Billing_Client_Company__r.Name, Subtotal_Credit1__c, Subtotal_Credit2__c,
                                                                                                   Tax_Credit1__c, Tax_Credit2__c, Total_Credits1__c, Total_Credits2__c, Billing_Client_Company__c,
                                                                                                   cl_FF_Sales_Credit_Note_1__r.Name, cl_FF_Sales_Credit_Note_2__r.Name, Display_Text_on_Invoice__c,
                                                                                                   Project_Address__r.City__c, Project_Address__r.State__c, Project_Address__r.PostalCode__c,
                                                                                                   (SELECT Invoice_Line_Description__c, Price__c, Quantity__c, Extended_Fee__c,
                                                                                                           cl_Credit_1_Amount__c, cl_Credit_2_Amount__c
                                                                                                    FROM Legacy_Billing_Items__r)
                                                                                            FROM Legacy_Pro_forma_Invoice__c
                                                                                            WHERE Id =: invoiceId]);
        
        if (invoices.isEmpty()) {
            throw new ErrorException(ErrorException.LEGACY_INVOICE_NOT_EXIST);
        
        }
        return invoices.get(0);
    
    }
    
    public static List<Legacy_Pro_forma_Invoice__c> getLegacyProformaInvoicesById(Set<Id> ids) {
        if (null == ids || ids.isEmpty()) {
            return new List<Legacy_Pro_forma_Invoice__c>();
            
        }
        
        return new List<Legacy_Pro_forma_Invoice__c>([SELECT cl_Create_FFA_Credit_Note_2__c, cl_Create_FFA_Credit_Note_1__c, Project_Native__c, Id, 
                                                             FF_Sales_Invoice__c, FFA_Invoice_Created__c, Create_FFA_Invoice__c, Billing_Contact__c,
                                                             Subtotal__c, Tax__c, Accounting_Contact__c, Name, Sent_To_Client__c, Total_Commissionable_Amount__c,
                                                             Contains_Fedex_Mailroom__c, Contains_Mess_Meilroom__c, Contains_Shredding__c, Contains_Scanning__c,
                                                             (SELECT Id, cl_Credit_1_Amount__c, cl_Credit_2_Amount__c FROM Legacy_Billing_Items__r)
                                                      FROM Legacy_Pro_forma_Invoice__c 
                                                      WHERE Id IN: ids]);
    
    }
    /* ------------------------------------- Begin DAO Methods ------------------------------------------------ */

}