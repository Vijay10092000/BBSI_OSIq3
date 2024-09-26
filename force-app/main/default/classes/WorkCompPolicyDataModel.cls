public without sharing class WorkCompPolicyDataModel 
{
    public WorkCompPolicy WcPolicies;
    public String StatusMsg;
    public Integer StatusCode;

    public void GetData()
    {
        String apiUrl = '';
        String requestBody = '';
        StatusMsg = '';
        StatusCode = 0;

        HttpResponse httpRes;
        try
        {
            httpRes = HttpCallout.callBoomi(WorkCompPolicy.ApiUrl, WorkCompPolicy.RequestBody);

            if(httpRes == null) {
                CalloutException e = (CalloutException) CalloutException.class.newInstance();
                e.setMessage(httpRes.getStatus());
                throw e;
            }

            StatusCode = httpRes.getStatusCode();
            StatusMsg = httpRes.getStatus();
            String body = httpRes.getBody();

            if (StatusCode == 200) {
                WcPolicies = WorkCompPolicy.parse(body);
                if (WcPolicies == null || WcPolicies.DATALIST == null || WcPolicies.DATALIST.size() == 0){
                    StatusMsg = 'Error - Get Work Comp Policies - Data not found';
                    StatusCode = 0;
                    return;
                }
            }
        } 
        catch (Exception e) {
            System.debug('WorkCompPolicyDataModel GetData Exception: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
            StatusCode = 0;
        } 
        finally {
            if (StatusMsg.length() == 0 && httpRes != null){
                StatusMsg = 'Status: ' + httpRes.getStatus() + ' - Status Code: ' + httpRes.getStatusCode();
                StatusCode = 0;
            }
        }
    }
}