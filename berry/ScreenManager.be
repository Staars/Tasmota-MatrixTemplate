import MatrixController

import BasicScreen
import DateScreen
import LongTextScreen
import SecondsScreen
import NetScreen
import ImgScreen
import StartScreen
import CalendarScreen
import WeatherScreen
import AlertScreen

var Screens = [
    StartScreen, # only shown once
    WeatherScreen,
    CalendarScreen,
    LongTextScreen,
    DateScreen,
    BasicScreen,
    SecondsScreen,
    NetScreen,
    ImgScreen,
    AlertScreen, # only shown on event
];

class ScreenManager
    var matrixController, offscreenController
    var brightness
    var color
    var currentScreen
    var currentScreenIdx
    var nextScreen, segueCtr, loop_50ms, outShiftBuffer, trashBuffer
    var changeCounter


    def init()
        import fonts
        import gpio
        print("ScreenManager Init")

        var matrix_width = 32
        var matrix_height = 8

        self.matrixController = MatrixController(matrix_width, matrix_height, gpio.pin(gpio.WS2812, 0))
        self.offscreenController = MatrixController(matrix_width, matrix_height,1) # 1 is a dummy pin, that MUST not be configured for WS2812

        self.brightness = 200;
        self.color = fonts.palette[self.getColor()]

        self.matrixController.print_string("booting", 0, 0, true, self.color, self.brightness)
        self.matrixController.draw()

        self.currentScreenIdx = 0
        self.currentScreen = Screens[self.currentScreenIdx](self)
        self.loop_50ms = /->self.currentScreen.loop()
        self.outShiftBuffer = bytes(-(matrix_width * 3)) # or height, if height > width
        self.trashBuffer = bytes(-(matrix_width * 3))
        self.changeCounter = 0
        self.segueCtr = 0

        gpio.pin_mode(14,gpio.INPUT_PULLUP) # 3
        gpio.pin_mode(26,gpio.INPUT_PULLUP) # 1
        gpio.pin_mode(27,gpio.INPUT_PULLUP) # 2
    end

    def getColor()
        if tasmota.wifi()["up"] == true
            return 'white'
        else
            return 'white' # for demo use white anyway
        end
    end

    def change_font(font)
        self.matrixController.change_font(font);
        self.offscreenController.change_font(font);
    end

    def on_button_prev()
        self.initSegue(-1)
    end

    def on_button_action()
        import introspect
        var handleActionMethod = introspect.get(self.currentScreen, "handleActionButton");

        if handleActionMethod != nil
            self.currentScreen.handleActionButton()
        end
    end

    def on_button_next()
        self.initSegue(1)
    end

    def initSegue(steps, screenIdx)
        if screenIdx
            self.currentScreenIdx = screenIdx # info/alert message or other override
            print("override screen with alert")
        else
            self.currentScreenIdx = (self.currentScreenIdx + steps) % (size(Screens) - 1)
        end
        if self.currentScreenIdx == 0 self.currentScreenIdx = 1 end # optional: show screen 0 only after reboot
        self.nextScreen = Screens[self.currentScreenIdx](self)
        self.nextScreen.render(true)
        self.segueCtr = self.matrixController.row_size
        var direction = steps > 0 ? 0 : 2
        self.loop_50ms = /->self.doSegue(direction)
    end

    def doSegue(direction)
        self.offscreenController.matrix.scroll(direction, self.outShiftBuffer)
        self.matrixController.matrix.scroll(direction, self.trashBuffer, self.outShiftBuffer)
        self.matrixController.draw()

        self.segueCtr -= 1
        if self.segueCtr == 0
            self.currentScreen = self.nextScreen
            self.nextScreen = nil
            self.loop_50ms = /->self.currentScreen.loop()
            self.redraw()
        end
    end

    def autoChangeScreen()
        if self.changeCounter == self.currentScreen.duration
            self.on_button_next()
            self.changeCounter = 0
        end
        self.changeCounter += 1
    end

    def alert(message)
        self.changeCounter = 0 # prevent overlapping auto change
        self.initSegue(1,size(Screens) - 1) # last element of screens array
        self.nextScreen.text += message
        print(self.nextScreen.text)
    end

    # This will be called automatically every 1s by the tasmota framework
    def every_second()
        if self.segueCtr != 0 return end
        self.update_brightness_from_sensor();
        self.redraw()
        self.autoChangeScreen()
    end

    def every_50ms()
        self.loop_50ms()
    end

    def every_100ms()
        if self.segueCtr != 0 return end
        # if gpio.digital_read(14) == 0
        #     self.on_button_next()
        # elif gpio.digital_read(27) == 0
        #     self.on_button_action()
        # elif gpio.digital_read(26) == 0
        #     self.on_button_prev()
        # end
    end

    def redraw()
        self.currentScreen.render()
        self.matrixController.draw()
    end

    def update_brightness_from_sensor()
        # use internal or external sensor/time data to adapt brightness
        self.brightness = 255;
    end

    def save_before_restart()
        # This function may be called on other occasions than just before a restart
        # => We need to make sure that it is in fact a restart
        if tasmota.global.restart_flag == 1 || tasmota.global.restart_flag == 2
            self.currentScreen = nil
            self.matrixController.change_font('MatrixDisplay3x5')
            self.matrixController.clear()

            self.matrixController.print_string("Reboot...", 0, 1, true, self.color, self.brightness)
            self.matrixController.draw()
            print("This is just to add some delay")
            print("   ")
            print("According to all known laws of aviation, there is no way a bee should be able to fly.")
            print("Its wings are too small to get its fat little body off the ground.")
            print("The bee, of course, flies anyway, because bees don't care what humans think is impossible")
        end
    end
end

return ScreenManager
