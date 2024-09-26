public with sharing class RenewalsRequestBody {
	
	public List<Integer> ClientIds{get; set;}
	public List<RenewalsDateRange> Dates{get; set;}

	private Integer numPeriods = 0;
	private Boolean hasLTD = false;
	private Boolean hasProjected = false;
	private Boolean isSimpleMode = false;

	public Integer ClientId {
		get {
			if (ClientIds != null && ClientIds.size() == 1){
				return ClientIds[0];
			}
			return 0;
		}
		set{
			ClientIds = new List<Integer>();
			ClientIds.add(value);
		}
	}

	public RenewalsRequestBody() {
		ClientIds = new List<Integer>();
		Dates = new List<RenewalsDateRange>();
	}
	// initialize with ONE Client Id

	public RenewalsRequestBody(Integer client, Date contractDate, Integer periods, Boolean ltd, Boolean projected){

		numPeriods = periods;
		hasLTD = ltd;
		hasProjected = projected;

		createBody(client, contractDate);
	} 
	public void QuickInit(Integer client, Date contractDate){

		numPeriods = 5;
		hasLTD = true;
		hasProjected = true;

		createBody(client, contractDate);
	} 
	public void SimpleInit(Integer client, Date contractDate, Integer periods, Boolean ltd, Boolean projected){

		numPeriods = periods;
		hasLTD = ltd;
		hasProjected = projected;
		isSimpleMode = true;

		createBody(client, contractDate);
	} 
	private void createBody(Integer client, Date contractDate){

		ClientId = client;
		Dates = new List<RenewalsDateRange>();
		Date minDate = Date.newInstance(2000, 1, 1);
		Integer daysToContractDate = Date.today().daysBetween(contractDate);
		// If contract Date is more than a year* old, then
		// we need to adjust it so we get any current data
		// *Using 365-90 days to catch clients that will be one
		//  year old now or sometime in the Renewals period
		if (isSimpleMode){
			// do nothing - don't modify contract date in simple mode
		}
		else if (daysToContractDate < (-365 + 90)) {
			Integer yearsToAdd = (Math.abs(daysToContractDate) + 90) / 365;
			contractDate = contractDate.addYears(yearsToAdd);
		}

		// Current Contract Year
		if(daysToContractDate < 1){
			Dates.add(new RenewalsDateRange(contractDate.addYears(-1).addDays(1), contractDate));

			// No projected data needed, so use bogus dates to keep the data structure complete
			if(hasProjected){
				Dates.add(new RenewalsDateRange(Date.today().addDays(1), Date.today().addDays(1)));
			}
		}else{
			Dates.add(new RenewalsDateRange(contractDate.addYears(-1).addDays(1), contractDate));
			// For projected data, use number of days from today to contract date
			if(hasProjected){
				Dates.add(new RenewalsDateRange(Date.today().addDays(-daysToContractDate), Date.today()));
			}
		}
		// LTD - lifetime to Date
		if(hasLTD){
			Dates.add(new RenewalsDateRange(minDate, contractDate));
		}

		// Years -1 and -2
		if(numPeriods > 1){
			Dates.add(new RenewalsDateRange(contractDate.addYears(-2).addDays(1), contractDate.addYears(-1)));
		}
		if(numPeriods > 2){
			Dates.add(new RenewalsDateRange(contractDate.addYears(-3).addDays(1), contractDate.addYears(-2)));
		}
		if(numPeriods > 3){
			Dates.add(new RenewalsDateRange(contractDate.addYears(-4).addDays(1), contractDate.addYears(-3)));
		}
		if(numPeriods > 4){
			Dates.add(new RenewalsDateRange(contractDate.addYears(-5).addDays(1), contractDate.addYears(-4)));
		}
	}

	public String GetJsonString () {

		String clientLabel = 'CLIENT';
		String dateLabel = 'DATES';
//		String dateFormat = 'yyyy-MM-dd';
		String listDelimiter = ',';
		String jsonStr;

		// CLIENTS SECTION
		if(ClientIds != null && ClientIds.size() > 0){
			jsonStr = '{\"' + clientLabel + '\": \"';
			for(Integer idstr : ClientIds){
				jsonStr += idstr + listDelimiter;
			}
			// replace last , with "
			jsonStr = jsonStr.substringBeforeLast(listDelimiter) + '\"';
		}

		// DATES SECTION
		if(Dates != null && Dates.size() > 0){
			jsonStr += ',\"' + dateLabel + '\": [';

			for(RenewalsDateRange range : Dates) {
				jsonStr += '{\"STARTDATE\": \"' + range.StartDate + '\", \"ENDDATE\": \"' + range.EndDate + '\"},';
			}

			// replace last , with ]}
			jsonStr = jsonStr.substringBeforeLast(listDelimiter) + ']}';
		}
//		System.debug('JSON Request: ' + jsonStr);

		return jsonStr;
	}
}