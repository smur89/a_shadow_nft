compile:
	npx hardhat compile

deploy:
	npx hardhat run scripts/deploy.js --network ropsten
	#npx hardhat deploy

check-balance:
	npx hardhat check-balance

mint:
	npx hardhat mint --address 0xb9720BE63Ea8896956A06d2dEd491De125fD705E

pack-images:
	npx ipfs-car --pack images --output images.car

pack-metadata:
	npx ipfs-car --pack metadata --output metadata.car

pack-songs:
	npx ipfs-car --pack songs --output songs.car

verify:
	npx hardhat verify $NFT_CONTRACT_ADDRESS