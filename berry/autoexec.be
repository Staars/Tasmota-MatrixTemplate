import ScreenManager

_screenManager = ScreenManager()

# tasmota.set_timer(20000,def() import fonts _screenManager.color = fonts.palette[_screenManager.getColor()] end)
tasmota.set_timer(18000, def() _screenManager.alert("Test alert - could be from MQTT") end)

tasmota.add_driver(_screenManager)
