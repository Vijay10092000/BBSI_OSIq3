/**
 * @description BenefitsPlansSelection_Controller reads and writes the selected Benefits Plans
 * for an Opporutnity or Benefits record.
 */
public without sharing class BenefitsPlansSelection_Controller {

    /**
     * @description InitData holds the initialization data for the Benefits Plan Selection
     * controller.
     */
    public without sharing class InitData {

		/**
		 * @description typeRecord
		 */
		@AuraEnabled
		public String title { get; private set; }

		/**
		 * @description typeRecord
		 */
		@AuraEnabled
		public String typeRecord { get; private set; }

		/**
		 * @description nameRecord
		 */
		@AuraEnabled
		public String nameRecord { get; private set; }

		/**
		 * @description idRecord
		 */
		@AuraEnabled
		public String idRecord { get; private set; }

		/**
		 * @description optionsAll contains all Benefits Plans
		 */
		@AuraEnabled
		public List<Option> optionsAll { get; private set; }

		/**
		 * @description optionsSelected contains Benefits Plans for the record
		 */
		@AuraEnabled
		public List<String> optionsSelected { get; private set; }

		/**
		 * @description optionsRequired contains required Benefits Plans
		 */
		@AuraEnabled
		public List<String> optionsRequired { get; private set; }
    }

	/**
	 * @description setup retrieves information to initializes the BenefitsPlanSelection component.
	 * @param  idRecord  Record Id working on (Opporutnity or Benefits__c)
	 * @return Data to initialize the component
	 */
    @AuraEnabled
    public static InitData setup(Id idRecord) {
        InitData data = new InitData();
        data.optionsAll = new List<Option>();
        data.optionsSelected = new List<String>();
        data.optionsRequired = new List<String>();

        Map<Id, Benefits_Plan__c> mapPlans = new Map<Id, Benefits_Plan__c>([
            SELECT Id, Name
            FROM Benefits_Plan__c
            ORDER BY Name
        ]);

        for (Benefits_Plan__c plan : mapPlans.values()) {
            data.optionsAll.add(new Option(plan.Id, plan.Name, false));
        }

        if (idRecord != null) {
            String type = Sobject_Services.getType(idRecord);

            if (type == 'Opportunity') {
                Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id = :idRecord];

                data.idRecord = idRecord;
                data.nameRecord = opp.Name;
                data.typeRecord = 'Opportunity';
                data.title = 'Add Benefits Plans for Opportunity';

                for (Benefits_Plan_Opp_Junction__c junction :[
                    SELECT Id, Opportunity__c, Benefits_Plan__c, Benefits_Plan__r.Name
                    FROM Benefits_Plan_Opp_Junction__c
                    WHERE Opportunity__c = :idRecord
                ]) {
                    data.optionsSelected.add(junction.Benefits_Plan__c);
                }
            }
            else if (type == 'Benefits__c') {
                Benefits__c benefits = [SELECT Id, Name, Opportunity__c FROM Benefits__c WHERE Id = :idRecord];

                data.idRecord = idRecord;
                data.nameRecord = benefits.Name;
                data.typeRecord = 'Benefits';
                data.title = 'Add Benefits Plans for Benefits';

                for (Benefits_Plan_Benefits_Junction__c junction : [
                    SELECT Id, Benefits__c, Benefits_Plan__c, Benefits_Plan__r.Name
                    FROM Benefits_Plan_Benefits_Junction__c
                    WHERE Benefits__c = :idRecord
                ]) {
                    data.optionsSelected.add(junction.Benefits_Plan__c);
                }
            }
            else {
                System.debug(LoggingLevel.ERROR, 'Type, ' + type + ' , is not handled in BenefitsPlansSelection_Controller.setUp()');
                data.idRecord = idRecord;
                data.nameRecord = 'NONE';
                data.typeRecord = 'UNKNOWN';
            }
        }

        return data;
    }

	/**
	 * @description onSave handles the save of the BenefitsPlansSelection controller.
	 * @param  idRecord  Record Id working on (Opporutnity or Benefits__c)
	 * @param  idPlans   Selected Plans from the controller.
	 */
    @AuraEnabled
    public static void onSave(Id idRecord, List<String> idPlans) {
        String type = Sobject_Services.getType(idRecord);

        if (type == 'Opportunity') {
            saveOpportunityPlans(idRecord, (List<Id>) idPlans);
        }
        else if (type == 'Benefits__c') {
            saveBenefitsPlans(idRecord, (List<Id>) idPlans);
        }
		else {
			System.debug(LoggingLevel.ERROR, 'BenefitsPlansSelection_Controller.onSave() does not handle type: ' + type);
		}
    }

	@TestVisible
    private static void saveOpportunityPlans(Id idRecord, List<Id> idPlans) {
        List<Benefits_Plan_Opp_Junction__c> junctions = [
            SELECT Id, Opportunity__c, Benefits_Plan__c, Benefits_Plan__r.Name
            FROM Benefits_Plan_Opp_Junction__c
            WHERE Opportunity__c = :idRecord
        ];

		handleOppDeletes(idPlans, junctions);
		handleOppInserts(idRecord, idPlans, junctions);
	}

	@TestVisible
	private static void handleOppDeletes(List<Id> idPlans, List<Benefits_Plan_Opp_Junction__c> junctions) {
		List<Benefits_Plan_Opp_Junction__c> deletes = new List<Benefits_Plan_Opp_Junction__c>();

        for (Benefits_Plan_Opp_Junction__c junction : junctions) {
            Boolean found = false;

            for (Id id : idPlans) {
                if (id == junction.Benefits_Plan__c) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                deletes.add(junction);
            }
        }

        if (!deletes.isEmpty()) {
            delete deletes;
        }
	}

	@TestVisible
	private static void handleOppInserts(Id idRecord, List<Id> idPlans, List<Benefits_Plan_Opp_Junction__c> junctions) {
        List<Benefits_Plan_Opp_Junction__c> inserts = new List<Benefits_Plan_Opp_Junction__c>();

        for (Id idPlan : idPlans) {
            Boolean found = false;

            for (Benefits_Plan_Opp_Junction__c junction : junctions) {
                if (idPlan == junction.Benefits_Plan__c) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                inserts.add(
                    new Benefits_Plan_Opp_Junction__c(
                        Opportunity__c = idRecord,
                        Benefits_Plan__c = idPlan
                    )
                );
            }
        }

        if (!inserts.isEmpty()) {
            insert inserts;
        }
    }

	@TestVisible
    private static void saveBenefitsPlans(Id idRecord, List<Id> idPlans) {
        List<Benefits_Plan_Benefits_Junction__c> junctions = [
            SELECT Id, Benefits__c, Benefits_Plan__c, Benefits_Plan__r.Name
            FROM Benefits_Plan_Benefits_Junction__c
            WHERE Benefits__c = :idRecord
        ];

		handleBenDeletes(idPlans, junctions);
		handleBenInserts(idRecord, idPlans, junctions);
	}

	@TestVisible
	private static void handleBenDeletes(List<Id> idPlans, List<Benefits_Plan_Benefits_Junction__c> junctions) {
		List<Benefits_Plan_Benefits_Junction__c> deletes = new List<Benefits_Plan_Benefits_Junction__c>();

        for (Benefits_Plan_Benefits_Junction__c junction : junctions) {
            Boolean found = false;

            for (Id idPlan : idPlans) {
                if (idPlan == junction.Benefits_Plan__c) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                deletes.add(junction);
            }
        }

        if (!deletes.isEmpty()) {
            delete deletes;
        }
	}

	@TestVisible
	private static void handleBenInserts(Id idRecord, List<Id> idPlans, List<Benefits_Plan_Benefits_Junction__c> junctions) {
        List<Benefits_Plan_Benefits_Junction__c> inserts = new List<Benefits_Plan_Benefits_Junction__c>();

        for (Id idPlan : idPlans) {
            Boolean found = false;

            for (Benefits_Plan_Benefits_Junction__c junction : junctions) {
                if (idPlan == junction.Benefits_Plan__c) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                inserts.add(
                    new Benefits_Plan_Benefits_Junction__c(
                        Benefits__c = idRecord,
                        Benefits_Plan__c = idPlan
                    )
                );
            }
        }

        if (!inserts.isEmpty()) {
            insert inserts;
        }
    }
}