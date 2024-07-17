<!---
  Suite         : PDIO
  Purpose       : PLANE IMPROVEMENT

  Version    Developer    		Date            Remarks
  2.0.00     Harris         	1/05/2019     	1. ADD PROD DELOVERY DATE FROM AND TO 
  2.1.00     Syafiq         	31/10/2023   	1. FIX ERRORS TO ADD DATAGRID PAGING OPTIONS [10, 25, 50, 100]
  2.2.00     Syahmi             24/04/2024      1. ADD CHANGE DELIVERY POINT FOR LOCAL PART P
--->
<cfsetting showdebugoutput="yes">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
 
<cfinclude template="../../../includes/file_access_validation.cfm" > 
<cfinclude template="../../../includes/basic_includes.cfm" > 

 
<!---kanban printer type setting ---->
<cfif parameterExists(session.kanban_printer_type) EQ FALSE >  
	<cfset session.kanban_printer_type = "NORMAL" >
<cfelseif session.kanban_printer_type NEQ "NORMAL" AND session.kanban_printer_type NEQ "SPECIAL" >
	<cfset session.kanban_printer_type = "NORMAL" >
</cfif>

<script language="javascript">
	var kanban_printer_type = '<cfoutput>#session.kanban_printer_type#</cfoutput>';
</script>  
<script language="javascript" src="view_pdio.js"></script>



<cfinvoke component="#component_path#.organization" method="retrieveOrganizations" dsn="#dsscmfw#" returnvariable="registeredOrg" ></cfinvoke> 
<cfinvoke component="#component_path#.shop" method="retrieveShops" dsn="#dswms#" returnvariable="registeredShop" ></cfinvoke>
<cfinvoke component="#component_path#.line_shop" method="retrieveLineShops" dsn="#dswms#" returnvariable="registeredLineShop" ></cfinvoke>
<cfinvoke component="#component_path#.dock" method="retrieveDocks" dsn="#dswms#" returnvariable="registeredDock" ></cfinvoke>
<cfinvoke component="#component_path#.order_type" method="retrieveOrderTypes" dsn="#dswms#" returnvariable="registeredOrderType" ></cfinvoke>
<cfinvoke component="#component_path#.delivery_type" method="retrieveDeliveryTypes" dsn="#dswms#" returnvariable="registeredDeliveryType" ></cfinvoke>

<!---- get approval access ----->
<cfquery name="getApprovalAccess" datasource="#dsscmfw#" >
SELECT CASE WHEN status = 0 THEN 'N' ELSE 'Y' END status FROM (
    SELECT COUNT(c.aclapprove) status 
    FROM frm_user_groups a, frm_acl_main_group_details b, frm_acl_groups c, frm_config_email d
    WHERE a.user_code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.user_code#" >
    AND a.group_id = b.main_group_header_id
    AND b.subgroup_id = c.group_id
    AND c.function_id = d.parent_function_id
    AND d.type = 'PDIO'
    AND c.aclapprove = 'Y' 
    AND a.active_date <= sysdate AND NVL(a.inactive_date, sysdate + 1) > sysdate 
)
</cfquery>
<!------------------------------->
<!---ADDED BY SYAHMI HANAFIAH 12_06_24(START)--->
<cfquery name="getGenwhouse" datasource="#dswms#">
	SELECT A.VENDOR_ID, VENDOR_NAME FROM WMS.GEN_WHOUSE A, FRM_VENDORS B
	WHERE A.VENDOR_ID = B.VENDOR_ID
	AND A.STATUS = 'ACTIVE'
	AND b.active_date <= sysdate AND NVL(b.inactive_date,sysdate+1) > sysdate
	ORDER BY VENDOR_NAME ASC
</cfquery>

<!---ADDED BY SYAHMI HANAFIAH 12_06_24(END)--->
 
 <style type="text/css">
 	
	/*
	.greenBG {
		background-color:#39FC01;
		color:#145B00;
		font-weight:bold;
	}
	.redBG {
		background-color:#FE0134;
		color:#FFC1C8;
		font-weight:bold;
	}	
	.blueBG {
		background-color:#09F;
		color:#CCE6FF;
		font-weight:bold;
	}
	.yellowBG {
		background-color:#FF0;
		color:#000;
		font-weight:bold;
	}
	*/

 	.greenBG { 
		color:#009124;
		font-weight:bold;
	}
	.redBG { 
		color:#E10000;
		font-weight:bold;
	}	
	.blueBG { 
		color:#0053A6;
		font-weight:bold;
	}
	.yellowBG { 
		color:#909090;
		font-weight:bold;
	}

	.data-table {
  width: 100%;
  border-collapse: collapse;
}

 .data-table td .data-table tr {
	height:30px;
  	border: 1px solid #ddd;
}

