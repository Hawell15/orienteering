process.env.NODE_ENV = process.env.NODE_ENV || 'development'

// config/webpack/development.js

const { environment } = require('@rails/webpacker');
const erb = require('./loaders/erb');

environment.loaders.prepend('erb', erb);

module.exports = environment.toWebpackConfig();
