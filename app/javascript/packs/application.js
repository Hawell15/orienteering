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


document.addEventListener('turbolinks:load', function() {
    $('th.sortable').on('click', function() {

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

document.addEventListener('turbolinks:load', function() {
    $('#search').on('input', function() {
        var query = $(this).val();
        var data = location.pathname.replace('/', '');
        if (query.length >= 1) { // Adjust minimum length as needed
            $.ajax({
                url: '/' + data,
                type: 'GET',
                data: { search: query },
                dataType: 'html',
                success: function(response) {
                    var tableData = $(response).find('#'+ data + '-table').html();
                    $('#'+ data + '-table').html(tableData);
                    $('#search').focus(); // Re-focus on search input
                }
            });
        } else {
            $.ajax({
                url: '/' + data,
                type: 'GET',
                dataType: 'html',
                success: function(response) {
                    var tableData = $(response).find('#'+ data + '-table').html();
                    $('#'+ data + '-table').html(tableData);
                }
            });
        }
    });
});

document.addEventListener('turbolinks:load', function() {
    $('#show_search').on('input', function() {
        var query =$('#show_search').val();
        var data = $('#show_search').attr('table_type');

        if (query.length >= 1) { // Adjust minimum length as needed
            $.ajax({
                url: location.pathname,
                type: 'GET',
                data: { search: query },
                dataType: 'html',
                success: function(response) {
                    var tableData = $(response).find('#'+ data + '-table').html();
                    $('#'+ data + '-table').html(tableData);
                    $('#show_search').focus(); // Re-focus on search input
                }
            });
        } else {
            $.ajax({
                 url: location.pathname,
                type: 'GET',
                dataType: 'html',
                success: function(response) {
                    var tableData = $(response).find('#'+ data + '-table').html();
                    $('#'+ data + '-table').html(tableData);
                }
            });
        }
    });
});


