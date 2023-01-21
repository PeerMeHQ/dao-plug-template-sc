#![no_std]

multiversx_sc::imports!();

#[multiversx_sc::contract]
pub trait Plug {
    #[init]
    fn init(&self) {}
}
