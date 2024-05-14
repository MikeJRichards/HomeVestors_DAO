import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";


module {
    public type Result<A,B> = Result.Result<A,B>;
    public type HashMap<Ok,Err> = HashMap.HashMap<Ok,Err>;

    public type Invoice = {
      invoiceId : Nat;
      createdBy : Principal;
      canisterId : Principal;
      name : Text;
      content : InvoiceContent;
      status : InvoiceStatus;
      approval : ? InvoiceApproval;
      category: InvoiceCategory;
      cashflow: InvoiceCashflow;
     };


    public type InvoiceCurrency = {
    #Ckusdc;
    #Hvd;
    };


  public type InvoiceRecurring ={
    recurring: Bool;
    days: Nat;
    lastPaid : Time.Time;
    endDate: Time.Time;
    total: Nat;
    totalPayments : Nat;
    allPayments : [Nat];
  };


  public type InvoiceContent = {
    description : Text;
    currency : InvoiceCurrency;
    amount : Float;
    paymentDate : Time.Time;
    recurring : ? InvoiceRecurring;  
  };


public type InvoiceStatus = {
  #Open;
  #Approved;
  #Rejected;
  #Paid;
  #Received;
  #Recurring;
};


public type InvoiceCategory = {
  #Mortgage;
  #Management;
  #Maintenance;
  #Insurance;
  #Tax;
  #StampDuty;
  #Legals;
  #Rent;
  #Defi;
  #Investment;
  #Dividends;
};


public type InvoiceCashflow = {
  #Income;
  #Expense;
};


public type InvoiceApproval = {
  proposalId : Nat64;
  dateAccepted: Time.Time;
  dateCreated : Time.Time;
};
}