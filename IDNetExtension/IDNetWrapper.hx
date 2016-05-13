package;
import haxe.ds.StringMap;
import idnet.Social;
import idnet.SocialBase;
import idnet.HashToJson;
import com.stencyl.Engine;
import haxe.Json;
import openfl.utils.Object;

class IDNetWrapper {
	public static var instance:Social;
	public static var isLoaded:Bool;
	public static var inBlackList:Bool;
	public static var userName:String;
	public static var sessionKey:String;
	public static var retrieveUserDataCallback:Void->Void;
	public static var saveUserDataCallback:Bool->Void;

    public static function initialize(appId:String, appSecret:String, debug:Int = 0, preload:Int = 0):Void
    {
		trace("appId: "+appId+" appSecret:"+appSecret);
		
		IDNetWrapper.inBlackList = false;
		IDNetWrapper.instance = new Social();
		IDNetWrapper.instance.init(appId, appSecret, (debug==0?false:true), (preload==0?false:true));
    }
	
	public static function showPopup(name:Int):Void
    {
		if(IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			switch(name) {
				case 0: IDNetWrapper.instance.register();
				case 1: IDNetWrapper.instance.loginPopup();
				case 2: IDNetWrapper.instance.achievementsList();
			}
		}
	}
	
	public static function scoreboard(table:String, highest:Bool = true, allowDuplicates:Bool = false, useMilliseconds:Bool = false):Void
    {
		IDNetWrapper.instance.scoreboard(table, highest, allowDuplicates, useMilliseconds);
	}
	
	public static function removeUserData(key:String, onComplete:Void->Void=null):Void {
		if(IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			IDNetWrapper.instance.removeUserData(key);
		}
	}
	
	public static function retrieveUserData(key:String, onComplete:Void->Void=null):Void
	{ 
		if (IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			IDNetWrapper.instance.retrieveUserData(key);
			
			IDNetWrapper.retrieveUserDataCallback = onComplete;
		}
	}
	
	public static function loadData(dataString:String):Void
	{
		if (IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			var data:Object = null;
			dataString = StringTools.replace(dataString, "'", "\'");
			try {
				var jsonData:Dynamic = Json.parse(dataString);
				data = jsonData.h;
			} catch (e:Dynamic) {
				trace("JSON parsing error: " + e);
				trace("Raw json: " + dataString);
			}
			if(data != null && Engine.engine.gameAttributes != null) {
				for (key in Engine.engine.gameAttributes.keys()) {
					if (data.hasOwnProperty(key)) {
						Engine.engine.gameAttributes.set(key, Reflect.field(data, key));
					}
				}
			}
			
			if(IDNetWrapper.IDNetWrapper.retrieveUserDataCallback != null) {
				Reflect.callMethod(IDNetWrapper, IDNetWrapper.retrieveUserDataCallback, []);
			}
		}
	}
	
	public static function submitUserData(key:String, saveUserDataCallback:Bool->Void=null):Void
	{ 
		if(IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			var data:String = "";
			if(Engine.engine.gameAttributes != null) {
				data = Json.stringify(Engine.engine.gameAttributes);
			}
			trace("data: "+data);
			
			IDNetWrapper.instance.submitUserData(key, data);
			
			if(IDNetWrapper.IDNetWrapper.saveUserDataCallback != null) {
				Reflect.callMethod(IDNetWrapper, IDNetWrapper.saveUserDataCallback, [true]);
			}
		} else {
			if(IDNetWrapper.IDNetWrapper.saveUserDataCallback != null) {
				Reflect.callMethod(IDNetWrapper, IDNetWrapper.saveUserDataCallback, [false]);
			}
		}
	}
	
	public static function submitScore(table:String, score:Int, playerName:String, highest:Bool = true, allowDuplicates:Bool = false, useMilliseconds:Bool = false):Void
	{
		if(IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			IDNetWrapper.instance.submitScore(table, score, playerName, highest, allowDuplicates, useMilliseconds);
		}
	}
	
	public static function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void
	{
		IDNetWrapper.instance.achievementsSave(achName, achKey, playerName, overwrite, allowDuplicates);
	}
	
	public static function isAuthorized():Bool
	{ 
		if(IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			return IDNetWrapper.instance.isAuthorized(); 
		} else {
			return false;
		}
	}
	
	public static function InterfaceOpen():Bool
	{ 
		if(IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			return IDNetWrapper.instance.InterfaceOpen();
		} else {
			return false;
		}
	}
	
	public static function isInit():Bool
	{
		return IDNetWrapper.isLoaded;
	}
	
	public static function logout():Void
	{ 
		if(IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			IDNetWrapper.instance.logout();  
		}
	}
	
	public static function getName():String
	{
		if(IDNetWrapper.instance != null && IDNetWrapper.isLoaded) {
			return IDNetWrapper.userName;
		} else {
			return "";
		}
	}
	
	public static function domainInBlackList():Bool
	{
		return IDNetWrapper.inBlackList;
	}
}