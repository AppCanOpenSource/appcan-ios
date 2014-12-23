window.open=function(){
}

var uex_s_uex="&";

function uexJoin(a){
	var l = a.length;
	var t = "";
	if (l > 0) {
		t += "?";
		for(var i=0;i<l;i++){
			t += encodeURIComponent(a[i]);
			if (i+1 == l) {
				return t;
			}
			t += uex_s_uex;
		}
	}
	return t;
};

window.uex={
	queue:{	commands:[],
	timer:null
	}
}

uex.exec=function(){
	uex.queue.commands.push(arguments);
	if(uex.queue.timer==null){
		uex.queue.timer = setInterval(uex.runCommand,10);
	}
}

uex.runCommand=function(){
	var arguments = uex.queue.commands[0];
	if(uex.queue.commands.length==0){
		clearInterval(uex.queue.timer);
		uex.queue.timer = null;
	}
	document.location = "uex://"+arguments[0];	
}

window.uexAudio={};
uexAudio.cbOpen = null;
uexAudio.cbRecord = null;
uexAudio.cbOpenSoundPool = null;
uexAudio.onPlayFinished= null;
uexAudio.cbBackgroundRecord = null;
uexAudio.open=function(){
	uex.exec("uexAudio.open/"+uexJoin(arguments));
}
uexAudio.play=function(){
	uex.exec("uexAudio.play/");
}
uexAudio.pause=function(){
	uex.exec("uexAudio.pause/");
}
uexAudio.stop=function(){
	uex.exec("uexAudio.stop/");
}
uexAudio.replay=function(){
	uex.exec("uexAudio.replay/");
}
uexAudio.volumeDown=function(){
	uex.exec("uexAudio.volumeDown/");
}
uexAudio.volumeUp=function(){
	uex.exec("uexAudio.volumeUp/");
}
uexAudio.openPlayer=function(){
	uex.exec("uexAudio.openPlayer/"+uexJoin(arguments));
}
uexAudio.record=function(){
	uex.exec("uexAudio.record/"+uexJoin(arguments));
}
uexAudio.openSoundPool=function(){
	uex.exec("uexAudio.openSoundPool/"+uexJoin(arguments));
}
uexAudio.playFromSoundPool=function(){
	uex.exec("uexAudio.playFromSoundPool/"+uexJoin(arguments));
}
uexAudio.stopFromSoundPool=function(){
	uex.exec("uexAudio.stopFromSoundPool/"+uexJoin(arguments));
}
uexAudio.startBackgroundRecord = function(){
	uex.exec("uexAudio.startBackgroundRecord/"+uexJoin(arguments));
}
uexAudio.stopBackgroundRecord = function(){
	uex.exec("uexAudio.stopBackgroundRecord/");
}
window.uexCall={};
uexCall.call=function(){
	uex.exec("uexCall.call/"+uexJoin(arguments));
}
uexCall.dial=function(){
	uex.exec("uexCall.dial/"+uexJoin(arguments));
}
uexCall.facetime = function(){
	uex.exec("uexCall.facetime/"+uexJoin(arguments));
}

window.uexCamera={};
uexCamera.cbOpen = null;
uexCamera.open=function(){
	uex.exec("uexCamera.open/");
}

window.uexContact={};
uexContact.cbOpen = null;
uexContact.cbAddItem = null;
uexContact.cbModifyItem = null;
uexContact.cbDeleteItem = null;
uexContact.cbSearchItem = null;
uexContact.open=function(){
	uex.exec("uexContact.open/");
}
uexContact.addItem=function(){
	uex.exec("uexContact.addItem/"+uexJoin(arguments));
}
uexContact.searchItem=function(){
	uex.exec("uexContact.searchItem/"+uexJoin(arguments));
}
uexContact.deleteItem=function(){
	uex.exec("uexContact.deleteItem/"+uexJoin(arguments));
}
uexContact.modifyItem=function(){
	uex.exec("uexContact.modifyItem/"+uexJoin(arguments));
}

