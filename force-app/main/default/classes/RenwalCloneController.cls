public with sharing class RenwalCloneController {
/*
    // the PricingScenario__c to be edited
    public PricingScenario__c ps {get; set;}
    
    // constructor - extracts account* parameters from the URL and
    // retrieves the associated account records
    public RenwalCloneController()
    {
        //Id ids=new Id();
        Integer idx=1;
        String psStr;
        
        // extract indexed parameters from the URL, stopping when null is retrieved
        psStr=ApexPages.currentPage().getParameters().get('PricingScenrios');
        system.debug('psStr in RenwalCloneController --' + psStr);
        if (psStr!=null)
        {
               ps = [Select ID, Name, CreatedDate__c, LastModifiedDate__c, ScenarioName__c, Status__c, Renewal__r.id from PricingScenario__c Where id =: psStr limit 1];
    
        }
        
    }
    
    // saves the account records and redirects to the accounts tab
    public PageReference saveAndRedirect()
    {
       // update psStr;   
      //  return new PageReference('/Acholdtestuse/0');
      //  a101b0000003Yx0AAE
     
      system.debug('save in RenwalCloneController --' + ps.renewal__r.id);
      PageReference renewPage = new PageReference('/apex/acholdtestuse?id=' + ps.renewal__r.id);
      //'http://www.google.com'
      //PageReference renewPage = new PageReference('http://www.google.com');
      renewPage.setRedirect(true);
      system.debug('renewPage in RenwalCloneController --' + renewPage);
      return renewPage;
 
    }
    
    public PageReference saveMethod()
    {
  		PageReference pgref = new PageReference('/0011b000005QFnk');
        pgref.setRedirect(true);
        return pgref;
    }
*/
}