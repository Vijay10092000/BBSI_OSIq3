public with sharing class RenewalsDateRange {

	public Datetime StartDate {get;set;}
	public Datetime EndDate {get;set;}

	public RenewalsDateRange(Datetime dateStart, Datetime dateEnd) {
		StartDate = dateStart;
		EndDate = dateEnd;
	}

}