// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var Aggregator = {
  extendTable: function(options) {
    var table = $(options.id);
    var wrapper = $(".wrapper", table);

    // show searchfield (it's disabled by default because with JS off,
    // when enter is pressed in search field, form is submited
    $(".search_field", table).css('display', 'block');

    // make column head links ajax
    $("table thead tr th a", table).click(function() {wrapper.load($(this).attr('href'));return false;});

    // pagination links should be ajax too
    $(".pagination a", table).click(function() {wrapper.load($(this).attr('href'));return false;});

    // check all checkboxes when checking "check all"
    $("input[name='check_all']", table).click(function() {$("input[name='ids[]']", table).attr('checked', $(this).attr('checked'))});

    // check checkbox if row is clicked
    $("table tbody tr", table).click(function(ev) {
      var on_checkbox = $(ev.target).attr('name') == 'ids[]';
      var box = $("input[name='ids[]']", this);
      var old_val = box.attr('checked');
      if (options.single_select || !on_checkbox) $("input[name='ids[]']", table).attr('checked', false);
      // when click is on checkbox, value is already toggled
      box.attr('checked', on_checkbox ? old_val : !old_val);
    });
  },

  extendTableSearchField: function(options) {
    var table = $(options.id);
    var wrapper = $(".wrapper", table);
    $(".search_field input", table).keypress(function(ev) {
      var delay = 1000;
      if (ev.keyCode == 13) {
        delay = 0;
        ev.preventDefault();
      }
      if (table.searching) clearTimeout(table.searching);
      table.searching = setTimeout(function() {
        $(".wrapper", table).mask('Searching...');
        table.search_lock = false;
        var search = $(".search_field input", table).val();
        var url = $("form", table).attr('action') + '&search=' + search;
        wrapper.load(url, function() {$(".wrapper", table).unmask()});
      }, delay);
    });
  }
}
