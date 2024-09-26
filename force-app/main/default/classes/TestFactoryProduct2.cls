@isTest
public class TestFactoryProduct2 {

	public static Product2 createProduct2(String Name,String description, String productcode,Boolean active) {
        Product2 testproduct = makeProduct2(Name, description,productcode,active);
        insert testproduct;
        return testproduct;
    }
	public static Product2 makeProduct2(String Name,String description, String productcode,Boolean active) {        
        Product2 testproduct = new Product2(
		Name = Name,
		Description = description,
		ProductCode = productcode,
		IsActive = active
		);
            
        
        return testproduct;
    }

 
}