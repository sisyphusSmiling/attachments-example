import StringUtils from "./utility/StringUtils.cdc"
import TopShot from "./utility/TopShot.cdc"
import LNVCT from "./utility/LNVCT.cdc"

pub contract IWasThere {

    pub let LNVCTCoarseDelimeter: String
    pub let LNVCTGranularDelimeter: String
    pub let TopShotCoarseDelimeter: String
    pub let TopShotGranularDelimeter: String

    pub struct Date {
        pub let month: Int
        pub let day: Int
        pub let year: Int

        init(y: Int, m: Int, d: Int) {
            self.month = m
            self.day = d
            self.year = y
        }

        pub fun equals(other: Date): Bool {
            return self.month == other.month &&
                self.day == other.day &&
                self.year == other.year
        }
    }

    pub attachment TopShotProofOfAttendance for TopShot.NFT {
        pub let id: UInt64
        init() {
            self.id = base.id
        }
    }

    pub attachment TopShotAttendanceValidator for LNVCT.NFT {
        pub let id: UInt64
        pub let dateOfEvent: Date
        
        init() {
            self.id = base.id
            let baseDateString = base.metadata["EVENT_TIME"]
                ?? panic("Ticket does not have EVENT_TIME specified in its metadata!")
            self.dateOfEvent = IWasThere.getDateFromString(
                dateString: baseDateString,
                coarseDelimiter: IWasThere.LNVCTCoarseDelimeter,
                granularDelimeter: IWasThere.LNVCTGranularDelimeter
            )
        }
        
        // Another good case for auth references - shouldn't be able to call this from reference on the attachment
        // as it would be public, should only be able to call from loaded base resource
        // access(auth) fun proveAttendance(nft: @TopShot.NFT): @TopShot.NFT {
        pub fun proveAttendance(nft: @TopShot.NFT): @TopShot.NFT {
            if nft[TopShotProofOfAttendance] != nil {
                return <-nft
            } else {
                if let view = nft.resolveView(Type<TopShot.TopShotMomentMetadataView>()) as! TopShot.TopShotMomentMetadataView? {
                    let topShotDateString = view.dateOfMoment
                        ?? panic("Cannot validate attendance without date of moment!")
                    let topShotDate = IWasThere.getDateFromString(
                            dateString: topShotDateString,
                            coarseDelimiter: IWasThere.TopShotCoarseDelimeter,
                            granularDelimeter: IWasThere.TopShotGranularDelimeter
                        )
                    // TODO: See if LNVCT standardizes their NBA home & away teams
                    if self.dateOfEvent.equals(other: topShotDate) {
                        return <-attach TopShotProofOfAttendance() to <-nft 
                    }
                }
                return <-nft
            }
        }
    }

    pub fun attachTopShotAttendanceValidator(ticket: @LNVCT.NFT): @LNVCT.NFT {
        if ticket[TopShotAttendanceValidator] != nil {
            return <-attach TopShotAttendanceValidator() to <-ticket
        }
        return <-ticket
    }

    /// Returns Date struct from LNVCT date string formatted as:
    /// YYYY<FINE_DELIMETER>MM<FINE_DELIMETER>DD<COARSE_DELIMETER>*
    pub fun getDateFromString(dateString: String, coarseDelimiter: String, granularDelimeter: String): Date {
        let calendarDate = StringUtils.split(dateString, coarseDelimiter)
        let yearMonthDay = StringUtils.split(calendarDate[0], granularDelimeter)
        assert(
            yearMonthDay.length == 3,
            message: "Problem formatting LNVCT date string!"
        )
        let year = Int.fromString(yearMonthDay[0]) ?? panic("Year formatting error in LNVCT date string!")
        let month = Int.fromString(yearMonthDay[1]) ?? panic("Year formatting error in LNVCT date string!")
        let day = Int.fromString(yearMonthDay[2]) ?? panic("Year formatting error in LNVCT date string!")
        return Date(y: year, m: month, d: day)
    }

    init() {
        self.LNVCTCoarseDelimeter = "T"
        self.LNVCTGranularDelimeter = "-"
        self.TopShotCoarseDelimeter = " "
        self.TopShotGranularDelimeter = "-"
    }
}
 