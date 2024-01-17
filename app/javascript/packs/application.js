// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//= require jquery
//= require jquery_ujs

import Rails from "@rails/ujs"
import * as Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "./application";

Rails.start()
Turbolinks.start()
ActiveStorage.start()


window.show_hide_new_competition = function(html) {
    var value = $('[id*="competition_id"]').val();
    if (value == "") {
        $('#new-competition').replaceWith(html);
    } else {
        $('#create-competition').replaceWith('<div id="new-competition"></div>');
    }
}

