/**
 * @description Organization_Service_Test contains test for the Organization_Service class.
 */
@IsTest
public without sharing class Organization_Service_Test {
    @IsTest
    static void test_getSandboxName() {
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1 ].IsSandbox;

        if (isSandbox) {
            Assert.isNotNull(Organization_Service.getSandboxName(), 'Sandbox name should exist.');
        } else {
            Assert.isNull(Organization_Service.getSandboxName(), 'Production does not have a sandbox name');
        }

        Assert.areNotEqual(
            null,
            Organization_Service.Organization,
            'The variable ogranization should have been read'
        );
    }

    @IsTest
    static void test_IsMethods() {
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1 ].IsSandbox;

        Assert.areEqual(isSandbox, Organization_Service.isSandbox(), 'Is Sandbox, but showing as Production');
        Assert.areEqual(isSandbox, !Organization_Service.isProduction(), 'Is Production, but showing as Sandbox');
    }

    @IsTest
    static void test_getOrgnaizationTitles() {
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1 ].IsSandbox;

        String title = Organization_Service.getOrgnaizationTitle();

        if (isSandbox) {
            Assert.isTrue(title.startsWith('Sandbox'), 'Sandbox titles should start will the work Sandbox');
        } else {
            Assert.areEqual('Production', title, 'Should be Production');
        }
    }

    @IsTest
    static void test_getApiVersions() {
        Assert.isNotNull(Organization_Service.ApiVersionFull, 'There should be an API Version');
        Assert.isNotNull(Organization_Service.ApiVersion, 'There should be an API Version');
    }

    @IsTest
    static void test_getVersion() {
        Assert.isNotNull(Organization_Service.getCurrentVersion(), 'There should be a Version');

        Assert.areEqual(Organization_Service.UNKNOWN_VERSION, Organization_Service.getVersion(0), 'Incorrect result');
        Assert.areEqual('Summer \'14', Organization_Service.getVersion(30), 'Incorrect result');
        Assert.areEqual('Winter \'15', Organization_Service.getVersion(31), 'Incorrect result');
        Assert.areEqual('Spring \'15', Organization_Service.getVersion(32), 'Incorrect result');
        Assert.areEqual('Summer \'15', Organization_Service.getVersion(33), 'Incorrect result');
        Assert.areEqual('Winter \'24', Organization_Service.getVersion(58), 'Incorrect result');
        Assert.areEqual('Spring \'24', Organization_Service.getVersion(59), 'Incorrect result');
        Assert.areEqual('Summer \'24', Organization_Service.getVersion(60), 'Incorrect result');
    }
}