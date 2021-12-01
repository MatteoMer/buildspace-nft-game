// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

contract MyEpicGame is ERC721 {
    struct CharacterAttr {
        uint256 index;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxhp;
        uint256 attackDamage;
        uint256 attackPower;
    }

    struct Boss {
        uint256 index;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxhp;
        uint256 attack;
        uint256 ratioAD;
        uint256 ratioAP;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(uint256 => CharacterAttr) public nftHolderAttr;
    mapping(address => uint256) public nftHolders;
    CharacterAttr[] defaultCharacters;
    Boss[] defaultBoss;
    Boss private actualBoss;

    event NewBoss(uint256 bossId, string bossName);
    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURI,
        uint256[] memory characterHP,
        uint256[] memory characterAD,
        uint256[] memory characterAP,
        string[] memory bossNames,
        string[] memory bossImageURI,
        uint256[] memory bossHP,
        uint256[] memory bossAttack,
        uint256[] memory bossRatioAD,
        uint256[] memory bossRatioAP
    ) ERC721("Witchers", "WTCHR") {
        for (uint256 i = 0; i < bossNames.length; i++) {
            defaultBoss.push(
                Boss({
                    index: i,
                    name: bossNames[i],
                    imageURI: bossImageURI[i],
                    hp: bossHP[i],
                    maxhp: bossHP[i],
                    attack: bossAttack[i],
                    ratioAD: bossRatioAD[i],
                    ratioAP: bossRatioAP[i]
                })
            );

            Boss memory c = defaultBoss[i];
            console.log(
                "Done initializing boss %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }

        for (uint256 i = 0; i < characterNames.length; i++) {
            defaultCharacters.push(
                CharacterAttr({
                    index: i,
                    name: characterNames[i],
                    imageURI: characterImageURI[i],
                    hp: characterHP[i],
                    maxhp: characterHP[i],
                    attackDamage: characterAD[i],
                    attackPower: characterAP[i]
                })
            );

            CharacterAttr memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }
        _tokenIds.increment();
        generateNewBoss();
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            );
    }

    function getBoss() public view returns (Boss memory) {
        return actualBoss;
    }

    function generateNewBoss() public {
        uint256 bossId = random() % defaultBoss.length;
        Boss memory newBoss = Boss({
            index: bossId,
            name: defaultBoss[bossId].name,
            imageURI: defaultBoss[bossId].imageURI,
            hp: defaultBoss[bossId].hp,
            maxhp: defaultBoss[bossId].maxhp,
            attack: defaultBoss[bossId].attack,
            ratioAD: defaultBoss[bossId].ratioAD,
            ratioAP: defaultBoss[bossId].ratioAP
        });

        actualBoss = newBoss;
        emit NewBoss(bossId, newBoss.name);
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttr[] memory)
    {
        return defaultCharacters;
    }

    function attackBoss() public {
        // If the boss is dead, bring a new one!
        if (actualBoss.hp == 0) {
            generateNewBoss();
        }

        //get the player state
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttr storage player = nftHolderAttr[nftTokenIdOfPlayer];

        require(player.hp > 0, "The attacker is already dead !");

        //player attacks first!
        uint256 playerOverallAttackVsBoss = (player.attackDamage *
            actualBoss.ratioAD) + (player.attackPower * actualBoss.ratioAP);

        if (actualBoss.hp < playerOverallAttackVsBoss) {
            actualBoss.hp = 0;
        } else {
            actualBoss.hp -= playerOverallAttackVsBoss;
        }

        //boss attacks in return
        if (player.hp < actualBoss.attack) {
            player.hp = 0;
        } else {
            player.hp -= actualBoss.attack;
        }

        console.log(
            "After the combat, boss %s is at %d HP and player is at %d HP",
            actualBoss.name,
            actualBoss.hp,
            player.hp
        );
        emit AttackComplete(actualBoss.hp, player.hp);
    }

    function checkIfUserHasNFT() public view returns (CharacterAttr memory) {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];
        // If the user has a tokenId in the map, return their character.
        if (userNftTokenId > 0) {
            return nftHolderAttr[userNftTokenId];
        }
        // Else, return an empty character.
        else {
            CharacterAttr memory emptyStruct;
            return emptyStruct;
        }
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttr memory charAttributes = nftHolderAttr[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxhp);
        string memory strAD = Strings.toString(charAttributes.attackDamage);
        string memory strAP = Strings.toString(charAttributes.attackPower);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " #",
                        Strings.toString(_tokenId),
                        '", "description": "This NFT let people play the best NFT game ever", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [{"trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, {"trait_type": "Attack Damage", "value": ',
                        strAD,
                        '}, {"trait_type": "Attack Power", "value": ',
                        strAP,
                        "}]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function mintNFT(uint256 _characterIndex) external {
        uint256 tokenId = _tokenIds.current();

        _safeMint(msg.sender, tokenId);

        nftHolderAttr[tokenId] = CharacterAttr({
            index: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxhp: defaultCharacters[_characterIndex].maxhp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            attackPower: defaultCharacters[_characterIndex].attackPower
        });

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            tokenId,
            _characterIndex
        );

        nftHolders[msg.sender] = tokenId;

        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, tokenId, _characterIndex);
    }
}
