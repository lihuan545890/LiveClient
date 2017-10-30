package com.qpidnetwork.livemodule.httprequest;


/**
 * 注册登录等认证模块接口
 * Created by Hunter Mun on 2017/5/17.
 */

public class RequestJniAuthorization {

    /**
     * 登录
     * @param manId
     * @param qnTokenId
     * @param deviceId
     * @param callback
     * @return
     */
    static public long Login(String manId, String qnTokenId, String deviceId, OnRequestLoginCallback callback){
    	return Login(manId, qnTokenId, deviceId, android.os.Build.MODEL, android.os.Build.MANUFACTURER, callback);
    }
    static private native long Login(String manId, String userSid, String deviceId, String model, String manufacturer, OnRequestLoginCallback callback);
    
    /**
     * 注销
     * @param callback
     * @return
     */
    static public native long Logout(OnRequestCallback callback);
    
    /**
     * 上传push tokenId
     * @param pushTokenId
     * @param callback
     * @return
     */
    static public native long UploadPushTokenId(String pushTokenId, OnRequestCallback callback);

}