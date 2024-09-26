/*
 * @description AllOrNothingController_Test is Test Class for AllOrNothingController
 */
@isTest
public class AllOrNothingController_Test {
    
    @isTest
    static void AllOrNothingControllerTest() 
    {     
        List<Contact> contacts=new List<Contact>();
        AllOrNothingController controller=new AllOrNothingController();        
        controller.values=contacts;
        Assert.isFalse(controller.getRender());
        contacts.add(new Contact(LastName='test'));
        controller.values=contacts;
        Assert.isTrue(controller.getRender());         
    }
}