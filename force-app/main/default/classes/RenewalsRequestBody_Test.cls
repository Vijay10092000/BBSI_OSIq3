@isTest
private class RenewalsRequestBody_Test {

	@isTest static void empty_object(){
		RenewalsRequestBody renewalBody = new RenewalsRequestBody();
		system.assertEquals(0, renewalBody.ClientId);
		system.assertEquals(null, renewalBody.GetJsonString());
	}

	@isTest static void Xmod_Constructor(){
		Date contractDate = Date.today().addDays(30);
		RenewalsRequestBody renewalBody = new RenewalsRequestBody(900024, contractDate, 3, False, False);
        system.debug('Request Body for Xmod: ' + renewalBody.GetJsonString());

		system.assertEquals(900024, renewalBody.ClientId);
		system.assertEquals(3, renewalBody.DATES.size());
		system.assertNotEquals(null, renewalBody.GetJsonString());
	}

	@isTest static void quick_init(){
		// one-year plus old contract date
		Date contractDate = Date.today().addDays(-395);
		RenewalsRequestBody renewalBody = new RenewalsRequestBody();
		renewalBody.QuickInit(900032, contractDate);
		system.assertEquals(900032, renewalBody.ClientId);

		// less than one-year old contract date
		contractDate = Date.today().addDays(-335);
		renewalBody = new RenewalsRequestBody();
		renewalBody.QuickInit(900032, contractDate);
		system.assertEquals(900032, renewalBody.ClientId);

		renewalBody = new RenewalsRequestBody();
		renewalBody.QuickInit(906878, Date.newInstance(2017, 12, 31));
		system.assertEquals(906878, renewalBody.ClientId);
	}
}