@IsTest
public with sharing class SupportBannerController_Test {

    @IsTest
    public static void testGetBannerSettings() {
        Map<String, Support_Banner_Setting__mdt> settings = SupportBannerController.getBannerSettings();

        System.assertEquals(1, settings.keySet().size());
    }
}