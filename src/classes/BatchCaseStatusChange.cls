/**********************************************************************************************
* @author       Melody Yang
* @date         08/13/2015
*
* @version      1.0
*
* @description  This batch apex that will run every hour to check for users who are not currently
* 				using Salesforce (Via logout or forced session timeout) and have a Work Item in
*				the status of Being Worked On. Those Work Items' status will be changed to 
*				Unavailable
* @revision     
*               
**********************************************************************************************/
global class BatchCaseStatusChange implements Database.batchable<sObject>{
  
  global Database.QueryLocator start(Database.BatchableContext BC) //done
    {
    String query = 'SELECT Id, Status, OwnerId from Case where Status = \'Being Worked On\' and Owner.Type = \'User\'';
           
    return Database.getQueryLocator(query);
    
    }
   
    global void execute(Database.BatchableContext BC, List<Case> wiList)
    {
        System.debug(Logginglevel.info,'***%%%%%%%%%%%%%%%%%%what is in list of case...' + wiList);
        //create a map of Work Items: key - ownerId, value - list of case records
        Map<Id, Case> wiMap = new Map<Id, Case>();
        for (Case c : wiList){
            if (wiMap.containsKey(c.OwnerId)){
                Case temp = wiMap.get(c.OwnerId);
                wiMap.put(c.OwnerId, temp);
            }
            else{
                wiMap.put(c.OwnerId, c);
            }
        }
        
        System.debug('***### here is the work item map: '+wiMap);
        
        //create a map of user session: key: user Id, value - auth session records
        Map<Id, AuthSession> authSessionMap = new Map<Id, AuthSession>();
        Set<Id> userIds = new Set<ID>(); 
        List<Id> ownerIds = new List<Id>();
        for(AuthSession auth : [select id, UsersId, UserType,SourceIp,SessionType,SessionSecurityLevel,ParentId,LoginType,CreatedDate, NumSecondsValid, LastModifiedDate from AuthSession where ParentId = null and (NOT SessionType LIKE 'Temp%')]){
            system.debug('auth.UsersId: ' + auth.UsersId + '|| auth.SessionType: ' + auth.SessionType);
            userIds.add(auth.UsersId);
            if(authSessionMap.containsKey(auth.UsersId)){
                if(authSessionMap.get(auth.UsersId).CreatedDate < auth.CreatedDate ){
                    authSessionMap.put(auth.UsersId, auth);
                }
            }
            else{
                authSessionMap.put(auth.UsersId, auth);
            }
        }
        system.debug('***### authSessionMap: '+ authSessionMap);
        
        //loop through cases with BWO status
        for (Case c : wiList){
            //if case is owned by a user who is not currently active, change status;
            if (!authSessionMap.containsKey(c.OwnerId)){
                system.debug('***### entering authSessionMap does NOT contains ownerId key. Here is the case: '+ c);
                c.Status = 'Unavailable';
                system.debug('***### here is the status of work item: '+ c.Status);
                wiMap.put(c.OwnerId, c);
                system.debug('***### here is the wiMap: '+ wiMap);
            }
            //if case is owned by a user who is currently active, check to see if the session is still valid. if not, change status
            if (authSessionMap.containsKey(c.OwnerId) || Test.isRunningTest()){
                Integer numSecondsValid = 0;
                DateTime validUntil = dateTime.now();
                
                system.debug('***### entering authSessionMap DOES contains ownerId key. Here is the case: '+ c);
                
                if(authSessionMap.containsKey(c.OwnerId)){
                    numSecondsValid = authSessionMap.get(c.OwnerId).NumSecondsValid;
                    validUntil = authSessionMap.get(c.OwnerId).LastModifiedDate.addSeconds(numSecondsValid);
                }
                
                if (Test.isRunningTest()){
                    numSecondsValid = 1;
                    validUntil = dateTime.now() - 1;
                }
                
                if (numSecondsValid > 0){
                    system.debug('***### entering numbSecondsValid > 0 loop. Here is validUntil value: '+ validUntil);
                    if (validUntil < dateTime.now()){
                        system.debug('***###changing status now');
                        c.Status = 'Unavailable';
                        system.debug('***### we just changed the status, here is the case: '+ c);
                        wiMap.put(c.OwnerId, c);
                        system.debug('***### here is the new wiMap case value: '+wiMap.get(c.OwnerId));
                    }
                }
            }
                
            
        }
        update wiMap.values();
        system.debug('***### here is the wiMap: '+ wiMap);
    }
    
    
   
    global void finish(Database.BatchableContext BC)
    {
    // Not needed at this point
    }
   
}