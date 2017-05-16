(($, E) ->
  "use strict"

  absoluteSum = () ->
    if $('table').height() > $('body').height()
      $('#computation-results').css({
          position: 'absolute',
          bottom: '0px',
          'max-width': $('#computation-results').closest('table').width() + 'px'
        })
      count = 0
      $("#computation-results > td").each ->
        totest = $(this).closest('table').find($('thead > tr > th'))[count]
        $(this).css('max-width', 'none')
        $(this).width($(totest).width())
        count++


  $(document).ready () ->
    absoluteSum()

    $('*[data-list-source]').on('page:change', absoluteSum)

    timer = 0
    $('.list-selector').click () ->
      if new Date - timer > 1000
        timer = new Date
        $('#computation-results > td > div').each ->
          myParent = $(this).parent()
          myWidth = myParent.width()
          myClass = myParent.attr('class')
          if $('.' + myClass).width() != myWidth
            $('.' + myClass).width(myWidth)

) jQuery, ekylibre
