process.env.NODE_ENV = process.env.NODE_ENV || 'production'
const erb = require('./loaders/erb');

const environment = require('./environment')
environment.loaders.prepend('erb', erb);

module.exports = environment.toWebpackConfig()
