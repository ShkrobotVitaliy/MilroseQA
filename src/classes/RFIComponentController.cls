public class RFIComponentController{
    public String noteRequieredNBandAlt1 {
        get {
            return 'Section required for NB and Alt1 enlargements only';
        }
    }

    public String notRequiredPermission {
        get {
            return 'Not required to obtain permit; required at time of sign off';
        }
    }
    public String notRequiredPermissionSignOff {
        get {
            return 'Not required at time of sign off';
        }
    }

    public String PW3Hyperlink {
        get {
            return 'http://www.nyc.gov/html/dob/downloads/pdf/pw3.pdf';
        }
    }

    public String TR1Hyperlink {
        get {
            return Label.TR1Link;
        }
    }

    public String TR8Hyperlink {
        get {
            return Label.TR8Link;
        }
    }

    public String SchBHyperlink {
        get {
            return 'http://www.nyc.gov/html/dob/downloads/pdf/pw1b.pdf';
        }
    }

    public String TCSPHyperlink {
        get {
            return 'http://www.nyc.gov/html/dob/downloads/bldgs_bulletins/bb_2012-009.pdf';
        }
    }

    private String rfiScopeRecordId;

    public void setRfiScopeRecordId(String s) {
        rfiScopeRecordId = s;
        initVariables();

    }

    public String getRfiScopeRecordId() {
        return rfiScopeRecordId;

    }

    private void initVariables() {
        PageReference initDocUploadPageReference = docUploadPageReference;

    }

    public RFI_Scope__c rfiScopeRecord {
        get{
        	// TODO remove when the following issue be fixed - https://success.salesforce.com/issues_view?id=a1p30000000T3CeAAK
        	preventIE11EmptyTextareas();

            return RFISingletonInstance.INSTANCE.rfiScope;
            /*List<RFI_Scope__c> rfiScope = new List<RFI_Scope__c>([SELECT Id, Project__c, Region__c, Region__r.Id, RFI_Section__c, Selected__c, Status__c, Project_Roster__r.Contact__c,
                                                                    Documents__c, Drawings__c, Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c,
                                                                    Recipient_Reminder_DateTime__c, Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c,
                                                                    Project_Roster_Role__c, Roster_to_CC__c, Project_Roster_to_CC__c, Notes__c, Name, Last_RFI_Sent__c, Last_RFI_Received__c,
                                                                    Project_Level_RFI__c, Service_Item_Level_RFI_Scope__r.Work_Type__c, Submit_Sign_Off__c, Submit_Application__c,
                                                                    Is_Sigh_Off_N_A__c, Is_Application_N_A__c, Sign_Off_Service_Item__c, Application_Service_Item__c, Group_Number__c,
                                                                    Application_Work_Permit_Service_Item__c, Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c,
                                                                    Sign_Off_Service_Item__r.Name_Short__c, Sign_Off_Service_Item__r.Service_Name_Full__c, Sign_Off_Service_Item__r.Name,
                                                                    Application_Work_Permit_Service_Item__r.Name_Short__c, Application_Work_Permit_Service_Item__r.Service_Name_Full__c,
                                                                    Application_Work_Permit_Service_Item__r.Name, Application_Service_Item__r.Name_Short__c, Application_Service_Item__r.Service_Name_Full__c,
                                                                    Application_Service_Item__r.Name, Sign_Off_Service_Item__r.Work_Type__c, Application_Work_Permit_Service_Item__r.Work_Type__c, Application_Service_Item__r.Work_Type__c,
                                                                         (SELECT Name, Actual_Costs__c, Application_Service_Item__c, Estimated_Cost__c, RFI_Scope__c, Sign_Off_Service_Item__c, Filing_Fee__c FROM RFI_Work_Types__r),
                                                                         (SELECT Name, Send_Via__c, Sent__c, Received__c, Sent_to__c, RFI_Scope__c, Submit_Type__c, Is_Lock__c FROM Monitor_RFI_Scopes__r ORDER BY Sent__c DESC),

                                                                    RFI_Scope_Description_Long_Island__r.Owner_Entity_Name_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Authorized_Signatory_Information_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Owner_Contact_Name_Information_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Previous_Tenant_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_copy_of_most_recent_Survey_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_copy_of_most_recent_Tax_Bill_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_copy_recent_Certif_Occupancy_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tenant_Contact_Information_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Primary_Contact_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Contractor_Contact_Information_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Contractor_Contact_Information_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Construction_Estimated_Start_Date_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Construction_Estimated_Start_Date_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Construction_End_Date_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Construction_End_Date_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.AHV_Description_Of_Work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.AHV_Dates_Desired_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Billing_client_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.DOT_Contractor_Signing_Sealing_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.DOT_Description_Of_Work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Duration_for_permit_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Street_to_be_affected_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.AHV_Contractor_Signing_Sealing_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Primary_Contact_Project_Manager_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Construction_Start_Date_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Contractor_Signing_DOB_Reg_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Primary_Contact_Project_Manager_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Application_Permit_s_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Signing_Sealing_License_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Signing_Sealing_License_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Project_Manager_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Project_Manager_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Square_Footage_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Square_Footage_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_mechanical_work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_mechanical_work_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Electrician_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Electrician_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.X3rd_Party_Inspector_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.X3rd_Party_Inspector_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_work_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Plumbing_fixture_components_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Plumbing_fixture_components_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Remove_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Remove_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Replace_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Replace_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Relocate_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Relocate_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Install_New_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Install_New_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Sprinkler_Installer_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Sprinkler_Installer_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Heads_Removed_Relocated_Installed_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Heads_Removed_Relocated_Installed_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_Special_Progress_Inspections_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_Special_Progress_Inspections_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Fire_Alarm_Vendor_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Fire_Alarm_Vendor_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Devices_Removed_Relocated_Installed_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Devices_Removed_Relocated_Installed_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_list_of_Inspections_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_list_of_Inspections_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Concrete_Work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Concrete_Work_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_structural_work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_structural_work_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_foundation_work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_foundation_work_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_support_excavation_work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_support_excavation_work_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_1_1_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_1_2_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_1_3_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_1_4_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_2_1_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_2_2_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_2_3_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_2_4_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_3_1_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_3_2_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_3_3_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_3_4_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_4_1_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_4_2_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_4_3_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_4_4_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_1_1_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_1_2_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_1_3_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_1_4_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_2_1_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_2_2_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_2_3_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_2_4_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_3_1_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_3_2_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_3_3_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_3_4_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_4_1_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_4_2_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_4_3_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Boiler_4_4_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_work_to_be_completed_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_work_to_be_completed_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Number_of_boilers_to_be_installed_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Number_of_boilers_to_be_installed_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.If_Modular_Number_of_Units_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.If_Modular_Number_of_Units_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Operating_Gauge_Pressure_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Operating_Gauge_Pressure_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Pressure_Setting_of_Relief_Valves_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Pressure_Setting_of_Relief_Valves_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Operating_Weight_of_Boiler_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Operating_Weight_of_Boiler_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Burner_Specifications_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Burner_Specifications_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Manufacture_Trade_Name_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Manufacture_Trade_Name_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.MEA_BSA_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.MEA_BSA_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Model_Number_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Model_Number_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Gross_Firing_Rate_of_Oil_Burners_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Gross_Firing_Rate_of_Oil_Burners_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_1_1_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_1_2_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_2_1_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_2_2_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_3_1_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_3_2_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_4_1_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_4_2_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_1_1_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_1_2_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_2_1_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_2_2_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_3_1_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_3_2_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_4_1_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Tank_4_2_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Design_Signing_Sealing_License_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Design_Signing_Sealing_License_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Length_of_curb_cut_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Length_of_curb_cut_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Street_Name_of_Nearest_Corner_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Street_Name_of_Nearest_Corner_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.list_required_Inspections_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.list_required_Inspections_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Final_Survey_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Distance_from_the_nearest_corner_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Measurement_of_New_Curb_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Measurement_of_the_Street_Frontage_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Length_of_fence_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Length_of_fence_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Height_of_fence_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Height_of_fence_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Distance_from_the_property_line_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Distance_from_the_property_line_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Type_of_material_used_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Type_of_material_used_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Owner_of_the_equipment_contact_info_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Owner_of_the_equipment_contact_info_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Name_of_Manufacturer_model_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Name_of_Manufacturer_model_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Fuel_Type_Used_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Fuel_Type_Used_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Number_of_Stacks_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Number_of_Stacks_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Serial_for_each_generator_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Serial_for_each_generator_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Engine_Model_Year_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Engine_Model_Year_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.EPA_Engine_Name_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.EPA_Engine_Name_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.APE_Tier_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.APE_Tier_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Displacement_liters_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Displacement_liters_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Maximum_rate_of_fuel_delivery_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Maximum_rate_of_fuel_delivery_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Horse_Power_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Horse_Power_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Equipment_Gross_Input_BTU_Hour_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Equipment_Gross_Input_BTU_Hour_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Primary_Use_Portable_Emergency_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Primary_Use_Portable_Emergency_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Nose_control_device_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Nose_control_device_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_Specification_Booklet_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_Specification_Booklet_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Frontage_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Frontage_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Height_of_Sign_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Height_of_Sign_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Advertising_or_Business_Sign_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Advertising_or_Business_Sign_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Sign_illuminated_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Sign_illuminated_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Is_the_sign_within_200_ft_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Is_the_sign_within_200_ft_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.provide_OAC_Sign_number_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.provide_OAC_Sign_number_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Building_Size_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Building_Size_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Required_Architectural_Inspections_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Required_Architectural_Inspections_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Sign_Hanger_name_license_Tax_ID_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Sign_Hanger_name_license_Tax_ID_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.GC_Signing_Sealing_License_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Dates_Desired_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Billing_client_Confirmation_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_list_of_Special_Progress_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Provide_list_of_Special_Progress_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_standpipe_work_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Description_of_standpipe_work_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.System_components_Removed_Relocated_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.System_components_Removed_Relocated_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Low_Voltage_Vendor_Information_App__c,
                                                                    RFI_Scope_Description_Long_Island__r.Low_Voltage_Vendor_Information_Off__c,
                                                                    RFI_Scope_Description_Long_Island__r.Checks_must_be_made_out_to_App__c

                                                FROM RFI_Scope__c
                                                WHERE Id =: rfiScopeRecordId ]);


            return rfiScope[0];     */

        }
        //AND RecordType.Name =: RECORD_TYPE_NAME_NY_REGION
        private set;

    }

    public PageReference docUploadPageReference {
        get {
            if (null == this.docUploadPageReference) {
                this.docUploadPageReference = new PageReference( '/apex/storedDocInlineRFIScope' );
                this.docUploadPageReference.getParameters().put('eid', String.valueOf(rfiScopeRecordId).left(15));

            }
            return this.docUploadPageReference;

        }
        set;
    }

    public Boolean isEmptyWorkType {
       get {
           return RFISingletonInstance.INSTANCE.rfiScope.RFI_Work_Types__r.isEmpty();
           //this.rfiScopeRecord.RFI_Work_Types__r.isEmpty();
       }
       private set;
    }

    /**
     * Set "three spaces" value for all empty or null textarea in the current RFI_Scope__c
     * for valid IE11 behaviour
     */
    private static void preventIE11EmptyTextareas() {
    	RFI_Scope__c rfi = RFISingletonInstance.INSTANCE.rfiScope;
    	Set<String> retrievedFields = retrievedFieldsLowerCase(rfi);
    	//System.debug(LoggingLevel.ERROR, retrievedFields);
    	if ( retrievedFields.contains('rfi_scope_description_new_york__r') && rfi.RFI_Scope_Description_New_York__r != null ) {
    		defaultValueForIE11TextAreas(rfi.RFI_Scope_Description_New_York__r, new Set<String> {
                'associated_preaction_work_app__c', 'primary_project_manager_sign_off__c', 'energy_code_inspections_app__c', 'tank_2_2_app__c', 'tank_1_1_app__c', 'acunits_replace_off__c', 'tank_3_2_app__c',
                'capacity_1_off__c', 'work_type_actual_costs__c', 'business_address_app__c', 'boiler_3_3_off__c', 'number_of_units_2_off__c', 'mea_serial_ul_5_off__c', 'length_of_curb_cut_sign_off__c',
                'hvac_equipment_name_model_off__c', 'square_footage_of_sign_app__c', 'serial_number_for_each_generator_app__c', 'boiler_2_1_app__c', 'modular_number_of_units_app__c', 'business_name_app__c',
                'boiler_4_4_off__c', 'description_of_work_to_be_completed_off__c', 'install_new_off__c', 'operating_weight_of_boiler_app__c', 'equipment_gross_input_app__c', 'description_of_work_app__c',
                'acunits_relocate_off__c', 'modular_number_of_units_off__c', 'associated_standpipepre_action_off__c', 'street_name_of_nearest_corner_sign_off__c', 'contractor_signing_dob_reg_app__c',
                'architectural_tpa_plans_app__c', 'provide_special_progress_inspect_app__c', 'tank_1_1_off__c', 'contractor_signing_dob_reg_sign_of__c', 'refrigerant_4_off__c', 'capacity_4_off__c',
                'system_components_removed_relocated_off__c', 'location_1_off__c', 'boiler_4_3_off__c', 'boiler_3_4_off__c', 'number_of_units_4_off__c', 'confirm_sprinkler_inspections_app__c',
                'if_modular_number_of_units_off__c', 'boiler_4_1_off__c', 'pressure_setting_of_relief_valves_app__c', 'devices_to_be_relocated_off__c', 'concrete_work_off__c', 'boiler_3_1_app__c',
                'nose_control_device_app__c', 'gross_firing_rate_of_oil_burners_off__c', 'location_4_off__c', 'mea_serial_ul_4_off__c', 'floor_3_off__c', 'final_survey_sign_off__c',
                'linear_footage_of_ductwork_app__c', 'location_2_off__c', 'indicate_the_area_of_the_exterior_app__c', 'site_contact_for_asbestos__c', 'filing_fee_check_app__c',
                'final_inspections_required_sign_off__c', 'mea_bsa_app__c', 'final_inspections_required_app__c', 'tank_3_1_off__c', 'operating_guage_pressure_off__c', 'hvac_number_of_units_off__c',
                'floor_2_off__c', 'floor_1_off__c', 'boiler_1_4_off__c', 'fuel_type_used_app__c', 'provide_specialprogress_inspections_app__c', 'description_of_work_to_be_completed_app__c',
                'burner_specifications_app__c', 'primary_project_manager_app__c', 'displacement__c', 'owner_name_representative_app__c', 'architect_work_to_complet_app__c', 'devices_to_be_removed_off__c',
                'refrigerant_3_off__c', 'is_the_sign_changeable_copy_app__c', 'sprinkler_subcontractor_off__c', 'tank_2_1_app__c', 'location_5_off__c', 'fax_representative_app__c',
                'number_of_boilers_to_be_installed_app__c', 'linear_footage_of_ductwork_off__c', 'sign_within_900_ft_app__c', 'equipment_name_model_1_off__c', 'sign_project_over_a_building_line_app__c',
                'concrete_work_app__c', 'floor_4_off__c', 'tank_4_1_app__c', 'devices_to_be_relocated_app__c', 'tank_3_2_off__c', 'signing_sealing_license_sign_off__c', 'business_telephone_app__c',
                'oac_sign_number_app__c', 'boiler_1_2_off__c', 'boiler_1_3_off__c', 'boiler_4_4_app__c', 'mea_serial_ul_3_off__c', 'design_signing_license_sign_off__c', 'confirm_sprinkler_inspections_off__c',
                'height_of_sign_app__c', 'business_name_representative_app__c', 'description_m_p_work_completed_off__c', 'capacity_2_off__c', 'hvac_capacity_btu_cfm_tons_off__c',
                'confirm_standpipe_inspections_off__c', 'refrigerant_1_off__c', 'asbestos_investigator_info__c', 'tank_1_2_app__c', 'description_of_support_exc_work_app__c', 'heads_removed_relocated_off__c',
                'tank_4_1_off__c', 'number_of_units_3_off__c', 'ahv_contractor_signing_license_app__c', 'operating_guage_pressure_app__c', 'hvac_mea_serial_ul_off__c', 'x3rd_party_inspector_contact_info__c',
                'if_modular_number_of_units_app__c', 'floor_5_off__c', 'advertising_or_business_sign_app__c', 'acunits_relocate_app__c', 'equipment_name_model_3_off__c', 'devices_to_be_installed_off__c',
                'devices_to_be_installed_app__c', 'sign_hanger_name_app__c', 'engine_model_year_app__c', 'identify_the_report_cycle_app__c', 'number_of_units_1_off__c', 'square_footage_sign_sign_off__c',
                'street_to_be_affected_app__c', 'measurement_of_the_street_frontage_app__c', 'ape_tier_app__c','boiler_3_2_off__c', 'inspector_signing_sealing_app__c', 'acunitsplumbing_fixture_components_app__c',
                'description_structural_work_off__c', 'business_address_representative_app__c', 'signing_sealing_license_app__c', 'acunits_remove_off__c', 'acunits_cooled_by_refrigerant_app__c',
                'horse_power_app__c', 'acunits_cooled_by_refrigerant_off__c', 'remove_app__c', 'number_of_boilers_to_be_installed_off__c', 'identify_the_exterior_wall_type_app__c', 'dot_contractor_signing_app__c',
                'boiler_2_2_app__c', 'provide_special_progress_inspect_off__c', 'distance_from_the_property_line_app__c', 'description_of_standpipe_work_off__c', 'engineer_signing_and_license_app__c',
                'manufacture_trade_name_app__c', 'tank_4_2_app__c', 'equipment_name_model_4_off__c', 'project_manager_app__c', 'boiler_4_3_app__c', 'boiler_2_3_off__c', 'boiler_1_1_app__c',
                'billing_client_confirmation_app__c', 'description_of_foundation_work_app__c', 'owner_of_the_equipment_app__c', 'mea_serial_ul_1_off__c', 'identify_the_inspection_status_app__c',
                'business_telephone_representative_app__c', 'hvac_location_off__c', 'primary_use_app__c', 'provide_energy_code_inspections_off__c', 'acunitsplumbing_fixture_components_off__c',
                'work_type_estimated_costs__c', 'measurement_of_new_curb_app__c', 'mea_bsa_off__c', 'operating_weight_of_boiler_off__c', 'equipment_name_model_2_off__c', 'tank_2_1_off__c', 'boiler_3_1_off__c',
                'model_number_app__c', 'boiler_1_3_app__c', 'associated_pre_action_tcsp_work_app__c', 'number_of_stacks_app__c', 'tenant_contact_information_app__c', 'description_fire_alarm_work_app__c',
                'street_name_of_nearest_corner_app__c', 'ahv_description_of_work_app__c', 'description_of_support_exc_work_sign_off__c', 'refrigerant_2_off__c', 'boiler_3_3_app__c',
                'description_structural_work_app__c', 'tenant_contact_information_sign_off__c', 'description_of_mechanical_work_off__c', 'heads_removed_relocated_sign_off__c', 'boiler_2_2_off__c',
                'boiler_2_3_app__c', 'manufacture_trade_name_off__c', 'acunits_remove_app__c', 'description_plumbing_work_completed_off__c', 'provide_energy_code_inspections_app__c', 'equipment_name_model_5_off__c',
                'heads_removed_relocated_app__c', 'tpa_event_notification_letter_app__c', 'boiler_1_1_off__c', 'gross_firing_rate_of_oil_burners_app__c', 'owner_name_app__c', 'energy_code_inspections_sign_off__c',
                'fire_alarm_inspections_off__c', 'duration_for_permit_app__c', 'boiler_2_4_off__c', 'description_of_foundation_work_sign_off__c', 'boiler_2_4_app__c', 'describe_the_type_of_fpp_system_app__c',
                'boiler_4_1_app__c', 'pressure_setting_of_relief_valves_off__c', 'description_fire_alarm_work_off__c', 'project_manager_sign_off__c', 'special_progress_inspections_app__c', 'model_number_off__c',
                'boiler_3_2_app__c', 'boiler_2_1_off__c', 'associated_preaction_work_off__c', 'length_of_fence_app__c', 'gc_signing_sealing_license__c', 'tank_1_2_off__c', 'system_components_removed_relocate_off__c',
                'percentage_of_building_sprinklered_app__c', 'associated_pre_action_tcsp_work_off__c', 'dot_description_of_work_app__c', 'special_progress_inspections_sign_off__c', 'fax_app__c',
                'description_of_mechanical_work_app__c', 'describe_the_type_of_fpp_system_off__c', 'square_footage_sign_app__c', 'refrigerant_5_off__c', 'hvac_floor_off__c', 'sign_within_200_ft_app__c',
                'system_components_removed_relocate_app__c', 'burner_specifications_off__c', 'install_new_app__c', 'boiler_1_4_app__c', 'boiler_4_2_off__c', 'boiler_4_2_app__c', 'capacity_5_off__c',
                'capacity_3_off__c', 'tank_3_1_app__c', 'description_plumbing_work_completed_app__c', 'type_of_material_used_app__c', 'epa_engine_name_app__c', 'tank_4_2_off__c', 'boiler_1_2_app__c',
                'tank_2_2_off__c', 'system_components_removed_relocated_app__c', 'architect_work_to_complete_sign_off__c', 'length_of_curb_cut_app__c', 'location_3_off__c', 'description_of_standpipe_work_app__c',
                'design_signing_license_app__c', 'inspector_pm_primary_app__c', 'boiler_3_4_app__c','mea_serial_ul_2_off__c', 'associated_standpipepre_action_app__c', 'acunits_replace_app__c',
                'distance_from_the_nearest_corner_app__c', 'devices_to_be_removed_app__c', 'maximum_rate_of_fuel_app__c', 'required_architectural_inspections_app__c', 'name_of_manufacturer_app__c',
                'description_m_p_work_completed_app__c', 'provide_specialprogress_inspections_off__c', 'billing_client_app__c', 'number_of_units_5_off__c'
    		});
    	}
    	if ( retrievedFields.contains('rfi_scope_description_long_island__r') && rfi.RFI_Scope_Description_Long_Island__r != null ) {
			defaultValueForIE11TextAreas(rfi.RFI_Scope_Description_Long_Island__r, new Set<String> {
				'initial_fee_app__c', 'tank_2_2_app__c', 'tank_1_1_app__c', 'owner_entity_name_app__c', 'tank_3_2_app__c', 'provide_copy_of_most_recent_tax_bill_app__c', 'boiler_3_3_off__c',
                'electrician_app__c', 'advertising_or_business_sign_off__c', 'frontage_app__c', 'gc_signing_sealing_license_app__c', 'boiler_2_1_app__c', 'name_of_manufacturer_model_app__c',
                'devices_removed_relocated_installed_app__c', 'boiler_4_4_off__c', 'description_of_work_to_be_completed_off__c', 'install_new_off__c', 'operating_weight_of_boiler_app__c', 'remove_off__c',
                'description_of_work_app__c', 'project_manager_off__c', 'final_survey_off__c', 'square_footage_app__c', 'sign_hanger_name_license_tax_id_off__c', 'checks_must_be_made_out_to_app__c',
                'plumbing_fixture_components_off__c', 'contractor_signing_dob_reg_app__c', 'tank_1_1_off__c', 'primary_use_portable_emergency_off__c', 'description_off__c', 'serial_for_each_generator_app__c',
                'system_components_removed_relocated_off__c', 'boiler_4_3_off__c', 'boiler_3_4_off__c', 'primary_contact_project_manager_app__c', 'if_modular_number_of_units_off__c',
                'contractor_contact_information_app__c', 'boiler_4_1_off__c', 'pressure_setting_of_relief_valves_app__c', 'concrete_work_off__c', 'boiler_3_1_app__c', 'gross_firing_rate_of_oil_burners_off__c',
                'nose_control_device_app__c', 'provide_oac_sign_number_off__c', 'ape_tier_off__c', 'sprinkler_installer_app__c', 'displacement_liters_off__c', 'low_voltage_vendor_information_off__c',
                'mea_bsa_app__c', 'tank_3_1_off__c', 'serial_for_each_generator_off__c', 'design_signing_sealing_license_off__c', 'boiler_1_4_off__c', 'fuel_type_used_app__c',
                'devices_removed_relocated_installed_off__c', 'equipment_gross_input_btu_hour_off__c', 'sprinkler_installer_off__c', 'description_of_work_to_be_completed_app__c', 'replace_app__c',
                'burner_specifications_app__c', 'equipment_gross_input_btu_hour_app__c', 'tank_2_1_app__c', 'sign_hanger_name_license_tax_id_app__c', 'name_of_manufacturer_model_off__c',
                'number_of_boilers_to_be_installed_app__c', 'signing_sealing_license_off__c', 'concrete_work_app__c', 'horse_power_off__c', 'tank_4_1_app__c', 'tank_3_2_off__c', 'frontage_off__c',
                'heads_removed_relocated_installed_app__c', 'relocate_off__c', 'boiler_1_2_off__c', 'provide_special_progress_inspections_app__c', 'boiler_1_3_off__c', 'description_of_structural_work_off__c',
                'boiler_4_4_app__c', 'number_of_stacks_off__c', 'height_of_sign_app__c', 'provide_list_of_special_progress_off__c', 'authorized_signatory_information_app__c', 'description_of_foundation_work_off__c',
                'tank_1_2_app__c', 'tank_4_1_off__c', 'primary_use_portable_emergency_app__c', 'heads_removed_relocated_installed_off__c', 'distance_from_the_property_line_off__c',
                'description_of_structural_work_app__c', 'if_modular_number_of_units_app__c', 'advertising_or_business_sign_app__c', 'provide_special_progress_inspections_off__c', 'replace_off__c',
                'engine_model_year_app__c', 'low_voltage_vendor_information_app__c', 'square_footage_off__c', 'primary_contact_app__c', 'street_to_be_affected_app__c', 'dot_contractor_signing_sealing_app__c',
                'measurement_of_the_street_frontage_app__c', 'ape_tier_app__c', 'boiler_3_2_off__c', 'provide_list_of_special_progress_app__c', 'previous_tenant_app__c', 'signing_sealing_license_app__c',
                'horse_power_app__c', 'is_the_sign_within_200_ft_off__c', 'maximum_rate_of_fuel_delivery_off__c', 'remove_app__c', 'required_architectural_inspections_off__c',
                'number_of_boilers_to_be_installed_off__c', 'owner_of_the_equipment_contact_info_app__c', 'height_of_fence_off__c', 'boiler_2_2_app__c', 'distance_from_the_property_line_app__c',
                'description_of_standpipe_work_off__c', 'provide_oac_sign_number_app__c', 'manufacture_trade_name_app__c', 'tank_4_2_app__c', 'nose_control_device_off__c', 'project_manager_app__c',
                'list_required_inspections_off__c', 'boiler_4_3_app__c', 'boiler_2_3_off__c', 'description_app__c', 'boiler_1_1_app__c', 'billing_client_confirmation_app__c', 'description_of_foundation_work_app__c',
                'owner_of_the_equipment_contact_info_off__c', 'provide_copy_recent_certif_occupancy_app__c', 'displacement_liters_app__c', 'engine_model_year_off__c', 'fuel_type_used_off__c',
                'type_of_material_used_off__c', 'plumbing_fixture_components_app__c', 'building_size_app__c', 'measurement_of_new_curb_app__c', 'mea_bsa_off__c', 'epa_engine_name_off__c',
                'operating_weight_of_boiler_off__c', 'tank_2_1_off__c', 'boiler_3_1_off__c', 'model_number_app__c', 'provide_list_of_inspections_off__c', 'number_of_stacks_app__c',
                'tenant_contact_information_app__c', 'x3rd_party_inspector_app__c', 'street_name_of_nearest_corner_app__c', 'design_signing_sealing_license_app__c', 'ahv_description_of_work_app__c',
                'length_of_fence_off__c', 'height_of_fence_app__c', 'boiler_3_3_app__c', 'provide_specification_booklet_off__c', 'contractor_contact_information_off__c', 'description_of_mechanical_work_off__c',
                'owner_contact_name_information_app__c', 'boiler_2_2_off__c', 'boiler_2_3_app__c', 'operating_gauge_pressure_app__c', 'fire_alarm_vendor_app__c', 'manufacture_trade_name_off__c', 'boiler_1_1_off__c',
                'gross_firing_rate_of_oil_burners_app__c', 'ahv_contractor_signing_sealing_app__c', 'x3rd_party_inspector_off__c', 'duration_for_permit_app__c', 'boiler_2_4_off__c', 'height_of_sign_off__c',
                'boiler_2_4_app__c', 'boiler_4_1_app__c', 'pressure_setting_of_relief_valves_off__c', 'boiler_3_2_app__c', 'model_number_off__c', 'boiler_2_1_off__c', 'length_of_fence_app__c',
                'provide_copy_of_most_recent_survey_app__c', 'tank_1_2_off__c', 'primary_contact_project_manager_off__c', 'dot_description_of_work_app__c', 'description_of_mechanical_work_app__c',
                'operating_gauge_pressure_off__c', 'maximum_rate_of_fuel_delivery_app__c', 'provide_specification_booklet_app__c', 'burner_specifications_off__c', 'install_new_app__c',
                'is_the_sign_within_200_ft_app__c', 'boiler_1_4_app__c', 'boiler_4_2_off__c', 'boiler_4_2_app__c', 'description_support_excavation_work_off__c', 'tank_3_1_app__c', 'description_of_work_off__c',
                'sign_illuminated_off__c', 'type_of_material_used_app__c', 'sign_illuminated_app__c', 'electrician_off__c', 'epa_engine_name_app__c', 'tank_4_2_off__c', 'boiler_1_2_app__c', 'relocate_app__c',
                'provide_list_of_inspections_app__c', 'tank_2_2_off__c', 'system_components_removed_relocated_app__c', 'length_of_curb_cut_app__c', 'description_support_excavation_work_app__c',
                'description_of_standpipe_work_app__c', 'application_permit_s_off__c', 'length_of_curb_cut_off__c', 'list_required_inspections_app__c', 'boiler_3_4_app__c', 'distance_from_the_nearest_corner_app__c',
                'street_name_of_nearest_corner_off__c', 'building_size_off__c', 'fire_alarm_vendor_off__c', 'required_architectural_inspections_app__c', 'billing_client_app__c'
			});
    	}
    	if ( retrievedFields.contains('rfi_scope_description_ct__r') && rfi.RFI_Scope_Description_CT__r != null ) {
			defaultValueForIE11TextAreas(rfi.RFI_Scope_Description_CT__r, new Set<String> {
				'initial_fee_app__c', 'tank_2_2_app__c', 'tank_1_1_app__c', 'owner_entity_name_app__c', 'tank_3_2_app__c', 'provide_copy_of_most_recent_tax_bill_app__c', 'boiler_3_3_off__c',
                'gc_signing_sealing_license_app__c', 'boiler_2_1_app__c', 'square_footage_of_sign_app__c', 'name_of_manufacturer_model_app__c', 'devices_removed_relocated_installed_app__c', 'boiler_4_4_off__c',
                'description_of_work_to_be_completed_off__c', 'install_new_off__c', 'operating_weight_of_boiler_app__c', 'remove_off__c', 'project_manager_off__c', 'final_survey_off__c', 'square_footage_app__c',
                'checks_must_be_made_out_to_app__c', 'plumbing_fixture_components_off__c', 'contractor_signing_dob_reg_app__c', 'tank_1_1_off__c', 'primary_use_portable_emergency_off__c',
                'serial_for_each_generator_app__c', 'system_components_removed_relocated_off__c', 'boiler_3_4_off__c', 'boiler_4_3_off__c', 'primary_contact_project_manager_app__c',
                'if_modular_number_of_units_off__c', 'ahv_billing_client_app__c', 'contractor_contact_information_app__c', 'boiler_4_1_off__c', 'pressure_setting_of_relief_valves_app__c', 'concrete_work_off__c',
                'boiler_3_1_app__c', 'gross_firing_rate_of_oil_burners_off__c', 'nose_control_device_app__c', 'ape_tier_off__c', 'displacement_liters_off__c', 'low_voltage_vendor_information_off__c',
                'mea_bsa_app__c', 'tank_3_1_off__c', 'serial_for_each_generator_off__c', 'design_signing_sealing_license_off__c', 'fuel_type_used_app__c', 'boiler_1_4_off__c',
                'devices_removed_relocated_installed_off__c', 'equipment_gross_input_btu_hour_off__c', 'description_of_work_to_be_completed_app__c', 'replace_app__c', 'burner_specifications_app__c',
                'equipment_gross_input_btu_hour_app__c', 'tank_2_1_app__c', 'sign_hanger_name_license_tax_id_app__c', 'name_of_manufacturer_model_off__c', 'number_of_boilers_to_be_installed_app__c',
                'signing_sealing_license_off__c', 'concrete_work_app__c', 'horse_power_off__c', 'tank_4_1_app__c', 'tank_3_2_off__c', 'heads_removed_relocated_installed_app__c', 'relocate_off__c',
                'boiler_1_2_off__c', 'provide_special_progress_inspections_app__c', 'boiler_1_3_off__c', 'is_the_sign_designed_for_changeable_app__c', 'description_of_structural_work_off__c', 'boiler_4_4_app__c',
                'number_of_stacks_off__c', 'height_of_sign_app__c', 'provide_list_of_special_progress_off__c', 'authorized_signatory_information_app__c', 'description_of_foundation_work_off__c', 'tank_1_2_app__c',
                'tank_4_1_off__c', 'primary_use_portable_emergency_app__c', 'heads_removed_relocated_installed_off__c', 'description_of_structural_work_app__c', 'if_modular_number_of_units_app__c',
                'advertising_or_business_sign_app__c', 'provide_special_progress_inspections_off__c', 'replace_off__c', 'engine_model_year_app__c', 'low_voltage_vendor_information_app__c', 'square_footage_off__c',
                'primary_contact_app__c', 'dot_contractor_signing_sealing_app__c', 'measurement_of_the_street_frontage_app__c', 'ape_tier_app__c', 'boiler_3_2_off__c', 'provide_list_of_special_progress_app__c',
                'previous_tenant_app__c', 'signing_sealing_license_app__c', 'horse_power_app__c', 'maximum_rate_of_fuel_delivery_off__c', 'remove_app__c', 'number_of_boilers_to_be_installed_off__c',
                'owner_of_the_equipment_contact_info_app__c', 'boiler_2_2_app__c', 'distance_from_the_property_line_app__c', 'description_of_standpipe_work_off__c', 'provide_oac_sign_number_app__c',
                'manufacture_trade_name_app__c', 'tank_4_2_app__c', 'nose_control_device_off__c', 'project_manager_app__c', 'do_sign_project_over_building_line_app__c', 'list_required_inspections_off__c',
                'boiler_4_3_app__c', 'boiler_2_3_off__c', 'boiler_1_1_app__c', 'description_of_foundation_work_app__c', 'provide_copy_recent_certif_occupancy_app__c', 'displacement_liters_app__c',
                'engine_model_year_off__c', 'fuel_type_used_off__c', 'plumbing_fixture_components_app__c', 'measurement_of_new_curb_app__c', 'mea_bsa_off__c', 'epa_engine_name_off__c',
                'operating_weight_of_boiler_off__c', 'tank_2_1_off__c', 'boiler_3_1_off__c', 'boiler_1_3_app__c', 'model_number_app__c', 'provide_list_of_inspections_off__c', 'number_of_stacks_app__c',
                'tenant_contact_information_app__c', 'street_name_of_nearest_corner_app__c', 'design_signing_sealing_license_app__c', 'ahv_description_of_work_app__c', 'height_of_fence_app__c',
                'boiler_3_3_app__c', 'contractor_contact_information_off__c', 'is_the_sign_within_900_ft_app__c', 'description_of_mechanical_work_off__c', 'owner_contact_name_information_app__c',
                'boiler_2_2_off__c', 'boiler_2_3_app__c', 'operating_gauge_pressure_app__c', 'manufacture_trade_name_off__c', 'dot_street_to_be_affected_app__c', 'boiler_1_1_off__c',
                'gross_firing_rate_of_oil_burners_app__c', 'ahv_contractor_signing_sealing_app__c', 'boiler_2_4_off__c', 'boiler_2_4_app__c', 'boiler_4_1_app__c', 'pressure_setting_of_relief_valves_off__c',
                'boiler_3_2_app__c', 'model_number_off__c', 'boiler_2_1_off__c', 'length_of_fence_app__c', 'provide_copy_of_most_recent_survey_app__c', 'tank_1_2_off__c', 'primary_contact_project_manager_off__c',
                'dot_description_of_work_app__c', 'description_of_mechanical_work_app__c', 'operating_gauge_pressure_off__c', 'maximum_rate_of_fuel_delivery_app__c', 'burner_specifications_off__c',
                'install_new_app__c', 'is_the_sign_within_200_ft_app__c', 'boiler_1_4_app__c', 'boiler_4_2_off__c', 'boiler_4_2_app__c', 'description_support_excavation_work_off__c', 'tank_3_1_app__c',
                'type_of_material_used_app__c', 'epa_engine_name_app__c', 'tank_4_2_off__c', 'boiler_1_2_app__c', 'dot_duration_for_permit_app__c', 'relocate_app__c', 'provide_list_of_inspections_app__c',
                'tank_2_2_off__c', 'system_components_removed_relocated_app__c', 'length_of_curb_cut_app__c', 'description_support_excavation_work_app__c', 'description_of_standpipe_work_app__c',
                'length_of_curb_cut_off__c', 'list_required_inspections_app__c', 'boiler_3_4_app__c', 'distance_from_the_nearest_corner_app__c', 'street_name_of_nearest_corner_off__c',
                'required_architectural_inspections_app__c'
			});
    	}
    	if ( retrievedFields.contains('rfi_scope_description_new_jersey__r') && rfi.RFI_Scope_Description_New_Jersey__r != null ) {
			defaultValueForIE11TextAreas(rfi.RFI_Scope_Description_New_Jersey__r, new Set<String> {
				'wet_chemical_pre_engineered_system_s_app__c', 'model_app__c', 'signaling_devices_size_app__c', 'local_general_contractor_license_app__c', 'water_heater_qty_app__c', 'owner_entity_name_app__c',
                'bath_tub_size_app__c', 'sprinkler_heads_dry_and_wet_qty_app__c', 'fuel_fired_appliances_qty_app__c', 'water_service_connection_qty_app__c', 'co2_suppression_system_qty_app__c',
                'hp_motors_1_hp_qty_app__c', 'lavatory_size_app__c', 'kw_central_a_c_unit_size_app__c', 'sprinkler_heads_dry_and_wet_size_app__c', 'lp_gas_tank_size_app__c', 'dry_pipe_alarm_valves_size_app__c',
                'hp_garbage_disposal_qty_app__c', 'alarm_devices_f_a_c_panel_size_app__c', 'dry_chemical_pre_engineered_system_q_app__c', 'alarm_devices_size_app__c', 'kitchen_hood_exhaust_system_size_app__c',
                'pre_action_valves_size_app__c', 'architect_of_record_information_app__c', 'floor_drain_size_app__c', 'fire_pump_type_size_app__c', 'equipment_make_app__c', 'description_of_work_app__c',
                'model_year_app__c', 'hot_water_boiler_qty_app__c', 'drinking_fountain_qty_app__c', 'urinal_bidet_size_app__c', 'federal_id_app__c', 'kw_elec_sign_outline_light_size_app__c',
                'sewer_pump_size_app__c', 'signaling_devices_qty_app__c', 'stacks_size_app__c', 'kw_oven_surface_unit_qty_app__c', 'alarm_devices_qty_app__c', 'smoke_control_system_qty_app__c',
                'light_poles_qty_app__c', 'storable_stool_spa_hot_tub_qty_app__c', 'kw_elec_sign_outline_light_qty_app__c', 'receptacles_qty_app__c', 'flammable_combustible_tanks_size_app__c',
                'property_mailing_address_app__c', 'kitchen_hood_exhaust_system_qty_app__c', 'standpipes_size_app__c', 'estimated_annual_operating_hours_app__c', 'kw_transformer_generator_qty_app__c',
                'tenant_contact_information_app__c', 'supervisory_devices_size_app__c', 'tele_communication_exemp_certificate_app__c', 'emergency_exit_lights_size_app__c', 'lp_gas_tank_qty_app__c',
                'stacks_qty_app__c', 'sink_qty_app__c', 'flammable_combustible_tanks_qty_app__c', 'fire_pump_type_qty_app__c', 'switches_qty_app__c', 'storable_stool_spa_hot_tub_size_app__c',
                'plumbing_description_of_work_app__c', 'year_manufactured_app__c', 'other_qty_app__c', 'primary_contact_information_app__c', 'owner_contact_name_information_app__c',
                'kw_transformer_generator_size_app__c', 'equipment_manufacturer_app__c', 'interceptor_separator_qty_app__c', 'steam_boiler_size_app__c', 'hp_kw_space_heater_air_handler_qty_app__c',
                'kw_baseboard_heat_qty_app__c', 'smoke_control_system_size_app__c', 'motors_fract_hp_qty_app__c', 'kw_baseboard_heat_size_app__c', 'interceptor_separator_size_app__c', 'other_size_app__c',
                'please_provide_a_copy_of_nj_license_app__c', 'light_poles_size_app__c', 'legal_property_address_app__c', 'lv_description_of_work_app__c', 'foam_suppression_system_size_app__c',
                'greasetrap_size_app__c', 'hose_bibb_qty_app__c', 'estimated_cost_app__c', 'gas_piping_qty_app__c', 'shower_qty_app__c', 'backflow_preventer_size_app__c', 'foam_suppression_system_qty_app__c',
                'lighting_fixtures_size_app__c', 'sewer_connection_size_app__c', 'wet_chemical_pre_engineered_system_q_app__c', 'detectors_qty_app__c', 'hp_motors_1_hp_size_app__c',
                'fm200_suppression_system_qty_app__c', 'sprinkler_description_of_work_app__c', 'pool_permit_with_uv_lights_qty_app__c', 'amp_subpanels_size_app__c', 'fireplace_venting_metal_chimney_size_app__c',
                'backflow_preventer_qty_app__c', 'dishwasher_size_app__c', 'amp_service_qty_app__c', 'communication_points_size_app__c', 'switches_size_app__c', 'lighting_fixtures_qty_app__c',
                'kw_dishwasher_size_app__c', 'fuel_oil_piping_qty_app__c', 'fireplace_venting_metal_chimney_qty_app__c', 'project_manager_information_app__c', 'max_rated_heat_input_mmbtu_hr_app__c',
                'fm200_suppression_system_size_app__c', 'washing_machine_size_app__c', 'facility_designation_emission_unit_app__c', 'floor_drain_qty_app__c', 'supervisory_devices_qty_app__c',
                'kw_elec_water_heater_qty_app__c', 'pre_action_valves_qty_app__c', 'amp_motor_control_center_qty_app__c', 'hot_water_boiler_size_app__c', 'steam_boiler_qty_app__c',
                'pool_permit_with_uv_lights_size_app__c', 'emergency_exit_lights_qty_app__c', 'contact_name_information_app__c', 'co2_suppression_system_size_app__c', 'receptacles_size_app__c',
                'authorized_signatory_information_app__c', 'dry_chemical_pre_engineered_system_s_app__c', 'kw_elec_dryer_receptacle_qty_app__c', 'water_closet_size_app__c', 'kw_dishwasher_qty_app__c',
                'standpipes_qty_app__c', 'shower_size_app__c', 'washing_machine_qty_app__c', 'urinal_bidet_qty_app__c', 'lavatory_qty_app__c', 'fuel_oil_piping_size_app__c', 'hp_garbage_disposal_size_app__c',
                'sink_size_app__c', 'kw_elec_range_receptacle_size_app__c', 'gas_piping_size_app__c', 'dry_pipe_alarm_valves_qty_app__c', 'kw_elec_dryer_receptacle_size_app__c',
                'electrical_description_of_work_app__c', 'fuel_fired_appliances_size_app__c', 'amp_subpanels_qty_app__c', 'dishwasher_qty_app__c', 'alarm_devices_f_a_c_panel_qty_app__c',
                'facility_contact_information_app__c', 'elevator_description_of_work_app__c', 'drinking_fountain_size_app__c', 'sewer_connection_qty_app__c', 'lot_block_app__c',
                'sub_contractor_information_app__c', 'square_footage_of_project_app__c', 'motors_fract_hp_size_app__c', 'kw_elec_water_heater_size_app__c', 'hose_bibb_size_app__c', 'amp_service_size_app__c',
                'greasetrap_qty_app__c', 'kw_central_a_c_unit_qty_app__c', 'water_service_connection_size_app__c', 'sewer_pump_qty_app__c', 'water_heater_size_app__c', 'bath_tub_qty_app__c',
                'amp_motor_control_center_size_app__c', 'water_closet_qty_app__c', 'kw_oven_surface_unit_size_app__c', 'detectors_size_app__c', 'hp_kw_space_heater_air_handler_size_app__c',
                'ES_Company_App__c', 'ES_Contact_Name_App__c', 'ES_Address_App__c', 'ES_Business_Phone_App__c', 'ES_Contact_Email_App__c', 'ES_State_License_App__c', 'ES_Fed_Employee_ID_App__c',
                'LVS_Company_App__c', 'LVS_Contact_Name_App__c', 'LVS_Address_App__c', 'LVS_Business_Phone_App__c', 'LVS_Contact_Email_App__c', 'LVS_State_License_App__c', 'LVS_Fed_Employee_ID_App__c',
                'FAS_Company_App__c', 'FAS_Contact_Name_App__c', 'FAS_Address_App__c', 'FAS_Business_Phone_App__c', 'FAS_Contact_Email_App__c', 'FAS_State_License_App__c', 'FAS_Fed_Employee_ID_App__c',
                'PS_Company_App__c', 'PS_Contact_Name_App__c', 'PS_Address_App__c', 'PS_Business_Phone_App__c', 'PS_Contact_Email_App__c', 'PS_State_License_App__c', 'PS_Fed_Employee_ID_App__c',
                'MS_Company_App__c', 'MS_Contact_Name_App__c', 'MS_Address_App__c', 'MS_Business_Phone_App__c', 'MS_Contact_Email_App__c', 'MS_State_License_App__c', 'MS_Fed_Employee_ID_App__c',
                'SS_Company_App__c', 'SS_Contact_Name_App__c', 'SS_Address_App__c', 'SS_Business_Phone_App__c', 'SS_Contact_Email_App__c', 'SS_State_License_App__c', 'SS_Fed_Employee_ID_App__c'
			});
    	}
    }

    private static Set<String> retrievedFieldsLowerCase(sObject sObj) {
    	Set<String> setLc = new Set<String>();
    	String rawJSON = JSON.serialize(sObj);
    	Map<String,Object> objMap = (Map<String,Object>) JSON.deserializeUntyped(rawJSON);
    	for (String field: objMap.keySet()) {
    		if ( field != 'attributes' ) setLc.add(field.toLowerCase());
    	}
    	return setLc;
    }

    private static void defaultValueForIE11TextAreas(sObject sObj, Set<String> fieldNames) {
    	for (String fieldName: fieldNames) {
	    	Object value = sObj.get(fieldName);
	    	if ( value instanceof String ) {
		    	if ( String.isBlank((String) value) ) {
		    		sObj.put(fieldName, '   ');
		    	}
	    	}
    	}
    }

}