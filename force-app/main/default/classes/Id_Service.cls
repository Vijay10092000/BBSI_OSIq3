/**
 * @description Id_Service contians routines to identify types of Ids.
 */
public with sharing class Id_Service {
    /**
     * @description isType determines if the given identifier is of the SObject type.
     * @param  id         Identifier to test
     * @param  typeObject Object type looking for
     * @return true if identifier is of the given type
     */
    public static Boolean isType(Id id, String typeObject) {
        return typeObject == id?.getSObjectType().getDescribe().getName();
    }

    /**
     * @description getSObjectName retrieves the name of the SObject for given identifier.
     * @param  id         Identifier looking for SObject name
     * @return Name of the SObject related to the identifier
     */
    public static String getSObjectName(Id id) {
        return id?.getSObjectType().getDescribe().getName();
    }

    /**
     * @description getSObjectLabel retrieves the label of the SObject for given identifier.
     * @param  id         Identifier looking for SObject label
     * @return Label of the SObject related to the identifier
     */
    public static String getSObjectLabel(Id id) {
        return id?.getSObjectType().getDescribe().getLabel();
    }

	/**
	 * @description makeIdString converts an Id into a string
	 * @param  id Id to convert
	 * @return A String with the id or a blank string if id is null
	 */
	public static String makeIdString(Id id) {
		if (id == null) {
			return '';
		}

		return String.valueOf(id);
	}
}