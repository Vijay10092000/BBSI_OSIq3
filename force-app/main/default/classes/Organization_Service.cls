/*
 * @description Organization_Service handles information about the current Orgnaization.
 * @see: https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_organization.htm
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public without sharing class Organization_Service {
    // Unknown Version
    @TestVisible
    private static final String UNKNOWN_VERSION = 'UNKNOWN';

    // The current API Version of the 
    public static final String ApiVersionFull;

    public static final Integer ApiVersion;

    // Information about the current organization
    public static final Organization Organization;

    static {    
        Organization = [
            SELECT
                Id,
                Address,
                ComplianceBccEmail,
                Division,
                InstanceName,
                IsSandbox,
                Latitude,
                Longitude,
                Name,
                NamespacePrefix,
                OrganizationType,
                Phone,
                PrimaryContact,
                TimeZoneSidKey
            FROM Organization
            LIMIT 1
        ];

        String version = '';
        JSONGenerator gen = JSON.createGenerator(false);
    
        gen.writeObject(new Account(Id='0012p00001aA1AaAAA'));
    
        for (String part : gen.getAsString().split('/')) {
            if (part.startsWith('v') && part.contains('.') && part.length() == 5) {
                version = part;
                break;
            }
        }
        ApiVersionFull = version;

        Integer iversion = 0;
        if (!String.isBlank(ApiVersionFull)) {
            iversion = Integer.valueOf(ApiVersionFull.substring(1, 2));
        }
        ApiVersion = iversion;
    }

    /**
     * @description isProduction determines if the current organization is Production.
     * @return  true if Production
     */
    public static Boolean isProduction() {
        return !organization.IsSandbox;
    }

    /**
     * @description isSandbox determines if the current organization is a Sandbox.
     * @return  true if Production
     */
    public static Boolean isSandbox() {
        return organization.IsSandbox;
    }

    /**
     * @description getSandboxName retrieves the name of the Sandbox.
     * @return  Name of sandbox or null if Production
     */
    public static String  getSandboxName() {
        if (isSandbox()) {
            System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());
            return domain.getSandboxName().toUppercase();
        }

        return null;
    }

    /**
     * @description getOrgnaizationTitle retrieves Production or 'Sandbox [NAME]'.
     * @return  A title for the Organization
     */
    public static String getOrgnaizationTitle() {
        String name = getSandboxName();

        if (name == null) {
            name = 'Production';
        } else {
            name = 'Sandbox ' + name;
        }

        return name;
    }

    /**
     * @description getCurrentVersion retrieves the season/year version of Salesforce
     * for the current organization.
     * @return Season Year of the version
     */
    public static String getCurrentVersion() {
        return getVersion(ApiVersion);
    }

    /**
     * @description getVersion retrieves the season/year version of Salesforce
     * for the given API Version.
     * @param  version  API Version number
     * @return Season Year of the version
     */
    public static String getVersion(Integer version) {
        if (0 < version) {
            String season;

            switch on (Math.mod(version, 3)) {
                when 0    { season = 'Summer'; }
                when 1    { season = 'Winter'; }
                when else { season = 'Spring'; }
            }

            Integer abbrYear = 5 + ((version - 1) / 3);

            return season + ' \'' + abbrYear;
        }

        return UNKNOWN_VERSION;
    }
}