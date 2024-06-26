#![no_std]

multiversx_sc::imports!();

#[multiversx_sc::contract]
pub trait Plug {
    #[init]
    fn init(&self) {}

    #[upgrade]
    fn upgrade(&self) {}

    #[view(getDaoVoteWeight)]
    fn get_dao_vote_weight_view(
        &self,
        address: ManagedAddress,
        token: OptionalValue<TokenIdentifier>,
    ) -> BigUint {
        // Implement your logic for user's voting power calculation here
        self.members().get(&address).unwrap_or_default()
    }

    #[view(getDaoMembers)]
    fn get_dao_members_view(
        &self,
        token: OptionalValue<TokenIdentifier>,
    ) -> MultiValueEncoded<MultiValue2<ManagedAddress, BigUint>> {
        // Return a list of DAO members' addresses + their vote weight here

        let mut members_multi = MultiValueEncoded::new();

        for (address, weight) in self.members().iter() {
            members_multi.push((address, weight).into());
        }

        members_multi.into()
    }

    // 👇 The below is just for testing purposes

    #[endpoint(addMember)]
    fn add_member_endpoint(&self, address: ManagedAddress, weight: BigUint) {
        self.members().insert(address, weight);
    }

    #[storage_mapper("members")]
    fn members(&self) -> MapMapper<ManagedAddress, BigUint>;
}