window.uexDevice={};
uexDevice.onOrientationChange = null;
uexDevice.cbGetInfo = null;
uexDevice.getInfo=function(){
	uex.exec("uexDevice.getInfo/"+uexJoin(arguments));
}
uexDevice.vibrate=function(){
	uex.exec("uexDevice.vibrate/"+uexJoin(arguments));
}
uexDevice.cancelVibrate=function(){
	uex.exec("uexDevice.cancelVibrate/");
}

window.uexEmail={};
uexEmail.open=function(){
	uex.exec("uexEmail.open/"+uexJoin(arguments));
}

window.uexLocation={};
uexLocation.onChange = null;
uexLocation.cbGetAddress = null;

uexLocation.openLocation=function(){
	uex.exec("uexLocation.openLocation/");
}
uexLocation.getAddress=function(){
	uex.exec("uexLocation.getAddress/"+uexJoin(arguments));
}
uexLocation.closeLocation = function(){
	uex.exec("uexLocation.closeLocation/");
}
window.uexPay={};
uexPay.onStatus = null;
uexPay.pay = function(){
	uex.exec("uexPay.pay/"+uexJoin(arguments));
}
uexPay.setPayInfo = function(){
	uex.exec("uexPay.setPayInfo/"+uexJoin(arguments));
}

window.uexMMS={};
uexMMS.open=function(){
	var num =encodeURIComponent(arguments[0]);
	var content = encodeURIComponent(arguments[2]);
	uex.exec("uexSMS.open/?"+num+uex_s_uex+content);
}

window.uexScanner={};
uexScanner.cbOpen = null;
uexScanner.open=function(){
	uex.exec("uexScanner.open/");
}
 
window.uexSensor={};
uexSensor.onAccelerometerChange=null;
uexSensor.onOrientationChange= null;
uexSensor.onMagneticChange =null;
uexSensor.onTemperatureChange = null;
uexSensor.onPressureChange = null;
uexSensor.onLightChange = null;
uexSensor.open=function(){
	uex.exec("uexSensor.open/"+uexJoin(arguments));
}
uexSensor.close=function(){
	uex.exec("uexSensor.close/"+uexJoin(arguments));
}


window.uexSMS={};
uexSMS.cbSend=null;
uexSMS.open=function(){
	uex.exec("uexSMS.open/"+uexJoin(arguments));
}
uexSMS.send=function(){
	uex.exec("uexSMS.send/"+uexJoin(arguments));
}
 
window.uexVideo={};
uexVideo.cbRecord = null;
uexVideo.open=function(){
	uex.exec("uexVideo.open/"+uexJoin(arguments));
}
uexVideo.record=function(){
	uex.exec("uexVideo.record/");
}

window.uexWidgetOne={};
uexWidgetOne.cbError = null;
uexWidgetOne.cbGetId = null;
uexWidgetOne.cbGetVersion = null;
uexWidgetOne.cbGetPlatform = null;
uexWidgetOne.cbGetWidgetNumber = null;
uexWidgetOne.cbGetWidgetInfo = null;
uexWidgetOne.cbGetCurrentWidgetInfo = null;
uexWidgetOne.cbCleanCache = null;
uexWidgetOne.cbGetMainWidgetId = null;
uexWidgetOne.getId=function(){
	uex.exec("uexWidgetOne.getId/");			 
}
uexWidgetOne.getVersion=function(){
	uex.exec("uexWidgetOne.getVersion/");			 
}
uexWidgetOne.getPlatform=function(){
	uex.exec("uexWidgetOne.getPlatform/");
	return 0;
}
uexWidgetOne.exit=function(){
	uex.exec("uexWidgetOne.exit/");			 
}
uexWidgetOne.cleanCache=function(){
	uex.exec("uexWidgetOne.cleanCache/");			 
}
uexWidgetOne.getWidgetNumber=function(){
	uex.exec("uexWidgetOne.getWidgetNumber/");
}
uexWidgetOne.getWidgetInfo=function(){
	uex.exec("uexWidgetOne.getWidgetInfo/"+uexJoin(arguments));				 
}
uexWidgetOne.getCurrentWidgetInfo=function(){
	uex.exec("uexWidgetOne.getCurrentWidgetInfo/");				 
}
uexWidgetOne.getMainWidgetId=function(){
	uex.exec("uexWidgetOne.getMainWidgetId/");			 
}

