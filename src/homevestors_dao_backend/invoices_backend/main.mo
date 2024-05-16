import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Time "mo:base/Time";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import { setTimer; recurringTimer } = "mo:base/Timer";
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
    type InvoiceError = Types.InvoiceError;
    type InvoiceRecurringFrequency = Types.InvoiceRecurringFrequency;
    type ProposalContent = ProposalTypes.ProposalContent;
    type ProposalCategory = ProposalTypes.ProposalCategory;
    type Company = CompanyTypes.Company; 
    type CompanyDAO = CompanyTypes.CompanyDAO;

    

    let proposal_backend : actor {
		_createInvoiceProposal : shared (caller : Principal, propertyId : Principal, category : ProposalCategory, content : ProposalContent, link : ? Text) -> async (); 
	} = actor ("bd3sg-teaaa-aaaaa-qaaba-cai"); 

  let company_backend : actor {
    getCompanyOnly : shared (companyId : Nat) -> async ? Company;
    getCompanyDao : shared (companyId : Nat) -> async Result<CompanyDAO, Text>;
  } = actor ("bd3sg-teaaa-aaaaa-qaaba-cai");

  let invoiceInfo_backend : actor {
    updateAllInvoicesOfStatus : shared (comapnyId : Nat) -> async Result<(), Text>;
    //updateInvoiceTotalsToDate : shared (companyId : Nat) -> async Result<(), Text>;
    updateInvoicesPaidThisYear : shared (comapnyId : Nat, num : Float, category : InvoiceCategory) -> async Result<(), Text>;
    updatePaidInvoiceTotals : shared (company: Nat, amount: Float, category : InvoiceCategory) -> async Result<(), Text>;
  } = actor("bd3sg-teaaa-aaaaa-qaaba-cai");

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

