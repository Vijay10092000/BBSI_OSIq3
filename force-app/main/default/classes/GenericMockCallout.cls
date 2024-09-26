/**
 * @description GenericMockCallout is a generic implementation of HttpCalloutMock.
 * It should be used for all tests with need to mock a HTTPHttp callout.  This allows
 * response data to be in the test file next to what is being tested and allows
 * the response to be changed during a single test.  Exceptions may be thrown during
 * test as well.
 * In the class, the response or exception are not set at the same time.  GenericMockCallout
 * either throws and exception, returns the response or returns null if both have
 * not value.
 * 
 * If there is an Exception set, then the call to response() will throw it.  If not set,
 * the HttpResponse is returned.
 *
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_restful_http_testing_httpcalloutmock.htm
 */
@SuppressWarnings('PMD.TestClassMustEndWithTest')
@IsTest
public class GenericMockCallout implements HttpCalloutMock {
    // response is the HttpResponse which will be returned from respond()
    private HttpResponse response = null;

    // except is the Exception to be thrown
    private Exception except = null;

    /**
     * @description GenericMockCallout constructor to setup the mock response.
     * @param  code    Status code for response
     * @param  status  Status text for response
     * @param  body    Body text for response
     * @param  headers Response headers for response
     */
    public GenericMockCallout(Integer code, String status, String body, Map<String, String> headers) {
        setResponse(code, status, body, headers);
    }

    /**
     * @description GenericMockCallout constructor with response set to null.
     */
    public GenericMockCallout() {
    }

    /**
     * @description GenericMockCallout constructor to set the mock response.
     * @param  response The HttpResponse to return from mock call
     */
    public GenericMockCallout(HttpResponse response) {
        setResponse(response);
    }

    /**
     * @description GenericMockCallout constructor to set the mock response.
     * @param  except The Exception to throw from mock call
     */
    public GenericMockCallout(Exception except) {
        setException(except);
    }

    /**
     * @description setResponse sets the HttpResponse to return from mock call.
     * @param  code    Status code for response
     * @param  status  Status text for response
     * @param  body    Body text for response
     * @param  headers Response headers for response
     */
    public void setResponse(Integer code, String status, String body, Map<String, String> headers) {
        HttpResponse response = new HttpResponse();

        if (body == null) {
            body = '';
        }

        if (headers != null) {
            for (String key : headers.keySet()) {
                response.setHeader(key, headers.get(key));
            }
        }

        response.setBody(body);
        response.setStatusCode(code);
        response.setStatus(status);

        setResponse(response);
    }

    /**
     * @description setResponse sets the HttpResponse to return from mock call.
     * @param  response The HttpResponse to return from mock call
     */
    public void setResponse(HttpResponse response) {
        this.response = response;
        this.except = (Exception) null;
    }

    /**
     * @description setException sets the Exception to be thrown.
     * @param  except The Exception to throw from mock call
     */
    public void setException(Exception except) {
        this.response = null;
        this.except = except;
    }

    /**
     * @description respond throws an Exception if there is one, or returns
     * a HttpResponse.
     * @param  request The HttpRequest
     * @return The current HttpResponse
     */
    public HTTPResponse respond(HTTPRequest request) {
        if (except != (Exception) null) {
            throw except;
        }

        return response;
    }
}