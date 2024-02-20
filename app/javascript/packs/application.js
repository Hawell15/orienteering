// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//= require jquery
//= require jquery_ujs
//= require_tree .

import Rails from "@rails/ujs"
import * as Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import 'jquery';
import "./application";
import 'images/logo_fos.png';

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


$(document).ready(function() {
    $('th.sortable').on('click', function() {
      console.log("aaa");
      var sort_by = $(this).data('sort-by');
      var current_url = new URL(window.location.href);
      var current_sort_by = current_url.searchParams.get('sort_by');
      var new_sort_by = sort_by;
      var new_direction = 'asc';

      if (current_sort_by === sort_by) {
        var current_direction = current_url.searchParams.get('direction');
        new_direction = (current_direction === 'asc') ? 'desc' : 'asc';
      }

      current_url.searchParams.set('sort_by', new_sort_by);
      current_url.searchParams.set('direction', new_direction);
      window.location.href = current_url;
    });
  });
