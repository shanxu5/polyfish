/**********************************************************************************************
* @author       Janella Espiritu
* @date         08/27/2014
* @description	User Skill Rule Utility. All validation methods are placed here 
* @revision(s)  Janella Espiritu 09152014 Add methods to access TurnOnAssignmentandGrouping__c
**********************************************************************************************/
public class UserSkillRuleUtility {
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate if 2 strings are equal
    * @parameters	  String string1, String String2
    **************************************************************************/
    public static Boolean validateEqualStrings(String string1, String string2){
        if(string1.toUpperCase() == string2.toUpperCase()){
            return true;
        }
        else{
            return false;
        }
        
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate boolean and string 
    * 					(picklist of true/false)
    * @parameters	  Boolean booleanVal, String stringVal
    **************************************************************************/
    public static Boolean validateBoolean(Boolean booleanVal, String stringVal){
        if(booleanVal && stringVal == 'True'){
            return true;
        }
        else if(!booleanVal && stringVal == 'False'){
            return true;
        }
        else{
            return false;
        }
        
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate a set of string contains a string
    * 					(used for Multi-picklists)
    * @parameters	  String string1 (shorter string), String string2 (set)
    **************************************************************************/
    public static Boolean validateStringContains(String string1, String string2){
        if(string2.toUpperCase().contains(string1.toUpperCase())){
            return true;
        }
        else{
            return false;
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate if a Decimal
    * 					is equal to a String(with Decimal Value) 
    * @parameters	  Decimal decimalVal1, Decimal decimalVal2
    **************************************************************************/
    public static Boolean validateEquals(Decimal decimalVal1, Decimal decimalVal2){
        if(decimalVal2 == decimalVal1){
            return true;
        }
        else{
            return false;
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate if a Decimal
    * 					is not equal to a String(with Decimal Value) 
    * @parameters	  Decimal decimalVal1, Decimal decimalVal2
    **************************************************************************/
    public static Boolean validateNotEqualTo(Decimal decimalVal1, Decimal decimalVal2){
        if(decimalVal2 != decimalVal1){
            return true;
        }
        else{
            return false;
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate if a Decimal
    * 					is less than a String(with Decimal Value) 
    * @parameters	  Decimal decimalVal1, Decimal decimalVal2
    **************************************************************************/
    public static Boolean validateLessThan(Decimal decimalVal1, Decimal decimalVal2){
        if(decimalVal2 < decimalVal1){
            return true;
        }
        else{
            return false;
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate if a Decimal
    * 					is greater than to a String(with Decimal Value) 
    * @parameters	  Decimal decimalVal1, Decimal decimalVal2
    **************************************************************************/
    public static Boolean validateGreaterThan(Decimal decimalVal1, Decimal decimalVal2){
        if(decimalVal2 > decimalVal1){
            return true;
        }
        else{
            return false;
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate if a Decimal
    * 					is less or equal to a String(with Decimal Value) 
    * @parameters	  Decimal decimalVal1, Decimal decimalVal2
    **************************************************************************/
    public static Boolean validateLessOrEqual(Decimal decimalVal1, Decimal decimalVal2){
    	if(decimalVal2 <= decimalVal1){
            return true;
        }
        else{
            return false;
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate if a Decimal
    * 					is greater or equal to a String(with Decimal Value) 
    * @parameters	  Decimal decimalVal1, Decimal decimalVal2
    **************************************************************************/
    public static Boolean validateGreaterOrEqual(Decimal decimalVal1, Decimal decimalVal2){
        if(decimalVal2 >= decimalVal1){
            return true;
        }
        else{
            return false;
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/27/2014
    * @description    This method validate if a Decimal
    * 					is not between a range specified on a 
    * 					String(with format 00-00, i.e. '20-100')
    * @parameters	  Decimal decimalVal1, Decimal decimalVal2, Decimal decimalVal3
    **************************************************************************/
    public static Boolean validateBetween(Decimal decimalVal1, Decimal decimalVal2, Decimal decimalVal3){
        if(decimalVal3 >= decimalVal1 && decimalVal3 <= decimalVal2){
            return true;
        }
        else{
            return false;
        }
    }
    
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           09/15/2014
    * @description    This method grabs all the Work Item types that are 
    * 					enabled for Assignment
    * @parameters	  
    **************************************************************************/
    public static Set<String> assignmentEnabled(){
        Set<String> temp = new Set<String>();
        Map<String, TurnOnAssignmentandGrouping__c> allRecords = TurnOnAssignmentandGrouping__c.getall();
        for(String s : allRecords.keySet()){
            if(allRecords.get(s).AssignmentEnabled__c){
                temp.add(allRecords.get(s).Name.toUpperCase());
            }
        }
        return temp;
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           09/18/2014
    * @description    This method sorts a user skills list based on the Sort Order
    * 					and Field name passed on the Parameter
    * @parameters	  List<User_Skill__c> sobjectList, String SortOrder, String fieldName
    **************************************************************************/
    public static List<Work_Item_Assignment__c> sortUserSkillsList(List<Work_Item_Assignment__c> sobjectList, String SortOrder, String fieldName){
        List<SortingWrapperClass> swList = new List<SortingWrapperClass>();
        for(Work_Item_Assignment__c c : sobjectList){
            swList.add(new SortingWrapperClass(c, SortOrder, fieldName));
        }
        swList.sort();
        sobjectList.clear();
        for(SortingWrapperClass sw : swList){
            sobjectList.add((Work_Item_Assignment__c) sw.sObj);
        }
        return sobjectList;
    }
    
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           09/18/2014
    * @description    Get a list of picklist values from an existing object field
    * @parameters	  SObject obj, String fld, Set<String> enabledSet
    **************************************************************************/    
	public static Set<String> getPicklistValues(SObject obj, String fld, Set<String> enabledSet){
		Set<String> pickValues = new Set<String>();
		Set<String> updatedSet = new Set<String>();
		Map<String, String> PickValuesMap = new Map<String,String>();
		// Get the object type of the SObject.
		Schema.sObjectType objType = obj.getSObjectType(); 
		// Describe the SObject using its object type.
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
		// Get a map of fields for the SObject
		Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
		// Get the list of picklist values for this field.
		List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
		// Add these values to the selectoption list.
		for (Schema.PicklistEntry a : values){ 
			pickValues.add(a.getLabel());
			PickValuesMap.put(a.getLabel().toUpperCase(), a.getLabel());
		}
		for(String s : enabledSet){
			if(PickValuesMap.containsKey(s.toUpperCase())){
				updatedSet.add(PickValuesMap.get(s.toUpperCase()));
			}
		}      
		return updatedSet;
	}
}