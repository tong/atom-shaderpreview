
import js.html.AudioElement;
import js.html.CSSStyleDeclaration;
import js.html.DivElement;
import js.html.Element;
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
import Atom.config;

@:keep
@:expose
class ShaderPreviewView {

    public var element(default,null) : Element;

    var preview : ShaderPreview;
    var animationFrameId : Int;

    public function new( preview : ShaderPreview ) {

        this.preview = preview;

        element = document.createDivElement();
        element.classList.add( 'shaderpreview' );
        element.appendChild( preview.canvas );

        //element.addEventListener( 'DOMNodeInserted', handleDOMInsert, false );

        requestAnimationFrame();

        element.addEventListener( 'click', function() toggleAnimationFrame(), false );

        /*
        var observer = new js.html.MutationObserver( function(r,o) {
            trace(r);
            trace(o);
        });
        var config = { attributes: true, childList: true, characterData: true };
        observer.observe( element, config);

        //canvas.addEventListener( 'resize', handleResize, false );
        */
    }

    public function dispose() {
        cancelAnimationFrame();
        preview = null;
    }

    function update( time : Float ) {
        animationFrameId = window.requestAnimationFrame( update );
        if( preview != null ) {
            if( element.offsetWidth != preview.canvas.width || element.offsetHeight != preview.canvas.height ) {
                preview.resize( element.offsetWidth, element.offsetHeight );
            }
            preview.render();
        }
    }

    inline function toggleAnimationFrame() {
        if( animationFrameId == null ) requestAnimationFrame() else cancelAnimationFrame();
    }

    inline function requestAnimationFrame() {
        animationFrameId = window.requestAnimationFrame( update );
    }

    inline function cancelAnimationFrame() {
        if( animationFrameId != null ) {
            window.cancelAnimationFrame( animationFrameId );
            animationFrameId = null;
        }
    }

    /*
    function handleResize(e) {
        preview.resize( element.offsetWidth, element.offsetHeight );
    }
    */

    function handleClick(e) {
        if( animationFrameId == null )
            requestAnimationFrame()
        else
            cancelAnimationFrame();
    }

}
