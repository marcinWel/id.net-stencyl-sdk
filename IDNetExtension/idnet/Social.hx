package idnet;
import idnet.common.events.PostStatusEvent;
import idnet.common.FeedParameters;
import idnet.common.InitParameters;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.Lib;

interface IDispatcher {
	function dispatch(evName:String):Void;
	function dispatchPostStatus(evName:String, postId:String = null, failReason:String = null):Void;
}

class Social extends EventDispatcher implements IDispatcher {
	
	//
	// Singleton routines
	//
	
    private static var _instance:Social;
    public static var i(get, never):Social;
    private static function get_i():Social {

        if (_instance == null) _instance = new Social();
        return _instance;
    }
	
	
	//
	// Constructor
	//

    public function new() {
		super();
		
        #if js
        _social = new idnet.js._Social();
        #elseif flash
        _social = new idnet.flash._Social();
        #end
    }

    public var _social:SocialBase;

	
	//
	// API
	//
	
    public function init(
			appId:String,
			appSecret:String, 
			debug:Bool = false,
			preload:Bool = false,
			status:Bool = true, 
			responseType:String = 'code',
			redirectUri:String = 'https://mocksite.com/auth/idnet/callback',
			channelUrl:String = null,
			meta:Dynamic = null
		):Void
    {
		_social.injectDispatcher(this);
		#if js
		_social.injectInitParams(new InitParameters(appId, status, responseType, redirectUri, channelUrl, meta));
		#elseif flash
		_social.injectInitParams(new InitParameters(Lib.current.stage, appId, appSecret, debug, preload));
		#end
			
        _social.init();
    }
	
	public function isAuthorized():Bool { return _social.authorized; }

	public function register():Void { _social.register(); }
	
	public function loginPopup():Void  {_social.loginPopup(); }
	
	public function scoreboard(table:String, highest:Bool = true, allowDuplicates:Bool = false, useMilliseconds:Bool = false):Void 
	{
		_social.scoreboard(table, highest, allowDuplicates, useMilliseconds);
	}
	
	public function removeUserData(key:String):Void
	{
		_social.removeUserData(key);
	}
	
	public function retrieveUserData(key:String):Void
	{ 
		_social.retrieveUserData(key);
	}
	
	public function submitUserData(key:String, data:String):Void
	{ 
		_social.submitUserData(key, data);
	}
	
	public function submitScore(table:String, score:Int, playerName:String, highest:Bool = true, allowDuplicates:Bool = false, useMilliseconds:Bool = false):Void
	{
		_social.submitScore(table, score, playerName, highest, allowDuplicates, useMilliseconds);
	}
	
	public function achievementsList():Void
	{
		_social.achievementsList();
	}
	
	public function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void
	{
		_social.achievementsSave(achName, achKey, playerName, overwrite, allowDuplicates);
	}
	
	public function InterfaceOpen():Bool
	{
		return _social.InterfaceOpen();
	}
	
	public function postToFeed(params:FeedParameters):Void { _social.postToFeed(params); }
	
	public function logout():Void { _social.logout();  }
	
	//
	// Implemented from IDispatcher:
	//
	
	public function dispatch(evName:String):Void 
	{
		this.dispatchEvent(new Event(evName));
	}
	
	public function dispatchPostStatus(evName:String, postId:String = null, failReason:String = null):Void
	{
		this.dispatchEvent(new PostStatusEvent(evName, postId, failReason));
	}
}
