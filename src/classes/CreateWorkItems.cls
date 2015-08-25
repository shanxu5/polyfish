/**********************************************************************************************
* @author       Janella Espiritu
* @date         December 2014
* @description  This class creates Work Items by accessing data loaded by ETL into Integration Joint object
* @version      1.1
* @revision(s)  Yefim Shuster on 2015-04-07 - Defect 154 - cannot complete WIs - new version is 1.1
**********************************************************************************************/
global without sharing class CreateWorkItems implements Database.Batchable<sObject>, Database.Stateful{
  global Database.QueryLocator Start(Database.BatchableContext bc) {
      // Query string to query all Integration Joint records
        String query = 'SELECT AccountId__c, ' +
                    'Bill_After_Dt__c, ' +
                    'Bill_Cycle__c, ' +
                    'Commencing_Bill__c, ' +
                    'DA_CCA_IND__c, ' +
                    'Event_Date__c, ' +
                    'Error_Log__c, ' +
                    'Exception_Message_Text__c, ' +
                    'Hold__c, ' +
                            'Int_WI_Key__c, ' +
                    'Last_BSEG_End_Dt__c,' +
                    'Local_Office__c, ' +
                    'Message_Number__c, ' +
                    'Message_Category_Number__c, ' +
                    'Meter_Read_Cycle__c, ' +
                    'Mtr_Config_Ty_Cd__c, ' + 
                    'ParentId__c, ' +
                    'QAS8_Date__c, ' +
                    'Rate_Schedule__c, ' +
                    'Recreated__c, ' +
                    'Reopen__c, ' +
                    'SA_Create_Date__c, ' +
                    'SA_Relationship_Date__c, ' +
                    'SA_Status__c, ' +
                    'SFDC_Prem_ID__c,' +
                    'SFDC_SA_ID__c, ' +
                            'SFDC_SP_ID__c, ' +
                    'SFDC_WI_Key__c,' +
                    'SmartMeter_SP_Status_Description__c, ' +
                    'SMSPST__c, ' +
                    'SMSPST_EffDt__c, ' +
                    'SPR_CD__c, ' +
                    'SPR_Descr__c,' +
                    'WI_OwnerId__c, ' +
                    'WI_Tran_Type__c, ' +
                    'Work_Item_Type__c, ' +
                    'WorkItemId__c ' +
                    'from Integration_Joint__c ' +
                  'order by AccountId__c';
        // Execute query
        return Database.getQueryLocator(query);
    }
    global void Execute(Database.BatchableContext bc, List<Integration_Joint__c> integJointList) {
        List<Case> ADRCcaseList = new List<Case>();
        List<Case> UDcaseList = new List<Case>();
        List<Case> DScaseList = new List<Case>();
        List<Case> ROcaseList = new List<Case>();
        List<Integration_Joint__c> ADRCijList = new List<Integration_Joint__c>();
        List<Integration_Joint__c> UDijList = new List<Integration_Joint__c>();
        List<Integration_Joint__c> DSijList = new List<Integration_Joint__c>();
        List<Integration_Joint__c> ROijList = new List<Integration_Joint__c>();
        for(Integration_Joint__c ij : integJointList){
            if(ij.Error_Log__c != 'Successful'){
                if(ij.WI_Tran_Type__c == 'AD' || ij.WI_Tran_Type__c == 'RC'){
                    Case c = new Case();
                    c.AccountId = ij.AccountId__c;
                    c.Bill_After_Dt__c = ij.Bill_After_Dt__c;
                    c.Bill_Cycle__c = ij.Bill_Cycle__c;
                    c.Commencing_Bill__c = ij.Commencing_Bill__c;
                    c.DA_CCA_IND__c = ij.DA_CCA_IND__c;
                    c.Event_Date__c = ij.Event_Date__c;
                    c.Exception_Message_Text__c = ij.Exception_Message_Text__c;
                    c.Hold__c = ij.Hold__c;
                    c.Int_WI_Key__c = ij.Int_WI_Key__c;
                    c.Last_BSEG_End_Dt__c = ij.Last_BSEG_End_Dt__c;
                    c.Local_Office__c = ij.Local_Office__c;
                    c.Message_Number__c = ij.Message_Number__c;
                    c.Message_Category_Number__c = ij.Message_Category_Number__c;
                    c.Meter_Read_Cycle__c = ij.Meter_Read_Cycle__c;
                    c.Mtr_Config_Ty_Cd__c = ij.Mtr_Config_Ty_Cd__c;
                    c.ParentId = ij.ParentId__c;
                    
                    // Modified by YXS7 on 2015-04-07 - Defect 154 - added below
                    c.IsParent__c = (ij.ParentId__c == null ? true : false);
                    
                    system.debug('*****'+ c.ParentId + ij.ParentId__c);
                    c.QAS8_Date__c = ij.QAS8_Date__c;
                    c.Rate_Schedule__c = ij.Rate_Schedule__c;
                    c.Recreated__c = ij.Recreated__c;
                    c.Reopened__c = ij.Reopen__c;
                    c.SA_Relationship_Date__c = ij.SA_Relationship_Date__c;
                    c.SA_Status__c = ij.SA_Status__c;
                    c.SFDC_Prem_ID__c = ij.SFDC_Prem_ID__c;
                    c.SFDC_SA_ID__c = ij.SFDC_SA_ID__c;
                    c.SFDC_SP_ID__c = ij.SFDC_SP_ID__c;
                    c.SFDC_WI_Key__c = ij.SFDC_WI_Key__c;
                    c.SmartMeter_SP_Status_Description__c = ij.SmartMeter_SP_Status_Description__c;
                    c.SMSPST__c = ij.SMSPST__c;
                    c.SMSPST_EffDt__c = ij.SMSPST_EffDt__c;
                    c.SPR_CD__c = ij.SPR_CD__c;
                    c.SPR_Descr__c = ij.SPR_Descr__c;
                    c.OwnerId = ij.WI_OwnerId__c;
                    c.Work_Item_Type__c = ij.Work_Item_Type__c;
                    c.SA_Create_Date__c = ij.SA_Create_Date__c;
                    ADRCcaseList.add(c);
                    ADRCijList.add(ij);
                }
                else if(ij.WI_Tran_Type__c == 'RO'){
                    Case c = new Case();
                    c.Id = ij.WorkItemId__c;
                    c.AccountId = ij.AccountId__c;
                    c.Bill_After_Dt__c = ij.Bill_After_Dt__c;
                    c.Bill_Cycle__c = ij.Bill_Cycle__c;
                    c.Commencing_Bill__c = ij.Commencing_Bill__c;
                    c.DA_CCA_IND__c = ij.DA_CCA_IND__c;
                    c.Event_Date__c = ij.Event_Date__c;
                    c.Exception_Message_Text__c = ij.Exception_Message_Text__c;
                    c.Hold__c = ij.Hold__c;
                    c.Int_WI_Key__c = ij.Int_WI_Key__c;
                    c.Last_BSEG_End_Dt__c = ij.Last_BSEG_End_Dt__c;
                    c.Local_Office__c = ij.Local_Office__c;
                    c.Message_Number__c = ij.Message_Number__c;
                    c.Message_Category_Number__c = ij.Message_Category_Number__c;
                    c.Meter_Read_Cycle__c = ij.Meter_Read_Cycle__c;
                    c.Mtr_Config_Ty_Cd__c = ij.Mtr_Config_Ty_Cd__c;
                    c.ParentId = ij.ParentId__c;
                    
                    // Modified by YXS7 on 2015-04-07 - Defect 154 - added below
                    c.IsParent__c = (ij.ParentId__c == null ? true : false);
                    
                    c.QAS8_Date__c = ij.QAS8_Date__c;
                    c.Rate_Schedule__c = ij.Rate_Schedule__c;
                    c.Recreated__c = ij.Recreated__c;
                    c.Reopened__c = ij.Reopen__c;
                    c.SA_Relationship_Date__c = ij.SA_Relationship_Date__c;
                    c.SA_Status__c = ij.SA_Status__c;
                    c.SFDC_Prem_ID__c = ij.SFDC_Prem_ID__c;
                    c.SFDC_SA_ID__c = ij.SFDC_SA_ID__c;
                    c.SFDC_SP_ID__c = ij.SFDC_SP_ID__c;
                    c.SFDC_WI_Key__c = ij.SFDC_WI_Key__c;
                    c.SmartMeter_SP_Status_Description__c = ij.SmartMeter_SP_Status_Description__c;
                    c.SMSPST__c = ij.SMSPST__c;
                    c.SMSPST_EffDt__c = ij.SMSPST_EffDt__c;
                    c.SPR_CD__c = ij.SPR_CD__c;
                    c.SPR_Descr__c = ij.SPR_Descr__c;
                    c.Work_Item_Type__c = ij.Work_Item_Type__c;
                    c.SA_Create_Date__c = ij.SA_Create_Date__c;
                    ROcaseList.add(c);
                    ROijList.add(ij);
                }
                else if(ij.WI_Tran_Type__c == 'UD'){
                    Case c = new Case();
                    c.Id = ij.WorkItemId__c; 
                    c.SA_Create_Date__c = ij.SA_Create_Date__c;
                    c.Hold__c = ij.Hold__c;
                    c.Event_Date__c = ij.Event_Date__c; 
                    c.Exception_Message_Text__c = ij.Exception_Message_Text__c;
                    c.Message_Number__c = ij.Message_Number__c; 
                    c.Message_Category_Number__c = ij.Message_Category_Number__c; 
                    c.QAS8_Date__c = ij.QAS8_Date__c; 
                    c.Reopened__c = ij.Reopen__c; 
                    UDcaseList.add(c);
                    UDijList.add(ij);
                }
                else if(ij.WI_Tran_Type__c == 'DS'){
                    Case c = new Case();
                    c.Id = ij.WorkItemId__c; 
                    c.Bill_After_Dt__c = ij.Bill_After_Dt__c;
                    c.Commencing_Bill__c = ij.Commencing_Bill__c;
                    c.Local_Office__c = ij.Local_Office__c;
                    DScaseList.add(c);
                    DSijList.add(ij);
                }
            }
        }
        List<Integration_Joint__c> intJoinUpdate = new List<Integration_Joint__c>();
        List<Integration_Joint__c> intJoinUpdatelist = new List<Integration_Joint__c>();
        Set<Id> updatedSet = new Set<Id>();
        if(ADRCcaseList.size() > 0){
            system.debug('****ADRCcaseList OK');
            intJoinUpdate = new List<Integration_Joint__c>();
            Integer index = 0;
            for(Database.UpsertResult dur : Database.upsert(ADRCcaseList,Case.Fields.Id,false)){
                system.debug('***dur.isSuccess(): '+ dur.isSuccess());
                if(!dur.isSuccess()){
                    String errMsg = dur.getErrors()[0].getMessage();
                    ADRCijList[index].Error_Log__c = errMsg; 
                }
                else{
                    ADRCijList[index].Error_Log__c = 'Successful';
                }
                if(!updatedSet.contains(ADRCijList[index].Id)){
                    intJoinUpdateList.add(ADRCijList[index]);  
                    intJoinUpdate.add(ADRCijList[index]);    
                    updatedSet.add(ADRCijList[index].Id);
                }
                system.debug('***AD/RC ADRCijList[index].Error_Log__c: '+ ADRCijList[index].Error_Log__c);
                index++;
                
            }
            if(intJoinUpdate.size() > 0){
                intJoinUpdate = new List<Integration_Joint__c>();
            }
        }
        if(ROcaseList.size() > 0){
            system.debug('****ROcaseList OK');
            intJoinUpdate = new List<Integration_Joint__c>();
            Integer index = 0;
            for(Database.UpsertResult dur : Database.upsert(ROcaseList,Case.Fields.Id,false)){
                system.debug('***dur.isSuccess(): '+ dur.isSuccess());
                if(!dur.isSuccess()){
                    String errMsg = dur.getErrors()[0].getMessage();
                    ROijList[index].Error_Log__c = errMsg; 
                }
                else{
                    ROijList[index].Error_Log__c = 'Successful';
                }
                if(!updatedSet.contains(ROijList[index].Id)){
                    intJoinUpdateList.add(ROijList[index]);  
                    intJoinUpdate.add(ROijList[index]);    
                    updatedSet.add(ROijList[index].Id);
                }
                system.debug('***RO integJointList[index].Error_Log__c: '+ ROijList[index].Error_Log__c);
                index++;
                
            }
            if(intJoinUpdate.size() > 0){
                intJoinUpdate = new List<Integration_Joint__c>();
            }
        }
        if(UDcaseList.size() > 0){
            system.debug('****UDcaseList OK');
            intJoinUpdate = new List<Integration_Joint__c>();
            Integer index = 0;
            for(Database.UpsertResult dur : Database.upsert(UDcaseList,Case.Fields.Id,false)){
                system.debug('***dur.isSuccess(): '+ dur.isSuccess());
                if(!dur.isSuccess()){
                    String errMsg = dur.getErrors()[0].getMessage();
                    UDijList[index].Error_Log__c = errMsg; 
                }
                else{
                    UDijList[index].Error_Log__c = 'Successful';
                }
                if(!updatedSet.contains(UDijList[index].Id)){
                    intJoinUpdateList.add(UDijList[index]);  
                    intJoinUpdate.add(UDijList[index]);    
                    updatedSet.add(UDijList[index].Id);
                }
                system.debug('***UD integJointList[index].Error_Log__c: '+ UDijList[index].Error_Log__c);
                index++;
                
            }
            if(intJoinUpdate.size() > 0){
                intJoinUpdate = new List<Integration_Joint__c>();
            }
        }
        if(DScaseList.size() > 0){
            system.debug('****DScaseList OK');
            intJoinUpdate = new List<Integration_Joint__c>();
            Integer index = 0;
            for(Database.UpsertResult dur : Database.upsert(DScaseList,Case.Fields.Id,false)){
                system.debug('***dur.isSuccess(): '+ dur.isSuccess());
                if(!dur.isSuccess()){
                    String errMsg = dur.getErrors()[0].getMessage();
                    DSijList[index].Error_Log__c = errMsg; 
                }
                else{
                    DSijList[index].Error_Log__c = 'Successful';
                }
                if(!updatedSet.contains(DSijList[index].Id)){
                    intJoinUpdateList.add(DSijList[index]);  
                    intJoinUpdate.add(DSijList[index]);    
                    updatedSet.add(DSijList[index].Id);
                }
                system.debug('***DS integJointList[index].Error_Log__c: '+ DSijList[index].Error_Log__c);
                index++;
                
            }
            if(intJoinUpdate.size() > 0){
                intJoinUpdate = new List<Integration_Joint__c>();
            }
        }
        system.debug('***intJoinUpdateList: '+ intJoinUpdateList);
        if(intJoinUpdateList.size() > 0){
            update intJoinUpdateList;
        }
    }    
    global void Finish(Database.BatchableContext bc) {
        // Call batch job to delete records
        DeleteIntegrationJointRecords deleteRecords = new DeleteIntegrationJointRecords();
        database.executeBatch(deleteRecords, 2000);
    }
}