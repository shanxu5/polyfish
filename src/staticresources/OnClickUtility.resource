// Added below by yxs7 on 2014-10-30
function isBeingWorkedOnForOtherParent(caseId, apiSessionId, userId){
    //alert('isBeingWorkedOnForOtherParent');
    //caseId is either a Parent WI id or a Child WI id
    //If WI is clicked and this WI is a Parent WI, make it "being worked on", unless there are other Parent WIs that are already "being worked on" or Child WIs of other Parent WIs that are already "being worked on"
    //If WI is clicked and this WI is a Child WI, make it "being worked on", unless there are different Parent WIs that are already "being worked on" or Child WIs of other Parent WIs that are already "being worked on"
    var myquery = "SELECT Id FROM Case WHERE OwnerId = '"+userId+"' and ((ParentId != '" + caseId + "' and Id != '" + caseId + "') or (ParentId = null and Id != '" + caseId + "')) and (Status = 'Being Worked On'  OR Status = 'Unavailable') LIMIT 1";
    //Session  
    sforce.connection.sessionId = apiSessionId; 
    var result = sforce.connection.query(myquery);
    var records = result.getArray("records");
    if (records && records.length > 0 && records[0].Id != '') {
        return true;
    }
    return false;
}

function updateWorkItemToBeingWorkedOn(sessionId, CID, userId){
    
    //Session  
    sforce.connection.sessionId = sessionId; 
    
    //Case instance  
    var update_Case = new sforce.SObject("Case");
    
    //Work Item that needs to be assigned
    update_Case.Id = CID;  
    
    //Change the status to Being worked on  
    update_Case.Status = 'Being Worked On';
    if(userId != null){
        update_Case.OwnerId = userId;
    }
    //update_Case.Sub_Status__c = '  ';
    update_Case.Sub_Status__c = null;
    // Modified by yxs7 on 2014-11-10 - added below
    // Clear Pending - Other Reason field when Status is changed to Being Worked On
    update_Case.Pending_Other_Reason__c = null;
    
    //Keeping the array in case if we need to extend this for bulk case update  
    var updateRecords = [];  
    
    //Adding records to array
    updateRecords.push(update_Case); 
    
    //Updating the Work Item Status 
    var result = sforce.connection.update(updateRecords); 
}

function redirectToRfr(rfr){
    if (top != self) {
        top.location.replace(rfr);
    }
    else {window.location.replace(rfr);}
}

function alertIsBeingWorkedOnByOtherCSR(){
    alert ('This Work Item is already being worked on by another CSR, you cannot self assign this work Item.'); 
}
function alertIsBeingWorkedOn(){
    alert ("A Work Item in Status 'Being Worked On' or 'Unavailable' already exists. This Work Item cannot be self-assigned.");
}