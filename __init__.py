from mycroft import MycroftSkill, intent_file_handler


class CodeServer(MycroftSkill):
    def __init__(self):
        MycroftSkill.__init__(self)

    @intent_file_handler('server.code.intent')
    def handle_server_code(self, message):
        self.speak_dialog('server.code')


def create_skill():
    return CodeServer()