.data-table tr:nth-child(even) {
  background-color: #F4F4F4;
}
.data-table th {
  background-color: #000000;
  max-height: 10px;
  height:20px;
  padding:6px;
  color: white;

}

.sticky-header {
  position: sticky;
  top: 0;
  background-color: #f5f5f5; /* Set the background color for the sticky headers */
  z-index: 1;
}
.centered-cell {
  text-align: center;
}
#addPanel .jqx-window-content {
  height: 100%;
  overflow-y: auto;
}
#changeDlvryPoint th,
#changeDlvryPoint tr,{
  	border: 1px solid black;

}
tr.dotted-line-row td {
  border-bottom: 2px dashed #000;
}
tr.dotted-line-row td#changeDlvryPoint {
  padding: 10px;
}
  #changeDlvryPoint {
    width: 100%;
    border-collapse: collapse;
  }
  
  #changeDlvryPoint th,
  #changeDlvryPoint td {
    border: 1px solid black;
    padding: 8px;
  }
 
  .container {
    display: flex;
    align-items: center;
    /*justify-content: space-between; */	
  }

  .formStyle {
    margin-right: 10px; /* Add space to the right of the select element */
  }
 </style>
    
</head>	 
<body background="../../../includes/images/bground1.png">  
	
	<div id="content">
		<div class="screen_header">LSP > PDIO Manager > View PDIO </div>  
	</div>  
	
	<br><br><br>  
	<div style="width:99%; margin:auto">  
			<div id='UIPanel'> 
				<div>Search Parameters</div>  
				<div>   
					<cfoutput>
						<form name="searchForm">
                        	<input type="hidden" value="#session.user_category#" id="user_category" >
                            <input type="hidden" value="#getApprovalAccess.status#" id="approvalAccess" >
							<table width="100%" cellpadding="4" class="formStyle" cellspacing="0" >
								<tr><td height="5"></td></tr>
                                
                                <tr>
									<td align="right" width="20%">PDIO Number : </td>
									<td align="left" width="25%">
										<input type="text" class="formStyle" id="pdio_number" size="20px">
									</td>  
                                    
                                    <td align="right" width="25%">Production Date : </td>
									<td align="left" width="30%">
										<div id='proddate_date_picker'></div>
										<input type="hidden" id="prod_date"> 
									</td>  
                                    
								</tr>
                                <tr>  
									<td align="right">Vendor Name : </td>
									<td align="left">
                                    
                                    	<cfset curr_vendor_id = "" >
                                        <cfset curr_vendor_name = "" >
                                        <cfset curr_vendor_cat = "" >
                                    	<cfif session.user_category EQ 2 >
                                            <cfquery name="getVendorInfo" datasource="#dswms#" >
                                                SELECT vendor_name, vendor_type
                                                FROM frm_vendors 
                                                WHERE vendor_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.vendor_id#" >
                                            </cfquery> 
                                            <cfset curr_vendor_id = session.vendor_id >
                                        	<cfset curr_vendor_name = getVendorInfo.vendor_name >
                                        	<cfset curr_vendor_cat = getVendorInfo.vendor_type >
                                        </cfif> 
                                    
                                    
										<div style="float:left">
											<input name="vendor_id" type="hidden" id="vendor_id" value="#curr_vendor_id#" >
											<input name="vendor_cat" type="hidden" id="vendor_cat" value="#curr_vendor_cat#" >
											<input type="text" id="vendor_name" name="vendor_name" 
                                            <cfif session.user_category EQ 2 > class="formStyleReadOnly" readOnly <cfelse> class="formStyle" </cfif> 
                                            size="33" onChange="clearNeccessaryHiddenFields(this.id,'vendor_id');" value="#curr_vendor_name#" >
										</div>
                                        <cfif session.user_category EQ 1 >
                                            <div style="float:left"> <img src="../../../includes/images/open_filter.png" style="cursor:pointer;" 
                                            id="lookupVendorBtn" class="tips"> </div>
                                        </cfif> 
                                         
                                        
									</td> 
									<td align="right">TPL Name : </td>
									<td align="left">
										<div style="float:left">
											<input name="tpl_id" type="hidden" id="tpl_id">
											<input type="text" id="tpl_name" name="tpl_name" class="formStyle" size="33" onChange="clearNeccessaryHiddenFields(this.id,'tpl_id');" >
										</div>
										<div style="float:left"> <img src="../../../includes/images/open_filter.png" style="cursor:pointer;" id="lookupTPLBtn"> </div> 
									</td> 
								</tr>   
                                <tr> 
									<td align="right">Order Type : </td>
									<td align="left">
									
                                        <!--- PLANE PMSB Project --->
                                        <div id="getOrderType" style="display: inline-block;">
                                			    <select name="order_type_id" id="order_type_id" class="formStyle tips" size="20px" disabled>
                                                     <option value="">-- Please Select --</option>
                                                </select>
                             			</div>
									</td> 
									<td align="right">Delivery Type : </td>
									<td align="left">
						
                                        <!--- PLANE PMSB Project --->
                                        <div id="getDeliveryType" style="display: inline-block;">
                                            <select name="delivery_type_id" id="delivery_type_id" disabled class="formStyle">
                                                 <option value="">-- Please Select --</option>
                                            </select>
                                        </div>  
									</td>
								</tr>
                                <tr> 
									<td align="right">Vendor Type : </td>
									<td align="left">
										<select name="vendor_type" id="vendor_type" class="formStyle">
											 <option value="">-- All --</option> 
                                             <option value="1">1st Tier</option> 
                                             <option value="2">2nd Tier</option> 
										</select> 
									</td>
                                    <td align="right">Delivery Category : </td>
									<td align="left">
                                    	<input type="text" class="formStyle tips" id="delivery_category" name="delivery_category" size="10"> 
									</td>  
								</tr>
								<tr>
									<td align="right">Organization : </td>
									<td align="left" >
										<cfif registeredOrg.recordCount LT 2 > 
											 <input type="hidden" name="org_id" id="org_id" class="formStyle" value="#registeredOrg.org_id#">
											 <input type="text" name="org_description" id="org_description" class="formStyleReadOnly" value="#registeredOrg.org_description#" 
											 size="40" readonly> 
										<cfelse>
											<select name="org_id" id="org_id" class="formStyle tips">
											<option value="">-- All --</option> 
												<cfloop query="registeredOrg">
													<option value="#org_id#">#org_description#</option>
												</cfloop>
											</select> 
										</cfif> 
									</td> 
									<td align="right">Shop : </td>
									<td align="left">
										
                                        <!--- PLANE PMSB Project --->
                                        <div id="displayShopID" style="display: inline-block;" class="tips">
                                                <select id="shop_id" name="shop_id" class="formStyle tips" disabled="disabled">
                                                    <option value="">-- Please Select --</option> 
                                                </select> 
                                        </div>
									</td> 
								</tr> 
								<tr> 
									<td align="right">Line Shop : </td>
									<td align="left">
				
                                        <div id="displayLineShopID" style="display: inline-block;" class="tips">
                                                    <select id="line_shop_id" name="line_shop_id" class="formStyle tips" disabled="disabled">
                                                        <option value="">-- Please Select --</option> 
                                                    </select> 
                                        </div>
									</td> 
									<td align="right">Dock : </td>
									<td align="left">
							
                                        <div id="displayDock" style="display: inline-block;">
                                                <select id="dock_code" name="dock_code" class="formStyle" disabled="disabled">
                                                    <option value="">-- Please Select --</option> 
                                                </select> 
                                        </div> 
									</td>
								</tr>
                                <tr> 
									<td align="right">Lane Number : </td>
									<td align="left">
										<select name="lane_no" id="lane_no" class="formStyle">
											 <option value="">-- All --</option>
											 <cfloop from="1" to="24" index="laneno">
												<option value="#laneno#">#laneno#</option>
											</cfloop> 
										</select> 
									</td> 
									<td align="right">Status : </td>
									<td align="left">
										<select name="status" id="status" class="formStyle">
											 <option value="">-- All --</option> 
                                             <cfif session.user_category EQ 1 >
                                             <option value="PENDING">PENDING</option> 
                                             </cfif>
                                             <option value="APPROVED">APPROVED</option> 
                                             <option value="ACKNOWLEDGED">ACKNOWLEDGED</option>  
										</select> 
									</td>  
								</tr> 
                                <tr>
                                	<td align="right">Kanban Printer Type :</td>
                                    <td>
                                    	<select id="kanban_printer_type" name="kanban_printer_type" class="formStyle"
                                        onChange="update_kanban_printer_type(this.value);" >
                                        	<option <cfif session.kanban_printer_type EQ "NORMAL" > selected </cfif> value="NORMAL">Normal</option> 
                                        	<option <cfif session.kanban_printer_type EQ "SPECIAL" > selected </cfif> value="SPECIAL">Special</option>
                                        	<option <cfif session.kanban_printer_type EQ "OLD" > selected </cfif> value="OLD">Old</option>
                                        </select>
                                    </td>
                                    <td align="right">Cycle :</td>
                                    <td>
                                    	<select name="cycle" id="cycle" class="formStyle">
											 <option value="">-- All --</option> 
                                             <cfloop index ="cycle" from = "1" to = "10">
                                             <option value="#cycle#">#cycle#</option> 
                                             </cfloop>
										</select> 	
                                    </td>
                                </tr>
                                
                                <tr>
                                	<td align="right">Prod Delivery Date From</td>
                                    <td><div id="prod_delivery_date_from" class="tips" val="" ></div></td>
                                    
                                    <td align="right">Prod Delivery Date To</td>
                                    <td><div id="prod_delivery_date_to" class="tips" val="" ></div></td>
                                </tr>
								<!---ADDED BY SYAHMI HANAFIAH || 12_06_2024 --->
								<tr>
									<td align="right">Warehouse : </td>
									<td>
										<select name="warehouse_id" id="warehouse_id" class="formStyle">
											<option value="" selected>-- Please Select --</option>
												<cfloop query="getGenwhouse">													
													<option value="#vendor_id#">#vendor_name#</option>
												</cfloop>
										</select>
									</td>
								</tr>
								<!---ADDED BY SYAHMI HANAFIAH || 12_06_2024 --->
                                <tr><td><input type="hidden" id="globalArray"></td></tr>
                                <tr><td>
                                <input type='hidden' id='isButtonAppend' name='isButtonAppend' value="false" />
								</td></tr>

                                <tr><td height="5"></td></tr>
								<tr> 
									<td colspan="4" align="right" bgcolor="F5F5F5" style="padding:8px"> 
									    <input class="button white" type="button" id="searchBtn" value="Search"/> <!--- Modified by Syafiq | 31/10/2023 | V2.1.00 | Incident: 2310/20635 --->
										<input class="button white" type="button" id="view_report" value="View Report" />
										<input class="button white" type="button" value="Reset" onClick="window.location.href=self.location" />
									</td>
								</tr>
							</table>
						</form> 
					</cfoutput>
				</div> 
			</div>
			<br>
			<div id="datagrid" ></div>  
	</div>
	
  
 	<div id="lookupVendorWindow" style="display:none">
         <div class="lookupHeader" style="background-image:url(../../../includes/images/lookupheader.png); ">
			 <div style="float:left">Vendor List</div>
			 <div id="lookupVendorProgress" style="float:left; margin:2px 0px 0px 5px"><img src="../../../includes/images/progress_green_small.gif" /></div>
		 </div>
         <div style="padding:0px;"> 
		 <iframe class="lookupFrame" id="lookupVendorContent" frameborder="0" scrolling="auto" ></iframe>
		 </div>
    </div>
	
	<div id="lookupTPLWindow" style="display:none">
         <div class="lookupHeader" style="background-image:url(../../../includes/images/lookupheader.png); ">
			 <div style="float:left">Vendor List</div>
			 <div id="lookupTPLProgress" style="float:left; margin:2px 0px 0px 5px"><img src="../../../includes/images/progress_green_small.gif" /></div>
		 </div>
         <div style="padding:0px;"> 
		 <iframe class="lookupFrame" id="lookupTPLContent" frameborder="0" scrolling="auto" ></iframe>
		 </div>
    </div>
 	<input type="hidden" name="pdio_to_approve_list" id="pdio_to_approve_list" >
    <input type="hidden" name="pdio_to_delete_list" id="pdio_to_delete_list" >
	<div id="confirmApproveWindow" style="display:none;">
        <div style="line-height:12px;"> 
			<div style="float:left"><img src="../../../includes/images/approve_small.png" /></div>
			<div id="winTitle1" style="float:left; font-weight:bold; font-size:11px; margin-top:5px;">Approve PDIO</div>
        </div>
        <div style="overflow: hidden; padding:0px" id="windowContent1"> 
         
			 <table width="100%" height="100%" class="formStyle" cellpadding="4" cellspacing="0" style="font-size:11px;"> 
                <tr>
                	<td align="left" valign="top" rowspan="2"><img src="../../../includes/images/questionmark.png" style="margin:4px 2px 0 2px; " /></td>
                	<td align="left" valign="middle" id="approveMsg" height="20">  
                    </td>
                </tr> 
                <tr>
                	<td valign="top">Are you sure you want to approve the selected PDIO?</td>
                </tr>
                <tr bgcolor="#f8f8f8">
                	<td align="right" valign="middle" colspan="2" > 
                    <input type="button" value="Yes" id="approveAllBtn" class="button white" >
                    <input type="button" value="No" id="cancelApproveBtn" class="button white" style="margin-right:7px;" >
                	</td>
                </tr>
            </table> 
		</div>
	</div>
    
    <div id="confirmDeleteWindow" style="display:none;">
        <div style="line-height:12px;">   
			<div style="float:left"><img src="../../../includes/images/dustbin_small.png" /></div>
			<div id="winTitle2" style="float:left; font-weight:bold; font-size:11px; margin-top:5px;">Delete PDIO</div>
        </div>
        <div style="overflow: hidden; padding:0px" id="windowContent2"> 
			 <table width="100%" height="100%" class="formStyle" cellpadding="4" cellspacing="0" style="font-size:11px;"> 
                <tr>
                	<td align="left" valign="top" rowspan="2"><img src="../../../includes/images/questionmark.png" style="margin:4px 2px 0 2px; " /></td>
                	<td align="left" valign="middle" id="deleteMsg"  height="20">  
                    </td>
                </tr> 
                <tr>
                	<td valign="top">Are you sure you want to delete the selected PDIO?</td>
                </tr>
                <tr bgcolor="#f8f8f8">
                	<td align="right" valign="middle" colspan="2" > 
                    <input type="button" value="Yes" id="deleteAllBtn" class="button white" >
                    <input type="button" value="No" id="cancelDeleteBtn" class="button white" style="margin-right:7px;" >
                	</td>
                </tr>
            </table> 
		</div>
	</div>

    <!-----------------------Add Pop Up Modal for Change Delivery Point--------------------------->    
