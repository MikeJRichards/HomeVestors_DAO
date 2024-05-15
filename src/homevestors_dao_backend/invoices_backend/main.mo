import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Time "mo:base/Time";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Types "types";
import ProposalTypes "./../proposals_backend/types";
import CompanyTypes "./../company_backend/types";

actor {
    type Result <Ok, Err> = Types.Result<Ok,Err>;
    type HashMap<K,V> = Types.HashMap<K,V>; 
    type Invoice = Types.Invoice; 
    type InvoiceCurrency = Types.InvoiceCurrency; 
    type InvoiceRecurring = Types.InvoiceRecurring; 
    type InvoiceContent = Types.InvoiceContent; 
    type InvoiceStatus = Types.InvoiceStatus;
    type InvoiceCategory = Types.InvoiceCategory; 
    type InvoiceCashflow = Types.InvoiceCashflow; 
    type InvoiceApproval = Types.InvoiceApproval;
    type RecurringFrequency = Types.RecurringFrequency;
    type ProposalContent = ProposalTypes.ProposalContent;
    type ProposalCategory = ProposalTypes.ProposalCategory;
    type Company = CompanyTypes.Company; 

    

    let proposal_backend : actor {
		_createInvoiceProposal : shared (caller : Principal, propertyId : Principal, category : ProposalCategory, content : ProposalContent, link : ? Text) -> async (); 
	} = actor ("bd3sg-teaaa-aaaaa-qaaba-cai"); 

  let company_backend : actor {
    getCompanyOnly : shared (companyId : Nat) -> async ? Company;
  } = actor ("bd3sg-teaaa-aaaaa-qaaba-cai");

  var invoiceId : Nat = 0;
  let invoices = HashMap.HashMap<Nat, Invoice>(0, Nat.equal, Hash.hash);
  
//Helper function required if invoice is recurring
//Need two function calls - one for if it is recurring, one for if it isn't
//Will also need a function for if
func _getCashflow (category : InvoiceCategory): InvoiceCashflow {
  let income : [InvoiceCategory] = [#Rent, #Investment, #LiquidHVD, #CashInHVD, #Dividends];
  for(vals in income.vals()){
    if(vals == category){
      return #Income;
    };
  };
  return #Expense;
};



 public shared ({ caller }) func createInvoice(companyId : Nat, name : Text, description : Text, currency : InvoiceCurrency, amount : Float, recurring : Bool, frequency : RecurringFrequency, category : InvoiceCategory): async Result<(), Text> {
 //My christ the logic here is complex essentially an invoice is only created if
 //it can be associated with a company otherwise error
 //Then recurring invoice type gets created
 //then invoice content is created with a switch to see if invoice is recurring if not recurring set to null otherwise adds recurring cretaed before
 //then invoice created parsing in company id and asset canister id
 //Then proposal content created utilising intercanister call
  switch(await company_backend.getCompanyOnly(companyId)){
    case(null){
      return #err("No company exists with that id");
    };
    case(? company ){
          let re : InvoiceRecurring = {
              recurring;
              frequency;
              lastPaid = Time.now();
              endDate = Time.now();
              total = 0;
              totalPayments = 0;
              allPayments = [0];
          };

          let newInvoiceContent : InvoiceContent = {
            description;
            currency;
            amount;
            paymentDate = Time.now();
            recurring = switch(recurring){case(true){?re};case(false){null}};
           };

          let canisterId = company.dao.assetCanister;
          let newInvoice : Invoice = {
            invoiceId = invoiceId;
            companyId;
            createdBy = caller;
            canisterId;
            name;
            content = newInvoiceContent;
            status = #Open;
            approval = null;
            category;
            cashflow = _getCashflow(category);
           };
          invoices.put(invoiceId, newInvoice);
          invoiceId += 1;
          
          let newProposalContent = {
            invoice = ?newInvoice;
            proposal = null;
          };
          return #ok(await proposal_backend._createInvoiceProposal(caller, company.dao.daoCanister , #Invoice, newProposalContent, null));//
        };
      };
};


 public func getInvoices (): async [Invoice]{
     return Iter.toArray(invoices.vals());
};

public func getInvoice (invoiceId : Nat): async Result<Invoice, Text> {
  switch(invoices.get(invoiceId)){
    case(null){
      return #err("Invalid Invoice Id");
    };
    case(? invoice){
      return #ok(invoice);
    };
  }
};

public func getInvoiceContent (invoiceId : Nat): async Result <InvoiceContent, Text>{
  switch (invoices.get(invoiceId)){
    case(null){
      return #err("There is no invoice with that id");
    };
    case ( ? invoice){
      return #ok(invoice.content);
    };
  };
};


public func getInvoiceStatus (invoiceId : Nat): async Result <InvoiceStatus, Text>{
  switch(invoices.get(invoiceId)){
    case(null){
      return #err("The invoice Id is incorrect");
    };
    case (? invoice){
      return #ok(invoice.status);
    };
  };
};


public func getInvoiceCategory (invoiceId : Nat): async Result <InvoiceCategory, Text>{
  switch (invoices.get(invoiceId)){
    case (null){
      return #err("The invoice Id is incorrect");
    };
    case (? invoice){
      return #ok(invoice.category);
    };
  };
};


public func getRecurringInvoice (invoiceId : Nat): async Result <InvoiceRecurring, Text>{
  switch(invoices.get(invoiceId)){
    case(null){
      return #err("The invoice Id is incorrect");
    };
    case(? invoice){
      switch(invoice.content.recurring){
        case(null){
          return #err("The invoice is not recurring");
        };
        case(? recurring){
          return #ok(recurring);
        };
      };
    };
  };
};


public func updateInvoice (invoiceId : Nat, newInvoice : Invoice): async Result<(),Text>{
  if(invoices.get(invoiceId) == null){
    return #err("The invoice id is incorrect");
  };


  invoices.put(invoiceId, newInvoice);
  return #ok();
};

public func listAllPropertyInvoices (companyId : Nat): async [Invoice] {
    let propertyInvoices =
      HashMap.mapFilter<Nat, Invoice, Invoice>(
      invoices,
      Nat.equal,
      Hash.hash,
    func (k, v) = if (v.companyId == companyId) { ?(v) } else { null }
);

let array = Iter.toArray(propertyInvoices.vals());
return array;
};




};

