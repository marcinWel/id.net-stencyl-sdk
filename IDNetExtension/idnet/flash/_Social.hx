package idnet.flash;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Stage;
import flash.errors.Error;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;
import flash.utils.Object;
import openfl.display.Sprite;
import idnet.common.events.IDNetEvent;

/*typedef Idnet = 
{	
	//
	// Public properties
	//
	var data(default, default):Dynamic;		// data from last response
	var isLoggedIn(default, null):Bool;		// is user logged in
	var type(default, default):String;		// last type of response
	var userdata(default, null):Dynamic;	// last saved user data w/o connecting
	var _protection(default, null):Dynamic;
	
	//
	// Public methods
	//
	function getPlayersScore():Void;
	function init(stageRef:Stage, appId:String, appSecret:String, verbose:Bool, showPreloader:Bool, protection:Bool):Void;
	function InterfaceOpen():Bool;		 							// if interface is visible
	function removeUserData(key:String):Dynamic;					// 
	function retrieveUserData(key:String):Dynamic;					// 
//	function sessionTestResponse(_data:Dynamic):Dynamic;			// GR:TODO:some debug function i guess
	function submitScore(score:Int):Void;							// submit user score to scoreboard
	function submitUserData(key:String, data:Dynamic):Dynamic;		// submit user data
	function submitProfileImage(picture:Sprite, type:String):Void;	// picture profile
	function toggleInterface(type:String):Void;						// 'login', 'registration', 'scoreboard', or null
	function logout():Void;											// 
}*/

class _Social extends SocialBase {
    
