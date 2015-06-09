window = this;

gameEngine = {	
	geContext: new _gameEngine.GEContext(),
	geMainCanvas: new _gameEngine.GEMainCanvas(),
	geLocalStorage: new _gameEngine.GELocalStorage(),
	geTouchInput: new _gameEngine.GETouchInput()
};

Function.prototype.bind = function(bind) {
	var self = this;
	return function(){
		var args = Array.prototype.slice.call(arguments);
		return self.apply(bind || null, args);
	};
};

TouchPoint = function(screenX, screenY, clientX, clientY) {
	//gameEngine.geContext.log("new TouchPoint",screenX,screenY,clientX,clientY);
	this.screenX = screenX;
	this.screenY = screenY;
	this.clientX = clientX;
	this.clientY = clientY;
	this.pageX = clientX;
	this.pageY = clientY;
	return this;
}

TouchEvent = function(screenX, screenY, clientX, clientY){
	//gameEngine.geContext.log("new TouchEvent",screenX,screenY,clientX,clientY);
	var t = new TouchPoint(screenX,screenY,clientX,clientY);
	this.screenX = screenX;
	this.screenY = screenY;
	this.clientX = clientX;
	this.clientY = clientY;
	this.pageX = clientX;
	this.pageY = clientY;
	this.touches = [];
	this.changedTouches = [];
	this.targetTouches = [];
	this.touches.push(t);
	this.changedTouches.push(t);
	this.targetTouches.push(t);
	this.preventDefault = function(){};
	return this;
};

Acceleration = function(aX,aY,aZ){
	this.x = aX;
	this.y = aY;
	this.z = aZ;
	return this;
}

RotationRate = function(rA,rB,rG){
	this.alpha = rA;
	this.beta = rB;
	this.gamma = rG;
	return this;
}

DeviceMotionEvent = function(aX, aY, aZ, rA,rB,rG){
	//gameEngine.geContext.log("DeviceMotionEvent");
	this.acceleration = new Acceleration(aX,aY,aZ);
	this.rotationRate = new RotationRate(rA,rB,rG);
	return this;
};

//1.console obj
console = {
	log: function() {
		var args = Array.prototype.join.call(arguments, ', ');
		gameEngine.geContext.log( args );
	}
};

//2.uexCanvas obj
uexCanvas = gameEngine.geMainCanvas;
//propertys
uexCanvas.touchStartCallback = null;
uexCanvas.touchMoveCallback = null;
uexCanvas.touchEndCallback = null;
uexCanvas.touchCancelCallback = null;
//callback funcs
uexCanvas.onshow = function(){};
uexCanvas.onhide = function(){};
uexCanvas.updatefps = function(){};
uexCanvas.ontouchstart = function(screenX, screenY, clientX, clientY) {
	console.log("callback", screenX,screenY,clientX,clientY);
	if (uexCanvas.touchStartCallback!=null) {
		uexCanvas.touchStartCallback(new TouchEvent(screenX, screenY, clientX, clientY));
	}
};
uexCanvas.ontouchmove = function(screenX, screenY, clientX, clientY) {
	if (uexCanvas.touchMoveCallback!=null) {
		uexCanvas.touchMoveCallback(new TouchEvent(screenX, screenY, clientX, clientY));
	}
};
uexCanvas.ontouchend = function(screenX, screenY, clientX, clientY) {
	if (uexCanvas.touchEndCallback!=null) {
		uexCanvas.touchEndCallback(new TouchEvent(screenX, screenY, clientX, clientY));
	}
};
uexCanvas.ontouchcancel = function(screenX, screenY, clientX, clientY) {
	if (uexCanvas.touchCancelCallback) {
		uexCanvas.touchCancelCallback(new TouchEvent(screenX, screenY, clientX, clientY));
	}
};
//API funcs
uexCanvas.getContext = function(inContextId){ 
	if(inContextId=="2d") {
		return gameEngine.geMainCanvas; 
	} else {
		return null;
	}
};
uexCanvas.addEventListener = function(type, callback, bubble){
	if(type == 'touchstart') {
		uexCanvas.touchStartCallback = callback;
		gameEngine.geTouchInput.touchStart(uexCanvas.ontouchstart);
	} else if(type == 'touchmove') {
		uexCanvas.touchMoveCallback = callback;
		gameEngine.geTouchInput.touchMove(uexCanvas.ontouchmove);
	} else if(type == 'touchend') {
		uexCanvas.touchEndCallback = callback;
		gameEngine.geTouchInput.touchEnd(uexCanvas.ontouchend);
	} else if(type == 'touchcancel') {
		uexCanvas.touchCancelCallback = callback;
		gameEngine.geTouchInput.touchCancel(uexCanvas.ontouchcancel);
	}
};
uexCanvas.removeEventListener = function(type, callback, bubble){
	if(type == 'touchstart') {
		uexCanvas.touchStartCallback = null;
		gameEngine.geTouchInput.touchStart(null);
	} else if(type == 'touchmove') {
		uexCanvas.touchMoveCallback = null;
		gameEngine.geTouchInput.touchMove(null);
	} else if(type == 'touchend') {
		uexCanvas.touchEndCallback = null;
		gameEngine.geTouchInput.touchEnd(null);
	} else if(type == 'touchcancel') {
		uexCanvas.touchCancelCallback = null;
		gameEngine.geTouchInput.touchCancel(null);
	}
};

