/**********************************************************************************************
* @author       Janella Espiritu
* @date         05/04/2015
* @description  This class holds all the methods called for Validations
* @revision(s)  Janella Espiritu 05062015 R2S1 : Added CustomerContactValidation
				Janella Espiritu 06242015 R2S3 : Added ValidateCanceledSubStatus
				Janella Espiritu 06242015 R2S3 : Updated RequiredFieldsValidationWorkItem 
													validate QAS fields
**********************************************************************************************/
public class ValidationUtility {
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           05/04/2015
    * @description    This method is called from CaseTriggerHandler.Handle to 
    * 				validate fields on the work item against the 
    * 				Customer Contact Type custom setting
    * @parameters    closedWorkItems - Work Items that are to be Closed
    **************************************************************************/
    public static void CustomerContactValidationWorkItem(List<Case> closedWorkItems){
        // Custom Label for Customer Contact Validation Error Message
        String ERROR_MESSAGE = System.Label.CCType_Validation_Error_Message;
        // KEY: String - Customer Contact Type
        // VALUE: CustomerContactType__c Instance
        Map<String, CustomerContactType__c> customerContactCSMap = CustomerContactType__c.getAll();
        // Loop work items to be closed
        for(Case wi : closedWorkItems){
            // If the customer contact type is in the customerContactCSMap
            if(customerContactCSMap.containsKey(wi.Customer_Contact_Type__c)){
                // Retrieve the CustomerContactType__c Instance
                CustomerContactType__c cct = customerContactCSMap.get(wi.Customer_Contact_Type__c);
                // If CustomerContactType__c ACCT ID is checked AND if CC Account ID is NULL
                if(cct.ACCT_ID__c && wi.CC_Account_ID__c == null){
                    wi.CC_Account_ID__c.addError(ERROR_MESSAGE);
                }
                // If CustomerContactType__c PREM ID is checked AND if CC Premise ID is NULL
                if(cct.PREM_ID__c && wi.CC_Premise_ID__c == null){
                    wi.CC_Premise_ID__c.addError(ERROR_MESSAGE);
                }
                // If CustomerContactType__c SA ID is checked AND if CC Service Agreement ID is NULL
                if(cct.SA_ID__c && wi.CC_Service_Agreement_ID__c == null){
                    wi.CC_Service_Agreement_ID__c.addError(ERROR_MESSAGE);
                }
            }
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           05/04/2015
    * @description    This method is called from CaseTriggerHandler.Handle to 
    * 				validate fields on the work item against the 
    * 				Customer Contact Type custom setting
    * @parameters    newRelatedRecords - Work Items that are to be inserted
    **************************************************************************/
    public static void CustomerContactValidationRelatedRecords(List<Related_Records__c> newRelatedRecords){
        Diags.Enter('ValidationUtility.CustomerContactValidationRelatedRecords');
        String CCRecordTypeId = Schema.SObjectType.Related_Records__c.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        // Custom Label for Customer Contact Validation Error Message
        String ERROR_MESSAGE = System.Label.CCType_Validation_Error_Message;
        // KEY: String - Customer Contact Type
        // VALUE: CustomerContactType__c Instance
        Map<String, CustomerContactType__c> customerContactCSMap = CustomerContactType__c.getAll();
        //Diags.Info('customerContactCSMap: '+String.valueOf(customerContactCSMap));
        //Diags.Info('newRelatedRecords: '+String.valueOf(newRelatedRecords));
        // Loop work items to be closed
        for(Related_Records__c rr : newRelatedRecords){
            Diags.Info('rr.RR_Customer_Contact_Type__c: '+rr.RR_Customer_Contact_Type__c);
            // If the customer contact type is in the customerContactCSMap
            if(customerContactCSMap.containsKey(rr.RR_Customer_Contact_Type__c) && rr.RecordTypeId == CCRecordTypeId){
                // Retrieve the CustomerContactType__c Instance
                CustomerContactType__c cct = customerContactCSMap.get(rr.RR_Customer_Contact_Type__c);
                // If CustomerContactType__c ACCT ID is checked AND if CC Account ID is NULL
                if(cct.ACCT_ID__c != null && cct.ACCT_ID__c && rr.CC_Account_ID__c == null){
                    Diags.Info('CC ACCT ID NULL');
                    rr.CC_Account_ID__c.addError(ERROR_MESSAGE);
                }
                // If CustomerContactType__c PREM ID is checked AND if CC Premise ID is NULL
                if(cct.PREM_ID__c && rr.CC_Premise_ID__c == null){
                    Diags.Info('CC PREM ID NULL');
                    rr.CC_Premise_ID__c.addError(ERROR_MESSAGE);
                }
                // If CustomerContactType__c SA ID is checked AND if CC Service Agreement ID is NULL
                if(cct.SA_ID__c && rr.CC_Service_Agreement_ID__c == null){
                    Diags.Info('CC SA ID NULL');
                    rr.CC_Service_Agreement_ID__c.addError(ERROR_MESSAGE);
                }
            }
        }
        Diags.Clear();
    }
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           05/11/2015
    * @description    This method is called from CaseTriggerHandler.Handle to 
    * 				validate fields on the work item against the 
    * 				Required Fields on Close WI Page custom setting
    * @parameters    closedWorkItems - Work Items that are to be inserted
    **************************************************************************/
    public static void RequiredFieldsValidationWorkItem(List<Case> closedWorkItems){
        system.debug('ENTER');
        Diags.Enter('RequiredFieldsValidationWorkItem');
        // Custom Label for Customer Contact Validation Error Message
        String ERROR_MESSAGE = System.Label.WIType_Validation_Error_Message;
		String CUSTOMER_FOLLOWUP_ERROR_MESSAGE = System.Label.Customer_Follow_Up_Required_Error_Message;
		String FastSlowUSR = WorkItemAssignmentUtility.getFastSlowToDoGasUSRId();
		String CSRProfileId = WorkItemAssignmentUtility.getCSRProfileId();
		String SSRProfileId = WorkItemAssignmentUtility.getSSRProfileId();
		String CurrentUserProfileId = UserInfo.getProfileId();
        Id IntegrationProfileId = WorkItemAssignmentUtility.getIntegrationProfileId();
        Id CaseRecordtypeId = WorkItemAssignmentUtility.getCCBCasesRecordTypeId();
        // KEY: String - Work Item Type
        // VALUE: Work_Item_Required_Fields__c Instance
        Map<String, Work_Item_Required_Fields__c> workItemCSMap = Work_Item_Required_Fields__c.getAll();
		// KEY: String - Work Item Type
		// VALUE: Work_Item_Type_Cases__c instance
		Map<String, Work_Item_Type_Cases__c> workItemTypeCaseMap = Work_Item_Type_Cases__c.getAll();
        
        // Loop work items to be closed
        for(Case wi : closedWorkItems){ 
            //System.debug(logginglevel.info, 'what is validation for thrid party' + wi.Third_Party_Response_Required__c);
            //System.debug(logginglevel.info, 'what is validation for thrid party' + wi.Third_Party_Response__c);
			//System.debug(logginglevel.info, 'what is validation for thrid party' + wi.Case_Age_Stopped__c);
            if (wi.Third_Party_Response_Required__c == 'Yes' && wi.Third_Party_Response__c == null){
                wi.addError('When Third Party Response Required is set to YES, Third Party Response must be populated to close a Work Item');
            }
            if(wi.Customer_Response_Required__c == 'Yes' && wi.Customer_Response_Resolution__c == null){            
                wi.addError('When Customer Response Required is set to YES, the Customer Response Resolution must be populated to close a Work Item');
            }

			// If the work item is a CC&B Case, validate the Sub Status
			if(workItemTypeCaseMap.containsKey(wi.Work_Item_Type__c)){
				// Retrieve Work Item Type Cases
        		Work_Item_Type_Cases__c workItemTypeCase = workItemTypeCaseMap.get(wi.Work_Item_Type__c);
                // If it is a QAS Case AND the Sub Status is not QAS Approved or QAS Denied or Redirect
				if(workItemTypeCase.Category__c == 'QAS' && wi.Sub_Status__c != 'QAS Approved' && wi.Sub_Status__c != 'QAS Denied' && wi.Sub_Status__c != 'Redirect'){
					wi.Sub_Status__c.addError(System.Label.QAS_Case_Sub_Status_Validation_Rule);
				}
                // If it is not a QAS Case and the Sub Status is QAS Approved or QAS Denied
                else if(workItemTypeCase.Category__c != 'QAS' && (wi.Sub_Status__c == 'QAS Approved' || wi.Sub_Status__c == 'QAS Denied')){
					wi.Sub_Status__c.addError(System.Label.Non_QAS_Case_Sub_Status_Validation_Rule);
				}
			}
			if(wi.User_Skill_Rule__c == FastSlowUSR && (CurrentUserProfileId == CSRProfileId || CurrentUserProfileId == SSRProfileId)){
				wi.User_Skill_Rule__c.addError(System.Label.Closed_Fast_Slow_Gas_Error);
			}
            // If the customer contact type is in the workItemCSMap
            if(workItemCSMap.containsKey(wi.Work_Item_Type__c) && UserInfo.getProfileId() != IntegrationProfileId){
                // Check if Sub_Status__c is NOT Completed by Other User OR Redirect AND Recordtype is CC&B Case
                if(wi.RecordTypeId == CaseRecordtypeId && wi.Sub_Status__c != 'Completed by System' && wi.Sub_Status__c != 'Redirect' && wi.Case_Closure_Method__c == null){
                    wi.Case_Closure_Method__c.addError(ERROR_MESSAGE);
                }
                // Retrieve the Work_Item_Required_Fields__c Instance
                Work_Item_Required_Fields__c cct = workItemCSMap.get(wi.Work_Item_Type__c);
				// Check if the Custom Setting is Active
                if(cct.IsActive__c && UserInfo.getProfileId() != IntegrationProfileId){
					// Check the Sub-Status
					if(wi.Sub_Status__c == 'Completed by Assigned User' || (workItemTypeCaseMap.containsKey(wi.Work_Item_Type__c) && workItemTypeCaseMap.get(wi.Work_Item_Type__c).Category__c == 'QAS')){
						// Compare the work item field with the Custom Setting field
						// If the conditions ARE MET, it will display an error message 
						// on the specific field
						if(!wi.Add_account_D_C_number__c && cct.Add_account_D_C_number__c){
							wi.Add_account_D_C_number__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Add_Person_ID__c && cct.Add_Person_ID__c){
							wi.Add_Person_ID__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Add_RA_Acct_SA_ID_in_RAP__c && cct.Add_RA_Acct_SA_ID_in_RAP__c){
							wi.Add_RA_Acct_SA_ID_in_RAP__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Alerts_added_to_CC_B__c && cct.Alerts_added_to_CC_B__c){
							wi.Alerts_added_to_CC_B__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Bill_completed_in_CC_B__c && cct.Bill_completed_in_CC_B__c){
							wi.Bill_completed_in_CC_B__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Bill_in_compliance_with_Rule_17__c && cct.Bill_in_compliance_with_Rule_17__c){
							wi.Bill_in_compliance_with_Rule_17__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Check_SM_Status__c && cct.Check_SM_Status__c){
							wi.Check_SM_Status__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Clear_related_ToDos_for_Acct_Premise__c && cct.Clear_related_ToDos_for_Acct_Premise__c){
							wi.Clear_related_ToDos_for_Acct_Premise__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Comment_Code_Added__c && cct.Comment_Code_Added__c){
							wi.Comment_Code_Added__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Completed_letter__c && cct.Completed_letter__c){
							wi.Completed_letter__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Did_you_clear_MDMS_Flags__c && cct.Did_you_clear_MDMS_Flags__c){
							wi.Did_you_clear_MDMS_Flags__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Did_you_increase_Threshold__c && cct.Did_you_increase_Threshold__c){
							wi.Did_you_increase_Threshold__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Drive_Rate_Added__c && cct.Drive_Rate_Added__c){
							wi.Drive_Rate_Added__c.addError(ERROR_MESSAGE);
						}
						if(!wi.If_start_cancelled_was_CC_created__c && cct.If_start_cancelled_was_CC_created__c){
							wi.If_start_cancelled_was_CC_created__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Interval_SA_set_up__c && cct.Interval_SA_set_up__c){
							wi.Interval_SA_set_up__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Is_the_account_billed_current__c && cct.Is_the_account_billed_current__c){
							wi.Is_the_account_billed_current__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Is_the_other_commodity_active__c && cct.Is_the_other_commodity_active__c){
							wi.Is_the_other_commodity_active__c.addError(ERROR_MESSAGE);
						}
						if(!wi.New_Active_SA__c && cct.New_Active_SA__c){
							wi.New_Active_SA__c.addError(ERROR_MESSAGE);
						}
						if(cct.Postpone_Credit__c && wi.Postpone_Credit_if_applicable__c == NULL){
							wi.Postpone_Credit_if_applicable__c.addError(ERROR_MESSAGE);
						}
                        /*
						if(!wi.Removed_SM_designation_from_MR_route__c && cct.Removed_SM_designation_from_MR_route__c){
							wi.Removed_SM_designation_from_MR_route__c.addError(ERROR_MESSAGE);
						}
						*/
						if(!wi.Send_RAP_bill__c && cct.Send_RAP_bill__c){
							wi.Send_RAP_bill__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Updated_Premise_characteristics__c && cct.Updated_Premise_characteristics__c){
							wi.Updated_Premise_characteristics__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Updated_SP_characteristics__c && cct.Updated_SP_characteristics__c){
							wi.Updated_SP_characteristics__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Update_RAP_notes__c && cct.Update_RAP_notes__c){
							wi.Update_RAP_notes__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Verified_no_SMOO_Delay_Billing_Fee_char__c && cct.Verified_no_SMOO_Delay_Billing_Fee_char__c){
							wi.Verified_no_SMOO_Delay_Billing_Fee_char__c.addError(ERROR_MESSAGE);
						}
						if(!wi.Verify_total_billed_same_for_RAP_CC_B__c && cct.Verify_total_billed_same_for_RAP_CC_B__c){
							wi.Verify_total_billed_same_for_RAP_CC_B__c.addError(ERROR_MESSAGE);
						}
					}
                    // If the wi Cust Follow Up Required is changed
                    // and Customer Follow up Required is either 
                    // Email, Letter, Does Not Apply, Phone or None
                    // throw an error message
					if(UserInfo.getProfileId() != IntegrationProfileId && !wi.Cust_Follow_up_Required__c != cct.Cust_Follow_up_Required__c &&
						(  wi.Customer_Follow_Up_Required__c == 'Email' 
						|| wi.Customer_Follow_Up_Required__c == 'Letter'
						|| wi.Customer_Follow_Up_Required__c == 'Does Not Apply'
						|| wi.Customer_Follow_Up_Required__c == 'Phone'
						|| wi.Customer_Follow_Up_Required__c == 'None')
						){
						wi.Cust_Follow_up_Required__c.addError(CUSTOMER_FOLLOWUP_ERROR_MESSAGE);
					}
				}
            }
        }
        Diags.Clear();
    }
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           06/17/2015
    * @description    This method is called from CaseTriggerHandler.Handle to 
    * 				validate the Fast/Slow Automation Pending Sub Status
    * @parameters    updatedWorkItems - Work Items that are to be updated
    **************************************************************************/
	public static void ValidateFastSlowAutomationSubStatus(List<Case> updatedWorkItems){
		String FastSlowUSR = WorkItemAssignmentUtility.getFastSlowToDoGasUSRId();
		String CSRProfileId = WorkItemAssignmentUtility.getCSRProfileId();
		String SSRProfileId = WorkItemAssignmentUtility.getSSRProfileId();
		String CurrentUserProfileId = UserInfo.getProfileId();
		// Validate if the USR is not the FastSlowUSR 
		// and the Sub Status is not Fast/Slow Automation 
		// and the current User is CSR or SSR
		for(Case wi : updatedWorkItems){
			if(wi.User_Skill_Rule__c != FastSlowUSR && wi.Sub_Status__c == 'Fast/Slow Automation' && (CurrentUserProfileId == CSRProfileId || CurrentUserProfileId == SSRProfileId)){
				wi.Sub_Status__c.addError(System.Label.Fast_Slow_Automation_Validation_Error);
			}
		}
	}
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           06/24/2015
    * @description    This method is called from CaseTriggerHandler.Handle to 
    * 					validate the Cancel Reason if the work item is canceled
    * @parameters    canceledWorkItems - Work Items that are to be canceled
    **************************************************************************/
	public static void ValidateCanceledSubStatus(List<Case> canceledWorkItems){
        Diags.Enter('ValidateCanceledSubStatus');
        Diags.Info('canceledWorkItems'+String.valueOf(canceledWorkItems));
		String FastSlowUSR = WorkItemAssignmentUtility.getFastSlowToDoGasUSRId();
		String CSRProfileId = WorkItemAssignmentUtility.getCSRProfileId();
		String SSRProfileId = WorkItemAssignmentUtility.getSSRProfileId();
		String CurrentUserProfileId = UserInfo.getProfileId();
		Id CaseRecordtypeId = WorkItemAssignmentUtility.getCCBCasesRecordTypeId();
		// Loop canceled work items
		for(Case wi : canceledWorkItems){
            // If the Sub Status is not Cancelled by User
            // and profile is either CSR or SSR
            // throw an error message
			if(wi.Sub_Status__c != 'Canceled by User' && (CurrentUserProfileId == CSRProfileId || CurrentUserProfileId == SSRProfileId) && wi.RecordTypeId == CaseRecordtypeId){
				wi.Sub_Status__c.addError(System.Label.Cancel_Sub_Status_Validation);
			}
            // If the Sub Status is not Cancelled by User
            //  and Cancel Reason is null
            // and profile is either CSR or SSR
            // throw an error message
			else if(wi.Sub_Status__c == 'Canceled by User' && wi.Cancel_Reason__c == null &&(CurrentUserProfileId == CSRProfileId || CurrentUserProfileId == SSRProfileId)){
				wi.Cancel_Reason__c.addError(System.Label.Cancel_Reason_Validation);
			}
		}
        Diags.Clear();
	}
    
     	/*************************************************************************
    * @author         Melody Yang
    * @date           August 2015
    * @description    This method is called from CaseTriggerHandler.Handle to 
    * 					validate the work item cannot be closed twice
    * @parameters    closedWorkItems - Work Items that are to be inserted
    **************************************************************************/
public static void ValidateClosingWIagain(List<Case> closedWorkItems){
        Diags.Enter('ValidateClosingWIagain');
        Diags.Info('closedWorkItems'+String.valueOf(closedWorkItems));
        System.debug(logginglevel.info, 'entering ValidationUtility.ValidateClosingWIagain');
		
        String CSRProfileId = WorkItemAssignmentUtility.getCSRProfileId();
		String SSRProfileId = WorkItemAssignmentUtility.getSSRProfileId();
		String CurrentUserProfileId = UserInfo.getProfileId();
        
        for(Case wi : closedWorkItems){
            // If the WI is already closed
            // and profile is either CSR or SSR
            // throw an error message
            if(
                (CurrentUserProfileId == CSRProfileId || CurrentUserProfileId == SSRProfileId)){
                
        System.debug(logginglevel.info, 'entering ValidationUtility.ValidateClosingWIagain loop as CSR/SSR');
				wi.Status.addError(System.Label.Closing_WI_Again);
			}
        }
        Diags.Clear();
    }
    
    /*************************************************************************
    * @author         Melody Yang
    * @date           August 2015
    * @description    This method is called from CaseTriggerHandler.Handle to 
    * 					validate the work item cannot be completed if owned by 
    * 					the Billing Exceptions Queue
    * @parameters    closedWorkItems - Work Items that are to be inserted
    **************************************************************************/

     public static void ValidateClosingWIasBillingExceptions(List<Case> closedWorkItems){
        Diags.Enter('ValidateClosingWIasBillingExceptions');
        Diags.Info('closedWorkItems'+String.valueOf(closedWorkItems));
        System.debug(logginglevel.info, 'entering ValidationUtility.ValidateClosingWIasBillingExceptions');
        
        String billingExceptionsQueueId   = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
        for(Case wi : closedWorkItems){
            // If the Status is Completed or Canceled
            // and profile is either CSR or SSR
            // throw an error message
            if(wi.Status == 'Completed' && wi.OwnerId == billingExceptionsQueueId){
        		System.debug(logginglevel.info, 'entering ValidationUtility.ValidateClosingWIasBillingExceptions loop');
				wi.Status.addError(System.Label.Closing_WI_As_Billing_Exceptions);
			}
        }
        Diags.Clear();
    }
}