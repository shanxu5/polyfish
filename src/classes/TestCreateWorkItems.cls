@isTest
public class TestCreateWorkItems {
    static testmethod void testCreateWorkItems(){
        // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Exceptions').getRecordTypeId();
        
        // Create Account
        Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); 
        acc.Postpone_Credit_Date__c = date.today();
        insert acc;
        // Create Service Agreement
        Service_Agreement__c SA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert SA;
        // Create Premise
        Premise__c prem = TestUtility.createPremise(); insert prem;
        // Create Service Point
        Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
        // Create Work Item
        Case WorkItem = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, SA.Id, true, prem.Id, sp.Id, queueId, recordtypeId);  insert WorkItem;
        Case WorkItem2 = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, SA.Id, true, prem.Id, sp.Id, queueId, recordtypeId);  insert WorkItem2;
        Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, SA.Id, true, prem.Id, sp.Id, queueId, recordtypeId);  insert WorkItem3;
        List<Integration_Joint__c> ijList = new List<Integration_Joint__c>();
        for(Integer i = 0; i < 5; i++){
            Integration_Joint__c ij = new Integration_Joint__c();
            ij.AccountId__c = acc.Id;
            ij.Bill_After_Dt__c = date.today();
            ij.Bill_Cycle__c = 'B';
            ij.Commencing_Bill__c = true;
            ij.DA_CCA_IND__c = true;
            ij.Event_Date__c = date.today() -100;
            ij.Exception_Message_Text__c = null;
            ij.Hold__c = false;
            ij.Int_WI_Key__c = 'QAS8_1428836020';
            ij.Last_BSEG_End_Dt__c = date.today() - 300;
            ij.Local_Office__c = 'BJ';
            ij.Message_Number__c = null;
            ij.Message_Category_Number__c = null;
            ij.Meter_Read_Cycle__c = 'F';
            ij.Mtr_Config_Ty_Cd__c = 'SM-15-SIMPLE';
            ij.ParentId__c = null;
            ij.QAS8_Date__c = date.today() - 54;
            ij.Rate_Schedule__c ='AG1A';
            ij.Recreated__c = false;
            ij.Reopen__c = false;
            ij.SA_Relationship_Date__c = date.today() - 1000;
            ij.SA_Status__c ='Active';
            ij.SFDC_Prem_ID__c = prem.Id;
            ij.SFDC_SA_ID__c = SA.Id;
            ij.SFDC_SP_ID__c = sp.Id;
            ij.SFDC_WI_Key__c = 'QAS8_1428836020';
            ij.SmartMeter_SP_Status_Description__c ='SM- Enabled';
            ij.SMSPST__c ='20';
            ij.SMSPST_EffDt__c = date.today() - 1000;
            ij.SPR_CD__c ='PGE-FS';
            ij.SPR_Descr__c ='PG&E, ESP, Bundled Service';
            ij.WI_OwnerId__c ='00Gq0000000QTOFEA4';
            ij.Work_Item_Type__c ='QAS8';
            ij.SA_Create_Date__c = null;
            ij.WI_Tran_Type__c = 'AD';
            ijList.add(ij);
        }
        for(Integer i = 0; i < 5; i++){
            Integration_Joint__c ij = new Integration_Joint__c();
            ij.AccountId__c = acc.Id;
            ij.Bill_After_Dt__c = date.today();
            ij.Bill_Cycle__c = 'B';
            ij.Commencing_Bill__c = true;
            ij.DA_CCA_IND__c = true;
            ij.Event_Date__c = date.today() -100;
            ij.Exception_Message_Text__c = null;
            ij.Hold__c = false;
            ij.Int_WI_Key__c = 'QAS8_1428836020';
            ij.Last_BSEG_End_Dt__c = date.today() - 300;
            ij.Local_Office__c = 'BJ';
            ij.Message_Number__c = null;
            ij.Message_Category_Number__c = null;
            ij.Meter_Read_Cycle__c = 'F';
            ij.Mtr_Config_Ty_Cd__c = 'SM-15-SIMPLE';
            ij.ParentId__c = null;
            ij.QAS8_Date__c = date.today() - 54;
            ij.Rate_Schedule__c ='AG1A';
            ij.Recreated__c = false;
            ij.Reopen__c = true;
            ij.SA_Relationship_Date__c = date.today() - 1000;
            ij.SA_Status__c ='Active';
            ij.SFDC_Prem_ID__c = prem.Id;
            ij.SFDC_SA_ID__c = SA.Id;
            ij.SFDC_SP_ID__c = sp.Id;
            ij.SFDC_WI_Key__c = 'QAS8_1428836020';
            ij.SmartMeter_SP_Status_Description__c ='SM- Enabled';
            ij.SMSPST__c ='20';
            ij.SMSPST_EffDt__c = date.today() - 1000;
            ij.SPR_CD__c ='PGE-FS';
            ij.SPR_Descr__c ='PG&E, ESP, Bundled Service';
            ij.WI_OwnerId__c ='00Gq0000000QTOFEA4';
            ij.Work_Item_Type__c ='QAS8';
            ij.SA_Create_Date__c = null;
            ij.WI_Tran_Type__c = 'RO';
            ijList.add(ij);
        }
        //for(Integer i = 0; i < 5; i++){
            Integration_Joint__c ij2 = new Integration_Joint__c();
            ij2.WorkItemId__c = WorkItem2.Id; 
            ij2.SA_Create_Date__c = date.today();
            ij2.Hold__c = false;
            ij2.Event_Date__c = date.today(); 
            ij2.Exception_Message_Text__c = null;
            ij2.Message_Number__c = null; 
            ij2.Message_Category_Number__c = null; 
            ij2.QAS8_Date__c = null; 
            ij2.Reopen__c = false; 
            ij2.WI_Tran_Type__c = 'UD';
            ijList.add(ij2);
        //}
        //for(Integer i = 0; i < 5; i++){
            Integration_Joint__c ij3 = new Integration_Joint__c();
            ij3.WorkItemId__c = WorkItem3.Id; 
            ij3.Bill_After_Dt__c = date.today();
            ij3.Commencing_Bill__c = true;
            ij3.Local_Office__c = 'BJ';
            ij3.WI_Tran_Type__c = 'DS';
            ijList.add(ij3);
        //}
        insert ijList;
        CreateWorkItems cwi = new CreateWorkItems();
		database.executeBatch(cwi,1000);
    }
}