window.uexWidget={};
uexWidget.cbStartWidget = null;
uexWidget.cbRemoveWidget = null;
uexWidget.cbGetOpennerInfo = null;
uexWidget.cbCheckUpdate = null;
uexWidget.cbGetPushInfo = null;
uexWidget.onSuspend = null;
uexWidget.onResume = null;
uexWidget.onTerminate = null;
uexWidget.onKeyPressed = null;
uexWidget.startWidget=function(){
	uex.exec("uexWidget.startWidget/"+uexJoin(arguments));				 
}
uexWidget.finishWidget=function(){
	uex.exec("uexWidget.finishWidget/"+uexJoin(arguments));				 
}
uexWidget.removeWidget=function(){
	uex.exec("uexWidget.removeWidget/"+uexJoin(arguments));				 
}
uexWidget.getOpenerInfo=function(){
	uex.exec("uexWidget.getOpenerInfo/");
}
uexWidget.setMySpaceInfo=function(){
	uex.exec("uexWidget.setMySpaceInfo/"+uexJoin(arguments));
}
uexWidget.loadApp=function(){
	uex.exec("uexWidget.loadApp/"+uexJoin(arguments));				 
}
uexWidget.checkUpdate=function(){
	uex.exec("uexWidget.checkUpdate/");	
}
uexWidget.setPushNotifyCallback=function(){
	uex.exec("uexWidget.setPushNotifyCallback/");
}
uexWidget.getPushInfo = function(){
	uex.exec("uexWidget.getPushInfo/");
}

window.uexWindow={};
uexWindow.cbConfirm = null;
uexWindow.cbPrompt = null;
uexWindow.cbActionSheet = null;
uexWindow.cbGetState = null;
uexWindow.cbGetUrlQuery = null;
uexWindow.onOAuthInfo = null;
uexWindow.onStateChange = null;
uexWindow.onBounceStateChange = null;
uexWindow.didShowKeyboard = 0;
uexWindow.forward=function(){
	uex.exec("uexWindow.forward/");				 
}
uexWindow.back=function(){
	uex.exec("uexWindow.back/");				 
}
uexWindow.alert=function(){
	uex.exec("uexWindow.alert/"+uexJoin(arguments));		
}
uexWindow.confirm=function(){
	uex.exec("uexWindow.confirm/"+uexJoin(arguments));		
}
uexWindow.prompt=function(){
	uex.exec("uexWindow.prompt/"+uexJoin(arguments));		
}

uexWindow.actionSheet=function(){
	uex.exec("uexWindow.actionSheet/"+uexJoin(arguments));	
}

uexWindow.open=function(){
	uex.exec("uexWindow.open/"+uexJoin(arguments));		
}

uexWindow.close=function(){
	uex.exec("uexWindow.close/"+uexJoin(arguments));		
}

uexWindow.openSlibing=function() {
	uex.exec("uexWindow.openSlibing/"+uexJoin(arguments));	
}

