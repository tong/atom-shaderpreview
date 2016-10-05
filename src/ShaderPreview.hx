
import js.Browser.document;
import atom.CompositeDisposable;
import atom.File;

using StringTools;
using haxe.io.Path;

private typedef ShaderPreviewState = Dynamic;

@:keep
@:expose
class ShaderPreview extends FragmentShaderView {

    static inline function __init__() {

        untyped module.exports = ShaderPreview;

		disposables = new CompositeDisposable();
        disposables.add( Atom.views.addViewProvider( ShaderPreview, function(shader:ShaderPreview) {
            return new ShaderPreviewView( shader ).element;
        }));
    }

    static inline var NAME = 'shaderpreview';
    static inline var PREFIX = '$NAME://';

    static var allowedFileTypes = ['frag'];
    static var disposables : CompositeDisposable;

    static function activate( state : ShaderPreviewState ) {

        trace( 'Atom-shaderpreview' );

        //Atom.workspace.observeTextEditors( function(e) trace(e) );

        disposables.add( Atom.workspace.addOpener( openURI ) );
        disposables.add( Atom.commands.add( 'atom-workspace', '$NAME:preview', function(e) {
            var path : String = untyped e.target.getAttribute( 'data-path' );
            if( sys.FileSystem.exists( path ) )
                Atom.workspace.open( '$PREFIX$path' );
        } ) );

        Atom.workspace.onDidDestroyPaneItem( function(e){
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
            var preview = new ShaderPreview( uri.substr( PREFIX.length ) );
            disposables.add( untyped preview );
            return preview;
        }
        return null;
    }

    /*
    static function consumeStatusBar( pane ) {
        //pane.addRightTile( { item: new Statusbar().element, priority:0 } );
    }
    */

    ////////////////////////////////////////////////////////////////////////////

	var file : File;

	function new( path : String ) {

        super( document.createCanvasElement(), Atom.config.get( 'shaderpreview.quality' ) );
		this.file = new File( path );

        compile( sys.io.File.getContent( file.getPath() ) );
        //render();
	}

	public inline function serialize() {
        return {
            deserializer: 'ShaderPreview',
            path: file.getPath()
        }
    }

    /*
	public  function dispose() {
	}
    */

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

	public static inline function deserialize( state : Dynamic ) {
		return new ShaderPreview( state.path );
	}
}
