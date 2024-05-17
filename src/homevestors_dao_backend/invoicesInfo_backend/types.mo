import Float "mo:base/Float";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import InvoiceTypes "./../invoices_backend/types"

module {
    public type Result<A,B> = Result.Result<A,B>;
    public type HashMap<Ok,Err> = HashMap.HashMap<Ok,Err>;
    public type Invoice = InvoiceTypes.Invoice;

    public type InvoicesInfo = {
     companyId: Nat;
     allOfStatus : AllInvoicesOfStatus;
     reccurringSummary : InvoiceReccurringSummary;
     annualCashflow : InvoicesPaidThisTaxYear;
     paymentsToDate : InvoiceTotalsToDate;
     allPropertyInvoices : [Invoice];
     taxByYear : [InvoiceTaxByYear];
    }; 

    public type InvoiceTaxByYear = {
     year : Int;
     taxPaid : Float; 
     previousAnnualSummary : InvoicesPaidThisTaxYear;
    };

    public type AllInvoicesOfStatus = {
     openInvoices : [Invoice];
     approvedInvoices : [Invoice];
     rejectedInvoices : [Invoice];
     paidInvoices : [Invoice];
     recievedInvoices : [Invoice];
     maintenanceInvoices : [Invoice];
     investmentInvoices : [Invoice];
    }; 

    public type InvoiceReccurringSummary = {
     approvedRecurringExpenses : [Invoice];
     recurringIncome : [Invoice];
     monthlyRecurringExpenses : Float; 
     monthlyRecurringIncome : Float; 
     hVDTokensRecievedperMonth: Float;
    };

    public type InvoicesPaidThisTaxYear = {
     annualIncomeRent: Float;
     annualIncomeSellingHVD: Float;
     annualMaintenanceTaxExempt : Float;
     annualMaintenanceTaxNonExempt : Float; 
     annualManagement : Float;
     annualMortgage : Float; 
     annualOther : Float;
    };   
    
    //consider renaming maintenance as allowableExpense
    public type InvoiceTotalsToDate = {
     mortgage: Float;
      maintenanceTaxExempt : Float;
      maintenanceNonTaxExempt : Float;
      management: Float;
      rentRecieved : Float; 
      hVDTokensRecieved : Float;
      hVDCashInRecieved : Float;
      investmentsMade : Float;
      dividendsRecieved : Float; 
      totalTaxPaid : Float;
     };
}