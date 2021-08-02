/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 07-21-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   07-18-2021   tom.h.ansley@medtronic.com   Initial Version
**/
@isTest
global class ListViewAdminControllerTest {

    @testSetup
    static void createSampleData()
    {
        ListViewHelper.insertCoreConfiguration();

        HelperTest.insertAccount('Test Account 1');
    }

    @IsTest
    static void getOrgWideConfigTest()
    {
    
        Test.startTest();
            
            ListViewAbstract.ListViewConfigWrapper config = ListViewAdminController.getOrgWideConfig();

            System.assertEquals('All', config.getObject());
            System.assertEquals('All', config.getName());
            System.assertEquals(14, config.getParameters().size());

        Test.stopTest();
        
    }

    @IsTest
    static void updateOrgWideConfigTest()
    {
    
        Test.startTest();
            
            String allowRefresh = ListViewConfigHelper.getOrgWideConfigParam('AllowAutomaticDataRefresh');
            System.assertEquals('true', allowRefresh);

            String result = ListViewAdminController.saveOrgWideConfig('[["ExcludedObjectTypes",["AIApplication"]],["AllowAutomaticDataRefresh","false"],["DisplayActionsButton","false"]]');
            System.assertEquals('Ok:', result);

            allowRefresh = ListViewConfigHelper.getOrgWideConfigParam('AllowAutomaticDataRefresh');
            System.assertEquals('false', allowRefresh);

        Test.stopTest();
        
    }

    @IsTest
    static void getObjectNamesTest()
    {
    
        Test.startTest();
            
            List<ListViewController.SelectOption> objNames = ListViewAdminController.getObjectNames();

            System.assert(objNames.size() > 0);
            Boolean hasAccount = false;
            for (ListViewController.SelectOption option: objNames)
            {
                if (option.value == 'Account')
                    hasAccount = true;
            }
            System.assertEquals(true, hasAccount);

        Test.stopTest();
        
    }

}