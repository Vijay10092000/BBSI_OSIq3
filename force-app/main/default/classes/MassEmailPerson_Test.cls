/**
 * @description MassEmailPerson_Test contains tests for the MassEmailPerson class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.AvoidHardcodingId')
public without sharing class MassEmailPerson_Test {
	@IsTest
	public static void test_construtor() {
		MassEmailPerson person1 = new MassEmailPerson(
			'Id1',
			Id.valueOf('0015000000sJCQFAA4'),
			'AccountName',
			Id.valueOf('0032J00003Y3pm0QAB'),
			'CONTACT',
			'Contact Name',
			'Contact.Name@AccountName.zzz',
			Id.valueOf('0052J00003Y3pm0QAB'),
			'Owner Name',
			'Owner.Name@bbsi.zzz',
			Id.valueOf('0052J00003Y3pm1QAB'),
			'Benefits Rep',
			'Benefits.Rep@bbsi.zzz'
		);
		MassEmailPerson person2 = new MassEmailPerson(
			'Id2',
			Id.valueOf('0015000000sJCQFAA4'),
			'AccountName',
			Id.valueOf('0032J00003Y3pm0QAB'),
			'CONTACT',
			'Contact Name',
			null,
			Id.valueOf('0052J00003Y3pm0QAB'),
			'Owner Name',
			'Owner.Name@bbsi.zzz',
			Id.valueOf('0052J00003Y3pm1QAB'),
			'Benefits Rep',
			'Benefits.Rep@bbsi.zzz'
		);
		MassEmailPerson person3 = new MassEmailPerson();

		Assert.areEqual(true, person1.allowSend);
		Assert.areEqual('0015000000sJCQFAA4', person1.idAccount);
		Assert.areEqual('AccountName', person1.nameAccount);
		Assert.areEqual('0032J00003Y3pm0QAB', person1.idPerson);
		Assert.areEqual('CONTACT', person1.typePerson);
		Assert.areEqual('Contact Name', person1.namePerson);
		Assert.areEqual('Contact.Name@AccountName.zzz', person1.emailPerson);
		Assert.areEqual('0052J00003Y3pm0QAB', person1.idOwner);
		Assert.areEqual('Owner Name', person1.nameOwner);
		Assert.areEqual('Owner.Name@bbsi.zzz', person1.emailOwner);
		Assert.areEqual('0052J00003Y3pm1QAB', person1.idBenefitsRep);
		Assert.areEqual('Benefits Rep', person1.nameBenefitsRep);
		Assert.areEqual('Benefits.Rep@bbsi.zzz', person1.emailBenefitsRep);
		Assert.areEqual(null, person1.status);
		Assert.areEqual(null, person1.emailSubject);
		Assert.areEqual(null, person1.emailBody);

		Assert.areEqual(false, person2.allowSend);
		Assert.areEqual('0015000000sJCQFAA4', person2.idAccount);
		Assert.areEqual('AccountName', person2.nameAccount);
		Assert.areEqual('0032J00003Y3pm0QAB', person2.idPerson);
		Assert.areEqual('CONTACT', person2.typePerson);
		Assert.areEqual('Contact Name', person2.namePerson);
		Assert.areEqual(null, person2.emailPerson);
		Assert.areEqual('Owner Name', person2.nameOwner);
		Assert.areEqual('Owner.Name@bbsi.zzz', person2.emailOwner);
		Assert.areEqual('Benefits Rep', person2.nameBenefitsRep);
		Assert.areEqual('Benefits.Rep@bbsi.zzz', person2.emailBenefitsRep);
		Assert.areEqual(null, person2.status);

		Assert.areEqual(false, person3.allowSend);
		Assert.areEqual(null, person3.idAccount);
		Assert.areEqual(null, person3.nameAccount);
		Assert.areEqual(null, person3.idPerson);
		Assert.areEqual(null, person3.typePerson);
		Assert.areEqual(null, person3.namePerson);
		Assert.areEqual(null, person3.emailPerson);
		Assert.areEqual(null, person3.nameOwner);
		Assert.areEqual(null, person3.emailOwner);
		Assert.areEqual(null, person3.nameBenefitsRep);
		Assert.areEqual(null, person3.emailBenefitsRep);
		Assert.areEqual(null, person3.status);

		Assert.areEqual(false, person3.isValid());

		person3.idAccount = '0010000000hNytFW2';
		person3.nameAccount = 'Test Account Name';
		Assert.areEqual(false, person3.isValid());

		person3.idPerson = '0030000000hNytFW2';
		person3.typePerson = 'CONTACT';
		person3.namePerson = 'Test Contact Name';
		person3.emailPerson = 'Test.Contact.Name@TestAccountName.zzz';
		Assert.areEqual(false, person3.isValid());

		person3.idOwner = '0050000000hNytFW2';
		person3.nameOwner = 'Test User Name';
		person3.emailOwner = 'Test.User.Name@TestAccountName.zzz';
		Assert.areEqual(false, person3.isValid());
	}

	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	public static void test_dump() {
		MassEmailPerson person = new MassEmailPerson();

		person.dump(LoggingLevel.FINEST);

		// There is no Assert available for this.
	}
}