<div id="addPanel" style="display:none; position:fixed">
        <div style="line-height:12px;">  
			<div style="float:left; font-weight:bold; font-size:11px; margin-top:5px;"><span id="modalTitle"></span> Change Delivery Point</div>
        </div>
        <div style="overflow: hidden; padding:0px; position: relative;" id="windowContent"> 
        <form id="actionForm" name="actionForm" action="bgprocess.cfm" method="post">
             <input type="hidden" name="add_delivery_point" id="add_delivery_point" value="add_delivery_point" >
             <input type="hidden" name="edit_id" id="edit_id" >
			 <table width="100%" height="100%" class="formStyle" id="addDeliveryPointTable" cellpadding="5" cellspacing="0" style="font-size:12px;"> 
             	<tr><td class="dlvryPoint" height="10px"></td></tr>
				 <!---Add New Delivery Point--->
				<tr style="text-align: left;" class="dotted-line-row">
					<td class="dlvryPoint" colspan="2" align="left">
						<div class="container">
							<div>
							  <span>Change Delivery Point:</span>
							  <select name="addDeliveryPoint" id="addDeliveryPoint" class="formStyle">
								<option value="">-- All --</option>
								<option value="PERODUA">PERODUA</option>
								<option value="WAREHOUSE">WAREHOUSE</option>
							  </select>
							</div>
								<div id ="whouse_name" name="whouse_name">
									<span>Warehouse Name: </span>
									<select name="warehouseName" id="warehouseName" class="formStyle">
										<option value="">-- Select Warehouse --</option>
									</select>
								<div>
						  </div>
						
						
					</td>
					<input type="hidden" name="po_header_id" id="po_header_id" >
				</tr>
             	<tr><td class="dlvryPoint" height="7px"></td></tr>

				 <!---Data Table Example --->
 				 <tr>
				 	<td>
					<div style="overflow-y:scroll;height:270px">
						<table width="100%" id="changeDlvryPoint" name="changeDlvryPoint" class="data-table">
						</table>
					</div>
					</td>
				 </tr>                                                                    
                 <tr bgcolor="#f8f8f8" id="button_panel"  style="vertical-align: bottom;  position: absolute; bottom: 0;  right: 0;">
                	<td class="dlvryPoint" align="right" colspan="4" height="25px" > 
                   	 	<input type="button" id="saveEditBtn" class="button white" value="Save" >
                    	<input type="button" id="cancelEditBtn" class="button white"  value="Cancel" >
                	</td>
                </tr>
            </table> 
        </form>    
		</div>
</div> 
</body> 
</html>








