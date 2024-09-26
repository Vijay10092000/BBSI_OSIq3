/**
 * FieldSetMember2
 */
public without sharing class FieldSetMember2 {
	public FieldSetMember2(Schema.FieldSetMember f, String objectName, String recordType) {
		this.DBRequired = f.DBRequired;
		this.fieldPath = f.fieldPath;
		this.iconName = '';
		this.label = f.label;
		this.subtitle = '';
		this.required = f.required;
		this.type = '' + f.getType();
		this.dynamic = false;
		this.value = '';
		this.disabled = false;
		this.otherDependent = false;
		this.parentField = '';
		this.filter = '';
		this.inlineHelp = '';

		this.picklistLabelValues = new List<Map<String,String>>();
		this.dependentPicklistLabelValues = new Map<String,List<Map<String,String>>>();

		Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
		Schema.DescribeSObjectResult res = objType.getDescribe();
		Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(this.fieldPath).getDescribe();

		inlineHelp = fieldResult.getInlineHelpText();
		
		if (this.type == 'PICKLIST') {
			Id idRecordType = RecordTypeService.getId(objectName, recordType);

			if (fieldResult.isDependentPicklist()) {
				this.picklistValues = new List<String>();
				this.disabled = true;
				SObjectField controllingPicklist = fieldResult.getController();
				this.parentField = controllingPicklist.getDescribe().getName();
				this.dependentPicklistValues = Picklist_Service.getPicklistValuesByRecordType(objectName, idRecordType, this.fieldPath);
			}
			else {
				Map<String, List<String>> picklistValues = Picklist_Service.getPicklistValuesByRecordType(objectName, idRecordType, this.fieldPath);
				List<String> pickListValuesList = new List<String>();
				for (String key : picklistValues.keySet()) {
					pickListValuesList.add(key);
				}				
				this.picklistValues = pickListValuesList;
			}
		} else {
			this.picklistValues = new List<String>();
		}

		if (this.type == 'MULTIPICKLIST') {
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			List<Map<String,String>> pickListValuesList = new List<Map<String,String>>();

			for ( Schema.PicklistEntry pickListVal : ple) {
				if (pickListVal.isActive()) {
					Map<String,String> temp = new Map<String,String>();
					temp.put('label', pickListVal.getLabel());
					temp.put('value', pickListVal.getLabel());
					pickListValuesList.add(temp);
				}
			}
			this.multiPicklistValues = pickListValuesList;
		}
		else {
			this.multiPicklistValues = new List<Map<String, String>>();
		}

		if (this.type == 'PICKLIST' || this.type == 'MULTIPICKLIST') {
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			
			Map<String,List<Map<String,String>>> dependentPicklistLabelValuesMap = new Map<String,List<Map<String,String>>>();

			// Create a map to store picklist values and labels
			Map<String, String> picklistMap = new Map<String, String>();

			// Populate the map with picklist values and labels
			for(Schema.PicklistEntry entry : ple) {
				picklistMap.put(entry.getValue(), entry.getLabel());
			}

			if(this.picklistValues != null && !this.picklistValues.isEmpty()){
				List<Map<String,String>> picklistLabelValuesMap = new List<Map<String,String>>();
				for(String picklistValue : this.picklistValues){
					if(picklistMap.containsKey(picklistValue)){
						picklistLabelValuesMap.add(new Map<String,String>{'label' => picklistMap.get(picklistValue), 'value' => picklistValue});						
					}
				}	
				this.picklistLabelValues = picklistLabelValuesMap;
			}
			if(this.dependentPicklistValues != null && !this.dependentPicklistValues.isEmpty()){
				for(String key : this.dependentPicklistValues.keySet()){
					dependentPicklistLabelValuesMap.put(key, new List<Map<String,String>>());
					List<String> picklistValues = this.dependentPicklistValues.get(key);
					List<Map<String,String>> picklistLabelValuesMap = new List<Map<String,String>>();
					if(!picklistValues.isEmpty()){							
						for(String picklistValue : picklistValues){
							if(picklistMap.containsKey(picklistValue)){
								picklistLabelValuesMap.add(new Map<String,String>{'label' => picklistMap.get(picklistValue), 'value' => picklistValue});						
							}
						}	
					}
					dependentPicklistLabelValuesMap.put(key, picklistLabelValuesMap);
				}
				this.dependentPicklistLabelValues = dependentPicklistLabelValuesMap;
			}
		}

		if (this.type == 'REFERENCE') {
			Schema.DescribeFieldResult fr = objType
				.getDescribe()
				.fields
				.getMap()
				.get(f.fieldPath)
				.getDescribe();

			for (Schema.SObjectType reference : fr.getReferenceTo()) {
				this.referenceTo = reference.getDescribe().getName();

				if (this.referenceTo  == 'Account') {
					this.subtitle = 'RecordType.Name';
					this.iconName = 'standard:account';
				}
				else if (this.referenceTo  == 'Contact') {
					this.subtitle = 'Account.Name';
					this.iconName = 'standard:contact';
				}
			}
		}
		else {
			this.referenceTo = '';
		}
	}

	public FieldSetMember2(Boolean DBRequired) {
		this.DBRequired = DBRequired;
	}

	@AuraEnabled
	public Boolean DBRequired { get; set; }

	@AuraEnabled
	public String fieldPath { get; set; }

	@AuraEnabled
	public String iconName { get; set; }

	@AuraEnabled
	public String label { get; set; }

	@AuraEnabled
	public String subtitle { get; set; }

	@AuraEnabled
	public Boolean required { get; set; }

	@AuraEnabled
	public String type { get; set; }

	@AuraEnabled
	public Boolean dynamic { get; set; }

	@AuraEnabled
	public String value { get; set; }

	@AuraEnabled
	public Boolean disabled { get; set; }

	@AuraEnabled
	public Boolean otherDependent { get; set; }

	@AuraEnabled
	public String referenceTo { get; set; }

	@AuraEnabled
	public List<String> picklistValues { get; set; }

	@AuraEnabled
	public List<Map<String,String>> picklistLabelValues { get; set; }
	
	@AuraEnabled
	public Map<String,List<Map<String,String>>> dependentPicklistLabelValues { get; set; }
    
	@AuraEnabled
	public List<Map<String,String>> multiPicklistValues { get; set; }

	@AuraEnabled
	public Map<String,List<String>> dependentPicklistValues { get; set; }

	@AuraEnabled
	public String parentField { get; set; }

	@AuraEnabled
	public String filter { get; set; }

	@AuraEnabled
	public String inlineHelp { get; set; }
}