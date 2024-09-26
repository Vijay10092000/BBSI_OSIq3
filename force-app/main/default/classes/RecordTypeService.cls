/**
 * @description RecordTypeService gives access to SObject Record Types without querying
 * for the information
 * Created: 11/14/2016  Harold Crouse
 */
public without sharing class RecordTypeService {
	public static final String ACCOUNT_PROSPECT = 'Account.Prospect';
	public static final String ACCOUNT_CLIENT = 'Account.Client';
	public static final String ACCOUNT_BRANCH = 'Account.BBSI Branch';
	public static final String ACCOUNT_HUB = 'Account.BBSI Hub';
	public static final String ACCOUNT_LOCATION = 'Account.Location';
	public static final String ACCOUNT_PARENT = 'Account.Parent';
	public static final String ACCOUNT_REFERRAL_PARTNER = 'Account.Referral Partner';
	public static final String ACCOUNT_SENT_CONTRACTS = 'Account.Sent to Contracts';
	public static final String ACCOUNT_TERMINATED = 'Account.Terminated';
	public static final String ACCOUNT_VENDOR = 'Account.Vendor';

	public static final String BUSINESS_ACTIVITY_GOAL_BEM = 'Business Activity Goal.BDM Goal';
	public static final String BUSINESS_ACTIVITY_GOAL_BRANCH = 'Business Activity Goal.BDM Branch Goal';

	public static final String CONTACT_EMPLOYEE = 'Contact.BBSI Employee';
	public static final String CONTACT_CLIENT = 'Contact.Client';
	public static final String CONTACT_OTHER = 'Contact.Other';
	public static final String CONTACT_PRODUCER = 'Contact.Producer';

	public static final String LEAD_CLIENT = 'Lead.Client Lead';
	public static final String LEAD_REFERRAL_PARTNER = 'Lead.Referral Partner Lead';

	public static final String REFERRAL_SOURCE_CLIENT = 'Referrsl Source.Client Referral Partner';
	public static final String REFERRAL_SOURCE_LEAD = 'Referrsl Source.Lead Referral Partner';
	public static final String REFERRAL_SOURCE_OPPORTUNITY = 'Referrsl Source.Opportunity Referral Partner';

	public static final String TASK_BENEFITS = 'Task.Benefits Task';
	public static final String TASK_EVENT = 'Task.Event Task';
	public static final String TASK_HUBSPOT = 'Task.HubSpot Activity';
	public static final String TASK_LOG_CALL = 'Task.Log a Call';
	public static final String TASK_TASK = 'Task.Task';

	public static final String RP_CHANGE_REQUEST_REFERRAL_PARTNER = 'Referral Partner Change Request.Commission Change - Referral Partner';
	public static final String RP_CHANGE_REQUEST_GROUP_COMMISSION = 'Referral Partner Change Request.Group Commission Change';
	public static final String RP_CHANGE_REQUEST_HOLD_CLIENT = 'Referral Partner Change Request.Hold Request - Client';
	public static final String RP_CHANGE_REQUEST_HOLD_REFERRAL_PARTNER = 'Referral Partner Change Request.Hold Request - Referral Partner';
	public static final String RP_CHANGE_REQUEST_OVERRIDE = 'Referral Partner Change Request.Override Request - Client';
	public static final String RP_CHANGE_REQUEST_RELEASE_CLIENT = 'Referral Partner Change Request.Release Hold - Client';
	public static final String RP_CHANGE_REQUEST_RELEASE_REFERRAL_PARTNER = 'Referral Partner Change Request.Release Hold - Referral Partner';
	public static final String RP_CHANGE_REQUEST_RPOR_CHANGE = 'Referral Partner Change Request.RPOR Change - Client';
    public static final String RP_CHANGE_REQUEST_REQUEST_ACTIVATION = 'Referral Partner Change Request.Request Activation';

	// Relate a SObject to all its RecordTypes
	private static Map<String, List<RTInfo>> recordTypes = new Map<String, List<RTInfo>>();

	//@SuppressWarnings('PMD.VariableNamingConventions')
	private class RTInfo {
		/**
		 * @description Identifier of the Record Type
		 */
		public Id id { get; private set; }

		/**
		 * @description Name of the Record Type
		 */
		public String name { get; private set; }

		/**
		 * @description Label of the Record Type
		 */
		public String  label { get; private set; }

		/**
		 * @description RTInfo constructor
		 * @param info RecordTypeInfo pulling data from
		 */
		public RTInfo(RecordTypeInfo info) {
			this.id = info.getRecordTypeId();
			this.name = info.getDeveloperName();
			this.label = info.getName();
		}
	}

	/**
	 * @description readData reads all the Record Type data into the static variable
	 * if it has not been done before.
	 * @param nameSObject Name of the SObject (lowercased)
	 */
	private static void readData(String nameSObject) {
		nameSobject = nameSobject.toLowerCase();

		if (!recordTypes.keySet().contains(nameSObject)) {
			recordTypes.put(nameSObject, new List<RTInfo>());

			if (Schema.getGlobalDescribe().containsKey(nameSObject)) {
				Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(nameSObject).getDescribe();

				List<Schema.RecordTypeInfo> recordTypeInfos = sobjectResult.getRecordTypeInfos();
				for (RecordTypeInfo info : recordTypeInfos) {
					recordTypes.get(nameSObject).add(new RTInfo(info));
				}
			}
		}
	}

	/**
	 * @description findByName retrieves the RTInfo given the SObject name and
	 * Record Type name looking for.
	 * NOTE: It is assumed there will not be duplicate names or developer names
	 * on a single object.
	 * @param  nameSobject Name of the SObject
	 * @param  nameRT      Name or Developer Name of the record Type
	 * @return The RTInfo or null if not found
	 */
	private static RTInfo findByName(String nameSobject, String nameRT) {
		nameSobject = nameSobject.toLowerCase();

		if (recordTypes.containsKey(nameSobject)) {
			for (RTInfo rti : recordTypes.get(nameSobject)) {
				if (nameRT == rti.name || nameRT == rti.label) {
					return rti;
				}
			}
		}
		return null;
	}

	/**
	 * @description getId retrieves the Record Type identifer given the SObject Name and
	 * either the Record Type name or Record Type developer name.
	 * NOTE: It is assumed there will not be duplicate names or developer names
	 * on a single object.
	 * @param  nameSobject Name of the SObject
	 * @param  nameRT      Name or Developer Name of the record Type
	 * @return The identifier or null if not found
	 */
	public static Id getId(String nameSobject, String nameRT) {
		readData(nameSobject);

		RTInfo rti = findByName(nameSobject, nameRT);

		if (rti != null) {
			return rti.id;
		}

		return null;
	}

	/**
	 * @description getId retrieves the Record Type identifer given the SObject Name and
	 * either the Record Type name or Record Type developer name.
	 * NOTE: It is assumed there will not be duplicate names or developer names
	 * on a single object.
	 * @param  nameSobject Name of the SObject
	 * @param  nameRTs     Names or Developer Name of the record Type
	 * @return List of identifiers or empty if not found
	 */
	public static Map<String, Id> getIds(String nameSobject, List<String> nameRTs) {
        Map<String, Id> result = new Map<String, Id>();

		readData(nameSobject);

		for (String name : nameRTs) {
			RTInfo rti = findByName(nameSobject, name);

			if (rti == null) {
				System.debug(LoggingLevel.WARN, 'No ' + nameSObject + ' RecordType of ' + name);
			} else {
				result.put(name, rti.id);
			}
		}

		return result;
	}

	/**
	 * @description getId retrieve a RecordType identifier from a single coded String.
	 * @param  type String with SObject.RecordTypeName
	 * @return The identifier or null if not found
	 */
	public static Id getId(String type) {
		List<String> params = type.split('\\.');
		return getId(params[0], params[1]);
	}

	/**
	 * @description getLabel finds the label for the given Record Type Identifier and
	 * object name.
	 * @param  idrtCheck   Id to check
	 * @param  nameSobject Name of the SObject
	 */
	public static String getLabel(Id idrtCheck, String nameSobject) {
		nameSobject = nameSobject.toLowerCase();
		
		readData(nameSobject);

		if (recordTypes.containsKey(nameSobject)) {
			List<RTInfo> rtInfos = recordTypes.get(nameSobject);

			for (RTInfo info : rtInfos) {
				if (info.Id == idrtCheck) {
					return info.label;
				}
			}
		}

		return null;
	}

	/**
	 * @description isType determines if the given Id is of the RecordType determined from
	 * the other data.
	 * on a single object.
	 * @param  idrtCheck   Id to check
	 * @param  nameSobject Name of the SObject
	 * @param  nameRT      Name or Developer Name of the record Type
	 * @return true if same
	 */
	public static Boolean isType(Id idrtCheck, String nameSobject, String nameRT) {
		return idrtCheck == getId(nameSobject, nameRT);
	}

	/**
	 * @description isType determines if the given Id is of the RecordType determined from
	 * the other data.
	 * on a single object.
	 * @param  idrtCheck   Id to check
	 * @param  type String with SObject.RecordTypeName
	 * @return true if same
	 */
	public static Boolean isType(Id idrtCheck, String type) {
		return idrtCheck == getId(type);
	}

	/**
	 * @description getRecordTypeIdsByName retrieves all the RecordType identifiers for an SObject.
	 * @param  nameSobject Name of the SObject
	 * @return Map relating the RecordType Name to its Id
	 */
	public static Map<String, Id> getRecordTypeIdsByName(String nameSobject) {
		nameSobject = nameSobject.toLowerCase();

		readData(nameSobject);

		Map<String, Id> results = new Map<String, Id>();

		if (recordTypes.containsKey(nameSobject)) {
			for (RTInfo rti : recordTypes.get(nameSobject)) {
				results.put(rti.label, rti.id);
			}
		}

		return results;
	}

	/**
	 * @description getRecordTypeIdsByDeveloperName retrieves all the RecordType identifiers for an SObject.
	 * @param  nameSobject Name of the SObject
	 * @return Map relating the RecordType Developer Name to its Id
	 */
	public static Map<String, Id> getRecordTypeIdsByDeveloperName(String nameSobject) {
		nameSobject = nameSobject.toLowerCase();

		readData(nameSObject);
		Map<String, Id> results = new Map<String, Id>();

		if (recordTypes.containsKey(nameSobject)) {
			for (RTInfo rti : recordTypes.get(nameSobject)) {
				results.put(rti.name, rti.id);
			}
		}

		return results;
	}

	/**
	 * @description getByRecordType runs through the given list of SObjects and returns those which match the
	 * Record Type.
	 * @param  listValues   List of SObjects to run through
	 * @param  nameSobject SObject name
	 * @param  nameRT      Record Type of the SObject to look for
	 * @return Only those in the given list which match the Record Type
	 */
	public static List<SObject> getByRecordType(List<SObject> listValues, String nameSobject, String nameRT) {
		return getByRecordType(listValues, getId(nameSobject, nameRT));
	}

	/**
	 * @description getByRecordType runs through the given list of SObjects and returns those which match the
	 * Record Type.
	 * @param  listValues   List of SObjects to run through
	 * @param  idRecordType Identifier of the Record Type looking for
	 * @return Only those in the given list which match the Record Type
	 */
	public static List<SObject> getByRecordType(List<SObject> listValues, Id idRecordType) {
		if (idRecordType == null) {
			throw new InvalidParameterValueException('RecordTypeService.getByRecordType()', 'Expecting a Record Type Id, not null');
		}

		List<SObject> result = new List<SObject>();

		for (SObject o : listValues) {
			if (o.get('RecordTypeId') == idRecordType) {
				result.add(o);
			}
		}

		return result;
	}

	/**
	 * @description getByRecordTypes runs through the given list of SObjects and returns those which match the
	 * Record Type.
	 * @param  listValues   List of SObjects to run through
	 * @param  nameSobject  SObject name
	 * @param  nameRTs      Identifiers of the Record Types looking for
	 * @return Only those in the given list which match the Record Type
	 */
	public static List<SObject> getByRecordTypes(List<SObject> listValues, String nameSobject, List<String> nameRTs) {
		List<Id> idRTs = new List<Id>();

		for (String name : nameRTs) {
			Id id = getId(nameSobject, name);

			if (id != null) {
				idRts.add(id);
			}
		}

		return getByRecordTypes(listValues, idRTs);
	}

	/**
	 * @description getByRecordTypes runs through the given list of SObjects and returns those which match the
	 * Record Type.
	 * @param  listValues    List of SObjects to run through
	 * @param  idRecordTypes Identifiers of the Record Types looking for
	 * @return Only those in the given list which match the Record Type
	 */
	public static List<SObject> getByRecordTypes(List<SObject> listValues, List<Id> idRecordTypes) {
		List<SObject> result = new List<SObject>();

		for (SObject o : listValues) {
			Id id = (Id) o.get('RecordTypeId');

			if (idRecordTypes.contains(Id)) {
				result.add(o);
			}
		}

		return result;
	}

	/**
	 * @description sortByRecordType sorts the objects by RecordType Label.
	 * @param  nameSobject  Name of the SObjects the List holds
	 * @param  listValues   List of SObjects to run through
	 * @return Map<String, SObject>
	 */
	public static Map<String, List<SObject>> sortByRecordType(String nameSobject, List<SObject> listValues) {
		Map<String, List<SObject>> result = new Map<String, List<SObject>>();

		String name = nameSobject.toLowerCase();

		readData(name);

		List<RTInfo> infos = recordTypes.get(name);

		for (RTInfo info : infos) {
			result.put(info.label, new List<SObject>());
		}

		Id idRT;

		for (SObject o : listValues) {
			idRT = (Id) o.get('RecordTypeId');

			for (RTInfo info : infos) {
				if (info.id == idRT) {
					result.get(info.label).add(o);
					break;
				}
			}
		}

		return result;
	}		
}