public class SortingWrapperClass implements Comparable {

        public SObject sobj;
        public String order = '';
    	public String sortFieldName = '';
        // Constructor
        public SortingWrapperClass(SObject obj, String SortingOrder, String fieldName) {
            sobj = obj;
            order = SortingOrder;
            sortFieldName = fieldName;
        }
        
        // Compare members based on the Member__c Age.
        public Integer compareTo(Object compareTo) {
            // Cast argument to SortingWrapperClass
            SortingWrapperClass compareToSW = (SortingWrapperClass)compareTo;
            SObject compareToSobject = compareToSW.sobj;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if(order == 'DESC'){
                //if (sobj.Priority_Score__c > compareToSW.sobj.Priority_Score__c) {
                if (Double.valueOf(sobj.get(sortFieldName)) > Double.valueOf(compareToSobject.get(sortFieldName)) ) {
                    // Set return value to a positive value.
                    returnValue = -1;
                } else if (Double.valueOf(sobj.get(sortFieldName)) < Double.valueOf(compareToSobject.get(sortFieldName))) {
                    // Set return value to a negative value.
                    returnValue = 1;
                }
                else if(Double.valueOf(sobj.get(sortFieldName)) == null){
                    returnValue = 1;
                }
            }
            else if(order == 'ASC'){
                if (Double.valueOf(sobj.get(sortFieldName)) > Double.valueOf(compareToSobject.get(sortFieldName))) {
                    // Set return value to a positive value.
                    returnValue = 1;
                } else if (Double.valueOf(sobj.get(sortFieldName)) < Double.valueOf(compareToSobject.get(sortFieldName))) {
                    // Set return value to a negative value.
                    returnValue = -1;
                }
            }
            
            return returnValue;       
        }
    }