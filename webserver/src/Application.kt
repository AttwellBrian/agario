package com.brianattwell.asteroids

import com.google.gson.GsonBuilder
import freemarker.cache.ClassTemplateLoader
import io.ktor.application.Application
import io.ktor.application.ApplicationCall
import io.ktor.application.call
import io.ktor.application.install
import io.ktor.features.ContentNegotiation
import io.ktor.freemarker.FreeMarker
import io.ktor.freemarker.FreeMarkerContent
import io.ktor.gson.gson
import io.ktor.http.ContentType
import io.ktor.http.cio.websocket.Frame
import io.ktor.http.cio.websocket.readText
import io.ktor.response.respond
import io.ktor.response.respondText
import io.ktor.routing.get
import io.ktor.routing.routing
import io.ktor.websocket.webSocket
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.channels.ClosedReceiveChannelException
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.css.CSSBuilder
import kotlinx.html.CommonAttributeGroupFacade
import kotlinx.html.FlowOrMetaDataContent
import kotlinx.html.style
import java.time.Clock
import java.time.Duration
import java.util.*

data class IndexData(val items: List<Int>)
data class AccountData(val uniqueIdentifer: String)

fun main(args: Array<String>): Unit = io.ktor.server.netty.EngineMain.main(args)

@Suppress("unused") // Referenced in application.conf
@kotlin.jvm.JvmOverloads
fun Application.module(testing: Boolean = false) {


    install(io.ktor.websocket.WebSockets) {
        pingPeriod = Duration.ofSeconds(15)
        timeout = Duration.ofSeconds(15)
        maxFrameSize = Long.MAX_VALUE
        masking = false
    }

    install(ContentNegotiation) {
        gson {
        }
    }

    install(FreeMarker) {
        templateLoader = ClassTemplateLoader(this::class.java.classLoader, "templates")
    }

    val gson = GsonBuilder().create()
    val gameStateMachine = GameStateMachine(Clock.systemUTC().millis())
    val webServer = WebServer(gameStateMachine)

    routing {
        get("/") {
            call.respond(FreeMarkerContent("index.html", mapOf("data" to IndexData(listOf(1, 2, 3))), ""))
        }


        // Also see https://ktor.io/quickstart/guides/chat.html for patterns.
        // See https://github.com/ktorio/ktor-samples/blob/master/app/chat/resources/web/main.js
        // TODO: https://github.com/ktorio/ktor-samples/blob/master/app/chat/resources/web/main.js
        webSocket("/ws") { // this: webSocket
            // TODO: get unique identifier

            val gameIdentifier = UUID.randomUUID().toString()
            webServer.memberJoin(gameIdentifier, this)

            println("Created player $gameIdentifier")

            //val gson = gson.toJson(UserState(0.3, 0.2, 0.1))
            //send(Frame.Text(gson))
            while (true) {
                try {
                    val frame = incoming.receive()

                    if (frame is Frame.Text) {
                        // TODO: pase an AccountData
                        // NOTE: This is necessary for some reason...
                        var textFromClient = frame.readText()
                        println("Text from client $textFromClient")
                    }
                } catch (e: ClosedReceiveChannelException) {
                    webServer.removePlayer(gameIdentifier)
                }

                //val json = gson.toJson(UserState(0.3, 0.2, 0.1))
                //send(Frame.Text(json))

            }
        }

        // Ideally this would be over UDP
        // Websocket might make sense.
        // But for now I don't think it makes much sense
        // https://gafferongames.com/post/why_cant_i_send_udp_packets_from_a_browser/
        get("/user-state") {
            call.respond(mapOf("hello" to "world"))
        }
    }

    // launch new coroutine in background and continue
    GlobalScope.launch {
        // TODO: will need to change the way we handle coroutines.
        // TO AVOID BLOCKING ON BOTTLE NECK.
        while (true) {
            delay(1000L / 30) // non-blocking delay for 1 second
            val viewModels = gameStateMachine.viewModel()
            viewModels
                //.parallelStream()
                .forEach {
                    println("Sending message to player ${it.id}")
                    webServer.sendUserView(it)
            }

            gameStateMachine.timeStep(Clock.systemUTC().millis())
        }
    }

}

fun FlowOrMetaDataContent.styleCss(builder: CSSBuilder.() -> Unit) {
    style(type = ContentType.Text.CSS.toString()) {
        +CSSBuilder().apply(builder).toString()
    }
}

fun CommonAttributeGroupFacade.style(builder: CSSBuilder.() -> Unit) {
    this.style = CSSBuilder().apply(builder).toString().trim()
}

suspend inline fun ApplicationCall.respondCss(builder: CSSBuilder.() -> Unit) {
    this.respondText(CSSBuilder().apply(builder).toString(), ContentType.Text.CSS)
}
