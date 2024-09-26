@isTest
public class viewClientControlsController_Test {
	
  @testSetup
  static void setup(){
    Account Client = TestFactoryAccount.createClient('Test Client', null, null);
  }

  @isTest
  public static void testController(){
    Account client = [SELECT Id FROM Account WHERE RecordType.name = 'Client' LIMIT 1];
    Id clientID = client.id;
    
    Set<String> fieldset = new Set<String>();
    for(Schema.FieldSetMember fields :Schema.SObjectType.Account.fieldSets.getMap().get('Price_Approval_To_Unapproved').getFields()){
      fieldSet.add(fields.getFieldPath());
    }
    
    Map<String,Schema.SObjectField> fieldMap;
    fieldMap = Schema.SObjectType.Account.Fields.getMap();
    Schema.SObjectField fieldVal;
    Schema.DisplayType FldType;

    String finalField;

    For(String field: fieldSet){
      fieldVal = fieldMap.get(field);
      object value = TestFactory.getFieldValueBySoapType(fieldVal.GetDescribe().getSoapType());
      Client.put(field,value);
    }
    update client;
    //now update 1 to create client controls
    for(String field: fieldSet){
        fieldVal = fieldMap.get(field);
        if(FieldVal.getDescribe().getSoapType() == Schema.SoapType.STRING){
          client.put(field,'Testing 123');
          break;
        }
      }
    update client;
    PageReference pageRef =  Page.viewClientControlsList;
    Test.setCurrentPage(pageRef);
    System.currentPageReference().getParameters().put('acctID', clientID);
    viewClientControlsController cntrl = new viewClientControlsController();
    Assert.areEqual(cntrl.getControls().size(), 1);
    Assert.areEqual(cntrl.getAccount().Id, client.ID);
    Assert.areEqual(cntrl.currentAccount, null);

  }
}