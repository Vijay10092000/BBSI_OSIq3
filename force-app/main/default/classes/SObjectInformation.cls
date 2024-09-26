/**
 * @description SObjectInformation retrieves information about an SObject.
*/
public without sharing virtual class SObjectInformation {	
	public String nameObject;
	public Map<String, String> objectData = new Map<String, String>();
	public Map<String, Map<String, String>> fieldsData = new Map<String, Map<String, String>>();

	public static final String EMPTY_STRING = '';

	private static final String FORMAT_FIELDDEFINITION_QUERY =
		'SELECT' +
		' BusinessOwnerId,' +
		' BusinessStatus,' +
		' ControllingFieldDefinitionId,' +
		' DataType,' +
		' Description,' +
		' DeveloperName, ' +
		' DurableId,' +
		' EntityDefinition.QualifiedApiName,' +
		' EntityDefinitionId,' +
		' ExtraTypeInfo,' +
		' Id,' +
		' IsApiFilterable,' +
		' IsApiGroupable,' +
		' IsApiSortable,' +
		' IsCalculated,' +
		' IsCompound,' +
		' IsCompactLayoutable,' +
		' IsFieldHistoryTracked,' +
		' IsHighScaleNumber,' +
		' IsHtmlFormatted,' +
		' IsIndexed,' +
		' IsListFilterable,' +
		' IsListVisible,' +
		' IsNameField,' +
		' IsNillable,' +
		' IsSearchPrefilterable,' +
		' IsPolymorphicForeignKey,' +
		' IsWorkflowFilterable,' +
		' Label,' +
		' LastModifiedBy.Name,' +
		' LastModifiedById,' +
		' LastModifiedDate,' +
		' Length,' +
		' NamespacePrefix,' +
		' Precision,' +
		' QualifiedApiName,' +
		' RelationshipName,' +
		' Scale,' +
		' SecurityClassification' +
		' FROM FieldDefinition' +
		' WHERE EntityDefinition.QualifiedApiName =  \'\'{0}\'\'';	

		public static final String KEY_PREFIX = 'KEY PREFIX';
		public static final String IS_CUSTOM = 'IS CUSTOM';
		public static final String IS_CUSTOM_SETTING = 'IS CUSTOM SETTING';
		public static final String IS_FEED_ENABLED = 'IS FEED ENABLED';
		public static final String IS_MRU_ENABLED = 'IS MRU ENABLED';
		public static final String LABEL = 'LABEL';
		public static final String LABEL_PLURAL = 'LABEL PLURAL';
		public static final String LOCAL_NAME = 'LOCAL NAME';
		public static final String NAME = 'NAME';
		public static final String SOBJECT_DESCRIBE_OPTION = 'SOBJECT DESCRIBE OPTION';
		public static final String SOBJECT_TYPE = 'SOBJECT TYPE';
		
		public static final String BUSINESS_OWNER_ID = 'BUSINESS OWNER ID';  
		public static final String BUSINESS_STATUS = 'BUSINESS STATUS';  
		public static final String BYTE_LENGTH = 'BYTE LENGTH'; 
		public static final String CALCULATED_FORMULA = 'CALCULATED FORMULA'; 
		public static final String CONTROLLER = 'CONTROLLER';  
		public static final String CONTROLLING_FIELD_DEFINITION_ID = 'CONTROLLING FIELD DEFINITION ID'; 
		public static final String DATA_TYPE = 'DATA TYPE'; 
		public static final String DEFAULT_VALUE = 'DEFAULT VALUE';
		public static final String DEFAULT_VALUE_FORMULA = 'DEFAULT VALUE FORMULA'; 
		public static final String DESCRIPTION = 'DESCRIPTION'; 
		public static final String DIGITS = 'DIGITS'; 
		public static final String DURABLE_ID = 'DURABLE ID'; 
		public static final String ENTITY_DEFINITION_ID = 'ENTITY DEFINITION ID'; 
		public static final String EXTRA_TYPE_INFO = 'EXTRA TYPE INFO'; 
		public static final String INLINE_HELP_TEXT = 'INLINE HELP TEXT';
		public static final String IS_ACCESSIBLE = 'IS ACCESSIBLE'; 
		public static final String IS_AI_PREDICTION_FIELD = 'IS AI PREDICTION FIELD';  
		public static final String IS_API_SORTABLE = 'IS API SORTABLE'; 
		public static final String IS_AUTO_NUMBER = 'IS AUTO NUMBER'; 
		public static final String IS_CALCULATED = 'IS CALCULATED'; 
		public static final String IS_CASCADE_DELETE = 'IS CASCADE DELETE'; 
		public static final String IS_CASE_SENSITIVE = 'IS CASE SENSITIVE';
		public static final String IS_COMPACT_LAYOUTABLE = 'IS COMPACT LAYOUTABLE'; 
		public static final String IS_COMPOUND = 'IS COMPOUND';
		public static final String IS_CREATEABLE = 'IS CREATEABLE'; 
		public static final String IS_DEFAULTED_ON_CREATE = 'IS DEFAULTED ON CREATE'; 
		public static final String IS_DEPENDENT_PICKLIST = 'IS DEPENDENT PICKLIST'; 
		public static final String IS_DEPRECATED_AND_HIDDEN = 'IS DEPRECATED AND HIDDEN';
		public static final String IS_ENCRYPTED = 'IS ENCRYPTED'; 
		public static final String IS_EXTERNAL_ID = 'IS EXTERNAL ID'; 
		public static final String IS_FIELD_HISTORY_TRACKED = 'IS FIELD HISTORY TRACKED';  
		public static final String IS_FILTERABLE = 'IS FILTERABLE'; 
		public static final String IS_FORMULA_TREAT_NULL_NUMBER_AS_ZERO = 'IS FORMULA TREAT NULL NUMBER AS ZERO';
		public static final String IS_GROUPABLE = 'IS GROUPABLE'; 
		public static final String IS_HIGH_SCALE_NUMBER = 'IS HIGH SCALE NUMBER';  
		public static final String IS_HTML_FORMATTED = 'IS HTML FORMATTED';  
		public static final String IS_ID_LOOKUP = 'IS ID LOOKUP'; 
		public static final String IS_INDEXED = 'IS INDEXED'; 
		public static final String IS_LIST_FILTERABLE = 'IS LIST FILTERABLE'; 
		public static final String IS_LIST_VISIBLE = 'IS LIST VISIBLE'; 
		public static final String IS_NAME_FIELD = 'IS NAME FIELD'; 
		public static final String IS_NAME_POINTING = 'IS NAME POINTING'; 
		public static final String IS_NILLABLE = 'IS NILLABLE'; 
		public static final String IS_PERMISSIONABLE = 'IS PERMISSIONABLE'; 
		public static final String IS_POLYMORPHIC_FOREIGN_KEY = 'IS POLYMORPHIC FOREIGN KEY';
		public static final String IS_RESTRICTED_DELETE = 'IS RESTRICTED DELETE'; 
		public static final String IS_RESTRICTED_PICKLIST = 'IS RESTRICTED PICKLIST'; 
		public static final String IS_SEARCH_PREFILTERABLE = 'IS SEARCH PREFILTERABLE';  
		public static final String IS_SORTABLE = 'IS SORTABLE'; 
		public static final String IS_UNIQUE = 'IS UNIQUE';  
		public static final String IS_UPDATEABLE = 'IS UPDATEABLE';  
		public static final String IS_WORKFLOW_FILTERABLE = 'IS WORKFLOW FILTERABLE';  
		public static final String IS_WRITE_REQUIRES_MASTER_READ = 'IS WRITE REQUIRES MASTER READ'; 
		public static final String LAST_MODIFIED_BY = 'LAST MODIFIED BY';  
		public static final String LAST_MODIFIED_BY_ID = 'LAST MODIFIED BY ID';  
		public static final String LAST_MODIFIED_DATE = 'LAST MODIFIED DATE';  
		public static final String NAMESPACE_PREFIX = 'NAMESPACE PREFIX';
		public static final String PICKLIST_VALUES = 'PICKLIST VALUES';  
		public static final String PRECISION = 'PRECISION';
		public static final String QUALIFIED_API_NAME = 'QUALIFIED API NAME';  
		public static final String REFERENCE_TAR_FIELD = 'REFERENCE TAR FIELD';  
		public static final String REFERENCE_TO = 'REFERENCE TO';  
		public static final String RELATIONSHIP_NAME = 'RELATIONSHIP NAME';  
		public static final String RELATIONSHIP_ORDER = 'RELATIONSHIP ORDER';  
		public static final String SCALE = 'SCALE';
		public static final String SECURITY_CLASSIFICATION = 'SECURITY CLASSIFICATION';
		public static final String SOAP_TYPE = 'SOAP TYPE';  
		public static final String SOBJECT_FIELD = 'SOBJECT FIELD';

		public static final List<String> DEFAULT_OBJECT_DATA_ORDER = new List<String>{			
			IS_CUSTOM,
			IS_FEED_ENABLED,
			IS_MRU_ENABLED,
			KEY_PREFIX,
			LABEL,
			LABEL_PLURAL,
			LOCAL_NAME,
			SObjectInformation.NAME,
			SOBJECT_DESCRIBE_OPTION,
			SOBJECT_TYPE
		};

		public static final List<String> DEFAULT_FIELD_DATA_ORDER = new List<String>{
			BUSINESS_OWNER_ID,
			BUSINESS_STATUS,
			BYTE_LENGTH,
			CALCULATED_FORMULA,
			CONTROLLER ,
			CONTROLLING_FIELD_DEFINITION_ID,
			DATA_TYPE,
			DEFAULT_VALUE,
			DEFAULT_VALUE_FORMULA,
			DESCRIPTION,
			DIGITS,
			DURABLE_ID,
			ENTITY_DEFINITION_ID,
			EXTRA_TYPE_INFO,
			INLINE_HELP_TEXT,
			IS_ACCESSIBLE,
			IS_AI_PREDICTION_FIELD,
			IS_API_SORTABLE,
			IS_AUTO_NUMBER,
			IS_CALCULATED,
			IS_CASCADE_DELETE,
			IS_CASE_SENSITIVE,
			IS_COMPACT_LAYOUTABLE,
			IS_COMPOUND,
			IS_CREATEABLE,
			IS_DEFAULTED_ON_CREATE,
			IS_DEPENDENT_PICKLIST,
			IS_DEPRECATED_AND_HIDDEN,
			IS_ENCRYPTED,
			IS_EXTERNAL_ID,
			IS_FIELD_HISTORY_TRACKED,
			IS_FILTERABLE,
			IS_FORMULA_TREAT_NULL_NUMBER_AS_ZERO,
			IS_GROUPABLE,
			IS_HIGH_SCALE_NUMBER,
			IS_HTML_FORMATTED,
			IS_ID_LOOKUP,
			IS_INDEXED,
			IS_LIST_FILTERABLE,
			IS_LIST_VISIBLE,
			IS_NAME_FIELD,
			IS_NAME_POINTING,
			IS_NILLABLE,
			IS_PERMISSIONABLE,
			IS_POLYMORPHIC_FOREIGN_KEY,
			IS_RESTRICTED_DELETE,
			IS_RESTRICTED_PICKLIST,
			IS_SEARCH_PREFILTERABLE,
			IS_SORTABLE,
			IS_UNIQUE ,
			IS_UPDATEABLE,
			IS_WORKFLOW_FILTERABLE,
			IS_WRITE_REQUIRES_MASTER_READ,
			LAST_MODIFIED_BY,
			LAST_MODIFIED_BY_ID,
			LAST_MODIFIED_DATE,
			NAMESPACE_PREFIX,
			PICKLIST_VALUES,
			PRECISION,
			QUALIFIED_API_NAME,
			REFERENCE_TAR_FIELD,
			REFERENCE_TO,
			RELATIONSHIP_NAME,
			RELATIONSHIP_ORDER,
			SCALE,
			SECURITY_CLASSIFICATION,
			SOAP_TYPE,
			SOBJECT_FIELD
		};

		public static final Set<String> FIELDS_TO_DOUBLE_QUOTE = new Set<String>{
			CALCULATED_FORMULA,
			DATA_TYPE,
			DEFAULT_VALUE,
			DEFAULT_VALUE_FORMULA,
			DESCRIPTION,
			INLINE_HELP_TEXT,
			PICKLIST_VALUES,
			REFERENCE_TO
		};
		
	
	/* FUTURE:
	private static final String FORMAT_VALIDATION_RULES_IDS =
		'SELECT Id' +
		' FROM ValidationRule' +
		' WHERE EntityDefinition.DeveloperName = \'\'{0}\'\'' +
		' ORDER BY ValidationName ASC';

	private static final String FORMAT_VALIDATION_RULES_METADATA =
		'SELECT Id, Active, Description, ErrorDisplayField, ErrorMessage, Metadata, NamespacePrefix, ValidationName' +
		' FROM ValidationRule' +
		' WHERE Id =  \'\'{0}\'\'';

	private class ValidationAttributes {
		public String type;
		public String url;
	}

	private class ValidationMetadata {
		public String errorConditionFormula;
	}

	private class ValidationId {
		public ValidationAttributes attributes;
		public String Id;
	}

	private class ValidationRule {
		public ValidationAttributes attributes;
		public ValidationMetadata Metadata;
		public String Id;
		public Boolean Active;
		public String Description;
		public String ErrorDisplayField;
		public String ErrorMessage;
		public String NamespacePrefix;
		public String ValidationName;
	}
	*/

	/**
	 * @description SObjectInformation constructor.  Reads the SObject's data.
	 */
	public SObjectInformation(String nameObject) {
		this.nameObject = nameObject;

		loadObjectData();
		loadFieldsData();
	}
	
	private void loadObjectData() {
		List<String> types = new List<String>{ nameObject };
		Schema.DescribeSObjectResult describe = Schema.describeSObjects(types)[0];

		objectData.put(IS_CUSTOM, String.valueOf(describe.isCustom()));
		objectData.put(IS_CUSTOM_SETTING, String.valueOf(describe.isCustomSetting()));
		objectData.put(IS_FEED_ENABLED , String.valueOf(describe.isFeedEnabled()));
		objectData.put(IS_MRU_ENABLED, String.valueOf(describe.isMruEnabled()));
		objectData.put(KEY_PREFIX, fixNull(describe.getKeyPrefix()));
		objectData.put(LABEL, fixNull(describe.getLabel()));
		objectData.put(LABEL_PLURAL, fixNull(describe.getLabelPlural()));
		objectData.put(LOCAL_NAME, fixNull(describe.getLocalName()));		
		objectData.put(NAME, describe.label);
		objectData.put(SOBJECT_DESCRIBE_OPTION, String.valueOf(describe.getSObjectDescribeOption()));
		objectData.put(SOBJECT_TYPE, String.valueOf(describe.getSobjectType()));
	}

	public void loadFieldsData() {
		Map<String, FieldDefinition> fieldDefs;
		
		for (FieldDefinition def : Database.query(
			String.format(FORMAT_FIELDDEFINITION_QUERY, new List<String>{ nameObject })
		)) {
			fieldDefs.put(def.QualifiedApiName, def);
		}

		List<String> types = new List<String>{ nameObject };
		Schema.DescribeSObjectResult describe = Schema.describeSObjects(types)[0];
		Map<String, SObjectField> fields = describe.fields.getMap();
		List<String> nameFields = new List<String>(fields.keySet());
		nameFields.sort();

		for (String name : nameFields) {
			Map<String, String> data = new Map<String, String>();
			fieldsData.put(name, data);

			Schema.DescribeFieldResult field = fields.get(name).getDescribe();

			FieldDefinition definition = (fieldDefs.containsKey(name))
				? fieldDefs.get(name)
				: null;

			data.put(BYTE_LENGTH, String.valueOf(field.getByteLength()));
			data.put(CALCULATED_FORMULA, field.getCalculatedFormula());
			data.put(CONTROLLER,  (field.getController() == null ? EMPTY_STRING : field.getController().getDescribe().getLabel()));
			data.put(DEFAULT_VALUE_FORMULA, field.getDefaultValueFormula());
			data.put(DEFAULT_VALUE,  String.valueOf(field.getDefaultValue() == null ? EMPTY_STRING : field.getDefaultValue()));
			data.put(DIGITS, String.valueOf(field.getDigits()));
			data.put(INLINE_HELP_TEXT, field.getInlineHelpText());
			data.put(IS_ACCESSIBLE, String.valueOf(field.isAccessible()));
			data.put(IS_AI_PREDICTION_FIELD, String.valueOf(field.isAiPredictionField()));
			data.put(IS_AUTO_NUMBER, String.valueOf(field.isAutoNumber()));
			data.put(IS_CALCULATED, String.valueOf(field.isCalculated()));
			data.put(IS_CASCADE_DELETE, String.valueOf(field.isCascadeDelete()));
			data.put(IS_CASE_SENSITIVE, String.valueOf(field.isCaseSensitive()));
			data.put(IS_CREATEABLE, String.valueOf(field.isCreateable()));
			data.put(IS_CUSTOM, String.valueOf(field.isCustom()));
			data.put(IS_DEFAULTED_ON_CREATE, String.valueOf(field.isDefaultedOnCreate()));
			data.put(IS_DEPENDENT_PICKLIST, String.valueOf(field.isDependentPicklist()));
			data.put(IS_DEPRECATED_AND_HIDDEN, String.valueOf(field.isDeprecatedAndHidden()));
			data.put(IS_ENCRYPTED, String.valueOf(field.isEncrypted()));
			data.put(IS_EXTERNAL_ID, String.valueOf(field.isExternalID()));
			data.put(IS_FILTERABLE, String.valueOf(field.isFilterable()));
			data.put(IS_FORMULA_TREAT_NULL_NUMBER_AS_ZERO, String.valueOf(field.isFormulaTreatNullNumberAsZero()));
			data.put(IS_GROUPABLE, String.valueOf(field.isGroupable()));
			data.put(IS_HTML_FORMATTED, String.valueOf(field.isHtmlFormatted()));
			data.put(IS_ID_LOOKUP, String.valueOf(field.isIdLookup()));
			data.put(IS_NAME_FIELD, String.valueOf(field.isNameField()));
			data.put(IS_NAME_POINTING, String.valueOf(field.isNamePointing()));
			data.put(IS_NILLABLE, String.valueOf(field.isNillable()));
			data.put(IS_PERMISSIONABLE, String.valueOf(field.isPermissionable()));
			data.put(IS_RESTRICTED_DELETE, String.valueOf(field.isRestrictedDelete()));
			data.put(IS_RESTRICTED_PICKLIST, String.valueOf(field.isRestrictedPicklist()));
			data.put(IS_SEARCH_PREFILTERABLE, String.valueOf(field.isSearchPrefilterable()));
			data.put(IS_SORTABLE, String.valueOf(field.isSortable()));
			data.put(IS_UNIQUE, String.valueOf(field.isUnique()));
			data.put(IS_UPDATEABLE, String.valueOf(field.isUpdateable()));
			data.put(IS_WRITE_REQUIRES_MASTER_READ, String.valueOf(field.isWriteRequiresMasterRead()));
			data.put(LABEL, fixNull(field.getLabel()));
			data.put(LOCAL_NAME, fixNull(field.getLocalName()));
			data.put(NAME, fixNull(field.getName()));
			data.put(PICKLIST_VALUES, csvPicklistValues(field.getPicklistValues()));
			data.put(PRECISION, String.valueOf(field.getPrecision()));
			data.put(REFERENCE_TAR_FIELD, fixNull(field.getReferenceTargetField()));
			data.put(REFERENCE_TO, fixReferenceTo(field.getReferenceTo()));
			data.put(RELATIONSHIP_NAME, fixNull(field.getRelationshipName()));
			data.put(RELATIONSHIP_ORDER, fixNull(field.getRelationshipOrder()));
			data.put(SCALE, String.valueOf(field.getScale()));
			data.put(SOAP_TYPE, String.valueOf(field.getSOAPType()));
			data.put(SOBJECT_FIELD, String.valueOf(field.getSObjectField()));
			data.put(SOBJECT_TYPE, String.valueOf(field.getSObjectType()));

			if (definition != null) {
				data.put(BUSINESS_OWNER_ID, fixNull(definition.BusinessOwnerId));
				data.put(BUSINESS_STATUS, fixNull(definition.BusinessStatus));
				data.put(CONTROLLING_FIELD_DEFINITION_ID, fixNull(definition.ControllingFieldDefinitionId));
				data.put(DATA_TYPE, definition.DataType);
				data.put(DESCRIPTION, definition.Description);
				data.put(DURABLE_ID, definition.DurableId);
				data.put(ENTITY_DEFINITION_ID, definition.EntityDefinitionId);
				data.put(EXTRA_TYPE_INFO, fixNull(definition.ExtraTypeInfo));
				data.put(IS_API_SORTABLE, String.valueOf(definition.IsApiSortable));
				data.put(IS_COMPACT_LAYOUTABLE, String.valueOf(definition.IsCompactLayoutable));
				data.put(IS_COMPOUND, String.valueOf(definition.IsCompound));
				data.put(IS_FIELD_HISTORY_TRACKED, String.valueOf(definition.IsFieldHistoryTracked));
				data.put(IS_HIGH_SCALE_NUMBER, String.valueOf(definition.IsHighScaleNumber));
				data.put(IS_INDEXED, String.valueOf(definition.IsIndexed));
				data.put(IS_LIST_FILTERABLE, String.valueOf(definition.IsListFilterable));
				data.put(IS_LIST_VISIBLE, String.valueOf(definition.IsListVisible));
				data.put(IS_NAME_FIELD, String.valueOf(definition.IsNameField));
				data.put(IS_POLYMORPHIC_FOREIGN_KEY, String.valueOf(definition.IsPolymorphicForeignKey));
				data.put(IS_SEARCH_PREFILTERABLE, String.valueOf(definition.IsSearchPrefilterable));
				data.put(IS_WORKFLOW_FILTERABLE, String.valueOf(definition.IsWorkflowFilterable));
				data.put(IS_NILLABLE, fixNull(definition.IsNillable));
				data.put(LAST_MODIFIED_BY_ID, fixNull(definition.LastModifiedById));
				data.put(LAST_MODIFIED_BY, fixNull(definition.LastModifiedBy.Name));
				data.put(LAST_MODIFIED_DATE, fixNull(definition.LastModifiedDate));
				data.put(NAMESPACE_PREFIX, fixNull(definition.NamespacePrefix));
				data.put(PRECISION, String.valueOf(definition.Precision));
				data.put(QUALIFIED_API_NAME, definition.QualifiedApiName);
				data.put(SCALE, fixNull(definition.Scale));
				data.put(SECURITY_CLASSIFICATION, fixNull(definition.SecurityClassification));
			}
		}
	}

	/* FUTURE: MAKE WORK
	// Validation Rules
	// https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_fields_describe.htm?q=IsCustom
	private String getValidationRules(String nameObject) {
		String query;
		HttpResponse response;

		query = String.format(FORMAT_VALIDATION_RULES_IDS, new List<String>{ nameObject });
		response = HttpCallout.queryToolingApi(query);
		List<Id> ruleIds = parseValidationRuleIds(response);

		List<ValidationRule> rules = new List<ValidationRule>();

		for (String id : ruleIds) {
			query = String.format(FORMAT_VALIDATION_RULES_METADATA, new List<String>{ Id });
			response = HttpCallout.queryToolingApi(query);

			rules.add(parseValidationRuleMetadatas(response));
		}

		String result = 'VALIDATION RULES';
		result += '\nValidation Name,Active,Description,Error Display Field,ErrorMessage';

		for (ValidationRule rule : rules) {
			result += '\n' + fixNull(rule.ValidationName);
			result += ',' + rule.Active;
			result += ',' + csvDoubleQuotes(rule.Description);
			result += ',' + csvDoubleQuotes(rule.ErrorDisplayField);
			result += ',' + csvDoubleQuotes(rule.ErrorMessage);
			result += ',' + csvDoubleQuotes(rule.Metadata.errorConditionFormula);
		}

		return result;
	}

	private List<Id> parseValidationRuleIds(HttpResponse response) {
		List<Id> result = new List<Id>();

		JSONParser parser = JSON.createParser(response.getBody());

		while (parser.nextToken() != null) {
			if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
				while (parser.nextToken() != null) {
					if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
						ValidationId id = (ValidationId) parser.readValueAs(ValidationId.class);

						result.add(id.Id);
					}
				}
			}
		}

		return result;
	}

	private ValidationRule parseValidationRuleMetadatas(HttpResponse response) {
		JSONParser parser = JSON.createParser(response.getBody());

		while (parser.nextToken() != null) {
			if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
				while (parser.nextToken() != null) {
					if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
						return (ValidationRule) parser.readValueAs(ValidationRule.class);
					}
				}
			}
		}

		return null;
	}

	// Object's Record Types
	// https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Schema_RecordTypeInfo.htm#apex_class_Schema_RecordTypeInfo
	private String getRecordTypes(Schema.DescribeSobjectResult describe) {
		Map<String, Schema.RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
		List<String> names = new List<String>(recordTypes.keySet());
		names.sort();

		String result = 'RECORD TYPES';
		result += '\nName,Developer Name,RecordTypeId,Is Active,Is Available,Is Default RecordType Mapping,Is Master';

		for (String name : names) {
			RecordTypeInfo info = recordTypes.get(name);

			result += '\n' + fixNull(info.getName());
			result += ',' + fixNull(info.getDeveloperName());
			result += ',' + fixNull(info.getRecordTypeId());
			result += ',' + info.isActive();
			result += ',' + info.isAvailable();
			result += ',' + info.isDefaultRecordTypeMapping();
			result += ',' + info.isMaster();
		}

		return result;
	}

	// Relationships
	// https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Schema_ChildRelationship.htm#apex_class_Schema_ChildRelationship
	private String getChildRelationships(Schema.DescribeSobjectResult describe) {
		List<Schema.ChildRelationship> relationships = describe.getChildRelationships();

		String result = EMPTY_STRING;

		result += 'RELATIONSHIPS';
		result += '\nChild,Field,Relationship Name,Cascade Delete,Deprecated And Hidden,Restricted Delete';

		for (Schema.ChildRelationship relationship : relationships) {
			result += '\n' + relationship.getChildSObject();
			result += ',' + relationship.getField().getDescribe().getLocalName();
			result += ',' + relationship.getRelationshipName();
			result += ',' + relationship.isCascadeDelete();
			result += ',' + relationship.isDeprecatedAndHidden();
			result += ',' + relationship.isRestrictedDelete();
		}

		return result;
	}
	*/

	private static String fixNull(String value) {
		return value == null ? EMPTY_STRING : value;
	}

	private static String fixNull(Integer value) {
		return value == null ? EMPTY_STRING : String.valueOf(value);
	}

	private static String fixNull(Boolean value) {
		return value == null ? EMPTY_STRING : String.valueOf(value);
	}

	private static String fixNull(Date value) {
		return value == null ? EMPTY_STRING : String.valueOf(value);
	}

	private static String fixNull(DateTime value) {
		return value == null ? EMPTY_STRING : String.valueOf(value);
	}

	private static String csvPicklistValues(List<Schema.PicklistEntry> entries) {
		String result = EMPTY_STRING;

		if (0 < entries.size()) {
			for (Schema.PicklistEntry entry : entries) {
				result += ', ' + entry.getLabel();
			}

			result = result.right(result.length() - 2);
		}

		return result;
	}

	private static String fixReferenceTo(List<Schema.SObjectType> types) {
		String result = String.valueOf(types);

		if (2 < result.length()) {
			result = result.substring(1, result.length() - 1);
		}

		return EMPTY_STRING;
	}
}