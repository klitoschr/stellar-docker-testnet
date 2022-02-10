const StellarSdk = require('stellar-sdk')
const rp = require('request-promise')


const server = new StellarSdk.Server('http://10.10.70.21:8000', {allowHttp: true})
const source = StellarSdk.Keypair.fromSecret('SCMWJA5CY26OKBMEKP4YWLCXXBQNPL4VXIQYBCFLXBD4UYQ3BV34OI2Z')
const destination = StellarSdk.Keypair.random()

server.accounts()
  .accountId(source.publicKey())
  .call()
  .then(({ sequence }) => {
    const account = new StellarSdk.Account(source.publicKey(), sequence)
    const transaction = new StellarSdk.TransactionBuilder(account, {
      fee: StellarSdk.BASE_FEE,
      networkPassphrase: "Standalone UNIC_IFF Network ; 2022"
    })
      .addOperation(StellarSdk.Operation.createAccount({
        destination: destination.publicKey(),
        startingBalance: '1000'
      }))
      .setTimeout(30)
      .build()
    transaction.sign(StellarSdk.Keypair.fromSecret(source.secret()))
    return server.submitTransaction(transaction)
  })
  .then(results => {
    console.log('Transaction', results._links.transaction.href)
    console.log('New Keypair', destination.publicKey(), destination.secret())
  })