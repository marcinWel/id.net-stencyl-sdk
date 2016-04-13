package idnet;
import idnet.common.FeedParameters;
import idnet.common.InitParameters;
import idnet.Social.IDispatcher;

class SocialBase
{
	public function new() { }
	
	private var params:InitParameters;
	private var d:IDispatcher;
	
	@:allow(idnet.Social)
	private var authorized:Bool = false;
	
	@:allow(idnet.Social)
	private function injectInitParams(params:InitParameters):Void
	{
		this.params = params;
	}
	
	@:allow(idnet.Social)
	private function injectDispatcher(dispatcher:IDispatcher):Void 
	{
		this.d = dispatcher;
	}
	
    public function init():Void 
	{
		//stub
    }

	public function register():Void 
	{
		//stub
	}
	
	public function loginPopup():Void 
	{
		//stub
	}
	
	public function scoreboard():Void 
	{
		//stub
	}
	
	public function removeUserData(key:String):Void {
	
	}
	
	public function retrieveUserData(key:String):Void
	{ 

	}
	
	public function submitUserData(key:String, data:String):Void
	{ 
	
	}
	
	public function submitScore(table:String, score:Int, playerName:String, highest:Bool = true, allowDuplicates:Bool = false):Void
	{
		
	}
	
	public function achievementsList():Void
	{
	
	}
	
	public function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void
	{

	}
	
	public function InterfaceOpen():Bool
	{
		return false;
	}
	
	public function postToFeed(params:FeedParameters):Void 
	{
		//stub
	}
	
	public function logout() 
	{
		//stub
	}
}