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
      companyId : Nat;
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
    #CKUSDC;
    #HVD;
    };

  public type InvoiceContent = {
    description : Text;
    currency : InvoiceCurrency;
    amount : Float;
    paymentDate : Time.Time;
    recurring : ? InvoiceRecurring;  
  };

  public type InvoiceError = {
    #ShortDescription;
    #Amount;
    #PaymentDate;
    #EndDate;
    #Name;
    #Ok;
  };

  public type InvoiceRecurring ={
    recurring: Bool;
    frequency: InvoiceRecurringFrequency;
    lastPaid : ? Time.Time;
    endDate: Time.Time;
    total: Float;
    totalPayments : Nat;
    allPayments : [Invoice];
  };

  public type InvoiceRecurringFrequency = {
    #Weekly;
    #Monthly; 
    #Annually; 
    #Other
  };

public type InvoiceStatus = {
  #Draft;
  #Open;
  #Approved;
  #Rejected;
  #Paid;
  #Received;
};

public type InvoiceCategory = {
  #Mortgage;
  #Management;
  #MaintenanceTaxExempt;
  #MaintenanceNonTaxExempt;
  #Insurance;
  #Tax;
  #StampDuty;
  #Legals;
  #Rent;
  #CashInHVD;
  #LiquidHVD;
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
};