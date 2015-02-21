# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('body').on 'change', 'select.word_class', (e) ->
  $(this).closest('form').submit().find('input,select,button,a').attr('readonly','readonly').css('pointer-events','none')