@isTest
private class MarginModel_Deserialize_Test {
	
	@isTest static void test_method_one() {

		String json = getJSON();

		MarginModel_Deserialize obj = MarginModel_Deserialize.parse(json);

		Assert.isTrue(obj != null);
        Assert.areEqual(obj.BILLINGADJUSTMENTS.CLIENTID, '905384');
        Assert.areEqual(obj.BILLINGADJUSTMENTS.DataList.size(), 5);
	}
	
	private static String getJSON() {
		return '' + 
		'{' + 
		'  "BILLINGADJUSTMENTS": {' + 
		'    "CLIENTID": "905384",' + 
		'    "DATALIST": [' + 
		'      {' + 
		'        "STARTDATE": "2016-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-07 00:00:00.0",' + 
		'        "BILLINGADJUSTMENTS": -225' + 
		'      },' + 
		'      {' + 
		'        "STARTDATE": "2017-06-15 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-15 00:00:00.0",' + 
		'        "BILLINGADJUSTMENTS": 0' + 
		'      },' + 
		'      {' + 
		'        "STARTDATE": "1999-12-31 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-14 00:00:00.0",' + 
		'        "BILLINGADJUSTMENTS": -225' + 
		'      },' + 
		'      {' + 
		'        "STARTDATE": "2015-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2016-06-07 00:00:00.0",' + 
		'        "BILLINGADJUSTMENTS": 0' + 
		'      },' + 
		'      {' + 
		'        "STARTDATE": "2014-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2015-06-07 00:00:00.0",' + 
		'        "BILLINGADJUSTMENTS": 0' + 
		'      }' + 
		'    ]' + 
		'  },' + 
		'  "DIRECTEXPENSES": {' + 
		'    "CLIENTID": "905384",' + 
		'    "DIRECTEXPENSES": [' + 
		'      {' + 
		'        "STARTDATE": "2016-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-07 00:00:00.0",' + 
		'        "COMMISSIONAMT": 5839.91,' + 
		'        "PERCENTOFWCBYPAYROLL": 0.1,' + 
		'        "PERCENTOFPAYROLL": 0,' + 
		'        "PERCENTOFWC": 0,' + 
		'        "CESPRPER": 0,' + 
		'        "MARGINPERCENT": 0,' + 
		'        "COMMENTS": "added 12/10/2015"' + 
		'      },' + 
		'      {' + 
		'        "STARTDATE": "2017-06-15 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-15 00:00:00.0",' + 
		'        "COMMISSIONAMT": 0,' + 
		'        "PERCENTOFWCBYPAYROLL": 0,' + 
		'        "PERCENTOFPAYROLL": 0,' + 
		'        "PERCENTOFWC": 0,' + 
		'        "CESPRPER": 0,' + 
		'        "MARGINPERCENT": 0' + 
		'      },' + 
		'      {' + 
		'        "STARTDATE": "1999-12-31 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-14 00:00:00.0",' + 
		'        "COMMISSIONAMT": 7740.5,' + 
		'        "PERCENTOFWCBYPAYROLL": 0.1,' + 
		'        "PERCENTOFPAYROLL": 0,' + 
		'        "PERCENTOFWC": 0,' + 
		'        "CESPRPER": 0,' + 
		'        "MARGINPERCENT": 0,' + 
		'        "COMMENTS": "added 12/10/2015"' + 
		'      },' + 
		'      {' + 
		'        "STARTDATE": "2015-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2016-06-07 00:00:00.0",' + 
		'        "COMMISSIONAMT": 1900.59,' + 
		'        "PERCENTOFWCBYPAYROLL": 0.1,' + 
		'        "PERCENTOFPAYROLL": 0,' + 
		'        "PERCENTOFWC": 0,' + 
		'        "CESPRPER": 0,' + 
		'        "MARGINPERCENT": 0,' + 
		'        "COMMENTS": "added 12/10/2015"' + 
		'      },' + 
		'      {' + 
		'        "STARTDATE": "2014-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2015-06-07 00:00:00.0",' + 
		'        "COMMISSIONAMT": 0,' + 
		'        "PERCENTOFWCBYPAYROLL": 0,' + 
		'        "PERCENTOFPAYROLL": 0,' + 
		'        "PERCENTOFWC": 0,' + 
		'        "CESPRPER": 0,' + 
		'        "MARGINPERCENT": 0' + 
		'      }' + 
		'    ]' + 
		'  },' + 
		'  "MARGINDATA": {' + 
		'    "CLIENTID": "905384",' + 
		'    "DATALIST": [' + 
		'      {' + 
		'        "StartDate": "2016-06-08 00:00:00.0",' + 
		'        "EndDate": "2017-06-07 00:00:00.0",' + 
		'        "MARGINSUMDATALIST": [' + 
		'          {' + 
		'            "STATE": "OR",' + 
		'            "WCCODE": "1000",' + 
		'            "MARGIN": 1633.32' + 
		'          },' + 
		'          {' + 
		'            "STATE": "OR",' + 
		'            "WCCODE": "4130",' + 
		'            "MARGIN": 6039.01' + 
		'          },' + 
		'          {' + 
		'            "STATE": "OR",' + 
		'            "WCCODE": "5102",' + 
		'            "MARGIN": 5055.82' + 
		'          },' + 
		'          {' + 
		'            "STATE": "OR",' + 
		'            "WCCODE": "5462",' + 
		'            "MARGIN": 21074.44' + 
		'          },' + 
		'          {' + 
		'            "STATE": "OR",' + 
		'            "WCCODE": "8380",' + 
		'            "MARGIN": 5980.5' + 
		'          },' + 
		'          {' + 
		'            "STATE": "OR",' + 
		'            "WCCODE": "8742",' + 
		'            "MARGIN": 512.48' + 
		'          },' + 
		'          {' + 
		'            "STATE": "OR",' + 
		'            "WCCODE": "8810",' + 
		'            "MARGIN": 1147.94' + 
		'          }' + 
		'        ]' + 
		'      },' + 
		'      {' + 
		'        "StartDate": "2017-06-15 00:00:00.0",' + 
		'        "EndDate": "2017-06-15 00:00:00.0",' + 
		'        "MARGINSUMDATALIST": [' + 
		'          {' + 
		'            "STATE": "none",' + 
		'            "WCCODE": "none",' + 
		'            "MARGIN": 0' + 
		'          }' + 
		'        ]' + 
		'      },' + 
		'      {' + 
		'        "StartDate": "1999-12-31 00:00:00.0",' + 
		'        "EndDate": "2017-06-14 00:00:00.0",  ' + 
		'        "MARGINSUMDATALIST": [               ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "1000",                ' + 
		'            "MARGIN": 1664.11                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "4130",                ' + 
		'            "MARGIN": 8038.65                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "5102",                ' + 
		'            "MARGIN": 6774.69                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "5462",                ' + 
		'            "MARGIN": 26939.4                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "8380",                ' + 
		'            "MARGIN": 7878.32                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "8742",                ' + 
		'            "MARGIN": 673.01                 ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "8810",                ' + 
		'            "MARGIN": 1538.42                ' + 
		'          }                                  ' + 
		'        ]                                    ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "StartDate": "2015-06-08 00:00:00.0",' + 
		'        "EndDate": "2016-06-07 00:00:00.0",  ' + 
		'        "MARGINSUMDATALIST": [               ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "1000",                ' + 
		'            "MARGIN": 30.79                  ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "4130",                ' + 
		'            "MARGIN": 1999.64                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "5102",                ' + 
		'            "MARGIN": 1718.87                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "5462",                ' + 
		'            "MARGIN": 5864.96                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "8380",                ' + 
		'            "MARGIN": 1897.82                ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "8742",                ' + 
		'            "MARGIN": 160.53                 ' + 
		'          },                                 ' + 
		'          {                                  ' + 
		'            "STATE": "OR",                   ' + 
		'            "WCCODE": "8810",                ' + 
		'            "MARGIN": 390.48                 ' + 
		'          }                                  ' + 
		'        ]                                    ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "StartDate": "2014-06-08 00:00:00.0",' + 
		'        "EndDate": "2015-06-07 00:00:00.0",' + 
		'        "MARGINSUMDATALIST": [' + 
		'          {' + 
		'            "STATE": "none",' + 
		'            "WCCODE": "none",' + 
		'            "MARGIN": 0' + 
		'          }' + 
		'        ]' + 
		'      }' + 
		'    ]' + 
		'  },' + 
		'  "TURNOVER": {' + 
		'    "CLIENTID": "905384",' + 
		'    "DATALIST": [' + 
		'      {' + 
		'        "STARTDATE": "2016-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-07 00:00:00.0",  ' + 
		'        "EEANNUAL": 58,                      ' + 
		'        "EECURRENT": 40                      ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2016-06-16 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-15 00:00:00.0",  ' + 
		'        "EEANNUAL": 58,                      ' + 
		'        "EECURRENT": 40                      ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2016-06-15 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-14 00:00:00.0",  ' + 
		'        "EEANNUAL": 58,                      ' + 
		'        "EECURRENT": 40                      ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2015-06-09 00:00:00.0",' + 
		'        "ENDDATE": "2016-06-07 00:00:00.0",  ' + 
		'        "EEANNUAL": 45,                      ' + 
		'        "EECURRENT": 40                      ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2014-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2015-06-07 00:00:00.0",  ' + 
		'        "EEANNUAL": 0,                       ' + 
		'        "EECURRENT": 0                       ' + 
		'      }                                      ' + 
		'    ]                                        ' + 
		'  },                                         ' + 
		'  "SECONDARYSERVICES": {                     ' + 
		'    "CLIENTID": "905384",                    ' + 
		'    "DATALIST": [                            ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2016-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-07 00:00:00.0",  ' + 
		'        "SECONDARYSERVICES": -31             ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2017-06-15 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-15 00:00:00.0",  ' + 
		'        "SECONDARYSERVICES": 0               ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "1999-12-31 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-14 00:00:00.0",  ' + 
		'        "SECONDARYSERVICES": -31             ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2015-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2016-06-07 00:00:00.0",  ' + 
		'        "SECONDARYSERVICES": 0               ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2014-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2015-06-07 00:00:00.0",  ' + 
		'        "SECONDARYSERVICES": 0               ' + 
		'      }                                      ' + 
		'    ]                                        ' + 
		'  },                                         ' + 
		'  "TAXBURDEN": {                             ' + 
		'    "CLIENTID": "905384",                    ' + 
		'    "DATALIST": [                            ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2016-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-07 00:00:00.0",  ' + 
		'        "TotalPayroll": 1521838.91,          ' + 
		'        "TotalTaxes": 155894.79,             ' + 
		'        "TotalPayrollNo1000": 1398931.26,    ' + 
		'        "TotalTaxesNo1000": 144254.1         ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2017-06-15 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-15 00:00:00.0",  ' + 
		'        "TotalPayroll": 0,                   ' + 
		'        "TotalTaxes": 0,                     ' + 
		'        "TotalPayrollNo1000": 0,             ' + 
		'        "TotalTaxesNo1000": 0                ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "1999-12-31 00:00:00.0",' + 
		'        "ENDDATE": "2017-06-14 00:00:00.0",  ' + 
		'        "TotalPayroll": 2045806.12,          ' + 
		'        "TotalTaxes": 212709.66,             ' + 
		'        "TotalPayrollNo1000": 1876211.24,    ' + 
		'        "TotalTaxesNo1000": 196057.53        ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2015-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2016-06-07 00:00:00.0",  ' + 
		'        "TotalPayroll": 523967.21,           ' + 
		'        "TotalTaxes": 56814.87,              ' + 
		'        "TotalPayrollNo1000": 477279.98,     ' + 
		'        "TotalTaxesNo1000": 51803.43         ' + 
		'      },                                     ' + 
		'      {                                      ' + 
		'        "STARTDATE": "2014-06-08 00:00:00.0",' + 
		'        "ENDDATE": "2015-06-07 00:00:00.0",' + 
		'        "TotalPayroll": 0,' + 
		'        "TotalTaxes": 0,' + 
		'        "TotalPayrollNo1000": 0,' + 
		'        "TotalTaxesNo1000": 0' + 
		'      }' + 
		'    ]' + 
		'  },' + 
		'  "BDM": {' + 
		'    "CLIENT": "905384",' + 
		'    "HASBDM": "FALSE",' + 
		'    "BDMNAME": " "' + 
		'  }' + 
		'}';
	}

}