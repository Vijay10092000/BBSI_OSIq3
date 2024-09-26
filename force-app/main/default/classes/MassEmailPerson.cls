/**
 * @description MassEmailPerson handles data about a person for
 * the MassEmail component.
 */
@SuppressWarnings('PMD.ApexDoc, PMD.ExcessivePublicCount')
public without sharing class MassEmailPerson {
	@AuraEnabled
	public Boolean allowSend { get; set; }

	@AuraEnabled
	public String identifier { get; set; }

	@AuraEnabled
	public String idAccount { get; set; }

	@AuraEnabled
	public String nameAccount { get; set; }

	@AuraEnabled
	public String idPerson { get; set; }

	@AuraEnabled
	public String typePerson { get; set; }

	@AuraEnabled
	public String namePerson { get; set; }

	@AuraEnabled
	public String emailPerson { get; set; }

	@AuraEnabled
	public String idOwner { get; set; }

	@AuraEnabled
	public String nameOwner { get; set; }

	@AuraEnabled
	public String emailOwner { get; set; }

	@AuraEnabled
	public String idBenefitsRep { get; set; }

	@AuraEnabled
	public String nameBenefitsRep { get; set; }

	@AuraEnabled
	public String emailBenefitsRep { get; set; }

	@AuraEnabled
	public String emailSubject { get; set; }

	@AuraEnabled
	public String emailBody { get; set; }

	@AuraEnabled
	public String status { get; set; }

	/**
	 * @description DataPerson constructor.
	 */
	public MassEmailPerson() {
		allowSend = false;
	}

	/**
	 * @description DataPerson constructor.
	 * @param  identifier        Temp identifier
	 * @param  idAccount         Identifier of the Client Account
	 * @param  nameAccount       Name of the Client Account
	 * @param  idPerson          Identifier of the Contact or Lead
	 * @param  typePerson        Contact or Lead
	 * @param  namePerson        Name of the Contact or Lead
	 * @param  emailPerson       Email for the Contact or Lead
	 * @param  nameOwner         Owner name of the Client Account if Contact otherwise Lead Owner
	 * @param  emailOwner        Owner email of the Client Account if Contact otherwise Lead Owner
	 * @param  nameBenefitsRep   Owner name of the Benefits Representatie of Account
	 * @param  emailBenefitsRep  Owner email of the Benefits Representatie of Account
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public MassEmailPerson(
		String identifier,
		Id idAccount,
		String nameAccount,
		Id idPerson,
		String typePerson,
		String namePerson,
		String emailPerson,
		String idOwner,
		String nameOwner,
		String emailOwner,
		String idBenefitsRep,
		String nameBenefitsRep,
		String emailBenefitsRep
	) {
		this.identifier = identifier;
		this.idAccount = String.valueOf(idAccount);
		this.nameAccount = nameAccount;

		this.idPerson = String.valueOf(idPerson);
		this.typePerson = typePerson;
		this.namePerson = namePerson;
		this.emailPerson = emailPerson;

		this.idOwner = idOwner;
		this.nameOwner = nameOwner;
		this.emailOwner = emailOwner;

		this.idBenefitsRep = idBenefitsRep;
		this.nameBenefitsRep = nameBenefitsRep;
		this.emailBenefitsRep = emailBenefitsRep;

		this.allowSend = (idAccount != null && idPerson != null && !String.isBlank(emailPerson));
	}

	/**
	 * @description isValid determines if the person is OK to receive an email.
	 * @return true if valid
	 */
	public Boolean isValid() {
		if (idAccount == null || String.isBlank(nameAccount)) {
			status = 'Missing Account Information';
			return false;
		}

		if (idPerson == null || String.isBlank(typePerson) || String.isBlank(namePerson) || String.isBlank(emailPerson)) {
			status = 'Missing contact information';
			return false;
		}

		if (idOwner == null || String.isBlank(nameOwner) || String.isBlank(emailOwner)) {
			status = 'Missing owner information';
			return false;
		}

		/*
		if (idBenefitsRep == null || String.isBlank(nameBenefitsRep) || String.isBlank(emailBenefitsRep)) {
			status = 'Missing Benefits Representative information';
			return false;
		}
		*/

		return allowSend;
	}

	/**
	 * @description dump logs the MassEmailPerson.
	 * @param  level  Level to log at
	 */
	public void dump(LoggingLevel level) {
		System.debug(
			level,
			'MassEmailPerson constructor - AllowSend: ' +
			allowSend +
			'\n.. Account: (' +
			idAccount +
			') ' +
			nameAccount +
			'\n.. Person: (' +
			idPerson +
			') ' +
			namePerson +
			'  ' +
			emailPerson +
			'\n.. Owner: (' +
			idOwner +
			') ' +
			nameOwner +
			'  ' +
			emailOwner +
			'\n.. BenefitsRep: (' +
			idBenefitsRep +
			') ' +
			nameBenefitsRep +
			'  ' +
			emailBenefitsRep
		);
	}
}