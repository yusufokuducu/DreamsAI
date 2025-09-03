class Command:
    def execute(self): raise NotImplementedError
    def undo(self): raise NotImplementedError

class CommandHistory:
    def __init__(self, main_window):
        self.undo_stack = []
        self.redo_stack = []
        self.main_window = main_window
        self.update_actions()

    def execute(self, command):
        command.execute()
        self.undo_stack.append(command)
        self.redo_stack.clear()
        self.update_actions()

    def undo(self):
        if not self.undo_stack: return
        command = self.undo_stack.pop()
        command.undo()
        self.redo_stack.append(command)
        self.update_actions()

    def redo(self):
        if not self.redo_stack: return
        command = self.redo_stack.pop()
        command.execute()
        self.undo_stack.append(command)
        self.update_actions()
    
    def update_actions(self):
        self.main_window.undo_action.setEnabled(bool(self.undo_stack))
        self.main_window.redo_action.setEnabled(bool(self.redo_stack))

class AddItemCommand(Command):
    def __init__(self, scene, item):
        self.scene = scene
        self.item = item

    def execute(self):
        self.scene.addItem(self.item)

    def undo(self):
        self.scene.removeItem(self.item)

class DeleteItemCommand(Command):
    def __init__(self, scene, item):
        self.scene = scene
        self.item = item

    def execute(self):
        self.scene.removeItem(self.item)

    def undo(self):
        self.scene.addItem(self.item)

class MoveItemCommand(Command):
    def __init__(self, item, old_pos, new_pos):
        self.item = item
        self.old_pos = old_pos
        self.new_pos = new_pos

    def execute(self):
        self.item.setPos(self.new_pos)

    def undo(self):
        self.item.setPos(self.old_pos)

class ChangePropertyCommand(Command):
    def __init__(self, item, data_index, old_value, new_value, timeline_panel):
        self.item = item
        self.data_index = data_index
        self.old_value = old_value
        self.new_value = new_value
        self.timeline_panel = timeline_panel

    def execute(self):
        self.item.setData(self.data_index, self.new_value)
        self.timeline_panel.item_selected.emit(self.item)

    def undo(self):
        self.item.setData(self.data_index, self.old_value)
        self.timeline_panel.item_selected.emit(self.item)
