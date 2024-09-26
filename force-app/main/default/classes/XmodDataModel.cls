public without sharing class XmodDataModel {
	// Data Model for *Published* Xmod Data (Intellicomp) - for California clients only
	public ExmodsICdata ExmodData;
	public String FEIN;
	public String StatusMsg { get; set; }
	public Integer StatusCode { get; set; }

	public XmodDataModel(String inFEIN) {
		this.FEIN = inFEIN;
	}

	/*
		When (root, intermediate and path) Cert is not valid
			{"Message": "Authorization has been denied for this request."}
		When Bureau number not found:
			{"FEIN": "ERROR"}
		When Intellicomp data not found:
			{"ExMods":[],"BureauReportUrl":null}
	*/
	public void GetData() {
		String apiUrl = '';
		String requestBody = '';
		StatusMsg = '';
		StatusCode = 0;

		HttpResponse httpRes;

		try {
			apiUrl = ExmodsICdata.ApiUrl + FEIN;
			httpRes = HttpCallout.callBoomi(apiUrl, requestBody);

			if(httpRes == null) {
				CalloutException e = (CalloutException)CalloutException.class.newInstance();
				e.setMessage(httpRes.getStatus());
				throw e;
			}

			StatusCode = httpRes.getStatusCode();
			StatusMsg = httpRes.getStatus();
			String body = httpRes.getBody();

			if (StatusCode == 200) {
				if (body == '') {
					setStatus(0, 'Error - Intellicomp Xmod History - API callout returns empty.');
					return;
				}

				if (body.contains('FEIN')) {
					setStatus(0, 'Error - Intellicomp Xmod History - FEIN or Bureau number not found.');
					return;
				}

				ExmodData = ExmodsICdata.parse(body);
				if (ExmodData == null || ExmodData.ExMods == null || ExmodData.ExMods.size() == 0){
					setStatus(0, 'Error - Intellicomp Xmod History - Xmod data not found');
					return;
				}
			} else if (body.contains('Auth')) {
				setStatus(0, 'Error - Intellicomp Xmod History - Status: ' + httpRes.getStatus() + ' - ' + httpRes.getBody());
				System.debug('Auth: ' + httpRes.getStatusCode() + ' - ' + StatusMsg);
				return;
			} else {
				setStatus(0, 'Error - Intellicomp Xmod History - Status: ' + httpRes.getStatus() + ' - ' + httpRes.getBody());
				System.debug(LoggingLevel.ERROR, 'Other Errors: ' + httpRes.getStatusCode() + ' - ' + StatusMsg);
				return;
			}
		} catch (Exception e) {
			System.debug('XmodDataModel GetData Exception: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
			setStatus(0, e.getMessage());
		} finally {
			if (StatusMsg.length() == 0 && httpRes != null) {
				setStatus(0, 'Status: ' + httpRes.getStatus() + ' - Status Code: ' + httpRes.getStatusCode());
			}
		}
	}

	private void setStatus(Integer code, String message) {
		StatusCode = code;
		StatusMsg = message;
	}
}