# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('body').on 'click', 'button.answer', (e) ->
  $(this).addClass('selected').closest('form').addClass('answered').find('button').css('pointer-events', 'none')

$('body').on 'click', '.missing_letters input[type="submit"]', (e) ->
  $(this).css('pointer-events', 'none')
  .closest('form').addClass('answered')
  .find('input.letter').css('pointer-events', 'none')
  .each ->
    if $(this).val() in $(this).data('correct').split(',')
      $(this).addClass('correct-answer')

$('body').on 'click change focus blur', 'select.word_class', (e) ->
  $(this).closest('form').find('.word-class-variant').addClass('hidden').select(".#{$(this).val()}").removeClass('hidden')