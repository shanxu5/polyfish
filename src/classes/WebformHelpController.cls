public with sharing class WebformHelpController {
        public WebformHelpController() {
                String WorkItemType = ApexPages.currentPage().getParameters().get('WIType');
        }
}