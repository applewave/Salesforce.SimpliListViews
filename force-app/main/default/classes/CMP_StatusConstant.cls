/****************************************************************************************
    * File Name    : CMP_StatusConstant
    * Author       : HoanPV4
    * Date         : 2023-10-16
    * Description  : Definition status constant
    * Copyright (c) 2023. LG CNS, All Rights Reserved.
    * Modification Log
    * ===============================================================
    * Ver      Date                Author              Modification
    * ===============================================================
    1.0        2023-10-16          HoanPV4            Create        

****************************************************************************************/
public with sharing class CMP_StatusConstant {

    /** The request was fulfilled */
    public static final Integer OK = 200;

    /** Permission denied */
    public static final Integer PERMISSION_DENIED = 403;

    /** Not found records, page, url, etc.. */
    public static final Integer NOT_FOUND = 404;

     /** The server has encountered a situation it does not know how to handle. */
    public static final Integer INTERNAL_SERVER_ERROR = 500;
}