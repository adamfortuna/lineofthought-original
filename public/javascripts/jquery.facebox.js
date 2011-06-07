/*
 * Facebox (for jQuery)
 * version: 1.2 (05/05/2008)
 * @requires jQuery v1.2 or later
 *
 * Examples at http://famspam.com/facebox/
 *
 * Licensed under the MIT:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2007, 2008 Chris Wanstrath [ chris@ozmm.org ]
 *
 * Usage:
 *
 *  jQuery(document).ready(function() {
 *    jQuery('a[rel*=facebox]').facebox()
 *  })
 *
 *  <a href="#terms" rel="facebox">Terms</a>
 *    Loads the #terms div in the box
 *
 *  <a href="terms.html" rel="facebox">Terms</a>
 *    Loads the terms.html page in the box
 *
 *  <a href="terms.png" rel="facebox">Terms</a>
 *    Loads the terms.png image in the box
 *
 *
 *  You can also use it programmatically:
 *
 *    jQuery.facebox('some html')
 *    jQuery.facebox('some html', 'my-groovy-style')
 *
 *  The above will open a facebox with "some html" as the content.
 *
 *    jQuery.facebox(function($) {
 *      $.get('blah.html', function(data) { $.facebox(data) })
 *    })
 *
 *  The above will show a loading screen before the passed function is called,
 *  allowing for a better ajaxy experience.
 *
 *  The facebox function can also display an ajax page, an image, or the contents of a div:
 *
 *    jQuery.facebox({ ajax: 'remote.html' })
 *    jQuery.facebox({ ajax: 'remote.html' }, 'my-groovy-style')
 *    jQuery.facebox({ image: 'stairs.jpg' })
 *    jQuery.facebox({ image: 'stairs.jpg' }, 'my-groovy-style')
 *    jQuery.facebox({ div: '#box' })
 *    jQuery.facebox({ div: '#box' }, 'my-groovy-style')
 *
 *  Want to close the facebox?  Trigger the 'close.facebox' document event:
 *
 *    jQuery(document).trigger('close.facebox')
 *
 *  Facebox also has a bunch of other hooks:
 *
 *    loading.facebox
 *    beforeReveal.facebox
 *    reveal.facebox (aliased as 'afterReveal.facebox')
 *    init.facebox
 *    afterClose.facebox
 *
 *  Simply bind a function to any of these hooks:
 *
 *   $(document).bind('reveal.facebox', function() { ...stuff to do after the facebox and contents are revealed... })
 *
 */
