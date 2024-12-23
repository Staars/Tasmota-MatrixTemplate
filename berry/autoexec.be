import ScreenManager

_screenManager = ScreenManager()

tasmota.set_timer(20000,def() import fonts _screenManager.color = fonts.palette[_screenManager.getColor()] end)

tasmota.add_driver(_screenManager)
