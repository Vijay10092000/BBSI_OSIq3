/**
 * @description TaskBenefits handles trigger events for Benefits Tasks.
 *
 * When Benefits Tasks are completed, a new task is create (except for the last one).  The data handling the order,
 * who owns the Task and other informations is contained in the Custom Metadata Object: Benefits_Task_Definition__mdt.
 *
 * A Task should only be created once.  If a previous Task is reopened then closed a new Task should not be created.
 */
public with sharing class TaskBenefits {
	private static final Integer TASK_FOLLOWUP_DAYS = -90;

	// CreatedWhen => Benefits_Task_Definition__mdt
	@TestVisible
	private static Map<String, List<Benefits_Task_Definition__mdt>> taskDefs = null;
	// DeveloperName => Benefits_Task_Definition__mdt
	@TestVisible
	private static Map<Integer, Benefits_Task_Definition__mdt> taskDefsByOrder = null;
	@TestVisible
	private static List<OpportunityStage> stages;

	@TestVisible
	private static Id idQueueBenefits = null;
	@TestVisible
	private static Id idQueueBenefitsCoordinator = null;
	@TestVisible
	private static Id idQueueBenefitsUnderwriting = null;
	@TestVisible
	private static Id idrtBenefitsTask = RecordTypeService.getId('Task', 'Benefits Task');

	public final static String CREATEEVENTONFIELDCHANGE = 'On Field Change'; // US-65534

	// OpportunityId => task.Category__c (Benefits_Task_Definition__mdt.DeveloperName) => Task
	private Map<Id, Map<String, Task>> oppExistingTasks;
	private Map<Id, Opportunity> mapOpportunities;

	private Set<Task> insertTasks = new Set<Task>();
	private Set<Opportunity> updateOpportunities = new Set<Opportunity>();

	static {
		loadBenefitsTaskDefinitions();

		for (Group g : [
			SELECT Id, Name
			FROM Group
			WHERE Type = 'Queue' AND Name IN ('Benefits', 'Benefits Coordinator', 'Benefits Underwriting')
			ORDER BY Name ASC
		]) {
			switch on g.Name {
				when 'Benefits' {
					idQueueBenefits = g.Id;
				}
				when 'Benefits Coordinator' {
					idQueueBenefitsCoordinator = g.Id;
				}
				when 'Benefits Underwriting' {
					idQueueBenefitsUnderwriting = g.Id;
				}
			}
		}
	}

	/**
	 * @description createOtherTasks create tasks which cannot be done from the Custom Metadata
	 * Benefits Task Definitions.
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  newOpps     Opportunities with changes
	 */
	public static void createOtherTasks(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps) {
		List<Task> tasks = new List<Task>();

		for (Opportunity opp : newOpps) {
			if (opp.StageName == 'Benefits Closed Lost') {
				if (mapOldOpps == null || mapOldOpps.get(opp.Id).StageName != 'Benefits Closed Lost') {
					if (opp.Closed_Reason__c == 'Timing - Client') {
						tasks.add(createBenefitsFollowUp(opp));
					}
				}
			}
		}

		insert tasks;
	}

	/**
	 * @description updateTasksByOpportunity creates Benefits Tasks based on a change to
	 * Opportunty StageName.  Opportunities must already have been seperated into changed Stages
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  mapStageToOpps  Map relating changed stages to List of Opportunities.
	 */
	public static void updateTasksByOpportunity(Map<Id, Opportunity> mapOldOpps, Map<String, List<Opportunity>> mapStageToOpps) {
		TaskBenefits taskBenefits = new TaskBenefits();

		for (String name : mapStageToOpps.keySet()) {
			taskBenefits.addOpportunities(name, mapOldOpps, mapStageToOpps.get(name));
		}

		taskBenefits.finish();
	}

	/**
	 * @description handleBenefitsTasks handles newly closed Benefits Tasks and
	 * sets up the next Task(s) if needed.
	 * @param  oldTasks  Map of Tasks before changes
	 * @param  newTasks  List of Tasks with changes
	 */
	public static void handleBenefitsTasks(Map<Id, Task> oldTasks, List<Task> newTasks) {
		List<Task> benefitsTasks = RecordTypeService.getByRecordType(newTasks, idrtBenefitsTask);
		List<Task> closedTasks = Task_Service.justCompletedTasks(oldTasks, benefitsTasks);

		if (!closedTasks.isEmpty()) {
			TaskBenefits taskBenefits = new TaskBenefits();

			Map<Id, Opportunity> mapOpps = taskBenefits.getOpportunities(closedTasks);

			for (Task task : closedTasks) {
				if (mapOpps.containsKey(task.WhatId)) {

					taskBenefits.addOpportunities(task.Category__c, new List<Opportunity>{ mapOpps.get(task.WhatId) });
				}
			}

			taskBenefits.finish();
		}
	}

	/**
	 * @description getOpportunities retrieves the Opportunites from the WhatIds on the Tasks.
	 * @param  tasks  Tasks looking at
	 * @return Map<Id, Opportunity>
	 */
	private Map<Id, Opportunity> getOpportunities(List<Task> tasks) {
		Set<Id> idOpps = new Set<Id>();

		for (Task task : tasks) {
			idOpps.add(task.WhatId);
		}

		return getOpportunities(idOpps);
	}

	/**
	 * @description loadBenefitsTaskDefinitions retrieves data about all the Benefits Tasks and
	 * places them into a map relating the Create When to the task definition.
	 */
	@SuppressWarnings('PMD.AvoidSystemDebugUsage')
	private static void loadBenefitsTaskDefinitions() {
		taskDefs = new Map<String, List<Benefits_Task_Definition__mdt>>();
		taskDefsByOrder = new Map<Integer, Benefits_Task_Definition__mdt>();
		//Updated SOQL for US-65534
		for (Benefits_Task_Definition__mdt defTask : [
			SELECT
				Assigned_To__c,
				Create_Event__c,
				Create_When__c,
				Days_Offset__c,
				Description__c,
				DeveloperName,
				MasterLabel,
				Offset_Field__c,
				Only_Business_Days__c,
				Order_New__c,
				Required__c,
				Set_Opportunity_Stage__c,
				Subject__c,
				Record_Type__c,
				Field_Name__c,
				Field_Value__c
			FROM Benefits_Task_Definition__mdt
			WHERE Active__c = TRUE
			ORDER BY Order_New__c
		]) {
			if (!taskDefs.containsKey(defTask.Create_When__c)) {
				taskDefs.put(defTask.Create_When__c, new List<Benefits_Task_Definition__mdt>());
			}

			taskDefs.get(defTask.Create_When__c).add(defTask);
			taskDefsByOrder.put(Integer.valueOf(defTask.Order_New__c), defTask);
		}
	}

	/**
	 * @description finish updates records based on work.
	 */
	private void finish() {
		if (!insertTasks.isEmpty()) {
			Database.DMLOptions dlo = new Database.DMLOptions();
			dlo.EmailHeader.triggerUserEmail = true;

			Database.insert(new List<Task>(insertTasks), dlo);
		}

		if (!updateOpportunities.isEmpty()) {
			update new List<Opportunity>(updateOpportunities);
		}
	}

	/**
	 * @description addOpportunities description
	 * @param  name name description
	 * @param  opps opps description
	*/
	private void addOpportunities(String name, List<Opportunity> opps) {
		addOpportunities(name, null, opps);
	}

	/**
	 * @description addOpportunities description
	 * @param  name name description
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  opps opps description
	*/
	private void addOpportunities(String name, Map<Id, Opportunity> mapOldOpps, List<Opportunity> opps) {
		List<Opportunity> benefitsOpps = OpportunityBenefits_Service.getBenefitsOpportunities(opps);
		List<Opportunity> benefitsRenewalOpps = OpportunityBenefits_Service.getBenefitsRenewalOpportunities(opps);
		List<Opportunity> allOpps = new List<Opportunity>();
		allOpps.addAll(benefitsOpps);
		allOpps.addAll(benefitsRenewalOpps);
		setOpportunityExistingTasks(allOpps);
		if (!benefitsOpps.isEmpty() || !benefitsRenewalOpps.isEmpty()){
			for (Benefits_Task_Definition__mdt taskDef : getTaskDefs(name)) {
				if(taskDef.Create_Event__c != CREATEEVENTONFIELDCHANGE){ // US-65534
					if((!benefitsOpps.isEmpty() && (String.IsEmpty(taskDef.Record_Type__c) || taskDef.Record_Type__c == Opportunity_Service.RECORDTYPE_BENEFITS))){
						doTaskDefs(taskDef, benefitsOpps);
						
					}
					if (!benefitsRenewalOpps.isEmpty() && (String.IsEmpty(taskDef.Record_Type__c) || taskDef.Record_Type__c == Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL)) {
						doTaskDefs(taskDef, benefitsRenewalOpps);
					}
				} 				
			}
		}
	}

	/**
	 * @description doTaskDefs description
	 * @param  taskDef taskDef description
	 * @param  opps    opps description
	 */
	private void doTaskDefs(Benefits_Task_Definition__mdt taskDef, List<Opportunity> opps) {
		Set<Id> idOpps = new Set<Id>();

		for (Opportunity o : opps) {
			idOpps.add(o.Id);
		}

		Map<Id, Opportunity> workOpps = getOpportunities(idOpps);

		for (Opportunity opp : workOpps.values()) {
			if (!String.isBlank(taskDef.Subject__c)) {
				if (canCreate(opp.Id, taskDef)) {
					Task task = Task_Service.createTask(
						'Task',
						null,
						opp.Id,
						determineOwner(taskDef.Assigned_To__c, opp),
						taskDef.Subject__c,
						taskDef.Description__c,
						calculateDueDate(
							taskDef.Offset_Field__c,
							Integer.valueOf(taskDef.Days_Offset__c),
							taskDef.Only_Business_Days__c,
							opp
						)
					);

					task.Category__c = taskDef.DeveloperName;
					task.RecordTypeId = idrtBenefitsTask;
					task.Benefits__c = true;

					insertTasks.add(task);
				}
			}

			if (taskDef.Set_Opportunity_Stage__c != null) {
				if (taskDef.Set_Opportunity_Stage__c != opp.StageName) {
					if (canChangeStage(opp, taskDef.Set_Opportunity_Stage__c, taskDef.Record_Type__c)) {
						opp.StageName = taskDef.Set_Opportunity_Stage__c;
						updateOpportunities.add(opp);
					}
				}
			}
		}
	}

	/**
	 * @description getTaskDefs retrieves the List of Benefits Task Definitions for the given definition name
	 * @param  name  Name of the Benefits Task Definition
	 * @return List<Benefits_Task_Definition__mdt>
	 */
	private List<Benefits_Task_Definition__mdt> getTaskDefs(String name) {
		if (taskDefs.containskey(name)) {
			return taskDefs.get(name);
		}

		return new List<Benefits_Task_Definition__mdt>();
	}

	/**
	 * @description determineOwner determines who should be the Task owner
	 * @param  assignTo  Who receives the Task
	 * @param  opp       Opportunity working with
	 * @return Id of the Owner
	 */
	@TestVisible
	private static Id determineOwner(String assignTo, Opportunity opp) {
		Id result = null;

		switch on assignTo {
			when 'Opportunity Creator' {
				result = opp.CreatedById;
			}
			when 'Benefits Consultant' {
				result = opp.Benefits_Consultant__c;
			}
			when 'Benefits Coordinator' {
				result = opp.Benefits_Coordinator__c;
			}
			when 'Benefits Representative' {
				result = opp.Account?.Benefits_Representative__c;
			}
			when 'Benefits Specialist' {
				result = opp.Benefits_Specialist__c;
			}
			when 'Benefits Underwriting' {
				result = idQueueBenefitsUnderwriting;
			}
			when 'Payroll Specialist' {
				result = opp.Account?.Payroll_Specialist__c;
			}
			when else {
				// 'Opportunity Owner' or default
				result = opp.OwnerId;
			}
		}

		if (result == null) {
			result = opp.OwnerId;
		}

		return result;
	}

	/**
	 * @description setOpportunityExistingTasks reads existing Tasks for the given Opportunity Ids.
	 * @param  opps  Opportunities looking at
	 */
	private void setOpportunityExistingTasks(List<Opportunity> opps) {
		Set<Id> idOpps = new Set<Id>();

		for (Opportunity opp : opps) {
			idOpps.add(opp.Id);
		}

		oppExistingTasks = new Map<Id, Map<String, Task>>();

		for (Task task : [SELECT Id, Status, WhatId, Category__c FROM Task WHERE WhatId IN :idOpps]) {
			if (!oppExistingTasks.containsKey(Task.WhatId)) {
				oppExistingTasks.put(Task.WhatId, new Map<String, Task>());
			}

			oppExistingTasks.get(Task.WhatId).put(task.Category__c, task);
		}
	}

	/**
	 * @description canCreate determines if the Task can be created.
	 * @param  idOpportunity  Opportunity identifier
	 * @param  taskDef        Which task looking for
	 * @return false if a Task already esists
	 */
	private Boolean canCreate(Id idOpportunity, Benefits_Task_Definition__mdt taskDef) {
		if (oppExistingTasks.containsKey(idOpportunity)) {

			return !oppExistingTasks.get(idOpportunity).containsKey(taskDef.DeveloperName);
		}

		return true;
	}

	/**
	 * @description isTaskCompleted determines if the Task aready exists for the Opportunity.
	 * @param  idOpportunity  Opportunity identifier
	 * @param  taskDef        Which task looking for
	 * @return true if a exists Task already
	 */
	private Boolean isTaskCompleted(Id idOpportunity, Benefits_Task_Definition__mdt taskDef) {
		if (oppExistingTasks.containsKey(idOpportunity)) {
			Task task = oppExistingTasks?.get(idOpportunity)?.get(taskDef.DeveloperName);

			if (task != null) {
				return task.Status == 'Completed';
			}

			System.debug(LoggingLevel.DEBUG, 'Task not found for Opportunity ' + idOpportunity + ' of name ' + taskDef.DeveloperName);
		}

		return false;
	}

	/**
	 * @description calculateDueDate determines the due date of the Task being created.
	 * @param  offsetField       Opportunity field giving starting date
	 * @param  offset            Number of days from the offsetField
	 * @param  onlyBusinessDays  Only Monday - Friday or whole week?
	 * @param  opp               Opportunity related to Task
	 * @return Date Task is due
	 */
	@TestVisible
	private Date calculateDueDate(String offsetField, Integer offset, Boolean onlyBusinessDays, Opportunity opp) {
		Date today = Date.today();
		Date result;

		switch on offsetField {
			when 'Current Medical Renewal Month' {
				String month = opp.Current_Medical_Renewal_Month__c;

				if (month == null) {
					result = today.addDays(30);
				} else {
					result = Date.newInstance(today.year(), Date_Service.getMonthNumber(month), 1);
				}
			}
			when 'Enrollment Start Date' {
				result = opp.Enrollment_Start_Date__c;
			}
			when 'Enrollment End Date' {
				result = opp.Enrollment_End_Date__c;
			}
			when 'Final OE End Date' {
				result = opp.Final_OE_End_Date__c;
			}
			when else {
				// 'Task Create Date' and default
				result = today;
			}
		}

		if (onlyBusinessDays) {
			result = Date_Service.addWeekdays(result, offset);
		} else {
			result.addDays(offset);
		}

		if (result < today) {
			result = result.addYears(1);
		}

		return result;
	}

	/**
	 * @description createBenefitsFollowUp creates a Benefits Follow-up Task.
	 * @param  opp  Related Opportunity
	 * @return Task
	 */
     @TestVisible
	private static Task createBenefitsFollowUp(Opportunity opp) {
		Date today = Date.today();

		Date dueDate = today.addDays(90);

		if (opp.Current_Medical_Renewal_Month__c != null) {
			Integer month = Date_Service.getMonthNumber(opp.Current_Medical_Renewal_Month__c);

			dueDate = Date.newInstance(
				today.year(),
				month,
				1);

			dueDate = dueDate.addDays(TASK_FOLLOWUP_DAYS);

			while (dueDate < today) {
				dueDate = dueDate.addYears(1);
			}
		}

		Task task = Task_Service.createTask(
			'Task',
			null,
			opp.Id,
			determineOwner('Benefits Consultant', opp),
			'Benefit Follow Up',
			'',
			dueDate
		);

		task.RecordTypeId = idrtBenefitsTask;
		task.Benefits__c = true;

		return task;
	}

	private Boolean canChangeStage(Opportunity opp, String toStage, String taskRT) {
		if (toStage != null) {
			loadStages();

			List<Integer> sortOrder = new List<Integer>(taskDefsByOrder.keySet());
			sortOrder.sort();

			Boolean lastOrder = false;

			for (Integer order : sortOrder) {
				Benefits_Task_Definition__mdt def = taskDefsByOrder.get(order);
				if(def.Create_Event__c != CREATEEVENTONFIELDCHANGE){ // US-65534
					if (def.Required__c && (def.Record_Type__c == taskRT || String.isEmpty(def.Record_Type__c))) {
						if (!isTaskCompleted(opp.Id, def)) {
							return false;
						}
					}
	
					if (def.Set_Opportunity_Stage__c == toStage) {
						lastOrder = true;
					} else if (lastOrder) {
						return true;
					}
				}				
			}
		}
		return false;
	}

	/**
	 * @description loadStages reads all the Opportunity Stages.
	 */
	private static void loadStages() {
		if (stages == null) {
			stages = [
				SELECT SortOrder, Id, ApiName, DefaultProbability, IsClosed, IsWon, MasterLabel
				FROM OpportunityStage
				WHERE IsActive = TRUE
				ORDER BY SortOrder ASC
			];
		}
	}

	private Map<Id, Opportunity> getOpportunities(Set<Id> idOpps) {
		return new Map<Id, Opportunity>(
			[
				SELECT
					Id,
					Name,
					StageName,
					CreatedById,
					OwnerId,
					Benefits_Consultant__c,
					Benefits_Coordinator__c,
					Account.Benefits_Representative__c,
					Benefits_Specialist__c,
					Current_Medical_Renewal_Month__c,
					Enrollment_Start_Date__c,
					Enrollment_End_Date__c,
					Account.Payroll_Specialist__c,
                	RecordTypeId,
					Final_OE_End_Date__c
				FROM Opportunity
				WHERE Id IN :idOpps
			]
		);
	}	

	/** US-65534
	 * @description getOnFieldChangeTaskDefs retrieves the List of Benefits Task Definitions for the given Stagename
	 * @param  name Benefits Oppertunity StageName
	 * @return List<Benefits_Task_Definition__mdt>
	 */
	public static List<Benefits_Task_Definition__mdt> getOnFieldChangeTaskDefs(String name) {
		if (taskDefs.containskey(name)) {
			return taskDefs.get(name);
		}
		return new List<Benefits_Task_Definition__mdt>();
	}

	/** US-65534
     * @description Get a map of field names to their display types for the Opportunity object.
     * @param fieldMap Map of SObject fields
     * @return Map of field names to their display types
     */
    @TestVisible 
    public static Map<String, Schema.DisplayType> getFieldTypeMap(Map<String, Schema.SObjectField> fieldMap) {
        Map<String, Schema.DisplayType> fieldTypeMap = new Map<String, Schema.DisplayType>();
        
        for (String fieldName : fieldMap.keySet()) {
            fieldTypeMap.put(fieldName.toLowerCase(), fieldMap.get(fieldName).getDescribe().getType());
        }

        return fieldTypeMap;
    }

    /** US-65534
     * @description Process the task definitions and update Opportunity stage if conditions are met.
     * @param taskDefinitions List of task definitions
     * @param oldOpp Old Opportunity
     * @param newOpp New Opportunity
     * @param fieldTypeMap Map of field names to their display types
     * @param recordType Record type of the Opportunities
     */
    @TestVisible
    public static void opportunityStageAutomation(List<Benefits_Task_Definition__mdt> taskDefinitions, Opportunity oldOpp, Opportunity newOpp, Map<String, Schema.DisplayType> fieldTypeMap, String recordType) {
        for (Benefits_Task_Definition__mdt taskDef : taskDefinitions) {
            if (shouldProcessTaskDef(taskDef, recordType)) {
                List<String> fieldNames = taskDef.Field_Name__c.split(',');
                List<String> fieldValues = taskDef.Field_Value__c.split(',');

                if (fieldNames.size() == fieldValues.size()) {
                    Boolean isValid = validateFieldValues(fieldNames, fieldValues, oldOpp, newOpp, fieldTypeMap);
                    Boolean isFieldChanged = checkFieldChanges(fieldNames, oldOpp, newOpp);

                    if ((oldOpp == null || isFieldChanged) && isValid && String.isNotBlank(taskDef.Set_Opportunity_Stage__c)) {
                        newOpp.StageName = taskDef.Set_Opportunity_Stage__c;
						break;
                    }
                }
            }
        }
    }

    /** US-65534
     * @description Check if a task definition should be processed based on the record type.
     * @param taskDef Task definition
     * @param recordType Record type of the Opportunities
     * @return Boolean indicating if the task definition should be processed
     */
    @TestVisible
    public static Boolean shouldProcessTaskDef(Benefits_Task_Definition__mdt taskDef, String recordType) {
        return taskDef.Create_Event__c == TaskBenefits.CREATEEVENTONFIELDCHANGE 
            && String.isNotBlank(taskDef.Field_Name__c) 
            && (String.isEmpty(taskDef.Record_Type__c) || taskDef.Record_Type__c == recordType);
    }

    /** US-65534
     * @description Validate the field values of an Opportunity.
     * @param fieldNames List of field names
     * @param fieldValues List of field values
     * @param oldOpp Old Opportunity
     * @param newOpp New Opportunity
     * @param fieldTypeMap Map of field names to their display types
     * @return Boolean indicating if the field values are valid
     */
    @TestVisible
    public static Boolean validateFieldValues(List<String> fieldNames, List<String> fieldValues, Opportunity oldOpp, Opportunity newOpp, Map<String, Schema.DisplayType> fieldTypeMap) {
        for (Integer i = 0; i < fieldNames.size(); i++) {
            String fieldName = fieldNames[i].trim().toLowerCase();
            String fieldValue = fieldValues[i];
            Object newValue = newOpp.get(fieldName);

            if (!isFieldValueValid(fieldTypeMap.get(fieldName), fieldValue, newValue)) {
                return false;
            }
        }
        return true;
    }

	/** US-65534
     * @description Check if a field value is valid based on its display type and expected value.
     * @param fieldType Display type of the field
     * @param fieldValue Expected field value
     * @param newValue New field value
     * @return Boolean indicating if the field value is valid
     */
    @TestVisible
    private static Boolean isFieldValueValid(Schema.DisplayType fieldType, String fieldValue, Object newValue) {
		if (fieldValue == '__NOTBLANK') {
			if (fieldType == Schema.DisplayType.Date || fieldType == Schema.DisplayType.DateTime) {
				return newValue != null;
			} else if (fieldType == Schema.DisplayType.String) {
				return String.isNotBlank((String)newValue);
			} else if (fieldType == Schema.DisplayType.Integer) {
				return newValue != null && (Integer)newValue > 0;
			} else {
				return String.isNotBlank(String.valueOf(newValue));
			}
		} else {
			if (fieldType == Schema.DisplayType.Boolean) {
				return ((newValue == null && (fieldValue.toLowerCase() == 'false' || fieldValue == '')) || (String.valueOf(newValue) == fieldValue.toLowerCase()));
			} else if (fieldType == Schema.DisplayType.Date || fieldType == Schema.DisplayType.DateTime) {
				return ((newValue == null && fieldValue == '') || String.valueOf(newValue) == fieldValue);
			} else if (fieldType == Schema.DisplayType.String) {
				return ((newValue == null && fieldValue == '') || (String)newValue == fieldValue);
			} else if (fieldType == Schema.DisplayType.Integer) {
				return ((newValue == null && fieldValue == '0') || String.valueOf(newValue) == fieldValue);
			} else {
				return ((newValue == null && fieldValue == '') || String.valueOf(newValue) == fieldValue);
			}
		}        
    }
	
    /** US-65534
     * @description Check if any fields in the Opportunity have changed.
     * @param fieldNames List of field names
     * @param oldOpp Old Opportunity
     * @param newOpp New Opportunity
     * @return Boolean indicating if any fields have changed
     */
    @TestVisible
    public static Boolean checkFieldChanges(List<String> fieldNames, Opportunity oldOpp, Opportunity newOpp) {
        for (String fieldName : fieldNames) {
            fieldName = fieldName.trim().toLowerCase();
            Object newValue = newOpp.get(fieldName);
            Object oldValue = oldOpp != null ? oldOpp.get(fieldName) : null;

            if (oldOpp == null || !valuesEqual(newValue, oldValue)) {
                return true;
            }
        }
        return false;
    }

	/** US-65534
     * @description Check if two field values are equal.
     * @param newValue New field value
     * @param oldValue Old field value
     * @return Boolean indicating if the field values are equal
     */
    @TestVisible
    private static Boolean valuesEqual(Object newValue, Object oldValue) {
        return newValue == null ? oldValue == null : newValue.equals(oldValue);
    } 

	/** US-65534
     * @description taskCreationOnFieldChange generated tasks on filedchang.
     * @param mapOldOpps Old field value
     * @param newOpps New field value
     */
	public static void taskCreationOnFieldChange(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps) {
		TaskBenefits taskBenefits = new TaskBenefits();
		taskBenefits.setOpportunityExistingTasks(newOpps);
		List<Opportunity> benefitsOpps = OpportunityBenefits_Service.getBenefitsOpportunities(newOpps);
		List<Opportunity> benefitsRenewalOpps = OpportunityBenefits_Service.getBenefitsRenewalOpportunities(newOpps);
		Map<String, Schema.DisplayType> OpportunityFieldTypes = Opportunity_Service.getOpportunityFieldTypes('Opportunity');
		
		if(!benefitsOpps.isEmpty()) {
			taskBenefits.taskCreationOnFieldChange(mapOldOpps, benefitsOpps, OpportunityFieldTypes, Opportunity_Service.RECORDTYPE_BENEFITS);
		}
		if (!benefitsRenewalOpps.isEmpty()) {
			taskBenefits.taskCreationOnFieldChange(mapOldOpps, benefitsRenewalOpps, OpportunityFieldTypes, Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL);
		}
		taskBenefits.finish();		
	}

	/** US-65534
     * @description taskCreationOnFieldChange generated tasks on filedchang.
     * @param mapOldOpps Old field value
     * @param newOpps New field value
	 * @param taskDef taskDef description
	 * @param fieldTypeMap A map where the keys are field names (String) and the values are the field display types (Schema.DisplayType) for the Opportunity object.
     */
	public void taskCreationOnFieldChange(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps, Map<String, Schema.DisplayType> fieldTypeMap, String recordType) {
		for (Opportunity newOpp : newOpps) {
			Opportunity oldOpp = mapOldOpps != null ? mapOldOpps.get(newOpp.Id) : null;
			for(Benefits_Task_Definition__mdt taskDef: TaskBenefits.getOnFieldChangeTaskDefs(newOpp.StageName)){
				if(String.isNotBlank(taskDef.Subject__c) && shouldProcessTaskDef(taskDef, recordType)){
					taskCreationOnFieldChange(oldOpp, newOpp, fieldTypeMap, recordType, taskDef);
				}
			}       
        }			
	}   

	/** US-65534
     * @description taskCreationOnFieldChange generated tasks on filedchang.
     * @param oldOpp Old Opportunity
     * @param newOpp New Opportunity	 
     * @param recordType Opportunity RecordType 
	 * @param fieldTypeMap A map where the keys are field names (String) and the values are the field display types (Schema.DisplayType) for the Opportunity object.
	 * @param taskDef Benefits Task Definition configuration record
     */
	public void taskCreationOnFieldChange(Opportunity oldOpp, Opportunity newOpp, Map<String, Schema.DisplayType> fieldTypeMap, String recordType, Benefits_Task_Definition__mdt taskDef) {
		if (String.isNotBlank(taskDef.Field_Name__c) && String.isNotBlank(taskDef.Subject__c)) {
			List<String> fieldNames = taskDef.Field_Name__c.split(',');
			List<String> fieldValues = taskDef.Field_Value__c.split(',');

			if (fieldNames.size() == fieldValues.size()) {
				Boolean isValid = validateFieldValues(fieldNames, fieldValues, oldOpp, newOpp, fieldTypeMap);
				Boolean isFieldChanged = checkFieldChanges(fieldNames, oldOpp, newOpp);
				if (isValid && isFieldChanged) {						
					doTaskDefs(taskDef, new List<Opportunity>{newOpp});
				}
			}
		}
	}
}