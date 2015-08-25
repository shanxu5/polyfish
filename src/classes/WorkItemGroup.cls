/*
	One WorkItemGroup contains a list of Work Items and Parent Work item
*/
global class WorkItemGroup {
    public Grouping_Rules__c groupingRuleRecord;
    public Id groupingRule;
    public String groupBy;
    public String groupByValue;
    public String groupingType;
    public Set<Id> classIds = new Set<Id>();
    public Map<Id, List<Case>> classWorkItemMap = new Map<Id, List<Case>>();
    public Map<String, List<Case>> groupByValueWIMap = new Map<String, List<Case>>();
    public Map<String,Set<Id>> groupByValueclassIdsMap = new Map<String,Set<Id>>();
    public List<Related_Class__c> relatedClasses;
}