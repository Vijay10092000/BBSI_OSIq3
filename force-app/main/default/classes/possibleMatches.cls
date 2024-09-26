/**
 * @description possibleMatches
 */
@SuppressWarnings('PMD.ApexDoc, PMD.PropertyNamingConventions')
public without sharing class possibleMatches implements Comparable {
	@AuraEnabled
	public ID recordID { get; set; }

	@AuraEnabled
	public String matchType { get; set; }

	@AuraEnabled
	public User Owner { get; set; }
	@AuraEnabled
	public String OwnerId { get; set; }
	@AuraEnabled
	public String OwnerName { get; set; }

	@AuraEnabled
	public Account Branch { get; set; }
	@AuraEnabled
	public String BranchName { get; set; }
	@AuraEnabled
	public String BranchId { get; set; }

	@AuraEnabled
	public String Name { get; set; }

	@AuraEnabled
	public String LastName { get; set; }

	@AuraEnabled
	public String Company { get; set; }

	@AuraEnabled
	public String CompanyId { get; set; }

	@AuraEnabled
	public String FEIN { get; set; }

	@AuraEnabled
	public String Street { get; set; }

	@AuraEnabled
	public String Phone { get; set; }

	@AuraEnabled
	public String recordType { get; set; }

	@AuraEnabled
	public DateTime createdDate { get; set; }

	@AuraEnabled
	public String DBAName { get; set; }

	@AuraEnabled
	public boolean FEINMatch { get; set; }

	@AuraEnabled
	public boolean CompanyMatch { get; set; }

	@AuraEnabled
	public boolean DBAMatch { get; set; }

	@AuraEnabled
	public boolean NameMatch { get; set; }

	@AuraEnabled
	public Integer matchCount {
		get {
			Integer count = 0;
			count += (CompanyMatch) ? 1 : 0;
			count += (FEINMatch) ? 1 : 0;
			count += (NameMatch) ? 1 : 0;
			count += (DBAMatch) ? 1 : 0;
			return count;
		}
		set;
	}

	public decimal smallestDistance { get; set; }

	public possibleMatches() {
		Owner = new User();
		CompanyMatch = false;
		DBAMatch = false;
		FEINMatch = false;
		NameMatch = false;
	}

	/**
	 * @description compareTo description
	 * @param  compareTo compareTo description
	 * @return
	 *     < 0 if this instance is before
	 *     0 if this instance and objectToCompareTo are equal
	 *     > 0 if this instance is after
	 */
	public Integer compareTo(Object compareTo) {
		possibleMatches that = (possibleMatches) compareTo;

		if (this.FEINMatch) {
			if (!that.FEINMatch) {
				return -1;
			}
		} else if (that.FEINMatch) {
			return 1;
		}

		Integer diff = that.matchCount - this.matchCount;

		if (diff != 0) {
			return diff;
		}

		if (this.smallestDistance < that.smallestDistance) {
			return -1;
		}

		if (this.smallestDistance > that.smallestDistance) {
			return 1;
		}

		if (this.CompanyMatch) {
			if (!that.CompanyMatch) {
				return -1;
			}
		} else if (that.CompanyMatch) {
			return 1;
		}

		if (this.NameMatch) {
			if (!that.NameMatch) {
				return -1;
			}
		} else if (that.NameMatch) {
			return 1;
		}

		if (this.DBAMatch) {
			if (!that.DBAMatch) {
				return -1;
			}
		} else if (that.DBAMatch) {
			return 1;
		}

		return 0;
	}
}