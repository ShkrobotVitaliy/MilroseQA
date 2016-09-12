public class PurchaseInvoiceServices {
    public final static String CREATE_BLI_JOB_NAME                 = 'Create BLI Job';
    public final static String CREATE_LEGACY_BILLING_ITEM_JOB_NAME = 'Create Legacy Billing Item';
    public final static String INVOICE_STATUS_COMPLETE             = 'Complete';
    
    /* ------------------------ Begin Create Payable Invoice By Click Link From Request Filling Fee  --------------------------------------- */
    public static List<c2g__codaPurchaseInvoice__c> filterPurchaseInvoiceForBLI(List<c2g__codaPurchaseInvoice__c> newInvoice, Map<Id, c2g__codaPurchaseInvoice__c> oldInvoiceMap) {
        List<c2g__codaPurchaseInvoice__c> filteredInvocies = new List<c2g__codaPurchaseInvoice__c>();
        
        for (c2g__codaPurchaseInvoice__c invoice : newInvoice) {
            if (!invoice.BLI_Created__c && invoice.Create_BLI__c && invoice.c2g__InvoiceStatus__c.equals(INVOICE_STATUS_COMPLETE) && !oldInvoiceMap.get(invoice.Id).c2g__InvoiceStatus__c.equals(INVOICE_STATUS_COMPLETE)) { //
                filteredInvocies.add(invoice);
            
            }
        
        }
        return filteredInvocies;
    
    }
    
    public static void runBLIClickRule(List<c2g__codaPurchaseInvoice__c> invoices) {
        if (!invoices.isEmpty() && !system.isScheduled() && !system.isBatch()) {
            Database.executeBatch(new ClickLinkBatch(CREATE_BLI_JOB_NAME), 1);
            
        }
    
    }
    
    /* ------------------------ End Create Payable Invoice By Click Link From Request Filling Fee  --------------------------------------- */
    
    /* ------------------------ Begin Create Legacy Billing By Click Link From Payable Invoice  --------------------------------------- */

    public static List<c2g__codaPurchaseInvoice__c> filterPurchaseInvoiceForLegacyBillingItem(List<c2g__codaPurchaseInvoice__c> invoices) {
        List<c2g__codaPurchaseInvoice__c> invoicesForCreateLegacyBillingItems = new List<c2g__codaPurchaseInvoice__c>();
        
        for (c2g__codaPurchaseInvoice__c invoice : invoices) {
            if (!String.isBlank(invoice.MRC__c) && !invoice.Created_by_ClickLink__c && invoice.Create_Legacy_BLI__c && !invoice.Legacy_BLI_Created__c && invoice.c2g__InvoiceStatus__c.equals(INVOICE_STATUS_COMPLETE)) { 
                invoicesForCreateLegacyBillingItems.add(invoice);
            
            }
        
        }
        return invoicesForCreateLegacyBillingItems;
    
    }
    
    public static void runLegacyBillingItemClickRule(List<c2g__codaPurchaseInvoice__c> invoices) {
        if (!invoices.isEmpty() && !system.isScheduled() && !system.isBatch()) {
            Database.executeBatch(new ClickLinkBatch(CREATE_LEGACY_BILLING_ITEM_JOB_NAME), 1);
            
        }
    
    }
    
    public static void setProjectMi7IdsForPayableInvoices(List<c2g__codaPurchaseInvoice__c> payableInvoices) {
        Set<String> mrc = new Set<String>();
        
        for (c2g__codaPurchaseInvoice__c payableInvoice : payableInvoices) {
            if (!String.isBlank(payableInvoice.MRC__c) && !payableInvoice.Created_by_ClickLink__c) {
                mrc.add(payableInvoice.MRC__c);
            
            } else {
                payableInvoice.Project_Native__c    = null;
                payableInvoice.Create_Legacy_BLI__c = false;
            
            }
            
        }
        mrc.remove(null);
        
        Map<String, Project__c> mrcToProject = LegacyBillingItemServices.getMRCNumberToProjectNameMi7ByMrc(mrc);
        
        for (c2g__codaPurchaseInvoice__c payableInvoice : payableInvoices) {
            //Checking if Payable Invoice Create Manually
            if (!payableInvoice.Created_by_ClickLink__c && !String.isBlank(payableInvoice.MRC__c)) {
                if (mrcToProject.containsKey(payableInvoice.MRC__c)) {
                    payableInvoice.Project_Native__c    = mrcToProject.get(payableInvoice.MRC__c).Id;
                    payableInvoice.Create_Legacy_BLI__c = true;
                    
                } else {
                    payableInvoice.addError(ErrorException.MRC_NUMBER_NOT_EXIST);
                
                }
            
            }
        
        }
        
    }
    
    public static List<c2g__codaPurchaseInvoice__c> filterPurchaseInvoiceForSetMi7Projects(List<c2g__codaPurchaseInvoice__c> newInvoice, Map<Id, c2g__codaPurchaseInvoice__c> oldInvoiceMap) {
        List<c2g__codaPurchaseInvoice__c> filteredInvocies = new List<c2g__codaPurchaseInvoice__c>();
        
        for (c2g__codaPurchaseInvoice__c invoice : newInvoice) {
            if (invoice.MRC__c != oldInvoiceMap.get(invoice.Id).MRC__c) {
                filteredInvocies.add(invoice);
            
            }
        
        }
        return filteredInvocies;
    
    }
    
    public static void updatePurchaseInvoiceDimensions( Map<Id, c2g__codaPurchaseInvoiceExpenseLineItem__c> invoiceIdToLineItem) {
        if (null == invoiceIdToLineItem || invoiceIdToLineItem.isEmpty()) {
            return;
        
        }
        
        List<c2g__codaPurchaseInvoice__c> invoices = PurchaseInvoiceServices.getPurchaseInvoicesByIds(invoiceIdToLineItem.keySet());
        
        for (c2g__codaPurchaseInvoice__c invoice : invoices) {
            invoice.c2g__Dimension1__c = invoiceIdToLineItem.get(invoice.Id).c2g__Dimension1__c;
            invoice.c2g__Dimension2__c = invoiceIdToLineItem.get(invoice.Id).c2g__Dimension2__c;
        
        }
        
        update invoices;
    
    }
    
    public static Map<Id, c2g__codaPurchaseInvoiceExpenseLineItem__c> getPurchaseInvoiceIdToPurchaseLineItem(List<c2g__codaPurchaseInvoiceExpenseLineItem__c> newList) {
        Map<Id, c2g__codaPurchaseInvoiceExpenseLineItem__c> invoiceIdToLineItem = new Map<Id, c2g__codaPurchaseInvoiceExpenseLineItem__c>();
        
        for (c2g__codaPurchaseInvoiceExpenseLineItem__c invoiceLineItem : newList) {
            invoiceIdToLineItem.put(invoiceLineItem.c2g__PurchaseInvoice__c, invoiceLineItem);
        
        }
        return invoiceIdToLineItem;
    
    }
    /* ------------------------ End Create Legacy Billing By Click Link From Payable Invoice  --------------------------------------- */
    
    /* --------------------------------------------- Begin DAO Methods  --------------------------------------- */
    public static List<c2g__codaPurchaseInvoice__c> getPurchaseInvoicesByIds(Set<Id> invoiceIds) {
        if (null == invoiceIds || invoiceIds.isEmpty()) {
            return new List<c2g__codaPurchaseInvoice__c>();
        
        }
        return new List<c2g__codaPurchaseInvoice__c>([SELECT c2g__Dimension1__c, c2g__Dimension2__c, Id 
                                                      FROM c2g__codaPurchaseInvoice__c
                                                      WHERE id IN: invoiceIds]);
    
    }
    /* --------------------------------------------- End DAO Methods --------------------------------------- */    

}