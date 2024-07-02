/****************************************************************************************
 * File Name    : cmp_SlickGridHelper
 * Author       : sy.lee
 * Date         : 2024-06-24
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-06-24 	sy.lee			    Create

 ****************************************************************************************/
import sf_slickGrid_bundle from '@salesforce/resourceUrl/CMP_slickgrid';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

// declare variables for all types, this will allow us to use `Formatters.bold` instead of `Slicker.Formatters.bold`
// all Wikis are written without the `Slicker` namespace, so doing this approach is better
export let Aggregators = {};
export let BindingService = {};
export let Editors = {};
export let Enums = {};
export let Filters = {};
export let Formatters = {};
export let GroupTotalFormatters = {};
export let SortComparers = {};
export let Utilities = {};
export let GridBundle = {};

/** Load all necessary SlickGrid resources (css/scripts) */
export async function loadResources(component) {
    try{
        await loadStyle(component, `${sf_slickGrid_bundle}/styles/css/slickgrid-theme-salesforce.css`);
        await loadScript(component, `${sf_slickGrid_bundle}/slickgrid-vanilla-bundle.js`);
        Aggregators = Slicker.Aggregators;
        BindingService = Slicker.BindingService;
        Editors = Slicker.Editors;
        Enums = Slicker.Enums;
        Filters = Slicker.Filters;
        Formatters = Slicker.Formatters;
        GroupTotalFormatters = Slicker.GroupTotalFormatters;
        SortComparers = Slicker.SortComparers;
        Utilities = Slicker.Utilities;
        GridBundle = Slicker.GridBundle;
    }catch(e){
        console.log(e.stack);
    }
}