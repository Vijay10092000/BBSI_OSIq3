/**
 * @description VerifyProspectTest contains test methods for the class VerifiyProspect.
 */
@IsTest
public class VerifyProspectTest {
	private static final String JSON_RESPONSE_GOOD =
		'<WebServiceResponse xmlns="http://ws.strikeiron.com">' +
		'	<SubscriptionInfo xmlns="http://ws.strikeiron.com">' +
		'	  <LicenseStatusCode>0</LicenseStatusCode>' +
		'	  <LicenseStatus>Valid license key</LicenseStatus>' +
		'	  <LicenseActionCode>0</LicenseActionCode>' +
		'	  <LicenseAction>Decremented hit count</LicenseAction>' +
		'	  <RemainingHits>107808</RemainingHits>' +
		'	  <Amount>0</Amount>' +
		'	</SubscriptionInfo>' +
		'	<NorthAmericanAddressVerificationResponse xmlns="http://www.strikeiron.com">' +
		'	  <NorthAmericanAddressVerificationResult>' +
		'		<ServiceStatus>' +
		'		  <StatusNbr>200</StatusNbr>' +
		'		  <StatusDescription>Found</StatusDescription>' +
		'		</ServiceStatus>' +
		'		<ServiceResult>' +
		'		  <USAddress>' +
		'			<AddressLine1>8100 NE Parkway Dr Ste 200</AddressLine1>' +
		'			<AddressLine2 />' +
		'			<StreetNumber>8100</StreetNumber>' +
		'			<Firm />' +
		'			<PreDirection>NE</PreDirection>' +
		'			<StreetName>Parkway</StreetName>' +
		'			<StreetType>Dr</StreetType>' +
		'			<PostDirection />' +
		'			<Extension>Ste</Extension>' +
		'			<ExtensionNumber>200</ExtensionNumber>' +
		'			<Village />' +
		'			<City>Vancouver</City>' +
		'			<AddressStatus>Valid</AddressStatus>' +
		'			<State>WA</State>' +
		'			<Urbanization />' +
		'			<ZIPPlus4>98662-6735</ZIPPlus4>' +
		'			<ZIPCode>98662</ZIPCode>' +
		'			<ZIPAddOn>6735</ZIPAddOn>' +
		'			<CarrierRoute>C054</CarrierRoute>' +
		'			<PMB />' +
		'			<PMBDesignator />' +
		'			<DeliveryPoint>50</DeliveryPoint>' +
		'			<DPCheckDigit>3</DPCheckDigit>' +
		'			<LACS />' +
		'			<CMRA>N</CMRA>' +
		'			<DPV>Y</DPV>' +
		'			<DPVFootnote>AA BB</DPVFootnote>' +
		'			<RDI />' +
		'			<RecordType>H</RecordType>' +
		'			<CongressDistrict>03</CongressDistrict>' +
		'			<County>Clark</County>' +
		'			<CountyNumber>011</CountyNumber>' +
		'			<StateNumber>53</StateNumber>' +
		'			<GeoCode>' +
		'			  <Latitude>45.655779</Latitude>' +
		'			  <Longitude>-122.591189</Longitude>' +
		'			  <CensusTract>041113</CensusTract>' +
		'			  <StateNumber>53</StateNumber>' +
		'			  <CountyNumber>011</CountyNumber>' +
		'			  <BlockNumber>1006</BlockNumber>' +
		'			  <BlockGroup>530110411131</BlockGroup>' +
		'			</GeoCode>' +
		'		  </USAddress>' +
		'		</ServiceResult>' +
		'	  </NorthAmericanAddressVerificationResult>' +
		'	</NorthAmericanAddressVerificationResponse>' +
		'</WebServiceResponse>';
	private static final String JSON_RESPONSE_BAD =
	'<WebServiceResponse xmlns="http://ws.strikeiron.com">' +
	'	<SubscriptionInfo xmlns="http://ws.strikeiron.com">' +
	'	  <LicenseStatusCode>0</LicenseStatusCode>' +
	'	  <LicenseStatus>Valid license key</LicenseStatus>' +
	'	  <LicenseActionCode>0</LicenseActionCode>' +
	'	  <LicenseAction>Decremented hit count</LicenseAction>' +
	'	  <RemainingHits>107808</RemainingHits>' +
	'	  <Amount>0</Amount>' +
	'	</SubscriptionInfo>' +
	'	<NorthAmericanAddressVerificationResponse xmlns="http://www.strikeiron.com">' +
	'	  <NorthAmericanAddressVerificationResult>' +
	'		<ServiceStatus>' +
	'		  <StatusNbr>200</StatusNbr>' +
	'		  <StatusDescription>Not Found</StatusDescription>' +
	'		</ServiceStatus>' +
	'		<ServiceResult>' +
	'		  <USAddress>' +
	'			<AddressStatus>Invalid</AddressStatus>' +
	'		  </USAddress>' +
	'		</ServiceResult>' +
	'	  </NorthAmericanAddressVerificationResult>' +
	'	</NorthAmericanAddressVerificationResponse>' +
	'</WebServiceResponse>';

	private static Account account = null;

	@TestSetup
	static void makeData() {
		// Account a = TestFactory.createAccount('Prospect Test', '98662', 'Prospect', false);
		Account a = TestFactoryAccount.makeProspect('Prospect Test', null, null);
		a.BillingStreet ='8100 NE Parkway Dr';
		a.BillingCity = 'Vancoucer';
		a.BillingState = 'WA';
		a.BillingPostalCode = '98662';

		insert a;
	}

	static void loadData() {
		account = [
			SELECT Id, RecordTypeId, Name, Verified__c, Verified_Status__c, BillingStreet, BillingCity,
				BillingState, BillingPostalCode, BillingLatitude, BillingLongitude, County__c
			FROM Account
			WHERE Name = 'Prospect Test'
		];
	}

	@IsTest
	static void test_pullAccountRecord() {
		loadData();

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', JSON_RESPONSE_GOOD, null));

		PageReference pageRef = Page.VerifyAddressPage;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', account.Id);

		Test.startTest();

		PageReference pageRefResult = (new VerifyProspect()).pullAccountRecord();

		Test.stopTest();

		Assert.isTrue(pageRefResult.getUrl().endsWith(String.valueOf(account.Id)), 'URL should end with the Account Id');
	}

	@IsTest
	static void test_updateAccount_Success() {
		loadData();

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', JSON_RESPONSE_GOOD, null));

		Test.startTest();

		VerifyProspect.updateAccount(account.Id);

		Test.stopTest();

		loadData();

		Assert.areEqual('Prospect Test', account.Name, 'Should have the test account');
		Assert.areEqual(true, account.Verified__c, 'Address is correct');
		Assert.areEqual('Address Verified', account.Verified_Status__c, 'Invalid address');
	}

	@IsTest
	static void test_updateAccount_Failure() {
		loadData();

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', JSON_RESPONSE_BAD, null));

		Test.startTest();

		VerifyProspect.updateAccount(account.Id);

		Test.stopTest();

		loadData();

		Assert.areEqual('Prospect Test', account.Name, 'Should have the test account');
		Assert.areEqual(false, account.Verified__c, 'Address is incorrect');
		Assert.areEqual('Not Found', account.Verified_Status__c, 'Invalid address');
	}
}