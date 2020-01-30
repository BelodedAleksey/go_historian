package main

const (
	strConn       = `Provider=iHOLEDB.iHistorian.1;Persist Security Info=False;USER ID=;Password=;Data Source=%ihistorian%;Mode=Read`
	alph          = "ABCDEFGHIJKLMNOPRSTUVWXYZ"
	maxSamples    = 5000   //ограничение на количество сэмплов на запрос, set rowcount=7199 - это максимум
	maxQueryCount = 100000 //ограничение при котором запрос нельзя делать
)

//пара время: значение
type sample struct {
	timestamp string
	value     float64
}

//промежуток времени
type timePeriod struct {
	start string
	end   string
}
