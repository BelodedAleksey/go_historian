package main

import (
	"database/sql"
	"math"
	"strconv"
	"strings"
	"time"

	"github.com/go-ole/go-ole"
	_ "github.com/mattn/go-adodb"
	"github.com/nanitefactory/winmb"
)

var percent float64

//Забираем данные
func fetchData(server string, tagnames []string, times []timePeriod, interval string) {

	newTimes := checkTimeSpans(times, interval)
	percent = 1.0 / float64(len(tagnames)*len(newTimes))
	//Запускаем рутину сбора
	go func() {
		data := getData(server, tagnames, newTimes, interval)
		export(data)
		winmb.MessageBoxPlain("Выборка", "Готова!!!")
	}()
}

//Разбиваем временные промежутки на промежутки с maxSamples
func checkTimeSpans(times []timePeriod, interval string) []timePeriod {
	p := string(interval[len(interval)-1])                               //указатель на часы, минуты и секунды
	parsedInterval, err := strconv.Atoi(strings.TrimSuffix(interval, p)) //количество часов, минут или секунд
	if err != nil {
		winmb.MessageBoxPlain("Ошибка в парсинге интервала: ", err.Error())
	}
	switch p {
	case "s":
		break
	case "m":
		parsedInterval *= 60
		break
	case "h":
		parsedInterval *= 3600
		break
	default:
		break
	}
	//parsedInterval в секундах
	duration := maxSamples * math.Pow(10, 9) * float64(parsedInterval)
	newTimes := []timePeriod{}
	for _, t := range times {
		tEnd := str2Time(t.end)
		nextTime := str2Time(t.start)
		var tLast string
		for nextTime.Before(tEnd) {
			tStart := time2Str(nextTime)
			nextTime = nextTime.Add(time.Duration(duration))
			if nextTime.After(tEnd) {
				tLast = t.end
			} else {
				tLast = time2Str(nextTime)
			}
			newTimes = append(newTimes, timePeriod{tStart, tLast})
		}
	}
	return newTimes
}

//Функция получения данных
func getData(server string, tagNames []string, times []timePeriod, interval string) map[string][]sample {
	var totalPerc float64 = 0.0
	data := map[string][]sample{}
	for _, tag := range tagNames {
		totalSamples := []sample{}
		for _, t := range times {
			samples := makeQuery(server, tag, t, interval)
			totalPerc += percent
			workPercent <- totalPerc
			totalSamples = append(totalSamples, samples...)
		}
		data[tag] = totalSamples
	}
	return data
}

//Запрос в базу для одного тэга
func makeQuery(server string, tagName string, period timePeriod, interval string) []sample {
	query := `select timestamp, value from ihrawdata where tagname like ` +
		tagName + ` and timestamp => '` +
		period.start + `' and timestamp < '` +
		period.end + `' and intervalmilliseconds = ` +
		interval
	conn := strings.ReplaceAll(strConn, `%ihistorian%`, server)
	db, err := sql.Open("adodb", conn)
	if err != nil {
		winmb.MessageBoxPlain("Ошибка соединения хисториана: ", err.Error())
	}
	defer db.Close()
	rows, err := db.Query(query)
	if err != nil {
		winmb.MessageBoxPlain("Ошибка запроса: ", err.Error())
	}
	defer rows.Close()

	data := []sample{}
	for rows.Next() {
		var timeStamp string
		var value interface{}
		err := rows.Scan(&timeStamp, &value)
		if err != nil {
			winmb.MessageBoxPlain("Ошибка скан строки запроса: ", err.Error())
		}
		valueOle := value.(*ole.VARIANT)
		t, err := time.Parse(time.RFC3339, timeStamp)
		if err != nil {
			winmb.MessageBoxPlain("Ошибка в парсинге времени: ", err.Error())
		}
		//Нужно округлить время
		t = t.Round(time.Second)
		s := sample{timestamp: time2Str(t), value: valueOle.Value().(float64)}
		data = append(data, s)
	}
	return data
}

//Запрос на тэги
func queryTags(server string) []interface{} {
	query := `select tagname, description from ihtags`
	conn := strings.ReplaceAll(strConn, `%ihistorian%`, server)
	db, err := sql.Open("adodb", conn)
	if err != nil {
		winmb.MessageBoxPlain("Ошибка соединения хисториана: ", err.Error())
	}
	defer db.Close()
	rows, err := db.Query(query)
	if err != nil {
		winmb.MessageBoxPlain("Ошибка запроса: ", err.Error())
	}
	defer rows.Close()

	data := []interface{}{}
	for rows.Next() {
		var tagname interface{}
		var description interface{}
		err := rows.Scan(&tagname, &description)
		if err != nil {
			winmb.MessageBoxPlain("Ошибка скан строки запроса: ", err.Error())
		}
		tagnameOle := tagname.(*ole.VARIANT)
		descriptionOle := description.(*ole.VARIANT)
		data = append(data, map[interface{}]interface{}{
			"name":        tagnameOle.Value().(string),
			"description": descriptionOle.Value().(string),
		})
	}
	return data
}
