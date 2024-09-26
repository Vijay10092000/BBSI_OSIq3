/**
 * @description UserRole_Service contains method to access the UserRole heirarchy.
 */
public with sharing class UserRole_Service {
	/**
	 * @description loadHeirarchy pulls all the UserRole data an builds out the heirarchy.
	 * The inner map includes the role and child roles.  So, all UserRoles should be in
	 * two places in the heirarchy - the parent and its own.
	 */
	private static Map<Id, Map<Id, UserRole>> heirarchy {
		get {
			if (heirarchy == null) {
				heirarchy = new Map<Id, Map<Id, UserRole>>();

				List<UserRole> roles = [
					SELECT
						Id,
						CaseAccessForAccountOwner,
						ContactAccessForAccountOwner,
						DeveloperName,
						ForecastUserId,
						MayForecastManagerShare,
						Name,
						OpportunityAccessForAccountOwner,
						ParentRoleId,
						PortalAccountId,
						PortalAccountOwnerId,
						PortalType,
						RollupDescription
					FROM UserRole
					ORDER BY DeveloperName
				];

				for (UserRole role : roles) {
					// Add to own list
					if (!heirarchy.containsKey(role.Id)) {
						heirarchy.put(role.Id, new Map<Id, UserRole>());
					}
					heirarchy.get(role.Id).put(role.Id, role);

					if (role.ParentRoleId != null) {
						// Add to parent list
						if (!heirarchy.containsKey(role.ParentRoleId)) {
							heirarchy.put(role.ParentRoleId, new Map<Id, UserRole>());
						}
						heirarchy.get(role.ParentRoleId).put(role.Id, role);
					}
				}
			}

			return heirarchy;
		}
		private set;
	}

	/**
	 * @description getById retrieves the UserRole given the Id.
	 * @param  idRole       UserRole Id looking for
	 * @return A UserRole or null if not found
	 */
	public static UserRole getById(Id idRole) {
		if (heirarchy.containsKey(idRole)) {
			Map<Id, UserRole> roles = heirarchy.get(idRole);

			if (roles.containsKey(idRole)) {
				return roles.get(idRole);
			}
		}

		return null;
	}

	/**
	 * @description getByName looks for the given Name in the UserRoles.
	 * @param  name  Name looking for
	 * @return UserRole if found, null if not
	 */
	public static UserRole getByName(String name) {
		for (Map<Id, UserRole> roles : heirarchy.values()) {
			for (UserRole role : roles.values()) {
				if (role.Name == name) {
					return role;
				}
			}
		}

		return null;
	}

	/**
	 * @description getByDeveloperName looks for the given Developer Name in the UserRoles.
	 * @param  name  Developer Name looking for
	 * @return UserRole if found, null if not
	 */
	public static UserRole getByDeveloperName(String name) {
		for (Map<Id, UserRole> roles : heirarchy.values()) {
			for (UserRole role : roles.values()) {
				if (role.DeveloperName == name) {
					return role;
				}
			}
		}

		return null;
	}

	/**
	 * @description contains determines if the given role id is in the heirarchy of the
	 * given parent role id.
	 * @param  idParent      Parent UserRole Id
	 * @param  idRole        UserRole Id looking for
	 * @param  includeParent Add idRoleParent to the list
	 * @return true if is idParent above in the heirarchy
	 */
	public static Boolean contains(Id idParent, Id idRole, Boolean includeParent) {
		return getUserRoleHeirarcyIds(idParent, includeParent).contains(idRole);
	}

	/**
	 * @description getUserRoleHeirarcyIds retrieves a Set of UserRole Ids for the given
	 * UserRole Id.
	 * @param  idRoleParent UserRole Id looking at
	 * @param  includeParent Add idRoleParent to the list
	 * @return List of UserRole Ids
	 */
	public static Set<Id> getUserRoleHeirarcyIds(Id idRoleParent, Boolean includeParent) {
		Set<Id> results = new Set<Id>();

		if (heirarchy.containsKey(idRoleParent)) {
			Map<Id, UserRole> userroles = heirarchy.get(idRoleParent);

			for (Id idRole : userroles.keySet()) {
				if (idRole == idRoleParent) {
					if (includeParent) {
						results.add(idRole);
					}
				} else {
					results.addAll(getUserRoleHeirarcyIds(idRole, true));
				}
			}
		}

		return results;
	}

	/**
	 * @description getUserRoleHeirarchy retrieves a Set of UserRole objects for the given
	 * UserRole Id.
	 * @param  idRoleParent   UserRole Id looking at
	 * @param  includeParent  Adds idRoleParent to the list
	 * @return List of UserRoles
	 */
	public static Set<UserRole> getUserRoleHeirarchy(Id idRoleParent, Boolean includeParent) {
		Set<UserRole> results = new Set<UserRole>();

		Set<Id> idRoles = getUserRoleHeirarcyIds(idRoleParent, includeParent);

		for (Id idRole : idRoles) {
			if (heirarchy.containsKey(idRole)) {
				results.add(heirarchy.get(idRole).get(idRole));
			}
		}

		return results;
	}
}