@isTest                       
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://ws.strikeiron.com/StrikeIron/NAAddressVerification6/NorthAmericanAddressVerificationService/NorthAmericanAddressVerification', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        res.setBody('<WebServiceResponse xmlns="http://ws.strikeiron.com"><SubscriptionInfo xmlns="http://ws.strikeiron.com"><LicenseStatusCode>0</LicenseStatusCode><LicenseStatus>Valid license key</LicenseStatus>' +
        			'<LicenseActionCode>0</LicenseActionCode> <LicenseAction>Decremented hit count</LicenseAction><RemainingHits>128</RemainingHits><Amount>0</Amount></SubscriptionInfo>' +
        			'<NorthAmericanAddressVerificationResponse xmlns="http://www.strikeiron.com"><NorthAmericanAddressVerificationResult><ServiceStatus><StatusNbr>200</StatusNbr><StatusDescription>Found</StatusDescription>' +
        			'</ServiceStatus><ServiceResult><USAddress><AddressLine1>8100 NE Parkway Dr</AddressLine1><AddressLine2 /><StreetNumber>8100</StreetNumber><Firm /><PreDirection>NE</PreDirection><StreetName>Parkway</StreetName>'+
        			'<StreetType>Dr</StreetType><PostDirection /><Extension /><ExtensionNumber /><Village /><City>Vancouver</City><AddressStatus>Valid</AddressStatus><State>WA</State><Urbanization /><ZIPPlus4>98662-6742</ZIPPlus4>' +
        			'<ZIPCode>98662</ZIPCode><ZIPAddOn>6742</ZIPAddOn><CarrierRoute>C054</CarrierRoute><PMB /><PMBDesignator /><DeliveryPoint>99</DeliveryPoint><DPCheckDigit>2</DPCheckDigit><LACS /><CMRA>N</CMRA><DPV>D</DPV>' +
        			'<DPVFootnote>AA N1</DPVFootnote><RDI /><RecordType>H</RecordType><CongressDistrict>3</CongressDistrict><County>Clark</County><CountyNumber>11</CountyNumber><StateNumber>53</StateNumber><GeoCode><Latitude>45.655431</Latitude>' +
        			'<Longitude>-122.590714</Longitude><CensusTract>041108</CensusTract><StateNumber>53</StateNumber><CountyNumber>011</CountyNumber><BlockNumber>3002</BlockNumber><BlockGroup>530110411083</BlockGroup></GeoCode></USAddress>'+
        			'</ServiceResult></NorthAmericanAddressVerificationResult></NorthAmericanAddressVerificationResponse></WebServiceResponse>');
        
        res.setStatusCode(200);
        return res;
    }
 
}