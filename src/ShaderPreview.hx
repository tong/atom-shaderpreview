
import js.Browser.document;
import js.html.AudioElement;
import js.html.audio.AudioContext;
import js.node.Fs;
import atom.CompositeDisposable;
import atom.Disposable;
import atom.File;

using Lambda;
using StringTools;
using haxe.io.Path;

private typedef ShaderPreviewState = Dynamic;

@:keep
@:expose
class ShaderPreview {

    static inline function __init__() {

        untyped module.exports = ShaderPreview;

		disposables = new CompositeDisposable();
        disposables.add( Atom.views.addViewProvider( ShaderPreview, function(shader:ShaderPreview) {
            return new ShaderPreviewView( shader ).element;
        }));
    }

    static inline var PREFIX = 'shaderpreview://';

    static var allowedFileTypes = ['frag'];
    static var disposables : CompositeDisposable;

    static function activate( state : ShaderPreviewState ) {

        trace( 'Atom-shaderpreview' );

        //Atom.workspace.observeTextEditors( function(e) trace(e) );

        disposables.add( Atom.workspace.addOpener( openURI ) );
        disposables.add( Atom.commands.add( 'atom-workspace', 'shaderpreview:preview', function(e) {
            var path : String = untyped e.target.getAttribute( 'data-path' );
            if( sys.FileSystem.exists( path ) )
                Atom.workspace.open( 'shaderpreview://$path' );
        } ) );
    }

    static function deactivate() {
        disposables.dispose();
    }

    static function openURI( uri : String ) {
        if( uri.startsWith( PREFIX ) ) {
            return new ShaderPreview( uri.substr( PREFIX.length ) );
        }
        return null;
    }

    /*
    static function consumeStatusBar( pane ) {
        //pane.addRightTile( { item: new Statusbar().element, priority:0 } );
    }
    */

    ////////////////////////////////////////////////////////////////////////////

	var file : atom.File;

	function new( path : String ) {
		this.file = new File( path );
	}

	public inline function serialize() {
        return {
            deserializer: 'ShaderPreview',
            path: file.getPath()
        }
    }

	public inline function dispose() {
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

	public static inline function deserialize( state : Dynamic ) {
		return new ShaderPreview( state.path );
	}
}
