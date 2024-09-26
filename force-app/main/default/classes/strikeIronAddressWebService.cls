public class strikeIronAddressWebService {  
    public Map<String,String> addressMap = new Map<String, String>();
    public httpResponse response = new httpResponse(); 

    public HttpResponse strikeIronAddress(Map<String, String> body){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://ws.strikeiron.com/StrikeIron/NAAddressVerification6/NorthAmericanAddressVerificationService/NorthAmericanAddressVerification');
        req.setMethod('GET');
        req.setBody(setBody(body));
        Http h = new Http();
        HttpResponse res = h.send(req);
        Dom.Document doc = res.getBodyDocument();
        dom.XmlNode docXMLNode = doc.getRootElement();
        xmlParse(docXMLNode);
        return res;        
    }
    
    public string setBody(Map<String, String> body){
        
        Login__c login = Login__c.getValues('StrikeIron');

        String strUsername = login.Username__c;
        String strPwd = login.Password__c;
        
        //String strUsername = 'bbsihq@strikeiron.com';
        //String strPwd = 'strike1';
        
        String AddressLine1 = '';
        String cityStateZipCode = '';
        String Country = '';
            
        for(String s : body.keySet()){
            System.debug(s + ' ' + body.get(s));
        }
        if(body.get('AddressLine1') != NULL){
            AddressLine1 = body.get('AddressLine1');            
        }
        String AddressLine2 = '';
        if(body.get('cityStateZipCode') != NULL){
            cityStateZipCode = body.get('cityStateZipCode');            
        }
        if(body.get('Country') != NULL){
            Country = body.get('Country');            
        }   
        String Firm = '';
        String Urbanization = '';
        String Casing = 'PROPER';
        
        String s = 'LicenseInfo.RegisteredUser.UserID='+EncodingUtil.urlEncode(strUsername, 'UTF-8')+
            '&LicenseInfo.RegisteredUser.Password='+EncodingUtil.urlEncode(strPwd, 'UTF-8')+
            '&NorthAmericanAddressVerification.AddressLine1='+EncodingUtil.urlEncode(AddressLine1, 'UTF-8')+
            '&NorthAmericanAddressVerification.AddressLine2='+EncodingUtil.urlEncode(AddressLine2, 'UTF-8')+
            '&NorthAmericanAddressVerification.CityStateOrProvinceZIPOrPostalCode='+EncodingUtil.urlEncode(cityStateZipCode, 'UTF-8')+
            '&NorthAmericanAddressVerification.Country='+EncodingUtil.urlEncode(Country, 'UTF-8')+
            '&NorthAmericanAddressVerification.Firm='+EncodingUtil.urlEncode(Firm, 'UTF-8')+
            '&NorthAmericanAddressVerification.Urbanization='+EncodingUtil.urlEncode(Urbanization, 'UTF-8')+
            '&NorthAmericanAddressVerification.Casing='+EncodingUtil.urlEncode(Casing, 'UTF-8');

        System.debug('URL String: ' + s);        

        return s;
    }
    
    private String xmlParse(DOM.XMLNode node){
        String result = '\n';
        
        //if (node.getNodeType() == DOM.XMLNodeType.COMMENT) {
        //    return 'Comment (' +  node.getText() + ')';
        //}
        //if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
        //    return 'Text (' + node.getText() + ')';
        //}
        
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += node.getName();
            if (node.getText().trim() != '') {
                result +=node.getText().trim();
            }
            if (node.getAttributeCount() > 0) { 
                //for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                    //result += node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
                //}  
            }
            for (Dom.XMLNode child: node.getChildElements()) {
                result += xmlParse(child);
            }
            addressMap.put(node.getName(), node.getText().trim());
            return result;
        }
        return null;  //should never reach here        
    }
}