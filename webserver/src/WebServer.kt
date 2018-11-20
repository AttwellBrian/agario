package com.brianattwell.asteroids

import com.google.gson.GsonBuilder
import io.ktor.http.cio.websocket.Frame
import io.ktor.http.cio.websocket.WebSocketSession
import java.util.concurrent.ConcurrentHashMap

// TODO: rename
class WebServer(val gameStateMachine: GameStateMachine) {

    val gson = GsonBuilder().create()
    val members = ConcurrentHashMap<String, WebSocketSession>()

    fun removePlayer(member: String) {
        members.remove(member)
        gameStateMachine.remove(member)
    }

    fun memberJoin(member: String, socket: WebSocketSession) {
        members.put(member, socket)
        gameStateMachine.addNewUser(member)
    }

    suspend fun sendUserView(userView: UserView) {
        val socket = members.get(userView.id)!!
        val json = gson.toJson(userView)
        socket.send(Frame.Text(json))

    }


}