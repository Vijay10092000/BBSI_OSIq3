/**
 * @description PlatformEvent holds the callout of Platform Events.
 */
public with sharing class PlatformEvent {
	/**
	 * @description fireLeadConversion sends the Lead Conversion event out for processing.
	 */
	public static void fireLeadConversion(Set<Id> idLeads) {		
		List<Lead_Conversion__e> events = new List<Lead_Conversion__e>();
		String LeadIds = 'CONVERTED LEAD IDS';

		for (Id idLead : idLeads) {
			leadIds += '\n  ' + idLead;

			events.add(
				new Lead_Conversion__e(
					LeadId__c = idLead
				)
			);
		}
		
		List<Database.SaveResult> listSaves = EventBus.publish(events);

		System.debug(Logginglevel.INFO,
			'1`1`1`1`1` - ' + listSaves);

		Log.writeIfError(
			Log.Severity.ERROR, 
			'Lead Conversion', 
			'LeadConvert.SendPlatformEventLeadConversion() Failed',
			leadIds,
			listSaves
		);
	}
}