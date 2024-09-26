@isTest
private class PayWcEstimate_Test {
	
	@isTest static void parseJson() {
		String json = '{"CLIENT":"900028","DATALIST":[{"LastName":"BALESTRERI","FirstName":"DANA","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8810","PayAmt":97625,"PremPayAmt":97625,"HoursWorked":1808,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"BOLANOS","FirstName":"MAYRA","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8810","PayAmt":6610,"PremPayAmt":6610,"HoursWorked":217,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"CLARK","FirstName":"JEFFREY","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8742","PayAmt":73985,"PremPayAmt":73670,"HoursWorked":1764.75,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"CONTRERAS","FirstName":"ULISSES","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8227","PayAmt":27889.74,"PremPayAmt":27617.71,"HoursWorked":1614.25,"IsEligibleSI":1,"EligibleRateSI":2.31}]},{"LastName":"MATA HERNANDEZ","FirstName":"SALVADOR","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"1803","PayAmt":61147.25,"PremPayAmt":58083.5,"HoursWorked":1976.75,"IsEligibleSI":1,"EligibleRateSI":3.02}]},{"LastName":"PARADA","FirstName":"JOSE","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":53086,"PremPayAmt":51765.5,"HoursWorked":1792.5,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"PETINARAKIS","FirstName":"NIKOS","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":58309.09,"PremPayAmt":57372.71,"HoursWorked":1634.75,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"RAMIREZ","FirstName":"JOSE","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5027","PayAmt":33677.5,"PremPayAmt":32890,"HoursWorked":1590.25,"IsEligibleSI":1,"EligibleRateSI":4},{"WCcode":"5028","PayAmt":600,"PremPayAmt":560,"HoursWorked":28,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"REYNOSO","FirstName":"ROBERTO","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":60273.75,"PremPayAmt":58719.75,"HoursWorked":1715.75,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"ROBINSON","FirstName":"JOY","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8742","PayAmt":23303.13,"PremPayAmt":23290,"HoursWorked":637.25,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"SANTOYO","FirstName":"JUAN","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":75956.12,"PremPayAmt":75348.8,"HoursWorked":1819.5,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"SCHUPP","FirstName":"STEPHEN","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"1803","PayAmt":41233.81,"PremPayAmt":40783.8,"HoursWorked":1553.5,"IsEligibleSI":1,"EligibleRateSI":3.02}]},{"LastName":"SHIRLEY","FirstName":"ALEXANDER","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5027","PayAmt":13186,"PremPayAmt":13001.5,"HoursWorked":692.75,"IsEligibleSI":1,"EligibleRateSI":4}]},{"LastName":"TORRES ESCOBAR","FirstName":"FRANCISCO","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5027","PayAmt":28890,"PremPayAmt":28653.5,"HoursWorked":1264.75,"IsEligibleSI":1,"EligibleRateSI":4}]},{"LastName":"VALENCIA","FirstName":"JUAN","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":47543.5,"PremPayAmt":46227,"HoursWorked":1532.5,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"WESTBROOK","FirstName":"CASSANDRA","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"8742","PayAmt":57356,"PremPayAmt":56997.5,"HoursWorked":1765,"IsEligibleSI":0,"EligibleRateSI":0}]},{"LastName":"WESTBROOK","FirstName":"EDWARD","Active":"A","IsOwner":0,"State":"CA","WCcodes":[{"WCcode":"5028","PayAmt":122997.5,"PremPayAmt":122997.5,"HoursWorked":2082.25,"IsEligibleSI":1,"EligibleRateSI":2.3}]},{"LastName":"WESTBROOK","FirstName":"EDWARD","Active":"A","IsOwner":1,"State":"CA","WCcodes":[{"WCcode":"1000","PayAmt":113076.81,"PremPayAmt":0,"HoursWorked":1960,"IsEligibleSI":0,"EligibleRateSI":0}]}]}';
		PayWcEstimate obj = PayWcEstimate.parse(json);

		System.assert(obj.CLIENT == '900028');
		System.assert(obj.DATALIST.size() > 0);
		System.assert(obj.DATALIST[0].State == 'CA');
		System.assert(obj.DATALIST[0].FirstName == 'DANA');
		System.assert(obj.DATALIST[0].LastName == 'BALESTRERI');
		System.assert(obj.DATALIST[0].Active == 'A');
		System.assert(obj.DATALIST[0].IsOwner == 0);
		System.assert(obj.DATALIST[0].WCcodes[0].WCcode == '8810');
		System.assert(obj.DATALIST[0].WCcodes[0].PayAmt == 97625.00);
		System.assert(obj.DATALIST[0].WCcodes[0].PremPayAmt == 97625.00);
		System.assert(obj.DATALIST[0].WCcodes[0].HoursWorked == 1808.00);
		System.assert(obj.DATALIST[0].WCcodes[0].IsEligibleSI == 0);
		System.assert(obj.DATALIST[0].WCcodes[0].EligibleRateSI == 0);

		System.assert(obj.DATALIST[0].TotalPay == 97625.00);
		System.assert(obj.DATALIST[0].TotalPremBasedPay == 97625.00);
		System.assert(obj.DATALIST[0].TotalHours == 1808.00);

		System.assert(obj.States != null);

	}
	
}