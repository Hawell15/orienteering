// config/webpack/environment.js

const { environment } = require('@rails/webpacker');
const erb = require('./loaders/erb')

environment.loaders.prepend('erb', erb);

environment.loaders.prepend('erb', erb)
module.exports = environment;
