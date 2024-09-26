/**
 * @description updatePayDayTest
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
private class updatePayDayTest {
	@IsTest
	static void singlePayroll() {
		Account a = TestFactoryAccount.createClient('TESTBBSI', null, null);
		Payroll__c p = TestFactoryPayroll.makePayroll(a, 'W5:P6:S2:D4', null);
		p.Pay_Period__c = 'W';
		p.Payday__c = '1';

		insert p;

		Assert.areEqual('Monday', [SELECT Payday__c FROM Payroll__c WHERE Id = :p.Id].payday__c);
	}

	@IsTest
	static void mutiplePayrolls() {
		Account a = TestFactoryAccount.createClient('TESTBBSI', null, null);

		List<Payroll__c> payrolls = new List<Payroll__c>();

		Payroll__c p1 = TestFactoryPayroll.makePayroll(a, 'W5:P6:S2:D4', null);
		Payroll__c p2 = TestFactoryPayroll.makePayroll(a, 'W5:P6:S2:D4', null);
		Payroll__c p3 = TestFactoryPayroll.makePayroll(a, 'W5:P6:S2:D4', null);
		Payroll__c p4 = TestFactoryPayroll.makePayroll(a, 'W5:P6:S2:D4', null);
		Payroll__c p5 = TestFactoryPayroll.makePayroll(a, 'W5:P6:S2:D4', null);

		p1.Pay_Period__c = 'B';
		p2.Pay_Period__c = 'W';
		p3.Pay_Period__c = 'B';
		p4.Pay_Period__c = 'W';
		p5.Pay_Period__c = 'S';

		p1.Payday__c = '2';
		p2.Payday__c = '3';
		p3.Payday__c = '4';
		p4.Payday__c = '5';
		p5.Payday__c = '3';

		payrolls.add(p1);
		payrolls.add(p2);
		payrolls.add(p3);
		payrolls.add(p4);
		payrolls.add(p5);

		insert payrolls;

		Assert.areEqual('Tuesday', [SELECT Payday__c FROM Payroll__c WHERE Id =: p1.Id].Payday__c);
		Assert.areEqual('Wednesday', [SELECT Payday__c FROM Payroll__c WHERE Id =: p2.Id].Payday__c);
		Assert.areEqual('Thursday', [SELECT Payday__c FROM Payroll__c WHERE Id =: p3.Id].Payday__c);
		Assert.areEqual('Friday', [SELECT Payday__c FROM Payroll__c WHERE Id =: p4.Id].Payday__c);
		Assert.areEqual('3', [SELECT Payday__c FROM Payroll__c WHERE Id =: p5.Id].Payday__c);
	}

	@IsTest
	static void updatePayroll() {
		Account a = TestFactoryAccount.createClient('TESTBBSI', null, null);
		Payroll__c p = TestFactoryPayroll.makePayroll(a, 'W5:P6:S2:D4', null);
		p.Pay_Period__c = 'W';
		p.Payday__c = '1';
		insert p;

		p.Payday__c = '2';
		update p;

		Assert.areEqual('Tuesday', [SELECT Payday__c FROM Payroll__c WHERE Id =: p.Id].Payday__c);
	}
}