/*************************************************************************
* @author         Tae Tran
* @date           8/4/2015
* @description    This class is call from casetrigger to be able to start 
				  stop and delete case age
* @parameters     caseList

**************************************************************************/

public class CaseAgeStartStopHandler {
    
   /*************************************************************************
    * @author         Tae Tran
    * @date           06/24/2015
    * @description    This method STOP the clock for Case Age
    * @parameters     caseList

    **************************************************************************/
	public static void CaseAgeStopClock(List<Case> caseList, Boolean onInsert){ // work
        Diags.Info('###########ENTERING CaseAgeClock STOP');// returns the name of the case type  
  		Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById(); // get a list of all case work item type to use for later
        for(Case ca : caseList){         
	        if(rtMap.get(ca.RecordTypeId).getName() == 'CC&B Billing Ops Cases' ||
               rtMap.get(ca.RecordTypeId).getName() == 'Closed Work Item - CC&B Billing Ops Cases'){
                    if(ca.Case_Age_Stopped__c == false){
                        if (ca.Third_Party_Response_Required__c ==  'Yes'){		    
                            if(onInsert && ca.Third_Party_Response__c != null){
                                ca.Third_Party_Response_Required__c = null;
                            } 
                            else if(onInsert && ca.Third_Party_Response__c == null){
								ca.Case_Age_Stopped__c = true;
                                ca.Case_Age_Stopped_Start_Date__c = System.now();
                                ca.Third_Party_Response__c = null;
                                ca.Case_Age_Stopped_End_Date__c = null;
                            }
                            else{
                                ca.Case_Age_Stopped__c = true;
                                ca.Case_Age_Stopped_Start_Date__c = System.now();
                                ca.Third_Party_Response__c = null;
                                ca.Case_Age_Stopped_End_Date__c = null;
                           }
                        }
                        if (ca.Customer_Response_Required__c == 'Yes'){
                            if(onInsert && ca.Customer_Response_Resolution__c != null){
                                ca.Customer_Response_Required__c = null;
                            }
							else if(onInsert && ca.Third_Party_Response__c == null){
								ca.Case_Age_Stopped__c = true;
                                ca.Case_Age_Stopped_Start_Date__c = System.now();
                                ca.Third_Party_Response__c = null;
                                ca.Case_Age_Stopped_End_Date__c = null;
                            }
                            else{
                                ca.Case_Age_Stopped__c = true;
                                ca.Case_Age_Stopped_Start_Date__c = System.now();
                                ca.Customer_Response_Resolution__c = null;
                                ca.Case_Age_Stopped_End_Date__c = null;        
							}		
                        }
					}
			}
		}
        
	}

