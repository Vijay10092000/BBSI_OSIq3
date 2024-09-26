/**
 * @description HttpCallout performs the REST callouts.  Failures are recorded into
 * the Log table.
 * All HTTP callouts should pass through this class.
 * @see https://medium.com/dyno-dev/calling-tooling-api-from-apex-1913933284da
 */
public without sharing class HttpCallout {
	// Default Timeout value (one second = 1000).  Currently set at 2 minutes.
	private static final Integer TIMEOUT_DEFAULT = 120000;

	// Most recent version of the UI API
	private static final String UI_API_VERSION = Organization_Service.ApiVersionFull;
	
	// Format for the callout back into Salesforce
	private static final String CALLOUT_SERVICES_DATA = 'callout:Picklist_Values/services/data/' + UI_API_VERSION;

	private static final String SERVICES_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/' + UI_API_VERSION;

	// Format for the PickList Values callout
	private static final String FORMAT_UI_API_PICKLISTS = '/ui-api/object-info/{0}/picklist-values/{1}';

	// Format for a query call into the Tooling API
	private static final String FORMAT_TOOLING_API_QUERY = '/tooling/query/?q={0}';

	// Endpoint for StrikeIron calls
	private static final String ENDPOINT_STRIKEIRON = 'https://ws.strikeiron.com/StrikeIron/NAAddressVerification6/NorthAmericanAddressVerificationService/NorthAmericanAddressVerification';

	// Data for the StrikeIron call
	private static final String FORMAT_STRIKEIRON_BODY =
		'LicenseInfo.RegisteredUser.UserID={0}' +
		'&LicenseInfo.RegisteredUser.Password={1}' +
		'&NorthAmericanAddressVerification.AddressLine1={2}' +
		'&NorthAmericanAddressVerification.AddressLine2={3}' +
		'&NorthAmericanAddressVerification.CityStateOrProvinceZIPOrPostalCode={4}' +
		'&NorthAmericanAddressVerification.Country={5}' +
		'&NorthAmericanAddressVerification.Firm={6}' +
		'&NorthAmericanAddressVerification.Urbanization={7}' +
		'&NorthAmericanAddressVerification.Casing={8}';

	// Format for a Boomi callout
	private static final String FORMAT_BOOMI_ENDPOINT = 'callout:{0}/ws/simple/{1}';

	// Format for when StatusCode is not 200
	private static final String FORMAT_FAILED_STATUS = '{0} {1}\n{2}';

	// boomiNamedCredential holds the Name Credential for Boomi
	private static String boomiNamedCredential = null;

	/**
	 * @description callBoomi makes a call to BOOMI.
	 * @param  command The call being made
	 * @param  body Data to POST, null for a GET
	 * @return The HTTP Response object
	 *
	 * ANONYMOUS APEX TEST CODE - Boomi
	 * This code should return a valid response
		HttpResponse response = HttpCallout.callBoomi('getWorkCompPolicies', '');
		String text = 'HttpResponse:';
		text += '\nResponse: ' + response);
		text += '\nResponse Status: ' + response.getStatus();
		text += '\nResponse Status Code: ' + response.getStatusCode();
		text += '\nBody: ' + response.getBody();
		System.debug(LoggingLevel.INFo, text);
	*/
	public static HttpResponse callBoomi(String command, String body) {
		if (command.startsWith('/')) {
			command.right(command.length() - 1);
		}

		String endpoint = String.format(FORMAT_BOOMI_ENDPOINT, new List<String>{ getBoomiNamedCredential(), command });

		return request(endpoint, body, TIMEOUT_DEFAULT);
	}

	/**
	 * @description retrieveAddressData retrieves information about the address.
	 * @param  street     Street description
	 * @param  city       City description
	 * @param  state      State description
	 * @param  postalCode PostalCode description
	 * @param  country    Country description
	 * @return Map containing information about the given address
	 *
	 * ANONYMOUS APEX TEST CODE - StrikeIron
	 * This code should return a set of valid values
		Map<String, String> data = HttpCallout.retrieveAddressData(
			'8100 NE Parkway Drive, Suite 200', 'Vancouver', 'WA', '98662', 'US'
		);

		if (data == null) {
			System.debug(LoggingLevel.ERROR, 'ERROR READING DATA');
		} else {
			String text = 'STRIKEIRON DATA';
			for (String key : data.keySet()) {
				text += '\n' + key + ': ' + data.get(key));
			}
			System.debug(LoggingLevel.INFO, text);
		}
	*/
	public static Map<String, String> retrieveAddressData(
		String street,
		String city,
		String state,
		String postalCode,
		String country
	) {
		String body = createBodyStrikeIron(street, city, state, postalCode, country);

		HttpRequest request = new HttpRequest();
		request.setEndpoint(ENDPOINT_STRIKEIRON);
		request.setTimeout(TIMEOUT_DEFAULT);
		request.setMethod('GET');
		request.setBody(body);

		HttpResponse response = request(request);

		if (response != null && response.getStatusCode() == 200) {
			return parseStrikeIronResponse(response.getBodyDocument());
		}

		return null;
	}

	/**
	 * @description queryToolingApi retrieves query data using Salesforce Tooling API.
	 * @param  query Query to send
	 * @return The HTTP Response object
	 */
	public static HttpResponse queryToolingApi(String query) {
		String service = String.format(FORMAT_TOOLING_API_QUERY, new List<String>{ encodeUTF8(query) });

		return callSalesforceServices(service);
	}

	/**
	 * @description picklistValuesUiApi retrieves picklist information for a record type of an object.
	 * @param  nameObject    Name of the object
	 * @param  idRecordType  RecordType Identifier
	 * @return The HTTP Response object
	 * ANONYMOUS APEX TEST CODE
	 * Retrieves picklist values for the Case's record type Branch Use
		HTTPResponse response = HttpCallout.picklistUiApi('Case', '01250000000HmUzAAK');
		System.debug(LoggingLevel.INFO, 'PICKLIST\n' + response.getBody());
	*/
	public static HttpResponse picklistValuesUiApi(String nameObject, Id idRecordType) {
		String endpoint = String.format(FORMAT_UI_API_PICKLISTS, new List<String>{ nameObject, idRecordType });

		return request(CALLOUT_SERVICES_DATA + endpoint, null, 60000);

		/** DOES NOT WORK - Call is blocked by Salesforce
		return callSalesforceServices(
			String.format(FORMAT_UI_API_PICKLISTS, new List<String>{ nameObject, idRecordType }
		);
		**/
	}

	/**
	 * @description callSalesforce calls back into Salesforce with the given endpoint.
	 * For calls back into Salesforce using the Session Id is easier than a Named Credential.
	 * @param  service  Service command calling
	 * @return The HTTP Response object
	 */
	@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
	public static HttpResponse callSalesforceServices(String service) {
		String endpoint = SERVICES_URL;

		if (!service.startsWith('/')) {
			endpoint += '/';
		}
		
		endpoint += service;

		System.debug(LoggingLevel.DEBUG, 'callSalesforceServices() Endpoint: ' + endpoint);      

		HttpRequest request = new HttpRequest();
		request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
		request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		request.setHeader('Content-Type', 'application/json');
		request.setMethod('GET');
		request.setTimeout(TIMEOUT_DEFAULT);
		request.setEndpoint(endpoint);

		return request(request);
	}

	/**
	 * @description request performs a call out and returns the response.
	 * @param  endpoint The call being made
	 * @param  body data to post
	 * @param  timeout time in milliseconds to wait before timeout occurs
	 * @return The HTTP Response object, or null on exception
	 */
	@TestVisible
	private static HttpResponse request(String endpoint, String body, Integer timeout) {
		return request(endpoint, body == null ? 'GET' : 'POST', body, timeout);
	}

	/**
	 * @description request performs a call out and returns the response.
	 * @param  endpoint The call being made
	 * @param  method HTTP method for call
	 * @param  body data to post
	 * @param  timeout time in milliseconds to wait before timeout occurs
	 * @return The HTTP Response object, or null on exception
	 */
	@TestVisible
	private static HttpResponse request(String endpoint, String method, String body, Integer timeout) {
		HttpRequest request = new HttpRequest();
		request.setHeader('Content-Type', 'application/json');
		request.setEndpoint(endpoint);
		request.setTimeout(timeout);
		request.setMethod(method);

		if (!String.isBlank(body)) {
			request.setBody(body);
		}

		return request(request);
	}

	/**
	 * @description request performs the call out and returns the response.
	 * All HTTP callouts should flow through this method.
	 * @param  request The HttpRequest
	 * @return The HTTP Response object, or null on exception
	 */
	@TestVisible
	public static HttpResponse request(HttpRequest request) {
		HttpResponse response = null;

		try {
			System.debug(LoggingLevel.FINER, 'HttpCallout Request: ' + request);
			response = (new Http()).send(request);
		} catch (Exception e) {
			writeErrorLog(e, request, response);
		}

		return response;
	}

	/**
	 * @description writeErrorLog writes log messsages to the Log and debug messaging.
	 * @param  e        An Exception
	 * @param  request  HttpRequest
	 * @param  response HttpResponse
	 */
	@SuppressWarnings('PMD.AvoidSystemDebugUsage')
	private static void writeErrorLog(Exception e, HttpRequest request, HttpResponse response) {
		String textRequest;
		String textResponse;
		String textException = '';

		if (request == null) {
			textRequest = 'Request is NULL';
		} else {
			textRequest = String.format(
				FORMAT_FAILED_STATUS,
				new List<String>{ request.getMethod(), request.getEndpoint(), request.getBody() }
			);
		}

		if (response == null) {
			textResponse = 'Response is NULL';
		} else {
			textResponse = String.format(
				FORMAT_FAILED_STATUS,
				new List<String>{ String.valueOf(response.getStatusCode()), response.getStatus(), response.getBody().substring(4096) }
			);
		}

		String message = 'HttpCallout\REQUEST:\n' + textRequest + 'RESPONSE:\n' + textResponse;

		if (e != null) {
			textException = '\n\nEXCEPTION: ' + e;
		}

		System.debug(LoggingLevel.ERROR, 'ERROR: HttpCallout Retreiving Data' + message + textException);
		Log.error('HttpCallout', 'ERROR HttpCallout Retreiving Data', message, e);
	}

	/**
	 * @description getBoomiNamedCredential retrieves the name of the Boomi Named Credential object
	 * for this Org  It uses the Organization object to determine if this is a Production or Sandbox
	 * organization.
	 * If a Sandbox, it looks up the preferred Boomi environment setting (Dev, QA, etc).
	 * @return   Boomi Named Credential for the current organization
	 */
	@TestVisible
	private static string getBoomiNamedCredential() {
		if (boomiNamedCredential == null) {
			boomiNamedCredential = 'DevBoomi';

			Organization org = [
				SELECT Id, isSandbox
				FROM Organization
				WHERE Id = :userInfo.getOrganizationId()
				LIMIT 1
			];

			if (org.isSandbox) {
				try {
					List<SandboxEnvironment__mdt> envSettings = [
						SELECT BoomiEnvironment__c
						FROM SandboxEnvironment__mdt
						WHERE MasterLabel = 'BoomiEnv'
					];

					if (envSettings.size() > 0) {
						boomiNamedCredential = envSettings[0].BoomiEnvironment__c;
					}
				} catch (Exception e) {
					System.debug(LoggingLevel.ERROR, 'SandboxEnvironment__mdt not found in this org.  ' + e);
				}
			} else {
				boomiNamedCredential = 'Production';
			}
		}

		return boomiNamedCredential;
	}

	/**
	 * @description createBodyStrikeIron creates the HttpRequest body for a StrikeIron call.
	 * @param  street     street description
	 * @param  city       city description
	 * @param  state      state description
	 * @param  postalCode postalCode description
	 * @param  country    country description
	 * @return String for the HttpRequest body.
	 */
	@TestVisible
	public static String createBodyStrikeIron(
		String street,
		String city,
		String state,
		String postalCode,
		String country
	) {
		String username = '';
		String password = '';

		Login__c login = Login__c.getValues('StrikeIron');
		if (login != null) {
			username = login.Username__c;
			password = login.Password__c;
		}

		String cityStateZipCode = city + ', ' + state + ' ' + postalCode;

		if (String.isBlank(country) || country.length() != 2) {
			country = 'US';
		}

		String body = String.format(
			FORMAT_STRIKEIRON_BODY,
			new List<String>{
				encodeUTF8(username),
				encodeUTF8(password),
				encodeUTF8(street),
				encodeUTF8(''),
				encodeUTF8(cityStateZipCode),
				encodeUTF8(country),
				encodeUTF8(''),
				encodeUTF8(''),
				encodeUTF8('PROPER')
			}
		);

		return body;
	}

	/**
	 * @description parseStrikeIronResponse pulls the data out of the response fro StrikeIron.
	 * @param  document XML DOM Document
	 * @return Map containing the address data, null if missing data.
	 */
	@TestVisible
	private static Map<String, String> parseStrikeIronResponse(Dom.Document document) {
		if (document != null) {
			Dom.XmlNode rootElement = document.getRootElement();

			if (rootElement != null) {
				return parseXmlStrikeIron(rootElement);
			}
		}

		return null;
	}

	/**
	 * @description parseXmlStrikeIron recursively pulls the data out of the given XML.
	 * @param  node XML node inspecting
	 * @return Map containing the address data
	 */
	@TestVisible
	private static Map<String, String> parseXmlStrikeIron(Dom.XMLNode node) {
		Map<String, String> addressMap = new Map<String, String>();

		if (node.getNodeType() == Dom.XMLNodeType.ELEMENT) {
			addressMap.put(node.getName().trim(), node.getText().trim());

			for (Dom.XMLNode child : node.getChildElements()) {
				addressMap.putAll(parseXmlStrikeIron(child));
			}
		}

		return addressMap;
	}

	/**
	 * @description encodeUTF8 encodes the given test to UTF-8.
	 * @param  text Text to encode
	 * @return Encoded text
	 */
	private static string encodeUTF8(String text) {
		return EncodingUtil.urlEncode(text, 'UTF-8');
	}
	
	
	public static WorkCompPolicyCodeRate callGetWorkCompPolicyCodeRate() {		
		try {
			HttpRequest request = new HttpRequest();

			request.setHeader('Content-Type', 'application/json');
			request.setMethod('GET');
			request.setTimeout(TIMEOUT_DEFAULT);
			request.setEndpoint(
				String.format(
					FORMAT_BOOMI_ENDPOINT, 
					new List<String>
					{ 
						getBoomiNamedCredential(),
						'getWorkCompPolicyCodeRate'
					}
				)
			);

			return (WorkCompPolicyCodeRate) System.JSON.deserialize(
				(new Http()).send(request).getBody().replace('\n',''), 
				WorkCompPolicyCodeRate.class
			);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e);
		}

		return null;
	}
}