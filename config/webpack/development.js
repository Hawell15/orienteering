// config/webpack/development.js

const { environment } = require('@rails/webpacker');
const erb = require('./loaders/erb');

// Add the following lines to expose jQuery globally
const webpack = require('webpack');
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery'
}));

environment.loaders.prepend('erb', erb);

module.exports = environment.toWebpackConfig();
