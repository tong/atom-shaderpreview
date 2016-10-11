
import js.Browser.document;
import js.Browser.window;
import js.html.DivElement;
import atom.CompositeDisposable;
import atom.Disposable;
import atom.File;

using StringTools;
using haxe.io.Path;

private typedef ShaderPreviewState = Dynamic;

@:keep
@:expose
class ShaderPreview extends FragmentShaderView {

    static inline function __init__() {
        untyped module.exports = ShaderPreview;
    }

    static inline var NAME = 'shaderpreview';
    static inline var PREFIX = '$NAME://';

    static var allowedFileTypes = ['frag'];
    static var disposables : CompositeDisposable;

    static function activate( state : ShaderPreviewState ) {

        trace( 'Atom-shaderpreview' );

        disposables = new CompositeDisposable();

        //Atom.workspace.observeTextEditors( function(e) trace(e) );

        disposables.add( Atom.workspace.addOpener( openURI ) );
        disposables.add( Atom.commands.add( 'atom-workspace', '$NAME:preview', function(e) {
            var path : String = untyped e.target.getAttribute( 'data-path' );
            if( sys.FileSystem.exists( path ) )
                Atom.workspace.open( '$PREFIX$path' );
        } ) );

        Atom.workspace.onDidDestroyPaneItem( function(e){
            //TODO
            try {
                if( Type.getClassName( Type.getClass( e.item ) ) == 'ShaderPreview' ) {
                    e.item.dispose();
                }
            } catch(e:Dynamic) {
                trace(e);
            }
        });
    }

    static function deactivate() {
        disposables.dispose();
    }

    static function openURI( uri : String ) {
        if( uri.startsWith( PREFIX ) ) {
            var preview = new ShaderPreview( { path: uri.substr( PREFIX.length ) } );
            //disposables.add( untyped preview );
            return preview;
        }
        return null;
    }

    /*
    static function consumeStatusBar( pane ) {
        pane.addRightTile( { item: new StatusbarView(), priority:0 } );
    }
    */

    static inline function deserialize( state : Dynamic ) {
        return new ShaderPreview( state );
    }

    ////////////////////////////////////////////////////////////////////////////

	var file : File;
	var fileChangeListener : Disposable;
    var element : DivElement;
    var animationFrameId : Int;

	function new( state ) {

        super( document.createCanvasElement(), Atom.config.get( 'shaderpreview.quality' ) );
		this.file = new File( state.path );

        element = document.createDivElement();
        element.classList.add( 'shaderpreview' );
        element.appendChild( canvas );

        fileChangeListener = file.onDidChange( handleSourceFileChange );
        file.read( true ).then(function(src) {
            try {
                compile( src );
            } catch(e:Dynamic) {
                Atom.notifications.addWarning( e );
            }
        });

        element.addEventListener( 'click', function() toggleAnimationFrame(), false );

        requestAnimationFrame();
	}

	public function serialize() {
        return {
            deserializer: 'ShaderPreview',
            path: file.getPath()
        }
    }

	public override function dispose() {
        super.dispose();
        fileChangeListener.dispose();
	}

	public inline function getPath() {
        return file.getPath();
    }

    public inline function getIconName() {
        return 'git-branch';
    }

    public inline function getTitle() {
        return file.getBaseName();
    }

    public inline function getURI() {
        return "file://" + file.getPath().urlEncode();
    }

    function update( time : Float ) {
        animationFrameId = window.requestAnimationFrame( update );
        if( element.offsetWidth != canvas.width || element.offsetHeight != canvas.height ) {
            resize( element.offsetWidth, element.offsetHeight );
        }
        render();
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

    function handleSourceFileChange() {
        file.read( true ).then(function(src){
            compile( src );
        });
    }

    function handleClick(e) {
        if( animationFrameId == null )
            requestAnimationFrame()
        else
            cancelAnimationFrame();
    }
}
