import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
//import Float "mo:base/Float";
import Time "mo:base/Time";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Types "types";
import InvoiceTypes "./../invoices_backend/types";

actor {
    type Result <Ok, Err> = Types.Result<Ok,Err>;
    type HashMap<K,V> = Types.HashMap<K,V>; 
    type Proposal = Types.Proposal; 
    type ProposalVotes = Types.ProposalVotes; 
    type ProposalStatus = Types.ProposalStatus; 
    type ProposalCategory = Types.ProposalCategory; 
    type ProposalContent = Types.ProposalContent; 
    type ProposalContents = Types.ProposalContents;
    type Invoice = InvoiceTypes.Invoice; 

    var proposalId : Nat = 0;
    let proposals = HashMap.HashMap<Nat, Proposal>(0, Nat.equal, Hash.hash);
    let members = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
   
func _createProposal (caller : Principal, companyId : Nat, category : ProposalCategory, content : ProposalContent, link : ? Text): Proposal {
  let newProposal : Proposal = {
    id = proposalId;
    companyId;
    creator = caller;
    category;
    content;
    link = switch(link){case (null){null}; case(?hyperlink){?hyperlink}};
    created = Time.now();
    votes = [];
    voteScore = 0;
    status = #Open;
    executed = null;
  };
  return newProposal;
};


public shared ({ caller }) func createProposal(companyId : Nat, category : ProposalCategory, content : ProposalContent, link : ? Text): async Result<(), Text> {
  let newProposal = _createProposal(caller : Principal, companyId : Nat, category:ProposalCategory, content : ProposalContent, link: ? Text);
  proposals.put(proposalId, newProposal);
  proposalId += 1;
  return #ok();
};


public shared func _createInvoiceProposal(caller : Principal, companyId : Nat, category : ProposalCategory, content : ProposalContent, link : ? Text): async (){
  let newProposal = _createProposal(caller : Principal, companyId : Nat, category:ProposalCategory, content : ProposalContent, link: ? Text);
  proposals.put(proposalId, newProposal);
  proposalId += 1;
  return;
};

public func getProposals (): async [Proposal]{
  return Iter.toArray(proposals.vals());
};

public func getInvoiceFromProposal (proposalId : Nat): async Result<Invoice, Text>{
  switch(proposals.get(proposalId)){
    case(null){
      return #err("The proposal Id is incorrect");
    };
    case(? Proposal){
      if(Proposal.category == #Invoice){
        switch(Proposal.content.invoice){
          case(null){
            return #err("The invoice type is null")
          };
          case (? invoice){
            return #ok(invoice);
          };
        }
      };
      return #err("The proposal is not of type invoice");
      };
    };
};

public shared ({ caller }) func vote (proposalId : Nat, yesOrNo : Bool): async Result<(),Text>{
  //Currently members is declared at top of this file with no principals - need NFTs really to test this function
  if(Option.isNull(members.get(caller))){
    return #err("You need to hold this properties NFT to vote on proposals")
  };
  switch(proposals.get(proposalId)){
    case(null){
      return #err("The proposal Id is incorrect");
    };
    case (? proposal){
      for(vals in proposal.votes.vals()){
        if(vals.member == caller){
          return #err("You have already voted!");
        };
      };
      if(proposal.status != #Open){
        return #err("The proposal is no longer open for voting")
      };
      //Need voting mechanism
      let addition = switch(yesOrNo){case(true){1}; case(false){-1}};
      let getVotes : Int = proposal.voteScore + addition;
      //check if the function now needs to be executed - if so call function needs to get current time, category
      //i.e. if execute then call function, set these variables, otherwise set to null and use switch below
      //I guess actually this could be a heartbeat function - when time is below - if majority call approval update invoice, if rejected update invoice
      //now recreating the proposal with new vote and votescore
      let buffer = Buffer.Buffer<ProposalVotes>(0); 
      let vote : ProposalVotes = {
        member = caller; 
        yesOrNo;
      };
      for(vals in proposal.votes.vals()){
        buffer.add(vals);
      };
      buffer.add(vote);
      let newVotes = Buffer.toArray<ProposalVotes>(buffer);
      let updateProposal : Proposal = {
        id = proposal.id;
        companyId = proposal.companyId;
        creator = proposal.creator;
        category = proposal.category; //this needs to be changed if approved from score
        content = proposal.content; 
        link = proposal.link; 
        created = proposal.created; 
        votes = newVotes;
        voteScore = getVotes; 
        status = proposal.status;
        executed = proposal.executed; //this needs to be set to the time it was approved if it was
      };
      proposals.put(proposalId, updateProposal);
      return #ok();


    };
  };
};

//public func getHousesProposals (propertyId : Principal): async [Proposal]{
//   let houseProposals = HashMap.mapFilter<Nat, Proposal>(
//    proposals,
//    Nat.equal,
//    Hash.hash,
//    func (k, v) = if (v.propertyId == propertyId) { v } else { null });
//return Iter.toArray(houseProposals.vals());
//};

};
