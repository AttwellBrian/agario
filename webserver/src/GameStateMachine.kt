package com.brianattwell.asteroids

import kotlin.math.cos
import kotlin.math.sin

data class UserState(var xposition: Double, var yposition: Double, var rotation: Double, val user: String)

data class OpponentView(var xposition: Double, var yposition: Double, var size: Double)
data class UserView(var opponents: List<OpponentView>, val size: Double, var id: String)
data class UserInput(val mouseX: Double, val mouseY: Double)
//data class UserInput(var xposition: Double, var yposition: Double)


class GameStateMachine(var lastTimeStep: Long) {

    val users = ArrayList<UserState>()
    val SPEED = 0.01

    fun addNewUser(userId: String) {
        // need some form of locking...
        val newUser = UserState(0.0, 0.0, 0.0, userId)
        users.add(newUser)
    }

    /**
     * Update all positions based on current direction.
     */
    fun timeStep(newTimeStep: Long) {
        val deltaTimestamp = lastTimeStep - newTimeStep
        lastTimeStep = newTimeStep

        users.forEach {
            val newX = it.xposition + sin(it.rotation) * deltaTimestamp * SPEED
            val newY = it.yposition + cos(it.rotation) * deltaTimestamp * SPEED
            it.xposition = newX
            it.yposition = newY
        }
    }

    fun viewModel(): List<UserView> {
        return users.map {user ->
                val opponents = listOf(OpponentView(100.0, 100.0, 20.0))
                val offsetOpponents = opponents
                    .map { OpponentView(it.xposition - user.xposition,
                        it.yposition - user.yposition,
                        it.size) }
                UserView(offsetOpponents, 50.0, id=user.user)
            }
    }

    fun backup() {

    }

    fun remove(member: String) {
        users.removeIf { it.user.equals(member) }
    }

    fun moveUser(gameIdentifier: String, userInput: UserInput) {
        // TODO: hack toghether something racy..
        users.filter { it.user.equals(gameIdentifier) }.first()?.let {

        }
    }

    // TODO: create a static restore method...


}