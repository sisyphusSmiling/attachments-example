import NonFungibleToken from "../contracts/utility/NonFungibleToken.cdc"
import MockTopShot from "../contracts/MockTopShot.cdc"
import TrollAttacker from "../contracts/TrollAttacker.cdc"

pub fun main(address: Address, id: UInt64): [TrollAttacker.DataBomb]? {
    let collectionRef = getAccount(address).getCapability<
            &MockTopShot.Collection{MockTopShot.CollectionPublic}
        >(
            MockTopShot.CollectionPublicPath
        ).borrow()
        ?? panic("No collection configured at given address!")
    let nftRef = collectionRef.borrowMockTopShot(id: id)
        ?? panic("No NFT with given id in collection!")
    if let timeBombRef = nftRef[TrollAttacker.TimeBomb] {
        return timeBombRef.dataBombs
    }
    return nil
}