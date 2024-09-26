/**
 * Profile_Service contains methods to retrive Profile data.
 *
 * This code will make a single SOQL call to load all the Profiles
 * and any further calls are not counted against the Governor
 * Limits.
 */
public without sharing class Profile_Service {

    public static final String SYSTEM_ADMIN = 'System Administrator';
    public static final String AREA_MANAGER = 'Area Manager';
    public static final String BBSI_STANDARD = 'BBSI Standard';
    public static final String BBSI_STANDARD_RUL = 'BBSI Standard RUL';
    public static final String BBSI_SUPPORT = 'BBSI Support';
    public static final String CONFIG_ADMIN = 'Configuration Admin';
    public static final String CONTRACTS = 'Contracts';
    public static final String LEGAL = 'Legal';
    public static final String USER_ADMIN = 'User Access Admin';

    private static Map<String, Profile> profiles = null;

    /**
     * loadProfile loads all the Profiles into the profiles map once.
     */
    private static void loadProfiles() {
        if (profiles == null) {
            List<Profile> ps = [
                SELECT Id, Name, Description, UserLicenseId, UserType, CreatedDate, LastModifiedDate
                FROM Profile
            ];

            profiles = new Map<String, Profile>();
            for (Profile p : ps) {
                profiles.put(p.Name, p);
            }
        }
    }

    /**
     * isProfile determines if the given identifier is for given name.
	 * @param  name       Name of the Profile looking for
     * @param  idProfile  Identifier to test
     * @return true when the idProfile is of the given name
     */
	public static Boolean isProfile(String name, Id idProfile) {
		loadProfiles();

        if (profiles.containsKey(name)) {
            return idProfile == profiles.get(name).Id;
		}

		return false;
	}

    /**
     * getProfile retrives the Profile object given the Profile Name.
     * @param  name Name of the Profile
     * @return The Profile related to the name, null if not found
     */
    public static Profile getProfile(String name) {
        loadProfiles();

        if (profiles.containsKey(name)) {
            return profiles.get(name);
        }

        return null;
    }

    /**
     * getProfile retrives the Profile object given the Profile Id.
     * @param  Id Identifier Name of the Profile
     * @return The Profile related to the identifier, null if not found
     */
    public static Profile getProfile(Id profileId) {
        loadProfiles();

        for (Profile p : profiles.values()) {
            if (p.Id == profileId) {
                return p;
            }
        }

        return null;
    }

    /**
     * getProfileId retrives the Profile identifier given the Profile Name.
     * @param  name Name of the Profile
     * @return The Profile Id, null if not found
     */
	public static Id getProfileId(String name) {
	    Profile p = getProfile(name);

		if (p != null) {
		    return p.Id;
		}

		return null;
	}

    /**
     * getProfileName retrives the Profile name given the Profile Id.
     * @param  Id Identifier Name of the Profile
     * @return The Profile name, null if not found
     */
	public static String getProfileName(Id profileId) {
	    Profile p = getProfile(profileId);

		if (p != null) {
		    return p.Name;
		}

		return null;
	}

    /**
     * isAreaManager determines if the given profile is for Area Managers.
     * @param  profileId is the Id to test
     * @return true if the given id is for Area Managers
     */
    public static Boolean isAreaManager(Id profileId) {
	    loadProfiles();

        return (getProfileName(profileId) == AREA_MANAGER);
    }

    /**
     * isSystemAdministrator determines if the given profile is for System Administrator.
     * @param  profileId is the Id to test
     * @return true if the given id is for System Administrators
     */
    public static Boolean isSystemAdministrator(Id profileId) {
	    loadProfiles();

        return (getProfileName(profileId) == SYSTEM_ADMIN);
    }

    /**
     * mayConfig determines if the given profile is a Salesforce Configuration profile.
     * @param  profileId is the Id to test
     * @return true if the given id is a Salesforce Configuration profile
     */
    public static Boolean mayConfigure(Id profileId) {
	    loadProfiles();

        String name = getProfileName(profileId);

        return (name == SYSTEM_ADMIN || name == CONFIG_ADMIN);
    }
}