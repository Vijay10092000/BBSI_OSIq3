/**
 * @description TestFactoryContact contains methods to create test Contacts.
 */
@IsTest
public without sharing class TestFactoryContact {
	private static final String BBSI_EMPLOYEE = 'BBSI Employee';
	private static final String CLIENT_CONTACT = 'Client Contact';
	private static final String PRODUCER = 'Producer';

	/**
	 * @description createContact creates a Contact record in the database.
	 * @param  firstName   First name of Contact
	 * @param  lastName    Last name of Contact
	 * @param  recordType  Record Type name
	 * @param  idAccount   Account identifier related to Contact
	 * @return Contact
	 */
	public static Contact createContact(String firstName, String lastName, String recordType, Id idAccount) {
		Contact contact = makeContact(firstName, lastName, recordType, idAccount);
		insert contact;
		return contact;
	}
	/**
	 * @description makeContact makes a Contact object.
	 * @param  firstName   First name of Contact
	 * @param  lastName    Last name of Contact
	 * @param  recordType  Record Type name
	 * @param  idAccount   Account identifier related to Contact
	 * @param  email 
	 * @return Contact
	 */
    public static Contact makeContact(String firstName, String lastName, String recordType, Id idAccount, String email) {
    	Contact contact =  new Contact(
			Active__c = true,
			FirstName = firstName,
			LastName = lastName,
			AccountId = idAccount,
			Phone = TestFactory.nextPhoneNumber(),
			Email = email
		);  
		if(String.isNotBlank(recordType)){
			contact.RecordTypeId = RecordTypeService.getId('Contact', recordType);
		}
		return contact;  
    }
	/**
	 * @description makeContact makes a Contact object.
	 * @param  firstName   First name of Contact
	 * @param  lastName    Last name of Contact
	 * @param  recordType  Record Type name
	 * @param  idAccount   Account identifier related to Contact
	 * @return Contact
	 */
	public static Contact makeContact(String firstName, String lastName, String recordType, Id idAccount) {
		String email = (firstName != null ? firstName + '.' : '') + lastName + '@bbsi.zzz';
		email = email.replaceAll('(\\s+)', '');
		return makeContact(firstName, lastName, recordType, idAccount, email);
	}

	/**
	 * @description createContact creates a Client Contact record in the database.
	 * @param  firstName  First name of Contact
	 * @param  lastName   Last name of Contact
	 * @param  idAccount  Account identifier related to Contact
	 * @return Contact
	 */
	public static Contact createClient(String firstName, String lastName, Id idAccount) {
		Contact contact = makeClient(firstName, lastName, idAccount);
		insert contact;
		return contact;
	}

	/**
	 * @description makeClient makes a Client Contact object.
	 * @param  firstName  First name of Contact
	 * @param  lastName   Last name of Contact
	 * @param  idAccount  Account identifier related to Contact
	 * @return Contact
	 */
	public static Contact makeClient(String firstName, String lastName, Id idAccount) {
		return makeContact(firstName, lastName, CLIENT_CONTACT, idAccount);
	}

	/**
	 * @description createProducer creates a Producer Contact record in the database.
	 * @param  firstName  First name of Contact
	 * @param  lastName   Last name of Contact
	 * @param  idAccount  Account identifier related to Contact
	 * @return Contact
	 */
	public static Contact createProducer(String firstName, String lastName, Id idAccount) {
		Contact contact = makeProducer(firstName, lastName, idAccount);
		insert contact;
		return contact;
	}

	/**
	 * @description makeClient makes a Producer Contact object.
	 * @param  firstName  First name of Contact
	 * @param  lastName   Last name of Contact
	 * @param  idAccount  Account identifier related to Contact
	 * @return Contact
	 */
	public static Contact makeProducer(String firstName, String lastName, Id idAccount) {
		return makeContact(firstName, lastName, PRODUCER, idAccount);
	}

	/**
	 * @description createEmployee creates an Employee Contact record in the database.
	 * @param  idUser     Id of User
	 * @param  firstName  First name of User
	 * @param  lastName   Last name of User
	 * @param  idAccount  Account identifier related to Contact
	 * @return Contact
	 */
	public static Contact createEmployee(Id idUser, String firstName, String lastName, Id idAccount) {
		Contact contact = makeEmployee(idUser, firstName, lastName, idAccount);
		insert contact;
		return contact;
	}

	/**
	 * @description makeEmployee creates an Employee Contact object.
	 * @param  idUser     Id of User
	 * @param  firstName  First name of User
	 * @param  lastName   Last name of User
	 * @param  idAccount  Account identifier related to Contact
	 * @return Contact
	 */
	public static Contact makeEmployee(Id idUser, String firstName, String lastName, Id idAccount) {
		String email = (firstName != null ? firstName + '.' : '') + lastName + '@bbsi.zzz';
		email = email.replaceAll('(\\s+)', '');
		Contact contact = makeContact(firstName, lastName, BBSI_EMPLOYEE, idAccount);
		contact.User_Id__c = idUser;		
		contact.Email = email;
		return contact;
	}
}