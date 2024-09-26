public with sharing class ErPayrollTaxBuilder {

    private ClientPricingScenario__c m_clientPricingScenario;
    private PricingDataModel m_pricingModel;
    private List<ERPayrollTax__c> m_erPayrollTaxes;

    public Boolean HasData {
        get{
            return (m_clientPricingScenario != null && m_pricingModel != null);
        }
    }

    public ErPayrollTaxBuilder(ClientPricingScenario__c ClientPricingScenario, PricingDataModel PricingModel) {

        If(ClientPricingScenario != null && PricingModel != null) {

            try {

                m_clientPricingScenario = ClientPricingScenario;
                m_pricingModel = PricingModel;
                m_erPayrollTaxes = new List<ERPayrollTax__c>(); 
            
            } catch (System.Exception e) {
                System.debug(e.getMessage());
				throw new RenewalException('Employer tax table encountered an unexpected error');
            }
        } else {
            system.debug('ErPayrollTaxBuilder not initialized: ClientPricingScenario ' + ClientPricingScenario + ', PricingModel ' + PricingModel);
        }
    }

    public List<ERPayrollTax__c> GetResult()
    {
        ERPayrollTax__c prTaxItem;

        for(ER_Payroll_Tax_Master__c taxMasterItem : m_pricingModel.PayrollTaxTable) {
            prTaxItem = new ERPayrollTax__c();

            prTaxItem.ClientPricingScenario__c = m_clientPricingScenario.Id;
            prTaxItem.Limit__c = taxMasterItem.Limit__c;
            prTaxItem.Rate__c = taxMasterItem.Rate__c;
            prTaxItem.State_Code__c = taxMasterItem.State_Code__c;
            prTaxItem.Tax_Type__c = taxMasterItem.Tax_Type__c;
            prTaxItem.Default_Rate__c = taxMasterItem.Rate__c;

            m_erPayrollTaxes.add(prTaxItem);
        }

        Database.SaveResult[] srList = Database.insert(m_erPayrollTaxes, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }

        return m_erPayrollTaxes;
    }
}