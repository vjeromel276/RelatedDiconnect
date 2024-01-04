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