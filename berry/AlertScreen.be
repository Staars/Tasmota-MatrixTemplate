import fonts

import BaseScreen
import MatrixController

class AlertScreen: BaseScreen
    var textPosition, text
    var scrollsLeft
    var img, img_idx

    def init(screenManager)
        super(self).init(screenManager);

        self.screenManager.change_font('Arcade');

        self.textPosition = 0
        self.text = ">>"
        self.duration = 15 # override default, because we need more time here
        var f = open("caution.bin","r")
        self.img = f.readbytes()
        f.close()
        self.img_idx = 0
        self.needs_render = true
    end

    def loop()
        if self.needs_render == true return end

        self.offscreenController.matrix.scroll(1, self.screenManager.outShiftBuffer) # 1 - to left, output - inOutBuf, no input buffer
        self.matrixController.matrix.scroll(1, self.screenManager.trashBuffer, self.screenManager.outShiftBuffer) # 1 - to left, unused output, input inOutBuf
        self.matrixController.leds.show();
        self.scrollsLeft -= 1
        if self.scrollsLeft > 0 return end
        self.nextChar()

    end

    def showImg(screen)
        var img_start = self.img_idx * 64 * 3
        var color = img_start
        for tile:0..2
            for y:0..7
                for x:0..7
                    var pixel = self.img[color]<<16 | self.img[color+1]<<8 | self.img[color+2]
                    screen.set_matrix_pixel_color(x+(tile*12),y, pixel ,self.screenManager.brightness)
                    color += 3
                end
            end
            color = img_start
        end
    end

    def nextChar()
        self.scrollsLeft = self.matrixController.font_width + 1

        self.offscreenController.clear()
        self.offscreenController.print_char(self.text[self.textPosition], 0, 0, true, self.screenManager.color, self.screenManager.brightness)
        self.textPosition += 1

        if self.textPosition == (size(self.text)-1) self.textPosition = 0 end
    end

    def render(segue)
        if self.needs_render == false return end
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()

        self.showImg(screen)
        self.scrollsLeft = 8

        # self.nextChar()
        self.needs_render = false
    end

end

return AlertScreen
