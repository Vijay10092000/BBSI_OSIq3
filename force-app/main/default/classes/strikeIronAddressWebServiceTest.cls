@isTest(seealldata = true)
private class strikeIronAddressWebServiceTest {
     private static testmethod void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        
        //crateCustomSetting();
        
        strikeIronAddressWebService strikeIron = new strikeIronAddressWebService();
         
        HttpResponse res = strikeIron.strikeIronAddress(strikeIronRequest());
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '<WebServiceResponse xmlns="http://ws.strikeiron.com"><SubscriptionInfo xmlns="http://ws.strikeiron.com"><LicenseStatusCode>0</LicenseStatusCode><LicenseStatus>Valid license key</LicenseStatus>' +
                    '<LicenseActionCode>0</LicenseActionCode> <LicenseAction>Decremented hit count</LicenseAction><RemainingHits>128</RemainingHits><Amount>0</Amount></SubscriptionInfo>' +
                    '<NorthAmericanAddressVerificationResponse xmlns="http://www.strikeiron.com"><NorthAmericanAddressVerificationResult><ServiceStatus><StatusNbr>200</StatusNbr><StatusDescription>Found</StatusDescription>' +
                    '</ServiceStatus><ServiceResult><USAddress><AddressLine1>8100 NE Parkway Dr</AddressLine1><AddressLine2 /><StreetNumber>8100</StreetNumber><Firm /><PreDirection>NE</PreDirection><StreetName>Parkway</StreetName>'+
                    '<StreetType>Dr</StreetType><PostDirection /><Extension /><ExtensionNumber /><Village /><City>Vancouver</City><AddressStatus>Valid</AddressStatus><State>WA</State><Urbanization /><ZIPPlus4>98662-6742</ZIPPlus4>' +
                    '<ZIPCode>98662</ZIPCode><ZIPAddOn>6742</ZIPAddOn><CarrierRoute>C054</CarrierRoute><PMB /><PMBDesignator /><DeliveryPoint>99</DeliveryPoint><DPCheckDigit>2</DPCheckDigit><LACS /><CMRA>N</CMRA><DPV>D</DPV>' +
                    '<DPVFootnote>AA N1</DPVFootnote><RDI /><RecordType>H</RecordType><CongressDistrict>3</CongressDistrict><County>Clark</County><CountyNumber>11</CountyNumber><StateNumber>53</StateNumber><GeoCode><Latitude>45.655431</Latitude>' +
                    '<Longitude>-122.590714</Longitude><CensusTract>041108</CensusTract><StateNumber>53</StateNumber><CountyNumber>011</CountyNumber><BlockNumber>3002</BlockNumber><BlockGroup>530110411083</BlockGroup></GeoCode></USAddress>'+
                    '</ServiceResult></NorthAmericanAddressVerificationResult></NorthAmericanAddressVerificationResponse></WebServiceResponse>';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
     }

    private static map<String,String> strikeIronRequest(){
        map<String,String> strikeIron = new map<String,String>();
        
        strikeIron.put('AddressLine1', '9999 1st AVE');
        strikeIron.put('cityStateZipCode', 'Village, DC 12345');
        strikeIron.put('Country', 'US');
        
        return strikeIron;
    }

}