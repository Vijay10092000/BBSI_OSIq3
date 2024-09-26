/**
 * @description XmodRecommendedWriter udpates and creates XmodRecommended records based
 * the incoming data.
 */
public without sharing class XmodRecommendedWriter {
	private List<XmodRecommended__c> records;
	Map<String, XmodRecommended__c> xmodMap;
	Map<String, List<WorkCompPolicyAccount__c>> wcMap;

	List<XmodRecommended__c> listUpsert;
	Map<String, XmodRecommended__c> mapCreated;

	private List<String> errorLog;

	/**
	 * @description perform make changes or new XmodRecommended__c records based on the given ones.
	 * @param  records  XmodRecommended__c records to update or create
	 * @param  xmodMap  Map of current
	 * @param  wcMap    Map of WorkCompPolicyAccount__c
	 * @return List<String> of failed records
	 */
	public static List<String> perform(
		List<XmodRecommended__c> records,
		Map<String, XmodRecommended__c> xmodMap,
		Map<String, List<WorkCompPolicyAccount__c>> wcMap
	) {
		XmodRecommendedWriter writer = new XmodRecommendedWriter(records, xmodMap, wcMap);

		writer.init();
		writer.updateRecords();
		writer.fixCreated();
		writer.write();

		return writer.errorLog;
	}

	/**
	 * @description XmodRecommendedWriter constructor
	 * @param  records  XmodRecommended__c records to update or create
	 * @param  xmodMap  Map of current
	 * @param  wcMap    Map of WorkCompPolicyAccount__c
	 */
	public XmodRecommendedWriter(
		List<XmodRecommended__c> records,
		Map<String, XmodRecommended__c> xmodMap,
		Map<String, List<WorkCompPolicyAccount__c>> wcMap
	) {
		this.records = records;
		this.xmodMap = xmodMap;
		this.wcMap = wcMap;
	}

	/**
	 * @description saveXmodRecommended description
	 */
	public void init() {
		errorLog = new List<String>();
		listUpsert = new List<XmodRecommended__c>();
		mapCreated = new Map<String, XmodRecommended__c>();
	}

	/**
	 * @description updateRecords update and create XmodRecommended records based on the current records.
	 */
	public void updateRecords() {
		for (XmodRecommended__c xr : records) {
			if (hasStateCode(xr)) {
				xr.Policy_Number__c = xr.Policy_Number__c.trim();

				if (String.isBlank(xr.Policy_Number__c)) {
					workNoPolicyNumber(xr);
				} else {
					workWithPolicyNumber(xr);
				}
			}
		}
	}

	/**
	 * @description write pushes changes to the database.
	 */
	private void write() {
		List<Database.UpsertResult> upsertResults = Database.upsert(listUpsert, true);
		List<Database.Error> errUpsertList = new List<Database.Error>();

		for (Database.UpsertResult sr : upsertResults) {
			if (!sr.isSuccess()) {
				errUpsertList.addAll(sr.getErrors());
			}
		}

		if (errUpsertList.size() > 0) {
			errorLog.add('Save Recommended XMOD Upsert failure: ' + errUpsertList);
		}
	}

	/**
	 * @description hasStateCode checks if the XmodRecommended__c has a State Code.
	 * @param  xr  XmodRecommended__c to check
	 * @return Boolean
	 */
	private Boolean hasStateCode(XmodRecommended__c xr) {
		if (String.isBlank(xr.State_Code__c)) {
			errorLog.add('Missing state code');
			return false;
		}

		return true;
	}

	/**
	 * @description workNoPolicyNumber handle record with no Policy Number.
	 * @param  xr  XmodRecommended__c
	 */
	private void workNoPolicyNumber(XmodRecommended__c xr) {
		if (String.isBlank(xr.Client_Info__c)) {
			errorLog.add('Missing PolicyNumber and CompanyNumber');
			return;
		}

		String key = xr.Client_Info__c + '-' + xr.State_Code__c;
		XmodRecommended__c xmod;

		if (xmodMap.containskey(key)) {
			xmod = xmodMap.get(key);
			xmod.Effective_Date__c = xr.Effective_Date__c;
			xmod.Notes__c = xr.Notes__c;
			xmod.Xmod__c = xr.Xmod__c;

			xmodMap.put(key, xmod);
			listUpsert.add(xmod);
		} else {
			XmodRecommended__c createXmod = new XmodRecommended__c(
				Client_Info__c = xr.Client_Info__c,
				State_Code__c = xr.State_Code__c,
				Effective_Date__c = xr.Effective_Date__c,
				Notes__c = xr.Notes__c,
				Xmod__c = xr.Xmod__c
			);

			xmodMap.put(key, xmod);
			mapCreated.put(xr.Client_Info__c, createXmod);
		}
	}

	/**
	 * @description workWithPolicyNumber handle record with a Policy Number.
	 * @param  xr  XmodRecommended__c
	 */
	private void workWithPolicyNumber(XmodRecommended__c xr) {
		if (!wcMap.containsKey(xr.Policy_Number__c)) {
			errorLog.add(xr.Policy_Number__c);
			return;
		}

		String key;
		XmodRecommended__c xmod;

		List<WorkCompPolicyAccount__c> workCompAccounts = wcMap.get(xr.Policy_Number__c);

		for (WorkCompPolicyAccount__c wca : workCompAccounts) {
			if (wca.Client__r.External_Id__c != null) {
				key = wca.Client__r.External_Id__c + '-' + xr.State_Code__c;
				if (xmodMap.containsKey(key)) {
					xmod = xmodMap.get(key);
				} else {
					xmod = new XmodRecommended__c(
						Client__c = wca.Client__c,
						Client_Info__c = (String.isBlank(xr.Client_Info__c)) ? null : wca.Client__r.External_Id__c,
						State_Code__c = xr.State_Code__c
					);
				}

				xmod.Work_Comp_Policy__c = wca.Work_Comp_Policy__c;
				xmod.Policy_Number__c = xr.Policy_Number__c;
				xmod.Effective_Date__c = xr.Effective_Date__c;
				xmod.Notes__c = xr.Notes__c;
				xmod.Xmod__c = xr.Xmod__c;

				xmodMap.put(key, xmod);
				listUpsert.add(xmod);
			}
		}
	}

	/**
	 * @description fixCreated adds the Account Id (Client__c) to the record.
	 */
	private void fixCreated() {
		if (!mapCreated.isEmpty()) {
			Map<String, Id> mapClients = new Map<String, Id>();

			for (Account client : [
				SELECT Id, Name, External_Id__c
				FROM Account
				WHERE External_Id__c IN :mapCreated.keySet()
			]) {
				mapClients.put(client.External_Id__c, client.Id);
			}

			for (XmodRecommended__c xr : mapCreated.values()) {
				if (mapClients.containsKey(xr.Client_Info__c)) {
					xr.Client__c = mapClients.get(xr.Client_Info__c);

					listUpsert.add(xr);
				}
			}
		}
	}
}