uexWindow.closeSlibing=function(){
	uex.exec("uexWindow.closeSlibing/"+uexJoin(arguments));		
}
uexWindow.showSlibing=function(){
	uex.exec("uexWindow.showSlibing/"+uexJoin(arguments));		
}
uexWindow.evaluateScript=function(){
	uex.exec("uexWindow.evaluateScript/"+uexJoin(arguments));		
}
uexWindow.windowForward=function(){
	uex.exec("uexWindow.windowForward/"+uexJoin(arguments));				 
}
uexWindow.windowBack=function(){
	uex.exec("uexWindow.windowBack/"+uexJoin(arguments));				 
}
uexWindow.loadObfuscationData=function(){
	uex.exec("uexWindow.loadObfuscationData/"+uexJoin(arguments));	
}
uexWindow.toast=function(){
	uex.exec("uexWindow.toast/"+uexJoin(arguments));	
}
uexWindow.closeToast=function(){
	uex.exec("uexWindow.closeToast/");	
}
uexWindow.setReportKey=function(){
    uex.exec("uexWindow.setReportKey/"+uexJoin(arguments));
}
uexWindow.getState=function(){
	uex.exec("uexWindow.getState/");	
}
uexWindow.openPopover=function() {
	uex.exec("uexWindow.openPopover/"+uexJoin(arguments));	
}
uexWindow.closePopover=function(){
	uex.exec("uexWindow.closePopover/"+uexJoin(arguments));		
}
uexWindow.setPopoverFrame=function(){
	uex.exec("uexWindow.setPopoverFrame/"+uexJoin(arguments));	
}
uexWindow.evaluatePopoverScript=function(){
	uex.exec("uexWindow.evaluatePopoverScript/"+uexJoin(arguments));		
}
uexWindow.openAd=function(){
	uex.exec("uexWindow.openAd/"+uexJoin(arguments));
}
uexWindow.setBounce=function(){
	uex.exec("uexWindow.setBounce/"+uexJoin(arguments));		
}
uexWindow.showBounceView=function(){
	uex.exec("uexWindow.showBounceView/"+uexJoin(arguments));		
}
uexWindow.hiddenBounceView=function(){
	uex.exec("uexWindow.hiddenBounceView/"+uexJoin(arguments));		
}
uexWindow.resetBounceView=function(){
	uex.exec("uexWindow.resetBounceView/"+uexJoin(arguments));		
}
uexWindow.notifyBounceEvent = function(){
	uex.exec("uexWindow.notifyBounceEvent/"+uexJoin(arguments));	
}
uexWindow.getUrlQuery = function(){
	uex.exec("uexWindow.getUrlQuery/");	
	return null;
}
uexWindow.statusBarNotification = function(){
	uex.exec("uexWindow.statusBarNotification/"+uexJoin(arguments));	
}
uexWindow.preOpenStart = function() {
	uex.exec("uexWindow.preOpenStart/"+uexJoin(arguments));
}
uexWindow.preOpenFinish = function() {
	uex.exec("uexWindow.preOpenFinish/"+uexJoin(arguments));
}
uexWindow.beginAnimition = function() {
	uex.exec("uexWindow.beginAnimition/"+uexJoin(arguments));
}
uexWindow.setAnimitionDelay = function() {
	uex.exec("uexWindow.setAnimitionDelay/"+uexJoin(arguments));
}
uexWindow.setAnimitionDuration = function() {
	uex.exec("uexWindow.setAnimitionDuration/"+uexJoin(arguments));
}
uexWindow.setAnimitionCurve = function() {
	uex.exec("uexWindow.setAnimitionCurve/"+uexJoin(arguments));
}
uexWindow.setAnimitionRepeatCount = function() {
	uex.exec("uexWindow.setAnimitionRepeatCount/"+uexJoin(arguments));
}
uexWindow.setAnimitionAutoReverse = function() {
	uex.exec("uexWindow.setAnimitionAutoReverse/"+uexJoin(arguments));
}
uexWindow.makeTranslation = function() {
	uex.exec("uexWindow.makeTranslation/"+uexJoin(arguments));
}
uexWindow.makeScale = function() {
	uex.exec("uexWindow.makeScale/"+uexJoin(arguments));
}
uexWindow.makeRotate = function() {
	uex.exec("uexWindow.makeRotate/"+uexJoin(arguments));
}
uexWindow.commitAnimition = function() {
	uex.exec("uexWindow.commitAnimition/"+uexJoin(arguments));
}

