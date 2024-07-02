/****************************************************************************************
    * File Name    : CMP_StatusConstant_test
    * Author       : HoanPV4
    * Date         : 2023-10-16
    * Description  : Unit test for CMP_StatusConstant
    * Copyright (c) 2023. LG CNS, All Rights Reserved.
    * Modification Log
    * ===============================================================
    * Ver      Date                Author              Modification
    * ===============================================================
    1.0        2023-10-16          HoanPV4            Create        

****************************************************************************************/
@IsTest
public  class CMP_StatusConstant_test {
    @IsTest
    static void testGetStatusShouldWork() {
       Test.startTest();
       Integer ok = CMP_StatusConstant.OK;
       Integer permissionDenied = CMP_StatusConstant.PERMISSION_DENIED;
       Integer notFound = CMP_StatusConstant.NOT_FOUND;
       Integer error = CMP_StatusConstant.INTERNAL_SERVER_ERROR;
       Test.stopTest();
    }
}