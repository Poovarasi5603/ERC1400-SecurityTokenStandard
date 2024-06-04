require('dotenv').config(); //require dotenv package

const { PINATA_API_KEY,PINATA_SECRET_KEY } = process.env; // instead of PINATA_API_KEY.process.env we can put like this 
//env file allows us to store sensitive info

const pinataSDK = require('@pinata/sdk')   //import sdk to indexjs 
const pinata = new pinataSDK( PINATA_API_KEY,PINATA_SECRET_KEY );



const HashToUnpin = 'Qmdm7DCFmhfgWbPNrBvamHhxjJTcGZYsmGBNCLuAZq8h7Y';
pinata.unpin(HashToUnpin).then((result) =>{
    console.log(result);
}).catch((err) =>{

});


