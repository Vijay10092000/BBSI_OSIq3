/**
 * @description BenefitsAffiliatesUpdates contains methods to compare and
 * update fields for Benefits between objects.
 */
public without sharing class BenefitsAffiliatesUpdates {
	/**
	 * @description sameAs compares the Benefits fields of the given accounts.
	 * @param oldClient  Account before changed
	 * @param newClient  Account with changes
	 * @return true if fields are the same.  Note: If either is null it returns false.
	 */
	public static Boolean sameAs(Account oldClient, Account newClient) {
		if (oldClient == null && newClient == null) {
			return true;
		}

		if (oldClient == null || newClient == null) {
			return false;
		}

		Boolean result = true;

		result &= oldClient.Name == newClient.Name;
		result &= oldClient.Benefits__c == newClient.Benefits__c;
		result &= oldClient.Benefits_Type__c == newClient.Benefits_Type__c;
		result &= oldClient.Benefits_Affiliates__c == newClient.Benefits_Affiliates__c;
		result &= oldClient.NumberOfEmployees == newClient.NumberOfEmployees;
		result &= oldClient.Active_Employees_Full_Time__c == newClient.Active_Employees_Full_Time__c;
		result &= oldClient.Active_Employees_Part_Time__c == newClient.Active_Employees_Part_Time__c;
		result &= oldClient.Benefits_Representative__c == newClient.Benefits_Representative__c;

		System.debug(
			LoggingLevel.FINE,
			'~~~~~~~~~~~~~~~~~~~~ sameAs(CLIENT, CLIENT) result = ' +
			result + '\n' +
			debugAccount(oldClient) +
			debugAccount(newClient)
		);
		return result;
	}

	/**
	 * @description sameAs compares the Benefits fields of the given
	 * account to an Opportunity.
	 * @param client  Account testing
	 * @param opp     Opportunity testing
	 * @return  true if fields are the same.  false if any input is null
	 */
	public static Boolean sameAs(Account client, Opportunity opp) {
		Boolean result = true;

		result &= (opp.Benefits_Affiliates__c == client.Benefits_Affiliates__c);
		result &= (opp.Benefits_Affiliated_Companies__c == client.Benefits_Affiliated_Companies__c);
		result &= (opp.Benefits_Consultant__c == client.Benefits_Representative__c);

		if (opp.Benefits_Affiliates__c == null) {
			result &= (opp.Benefits_Affiliated_Companies__c == null);
			result &= (opp.Active_Employees_All_Affiliates__c == client.NumberOfEmployees);
			result &= (opp.Full_Time_Employees_All_Affiliates__c == client.Active_Employees_Full_Time__c);
			result &= (opp.Part_Time_Employees_All_Affiliates__c == client.Active_Employees_Part_Time__c);
		} else {
			result &= (opp.Benefits_Affiliated_Companies__c == client.Benefits_Affiliated_Companies__c);
			result &= (opp.Active_Employees_All_Affiliates__c == client.Active_Employees_All_Affiliates__c);
			result &= (opp.Full_Time_Employees_All_Affiliates__c == client.Full_Time_Employees_All_Affiliates__c);
			result &= (opp.Part_Time_Employees_All_Affiliates__c == client.Part_Time_Employees_All_Affiliates__c);
		}

		System.debug(
			LoggingLevel.FINE,
			'~~~~~~~~~~~~~~~~~~~~ sameAs(CLIENT, OPPORTUNITY) result = ' +
			result + '\n' +
			debugAccount(client) +
			debugOpportunity(opp)
		);
		return result;
	}

	/**
	 * @description sameAs compares the Benefits fields of the given
	 * account to a Benefits_Affiliates__c.
	 * @param client    Account
	 * @param benefits  Benefits__c
	 * @return  true if fields are the same.
	 */
	public static Boolean sameAs(Account client, Benefits__c benefits) {
		Boolean result = true;

		result &= (benefits.Id == client.Benefits__c);
		result &= (benefits.Benefits_Type__c == client.Benefits_Type__c);
		result &= (benefits.Benefits_Affiliated_Companies__c == client.Benefits_Affiliated_Companies__c);
		result &= (benefits.Benefits_Specialist__c == client.Benefits_Representative__c);
		if (client.Benefits_Affiliates__c == null) {
			result &= (benefits.Active_Employees_All_Affiliates__c == client.NumberOfEmployees);
			result &= (benefits.Full_Time_Employees_All_Affiliates__c == client.Active_Employees_Full_Time__c);
			result &= (benefits.Part_Time_Employees_All_Affiliates__c == client.Active_Employees_Part_Time__c);
		}
		else {
			result &= (benefits.Active_Employees_All_Affiliates__c == client.Active_Employees_All_Affiliates__c);
			result &= (benefits.Full_Time_Employees_All_Affiliates__c == client.Full_Time_Employees_All_Affiliates__c);
			result &= (benefits.Part_Time_Employees_All_Affiliates__c == client.Part_Time_Employees_All_Affiliates__c);
		}

		System.debug(
			LoggingLevel.FINE,
			'~~~~~~~~~~~~~~~~~~~~ sameAs(CLIENT, BENEFITS) result = ' +
			result + '\n' +
			debugAccount(client) +
			debugBenefits(benefits)
		);
		return result;
	}

	/**
	 * @description sameAs compares the Benefits fields of the given
	 * account to a Benefits_Affiliates__c.
	 * @param client  Account
	 * @param ba      Benefits_Affiliates__c
	 * @return  true if fields are the same.  false if any input is null
	 */
	public static Boolean sameAs(Account client, Benefits_Affiliates__c ba) {
		Boolean result = true;

		result &= (client.Benefits__c == ba.Benefits__c);
		result &= (client.Benefits_Representative__c == ba.Benefits_Representative__c);

		if (ba.Benefits__c == null) {
			result &= (client.Benefits_Affiliated_Companies__c == null);
			result &= (ba.Active_Employees_All_Affiliates__c == client.NumberOfEmployees);
			result &= (ba.Full_Time_Employees_All_Affiliates__c == client.Active_Employees_Full_Time__c);
			result &= (ba.Part_Time_Employees_All_Affiliates__c == client.Active_Employees_Part_Time__c);
		} else {
			result &= (client.Benefits_Affiliated_Companies__c == ba.Benefits_Affiliated_Companies__c);
			result &= (client.Active_Employees_All_Affiliates__c == ba.Active_Employees_All_Affiliates__c);
			result &= (client.Full_Time_Employees_All_Affiliates__c == ba.Full_Time_Employees_All_Affiliates__c);
			result &= (client.Part_Time_Employees_All_Affiliates__c == ba.Part_Time_Employees_All_Affiliates__c);
		}

		System.debug(
			LoggingLevel.FINE,
			'~~~~~~~~~~~~~~~~~~~~ sameAs(CLIENT, BENEFITS AFFILIATES) result = ' +
			result + '\n' +
			debugAccount(client) +
			debugBenefitsAffiliates(ba)
		);
		return result;
	}

	/**
	 * @description sameAs checks for Benefits fields differences between the
	 * old and new Opportuities.
	 * @param oldOpp  Opportunity before changes
	 * @param newOpp  Opportunity with changes
	 * @return true if there are differeneces
	 */
	public static Boolean sameAs(Opportunity oldOpp, Opportunity newOpp) {
		if (oldOpp == null && newOpp == null) {
			return true;
		}

		if (oldOpp == null || newOpp == null) {
			return false;
		}

		Boolean result = true;

		result &= oldOpp.Benefits_Affiliated_Companies__c == newOpp.Benefits_Affiliated_Companies__c;
		result &= oldOpp.Active_Employees_All_Affiliates__c == newOpp.Active_Employees_All_Affiliates__c;
		result &= oldOpp.Full_Time_Employees_All_Affiliates__c == newOpp.Full_Time_Employees_All_Affiliates__c;
		result &= oldOpp.Part_Time_Employees_All_Affiliates__c == newOpp.Part_Time_Employees_All_Affiliates__c;
		result &= oldOpp.Benefits_Specialist__c == newOpp.Benefits_Specialist__c;
		result &= oldOpp.Benefits_Consultant__c == newOpp.Benefits_Consultant__c;
		result &= oldOpp.Benefits_Coordinator__c == newOpp.Benefits_Coordinator__c;

		System.debug(
			LoggingLevel.FINE,
			'~~~~~~~~~~~~~~~~~~~~ sameAs(OPPORTUNITY, OPPORTUNITY) result = ' +
			result + '\n' +
			debugOpportunity(oldOpp) +
			debugOpportunity(newOpp)
		);
		return result;
	}

	/**
	 * @description sameAs checks if the Benefits fields are different between the Opportunity
	 * and the Benefits_Affiliates__c.
	 * @param opp  Opportunity testing
	 * @param ba   Benefits_Affiliates__c testing
	 * @return true if there are differeneces
	 */
	public static Boolean sameAs(Opportunity opp, Benefits_Affiliates__c ba) {
		Boolean result = true;

		result &= opp.Id == ba.Benefits_Opportunity__c;
		result &= opp.Benefits_Affiliates__c == ba.Id;
		result &= opp.Benefits_Affiliated_Companies__c == ba.Benefits_Affiliated_Companies__c;
		result &= opp.Active_Employees_All_Affiliates__c == ba.Active_Employees_All_Affiliates__c;
		result &= opp.Full_Time_Employees_All_Affiliates__c == ba.Full_Time_Employees_All_Affiliates__c;
		result &= opp.Part_Time_Employees_All_Affiliates__c == ba.Part_Time_Employees_All_Affiliates__c;
		result &= opp.Benefits_Consultant__c == ba.Benefits_Representative__c;
		result &= opp.Benefits_Coordinator__c == ba.Benefits_Coordinator__c;

		System.debug(
			LoggingLevel.FINE,
			'~~~~~~~~~~~~~~~~~~~~ sameAs(OPPORTUNITY, BENEFITS AFFILIATES) result = ' +
			result + '\n' +
			debugOpportunity(opp) +
			debugBenefitsAffiliates(ba)
		);
		return result;
	}

	/**
	 * @description sameAs compares the Benefits fields of the given
	 * Benefits__cs.
	 * @param oldBenefits  Benefits__c before changed
	 * @param newBenefits  Benefits__c with changes
	 * @return  true if fields are the same.  false if any input is null
	 */
	public static Boolean sameAs(Benefits__c oldBenefits, Benefits__c newBenefits) {
		if (oldBenefits == null && newBenefits == null) {
			return true;
		}

		if (oldBenefits == null || newBenefits == null) {
			return false;
		}

		Boolean result = true;

		result &= oldBenefits.Benefits_Type__c == newBenefits.Benefits_Type__c;
		result &= oldBenefits.Benefits_Affiliated_Companies__c == newBenefits.Benefits_Affiliated_Companies__c;
		result &= oldBenefits.Active_Employees_All_Affiliates__c == newBenefits.Active_Employees_All_Affiliates__c;
		result &=
			oldBenefits.Full_Time_Employees_All_Affiliates__c == newBenefits.Full_Time_Employees_All_Affiliates__c;
		result &=
			oldBenefits.Part_Time_Employees_All_Affiliates__c == newBenefits.Part_Time_Employees_All_Affiliates__c;
		result &= oldBenefits.Benefits_Specialist__c == newBenefits.Benefits_Specialist__c;
		result &= oldBenefits.Benefits_Coordinator__c == newBenefits.Benefits_Coordinator__c;

		System.debug(
			LoggingLevel.FINE,
			'~~~~~~~~~~~~~~~~~~~~ sameAs(BENEFITS, BENEFITS) result = ' +
			result + '\n' +
			debugBenefits(oldBenefits) +
			debugBenefits(newBenefits)
		);
		return result;
	}

	/**
	 * @description sameAs checks if the Benefits fields are different between the Benefits__c
	 * and the Benefits_Affiliates__c.
	 * @param benefits  Benefits__c testing
	 * @param ba   Benefits_Affiliates__c testing
	 * @return true if there are differeneces
	 */
	public static Boolean sameAs(Benefits__c benefits, Benefits_Affiliates__c ba) {
		Boolean result = true;

		result &= benefits.Benefits_Affiliates__c == ba.Id;
		result &= benefits.Id == ba.Benefits__c;
		result &= benefits.AccountId__c == ba.Primary_Account__c;
		result &= benefits.Benefits_Affiliated_Companies__c == ba.Benefits_Affiliated_Companies__c;
		result &= benefits.Active_Employees_All_Affiliates__c == ba.Active_Employees_All_Affiliates__c;
		result &= benefits.Full_Time_Employees_All_Affiliates__c == ba.Full_Time_Employees_All_Affiliates__c;
		result &= benefits.Part_Time_Employees_All_Affiliates__c == ba.Part_Time_Employees_All_Affiliates__c;
		result &= benefits.Benefits_Specialist__c == ba.Benefits_Representative__c;
		result &= benefits.Benefits_Coordinator__c == ba.Benefits_Coordinator__c;

		System.debug(
			LoggingLevel.FINE,
			'~~~~~~~~~~~~~~~~~~~~ sameAs(BENEFITS, BENEFITS AFFILIATES) result = ' +
			result + '\n' +
			debugBenefits(benefits) +
			debugBenefitsAffiliates(ba)
		);
		return result;
	}

	/**
	 * @description updateRelated updates the Account to the Benefits if there is a change.
	 * @param  client  Account changing
	 * @param  opp     Opportunity
	 * @return true if a change was made
	 */
	public static Boolean updateRelated(Account client, Opportunity opp) {
		if (client != null && opp != null) {
			if (!sameAs(client, opp)) {
				client.Benefits_Affiliates__c = opp.Benefits_Affiliates__c;
				client.Active_Employees_All_Affiliates__c = opp.Active_Employees_All_Affiliates__c;
				client.Full_Time_Employees_All_Affiliates__c = opp.Full_Time_Employees_All_Affiliates__c;
				client.Part_Time_Employees_All_Affiliates__c = opp.Part_Time_Employees_All_Affiliates__c;
				client.Benefits_Representative__c = opp.Benefits_Consultant__c;

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(CLIENT, OPPORTUNITY) result = true \n' +
					debugAccount(client) +
					debugOpportunity(opp)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description updateRelated updates the Account to the Benefits if there is a change.
	 * @param  client    Account changing
	 * @param  benefits  Benefits__c
	 * @return true if change occurred
	 */
	public static Boolean updateRelated(Account client, Benefits__c benefits) {
		if (client != null && benefits != null) {
			if (!sameAs(client, benefits)) {
				client.Benefits__c = benefits.Id;
				client.BBSI_Benefits__c = (benefits.Id != null);
				if(client.BBSI_Benefits__c && benefits.L_H_Referral_Partner__c != null && benefits.L_H_Producer__c != null){
					client.Referral_Partner_for_Benefits__c = benefits.L_H_Referral_Partner__c;
    				client.Producer_for_Benefits__c = benefits.L_H_Producer__c;
					client.Is_there_a_benefits_referral_partner__c = benefits.Is_there_a_benefits_referral_partner__c;
				}
				client.Benefits_Affiliated_Companies__c = benefits.Benefits_Affiliated_Companies__c;
				client.Active_Employees_All_Affiliates__c = benefits.Active_Employees_All_Affiliates__c;
				client.Full_Time_Employees_All_Affiliates__c = benefits.Full_Time_Employees_All_Affiliates__c;
				client.Part_Time_Employees_All_Affiliates__c = benefits.Part_Time_Employees_All_Affiliates__c;
				client.Benefits_Representative__c = benefits.Benefits_Specialist__c;

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(CLIENT, BENEFITS)  CHANGED \n' +
					debugAccount(client) +
					debugBenefits(benefits)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description updateRelated updates a Client account from the given Benefits_Affiliates__c.
	 * @param  client  Account
	 * @param  ba      Benefits Affiliates
	 * @return true if change occurred
	 */
	public static Boolean updateRelated(Account client, Benefits_Affiliates__c ba) {
		if (client != null && ba != null) {
			if (!sameAs(client, ba)) {
				client.Benefits_Affiliates__c = ba.Id;
				client.Active_Employees_All_Affiliates__c = ba.Active_Employees_All_Affiliates__c;
				client.Full_Time_Employees_All_Affiliates__c = ba.Full_Time_Employees_All_Affiliates__c;
				client.Part_Time_Employees_All_Affiliates__c = ba.Part_Time_Employees_All_Affiliates__c;
				client.Benefits_Representative__c = ba.Benefits_Representative__c;

				if (ba.Benefits__c == null) {
					client.Benefits__c = null;
					client.BBSI_Benefits__c = false;
					client.Benefits_Affiliated_Companies__c = null;
				} else {
					client.Benefits__c = ba.Benefits__c;
					client.BBSI_Benefits__c = (ba.Benefits__c != null);
					client.Benefits_Affiliated_Companies__c = ba.Benefits_Affiliated_Companies__c;
				}
				if(ba.Primary_Account__c != null && ba.Primary_Account__c != client.Id){
					client.Is_there_a_benefits_referral_partner__c = ba.Primary_Account__r.Is_there_a_benefits_referral_partner__c;
					client.Benefits_Effective_Date__c = ba.Primary_Account__r.Benefits_Effective_Date__c;
					client.BBSI_Benefits_Renewal_Date__c = ba.Primary_Account__r.BBSI_Benefits_Renewal_Date__c;
				}
				if(client.Referral_Partners__r != null && !client.Referral_Partners__r.isEmpty()){
					for(Referral_Partner__c rs:client.Referral_Partners__r){
						rs.Benefits_Affiliated_Companies__c = ba.Benefits_Affiliated_Companies__c;
					}
				}
				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(CLIENT, BENEFITS AFFILIATES)  CHANGED \n' +
					debugAccount(client) +
					debugBenefitsAffiliates(ba)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description updateRelated updates Opportunity related to given Benefits_Affiliates__c.
	 * @param  opp     Benefits__c
	 * @param  client  Account related to the Opportunity
	 * @return true if there was a change
	 */
	public static Boolean updateRelated(Opportunity opp, Account client) {
		if (opp != null && client != null) {
			if (!sameAs(client, opp)) {
				if (opp.IsClosed) {
					System.debug('OPPORTUNITY IS CLOSED -- NO UPDATE');
					return false;
				}

				opp.Benefits_Affiliates__c = client.Benefits_Affiliates__c;
				opp.Benefits_Consultant__c = client.Benefits_Representative__c;
				opp.Validation_Rule_Skip_Toggle__c = !opp.Validation_Rule_Skip_Toggle__c;

				if (client.Benefits_Affiliates__c == null) {
					opp.Have_Common_Ownership__c = 'No';
					opp.Benefits_Affiliated_Companies__c = null;
					opp.Active_Employees_All_Affiliates__c = client.NumberOfEmployees;
					opp.Full_Time_Employees_All_Affiliates__c = client.Active_Employees_Full_Time__c;
					opp.Part_Time_Employees_All_Affiliates__c = client.Active_Employees_Part_Time__c;
				} else {
					opp.Have_Common_Ownership__c = 'Yes';
					opp.Benefits_Affiliated_Companies__c = client.Benefits_Affiliated_Companies__c;
					opp.Active_Employees_All_Affiliates__c = client.Active_Employees_All_Affiliates__c;
					opp.Full_Time_Employees_All_Affiliates__c = client.Full_Time_Employees_All_Affiliates__c;
					opp.Part_Time_Employees_All_Affiliates__c = client.Part_Time_Employees_All_Affiliates__c;
				}

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(OPPORTUNITY, CLIENT)   CHANGED \n' +
					debugOpportunity(opp) +
					debugAccount(client)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description updateRelated updates Opportunity related to given Benefits_Affiliates__c.
	 * @param  opp  Opportunity
	 * @param  ba   Benefits Affiliates
	 * @return true if a change was made
	 */
	public static Boolean updateRelated(Opportunity opp, Benefits_Affiliates__c ba) {
		if (opp != null && ba != null) {
			if (!sameAs(opp, ba)) {
				if (opp.IsClosed) {
					System.debug('OPPORTUNITY IS CLOSED -- NO UPDATE');
					return false;
				}

				opp.Benefits_Affiliates__c = ba.Id;
				opp.Have_Common_Ownership__c = 'Yes';
				opp.Benefits_Consultant__c = ba.Benefits_Representative__c;
				opp.Benefits_Coordinator__c = ba.Benefits_Coordinator__c;
				opp.Active_Employees_All_Affiliates__c = ba.Active_Employees_All_Affiliates__c;
				opp.Full_Time_Employees_All_Affiliates__c = ba.Full_Time_Employees_All_Affiliates__c;
				opp.Part_Time_Employees_All_Affiliates__c = ba.Part_Time_Employees_All_Affiliates__c;
				opp.Benefits_Affiliated_Companies__c = ba.Benefits_Affiliated_Companies__c;

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(OPPORTUNITY, BENEFITS AFFILIATES)  CHANGED \n' +
					debugOpportunity(opp) +
					debugBenefitsAffiliates(ba)
				);
				return true;
			}
		}
		return false;
	}

	/**
	 * @description updateRelatedAccount updates Benefits__c related to given Benefits_Affiliates__c.
	 * @param  benefits  Benefits__c
	 * @param  client    Account
	 * @return true if there was a change
	 */
	public static Boolean updateRelated(Benefits__c benefits, Account client) {
		if (benefits != null && client != null) {
			if (!sameAs(client, benefits)) {
				benefits.Benefits_Affiliates__c = client.Benefits_Affiliates__c;
				benefits.Is_there_common_ownership__c = (client.Benefits_Affiliates__c == null) ? 'No' : 'Yes';
				benefits.Benefits_Affiliated_Companies__c = client.Benefits_Affiliated_Companies__c;

				if (client.Benefits_Affiliates__c == null) {
					benefits.Active_Employees_All_Affiliates__c = client.NumberOfEmployees; // 51500
					benefits.Full_Time_Employees_All_Affiliates__c = client.Active_Employees_Full_Time__c; // 51500
					benefits.Part_Time_Employees_All_Affiliates__c = client.Active_Employees_Part_Time__c; // 51500
				}
				else {
					benefits.Active_Employees_All_Affiliates__c = client.Active_Employees_All_Affiliates__c;
					benefits.Full_Time_Employees_All_Affiliates__c = client.Full_Time_Employees_All_Affiliates__c;
					benefits.Part_Time_Employees_All_Affiliates__c = client.Part_Time_Employees_All_Affiliates__c;
				}

				benefits.Benefits_Specialist__c = client.Benefits_Representative__c;

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(BENEFITS, CLIENT)  CHANGED \n' +
					debugBenefits(benefits) +
					debugAccount(client)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description updateRelated updates Benefits__c related to given Benefits_Affiliates__c.
	 * @param  benefits  Benefits__c
	 * @param  ba        Benefits Affiliates
	 * @return true if change occurred
	 */
	public static Boolean updateRelated(Benefits__c benefits, Benefits_Affiliates__c ba) {
		if (benefits != null && ba != null) {
			if (!sameAs(benefits, ba)) {
				benefits.Benefits_Affiliates__c = ba.Id;
				benefits.Is_there_common_ownership__c = 'Yes';
				benefits.Benefits_Affiliated_Companies__c = ba.Benefits_Affiliated_Companies__c;
				benefits.Active_Employees_All_Affiliates__c = ba.Active_Employees_All_Affiliates__c;
				benefits.Full_Time_Employees_All_Affiliates__c = ba.Full_Time_Employees_All_Affiliates__c;
				benefits.Part_Time_Employees_All_Affiliates__c = ba.Part_Time_Employees_All_Affiliates__c;
				benefits.Benefits_Specialist__c = ba.Benefits_Representative__c;
				benefits.Benefits_Coordinator__c = ba.Benefits_Coordinator__c;

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(BENEFITS, BENEFITS AFFILIATES)  CHANGED \n' +
					debugBenefits(benefits) +
					debugBenefitsAffiliates(ba)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description updateRelated updates a Benefits_Affiliates__c from the given Client account.
	 * @param  ba      Benefits Affiliates
	 * @param  client  Account
	 * @return true if change occurred
	 */
	public static Boolean updateRelated(Benefits_Affiliates__c ba, Account client) {
		if (ba != null && client != null) {
			if (!sameAs(client, ba)) {
				ba.Benefits__c = client.Benefits__c;
				ba.Benefits_Representative__c = client.Benefits_Representative__c;
				ba.OwnerId = (client.Benefits_Representative__c == null) ? ba.OwnerId : client.Benefits_Representative__c;

				if (ba.Benefits__c == null) {
					ba.Active_Employees_All_Affiliates__c = client.NumberOfEmployees;
					ba.Full_Time_Employees_All_Affiliates__c = client.Active_Employees_Full_Time__c;
					ba.Part_Time_Employees_All_Affiliates__c = client.Active_Employees_Part_Time__c;
				} else {
					ba.Active_Employees_All_Affiliates__c = client.Active_Employees_All_Affiliates__c;
					ba.Full_Time_Employees_All_Affiliates__c = client.Full_Time_Employees_All_Affiliates__c;
					ba.Part_Time_Employees_All_Affiliates__c = client.Part_Time_Employees_All_Affiliates__c;
				}

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(BENEFITS AFFILIATES, CLIENT)  CHANGED \n' +
					debugBenefitsAffiliates(ba) +
					debugAccount(client)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description updateRelated updates a Benefits_Affiliates__c from the given Benefits.
	 * @param  ba   Benefits Affiliates
	 * @param  opp  Opportunity
	 * @return true if change occurred
	 */
	public static Boolean updateRelated(Benefits_Affiliates__c ba, Opportunity opp) {
		if (ba != null && opp != null) {
			if (!sameAs(opp, ba)) {
				ba.Benefits_Opportunity__c = opp.Id;
				ba.Benefits_Coordinator__c = opp.Benefits_Coordinator__c;
				ba.Benefits_Representative__c = opp.Benefits_Consultant__c;
				ba.Toggle_Update__c = true;

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(BENEFITS AFFILIATES, OPPORTUNITY)  CHANGED \n' +
					debugBenefitsAffiliates(ba) +
					debugOpportunity(opp)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description updateRelated updates a Benefits_Affiliates__c from the given Benefits.
	 * @param  ba        Benefits Affiliates
	 * @param  benefits  Benefits
	 * @return true if change occurred
	 */
	public static Boolean updateRelated(Benefits_Affiliates__c ba, Benefits__c benefits) {
		if (ba != null && benefits != null) {
			if (!sameAs(benefits, ba)) {
				ba.Benefits__c = benefits.Id;
				ba.Primary_Account__c = benefits.AccountId__c;
				ba.Benefits_Opportunity__c = benefits.Opportunity__c;
				ba.Benefits_Coordinator__c = benefits.Benefits_Coordinator__c;
				ba.Benefits_Representative__c = benefits.Benefits_Specialist__c;
				ba.Toggle_Update__c = true;

				System.debug(
					LoggingLevel.FINE,
					'~~~~~~~~~~~~~~~~~~~~ updateRelates(BENEFITS AFFILIATES, BENEFITS)  CHANGED \n' +
					debugBenefitsAffiliates(ba) +
					debugBenefits(benefits)
				);
				return true;
			}
		}

		return false;
	}

	/**
	 * @description clearAffiliatesData updates a Client account related to given Benefits_Affiliates__c.
	 * @param  client    Account
	 * @param  branch    Benefits Affiliates
	 * @param  benefits  Related Benefits
	 */
	public static void clearAffiliatesData(Account client, Account branch, List<Benefits__c> benefits) {
		Boolean haveBenefits = false;
		String typeBenefits = null;

		for (Benefits__c b : benefits) {
			if (b.AccountId__c == client.Id) {
				haveBenefits = true;
				typeBenefits = b.Benefits_Type__c;
				break;
			}
		}

		client.Benefits_Representative__c = branch?.Benefits_Consultant__c;
		client.Benefits_Affiliates__c = null;
		client.Benefits_Affiliated_Companies__c = null;
		client.BBSI_Benefits__c = haveBenefits;
		//client.Benefits_Type__c = typeBenefits;
		client.Active_Employees_All_Affiliates__c = 0;
		client.Full_Time_Employees_All_Affiliates__c = 0;
		client.Part_Time_Employees_All_Affiliates__c = 0;
	}

	/**
	 * @description clearAffiliatesData updates Opportunity by removing data about a Benefits Affiliates.
	 * @param  o        Opportunity
	 * @param  account  Account related to the Opportunity
	 * @param  branch   Related Branch
	 */
	public static void clearAffiliatesData(Opportunity o, Account account, Account branch) {
		o.Benefits_Affiliates__c = null;
		o.Benefits_Affiliated_Companies__c = null;
		o.Have_Common_Ownership__c = 'No';
		o.Active_Employees_All_Affiliates__c = (account == null) ? 0 : account.NumberOfEmployees;
		o.Full_Time_Employees_All_Affiliates__c = (account == null) ? 0 : account.Active_Employees_Full_Time__c;
		o.Part_Time_Employees_All_Affiliates__c = (account == null) ? 0 : account.Active_Employees_Part_Time__c;
		o.Validation_Rule_Skip_Toggle__c = !o.Validation_Rule_Skip_Toggle__c;
	}

	/**
	 * @description clearAffiliatesData updates Benefits by removing data about a Benefits Affiliates.
	 * @param  benefits  Benefits__c
	 * @param  account   Account related to the Benefits
	 * @param  branch    Related Branch
	 */
	public static void clearAffiliatesData(Benefits__c benefits, Account account, Account branch) {
		benefits.Benefits_Affiliates__c = null;
		benefits.Benefits_Affiliated_Companies__c = null;
		benefits.Is_there_common_ownership__c = 'No';
		benefits.Active_Employees_All_Affiliates__c = 0;
		benefits.Full_Time_Employees_All_Affiliates__c = 0;
		benefits.Part_Time_Employees_All_Affiliates__c = 0;
	}

	private static String debugAccount(Account client) {
		String textDebug = '  CLIENT: ' + client.Id + '  ' + client.Name;
		textDebug += '\n    Benefits__c: ' + client.Benefits__c;
		textDebug += '\n    BBSI_Benefits__c -  CLIENT: ' + client.BBSI_Benefits__c;
		textDebug += '\n    Benefits_Type__c: ' + client.Benefits_Type__c;
		textDebug += '\n    Benefits_Affiliates__c: ' + client.Benefits_Affiliates__c;
		textDebug += '\n    NumberOfEmployees: ' + client.NumberOfEmployees;
		textDebug += '\n    Active_Employees_Full_Time__c: ' + client.Active_Employees_Full_Time__c;
		textDebug += '\n    Active_Employees_Part_Time__c: ' + client.Active_Employees_Part_Time__c;
		textDebug += '\n    Active_Employees_All_Affiliates__c: ' + client.Active_Employees_All_Affiliates__c;
		textDebug += '\n    Full_Time_Employees_All_Affiliates__c: ' + client.Full_Time_Employees_All_Affiliates__c;
		textDebug += '\n    Part_Time_Employees_All_Affiliates__c: ' + client.Part_Time_Employees_All_Affiliates__c;
		textDebug += '\n    Benefits_Representative__c: ' + client.Benefits_Representative__c;
		textDebug += '\n    Benefits_Affiliated_Companies__c: \n    ' + client.Benefits_Affiliated_Companies__c;
		textDebug += '\n';

		return textDebug;
	}

	private static String debugOpportunity(Opportunity opp) {
		String textDebug = '  OPPORTUNITY: ' + opp.Name;
		textDebug += '\n    Benefits_Affiliates__c: ' + opp.Benefits_Affiliates__c;
		textDebug += '\n    Active_Employees_All_Affiliates__c: ' + opp.Active_Employees_All_Affiliates__c;
		textDebug += '\n    Full_Time_Employees_All_Affiliates__c: ' + opp.Full_Time_Employees_All_Affiliates__c;
		textDebug += '\n    Part_Time_Employees_All_Affiliates__c: ' + opp.Part_Time_Employees_All_Affiliates__c;
		textDebug += '\n    Benefits_Consultant__c: ' + opp.Benefits_Consultant__c;
		textDebug += '\n    Benefits_Coordinator__c: ' + opp.Benefits_Coordinator__c;
		textDebug += '\n    Benefits_Affiliated_Companies__c: \n    ' + opp.Benefits_Affiliated_Companies__c;
		textDebug += '\n';

		return textDebug;
	}

	private static String debugBenefits(Benefits__c benefits) {
		String textDebug = '  BENEFITS: ' + benefits.Id + '  ' + benefits.Name;
		textDebug += '\n    Benefits_Affiliates__c : ' + benefits.Benefits_Affiliates__c;
		textDebug += '\n    Active_Employees_All_Affiliates__c : ' + benefits.Active_Employees_All_Affiliates__c;
		textDebug += '\n    Full_Time_Employees_All_Affiliates__c : ' + benefits.Full_Time_Employees_All_Affiliates__c;
		textDebug += '\n    Part_Time_Employees_All_Affiliates__c : ' + benefits.Part_Time_Employees_All_Affiliates__c;
		textDebug += '\n    Benefits_Specialist__c : ' + benefits.Benefits_Specialist__c;
		textDebug += '\n    Benefits_Coordinator__c : ' + benefits.Benefits_Coordinator__c;
		textDebug += '\n    Benefits_Affiliated_Companies__c : \n    ' + benefits.Benefits_Affiliated_Companies__c;
		textDebug += '\n';

		return textDebug;
	}

	private static String debugBenefitsAffiliates(Benefits_Affiliates__c ba) {
		String textDebug = ' BENEFITS AFFILIATES: ' + ba.Id + '  ' + ba.Name;
		textDebug += '\n    Benefits_Opportunity__c: ' + ba.Benefits_Opportunity__c;
		textDebug += '\n    Benefits__c: ' + ba.Benefits__c;
		textDebug += '\n    BBSI_Benefits__c: ' + (ba.Benefits__c != null);
		textDebug += '\n    Benefits_Type__c: ' + ba.Benefits_Type__c;
		textDebug += '\n    Active_Employees_All_Affiliates__c: ' + ba.Active_Employees_All_Affiliates__c;
		textDebug += '\n    Full_Time_Employees_All_Affiliates__c: ' + ba.Full_Time_Employees_All_Affiliates__c;
		textDebug += '\n    Part_Time_Employees_All_Affiliates__c: ' + ba.Part_Time_Employees_All_Affiliates__c;
		textDebug += '\n    Benefits_Representative__c: ' + ba.Benefits_Representative__c;
		textDebug += '\n    Benefits_Coordinator__c : ' + ba.Benefits_Coordinator__c;
		textDebug += '\n    Benefits_Affiliated_Companies__c: \n    ' + ba.Benefits_Affiliated_Companies__c;
		textDebug += '\n';

		return textDebug;
	}
}