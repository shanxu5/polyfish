/**********************************************************************************************
* @author       Janella Espiritu
* @date         06/22/2015
* @description  This class holds all the methods for the Shift vs Core Hours
* @version      1.0
* @revision(s)  Janella Espiritu - 06/22/2015 - Created updateBusinessHoursOnComplete
				Janella Espiritu - 06/22/2015 - Created updateBusinessHoursOnCreateOfShiftTimes
**********************************************************************************************/
public class ShiftTimesUtility {
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           06/22/2015
    * @description    This method will update the Business Hours every 
						time a work item is completed
    * @parameters     completedWIs - List of Work Items completed
    **************************************************************************/
    public static void updateBusinessHoursOnComplete(List<Case> completedWIs){
		// Instantiate Variables
        Set<Id> wiaIds = new Set<Id>();
        Set<Id> businessHourIds = new Set<Id>();
        Map<Id,Id> wiaShiftTimeMap = new Map<Id,Id>();
        Map<Id,Id> wiaCoreHoursMap = new Map<Id,Id>();
		// Loop completed work items
        for(Case wi : completedWIs){
			// If the sub status is 'Completed by Assigned User',
			// collect the Work Item Assignment Id
			if(wi.Sub_Status__c == 'Completed by Assigned User'){
				wiaIds.add(wi.Work_Item_Assignment__c);
			}
        }
        // Query Work Item Assignment Core Hours
		// Put Core Hours in a map
		// Collect Business Hour Ids
        for(Work_Item_Assignment__c wia : [select Id, Business_Hours__c from Work_Item_Assignment__c where Id =: wiaIds]){
            wiaCoreHoursMap.put(wia.Id, wia.Business_Hours__c);
            businessHourIds.add(wia.Business_Hours__c);
        }
        // Query Shift Times related to the Work Item Assignment that is within the Closed Date
		// Put Shift Times in a map
		// Collect Business Hour Ids
        for(Shift_Time_Change__c st : [select Id, 
                                                       Business_Hours__c, 
                                                       From_Date__c, 
                                                       To_Date__c,
                                                       Work_Item_Assignment__c
                                                       from Shift_Time_Change__c
                                                       where Work_Item_Assignment__c IN: wiaIds
                                                       and From_Date__c <= :date.today()
                                                       and To_Date__c >= :date.today()
                                                       order by CreatedDate]){
            businessHourIds.add(st.Business_Hours__c);
            wiaShiftTimeMap.put(st.Work_Item_Assignment__c, st.Business_Hours__c);
        }
		// Loop completed work items
        for(Case wi : completedWIs){
			// If the work item assignment has core hours,
			// Assign that core hours to the work item
            if(wiaCoreHoursMap.containsKey(wi.Work_Item_Assignment__c)){
                wi.BusinessHoursId = wiaCoreHoursMap.get(wi.Work_Item_Assignment__c);
				// If there is a shift time available,
				// Assign that business hour to the work item
            	if(wiaShiftTimeMap.containsKey(wi.Work_Item_Assignment__c)){
                	wi.BusinessHoursId = wiaShiftTimeMap.get(wi.Work_Item_Assignment__c);
            	}
				// If now is not within the business hours,
				// check Overtime
                if(!BusinessHours.isWithin(wi.BusinessHoursId, datetime.now())){
                    wi.Overtime__c = true;
            	}
            }
        }
    }
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           06/22/2015
    * @description    This method will update the Business Hours every 
						time a shift time has been created with from/to 
						date in the past
    * @parameters     completedWIs - List of Work Items completed
    **************************************************************************/
	public static void updateBusinessHoursOnCreateOfShiftTimes(List<Shift_Time_Change__c> shiftTimes){
		Diags.Enter('ShiftTimesUtility.updateBusinessHoursOnCreateOfShiftTimes');
		Diags.Info(String.valueOf(shiftTimes.size()));
		// Instantiate variables
        Set<Id> wiaIds = new Set<Id>();
		Map<Id,Shift_Time_Change__c> wiaShiftTimeMap = new Map<Id,Shift_Time_Change__c>();
		List<Case> workItemsUpdate = new List<Case>();
		// Loop created shift times
		for(Shift_Time_Change__c st : shiftTimes){
			// Validate that the shift time dates are in the past,
			// if so, put in a map
			if(st.From_Date__c <= date.today()){
				wiaIds.add(st.Work_Item_Assignment__c);
				wiaShiftTimeMap.put(st.Work_Item_Assignment__c, st);
			}
		}
        Diags.Info('***wiaShiftTimeMap: '+String.valueOf(wiaShiftTimeMap));
		if(wiaIds.size() > 0){
			// Query work items that are Completed, Completed by Assigned User 
			// and has the work item assignment collected
			List<Case> workItems = [SELECT Id, Work_Item_Assignment__c, ClosedDate, Work_Item_Assignment__r.Business_Hours__c FROM Case 
										WHERE Work_Item_Assignment__c IN: wiaIds 
										AND Status = 'Completed' 
										//AND Sub_Status__c = 'Completed by Assigned User'
                                        ];
			// If there are work items queried
			if(workItems.size() > 0){
				for(Case wi : workItems){
                    wi.BusinessHoursId = wi.Work_Item_Assignment__r.Business_Hours__c;
					// If there is a shift time available for the work item assignment
					if(wiaShiftTimeMap.containsKey(wi.Work_Item_Assignment__c)){
						Shift_Time_Change__c st = wiaShiftTimeMap.get(wi.Work_Item_Assignment__c);
                        Diags.Info('***st: '+st);
						// if the work item closed date is within shift time From/To Dates,
						// Assign the business hour to the work item
						Date closedDate = date.newinstance(wi.ClosedDate.year(),wi.ClosedDate.month(),wi.ClosedDate.day());
						if(closedDate <= st.To_Date__c && closedDate >= st.From_Date__c){
							wi.BusinessHoursId = st.Business_Hours__c;
						}
					}
                    // If now is not within the business hours,
                    // check Overtime
                    if(!BusinessHours.isWithin(wi.BusinessHoursId, wi.ClosedDate)){
                        wi.Overtime__c = true;
                    }
                    else{
                        wi.Overtime__c = false;
                    }
                    // Add work item to list for update
                    workItemsUpdate.add(wi);
				}
			}
		}
		// If workItemsUpdate is not empty,
		// update work items
        if(workItemsUpdate.size() > 0){
            update workItemsUpdate;
            /*try{
                update workItemsUpdate;
            }
            catch(Exception e){
                Diags.SaveException(e);
        		Diags.ClearAll();
            }*/
        }
		Diags.Clear();
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           06/26/2015
    * @description    This method will update the Business Hours every 
						time a shift time has been deleted
    * @parameters     completedWIs - List of Shift Times
    **************************************************************************/
	public static void updateBusinessHoursOnDeleteOfShiftTimes(List<Shift_Time_Change__c> ShiftTimes){
		Diags.Enter('ShiftTimesUtility.updateBusinessHoursOnDeleteOfShiftTimes');
		Diags.Info(String.valueOf(ShiftTimes.size()));
		// Instantiate variables
        Set<Id> wiaIds = new Set<Id>();
        Set<Id> businessHourIds = new Set<Id>();
		Map<Id,Shift_Time_Change__c> wiaShiftTimeMap = new Map<Id,Shift_Time_Change__c>();
		List<Case> workItemsUpdate = new List<Case>();
		// Loop created shift times
		for(Shift_Time_Change__c st : ShiftTimes){
			// Validate that the shift time dates are in the past,
			// if so, put in a map
            wiaIds.add(st.Work_Item_Assignment__c);
            businessHourIds.add(st.Business_Hours__c);
            //wiaShiftTimeMap.put(st.Work_Item_Assignment__c, st);
		}
        Diags.Info('***wiaIds: '+String.valueOf(wiaIds));
        Diags.Info('***businessHourIds: '+String.valueOf(businessHourIds));
		if(wiaIds.size() > 0){
            // Query Shift Times related to the Work Item Assignment that is within the Closed Date
            // Put Shift Times in a map
            // Collect Business Hour Ids
            for(Shift_Time_Change__c st : [select Id, 
                                                           Business_Hours__c, 
                                                           From_Date__c, 
                                                           To_Date__c,
                                                           Work_Item_Assignment__c
                                                           from Shift_Time_Change__c
                                                           where Work_Item_Assignment__c IN: wiaIds
                                                           order by CreatedDate]){
                //businessHourIds.add(st.Business_Hours__c);
                // Validate that the shift time dates are in the past,
				// if so, put in a map
               // if(st.From_Date__c <= date.today()){
                    //wiaIds.add(st.Work_Item_Assignment__c);
                    wiaShiftTimeMap.put(st.Work_Item_Assignment__c, st);
                //}
                //wiaShiftTimeMap.put(st.Work_Item_Assignment__c, st);
            }
            Diags.Info('***wiaShiftTimeMap: '+String.valueOf(wiaShiftTimeMap));
			// Query work items that are Completed, Completed by Assigned User 
			// and has the work item assignment collected
			List<Case> workItems = [SELECT Id, Work_Item_Assignment__c, ClosedDate, Work_Item_Assignment__r.Business_Hours__c FROM Case 
										WHERE Work_Item_Assignment__c IN: wiaIds 
                                    	AND BusinessHoursId IN: businessHourIds
										AND Status = 'Completed' 
										//AND Sub_Status__c = 'Completed by Assigned User'
                                        ];
			// If there are work items queried
			if(workItems.size() > 0){
				for(Case wi : workItems){
                    wi.BusinessHoursId = wi.Work_Item_Assignment__r.Business_Hours__c;
					// If there is a shift time available for the work item assignment
					if(wiaShiftTimeMap.containsKey(wi.Work_Item_Assignment__c)){
						Shift_Time_Change__c st = wiaShiftTimeMap.get(wi.Work_Item_Assignment__c);
                        Diags.Info('***st: '+st);
						// if the work item closed date is within shift time From/To Dates,
						// Assign the business hour to the work item
						Date closedDate = date.newinstance(wi.ClosedDate.year(),wi.ClosedDate.month(),wi.ClosedDate.day());
						if(closedDate <= st.To_Date__c && closedDate >= st.From_Date__c){
							wi.BusinessHoursId = st.Business_Hours__c;
						}
					}
                    // If now is not within the business hours,
                    // check Overtime
                    if(!BusinessHours.isWithin(wi.BusinessHoursId, wi.ClosedDate)){
                        wi.Overtime__c = true;
                    }
                    else{
                        wi.Overtime__c = false;
                    }
                    // Add work item to list for update
                    workItemsUpdate.add(wi);
				}
			}
		}
		// If workItemsUpdate is not empty,
		// update work items
        if(workItemsUpdate.size() > 0){
            update workItemsUpdate;
            /*try{
                update workItemsUpdate;
            }
            catch(Exception e){
                Diags.SaveException(e);
        		Diags.ClearAll();
            }*/
        }
		Diags.Clear();
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           06/26/2015
    * @description    This method will update the Business Hours every 
						time a shift time has been deleted
    * @parameters     completedWIs - List of Shift Times
    **************************************************************************/
	public static void updateBusinessHoursOnUpdateOfShiftTimes(List<Shift_Time_Change__c> ShiftTimes,Map<Id, Shift_Time_Change__c> oldSTMap){
		Diags.Enter('ShiftTimesUtility.updateBusinessHoursOnUpdateOfShiftTimes');
		Diags.Info(String.valueOf(ShiftTimes.size()));
		// Instantiate variables
        Set<Id> wiaIds = new Set<Id>();
        Set<Id> businessHourIds = new Set<Id>();
		Map<Id,Shift_Time_Change__c> wiaShiftTimeMap = new Map<Id,Shift_Time_Change__c>();
		List<Case> workItemsUpdate = new List<Case>();
		// Loop created shift times
		for(Shift_Time_Change__c st : ShiftTimes){
			// Validate that the shift time dates are in the past,
			// if so, put in a map
            wiaIds.add(st.Work_Item_Assignment__c);
            businessHourIds.add(oldSTMap.get(st.Id).Business_Hours__c);
            //wiaShiftTimeMap.put(st.Work_Item_Assignment__c, st);
		}
        Diags.Info('***wiaIds: '+String.valueOf(wiaIds));
        Diags.Info('***businessHourIds: '+String.valueOf(businessHourIds));
		if(wiaIds.size() > 0){
            // Query Shift Times related to the Work Item Assignment that is within the Closed Date
            // Put Shift Times in a map
            // Collect Business Hour Ids
            for(Shift_Time_Change__c st : [select Id, 
                                                           Business_Hours__c, 
                                                           From_Date__c, 
                                                           To_Date__c,
                                                           Work_Item_Assignment__c
                                                           from Shift_Time_Change__c
                                                           where Work_Item_Assignment__c IN: wiaIds
                                                           order by CreatedDate]){
                //businessHourIds.add(st.Business_Hours__c);
                // Validate that the shift time dates are in the past,
				// if so, put in a map
                if(st.From_Date__c <= date.today()){
                    //wiaIds.add(st.Work_Item_Assignment__c);
                businessHourIds.add(st.Business_Hours__c);
                wiaShiftTimeMap.put(st.Work_Item_Assignment__c, st);
                }
                //wiaShiftTimeMap.put(st.Work_Item_Assignment__c, st);
            }
            Diags.Info('***wiaShiftTimeMap: '+String.valueOf(wiaShiftTimeMap));
			// Query work items that are Completed, Completed by Assigned User 
			// and has the work item assignment collected
			List<Case> workItems = [SELECT Id, Work_Item_Assignment__c, ClosedDate, Work_Item_Assignment__r.Business_Hours__c FROM Case 
										WHERE Work_Item_Assignment__c IN: wiaIds 
                                    	//AND BusinessHoursId IN: businessHourIds
										AND Status = 'Completed' 
										//AND Sub_Status__c = 'Completed by Assigned User'
                                        ];
			// If there are work items queried
			if(workItems.size() > 0){
				for(Case wi : workItems){
                    wi.BusinessHoursId = wi.Work_Item_Assignment__r.Business_Hours__c;
					// If there is a shift time available for the work item assignment
					if(wiaShiftTimeMap.containsKey(wi.Work_Item_Assignment__c)){
						Shift_Time_Change__c st = wiaShiftTimeMap.get(wi.Work_Item_Assignment__c);
                        Diags.Info('***st: '+st);
                        Diags.Info('***wi.ClosedDate: '+wi.ClosedDate);
                        Diags.Info('*** st.From_Date__c: '+ st.From_Date__c);
                        Diags.Info('*** st.To_Date__c: '+st.To_Date__c);
                        
                        Date closedDate = date.newinstance(wi.ClosedDate.year(),wi.ClosedDate.month(),wi.ClosedDate.day());
						// if the work item closed date is within shift time From/To Dates,
						// Assign the business hour to the work item
						if(closedDate <= st.To_Date__c && closedDate >= st.From_Date__c){
							wi.BusinessHoursId = st.Business_Hours__c;
						}
                        // If now is not within the business hours,
                        // check Overtime
                        Diags.Info('BusinessHours.isWithin(wi.BusinessHoursId, wi.ClosedDate)'+BusinessHours.isWithin(wi.BusinessHoursId, wi.ClosedDate));
                        if(!BusinessHours.isWithin(wi.BusinessHoursId, wi.ClosedDate)){
                            wi.Overtime__c = true;
                        }
                        else{
                             wi.Overtime__c = false;
                        }
                        // Add work item to list for update
                        workItemsUpdate.add(wi);
					}
				}
			}
		}
		// If workItemsUpdate is not empty,
		// update work items
        if(workItemsUpdate.size() > 0){
            update workItemsUpdate;
            /*try{
                update workItemsUpdate;
            }
            catch(Exception e){
                Diags.SaveException(e);
        		Diags.ClearAll();
            }*/
        }
		Diags.Clear();
    }
}