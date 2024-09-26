public with sharing class WcAndSIdata {

    Public Integer Client;
    Public List<WcSiItem> WcSiList;

    Public Class WcSiItem{
        Public String StateCode;
        Public String WcCode;
        Public Integer IsEligible;
        Public Double EligibleRateSI;
    }

	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }
    
	public static WcAndSIdata parse(String json) {
		return (WcAndSIdata) System.JSON.deserialize(json, WcAndSIdata.class);
	}

}