@isTest
private class ClientBdmData_Test {
	
	static testMethod void parseJson() {
		String json = '{"CLIENT":"900005","HASBDM":"TRUE","BDMNAME":"Erik Swanson"}';

		ClientBdmData obj = ClientBdmData.parse(json);
		Assert.isTrue(obj != null);
		Assert.isTrue(obj.CLIENT == '900005');
		Assert.isTrue(obj.HASBDM == 'TRUE');
		Assert.isTrue(obj.BDMNAME == 'Erik Swanson');
	}
}