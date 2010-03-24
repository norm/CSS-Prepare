function select_text() {
    var text = document.getElementById('code');
    
    if ( $.browser.msie ) {
        var range = document.body.createTextRange();
        range.moveToElementText( text );
        range.select();
    } 
    else if ( $.browser.mozilla || $.browser.opera ) {
        var selection = window.getSelection();
        var range = document.createRange();
        range.selectNodeContents( text );
        selection.removeAllRanges();
        selection.addRange( range );
    } 
    else if ( $.browser.safari ) {
        var selection = window.getSelection();
        selection.setBaseAndExtent( text, 0, text, 1 );
    }
}

$("#output").prepend("<span id='select-text'>select result</span>");
$("#select-text").click( function() {
        select_text();
    });