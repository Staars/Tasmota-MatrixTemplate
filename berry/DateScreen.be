import BaseScreen

class DateScreen: BaseScreen
    var showYear
    var scrollDirection, scrollIdx

    def init(screenManager)
        super(self).init(screenManager);

        self.screenManager.change_font('Mono65');

        self.showYear = false
        self.needs_render = true

        self.scrollDirection = 0
        self.scrollIdx = 0
    end

    def handleActionButton()
        self.showYear = !self.showYear
    end

    def loop()
        if self.needs_render == true return end

        self.matrixController.matrix.scroll(self.scrollDirection,self.screenManager.outShiftBuffer)
        self.matrixController.leds.show();
        self.scrollIdx += 1
        if self.scrollIdx%32 == 0 self.scrollDirection += 1 end
        if self.scrollDirection > 3 self.scrollDirection = 0 end

    end


    def render(segue)
        if self.needs_render == false return end
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        var rtc = tasmota.rtc()

        var time_data = tasmota.time_dump(rtc['local'])
        var x_offset = 0
        var y_offset = 0

        var date_str = ""
        if self.showYear != true
            date_str = format("%02i.%02i", time_data['day'], time_data['month'])
        else
            date_str = str(time_data["year"])
            x_offset += 2
        end

        screen.print_string(date_str, x_offset, y_offset, false, self.screenManager.color, self.screenManager.brightness)

        if segue == true return end
        self.needs_render = false
    end
end

return DateScreen