	//
	// Static helper variables
	//
	private static inline var EVENT:String = 'IDNET';
	private static inline var EVENT_LOGIN:String = 'login';
	private static inline var EVENT_SUBMIT:String = 'submit';
	private static inline var EVENT_RETRIEVE:String = 'retrieve';
	
	
	//
	// Constructor
	//
	public function new() {
		super();
    }

	
	//
	// Variables
	//
	private var _idnet:Object;
	
	
	//
	// API
	//
	override public function init():Void 
	{
		//super.init();
		Security.allowInsecureDomain('*');
		Security.allowDomain('*');
		
		var context:LoaderContext = new LoaderContext();
		context.applicationDomain = ApplicationDomain.currentDomain;
		if (Security.sandboxType != 'localTrusted') {
			context.securityDomain = SecurityDomain.currentDomain;
		}
		
		var sdkUrl:String = "https://www.id.net/swf/idnet-client.swc?=" + Date.now();
		var request:URLRequest = new URLRequest(sdkUrl);
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSWCLoaded);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onSWCLoadingFailed);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, onSWCLoadingFailed);
		loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSWCLoadingFailed);
		try
		{
			loader.load(request, context);
		}
		catch (new_error:Error) 
		{
			trace("error on loading: " + new_error);
		}
	}
	
	//
	// ID.net sdk callbacks
	//
	
	private function onSWCLoaded(e:Event):Void 
	{
		var loader = e.target.loader;
		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSWCLoaded);
		loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onSWCLoadingFailed);
		loader.contentLoaderInfo.removeEventListener(IOErrorEvent.NETWORK_ERROR, onSWCLoadingFailed);
		loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSWCLoadingFailed);
		
		if (e.target.content == null) 
		{
			d.dispatch(IDNetEvent.ID_INITIALIZE_FAILED);
			return;
		}
		
		_idnet = e.target.content;
		_idnet.addEventListener(EVENT, handleIDnetEvents);
		
		params.stageRef.addChild(_idnet);
		_idnet.init(
			params.stageRef, 
			params.appId, 
			params.appSecret, 
			params.debug,
			params.preload,
			true
		);
		
		IDNetWrapper.isLoaded = true;
		d.dispatch(IDNetEvent.ID_INITIALIZE_COMPLETE);
	}
	
	private function onSWCLoadingFailed(e:Event):Void 
	{
		d.dispatch(IDNetEvent.ID_INITIALIZE_FAILED);
		
		//stub
		//throw e;
		trace("SWC Loading Failed, event:" + e);
	}
	
	private function handleIDnetEvents(e:Event):Void
	{
		if(_idnet.type == 'protection') {
			if(_idnet._protection != null && _idnet._protection.isBlacklisted()){
				IDNetWrapper.inBlackList = true;
			}
			return;
		} else if (_idnet.type == 'login') {
			if (isError()) {
				if (_idnet.data.error == 'Key not found' ) {
					//stub
					return;
				}
				this.authorized = false;
				d.dispatch(IDNetEvent.ID_AUTH_FAIL);
				trace('Error: ' + _idnet.data.error);
			} else {
				IDNetWrapper.userName = _idnet.data.user.nickname;
				IDNetWrapper.sessionKey = _idnet.data.sessionKey;
				trace('logged in');
				this.authorized = true;
				d.dispatch(IDNetEvent.ID_AUTH_COMPLETE);
			}
		} else 
		if (_idnet.type == 'submit') {
			if (isError()) {
				trace('Error: '+_idnet.data.error);
			} else {
				trace('Status: ' + _idnet.data.status);
			}
		} else 
		if (_idnet.type == 'retrieve') {
			if (isError()) {
				trace('Error: '+_idnet.data.error);
			} else {
				trace('Key '+_idnet.data.key);
				trace('Data: '+_idnet.data.jsondata);
				IDNetWrapper.loadData(_idnet.data.jsondata);
			}
		} else 
		if (_idnet.type == 'scoreboard') 
		{
			if (isError()) 
			{
				trace('Error: '+_idnet.data.error);
			}
			trace("scoreboard type");
		} else
		{
			trace('unhandled event type: ' + _idnet.type);
		}
	}
	
	private function isError():Bool { return _idnet.data.error != null && _idnet.data.error.length != 0; }
	
	override public function register():Void 
	{
		if (_idnet.isLoggedIn) {
			d.dispatch(IDNetEvent.ID_AUTH_COMPLETE);
		} else {
			_idnet.toggleInterface('registration');
		}
	}
	
	override public function loginPopup():Void 
	{
		if (_idnet.isLoggedIn) {
			d.dispatch(IDNetEvent.ID_AUTH_COMPLETE);
		} else {
			_idnet.toggleInterface('login');
		}
	}
	
	override public function scoreboard(table:String, highest:Bool = true, allowDuplicates:Bool = false, useMilliseconds:Bool = false):Void 
	{
		_idnet.advancedScoreList(table, highest, allowDuplicates, useMilliseconds);
	}
	
	override public function removeUserData(key:String):Void { 
		if (_idnet.isLoggedIn) {
			_idnet.removeUserData(key);
		} else {
			_idnet.toggleInterface('login');
		}
	}
	
	override public function retrieveUserData(key:String):Void { 
		if (_idnet.isLoggedIn) {
			_idnet.retrieveUserData(key);
		} else {
			_idnet.toggleInterface('login');
		}
	}
	
	override public function submitUserData(key:String, data:String):Void { 
		if (_idnet.isLoggedIn) {
			_idnet.submitUserData(key, data);
		} else {
			_idnet.toggleInterface('login');
		}
	}
	
	override public function submitScore(table:String, score:Int, playerName:String, highest:Bool = true, allowDuplicates:Bool = false, useMilliseconds:Bool = false):Void
	{		
		if (_idnet.isLoggedIn) 
		{
			_idnet.advancedScoreSubmitList(score, table, playerName, highest, allowDuplicates, useMilliseconds);
		} 
		else 
		{
			_idnet.advancedScoreList(table, highest, allowDuplicates, useMilliseconds);
		}
	}
	
	override public function achievementsList():Void
	{
		if (_idnet.isLoggedIn) {
			_idnet.toggleInterface('achievements');
		} else {
			_idnet.toggleInterface('login');
		}
	}
	
	override public function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void
	{
		if (_idnet.isLoggedIn) {
			_idnet.achievementsSave(achName, achKey, playerName, overwrite, allowDuplicates);
		} else {
			_idnet.toggleInterface('login');
		}
	}
	override public function InterfaceOpen():Bool
	{
		return _idnet.InterfaceOpen();
	}
	
	override public function logout() 
	{
		if (_idnet.isLoggedIn) {
			this.authorized = false;
			_idnet.logout();
			d.dispatch(IDNetEvent.ID_LOGOUT);
		} else {
			//trace('already logged out');
		}
	}
}
