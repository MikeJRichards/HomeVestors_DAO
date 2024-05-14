import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Types "./../invoices_backend/types";

module {
public type Result<A,B> = Result.Result<A,B>;
public type HashMap<Ok,Err> = HashMap.HashMap<Ok,Err>;
type Invoice = Types.Invoice;

public type Proposal = {
  id : Nat;
  propertyId : Principal; //Of canister
  creator: Principal;
  category: ProposalCategory;
  content : ProposalContent;
  link: ? Text;
  created: Time.Time;
  votes : [ProposalVotes];
  voteScore : Int;
  status : ProposalStatus;
  executed: ? Int;
};


public type ProposalVotes = {
  member : Principal;
  yesOrNo: Bool;
};


public type ProposalStatus = {
  #Open;
  #Accepted;
  #Rejected;
};


public type ProposalCategory = {
  #Invoice;
  #Proposal;
};


public type ProposalContent = {
  invoice : ? Invoice;
  proposal : ? ProposalContents;
};


public type ProposalContents = {
  contentId : Nat;
  Name: Text;
  Description : Text;
};


}