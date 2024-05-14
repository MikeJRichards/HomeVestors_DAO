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
//import Option "mo:base/Option"

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
    type ProposalContent = ProposalTypes.ProposalContent;
    type ProposalCategory = ProposalTypes.ProposalCategory;
  
  //let proposal_backend : actor {
	//	_createInvoiceProposal : shared (caller : Principal, propertyId : Principal, category : ProposalCategory, content : ProposalContent, link : ? Text) -> async (); 
	//} = actor ("bd3sg-teaaa-aaaaa-qaaba-cai"); 


  var invoiceId : Nat = 0;
  let invoices = HashMap.HashMap<Nat, Invoice>(0, Nat.equal, Hash.hash);
  
//Helper function required if invoice is recurring
//Need two function calls - one for if it is recurring, one for if it isn't
//Will also need a function for if
func _getCashflow (category : InvoiceCategory): InvoiceCashflow {
  let income : [InvoiceCategory] = [#Rent, #Investment, #Defi, #Dividends];
  for(vals in income.vals()){
    if(vals == category){
      return #Income;
    };
  };
  return #Expense;
};



 public shared ({ caller }) func createInvoice(canisterId : Principal, name : Text, description : Text, currency : InvoiceCurrency, amount : Float, recurring : Bool, days : Nat, category : InvoiceCategory): async () {
  let re : InvoiceRecurring = {
             recurring;
            days;
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
let newInvoice : Invoice = {
     invoiceId = invoiceId;
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
  return ();
 // let newProposalContent = {//
// //   invoice = ?newInvoice;//
// //   proposal = null;//
// // };//
// // return (await proposal_backend._createInvoiceProposal(caller, canisterId , #Invoice, newProposalContent, null));//
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





//public func listAllPropertyInvoices (propertyId : Nat): async [Invoice] {
//    
//}




 




};

