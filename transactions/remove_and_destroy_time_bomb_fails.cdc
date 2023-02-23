import NonFungibleToken from "../contracts/utility/NonFungibleToken.cdc"
import MockTopShot from "../contracts/MockTopShot.cdc"
import TrollAttacker from "../contracts/TrollAttacker.cdc"

transaction(removeFromNFT: UInt64) {
    
    let collectionRef: &MockTopShot.Collection
    
    prepare(signer: AuthAccount) {
        self.collectionRef = signer.borrow<
                &MockTopShot.Collection
            >(
                from: MockTopShot.CollectionStoragePath
            ) ?? panic("No collection configured")
    }

    execute {
        let attackedNFT <-self.collectionRef.withdraw(withdrawID: removeFromNFT) as! @MockTopShot.NFT
        // This should fail due to attachment's destroy
        remove TrollAttacker.TimeBomb from attackedNFT
        self.collectionRef.deposit(token: <-attackedNFT)
    }
}