(function($) {
  $.facebox = function(data, klass) {
    $.facebox.loading();

    if (data.ajax) fillFaceboxFromAjax(data.ajax, klass);
    else if (data.image) fillFaceboxFromImage(data.image, klass);
    else if (data.div) fillFaceboxFromHref(data.div, klass);
    else if ($.isFunction(data)) data.call($);
    else $.facebox.reveal(data, klass);
  }


  /*
   * Public, $.facebox methods
   */

  $.extend($.facebox, {
    settings: {
      opacity: 0.50,
      overlay: true,
      loadingImage: '/images/facebox/loading.gif',
      closeImage: '/images/facebox/close.png',
      imageTypes: ['png', 'jpg', 'jpeg', 'gif'],
      faceboxHtml: '\
        <div id="facebox" style="display: none;"> \
          <div class="popup"> \
            <a href="#" class="close"> \
              <img src="" title="Close" /> \
            </a> \
            <div class="loading"><img src="" /></div> \
            <div class="content"></div> \
          </div> \
        </div>'
    },

    loading: function() {
      init();
      showOverlay();

      $('#facebox .content').empty().hide();
      $('#facebox .loading').show();

      $('#facebox').fadeIn().css({
        top: $(window).scrollTop() + ($(window).height() / 10),
        left: ($(window).width() / 2) - ($('#facebox .loading').width() / 2)
      });

      $(document).bind('keydown.facebox', function(event) {
        if (event.keyCode == 27) $.facebox.close(event);
      })

      $(document).trigger('loading.facebox');
    },

    reveal: function(data, klass) {
      $(document).trigger('beforeReveal.facebox');
      if (klass) $('#facebox .content').addClass(klass);
      $('#facebox .loading').hide();
      $('#facebox .content').append(data).fadeIn();
      $('#facebox').css(
        'left', $(window).width() / 2 - ($('#facebox .content').width() / 2)
      );
      $(document).trigger('reveal.facebox').trigger('afterReveal.facebox');
    },

    close: function(event) {
      $(document).trigger('close.facebox');
      if (event) event.preventDefault();
    }
  });


  /*
   * Public, $.fn methods
   */

  $.fn.facebox = function(settings) {
    if ($(this).length == 0) return;

    init(settings);

    return this.bind('click.facebox', function(event) {
      $.facebox.loading();

      // support for rel="facebox.inline_popup" syntax, to add a class
      // also supports deprecated "facebox[.inline_popup]" syntax
      var klass = this.rel.match(/facebox\[?\.(\w+)\]?/);
      if (klass) klass = klass[1];

      fillFaceboxFromHref(this.href, klass);
      event.preventDefault();
    });
  };


  /*
   * Private methods
   */

  // Called once to set up Facebox on this page.
  function init(settings) {
    if ($.facebox.settings.inited) return true;
    else $.facebox.settings.inited = true;

    $(document).trigger('init.facebox');

    var imageTypes = $.facebox.settings.imageTypes.join('|');
    $.facebox.settings.imageTypesRegexp = new RegExp('\.(' + imageTypes + ')$', 'i');

    if (settings) $.extend($.facebox.settings, settings);
    $('body').append($.facebox.settings.faceboxHtml);

    var preload = [new Image(), new Image()];
    preload[0].src = $.facebox.settings.closeImage;
    preload[1].src = $.facebox.settings.loadingImage;

    $('#facebox .close').click($.facebox.close);
    $('#facebox .close img').attr('src', $.facebox.settings.closeImage);
    $('#facebox .loading img').attr('src', $.facebox.settings.loadingImage);
  }

  // Figures out what you want to display and displays it
  // formats are:
  //     div: #id
  //   image: blah.extension
  //    ajax: anything else
  function fillFaceboxFromHref(href, klass) {
    // div
    if (href.match(/#/)) {
      var url = window.location.href.split('#')[0];
      var target = href.replace(url, '');
      if (target == '#') return;
      $.facebox.reveal($(target).html(), klass);

    // image
    } else if (href.match($.facebox.settings.imageTypesRegexp)) {
      fillFaceboxFromImage(href, klass);
    // ajax
    } else {
      fillFaceboxFromAjax(href, klass);
    }
  }

  function fillFaceboxFromImage(href, klass) {
    var image = new Image();
    image.onload = function() {
      $.facebox.reveal('<div class="image"><img src="' + image.src + '" /></div>', klass);
    };
    image.src = href;
  }

  function fillFaceboxFromAjax(href, klass) {
    $.get(href, function(data) { $.facebox.reveal(data, klass) });
  }

  function showOverlay() {
    if ($('#facebox_overlay').length == 0)
      $('body').append('<div id="facebox_overlay" class="facebox_hide"></div>');

    $('#facebox_overlay').hide().addClass('facebox_overlayBG')
      .css('opacity', $.facebox.settings.opacity)
      .click(function() { $(document).trigger('close.facebox') })
      .fadeIn(200);
  }

  function hideOverlay() {
    $('#facebox_overlay').fadeOut(200, function() {
      $('#facebox_overlay').removeClass('facebox_overlayBG');
      $('#facebox_overlay').addClass('facebox_hide');
      $('#facebox_overlay').remove();
    });
  }


  /*
   * Bindings
   */

  $(document).bind('close.facebox', function() {
    $(document).unbind('keydown.facebox');

    $('#facebox').fadeOut(function() {
      $('#facebox .content').removeClass().addClass('content');
      hideOverlay();
      $('#facebox .loading').hide();
      $(document).trigger('afterClose.facebox');
    });
  });
})(jQuery);
