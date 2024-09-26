@IsTest
public without sharing class RiskAnalysisWrapper_Test {
    @IsTest
    static void testRiskAnalysisWrapper() {
        RiskAnalysisWrapper raw = new RiskAnalysisWrapper();
        raw.TimePeriod = 'Hour';
        raw.STATE = 'Disabled';
        raw.Frequency = 100.0;
        raw.TotalIncurred = 33.33;
        raw.PEBilled = 1.23;
        
        System.assertEquals('Hour', raw.TimePeriod);
        System.assertEquals('Disabled', raw.STATE);
        System.assertEquals(100.0, raw.Frequency);
        System.assertEquals(33.33, raw.TotalIncurred);
        System.assertEquals(1.23, raw.PEBilled);
    }
}