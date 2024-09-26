public with sharing class PricingTemplateWcCodes_Schedule implements Schedulable {
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new PricingTemplateWcCodes_Batch(), 100);
	}
}