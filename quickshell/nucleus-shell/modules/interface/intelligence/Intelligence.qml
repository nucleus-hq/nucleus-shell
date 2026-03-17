import "../../components/morphedPolygons/material-shapes.js" as MaterialShapes
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.functions
import qs.modules.components
import qs.modules.components.morphedPolygons
import qs.services

FloatingWindow {
    id: appWin
    color: Appearance.m3colors.m3background

    property bool initialChatSelected: false
    property bool chatsInitialized: false
    property string activeSystemPrompt: ""
    property string activePromptLabel: ""

    readonly property var availableModels: [
        "openai/gpt-3.5-turbo",
        "openai/gpt-4",
        "openai/gpt-4o",
        "openai/gpt-4o-mini",
        "anthropic/claude-3.5-sonnet",
        "anthropic/claude-3-haiku",
        "meta-llama/llama-3.3-70b-instruct:free",
        "deepseek/deepseek-r1-0528:free",
        "qwen/qwen3-coder:free"
    ]

    readonly property var promptPresets: [
        { label: "Assistant",  prompt: "You are a helpful assistant." },
        { label: "Perplexity", prompt: Zenith.perplexityPrompt },
        { label: "Coder",      prompt: "You are an expert software engineer. Give concise, correct code with brief explanations. Prefer modern idioms and best practices." },
        { label: "Concise",    prompt: "Answer as briefly and directly as possible. No filler, no preamble, no sign-off." },
        { label: "Socratic",   prompt: "Guide the user to the answer through questions rather than giving it directly. Encourage critical thinking." },
        { label: "ELI5",       prompt: "Explain everything as if the user is five years old. Use simple words, short sentences, and fun analogies." },
        { label: "Skeptic",    prompt: "Challenge assumptions, highlight weak points, and ask for evidence. Be constructively critical." },
        { label: "Translator", prompt: "Translate all user messages to English. If already English, translate to French." },
        { label: "No system",  prompt: "" }
    ]

    readonly property var slashCommands: [
        { cmd: "/model",  hint: "switch model for this session" },
        { cmd: "/prompt", hint: "set or clear the system prompt" },
        { cmd: "/clear",  hint: "erase all message history" },
        { cmd: "/help",   hint: "list all commands" }
    ]

    function switchModel(name) {
        let exact = name.trim();
        for (let i = 0; i < availableModels.length; i++) {
            if (availableModels[i] === exact) {
                modelSelector.currentIndex = i;
                Zenith.currentModel = availableModels[i];
                return availableModels[i];
            }
        }
        let lower = exact.toLowerCase();
        for (let i = 0; i < availableModels.length; i++) {
            let m = availableModels[i].toLowerCase();
            if (m.endsWith("/" + lower) || m === lower) {
                modelSelector.currentIndex = i;
                Zenith.currentModel = availableModels[i];
                return availableModels[i];
            }
        }
        Zenith.currentModel = exact;
        return exact;
    }

    function appendMessage(sender, message) {
        messageModel.append({ "sender": sender, "message": message });
        scrollToBottom();
    }

    function updateChatsList(files) {
        let existing = {};
        for (let i = 0; i < chatListModel.count; i++)
            existing[chatListModel.get(i).name] = true;
        for (let file of files) {
            let name = file.trim();
            if (!name.length) continue;
            if (name.endsWith(".txt"))  name = name.slice(0, -4);
            if (name.endsWith(".json")) continue;
            if (!existing[name]) chatListModel.append({ "name": name });
            delete existing[name];
        }
        for (let name in existing) {
            for (let i = 0; i < chatListModel.count; i++) {
                if (chatListModel.get(i).name === name) { chatListModel.remove(i); break; }
            }
        }
        let hasDefault = false;
        for (let i = 0; i < chatListModel.count; i++)
            if (chatListModel.get(i).name === "default") hasDefault = true;
        if (!hasDefault) {
            chatListModel.insert(0, { "name": "default" });
            FileUtils.createFile(FileUtils.trimFileProtocol(Directories.config) + "/zenith/chats/default.txt");
        }
    }

    function scrollToBottom() {
        chatView.forceLayout();
        chatView.positionViewAtEnd();
    }

    function sendMessage() {
        if (userInput.text === "" || Zenith.loading) return;
        commandPopup.visible = false;
        Zenith.pendingInput = userInput.text;
        appendMessage("You", userInput.text);
        userInput.text = "";
        Zenith.loading = true;
        Zenith.send();
    }

    function sendCommand(cmd) {
        Zenith.pendingInput = cmd;
        Zenith.loading = true;
        Zenith.send();
    }

    function handleCmdResponse(text) {
        if (!text.startsWith("cmd: ")) return false;
        let body = text.slice(5).trim();
        if (body.startsWith("model=")) {
            let resolved = switchModel(body.slice(6).trim());
            appendMessage("System", "Switched to " + resolved);
        } else if (body.startsWith("prompt=")) {
            let p = body.slice(7).trim();
            if (p === "<none>") {
                appWin.activeSystemPrompt = "";
                appWin.activePromptLabel = "";
                appendMessage("System", "System prompt cleared.");
            } else {
                appWin.activeSystemPrompt = p;
                let match = appWin.promptPresets.find(pr => pr.prompt === p);
                appWin.activePromptLabel = match ? match.label : p.slice(0, 40) + (p.length > 40 ? "…" : "");
                appendMessage("System", "System prompt set.");
            }
        } else if (body === "prompt cleared") {
            appWin.activeSystemPrompt = "";
            appWin.activePromptLabel = "";
            appendMessage("System", "System prompt cleared.");
        } else if (body === "cleared") {
            messageModel.clear();
            appWin.activeSystemPrompt = "";
            appWin.activePromptLabel = "";
        } else if (body.startsWith("help")) {
            appendMessage("System", text.slice(5).replace(/\n\s*/g, "\n").trim());
        } else if (body.startsWith("error")) {
            appendMessage("System", "⚠ " + body.slice(6).trim());
        } else {
            appendMessage("System", body);
        }
        return true;
    }

    function loadChatHistory(chatName) {
        messageModel.clear();
        appWin.activeSystemPrompt = "";
        Zenith.loadChat(chatName);
    }

    function selectDefaultChat() {
        let defaultIndex = -1;
        for (let i = 0; i < chatListModel.count; i++)
            if (chatListModel.get(i).name === "default") { defaultIndex = i; break; }
        if (defaultIndex !== -1) {
            chatSelector.currentIndex = defaultIndex;
            Zenith.currentChat = "default";
            loadChatHistory("default");
        } else if (chatListModel.count > 0) {
            chatSelector.currentIndex = 0;
            Zenith.currentChat = chatListModel.get(0).name;
            loadChatHistory(Zenith.currentChat);
        }
    }

    visible: Globals.states.intelligenceWindowOpen

    onVisibleChanged: {
        if (!visible) return;
        chatsInitialized = false;
        messageModel.clear();
    }

    IpcHandler {
        function openWindow()  { Globals.states.intelligenceWindowOpen = true;  }
        function closeWindow() { Globals.states.intelligenceWindowOpen = false; }
        target: "intelligence"
    }

    ListModel { id: messageModel }
    ListModel { id: chatListModel }

    ColumnLayout {
        spacing: Metrics.spacing(8)
        anchors.centerIn: parent
        visible: !Config.runtime.misc.intelligence.enabled

        StyledText {
            visible: !Config.runtime.misc.intelligence.enabled
            text: "Intelligence is disabled!"
            Layout.leftMargin: Metrics.margin(24)
            font.pixelSize: Metrics.fontSize("huge")
        }
        StyledText {
            visible: !Config.runtime.misc.intelligence.enabled
            text: "Go to the settings to enable intelligence"
        }
    }

    StyledRect {
        anchors.fill: parent
        color: "transparent"
        visible: Config.runtime.misc.intelligence.enabled

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.margin(16)
            spacing: Metrics.spacing(10)

            // Chat selector row
            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                StyledDropDown {
                    id: chatSelector
                    Layout.fillWidth: true
                    model: chatListModel
                    textRole: "name"
                    Layout.preferredHeight: 40
                    onCurrentIndexChanged: {
                        if (currentIndex < 0) return;
                        let name = chatListModel.get(currentIndex).name;
                        if (name === Zenith.currentChat) return;
                        Zenith.currentChat = name;
                        loadChatHistory(name);
                    }
                }

                StyledButton {
                    icon: "add"
                    Layout.preferredWidth: 40
                    onClicked: {
                        let name = "new-chat-" + chatListModel.count;
                        let path = FileUtils.trimFileProtocol(Directories.config) + "/zenith/chats/" + name + ".txt";
                        FileUtils.createFile(path, function(success) {
                            if (success) {
                                chatListModel.append({ "name": name });
                                chatSelector.currentIndex = chatListModel.count - 1;
                                Zenith.currentChat = name;
                                messageModel.clear();
                                appWin.activeSystemPrompt = "";
                            }
                        });
                    }
                }

                StyledButton {
                    icon: "edit"
                    Layout.preferredWidth: 40
                    enabled: chatSelector.currentIndex >= 0
                    onClicked: renameDialog.open()
                }

                StyledButton {
                    icon: "delete"
                    Layout.preferredWidth: 40
                    enabled: chatSelector.currentIndex >= 0 && chatSelector.currentText !== "default"
                    onClicked: {
                        let name = chatSelector.currentText;
                        let path = FileUtils.trimFileProtocol(Directories.config) + "/zenith/chats/" + name + ".txt";
                        FileUtils.removeFile(path, function(success) {
                            if (success) {
                                chatListModel.remove(chatSelector.currentIndex);
                                selectDefaultChat();
                            }
                        });
                    }
                }
            }

            // Model selector row
            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                StyledDropDown {
                    id: modelSelector
                    Layout.fillWidth: true
                    model: appWin.availableModels
                    currentIndex: 0
                    Layout.preferredHeight: 40
                    onCurrentTextChanged: Zenith.currentModel = currentText
                }

                StyledButton {
                    icon: "close_fullscreen"
                    Layout.preferredWidth: 40
                    onClicked: {
                        Quickshell.execDetached(["nucleus", "ipc", "call", "intelligence", "closeWindow"]);
                        Globals.visiblility.sidebarLeft = true;
                    }
                }
            }

            // Active prompt indicator
            StyledRect {
                Layout.fillWidth: true
                height: 28
                radius: Metrics.radius("small")
                color: Appearance.m3colors.m3tertiaryContainer
                visible: appWin.activeSystemPrompt.length > 0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Metrics.margin(10)
                    anchors.rightMargin: Metrics.margin(6)
                    spacing: Metrics.spacing(6)

                    StyledText { text: "⚙"; font.pixelSize: Metrics.fontSize(11) }
                    StyledText {
                        Layout.fillWidth: true
                        text: appWin.activePromptLabel.length > 0 ? appWin.activePromptLabel : appWin.activeSystemPrompt
                        font.pixelSize: Metrics.fontSize(11)
                        elide: Text.ElideRight
                    }
                    StyledButton {
                        text: "✕"
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 20
                        font.pixelSize: Metrics.fontSize(10)
                        onClicked: sendCommand("/prompt clear")
                    }
                }
            }

            // Chat area
            StyledRect {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Metrics.radius("normal")
                color: Appearance.m3colors.m3surfaceContainerLow

                // Empty state
                Item {
                    anchors.centerIn: parent
                    visible: messageModel.count === 0 && !Zenith.loading
                    width: 200
                    height: emptyCol.implicitHeight

                    Column {
                        id: emptyCol
                        width: parent.width
                        spacing: Metrics.spacing(16)
                        anchors.horizontalCenter: parent.horizontalCenter

                        Item {
                            width: 90
                            height: 90
                            anchors.horizontalCenter: parent.horizontalCenter

                            MorphedPolygon {
                                anchors.fill: parent
                                color: Appearance.m3colors.m3secondaryContainer
                                roundedPolygon: MaterialShapes.getCookie12Sided()

                                NumberAnimation on rotation {
                                    from: 0; to: 360
                                    duration: 20000
                                    loops: Animation.Infinite
                                    running: true
                                }
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: "neurology"
                                font.family: "Material Symbols Rounded"
                                font.pixelSize: Metrics.fontSize(34)
                                opacity: 0.8
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Metrics.spacing(5)
                            anchors.horizontalCenter: parent.horizontalCenter

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Intelligence"
                                font.pixelSize: Metrics.fontSize(17)
                                font.weight: Font.Medium
                            }

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width
                                text: "Type \"/\" for commands"
                                font.pixelSize: Metrics.fontSize(12)
                                opacity: 0.45
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    ListView {
                        id: chatView
                        model: messageModel
                        spacing: Metrics.spacing(8)
                        anchors.fill: parent
                        anchors.margins: Metrics.margin(12)
                        clip: true

                        delegate: Item {
                            width: chatView.width
                            height: bubble.implicitHeight + 6
                            Component.onCompleted: chatView.forceLayout()

                            Row {
                                width: parent.width
                                spacing: Metrics.spacing(8)

                                Item {
                                    width: sender === "AI" || sender === "System"
                                           ? 0 : parent.width * 0.2
                                }

                                StyledRect {
                                    id: bubble
                                    radius: Metrics.radius("normal")
                                    color: {
                                        if (sender === "You")    return Appearance.m3colors.m3primaryContainer;
                                        if (sender === "System") return Appearance.m3colors.m3surfaceContainerHighest;
                                        return Appearance.m3colors.m3surfaceContainerHigh;
                                    }
                                    implicitWidth: Math.min(textItem.implicitWidth + 20, chatView.width * 0.8)
                                    implicitHeight: textItem.implicitHeight
                                    anchors.right: sender === "You" ? parent.right : undefined
                                    anchors.left:  sender !== "You" ? parent.left  : undefined
                                    anchors.topMargin: Metrics.margin(2)

                                    TextEdit {
                                        id: textItem
                                        text: message
                                        wrapMode: TextEdit.Wrap
                                        textFormat: TextEdit.MarkdownText
                                        readOnly: true
                                        font.pixelSize: Metrics.fontSize(sender === "System" ? 13 : 16)
                                        font.italic: sender === "System"
                                        color: Appearance.syntaxHighlightingTheme
                                        padding: Metrics.padding(8)
                                        anchors.fill: parent
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.RightButton
                                        onClicked: {
                                            let p = Qt.createQmlObject(
                                                'import Quickshell; import Quickshell.Io; Process { command: ["wl-copy", "' + message + '"] }',
                                                parent
                                            );
                                            p.running = true;
                                        }
                                    }
                                }

                                Item {
                                    width: sender === "You" ? 0 : parent.width * 0.2
                                }
                            }
                        }
                    }
                }
            }

            // Input area
            StyledRect {
                Layout.fillWidth: true
                height: 50
                radius: Metrics.radius("normal")
                color: Appearance.m3colors.m3surfaceContainer

                // Command popup
                StyledRect {
                    id: commandPopup
                    visible: false
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.top
                    anchors.bottomMargin: Metrics.margin(4)
                    radius: Metrics.radius("normal")
                    color: Appearance.m3colors.m3surfaceContainerHigh
                    border.color: Appearance.colors.colOutline
                    border.width: 1
                    height: Math.min(popupFlick.contentHeight + Metrics.margin(10), 260)
                    clip: true
                    z: 10

                    Flickable {
                        id: popupFlick
                        anchors.fill: parent
                        anchors.margins: Metrics.margin(5)
                        contentHeight: popupCol.implicitHeight
                        clip: true

                        ColumnLayout {
                            id: popupCol
                            width: parent.width
                            spacing: 1

                            StyledText {
                                visible: filteredCommands.count > 0
                                text: "Commands"
                                font.pixelSize: Metrics.fontSize(10); opacity: 0.5
                                Layout.leftMargin: Metrics.margin(6); Layout.topMargin: Metrics.margin(4)
                            }
                            Repeater {
                                model: filteredCommands
                                delegate: StyledRect {
                                    Layout.fillWidth: true; height: 32; radius: Metrics.radius("small")
                                    color: cmdHov.containsMouse ? Appearance.m3colors.m3primaryContainer : "transparent"
                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: Metrics.margin(10); anchors.rightMargin: Metrics.margin(10); spacing: Metrics.spacing(10)
                                        StyledText { text: cmd; font.pixelSize: Metrics.fontSize(13); font.family: "monospace" }
                                        StyledText { text: hint; font.pixelSize: Metrics.fontSize(12); opacity: 0.5; Layout.fillWidth: true; elide: Text.ElideRight }
                                    }
                                    MouseArea {
                                        id: cmdHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: { userInput.text = cmd + " "; userInput.forceActiveFocus(); userInput.cursorPosition = userInput.text.length; }
                                    }
                                }
                            }

                            Rectangle {
                                visible: filteredCommands.count > 0 && filteredModels.count > 0
                                Layout.fillWidth: true; height: 1; color: Appearance.colors.colOutline; opacity: 0.3
                                Layout.topMargin: Metrics.margin(2); Layout.bottomMargin: Metrics.margin(2)
                            }

                            StyledText {
                                visible: filteredModels.count > 0
                                text: "Models"; font.pixelSize: Metrics.fontSize(10); opacity: 0.5
                                Layout.leftMargin: Metrics.margin(6)
                            }
                            Repeater {
                                model: filteredModels
                                delegate: StyledRect {
                                    Layout.fillWidth: true; height: 32; radius: Metrics.radius("small")
                                    color: modHov.containsMouse ? Appearance.m3colors.m3primaryContainer : "transparent"
                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: Metrics.margin(10); anchors.rightMargin: Metrics.margin(10); spacing: Metrics.spacing(10)
                                        StyledText { text: modelName; font.pixelSize: Metrics.fontSize(13); font.family: "monospace" }
                                        StyledText { visible: modelName === modelSelector.currentText; text: "active"; font.pixelSize: Metrics.fontSize(11); opacity: 0.5 }
                                    }
                                    MouseArea {
                                        id: modHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            let r = switchModel(modelName);
                                            commandPopup.visible = false; userInput.text = "";
                                            appendMessage("System", "Switched to " + r);
                                            userInput.forceActiveFocus();
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                visible: (filteredCommands.count > 0 || filteredModels.count > 0) && filteredPrompts.count > 0
                                Layout.fillWidth: true; height: 1; color: Appearance.colors.colOutline; opacity: 0.3
                                Layout.topMargin: Metrics.margin(2); Layout.bottomMargin: Metrics.margin(2)
                            }

                            StyledText {
                                visible: filteredPrompts.count > 0
                                text: "Prompt presets"; font.pixelSize: Metrics.fontSize(10); opacity: 0.5
                                Layout.leftMargin: Metrics.margin(6)
                            }
                            Repeater {
                                model: filteredPrompts
                                delegate: StyledRect {
                                    Layout.fillWidth: true; height: 32; radius: Metrics.radius("small")
                                    color: prmHov.containsMouse ? Appearance.m3colors.m3primaryContainer : "transparent"
                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: Metrics.margin(10); anchors.rightMargin: Metrics.margin(10); spacing: Metrics.spacing(10)
                                        StyledText { text: presetLabel; font.pixelSize: Metrics.fontSize(13) }
                                        StyledText { text: presetPrompt.length > 0 ? presetLabel + " preset" : "(clear prompt)"; font.pixelSize: Metrics.fontSize(12); opacity: 0.5; Layout.fillWidth: true; elide: Text.ElideRight }
                                        StyledText { visible: presetPrompt === appWin.activeSystemPrompt; text: "active"; font.pixelSize: Metrics.fontSize(11); opacity: 0.5 }
                                    }
                                    MouseArea {
                                        id: prmHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            let c = presetPrompt.length > 0 ? "/prompt " + presetPrompt : "/prompt clear";
                                            commandPopup.visible = false; userInput.text = "";
                                            sendCommand(c); userInput.forceActiveFocus();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Metrics.margin(6)
                    spacing: Metrics.spacing(10)

                    StyledTextField {
                        id: userInput
                        Layout.fillWidth: true
                        placeholderText: "Type a message or /command…"
                        font.pixelSize: Metrics.iconSize(14)
                        padding: Metrics.spacing(8)

                        onTextChanged: {
                            let t = text.trim();
                            if (t.startsWith("/")) {
                                filteredCommands.update(t);
                                filteredModels.update(t);
                                filteredPrompts.update(t);
                                commandPopup.visible =
                                    filteredCommands.count > 0 ||
                                    filteredModels.count  > 0 ||
                                    filteredPrompts.count > 0;
                            } else {
                                commandPopup.visible = false;
                            }
                        }

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Escape) {
                                commandPopup.visible = false;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (event.modifiers & Qt.ShiftModifier)
                                    insert("\n");
                                else
                                    sendMessage();
                                event.accepted = true;
                            }
                        }
                    }

                    StyledButton {
                        text: "Send"
                        enabled: userInput.text.trim().length > 0 && !Zenith.loading
                        opacity: enabled ? 1 : 0.5
                        onClicked: sendMessage()
                    }
                }
            }
        }

        // Rename dialog — original
        Dialog {
            id: renameDialog
            title: "Rename Chat"
            modal: true; visible: false
            standardButtons: Dialog.NoButton
            x: (appWin.width - 360) / 2
            y: (appWin.height - 160) / 2
            width: 360; height: 200

            ColumnLayout {
                anchors.fill: parent; anchors.margins: Metrics.margin(16); spacing: Metrics.spacing(12)

                StyledText { text: "Enter a new name for the chat"; font.pixelSize: Metrics.fontSize(18); horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }

                StyledTextField {
                    id: renameInput; Layout.fillWidth: true; placeholderText: "New name"
                    filled: false; highlight: false; text: chatSelector.currentText
                    font.pixelSize: Metrics.fontSize(16); Layout.preferredHeight: 45; padding: Metrics.padding(8)
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: Metrics.spacing(12); Layout.alignment: Qt.AlignRight
                    StyledButton { text: "Cancel"; Layout.preferredWidth: 80; onClicked: renameDialog.close() }
                    StyledButton {
                        text: "Rename"; Layout.preferredWidth: 100
                        enabled: renameInput.text.trim().length > 0 && renameInput.text !== chatSelector.currentText
                        onClicked: {
                            let oldName = chatSelector.currentText;
                            let newName = renameInput.text.trim();
                            let oldPath = FileUtils.trimFileProtocol(Directories.config) + "/zenith/chats/" + oldName + ".txt";
                            let newPath = FileUtils.trimFileProtocol(Directories.config) + "/zenith/chats/" + newName + ".txt";
                            FileUtils.renameFile(oldPath, newPath, function(success) {
                                if (success) {
                                    chatListModel.set(chatSelector.currentIndex, { "name": newName });
                                    Zenith.currentChat = newName;
                                    renameDialog.close();
                                }
                            });
                        }
                    }
                }
            }

            background: StyledRect { color: Appearance.m3colors.m3surfaceContainer; radius: Metrics.radius("normal"); border.color: Appearance.colors.colOutline; border.width: 1 }
            header: StyledRect { color: Appearance.m3colors.m3surfaceContainer; radius: Metrics.radius("normal"); border.color: Appearance.colors.colOutline; border.width: 1 }
        }

        StyledText {
            text: "Thinking…"
            visible: Zenith.loading
            color: Appearance.colors.colSubtext
            font.pixelSize: Metrics.fontSize(14)
            anchors { left: parent.left; bottom: parent.bottom; leftMargin: Metrics.margin(22); bottomMargin: Metrics.margin(76) }
        }
    }

    ListModel {
        id: filteredCommands
        function update(input) {
            clear();
            let lower = input.toLowerCase();
            for (let item of appWin.slashCommands)
                if (lower === "/" || item.cmd.startsWith(lower))
                    append({ "cmd": item.cmd, "hint": item.hint });
        }
    }

    ListModel {
        id: filteredModels
        function update(input) {
            clear();
            let lower = input.toLowerCase().trim();
            if (!lower.startsWith("/model")) return;
            let partial = lower.startsWith("/model ") ? lower.slice(7).trim() : "";
            for (let m of appWin.availableModels)
                if (partial === "" || m.toLowerCase().includes(partial))
                    append({ "modelName": m });
        }
    }

    ListModel {
        id: filteredPrompts
        function update(input) {
            clear();
            let lower = input.toLowerCase().trim();
            if (!lower.startsWith("/prompt")) return;
            let partial = lower.startsWith("/prompt ") ? lower.slice(8).trim() : "";
            for (let p of appWin.promptPresets)
                if (partial === "" || p.label.toLowerCase().includes(partial))
                    append({ "presetLabel": p.label, "presetPrompt": p.prompt });
        }
    }

    Connections {
        target: Zenith

        function onChatsListed(text) {
            let lines = text.split(/\r?\n/);
            let previousChat = Zenith.currentChat;
            updateChatsList(lines);
            if (!chatsInitialized) {
                chatsInitialized = true;
                let index = -1;
                for (let i = 0; i < chatListModel.count; i++) {
                    if (chatListModel.get(i).name === previousChat) { index = i; break; }
                }
                if (index === -1 && chatListModel.count > 0) index = 0;
                if (index !== -1) {
                    chatSelector.currentIndex = index;
                    Zenith.currentChat = chatListModel.get(index).name;
                    loadChatHistory(Zenith.currentChat);
                }
                return;
            }
            let stillExists = false;
            for (let i = 0; i < chatListModel.count; i++) {
                if (chatListModel.get(i).name === Zenith.currentChat) { stillExists = true; break; }
            }
            if (!stillExists && chatListModel.count > 0) {
                chatSelector.currentIndex = 0;
                Zenith.currentChat = chatListModel.get(0).name;
                loadChatHistory(Zenith.currentChat);
            }
        }

        function onAiReply(text) {
            let full = text.trim();
            if (full.startsWith("cmd: "))       handleCmdResponse(full);
            else if (full.startsWith("wiki: ")) appendMessage("AI", full.slice(6));
            else if (full.startsWith("out: "))  appendMessage("AI", full.slice(5));
            else                                appendMessage("AI", full.length > 5 ? full.slice(5) : full);
            Zenith.loading = false;
        }

        function onChatLoaded(text) {
            let lines = text.split(/\r?\n/);
            let batch = [];
            for (let l of lines) {
                let line = l.trim();
                if (!line.length) continue;
                let u = line.match(/^\[\d{4}-.*\] User: (.*)$/);
                let a = line.match(/^\[\d{4}-.*\] AI: (.*)$/);
                if (u)      batch.push({ "sender": "You", "message": u[1] });
                else if (a) batch.push({ "sender": "AI",  "message": a[1] });
                else if (batch.length) batch[batch.length - 1].message += "\n" + line;
            }
            messageModel.clear();
            for (let m of batch) messageModel.append(m);
            scrollToBottom();
        }
    }
}