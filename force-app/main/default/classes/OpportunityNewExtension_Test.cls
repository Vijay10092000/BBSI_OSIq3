/**
 * @description OpportunityNewExtension_Test contains tests for the OpportunityNewExtension class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class OpportunityNewExtension_Test {
	@IsTest
	public static void test_OpportunityClient() {
		Account client = TestFactoryAccount.createClient('!!!TEST CLIENT', null, null);
		Id idRt = RecordTypeService.getId('Opportunity', 'Client');

		//Opportunity opp = new Opportunity(Name = 'CLIENT - TEST CLIENT', AccountId = client.Id, RecordTypeId = idRt);
		Opportunity opp = TestFactoryOpportunity.makeClient('CLIENT - TEST CLIENT',client.Id,null,null);
		ApexPages.StandardController controller = new ApexPages.StandardController(opp);
		OpportunityNewExtension extension = new OpportunityNewExtension(controller);

		Assert.areEqual(true, extension.showBlocker);
		Assert.areEqual(client.Id, extension.idAccount);
		Assert.areEqual(idRt, extension.idrtNewOpp);

		Test.startTest();

		PageReference ref = extension.redirect();

		Test.stopTest();

		Assert.areEqual(true, ref.getRedirect());
		Assert.areEqual('/apex/NewOpportunityWarning', ref.getUrl());
	}

	@IsTest
	public static void test_OpportunityBenefits() {
		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', JSON_RESPONSE_FIRST_STAGE, null));

		Account client = TestFactoryAccount.createClient('!!!TEST CLIENT', null, null);
		Id idRt = RecordTypeService.getId('Opportunity', 'Benefits');

		//Opportunity opp = new Opportunity(Name = 'Opp - TEST CLIENT', AccountId = client.Id, RecordTypeId = idRt);
		Opportunity opp = TestFactoryOpportunity.makeBenefits('Opp - TEST CLIENT',client.Id,null,'');
		ApexPages.StandardController controller = new ApexPages.StandardController(opp);
		OpportunityNewExtension extension = new OpportunityNewExtension(controller);

		Assert.areEqual(false, extension.showBlocker);
		Assert.areEqual(client.Id, extension.idAccount);
		Assert.areEqual(idRt, extension.idrtNewOpp);

		Test.startTest();

		PageReference ref = extension.redirect();

		Test.stopTest();

		List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :client.Id];

		Assert.areEqual(1, opps.size());

		opp = opps.get(0);
		Assert.areEqual('Benefits: !!!TEST CLIENT', opp.Name);

		Assert.areEqual('/' + opp.Id, ref.getUrl());
	}

	@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart')
	private static final String JSON_RESPONSE_FIRST_STAGE =
	'{' +
	' "eTag":"bf8ed4a078f878f4d76caa3d1beeaa83",' +
	' "picklistFieldValues":{' +
	'  "StageName":{' +
	'   "controllerValues":{' +
	'   },' +
	'   "defaultValue":null,' +
	'   "eTag":"830884c9a49e8a05206893f56658d3bc",' +
	'   "url":"/services/data/v51.0/ui-api/object-info/Opportunity/picklist-values/0122J000000goXWQAY/StageName",' +
	'   "values":[' +
	'      {' +
	'        "attributes":{' +
	'         "closed":false,' +
	'         "defaultProbability":30.0,' +
	'         "forecastCategoryName":"Pipeline",' +
	'         "picklistAtrributesValueType":"OpportunityStage",' +
	'         "won":false' +
	'        },' +
	'        "label":"Pending Submission",' +
	'        "validFor":[' +
	'         ' +
	'        ],' +
	'        "value":"Pending Submission"' +
	'      },' +
	'      {' +
	'        "attributes":{' +
	'         "closed":false,' +
	'         "defaultProbability":58.0,' +
	'         "forecastCategoryName":"Pipeline",' +
	'         "picklistAtrributesValueType":"OpportunityStage",' +
	'         "won":false' +
	'        },' +
	'        "label":"Underwriting",' +
	'        "validFor":[' +
	'         ' +
	'        ],' +
	'        "value":"Underwriting"' +
	'      },' +
	'      {' +
	'        "attributes":{' +
	'         "closed":false,' +
	'         "defaultProbability":95.0,' +
	'         "forecastCategoryName":"Pipeline",' +
	'         "picklistAtrributesValueType":"OpportunityStage",' +
	'         "won":false' +
	'        },' +
	'        "label":"Post Enrollment",' +
	'        "validFor":[' +
	'         ' +
	'        ],' +
	'        "value":"Post Enrollment"' +
	'      },' +
	'      {' +
	'        "attributes":{' +
	'         "closed":true,' +
	'         "defaultProbability":100.0,' +
	'         "forecastCategoryName":"Closed",' +
	'         "picklistAtrributesValueType":"OpportunityStage",' +
	'         "won":true' +
	'        },' +
	'        "label":"Benefits Closed Won",' +
	'        "validFor":[' +
	'         ' +
	'        ],' +
	'        "value":"Benefits Closed Won"' +
	'      }' +
	'     ]' +
	'   }' +
	'  }' +
	'}';
}