//3. uexBrowserView obj
uexBrowserView = {
	evaluateScript: function(js){
		console.log(js);
		gameEngine.geContext.evaluateScriptInBrwView(js);
	}
};

//4. window obj
window.deviceMotionCallback = null;
window.ondevicemontion = function(aX, aY, aZ, rA,rB,rG) {
	if (window.deviceMotionCallback) {
		window.deviceMotionCallback(new DeviceMotionEvent(aX, aY, aZ, rA,rB,rG));
	}
};
devicePixelRatio = gameEngine.geContext.devicePixelRatio;
innerWidth = gameEngine.geContext.screenWidth;
innerHeight = gameEngine.geContext.screenHeight;
screen = {
availWidth: innerWidth,
availHeight: innerHeight
};
navigator = {
userAgent: gameEngine.geContext.userAgent
};
onorientationchange = function(){};
setTimeout = function(cb, t) { 
	return gameEngine.geContext.setTimeout(cb, t); 
};
setInterval = function(cb, t){ 
	return gameEngine.geContext.setInterval(cb, t); 
};
clearTimeout = function(id){ 
	return gameEngine.geContext.clearTimeout(id); 
};
clearInterval = function(id){ 
	return gameEngine.geContext.clearInterval(id); 
};
alert = function(msg) {
    gameEngine.geContext.alert(msg);
}
addEventListener = function(type, callback){
	if(type == 'devicemotion') {
		console.log("devicemotion");
		window.deviceMotionCallback = callback;
		gameEngine.geTouchInput.deviceMotion(window.ondevicemontion);
	}
};
removeEventListener = function(type, callback, bubble){
	if(type == 'devicemotion') {
		window.deviceMotionCallback = null;
		gameEngine.geTouchInput.deviceMotion(null);
	}
};
scrollTo = function(x,y){};


//5. localStorage obj
localStorage = gameEngine.geLocalStorage;


//6. HTMLElement class
HTMLElement = function( tagName ){ 
	this.tagName = tagName;
	this.children = [];
};
HTMLElement.prototype.appendChild = function( element ) {
	this.children.push( element );
	
	if(element.tagName == 'script') {
		var id = gameEngine.geContext.setTimeout( function(){
			gameEngine.geContext.include( element.src ); 
			if( element.onload ) {
				element.onload();
			}
		}, 1);
	}
};

//7. Image class
Image = function() {
    var _src = '';
    /*
    failed: false,
    loadCallback: null,
     */
    
    this.prototype = new HTMLElement('image');

    this.data = null;
    this.src = null;//instead of path
    this.height = 0;
    this.width = 0;
    this.loaded = false;
    this.onabort = null;
    this.onerror = null;
    this.onload = null;//instead of loadCallback
    this._onload = function( width, height ) {
		console.log("this._onload in");
		this.width = width;
		this.height = height;
		this.loaded = true;
	};
    this._onload2 = function() {
		console.log("this._onload2 in");
		if( this.onload ) {
			console.log("this.onload in");
			this.onload( this.src, true );
		}
	};
    this.__defineGetter__("src", function(){
        return _src;
    });
    
    this.__defineSetter__("src", function(val){
        _src = val;
		//console.log('img __defineSetter__ src value is ',val);
        this.data = new _gameEngine.GETexture( this.src, this._onload.bind(this) );
        this._onload2();//call after assigning this.data, which needs to be available for the onload
    });
    
    return this;
}

//8. document obj
document = {
	location: {href: 'index'},
	
	head: new HTMLElement('head'),
	body: new HTMLElement('body'),
	
	createElement: function(name) {
		if( name == 'canvas' ) {
			return new _gameEngine.GECanvas();
		} else if (name == 'image') {
			return new Image();
        } else {
            return new HTMLElement('script');
        }
	},
	
	getElementById: function(id){	
		return null;
	},
	
	getElementsByTagName: function(tagName){
		if(tagName == 'head') {
			return [document.head];
		}
	},
	
	addEventListener: function(type, callback){
		if(type == 'DOMContentLoaded') {
			setTimeout( callback, 1 );
		}
	}
};
Audio = _gameEngine.GEAudio;



