/**
 * @description User_Services
 */
public without sharing class User_Services {
	private static final String DEFAULT_USER_FIELDS =
		'Id, Acronym__c, AD_Username__c, Branch_Id__c, CompanyName, ContactId, Department, ' +
		'Deployment_Access__c, Division, Email, FirstName, IsActive, LastName, ManagerId, ' +
		'Name, ProfileId, Title, UserName, UserRoleId, UserType';

	/**
	 * modifyProfiles is the list of profiles which are allowed to make changes to an User object.
	 */
	private static Set<String> modifyProfiles = new Set<String>{
		'System Administrator',
		'User Access Admin',
		'Administrative Support'
	};

	/**
	 * updatableFields is the list of fields a user may change about themselves.
	 */
	private static Set<String> updatableFields = new Set<String>{
		'AboutMe',
		'Alias',
		'City',
		'CommunityNickname',
		'CompanyName',
		'Country',
		'Department',
		'Division',
		'Email',
		'EmployeeNumber',
		'Extension',
		'Fax',
		'FirstName',
		'LastName',
		'MiddleName',
		'MobilePhone',
		'Phone',
		'PostalCode',
		'State',
		'Street',
		'Suffix',
		'TimeZoneSidKey',
		'Title'
	};

	/**
	 * checkFields are the User field which will be tested for change and if current user
	 * has the permissions to change.
	 */
	private static Set<String> checkFields = new Set<String>{
		'AboutMe',
		'Acronym__c',
		'AD_Username__c',
		'Address',
		'Alias',
		'BannerPhotoId',
		'BannerPhotoUrl',
		'Branch_ID__c',
		'CallCenterId',
		'City',
		'CommunityNickname',
		'CompanyName',
		'ContactId',
		'Country',
		'DefaultGroupNotificationFrequency',
		'DelegatedApproverId',
		'Department',
		'Deployment_Access__c',
		'DigestFrequency',
		'Division',
		'Email',
		'EmailEncodingKey',
		'EmployeeNumber',
		'EndDay',
		'Extension',
		'Fax',
		'FederationIdentifier',
		'FirstName',
		'ForecastEnabled',
		'GlobalIdentity',
		'IndividualId',
		'IsActive',
		'IsExtIndicatorVisible',
		'IsProfilePhotoActive',
		'IsSystemControlled',
		'LanguageLocaleKey',
		'LastName',
		'LocaleSidKey',
		'ManagerId',
		'MediumBannerPhotoUrl',
		'MediumPhotoUrl',
		'MiddleName',
		'MobilePhone',
		'Name',
		'OutOfOfficeMessage',
		'PasswordResetAttempt',
		'PasswordResetLockoutDate',
		'Phone',
		'PostalCode',
		'ProfileId',
		'ReceivesAdminInfoEmails',
		'ReceivesInfoEmails',
		'SenderEmail',
		'SenderName',
		'Signature',
		'SmallBannerPhotoUrl',
		'SpringCMEos__Portal_Only__c',
		'SpringCMEos__SpringCM_EnabledEndDate__c',
		'SpringCMEos__SpringCM_EnabledStartDate__c',
		'SpringCMEos__SpringCM_Persona__c',
		'SpringCMEos__SpringCM_Role__c',
		'SpringCMEos__SpringCM_User__c',
		'StartDay',
		'State',
		'StayInTouchNote',
		'StayInTouchSignature',
		'StayInTouchSubject',
		'Street',
		'Suffix',
		'TimeZoneSidKey',
		'Title',
		'User_Log_Changes__c',
		'Username',
		'UserRoleId',
		'UserSubtype',
		'WorkspaceId'
	};

	/**
	 * @description idUserAMs holds the ids of the Area Managers and those
	 * with the Area Manager Permission Set.
	 */
	private static Set<Id> idUserAMs = null;

	/**
	 * @description getUserRecordsMap retrieves a list of User branches given
	 * the User Ids.
	 * @param  newOwners
	 * @return a map of user records for a list of user ids
	 * add any fields you need to the query.
	 */
	public static Map<Id, User> getUserRecordsMap(Set<Id> newOwners) {
		// FUTURE: Replace with getUsers()
		return new Map<Id, User>([SELECT Id, Branch_ID__c FROM User WHERE Id IN :newOwners]);
	}

	/**
	 * @description getUsers retrieved User information for the given user ids.
	 * @param userIds - A list of user ids to get information
	 * @return A Map of User Id to User records
	 */
	public static Map<Id, User> getUsers(Set<Id> userIds) {
		return new Map<Id, User>(getUserList(userIds));
	}

	/**
	 * @description getUserList retrieved User information for the given user ids.
	 * @param userIds - A list of user ids to get information
	 * @return List of User records
	 */
	public static List<User> getUserList(Set<Id> userIds) {
		return [
			SELECT Id, IsActive, FirstName, LastName, Email, ManagerId, UserRoleId, UserType, UserName, ContactId, Branch_Id__c
			FROM User
			WHERE Id IN :userIds
		];
	}

	/**
	 * @description getUsers retrieved User information for the given user names.
	 * @param names - A list of user names
	 * @return A Map of User Name to User records
	 */
	public static Map<Id, User> getUsers(Set<String> names) {
		return new Map<Id, User>(getUserList(names));
	}

	/**
	 * @description getUserList retrieved User information for the given user names.
	 * @param names - A list of user names
	 * @return List of User records
	 */
	public static List<User> getUserList(Set<String> names) {
		return [
			SELECT Id, IsActive, FirstName, LastName, Email, ManagerId, UserRoleId, UserType, UserName, ContactId, Branch_Id__c
			FROM User
			WHERE Name IN :names
		];
	}

	/**
	 * @description getUsersByBranchNo retrieved User information for the given branch numbers.
	 * @param branchNos - A list of branch numbers (External Ids)
	 * @return A Map of User Name to User records
	 */
	public static Map<Id, User> getUsersByBranchNo(Set<String> branchNos) {
		return new Map<Id, User>(getUserListByBranchNo(branchNos));
	}

	/**
	 * @description getUserListByBranchNo retrieved User information for the given branch numbers.
	 * @param branchNos - A list of branch numbers (External Ids)
	 * @return List of User records
	 */
	public static List<User> getUserListByBranchNo(Set<String> branchNos) {
		return [
			SELECT Id, IsActive, FirstName, LastName, Email, ManagerId, UserRoleId, UserType, UserName, ContactId, Branch_Id__c
			FROM User
			WHERE Branch_Id__c IN :branchNos
		];
	}

	/**
	 * @description getUsers retrieves User information.
	 * @param  idUsers      User identifiers
	 * @param  onlyActive   Only return active Users
	 * @param  fields       Fields to return. If null uses the default list.
	 * @return Map relating User Ids to User records
	 */
	public static Map<Id, User> getUsers(Set<Id> idUsers, Boolean onlyActive, List<String> fields) {
		return new Map<Id, User>(getUserList(idUsers, onlyActive, fields));
	}

	/**
	 * @description getUserList retrieves User information.
	 * @param  idUsers      User identifiers
	 * @param  onlyActive   Only return active Users
	 * @param  fields       Fields to return. If null uses the default list.
	 * @return List of User records
	 */
	public static List<User> getUserList(Set<Id> idUsers, Boolean onlyActive, List<String> fields) {
		if (idUsers == null || idUsers.isEmpty()) {
			return new List<User>();
		}

		String strUserIds = String.join(new List<Id>(idUsers), '\', \'');
		String strFields = DEFAULT_USER_FIELDS;

		if (fields != null) {
			strFields = String.join(fields, ', ');
		}

		String query = 'SELECT ' + strFields + ' FROM User' + ' WHERE Id IN (\'' + strUserIds + '\')';

		if (onlyActive) {
			query += ' AND IsActive = true';
		}

		return (List<User>) Database.query(query);
	}

	/**
	 * @description getRelatedContactIds retrieves Contact information related to the given users
	 * @param idUsers - User Ids to get Contact information for
	 * @return A map related User Id to their Contact Id.  Warning: Contact Id wiil be null
	 * if there  is not a relationship.
	 */
	public static Map<Id, Id> getRelatedContactIds(Set<Id> idUsers) {
		Map<Id, Id> result = new Map<Id, Id>();

		for (Id idUser : idUsers) {
			result.put(idUser, null);
		}

		for (Contact c : [SELECT Id, User_Id__c FROM Contact WHERE User_Id__c IN :idUsers]) {
			if (!String.isBlank(c.User_Id__c)) {
				result.put(c.User_Id__c, c.Id);
			}
		}

		return result;
	}

	/**
	 * @description limitEditOfUsers only certain profiles are allowed to edit a User,
	 * so block all others.
	 * @param mapNew is the changes to the User objects
	 * @param mapOld is the previous values of the User objects
	 * @return true if no errors
	 */
	public static Boolean limitEditOfUsers(Map<Id, User> mapNew, Map<Id, User> mapOld) {
		Boolean success = true;
		Map<Id, Profile> mapProfiles = new Map<Id, Profile>(
			[
				SELECT Id, Name
				FROM Profile
				WHERE Name IN :modifyProfiles
			]
		);

		if (!mapProfiles.containsKey(UserInfo.getProfileId())) {
			for (User u : mapNew.values()) {
				if (mapOld == null) {
					u.addError('Insufficient privileges to create a new User.');
					success = false;
				} else if (u.Id != UserInfo.getUserId()) {
					u.addError('Insufficient privileges to change other User\'s information.');
					success = false;
				} else if (!changedOnlyAllowedFields(u, mapOld.get(u.Id))) {
					u.addError('Insufficient privileges to change User information.');
					success = false;
				}
			}
		}

		return success;
	}

	/**
	 * @description changedOnlyAllowedFields runs through all the changed fields to
	 * confirm only the allowed ones have been changed.
	 * @param  userNew values changed to
	 * @param  userOld values changed from
	 * @return true if only the allowed fields have been changed
	 */
	@TestVisible
	private static Boolean changedOnlyAllowedFields(User userNew, User userOld) {
		if (userOld == null) {
			return false;
		}

		Boolean result = true;

		if (userNew != null) {
			for (String field : checkFields) {
				try {
					if (userNew.get(field) != userOld.get(field)) {
						if (!updatableFields.contains(field)) {
							result = false;
							System.debug(
								LoggingLevel.ERROR,
								'CHANGED FIELD: ' +
									field +
									' FROM: ' +
									userOld.get(field) +
									' TO: ' +
									userNew.get(field)
							);
						}
					}
				} catch (Exception e) {
					System.debug(LoggingLevel.ERROR, 'Exception: ' + e);
				}
			}
		}

		return result;
	}

	/**
	 * @description checkBusinessUnitMembers deactive any Business Unit Members related to
	 * users being deactivated.
	 * @param  mapNewUsers map of new user values
	 * @param  mapOldUsers map of previous user values
	 */
	public static void checkBusinessUnitMembers(Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers) {
		Set<Id> inactiveIds = new Set<Id>();

		for (User newUser : mapNewUsers.values()) {
			if (!newUser.IsActive) {
				if (mapOldUsers == null || mapOldUsers.get(newUser.Id).IsActive) {
					inactiveIds.add(newUser.Id);
				}
			}
		}

		if (!inactiveIds.isEmpty()) {
			Map<Id, Business_Unit_Contact__c> bums = new Map<Id, Business_Unit_Contact__c>(
				[
					SELECT Id
					FROM Business_Unit_Contact__c
					WHERE Active__c = TRUE AND BU_Member__c != NULL AND BU_Member__r.User_Id__c IN :inactiveIds
				]
			);

			if (!bums.isEmpty()) {
				futureDeactivateBUMembers(bums.keySet());
			}
		}
	}

	/**
	 * @description futureDeactivateBUMembers deactivates a set of Business Unit Members (Business_Unit_Contact__c).
	 * @param  bumIds Set of Business Unit Member Ids to deactivate.
	 */
	@future
	public static void futureDeactivateBUMembers(Set<Id> bumIds) {
		List<Business_Unit_Contact__c> bums = [
			SELECT Id, Active__c, Active_Date__c
			FROM Business_Unit_Contact__c
			WHERE Id IN :bumIds
		];

		for (Business_Unit_Contact__c bum : bums) {
			bum.Active__c = false;
			bum.Inactive_Date__c = System.today();
		}

		update bums;
	}

	/**
	 * @description handleDeactivatedUsers runs through the users being deactivated
	 * and confirms they can be.
	 * @param  newMap newMap description
	 * @param  oldMap oldMap description
	 */
	public static void handleDeactivatedUsers(Map<Id, User> newMap, Map<Id, User> oldMap) {
		Set<Id> deactivatedUserIds = new Set<Id>();

		for (User u : newMap.Values()) {
			if (oldMap.get(u.Id).IsActive == true && u.IsActive == false) {
				deactivatedUserIds.add(u.Id);
			}
		}

		if (!deactivatedUserIds.isEmpty()) {
			confirmNotRecordOwner(deactivatedUserIds, newMap);
			confirmNotAreaManager(deactivatedUserIds, newMap);
		}
	}

	/**
	 * @description confirmNotRecordOwner blocks users from being deactivated if they still
	 * have ownership of Accounts, Leads or Opportunities.
	 * @param  deactivatedUsers
	 * @param  newMap Changes made to User objects
	 */
	private static void confirmNotRecordOwner(Set<Id> deactivatedUsers, Map<Id, User> newMap) {
		Id idUser;

		for (AggregateResult obj : [
			SELECT OwnerId, Count_Distinct(RecordTypeId) Total
			FROM Account
			WHERE OwnerId IN :deactivatedUsers
			GROUP BY OwnerId
		]) {
			idUser = (Id) obj.get('OwnerId');
			newMap.get(idUser)
				.addError('User is still the owner of some Accounts.  Transfer accounts before deactivating.');
		}

		for (AggregateResult obj : [
			SELECT OwnerId, Count_Distinct(RecordTypeId) Total
			FROM Lead
			WHERE OwnerId IN :deactivatedUsers AND IsConverted = FALSE
			GROUP BY OwnerId
		]) {
			idUser = (Id) obj.get('OwnerId');
			newMap.get(idUser).addError('User is still the owner of some Leads.  Transfer leads before deactivating.');
		}

		for (AggregateResult obj : [
			SELECT OwnerId, Count_Distinct(RecordTypeId) Total
			FROM Opportunity
			WHERE
				OwnerId IN :deactivatedUsers
				AND (StageName != 'Closed Won'
				OR StageName != 'Benefits Closed Won'
				OR StageName != 'Closed Lost')
			GROUP BY OwnerId
		]) {
			idUser = (Id) obj.get('OwnerId');
			newMap.get(idUser)
				.addError(
					'User is still the owner of some Opportunities.  Transfer opportunities before deactivating.'
				);
		}
	}

	/**
	 * @description confirmNotAreaManager confirms there is not a Branch Account with
	 * the deactivating user is the Area Manager.
	 * @param  deactivatedUsers
	 * @param  newMap Changes made to User objects
	 */
	private static void confirmNotAreaManager(Set<Id> deactivatedUsers, Map<Id, User> newMap) {
		Map<String, User> mapNameToUser = new Map<String, User>();

		for (User u : [SELECT Id, Name FROM User WHERE Id IN :deactivatedUsers]) {
			mapNameToUser.put(u.Name, u);
		}

		for (Account acc : [
			SELECT Branch_Manager__c, Name
			FROM Account
			WHERE Branch_Manager__c IN :mapNameToUser.keySet() AND RecordType.Name = 'BBSI Branch'
		]) {
			Id userId = mapNameToUser.get(acc.Branch_Manager__c).Id;
			newMap.get(userId)
				.addError(
					'User is Area Manager of the branch ' + acc.Name + '.  Set new Area Manager before deactivating.'
				);
		}
	}

	/**
	 * @description actsAsAreaManager determines if the given user may act
	 * as an Area Manager.  Must have Area Manager Profile or Area Manager
	 * Approval Permission Set.
	 * @param  idUser  Profile identifier
	 * @return true if current user can act as an Area Manager
	 */
	public static Boolean actsAsAreaManager(Id idUser) {
		if (idUserAms == null) {
			idUserAms = new Set<Id>();

			for (User u : [SELECT Id FROM User WHERE Profile.Name = :Profile_Service.AREA_MANAGER]) {
				idUserAMs.add(u.Id);
			}

			for (PermissionSetAssignment psa : [
				SELECT AssigneeId
				FROM PermissionSetAssignment
				WHERE PermissionSet.Name = :PermissionSet_Service.AREA_MANAGER_APPROVER_LABEL
			]) {
				idUserAMs.add(psa.AssigneeId);
			}
		}

		return idUserAms.contains(idUser);
	}
}