    /*************************************************************************
    * @author         Tae Tran
    * @date           06/24/2015
    * @description    This method START the clock for Case Age
    * @parameters     caseList

    **************************************************************************/
	public static void CaseAgeStartClock(List<Case> caseList,  Map<Id, Case> oldCaseMap){
		Diags.Info('###########ENTERING CaseAgeClock START');// returns the name of the case type                      
	  	BusinessHours bh = [SELECT Id from BusinessHours where name = 'Case Age Business Hours'];
        Decimal temp1 = 0;
        Decimal temp2 = 0;
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById(); // get a list of all case work item type to use for later

		for(Case ca : caseList){
            if(rtMap.get(ca.RecordTypeId).getName() == 'CC&B Billing Ops Cases' || 
              rtMap.get(ca.RecordTypeId).getName() == 'Closed Work Item - CC&B Billing Ops Cases'){
                	System.debug(Logginglevel.info,'@@@@@@@@@CASE WORK ITEM');
                    if(ca.Case_Age_Stopped__c == true){
                       System.debug(Logginglevel.info,'@@@@@@@@@NO ERRORS');                             
                        if (ca.Total_Days_Stopped__c == null) {
                            ca.Total_Days_Stopped__c = 0;
                        }
                        if(ca.CreatedDate == null){
                             //temp = ((((BusinessHours.diff(bh.id, date.today(), date.today()) / 1000) / 60) / 60 ) /24);
                            temp1 = BusinessHours.diff(bh.id, System.now(), System.now()); 
                            temp2 = ((((temp1 / 1000) / 60) / 60 ) /24); 
                        } 
                        else{
                             //temp = ((((BusinessHours.diff(bh.id, ca.CreatedDate, date.today()) / 1000) / 60) / 60 ) /24);
                             temp1 = BusinessHours.diff(bh.id, ca.CreatedDate, System.now()); 
                             temp2 = ((((temp1 / 1000) / 60) / 60 ) /24); 
                        }
                        
                        if (ca.Third_Party_Response__c != null){
                            ca.Third_Party_Response_Required__c = null;
                            if(ca.Customer_Response_Required__c != 'Yes'){
                                ca.Case_Age_Stopped__c = false;
                                ca.Case_Age_Stopped_End_Date__c = System.now(); 
                                decimal tot_stop1 = BusinessHours.diff(bh.id, ca.Case_Age_Stopped_Start_Date__c, ca.Case_Age_Stopped_End_Date__c);
                                decimal tot_stop = ((((tot_stop1 / 1000) / 60) / 60) /24);
                                ca.Total_Days_Stopped__c += tot_stop; //BusinessHours.diff(bh.id, ca.Case_Age_Stopped_Start_Date__c, ca.Case_Age_Stopped_End_Date__c);
                                ca.Case_Age__c = temp2 - ca.Total_Days_Stopped__c;	
                            }
                        } 
                        if (ca.Customer_Response_Resolution__c != null){
                            ca.Customer_Response_Required__c = null;   
                            if (ca.Third_Party_Response_Required__c != 'Yes'){
                                ca.Case_Age_Stopped__c = false;
                                ca.Case_Age_Stopped_End_Date__c = System.now(); 
                                decimal tot_stop1 = BusinessHours.diff(bh.id, ca.Case_Age_Stopped_Start_Date__c, ca.Case_Age_Stopped_End_Date__c);
                                decimal tot_stop = ((((tot_stop1 / 1000) / 60) / 60) /24);
                                ca.Total_Days_Stopped__c += tot_stop; //BusinessHours.diff(bh.id, ca.Case_Age_Stopped_Start_Date__c, ca.Case_Age_Stopped_End_Date__c);
                                ca.Case_Age__c = temp2 - ca.Total_Days_Stopped__c;	
                            }
                        }
						
                        if (oldCaseMap != null){
                            if (ca.Third_Party_Response_Required__c == 'Yes' && oldCaseMap.get(ca.id).Third_Party_Response_Required__c != 'Yes')
                            {
                                ca.Third_Party_Response__c = null;
                            }
                            if (ca.Customer_Response_Required__c == 'Yes' && oldCaseMap.get(ca.id).Customer_Response_Required__c != 'Yes')
                            {
                                    ca.Customer_Response_Resolution__c = null;         
                            }
                            if (ca.Third_Party_Response_Required__c == 'No' && oldCaseMap.get(ca.id).Third_Party_Response_Required__c == 'Yes'){
                                if(ca.Customer_Response_Required__c != 'Yes'){//use to be nul
                                    ca.Case_Age_Stopped__c = false;
                                    ca.Case_Age_Stopped_Start_Date__c = null;
                                    ca.Case_Age__c = temp2 - ca.Total_Days_Stopped__c;			
                                }
                            }
                            else if (ca.Customer_Response_Required__c == 'No' && oldCaseMap.get(ca.id).Customer_Response_Required__c == 'Yes'){
                                if(ca.Third_Party_Response_Required__c !=  'Yes'){ // use to be null
                                    ca.Case_Age_Stopped__c = false;
                                    ca.Case_Age_Stopped_Start_Date__c = null;
                                    ca.Case_Age__c = temp2 - ca.Total_Days_Stopped__c;
                                }
                            }
                   		}    
                    }
            }
		}
        
	}
    
	/*************************************************************************
    * @author         Tae Tran
    * @date           06/24/2015
    * @description    This methods check for errors before
    * @parameters     caseList

    **************************************************************************/
    public static void CaseErrorCheck(List<Case> caseList,  Map<Id, Case> oldCaseMap){         
	//public static void CaseErrorCheck(List<Case> caseList,  Map<Id, Case> oldCaseMap){  
	Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById(); // get a list of all case work item type to use for later
		for(Case ca : caseList){
                if(rtMap.get(ca.RecordTypeId).getName() == 'CC&B Billing Ops Cases'){
 					System.debug(Logginglevel.info,'@@@@@@@@@CASE WORK ITEM');

                    if (ca.Third_Party_Response_Required__c == 'No' && ca.Third_Party_Response__c != null){ // check error
                        ca.addError('Third Party Response Required cannot be NO if Third Party Response is filled');
                    }
                    else if (ca.Customer_Response_Required__c == 'No' && ca.Customer_Response_Resolution__c != null){
                        ca.addError('Customer Response Required cannot be NO if Customer Response Resolution is filled');
                    }
    
                    if (oldCaseMap != null) {
                        if((oldCaseMap.get(ca.id).Third_Party_Response_Required__c == 'Yes' ||
                            oldCaseMap.get(ca.id).Third_Party_Response_Required__c == 'No') && 
                            ca.Third_Party_Response_Required__c == null){
                            ca.addError('Third Party Response Required can only be YES or NO');
                   
                        }
                        if((oldCaseMap.get(ca.id).Customer_Response_Required__c == 'Yes' || 
                              oldCaseMap.get(ca.id).Customer_Response_Required__c == 'No') && 
                              ca.Customer_Response_Required__c == null || ca.Customer_Response_Required__c == '' ){
                              ca.addError('Customer Response Required can only be YES or NO');
                        }
						if(ca.Third_Party_Response_Required__c == 'No' && 
                           oldCaseMap.get(ca.id).Third_Party_Response_Required__c != 'Yes'){
					  		ca.addError('Third Party Response Required cannot be No if previous value was blank');
                		}
                        if(ca.Customer_Response_Required__c == 'No' && 
                           oldCaseMap.get(ca.id).Customer_Response_Required__c != 'Yes'){              
	                   	  	ca.addError('Customer Response Required cannot be No if previous value was blank');
    	                }
            		}
     	       }
    	}
    }
}