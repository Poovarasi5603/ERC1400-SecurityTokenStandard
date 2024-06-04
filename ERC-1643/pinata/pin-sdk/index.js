require('dotenv').config(); //require dotenv package

const { PINATA_API_KEY,PINATA_SECRET_KEY } = process.env; // instead of PINATA_API_KEY.process.env we can put like this 
//env file allows us to store sensitive info

const pinataSDK = require('@pinata/sdk')   //import sdk to indexjs 
const pinata = new pinataSDK( PINATA_API_KEY,PINATA_SECRET_KEY ); //create new instance of sdk

//new file service object

const fs = require('fs'); // fs -> inbuilt module in nodejs and allow us to interact with file s/m ie our computer
const readableStreamForFile = fs.createReadStream('./blockchain.jpg');//create a readable stream

//create object to enter your metadata

const options ={

    pinataMetadata:{
        name:'project1',
        keyvalues:{
            document:'3'
        }
    },
    pinataOptions:{
        cidVersion: 0,
    }
}

pinata.pinFileToIPFS(readableStreamForFile,options).then ((result)=> {
    console.log(result);
}).catch((err) =>{
    console.log(err);
})

