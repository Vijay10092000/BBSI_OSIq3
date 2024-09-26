/**
 * @description WorkCompPolicyCodeRateDataModel
 */
public without sharing class WorkCompPolicyCodeRateDataModel {
    @TestVisible
    private static final String ERROR_NULL_RESPONSE = 'Error - Response is null';

    @TestVisible
    private static final String ERROR_FAILED_RESPONSE = '\n Error - getWorkCompPolicyCodeRate - ';

    @TestVisible
    private static final String ERROR_NO_DATA = '\nError - getWorkCompPolicyCodeRate - Data not found';

    private static final String FORMAT_MESSAGE = 'Status: {0} - Status Code: {1}';

    public WorkCompPolicyCodeRate wcPolicyCodeRate = new WorkCompPolicyCodeRate();
    public String statusMsg;
    public Integer statusCode;

    public Map<String, Map<String, List<String>>> wcPolicy = new Map<String, Map<String, List<String>>>();

    public Boolean GetData() {
		wcPolicyCodeRate = HttpCallout.callGetWorkCompPolicyCodeRate();

		if (wcPolicyCodeRate == null || wcPolicyCodeRate.DATALIST == null || wcPolicyCodeRate.DATALIST.size() == 0) {
			return false;
		}

		InitializeMap();

		return true;
    }

    public void InitializeMap() {
        for (WorkCompPolicyCodeRate.DATA item : wcPolicyCodeRate.DATALIST) {
            Map<String, List<String>> wcState = new Map<String, List<String>>();
            if (wcPolicy.containsKey(item.WcPolicy)) {
                wcState = wcPolicy.get(item.WcPolicy);
            }

            List<String> wcCodes = new List<String>();
            if (wcState.containsKey(item.State)) {
                wcCodes = wcState.get(item.State);
            }

            wcCodes.add(item.Code + '-' + item.Rate);
            wcState.put(item.State, wcCodes);
            wcPolicy.put(item.WcPolicy, wcState);
        }
    }
}