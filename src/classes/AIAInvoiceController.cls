public with sharing class AIAInvoiceController {
    public Boolean isValid { get; private set; }
    public AIAInvoiceWrapper content { get; private set; }

    public AIAInvoiceController() {
        isValid = true;
        String parentId = ApexPages.currentPage().getParameters().get('p');
        if( parentId == null || !(parentId instanceOf Id) ) {
            MilroseDevHelper.addMessage('Invalid parameters have been passed.');
            isValid = false;
            return;
        }
        List<Pro_Forma_Invoice__c> pfis = [ SELECT Project_Profile__c, Billing_Client_Company__r.Name, CreatedDate, Name_without_Prefix__c,
                                                   Billing_Contact__r.MailingStreet, Project_Name__c, Client_Project__c,
                                                   Billing_Contact__r.MailingCity, Billing_Contact__r.MailingState, Billing_Contact__r.MailingPostalCode
                                            FROM Pro_Forma_Invoice__c
                                            WHERE Id = : parentId ];
        if( pfis.isEmpty() || String.isBlank( pfis[0].Project_Profile__c ) ) {
            isValid = false;
            if( pfis.isEmpty() ) {
                MilroseDevHelper.addMessage( 'No Pro-Forma Invoice was found.' );
            } else {
                MilroseDevHelper.addMessage( 'No related Project Profile was found.' );
            }
            return;
        }
        List<Project_Profile__c> projects = [ SELECT Total_Service_Amount__c, Proposal__r.Sales_Tax__c, Project_Name__c,
                                                     Client_Project__c, Proposal_Awarded_Date__c, Proposal__c,
                                                     Billing_Method__c, Interval__c, Number_Of_Intervals__c, Frequency__c,
                                                     ( SELECT Id
                                                       FROM Pro_forma_Invoices__r
                                                       WHERE CreatedDate < : pfis[0].CreatedDate OR
                                                             ( CreatedDate = : pfis[0].CreatedDate AND
                                                               Id < : pfis[0].Id ) ),
                                                     ( SELECT Services_Total__c, Discount_Percentage__c, Approved_Date__c /* MRS 6976 */
                                                       FROM Change_Orders__r
                                                       WHERE Status__c = : ChangeOrderServices.STATUS_APPROVED ),
                                                     ( SELECT Quantity_Old__c, Discounted_Unit_Price__c,
                                                              Tax_Percent_1__c, Tax_Percent_2__c,
                                                              Total_Service_Price__c, Sales_Tax_Amount__c
                                                       FROM Service_Items__r
                                                       WHERE Original__c = true )
                                              FROM Project_Profile__c
                                              WHERE Id = : pfis[0].Project_Profile__c ];
        if( projects.isEmpty() ) {
            isValid = false;
            MilroseDevHelper.addMessage( 'The related Project Profile can not be retrieved.' );
            return;
        }
        content = new AIAInvoiceWrapper( projects[0], pfis[0] );
    }

    public class AIAInvoiceWrapper {
        public List<AIAInvoiceLineItemWrapper> lines { get { if( lines == null ) lines = new List<AIAInvoiceLineItemWrapper>(); return lines; } private set; }
        public Pro_Forma_Invoice__c pfi { get { if( pfi == null ) pfi = new Pro_Forma_Invoice__c(); return pfi; } private set; }
        public Project_Profile__c project { get { if( project == null ) project = new Project_Profile__c(); return project; } private set; }
        public String billingCompany { get { if( String.isBlank( billingCompany ) ) billingCompany = ''; return billingCompany; } private set; }
        public String billingContactAddr1 { get { if( String.isBlank( billingContactAddr1 ) ) billingContactAddr1 = ''; return billingContactAddr1; } private set; }
        public String billingContactAddr2 { get { if( String.isBlank( billingContactAddr2 ) ) billingContactAddr2 = ''; return billingContactAddr2; } private set; }
        public String prevInvoicesNo { get { if( String.isBlank( prevInvoicesNo ) ) prevInvoicesNo = '1'; return prevInvoicesNo; } private set; }
        public String projectName { get { if( String.isBlank( projectName ) ) projectName = ''; return projectName; } private set; }
        public String clientProject { get { if( String.isBlank( clientProject ) ) clientProject = ''; return clientProject; } private set; }
        public Date invoiceDate { get { if( invoiceDate == null ) invoiceDate = Date.today(); return invoiceDate; } private set; }
        public Date proposalDate { get { if( proposalDate == null ) proposalDate = Date.today(); return proposalDate; } private set; }

        public Decimal proposalStartFees { get { if( proposalStartFees == null ) proposalStartFees = 0.00; return proposalStartFees; } private set; }
        public Decimal approvedChOrdFees { get { if( approvedChOrdFees == null ) approvedChOrdFees = 0.00; return approvedChOrdFees; } private set; }
        public Decimal proposalEndFees { get { if( proposalEndFees == null ) proposalEndFees = 0.00; return proposalEndFees; } private set; }
        public Decimal balanceToFinishFirstPage { get { return proposalEndFees - totalCompleted; } }

        public Decimal serviceAmount { get { if( serviceAmount == null ) serviceAmount = 0.00; return serviceAmount; } private set; }
        public Decimal priorBilling { get { if( priorBilling == null ) priorBilling = 0.00; return priorBilling; } private set; }
        public Decimal currentBilling { get { if( currentBilling == null ) currentBilling = 0.00; return currentBilling; } private set; }
        public Decimal totalCompleted { get { if( totalCompleted == null ) totalCompleted = 0.00; return totalCompleted; } private set; }
        public Decimal percentage { get { return serviceAmount != 0 ? (100 * totalCompleted / serviceAmount).setScale(2) : 0.00; } }
        public Decimal balanceToFinish { get { if( balanceToFinish == null ) balanceToFinish = 0.00; return balanceToFinish; } private set; }

        public AIAInvoiceWrapper( Project_Profile__c project, Pro_Forma_Invoice__c pfi ) {
            this.pfi = pfi;
            this.project = project;
            init();
        }

        private void init() {
            billingCompany = pfi.Billing_Client_Company__r.Name;
            billingContactAddr1 = pfi.Billing_Contact__r.MailingStreet;
            billingContactAddr2 = ( !String.isEmpty(pfi.Billing_Contact__r.MailingCity) ? pfi.Billing_Contact__r.MailingCity : '' ) +
                                  ( !String.isEmpty(pfi.Billing_Contact__r.MailingCity) && ( !String.isEmpty(pfi.Billing_Contact__r.MailingState) || !String.isEmpty(pfi.Billing_Contact__r.MailingPostalCode) ) ? ', ' : '') +
                                  ( !String.isEmpty(pfi.Billing_Contact__r.MailingState) ? pfi.Billing_Contact__r.MailingState : '' ) +
                                  ( !String.isEmpty(pfi.Billing_Contact__r.MailingState) && !String.isEmpty(pfi.Billing_Contact__r.MailingPostalCode) ? ' ' : '' ) +
                                  ( !String.isEmpty(pfi.Billing_Contact__r.MailingPostalCode) ? pfi.Billing_Contact__r.MailingPostalCode : '' );
            projectName = pfi.Project_Name__c;
            clientProject = pfi.Client_Project__c;
            invoiceDate = Date.newInstance( pfi.CreatedDate.year(), pfi.CreatedDate.month(), pfi.CreatedDate.day() );
            prevInvoicesNo = String.valueOf( project.Pro_forma_Invoices__r.size() + 1 );
            proposalDate = project.Proposal_Awarded_Date__c;

            for( Service_Item__c si : project.Service_Items__r ) {
                if( si.Quantity_Old__c == null || si.Quantity_Old__c == 0 ) {
                    proposalStartFees += si.Total_Service_Price__c + si.Sales_Tax_Amount__c;
                } else {
                    proposalStartFees += si.Discounted_Unit_Price__c * si.Quantity_Old__c * ( 1 + ( si.Tax_Percent_1__c != null ? si.Tax_Percent_1__c : 0 ) + ( si.Tax_Percent_2__c != null ? si.Tax_Percent_2__c : 0 ) ) ;
                }
            }

            //MRS-6976
            Set<Id> changeOrders = new Set<Id>();
            Map<Id, Change_Order__c> idToChangeOrderMap = new Map<Id, Change_Order__c>();

            for( Change_Order__c co : project.Change_Orders__r ) {
                approvedChOrdFees += co.Services_Total__c;
                changeOrders.add(co.Id);
                idToChangeOrderMap.put(co.Id, co);
            }

            //hourly services (Quantity > 1) don't have taxes
            List<Service_Item__c> serviceItemsList = [ SELECT Tax_Percent_1__c, Tax_Percent_2__c, Unit_Price__c, Change_Order__c, Is_Amendmend_Deleted__c, Discount_Percentage__c
                                                       FROM Service_Item__c
                                                       WHERE Change_Order__c IN : changeOrders ];
            for( Service_Item__c serviceItem : serviceItemsList ) {
                if( serviceItem.Unit_Price__c != null ) {
                    Decimal totalSalesTaxAmount = 0;
                    Decimal totalTaxAmount = serviceItem.Unit_Price__c * ( (serviceItem.Tax_Percent_1__c != null ? serviceItem.Tax_Percent_1__c : 0) + (serviceItem.Tax_Percent_2__c != null ? serviceItem.Tax_Percent_2__c : 0) ) / 100;
                    if( serviceItem.Is_Amendmend_Deleted__c == true && idToChangeOrderMap.get(serviceItem.Change_Order__c).Approved_Date__c != null ) {
                        totalTaxAmount *= -1;
                    }
                    totalSalesTaxAmount += totalTaxAmount;
                    if( serviceItem.Discount_Percentage__c != null ) {
                        totalSalesTaxAmount *= 1 - serviceItem.Discount_Percentage__c / 100;
                    }
                    approvedChOrdFees += totalSalesTaxAmount;
                }
            }

            proposalEndFees = proposalStartFees + approvedChOrdFees; // MRS-6973
            if( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ) {
                for( Service_Item__c si : [ SELECT Service_Name_Full__c, Total_Discounted_Price_Tax__c, Original__c, Change_Order__c,
                                                   Is_Amendmend_Deleted__c, Change_Order__r.Status__c,
                                                   Quantity_Old__c, Discounted_Unit_Price__c, Tax_Percent_1__c, Tax_Percent_2__c,
                                                   ( SELECT Pro_Forma_Invoice__c, Amount_Billed__c
                                                     FROM Billing_Line_Items_del__r
                                                     WHERE isReimbursable__c = false
                                                       AND Pro_Forma_Invoice__c != null
                                                       AND Pro_Forma_Invoice__r.CreatedDate <= : pfi.CreatedDate
                                                       AND Department_Based__c = false )
                                            FROM Service_Item__c
                                            WHERE Project_Profile__c = : project.Id
                                            ORDER BY Change_Order__c NULLS FIRST, Row_Position__c ] ) {
                    Boolean doAddItem = doAddItem( si,
                                                   si.Original__c,
                                                   si.Is_Amendmend_Deleted__c,
                                                   si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED,
                                                   si.Quantity_Old__c != null && si.Quantity_Old__c != 0 );
                    if( doAddItem != null ) {
                        lines.add( new AIAInvoiceLineItemWrapper( si, doAddItem, pfi.Id, project ) );
                    }
                }
            } else {
                for( Service_Item__c si : [ SELECT Service_Name_Full__c, Total_Discounted_Price_Tax__c, Original__c, Change_Order__c,
                                                   Is_Amendmend_Deleted__c, Change_Order__r.Status__c,
                                                   Quantity_Old__c, Discounted_Unit_Price__c, Tax_Percent_1__c, Tax_Percent_2__c
                                            FROM Service_Item__c
                                            WHERE Project_Profile__c = : project.Id
                                            ORDER BY Change_Order__c NULLS FIRST, Row_Position__c ] ) {
                    Boolean doAddItem = doAddItem( null,
                                                   si.Original__c,
                                                   si.Is_Amendmend_Deleted__c,
                                                   si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED,
                                                   si.Quantity_Old__c != null && si.Quantity_Old__c != 0 );
                    if( doAddItem != null ) {
                        lines.add( new AIAInvoiceLineItemWrapper( si, doAddItem, pfi.Id, project ) );
                    }
                }
                for( Pro_Forma_Invoice__c pfiItem : [ SELECT Id,
                                                        ( SELECT Pro_Forma_Invoice__c, Amount_Billed__c,
                                                                 Billing_Date_Step_Number__c
                                                          FROM Billing_Line_Items__r
                                                          WHERE isReimbursable__c = false
                                                            AND Pro_Forma_Invoice__c != null
                                                            AND Department_Based__c = false
                                                          ORDER BY Billing_Date_Step_Number__c )
                                                      FROM Pro_Forma_Invoice__c
                                                      WHERE Project_Profile__c = : project.Id
                                                      AND CreatedDate <= : pfi.CreatedDate
                                                      ORDER BY CreatedDate ] ) {
                    for( Billing_Line_Item__c bli : pfiItem.Billing_Line_Items__r ) {
                        lines.add( new AIAInvoiceLineItemWrapper( bli, pfi.Id, project ) );
                    }
                }
            }

            //calculate reimbursable amounts
            List<Pro_Forma_Invoice__c> pfiReimb = [ SELECT Id,
                                                      ( SELECT Pro_Forma_Invoice__c, Amount_Billed__c
                                                        FROM Billing_Line_Items__r
                                                        WHERE isReimbursable__c = true
                                                          AND Pro_Forma_Invoice__c != null )
                                                    FROM Pro_Forma_Invoice__c
                                                    WHERE Project_Profile__c = : project.Id
                                                      AND CreatedDate <= : pfi.CreatedDate
                                                    ORDER BY CreatedDate ];
            Decimal additionalReimbursables = 0.0;
            for( AggregateResult aggResult : [ SELECT Change_Order__c co, SUM(Amount__c) am FROM Additional_Reimbursable__c
                                               WHERE Proposal__c =: project.Proposal__c
                                                 AND ( Change_Order__c = null OR ( Change_Order__c != null AND Change_Order__r.Approved_Date__c != null ) )
                                               /*AND CreatedDate <= : pfi.CreatedDate*/
                                               GROUP BY Change_Order__c ] ) {
                if( aggResult.get('am') != null ) {
                    Decimal reimbAmount = (Decimal)aggResult.get('am');
                    additionalReimbursables += reimbAmount;
                    if( (Id)aggResult.get('co') == null ) {
                        proposalStartFees += reimbAmount;
                    } else {
                        approvedChOrdFees += reimbAmount;
                    }
                    proposalEndFees += reimbAmount;
                }
            }

            ChangeOrderController changeOrderController = new ChangeOrderController( project.Proposal__c ); //MRS-6319
            proposalStartFees += changeOrderController.originalContent.reimbursableApproved; //line 1 should include reimbursables amounts of Proposal
            if( changeOrderController.changeOrderContent != null ) {
                approvedChOrdFees += changeOrderController.changeOrderContent.reimbursableApproved; //line 2 should include reimbursables amounts of approved COs
            }
            proposalEndFees += changeOrderController.reimbursableApproved;
            AIAInvoiceLineItemWrapper reimbLine = new AIAInvoiceLineItemWrapper( pfiReimb, pfi.Id, project, changeOrderController.reimbursableApproved, additionalReimbursables );
            //if( reimbLine.currentBilling + reimbLine.priorBilling != 0 ) { //display even if 0
                lines.add( reimbLine );
            //}

            for( AIAInvoiceLineItemWrapper line : lines ) {
                serviceAmount += line.serviceAmount;
                priorBilling += line.priorBilling;
                currentBilling += line.currentBilling;
                totalCompleted += line.totalCompleted;
                balanceToFinish += line.balanceToFinish;
            }

            if( project.Billing_Method__c != ProjectProfileServices.BILLINGMETHODMILESTONE ) {
                balanceToFinish = serviceAmount - totalCompleted;
            }
        }

        private Boolean doAddItem( Service_Item__c si, Boolean isOriginal, Boolean isDeleted, Boolean isApprovedCO, Boolean isQuantityCO ) {
            //true = add Item and use new Quentity
            //false = add Item and use old Quantity
            //null = do not add Item
            if( isOriginal ) {
                if( isDeleted ) {
                    if( !isApprovedCO ) {
                        if( !isQuantityCO ) {
                            return true;
                        }
                    } else {
                        if( !isQuantityCO ) {
                            if( si != null && !si.Billing_Line_Items_del__r.isEmpty() ) {
                                return true;
                            }
                        }
                    }
                } else {
                    if( isApprovedCO ) {
                        if( isQuantityCO ) {
                            return true;
                        }
                    } else {
                        if( isQuantityCO ) {
                            return false;
                        } else {
                            return true;
                        }
                    }
                }
            } else {
                if( isDeleted ) {
                    if( !isApprovedCO ) {
                        if( !isQuantityCO ) {
                            return true;
                        }
                    } else {
                        if( !isQuantityCO ) {
                            if( si != null && !si.Billing_Line_Items_del__r.isEmpty() ) {
                                return true;
                            }
                        }
                    }
                } else {
                    if( isApprovedCO ) {
                        return true;
                    } else {
                        if( isQuantityCO ) {
                            return false;
                        }
                    }
                }
            }
            return null;
        }
    }

    public class AIAInvoiceLineItemWrapper {
        public String serviceName { get { if( String.isEmpty( serviceName ) ) serviceName = ''; return serviceName; } private set; }
        public Decimal serviceAmount { get { if( serviceAmount == null ) serviceAmount = 0.00; return serviceAmount; } private set; }
        public Decimal priorBilling { get { if( priorBilling == null ) priorBilling = 0.00; return priorBilling; } private set; }
        public Decimal currentBilling { get { if( currentBilling == null ) currentBilling = 0.00; return currentBilling; } private set; }
        public Decimal totalCompleted { get { return priorBilling + currentBilling; } }
        public Decimal percentage { get { return serviceAmount != 0 ? (100 * totalCompleted / serviceAmount).setScale(2) : 0.00; } }
        public Decimal balanceToFinish { get { return serviceAmount - totalCompleted; } }

        public Boolean showServiceAmount { get { if( showServiceAmount == null ) showServiceAmount = true; return showServiceAmount; } private set; }
        public Boolean showPriorBilling { get { if( showPriorBilling == null ) showPriorBilling = true; return showPriorBilling; } private set; }
        public Boolean showCurrentBilling { get { if( showCurrentBilling == null ) showCurrentBilling = true; return showCurrentBilling; } private set; }
        public Boolean showTotalCompleted { get { if( showTotalCompleted == null ) showTotalCompleted = true; return showTotalCompleted; } private set; }
        public Boolean showPercentage { get { if( showPercentage == null ) showPercentage = true; return showPercentage; } private set; }
        public Boolean showBalanceToFinish { get { if( showBalanceToFinish == null ) showBalanceToFinish = true; return showBalanceToFinish; } private set; }

        public AIAInvoiceLineItemWrapper( Service_Item__c si, Boolean useNewQuantity, Id invoiceId, Project_Profile__c project ) {
            serviceName = si.Service_Name_Full__c;
            Integer multiplier = 1;
            if( si.Is_Amendmend_Deleted__c /*&& si.Change_Order__r.Status__c != ChangeOrderServices.STATUS_APPROVED*/ ) {
                multiplier = -1;
            }

            if( useNewQuantity ) {
                serviceAmount = si.Total_Discounted_Price_Tax__c * multiplier;
            } else {
                serviceAmount = si.Discounted_Unit_Price__c * si.Quantity_Old__c * ( 1 + ( si.Tax_Percent_1__c != null ? si.Tax_Percent_1__c : 0 ) + ( si.Tax_Percent_2__c != null ? si.Tax_Percent_2__c : 0 ) ) * multiplier;
            }

            if( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ) {
                if( si.Is_Amendmend_Deleted__c &&
                    si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED &&
                    ( si.Quantity_Old__c == null || si.Quantity_Old__c == 0 ) &&
                    !si.Billing_Line_Items_del__r.isEmpty() ) {
                    serviceAmount = 0.00; //Deleted by CO Service which has already created BLIs should be displayed with 0 Scheduled value and other values calculated as usual
                }
                for( Billing_Line_Item__c bli : si.Billing_Line_Items_del__r ) {
                    if( bli.Pro_Forma_Invoice__c == invoiceId ) {
                        currentBilling += bli.Amount_Billed__c;
                    } else {
                        priorBilling += bli.Amount_Billed__c;
                    }
                }
            } else {
                showPriorBilling = false;
                showCurrentBilling = false;
                showTotalCompleted = false;
                showPercentage = false;
                showBalanceToFinish = false;
            }
            if( serviceAmount == 0.00 ) {
                showPercentage = false;
            }
        }

        public AIAInvoiceLineItemWrapper( Billing_Line_Item__c bli, Id invoiceId, Project_Profile__c project ) {
            if( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) {
                serviceName = project.Frequency__c +
                              ' Installment Billing (' +
                              String.valueOf( bli.Billing_Date_Step_Number__c ) +
                              ' of ' +
                              project.Number_Of_Intervals__c +
                              ')';
            } else if( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE ) {
                serviceName = 'Percentage Billing';
            }
            if( bli.Pro_Forma_Invoice__c == invoiceId ) {
                currentBilling += bli.Amount_Billed__c;
            } else {
                priorBilling += bli.Amount_Billed__c;
            }
            if( project.Billing_Method__c != ProjectProfileServices.BILLINGMETHODMILESTONE ) {
                showServiceAmount = false;
                showPercentage = false;
                showBalanceToFinish = false;
            } else {
                serviceAmount = bli.Amount_Billed__c;
            }
        }

        public AIAInvoiceLineItemWrapper( List<Pro_Forma_Invoice__c> pfis, Id invoiceId, Project_Profile__c project, Decimal reimbApproved, Decimal additionalReimbursables ) {
            ChangeOrderController changeOrderController = new ChangeOrderController( project.Proposal__c ); //MRS-6319
            Decimal baseReimbursables = reimbApproved; //MRS-6319, MRS-6542

            serviceName = 'Reimbursable Billing';
            for( Pro_Forma_Invoice__c pfi : pfis ) {
                for( Billing_Line_Item__c bli : pfi.Billing_Line_Items__r ) {
                    if( bli.Pro_Forma_Invoice__c == invoiceId ) {
                        currentBilling += bli.Amount_Billed__c;
                    } else {
                        priorBilling += bli.Amount_Billed__c;
                    }
                }
            }

            serviceAmount = baseReimbursables + additionalReimbursables; // MRS-6974

            //currentBilling += additionalReimbursables; //MRS-6319
            if( project.Billing_Method__c != ProjectProfileServices.BILLINGMETHODMILESTONE ) {
                showPercentage = false;
                showBalanceToFinish = false;
            }
        }
    }

}