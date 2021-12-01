# The Witcher NFT Game ! 🧙‍♂️

https://buildspace-nft-game.herokuapp.com/ **RINKEBY NETWORK ONLY**

## What is it ?

This a really buildspace project that makes you create a real web3 game solidity contract and dapp.

The project itself is pretty basic : you need to mint one of the 3 characaters (Ciri, Geralt and Triss from the witcher games).

When you've got your character you can fight the boss and try to defeat him.

## Changes I've done compared to the buildspace project
- Added three bosses instead of one, the boss is chosed (pseudo)randomly by the contract  
- Added an Attack Power and Attack Damage difference (magic 💫 vs physical damage ⚔️). Each character got their own stats in AP and AD
- Each boss have different resistance to AP and AD, some bosses will be easier to kill for certain characters

## Cool things I learned
- Pseudo random implementation with `block.timestamp` and `block.difficulty`
- Metadata update by the contract
- And some practice for things I already knew :)

### Front-end part
https://github.com/MatteoMer/buildspace-nft-game-frontend
