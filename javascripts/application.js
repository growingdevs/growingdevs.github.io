var APP = APP || {};
APP = $.extend({}, APP, {
  init: function() {},
  post: function() {}
});

UTIL = {
  exec: function( trigger ) {
    var ns = APP;

    if ( trigger !== "" && ns[trigger] && typeof( ns[trigger] ) == "function" ) {
      ns[trigger]();
    }
  },

  init: function() {
    var body = document.body, trigger = body.getAttribute( "data-trigger" );

    UTIL.exec( "init" );
    UTIL.exec( trigger );

    $(document).trigger('finalized');
  }
};

$(document).ready( UTIL.init );
