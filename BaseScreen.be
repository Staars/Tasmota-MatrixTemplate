import introspect

class BaseScreen
    var screenManager
    var matrixController, offscreenController
    var needs_render

    var hasValue
    var value

    def init(screenManager)
        print(classname(self), "Init")

        self.screenManager = screenManager
        self.matrixController = screenManager.matrixController
        self.offscreenController = screenManager.offscreenController
    end

    def deinit()
        print(classname(self), "DeInit")
    end

    def loop()
    end

    def render(segue)
    end

end

return BaseScreen
