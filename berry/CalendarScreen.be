import BaseScreen

class SecondsScreen: BaseScreen

    var img, img_idx

    def init(screenManager)
        super(self).init(screenManager);

        self.screenManager.change_font('MatrixDisplay3x5');
        var f = open("cal.bin","r")
        self.img = f.readbytes()
        f.close()
        self.img_idx = 0
    end

    def showImg(screen)
        var img_start = self.img_idx * 64 * 3
        var color = img_start
        for y:0..7
            for x:0..7
                var pixel = self.img[color]<<16 | self.img[color+1]<<8 | self.img[color+2]
                screen.set_matrix_pixel_color(x,y, pixel ,self.screenManager.brightness)
                color += 3
            end
        end
    end

    def drawBars(screen)
        var i = 10
        while i < 30
            screen.set_matrix_pixel_color(i,7, 0x303030 ,self.screenManager.brightness)
            screen.set_matrix_pixel_color(i+1,7, 0x303030 ,self.screenManager.brightness)
            i += 3
        end
    end


    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()

        self.showImg(screen)
        self.drawBars(screen)

        var rtc = tasmota.rtc()

        var day_str = tasmota.strftime('%d', rtc['local'])
        var x_offset = 1
        var y_offset = 1

        screen.print_string(day_str, x_offset, y_offset, true, 0x101010, self.screenManager.brightness) 

        var time_str = tasmota.strftime('%H:%M', rtc['local'])
        x_offset = 12
        y_offset = -1

        screen.print_string(time_str, x_offset, y_offset, true, self.screenManager.color, self.screenManager.brightness)
    end
end

return SecondsScreen
