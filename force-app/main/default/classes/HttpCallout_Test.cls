/**
 * @description HttpCallout_Test tests the class HttpCallout.
 */
@IsTest
public without sharing class HttpCallout_Test {
	private static final String FAKE_ENDPOINT = 'https://fakeAddress.zzz';

	private static final String BOOMI_RESPONSE = '{"SUCCESS"}';

	private static final String STRIKEIRON_USERNAME = 'STRIKEIRON';
	private static final String STRIKEIRON_PASSWORD = 'PASSWORD';

	private static final String STRIKEIRON_BODY =
		'LicenseInfo.RegisteredUser.UserID=' +
		STRIKEIRON_USERNAME +
		'&LicenseInfo.RegisteredUser.Password=' +
		STRIKEIRON_PASSWORD +
		'&NorthAmericanAddressVerification.AddressLine1=8100+NE+Parkway+Drive%2C+Suite+200' +
		'&NorthAmericanAddressVerification.AddressLine2=' +
		'&NorthAmericanAddressVerification.CityStateOrProvinceZIPOrPostalCode=Vancouver%2C+WA+98662' +
		'&NorthAmericanAddressVerification.Country=US' +
		'&NorthAmericanAddressVerification.Firm=' +
		'&NorthAmericanAddressVerification.Urbanization=' +
		'&NorthAmericanAddressVerification.Casing=PROPER';

	private static final String STRIKEIRON_ADDRESS_FOUND =
		'<WebServiceResponse xmlns="http://ws.strikeiron.com">' +
		'  <SubscriptionInfo xmlns="http://ws.strikeiron.com">' +
		'    <LicenseStatusCode>0</LicenseStatusCode>' +
		'    <LicenseStatus>Valid license key</LicenseStatus>' +
		'    <LicenseActionCode>0</LicenseActionCode>' +
		'    <LicenseAction>Decremented hit count</LicenseAction>' +
		'    <RemainingHits>86771</RemainingHits>' +
		'    <Amount>0</Amount>' +
		'  </SubscriptionInfo>' +
		'  <NorthAmericanAddressVerificationResponse xmlns="http://www.strikeiron.com">' +
		'    <NorthAmericanAddressVerificationResult>' +
		'      <ServiceStatus>' +
		'        <StatusNbr>200</StatusNbr>' +
		'        <StatusDescription>Found</StatusDescription>' +
		'      </ServiceStatus>' +
		'      <ServiceResult>' +
		'        <USAddress>' +
		'          <AddressLine1>8100 NE Parkway Dr Ste 200</AddressLine1>' +
		'          <AddressLine2 />' +
		'          <StreetNumber>8100</StreetNumber>' +
		'          <Firm />' +
		'          <PreDirection>NE</PreDirection>' +
		'          <StreetName>Parkway</StreetName>' +
		'          <StreetType>Dr</StreetType>' +
		'          <PostDirection />' +
		'          <Extension>Ste</Extension>' +
		'          <ExtensionNumber>200</ExtensionNumber>' +
		'          <Village />' +
		'          <City>Vancouver</City>' +
		'          <AddressStatus>Valid</AddressStatus>' +
		'          <State>WA</State>' +
		'          <Urbanization />' +
		'          <ZIPPlus4>98662-6735</ZIPPlus4>' +
		'          <ZIPCode>98662</ZIPCode>' +
		'          <ZIPAddOn>6735</ZIPAddOn>' +
		'          <CarrierRoute>C054</CarrierRoute>' +
		'          <PMB />' +
		'          <PMBDesignator />' +
		'          <DeliveryPoint>50</DeliveryPoint>' +
		'          <DPCheckDigit>3</DPCheckDigit>' +
		'          <LACS />' +
		'          <CMRA>N</CMRA>' +
		'          <DPV>Y</DPV>' +
		'          <DPVFootnote>AA BB</DPVFootnote>' +
		'          <RDI />' +
		'          <RecordType>H</RecordType>' +
		'          <CongressDistrict>03</CongressDistrict>' +
		'          <County>Clark</County>' +
		'          <CountyNumber>011</CountyNumber>' +
		'          <StateNumber>53</StateNumber>' +
		'          <GeoCode>' +
		'            <Latitude>45.655779</Latitude>' +
		'            <Longitude>-122.591189</Longitude>' +
		'            <CensusTract>041108</CensusTract>' +
		'            <StateNumber>53</StateNumber>' +
		'            <CountyNumber>011</CountyNumber>' +
		'            <BlockNumber>3002</BlockNumber>' +
		'            <BlockGroup>530110411083</BlockGroup>' +
		'          </GeoCode>' +
		'        </USAddress>' +
		'      </ServiceResult>' +
		'    </NorthAmericanAddressVerificationResult>' +
		'  </NorthAmericanAddressVerificationResponse>' +
		'</WebServiceResponse>';

	private static final String STRIKEIRON_ADDRESS_NOT_FOUND =
		'<WebServiceResponse xmlns="http://ws.strikeiron.com">' +
		'  <SubscriptionInfo xmlns="http://ws.strikeiron.com">' +
		'    <LicenseStatusCode>0</LicenseStatusCode>' +
		'    <LicenseStatus>Valid license key</LicenseStatus>' +
		'    <LicenseActionCode>7</LicenseActionCode>' +
		'    <LicenseAction>No hit deduction for invocation</LicenseAction>' +
		'    <RemainingHits>86771</RemainingHits>' +
		'    <Amount>0</Amount>' +
		'  </SubscriptionInfo>' +
		'  <NorthAmericanAddressVerificationResponse xmlns="http://www.strikeiron.com">' +
		'    <NorthAmericanAddressVerificationResult>' +
		'      <ServiceStatus>' +
		'        <StatusNbr>304</StatusNbr>' +
		'        <StatusDescription>Address Not Found</StatusDescription>' +
		'      </ServiceStatus>' +
		'      <ServiceResult />' +
		'    </NorthAmericanAddressVerificationResult>' +
		'  </NorthAmericanAddressVerificationResponse>' +
		'</WebServiceResponse>';

	@IsTest
	static void test_request_Success() {
		Test.setMock(
			HttpCalloutMock.class,
			new GenericMockCallout(200, 'SUCCESS', 'Simple Body', (Map<String, String>) null)
		);

		HTTPResponse response = HttpCallout.request(FAKE_ENDPOINT, null, 1000);

		Assert.areEqual(200, response.getStatusCode(), 'Should have received a succussful Status Code');
		Assert.areEqual('SUCCESS', response.getStatus(), 'Should have received "SUCCESS" in the Status');
		Assert.areEqual(
			'Simple Body',
			response.getBody(),
			'Should have received "Simple Body" in the response Body'
		);
	}

	@IsTest
	static void test_request_Failure_Exception() {
		CalloutException except = new CalloutException();
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(except));

		HTTPResponse response = HttpCallout.request(FAKE_ENDPOINT, null, 1000);

		Assert.areEqual(null, response, 'Internal Exception should have been thrown.');
	}

	@IsTest
	static void test_request_Failure_CallFailed() {
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(503, 'FAILED', null, (Map<String, String>) null));

		HTTPResponse response = HttpCallout.request(FAKE_ENDPOINT, 'Request Body', 1000);

		Assert.areEqual(503, response.getStatusCode(), 'Should have received a failed Status Code');
		Assert.areEqual('FAILED', response.getStatus(), 'Should have received "FAILED" in the Status');
		Assert.isTrue(String.isEmpty(response.getBody()), 'Should have received no response Body');
	}

	@IsTest
	static void test_request_Failure_CalloutException() {
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(new CalloutException('Failed Callout')));

		Assert.areEqual(
			null,
			HttpCallout.request(FAKE_ENDPOINT, null, 1000),
			'An Exception should have been thrown'
		);
	}

	@IsTest
	static void test_queryToolingApi_Success() {
		String query = 'SELECT Id, Name FROM ApexClass WHERE Name = \'HttpCallout_Test\' LIMIT 1';

		String textJSON = 'RESPONSE: JSON STRING';
		Test.setMock(
			HttpCalloutMock.class,
			new GenericMockCallout(200, 'SUCCESS', textJSON, (Map<String, String>) null)
		);

		HTTPResponse response = HttpCallout.queryToolingApi(query);

		Assert.areEqual(200, response.getStatusCode(), 'Should have received a succussful Status Code');
		Assert.areEqual('SUCCESS', response.getStatus(), 'Should have received "SUCCESS" in the Status');
		Assert.areEqual(textJSON, response.getBody(), 'Should have received the JSON data in the response Body');
	}

	@IsTest
	static void test_picklistValuesUiApi_Success() {
		String textJSON = 'RESPONSE: JSON STRING';
		Test.setMock(
			HttpCalloutMock.class,
			new GenericMockCallout(200, 'SUCCESS', textJSON, (Map<String, String>) null)
		);

		HTTPResponse response = HttpCallout.picklistValuesUiApi('Case', '0122J000000ASJeQAO');

		Assert.areEqual(200, response.getStatusCode(), 'Should have received a succussful Status Code');
		Assert.areEqual('SUCCESS', response.getStatus(), 'Should have received "SUCCESS" in the Status');
		Assert.areEqual(textJSON, response.getBody(), 'Should have received the JSON data in the response Body');
	}

	@IsTest
	static void test_getBoomiNamedCredential() {
		String result = HttpCallout.getBoomiNamedCredential();

		if (Organization_Service.isProduction()) {
			Assert.areEqual('Production', result, 'In Production should recieve Production');
		} else {
			Assert.areNotEqual('Production', result, 'In a sandbox should not recieve Production');
		}
	}

	@IsTest
	static void test_callBoomi() {
		Test.startTest();

		Test.setMock(
			HttpCalloutMock.class,
			new GenericMockCallout(200, 'SUCCESS', BOOMI_RESPONSE, (Map<String, String>) null)
		);
		HttpResponse result = HttpCallout.callBoomi('/boomiCommand', '');

		Test.stopTest();

		Assert.areNotEqual(null, result, 'Should get response');
		Assert.areEqual(BOOMI_RESPONSE, result.getBody(), 'Should have success response');
	}

	@IsTest
	static void test_createBodyStrikeIron() {
		Login__c login = new Login__c();
		login.Name = 'StrikeIron';
		login.Username__c = STRIKEIRON_USERNAME;
		login.Password__c = STRIKEIRON_PASSWORD;
		insert login;

		Test.startTest();
		String result = HttpCallout.createBodyStrikeIron(
			'8100 NE Parkway Drive, Suite 200',
			'Vancouver',
			'WA',
			'98662',
			''
		);
		Test.stopTest();

		Assert.areEqual(STRIKEIRON_BODY, result, 'Should recieve a result');
	}

	@IsTest
	static void test_retrieveAddressData_GoodAddress() {
		Test.startTest();

		Test.setMock(
			HttpCalloutMock.class,
			new GenericMockCallout(200, 'SUCCESS', STRIKEIRON_ADDRESS_FOUND, (Map<String, String>) null)
		);
		Map<String, String> result = HttpCallout.retrieveAddressData(
			'8100 NE Parkway Drive, Suite 200',
			'Vancouver',
			'WA',
			'98662',
			''
		);

		Test.stopTest();

		Assert.areEqual('Found', result.get('StatusDescription'), 'Address should be found');
		Assert.areEqual('45.655779', result.get('Latitude'), 'Latitude should be set');
		Assert.areEqual('-122.591189', result.get('Longitude'), 'Longitude should be set');
	}

	@IsTest
	static void test_retrieveAddressData_BadAddress() {
		Test.setMock(
			HttpCalloutMock.class,
			new GenericMockCallout(200, 'SUCCESS', STRIKEIRON_ADDRESS_NOT_FOUND, (Map<String, String>) null)
		);

		Test.startTest();
		Map<String, String> result = HttpCallout.retrieveAddressData(
			'8100 NE Parkway Drive, Suite 200',
			'Vancouver',
			'WA',
			'98662',
			''
		);
		Test.stopTest();

		Assert.areEqual('Address Not Found', result.get('StatusDescription'), 'Address should fail');
	}

	@IsTest
	static void test_retrieveAddressData_Failure() {
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(401, 'FAILED', '', (Map<String, String>) null));

		Test.startTest();
		Map<String, String> result = HttpCallout.retrieveAddressData(
			'8100 NE Parkway Drive, Suite 200',
			'Vancouver',
			'WA',
			'98662',
			''
		);
		Test.stopTest();

		Assert.areEqual(null, result, 'Failed callout');
	}

	@IsTest
	static void test_parseStrikeIronResponse_Null() {
		Test.startTest();
		Map<String, String> result = HttpCallout.parseStrikeIronResponse(null);
		Test.stopTest();

		Assert.areEqual(null, result, 'XML Document is null');
	}
}