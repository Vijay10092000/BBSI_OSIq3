/**
 * @description ApexInformationController_Test contains tests for the class ApexInformationController.
 */
@IsTest
public with sharing class ApexInformationController_Test {
    private static final String ID_CLASS_ONE = '01p00000000k15tAAA';
    private static final String ID_CLASS_1_TEST = '01p00000000R458AAC';
    private static final String ID_CLASS_TWO = '01p00000000k16yAAA';
    private static final String ID_TRIGGER_TEST = '01q00000000p4TtAAI';
    
    private static final String MOCK_COVERAGE_DATA =
        '{"size":3,"totalSize":3,"done":true,"queryLocator":null,"entityTypeName":"ApexCodeCoverageAggregate",' +
        ' "records":[' +
        '  {"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v51.0/tooling/sobjects/ApexCodeCoverageAggregate/7152J000000BkNXQA0"},"ApexClassOrTriggerId":"01p00000000k15tAAA","NumLinesCovered":25,"NumLinesUncovered":75},' +
        '  {"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v51.0/tooling/sobjects/ApexCodeCoverageAggregate/7152J000000BkNYQA0"},"ApexClassOrTriggerId":"01p00000000k16yAAA","NumLinesCovered":67,"NumLinesUncovered":33},' +
        '  {"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v51.0/tooling/sobjects/ApexCodeCoverageAggregate/7152J000000BkNZQA0"},"ApexClassOrTriggerId":"01q00000000p4TtAAI","NumLinesCovered":7,"NumLinesUncovered":3}' +
        ']}';

    @IsTest
    static void test_makePercent() {
        ApexInformationController controller = new ApexInformationController();
        Assert.areEqual(100, controller.makePercent(15, 15));
        Assert.areEqual(50, controller.makePercent(8, 16));
        Assert.areEqual(46, controller.makePercent(7, 15));
    }

    @IsTest
    static void test_loadClasses() {
        ApexInformationController controller = new ApexInformationController();
        controller.loadClasses();
        Assert.isTrue(0 < controller.listClasses.size());
    }

    @IsTest
    static void test_loadTriggers() {
        ApexInformationController controller = new ApexInformationController();
        controller.loadTriggers();
        Assert.isTrue(0 < controller.listTriggers.size());
    }

    @IsTest
    static void test_loadCoverages() {
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', MOCK_COVERAGE_DATA, null));
        ApexInformationController controller = new ApexInformationController();
        controller.loadCoverages();
       Assert.areEqual(3, controller.mapCoverages.keySet().size());
    }

    @IsTest
    static void test_processClasses() {
        ApexInformationController controller = new ApexInformationController();
        controller.listClasses = createTestClasses();
        controller.mapCoverages = createCoverages(); 
        controller.setTestClassIds = createTestClasId(); 
        List<ApexInformationController.FileInfo> fileInfos = controller.processClasses();
        Assert.isTrue(0 < fileInfos.size());
        Assert.areEqual(controller.listClasses.size(), fileInfos.size(), 'Create one FileInfo for a Class.');
    }

    @IsTest
    static void test_processTriggers() {
        ApexInformationController controller = new ApexInformationController();
        controller.listTriggers = createTestTriggers();
        List<ApexInformationController.FileInfo> fileInfos = controller.processTriggers();
        Assert.isTrue(0 < fileInfos.size());
        Assert.areEqual(controller.listTriggers.size(), fileInfos.size(), 'Create one FileInfo for a Trigger.');
    }

    @IsTest
    static void test_processFileData() {
        ApexInformationController controller = new ApexInformationController();
        controller.listClasses = createTestClasses();
        controller.listTriggers = createTestTriggers();
        controller.mapCoverages = createCoverages(); 
        controller.setTestClassIds = createTestClasId();
        controller.processFileData();
        Assert.areEqual(4, controller.listFileInfo.size());
        // listFileInfo is sorted by name: Class1, Class1TEST, ClassTWO, ContactTrigger
        Assert.areEqual(4, controller.listFileInfo.size());

        ApexInformationController.FileInfo fi;
        fi = controller.listFileInfo[0];
        Assert.areEqual(ID_CLASS_ONE, fi.id);
        Assert.areEqual('Class1', fi.name);
        Assert.areEqual('Class', fi.type);
        Assert.areEqual('51.0', fi.apiVersion);
        Assert.areEqual(23, fi.lengthWithoutComments);
        Assert.areEqual(30, fi.numberCoveredLines);
        Assert.areEqual(70, fi.numberUncoveredLines);
        Assert.areEqual(100, fi.numberLines);
        Assert.areEqual('30', fi.textPercentLineCoverage);

        fi = controller.listFileInfo[1];
        Assert.areEqual(ID_CLASS_1_TEST, fi.id);
        Assert.areEqual('Class1TEST', fi.name);
        Assert.areEqual('Test Class', fi.type);
        Assert.areEqual('48.0', fi.apiVersion);
        Assert.areEqual(33, fi.lengthWithoutComments);
        Assert.areEqual(0, fi.numberCoveredLines);
        Assert.areEqual(0, fi.numberUncoveredLines);
        Assert.areEqual(0, fi.numberLines);
        Assert.areEqual('N/A', fi.textPercentLineCoverage);

        fi = controller.listFileInfo[2];
        Assert.areEqual(ID_CLASS_TWO, fi.id);
        Assert.areEqual('ClassTWO', fi.name);
        Assert.areEqual('Class', fi.type);
        Assert.areEqual('47.0', fi.apiVersion);
        Assert.areEqual(25, fi.lengthWithoutComments);
        Assert.areEqual(64, fi.numberCoveredLines);
        Assert.areEqual(36, fi.numberUncoveredLines);
        Assert.areEqual(100, fi.numberLines);
        Assert.areEqual('64', fi.textPercentLineCoverage);

        fi = controller.listFileInfo[3];
        Assert.areEqual(ID_TRIGGER_TEST, fi.id);
        Assert.areEqual('TriggerTest', fi.name);
        Assert.areEqual('Trigger', fi.type);
        Assert.areEqual('51.0', fi.apiVersion);
        Assert.areEqual(52, fi.lengthWithoutComments);
        Assert.areEqual(1, fi.numberCoveredLines);
        Assert.areEqual(0, fi.numberUncoveredLines);
        Assert.areEqual(1, fi.numberLines);
        Assert.areEqual('100', fi.textPercentLineCoverage);
   }
    
    @IsTest
    static void test_createWrapper() {
        ApexInformationController controller = new ApexInformationController();

        controller.listClasses = createTestClasses();
        controller.listTriggers = createTestTriggers();
        controller.mapCoverages = createCoverages(); 
        controller.setTestClassIds = createTestClasId();
        controller.processFileData();

        ApexInformationController.ApexInformationWrapper wrapper = controller.createWrapper();
        Assert.areEqual(100, wrapper.totalCharactersUsed);
        Assert.areEqual('0', wrapper.textPercentCharactersUsed);
        Assert.areEqual(201, wrapper.totalLines);
        Assert.areEqual(95, wrapper.totalLinesCovered);
        Assert.areEqual('47', wrapper.textTotalPercentCoverage);
        Assert.areEqual(2, wrapper.totalClasses);
        Assert.areEqual(1, wrapper.totalTriggers);
        Assert.areEqual(4, wrapper.listAllFiles.size());
	}
    @IsTest
    static void test_getData() {
        ApexInformationController.ApexInformationWrapper wrapper = ApexInformationController.getData();
        Assert.isNotNull(wrapper.totalCharactersUsed);
        Assert.isNotNull(wrapper.textPercentCharactersUsed);
        Assert.isNotNull(wrapper.totalLines);
        Assert.isNotNull(wrapper.totalLinesCovered);
        Assert.isNotNull(wrapper.textTotalPercentCoverage);
        Assert.isNotNull(wrapper.totalClasses);
        Assert.isNotNull(wrapper.totalTriggers);
        Assert.isNotNull(wrapper.listAllFiles.size());
    }

    static List<ApexClass> createTestClasses() {
        ApexClass ClassTWO = new ApexClass(
            Id = ID_CLASS_TWO,
            Name = 'ClassTWO',
            ApiVersion = 47.0,
            Body = 'public class ClassTWO { }',
            LengthWithoutComments = 25,
            IsValid = true,
            Status = 'Active'
        );
        ApexClass Class1 = new ApexClass(
            Id = ID_CLASS_ONE,
            Name = 'Class1',
            ApiVersion = 51.0,
            Body = 'public class Class1 { }',
            LengthWithoutComments = 23,
            IsValid = true,
            Status = 'Active'
        );
        ApexClass Class1TEST = new ApexClass(
            Id = ID_CLASS_1_TEST,
            Name = 'Class1TEST',
            ApiVersion = 48.0,
            Body = '@IsTest public class Class1TEST { }',
            LengthWithoutComments = 33,
            IsValid = true,
            Status = 'Active'
        );

        return new List<ApexClass>{ ClassTWO, Class1, Class1TEST };
    }

    static Set<Id> createTestClasId() {
        return new Set<Id>{ ID_CLASS_1_TEST };
    }

    static List<ApexTrigger> createTestTriggers() {
        ApexTrigger contactTrigger = new ApexTrigger(
            Id = ID_TRIGGER_TEST,
            Name = 'TriggerTest',
            ApiVersion = 51.0,
            Body = 'trigger TriggerTest on Contact(after undelete) {}',
            LengthWithoutComments = 52,
            IsValid = true,
            Status = 'Active'
        );

        return new List<ApexTrigger>{ contactTrigger };
    }

    static Map<Id, ApexInformationController.Coverage> createCoverages() {
        ApexInformationController.Coverage coverageClassONE = new ApexInformationController.Coverage();
        coverageClassONE.apexClassorTriggerId = ID_CLASS_ONE;
        coverageClassONE.numLinesCovered = 30;
        coverageClassONE.numLinesUncovered = 70;

        ApexInformationController.Coverage coverageClassTWO = new ApexInformationController.Coverage();
        coverageClassTWO.apexClassorTriggerId = ID_CLASS_TWO;
        coverageClassTWO.numLinesCovered = 64;
        coverageClassTWO.numLinesUncovered = 36;

        ApexInformationController.Coverage coverageTriggerTest = new ApexInformationController.Coverage();
        coverageTriggerTest.apexClassorTriggerId = ID_TRIGGER_TEST;
        coverageTriggerTest.numLinesCovered = 1;
        coverageTriggerTest.numLinesUncovered = 0;

        return new Map<Id, ApexInformationController.Coverage>{ 
            ID_CLASS_ONE => coverageClassONE, 
            ID_CLASS_TWO => coverageClassTWO, 
            ID_TRIGGER_TEST => coverageTriggerTest
        };
    }
}