// Make all modal links open in a facebox
(function($) {
  $.fn.linkToModal = function(className, options) {
    var settings = $.extend({}, options);
    var selector = this.selector;

    return this.each(function() {
      var $this = $(this);
      var href = $this.attr('href');

      if ($this.is('a')) {
        $this.bind('click', function(event) {
          if (href[0] == '#') {
            $.facebox({div: href});
          } else {
            $.facebox.loading();
            $.ajax({
              url: href,
              dataType: 'script',
              success: function(data, status, xhr) {
                var $form = $('#facebox .content').find('form');

                // Close the dialog on success
                // $form.live('ajax:success', $.facebox.close);

                // Bind success and failure handlers to the form
                if ($.isFunction(settings.success))
                  $form.live('ajax:success', settings.success);
                if ($.isFunction(settings.failure))
                  $form.live('ajax:failure', settings.failure);

                $.facebox.reveal(null, className);
              }
            });
          }

          event.preventDefault();
        });
      } else if ($this.is('form')) {
        $('body').delegate(selector, 'submit', function(event) {
          $.facebox.loading();

          $(this).bind('ajax:success', function() {
            $.facebox.reveal(null, className);
          });
        });
      }
    });
  };
})(jQuery);