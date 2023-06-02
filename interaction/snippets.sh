NETWORK_NAME="devnet" # devnet, testnet, mainnet

PROXY="https://devnet-gateway.multiversx.com"
CHAIN_ID="D"
ADDRESS="erd1qqqqqqqqqqqqqpgq30ngd7su8mm970sspms2mhfkhtra2u9q27rsma8tra"

deploy() {
    echo "accidental deploy protection is active"
    exit 1;

    mxpy --verbose contract clean || return
    mxpy --verbose contract build || return
    cargo test || return

    mxpy --verbose contract deploy --project . \
        --recall-nonce --gas-limit=50000000 \
        --proxy=$PROXY --chain=$CHAIN_ID \
        --outfile="deploy-$NETWORK_NAME.interaction.json" \
        --metadata-payable-by-sc \
        --metadata-payable \
        --ledger \
        --send || return

    TRANSACTION=$(mxpy data parse --file="deploy-${NETWORK_NAME}.interaction.json" --expression="data['emittedTransactionHash']")
    ADDRESS=$(mxpy data parse --file="deploy-${NETWORK_NAME}.interaction.json" --expression="data['contractAddress']")

    mxpy data store --partition $NETWORK_NAME --key=address --value=$ADDRESS
    mxpy data store --partition $NETWORK_NAME --key=deploy-transaction --value=$TRANSACTION

    echo ""
    echo "deployed smart contract address: $ADDRESS"
}

upgrade() {
    mxpy --verbose contract clean || return
    mxpy --verbose contract build || return
    cargo test || return

    mxpy --verbose contract upgrade $ADDRESS --project . \
        --recall-nonce --gas-limit=50000000 \
        --proxy=$PROXY --chain=$CHAIN_ID \
        --metadata-payable-by-sc \
        --metadata-payable \
        --ledger \
        --send || return
}

# params:
#   $1 = address
#   $2 = vote weight
addMember() {
    mxpy contract call $ADDRESS \
        --function="addMember" \
        --arguments $1 $2 \
        --recall-nonce --gas-limit=10000000 \
        --proxy=$PROXY --chain=$CHAIN_ID \
        --ledger \
        --send || return
}

# params:
#   $1 = address
getDaoVoteWeight() {
    mxpy contract query $ADDRESS \
        --function="getDaoVoteWeight" \
        --arguments $1 \
        --proxy=$PROXY || return
}

getDaoMembers() {
    mxpy contract query $ADDRESS \
        --function="getDaoMembers" \
        --proxy=$PROXY || return
}
