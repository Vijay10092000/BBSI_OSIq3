/**
 * @description MassEmailHistoryListController
 */
public without sharing class MassEmailHistoryListController {
	/**
	 * @description ControllerData handles initialization data for the MassEmailList component.
	 */
	@SuppressWarnings('PMD.ApexDoc')
	public without sharing class ControllerData {
		@AuraEnabled
		public String id { get; private set; }

		@AuraEnabled
		public String name { get; private set; }

		@AuraEnabled
		public String linkObject { get; private set; }

		@AuraEnabled
		public String linkIcon { get; private set; }

		@AuraEnabled
		public String sentDate { get; private set; }

		@AuraEnabled
		public String sentBy { get; private set; }

		@AuraEnabled
		public String subject { get; private set; }

		@AuraEnabled
		public String label { get; private set; }

		@SuppressWarnings('PMD.ExcessiveParameterList')
		public ControllerData(String id, String name, String linkObject, String linkIcon, String sentDate, String sentBy, String subject) {
			this.id = id;
			this.name = name;
			this.linkObject = linkObject;
			this.linkIcon = linkIcon;
			this.sentDate = sentDate;
			this.sentBy = sentBy;
			this.subject = subject;

			this.label = name + ' - ' + subject;
		}
	}

	/**
	 * @description getRecords determines the data needed for the component.
	 * @param maximum      Maximum number of records to retrieve
	 * @return ControllerData containing requested data
	 */
	@AuraEnabled(cacheable=true)
	public static List<ControllerData> getRecords(Integer maximum) {
		List<ControllerData> result = new List<ControllerData>();

		try {
			List<Mass_Email_History__c> histories = [
				SELECT Id, Name, Owner.Name, Date_Sent__c, Email_Subject__c
				FROM Mass_Email_History__c
				ORDER BY Date_Sent__c DESC
				LIMIT :maximum
			];

			List<TabDefinition> linkIcon = [
				SELECT Url
				FROM TabDefinition
				WHERE IsCustom = true
				AND SobjectName = 'Mass_Email_History__c'
			];

			for (Mass_Email_History__c history : histories) {
				result.add(
					new ControllerData(
						history.Id,
						history.Name,
						'/lightning/r/Mass_Email_History__c/' + history.Id + '/view',
						linkIcon[0].Url,
						history.Date_Sent__c.format('MM/dd/yyyy'),
						history.Owner.Name,
						history.Email_Subject__c
					)
				);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'RecentListSingleController.setup Exception: ' + e);
			throw new AuraHandledException(e.getMessage());
		}

		return result;
	}
}