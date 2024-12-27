import fonts

import BaseScreen
import MatrixController

class LongTextScreen: BaseScreen
    var trashOutBuf
    var textPosition, text
    var scrollsLeft

    def init(screenManager)
        super(self).init(screenManager);

        self.screenManager.change_font('TinyUnicode');

        self.textPosition = 0
        self.text = " THIS IS A VERY LONG TEXT MESSAGE, THAT WOULD NEVER FIT ON THE SCREEN OF A ULANZI CLOCK !  "
        self.duration = 20 # override default, because we need more time here
        self.can_render = true
        self.trashOutBuf = bytes(-(3 * 8)) # height * RGB
    end

    def loop()
        if self.can_render == true return end

        self.offscreenController.matrix.scroll(1, self.screenManager.outShiftBuffer) # 1 - to left, output - inOutBuf, no input buffer
        self.matrixController.matrix.scroll(1, self.trashOutBuf, self.screenManager.outShiftBuffer) # 1 - to left, unused output, input inOutBuf
        self.matrixController.leds.show();
        self.scrollsLeft -= 1
        if self.scrollsLeft > 0 return end
        self.nextChar()

    end

    def nextChar()

        self.offscreenController.clear()
        self.scrollsLeft = self.offscreenController.print_char(self.text[self.textPosition], 0, 0, true, self.screenManager.color, self.screenManager.brightness) + 1
        self.textPosition += 1

        if self.textPosition == (size(self.text)-1) self.textPosition = 0 end
    end

    def render(segue)
        if self.can_render == false return end
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()

        self.nextChar()
        # if segue == true
        #     return # do nott
        # end
        self.can_render = false
    end

end

return LongTextScreen