window.uexSocketMgr={};
uexSocketMgr.onData = null;
uexSocketMgr.cbCreateTCPSocket = null;
uexSocketMgr.cbCreateUDPSocket = null;
uexSocketMgr.cbSendData = null;
uexSocketMgr.createUDPSocket=function(){
	uex.exec("uexSocketMgr.createUDPSocket/"+uexJoin(arguments));		
}
uexSocketMgr.createTCPSocket=function(){
	uex.exec("uexSocketMgr.createTCPSocket/"+uexJoin(arguments));		
}
uexSocketMgr.closeSocket=function(){
	uex.exec("uexSocketMgr.closeSocket/"+uexJoin(arguments));		
}
uexSocketMgr.setTimeOut=function(){
	uex.exec("uexSocketMgr.setTimeOut/"+uexJoin(arguments));		
}
uexSocketMgr.setInetAddressAndPort=function(){
	uex.exec("uexSocketMgr.setInetAddressAndPort/"+uexJoin(arguments));		
}
uexSocketMgr.sendData=function(){
	uex.exec("uexSocketMgr.sendData/"+uexJoin(arguments));		
}

window.uexFileMgr={};
uexFileMgr.cbCreateFile = null;
uexFileMgr.cbCreateDir = null;
uexFileMgr.cbOpenFile = null;
uexFileMgr.cbOpenDir = null;
uexFileMgr.cbDeleteFileByPath = null;
uexFileMgr.cbDeleteFileByID = null;
uexFileMgr.cbGetFileTypeByPath = null;
uexFileMgr.cbGetFileTypeById = null;
uexFileMgr.cbIsFileExistByPath = null;
uexFileMgr.cbIsFileExistById = null;
uexFileMgr.cbExplorer = null;
uexFileMgr.cbReadFile = null;
uexFileMgr.cbGetFileSize = null;
uexFileMgr.cbGetFilePath = null;
uexFileMgr.cbGetReaderOffset = null;
uexFileMgr.cbReadPercent = null;
uexFileMgr.cbReadPre = null;
uexFileMgr.cbReadNext = null;
uexFileMgr.cbGetFileRealPath =null;
uexFileMgr.createFile=function(){
	uex.exec("uexFileMgr.createFile/"+uexJoin(arguments));
}
uexFileMgr.createDir=function(){
	uex.exec("uexFileMgr.createDir/"+uexJoin(arguments));	
}
uexFileMgr.openFile=function(){
	uex.exec("uexFileMgr.openFile/"+uexJoin(arguments));	
}
uexFileMgr.openDir=function(){
	uex.exec("uexFileMgr.openDir/"+uexJoin(arguments));	
}
uexFileMgr.deleteFileByPath=function(){
	uex.exec("uexFileMgr.deleteFileByPath/"+uexJoin(arguments));	
}
uexFileMgr.deleteFileByID=function(){
	uex.exec("uexFileMgr.deleteFileByID/"+uexJoin(arguments));	
}
uexFileMgr.getFileTypeByPath=function(){
	uex.exec("uexFileMgr.getFileTypeByPath/"+uexJoin(arguments));	
}
uexFileMgr.getFileTypeByID=function(){	
	uex.exec("uexFileMgr.getFileTypeByID/"+uexJoin(arguments));	
}
uexFileMgr.isFileExistByPath=function(){
	uex.exec("uexFileMgr.isFileExistByPath/"+uexJoin(arguments));	
}
uexFileMgr.isFileExistByID=function(){
	uex.exec("uexFileMgr.isFileExistByID/"+uexJoin(arguments));	
}
uexFileMgr.explorer=function(){
	uex.exec("uexFileMgr.explorer/"+uexJoin(arguments));	
}
uexFileMgr.seekFile=function(){	
	uex.exec("uexFileMgr.seekFile/"+uexJoin(arguments));	
}
uexFileMgr.seekBeginOfFile=function(){	
	uex.exec("uexFileMgr.seekBeginOfFile/"+uexJoin(arguments));	
}
uexFileMgr.seekEndOfFile=function(){	
	uex.exec("uexFileMgr.seekEndOfFile/"+uexJoin(arguments));	
}
uexFileMgr.readFile=function(){	
	uex.exec("uexFileMgr.readFile/"+uexJoin(arguments));	
}
uexFileMgr.writeFile=function(){	
	uex.exec("uexFileMgr.writeFile/"+uexJoin(arguments));	
}
uexFileMgr.getFileSize=function(){	
	uex.exec("uexFileMgr.getFileSize/"+uexJoin(arguments));	
}
uexFileMgr.getFilePath=function(){	
	uex.exec("uexFileMgr.getFilePath/"+uexJoin(arguments));	
}
uexFileMgr.closeFile=function(){	
	uex.exec("uexFileMgr.closeFile/"+uexJoin(arguments));
}
uexFileMgr.getReaderOffset=function(){	
	uex.exec("uexFileMgr.getReaderOffset/"+uexJoin(arguments));
}
uexFileMgr.readPercent=function(){
	uex.exec("uexFileMgr.readPercent/"+uexJoin(arguments));
}
uexFileMgr.readNext=function(){
	uex.exec("uexFileMgr.readNext/"+uexJoin(arguments));
}
uexFileMgr.readPre=function(){	
	uex.exec("uexFileMgr.readPre/"+uexJoin(arguments));
}
uexFileMgr.getFileRealPath=function(){
	uex.exec("uexFileMgr.getFileRealPath/"+uexJoin(arguments));
}

