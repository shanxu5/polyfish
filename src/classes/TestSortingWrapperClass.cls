@isTest 
private class TestSortingWrapperClass {
    static testmethod void testDESC() {
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(p.id,r.id,2); admin.LAN_ID__C = 'ADM1'; insert admin;
        System.runAs(admin){
            List<Work_Item_Assignment__c> wlist = new List<Work_Item_Assignment__c>();
            Work_Item_Assignment__c wia= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=10,Limit__c=20 );  wlist.add(wia);
            Work_Item_Assignment__c wia2= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=9,Limit__c=20 );  wlist.add(wia2);
            Work_Item_Assignment__c wia3= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=12,Limit__c=20 );  wlist.add(wia3);
            Work_Item_Assignment__c wia4= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=8,Limit__c=20 );  wlist.add(wia4);
            Work_Item_Assignment__c wia5= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=13,Limit__c=20 );  wlist.add(wia5);
            Work_Item_Assignment__c wia6= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=16,Limit__c=20 );  wlist.add(wia6);
            Work_Item_Assignment__c wia7= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=1,Limit__c=20 ); wlist.add(wia7);
            insert wlist;
            wList = UserSkillRuleUtility.sortUserSkillsList(wlist, 'DESC', 'Load_Score__c');
            system.assertEquals(null, wList[0].Load_Score__c); 
            wlist = [select WI_Assigned__c from Work_Item_Assignment__c];
            wList = UserSkillRuleUtility.sortUserSkillsList(wlist, 'DESC', 'WI_Assigned__c');
            system.assertEquals(16, wList[0].WI_Assigned__c); 
        }      
    }
    static testmethod void testASC() {
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(p.id,r.id,2); admin.LAN_ID__C = 'ADM1'; insert admin;
        System.runAs(admin){
            List<Work_Item_Assignment__c> wlist = new List<Work_Item_Assignment__c>();
            Work_Item_Assignment__c wia= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=10,Limit__c=20 );  wlist.add(wia);
            Work_Item_Assignment__c wia2= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=9,Limit__c=20 );  wlist.add(wia2);
            Work_Item_Assignment__c wia3= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=12,Limit__c=20 );  wlist.add(wia3);
            Work_Item_Assignment__c wia4= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=8,Limit__c=20 );  wlist.add(wia4);
            Work_Item_Assignment__c wia5= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=13,Limit__c=20 );  wlist.add(wia5);
            Work_Item_Assignment__c wia6= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=16,Limit__c=20 );  wlist.add(wia6);
            Work_Item_Assignment__c wia7= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=1,Limit__c=20 ); wlist.add(wia7);
            insert wlist;
            wList = UserSkillRuleUtility.sortUserSkillsList(wlist, 'ASC', 'WI_Assigned__c');
            system.assertEquals(1, wList[0].WI_Assigned__c); 
        }      
    }
}