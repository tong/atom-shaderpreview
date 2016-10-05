
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
    var canvas : CanvasElement;
    var view : ShaderView;
    var animationFrameId : Int;

    public function new( preview : ShaderPreview ) {

        this.preview = preview;

        element = document.createDivElement();
        element.classList.add( 'shaderpreview' );

		canvas = document.createCanvasElement();
		element.appendChild( canvas );

        element.addEventListener( 'DOMNodeInserted', handleDOMInsert, false );

        //canvas.addEventListener( 'resize', handleResize, false );
    }

    /*
    public function attach() {
        trace("attach");
    }

    public function attached() {
        trace("attached");
    }
    */

    public function dispose() {
        cancelAnimationFrame();
    }

    function handleDOMInsert(e) {

        trace("handleDOMInsert");

        element.removeEventListener( 'DOMNodeInserted', handleDOMInsert );

        view = new ShaderView( canvas );
        view.resize( element.offsetWidth, element.offsetHeight );
        view.compile( sys.io.File.getContent( preview.getPath() ) );
        view.render();

        element.addEventListener( 'click', handleClick, false );

        requestAnimationFrame();
    }

    function update( time : Float ) {
        animationFrameId = window.requestAnimationFrame( update );
        if( view != null ) {
            view.render();
        }
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

    function handleClick(e) {
        if( animationFrameId == null )
            requestAnimationFrame()
        else
            cancelAnimationFrame();
    }

    function handleResize(e) {
        trace(e.target);
        view.resize( element.offsetWidth, element.offsetHeight );
        //canvas.width = element.innerWidth;
        //canvas.height = element.innerHeight;
        //trace(element.innerWidth,element.innerHeight);
    }
}
