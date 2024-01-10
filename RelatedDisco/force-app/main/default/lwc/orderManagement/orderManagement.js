import { LightningElement, api, track, wire } from "lwc";
import { getRecord, updateRecord } from "lightning/uiRecordApi";

export default class OrderManagement extends LightningElement {
	@api recordId;
	objectApiName = "Order";
	accountNameId;
	activatedById;
	contactId;
	addressAId;
	addressZId;
	addressAContactId;
	addressZContactId;	
	billToContactId;
	billingAccount;
	cloudEngineerId;
	companyAuthorizedById;
	ontractId;
	contractorId;
	coreDesignEngineerId;
	createById;
	customerAuthorizedById;
	dissconnectContactId;
	expansionEngineerId;
	facilityAId;
	facilityZId;
	facilityZBId;
	ffaCompanyId;
	fiberDesignEngineerId;
	gisSpecialistId;
	ispEngineerId;
	LastMileCarrierId;
	lastModifiedById;
	mspEngineerId;
	nni;
	node;
	orderContactId;
	orderOwnerId;
	origServiceOrderAgreement;
	ospEngineerId;
	parentSOFId;
	permittingContractorId;
	powerVendorId;
	predecessorProjectId;
	priceBookId;
	program;
	quoteId;
	quoteLineId;
	quoteLineGroupoId;
	relatedDiscountId;
	relatedOrderPortabilityId;
	ring;
	salesCostEstimateId;
	salesRepId;
	serviceDeliveryManagerId;
	serviceOrderAgreementReplacingId;
	shipToContactId;
	smallCellContractorId;
	transportEngineerId;
	voiceEngineerId;
	

	fields = [
		"Order.AccountId",
		"Order.ActivatedById",
		"Order.Address_A__c",
		"Order.Address_A_Contact__c",
		"Order.Address_Z__c",		
		"Order.Address_Z_Contact__c",
		"Order.Billing_Invoice__c",
		"Order.BillToContactId",
		"Order.Cloud_Engineer__c",
		"Order.Company_Authorized_By__c",
		"Order.ContractId",
		"Order.Contractor__c",
		"Order.Core_Design_Engineer__c",
		"Order.CreatedById",
		"Order.Customer_Authorized_By__c",
		"Order.Disconnect_Contact__c",
		"Order.Expansion_Engineer__c",
		"Order.Facility_A__c",
		"Order.Facility_Z__c",
		"Order.Facility_ZB__c",
		"Order.FFA_Company__c",
		"Order.Fiber_Design_Engineer__c",
		"Order.GIS_Specialist__c",
		"Order.ISP_Engineer__c",
		"Order.LastMile_Carrier__c",
		"Order.LastModifiedById",
		"Order.MSP_Engineer__c",
		"Order.NNI__c",
		"Order.Node__c",
		"Order.OrderContactId",
		"Order.OrderOwnerId",
		"Order.Orig_Service_Order_Agreement__c",
		"Order.OSP_Engineer__c",
		"Order.Parent_SOF__c",
		"Order.Permitting_Contractor__c",
		"Order.Power_Vendor__c",
		"Order.Predecessor_Project__c",
		"Order.Pricebook2Id",
		"Order.Program__c",
		"Order.QuoteId",
		"Order.QuoteLineId",
		"Order.QuoteLineGroupId",
		"Order.Related_Discount__c",
		"Order.Related_Order_Portability__c",
		"Order.Ring__c",
		"Order.Sales_Cost_Estimate__c",
		"Order.SalesRepId",
		"Order.Service_Delivery_Manager__c",
		"Order.Service_Order_Agreement_Replacing__c",
		"Order.ShipToContactId",
		"Order.Small_Cell_Contractor__c",
		"Order.Transport_Engineer__c",
		"Order.Voice_Engineer__c"
	];
	
	@wire( getRecord, { recordId: "$recordId", fields: "$fields" } )
	wiredRecord( { error, data } ) {
		if ( data ) {
			this.accountNameId = data.fields.AccountId.value;
			this.activatedById = data.fields.ActivatedById.value;
		} else if ( error ) {
			console.log( error );
		}
	}
}