public with sharing class WebformHelp {
    public String workItemType {get;set;}
    public FieldSettingUtilities fieldSettingUt {get;set;}
    public Webform_Field_Settings__c webFormFieldSetting {get;set;}

    public WebformHelp() {
    	workItemType = ApexPages.currentPage().getParameters().get('workItemType');
    	System.debug('workItemType ' + workItemType);

    	if (fieldSettingUt == null) {
    		fieldSettingUt = new FieldSettingUtilities(workItemType);
		}

    	webFormFieldSetting = fieldSettingUt.getWebformFS();

    	System.debug('webFormFieldSetting ' + webFormFieldSetting);
    }

}