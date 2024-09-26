/**
 * @description
 */
@IsTest
public with sharing class WorkCompPolicyCodeRateDataModel_Test {
    private static final String MOCK_WORKCOMPPOLICYRATES =
            '{"DATALIST":[' +
            '  { "WcPolicy":"A1",' +
            '    "State":"NV",' +
            '    "Rate":3.33,' +
            '    "Code":"3333" },' +
            '  { "WcPolicy":"A1",' +
            '    "State":"CA",' +
            '    "Rate":9.33,' +
            '    "Code":"3333" },' +
            '  { "WcPolicy":"A3",' +
            '    "State":"CA",' +
            '    "Rate":9.33,' +
            '    "Code":"4444" },' +
            '  { "WcPolicy":"A3",' +
            '    "State":"CA",' +
            '    "Rate":9.77,' +
            '    "Code":"7777" },' +
            '  { "WcPolicy":"A4",' +
            '    "State":"MT",' +
            '    "Rate":4.44,' +
            '    "Code":"444" }' +
            ']}';
        private static final String MOCK_INVALID_DATA =
            '{ "WcPolicy":"Ba",' +
            '  "State":"NV",' +
            '  "Rate":3.33,' +
            '  "Code":"3333" }';
    private static final String MOCK_EMPTY = '{}';
    private static final String FAIL_MESSAGE = 'FAILED';

    @IsTest
    public static void test_GetData_Success() {
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', MOCK_WORKCOMPPOLICYRATES, null));

        WorkCompPolicyCodeRateDataModel model = new WorkCompPolicyCodeRateDataModel();

        Test.startTest();

        Assert.isTrue(model.GetData());

        Test.stopTest();

        Assert.areEqual(5, model.wcPolicyCodeRate.DATALIST.size());
    }

    @IsTest
    public static void test_GetData_FailureBadResponse() {
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(401, 'OK', MOCK_EMPTY, null));

        WorkCompPolicyCodeRateDataModel model = new WorkCompPolicyCodeRateDataModel();

        Test.startTest();

        Assert.isFalse(model.GetData());

        Test.stopTest();
	}

    @IsTest
    public static void test_GetData_Exception() {
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(new CalloutException(FAIL_MESSAGE)));

        WorkCompPolicyCodeRateDataModel model = new WorkCompPolicyCodeRateDataModel();

        Test.startTest();

        Assert.isFalse(model.GetData());

        Test.stopTest();
    }

    @IsTest
    public static void test_GetData_Failure_NoData() {
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', MOCK_INVALID_DATA, null));

        WorkCompPolicyCodeRateDataModel model = new WorkCompPolicyCodeRateDataModel();

        Test.startTest();

        Assert.isFalse(model.GetData());

        Test.stopTest();
    }

    @IsTest
    public static void test_WorkCompControllerGetData_Success() {
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', MOCK_WORKCOMPPOLICYRATES, null));

        Test.startTest();
        List<WorkCompPolicyCodeRate.DATA> model = WorkCompController.getWorkCompPolicyCodeRate();

        Test.stopTest();

        Assert.areEqual(5, model.size());
    }
}