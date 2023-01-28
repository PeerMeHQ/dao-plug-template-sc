#![no_std]

multiversx_sc::imports!();

#[multiversx_sc::contract]
pub trait Plug {
    #[init]
    fn init(&self) {}

    #[view(getDaoVoteWeight)]
    fn get_dao_vote_weight_view(&self, address: ManagedAddress) -> BigUint {
        // Implement your logic for user's vote weight here
        self.members().get(&address).unwrap_or_default()
    }

    #[view(getDaoMembers)]
    fn get_dao_members_view(&self) -> MultiValueEncoded<ManagedAddress> {
        // Return a list of DAO members' addresses here
        self.members().keys().collect()
    }

    // 👇 The below is just for testing purposes

    #[endpoint(addMember)]
    fn add_member_endpoint(&self, address: ManagedAddress, weight: BigUint) {
        self.members().insert(address, weight);
    }

    #[storage_mapper("members")]
    fn members(&self) -> MapMapper<ManagedAddress, BigUint>;
}
