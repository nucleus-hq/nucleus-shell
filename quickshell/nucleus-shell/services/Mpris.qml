import QtQuick
import Quickshell
import Quickshell.Services.Mpris
pragma Singleton

Singleton {
    id: root

    property alias activePlayer: instance.activePlayer
    property bool isPlaying: activePlayer ? activePlayer.playbackState === MprisPlaybackState.Playing : false
    property string title: activePlayer ? activePlayer.trackTitle : "No Media"
    property string artist: activePlayer ? activePlayer.trackArtist : ""
    property string album: activePlayer ? activePlayer.trackAlbum : ""
    property string artUrl: activePlayer ? activePlayer.trackArtUrl : ""
    property double position: 0
    property double length: activePlayer ? activePlayer.length : 0
    property var _players: Mpris.players.values
    property int playerCount: _players.length
    property var playerList: {
        let list = [];
        for (let p of _players) {
            list.push({
                "identity": p.identity || p.desktopEntry || "Unknown",
                "desktopEntry": p.desktopEntry || "",
                "player": p
            });
        }
        return list;
    }
    property string currentPlayerName: activePlayer ? (activePlayer.identity || activePlayer.desktopEntry || "Unknown") : ""
    property bool manualSelection: false

    function setPosition(pos) {
        if (activePlayer)
            activePlayer.position = pos;

    }

    function selectPlayer(player) {
        if (player) {
            instance.activePlayer = player;
            manualSelection = true;
        }
    }

    function selectNextPlayer() {
        const players = Mpris.players.values;
        if (players.length <= 1)
            return ;

        const currentIndex = players.indexOf(activePlayer);
        const nextIndex = (currentIndex + 1) % players.length;
        selectPlayer(players[nextIndex]);
    }

    function selectPreviousPlayer() {
        const players = Mpris.players.values;
        if (players.length <= 1)
            return ;

        const currentIndex = players.indexOf(activePlayer);
        const prevIndex = (currentIndex - 1 + players.length) % players.length;
        selectPlayer(players[prevIndex]);
    }

    function updateActivePlayer() {
        const players = Mpris.players.values;
        if (manualSelection && instance.activePlayer && players.includes(instance.activePlayer))
            return ;

        if (manualSelection && instance.activePlayer && !players.includes(instance.activePlayer))
            manualSelection = false;

        const playing = players.find((p) => {
            return p.playbackState === MprisPlaybackState.Playing;
        });
        if (playing) {
            instance.activePlayer = playing;
        } else if (players.length > 0) {
            if (!instance.activePlayer || !players.includes(instance.activePlayer))
                instance.activePlayer = players[0];

        } else {
            instance.activePlayer = null;
        }
    }

    function playPause() {
        if (activePlayer && activePlayer.canTogglePlaying)
            activePlayer.togglePlaying();

    }

    function next() {
        if (activePlayer && activePlayer.canGoNext)
            activePlayer.next();

    }

    function previous() {
        if (activePlayer && activePlayer.canGoPrevious)
            activePlayer.previous();

    }

    Component.onCompleted: updateActivePlayer()

    QtObject {
        id: instance

        property var players: Mpris.players.values
        property var activePlayer: null
    }

    Timer {
        interval: 1000
        running: root.isPlaying
        repeat: true
        onTriggered: {
            if (activePlayer)
                root.position = activePlayer.position;
        }
    }

    // Player selection runs only on player list changes (via Connections below),
    // not on every tick — avoids constant polling when nothing is playing
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: updateActivePlayer()
    }

    Connections {
        function onValuesChanged() {
            root._players = Mpris.players.values;
            updateActivePlayer();
        }

        target: Mpris.players
    }

}