window.uexZip={};
uexZip.cbZip = null;
uexZip.cbUnZip = null;
uexZip.zip=function(){
	uex.exec("uexZip.zip/"+uexJoin(arguments));				 
}
uexZip.unzip=function(){
	uex.exec("uexZip.unzip/"+uexJoin(arguments));				 
}

window.uexJabber={};
uexJabber.onData = null;
uexJabber.onFile = null;
uexJabber.cbLogin = null;
uexJabber.cbSendFile = null;
uexJabber.cbReceiveFile = null;
uexJabber.onOffLine = null;
uexJabber.login=function(){
	uex.exec("uexJabber.login/"+uexJoin(arguments));
}
uexJabber.sendData=function(){
	uex.exec("uexJabber.sendData/"+uexJoin(arguments));
}
uexJabber.sendFile=function(){
	uex.exec("uexJabber.sendFile/"+uexJoin(arguments));
}
uexJabber.receiveFile=function(){
	uex.exec("uexJabber.receiveFile/"+uexJoin(arguments));
}
uexJabber.refuseAcceptFile=function(){
	uex.exec("uexJabber.refuseAcceptFile/");
}
uexJabber.logout=function(){
	uex.exec("uexJabber.close/");
}

window.uexUploaderMgr={};
uexUploaderMgr.onStatus = null;
uexUploaderMgr.cbCreateUploader = null;

uexUploaderMgr.createUploader=function(){
	uex.exec("uexUploaderMgr.createUploader/"+uexJoin(arguments));
}
uexUploaderMgr.closeUploader=function(){
	uex.exec("uexUploaderMgr.closeUploader/"+uexJoin(arguments));
}
uexUploaderMgr.uploadFile=function(){
	uex.exec("uexUploaderMgr.uploadFile/"+uexJoin(arguments));
}
 
window.uexXmlHttpMgr={};
uexXmlHttpMgr.onData = null;
uexXmlHttpMgr.onPostProgress = null;
uexXmlHttpMgr.open=function(){
	uex.exec("uexXmlHttpMgr.open/"+uexJoin(arguments));
}
uexXmlHttpMgr.setPostData = function(){
	uex.exec("uexXmlHttpMgr.setPostData/"+uexJoin(arguments));
}
uexXmlHttpMgr.send = function(){
	uex.exec("uexXmlHttpMgr.send/"+uexJoin(arguments));
}
uexXmlHttpMgr.close = function(){
	uex.exec("uexXmlHttpMgr.close/"+uexJoin(arguments));
}

