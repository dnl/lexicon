# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('body').on 'click', 'button.answer', (e) ->
  $(this).addClass('selected').closest('form').addClass('answered')
