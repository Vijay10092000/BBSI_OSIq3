@isTest
public class MapPageController_Test {
    private static testmethod void MapControllerTest(){
        PageReference pageRef = Page.renewalClientDetail;
        Test.setCurrentPage(pageRef);
        
        Renewal__c temp = new Renewal__c();
        insert temp;
        
        ApexPages.StandardController Extension = new ApexPages.StandardController(temp);
        MapPageController controller = new MapPageController(Extension);
        controller.aMapWrapper = new MapWrapper();
        Object x = controller.aMapWrapper.values;
        Object y = controller.aMapWrapper.HelpResourceMap;
        Object z = controller.aMapWrapper.gvalue(x);
        controller.aMapWrapper.put(x,y);
        
        controller.aMapWrapper.put('helpmap', 'Help Map Test Value');
        x = controller.aMapWrapper.values;
        y = controller.aMapWrapper.HelpResourceMap;
        Assert.areEqual(x, 'Help Map Test Value');
        Assert.areEqual(y, 'Help Map Test Value');
    }   
}