window.uexDownloaderMgr={};
uexDownloaderMgr.onStatus = null;
uexDownloaderMgr.cbCreateDownloader = null;
uexDownloaderMgr.cbGetInfo = null;
uexDownloaderMgr.createDownloader=function(){
	uex.exec("uexDownloaderMgr.createDownloader/"+uexJoin(arguments));
}
uexDownloaderMgr.download=function(){
	uex.exec("uexDownloaderMgr.download/"+uexJoin(arguments));
}
uexDownloaderMgr.closeDownloader=function(){	
	uex.exec("uexDownloaderMgr.closeDownloader/"+uexJoin(arguments));
}
uexDownloaderMgr.getInfo = function(){
	uex.exec("uexDownloaderMgr.getInfo/"+uexJoin(arguments));
}
uexDownloaderMgr.clearTask = function(){
	uex.exec("uexDownloaderMgr.clearTask/"+uexJoin(arguments));
}
window.uexLog = {};
uexLog.sendLog =function(inLog){
	uex.exec("uexLog.sendLog/"+uexJoin(arguments));
}

window.uexControl = {};
uexControl.cbOpenDatePicker = null;
uexControl.cbOpenTimePicker = null;

uexControl.openDatePicker = function(){
	uex.exec("uexControl.openDatePicker/"+uexJoin(arguments));
}
uexControl.openTimePicker = function(){
	uex.exec("uexControl.openTimePicker/"+uexJoin(arguments));
}

window.uexImageBrowser = {};
uexImageBrowser.cbPick = null;
uexImageBrowser.pick = function(){
	uex.exec("uexImageBrowser.pick/");
}
uexImageBrowser.open = function(){
	uex.exec("uexImageBrowser.open/"+uexJoin(arguments));
}
uexImageBrowser.save = function(){
	uex.exec("uexImageBrowser.save/"+uexJoin(arguments));
}

window.uexAppCenter = {};
uexAppCenter.cbGetSessionKey = null;
uexAppCenter.cbLoginOut = null;
uexAppCenter.appCenterLoginResult = function(){
	uex.exec("uexAppCenter.appCenterLoginResult/"+uexJoin(arguments));
}
uexAppCenter.downloadApp = function(){
	uex.exec("uexAppCenter.downloadApp/"+uexJoin(arguments));
}
uexAppCenter.loginOut = function(){
	uex.exec("uexAppCenter.loginOut/");
}
uexAppCenter.getSessionKey = function(){
	uex.exec("uexAppCenter.getSessionKey/");
}

window.uexConsole = {};
uexConsole.log = function(inLogInfo){
    uex.exec("uexConsole.log/"+uexJoin(arguments));
};
	
window.uexDataBaseMgr = {};
uexDataBaseMgr.cbOpenDataBase = null;
uexDataBaseMgr.cbExecuteSql = null;
uexDataBaseMgr.cbSelectSql = null;
uexDataBaseMgr.cbTransaction = null;
uexDataBaseMgr.cbCloseDataBase = null;
uexDataBaseMgr.openDataBase = function(){
    uex.exec("uexDataBaseMgr.openDataBase/"+uexJoin(arguments));
};
uexDataBaseMgr.executeSql = function(){
    uex.exec("uexDataBaseMgr.executeSql/"+uexJoin(arguments));
};
uexDataBaseMgr.selectSql = function(){
    uex.exec("uexDataBaseMgr.selectSql/"+uexJoin(arguments));
};
uexDataBaseMgr.transaction = function(inDBName,inOpId,inFunc){
	var temp = encodeURIComponent(inDBName)+uex_s_uex+encodeURIComponent(inOpId);
		uex.exec("uexDataBaseMgr.beginTransaction/?"+temp);	
		inFunc();
		uex.exec("uexDataBaseMgr.endTransaction/?"+temp);
}
uexDataBaseMgr.closeDataBase = function (){
	uex.exec("uexDataBaseMgr.closeDataBase/"+uexJoin(arguments));
}
window.uexClipboard = {};
uexClipboard.cbGetContent = null;
uexClipboard.copy = function(){
	uex.exec("uexClipboard.copy/"+uexJoin(arguments));
}
uexClipboard.getContent = function(){
	uex.exec("uexClipboard.getContent/");
}

