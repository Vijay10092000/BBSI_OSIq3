/**
 * @description Profile_Service_Test contains tests for the Profile_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class Profile_Service_Test {
	private static final Id FAKE_PROFILE_ID = Id.valueof('00e000000000000');

	@IsTest
	static void test_isProfile() {
		Profile systemAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile configAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'Configuration Admin' LIMIT 1];

		Assert.isTrue(Profile_Service.isProfile('System Administrator', systemAdmin.Id));
		Assert.isTrue(Profile_Service.isProfile('Configuration Admin', configAdmin.Id));

		Assert.isFalse(Profile_Service.isProfile('Configuration Admin', systemAdmin.Id));
		Assert.isFalse(Profile_Service.isProfile('System Administrator', configAdmin.Id));

		Assert.isFalse(Profile_Service.isProfile('Invalid Profile', configAdmin.Id));
	}

	@IsTest
	static void test_getProfileByName() {
		Assert.areEqual('System Administrator', Profile_Service.getProfile('System Administrator').Name);
		Assert.areEqual('Configuration Admin', Profile_Service.getProfile('Configuration Admin').Name);
		Assert.areEqual('BBSI Support', Profile_Service.getProfile('BBSI Support').Name);
		Assert.isNull(Profile_Service.getProfile('Bad Profile'));
	}

	@IsTest
	static void test_getProfileById() {
		Profile systemAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile bbsiSupport = (Profile) [SELECT Id FROM Profile WHERE Name = 'BBSI Support' LIMIT 1];

		Assert.areEqual(systemAdmin.Id, Profile_Service.getProfile(systemAdmin.Id).Id);
		Assert.areEqual(bbsiSupport.Id, Profile_Service.getProfile(bbsiSupport.Id).Id);
		Assert.isNull(Profile_Service.getProfile(FAKE_PROFILE_ID));
	}

	@IsTest
	static void test_getProfileId() {
		Profile systemAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile bbsiSupport = (Profile) [SELECT Id FROM Profile WHERE Name = 'BBSI Support' LIMIT 1];

		Assert.areEqual(systemAdmin.Id, Profile_Service.getProfileId('System Administrator'));
		Assert.areEqual(bbsiSupport.Id, Profile_Service.getProfileId('BBSI Support'));
		Assert.isNull(Profile_Service.getProfileId('Bad Profile'));
	}

	@IsTest
	static void test_getProfileName() {
		Profile systemAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile bbsiSupport = (Profile) [SELECT Id FROM Profile WHERE Name = 'BBSI Support' LIMIT 1];

		Assert.areEqual('System Administrator', Profile_Service.getProfileName(systemAdmin.Id));
		Assert.areEqual('BBSI Support', Profile_Service.getProfileName(bbsiSupport.Id));
		Assert.isNull(Profile_Service.getProfileName(FAKE_PROFILE_ID));
	}

	@IsTest
	static void test_isAreaManager() {
		Profile areaManager = (Profile) [SELECT Id FROM Profile WHERE Name = 'Area Manager' LIMIT 1];
		Profile bbsiSupport = (Profile) [SELECT Id FROM Profile WHERE Name = 'BBSI Support' LIMIT 1];

		Assert.isTrue(Profile_Service.isAreaManager(areaManager.Id));
		Assert.isFalse(Profile_Service.isAreaManager(bbsiSupport.Id));
	}

	@IsTest
	static void test_isSystemAdministrator() {
		Profile systemAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile bbsiSupport = (Profile) [SELECT Id FROM Profile WHERE Name = 'BBSI Support' LIMIT 1];

		Assert.isTrue(Profile_Service.isSystemAdministrator(systemAdmin.Id));
		Assert.isFalse(Profile_Service.isSystemAdministrator(bbsiSupport.Id));
	}

	@IsTest
	static void test_mayConfigure() {
		Profile systemAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile configAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'Configuration Admin' LIMIT 1];
		Profile userAdmin = (Profile) [SELECT Id FROM Profile WHERE Name = 'User Access Admin' LIMIT 1];
		Profile bbsiSupport = (Profile) [SELECT Id FROM Profile WHERE Name = 'BBSI Support' LIMIT 1];

		Assert.isTrue(Profile_Service.mayConfigure(systemAdmin.Id));
		Assert.isTrue(Profile_Service.mayConfigure(configAdmin.Id));
		Assert.isFalse(Profile_Service.mayConfigure(userAdmin.Id));
		Assert.isFalse(Profile_Service.mayConfigure(bbsiSupport.Id));
	}
}