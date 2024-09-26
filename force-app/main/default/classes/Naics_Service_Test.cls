/**
 * @description
 * 
 */
@IsTest
public with sharing class Naics_Service_Test {  
    @TestSetup 
    static void setup() {
        NAICS_Code__c n1 = new NAICS_Code__c( Name = '11', NAICS_Title__c = 'Agriculture, Forestry, Fishing and Hunting' );
        NAICS_Code__c n2 = new NAICS_Code__c( Name = '111', NAICS_Title__c = 'Crop Production' );
        NAICS_Code__c n3 = new NAICS_Code__c( Name = '111111', NAICS_Title__c = 'Oilseed and Grain Farming' );
        NAICS_Code__c n4 = new NAICS_Code__c( Name = '42', NAICS_Title__c = 'Wholesale Trade' );
        NAICS_Code__c n5 = new NAICS_Code__c( Name = '423', NAICS_Title__c = 'Merchant Wholesalers, Durable Goods' );
        NAICS_Code__c n6 = new NAICS_Code__c( Name = '423120', NAICS_Title__c = 'Motor Vehicle Supplies and New Parts Merchant Wholesalers' );
        
        insert new List<NAICS_Code__c>{ n1, n2, n3, n4, n5, n6 };
    }

    @IsTest
    static void test_getNaics() {
        System.assertEquals(null, Naics_Service.mapCodeToTitle);

        Naics_Service.getNaics();

        System.assertEquals(6, Naics_Service.mapCodeToTitle.size());
        System.assertEquals(true, Naics_Service.mapCodeToTitle.containsKey('11'));
        System.assertEquals(true, Naics_Service.mapCodeToTitle.containsKey('111'));
        System.assertEquals(true, Naics_Service.mapCodeToTitle.containsKey('111111'));
        System.assertEquals(true, Naics_Service.mapCodeToTitle.containsKey('42'));
        System.assertEquals(true, Naics_Service.mapCodeToTitle.containsKey('423'));
        System.assertEquals(true, Naics_Service.mapCodeToTitle.containsKey('423120'));
    }

    @IsTest
    static void test_is6DigitNaics() {
        System.assertEquals(false, Naics_Service.is6DigitNaics('ABCD'));
        System.assertEquals(false, Naics_Service.is6DigitNaics('123'));
        System.assertEquals(false, Naics_Service.is6DigitNaics('11'));
        System.assertEquals(false, Naics_Service.is6DigitNaics('423'));

        System.assertEquals(true, Naics_Service.is6DigitNaics('111111'));
        System.assertEquals(true, Naics_Service.is6DigitNaics('423120'));
    }

    @IsTest
    static void test_isValidCode() {
        System.assertEquals(false, Naics_Service.isValidCode('ABCD'));
        System.assertEquals(false, Naics_Service.isValidCode('123'));

        System.assertEquals(true, Naics_Service.isValidCode('111111'));
        System.assertEquals(true, Naics_Service.isValidCode('423120'));
        System.assertEquals(true, Naics_Service.isValidCode('423'));
        System.assertEquals(true, Naics_Service.isValidCode('11'));
    }

    @IsTest
    static void test_getTitle() {
        System.assertEquals(null, Naics_Service.getTitle('ABCD'));
        System.assertEquals(null, Naics_Service.getTitle('123'));

        System.assertEquals('Oilseed and Grain Farming', Naics_Service.getTitle('111111'));
        System.assertEquals('Motor Vehicle Supplies and New Parts Merchant Wholesalers', Naics_Service.getTitle('423120'));
        System.assertEquals('Merchant Wholesalers, Durable Goods', Naics_Service.getTitle('423'));
        System.assertEquals('Motor Vehicle Supplies and New Parts Merchant Wholesalers', Naics_Service.getTitle('423120'));
    }

    @IsTest
    static void test_getIndustry() {
        System.assertEquals(null, Naics_Service.getIndustry('ABCD'));
        System.assertEquals(null, Naics_Service.getIndustry('123'));
        System.assertEquals(null, Naics_Service.getIndustry('11'));

        System.assertEquals('Crop Production', Naics_Service.getIndustry('111111'));
        System.assertEquals('Merchant Wholesalers, Durable Goods', Naics_Service.getIndustry('423120'));
        System.assertEquals('Merchant Wholesalers, Durable Goods', Naics_Service.getIndustry('423'));
    }

    @IsTest
    static void test_populateNaics_Accounts() {
        Account account1 = new Account(
            Name = 'Account 1',
            NAICS__c = null
        );
        Account account2 = new Account(
            Name = 'Account 2',
            NAICS__c = 'BAD'
        );
        Account account3 = new Account(
            Name = 'Account 3',
            NAICS__c = '111111'
        );

        Test.startTest();

        Naics_Service.populateNaics(null, new List<Account>{ account1, account2, account3});

        Test.stopTest();

        System.assertEquals(null, account1.NAICS_Title__c);
        System.assertEquals(null, account1.Custom_Industry__c);
        System.assertEquals(true, account2.hasErrors());
        System.assertEquals('Oilseed and Grain Farming', account3.NAICS_Title__c);
        System.assertEquals('Crop Production', account3.Custom_Industry__c);
    }

    @IsTest
    static void test_populateNaics_Leads() {
        Id idrtClientLead = recordTypeService.getId('Lead', 'Client_Lead');
        Id idrtReferralPartnerLead = recordTypeService.getId('Lead', 'Referral Partner Lead');

        Lead lead1 = new Lead(
            recordTypeId = idrtClientLead,
            LastName = 'Lead 1',
            NAICS__c = null
        );
        Lead lead2 = new Lead(
            recordTypeId = idrtClientLead,
            LastName = 'Lead 2',
            NAICS__c = 'BAD'
        );
        Lead lead3 = new Lead(
            recordTypeId = idrtClientLead,
            LastName = 'Lead 3',
            NAICS__c = '111111'
        );
        Lead lead4 = new Lead(
            recordTypeId = idrtClientLead,
            LastName = 'Lead 4',
            NAICS__c = '111111',
            isConverted = true
        );
        Lead lead5 = new Lead(
            recordTypeId = idrtReferralPartnerLead,
            LastName = 'Lead 5',
            NAICS__c = '111111'
        );

        Test.startTest();

        Naics_Service.populateNaics(null, new List<Lead>{ lead1, lead2, lead3, lead4, lead5 });

        Test.stopTest();

        System.assertEquals(null, lead1.NAICS_Title__c);
        System.assertEquals(null, lead1.Custom_Industry__c);
        System.assertEquals(true, lead2.hasErrors());
        System.assertEquals('Oilseed and Grain Farming', lead3.NAICS_Title__c);
        System.assertEquals('Crop Production', lead3.Custom_Industry__c);
        System.assertEquals(null, lead4.NAICS_Title__c);
        System.assertEquals(null, lead4.Custom_Industry__c);
        System.assertEquals(null, lead5.NAICS_Title__c);
        System.assertEquals(null, lead5.Custom_Industry__c);
    }
}