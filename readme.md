## Documentation

<b>Step 1</b> - Click the green download button to get the stencyl id.net extension.

<img src="doc-images/step1.png">

Then install it and you'll see new code blocks.

<img src="doc-images/step1.2.png">


<b>Step 2</b> - You should have 3 different scenes.

 1. To load local saves (loadScene)
 2. For banned sites (lockedScene)
 3. To load online saves (mainMenu)
 
<img src="doc-images/step2.png">
 
Duplicate the game attributes you want to save in cloud (use the prefix "cloud" - it's useful)
 
<img src="doc-images/step2.1.png">
 
 
<b>Step 3</b> - Scene: loadScene

Example code for loading local saves

<img src="doc-images/step3.png">

First, we must initialize the app. After loading, set your game attributes with the prefix "cloud" as default. This is an important part. Also, create a game attribute `NeedLoadingCloud`.


<b>Step 4</b> - Scene: mainMenu

Example code for loading id.net saves.


<img src="doc-images/step4.png">

This code should be in for the update event. Before loading, you must save your non-cloud game attributes in local attributes (create local-blue attributes for it), and after loading use local-blue attributes to feed in their respective saved values. This is very important.

Use the following code for banned sites.

<img src="doc-images/step4.1.png">


<b>Step 5</b> - Example code for saving (id.net and local).

<img src="doc-images/step5.png">


<b>Step 6</b> - Example code for unlocking achievements.

<img src="doc-images/step6.png">

To display the achievements menu.

<img src="doc-images/step6.1.png">


<b>Step 7</b> - Example code for submitting high scores

<img src="doc-images/step7.png">

To show the high scores menu.

<img src="doc-images/step7.1.png">


<b>Step 8</b> - Example code for any menu button which might be covered by id.net UI

First, we must check if a id.net UI is open or not.

<img src="doc-images/step8.png">
<img src="doc-images/step8.1.png">


<b>Step 9</b> - Example code for choosing save type (local or id.net)

<img src="doc-images/step9.png">

<b>Step 10</b> - LockedScene

A LockedScene can look something like this.

<img src="doc-images/step10.png">

Add actor to the lockedScene.

<img src="doc-images/step10.1.png">

Example code for this actor. This code lets the player highlight and copy/paste the correct game link in their browser.

<img src="doc-images/step10.2.png">


```
//import:
import flash.text.TextField;
import flash.text.TextFormat;

//created:
var txt = new openfl.text.TextField();
		txt.width = 500;
		txt.height = 500;
		txt.x = 190;
		txt.y = 200;
		txt.wordWrap = true;
		txt.type = INPUT;
		txt.mouseEnabled = true;
		txt.selectable = true;
		txt.textColor = 0xffffff;
		txt.multiline = true;
		txt.wordWrap = true;
var lockText = "http://www.y8.com/games/game_name";
		txt.text = lockText;
		Engine.engine.root.parent.addChild(txt);
var formato:TextFormat = new TextFormat();
formato.size = 28;
formato.color=0xFF0033;
txt.setTextFormat(formato);

//updated:
txt.text = "http://www.y8.com/games/game_name"; 
```