//Logic here:
//switch statement on whether company exists - if null error otherwise continue
//Edit -switch statement on invoiceId - if exists call helper function to create invoice and then don't increment id and use id
//Create - if doesn't exist again call helper function and then add and increment
func _createDraftInvoice (invoiceId : Nat, companyId : Nat, name : Text, description : Text, currency : InvoiceCurrency, amount : Float, recurring : Bool, frequency : InvoiceRecurringFrequency, endDate : Int, category : InvoiceCategory, createdBy : Principal): async Invoice {
  let re : InvoiceRecurring = {
              recurring;
              frequency;
              lastPaid = null;
              endDate;
              total = 0;
              totalPayments = 0;
              allPayments = [0];
          };

          let newInvoiceContent : InvoiceContent = {
            description;
            currency = switch(_getCashflow(category)){case(#Expense){#CKUSDC};case(#Income){currency}};
            amount;
            paymentDate = Time.now();
            recurring = switch(recurring){case(true){?re};case(false){null}};
           };
          let dao = company_backend.getCompanyDao(compnayId);
          let canisterId = dao.assetCanister;
          let newInvoice : Invoice = {
            invoiceId = invoiceId;
            companyId;
            createdBy;
            canisterId;
            name;
            content = newInvoiceContent;
            status = #Open;
            approval = null;
            category;
            cashflow = _getCashflow(category);
           };
  return newInvoice;
};




 public shared ({ caller }) func createDraftInvoice(thisInvoiceId : ? Nat, companyId : Nat, name : Text, description : Text, currency : InvoiceCurrency, amount : Float, recurring : Bool, frequency : InvoiceRecurringFrequency, endDate : Int, category : InvoiceCategory): async Result<(), Text> {
  switch(await company_backend.getCompanyOnly(companyId)){
    case(null){
      return #err("No company exists with that id");
    };
    case(_){
      switch(thisInvoiceId){
        case(null){ //creating an invoice
          let invoice = _createDraftInvoice(invoiceId, companyId, name, description, currency, amount, recurring, frequency, endDate, category, caller);
          invoices.put(invoiceId, invoice);
          invoiceId += 1;
          return #ok();
        };
        case(? notNullThisInvoiceId){
          switch(invoices.get(thisInvoiceId)){
            case(null){ 
              return #err("There is no invoice with that id")

            };
            case(? invoice){//editing a draft invoice
              if(invoice.status != #Draft){
                return #err("You can only edit draft invoices");
              }
              else{
              let invoice = _createDraftInvoice(invoiceId, companyId, name, description, currency, amount, recurring, frequency, endDate, category, caller);
              invoices.put(invoiceId, invoice);
              return #ok();
              };
            };
          };
        };
      };
    };
  };
};



public func getDraftInvoices (): async [Invoice]{
  let allInvoices = Iter.toArray(invoices.vals());
  let allInvoicesBuffer = Buffer.fromArray<Invoice>(allInvoices);
  let draft = Buffer.mapFilter<Invoice, Invoice>(allPropertyInvoicesBuffer, func (x) { if (x.status == #Draft) { ?(x) } else { null }});
  let draftInvoices = Buffer.toArray(draft);
  return draftInvoices;
};


public func getDraftInvoice (invoiceId : Nat) : async Result<Invoice,Text>{
  switch (invoices.get(invoiceId)){
    case(null){
      return #err("There is no invoice with that id");
    };
    case(? invoice){
      return #ok(invoice);
    };
  };
};

public func getDraftInvoicesOfCompany (companyId : Nat): async (){
  let allInvoices = Iter.toArray(invoices.vals());
  let allInvoicesBuffer = Buffer.fromArray<Invoice>(allInvoices);
  let draft = Buffer.mapFilter<Invoice, Invoice>(allPropertyInvoicesBuffer, func (x) { if (x.status == #Draft and x.companyId == companyId) { ?(x) } else { null }});
  let draftInvoices = Buffer.toArray(draft);
  return draftInvoices;
};

func _invoiceChecks (invoice : Invoice): InvoiceError{
  if(Text.size(invoice.name) < 4){
    return #Name;
  };
  if(Text.size(invoice.content.description) < 10){
    return #Description;
  };
  if(invoice.content.amount <= 0){
    return #Amount
  };
  if(invoice.content.recurring != null){
    if(invoice.content.recurring.paymentDate < time.now()){
      return #PaymentDate
    };
    if(invoice.content.recurring.endDate < invoice.content.recurring.paymentDate){
      return #EndDate;
    };
  };
  return #Ok;
};

public func openInvoice (invoiceId : Nat) : async (){
  switch(invoices.get(invoiceId)){
    case(null){
     return #err("There is no invoice with that id");
    };
    case(? invoice){
      //At this point include checks
      if(_invoiceChecks(invoice) == #Ok){
      let newInvoice = {
        invoiceId;
        companyId = invoice.companyId;
        createdBy = invoice.createdBy;
        canisterId = invoice.canisterId;
        name = invoice.name;
        content = invoice.content;
        status = #Open;
        approval = invoice.approval;
        category = invoice.category; 
        cashflow = invoice.cashflow; 
      };

      let newProposalContent = {
       invoice = ?newInvoice;
       proposal = null;
      };
      return #ok(await proposal_backend._createInvoiceProposal(caller, company.dao.daoCanister , #Invoice, newProposalContent, null));//
    };
  };
  };
};

public func getInvoicesOfCompany (companyId : Nat): async [Invoice]{
  let allInvoices = Iter.toArray(invoices.vals());
  let allInvoicesBuffer = Buffer.fromArray<Invoice>(allInvoices);
  let allInvoicesOfCompanyBuffer = Buffer.mapFilter<Invoice, Invoice>(allPropertyInvoicesBuffer, func (x) { if (x.companyId == companyId) { ?(x) } else { null }});
  let allInvoicesOfCompany = Buffer.toArray(allInvoicesOfCompanyBuffer);
  return allInvoicesOfCompany;
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

private func collectDueInvoices (): async (){
  let array = Iter.toArray(invoices.vals());
  let buffer = Buffer.fromArray<Invoice>(array);
  let recurringInvoices = Buffer.mapFilter<Invoice, Invoice>(buffer, func (x) { if (x.status == #Approved and x.content.recurring != null) { ?(x) } else { null }});
  let toPay = Buffer.mapFilter<Invoice, Invoice>(recurringInvoices, func (x) { if ((x.content.paymentDate - Time.now()) / 86400000000000 < 5) { ?(x) } else { null }});
  let payNowArray = Buffer.toArray(toPay);
  ignore payRecurringInvoice(payNowArray);
};

private func payRecurringInvoice (array : [Invoice]): async (){
  for(invoice in array.vals()){
    let newInvoice = {
      invoiceId = invoice.invoiceId;
      companyId = invoice.companyId; 
      createdBy = invoice.createdBy;
      canisterId = invoice.canisterId;
      name = invoice.name; 
      content = invoice.content;
      status = #Paid; 
      approval = invoice.approval;
      category = invoice.category;
      cashflow = invoice.cashflow;
    };
    invoices.put(invoice.invoiceId, newInvoice);
    
    let currency = invoice.content.currency;
    let assetCanister = company_backend.getCompanyDAO(invoice.companyId);
      if(invoice.cashflow == #Income){
        //call transfer from function and send it to this accounts asset canister principal

      }
      else{
        //call transfer from function and send it from this accounts asset canister principal
      };

    let invoiceId = invoice.invoiceId;
    let companyId = invoice.companyId;
    let amount = invoice.content.amount;
    let category = invoice.category; 
    let canisterId = invoice.canisterId; 
    //Call other functions from invoiceInfo
    invoiceInfo_backend.updateAllInvoicesOfStatus(companyId);
    invoiceInfo_backend.updateInvoicesPaidThisYear(companyId, amount, category);
    invoiceInfo_backend.updatePaidInvoiceTotals(companyId, amount, category);
    recreateRecurringInvoice(invoice)
  };
};

private func recreateRecurringInvoice (invoice : Invoice): async (){
  let daysFromNow = switch(invoice.content.recurring){case(#Weekly){7}; case(#Monthly){30}; case(#Annually){365};};
  //need to ensure that additional recurring invoices aren't created after a recurring payment has ended
  //This needs endDate to be set correctly each time in nanoseconds and frequency to be set correctly
  if(Time.now()+daysFromNow*86400000000000 > invoice.content.recurring.endDate){
    return;
  };
  let allPaymentsBuffer = Buffer.fromArray(invoice.content.recurring.allPayments);
  allPaymentsBuffer.add(invoice);
  let allPayments = Buffer.toArray(allPaymentsBuffer);
  let recurring : InvoiceRecurring = {
    recurring = invoice.content.recurring.recurring; 
    frequency = invoice.content.recurring.frequency;
    lastPaid = Time.now();
    endDate = invoice.content.recurring.endDate;
    total = invoice.content.recurring.total + invoice.content.amount; 
    totalPayments = invoice.content.recurring.totalPayments + 1; 
    allPayments;
  };
  
  let content : InvoiceContent = {
    description = invoice.content.description;
    currency = invoice.content.currency;
    amount = invoice.content.amount; //This makes the assumption that every requiring invoice is the same amount
    paymentDate = Time.now() + days * 86400000000000;
    recurring; 
  };
  
  let recurringInvoice : Invoice = {
    invoiceId; 
    companyId = invoice.companyId; 
    createdBy = invoice.createdBy;
    canisterId = invoice.canisterId;
    name = invoice.name; 
    content;
    status = #Approved; 
    approval = invoice.approval;
    category = invoice.category;
    cashflow = invoice.cashflow;
  };
  invoices.put(invoiceId, recurringInvoice);
};

public func paySpecificInvoice (invoiceId : Nat): async Result<Text,Text> {
  switch(invoices.get(invoiceId)){
    case(null){
      #err("There is no invoice with that id");
    };
    case(? invoice){
      if(invoice.status != #Approved){
        return #err("This invoice has not been approved for payment yet.")
      };
      if(invoice.content.recurring != null){
        return #err("This invoice is recurring and cannot be paid before the payment date!")
      };

      let newInvoice = {
        invoiceId   =   invoice.invoiceId;
        companyId   =   invoice.companyId; 
        createdBy   =   invoice.createdBy;
        canisterId  =   invoice.canisterId;
        name        =   invoice.name; 
        content     =   invoice.content;
        status      =   switch(invoice.cashflow){case(#Expense){#Paid}; case(#Income){#Recieved}}; 
        approval    =   invoice.approval;
        category    =   invoice.category;
        cashflow    =   invoice.cashflow;
      };
      invoices.put(invoice.invoiceId, newInvoice);
      let currency = invoice.content.currency;
      let assetCanister = company_backend.getCompanyDAO(invoice.companyId);
      if(invoice.cashflow == #Income){
        //call transfer from function and send it to this accounts asset canister principal

      }
      else{
        //call transfer from function and send it from this accounts asset canister principal
      };
      let companyId = invoice.companyId;
      let amount = invoice.content.amount;
      let category = invoice.category; 
      let canisterId = invoice.canisterId; 
      //Call other functions from invoiceInfo
      invoiceInfo_backend.updateAllInvoicesOfStatus(companyId);
      invoiceInfo_backend.updateInvoicesPaidThisYear(companyId, amount, category);
      invoiceInfo_backend.updatePaidInvoiceTotals(companyId, amount, category);
    };
  };
};

let day = 24*60*60;

ignore setTimer(#seconds (day - Int.abs(Time.now() / 1_000_000_000) % day),  
 func () : async () {  
 ignore recurringTimer(#seconds day, collectDueInvoices);  
 await collectDueInvoices();  
 });  

};

