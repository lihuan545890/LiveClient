/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_qpidnetwork_anchor_httprequest_RequstJniSchedule */

#ifndef _Included_com_qpidnetwork_anchor_httprequest_RequstJniSchedule
#define _Included_com_qpidnetwork_anchor_httprequest_RequstJniSchedule
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    GetScheduleInviteList
 * Signature: (IIILcom/qpidnetwork/livemodule/httprequest/OnGetScheduleInviteListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_GetScheduleInviteList
  (JNIEnv *, jclass, jint, jint, jint, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    AcceptScheduledInvite
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_AcceptScheduledInvite
  (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    RejectScheduledInvite
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_RejectScheduledInvite
  (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    GetCountOfUnreadAndPendingInvite
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetCountOfUnreadAndPendingInviteCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_GetCountOfUnreadAndPendingInvite
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    GetScheduledAcceptNum
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetScheduledAcceptNumCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_GetScheduledAcceptNum
        (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    AcceptInstanceInvite
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnAcceptInstanceInviteCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_AcceptInstanceInvite
        (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    RejectInstanceInvite
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_RejectInstanceInvite
  (JNIEnv *, jclass, jstring, jstring, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    CancelInstantInvite
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_CancelInstantInvite
        (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    SetRoomCountDown
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_SetRoomCountDown
        (JNIEnv *, jclass, jstring, jobject);

#ifdef __cplusplus
}
#endif
#endif