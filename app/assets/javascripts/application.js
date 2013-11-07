// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.floatThead
//= require underscore-min
//= require codemirror/codemirror
//= require codemirror/modes/sql
//= require_tree .

window.cm = null

function toggleAutoResize(ev) {
  ev.preventDefault()
  $('#editor').toggleClass('editor-auto-resize')
  cm.refresh()
}

function toggleHideQueryIndex(ev) {
  ev.preventDefault()
  $('.query-read-only-sql-text').toggleClass('query-read-only-sql-text-hidden')
}

$(function() {

		// main query editor
		textarea = $('#editor textarea')[0]
		if (textarea) {
			window.cm = CodeMirror.fromTextArea(textarea, {mode : "text/x-sql", autofocus : true, lineNumbers: true})
		}

		recent = $('.query-sql-text, .query-read-only-sql-text')
		if (recent) {
			recent.each(function(i) {
				sql = $(this).text().trim()
				$(this).text('')
				CodeMirror(this, {value : sql, mode : "text/x-sql", readOnly : true, lineWrapping: true, lineNumbers: true})
			})

      var $table = $('table.query-index');
      $table.floatThead()

      var $resultset = $('table.resultset');
      $resultset.floatThead()
		}

    $('#toggle-auto-resize').on('click', toggleAutoResize)
    $('#toggle-query-index-hide').on('click', toggleHideQueryIndex)
	}
)

